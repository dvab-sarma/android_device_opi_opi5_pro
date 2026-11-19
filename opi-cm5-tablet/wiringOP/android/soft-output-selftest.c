/* Android thread lifecycle test. All GPIO access is mocked in this executable. */
#include <assert.h>
#include <stdatomic.h>
#include <time.h>
#include <wiringPi.h>
#include <softPwm.h>
#include <softTone.h>
#include <stdio.h>
static atomic_int writes;
static atomic_int level;
void digitalWrite(int pin, int value) { (void)pin; atomic_store(&level,value); atomic_fetch_add(&writes,1); }
void pinMode(int pin, int mode) { (void)pin; (void)mode; }
int piHiPri(int priority) { (void)priority; return 0; }
void delayMicroseconds(unsigned int us) {
 struct timespec t={.tv_sec=us/1000000,.tv_nsec=(us%1000000)*1000};
 nanosleep(&t,0);
}
void delay(unsigned int ms) { delayMicroseconds(ms*1000); }
int main(void) {
 for(int i=0;i<3;i++) {
  if(softPwmCreate(0,50,100)!=0) return 1;
  delay(25);
  softPwmWrite(0,25);
  softPwmStop(0);
  if(atomic_load(&level)!=LOW) return 2;
  if(softToneCreate(1)!=0) return 3;
  delay(3);
  softToneStop(1); /* Must stop even when frequency is zero. */
  if(softToneCreate(1)!=0) return 4;
  softToneWrite(1,500);
  delay(10);
  softToneStop(1);
  if(atomic_load(&level)!=LOW) return 5;
 }
 if(atomic_load(&writes)<12) return 6;
 puts("PASS: software PWM/tone create, update, stop and recreate; mocked GPIO only");
 return 0;
}
