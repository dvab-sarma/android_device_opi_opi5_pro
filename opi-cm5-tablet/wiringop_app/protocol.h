// SPDX-License-Identifier: Apache-2.0
#pragma once
#include <stdint.h>
#include <errno.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/un.h>
#include <string.h>
#define WOP_MAGIC 0x574f5031u
#define WOP_MAX 16384
#define WOP_SOCKET "/dev/socket/wiringop"
enum { WOP_SETUP=1,WOP_READ,WOP_WRITE,WOP_MODE,WOP_PULL,WOP_SERIAL_OPEN,WOP_SERIAL_CLOSE,WOP_SERIAL_AVAIL,WOP_SERIAL_GET,WOP_SERIAL_PUTS,WOP_I2C_OPEN,WOP_I2C_READ8,WOP_I2C_WRITE8,WOP_SPI_OPEN,WOP_SPI_RW,WOP_COMMAND };
struct WopRequest { uint32_t magic,op; int32_t arg[4]; uint32_t length; };
struct WopResponse { int32_t result; uint32_t length; };
static inline int wop_io(int fd,void *p,size_t n,int writing) {
 char *s=(char*)p;
 while(n) { ssize_t k=writing?write(fd,s,n):read(fd,s,n);if(k<0&&errno==EINTR)continue;if(k<=0)return -1;s+=k;n-=k; } return 0;
}
static inline int wop_call(uint32_t op,int a,int b,int c,int d,const void *in,uint32_t n,void *out,uint32_t *outlen) {
 uint32_t capacity=outlen?*outlen:0;if(outlen)*outlen=0;
 if(n>WOP_MAX)return -EINVAL;
 int fd=socket(AF_UNIX,SOCK_STREAM|SOCK_CLOEXEC,0);if(fd<0)return -errno;
 struct timeval timeout={10,0};setsockopt(fd,SOL_SOCKET,SO_RCVTIMEO,&timeout,sizeof(timeout));setsockopt(fd,SOL_SOCKET,SO_SNDTIMEO,&timeout,sizeof(timeout));
 struct sockaddr_un addr;memset(&addr,0,sizeof(addr));addr.sun_family=AF_UNIX;strcpy(addr.sun_path,WOP_SOCKET);
 if(connect(fd,(struct sockaddr*)&addr,sizeof(addr))<0) {int e=errno;close(fd);return -e;}
 struct WopRequest req={WOP_MAGIC,op,{a,b,c,d},n};struct WopResponse res={0,0};
 int bad=wop_io(fd,&req,sizeof(req),1)||(n&&wop_io(fd,(void*)in,n,1))||wop_io(fd,&res,sizeof(res),0);
 if(bad||res.length>WOP_MAX||(res.length&&(!out||!outlen||res.length>capacity))) {close(fd);return -EPROTO;}
 if(res.length&&wop_io(fd,out,res.length,0)) {close(fd);return -EIO;}
 if(outlen)*outlen=res.length;close(fd);return res.result;
}
