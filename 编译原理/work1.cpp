#include<map>
#include<cassert>
#include<string>
#include<iostream>

#define TODO assert(0 && "TODO")
// #define DEBUG_DFA

// enumerate for Status
enum class State {
    Empty,              // space, \n, \r ...
    IntLiteral,         // int literal, like '1' '01900', '0xAB', '0b11001'
    op                  // operators and '(', ')'
};
std::string toString(State s) {
    switch (s) {
    case State::Empty: return "Empty";
    case State::IntLiteral: return "IntLiteral";
    case State::op: return "op";
    default:
        assert(0 && "invalid State");
    }
    return "";
}

// enumerate for Token type
enum class TokenType{
    INTLTR,		// int literal
    PLUS,		// +
    MINU,		// -
    MULT,		// *
    DIV,		// /
    LPARENT,		// (
    RPARENT,		// )
};
std::string toString(TokenType type) {
    switch (type) {
    case TokenType::INTLTR: return "INTLTR";
    case TokenType::PLUS: return "PLUS";
    case TokenType::MINU: return "MINU";
    case TokenType::MULT: return "MULT";
    case TokenType::DIV: return "DIV";
    case TokenType::LPARENT: return "LPARENT";
    case TokenType::RPARENT: return "RPARENT";
    default:
        assert(0 && "invalid token type");
        break;
    }
    return "";
}

// definition of Token
struct Token {
    TokenType type;
    std::string value;
};

// definition of DFA
struct DFA {
    /**
     * @brief constructor, set the init state to State::Empty
     */
    DFA();
    
    /**
     * @brief destructor
     */
    ~DFA();
    
    // the meaning of copy and assignment for a DFA is not clear, so we do not allow them
    DFA(const DFA&) = delete;   // copy constructor
    DFA& operator=(const DFA&) = delete;    // assignment

    /**
     * @brief take a char as input, change state to next state, and output a Token if necessary
     * @param[in] input: the input character
     * @param[out] buf: the output Token buffer
     * @return  return true if a Token is produced, the buf is valid then
     */
    bool next(char input, Token& buf);

    /**
     * @brief reset the DFA state to begin
     */
    void reset();

private:
    State cur_state;    // record current state of the DFA
    std::string cur_str;    // record input characters
};


DFA::DFA(): cur_state(State::Empty), cur_str() {}

DFA::~DFA() {}

// helper function, you are not require to implement these, but they may be helpful
bool isoperator(char c) {

if(c == '+' || c == '-' || c == '*' || c == '/' || c == '(' || c == ')')
        return true;
    return false;
}

TokenType get_op_type(std::string s) {
switch (s[0])
    {
        case '+':   return TokenType::PLUS;
        case '-':   return TokenType::MINU;
        case '*':   return TokenType::MULT;
        case '/':   return TokenType::DIV;
        case '(':   return TokenType::LPARENT;
        case ')':   return TokenType::RPARENT;
        default:
            assert(0 && "invalid  operator");
            break;
    }
    return TokenType::INTLTR;

}

bool DFA::next(char input, Token& buf) {
if(input == '\n') {
        buf.value = cur_str;
        buf.type = (cur_state==State::IntLiteral)?TokenType::INTLTR:
                   get_op_type(cur_str);
        return true;
    }
    switch(cur_state) {
        case State::Empty: 
            if(input == ' ') return false;
            if(isoperator(input)) cur_state = State::op;
            else                  cur_state = State::IntLiteral;
            cur_str += input;
            return false;
        case State::op:
            buf.value = cur_str;
            buf.type = get_op_type(cur_str);
            cur_str = input;
            if(input == ' ') { 
                reset();
            }
            else if(!isoperator(input)) {
                cur_state = State::IntLiteral;
            }
            return true;
        case State::IntLiteral:
            if(input != ' ' && !isoperator(input)) {
                cur_str += input;
                return false;
            }
            buf.value = cur_str;
            buf.type = TokenType::INTLTR;
            if(input == ' ') reset();
            else {
                cur_state = State::op;
                cur_str = input;
            }
            return true;
        default: assert(0 && "invalid  state");
    }
    return false;
}

void DFA::reset() {
    cur_state = State::Empty;
    cur_str = "";
}

int main(){
    std::string stdin_str;
    std::getline(std::cin, stdin_str);
    stdin_str += "\n";
    DFA dfa;
    Token tk;
    for (size_t i = 0; i < stdin_str.size(); i++) {
        if(dfa.next(stdin_str[i], tk)){
            std::cout << toString(tk.type) << " " << tk.value << std::endl; 
        }
    }
    return 0;
}



