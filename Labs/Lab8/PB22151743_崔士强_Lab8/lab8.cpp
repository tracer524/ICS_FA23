#include <cstdint>
#include <iostream>
#include <fstream>
#include <bitset>

/*
#define LENGTH 1
*/
#define MAXLEN 1000
#define STUDENT_ID_LAST_DIGIT 3

bool Check4LastDigit(int16_t result);
bool Check4Divisibility(int16_t result);
void Put(int16_t *memory, int16_t n, int &i);
void Remove(int16_t *memory, int16_t n, int &i);
int16_t SingleBit(int16_t n);

int16_t lab1(int16_t n) {
    // initialize
    int16_t singleBit = 1;
    int count = 0;

    // calculation
    if((n & 1) == 0)      n = -n;     // odd number
    for(int i = 0; i < 16; i++){
        count = count + !(n & singleBit);
        singleBit = singleBit + singleBit;
    }

    // return value
    return count + STUDENT_ID_LAST_DIGIT;
}

int16_t lab2(int16_t n) {
    // initialize
    int16_t result = 3;
    int operator_d_n = 1;    // 1 for +, -1 for -

    // calculation
    for( ; n>1; n--){
        if(operator_d_n == 1)    result = result + result + 2;
        else    result = result + result - 2;
        result = result & 0x0FFF;
        if(Check4LastDigit(result)||Check4Divisibility(result))   operator_d_n = -operator_d_n;
    }

    // return value
    return result;
}

bool Check4LastDigit(int16_t result){
    while(result>0)   result = result - 10;
    return result == -2;
}

bool Check4Divisibility(int16_t result){
    while(result>0)   result = result - 8; 
    return result == 0;
}

int16_t lab3(char s1[], char s2[]) {
    // initialize
    int i = 0;

    // calculation
    while(s1[i] == s2[i]){
        if(s1[i++] == '\0')   return 0;
    }

    // return value
    return s1[i]-s2[i];
}


int16_t lab4(int16_t *memory, int16_t n) {
    // initialize
    int i = 1;              // current index in memory
    memory[0] = 0;

    // calculation
    Remove(memory, n, i);
    for(int j = 0; j < i-1; j++){
        memory[j] = memory[j+1];
    }

    // return value
    return i-1;
}

void Put(int16_t *memory, int16_t n, int &i){
    if(!n)  return;
    if(n == 1){
        memory[i] = memory[i-1] & (~SingleBit(1));
        i++;
        return;
    }
    Put(memory, n-1, i);
    Remove(memory, n-2, i);
    memory[i] = memory[i-1] & (~SingleBit(n));
    i++;
    Put(memory, n-2, i);
    return;
}

void Remove(int16_t *memory, int16_t n, int &i){
    if(!n)  return;
    if(n == 1){
        memory[i] = memory[i-1] | SingleBit(1);
        i++;
        return;
    }
    Remove(memory, n-2, i);
    memory[i] = memory[i-1] | SingleBit(n);
    i++;
    Put(memory, n-2, i);
    Remove(memory, n-1, i);
}

int16_t SingleBit(int16_t n){
    int16_t result = 1;
    for(int i = 0; i<n-1; i++){
        result = result +result;
    }
    return result;
}

int main() {
    std::fstream file;
    file.open("test.txt", std::ios::in);

    // lab1
    int16_t n = 0;
    std::cout << "===== lab1 =====" << std::endl;
    for (int i = 0; i < LENGTH; ++i) {
        file >> n;
        std::cout << lab1(n) << std::endl;
    }

    // lab2
    std::cout << "===== lab2 =====" << std::endl;
    for (int i = 0; i < LENGTH; ++i) {
        file >> n;
        std::cout << lab2(n) << std::endl;
    }

    // lab3
    std::cout << "===== lab3 =====" << std::endl;
    char s1[MAXLEN]; char s2[MAXLEN];
    for (int i = 0; i < LENGTH; ++i) {
        file >> s1 >> s2;
        std::cout << lab3(s1, s2) << std::endl;
    }
    
    // lab4
    std::cout << "===== lab4 =====" << std::endl;
    int16_t memory[MAXLEN], move;
    for (int i = 0; i < LENGTH; ++i) {
        file >> n;
        int16_t state = 0;
        move = lab4(memory, n);
        for(int j = 0; j < move; ++j){
            std::cout << std::bitset<16>(memory[j]) << std::endl;
        }
    }
    
    file.close();
    return 0;
}