unit customTypes;

interface


  type
    TArray = array of string;
    TChar = set of char;

    TErrors = (ENoError, EInvChar {= $0001}, ELongOp {= $0002}, ENotEnoughOps {= $0004},
               ENotEnoughBrackets, ELexemsBoundaryExeeded {= $0008});
    TCharType = (CUnexpected, CSpecial, CLetter, CSign, CDelimeter);

    tCountAr = array of record           //stores operands and operators and their count
                      lex: String;
                      num: integer;
                      isOperator: boolean;
                    end;


  const
        ERRORMSG: array [TErrors] of string = (
            'Everything is good! ',
            'ERROR! Invalid character detected',
            'ERROR! Too long operand detected',
            'ERROR! Not enough operands! Last readed:',
            'ERROR! Number of ''('' and '')'' symbols doesnt match',
            'ERROR! Parser exeeded number of readed lexems!');

        Letters : TChar = ['A'..'Z', 'a'..'z', '_', '0'..'9', '@', '^', '.', '#', '$'];
        Signs : TChar = ['~', ':', '=', '/', '\', '+', '-', '*', '%', '&', '|', '<', '>', '?', {';',} '''', ',', '"'];
        Delimeters : TChar = ['{', '}', '[', ']', '(', ')', ';', ','];

        STR_VARIABLE_HEADER = 'int byte short long boolean char double float ';   //basic types

implementation

end.
