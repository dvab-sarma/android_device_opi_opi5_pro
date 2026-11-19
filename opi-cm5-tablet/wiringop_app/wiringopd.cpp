// SPDX-License-Identifier: Apache-2.0
#include "protocol.h"
#include <wiringPi.h>
#include <wiringSerial.h>
#include <wiringPiI2C.h>
#include <linux/spi/spidev.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <dirent.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <algorithm>
#include <atomic>
#include <mutex>
#include <sstream>
#include <string>
#include <thread>
#include <vector>
static int handles[64],types[64],spi[1]={-1};
static std::mutex gpio_lock;
static std::atomic<bool> blinking{false};
static std::thread blinker;
static int store(int fd,int type) {if(fd<0)return -errno;for(int i=0;i<64;i++)if(!types[i]){handles[i]=fd;types[i]=type;return i+100;}close(fd);return -EMFILE;}
static int handle(int h,int type) {return h>=100&&h<164&&types[h-100]==type?handles[h-100]:-1;}
static bool header_pwm(const std::string& chip) {char path[PATH_MAX];std::string p="/sys/class/pwm/"+chip+"/device";if(!realpath(p.c_str(),path))return false;return strstr(path,"fd8b0010")||strstr(path,"fd8b0030");}
static std::string list(const char*path,int kind) {
 std::vector<std::string> names;DIR*d=opendir(path);if(!d)return "";dirent*e;
 while((e=readdir(d))) {std::string n=e->d_name;bool ok=false;
  if(kind==1)ok=n=="spidev0.0"||n=="spidev0.1";
  if(kind==2)ok=n=="i2c-5";
  if(kind==3)ok=n=="ttyS4"||n=="ttyS6";
  if(kind==4)ok=n.rfind("pwmchip",0)==0&&header_pwm(n);
  if(ok)names.push_back(kind==4?n:std::string(path)+"/"+n);
 }closedir(d);std::sort(names.begin(),names.end());std::string out;for(const auto&n:names)out+=n+"\n";return out;
}
static int readall(std::string& out) {
 int p[2];if(pipe2(p,O_CLOEXEC)<0)return -errno;pid_t child=fork();
 if(child==0){dup2(p[1],1);close(p[0]);close(p[1]);execl("/vendor/bin/gpio","gpio","readall",(char*)nullptr);_exit(127);}
 close(p[1]);if(child<0){close(p[0]);return -errno;}char b[1024];ssize_t n;
 while((n=read(p[0],b,sizeof(b)))>0)if(out.size()+n<=WOP_MAX)out.append(b,n);
 close(p[0]);int status=0;while(waitpid(child,&status,0)<0&&errno==EINTR){}return WIFEXITED(status)&&WEXITSTATUS(status)==0?0:-EIO;
}
static int blink(bool on) {
 if(!on){blinking=false;if(blinker.joinable())blinker.join();return 0;}
 if(blinking.exchange(true))return 0;
 if(blinker.joinable())blinker.join();
 blinker=std::thread([]{int v=0;while(blinking){ {std::lock_guard<std::mutex> g(gpio_lock);for(int p=0;p<17;p++){pinMode(p,OUTPUT);digitalWrite(p,v);}}v=!v;for(int i=0;i<20&&blinking;i++)usleep(10000);}std::lock_guard<std::mutex> g(gpio_lock);for(int p=0;p<17;p++)digitalWrite(p,LOW);});return 0;
}
static int command(const std::string&cmd,std::string&out) {
 // Recognize the original app's operations; never execute supplied shell text.
 if(cmd=="gpiox readall"||cmd=="gpio readall")return readall(out);
 if(cmd=="blink_all_gpio &")return blink(true);
 if(cmd=="pkill blink_all_gpio")return blink(false);
 if(cmd=="ls /dev/spidev*"){out=list("/dev",1);return 0;}
 if(cmd=="ls /dev/i2c*"||cmd=="ls /dev/i2c-*"){out=list("/dev",2);return 0;}
 if(cmd=="ls /dev/tty[A,S]*"){out=list("/dev",3);return 0;}
 if(cmd=="ls /sys/class/pwm"){out=list("/sys/class/pwm",4);return 0;}
 if(cmd.rfind("chmod 666 /dev/",0)==0)return 0; // Broker owns device access; no chmod required.
 const std::string prefix="ls -ld /sys/class/pwm/",suffix="/device|awk '{print $NF}' |xargs basename";
 if(cmd.rfind(prefix,0)==0&&cmd.size()>prefix.size()+suffix.size()&&cmd.compare(cmd.size()-suffix.size(),suffix.size(),suffix)==0) {
  std::string chip=cmd.substr(prefix.size(),cmd.size()-prefix.size()-suffix.size());if(!header_pwm(chip))return -EPERM;
  char path[PATH_MAX];std::string p="/sys/class/pwm/"+chip+"/device";if(!realpath(p.c_str(),path))return -errno;char*base=strrchr(path,'/');out=std::string(base?base+1:path)+"\n";return 0;
 }
 std::istringstream stream(cmd);std::string echo,value,arrow,path,extra;
 if(stream>>echo>>value>>arrow>>path && !(stream>>extra)&&echo=="echo"&&arrow==">") {
  if(value.empty()||value.find_first_not_of("0123456789")!=std::string::npos||value.size()>10)return -EINVAL;
  unsigned long long val=strtoull(value.c_str(),nullptr,10);if(val>1000000000)return -ERANGE;
  const std::string root="/sys/class/pwm/";if(path.rfind(root,0)!=0)return -EPERM;
  std::string tail=path.substr(root.size());auto slash=tail.find('/');if(slash==std::string::npos)return -EINVAL;
  std::string chip=tail.substr(0,slash),attr=tail.substr(slash+1);if(!header_pwm(chip))return -EPERM;
  bool valid=attr=="export"||attr=="unexport";
  if(!valid)for(int c=0;c<4;c++)for(const char*a:{"period","duty_cycle","enable"})if(attr=="pwm"+std::to_string(c)+"/"+a)valid=true;
  if(!valid)return -EPERM;int fd=open(path.c_str(),O_WRONLY|O_CLOEXEC);if(fd<0)return -errno;
  int r=write(fd,value.data(),value.size())==(ssize_t)value.size()?0:-EIO;close(fd);return r;
 }return -EOPNOTSUPP;
}
static int dispatch(const WopRequest&r,const char*data,std::string&out) {
 int a=r.arg[0],b=r.arg[1],c=r.arg[2],d=r.arg[3],fd;
 if(r.op==WOP_SETUP)return 0;
 if(r.op==WOP_COMMAND)return command(std::string(data,r.length),out);
 if(r.op>=WOP_READ&&r.op<=WOP_PULL){if(a<0||a>=17)return -EINVAL;std::lock_guard<std::mutex>g(gpio_lock);
  if(r.op==WOP_READ)return digitalRead(a);
  if(r.op==WOP_WRITE){if(b!=0&&b!=1)return -EINVAL;digitalWrite(a,b);return 0;}
  if(r.op==WOP_MODE){if(b!=INPUT&&b!=OUTPUT)return -EINVAL;pinMode(a,b);return 0;}
  if(b<PUD_OFF||b>PUD_UP)return -EINVAL;pullUpDnControl(a,b);return 0;
 }
 if(r.op==WOP_SERIAL_OPEN) {std::string p(data,r.length);if(p!="/dev/ttyS4"&&p!="/dev/ttyS6")return -EPERM;fd=serialOpen(p.c_str(),a);if(fd<0)return fd==-2?-EINVAL:-errno;fcntl(fd,F_SETFL,fcntl(fd,F_GETFL)|O_NONBLOCK);return store(fd,1);}
 if(r.op>=WOP_SERIAL_CLOSE&&r.op<=WOP_SERIAL_PUTS){fd=handle(a,1);if(fd<0)return -EBADF;
  if(r.op==WOP_SERIAL_CLOSE){serialClose(fd);types[a-100]=0;return 0;}
  if(r.op==WOP_SERIAL_AVAIL)return serialDataAvail(fd);
  if(r.op==WOP_SERIAL_GET)return serialGetchar(fd);
  return write(fd,data,r.length)==(ssize_t)r.length?0:-EIO;
 }
 if(r.op==WOP_I2C_OPEN){if(std::string(data,r.length)!="/dev/i2c-5"||a<3||a>0x77)return -EPERM;return store(wiringPiI2CSetupInterface("/dev/i2c-5",a),2);}
 if(r.op==WOP_I2C_READ8||r.op==WOP_I2C_WRITE8){fd=handle(a,2);if(fd<0||b<0||b>255)return -EINVAL;return r.op==WOP_I2C_READ8?wiringPiI2CReadReg8(fd,b):wiringPiI2CWriteReg8(fd,b,c);}
 if(r.op==WOP_SPI_OPEN){if(a!=0||b<0||b>1||c<1000||c>50000000||d<0||d>3)return -EINVAL;char path[64];snprintf(path,sizeof(path),"/dev/spidev%d.%d",a,b);
  fd=open(path,O_RDWR|O_CLOEXEC);if(fd<0)return -errno;uint8_t mode=d,bits=8;uint32_t speed=c;
  if(ioctl(fd,SPI_IOC_WR_MODE,&mode)<0||ioctl(fd,SPI_IOC_WR_BITS_PER_WORD,&bits)<0||ioctl(fd,SPI_IOC_WR_MAX_SPEED_HZ,&speed)<0){int e=errno;close(fd);return -e;}
  if(spi[0]>=0)close(spi[0]);spi[0]=fd;return 0;
 }
 if(r.op==WOP_SPI_RW){if(a!=0||spi[0]<0)return -EBADF;out.assign(data,r.length);spi_ioc_transfer transfer{};transfer.tx_buf=(uintptr_t)data;transfer.rx_buf=(uintptr_t)out.data();transfer.len=r.length;return ioctl(spi[0],SPI_IOC_MESSAGE(1),&transfer);}
 return -EOPNOTSUPP;
}
int main(int argc,char**argv) {
 if(argc==3&&!strcmp(argv[1],"--query")){char out[WOP_MAX];uint32_t n=WOP_MAX;int r=wop_call(WOP_COMMAND,0,0,0,0,argv[2],strlen(argv[2]),out,&n);if(n)write(1,out,n);if(r<0)fprintf(stderr,"wiringOP helper: %s\n",strerror(-r));return r<0?1:0;}
 if(getuid()!=0)return 1;
 {FILE*dt=fopen("/proc/device-tree/compatible","rb");char ids[512]={};
  if(!dt)return 1;size_t n=fread(ids,1,sizeof(ids)-1,dt);fclose(dt);bool match=false;
  for(size_t i=0;i<n;i+=strlen(ids+i)+1)if(!strcmp(ids+i,"xunlong,orangepi-cm5-tablet"))match=true;
  if(!match)return 1;}

 signal(SIGPIPE,SIG_IGN);setenv("WIRINGPI_CODES","1",1);if(wiringPiSetup()<0)return 1;
 int sock=-1;const char*inherited=getenv("ANDROID_SOCKET_wiringop");
 if(inherited)sock=atoi(inherited);
 else {sock=socket(AF_UNIX,SOCK_STREAM|SOCK_CLOEXEC,0);if(sock<0)return 1;struct sockaddr_un addr{};addr.sun_family=AF_UNIX;strcpy(addr.sun_path,WOP_SOCKET);unlink(WOP_SOCKET);if(bind(sock,(sockaddr*)&addr,sizeof(addr))<0)return 1;chown(WOP_SOCKET,0,1000);chmod(WOP_SOCKET,0660);}
 if(listen(sock,8)<0)return 1;
 if(argc==2&&!strcmp(argv[1],"--daemon")){pid_t pid=fork();if(pid<0)return 1;if(pid>0)return 0;setsid();int nullfd=open("/dev/null",O_RDWR);for(int i=0;i<3;i++)dup2(nullfd,i);if(nullfd>2)close(nullfd);}
 for(;;){int client=accept4(sock,nullptr,nullptr,SOCK_CLOEXEC);if(client<0){if(errno==EINTR)continue;return 1;}
  struct ucred peer{};socklen_t size=sizeof(peer);
  if(getsockopt(client,SOL_SOCKET,SO_PEERCRED,&peer,&size)<0||(peer.uid!=0&&peer.uid!=1000)){close(client);continue;}
  struct timeval timeout={10,0};setsockopt(client,SOL_SOCKET,SO_RCVTIMEO,&timeout,sizeof(timeout));setsockopt(client,SOL_SOCKET,SO_SNDTIMEO,&timeout,sizeof(timeout));
  WopRequest req{};WopResponse res{-EINVAL,0};char data[WOP_MAX+1];std::string out;
  if(!wop_io(client,&req,sizeof(req),0)&&req.magic==WOP_MAGIC&&req.length<=WOP_MAX&&(!req.length||!wop_io(client,data,req.length,0))){data[req.length]=0;res.result=dispatch(req,data,out);if(out.size()<=WOP_MAX)res.length=out.size();else res.result=-EOVERFLOW;}
  if(!wop_io(client,&res,sizeof(res),1)&&res.length)wop_io(client,out.data(),res.length,1);close(client);
 }
}
