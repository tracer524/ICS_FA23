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

vector<string> read_asm_file(const string &filename);
void write_output_file(const string &filename, const vector<string> &output);
vector<string> assemble(const vector<string> &input_lines);
void InitInstSet(vector<string> &instSet);
string translate_instruction(const string &instruction, map<string, int> symbol_table, const vector<string> instSet, const int PC);
void FetchRegister(string &instruction, string &machine_code);
void FetchImmediate(string &instruction, string &machine_code, const int len);
void FetchLabel(string &instruction, string &machine_code, const map<string, int> symbol_table, const int PC, const int offset_length);
string SEXT(string num, int len);
string ZEXT(string num, int len);
int toDecimal(string s, int radix);
string toBinary(int num);

int main(int argc, char *argv[])
{
    // Command-line argument parsing
    if (argc != 3)
    {
        std::cerr << "Usage: " << argv[0] << " <input_file.asm> <output_file.txt>" << std::endl;
        return 1;
    }
   
    string input_filename = argv[1];
    string output_filename = argv[2];
    
    // Read the input ASM file
    vector<string> input_lines = read_asm_file(input_filename);

    // Assemble the input file
    vector<string> output_lines = assemble(input_lines);

    // Write the output file
    write_output_file(output_filename, output_lines);

    return 0;
}

vector<string> read_asm_file(const string &filename)
{
    vector<string> lines;
    string line;
    std::ifstream file(filename);

    if (file.is_open())
    {
        while (getline(file, line))
        {
            lines.push_back(line);
        }
        file.close();
    }
    else
    {
        std::cerr << "Unable to open file: " << filename << std::endl;
    }

    return lines;
}

void write_output_file(const string &filename, const vector<string> &output)
{
    std::ofstream file(filename);
    if (file.is_open())
    {
        for (const auto &line : output)
        {
            file << line << std::endl;
        }
        file.close();
    }
    else
    {
        std::cerr << "Unable to open file: " << filename << std::endl;
    }
}

vector<string> assemble(const vector<string> &input_lines)
{
    vector<string> instSet;
    InitInstSet(instSet);
    vector<string> output_lines;
    vector<string> lines = input_lines;
    map<string, int> symbol_table;
    int PC = 0;
    for(auto &line : lines){        // Get the label table in the first pass
        PC++;
        bool hasLabel = true;
        for(const auto &inst : instSet){
            if((line.find(inst) != string::npos) && !line.find(inst)) hasLabel = false;
        }
        if(hasLabel){
            auto pos = line.find(" ");
            const string label = line.substr(0, pos);
            line.erase(0, pos+1);
            symbol_table[label] = PC;       // Add the label to the symbol table
        }
    }
    PC = 0;
    for(const auto &line : lines){
        if(line == ".END") continue;
        PC++;
        output_lines.push_back(translate_instruction(line, symbol_table, instSet, PC));       // Translate the instruction in the second pass
    }
    return output_lines;
}

void InitInstSet(vector<string> &instSet)
{
    instSet = {"ADD", "AND", "BR", "JMP", "JSR", "JSRR", "LD", "LDI", "LDR", "LEA", "NOT", "RET", "RTI", "ST", "STI", "STR", "TRAP", ".ORIG", ".FILL", ".BLKW", ".STRINGZ", ".END"};
}

