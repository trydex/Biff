unit Biff_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Math, INIFiles, ComCtrls, ExtCtrls, UnitDialog, Utils, StrUtils,
  profile, variables, Login, NewUser; 

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    EditCapital: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Editrasxod: TEdit;
    Label3: TLabel;
    EditDays: TEdit;
    Label4: TLabel;
    EditSims: TEdit;
    ButtonClearMemo: TButton;
    Label5: TLabel;
    EditUPROPer: TEdit;
    ButtonUPRO: TButton;
    CheckBoxBankruptcy: TCheckBox;
    Label6: TLabel;
    EditMyBankr: TEdit;
    EditUPROBankr: TEdit;
    ButtonBestRatio: TButton;
    StatusBar1: TStatusBar;
    RadioGroupBiff: TRadioGroup;
    ProgressBar: TProgressBar;
    ButtonStopFillTable: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ButtonClearMemoClick(Sender: TObject);
    procedure ButtonUPROClick(Sender: TObject);
    procedure ButtonBestRatioClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EnableControls(enable: bool);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Memo1KeyPress(Sender: TObject; var Key: Char);
    procedure NumericEditKeyPress(Sender: TObject; var Key: Char);
    procedure FloatEditKeyPress(Sender: TObject; var Key: Char);

  private
    { Private declarations }
  public
    BestRatioThread: TBestRatioThread;
    CaclBankruptcyThreads: array of TCaclBankruptcyThread;
    //IsClosing: bool;
    CalculationIsRuning: bool;
    MaxThreads: integer;
    TotalSteps: integer;
    TotalStepsTime: real;
    StepsThrottling: Cardinal;
    Version: string;
  //  procedure WMUpdatePB(var msg: TMessage); message WM_UPDATE_PB;
  //public
    { Public declarations }

    PriceData: TArrPriceData;
    PriceData2Dim: array of TArrPriceData;
    StartCapital: real;
    Rasxod: real;
    NumDay: integer;
    NumSim: int64;
    MyBankr: real;
    UPROBankr: integer;
    FUPROPerc, FVOOPerc: real;
    TotalDay, StepDay, ReRatioDay: integer;
    IsBankruptcy: boolean;
    IsInflation: boolean;   // allways true
    RatioArray: TRatioArray;
    ZeroRatioArray: TRatioArray;
    LogFileName: string;
    
