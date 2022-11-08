unit Biff_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Math, INIFiles, ComCtrls, ExtCtrls, UnitDialog, Utils, StrUtils,
  profile, variables, Login, NewUser; 

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    ButtonClearMemo: TButton;
    ButtonBestRatio: TButton;
    StatusBar1: TStatusBar;
    ProgressBar: TProgressBar;
    ButtonStopFillTable: TButton;
    Label5: TLabel;
    EditScreenName: TEdit;
    Label7: TLabel;
    DateTimePicker1: TDateTimePicker;
    Label6: TLabel;
    EditTodayRisk: TEdit;
    Label1: TLabel;
    EditStocks: TEdit;
    Label8: TLabel;
    EditGold: TEdit;
    Label9: TLabel;
    EditTotalBankroll: TEdit;
    Label2: TLabel;
    EditMonthlyExpences: TEdit;
    Label3: TLabel;
    EditBusinessDaysLeft: TEdit;
    Label10: TLabel;
    EditTodayDayLeft: TEdit;
    CheckBoxAdvanced: TCheckBox;
    Label4: TLabel;
    EditNumSim: TEdit;
    CheckBoxBankruptcy: TCheckBox;
    EditUPROBankr: TEdit;
    ButtonRefreshParameter: TButton;
    ButtonCalculateRisk: TButton;
    ListBoxVolGroup: TListBox;
    Timer1: TTimer;
    ButtonCalculateEV: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ButtonClearMemoClick(Sender: TObject);
  //  procedure ButtonUPROClick(Sender: TObject);
    procedure ButtonBestRatioClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EnableControls(enable: bool);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Memo1KeyPress(Sender: TObject; var Key: Char);
    procedure NumericEditKeyPress(Sender: TObject; var Key: Char);
    procedure FloatEditKeyPress(Sender: TObject; var Key: Char);
    procedure ButtonRefreshParameterClick(Sender: TObject);
    procedure ButtonCalculateRiskClick(Sender: TObject);
    procedure CheckBoxAdvancedClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ButtonCalculateEVClick(Sender: TObject);

  private
    { Private declarations }
    Utils: TUtils;
  public
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
  {
    StartCapital: real;
    Rasxod: real;
    NumDay: integer;
    NumSim: int64;
    MyBankr: real;
    UPROBankr: integer;
    FUPROPerc, FVOOPerc: real;
    TotalDay, StepDay, ReRatioDay: integer;
    IsBankruptcy: boolean;
    }
    IsInflation: boolean;   // allways true
    RatioArray: TRatioArray;
    ZeroRatioArray: TRatioArray;
    LogFileName: string;
    
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
    //procedure GetMainParameter;
    function GetMainParameter: boolean;
    procedure SetParameter;
    procedure SetLogFileName;
    procedure SaveLog;
    procedure CalculateDayRisk(AStartCapital, ARasxod, AMyBankr: real; ANumDay, ANumSim: integer);
    procedure CreateTableDayRisk(AStartCapital, ARasxod, AMyBankr: real; ANumDay, ANumSim: integer);
    procedure FindBestRatioThreadSwitcher(ThreadCase: TCalculationCase);
    procedure FindBestRatioProcedure;
    function FindBestRatio(ACapital, ARasxod, APercent: real; ANumDay, ANumSim: integer): integer;  // Result 0..100 Perc for UPRO
    function FindBestRatio_12DayVol(ACapital, ARasxod, APercent: real; ANumDay, ANumSim: integer): integer;  // Result 0..100 Perc for UPRO
    function FindBestRatio_12DayVol2(ACapital, ARasxod, APercent: real; ANumDay, ANumSim: integer): integer;  // Result 0..100 Perc for UPRO
    procedure CalculateBestRatioMain();
    procedure CalculateRiskForNewUser();
    procedure CalculateRiskForMain();

  //  function FindBestRatioAdv(ACapital, ARasxod, APercent: real; ANumDay, ANumSim, AStepDay: integer): integer;  // Result 0..100 Perc for UPRO
 //   procedure CalcNumBankruptcyAdvInternal(FirstSeed: Cardinal; AInnerNumSim, ANumDay, AStepDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
    procedure CalcNumBankruptcySimple(ANumSim,  ANumDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
    procedure CalcNumBankruptcySimpleInternal(FirstSeed: Cardinal; ANumSim, ANumDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
    procedure qSort(var A: TArrayReal; min, max: Integer);
    procedure CalculateRiskEV(AStartCapital, ARasxod, AMyBankr: real; ANumDay, ANumSim: integer;
                                 var ArrBankr: TArrayInt; var ArrayEV: TArrayReal);
    procedure CalculateEV(AStartCapital, ARasxod, AMyBankr: real; ANumDay, ANumSim: integer);
    function CalculateRisk(AStartCapital, ARasxod, AMyBankr: real; ANumDay, ANumSim: integer): boolean;
    function CreatePriceDataArray(ANumDay: integer; FirstSeed: PCardinal): TArrPriceData;
    function CorrectArrVolGroup(FArrVolGroup: TArrVolGroup; Delta: real): TArrVolGroup;
    function CreateArrVolGroup(APercent: real): TArrVolGroup;
    procedure ShowArrVolGroup(AArrVolGroup: TArrVolGroup);
    procedure ShowArrVolGroupForm(AArrVolGroup: TArrVolGroup);
   // function NotEmpty(AArrVolGroup: TArrVolGroup): boolean;
    procedure StartTimer(Restart: boolean; AStr: string);
    procedure StopTimer(AStr: string);

 end;

var
  Form1: TForm1;
  Terminating : bool;
  //DecimalSeparator : char;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
  var i: integer;
    CanShow: boolean;
  Label BeginProfile;
begin
  IsInflation:= true;
  CanShow:= false;
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
      CurForm:= Self;
      LoadTableDayRisk(TableDayRisk);
      LoadProfileIniFile;
      SetParameter;
      GetMainParameter;;
      CanShow:= true;
      //Self.Visible:= true;
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
  LoadIniFile;
  Randomize;
  // Update decimal separator only for currect application.
  Application.UpdateFormatSettings := false;
  DecimalSeparator := '.';

  // Init some default values.
  ProgressBar.DoubleBuffered := true;
  MaxThreads := Utils.GetCpuCount;
  TotalStepsTime := 0;
  Version := Caption;

  //LoadIniFile;
  //GetAllParameter;
  //if IsInflation = false then
    OpenPriceFile; // load price file only if it wasn't loaded before
  //LoadTable; // uncomment to auto-load a table on start
  GetProbDeath;
  GetProbDeathArr;
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
 if CanShow then
   Self.Visible:= true;
end;

procedure TForm1.SetLogFileName;
begin
  LogFileName:= Caption + '_'+  FormatDateTime('yyyy-mm-dd-hh-nn-ss', Now) + '.txt';
end;

procedure TForm1.SaveLog;
begin
  //Memo1.Lines.SaveToFile(LogFileName);
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
//  SaveLog;
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
        with CurParameter do begin
          if IsBankruptcy then begin
            if MyRandInt(UPROBankr) = 0 then
              UPROPart:= 0;
          end;
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
  //MemoLinesAdd('');
  //MemoLinesAdd(Format('Capital: %.0f, Rasxod: %.2f, Percent: %.4f, Days: %d, Sim: %d ',
  //                       [ACapital, ARasxod, APercent*100, ANumDay, ANumSim]));
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
 // MemoLinesAdd('');
 // MemoLinesAdd(Format('Capital: %.0f, Rasxod: %.0f, Percent: %.4f, Days: %d, Sim: %d ',
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
      MemoLinesAdd(Format('DeltaProc = *%.4f ', [Delta]));
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
//  MemoLinesAdd('Time: ' + TimeToStr(StartTime));
//  if RadioGroupDeltaMethod.ItemIndex = 0 then begin   // Add
//    Memo1.Lines.Add(Format('Day Left: %d,  Delta Ratio: %f ', [ANumDay, Delta * 100]));
//    EditUPROPer.Text:= FloatToStr(Delta * 100);
  begin                                      // Multiplay
    MemoLinesAdd(Format(' Koef Ratio: *%.4f ', [Delta]));
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
 // Memo1.Lines.Add('');
 // Memo1.Lines.Add(Format('Capital: %.0f, Rasxod: %.0f, Percent: %.4f, Days: %d, Sim: %d ',
 //                        [ACapital, ARasxod, APercent*100, ANumDay, ANumSim]));
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
      //BestRatio:= FindBestRatio(StartCapital, Rasxod, APercent{MyBankr}, NumDay, NumSim);
      with CurParameter do begin
        BestRatio:= FindBestRatio(StocksCapital, DailyExpences, TodayRisk, TodayDayLeft, FNumSim);
      end;  
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

procedure TForm1.ButtonBestRatioClick(Sender: TObject);
begin
  ProgressBar.Position := 0;
  if GetMainParameter then begin;
    CurForm:= Self;
    TCaclulationThread.Create(CaseFindBestRatio);
  end;
end;

procedure TForm1.FindBestRatioThreadSwitcher(ThreadCase: TCalculationCase);
begin
  case ThreadCase of
    CaseFindBestRatio : CalculateBestRatioMain;  //FindBestRatioProcedure();
    CaseDailyRisk : CalculateRiskForNewUser();
    CaseDailyRiskMain : CalculateRiskForMain();
    CaseCalcEv : CalculateEV(CurParameter.StocksCapital, CurParameter.DailyExpences, CurParameter.TodayRisk, CurParameter.TodayDayLeft, CurParameter.FNumSim);
	else
    ShowMessage('Unsupported case, please update ThreadCase type');
  end;
end;

procedure TForm1.FindBestRatioProcedure();
var
  i, BestRatio: integer;
begin
  //GetAllParameter;
    with CurParameter do begin
      MemoLinesAdd('Start...');
      OrigArrVolGroup:= CreateArrVolGroup(TodayRisk);
      OrigArrVolGroup:= SmoothingArrVolGroup(OrigArrVolGroup);
      MemoLinesAdd('Original Array of Volatility Group:');
      ShowArrVolGroup(OrigArrVolGroup);
        //BestRatio:= FindBestRatio_12DayVol(StartCapital, Rasxod, MyBankr, NumDay, NumSim);
        BestRatio:= FindBestRatio_12DayVol(StocksCapital, DailyExpences, TodayRisk, TodayDayLeft, FNumSim);
      BestRatio:= BestRatio - Round(0.5 * MaxI);
      MemoLinesAdd('Final Array of Volatility Group:');
      OrigArrVolGroup:= ArrVolGroup;
      ShowArrVolGroup(ArrVolGroup);
      ShowArrVolGroupForm(ArrVolGroup);
    end;
 //  SaveLog;
 // EditUPROPer.Text:= FloatToStr(BestRatio * 100 / MaxI);
end;

procedure TForm1.CalculateBestRatioMain();
begin
    Memo1.Lines.Add('');
    StartTimer(true, 'Calculating Best Ratio ( UPRO / VOO ) ...');
    FindBestRatioProcedure();
    Memo1.Lines.Add('');
    StopTimer('Calculating finished.');
end;

procedure TForm1.CalculateRiskForNewUser();
begin
  with CurParameter, FormNewUser do begin
   { Memo1.Lines.Add('');
    Memo1.Lines.Add('Calculate min risk for your parameter ...');

    if CalculateRisk(StocksCapital, DailyExpences, TodayRisk, TodayDayLeft, FNumSim ) then begin
      Memo1.Lines.Add('');
      Memo1.Lines.Add('Calculating is finished.');
      Exit;
    end;
    }
    StartTimer(true, 'Calculate Daily Risks ...');
    TodayRisk:= TargetRisk;
    Memo1.Lines.Add('');
    Memo1.Lines.Add('Calculate 1 / 4 ...');
    Memo1.Lines.Add(Format('Find ratio for 23 groups when Risk = %f',[TodayRisk * 100]));
    FindBestRatioProcedure();    // first iteration with TargetRisk
    Memo1.Lines.Add('');
    Memo1.Lines.Add('Calculate 2 / 4 ...');
    Memo1.Lines.Add(Format('Find real Risk with probability of death when Risk = %f',[TodayRisk * 100]));
    CalculateDayRisk(StocksCapital, DailyExpences, TargetRisk, TodayDayLeft, FNumSim * 10); // for find TodayRisk
    Memo1.Lines.Add('');
    Memo1.Lines.Add('Calculate 3 / 4 ...');
    Memo1.Lines.Add(Format('Find ratio for 23 groups when Risk = %f',[TodayRisk * 100]));
    //MemoLinesAdd(Format('TodayRisk = %f',[TodayRisk * 100]));
    FindBestRatioProcedure();    // second iteration with TodayRisk
    Memo1.Lines.Add('');
    Memo1.Lines.Add('Calculate 4 / 4 ...');
    Memo1.Lines.Add(Format('Create table of days risk when Risk = %f',[TodayRisk * 100]));
    CreateTableDayRisk(StocksCapital, DailyExpences, TodayRisk, TodayDayLeft, FNumSim * 10);
    Memo1.Lines.Add('');
    Memo1.Lines.Add('All calculating is finished.');
    if CurForm is TFormNewUser then begin
      Memo1.Lines.Add('Now You can Go to Main Window.');
    end;
  end;
  if Assigned(FormNewUser) then begin
    FormNewUser.ButtonGoMainForm.Enabled:= true;
  end;
  ShowArrVolGroupForm(ArrVolGroup);
  StopTimer('Calculate Daily Risks finished.');
end;

procedure TForm1.CalculateRiskForMain();
begin
  //TODO: write code here.
  with CurParameter, Form1 do begin
    Memo1.Lines.Add('');
    Memo1.Lines.Add('Calculate 1 / 2 ...');
    Memo1.Lines.Add(Format('Find ratio for 23 groups when Risk = %f',[TodayRisk * 100]));
    //MemoLinesAdd(Format('TodayRisk = %f',[TodayRisk * 100]));
    FindBestRatioProcedure();
    ShowArrVolGroupForm(ArrVolGroup);
    Memo1.Lines.Add('');
    Memo1.Lines.Add('Calculate 2 / 2 ...');
    Memo1.Lines.Add(Format('Create table of days risk when Risk = %f',[TodayRisk * 100]));
    CreateTableDayRisk(StocksCapital, DailyExpences, TodayRisk, TodayDayLeft, FNumSim * 10);
    Memo1.Lines.Add('');
    Memo1.Lines.Add('All calculating is finished.');
  end;  

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
         with CurParameter do begin
           if IsBankruptcy then begin
             if Random(UPROBankr) = 0 then
               UPROPart:= 0;
           end;
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
    CurYear:= Trunc((t + StartDay) / 251.2);
    SumaBankr2:= SumaBankr2 + ArrBankr[t] * ArrProbDeath2[StartYear][CurYear];
    if ((t mod 100) = 0) or (t = High(ArrBankr)) then begin
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
  ArrBankrReal: TArrayReal;
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
  SetLength(ArrBankrReal, ANumDay + 1);
  for i:= 0 to ANumSim - 1 do begin  // 1.39
    TotalCapital:= AStartCapital;
    ArrPriceData := CreatePriceDataArray(ANumDay, @Seed);
    for k:= 1 to ANumDay do begin
      with ArrPriceData[k] do begin
            // use ArrVolGroup
         CurUPROPer:= ArrVolGroup[NumGroup];
         CurVOOPer:= 1 - CurUPROPer;

         UPROPart:= CurUPROPer * UPRO;
         with CurParameter do begin
           if IsBankruptcy then begin
             if Random(UPROBankr) = 0 then
               UPROPart:= 0;
           end;
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
    CurYear:= Trunc((t + StartDay) / 251.2);
    SumaBankr2:= SumaBankr2 + ArrBankr[t] * ArrProbDeath2[StartYear][CurYear];
    if ((t mod 100) = 0) or (t = High(ArrBankr)) then begin
      MemoLinesAdd(Format('Day: %d, Bankruptcy: %.3f, with ProbDeath: %.3f',
       [t,(SumaBankr) * 100 / ANumSim, (SumaBankr2) * 100 / ANumSim])) ;
    end;
  end;
//  Koef:= AMyBankr / (SumaBankr / ANumSim) ;           // old
  Koef:= CurParameter.TargetRisk / (SumaBankr2 / ANumSim);  // new
  SumaBankr:= 0;
  SumaBankr2:= 0;
  MemoLinesAdd(Format('Koef = %.4f', [Koef]));
  for t:=1 to High(ArrBankr) do begin
    SumaBankr:= SumaBankr + ArrBankr[t];
    CurYear:= Trunc((t + StartDay) / 251.2);
    SumaBankr2:= SumaBankr2 + ArrBankr[t] * ArrProbDeath2[StartYear][CurYear];
    ArrBankrReal[t]:= (SumaBankr * Koef) / ANumSim;
    if ((t mod 100) = 0) or (t = High(ArrBankr)) then begin
      MemoLinesAdd(Format('Day: %d, Bankruptcy: %.3f, with ProbDeath: %.3f',
       [t,(SumaBankr * Koef) * 100 / ANumSim, (SumaBankr2 * Koef) * 100 / ANumSim])) ;
    end;
  end;
  AddToTableDayRisk(TableDayRisk, ArrBankrReal);
  for t:= High(TableDayRisk) downto 0 do begin
    MemoLinesAdd(Format('Day: %d , Risk: %.4f ', [t, TableDayRisk[t] * 100]));
  end;
  SaveTableDayRisk(TableDayRisk);
end;

procedure TForm1.CalculateRiskEV(AStartCapital, ARasxod, AMyBankr: real; ANumDay, ANumSim: integer;
                                 var ArrBankr: TArrayInt; var ArrayEV: TArrayReal);
var
  i, k : integer;
  TotalCapital, UPROPart, CurUPROPer, CurVOOPer: real;
  Seed: Cardinal;
  ArrPriceData: TArrPriceData;
begin
  ArrVolGroup:= OrigArrVolGroup;
  Seed := GetTickCount;
  SetLength(ArrayEV, ANumSim);
  NumVolGroup:= -1;
  SetLength(ArrBankr, ANumDay + 1);
  for i:= 0 to ANumSim - 1 do begin
    TotalCapital:= AStartCapital;
    ArrPriceData := CreatePriceDataArray(ANumDay, @Seed);
    for k:= 1 to ANumDay do begin
      with ArrPriceData[k] do begin
            // use ArrVolGroup
         CurUPROPer:= ArrVolGroup[NumGroup];
         CurVOOPer:= 1 - CurUPROPer;

         UPROPart:= CurUPROPer * UPRO;
         with CurParameter do begin
           if IsBankruptcy then begin
             if Random(UPROBankr) = 0 then
               UPROPart:= 0;
           end;
         end;
         TotalCapital:= TotalCapital * (CurVOOPer * VOO + UPROPart) - ARasxod;
         if TotalCapital <= 0 then begin
           //Inc(UPROBankrot);
           TotalCapital:= 0;
           Inc(ArrBankr[k]);
           Break;
         end;
      end;
    end;
    //Total_EV:= Total_EV + TotalCapital;
    ArrayEV[i]:= TotalCapital;
  end;
end;

procedure TForm1.CalculateEV(AStartCapital, ARasxod, AMyBankr: real; ANumDay, ANumSim: integer);
var i, k, t, N, Index, UPROBankrot: integer;
  TotalCapital: real;
  UPROPart: real;
  Total_EV, Total_Day: real;
  StartTime: TdateTime;
  ArrayEV: TArrayReal;  // 1.39
  CurPercentile: real;
  Seed: Cardinal;
  CurUPROPer, CurVOOPer: real;
  ArrPriceData: TArrPriceData;
 // StatVolGroup: array[0..22] of Longint;
  ArrBankr: TArrayInt;
  SumaBankr: Longint;
  SumaBankr2, Koef: real;
  StartYear, StartDay, CurYear: integer;
begin
  MemoLinesAdd('');
  StartTimer(true, 'Calculate EV ...');
  CalculateRiskEV(AStartCapital, ARasxod, AMyBankr, ANumDay, ANumSim, ArrBankr, ArrayEV);
  qSort(ArrayEV, 0, High(ArrayEV));   // 1.39
  //StartTime:= Now - StartTime;
  Total_EV:= 0;
  for i:= 0 to High(ArrayEV) do begin
    Total_EV:= Total_EV + ArrayEV[i];
  end;
  //Total_EV:= Total_EV / ANumSim;
  Total_EV:= Total_EV / Length(ArrayEV);
  Total_Day:= Power(Total_EV / AStartCapital, 1 / ANumDay);;
  Total_Day:= (Total_Day - 1) * 100;  // in percent

  MemoLinesAdd(Format('EV:  Total: %f ', [Total_EV]));
  MemoLinesAdd(Format('EV daily:  %.6f ', [Total_Day]));
  //Memo1.Lines.Add(Format('Bankruptcy:  %d ( %f ) ', [UPROBankrot, UPROBankrot * 100 / NumSim]));
  MemoLinesAdd('');

  CurPercentile:= ArrayEV[((10 * ANumSim) div 100) - 1];
  MemoLinesAdd(Format('10th Percentile: %f    %f  EV', [CurPercentile, CurPercentile * 100 / Total_EV ]));
  CurPercentile:= ArrayEV[((25 * ANumSim) div 100) - 1];
  MemoLinesAdd(Format('25th Percentile: %f    %f  EV', [CurPercentile, CurPercentile * 100 / Total_EV ]));
  CurPercentile:= ArrayEV[((50 * ANumSim) div 100) - 1];
  MemoLinesAdd(Format('50th Percentile: %f    %f  EV', [CurPercentile, CurPercentile * 100 / Total_EV ]));
  CurPercentile:= ArrayEV[((75 * ANumSim) div 100) - 1];
  MemoLinesAdd(Format('75th Percentile: %f    %f  EV', [CurPercentile, CurPercentile * 100 / Total_EV ]));
  CurPercentile:= ArrayEV[((90 * ANumSim) div 100) - 1];
  MemoLinesAdd(Format('90th Percentile: %f    %f  EV', [CurPercentile, CurPercentile * 100 / Total_EV ]));


  SumaBankr:= 0;
  MemoLinesAdd('');
  StartYear:= Trunc((Date - CurParameter.DateOfBirth) / 365.25);
  StartDay:= Trunc(Date - CurParameter.DateOfBirth - StartYear * 365.25);
  StartDay:= Round(StartDay * 251.2 / 365.25);
  for t:=1 to High(ArrBankr) do begin
    SumaBankr:= SumaBankr + ArrBankr[t];
    CurYear:= Trunc((t + StartDay) / 251.2);
    SumaBankr2:= SumaBankr2 + ArrBankr[t] * ArrProbDeath2[StartYear][CurYear];
    //if (t mod 100) = 0 then begin
    if t = High(ArrBankr) then begin
      MemoLinesAdd(Format('Day: %d, Bankruptcy: %.3f, with ProbDeath: %.3f',
       [t,(SumaBankr) * 100 / ANumSim, (SumaBankr2) * 100 / ANumSim])) ;
    end;
  end;
  Koef:= SumaBankr / SumaBankr2;
  //Memo1.Lines.Add(Format('Bankruptcy with ProbDeath: %f ', [(SumaBankr2) * 100 / NumSim])) ;
   StopTimer('Calculate EV Finished.');
end;


function TForm1.CalculateRisk(AStartCapital, ARasxod, AMyBankr: real; ANumDay, ANumSim: integer): boolean;
var
  CurRisk: real;
  i: integer;
  CurCapital, First, Last: real;
  
function GetRiskCapital(ACapital: real): real;   // inner function
var
  t: integer;
  ArrayEV: TArrayReal;  // 1.39
  ArrBankr: TArrayInt;
  SumaBankr: Longint;
  SumaBankr2, Koef: real;
  StartYear, StartDay, CurYear: integer;
begin
  CalculateRiskEV(ACapital, ARasxod, AMyBankr, ANumDay, ANumSim, ArrBankr, ArrayEV);
  SumaBankr:= 0;
  SumaBankr2:= 0;
  StartYear:= Trunc((Date - CurParameter.DateOfBirth) / 365.25);
  StartDay:= Trunc(Date - CurParameter.DateOfBirth - StartYear * 365.25);
  StartDay:= Round(StartDay * 251.2 / 365.25);
  for t:=1 to High(ArrBankr) do begin
    //SumaBankr:= SumaBankr + ArrBankr[t];
    CurYear:= Trunc((t + StartDay) / 251.2);
    SumaBankr2:= SumaBankr2 + ArrBankr[t] * ArrProbDeath2[StartYear][CurYear];
  end;
  Result:= SumaBankr2 / AnumSim;
end;     // end inner function

begin    // main function
  MemoLinesAdd('');
  for i:= 0 to 22 do begin
    ArrVolGroup[i]:= 0;
  end;
  CurRisk:= GetRiskCapital(AStartCapital);
  MemoLinesAdd(Format('For Capital = %.0f , Risk = %f ', [AStartCapital, CurRisk * 100]));
  Result:= false;
  if CurRisk < AMyBankr then Exit;
  Result:= true;
  if MessageDlg('You Stocks Capital is too small. '
                + 'Do you want calculate minimum needed capital?' , mtCustom, [mbYes, mbNo], 0) = mrYes then begin

    First:= AStartCapital;
    Last:= ARasxod * ANumDay;

    while Abs(Last - First) > ARasxod * 20.9  do begin
      if Terminating then
        Break;

      CurCapital:= (First + Last) / 2;
      CurRisk:= GetRiskCapital(CurCapital);
      MemoLinesAdd(Format('For Capital = %.0f , Risk = %f ', [CurCapital, CurRisk * 100]));
      if CurRisk < AMyBankr then begin
        Last:= CurCapital;
      end else begin
        First:= CurCapital;
      end;
    end;   //while

    MemoLinesAdd(Format('Min Capital = %.0f ', [Last]));

  end;
end;

function TForm1.GetMainParameter: boolean;
begin
  with CurParameter do begin
    Result:= false;
    StocksCapital:= StrToFloatDef(EditStocks.Text, 0);
    GoldCapital:= StrToFloatDef(EditGold.Text, 0);
    TotalBankroll:= StocksCapital + GoldCapital;
    EditTotalBankroll.Text:= FloatToStr(TotalBankroll);
    MonthlyExpences:= StrToFloatDef(EditMonthlyExpences.Text, 0);
    AdvancedUser:= CheckBoxAdvanced.Checked;
    FNumSim:= StrToIntDef(EditNumSim.Text, 25000);
    IsBankruptcy:= CheckBoxBankruptcy.Checked;
    UPROBankr:= StrToIntDef(EditUPROBankr.Text, 50000);

    CalculateDayLeft(DateTimePicker1.Date);
    EditBusinessDaysLeft.Text:= IntToStr(BusinessDaysLeft);
    EditTodayDayLeft.Text:= IntToStr(TodayDayLeft);
    CurProfile:= ScreenName;
    if TodayDayLeft < 0 then begin
      TodayDayLeft:= 0;
      MemoLinesAdd('You will never be broke.');
      MemoLinesAdd('Your gold assets are enough for the rest of your life.');
      MemoLinesAdd('Invest all your stock money to UPRO and have fun.');
      MemoLinesAdd('YOU DON''T NEED BIFF.');
    end else if BusinessDaysLeft > High(TableDayRisk) then begin
      MemoLinesAdd('');
      MemoLinesAdd('Today Risk not finded.');
      MemoLinesAdd('First of all create Table Day Risk.');
    end else begin
      TodayRisk:= TableDayRisk[BusinessDaysLeft] ;
      EditTodayRisk.Text:= Format('%f', [TodayRisk * 100]);
      Result:= true;
    end;
    EditTodayDayLeft.Text:= IntToStr(TodayDayLeft);
  end;

end;


procedure TForm1.SetParameter;
begin
  with CurParameter do begin
    CalculateDayLeft(DateTimePicker1.Date);
    EditScreenName.Text:= ScreenName;
    DateTimePicker1.Date:= Date;
    EditTodayRisk.Text:= FloatToStr(TodayRisk * 100);
    EditStocks.Text:= FloatToStr(StocksCapital);
    EditGold.Text:= FloatToStr(GoldCapital);
    TotalBankroll:= StocksCapital + GoldCapital;
    EditTotalBankroll.Text:= FloatToStr(TotalBankroll);
    EditMonthlyExpences.Text:= FloatToStr(MonthlyExpences);
    AdvancedUser:= CheckBoxAdvanced.Checked;
    FNumSim:= StrToIntDef(EditNumSim.Text, 25000);
    IsBankruptcy:= CheckBoxBankruptcy.Checked;
    UPROBankr:= StrToIntDef(EditUPROBankr.Text, 50000);

    EditBusinessDaysLeft.Text:= IntToStr(BusinessDaysLeft);
    EditTodayDayLeft.Text:= IntToStr(TodayDayLeft);
  end;
  //GetMainParameter;  // ???
end;

procedure TForm1.ShowArrVolGroupForm(AArrVolGroup: TArrVolGroup);
var i: integer;
begin
  with ListBoxVolGroup do begin
    //ListBoxVolGroup.Count:= 23;
    if Length(AArrVolGroup) = 23 then
    for i:= 0 to 22 do begin
      Items[i]:= Format(' %2d:  %2.2F' + '%', [i+1, AArrVolGroup[i] * 100]);
    end;
  end;
  SaveArrVolGroup(AArrVolGroup);
end;

procedure TForm1.EnableControls(enable: bool);
begin
  if Terminating then
    Exit;
        ButtonRefreshParameter.Enabled:= enable;
        ButtonCalculateRisk .Enabled:= enable;
        ButtonBestRatio.Enabled:= enable;
        ButtonClearMemo.Enabled:= enable;
end;

procedure TForm1.WMUpdatePB(var msg: TMessage);
begin
  ProgressBar.StepIt;
end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // In case closing was already queried, don't ask permission.
  if CurForm <> nil then begin
    SaveLog;
    SaveIniFile;
  //  CurForm:= Self;
    SaveProfileIniFile;
  end;
{
  CurForm:= Self;
  SaveLog;
  SaveIniFile;
  SaveProfileIniFile;
 }
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


procedure TForm1.ButtonRefreshParameterClick(Sender: TObject);
begin
  GetMAinParameter;
end;

procedure TForm1.ButtonCalculateRiskClick(Sender: TObject);
begin
//  with Form1, CurParameter do begin
  if MessageDlg('You should recalculate daily risks only if your parameter is changed a lot. '
                + 'Do you really want to recalculate?' , mtCustom, [mbYes, mbNo], 0) = mrYes then begin
    if GetMainParameter then begin
      CurForm:= Self;
      Memo1.Lines.Add('');
      StartTimer(true, 'Calculating Table of Days Risk ...');

      TCaclulationThread.Create(CaseDailyRiskMain);
    end;  
  end;
end;


procedure TForm1.CheckBoxAdvancedClick(Sender: TObject);
var IsEnabled: boolean;
begin
  IsEnabled:= CheckBoxAdvanced.Checked;
  EditNumSim.Enabled:= IsEnabled;
  EditUPROBankr.Enabled:= IsEnabled;
  CheckBoxBankruptcy.Enabled:= IsEnabled;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if CurForm is TForm1 then begin
    with TForm1(CurForm) do begin
      if Timer1.Enabled then begin
        StatusBar1.Panels[0].Text:= TimeToStr(Now - StartTimeTimer);
      end;
    end;  
  end else if CurForm is TFormNewUser then begin
    with TFormNewUser(CurForm) do begin
      if Timer1.Enabled then begin
        StatusBar1.Panels[0].Text:= TimeToStr(Now - StartTimeTimer);
      end;
    end;
  end;
{
  if Timer1.Enabled then begin
    StatusBar1.Panels[0].Text:= TimeToStr(Now - StartTimeTimer);
  end else begin
    //StatusBar1.Panels[0].Text:= '';
  end;}
end;

procedure TForm1.StartTimer(Restart: boolean; AStr: string);
begin
  if CurForm is TForm1 then begin
    with TForm1(CurForm) do begin
      StatusBar1.Panels[1].Text:= AStr;
      Memo1.Lines.Add(AStr);
    end;
  end else if CurForm is TFormNewUser then begin
    with TFormNewUser(CurForm) do begin
      StatusBar1.Panels[1].Text:= AStr;
      Memo1.Lines.Add(AStr);
    end;
  end;
  Timer1.Enabled:= true;
  if Restart then
    StartTimeTimer:= Now;
end;

procedure TForm1.StopTimer(AStr: string);
begin
  if CurForm is TForm1 then begin
    with TForm1(CurForm) do begin
      StatusBar1.Panels[1].Text:= AStr;
      Memo1.Lines.Add(AStr);
    end;
  end else if CurForm is TFormNewUser then begin
    with TFormNewUser(CurForm) do begin
      StatusBar1.Panels[1].Text:= AStr;
      Memo1.Lines.Add(AStr);
    end;
  end;
//  StatusBar1.Panels[1].Text:= AStr;
//  Memo1.Lines.Add(AStr);
  Timer1.Enabled:= false;
end;


procedure TForm1.ButtonCalculateEVClick(Sender: TObject);
begin
  GetMainParameter;
  TCaclulationThread.Create(CaseCalcEv);
end;


end.
