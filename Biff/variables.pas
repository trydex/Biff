unit variables;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Math, INIFiles, ComCtrls, ExtCtrls, UnitDialog, Utils, StrUtils ;

const
  WM_UPDATE_PB = WM_USER;
  MaxI = 1000;

type
  TPriceData = record
    PriceDate: TDateTime;
    VOO: real;
    UPRO: real;
    Vol: real;  // Volatility
    NumGroup: integer;
  end;
  TArrPriceData = array of TPriceData;

  TRatio = record
    VOOPerc, UPROPerc: real;   // 0.00, 0.01, ..0.99, 1.00
    Total, Bankruptcy: integer;
    R0, R100: integer;          // New for count outside range
    FRatio: real;  // Bankruptcy / Total ??
  end;
  TRatioArray =  array [0..MaxI] of TRatio;
  PRatio = ^TRatio; // Pointer to a record TRatio

  TRatioForDay = record
    FCapital: real;
//    RatioSimple: integer;  //   0..100 for UPRO
//    RatioAdv: integer;     //   0..100 for UPRO use previus level
    FNumSim: integer;
  end;

  TRatioDayArray = record
    FDay: integer;
    FMyBankr: real;         // maybe not
    FUPROBankr: integer;    // maybe not
    FPercent: real;
    RatioForDay: array [0..MaxI] of TRatioForDay;
  end;

  TTable = array of TRatioDayArray;
  PTable = ^TTable;
  PCardinal = ^Cardinal;

  TCaclBankruptcyAlgo = (AlgoSimple, AlgoAdvanced, AlgoExtra);

  TBestRatioCase = (CaseFindBestRatio, CaseDailyRisk, CaseSomeNameForm3);

  TArrayReal = array of real;    // for sort array of Total_EV

  TArrVolGroup = array[0..22] of real;

  TParameter = record
    ScreenName: string;
    DateOfBirth: TDate;
    TargetRisk, RiskWithDeath, TodayRisk: real;
    StocksCapital, GoldCapital, TotalBankroll: real;
    MonthlyExpences, DailyExpences: real;
    AdvancedUser: boolean;
    FNumSim: int64;
    IsBankruptcy: boolean;
    UPROBankr: integer;
    BusinessDaysLeft, TodayDayLeft: integer;
    TodayVol: real;
    TodayVolGroup: integer;
  end;

const
  GroupVol: array[0..22] of real =
   (0.00268444417, 0.00314709083, 0.0035062525, 0.0038021225, 0.0040878625, 0.0043652625, 0.00464857167,
    0.00494001333, 0.005232215, 0.00550140167, 0.005775275, 0.00607376, 0.00642635167, 0.00683055, 0.0072788175,
    0.0077491975, 0.00835090583, 0.0091001775, 0.01011414667, 0.01150477083, 0.0135928075, 0.01802705333, 1);