string translate_instruction(const string &instruction, map<string, int> symbol_table, const vector<string> instSet, const int PC)
{
    string inst = instruction;
    string machine_code;
    
    auto pos = inst.find(" ");
    int i;
    for(i=0; i<instSet.size(); i++){
        if(!inst.compare(0, pos, instSet[i]))     break;
    }
    if(!inst.compare(0, 2, "BR")){       // Deal with BR instruction
        pos = 1;
        i = 2;
    }
    inst.erase(0, pos+1);
    string cond;
    switch (i)
    {
    case 0:     // ADD
    case 1:     // AND
        if(i)   machine_code += "0101";
        else    machine_code += "0001";
        FetchRegister(inst, machine_code);
        FetchRegister(inst, machine_code);
        if(inst[0] == 'R'){
            machine_code += "000";
            FetchRegister(inst, machine_code);
        }
        else{
            machine_code += "1";
            FetchImmediate(inst, machine_code, 5);
        }
        break;

    case 2:     // BR
        machine_code += "0000";
        cond = inst.substr(0, inst.find(' '));
        inst.erase(0, inst.find(' ')+1);
        if(cond.find('N') == string::npos)   machine_code += "0";
        else    machine_code += "1";
        if(cond.find('Z') == string::npos)   machine_code += "0";
        else    machine_code += "1";
        if(cond.find('P') == string::npos)   machine_code += "0";
        else    machine_code += "1";
        inst.erase(0, inst.find(' ')+1);
        FetchLabel(inst, machine_code, symbol_table, PC, 9);
        break;

    case 3:     // JMP
        machine_code += "1100000";
        FetchRegister(inst, machine_code);
        machine_code += "000000";
        break;

    case 4:     // JSR
        machine_code += "01001";
        FetchLabel(inst, machine_code, symbol_table, PC, 11);
        break;

    case 5:     // JSRR
        machine_code += "0100000";
        FetchRegister(inst, machine_code);
        machine_code += "000000";
        break;

    case 6:     // LD
        machine_code += "0010";
        FetchRegister(inst, machine_code);
        FetchLabel(inst, machine_code, symbol_table, PC, 9);
        break;

    case 7:     // LDI
        machine_code += "1010";
        FetchRegister(inst, machine_code);
        FetchLabel(inst, machine_code, symbol_table, PC, 9);
        break;

    case 8:     // LDR
        machine_code += "0110";
        FetchRegister(inst, machine_code);
        FetchRegister(inst, machine_code);
        FetchLabel(inst, machine_code, symbol_table, PC, 6);
        break;

    case 9:     // LEA
        machine_code += "1110";
        FetchRegister(inst, machine_code);
        FetchLabel(inst, machine_code, symbol_table, PC, 9);
        break;

    case 10:    // NOT
        machine_code += "1001";
        FetchRegister(inst, machine_code);
        FetchRegister(inst, machine_code);
        machine_code += "111111";
        break;

    case 11:    // RET
        machine_code += "1100000111000000";
        break;

    case 12:    // RTI
        machine_code += "1000000000000000";
        break;

    case 13:    // ST
        machine_code += "0011";
        FetchRegister(inst, machine_code);
        FetchLabel(inst, machine_code, symbol_table, PC, 9);
        break;

    case 14:    // STI
        machine_code += "1011";
        FetchRegister(inst, machine_code);
        FetchLabel(inst, machine_code, symbol_table, PC, 9);
        break;

    case 15:    // STR
        machine_code += "0111";
        FetchRegister(inst, machine_code);
        FetchRegister(inst, machine_code);
        FetchLabel(inst, machine_code, symbol_table, PC, 6);
        break;

    case 16:    // TRAP
        machine_code += "11110000";
        FetchImmediate(inst, machine_code, 8);
        break;

    case 17:    // .ORIG
        FetchImmediate(inst, machine_code, 16);
        break;

    case 18:    // .FILL
        FetchImmediate(inst, machine_code, 16);
        break;

    case 19:    // .BLKW
        switch (inst[0])
        {
        case '#':
            inst.erase(0, 1);
            for(int i=0; i<toDecimal(inst, 10); i++){
                machine_code += "0000000000000000";
                if(i<toDecimal(inst, 10)-1)     machine_code += '\n';
            }
            break;

        case 'x':
            inst.erase(0, 1);
            for(int i=0; i<toDecimal(inst, 16); i++){
                machine_code += "0000000000000000";
                if(i<toDecimal(inst, 16)-1)     machine_code += '\n';
            }

        default:
            break;
        }
        break;

    case 20:    // .STRINGZ
        for(int i=1; i<inst.size()-1; i++){
            machine_code += SEXT(toBinary(int(inst[i])), 16);
            machine_code += '\n';
        }
        machine_code += "0000000000000000";
        break;

    default:
        break;
    }

    return machine_code;
}

void FetchRegister(string &instruction, string &machine_code)
{
    string operand;
    operand.assign(instruction, 1, 1);
    machine_code += ZEXT(to_string(stoi(operand, 0, 2)), 3);
    instruction.erase(0, 4);
}

void FetchImmediate(string &instruction, string &machine_code, const int len){
    switch (instruction[0])
    {
    case '#':
        instruction.erase(0, 1);
        machine_code += SEXT(toBinary(toDecimal(instruction, 10)), len);
        break;
    
    case 'x':
        instruction.erase(0, 1);
        machine_code += SEXT(toBinary(toDecimal(instruction, 16)), len);
        break;
    
    default:
        break;
    }
}

void FetchLabel(string &instruction, string &machine_code, const map<string, int> symbol_table, const int PC, const int offset_length)
{
    const int offset = symbol_table.find(instruction)->second - PC - 1;
    machine_code += SEXT(toBinary(offset), offset_length);
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

int toDecimal(string s, int radix)      // Convert a string to a decimal integer
{   
    int ans = 0;
    bool negative = false;
    if(s[0] == '-'){
        negative = true;
        s.erase(0, 1);
    }
	for(int i = 0; i < s.size(); i++){
		char t = s[i];
		if(t >= '0' && t <= '9') ans = ans * radix + (t - '0');
		else ans = ans * radix + (t - 'A' + 10);
	}
	return negative? -ans:ans;
}

string toBinary(int num)        // Convert an integer to binary string
{   
    if (num == 0) return "0";
    bool is_negative = (num < 0);
    if (is_negative) num = -num-1;
    string ans;
    while (num) {
        int remainder = num % 2;
        ans.insert(ans.begin(), '0'+remainder);
        num /= 2;
    }
    if(ans[0]=='1'){
        ans.insert(ans.begin(), '0');
    }
    if(is_negative){
        for(int i = 0; i<ans.size(); i++){
            if(ans[i] == '0')   ans[i] = '1';
            else ans[i] = '0';
        }
    }
    return ans;
}
