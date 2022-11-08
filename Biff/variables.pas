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

  TBestRatioCase = (CaseFindBestRatio, CaseDailyRisk, CaseDailyRiskMain);

  TArrayReal = array of real;    // for sort array of Total_EV
  TArrayInt = array of integer;

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
  Utils: TUtils;
  CurForm: TForm;
  AllProfiles: TStringList;
  CurProfile: string;
  CurParameter: TParameter;
  TableDayRisk: TArrayReal;
  StartTimeTimer: TDateTime;

 // procedure FindBestRatioProcedure();
  procedure LoadIniFile;
  procedure SaveIniFile;
  procedure LoadProfileIniFile;
  procedure SaveProfileIniFile;

  procedure GetAllProfiles;
  procedure MemoLinesAdd(AText: string);
  procedure LoadTableDayRisk(var ATable: TArrayReal);
  procedure SaveTableDayRisk(ATable: TArrayReal);
  procedure SaveArrVolGroup(AArrVolGroup: TArrVolGroup);
  procedure AddToTableDayRisk(var ATable: TArrayReal; ADayRisk: TArrayReal);
  procedure CalculateDayLeft(ATodayDate: TDate);
  function SetProfileTableName: string;
  function SmoothingArrVolGroup(AArrVolGroup: TArrVolGroup): TArrVolGroup;
  procedure EnableControls(enable: bool);

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
    EnableControls(false);
    FindBestRatioThreadSwitcher(self.ThreadCase);
  end;
end;

procedure TBestRatioThread.DoTerminate;
begin
 with Form1 do begin  // Old Form1
  if Terminating = false then
    EnableControls(true);
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
    //if Assigned(Form1) then
    if CurForm is TForm1 then begin
      with TForm1(CurForm) do begin

 //   with Form1 do begin
        Left:= AIniFile.ReadInteger('Common', 'Left', Left);
        Top:= AIniFile.ReadInteger('Common', 'Top', Top);
        Width:= AIniFile.ReadInteger('Common', 'Width', Width);
        Height:= AIniFile.ReadInteger('Common', 'Height', Height);
      end;
    end;
 //   if Assigned(FormNewUser) then
    if CurForm is TFormNewUser then begin
      with TFormNewUser(CurForm) do begin

//    with FormNewUser do begin
        Left:= AIniFile.ReadInteger('NewUser', 'Left', Left);
        Top:= AIniFile.ReadInteger('NewUser', 'Top', Top);
        Width:= AIniFile.ReadInteger('NewUser', 'Width', Width);
        Height:= AIniFile.ReadInteger('NewUser', 'Height', Height);
      end;  
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
  AFileName:= ExtractFilePath(GetModuleName(0)) + 'startup.ini';
  AIniFile:= IniFiles.TIniFile.Create(AFileName);
  try
    if CurForm is TForm1 then begin
      with TForm1(CurForm) do begin
        AIniFile.WriteInteger('Common', 'Left', Left);
        AIniFile.WriteInteger('Common', 'Top', Top);
        AIniFile.WriteInteger('Common', 'Width', Width);
        AIniFile.WriteInteger('Common', 'Height', Height);
      end;
    end;

    if CurForm is TFormNewUser then begin
      with TFormNewUser(CurForm) do begin
        AIniFile.WriteInteger('NewUser', 'Left', Left);
        AIniFile.WriteInteger('NewUser', 'Top', Top);
        AIniFile.WriteInteger('NewUser', 'Width', Width);
        AIniFile.WriteInteger('NewUser', 'Height', Height);
      end;
    end;
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
      DateOfBirth:= Utils.StrToDateEx(AIniFile.ReadString('Parameter', 'DateOfBirth', ''));
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
    AIniFile.WriteString('Parameter', 'DateOfBirth', FormatDateTime(BiffShortDateFomat, DateOfBirth));
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
    ARisk:= StrToFloatDef(Copy(Str, PosEqual + 1, 20), 0) / 100;  // till end of string
  end;

begin
  FileNameStr:= ExtractFilePath(ParamStr(0)) + '\Profiles\' + CurProfile + '\TableDayRisk.txt';
  AssignFile(F, FileNameStr);
  {$I-}
  Reset(F);
  {$I+}
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
  S, FileNameStr, ArchiveNameStr: string;
  i: integer;
  CurDate, DeathDate: TDate;
