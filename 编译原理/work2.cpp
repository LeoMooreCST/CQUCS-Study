/*
Exp -> AddExp

    Exp.v

Number -> IntConst | floatConst

PrimaryExp -> '(' Exp ')' | Number
    PrimaryExp.v

UnaryExp -> PrimaryExp | UnaryOp UnaryExp
    UnaryExp.v

UnaryOp -> '+' | '-'

MulExp -> UnaryExp { ('*' | '/') UnaryExp }
    MulExp.v

AddExp -> MulExp { ('+' | '-') MulExp }
    AddExp.v
*/
#include<map>
#include<cassert>
#include<string>
#include<iostream>
#include<vector>
#include<set>
#include<queue>

#define TODO assert(0 && "TODO")
// #define DEBUG_DFA
// #define DEBUG_PARSER

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
    INTLTR,        // int literal
    PLUS,        // +
    MINU,        // -
    MULT,        // *
    DIV,        // /
    LPARENT,        // (
    RPARENT,        // )
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
    if (c == '+' || c == '-' || c == '*' || c == '/' || c == '(' || c == ')')
        return true;
    return false;
}

TokenType get_op_type(std::string s) {
    switch (s[0])
    {
    case '+':
        return TokenType::PLUS;
    case '-':
        return TokenType::MINU;
    case '*':
        return TokenType::MULT;
    case '/':
        return TokenType::DIV;
    case '(':
        return TokenType::LPARENT;
    case ')':
        return TokenType::RPARENT;
    default:
        assert(0 && "invalid  operator");
        break;
    }
    return TokenType::INTLTR;

}

bool DFA::next(char input, Token& buf) {
    if (input == '\n')
    {
        buf.value = cur_str;
        buf.type = (cur_state == State::IntLiteral) ? TokenType::INTLTR : get_op_type(cur_str);
        return true;
    }
    switch (cur_state)
    {
    case State::Empty:
        if (input == ' ')
            return false;
        if (isoperator(input))
            cur_state = State::op;
        else
            cur_state = State::IntLiteral;
        cur_str += input;
        return false;
    case State::op:
        buf.value = cur_str;
        buf.type = get_op_type(cur_str);
        cur_str = input;
        if (input == ' ')
            reset();
        else if (!isoperator(input))
            cur_state = State::IntLiteral;
        return true;
    case State::IntLiteral:
        if (input != ' ' && !isoperator(input))
        {
            cur_str += input;
            return false;
        }
        buf.value = cur_str;
        buf.type = TokenType::INTLTR;
        if (input == ' ')
            reset();
        else
        {
            cur_state = State::op;
            cur_str = input;
        }
        return true;
    default:
        assert(0 && "invalid  state");
    }
    return false;
}

void DFA::reset() {
    cur_state = State::Empty;
    cur_str = "";
}

// hw2
enum class NodeType {
    TERMINAL,       // terminal lexical unit
    EXP,
    NUMBER,
    PRIMARYEXP,
    UNARYEXP,
    UNARYOP,
    MULEXP,
    ADDEXP,
    NONE
};
std::string toString(NodeType nt) {
    switch (nt) {
    case NodeType::TERMINAL: return "Terminal";
    case NodeType::EXP: return "Exp";
    case NodeType::NUMBER: return "Number";
    case NodeType::PRIMARYEXP: return "PrimaryExp";
    case NodeType::UNARYEXP: return "UnaryExp";
    case NodeType::UNARYOP: return "UnaryOp";
    case NodeType::MULEXP: return "MulExp";
    case NodeType::ADDEXP: return "AddExp";
    case NodeType::NONE: return "NONE";
    default:
        assert(0 && "invalid node type");
        break;
    }
    return "";
}

// tree node basic class
struct AstNode{
    int value;
    NodeType type;  // the node type
    AstNode* parent;    // the parent node
    std::vector<AstNode*> children;     // children of node

    /**
     * @brief constructor
     */
    AstNode(NodeType t = NodeType::NONE, AstNode* p = nullptr): type(t), parent(p), value(0) {} 

    /**
     * @brief destructor
     */
    virtual ~AstNode() {
        for(auto child: children) {
            delete child;
        }
    }

    // rejcet copy and assignment
    AstNode(const AstNode&) = delete;
    AstNode& operator=(const AstNode&) = delete;
};

// definition of Parser
// a parser should take a token stream as input, then parsing it, output a AST
struct Parser {
    uint32_t index; // current token index
    const std::vector<Token>& token_stream;

    /**
     * @brief constructor
     * @param tokens: the input token_stream
     */
    Parser(const std::vector<Token>& tokens): index(0), token_stream(tokens) {}

    /**
     * @brief destructor
     */
    ~Parser() {}
    
    /**
     * @brief creat the abstract syntax tree
     * @return the root of abstract syntax tree
     */
    AstNode* get_abstract_syntax_tree() {
        AstNode* node = new AstNode(NodeType::EXP, nullptr);
        parseExp(node);
        return node;    
    }

    // u can define member funcition of Parser here
    bool parseExp(AstNode* root);
    bool parseNumber(AstNode* root);
    bool parsePrimaryExp(AstNode* root);
    bool parseUnaryExp(AstNode* root);
    bool parseUnaryOp(AstNode* root);
    bool parseMulExp(AstNode* root);
    bool parseAddExp(AstNode* root);
    
};

// u can define funcition here
#define CUR_TOKEN_IS(tk_type) (token_stream[index].type == TokenType::tk_type)
#define PARSE_TOKEN \
    root->children.push_back(new AstNode(NodeType::TERMINAL, root)); \
    index++;
