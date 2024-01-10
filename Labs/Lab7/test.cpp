#include <iostream>

int main(){
    int fib[21];
    fib[0] = 1;
    fib[1] = 2;
    for(int i = 2; i < 21; i++){
        fib[i] = fib[i-1] + fib[i-2];
    }
    float sum = 0.0;
    for(int i=0; i < 20; i++){
        sum += (fib[i+1]/fib[i]);
    }
    std::cout << sum << std::endl;
}