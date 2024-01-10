#include <cstdint>
#include <iostream>
#include <fstream>
#define MAXLEN 100
#ifndef LENGTH
#define LENGTH 3
#endif

int16_t lab1(int16_t a, int16_t b) {
    int i,t=1,n=0;// initialize
    for(i=1;i<=b;i++){
        if(a&t) n++;// calculation
        t=t+t;
    }
    return n;//return value
}

int16_t lab2(int16_t p, int16_t q, int16_t n) {
    int r0,r1,r2,r3,a;// initialize
    r0=r1=1;
    for(int i=1;i<n;i++){// calculation
        //r2=r0%q;test
        a=r0;
        while(a>0){
            a=a-q;
        }
        r2=a+q;
        r3=r1&(p-1);
        r1=r0;
        r0=r2+r3;
    }
    return r0;//return value
}

int16_t lab3(int16_t n, char s[]) {
    int i,j,max=0,now=1;// initialize
    for(i=0;i<n;i++){// calculation
        if(s[i]==s[i+1]) now++;
        if(s[i]!=s[i+1]){
            if(now>=max){
                max=now;
            }
            now=1;
        }
    }
    return max;// return value
}

void lab4(int16_t score[], int16_t *a, int16_t *b) {
    int m=0,n=0,i=1,cal=0;// initialize
    int t[16];
    for(i=0;i<16;i++){// calculation
        for(int j=0;j<16;j++){
            if(score[i]>=score[j]) {cal++;} 
        }
        t[cal-1]=score[i];
        cal=0;
    }
    for(i=0;i<16;i++){
        score[i]=t[i];
    }
    for(i=15;i>=12;i--){
        if(score[i]>=85) m++;
    }
    for(i=15;i>8;i--){
        if(score[i]>=75) n++;
    }
    n=n-m;
    *a=m;
    *b=n;
}


int main() {
std::fstream file;
file.open("test.txt", std::ios::in);
// lab1
int16_t a = 0, b = 0;
for (int i = 0; i < LENGTH; ++i) {
file >> a >> b;
std::cout << lab1(a, b) << std::endl;
}
//lab2
int16_t p = 0, q = 0, n = 0;
for (int i = 0; i < LENGTH; ++i) {
file >> p >> q >> n;
std::cout << lab2(p, q, n) << std::endl;
}
//lab3
char s[MAXLEN];
for (int i = 0; i < LENGTH; ++i) {
file >> n >> s;
std::cout << lab3(n, s) << std::endl;
}
//lab4
int16_t score[16];
for (int i = 0; i < LENGTH; ++i) {
for (int j = 0; j < 16; ++j) {
file >> score[j];
}
lab4(score, &a, &b);
for (int j = 0; j < 16; ++j) {
std::cout << score[j] << " ";
}
std::cout << std::endl << a << " " << b << std::endl;
}

file.close();
return 0;
}