type    
  TBestRatioThread = class(TThread)
  private
    ThreadCase: TBestRatioCase;
  public
    constructor Create(ThreadCase: TBestRatioCase);
    procedure Execute; override;
    procedure DoTerminate; override;
  end;

  TCaclBankruptcyThread = class(TThread)
  private
    ANumSim, ACurRatio, ANumDay, ACurDay, AStepDay: integer;
    ACapital, ARasxod: real;
    StartRatio: PRatio;
    CaclBankruptcyAlgo: TCaclBankruptcyAlgo;
    FirstSeed: Cardinal;
  public
    constructor Create(FirstSeed: Cardinal; CaclBankruptcyAlgo: TCaclBankruptcyAlgo; ANumSim, ANumDay, ACurDay, AStepDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
    procedure Execute; override;
    destructor Destroy; override;
    //procedure DoTerminate; override;
  end;

var
  CurForm: TForm;
  AllProfiles: TStringList;
  CurProfile: string;
  CurParameter: TParameter;
  TableDayRisk: TArrayReal;

 // procedure FindBestRatioProcedure();
  procedure LoadIniFile;
  procedure SaveIniFile;
  procedure LoadProfileIniFile;
  procedure SaveProfileIniFile;

  procedure GetAllProfiles;
  procedure MemoLinesAdd(AText: string);
  procedure LoadTableDayRisk(var ATable: TArrayReal);
  procedure SaveTableDayRisk(ATable: TArrayReal);
  procedure AddToTableDayRisk(var ATable: TArrayReal; ADayRisk: TArrayReal);

implementation

uses
  Biff_Main, NewUser;

//================================================
constructor TBestRatioThread.Create(ThreadCase: TBestRatioCase);
begin
  inherited create(false);
  FreeOnTerminate := true;
  Priority := tpNormal;

  self.ThreadCase := ThreadCase;
end;

procedure TBestRatioThread.Execute;
begin
  with Form1 do begin  // Old Form1
    //EnableControls(false);
    FindBestRatioThreadSwitcher(self.ThreadCase);
  end;
end;

procedure TBestRatioThread.DoTerminate;
begin
 with Form1 do begin  // Old Form1
  if Terminating = false then
    //EnableControls(true);
  inherited
 end;
end;


constructor TCaclBankruptcyThread.Create(FirstSeed: Cardinal; CaclBankruptcyAlgo: TCaclBankruptcyAlgo; ANumSim, ANumDay, ACurDay, AStepDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
begin
  inherited create(false);
  FreeOnTerminate := true;
  Priority := tpNormal;

  self.CaclBankruptcyAlgo := CaclBankruptcyAlgo;
  self.ANumSim := ANumSim;
  self.ACurRatio := ACurRatio;
  self.ANumDay := ANumDay;
  self.ACurDay := ACurDay;
  self.AStepDay := AStepDay;
  self.ACapital := ACapital;
  self.ARasxod := ARasxod;
  self.StartRatio := StartRatio;
  self.FirstSeed := FirstSeed;
end;

procedure TCaclBankruptcyThread.Execute;
begin
  if CaclBankruptcyAlgo = AlgoSimple then
    Form1.CalcNumBankruptcySimpleInternal(FirstSeed, ANumSim, ANumDay, ACapital, ARasxod, StartRatio)
  else if CaclBankruptcyAlgo = AlgoAdvanced then
    //Form1.CalcNumBankruptcyAdvInternal(FirstSeed, ANumSim, ANumDay, AStepDay, ACapital, ARasxod, StartRatio)
  else if CaclBankruptcyAlgo = AlgoExtra then
    //Form1.CalcNumBankruptcyExtraInternal(FirstSeed, ANumSim, ANumDay, ACurDay, AStepDay, ACapital, ARasxod, StartRatio);
    ;
end;

destructor TCaclBankruptcyThread.Destroy;
begin
  inherited;
end;

//================================================

procedure LoadIniFile;
var
  AIniFile: INIFiles.TIniFile;
  AFileName: string;
  i: integer;
begin
  AFileName:= ExtractFilePath(GetModuleName(0)) + 'startup.ini';
  AIniFile:= IniFiles.TIniFile.Create(AFileName);
  try
    Form1.Left:= AIniFile.ReadInteger('Common', 'Left', Form1.Left);
    Form1.Top:= AIniFile.ReadInteger('Common', 'Top', Form1.Top);
    Form1.Width:= AIniFile.ReadInteger('Common', 'Width', Form1.Width);
    Form1.Height:= AIniFile.ReadInteger('Common', 'Height', Form1.Height);
    with FormNewUser do begin
      Left:= AIniFile.ReadInteger('NewUser', 'Left', Left);
      Top:= AIniFile.ReadInteger('NewUser', 'Top', Top);
      Width:= AIniFile.ReadInteger('NewUser', 'Width', Width);
      Height:= AIniFile.ReadInteger('NewUser', 'Height', Height);
    end;
  finally
    FreeAndNil(AIniFile);
  end;
end;


procedure SaveIniFile;
var
  AIniFile: INIFiles.TIniFile;
  AFileName: string;
  i: integer;
begin
  //GetAllParameter;
  AFileName:= ExtractFilePath(GetModuleName(0)) + 'startup.ini';
  AIniFile:= IniFiles.TIniFile.Create(AFileName);
  try
    AIniFile.WriteInteger('Common', 'Left', Form1.Left);
    AIniFile.WriteInteger('Common', 'Top', Form1.Top);
    AIniFile.WriteInteger('Common', 'Width', Form1.Width);
    AIniFile.WriteInteger('Common', 'Height', Form1.Height);

    //if Assigned(FormNewUser) then begin
     //with TFormNewUser(FormNewUser) do begin
      AIniFile.WriteInteger('NewUser', 'Left', FormNewUser.Left);
      AIniFile.WriteInteger('NewUser', 'Top', FormNewUser.Top);
      AIniFile.WriteInteger('NewUser', 'Width', FormNewUser.Width);
      AIniFile.WriteInteger('NewUser', 'Height', FormNewUser.Height);
     //end;
    //end;

  finally
    FreeAndNil(AIniFile);
  end;
end;

procedure LoadProfileIniFile;
var
  AIniFile: INIFiles.TIniFile;
  AFileName: string;
  i: integer;
begin
  AFileName:= ExtractFilePath(ParamStr(0)) + '\Profiles\' + CurProfile + '\profile.ini';
  AIniFile:= IniFiles.TIniFile.Create(AFileName);
  try
    with CurParameter do begin
      ScreenName:= AIniFile.ReadString('Parameter', 'ScreenName', 'New User');
      DateOfBirth:= StrToDate(AIniFile.ReadString('Parameter', 'DateOfBirth', DateToStr(Date)));
      TargetRisk:= AIniFile.ReadFloat('Parameter', 'TargetRisk', 0) / 100;
      TodayRisk:= AIniFile.ReadFloat('Parameter', 'TodayRisk', 0) / 100;
      StocksCapital:= AIniFile.ReadFloat('Parameter', 'StocksCapital', 20000);
      GoldCapital:= AIniFile.ReadFloat('Parameter', 'GoldCapital', 2000);
      TotalBankroll:= StocksCapital + GoldCapital;
      MonthlyExpences:= AIniFile.ReadFloat('Parameter', 'MonthlyExpences', 20);
      BusinessDaysLeft:= AIniFile.ReadInteger('Parameter', 'BusinessDaysLeft', 0);
      TodayDayLeft:= AIniFile.ReadInteger('Parameter', 'TodayDayLeft', 0);
      AdvancedUser:= AIniFile.ReadBool('Parameter', 'AdvancedUser', false);
      FNumSim:= AIniFile.ReadInteger('Parameter', 'NumSim', 25000);
      IsBankruptcy:= AIniFile.ReadBool('Parameter', 'IsBankruptcy', true);
      UPROBankr:= AIniFile.ReadInteger('Parameter', 'UPROBankr', 50000);
    end;
  finally
    FreeAndNil(AIniFile);
  end;
end;


procedure SaveProfileIniFile;
var
  AIniFile: INIFiles.TIniFile;
  AFileName: string;
  i: integer;
begin
  if CurProfile = '' then Exit;
  AFileName:= ExtractFilePath(ParamStr(0)) + '\Profiles\' + CurProfile + '\profile.ini';
  AIniFile:= IniFiles.TIniFile.Create(AFileName);
  try
   with CurParameter do begin
    AIniFile.WriteString('Parameter', 'ScreenName', ScreenName);
    AIniFile.WriteString('Parameter', 'DateOfBirth', DateToStr(DateOfBirth));
    AIniFile.WriteFloat('Parameter', 'TargetRisk', TargetRisk * 100);
    AIniFile.WriteFloat('Parameter', 'TodayRisk', TodayRisk * 100);
    AIniFile.WriteFloat('Parameter', 'StocksCapital', StocksCapital);
    AIniFile.WriteFloat('Parameter', 'GoldCapital', GoldCapital);
    TotalBankroll:= StocksCapital + GoldCapital;
    AIniFile.WriteFloat('Parameter', 'TotalBankroll', TotalBankroll);
    AIniFile.WriteFloat('Parameter', 'MonthlyExpences', MonthlyExpences);
    AIniFile.WriteInteger('Parameter', 'BusinessDaysLeft', BusinessDaysLeft);
    AIniFile.WriteInteger('Parameter', 'TodayDayLeft', TodayDayLeft);
    AIniFile.WriteBool('Parameter', 'AdvancedUser', AdvancedUser);
    AIniFile.WriteInteger('Parameter', 'NumSim', FNumSim);
    AIniFile.WriteBool('Parameter', 'IsBankruptcy', IsBankruptcy);
    AIniFile.WriteInteger('Parameter', 'UPROBankr', UPROBankr);
   end;
  finally
    FreeAndNil(AIniFile);
  end;
end;


procedure LoadTableDayRisk(var ATable: TArrayReal);
var
  F: TextFile;
  S, FileNameStr: string;
  Index, MaxIndex: integer;
  Risk: real;

  procedure GetData(Str: string; var AIndex: integer; var ARisk: real);
  var PosEqual: integer;
  begin
    PosEqual:= Pos('=', Str);
    AIndex:= StrToIntDef(Copy(Str, 1, PosEqual - 1), 0);
    ARisk:= StrToFloatDef(Copy(Str, PosEqual + 1, 20), 0);  // till end of string
  end;

begin
  FileNameStr:= ExtractFilePath(ParamStr(0)) + '\Profiles\' + CurProfile + '\TableDayRisk.txt';
  AssignFile(F, FileNameStr);
  if IOResult <> 0 then begin
    MessageDlg('Error Loading file ' + FileNameStr, mtError, [mbOk], 0);
    Exit;
  end;
  SetLength(ATable, 20000);
  MaxIndex:= 0;
  while not EOF(F) do begin
    readln(F, S);
    GetData(S, Index, Risk);
    ATable[Index]:= Risk;
    if Index > MaxIndex then
      MaxIndex:= Index;
  end;
  SetLength(ATable, MaxIndex + 1);
  CloseFile(F);
end;

procedure SaveTableDayRisk(ATable: TArrayReal);
var
  F: TextFile;
  S, FileNameStr: string;
  i: integer;
begin
  FileNameStr:= ExtractFilePath(ParamStr(0)) + '\Profiles\' + CurProfile + '\TableDayRisk.txt';
  AssignFile(F, FileNameStr);
  Rewrite(F);
  for i:= High(ATable) downto 0 do begin
    S:= IntToStr(i) + '=' + Format('%.4f', [ATable[i] * 100]);
    writeln(F, S);
  end;
  CloseFile(F);
end;

procedure AddToTableDayRisk(var ATable: TArrayReal; ADayRisk: TArrayReal);
var i, Day: integer;
begin
  with CurParameter do begin
    if Length(ATable) < (BusinessDaysLeft + 1) then begin
      SetLength(ATable, BusinessDaysLeft + 1) ; //Length(ADayRisk));
    end;
    for i:= BusinessDaysLeft downto 1 do begin
      Day:= BusinessDaysLeft - i;
      if Day < Length(ADayRisk) then begin
        ATable[i]:= TodayRisk - ADayRisk[Day];
      end else begin
        ATable[i]:= 0;
      end;
    end;
  end;
end;

procedure GetAllProfiles;
var
  SR: TSearchRec;
  i, FindRes: integer;
  //SL: TStringList;
  AFileMask, FileStr, FileRootStr: string;
begin
  AllProfiles:= TStringList.Create;
  try
    try
      AFileMask:= '*';
      FileRootStr:= ExtractFilePath(ParamStr(0)) + '\Profiles\';
      FindRes:= FindFirst(FileRootStr + AFileMask, faDirectory, SR);
      while FindRes = 0 do begin
        //SR.Name:= SR.Name ;
        if not ((SR.Name = '.') or (SR.Name = '..')) then
          AllProfiles.Add(SR.Name);
        FindRes:= FindNext(SR);
      end;
    finally
      FindClose(SR);
    end;
  finally
   // FreeAndNil(SL);
  end;
end;

procedure MemoLinesAdd(AText: string);
begin
  if Assigned(CurForm) then begin

    if CurForm is TFormNewUser then begin
      with TFormNewUser(CurForm) do begin
        if CheckBoxShowCalculating.Checked then
          Memo1.Lines.Add(AText);
      end;    
    end else if CurForm is TForm1 then begin
      TForm1(CurForm).Memo1.Lines.Add(AText);
    end;
  end;
end;

end.
