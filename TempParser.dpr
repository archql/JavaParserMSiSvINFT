program TempParser;

{$APPTYPE CONSOLE}

{$R *.res}

uses
    System.SysUtils, CodeParser,
    Math,
    System.ioutils, types,
    ShellApi, Winapi.Windows;

var
    Path, filename  : String;
    Files           : TStringDynArray;
    i, nLexems      : integer;

    lexems          : TArray;

    fileIn, fileOut : TextFile;

begin

    // Get the current folder
    Path := GetCurrentDir;
    writeln('Files in ' + Path + ': ');

    // Get the files in this folder
    Files := TDirectory.GetFiles(Path, '*.txt');

    // Display the files - just the file names that is
    for i := 0 to Length(Files)-1 do
        writeln(' - ' + TPath.GetFileName(Files[i]));

    repeat
        write('input valid file name (with java code) (.txt): '); readln(filename);
    until FileExists(filename + '.txt');
    AssignFile(fileIn, filename + '.txt', CP_UTF8);   // open file

    reset(fileIn);
    anCode(fileIn, lexems, nLexems);
    closeFile(fileIn);

    // create output
    AssignFile(fileOut, filename + '_out' + '.txt', CP_UTF8);   // open file
    rewrite(fileOut);
    for i := 0 to nLexems do
        writeln(fileOut, lexems[i]);
    closeFile(fileOut);


    readln;
end.
