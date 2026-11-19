// SPDX-License-Identifier: Apache-2.0
#include <jni.h>
#include <stdlib.h>
#include "protocol.h"
#define JNI_FN(n) Java_com_example_wiringop_wpiControl_##n
JNIEXPORT jint JNICALL JNI_FN(wiringPiSetup)(JNIEnv*e,jclass c) {(void)e;(void)c;return wop_call(WOP_SETUP,0,0,0,0,0,0,0,0);}
JNIEXPORT jint JNICALL JNI_FN(digitalRead)(JNIEnv*e,jclass c,jint p) {(void)e;(void)c;return wop_call(WOP_READ,p,0,0,0,0,0,0,0);}
JNIEXPORT void JNICALL JNI_FN(digitalWrite)(JNIEnv*e,jclass c,jint p,jint v) {(void)e;(void)c;wop_call(WOP_WRITE,p,v,0,0,0,0,0,0);}
JNIEXPORT void JNICALL JNI_FN(pinMode)(JNIEnv*e,jclass c,jint p,jint m) {(void)e;(void)c;wop_call(WOP_MODE,p,m,0,0,0,0,0,0);}
JNIEXPORT void JNICALL JNI_FN(pullUpDnControl)(JNIEnv*e,jclass c,jint p,jint m) {(void)e;(void)c;wop_call(WOP_PULL,p,m,0,0,0,0,0,0);}
JNIEXPORT jint JNICALL JNI_FN(getGpioInfo)(JNIEnv*e,jclass c,jintArray pins,jobjectArray names) {
 (void)c;static const jint map[64]={-1,-1,-1,0,-1,1,-1,2,3,-1,4,5,6,7,-1,8,9,-1,10,11,-1,12,13,14,15,-1,16};
 static const char* labels[]={"","3.3V","5V","SDA.5","5V","SCL.5","GND","PWM1","TXD.6","GND","RXD.6","RXD.4","GPIO1_A2","TXD.4","GND","GPIO1_B0","GPIO1_A4","3.3V","GPIO1_A6","SPI0_TXD","GND","SPI0_RXD","PWM3","SPI0_CLK","SPI0_CS0","GND","SPI0_CS1"};
 if((*e)->GetArrayLength(e,pins)<27||(*e)->GetArrayLength(e,names)<27)return -1;
 (*e)->SetIntArrayRegion(e,pins,0,27,map);
 for(int i=0;i<27;i++) {jstring s=(*e)->NewStringUTF(e,labels[i]);(*e)->SetObjectArrayElement(e,names,i,s);(*e)->DeleteLocalRef(e,s);}return 26;
}
static int string_call(JNIEnv *e,jstring value,uint32_t op,int a,int b) {
 if(!value)return -EINVAL;const char*s=(*e)->GetStringUTFChars(e,value,0);if(!s)return -ENOMEM;
 size_t n=strlen(s);int r=n>WOP_MAX?-EINVAL:wop_call(op,a,b,0,0,s,n,0,0);(*e)->ReleaseStringUTFChars(e,value,s);return r;
}
JNIEXPORT jint JNICALL JNI_FN(serialOpen)(JNIEnv*e,jclass c,jstring p,jint baud) {(void)c;return string_call(e,p,WOP_SERIAL_OPEN,baud,0);}
JNIEXPORT void JNICALL JNI_FN(serialClose)(JNIEnv*e,jclass c,jint h) {(void)e;(void)c;wop_call(WOP_SERIAL_CLOSE,h,0,0,0,0,0,0,0);}
JNIEXPORT jint JNICALL JNI_FN(serialDataAvail)(JNIEnv*e,jclass c,jint h) {(void)e;(void)c;return wop_call(WOP_SERIAL_AVAIL,h,0,0,0,0,0,0,0);}
JNIEXPORT jint JNICALL JNI_FN(serialGetchar)(JNIEnv*e,jclass c,jint h) {(void)e;(void)c;return wop_call(WOP_SERIAL_GET,h,0,0,0,0,0,0,0);}
JNIEXPORT void JNICALL JNI_FN(serialPuts)(JNIEnv*e,jclass c,jint h,jstring s) {(void)c;string_call(e,s,WOP_SERIAL_PUTS,h,0);}
JNIEXPORT jint JNICALL JNI_FN(wiringPiI2CSetupInterface)(JNIEnv*e,jclass c,jstring p,jint addr) {(void)c;return string_call(e,p,WOP_I2C_OPEN,addr,0);}
JNIEXPORT jint JNICALL JNI_FN(wiringPiI2CReadReg8)(JNIEnv*e,jclass c,jint h,jint reg) {(void)e;(void)c;return wop_call(WOP_I2C_READ8,h,reg,0,0,0,0,0,0);}
JNIEXPORT jint JNICALL JNI_FN(wiringPiI2CWriteReg8)(JNIEnv*e,jclass c,jint h,jint reg,jint value) {(void)e;(void)c;return wop_call(WOP_I2C_WRITE8,h,reg,value,0,0,0,0,0);}
JNIEXPORT jint JNICALL JNI_FN(wiringPiSPISetupMode)(JNIEnv*e,jclass c,jint bus,jint port,jint speed,jint mode) {(void)e;(void)c;return wop_call(WOP_SPI_OPEN,bus,port,speed,mode,0,0,0,0);}
JNIEXPORT jint JNICALL JNI_FN(wiringPiSPIDataRW)(JNIEnv*e,jclass c,jint bus,jbyteArray array,jint len) {
 (void)c;if(!array||len<0||len>WOP_MAX||len>(*e)->GetArrayLength(e,array))return -EINVAL;
 jbyte*buf=(*e)->GetByteArrayElements(e,array,0);if(!buf)return -ENOMEM;uint32_t size=(uint32_t)len;
 int r=wop_call(WOP_SPI_RW,bus,0,0,0,buf,len,buf,&size);(*e)->ReleaseByteArrayElements(e,array,buf,r<0?JNI_ABORT:0);return r;
}
JNIEXPORT jstring JNICALL Java_com_example_demo_RootCmd_execNative(JNIEnv*e,jclass c,jstring command) {
 (void)c;if(!command)return 0;const char*s=(*e)->GetStringUTFChars(e,command,0);if(!s)return 0;
 char out[WOP_MAX+1];uint32_t n=WOP_MAX;int r=wop_call(WOP_COMMAND,0,0,0,0,s,strlen(s),out,&n);
 (*e)->ReleaseStringUTFChars(e,command,s);if(r<0)return 0;out[n]=0;return (*e)->NewStringUTF(e,out);
}
JNIEXPORT jint JNICALL Java_com_example_demo_RootCmd_statusNative(JNIEnv*e,jclass c,jstring command) {
 (void)c;if(!command)return -EINVAL;const char*s=(*e)->GetStringUTFChars(e,command,0);if(!s)return -ENOMEM;
 char out[WOP_MAX];uint32_t n=WOP_MAX;int r=wop_call(WOP_COMMAND,0,0,0,0,s,strlen(s),out,&n);(*e)->ReleaseStringUTFChars(e,command,s);return r;
}