begin
  FileNameStr:= ExtractFilePath(ParamStr(0)) + '\Profiles\' + CurProfile + '\TableDayRisk.txt';
  AssignFile(F, FileNameStr);
  Rewrite(F);
  for i:= High(ATable) downto 0 do begin
    S:= IntToStr(i) + '=' + Format('%.4f', [ATable[i] * 100]);
    writeln(F, S);
  end;
  CloseFile(F);

  ArchiveNameStr:= ExtractFilePath(GetModuleName(0)) + '\Profiles\' + CurProfile + '\Archive Tables';
  ForceDirectories(ArchiveNameStr);
  ArchiveNameStr:= ArchiveNameStr + '\' + SetProfileTableName;
  AssignFile(F, ArchiveNameStr);
  Rewrite(F);
  DeathDate:= Round(CurParameter.DateOfBirth + 85 * 365.25);
  for i:= High(ATable) downto 0 do begin
    CurDate:= Round(DeathDate - i * 365.25 / 251.2);
    S:= FormatDateTime(BiffShortDateFomat, CurDate) + ' ';
    S:= S + IntToStr(i) + '=' + Format('%.4f', [ATable[i] * 100]);
    writeln(F, S);
  end;
  CloseFile(F);
end;

procedure SaveArrVolGroup(AArrVolGroup: TArrVolGroup);
var
  F: TextFile;
  S, ArchiveNameStr: string;
  i: integer;
begin
  ArchiveNameStr:= ExtractFilePath(GetModuleName(0)) + '\Profiles\' + CurProfile + '\Archive Ratio';
  ForceDirectories(ArchiveNameStr);
  ArchiveNameStr:= ArchiveNameStr + '\' + SetProfileTableName;
  AssignFile(F, ArchiveNameStr);
  Rewrite(F);
  for i:= 0 to High(AArrVolGroup) do begin
    S:= Format(' %2d:  %2.2F' , [i+1, AArrVolGroup[i] * 100]);
    writeln(F, S);
  end;
  CloseFile(F);
end;


procedure AddToTableDayRisk(var ATable: TArrayReal; ADayRisk: TArrayReal);
var i, Day: integer;
begin
  with CurParameter do begin
   // if Length(ATable) < (BusinessDaysLeft + 1) then begin
   //   SetLength(ATable, BusinessDaysLeft + 1) ; //Length(ADayRisk));
   // end;
    TodayRisk:= ADayRisk[High(ADayRisk)];
    SetLength(ATable, BusinessDaysLeft + 1) ; //Length(ADayRisk));
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

procedure CalculateDayLeft(ATodayDate: TDate);
var TodayDate: TDate;
begin
  //TodayDate:= Form1.DateTimePicker1.Date;
  with CurParameter do begin
    DailyExpences:= MonthlyExpences / 20.933;   // Check it !!!
    BusinessDaysLeft:= Trunc(DateofBirth + 85 * 365.25)  - Trunc(ATodayDate);
    BusinessDaysLeft:= Round(BusinessDaysLeft * 251.2 / 365.25);
    TodayDayLeft:= BusinessDaysLeft - Round(GoldCapital / DailyExpences);
  end;  
end;

function SmoothingArrVolGroup(AArrVolGroup: TArrVolGroup): TArrVolGroup;
var
 i: integer;
 Average: real;
 Changed: boolean;
begin
  repeat
    Changed:= false;
    for i:= 0 to High(AArrVolGroup) - 1 do begin
      if AArrVolGroup[i] < AArrVolGroup[i + 1] then begin   //
         Average:= (AArrVolGroup[i] + AArrVolGroup[i + 1]) / 2;
         AArrVolGroup[i]:= Average + 0.0001;
         AArrVolGroup[i + 1]:= Average - 0.0001;
         Changed:= true;
      end;
    end;
  until not Changed;
  Result:= AArrVolGroup;
end;

function SetProfileTableName: string;
var
  TotalStr: string;

   procedure AddStr(PreStr, Root: string);
   begin
     TotalStr:= TotalStr + PreStr + Root + '_';
   end;

begin
  TotalStr:= '';
  with CurParameter do begin
    AddStr('BDL', Format('%d' , [BusinessDaysLeft]));
    AddStr('BDBG', Format('%d' , [TodayDayLeft]));
    AddStr('RISK', Format('%.2f', [TodayRisk * 100]));
    AddStr('S', Format('%d' , [Round(StocksCapital)]));
    AddStr('G', Format('%d' , [Round(GoldCapital)]));
    AddStr('R', Format('%d' , [Round(MonthlyExpences)]));
    TotalStr:= TotalStr + FormatDateTime('yyyy-mm-dd-hh-nn-ss', Now) + '.txt';
  end;
  Result:= TotalStr;
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

procedure EnableControls(enable: bool);
begin
//  if Terminating then
//    Exit;

{
  if Assigned(CurForm) then begin

    if CurForm is TFormNewUser then begin
      with TFormNewUser(CurForm) do begin
        //
      end;
    end else if CurForm is TForm1 then begin
      with TForm1(CurForm) do begin
        ButtonRefreshParameter.Enabled:= enable;
        ButtonCalculateRisk .Enabled:= enable;
        ButtonBestRatio.Enabled:= enable;
        ButtonClearMemo.Enabled:= enable;
      end;
    end;
  end;
  }
end;


end.
