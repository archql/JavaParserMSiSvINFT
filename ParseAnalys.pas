unit ParseAnalys;



interface
  uses
    customTypes, Math;


  var
    numLength: integer = 0;

  procedure countLex(var COUNT: tCountAr; const LEXEMS: tArray);
  procedure formOut(const COUNT: tCountAr; var f: textFile);

implementation

  procedure modifyLen(var COUNT: tCountAr; var maxLen: integer );
    begin
      if (maxLen<>0) then
          inc(maxLen, maxLen)
        else
          maxLen:=1;
      setLength(COUNT, maxLen);
    end;

  function isExist(var COUNT: tCountAr; const TMP: String): integer;
    var
      i: integer;
      f: boolean;
    begin
      if length(COUNT)<>0 then f:=true
        else f:=false;
      i:=0;
      RESULT:=-1;
      while f do
        begin
          if COUNT[i].lex=TMP then
            begin
              f:=false;
              RESULT:=i;
            end;
          inc(i);
          if i=length(COUNT) then f:=false;
        end;
    end;

  procedure addlex(var COUNT: tCountAr; var CURLEN, MAXLEN: integer; const TMP: String; const IS_OPERATOR: boolean);
    var
      num: integer;
    begin           //copy(s, from, count)

      num:=isExist(COUNT, TMP);
      if num<>-1 then inc(COUNT[num].num)
        else
          begin
            if CURLEN>=MAXLEN-1 then modifyLen(COUNT, MAXLEN);
            inc(CURLEN);
            with COUNT[CURLEN] do
              begin
                lex:=TMP;
                isOperator:=IS_OPERATOR;
                num:=1;
              end;
          end;
    end;

  function findTerm(const tmp: String): integer;
    begin         //for, while - '(', method - '{', other - ';'    //скобочные последовательности???
      if tmp='(' then RESULT:=1
        else if tmp='{' then RESULT:=2
          else if tmp='<' then RESULT:=3
              else if ((tmp='assert') or (tmp='throw') or (tmp=':')) then RESULT:=4
                else RESULT:=5;
    end;

  function isLexEnd(const LEXEMS: tArray; const POSIT: integer; const MODE: integer): boolean;
      var
        tmp: String;
      begin
        RESULT:=false;
        tmp:=LEXEMS[POSIT];
        case MODE of
          0: if POSIT=length(LEXEMS)-1 then RESULT:=true;
          1: if tmp=')' then RESULT:=true;
          2: if tmp='}' then RESULT:=true;
          3: if tmp='>' then RESULT:=true;
          4: if tmp=';' then RESULT:=true;
          5: if (tmp=';')or(tmp='}') then RESULT:=true;
        end;
      end;

  procedure countLex(var COUNT: tCountAr; const LEXEMS: tArray);

    procedure crawl(var POSIT: integer; const MODE: integer);   //0 - until the EoF, 1-), 2-}, 3->, 4-;, 5-; or }
      var
        tmp: String;
        cur, len: integer;
        isWaiting, isEnd: boolean;
      begin
        cur:=POSIT;
        isEnd:=false;
        len:=length(LEXEMS);
        isWaiting:=false;
        while not isEnd do
          begin
            tmp:=LEXEMS[cur];

            if (pos(tmp, MAJORENTRIES)>0) then
                begin
                  //addlex (pair lexem in most cases)
                  inc(cur);
                  crawl(cur, findTerm(tmp));
                end
              else if (pos(tmp, MINORENTRIES)>0) then
                  begin
                    inc(cur);
                    crawl(cur, findTerm(tmp));
                  end
                else if ( isLexEnd(LEXEMS, cur, MODE) ) then
                    begin
                      //addLex, if mode<>0
                      isEnd:=true;
                      POSIT:=cur;
                    end
                  else if (pos(tmp, SUPER_IGNORED)>0) then
                      begin
                        while LEXEMS[cur]<>':' do
                          inc(cur);
                      end
                    else if (pos(tmp, IGNORED)>0) then
                        begin
                          inc(cur);
                        end
                    else if (pos(tmp, OP_SIGNS)>0)or(pos(tmp, JUMPES)>0) then
                        begin
                          //addlex(tmp)
                        end
                      else  if (pos(tmp, CYCLES)>0) then
                          begin
                            if tmp='do' then
                                begin
                                  //addLex('do')
                                  isWaiting:=true;
                                  inc(cur);
                                  crawl(cur, findTerm(tmp));
                                end
                              else if tmp='while' then
                                  begin
                                    if not isWaiting then
                                        begin
                                          //addLex
                                          inc(cur);
                                          crawl(cur, findTerm(tmp));
                                          inc(cur);
                                          crawl(cur, findTerm(LEXEMS[cur]));
                                        end
                                      else
                                        begin
                                          isWaiting:=false;
                                          inc(cur);
                                          crawl(cur, findTerm(tmp));
                                        end;
                                  end
                                else
                                  begin
                                    //addLex
                                    crawl(cur, findTerm(tmp));
                                  end;
                          end;

          end;




      end;

    var
      curPos: integer;
    begin
      curPos:=0;
      crawl(curPos, 0);
    end;

  {procedure countLex(var COUNT: tCountAr; const LEXEMS: tArray);
    var
      maxLen, curLen: integer;
      strBegin, strEnd: integer;
      lexCount: integer;
      tmp: String;
    begin
      maxLen:=0;    //length of array
      curLen:=0;               //pos of first empty el [0;maxLen-1]

      lexCount:=length(LEXEMS);
      if lexCount>0 then
        begin
          maxLen:=0;
          curLen:=0;
          strBegin:=0;
          strEnd:=0;
          while (strEnd<=lexCount-1) do
            begin
              tmp:=LEXEMS[strBegin];
              if (tmp='do') then
                  begin
                    addLex(COUNT, curLen, maxLen, 'do..while', true);   //проверка while на наличие  do
                    //найти strEnd while?
                    //переход str<>
                  end
                else if (tmp='try') then
                    begin
                      addLex(COUNT, curLen, maxLen, 'try..catch[..finally]', true);
                      //что-то ещё?
                      //переход str<>
                    end
                  else if (tmp='{') then
                      begin
                        addLex(COUNT, curLen, maxLen, '{..', true);
                        inc(strBegin);
                      end
                    else if (tmp=';') then
                        begin
                          addLex(COUNT, curLen, maxLen, ';', true);
                          inc(strBegin);
                        end
                      else if (tmp='while') then
                          begin
                            //isClearWhile?
                            //переход str<>
                          end
                        else
                          begin
                            strEnd:=findTerm(LEXEMS, strBegin);

                          end;

            end;

        end;

    end;   }

  procedure formOut(const COUNT: tCountAr; var f: textFile);
    var
      i, k, len: integer;
      operatorDict, operandDict, operatorGen, operandGen: integer;
    begin
      operatorDict:=0;
      operandDict:=0;
      operatorGen:=0;
      operandGen:=0;

      k:=1;
      writeln(f, 'Operators:');
      writeln(f, 'num#':8,'lex. entries':12,'lexem');
      for i:=0 to numLength-1 do
        begin
          if (COUNT[i].isOperator = true) then
            begin
              writeln(f, k:8, COUNT[i].num:12,' - ',COUNT[i].lex);
              inc(k);
              inc(operatorGen, COUNT[i].num);
            end;
        end;
      operatorDict:=k;
      writeln(f);
      k:=1;
      writeln(f, 'Operands:');
      writeln(f, 'num#':8,'lex. entries':12,'lexem');
      for i:=0 to numLength-1 do
        begin
          if (COUNT[i].isOperator = false) then
            begin
              writeln(f, k:8, COUNT[i].num:12,' - ',COUNT[i].lex);
              inc(k);
            end;
          inc(operandGen, COUNT[i].num);
        end;
      operandDict:=k;
      writeln(f);
      writeln(f,'Operators dictionary: ',operatorDict,' - Operators, in total: ',operatorGen);
      writeln(f,'Operands dictionary: ',operandDict,' - Operands, in total: ',operandGen);
      writeln(f,'Program dictionary: ',operatorDict+operandDict);
      writeln(f,'Program length: ',operatorGen+operandGen);
      writeln(f,'Program volume: ', (operatorGen+operandGen)*Round(log2(operatorDict+operandDict)) );
    end;
end.
