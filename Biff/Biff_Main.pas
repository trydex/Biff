unit Biff_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Math, INIFiles, ComCtrls, ExtCtrls, UnitDialog, Utils;

const
  WM_UPDATE_PB = WM_USER;
  MaxI = 1000;

type
  TPriceData = record
    PriceDate: TDateTime;
    VOO: real;
    UPRO: real;
  end;
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

  TCaclBankruptcyAlgo = (AlgoSimple, AlgoAdvanced);


  TArrayReal = array of real;    // for sort array of Total_EV

  TBestRatioThread = class(TThread)
  public
    constructor Create();
    procedure Execute; override;
    procedure DoTerminate; override;
  end;

  TFillTableThread = class(TThread)
  public
    constructor Create();
    procedure Execute; override;
    procedure DoTerminate; override;
  end;

  TCaclBankruptcyThread = class(TThread)
  private
    ANumSim, ACurRatio, ANumDay, AStepDay: integer;
    ACapital, ARasxod: real;
    StartRatio: PRatio;
    CaclBankruptcyAlgo: TCaclBankruptcyAlgo;
    FirstSeed: Longint;
  public
    constructor Create(FirstSeed: Longint; CaclBankruptcyAlgo: TCaclBankruptcyAlgo; ANumSim, ANumDay, AStepDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
    procedure Execute; override;
    destructor Destroy; override;
    //procedure DoTerminate; override;
  end;

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
    ButtonTest: TButton;
    ButtonClearMemo: TButton;
    Label5: TLabel;
    EditUPROPer: TEdit;
    ButtonUPRO: TButton;
    CheckBoxRebalance: TCheckBox;
    EditRePerc: TEdit;
    CheckBoxBankruptcy: TCheckBox;
    Label6: TLabel;
    EditMyBankr: TEdit;
    EditUPROBankr: TEdit;
    ButtonBestRatio: TButton;
    ButtonFillRatio: TButton;
    EditTotalDay: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    EditStepDay: TEdit;
    ButtonFillTable: TButton;
    CheckBoxAdv: TCheckBox;
    CheckBoxInflation: TCheckBox;
    StatusBar1: TStatusBar;
    OpenDialog1: TOpenDialog;
    ButtonOpenTable: TButton;
    Timer1: TTimer;
    ButtonConvertTable: TButton;
    RadioGroupBiff: TRadioGroup;
    ProgressBar: TProgressBar;
    ButtonStopFillTable: TButton;
    Label9: TLabel;
    CheckBoxReRatio: TCheckBox;
    EditReRatioDAy: TEdit;
    procedure ButtonTestClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonClearMemoClick(Sender: TObject);
    procedure ButtonUPROClick(Sender: TObject);
    procedure ButtonBestRatioClick(Sender: TObject);
    procedure ButtonFillRatioClick(Sender: TObject);
 //  procedure ButtonFindAdvClick(Sender: TObject);
    procedure ButtonFillTableClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonOpenTableClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ButtonConvertTableClick(Sender: TObject);
    procedure CheckBoxInflationClick(Sender: TObject);
    procedure RadioGroupBiffClick(Sender: TObject);
    procedure EnableControls(enable: bool);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Memo1KeyPress(Sender: TObject; var Key: Char);
    procedure NumericEditKeyPress(Sender: TObject; var Key: Char);
    procedure FloatEditKeyPress(Sender: TObject; var Key: Char);
    procedure ButtonStopFillTableClick(Sender: TObject);
    procedure ButtonExtraTableClick(Sender: TObject);

  private
    { Private declarations }
    BestRatioThread: TBestRatioThread;
    FillTableThread: TFillTableThread;
    CaclBankruptcyThreads: array of TCaclBankruptcyThread;
    IsClosing: bool;
    CalculationIsRuning: bool;
    MaxThreads: integer;
    TotalSteps: integer;
    TotalStepsTime: real;
    StepsThrottling: longint;
    Version: string;
    procedure WMUpdatePB(var msg: TMessage); message WM_UPDATE_PB;
  public
    { Public declarations }

    PriceData: array of TPriceData;
    StartCapital: real;
    Rasxod: real;
    NumDay: integer;
    NumSim: int64;
    MyBankr: real;
    UPROBankr: integer;
    FUPROPerc, FVOOPerc: real;
    TotalDay, StepDay, ReRatioDay: integer;
    Advanced: boolean;
    NumAlgo: integer;            // 0 - Biff 1, 1 - Biff 1.5, 2 - Biff 2.0, 3 - Biff 3.0
    IsBankruptcy: boolean;
    IsInflation: boolean;
    Correction: boolean;
    RatioArray: TRatioArray;
    ZeroRatioArray: TRatioArray;
    CurTable: TTable;  //array of TRatioDayArray;
    ExtraTable: TTable; 
    CurTableFileName: string;
    StartTimeTimer: TDateTime;
    LogFileName: string;
    Precision: real;   // need for Biff3 Fill Table
    StartPercentArr: array of real;
    ManualStartPercentOn: boolean;

    procedure OpenPriceFile;
    procedure GetAllParameter;
    procedure LoadIniFile;
    procedure SaveIniFile;
    procedure SetLogFileName;
    procedure SaveLog;
    procedure CalculateEV;
    procedure CalculateEVAdv;
    procedure CalculateTest;
    procedure Statistic;
    procedure FindBestRatioProcedure;
    function FindBestRatio(ACapital, ARasxod, APercent: real; ANumDay, ANumSim: integer): integer;  // Result 0..100 Perc for UPRO
    function FindBestRatioAdv(ACapital, ARasxod, APercent: real; ANumDay, ANumSim, AStepDay: integer): integer;  // Result 0..100 Perc for UPRO
    procedure CalcNumBankruptcyAdvInternal(FirstSeed: Longint; AInnerNumSim, ANumDay, AStepDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
    procedure CalcNumBankruptcySimple(ANumSim,  ANumDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
    procedure CalcNumBankruptcySimpleInternal(FirstSeed: Longint; ANumSim, ANumDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
    function FindTablePercent(ACapital, ARasxod, APercent: real; ARatio, ANumDay, ANumSim, AStepDay: integer; var ATable: TTable): integer;  // Result 0..100 Perc for UPRO

    function FillRatioForDays(ANumDay, AStepDay: integer; APercent:real): TRatioDayArray;
    procedure FillAllRatio(var ARatioDayArray: TRatioDayArray; AMaxRatio: integer);
    function FindTableRatio(ACapital: real; DayLeft: integer; ATable: PTable): integer;
    function FindExtraTableRatio(ACapital: real; DayLeft: integer; ATable: PTable): integer;
    procedure FillAllTableProcedure();
    procedure FillAllTable(ANumDay, AStepDay: integer);
    procedure StopFillTable();
    procedure SaveTable;
    procedure LoadTable;
    function SetTableName: string;
    function SetTableMask: string;
    function GetTableList(AFileMask: string): string;
    procedure StartTimer(Restart: boolean; AStr: string);
    function TableIsCorrect: boolean;
    procedure ShowTable(ATable: TTable);  //ConvertTableToTxt;
    function CorrectPerc(ACapital, APercent: real; ARatio, ANumDay, ACurDay, AStepDay: integer;
                             var ATable: TTable; var AFinalRisk: real): real;  // New correct percent
    procedure CreateTablePercent(var ATable: TTable; TargetPercent, Koef: real; ANumDay, AStepDay: integer);
    procedure CopyPercentFromCurTable;
    procedure qSort(var A: TArrayReal; min, max: Integer);
    function CheckFinishedTable(ANumDay, AStepDay: integer): integer;
    function CreateExtraTable(ATable: TTable): TTable;
    function CorrectExtraTable(ATable: TTable; var AExtraTable: TTable; ACurBlock: integer): TTable;
    //procedure CalcNumBankruptcyExtra(ACapital, ARasxod: real; ANumDay, ANumSim, AStepDay: integer; StartRatio: PRatio);
    procedure CalcNumBankruptcyExtra(ACapital, ARasxod: real; ANumSim, ANumDay, ACurDay, AStepDay: integer; StartRatio: PRatio);

    function PrepareExtraTable(ATable: TTable; var AExtraTable: TTable; ACurBlock: integer): TTable;

 end;

var
  Form1: TForm1;
  Utils: TUtils;
  Terminating : bool;
  //DecimalSeparator : char;

implementation

{$R *.dfm}

//================================================
constructor TBestRatioThread.Create();
begin
  inherited create(false);
  FreeOnTerminate := true;
  Priority := tpNormal;
end;

procedure TBestRatioThread.Execute;
begin
  Form1.EnableControls(false);
  Form1.FindBestRatioProcedure();
end;

procedure TBestRatioThread.DoTerminate;
begin
  if Terminating = false then
    Form1.EnableControls(true);
  inherited
end;


constructor TFillTableThread.Create();
begin
  inherited create(false);
  Priority := tpNormal;
end;

procedure TFillTableThread.Execute;
begin
  Form1.EnableControls(false);
  Form1.FillAllTableProcedure();
end;

procedure TFillTableThread.DoTerminate;
begin
  if Terminating = false then
    Form1.EnableControls(true);
  inherited
end;


constructor TCaclBankruptcyThread.Create(FirstSeed: Longint; CaclBankruptcyAlgo: TCaclBankruptcyAlgo; ANumSim, ANumDay, AStepDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
begin
  inherited create(false);
  FreeOnTerminate := true;
  Priority := tpNormal;

  self.CaclBankruptcyAlgo := CaclBankruptcyAlgo;
  self.ANumSim := ANumSim;
  self.ACurRatio := ACurRatio;
  self.ANumDay := ANumDay;
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
    Form1.CalcNumBankruptcyAdvInternal(FirstSeed, ANumSim, ANumDay, AStepDay, ACapital, ARasxod, StartRatio);
end;

destructor TCaclBankruptcyThread.Destroy;
begin
  inherited;
end;

//================================================

procedure TForm1.FormCreate(Sender: TObject);
var i: integer;
begin
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
  LoadTable;
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
 Memo1.Lines.Add(Format('Precision: %f ', [Precision * 100]));
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

procedure TForm1.ButtonTestClick(Sender: TObject);
begin
  CalculateTest;
end;

procedure TForm1.ButtonUPROClick(Sender: TObject);
begin
  GetAllParameter;
  if NumAlgo = 0 then
    CalculateEV
  else begin        // all other use Table
    LoadTable;
    if TableIsCorrect then
      CalculateEVAdv;
  end;
  SaveLog;
end;

procedure TForm1.ButtonClearMemoClick(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TForm1.OpenPriceFile;
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
    PriceFileName:= 'price_i.txt'
  else
    PriceFileName:= 'price_new.txt';
 try
  Memo1.Lines.Clear;
  Memo1.Lines.LoadFromFile(PriceFileName);
  SetLength(PriceData, Memo1.Lines.Count);

  for i:= 0 to Memo1.Lines.Count - 1 do begin
    with PriceData[i] do begin
      S:= Memo1.Lines[i];
      CurStr:= GetFirstString(S);
      PriceDate:= Utils.StrToDateEx(CurStr);
      CurStr:= GetFirstString(S);
      VOO:= StrToFloat(CurStr);
      CurStr:= GetFirstString(S);
      UPRO:= StrToFloat(CurStr);
    end;
  end;
  Memo1.Lines.Clear;
  StatusBar1.Panels[1].Text:= 'Downloaded Price File: ' + PriceFileName;
  Memo1.Lines.Add('Downloaded Price File: ' + PriceFileName);
 except
   Memo1.Lines.Add('File ' + PriceFileName + ' not found.')
 end;
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
  TotalDay:= StrToIntDef(EditTotalDay.Text, 5000);
  StepDay:= StrToIntDef(EditStepDay.Text, 1000);
  ReRatioDay:= StrToIntDef(EditReRatioDay.Text, 1);
  Advanced:= CheckBoxAdv.Checked;
  IsInflation:= CheckBoxInflation.Checked;
  NumAlgo:= RadioGroupBiff.ItemIndex;
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

    EditCapital.Text:= AIniFile.ReadString('Common', 'Initial Money', '100000');
    EditRasxod.Text:= AIniFile.ReadString('Common', 'Daily Expenses', '1');
    EditDays.Text:= AIniFile.ReadString('Common', 'NumDay', '2000');
    EditSims.Text:= AIniFile.ReadString('Common', 'NumSim', '20000');
    EditMyBankr.Text:= AIniFile.ReadString('Common', 'Risk Of Ruin', '10');
    EditUPROBankr.Text:= AIniFile.ReadString('Common', 'UPRO Daily Fail', '50000');
    CheckBoxBankruptcy.Checked:= AIniFile.ReadBool('Common', 'IsBankruptcy', CheckBoxBankruptcy.Checked);
    EditUPROPer.Text:= AIniFile.ReadString('Common', 'UPRO Perc', '100');
    EditTotalDay.Text:= AIniFile.ReadString('Common', 'Total Day', '5000');
    EditStepDay.Text:= AIniFile.ReadString('Common', 'Step Day', '1000');
    EditReRatioDay.Text:= AIniFile.ReadString('Common', 'ReRatio Day', '1');
    CheckBoxReRatio.Checked:= AIniFile.ReadBool('Common', 'ReRatio On', CheckBoxReRatio.Checked);

    CheckBoxAdv.Checked:= AIniFile.ReadBool('Common', 'Advanced', CheckBoxAdv.Checked);
    CheckBoxInflation.Checked:= AIniFile.ReadBool('Common', 'IsInflation', CheckBoxInflation.Checked);
    CurTableFileName:= AIniFile.ReadString('Common', 'Table File Name', '');
    RadioGroupBiff.ItemIndex:= AIniFile.ReadInteger('Common', 'Num Algo', RadioGroupBiff.ItemIndex);
    Precision:= AIniFile.ReadFloat('Common', 'Precision %', 1) / 100;
    ManualStartPercentOn:= AIniFile.ReadBool('Start Percent', 'ManualStartPercentOn', false);
    TotalDay:= StrToIntDef(EditTotalDay.Text, 1000);
    StepDay:= StrToIntDef(EditStepDay.Text, 100);
    SetLength(StartPercentArr, TotalDay div StepDay);
    for i:= 0 to High(StartPercentArr) do begin
      StartPercentArr[i]:= AIniFile.ReadFloat('Start Percent', 'Day: ' + IntToStr((i+1) * StepDay), (i+1)/10) / 100;
    end;
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
    AIniFile.WriteBool('Common', 'ReRatio On', CheckBoxReRatio.Checked);

    AIniFile.WriteBool('Common', 'Advanced', Advanced);
    AIniFile.WriteBool('Common', 'IsInflation', IsInflation);
    AIniFile.WriteString('Common', 'Table File Name', CurTableFileName);
    AIniFile.WriteInteger('Common', 'Num Algo', RadioGroupBiff.ItemIndex);
    AIniFile.WriteFloat('Common', 'Precision %', Precision * 100);
    AIniFile.WriteBool('Start Percent', 'ManualStartPercentOn', ManualStartPercentOn);

    for i:= 0 to High(StartPercentArr) do begin
      AIniFile.WriteFloat('Start Percent', 'Day: ' + IntToStr((i+1) * StepDay), StartPercentArr[i] * 100);
    end;

  finally
    FreeAndNil(AIniFile);
  end;
end;



procedure TForm1.CalculateTest;
var i, k, N, Index, Win, VOOBankrot, UPROBankrot: integer;
  VOOCapital, UPROCapital: real;
  StartVOO, StartUPRO, RasxodVOO, RasxodUPRO: real;
  VOO_EV, UPRO_EV: real;
  VOO_Day, UPRO_Day: real;
  StartTime: TdateTime;
begin
  StartCapital:= StrToFloatDef(EditCapital.Text, 100000);
  Rasxod:=  StrToFloatDef(EditRasxod.Text, 10);
  NumDay:= StrToIntDef(EditDays.Text, 250);
  NumSim:= StrToIntDef(EditSims.Text, 1000000);
  N:= Length(PriceData);
  VOO_EV:= 0;
  UPRO_EV:= 0;
  Win:= 0;
  VOOBankrot:= 0;
  UPROBankrot:= 0;
  StartVOO:= StartCapital ;
  StartUPRO:= StartCapital ;
  RasxodVOO:= Rasxod ;
  RasxodUPRO:= Rasxod ;
  StartTime:= Now;
  for i:= 1 to NumSim do begin
    VOOCapital:= StartVOO;
    UPROCapital:= StartUPRO;
    for k:= 1 to NumDay do begin
      Index:= Random(N);
      with PriceData[Index] do begin
       VOOCapital:= VOOCapital * VOO;
        VOOCapital:= VOOCapital - RasxodVOO;
        if VOOCapital < 0 then
          VOOCapital:= 0;
        UPROCapital:= UPROCapital * UPRO;
        UPROCapital:= UPROCapital - RasxodUPRO;
        if UPROCapital < 0 then
          UPROCapital:= 0;
      end;
    end;
    if IsZero(VOOCapital) then begin
      Inc(VOOBankrot);
    end;

    if IsZero(UPROCapital) then begin
      Inc(UPROBankrot);
    end;

    if UPROCapital > VOOCapital then begin
      Inc(Win);
    end;
    VOO_EV:= VOO_EV + VOOCapital;
    UPRO_EV:= UPRO_EV + UPROCapital;

  end;
  StartTime:= Now - StartTime;
  VOO_EV:= VOO_EV / NumSim;
  UPRO_EV:= UPRO_EV / NumSim;
  VOO_Day:= Power(VOO_EV / StartCapital , 1 / NumDay);;
  UPRO_Day:= Power(UPRO_EV / StartCapital, 1 / NumDay);;
  VOO_Day:= (VOO_Day - 1) * 100;  // in percent
  UPRO_Day:= (UPRO_Day - 1) * 100;  // in percent
  Memo1.Lines.Add('Time: ' + TimeToStr(StartTime));
  Memo1.Lines.Add(Format('EV:  VOO: %f ,  UPRO: %f , UPRO win: %f ', [VOO_EV, UPRO_EV, Win * 100 / NumSim]));
  Memo1.Lines.Add(Format('EV daily: VOO: %.6f,  UPRO: %.6f ', [VOO_Day, UPRO_Day]));
  Memo1.Lines.Add(Format('Bankruptcy: VOO - %d ( %f ) ,   UPRO - %d ( %f ) ',
                         [VOOBankrot, VOOBankrot * 100 / NumSim, UPROBankrot, UPROBankrot * 100 / NumSim]));
//  Memo1.Lines.Add(Format('Bankrot:  %d ( %f ) ', [UPROBankrot, UPROBankrot * 100 / NumSim]));
  Memo1.Lines.Add('');
end;


procedure TForm1.CalculateEV;
var i, k, N, Index, UPROBankrot: integer;
  VOOCapital, UPROCapital, TotalCapital: real;
  StartVOO, StartUPRO, RasxodVOO, RasxodUPRO, UPROPart: real;
  Total_EV, Total_Day: real;
  VOOPer, UPROPer, RePerc: real;
  StartTime: TdateTime;
  CanRebalance: boolean;
  CurArrayReal: TArrayReal;  // 1.39
  CurPercentile: real;

begin
  Memo1.Lines.Add('');
  StartTimer(true, 'Calculating simple EV  ...');
  N:= Length(PriceData);
  UPROPer:= (StrToFloatDef(EditUPROPer.Text, 100)) / 100;
  VOOPer:= 1 - UPROPer;
  RePerc:= (StrToFloatDef(EditREPerc.Text, 2)) / 100;
  CanRebalance:= CheckBoxRebalance.Checked;

  if IsZero(RePerc) then
    CanRebalance:= false;
  Total_EV:= 0;
  UPROBankrot:= 0;
  StartVOO:= StartCapital * VOOPer;
  StartUPRO:= StartCapital * UPROPer;
  RasxodVOO:= Rasxod * VOOPer;
  RasxodUPRO:= Rasxod * UPROPer;
  SetLength(CurArrayReal, NumSim);  // 1.39
  StartTime:= Now;
  for i:= 0 to NumSim - 1 do begin  // 1.39
    VOOCapital:= StartVOO;
    UPROCapital:= StartUPRO;
    TotalCapital:= StartCapital;
    for k:= 1 to NumDay do begin
      Index:= Random(N);
      with PriceData[Index] do begin
       if CanRebalance then begin
        VOOCapital:= VOOCapital * VOO;
        VOOCapital:= VOOCapital - RasxodVOO;
        UPROCapital:= UPROCapital * UPRO;
        UPROCapital:= UPROCapital - RasxodUPRO;
        if IsBankruptcy then begin
          if Random(UPROBankr) = 0 then
          //UPROCapital:= UPROCapital * 0.99998;
          UPROCapital:= 0;
        end;
        TotalCapital:= VOOCapital + UPROCapital;

        if TotalCapital <= 0 then begin
          Inc(UPROBankrot);
          TotalCapital:= 0;
          Break;
        end;
        UPROPart:= UPROCapital / TotalCapital;
        if (UPROPart < UPROPer - RePerc) or (UPROPart > UPROPer + RePerc) then begin  // Rebalance
          VOOCapital:= TotalCapital * VOOPer;
          UPROCapital:= TotalCapital * UPROPer;
        end;

       end else begin     // not CanRebalance (each day auto Rebalance)
         UPROPart:= UPROPer * UPRO;
         if IsBankruptcy then begin
           if Random(UPROBankr) = 0 then
             UPROPart:= 0;
         end;
         TotalCapital:= TotalCapital * (VOOPer * VOO + UPROPart) - Rasxod;
         if TotalCapital <= 0 then begin
           Inc(UPROBankrot);
           TotalCapital:= 0;
           Break;
         end;
       end;
      end;
    end;
    Total_EV:= Total_EV + TotalCapital;
    CurArrayReal[i]:= TotalCapital;  // 1.39
  end;
  qSort(CurArrayReal, 0, High(CurArrayReal));   // 1.39
  StartTime:= Now - StartTime;
  Total_EV:= Total_EV / NumSim;
  Total_Day:= Power(Total_EV / StartCapital, 1 / NumDay);;
  Total_Day:= (Total_Day - 1) * 100;  // in percent
  Memo1.Lines.Add('Time: ' + TimeToStr(StartTime) + '  UPRO: ' + FloatToStr(UPROPer * 100) + ' %' );
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

  Timer1.Enabled:= false;
end;

procedure TForm1.CalculateEVAdv;
var
  N, UPROBankruptcy: integer;
  VOOPer, UPROPer, Total_EV, Total_Day: real;
  StartTime: TDateTime;
  CurArrayReal: TArrayReal;  // 1.39
  CurPercentile: real;

  procedure CalcNumBankruptcyEV(ACapital, ARasxod: real; ANumDay, ANumSim, AStepDay: integer);
  var i, k, y, Index, NumBlock: integer;
    TotalCapital, UPROPart: real;
    CurVOOPerc, CurUPROPerc: real;
    label ZeroCapital;
  begin
    NumBlock:= ANumDay div AStepDay;
    for i:= 0 to ANumSim - 1 do begin
      TotalCapital:= ACapital;
      for y:= NumBlock downto 1 do begin
        if y = NumBlock then begin           // first block
          CurVOOPerc:= VOOPer;
          CurUPROPerc:= UPROPer;
        end else begin                     // all other block get Ratio from Table
          CurUPROPerc:= FindTableRatio(TotalCapital, y * AStepDay, @CurTable) / MaxI;
          CurVOOPerc:= 1 - CurUPROPerc;
        end;
        for k:= 1 to AStepDay do begin
          Index:= Random(N);
          with PriceData[Index] do begin
            UPROPart:= CurUPROPerc * UPRO;
            if IsBankruptcy then begin
              if Random(UPROBankr) = 0 then
                UPROPart:= 0;
            end;
            TotalCapital:= TotalCapital * (CurVOOPerc * VOO + UPROPart) - ARasxod;
            if TotalCapital <= 0 then begin
              InterlockedIncrement(UPROBankruptcy);
              TotalCapital:= 0;
              Goto ZeroCapital;
              //Break;
            end;
          end;
        end;
      end;
      ZeroCapital://
      Total_EV:= Total_EV + TotalCapital;    // if need EV
      CurArrayReal[i]:= TotalCapital;  // 1.39
    end;
  end;

  procedure CalcNumBankruptcyEV_4(ACapital, ARasxod: real; ANumDay, ANumSim, AStepDay: integer);
  var i, k, y, Index, NumBlock: integer;
    TotalCapital, UPROPart: real;
    CurVOOPerc, CurUPROPerc: real;
    label ZeroCapital;
  begin
    NumBlock:= ANumDay div AStepDay;
    for i:= 0 to ANumSim - 1 do begin
      TotalCapital:= ACapital;
      for y:= NumBlock downto 1 do begin
{        if y = NumBlock then begin           // first block
          CurVOOPerc:= VOOPer;
          CurUPROPerc:= UPROPer;
        end else begin                     // all other block get Ratio from Table
          CurUPROPerc:= FindTableRatio(TotalCapital, y * AStepDay, @CurTable) / MaxI;
          CurVOOPerc:= 1 - CurUPROPerc;
        end;
 }
        for k:= 1 to AStepDay do begin
          if y = NumBlock then begin           // first block
            CurVOOPerc:= VOOPer;
            CurUPROPerc:= UPROPer;
          end else begin                     // all other block get Ratio from Table
            CurUPROPerc:= FindTableRatio(TotalCapital, y * AStepDay, @CurTable) / MaxI;
            CurVOOPerc:= 1 - CurUPROPerc;
          end;

          Index:= Random(N);
          with PriceData[Index] do begin
            UPROPart:= CurUPROPerc * UPRO;
            if IsBankruptcy then begin
              if Random(UPROBankr) = 0 then
                UPROPart:= 0;
            end;
            TotalCapital:= TotalCapital * (CurVOOPerc * VOO + UPROPart) - ARasxod;
            if TotalCapital <= 0 then begin
              InterlockedIncrement(UPROBankruptcy);
              TotalCapital:= 0;
              Goto ZeroCapital;
              //Break;
            end;
          end;
        end;
      end;
      ZeroCapital://
      Total_EV:= Total_EV + TotalCapital;    // if need EV
      CurArrayReal[i]:= TotalCapital;  // 1.39
    end;
  end;

  procedure CalcNumBankruptcyEV_5(ACapital, ARasxod: real; ANumDay, ANumSim, AStepDay: integer);
  var i, k, y, Index, NumBlock: integer;
    TotalCapital, UPROPart: real;
    CurVOOPerc, CurUPROPerc: real;
    label ZeroCapital;
  begin
    NumBlock:= ANumDay div AStepDay;
    for i:= 0 to ANumSim - 1 do begin
      TotalCapital:= ACapital;
      for y:= NumBlock downto 1 do begin
        if y = NumBlock then begin           // first block
          CurVOOPerc:= VOOPer;
          CurUPROPerc:= UPROPer;
        end else begin                     // all other block get Ratio from Table
          CurUPROPerc:= FindExtraTableRatio(TotalCapital, y * AStepDay, @ExtraTable) / MaxI;
          CurVOOPerc:= 1 - CurUPROPerc;
        end;
        for k:= 1 to AStepDay do begin
          Index:= Random(N);
          with PriceData[Index] do begin
            UPROPart:= CurUPROPerc * UPRO;
            if IsBankruptcy then begin
              if Random(UPROBankr) = 0 then
                UPROPart:= 0;
            end;
            TotalCapital:= TotalCapital * (CurVOOPerc * VOO + UPROPart) - ARasxod;
            if TotalCapital <= 0 then begin
              InterlockedIncrement(UPROBankruptcy);
              TotalCapital:= 0;
              Goto ZeroCapital;
              //Break;
            end;
          end;
        end;
      end;
      ZeroCapital://
      Total_EV:= Total_EV + TotalCapital;    // if need EV
      CurArrayReal[i]:= TotalCapital;  // 1.39
    end;
  end;


begin
  Memo1.Lines.Add('');
  StartTimer(true, 'Calculating EV Advantage ...');
  N:= Length(PriceData);
  UPROPer:= (StrToFloatDef(EditUPROPer.Text, 100)) / 100;
  VOOPer:= 1 - UPROPer;
  Total_EV:= 0;
  UPROBankruptcy:= 0;
  StartTime:= Now;
  SetLength(CurArrayReal, NumSim);  // 1.39
  if CheckBoxReratio.Checked then begin
    Memo1.Lines.Add(Format('Biff %d , Sim: %d , ReRatio: %d', [NumAlgo, NumSim, ReRatioDay]));
    ExtraTable:= CreateExtraTable(CurTable);
    CalcNumBankruptcyEV_5(StartCapital / Rasxod, 1, NumDay, NumSim, ReRatioDay);
  end else begin
    Memo1.Lines.Add(Format('Biff %d , Sim: %d , Step Day: %d', [NumAlgo, NumSim, StepDay]));
    CalcNumBankruptcyEV(StartCapital / Rasxod, 1, NumDay, NumSim, StepDay);
  end;
  qSort(CurArrayReal, 0, High(CurArrayReal));    // 1.39
  StartTime:= Now - StartTime;
  Total_EV:= Total_EV / NumSim;
  Total_EV:= Total_EV * Rasxod;
  Total_Day:= Power(Total_EV / StartCapital, 1 / NumDay);;
  Total_Day:= (Total_Day - 1) * 100;  // in percent
  Memo1.Lines.Add('Time: ' + TimeToStr(StartTime) + ' Advanced UPRO: ' + FloatToStr(UPROPer * 100) + ' %' );
  Memo1.Lines.Add(Format('EV:  Total: %f ', [Total_EV]));
  Memo1.Lines.Add(Format('EV daily:  %.6f ', [Total_Day]));
  Memo1.Lines.Add(Format('Bankruptcy:  %d ( %f ) ', [UPROBankruptcy, UPROBankruptcy * 100 / NumSim]));
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

{  Memo1.Lines.Add(Format('25th Percentile: %f ', [CurArrayReal[((25 * NumSim) div 100) - 1]]));
  Memo1.Lines.Add(Format('50th Percentile: %f ', [CurArrayReal[((50 * NumSim) div 100) - 1]]));
  Memo1.Lines.Add(Format('75th Percentile: %f ', [CurArrayReal[((75 * NumSim) div 100) - 1]]));
  Memo1.Lines.Add(Format('90th Percentile: %f ', [CurArrayReal[((90 * NumSim) div 100) - 1]]));
 }
  Timer1.Enabled:= false;
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
    //stepsAdditional: integer;
    c1, c2, f: Int64;
    //time: string; // uncomment for debug to track time
    handles: array of THandle;
    CurrentTicks: Longint;
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
    CaclBankruptcyThreads[t] := TCaclBankruptcyThread.Create(CurrentTicks, AlgoSimple, stepsThread, ANumDay, 0, ACapital, ARasxod, StartRatio);
    handles[t] := CaclBankruptcyThreads[t].Handle;
    CurrentTicks := CurrentTicks + 1;
  end;
  WaitForMultipleObjects(threadLimit, Pointer(handles), true, INFINITE);
  Finalize(handles);
  Finalize(CaclBankruptcyThreads);
  SetLength(CaclBankruptcyThreads, 0);

  // Perform additional steps that have left. stepsAdditional is always less then stepsThread (one full iteration for each thread.)
  //if stepsAdditional > 0 then
  //  CalcNumBankruptcySimpleInternal(CurrentTicks, stepsAdditional, ACurRatio, ANumDay, ACapital, ARasxod, StartRatioArray[ACurRatio]);

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

procedure TForm1.CalcNumBankruptcySimpleInternal(FirstSeed: Longint; ANumSim, ANumDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
var i, k, index, priceDataLength : integer;
  TotalCapital, UPROPart: real;
  RandSeed: Longint;

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

begin
  priceDataLength:= Length(PriceData);
  RandSeed := FirstSeed;

  for i:= 1 to ANumSim do begin
    TotalCapital:= ACapital;
    for k:= 1 to ANumDay do begin
      if Terminating then
        Exit;
      index := MyRandInt(priceDataLength);
      UPROPart:= StartRatio.UPROPerc * PriceData[index].UPRO;
      if IsBankruptcy then begin
        if MyRandInt(UPROBankr) = 0 then
          UPROPart:= 0;
      end;

      TotalCapital:= TotalCapital * (StartRatio.VOOPerc * PriceData[index].VOO + UPROPart) - ARasxod;
      if TotalCapital <= 0 then begin
        InterlockedIncrement(StartRatio.Bankruptcy);
        TotalCapital:= 0;
        Break;
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
//  StartTimer('Finding simple Best Ratio ...');
  Memo1.Lines.Add('');
  Memo1.Lines.Add(Format('Biff: %d, Capital: %.0f, Rasxod: %.0f, Percent: %.4f, Days: %d, Sim: %d ',
                         [NumAlgo, ACapital, ARasxod, APercent*100, ANumDay, ANumSim]));
  StartRatioArray:= ZeroRatioArray;
  StartTime:= Now;
  InnerNumSim:= ANumSim div 5;
{  CurRatio:= 100;
  CalcNumBankruptcySimple(InnerNumSim, ANumDay, ACapital, ARasxod, @(StartRatioArray[CurRatio]));
  with StartRatioArray[CurRatio] do begin
    if FRatio > MyBankr then begin
      First:= 0;
    end else begin
      First:= CurRatio;
    end;
    Last:= CurRatio;
  end;  }

   /////////////    New Algo   !!!!!!!!!!!!    //////////////////
  if Correction then begin
    CurRatio:= 0;
    CalcNumBankruptcySimple(ANumSim, ANumDay, ACapital, ARasxod, @(StartRatioArray[CurRatio]));
    with StartRatioArray[CurRatio] do begin
      CurMyBankr:= MyBankr - FRatio;
      Total:= 0;
      Bankruptcy:= 0;
      FRatio:= 0;
    end;
    if CurMyBankr < 0 then begin
      Result:= 0;
    end else begin
      Result:= -1;
    end;
  end else begin
    //CurMyBankr:= MyBankr;         // old Algo
    CurMyBankr:= APercent;
    Result:= -1;
  end;
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
  //until Result >= 0;
  StartTime:= Now - StartTime;
//  Memo1.Lines.Add('');
  Memo1.Lines.Add('Time: ' + TimeToStr(StartTime));
//  Memo1.Lines.Add(Format('Best Ratio: %d ', [Result]));
  Memo1.Lines.Add(Format('Day Left: %d,  Best Ratio: %f ', [ANumDay, Result * 100 / MaxI]));
  //EditUPROPer.Text:= IntToStr(Result);
  EditUPROPer.Text:= FloatToStr(Result * 100 / MaxI);

end;

procedure TForm1.CalcNumBankruptcyAdvInternal(FirstSeed: Longint; AInnerNumSim, ANumDay, AStepDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
var i, k, y, index, NumBlock, priceDataLength: integer;
  TotalCapital, UPROPart: real;
  CurVOOPerc, CurUPROPerc: real;
  RandSeed: Longint;
  label ZeroCapital;

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

begin
  RandSeed := FirstSeed;
  priceDataLength:= Length(PriceData);
  NumBlock:= ANumDay div AStepDay;

  for i:= 1 to AInnerNumSim do begin
    TotalCapital:= ACapital;
    for y:= NumBlock downto 1 do begin
      if y = NumBlock then begin           // first block
        CurVOOPerc:= StartRatio.VOOPerc;
        CurUPROPerc:= StartRatio.UPROPerc;
      end else begin                     // all other block get Ratio from Table
        CurUPROPerc:= FindTableRatio(TotalCapital, y * AStepDay, @CurTable) / MaxI;
        CurVOOPerc:= 1 - CurUPROPerc;
      end;
      for k:= 1 to AStepDay do begin
        index:= MyRandInt(priceDataLength);
        UPROPart:= CurUPROPerc * PriceData[index].UPRO;
        if IsBankruptcy then begin
          if MyRandInt(UPROBankr) = 0 then begin
            UPROPart:= 0;
          end;
        end;
        TotalCapital:= TotalCapital * (CurVOOPerc * PriceData[index].VOO + UPROPart) - ARasxod;
        if TotalCapital <= 0 then begin
          InterlockedIncrement(StartRatio.Bankruptcy);
          Goto ZeroCapital;
        end;
      end;
    end;
  ZeroCapital:
  end;

end;

function TForm1.FindBestRatioAdv(ACapital, ARasxod, APercent: real; ANumDay, ANumSim, AStepDay: integer): integer;  // Result 0..100 Perc for UPRO
var
  InnerNumSim, CurRatio, First, Last: integer;
  StartRatioArray: TRatioArray;
  StartTime: TDateTime;
  CurMyBankr, CurFRatio: real;

procedure CalcNumBankruptcyAdv(AInnerNumSim: integer; StartRatio: PRatio);
var t, threadLimit, stepsThread: integer;
    //stepsAdditional: integer;
    c1, c2, f: Int64;
    //time: string; // uncomment for debug to track time
    handles: array of THandle;
    CurrentTicks: Longint;
begin
  QueryPerformanceFrequency(f);
  QueryPerformanceCounter(c1);

  threadLimit := MaxThreads;
  if threadLimit > AInnerNumSim then
    threadLimit := AInnerNumSim;
  SetLength(CaclBankruptcyThreads, threadLimit);
  SetLength(handles, threadLimit);
  stepsThread := AInnerNumSim div threadLimit; // total number of iterations for each thread
  //stepsAdditional := AInnerNumSim - (stepsThread * threadLimit); // additional calls
  CurrentTicks := GetTickCount;

  // Create threads.
  for t:= 0 to threadLimit-1 do begin
    CaclBankruptcyThreads[t] := TCaclBankruptcyThread.Create(CurrentTicks, AlgoAdvanced, stepsThread, ANumDay, AStepDay, ACapital, ARasxod, StartRatio);
    handles[t] := CaclBankruptcyThreads[t].Handle;
    CurrentTicks := CurrentTicks + 1;
  end;
  WaitForMultipleObjects(threadLimit, Pointer(handles), true, INFINITE);
  Finalize(handles);
  Finalize(CaclBankruptcyThreads);
  SetLength(CaclBankruptcyThreads, 0);

  // Perform additional steps that have left. stepsAdditional is always less then stepsThread (one full iteration for each thread.)
  //if stepsAdditional > 0 then
  //  CalcNumBankruptcyAdvInternal(CurrentTicks, stepsAdditional, ACurRatio, ANumDay, ACapital, ARasxod, StartRatioArray[ACurRatio]);

  // Total_EV:= Total_EV + TotalCapital;     if need EV
  with StartRatio^ do begin
    Total:= Total + AInnerNumSim;
    FRatio:= Bankruptcy / Total;
    CurFRatio:= FRatio;
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

begin
//  StartTimer('Finding Best Ratio Advantage...');
  Memo1.Lines.Add('');
  Memo1.Lines.Add(Format('Capital: %.0f, Rasxod: %.0f, Percent: %.4f, Days: %d, Sim: %d ',
                         [ACapital, ARasxod, APercent*100, ANumDay, ANumSim]));
  CurFRatio:= 0;
  StartRatioArray:= ZeroRatioArray;
  StartTime:= Now;
  InnerNumSim:= ANumSim div 5;

   /////////////    New Algo   !!!!!!!!!!!!    //////////////////
  if Correction then begin
    CurRatio:= 0;
    CalcNumBankruptcySimple(ANumSim, ANumDay, ACapital, ARasxod, @(StartRatioArray[CurRatio]));
    with StartRatioArray[CurRatio] do begin
      CurMyBankr:= MyBankr - FRatio;
      Total:= 0;
      Bankruptcy:= 0;
      FRatio:= 0;
    end;
    if CurMyBankr < 0 then begin
      Result:= 0;
    end else begin
      Result:= -1;
    end;
  end else begin                 // not correction
    //CurMyBankr:= MyBankr;
    CurMyBankr:= APercent;
    Result:= -1;
  end;

  First:= 0;
  Last:= MaxI;
  while Result < 0 do begin
    if Terminating then
      Break;
    if Last - First = 1 then begin
      if StartRatioArray[First].Total > StartRatioArray[Last].Total then
        CurRatio:= Last
      else
        CurRatio:= First;
    end else begin
      CurRatio:= (First + Last) div 2;
    end;
    CalcNumBankruptcyAdv(InnerNumSim, @(StartRatioArray[CurRatio]));
    with StartRatioArray[CurRatio] do begin
      if Total >= ANumSim then begin    // End calculation
        Result:= CurRatio;
        if FRatio > CurMyBankr then begin
          Result:= Result - 1;
          if Result < 0 then
            Result:= 0;
        end;
      end else if CurFRatio > CurMyBankr then begin
        Last:= CurRatio;
        if (First = Last) and (Last > 0) then
          First:= Last - 1;
      end else begin
        First:= CurRatio;
        if (First = Last) and ( First < MaxI) then
          Last:= First + 1;
      end;
    end;
  end; // while
  StartTime:= Now - StartTime;
  Memo1.Lines.Add('Time: ' + TimeToStr(StartTime));
  Memo1.Lines.Add(Format('Day Left: %d,  Best Ratio: %f ', [ANumDay, Result * 100 / MaxI]));
  EditUPROPer.Text:= FloatToStr(Result * 100 / MaxI);
end;


function TForm1.FindTablePercent(ACapital, ARasxod, APercent: real; ARatio, ANumDay, ANumSim, AStepDay: integer; var ATable: TTable): integer;  // Result 0..100 Perc for UPRO
var
  N, T : integer;
  StartRatioArray: TRatioArray;
  Koef, CumPercent, MinPercent: real;

procedure CalcNumBankruptcy(AInnerNumSim, ACurRatio: integer);
var i, k, y, Index, NumBlock: integer;
  TotalCapital, UPROPart: real;
label ZeroCapital;
begin
  NumBlock:= ANumDay div AStepDay;
  with StartRatioArray[ACurRatio] do begin
    for i:= 1 to AInnerNumSim do begin
     TotalCapital:= ACapital;
     for y:= NumBlock - 1 downto 0 do begin
      for k:= 1 to AStepDay do begin
        Index:= Random(N);
        with PriceData[Index] do begin
          UPROPart:= UPROPerc * UPRO;
          if IsBankruptcy then begin
            if Random(UPROBankr) = 0 then
              UPROPart:= 0;
          end;
          TotalCapital:= TotalCapital * (VOOPerc * VOO + UPROPart) - ARasxod;
          if TotalCapital <= 0 then begin
            with ATable[y] do begin        // count Bankruptcy on each step
              FPercent:= FPercent + 1;
            end;
            Inc(Bankruptcy);
            TotalCapital:= 0;
            Goto ZeroCapital;
            //Break;
          end;
        end;
      end;
     end;
     ZeroCapital://
    end;
    Total:= Total + AInnerNumSim;
    FRatio:= Bankruptcy / Total;
    if IsZero(FRatio) then
      Koef:= 1
    else if AcurRatio < MaxI then
      Koef:= APercent / FRatio  // Norm Koef = TargetPercent / FactPercent
    else
      Koef:= 1;
  end;
end;

begin
  StartRatioArray:= ZeroRatioArray;
  N:= Length(PriceData);
  for T:= 0 to High(ATable) do begin
    ATable[T].FPercent:= 0;
  end;
  //InnerNumSim:= ANumSim div 5;
  CalcNumBankruptcy(ANumSim, ARatio);
  Memo1.Lines.Add(Format('Target Percent: %f , Koef: %.4f', [APercent * 100, Koef]));
  CumPercent:= 0;
  MinPercent:= 0.05 / 100;
 { for T:= 0 to High(ATable) do begin
    with ATable[T] do begin
      FPercent:= FPercent / ANumSim;
      If FPercent < MinPercent then
        FPercent:= FPercent + MinPercent;
      CumPercent:= CumPercent + FPercent;
    end;
  end;
  Koef:= APercent  / CumPercent;
  }
  CumPercent:= 0;
  for T:= 0 to High(ATable) do begin
    with ATable[T] do begin
      FPercent:= Koef * FPercent / ANumSim ;
      CumPercent:= CumPercent + FPercent;
      Memo1.Lines.Add(Format('Start Percent for Day %7d:' +#9+ '%.4f' +#9+ '%.4f ', [(T+1)* AStepDay,
                             FPercent * 100, CumPercent * 100]));
      FPercent:= CumPercent;
    end;
  end;

end;



procedure TForm1.Statistic;
begin
   //
end;

procedure TForm1.ButtonBestRatioClick(Sender: TObject);
var
  CurUPROPerc: real;
begin
//  if CheckBoxReRatio.Checked then begin
//    ExtraTable:= CreateExtraTable(CurTable);
//    CurUPROPerc:= FindExtraTableRatio(StartCapital, NumDay, @ExtraTable) / MaxI;
//    EditUPROPer.Text:= FloatToStr(CurUPROPerc * 100);
//  end else begin
    ProgressBar.Position := 0;
    BestRatioThread := TBestRatioThread.Create();
//  end;
end;

procedure TForm1.FindBestRatioProcedure();
var
  BestRatio: integer;
begin
  GetAllParameter;
  Correction:= false;
  BestRatio:= 0;
 if CheckBoxReRatio.Checked then begin
    ExtraTable:= CreateExtraTable(CurTable);
      Memo1.Lines.Add('');
      Memo1.Lines.Add(Format('Find Best Ratio from Extra Table ...', []));

    //CurUPROPerc:= FindExtraTableRatio(StartCapital, NumDay, @ExtraTable) / MaxI;
    BestRatio:= FindExtraTableRatio(StartCapital, NumDay, @ExtraTable);
    Memo1.Lines.Add(Format('Best Ratio: %f ', [BestRatio * 100 / MaxI]));
    //EditUPROPer.Text:= FloatToStr(CurUPROPerc * 100);
 end else begin

  if {Advanced} NumAlgo > 0 then begin
    LoadTable;
    if TableIsCorrect then begin
      //StartTimer(Format('Find Best Ratio by Biff %d ', [NumAlgo]));
      Memo1.Lines.Add('');
      Memo1.Lines.Add(Format('Find Best Ratio by Biff %d ...', [NumAlgo]));
      BestRatio:= FindBestRatioAdv(StartCapital / Rasxod, 1, MyBankr, NumDay, NumSim, StepDay);
    end;
  end else begin
    //StartTimer(Format('Find Best Ratio by Biff %d ', [NumAlgo]));
    Memo1.Lines.Add('');
    Memo1.Lines.Add(Format('Find Best Ratio by Biff %d ...', [NumAlgo]));
{    if not IsZero(FUPROPerc) then           // Calculate StartRatio for both Biff 3 and Biff 2
      BestRatio:= Round(FUPROPerc *  MaxI)
    else    }
      BestRatio:= FindBestRatio(StartCapital, Rasxod, MyBankr, NumDay, NumSim);
   // SetLength(TempTable, NumDay div StepDay);
   // FindTablePercent(StartCapital, Rasxod, MyBankr, BestRatio, NumDay, NumSim, StepDay, TempTable);
  end;
 end;
  //Timer1.Enabled:= false;
  SaveLog;
  EditUPROPer.Text:= FloatToStr(BestRatio * 100 / MaxI);
end;

function TForm1.FillRatioForDays(ANumDay, AStepDay: integer; APercent: real): TRatioDayArray;
var
  StartM, StepM : real;
  UPROFail, CurStartCapital: real;
  i, k, BestRatio, LastRatio, DiffRatio, MaxRatio: integer;
  I10, I5, I1: integer;
  CurSim: int64;

  procedure AddCapital(ACapital: real; ARatio: integer);
  begin
    with Result.RatioForDay[ARatio] do begin
      if (ARatio = 0) or (ARatio = MaxI) then begin
        FCapital:= ACapital;
        FNumSim:= FNumSim + NumSim;
      end else begin
        FCapital:= (FCapital * FNumSim + ACapital) / ((FNumSim + NumSim) / NumSim); // New Average
        FNumSim:= FNumSim + NumSim;
      end;
    end;
  end;

begin
  UPROFail:= 1 - Power((UPROBankr - 1) / UPROBankr, ANumDay);
//  if UPROFail > MyBankr then begin
  if UPROFail > APercent then begin
    //MaxRatio:= Round(MaxI * 0.994); // maybe   MaxI - 1;
    MaxRatio:= MaxI - 1;
    Memo1.Lines.Add('');
    Memo1.Lines.Add(Format(' UPRO Bankruptcy: = %.2f', [UPROFail * 100]) + ' %');
  end else
    MaxRatio:= MaxI;
//  Rasxod:= 1;
  StartM:= 2;
  StepM:= 1.1;
  LastRatio:= -1;
 with Result do begin
  FDay:= ANumDay;
  FMyBankr:= MyBankr;
  FUPROBankr:= UPROBankr;
  for i:= 0 to MaxI do begin
    RatioForDay[i].FCapital:= 0;
    RatioForDay[i].FNumSim:= 0;
  end;
  I10:= MaxI div 10; // 10%
  I5:= MaxI div 20;  // 5%
  I1:= MaxI div 100; // 1%
  //CurSim:= Round(NumSim * ((TotalDay / ANumDay) / 100)) * 100;
  CurSim:= NumSim;
  repeat
    if Terminating then
      Exit;
    CurStartCapital:= ANumDay * StartM;
    if {Advanced} NumAlgo = 2 then
      BestRatio:= FindBestRatioAdv(CurStartCapital, {Rasxod} 1, APercent, ANumDay, CurSim, AStepDay)
    else
      BestRatio:= FindBestRatio(CurStartCapital, {Rasxod} 1, APercent, ANumDay, CurSim);

    if LastRatio >=0 then begin
      DiffRatio:= BestRatio - LastRatio;
      if DiffRatio > I10 then begin       // > 10%
        StepM:= Sqrt(StepM);
      end else if (DiffRatio >= 0) then begin
        if (DiffRatio <= I1)  then begin    //    0% <  < 1%
          StepM:= StepM * 1.2;
        end else if DiffRatio <= I5 then begin                           //    1% <  < 5%
          StepM:= StepM * 1.1;
        end;
      end;
    end;

    LastRatio:= BestRatio;
    StartM:= StartM * StepM;
    RatioForDay[BestRatio].FCapital:= CurStartCapital;
    RatioForDay[BestRatio].FNumSim:= RatioForDay[BestRatio].FNumSim + CurSim;
    //AddCapital(CurStartCapital, BestRatio);
   // Memo1.Lines.Add(Format('Capital: %f , Best Ratio: %d ', [CurStartCapital, BestRatio]));
  until (BestRatio >= MaxRatio) or (DiffRatio < 0) or (RatioForDay[BestRatio].FNumSim >= 5 * CurSim);

  if RatioForDay[0].FNumSim = 0 then begin   // not Calculated yet for Ratio = 0
    StepM:= 1.1;
    StartM:= 2 / StepM;
    LastRatio:= -1;
    repeat
      if Terminating then
        Exit;
      CurStartCapital:= ANumDay * StartM;
      if {Advanced} NumAlgo = 2 then
        BestRatio:= FindBestRatioAdv(CurStartCapital, {Rasxod} 1, APercent, ANumDay, CurSim, AStepDay)
      else
        BestRatio:= FindBestRatio(CurStartCapital, {Rasxod} 1, APercent, ANumDay, CurSim);
      if LastRatio >=0 then begin
        DiffRatio:= (LastRatio - BestRatio);
        if DiffRatio > I10 then begin
          StepM:= Sqrt(StepM);
        end; // else  if DiffRatio <= 5 then
       //   StepM:= StepM * 1.1;
      end;
      LastRatio:= BestRatio;
      StartM:= StartM / StepM;
      RatioForDay[BestRatio].FCapital:= CurStartCapital;
      RatioForDay[BestRatio].FNumSim:= RatioForDay[BestRatio].FNumSim + CurSim;
     // AddCapital(CurStartCapital, BestRatio);
    //  Memo1.Lines.Add(Format('Capital: %f , Best Ratio: %d ', [CurStartCapital, BestRatio]));
      Memo1.Lines.Add('');
    until BestRatio <= 0;
  end;                  // not Calculated yet for Ratio = 0
 end;                   // with result
 FillAllRatio(Result, MaxRatio);
 Result.FPercent:= APercent;
 for i:= 0 to 100 do begin
   k:= i * (MaxI div 100);
   Memo1.Lines.Add(Format('%d: %f ', [k, Result.RatioForDay[k].FCapital]));
 end;
 if MaxI = 1000 then
 for i:= 991 to 1000 do begin
   //k:= i * (MaxI div 100);
   K:= i;
   Memo1.Lines.Add(Format('%d: %f ', [k, Result.RatioForDay[k].FCapital]));
 end;

end;

procedure TForm1.FillAllRatio(var ARatioDayArray: TRatioDayArray; AMaxRatio: integer);
var
  i, K1, K2, K3: integer;
  Step: real;
{
  function FindNotZero(FromIndex: integer): integer;
  var i: integer;
  begin
    i:= FromIndex;
    repeat
      Dec(i);
    until (not IsZero(ARatioDayArray.RatioForDay[i].FCapital)) or (i = 0);
    Result:= i;
  end;
 }
  function FindNotZero(FromIndex: integer): integer;
  var i: integer;
  begin
    i:= FromIndex;
    while (IsZero(ARatioDayArray.RatioForDay[i].FCapital)) and (i > 0) do begin
      Dec(i);
    end;
    Result:= i;
  end;


begin
 try
  with ARatioDayArray do begin
//    RatioForDay[MaxI].FCapital:= 0;
//    RatioForDay[0].FCapital:= 0;
    K1:= FindNotZero(MaxI);
     {
    if K1 = 0 then begin
      for i:= 0 to MaxI do begin
        RatioForDay[i].FCapital:= StartCapital * 1000; // RatioForDay[K1].FCapital * 10;
      end;
      Exit;
    end;
      }
    if not IsZero(MaxI - AMaxRatio)  then begin
     repeat                             // Check for downtrend
      K2:= FindNotZero(K1 - 1);
      if RatioForDay[K1].FCapital < RatioForDay[K2].FCapital then begin
        RatioForDay[K1].FCapital:= 0;
        K1:= K2;
      end else begin
        Break;
      end;
     until false;
    end;

    K2:= FindNotZero(K1 - 1);
    {  if RatioForDay[K1].FCapital < RatioForDay[K2].FCapital then begin
        RatioForDay[K2].FCapital:= 0;
        Memo1.Lines.Add('Deleting wrong Capital.') ;
      end else begin
        Break;
      end;
     }
    K3:= FindNotZero(K2 - 1);
    if K3 > 0 then begin     // more then 3 Control Point
      RatioForDay[MaxI].FCapital:= 0;
      RatioForDay[0].FCapital:= 0;
      if K1 = MaxI then
        K1:= K2;
    end;

    repeat
      if Terminating then
        Exit;
      K2:= FindNotZero(K1 - 1);
      if RatioForDay[K1].FCapital < RatioForDay[K2].FCapital then begin
        RatioForDay[K2].FCapital:= 0;
        Memo1.Lines.Add('Deleting wrong Capital.') ;
        Continue;
      end;
      if K1 - K2 > 0 then begin
        if (K2 = 0) and (K1 < MaxI) and not IsZero(RatioForDay[K1 + 1].FCapital) then begin   // K2 = 0
          Step:= RatioForDay[K1 + 1].FCapital / RatioForDay[K1].FCapital;
        end else begin
          Step:= Power(RatioForDay[K1].FCapital / RatioForDay[K2].FCapital, 1 / (K1 - K2));
        end;
        for i:= K1 - 1 downto K2  do begin
          RatioForDay[i].FCapital:= RatioForDay[i + 1].FCapital / Step;
        end;
      end;
      K1:= K2;
    until K2 = 0;
    K1:= FindNotZero(MaxI);
    if AMaxRatio < MaxI then begin
      for i:= K1 + 1 to MaxI do begin
        RatioForDay[i].FCapital:= StartCapital * 1000;
      end;
    end else begin
      Step:= RatioForDay[K1 ].FCapital / RatioForDay[K1 - 1].FCapital;
      for i:= K1 + 1 to MaxI do begin
        RatioForDay[i].FCapital:= RatioForDay[i - 1].FCapital * Step;
      end;
    end;
{    if AMaxRatio < MaxI then begin
      for i:= K1 + 1 to MaxI do begin
        RatioForDay[i].FCapital:= StartCapital * 1000;
      end;
    end else begin
      Step:= RatioForDay[K1 ].FCapital / RatioForDay[K1 - 1].FCapital;
      for i:= K1 + 1 to MaxI do begin
        RatioForDay[i].FCapital:= RatioForDay[i - 1].FCapital * Step;
      end;
    end;
    }
  end;
 except
   Memo1.Lines.Add('Error in FillAllRatio...')
 end;
end ;

function TForm1.FindTableRatio(ACapital: real; DayLeft: integer; ATable: PTable): integer;
var
  i, Index, First, Last, Pivot: integer;
begin
  Index:= -1;
  for i:= 0 to High(ATable^) do begin
    if ATable^[i].FDay = DayLeft then begin
      Index:= i;
      Break;
    end;
  end;
  if Index >= 0 then begin
    with ATable^[Index] do begin
      if IsZero(RatioForDay[MAxI].FCapital)  then
        Last:= MaxI - 1
      else
        Last:= MaxI;
      if ACapital >= RatioForDay[Last].FCapital then begin
        Result:= Last;
      end else if ACapital < RatioForDay[0].FCapital then begin
        Result:= 0;
      end else begin     // Binarny search
        First:= 0;
        while Last - First >= 1 do begin
          Pivot:= (First + Last) div 2;
          if ACapital > RatioForDay[Pivot].FCapital then
            First:= Pivot + 1
          else
            //Last:= Pivot - 1;
            Last:= Pivot;
        end;
        Result:= First;
      end;
    end;
  end else begin  // not finded
    Memo1.Lines.Add(Format('Not finded precaclulated data for %d days.', [DayLeft]));
    Result:= -1;
  end;
end;

function TForm1.FindExtraTableRatio(ACapital: real; DayLeft: integer; ATable: PTable): integer;
var
  i, Index, First, Last, Pivot: integer;
begin
    with ATable^[DayLeft] do begin
      if IsZero(RatioForDay[MAxI].FCapital)  then
        Last:= MaxI - 1
      else
        Last:= MaxI;
      if ACapital >= RatioForDay[Last].FCapital then begin
        Result:= Last;
      end else if ACapital < RatioForDay[0].FCapital then begin
        Result:= 0;
      end else begin     // Binarny search
        First:= 0;
        while Last - First >= 1 do begin
          Pivot:= (First + Last) div 2;
          if ACapital > RatioForDay[Pivot].FCapital then
            First:= Pivot + 1
          else
            //Last:= Pivot - 1;
            Last:= Pivot;
        end;
        Result:= First;
      end;
    end;
end;


procedure TForm1.ButtonFillRatioClick(Sender: TObject);
begin
  GetAllParameter;
  FillRatioForDays(NumDay, StepDay, MyBankr);
end;

procedure TForm1.ButtonFillTableClick(Sender: TObject);
var
  Res: TModalResult;
begin
  with FormDialog do begin
    CopyParameterFromMain;
    Res:= FormDialog.ShowModal;
    if Res = mrCancel then
      Exit;
    if Res = mrOk then begin
      CopyParameterToMain;
      EditDays.Text:= EditTotalDay.Text;
      GetAllParameter;
      SaveIniFile;
      Correction:= false;
      FillTableThread := TFillTableThread.Create();
    end;
  end;
end;

procedure TForm1.FillAllTableProcedure();
begin
  ProgressBar.Position := 0;
  CurTableFileName:= SetTableName;
  TotalSteps := 0;
  StepsThrottling := GetTickCount;
  CalculationIsRuning := true;
  FillAllTable(TotalDay, StepDay);
  CalculationIsRuning := false;
  ProgressBar.Position := ProgressBar.Max;
  SaveTable;
  SaveIniFile;
end;

procedure TForm1.FillAllTable(ANumDay, AStepDay: integer);
var
  i, k, m, NumBlock, StartBlock, StartRatio: integer;
  Percent, NewPercent, StartPercent, DiffPercent, FinalRisk, StepPercent, TargetRisk: real;
  OldPercent, OldRisk: real;
  SumaAverage: real;
label
  ExitUntil;
begin
  if NumAlgo = 0 then begin
    Memo1.Lines.Add(Format('Not need create table for Biff 1.0 ', []));
    Exit;
  end;
  NumBlock:= ANumDay div AStepDay;
  ProgressBar.Step := ProgressBar.Max div NumBlock;
  CopyPercentFromCurTable ;
  StartBlock:= CheckFinishedTable(ANumDay, AStepDay);
//  SetLength(CurTable, 0);
//  SetLength(CurTable, NumBlock);
    if not IsZero(FUPROPerc) then           // Calculate StartRatio for both Biff 3 and Biff 2
      StartRatio:= Round(FUPROPerc *  MaxI)
    else
      StartRatio:= FindBestRatio(StartCapital, Rasxod, MyBankr, NumDay, NumSim);  // Biff 1

  if NumAlgo = 3 then begin
    StartTimer(true, 'Creating Table by Biff 3.0...');
    Memo1.Lines.Add(Format('Biff 1 Start Ratio:: %f ', [StartRatio * 100 / MaxI]));
    //Percent:= MyBankr;
    //DiffPercent:= 0;
    if (StartBlock + 1) < NumBlock then begin
      Percent:= CurTable[StartBlock + 1].FPercent;
    end else begin
      Percent:= CurTable[StartBlock ].FPercent;
    end;
    if (StartBlock + 2) < NumBlock then begin
      DiffPercent:= CurTable[StartBlock + 2].FPercent - CurTable[StartBlock + 1].FPercent;
    end else begin
      DiffPercent:= 0;
    end;
    TargetRisk:= MyBankr * (1 - Precision / 2);
    PrepareExtraTable(CurTable, ExtraTable, StartBlock + 1);
    for i:= StartBlock {NumBlock - 2} downto 0 do begin
      if Terminating then
        Break;
      StatusBar1.Panels[1].Text:= Format('Calculating table for days: %d / %d ', [(i+1) * AStepDay, ANumDay]);
      StartPercent:= Percent;
      if DiffPercent >= Percent / 2 then
        Percent:= Percent / 2
      else
        Percent:= Percent - DiffPercent;
      CurTable[i]:= FillRatioForDays((i+1) * AStepDay, AStepDay, Percent);
      //for k:= 1 to 2 do begin
      k:= 0;
      SumaAverage:= 0;
      OldPercent:= 0;
      OldRisk:= 0;
      repeat
        if Terminating then
          Break;
        Inc(k);
        m:= 0;
        repeat
          if Terminating then
            Break;
          Memo1.Lines.Add(Format('Correction %d _ %d', [k, m]));
          CorrectExtraTable(CurTable, ExtraTable, i);
          NewPercent:= CorrectPerc(StartCapital / Rasxod, Percent, StartRatio,
                      ANumDay, (i+1) * AStepDay, AStepDay, CurTable, FinalRisk);  // New correct percent

 {         if (m = 0) and (FinalRisk < MyBankr) and (Abs(FinalRisk - MyBankr) < MyBankr * Precision) then begin
            Memo1.Lines.Add(Format('End Correction, Final Risk =  %f', [FinalRisk * 100]));
            Goto ExitUntil;
          end;   }
{          SumaAverage:= SumaAverage + FinalRisk / Percent ;
          NewPercent:= MyBankr / (SumaAverage / k);
//          if (m = 0) and (FinalRisk < MyBankr) and (Abs(NewPercent - Percent) < MyBankr * Precision / 2) then begin
//            Memo1.Lines.Add(Format('End Correction, Final Risk =  %f', [FinalRisk * 100]));
//            Goto ExitUntil;
//          end;
 }

          //NewPercent:= MyBankr / (FinalRisk / Percent) ;
        {          // 1.36
          NewPercent:= TargetRisk / (FinalRisk / Percent) ;
          if (m = 0) and (FinalRisk < MyBankr) and (Abs(FinalRisk - MyBankr) < MyBankr * Precision) then begin
            Memo1.Lines.Add(Format('End Correction, Final Risk =  %f', [FinalRisk * 100]));
            Goto ExitUntil;
          end;    }
                  // 1.37
          NewPercent:= MyBankr / (FinalRisk / Percent) ; // 1.48
          NewPercent:= Percent + (NewPercent - Percent) * 1.5 ;  // New in 1.48
         {  1.49
          NewPercent:= Percent + (MyBankr - FinalRisk)*(Percent - OldPercent) / (FinalRisk - OldRisk);
          OldPercent:= Percent;
          OldRisk:= FinalRisk;
          }
          if NewPercent > 1 then
            NewPercent:= 1;
           // NewPercent:= Percent + MyBankr;
          if {IsZero(StartRatio - 1) and} IsZero(NewPercent - 1) then begin
            Memo1.Lines.Add(Format('End Correction on 100 pr., Final Risk =  %f', [FinalRisk * 100]));
            Goto ExitUntil;
          end;
          if (m = 0) and (Abs(FinalRisk - MyBankr) < MyBankr * Precision / 2) then begin
            Memo1.Lines.Add(Format('End Correction, Final Risk =  %f', [FinalRisk * 100]));
            Goto ExitUntil;
          end;
       {
          if NewPercent < 0 then begin
            Percent:= Percent * 0.95;
            Inc(m);
          end;    }
        until NewPercent > 0;
        Percent:= NewPercent;
        CurTable[i]:= FillRatioForDays((i+1) * AStepDay, AStepDay, Percent);
      //end;
      until k > 9;
      Memo1.Lines.Add(Format('End Correction on 10 iterration, Final Risk =  %f', [FinalRisk * 100]));
      ExitUntil:
      DiffPercent:= StartPercent - Percent;
      //CorrectPerc(StartCapital, Percent, StartRatio, ANumDay, i * AStepDay, AStepDay, CurTable, FinalRisk);  // New correct percent

      SaveTable;
      SaveLog;
      PostMessage(Form1.Handle, WM_UPDATE_PB, 0, 0);
    end;
  end else if NumAlgo = 2 then begin
   StartTimer(true, 'Creating Table by Biff 2.0...');
   Memo1.Lines.Add(Format('Biff 1 Start Ratio:: %f ', [StartRatio * 100 / MaxI]));
 //  FindTablePercent(StartCapital, Rasxod, MyBankr, StartRatio, ANumDay, NumSim, AStepDay, CurTable);
 //  CreateTablePercent(CurTable, MyBankr, 1.5, ANumDay, AStepDay);
//   StepPercent:= MyBankr / NumBlock;
   //CopyPercentFromCurTable ;
   for i:= StartBlock to NumBlock - 1 do begin
     StatusBar1.Panels[1].Text:= Format('Calculating table for days: %d / %d ', [(i+1) * AStepDay, ANumDay]);
     CurTable[i]:= FillRatioForDays((i+1) * AStepDay, AStepDay, StartPercentArr[i]);

   {
   for i:= 0 to NumBlock - 2 do begin
    StatusBar1.Panels[1].Text:= Format('Calculating table for days: %d / %d ', [(i+1) * AStepDay, ANumDay]);
    if ManualStartPercentOn then begin
      Memo1.Lines.Add(Format('Use Manual Start Percent: %.4f ', [StartPercentArr[i]]));
      CurTable[i]:= FillRatioForDays((i+1) * AStepDay, AStepDay, StartPercentArr[i]);
    end else begin
      Memo1.Lines.Add(Format('Use Start Percent: %.4f ', [(i+1) * StepPercent]));
      CurTable[i]:= FillRatioForDays((i+1) * AStepDay, AStepDay, (i+1) * StepPercent);
   // CurTable[i]:= FillRatioForDays((i+1) * AStepDay, AStepDay,CurTable[i].FPercent);
    end;     }
     SaveTable;
     SaveLog;
     PostMessage(Form1.Handle, WM_UPDATE_PB, 0, 0);
   end;
  end else begin
   StartTimer(true, 'Creating Table by Biff 1.5...');
   Memo1.Lines.Add(Format('Biff 1 Start Ratio:: %f ', [StartRatio * 100 / MaxI]));
   StepPercent:= MyBankr / NumBlock;
   for i:= StartBlock {NumBlock - 2} downto 0 do begin
    StatusBar1.Panels[1].Text:= Format('Calculating table for days: %d / %d ', [(i+1) * AStepDay, ANumDay]);
    if ManualStartPercentOn then begin
      Memo1.Lines.Add(Format('Use Manual Start Percent: %.4f ', [StartPercentArr[i]]));
      CurTable[i]:= FillRatioForDays((i+1) * AStepDay, AStepDay, StartPercentArr[i]);
    end else begin
      Memo1.Lines.Add(Format('Use Start Percent: %.4f ', [(i+1) * StepPercent]));
      CurTable[i]:= FillRatioForDays((i+1) * AStepDay, AStepDay, (i+1) * StepPercent);
   // CurTable[i]:= FillRatioForDays((i+1) * AStepDay, AStepDay,CurTable[i].FPercent);
    end;

    SaveTable;
    SaveLog;
    PostMessage(Form1.Handle, WM_UPDATE_PB, 0, 0);
   end;
  end;
 StatusBar1.Panels[1].Text:='Ready';
 Memo1.Lines.Add('');
 Memo1.Lines.Add(Format('Table for Biff %d succesfully created.', [NumAlgo]));
 Memo1.Lines.Add('Start Time: ' + TimeToStr(StartTimeTimer));
 Memo1.Lines.Add('End Time: ' + TimeToStr(Now));
 Memo1.Lines.Add('Duration: ' + TimeToStr(StartTimeTimer - Now));
 Timer1.Enabled:= false;
end;

function TForm1.CheckFinishedTable(ANumDay, AStepDay: integer): integer;
var
  i, k, NumBlock, LastDay: integer;
  LastDayFilled: boolean;
begin
  NumBlock:= ANumDay div AStepDay;
  if Length(CurTable) = NumBlock then begin
    LastDayFilled:= true;
    if NumAlgo = 2 then begin     // Biff2 reverce direction
      LastDay:= NumBlock - 1;
      for i:= 0 to NumBlock - 1 do begin
        if CurTable[i].FDay = 0 then begin
          LastDay:= i - 1;
          Break;
        end;
      end;
      if LastDay < 0 then begin
         LastDay:= 0;    // Empty Table
      end else begin
        for k:= 0 to MaxI do begin
          if IsZero(CurTable[LastDAy].RatioForDay[k].FCapital) then begin
            LastDayFilled:= false;
            Break;
          end;
        end;
      end;
    end else begin               // Biff 3, Biff 1.5
      LastDay:= 0;
      for i:= NumBlock - 1 downto 0 do begin
        if CurTable[i].FDay = 0 then begin
          LastDay:= i + 1;
          Break;
        end;
      end;
      if LastDay > NumBlock - 1 then begin
         LastDay:= NumBlock - 1;    // Empty Table
      end else begin
        for k:= 0 to MaxI do begin
          if IsZero(CurTable[LastDay].RatioForDay[k].FCapital) then begin
            LastDayFilled:= false;
            Break;
          end;
        end;
      end;
    end;

    if (LastDay > 0) and (LastDay < NumBlock - 1)     // not finished table exists
       and (MessageDlg('You have not finished old table! ' +
       'Do you want continue filling old table?', mtCustom, [mbYes, mbNo], 0) = mrYes) then begin
         Result:= LastDay;
         Exit;
    end;
  end;
  SetLength(CurTable, 0);
  SetLength(CurTable, NumBlock);
  CurTAble[NumBlock - 1].FPercent:= MyBankr;
  CurTAble[NumBlock - 1].FDay:= ANumDay;
  if NumAlgo = 2 then
    Result:= 0
  else
    Result:= NumBlock - 1;
end;

procedure TForm1.SaveTable;
var
  i: integer;
  FileStr: string;
  F: file of TRatioDayArray;
begin
  FileStr:= CurTableFileName; //SetTableName;
  //CurTableFileName:= FileStr;
  AssignFile(F, FileStr);
  Rewrite(F);
  for i:= 0 to High(CurTable) do begin
    Write(F, CurTable[i]);
  end;
  CloseFile(F);
end;

procedure TForm1.LoadTable;
var
  i, Size: integer;
  F: file of TRatioDayArray;
  FileStr: string;
begin
  //FileStr:= SetTableName;
  FileStr:= GetTableList(SetTableMask);
  if FileStr = '' then begin
    SetLength(CurTable, 0);
    StatusBar1.Panels[1].Text:= 'Table not exists';
  end else {if FileStr <> CurTableFileName then} begin
    CurTableFileName:= FileStr;
    AssignFile(F, FileStr);
    if FileExists(FileStr) then begin
      Reset(F);
      Size:= FileSize(F);
      SetLength(CurTable, Size);
      for i:= 0 to Size - 1 do begin
        Read(F, CurTable[i]);
      end;
      CloseFile(F);
      StatusBar1.Panels[1].Text:= 'Table downloaded: ' + FileStr;
    end;
  end;
end;

function TForm1.SetTableName: string;
var
  TotalStr: string;
  CurReRatio: integer;

   procedure AddStr(PreStr, Root: string);
   begin
     TotalStr:= TotalStr + PreStr + Root + '_';
   end;

   procedure AddBool(PreStr: string; Root: boolean);
   var RootStr: string;
   begin
     if Root then
       RootStr:= '+'
     else
       RootStr:= '-';
     TotalStr:= TotalStr + PreStr + RootStr + '_';
   end;

begin
  GetAllParameter;
  TotalStr:= '';
  AddStr('M', Format('%d' , [Round(StartCapital)]));
  AddStr('N', Format('%d' , [NumSim]));
//  AddStr('R', Format('%.1f', [MyBankr * 100]));
  AddStr('R', Format('%.2f', [MyBankr * 100]));
  AddStr('B', Format('%d' , [UPROBankr]));
  AddStr('D', Format('%d' , [TotalDay]));
  AddStr('C', Format('%d' , [StepDay]));
  if CheckBoxReRatio.Checked then
    CurReRatio:= ReRatioDay
  else
    CurReRatio:= 0;
  AddStr('X', Format('%d' , [CurReRatio]));
  AddStr('A', Format('%d' , [NumAlgo]));

 // AddBool('A', Advanced);
  AddBool('E', IsInflation);
  TotalStr:= TotalStr + FormatDateTime('yyyy-mm-dd-hh-nn-ss', Now);
  TotalStr:= Version + '_' + TotalStr + '.biff';
  //Memo1.Lines.Add(TotalStr);
  //StatusBar1.SimpleText:= TotalStr;
  Result:= TotalStr;
end;

function TForm1.SetTableMask: string;
var
  TotalStr: string;

   procedure AddStr(PreStr, Root: string);
   begin
     TotalStr:= TotalStr + PreStr + Root + '*';
   end;

   procedure AddBool(PreStr: string; Root: boolean);
   var RootStr: string;
   begin
     if Root then
       RootStr:= '+'
     else
       RootStr:= '-';
     TotalStr:= TotalStr + PreStr + RootStr + '*';
   end;

begin
  GetAllParameter;
  TotalStr:= '*';
//  AddStr('N', Format('%d' , [NumSim]));
 // AddStr('R', Format('%.1f', [MyBankr * 100]));     // 1.38
  AddStr('B', Format('%d' , [UPROBankr]));
//  AddStr('D', Format('%d' , [TotalDay]));
  AddStr('C', Format('%d' , [StepDay]));
  AddStr('A', Format('%d' , [NumAlgo]));

//  AddBool('A', Advanced);
  AddBool('E', IsInflation);
//  TotalStr:= TotalStr + FormatDateTime('yyyy-mm-dd-hh-nn-ss', Now);
  TotalStr:= TotalStr + '.biff';
  //Memo1.Lines.Add(TotalStr);
 // StatusBar1.SimpleText:= TotalStr;
  Result:= TotalStr;
end;

function TForm1.GetTableList(AFileMask: string): string;
var
  SR: TSearchRec;
  FindRes: integer;
  SL: TStringList;
  FileStr, FileRootStr: string;
begin
 if NumAlgo = 0 then Exit;
 SL:= TStringList.Create;
  try
    try
      FileRootStr:= ExtractFilePath(ParamStr(0));
      FindRes:= FindFirst(FileRootStr + '\' + AFileMask, faAnyFile, SR);
      while FindRes = 0 do begin
        SR.Name:= FileRootStr + SR.Name ;
        if SR.Name = CurTableFileName Then begin
          SL.Clear;
          SL.Add(CurTableFileName);
          Break;
        end;
      //  Memo1.Lines.Add(SR.Name);
        SL.Add(SR.Name);
        FindRes:= FindNext(SR);
      end;
    finally
      FindClose(SR);
    end;
    if (SL.Count) > 1 then begin
      with OpenDialog1 do begin
        InitialDir:= ExtractFilePath(ParamStr(0));
        Filter:= 'Table | ' + AFileMask;
        if Execute then begin
          //Memo1.Lines.Add(FileName);
          FileStr:= FileName;
        end;
      end;
    end else if SL.Count = 1 then begin
      FileStr:= SL[0];
    end else begin
      ShowMessage('First create Table by "Fill Table" button');
      FileStr:= '';
    end;
  finally
    FreeAndNil(SL);
  end;
  Result:= FileStr;
end;


procedure TForm1.ButtonOpenTableClick(Sender: TObject);
//var i: integer;
begin
  with OpenDialog1 do begin
    InitialDir:= ExtractFilePath(ParamStr(0));
    Filter:= 'Table | ' + SetTableMask;
    if Execute then begin
     // for i:= 0 to Length(Files) do begin
        Memo1.Lines.Add(FileName);
        CurTableFileName:= FileName;
        LoadTable;
      //end;
    end;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
//  GetTableList(SetTableMask);
  LoadTable;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if Timer1.Enabled then begin
    StatusBar1.Panels[0].Text:= TimeToStr(Now - StartTimeTimer);
//    StatusBar1.Invalidate;
//    StatusBar1.Update;
  end;
end;

procedure TForm1.StartTimer(Restart: boolean; AStr: string);
begin
  StatusBar1.Panels[1].Text:= AStr; //'Finding Best Ratio Advantage...';
  Memo1.Lines.Add(AStr);
  Timer1.Enabled:= true;
  if Restart then
    StartTimeTimer:= Now;
//  StatusBar1.Invalidate;
end;

function TForm1.TableIsCorrect: boolean;
var
  i, MaxDay: integer;
begin
  MaxDay:= 0;
  for i:= 0 to High(CurTable) do begin
    if CurTable[i].FDay > MaxDay then begin
      MaxDay:= CurTable[i].FDay;
    end;
  end;
  if (NumDay - StepDay) <= MaxDay then begin
    Result:= true;
  end else begin
    Result:= False;
    StartTimer(false, Format('Current table calculated maximum for %d days.', [MaxDay]));
  end;
end;

procedure TForm1.ShowTable(ATable: TTable);
var
  i, k, StartLine: integer;
  CurStr: string;
  FileStr: string;
  F: Textfile;
begin
  if Length(ATable) = 0 then begin
    Memo1.Lines.Add('Table not loaded.');
    Exit;
  end;
  if CheckBoxReRatio.Checked then begin
    ExtraTable:= CreateExtraTable(CurTAble);
    ATable:= ExtraTable;
    Memo1.Lines.Add('Showing Extra Table ' + CurTableFileName);
    FileStr:= CurTableFileName + '_extra_' + IntToStr(ReRatioDay) + '.txt';
  end else begin
    ATable:= CurTable;
    Memo1.Lines.Add('Showing Table ' + CurTableFileName);
    FileStr:= CurTableFileName + '.txt';
  end;
  Memo1.Lines.Add('');
  StartLine:= Memo1.Lines.Count;
  with ATable[High(ATable)] do begin
    CurStr:= Format('Risk of Ruin: %f, UPRO Daily Fail 1 / %d ', [FMyBankr * 100, FUPROBankr]);
    Memo1.Lines.Add(CurStr);
  end;

    CurStr:= 'Days:' + #9;
    CurStr:= CurStr + 'St%:' + #9;
    for i:= 0 to 100 do begin
      CurStr:= CurStr + Format('%7d' + #9, [i]);  // IntToStr(i) + '.' + #9;
    end;
    Memo1.Lines.Add(CurStr);
  for k:= 0 to High(ATable) do begin
    with ATable[k] do begin
      CurStr:= Format('%7d' + #9, [FDay]);
      if IsZero(FPercent) then
        CurStr:= CurStr + #9
      else
        CurStr:= CurStr + Format('%7.3f' + #9, [FPercent * 100]);
    end;
    for i:= 0 to 100 do begin
      with ATable[k].RatioForDay[i * MAxI div 100] do begin
        CurStr:= CurStr + Format('%7.0f' + #9, [FCapital]);
      end;
    end;
    Memo1.Lines.Add(CurStr);
  end;

 //  FileStr:= CurTableFileName + '.txt';
  AssignFile(F, FileStr);
  Rewrite(F);
  for i:= StartLine to Memo1.Lines.Count - 1 do begin
    Writeln(F, Memo1.Lines[i]);
  end;
  CloseFile(F);
end;
 {
procedure TForm1.ShowTable(ATable: TTable);
var
  i, k, StartLine: integer;
  CurStr: string;
  FileStr: string;
  F: Textfile;
begin
  if Length(ATable) = 0 then begin
    Memo1.Lines.Add('Table not loaded.');
    Exit;
  end;
  if CheckBoxReRatio.Checked then begin
    ExtraTable:= CreateExtraTable(CurTAble);
    ATable:= ExtraTable;
    Memo1.Lines.Add('Showing Extra Table ' + CurTableFileName);
    FileStr:= CurTableFileName + '_extra.txt';
  end else begin
    ATable:= CurTable;
    Memo1.Lines.Add('Showing Table ' + CurTableFileName);
    FileStr:= CurTableFileName + '.txt';
  end;
  StartLine:= Memo1.Lines.Count;
  with ATable[0] do begin
    CurStr:= Format('Risk of Ruin: %f, UPRO Daily Fail 1 / %d ', [FMyBankr * 100, FUPROBankr]);
    Memo1.Lines.Add(CurStr);
  end;
    CurStr:= 'Days:' + #9;
    for k:= 0 to High(ATable) do begin
      with ATable[k] do begin
        CurStr:= CurStr + Format('%7d' + #9, [FDay]);
      end;
    end;
    Memo1.Lines.Add(CurStr);
    CurStr:= 'St%:' + #9;
    for k:= 0 to High(ATable) do begin
      with ATable[k] do begin
        CurStr:= CurStr + Format('%7.3f' + #9, [FPercent * 100]);
      end;
    end;
    Memo1.Lines.Add(CurStr);

  for i:= 0 to 100 do begin
    CurStr:= IntToStr(i) + '.' + #9;
    for k:= 0 to High(ATable) do begin
      with ATable[k].RatioForDay[i * MAxI div 100] do begin
        CurStr:= CurStr + Format('%7.0f' + #9, [FCapital]);
      end;
    end;
    Memo1.Lines.Add(CurStr);
  end;


 //  FileStr:= CurTableFileName + '.txt';
  AssignFile(F, FileStr);
  Rewrite(F);
  for i:= StartLine to Memo1.Lines.Count - 1 do begin
    Writeln(F, Memo1.Lines[i]);
  end;
  CloseFile(F);
end;
}

procedure TForm1.ButtonConvertTableClick(Sender: TObject);
begin
  //ConvertTableToTxt;
  ShowTable(CurTable);
end;

//procedure CalcNumBankruptcySimple(ANumSim,  ANumDay: integer; ACapital, ARasxod: real; StartRatio: PRatio);
procedure TForm1.CalcNumBankruptcyExtra(ACapital, ARasxod: real; ANumSim, ANumDay, ACurDay, AStepDay: integer; StartRatio: PRatio);
  var i, k, y, N, Index, NumBlock, CurBlock {, Bankruptcy} : integer;
    TotalCapital, UPROPart: real;
    CurVOOPerc, CurUPROPerc: real;
    label ZeroCapital;
  begin
    NumBlock:= ANumDay div AStepDay;
    CurBlock:= ACurDay div AStepDay;
    N:= Length(PriceData);
//    Bankruptcy:= 0;
    for i:= 0 to ANumSim - 1 do begin
      TotalCapital:= ACapital;
      for y:= NumBlock downto 1 do begin
        if y >= CurBlock then begin
          CurUPROPerc:= FindExtraTableRatio(TotalCapital, y * AStepDay, @ExtraTable) / MaxI;
          CurVOOPerc:= 1 - CurUPROPerc;
        end;
        for k:= 1 to AStepDay do begin
          Index:= Random(N);
          with PriceData[Index] do begin
            UPROPart:= CurUPROPerc * UPRO;
            if IsBankruptcy then begin
              if Random(UPROBankr) = 0 then
                UPROPart:= 0;
            end;
            TotalCapital:= TotalCapital * (CurVOOPerc * VOO + UPROPart) - ARasxod;
            if TotalCapital <= 0 then begin
              InterlockedIncrement(StartRatio.Bankruptcy);
              TotalCapital:= 0;
              Goto ZeroCapital;
              //Break;
            end;
          end;
        end;
      end;
      ZeroCapital://
    end;
//      Total_EV:= Total_EV + TotalCapital;    // if need EV
//      CurArrayReal[i]:= TotalCapital;  // 1.39
      StartRatio.Total:= StartRatio.Total + ANumSim;
      StartRatio.FRatio:= StartRatio.Bankruptcy / StartRatio.Total;

  end;


function TForm1.CorrectPerc(ACapital, APercent: real; ARatio, ANumDay, ACurDay, AStepDay: integer;
                             var ATable: TTable; var AFinalRisk: real): real;  // New correct percent
var
  N: integer; //InnerNumSim, CurRatio, First, Last: integer;
  StartRatioArray: TRatioArray;
  //StartTime: TDateTime;
  X, Y, R0Perc, R100Perc, DeltaR: real;

procedure CalcNumBankruptcy(AInnerNumSim, ACurRatio: integer);
var i, k, y, Index, NumBlock, CurBlock: integer;
  TotalCapital, UPROPart: real;
  CurVOOPerc, CurUPROPerc: real;
  label ZeroCapital;
begin
  CurUPROPerc:= 0;
  CurVOOPerc:= 0;
  NumBlock:= ANumDay div AStepDay;
  CurBlock:= ACurDay div AStepDay;
  with StartRatioArray[ACurRatio] do begin
   for i:= 1 to AInnerNumSim do begin
    TotalCapital:= ACapital;
    for y:= NumBlock downto 1 do begin
      if y = NumBlock then begin           // first block
        CurVOOPerc:= VOOPerc;
        CurUPROPerc:= UPROPerc;
      end else if y >= CurBlock then begin                     // all other block get Ratio from Table
        CurUPROPerc:= FindTableRatio(TotalCapital, y * AStepDay, @ATable) / MaxI;
        CurVOOPerc:= 1 - CurUPROPerc;
      end;
      if y = CurBlock then begin
        If IsZero(CurUPROPerc) then  // Ratio = 0
          InterlockedIncrement(R0)
        else if IsZero(CurUPROPerc - 1) then  // // Ratio = 100
          InterlockedIncrement(R100);
      end;
      for k:= 1 to AStepDay do begin
        Index:= Random(N);
        with PriceData[Index] do begin
          UPROPart:= CurUPROPerc * UPRO;
          if IsBankruptcy then begin
            if Random(UPROBankr) = 0 then begin
              UPROPart:= 0;
            end;
          end;
          TotalCapital:= TotalCapital * (CurVOOPerc * VOO + UPROPart) - 1; //ARasxod;
          if TotalCapital <= 0 then begin
            InterlockedIncrement(Bankruptcy);
            //TotalCapital:= 0;
            Goto ZeroCapital;
            //Break;
          end;
        end;
      end;
    end;
    ZeroCapital://
  end;
  // Total_EV:= Total_EV + TotalCapital;     if need EV
  Total:= Total + AInnerNumSim;
  FRatio:= Bankruptcy / Total;
 end;
end;

begin
  StartTimer(false, Format('Correcting table for %d / %d days ...', [ACurDay, ANumDay]));
  StartRatioArray:= ZeroRatioArray;
 if CheckBoxReratio.Checked then begin
   CalcNumBankruptcyExtra(ACapital, 1, NumSim, ANumDay, ACurDay, ReRatioDay, @(StartRatioArray[ARatio]));
   AFinalRisk:= StartRatioArray[ARatio].FRatio;
 end else begin
  N:= Length(PriceData);
  //StartTime:= Now;
 // InnerNumSim:= ANumSim div 5;
  CalcNumBankruptcy(NumSim, ARatio);
  with StartRatioArray[ARatio] do begin
    R0Perc:= R0 / Total;
    R100Perc:= R100 / Total;
    //DeltaR:= R0Perc + R100Perc;
    DeltaR:= R0Perc ;
    if IsZero(DeltaR) or IsZero(1 - DeltaR) then begin
      X:= 0;
      Y:= APercent;
    end else begin
      X:= (FRatio - (1 - DeltaR) * APercent) / DeltaR;
      Y:= (MyBankr - DeltaR * X) / (1 - DeltaR);
     // X:= 1;
     // Y:= APercent * MyBankr / FRatio;
    end;
    AFinalRisk:= FRatio;
//    Memo1.Lines.Add(Format('R0 = %f, R100 = %f, FinalRisk = %f ',
//                           [R0Perc * 100, R100Perc * 100, AFinalRisk * 100]));
//    Memo1.Lines.Add(Format('Start Percent = %f, X = %f, Y = %f ', [APercent *100, X *100, Y * 100]));
   end;
 end;
  Memo1.Lines.Add(Format('Start Percent = %f, FinalRisk = %f ', [APercent *100, AFinalRisk * 100]));
  Result:= Y;
end;

procedure TForm1.CheckBoxInflationClick(Sender: TObject);
begin
  CheckBoxInflation.Enabled := false;
  IsInflation:= CheckBoxInflation.Checked;
  OpenPriceFile;
  CheckBoxInflation.Enabled := true;
end;

procedure TForm1.RadioGroupBiffClick(Sender: TObject);
begin
  NumAlgo:= RadioGroupBiff.ItemIndex;
end;

procedure TForm1.EnableControls(enable: bool);
begin
  if Terminating then
    Exit;
  Form1.ButtonBestRatio.Enabled := enable;
  Form1.ButtonFillTable.Enabled := enable;
  Form1.ButtonUPRO.Enabled := enable;
  CheckBoxInflation.Enabled := enable;
  ButtonFillRatio.Enabled := enable;
  ButtonOpenTable.Enabled := enable;
end;

procedure TForm1.WMUpdatePB(var msg: TMessage);
begin
  ProgressBar.StepIt;
end;

procedure TForm1.CreateTablePercent(var ATable: TTable; TargetPercent, Koef: real; ANumDay, AStepDay: integer);
var
  i, NumBlock: integer;
begin
  NumBlock:= ANumDay div AStepDay;
  if Length(ATable) < NumBlock then
    SetLength(ATable, NumBlock);
  ATable[NumBlock - 1].FPercent:= TargetPercent;
  for i:= NumBlock - 2 downto 0 do begin
    ATable[i].FPercent:= ATable[i+1].FPercent / Koef;
  end;
  for i:= NumBlock - 1 downto 0 do begin
    Memo1.Lines.Add(Format('Days: ' +#9+ '%d ,' +#9+ '%.4f ', [(i+1) * AStepDay, ATable[i].FPercent *100]));
  end;

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
    '.', ',':
      if Pos(DecimalSeparator, (Sender as TEdit).Text) = 0 then
        Key := DecimalSeparator
      else
        Key := #0; // decimal separator
    else
      key := #0;
  end;
end;

procedure TForm1.StopFillTable();
begin
  Terminating := true;
  EnableControls(false);
end;

procedure TForm1.ButtonStopFillTableClick(Sender: TObject);
begin
  StopFillTable();
end;

procedure TForm1.CopyPercentFromCurTable;
var
  i, NumBlock: integer;
  StepPercent: real;
begin
  NumBlock:= NumDay div StepDay;
  if FormDialog.CheckBoxUseCurTable.Checked then begin
    SetLength(StartPercentArr, Length(CurTable));
    for i:= 0 to High(StartPercentArr) do begin
      StartPercentArr[i]:= CurTAble[i].FPercent;
    end;
  end else begin
    if not ManualStartPercentOn then begin
      SetLength(StartPercentArr, NumBlock);
      StepPercent:= MyBankr / NumBlock;
      for i:= 0 to High(StartPercentArr) do begin
        StartPercentArr[i]:= (i+1) * StepPercent;
      end;
    end;
  end;
end;

function TForm1.CreateExtraTable(ATable: TTable): TTable;
var
  i, k, y, NumBlock, MaxDay, AStepDAy: integer;
  CapitalFrom, CapitalTo, CapitalStep: real;
begin
  NumBlock:= Length(ATable);
  if NumBlock = 0 then Exit;  // Empty Table
  MaxDay:= ATable[High(ATable)].FDay;
  if MaxDay = 0 then begin  // old Format (not filled highest day)
    MaxDay:= ATable[NumBlock-2].FDay + (ATable[NumBlock-2].FDay - ATable[NumBlock-3].FDay);
  end;
  if MaxDay = 0 then  Exit;   // wrong Table
  SetLength(Result, MaxDay + 1);  // zero Index - empty
  AStepDay:= MaxDay div NumBlock;
  for i:= NumBlock - 1 downto 0 do begin
    Result[(i + 1) * AStepDay].FPercent:= ATable[i].FPercent;
    Result[(i + 1) * AStepDay].FMyBankr:= ATable[i].FMyBankr;
    Result[(i + 1) * AStepDay].FUPROBankr:= ATable[i].FUPROBankr;
    for y:= 1 to AStepDAy do begin
      Result[i * AStepDay + y].FDay:= i * AStepDay + y;
    end;
    for k:= 0 to MaxI do begin
      CapitalFrom:= ATable[i].RatioForDay[k].FCapital;
      if i = NumBlock - 1 then begin    // First Row
        if IsZero(CapitalFrom) then begin
          CapitalFrom:= StartCapital / Rasxod;    //   old Format (not filled highest day)
        end;
      end;
      if i > 0 then begin
        CapitalTo:= ATable[i-1].RatioForDay[k].FCapital;
      end else begin        // Zero Row
        CapitalTo:= 2 * ATable[i].RatioForDay[k].FCapital - ATable[i+1].RatioForDay[k].FCapital ;
        if CapitalTo < 2 then
          CapitalTo:= 2;
      end;
      CapitalStep:= (CapitalFrom - CapitalTo) / AStepDay;
      for y:= 1 to AStepDAy do begin
        Result[i * AStepDay + y].RatioForDay[k].FCapital:= CapitalTo + y * CapitalStep;
      end;
    end;
  end;
end;

function TForm1.CorrectExtraTable(ATable: TTable; var AExtraTable: TTable; ACurBlock: integer): TTable;
var
  i, k, y, NumBlock, MaxDay, AStepDAy: integer;
  CapitalFrom, CapitalTo, CapitalStep: real;
begin
  NumBlock:= Length(ATable);
  if NumBlock = 0 then Exit;  // Empty Table
  MaxDay:= ATable[High(ATable)].FDay;
  if MaxDay = 0 then begin  // old Format (not filled highest day)
    MaxDay:= ATable[NumBlock-2].FDay + (ATable[NumBlock-2].FDay - ATable[NumBlock-3].FDay);
  end;
  if MaxDay = 0 then  Exit;   // wrong Table
 // SetLength(Result, MaxDay + 1);  // zero Index - empty
  AStepDay:= MaxDay div NumBlock;
  //for i:= NumBlock - 1 downto 0 do begin

    i:= ACurBlock;    // one piece from CurBlock to CurBlock + 1
    AExtraTable[(i + 1) * AStepDay].FPercent:= ATable[i].FPercent;
    for k:= 0 to MaxI do begin
      CapitalTo:= ATable[i].RatioForDay[k].FCapital;
      if i < NumBlock - 1 then begin
        CapitalFrom:= ATable[i + 1].RatioForDay[k].FCapital;
        CapitalStep:= (CapitalFrom - CapitalTo) / AStepDay;
        for y:= 1 to AStepDAy do begin
          AExtraTable[i * AStepDay + y].RatioForDay[k].FCapital:= CapitalTo + y * CapitalStep;
        end;
      end;
    end;
    for k:= 0 to MaxI do begin
      CapitalFrom:= ATable[i].RatioForDay[k].FCapital;
      CapitalTo:= 2;
      CapitalStep:= (CapitalFrom - CapitalTo) / (AStepDay * (i + 1));
      for y:= 1 to AStepDAy * (i + 1) do begin
        AExtraTable[y].RatioForDay[k].FCapital:= CapitalTo + y * CapitalStep;
      end;
    end;
end;

function TForm1.PrepareExtraTable(ATable: TTable; var AExtraTable: TTable; ACurBlock: integer): TTable;
var
  i, k, y, NumBlock, MaxDay, AStepDAy: integer;
  CapitalFrom, CapitalTo, CapitalStep: real;
begin
  NumBlock:= Length(ATable);
  if NumBlock = 0 then Exit;  // Empty Table
  MaxDay:= ATable[High(ATable)].FDay;
  if MaxDay = 0 then begin  // old Format (not filled highest day)
    MaxDay:= ATable[NumBlock-2].FDay + (ATable[NumBlock-2].FDay - ATable[NumBlock-3].FDay);
  end;
  if MaxDay = 0 then  Exit;   // wrong Table
  SetLength(AExtraTable, 0);  // zero Index - empty
  SetLength(AExtraTable, MaxDay + 1);  // zero Index - empty

  AStepDay:= MaxDay div NumBlock;
  for y:= 1 to AStepDAy * NumBlock do begin
    AExtraTable[y].FDay:= y;
  end;
  for i:= NumBlock - 1 downto ACurBlock do begin
    //i:= ACurBlock;    // one piece from CurBlock to CurBlock + 1
    AExtraTable[(i + 1) * AStepDay].FPercent:= ATable[i].FPercent;
    for k:= 0 to MaxI do begin
      CapitalTo:= ATable[i].RatioForDay[k].FCapital;
      if i < NumBlock - 1 then begin
        CapitalFrom:= ATable[i + 1].RatioForDay[k].FCapital;
        CapitalStep:= (CapitalFrom - CapitalTo) / AStepDay;
        for y:= 1 to AStepDAy do begin
          AExtraTable[i * AStepDay + y].RatioForDay[k].FCapital:= CapitalTo + y * CapitalStep;
        end;
      end;
    end;
  end;
  i:= ACurBlock;
  if (i <= NumBlock - 1) and (i >= 0) then begin
    for k:= 0 to MaxI do begin
      CapitalFrom:= ATable[i].RatioForDay[k].FCapital;
      CapitalTo:= 2;
      CapitalStep:= (CapitalFrom - CapitalTo) / (AStepDay * (i + 1));
      for y:= 1 to AStepDAy * (i + 1) do begin
        AExtraTable[y].RatioForDay[k].FCapital:= CapitalTo + y * CapitalStep;
      end;
    end;
  end;
end;



procedure TForm1.ButtonExtraTableClick(Sender: TObject);
begin
  CurTable:= CreateExtraTable(CurTAble);
end;

end.