#define PARSE(val, name, type)  \
    AstNode* val = new AstNode(NodeType::type, root); \
    assert(parse##name(val)); \
    root->children.push_back(val); \
//Exp  ->  AddExp
bool Parser::parseExp(AstNode* root) {
    PARSE(addexp, AddExp, ADDEXP);
    root->value = addexp->value;
    return true;
}
//AddExp  ->  MulExp  {  ('+'  |  '-')  MulExp  }
bool Parser::parseAddExp(AstNode* root) {
    PARSE(mulexp, MulExp, MULEXP);
    root->value = mulexp->value;
    while (CUR_TOKEN_IS(PLUS) || CUR_TOKEN_IS(MINU))
    {
        if(CUR_TOKEN_IS(PLUS)) {
            PARSE_TOKEN;
            PARSE(mulexp, MulExp, MULEXP);
            root->value += mulexp->value;
        }
        else if(CUR_TOKEN_IS(MINU)) {
            PARSE_TOKEN;
            PARSE(mulexp, MulExp, MULEXP);
            root->value -= mulexp->value;
        }
        else assert(0 && "wrong!");
    }
    return true;
}
//MulExp  ->  UnaryExp  {  ('*'  |  '/')  UnaryExp  }
bool Parser::parseMulExp(AstNode* root) {
    PARSE(unaryexp, UnaryExp, UNARYEXP);
    root->value = unaryexp->value;
    while(CUR_TOKEN_IS(MULT) || CUR_TOKEN_IS(DIV)) {
        if(CUR_TOKEN_IS(MULT)) {
            PARSE_TOKEN;
            PARSE(unaryexp, UnaryExp, UNARYEXP);
            root->value *= unaryexp->value;
        }
        else {
            PARSE_TOKEN;
            PARSE(unaryexp, UnaryExp, UNARYEXP);
            root->value /= unaryexp->value;
        }
    }
    return true;
}
//UnaryExp  ->  PrimaryExp  |  UnaryOp  UnaryExp
bool Parser::parseUnaryExp(AstNode* root) {
    if(CUR_TOKEN_IS(PLUS) || CUR_TOKEN_IS(MINU)) {
        if(CUR_TOKEN_IS(PLUS)) {
            PARSE(unaryop, UnaryOp, UNARYOP);
            PARSE(unaryexp, UnaryExp, UNARYEXP);
            root->value = unaryexp->value;
        }
        else {
            PARSE(unartop, UnaryOp, UNARYOP);
            PARSE(unaryexp, UnaryExp, UNARYEXP);
            root->value = -unaryexp->value;
        }
    }
    else {
        PARSE(primaryexp, PrimaryExp, PRIMARYEXP);
        root->value = primaryexp->value;
    }
    return true;
}
//Number  ->  IntConst  |  floatConst
#include <cstdlib> 
bool Parser::parseNumber(AstNode* root) {
    if(CUR_TOKEN_IS(INTLTR)) {
        std::string val = token_stream[index].value;
        int sum = 0;
        if(val.size()) {
            if(val.size() >= 2) {
                //十六进制
                if(val.substr(0, 2) == "0x" || val.substr(0, 2) == "0X") {
                    val = val.substr(2);
                    sum = std::stoul(val, nullptr, 16);
                }
                //二进制
                else if(val.substr(0, 2) == "0b" || val.substr(0,2) == "0B") {
                    val = val.substr(2);
                    for (char c : val) {  
                        if (c != '0' && c != '1') {  
                            throw std::invalid_argument("Invalid binary string");  
                        }  
                        sum = (sum << 1) + (c - '0');  
                    }  
                }
                //八进制
                else if(val[0] == '0') {
                    for (size_t i =  1; i < val.size(); ++i) {  
                        char c = val[i];  
                        if (c < '0' || c > '7') {  
                            throw std::invalid_argument("Invalid octal string (contains non-octal digit)");  
                        }  
                        sum = (sum * 8) + (c - '0');  
                    }  
                }
                else sum = std::stoi(val);
            }
            else {
                sum = std::stoi(val);
            }
            
        }
        AstNode* child = new AstNode(NodeType::TERMINAL, root);
        index++;
        child->value = sum;
        root->children.push_back(child);
        root->value = child->value;
        return true;
    }
    return false;
}
//PrimaryExp  ->  '('  Exp  ')'  |  Number
bool Parser::parsePrimaryExp(AstNode* root) {
    //"("
    if(CUR_TOKEN_IS(LPARENT)) {
        PARSE_TOKEN;
        PARSE(exp, Exp, EXP);
        root->value = exp->value;
        PARSE_TOKEN;
    }
    else {
        PARSE(number, Number, NUMBER);
        root->value = number->value;
    }
    return true;
}
//UnaryOp  ->  '+'  |  '-'
bool Parser::parseUnaryOp(AstNode* root) {
    PARSE_TOKEN;
    return true;
}

int main(){
    std::string stdin_str;
    std::getline(std::cin, stdin_str);
    stdin_str += "\n";
    DFA dfa;
    Token tk;
    std::vector<Token> tokens;
    for (size_t i = 0; i < stdin_str.size(); i++) {
        if(dfa.next(stdin_str[i], tk)){
            tokens.push_back(tk); 
        }
    }

    // hw2
    Parser parser(tokens);
    auto root = parser.get_abstract_syntax_tree();
    // u may add function here to analysis the AST, or do this in parsing
    // like get_value(root);
    

    std::cout << root->value;

    return 0;
}

