#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>

using std::vector;
using std::string;
using std::map;
using std::to_string;
using std::stoi;

string SEXT(string num, int len);
string ZEXT(string num, int len);
string toBinary(int num);

int main(){
    string num = "10101";
    std::cout << toBinary(-2) << std::endl;
    return 0;
}

string SEXT(string num, int len)
{
    num.insert(num.begin(), len-num.length(), num[0]);
    return num;
}

string ZEXT(string num, int len)
{
    num.insert(num.begin(), len-num.length(), '0');
    return num;
}

string toBinary(int num)        // Convert an integer to binary string
{   
    if (num == 0) return "0";
    std::cout << num << "->";
    bool is_negative = (num < 0);
    if (is_negative) num = -num-1;
    std::cout << num;
    string ans;
    while (num) {
        int remainder = num % 2;
        ans.insert(ans.begin(), '0'+remainder);
        num /= 2;
    }
    std::cout << ans;
    if(is_negative){
        for(int i = 0; i<ans.size(); i++){
            if(ans[i] == '0')   ans[i] = '1';
            else ans[i] = '0';
        }
    }
    if(!is_negative&&(ans[0]=='1')){
        ans.insert(ans.begin(), '0');
    }
    std::cout << "->" << ans << std::endl;
    return ans;
}