{    Advanced: boolean;
    NumAlgo: integer;            // 0 - Biff 1, 1 - Biff 1.5, 2 - Biff 2.0, 3 - Biff 3.0
    IsBankruptcy: boolean;
    IsInflation: boolean;
    Correction: boolean;
    RatioArray: TRatioArray;
    ZeroRatioArray: TRatioArray;
    CurTable: TTable;  //array of TRatioDayArray;
    ExtraTable: TTable; 
    CurTableFileName: string;
    StartPrcFileName: string;
    StartTimeTimer: TDateTime;
    LogFileName: string;
    Precision: real;   // need for Biff3 Fill Table
    StartPercentArr: array of real;
    ManualStartPercentOn: boolean;
    }
    NumVolGroup: integer;     // temporally
    ArrVolGroup: TArrVolGroup;  //array[0..22] of real;
    OrigArrVolGroup: TArrVolGroup;
    ArrProbDeath: array of real;
    ArrProbDeath2: array[15..84] of array of real;
    IsClosing: bool;

    procedure WMUpdatePB(var msg: TMessage); message WM_UPDATE_PB;
    procedure OpenPriceFile;
    procedure OpenPriceFileByName(var APriceData: TArrPriceData; AFileName: string);
    function GetDirectoryName(NumGroup: integer): string;
    procedure GetProbDeath;
    procedure GetProbDeathArr;
    procedure GetAllParameter;
    procedure LoadIniFile;
    procedure SaveIniFile;
    procedure SetLogFileName;
    procedure SaveLog;
    //procedure CalculateEV;
    procedure CalculateDayRisk(AStartCapital, ARasxod, AMyBankr: real; ANumDay, ANumSim: integer);
    procedure CreateTableDayRisk(AStartCapital, ARasxod, AMyBankr: real; ANumDay, ANumSim: integer);
    procedure FindBestRatioProcedure;
    function FindBestRatio(ACapital, ARasxod, APercent: real; ANumDay, ANumSim: integer): integer;  // Result 0..100 Perc for UPRO
    function FindBestRatio_12DayVol(ACapital, ARasxod, APercent: real; ANumDay, ANumSim: integer): integer;  // Result 0..100 Perc for UPRO
    function FindBestRatio_12DayVol2(ACapital, ARasxod, APercent: real; ANumDay, ANumSim: integer): integer;  // Result 0..100 Perc for UPRO

  //  function FindBestRatioAdv(ACapital, ARasxod, APercent: real; ANumDay, ANumSim, AStepDay: integer): integer;  // Result 0..100 Perc for UPRO
 //   procedure CalcNumBankruptcyAdvInternal(FirstSeed: Cardinal; AInnerNumSim, ANumDay, AStepDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
    procedure CalcNumBankruptcySimple(ANumSim,  ANumDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
    procedure CalcNumBankruptcySimpleInternal(FirstSeed: Cardinal; ANumSim, ANumDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
    procedure qSort(var A: TArrayReal; min, max: Integer);

    function CreatePriceDataArray(ANumDay: integer; FirstSeed: PCardinal): TArrPriceData;
//    function BacktestPriceDataArray(AFromDay, ANumDay: integer; FirstSeed: PCardinal): TArrPriceData;

    function CorrectArrVolGroup(FArrVolGroup: TArrVolGroup; Delta: real): TArrVolGroup;
    function CreateArrVolGroup(APercent: real): TArrVolGroup;
    procedure ShowArrVolGroup(AArrVolGroup: TArrVolGroup);
    function NotEmpty(AArrVolGroup: TArrVolGroup): boolean;

 end;

var
  Form1: TForm1;
  Utils: TUtils;
  Terminating : bool;
  //DecimalSeparator : char;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
  var i: integer;
  Label BeginProfile;
begin
  GetAllProfiles;
  BeginProfile: 
  if not Assigned(FormProfile) then
    FormProfile:= TFormProfile.Create(Self);
  FormProfile.ShowModal;
  if FormProfile.ModalResult = mrYes then begin  // New User
    if not Assigned(FormNewUser) then
      FormNewUser:= TFormNewUser.Create(Self);
    FormNewUser.Show;
  end else if FormProfile.ModalResult = mrOk then begin  // Login
    if not Assigned(FormLogin) then
      FormLogin:= TFormLogin.Create(Self);
    FormLogin.ShowModal;
    if FormLogin.ModalResult = mrOk then begin
      CurProfile:= AllProfiles[Formlogin.ListBox1.ItemIndex];
    end else if FormLogin.ModalResult = mrAbort then begin
      goto BeginProfile;
    end else begin
      IsClosing:= true;
      Close;
    end;
    FormLogin.Free;
  end else begin                      // Close Choose Profile
    IsClosing:= true;
    Close;
  end;
  FormProfile.Free;

  Randomize;
  // Update decimal separator only for currect application.
  Application.UpdateFormatSettings := false;
  DecimalSeparator := '.';

  // Init some default values.
  ProgressBar.DoubleBuffered := true;
  MaxThreads := Utils.GetCpuCount;
  TotalStepsTime := 0;
  Version := Caption;

  LoadIniFile;
  GetAllParameter;
  if IsInflation = false then
    OpenPriceFile; // load price file only if it wasn't loaded before
  //LoadTable; // uncomment to auto-load a table on start
  GetProbDeath;
  GetProbDeathArr;
  EditUPROPer.Text := '0'; // Temporary

  for i:= 0 to MaxI do begin
    with ZeroRatioArray[i] do begin
      UPROPerc:= i / MaxI;
      VOOPerc:= 1 - UPROPerc;
      Total:= 0;
      Bankruptcy:= 0;
      FRatio:= 0;
    end;
  end;
 SetLogFileName;
end;

procedure TForm1.SetLogFileName;
begin
  LogFileName:= Caption + '_'+  FormatDateTime('yyyy-mm-dd-hh-nn-ss', Now) + '.txt';
end;

procedure TForm1.SaveLog;
begin
  Memo1.Lines.SaveToFile(LogFileName);
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  SaveLog;
  SaveIniFile;
end;


procedure TForm1.ButtonUPROClick(Sender: TObject);
begin
  GetAllParameter;
 // CalculateEV;
  SaveLog;
end;

procedure TForm1.ButtonClearMemoClick(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TForm1.OpenPriceFile;
var i, Suma: integer;
begin
  OpenPriceFileByName(PriceData, '');
  SetLength(PriceData2Dim, 23);
  for i:= 0 to High(PriceData2Dim) do begin
    OpenPriceFileByName(PriceData2Dim[i], GetDirectoryName(i + 1));
  end;
end;

function TForm1.GetDirectoryName(NumGroup: integer): string;
var
  SR: TSearchRec;
  FindRes: integer;
  SL: TStringList;
  AFileMask, FileStr, FileRootStr: string;
begin
  SL:= TStringList.Create;
  try
    try
      AFileMask:= IntToStr(NumGroup) + ')*';
      FileRootStr:= ExtractFilePath(ParamStr(0)) + '\Prices\';
      FindRes:= FindFirst(FileRootStr + AFileMask, faAnyFile, SR);
      while FindRes = 0 do begin
        SR.Name:= FileRootStr + SR.Name ;
        SL.Add(SR.Name);
        FindRes:= FindNext(SR);
      end;
    finally
      FindClose(SR);
    end;
    if SL.Count = 1 then begin
      FileStr:= SL[0];
    end else begin
      ShowMessage('Directory for group ' + IntToStr(NumGroup) + 'not finded.');
      FileStr:= '';
    end;
  finally
    FreeAndNil(SL);
  end;
  Result:= FileStr + '\';
end;


procedure TForm1.OpenPriceFileByName(var APriceData: TArrPriceData; AFileName: string);
var
  i: integer;
  S, CurStr, PriceFileName: string;

  function GetFirstString(var FullStr: string): string;
  var PosSpace: integer;
  begin
    PosSpace:= Pos(#9, FullStr);   // Tab symbol
    if PosSpace > 0 then begin
      Result:= Copy(FullStr, 1, PosSpace - 1);
      Delete(FullStr, 1, PosSpace);
    end else
      Result:= FullStr;
    if Length(Result) < 1 then
  end;

begin
  if IsInflation then
    PriceFileName:= AFileName + 'price_i.txt'
  else
    PriceFileName:= AFileName + 'price_new.txt';
 try
  Memo1.Lines.Clear;
  Memo1.Lines.LoadFromFile(PriceFileName);
  SetLength(APriceData, Memo1.Lines.Count);

  for i:= 0 to Memo1.Lines.Count - 1 do begin
    //with APriceData[i] do begin
    with APriceData[Memo1.Lines.Count - 1 - i] do begin
      S:= Memo1.Lines[i];
      CurStr:= GetFirstString(S);
      PriceDate:= Utils.StrToDateEx(CurStr);
      CurStr:= GetFirstString(S);
      VOO:= StrToFloat(CurStr);
      CurStr:= GetFirstString(S);
      UPRO:= StrToFloat(CurStr);
      Vol:= Abs(VOO - 1.0006825);
    end;
  end;
  Memo1.Lines.Clear;
  StatusBar1.Panels[1].Text:= 'Downloaded Price File: ' + PriceFileName;
  //Memo1.Lines.Add('Downloaded Price File: ' + PriceFileName);
 except
   Memo1.Lines.Add('File ' + PriceFileName + ' not found.')
 end;
end;

procedure TForm1.GetProbDeath;
var
  i: integer;
  FileNameStr, S: string;
begin
  FileNameStr:= ExtractFilePath(ParamStr(0)) + '\Prices\prob_death.txt';
  try
    Memo1.Lines.Clear;
    Memo1.Lines.LoadFromFile(FileNameStr);
    SetLength(ArrProbDeath, Memo1.Lines.Count);
    for i:= 0 to Memo1.Lines.Count - 1 do begin
      S:= Memo1.Lines[i];
      ArrProbDeath[i]:= StrToFloat(S);
    end;
    Memo1.Lines.Clear;
  except
    Memo1.Lines.Add('File ' + FileNameStr + ' not found.')
  end;
end;

procedure TForm1.GetProbDeathArr;
var
  i, k: integer;
  FileNameStr, S: string;
begin
 for k:= Low(ArrProbDeath2) to High(ArrProbDeath2) do begin
  FileNameStr:= ExtractFilePath(ParamStr(0)) + '\Prob_Death\' + IntToStr(k) + ').txt';
  try
    Memo1.Lines.Clear;
    Memo1.Lines.LoadFromFile(FileNameStr);
    SetLength(ArrProbDeath2[k], Memo1.Lines.Count);
    for i:= 0 to Memo1.Lines.Count - 1 do begin
      S:= Memo1.Lines[i];
      ArrProbDeath2[k][i]:= StrToFloat(S);
    end;
    Memo1.Lines.Clear;
  except
    Memo1.Lines.Add('File ' + FileNameStr + ' not found.')
  end;
 end;
 //
end;


function TForm1.CreatePriceDataArray(ANumDay: integer; FirstSeed: PCardinal): TArrPriceData;
var i, N,  NumGroup, Index: integer;
  SumaVol: real;
  RandSeed: Cardinal;
  ArrPriceData: TArrPriceData;

  function MyRandInt(Range: integer) : integer;
  asm
      PUSH    EBX
      XOR     EBX, EBX
      IMUL    EDX,[EBX].RandSeed,08088405H
      INC     EDX
      MOV     [EBX].RandSeed,EDX
      MUL     EDX
      MOV     EAX,EDX
      POP     EBX
  end;

  function FindNumGroup(ToFind: real): integer;
  var
    N, First, Last, Mid: integer;
  begin
    First:= 0;  Last:= 22;
    while First < Last do begin
      Mid:= (First + Last) div 2;
      if GroupVol[Mid] < ToFind then
        First:= Mid + 1
      else
        Last:= Mid ;
    end;
    Result:= First;  // or Last
  end;

begin
  RandSeed := FirstSeed^;
  SetLength(ArrPriceData, ANumDay + 1);   // not use 0-index of array
  N:= Length(PriceData);
  begin                                   // 12-Day Volatility
    SumaVol:= 0;
    for i:= 1 to 12 do begin
      Index:= MyRandInt(N);
      ArrPriceData[i]:= PriceData[Index];
      SumaVol:= SumaVol + ArrPriceData[i].Vol;
      ArrPriceData[i].NumGroup:= FindNumGroup(SumaVol / i);
    end;

   if NumVolGroup >=0 then begin
    NumGroup:= NumVolGroup; //FindNumGroup(SumaVol / 12);
    N:= Length(PriceData2Dim[NumGroup]);
    for i:= 13 to ANumDay do begin
      Index:= MyRandInt(N);
      ArrPriceData[i]:= PriceData2Dim[NumGroup][Index];
      //SumaVol:= SumaVol - ArrPriceData[i - 12].Vol + ArrPriceData[i].Vol;  // nor need find NumGroup
      ArrPriceData[i].NumGroup:= NumGroup;
    end;

   end else begin
    for i:= 13 to ANumDay do begin
      NumGroup:= FindNumGroup(SumaVol / 12);
      Index:= MyRandInt(Length(PriceData2Dim[NumGroup]));
      ArrPriceData[i]:= PriceData2Dim[NumGroup][Index];
      SumaVol:= SumaVol - ArrPriceData[i - 12].Vol + ArrPriceData[i].Vol;
      ArrPriceData[i].NumGroup:= NumGroup;
    end;
   end; 
  end;

  FirstSeed^ := RandSeed;
  Result := ArrPriceData; 
end;


procedure TForm1.GetAllParameter;
begin
  StartCapital:= StrToFloatDef(EditCapital.Text, 100000);
  Rasxod:=  StrToFloatDef(EditRasxod.Text, 10);
  NumDay:= StrToIntDef(EditDays.Text, 250);
  NumSim:= StrToIntDef(EditSims.Text, 1000000);
  MYBankr:= StrToFloatDef(EditMyBankr.Text, 10) / 100;
  UPROBankr:= StrToIntDef(EditUPROBankr.Text, 50000);
  IsBankruptcy:= CheckBoxBankruptcy.Checked;
  FUPROPerc:= StrToFloatDef(EditUPROPer.Text, 0) / 100;
  FVOOPerc:= 1 - FUPROPerc;
end;

procedure TForm1.LoadIniFile;
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
    Form1.Width:= AIniFile.ReadInteger('Common', 'Width', Form1.Left);
    Form1.Height:= AIniFile.ReadInteger('Common', 'Height', Form1.Left);

    EditCapital.Text:= AIniFile.ReadString('Common', 'Initial Money', '100000');
    EditRasxod.Text:= AIniFile.ReadString('Common', 'Daily Expenses', '1');
    EditDays.Text:= AIniFile.ReadString('Common', 'NumDay', '2000');
    EditSims.Text:= AIniFile.ReadString('Common', 'NumSim', '20000');
    EditMyBankr.Text:= AIniFile.ReadString('Common', 'Risk Of Ruin', '10');
    EditUPROBankr.Text:= AIniFile.ReadString('Common', 'UPRO Daily Fail', '50000');
    CheckBoxBankruptcy.Checked:= AIniFile.ReadBool('Common', 'IsBankruptcy', CheckBoxBankruptcy.Checked);
    EditUPROPer.Text:= AIniFile.ReadString('Common', 'UPRO Perc', '100');
    {
    EditTotalDay.Text:= AIniFile.ReadString('Common', 'Total Day', '5000');
    EditStepDay.Text:= AIniFile.ReadString('Common', 'Step Day', '1000');
    EditReRatioDay.Text:= AIniFile.ReadString('Common', 'ReRatio Day', '1');
    CheckBoxReRatio.Checked:= AIniFile.ReadBool('Common', 'ReRatio On', CheckBoxReRatio.Checked);

    CheckBoxAdv.Checked:= AIniFile.ReadBool('Common', 'Advanced', CheckBoxAdv.Checked);
    CheckBoxInflation.Checked:= AIniFile.ReadBool('Common', 'IsInflation', CheckBoxInflation.Checked);
    CurTableFileName:= AIniFile.ReadString('Common', 'Table File Name', '');
    RadioGroupBiff.ItemIndex:= AIniFile.ReadInteger('Common', 'Num Algo', RadioGroupBiff.ItemIndex);
    Precision:= AIniFile.ReadFloat('Common', 'Precision %', 1) / 100;
    //ManualStartPercentOn:= AIniFile.ReadBool('Common', 'ManualStartPercentOn', false);
    ManualStartPercentOn:= false;
    SetLength(StartPercentArr, 0);
    }
  finally
    FreeAndNil(AIniFile);
  end;
end;

procedure TForm1.SaveIniFile;
var
  AIniFile: INIFiles.TIniFile;
  AFileName: string;
  i: integer;
begin
  GetAllParameter;
  AFileName:= ExtractFilePath(GetModuleName(0)) + 'startup.ini';
  AIniFile:= IniFiles.TIniFile.Create(AFileName);
  try
    AIniFile.WriteInteger('Common', 'Left', Form1.Left);
    AIniFile.WriteInteger('Common', 'Top', Form1.Top);
    AIniFile.WriteInteger('Common', 'Width', Form1.Width);
    AIniFile.WriteInteger('Common', 'Height', Form1.Height);


    AIniFile.WriteFloat('Common', 'Initial Money', StartCapital);
    AIniFile.WriteFloat('Common', 'Daily Expenses', Rasxod);
    AIniFile.WriteInteger('Common', 'NumDay', NumDay);
    AIniFile.WriteInteger('Common', 'NumSim', NumSim);
    AIniFile.WriteFloat('Common', 'Risk Of Ruin', MyBankr * 100);
    AIniFile.WriteInteger('Common', 'UPRO Daily Fail', UPROBankr);
    AIniFile.WriteBool('Common', 'IsBankruptcy', IsBankruptcy);
    AIniFile.WriteFloat('Common', 'UPRO Perc', FUPROPerc * 100);
    AIniFile.WriteInteger('Common', 'Total Day', TotalDay);
    AIniFile.WriteInteger('Common', 'Step Day', StepDay);
    AIniFile.WriteInteger('Common', 'ReRatio Day', ReRatioDay);

  finally
    FreeAndNil(AIniFile);
  end;
end;

function TForm1.CorrectArrVolGroup(FArrVolGroup: TArrVolGroup; Delta: real): TArrVolGroup;
var i: integer;
begin
  for i:= 0 to 22 do begin
    Result[i]:= FArrVolGroup[i] * Delta;
    if Result[i] > 1 then
      Result[i]:= 1;
    if Result[i] < 0 then
      Result[i]:= 0;
  end;
end;

procedure TForm1.qSort(var A: TArrayReal; min, max: Integer);
var
  i, j: integer;
  supp, tmp: real;
begin
  supp:=A[max-((max-min) div 2)];
  i:=min; j:=max;
  while i<j do
    begin
      while A[i]<supp do i:=i+1;
      while A[j]>supp do j:=j-1;
      if i<=j then
        begin
          tmp:=A[i]; A[i]:=A[j]; A[j]:=tmp;
          i:=i+1; j:=j-1;
        end;
    end;
  if min<j then qSort(A, min, j);
  if i<max then qSort(A, i, max);
end;



procedure TForm1.CalcNumBankruptcySimple(ANumSim,  ANumDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
var t, threadLimit, stepsThread: integer;
    c1, c2, f: Int64;
    //time: string; // uncomment for debug to track time
    handles: array of THandle;
    CurrentTicks: Cardinal;
begin
  QueryPerformanceFrequency(f);
  QueryPerformanceCounter(c1);

  threadLimit := MaxThreads;
  if threadLimit > ANumSim then
    threadLimit := ANumSim;
  SetLength(CaclBankruptcyThreads, threadLimit);
  SetLength(handles, threadLimit);
  stepsThread := ANumSim div threadLimit; // total number of iterations for each thread
  //stepsAdditional := ANumSim - (stepsThread * threadLimit); // additional calls
  CurrentTicks := GetTickCount;

  // Create threads.
  for t:= 0 to threadLimit-1 do begin
    CaclBankruptcyThreads[t] := TCaclBankruptcyThread.Create(CurrentTicks, AlgoSimple, stepsThread, ANumDay, 0, 0, ACapital, ARasxod, StartRatio);
    handles[t] := CaclBankruptcyThreads[t].Handle;
    CurrentTicks := CurrentTicks + 1;
  end;
  WaitForMultipleObjects(threadLimit, Pointer(handles), true, INFINITE);
  Finalize(handles);
  Finalize(CaclBankruptcyThreads);
  SetLength(CaclBankruptcyThreads, 0);

  with StartRatio^ do begin
    Total:= Total + ANumSim {stepsThread};
    FRatio:= Bankruptcy / Total;
  end;
  InterlockedIncrement(TotalSteps);

  // Calculate execution time.
  QueryPerformanceCounter(c2);
  //time := FloatToStr((c2-c1)/f*1000); // uncomment for debug to track time
  TotalStepsTime := TotalStepsTime + (c2-c1)/f*1000;
  if CurrentTicks - StepsThrottling >= 1000 then begin
    StepsThrottling := GetTickCount;
    Caption := Version + '  Total steps: ' + IntToStr(TotalSteps) + ' av.step msec: ' + Format('%.1f', [TotalStepsTime/TotalSteps]);
  end;
end;

procedure TForm1.CalcNumBankruptcySimpleInternal(FirstSeed: Cardinal; ANumSim, ANumDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
var i, k, index, priceDataLength : integer;
  TotalCapital, UPROPart: real;
  RandSeed,RandSeed2: Cardinal;
  ArrPriceData: TArrPriceData;
  CurUPROPer, CurVOOPer: real;

function MyRandInt(Range: integer) : integer;
asm
    PUSH    EBX
    XOR     EBX, EBX
    IMUL    EDX,[EBX].RandSeed,08088405H
    INC     EDX
    MOV     [EBX].RandSeed,EDX
    MUL     EDX
    MOV     EAX,EDX
    POP     EBX
end;
begin    // new version from 2.01
  //priceDataLength:= Length(PriceData);
  RandSeed := FirstSeed;

  for i:= 1 to ANumSim do begin
    TotalCapital:= ACapital;
    ArrPriceData := CreatePriceDataArray(ANumDay, @RandSeed);
    for k:= 1 to ANumDay do begin
      if Terminating then
        Exit;
      with ArrPriceData[k] do begin

         if NumVolGroup > -1 then begin   // not use ArrVolGroup
           CurUPROPer:= StartRatio.UPROPerc;
           CurVOOPer:= StartRatio.VOOPerc;
         end else begin                           // use ArrVolGroup
           CurUPROPer:= ArrVolGroup[NumGroup];
           CurVOOPer:= 1 - CurUPROPer;
         end;


        UPROPart:= CurUPROPer * UPRO;
        if IsBankruptcy then begin
          if MyRandInt(UPROBankr) = 0 then
            UPROPart:= 0;
        end;

        TotalCapital:= TotalCapital * (CurVOOPer * VOO + UPROPart) - ARasxod;
        if TotalCapital <= 0 then begin
          InterlockedIncrement(StartRatio.Bankruptcy);
          TotalCapital:= 0;
          Break;
        end;
      end;
    end;
  end;
end;


function TForm1.FindBestRatio(ACapital, ARasxod, APercent: real; ANumDay, ANumSim: integer): integer;  // Result 0..100 Perc for UPRO
var
  CurRatio, First, Last, InnerNumSim: integer;
  StartRatioArray: TRatioArray;
  StartTime: TDateTime;
  CurMyBankr: real;
begin
//  Memo1.Lines.Add('');
//  Memo1.Lines.Add(Format('Capital: %.0f, Rasxod: %.0f, Percent: %.4f, Days: %d, Sim: %d ',
//                         [ACapital, ARasxod, APercent*100, ANumDay, ANumSim]));
  StartRatioArray:= ZeroRatioArray;
  StartTime:= Now;
  InnerNumSim:= ANumSim div 5;

  CurMyBankr:= APercent;
  Result:= -1;
  First:= 0;
  Last:=MaxI;

  while Result < 0 do begin
    if Terminating then
      Break;
  //repeat
    if Last - First = 1 then begin
      if StartRatioArray[First].Total > StartRatioArray[Last].Total  then
        CurRatio:= Last
      else
        CurRatio:= First;
    end else begin
      CurRatio:= (First + Last) div 2;
    end;
    CalcNumBankruptcySimple(InnerNumSim, ANumDay, ACapital, ARasxod, @(StartRatioArray[CurRatio]));
    with StartRatioArray[CurRatio] do begin
      if Total >= ANumSim then begin    // End calculation
        Result:= CurRatio;
        if FRatio > CurMyBankr then begin
          Result:= Result - 1;
          if Result < 0 then
            Result:= 0;
        end;
      end else if FRatio > CurMyBankr then begin
        Last:= CurRatio;
        if (First = Last) and (Last > 0) then
          First:= Last - 1;
      end else begin
        First:= CurRatio;
        if (First = Last) and ( First < MaxI) then
          Last:= First + 1;
      end;
    end;
  end;   //while
  StartTime:= Now - StartTime;
//  Memo1.Lines.Add('Time: ' + TimeToStr(StartTime));
//  Memo1.Lines.Add(Format('Day Left: %d,  Best Ratio: %f ', [ANumDay, Result * 100 / MaxI]));
//  EditUPROPer.Text:= FloatToStr(Result * 100 / MaxI);

end;

function TForm1.FindBestRatio_12DayVol(ACapital, ARasxod, APercent: real; ANumDay, ANumSim: integer): integer;  // Result 0..100 Perc for UPRO
var
  CurRatio, First, Last, InnerNumSim: integer;
  StartRatioArray: TRatioArray;
  StartTime: TDateTime;
  CurMyBankr: real;
  Delta, OffSet: real;
begin
 // Memo1.Lines.Add('');
 // Memo1.Lines.Add(Format('Capital: %.0f, Rasxod: %.0f, Percent: %.4f, Days: %d, Sim: %d ',
 //                        [ACapital, ARasxod, APercent*100, ANumDay, ANumSim]));
  NumVolGroup:= -1;   // use ArrVolGroup
  StartRatioArray:= ZeroRatioArray;
  StartTime:= Now;
  InnerNumSim:= ANumSim div 5;

    //CurMyBankr:= MyBankr;         // old Algo
  CurMyBankr:= APercent;
  Result:= -1;

  CalcNumBankruptcySimple(InnerNumSim, ANumDay, ACapital, ARasxod, @(StartRatioArray[0]));
  if StartRatioArray[0].FRatio < CurMyBankr then begin
    OffSet:= 0;
  end else begin
    OffSet:= 1;
  end;
      
  First:= 0;
  Last:=MaxI;

  while Result < 0 do begin
    if Terminating then
      Break;

    if Last - First = 1 then begin
      if StartRatioArray[First].Total > StartRatioArray[Last].Total  then
        CurRatio:= Last
      else
        CurRatio:= First;
    end else begin
      CurRatio:= (First + Last) div 2;
    end;

    /////  only this line differ from original FindBestRatio
    Delta:= CurRatio / MaxI - OffSet;
//    if RadioGroupDeltaMethod.ItemIndex = 0 then begin   // Add
//      Memo1.Lines.Add(Format('DeltaProc = %.1f ', [Delta * 100]));
//      ArrVolGroup:= CorrectArrVolGroup(OrigArrVolGroup, Delta); // 500 = 0
    begin                                      // Multiplay
      Delta:= 1 + Delta ;
      Memo1.Lines.Add(Format('DeltaProc = *%.4f ', [Delta]));
      ArrVolGroup:= CorrectArrVolGroup(OrigArrVolGroup, Delta); // 500 = 0
    end;
    CalcNumBankruptcySimple(InnerNumSim, ANumDay, ACapital, ARasxod, @(StartRatioArray[CurRatio]));

    with StartRatioArray[CurRatio] do begin
      if Total >= ANumSim then begin    // End calculation
        Result:= CurRatio;
        if FRatio > CurMyBankr then begin
          Result:= Result - 1;
          if Result < 0 then
            Result:= 0;
        end;
      end else if FRatio > CurMyBankr then begin
        Last:= CurRatio;
        if (First = Last) and (Last > 0) then
          First:= Last - 1;
      end else begin
        First:= CurRatio;
        if (First = Last) and ( First < MaxI) then
          Last:= First + 1;
      end;
    end;
  end;   //while
  StartTime:= Now - StartTime;
//  Memo1.Lines.Add('');
  MemoLinesAdd('Time: ' + TimeToStr(StartTime));
//  if RadioGroupDeltaMethod.ItemIndex = 0 then begin   // Add
//    Memo1.Lines.Add(Format('Day Left: %d,  Delta Ratio: %f ', [ANumDay, Delta * 100]));
//    EditUPROPer.Text:= FloatToStr(Delta * 100);
  begin                                      // Multiplay
    MemoLinesAdd(Format(' Koef Ratio: *%f ', [Delta]));
    //EditUPROPer.Text:= FloatToStr(Delta );
  end;

  //EditUPROPer.Text:= FloatToStr(Result * 100 / MaxI);
end;

function TForm1.FindBestRatio_12DayVol2(ACapital, ARasxod, APercent: real; ANumDay, ANumSim: integer): integer;  // Result 0..100 Perc for UPRO
var
  i, CurRatio, First, Last, InnerNumSim: integer;
  StartRatioArray: TRatioArray;
  StartTime: TDateTime;
  CurMyBankr, PrevMyBankr, CurRealRisk, PrevRealRisk: real;
  Delta: real;
begin
  Memo1.Lines.Add('');
  Memo1.Lines.Add(Format('Capital: %.0f, Rasxod: %.0f, Percent: %.4f, Days: %d, Sim: %d ',
                         [ACapital, ARasxod, APercent*100, ANumDay, ANumSim]));
  NumVolGroup:= -1;   // use ArrVolGroup
  StartRatioArray:= ZeroRatioArray;
  StartTime:= Now;
  InnerNumSim:= ANumSim div 5;
  CurMyBankr:= APercent;
  CurRatio:= Round(0.5 * MaxI);
  for i:= 1 to 1 do begin
    OrigArrVolGroup:= CreateArrVolGroup(CurMyBankr);
    NumVolGroup:= -1;   // use ArrVolGroup
    Memo1.Lines.Add(Format('Iteration: %d, Array of Volatility Group for Tardet Risk = %.2f ', [i, CurMyBankr * 100]));
    ShowArrVolGroup(OrigArrVolGroup);
    CalcNumBankruptcySimple(ANumSim, ANumDay, ACapital, ARasxod, @(StartRatioArray[CurRatio]));
    with StartRatioArray[CurRatio] do begin
      Memo1.Lines.Add(Format('Real Risk = %f ', [FRatio * 100]));
      PrevRealRisk:= FRatio;
      Delta:= APercent - FRatio;
      PrevMyBankr:= CurMyBankr;
      CurMyBankr:= CurMyBankr + 2 * Delta;
    end;
  end;
  for i:= 2 to 3 do begin
    OrigArrVolGroup:= CreateArrVolGroup(CurMyBankr);
    NumVolGroup:= -1;   // use ArrVolGroup
    Memo1.Lines.Add(Format('Iteration: %d, Array of Volatility Group for Tardet Risk = %.2f ', [i, CurMyBankr * 100]));
    ShowArrVolGroup(OrigArrVolGroup);
    CalcNumBankruptcySimple(ANumSim, ANumDay, ACapital, ARasxod, @(StartRatioArray[CurRatio]));
    with StartRatioArray[CurRatio] do begin
      CurRealRisk:= FRatio;
      Memo1.Lines.Add(Format('Real Risk = %f ', [FRatio * 100]));
      Delta:= (CurMyBankr - PrevMyBankr) / (CurRealRisk - PrevRealRisk);
      PrevMyBankr:= CurMyBankr;
//      Delta:= APercent - FRatio;
//      CurMyBankr:= CurMyBankr + 2 * Delta;
     CurMyBankr:= CurMyBankr + (APercent - CurRealRisk) * Delta;
     PrevRealRisk:= CurRealRisk;
    end;
  end;
  //EditUPROPer.Text:= FloatToStr(Result * 100 / MaxI);
end;


function TForm1.CreateArrVolGroup(APercent: real): TArrVolGroup;
var i: integer;

  procedure FillAllGroups(First, Last: integer);  // recurce
  var i, Mid, BestRatio: integer;

    procedure FillGroup(AGroup: integer);
    begin
      NumVolGroup:= AGroup;
      BestRatio:= FindBestRatio(StartCapital, Rasxod, APercent{MyBankr}, NumDay, NumSim);
      ArrVolGroup[NumVolGroup]:= BestRatio /MaxI;
      MemoLinesAdd(Format('Group %d, Ratio = %.2f ', [NumVolGroup+1, BestRatio * 100 /MaxI]));
    end;

  begin
    if First > Last then Exit;
    Mid:= First + (Last - First) div 2;
    FillGroup(Mid);
    if IsZero(ArrVolGroup[Mid]) then begin // = 0%
      FillAllGroups(First, Mid-1);
      //for i:= Mid + 1 to Last do begin
      //  ArrVolGroup[i]:= 0; //  0%
      //end;
    end else begin
      for i:= Mid - 1 downto First do begin
        if ArrVolGroup[i+1] < 1 then begin   // < 100%
          FillGroup(i);
        end else begin
          ArrVolGroup[i]:= 1; //BestRatio / MaxI;
        end;
      end;
    end;
    if IsZero(ArrVolGroup[Mid] - 1) then begin // = 100%
      FillAllGroups(Mid+1, Last);
    end else begin
      for i:= Mid + 1 to Last do begin
        if ArrVolGroup[i-1] > 0 then begin   // > 0%
          FillGroup(i);
        end else begin
          ArrVolGroup[i]:= 0; //BestRatio / MaxI;
        end;
      end;
    end;
  end;


begin
  FillAllGroups(0, 22);
  Result:= ArrVolGroup;
end;

procedure TForm1.ShowArrVolGroup(AArrVolGroup: TArrVolGroup);
var i: integer;
begin
  MemoLinesAdd('');
  for i:= 0 to 22 do begin
    MemoLinesAdd(Format('Group %d, Ratio = %.2f ', [i+1, AArrVolGroup[i] * 100 ]));
  end;
end;

function TForm1.NotEmpty(AArrVolGroup: TArrVolGroup): boolean;
var i: integer;
begin
  Result:= false;
  for i:= 0 to 22 do begin
    if AArrVolGroup[i] > 0 then begin
      Result:= true;
      Exit;
    end;
  end;
end;

procedure TForm1.ButtonBestRatioClick(Sender: TObject);
begin
  ProgressBar.Position := 0;
  CurForm:= Self;
  BestRatioThread := TBestRatioThread.Create();
end;

procedure TForm1.FindBestRatioProcedure();
var
  i, BestRatio: integer;
begin
  //GetAllParameter;
      MemoLinesAdd('Start...');
      OrigArrVolGroup:= CreateArrVolGroup(MyBankr);
      MemoLinesAdd('Original Array of Volatility Group:');
      ShowArrVolGroup(OrigArrVolGroup);
      with CurParameter do begin
        //BestRatio:= FindBestRatio_12DayVol(StartCapital, Rasxod, MyBankr, NumDay, NumSim);
        BestRatio:= FindBestRatio_12DayVol(StocksCapital, DailyExpences, TodayRisk, TodayDayLeft, FNumSim);
      end;
      BestRatio:= BestRatio - Round(0.5 * MaxI);
      MemoLinesAdd('Final Array of Volatility Group:');
      OrigArrVolGroup:= ArrVolGroup;
      ShowArrVolGroup(ArrVolGroup);

 //  SaveLog;
 // EditUPROPer.Text:= FloatToStr(BestRatio * 100 / MaxI);
end;

procedure TForm1.CalculateDayRisk(AStartCapital, ARasxod, AMyBankr: real; ANumDay, ANumSim: integer);
                          //(StocksCapital, DailyExpences, TodayRisk, TodayDayLeft, NumSim)
var i, k, t, N, Index, UPROBankrot: integer;
  TotalCapital: real;
  UPROPart: real;
  Total_EV, Total_Day: real;
  StartTime: TdateTime;
  CurArrayReal: TArrayReal;  // 1.39
  CurPercentile: real;
  Seed: Cardinal;
  CurUPROPer, CurVOOPer: real;
  ArrPriceData: TArrPriceData;
 // StatVolGroup: array[0..22] of Longint;
  ArrBankr: array of integer;
  SumaBankr: Longint;
  SumaBankr2, Koef: real;
  StartYear, StartDay, CurYear: integer;
begin
  MemoLinesAdd('');
  //Memo1.Lines.Add('Simulation Method - 12-Day Volatility');
  N:= Length(PriceData);
  ArrVolGroup:= OrigArrVolGroup;
  Seed := GetTickCount;

  Total_EV:= 0;
  UPROBankrot:= 0;
  SetLength(CurArrayReal, ANumSim);  // 1.39
  StartTime:= Now;
  NumVolGroup:= -1;
  SetLength(ArrBankr, ANumDay + 1);
  for i:= 0 to ANumSim - 1 do begin  // 1.39
    TotalCapital:= AStartCapital;
    ArrPriceData := CreatePriceDataArray(ANumDay, @Seed);
    for k:= 1 to ANumDay do begin
      with ArrPriceData[k] do begin
            // use ArrVolGroup
         CurUPROPer:= ArrVolGroup[NumGroup];
         CurVOOPer:= 1 - CurUPROPer;

         UPROPart:= CurUPROPer * UPRO;
         if IsBankruptcy then begin
           if Random(UPROBankr) = 0 then
             UPROPart:= 0;
         end;
         TotalCapital:= TotalCapital * (CurVOOPer * VOO + UPROPart) - ARasxod;
         //if CheckBoxShowStat.Checked then begin
         //  Memo1.Lines.Add(Format('Day: %d   %s   %.6f %.3f   %.6f %.3f   %.6f   %d   %.2f',
         //  [k, DateToStr(PriceDate), VOO, CurVOOPer, UPRO, CurUPROPer, Vol, NumGroup+1, TotalCapital ]));
         //end;
         //Inc(StatVolGroup[NumGroup]);
         if TotalCapital <= 0 then begin
           Inc(UPROBankrot);
           TotalCapital:= 0;
           Inc(ArrBankr[k]);
           Break;
         end;
      end;
    end;
    Total_EV:= Total_EV + TotalCapital;
    CurArrayReal[i]:= TotalCapital;  // 1.39
  end;
{  qSort(CurArrayReal, 0, High(CurArrayReal));   // 1.39
  StartTime:= Now - StartTime;
  Total_EV:= Total_EV / ANumSim;
  Total_Day:= Power(Total_EV / StartCapital, 1 / NumDay);;
  Total_Day:= (Total_Day - 1) * 100;  // in percent

  Memo1.Lines.Add(Format('EV:  Total: %f ', [Total_EV]));
  Memo1.Lines.Add(Format('EV daily:  %.6f ', [Total_Day]));
  Memo1.Lines.Add(Format('Bankruptcy:  %d ( %f ) ', [UPROBankrot, UPROBankrot * 100 / NumSim]));
  Memo1.Lines.Add('');

  CurPercentile:= CurArrayReal[((10 * NumSim) div 100) - 1];
  Memo1.Lines.Add(Format('10th Percentile: %f    %f  EV', [CurPercentile, CurPercentile * 100 / Total_EV ]));
  CurPercentile:= CurArrayReal[((25 * NumSim) div 100) - 1];
  Memo1.Lines.Add(Format('25th Percentile: %f    %f  EV', [CurPercentile, CurPercentile * 100 / Total_EV ]));
  CurPercentile:= CurArrayReal[((50 * NumSim) div 100) - 1];
  Memo1.Lines.Add(Format('50th Percentile: %f    %f  EV', [CurPercentile, CurPercentile * 100 / Total_EV ]));
  CurPercentile:= CurArrayReal[((75 * NumSim) div 100) - 1];
  Memo1.Lines.Add(Format('75th Percentile: %f    %f  EV', [CurPercentile, CurPercentile * 100 / Total_EV ]));
  CurPercentile:= CurArrayReal[((90 * NumSim) div 100) - 1];
  Memo1.Lines.Add(Format('90th Percentile: %f    %f  EV', [CurPercentile, CurPercentile * 100 / Total_EV ]));
 }
      //Memo1.Lines.Add('');
      //for t:=0 to 22 do begin
      //  Memo1.Lines.Add(Format('Group %d:  %d ( %.2f )', [t+1, StatVolGroup[t], (StatVolGroup[t] / NumSim / NumDay) * 100])) ;
      //end;
  SumaBankr:= 0;
  MemoLinesAdd('');
  StartYear:= Trunc((Date - CurParameter.DateOfBirth) / 365.25);
  StartDay:= Trunc(Date - CurParameter.DateOfBirth - StartYear * 365.25);
  StartDay:= Round(StartDay * 251.2 / 365.25);
  for t:=1 to High(ArrBankr) do begin
    SumaBankr:= SumaBankr + ArrBankr[t];
    //SumaBankr2:= SumaBankr2 + ArrBankr[t] * ArrProbDeath[t div 251];
    CurYear:= Trunc((t + StartDay) / 251.2);
    SumaBankr2:= SumaBankr2 + ArrBankr[t] * ArrProbDeath2[StartYear][CurYear];
    //MemoLinesAdd(Format('Day  %d:  %.6f', [t, ArrProbDeath2[StartYear][CurYear]]));
    if (t mod 100) = 0 then begin
      MemoLinesAdd(Format('Day: %d, Bankruptcy: %.3f, with ProbDeath: %.3f',
       [t,(SumaBankr) * 100 / ANumSim, (SumaBankr2) * 100 / ANumSim])) ;
    end;
  end;
  Koef:= SumaBankr / SumaBankr2;
  with CurParameter do begin
    TodayRisk:= TargetRisk * Koef;
    RiskWithDeath:= SumaBankr2 / ANumSim;    // not need ??
  end;
  //Memo1.Lines.Add(Format('Bankruptcy with ProbDeath: %f ', [(SumaBankr2) * 100 / NumSim])) ;
end;

procedure TForm1.CreateTableDayRisk(AStartCapital, ARasxod, AMyBankr: real; ANumDay, ANumSim: integer);
var i, k, t, N, Index, UPROBankrot: integer;
  TotalCapital: real;
  UPROPart: real;
  Total_EV, Total_Day: real;
  StartTime: TdateTime;
  CurArrayReal: TArrayReal;  // 1.39
  CurPercentile: real;
  Seed: Cardinal;
  CurUPROPer, CurVOOPer: real;
  ArrPriceData: TArrPriceData;
 // StatVolGroup: array[0..22] of Longint;
  ArrBankr: array of integer;
  SumaBankr: Longint;
  SumaBankr2, Koef: real;
  StartYear, StartDay, CurYear: integer;
begin
  MemoLinesAdd('');
  //Memo1.Lines.Add('Simulation Method - 12-Day Volatility');
  N:= Length(PriceData);
  ArrVolGroup:= OrigArrVolGroup;
  Seed := GetTickCount;

  Total_EV:= 0;
  UPROBankrot:= 0;
  SetLength(CurArrayReal, ANumSim);  // 1.39
  StartTime:= Now;
  NumVolGroup:= -1;
  SetLength(ArrBankr, ANumDay + 1);
  for i:= 0 to ANumSim - 1 do begin  // 1.39
    TotalCapital:= AStartCapital;
    ArrPriceData := CreatePriceDataArray(ANumDay, @Seed);
    for k:= 1 to ANumDay do begin
      with ArrPriceData[k] do begin
            // use ArrVolGroup
         CurUPROPer:= ArrVolGroup[NumGroup];
         CurVOOPer:= 1 - CurUPROPer;

         UPROPart:= CurUPROPer * UPRO;
         if IsBankruptcy then begin
           if Random(UPROBankr) = 0 then
             UPROPart:= 0;
         end;
         TotalCapital:= TotalCapital * (CurVOOPer * VOO + UPROPart) - ARasxod;
         //if CheckBoxShowStat.Checked then begin
         //  Memo1.Lines.Add(Format('Day: %d   %s   %.6f %.3f   %.6f %.3f   %.6f   %d   %.2f',
         //  [k, DateToStr(PriceDate), VOO, CurVOOPer, UPRO, CurUPROPer, Vol, NumGroup+1, TotalCapital ]));
         //end;
         //Inc(StatVolGroup[NumGroup]);
         if TotalCapital <= 0 then begin
           Inc(UPROBankrot);
           TotalCapital:= 0;
           Inc(ArrBankr[k]);
           Break;
         end;
      end;
    end;
    Total_EV:= Total_EV + TotalCapital;
    CurArrayReal[i]:= TotalCapital;  // 1.39
  end;

  SumaBankr:= 0;
  MemoLinesAdd('');
  StartYear:= Trunc((Date - CurParameter.DateOfBirth) / 365.25);
  StartDay:= Trunc(Date - CurParameter.DateOfBirth - StartYear * 365.25);
  StartDay:= Round(StartDay * 251.2 / 365.25);
  for t:=1 to High(ArrBankr) do begin
    SumaBankr:= SumaBankr + ArrBankr[t];
    ArrBankr[t]:= SumaBankr;
    CurYear:= Trunc((t + StartDay) / 251.2);
    SumaBankr2:= SumaBankr2 + ArrBankr[t] * ArrProbDeath2[StartYear][CurYear];
    if (t mod 100) = 0 then begin
      MemoLinesAdd(Format('Day: %d, Bankruptcy: %.3f, with ProbDeath: %.3f',
       [t,(SumaBankr) * 100 / ANumSim, (SumaBankr2) * 100 / ANumSim])) ;
    end;
  end;
  //SumaBankr:= SumaBankr / ANumSim;
  Koef:= SumaBankr / ANumSim / AMyBankr;
  for t:=1 to High(ArrBankr) do begin
    SumaBankr2:= ArrBankr[t] * Koef ;
    if (t mod 100) = 0 then begin
      MemoLinesAdd(Format('Day: %d, Bankruptcy: %.3f, with ProbDeath: %.3f',
       [t,(SumaBankr) * 100 / ANumSim, (SumaBankr2) * 100 / ANumSim])) ;
    end;
  end;
  //Memo1.Lines.Add(Format('Bankruptcy with ProbDeath: %f ', [(SumaBankr2) * 100 / NumSim])) ;
end;



procedure TForm1.EnableControls(enable: bool);
begin
  if Terminating then
    Exit;
{  Form1.ButtonBestRatio.Enabled := enable;
  Form1.ButtonFillTable.Enabled := enable;
  Form1.ButtonUPRO.Enabled := enable;
  }
end;

procedure TForm1.WMUpdatePB(var msg: TMessage);
begin
  ProgressBar.StepIt;
end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // In case closing was already queried, don't ask permission.
  if IsClosing then begin
    CanClose := true;
    Application.Terminate;
  end
  else begin
  // Set up a termination flag.
  IsClosing:= MessageDlg('Do you really want to close?', mtCustom, [mbYes, mbNo], 0) = mrYes;
  Terminating := IsClosing;

  if CalculationIsRuning then
    CanClose := false // Don't allow to close in case calculation is running.
  else
    CanClose := IsClosing; // Otherwise relay on user's chiose.
  end;
end;

procedure TForm1.Memo1KeyPress(Sender: TObject; var Key: Char);
begin
  case Key of ^A: begin
    (Sender as TMemo).SelectAll;
    Key := #0;
    end;
  end;  
end;

procedure TForm1.NumericEditKeyPress(Sender: TObject; var Key: Char);
begin
  case key of
    '0'..'9': ; // numbers
    #8: ;       // backspace
    #127: ;     // delete
    else
      key := #0;
  end;
end;

procedure TForm1.FloatEditKeyPress(Sender: TObject; var Key: Char);
begin
  case key of
    '0'..'9': ; // numbers
    #8: ;       // backspace
    #127: ;     // delete
    '-': ;      // minus
    '.', ',':
      if Pos(DecimalSeparator, (Sender as TEdit).Text) = 0 then
        Key := DecimalSeparator
      else
        Key := #0; // decimal separator
    else
      key := #0;
  end;
end;

end.
