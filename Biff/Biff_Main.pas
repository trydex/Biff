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
  
  TBestRatioThread = class(TThread)
  public
    constructor Create(value: bool);
    procedure Execute; override;
    procedure DoTerminate; override;
  end;

  TFillTableThread = class(TThread)
  public
    constructor Create(value: bool);
    procedure Execute; override;
    procedure DoTerminate; override;
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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    { Private declarations }
    Utils: TUtils;
    BestRatioThread: TBestRatioThread;
    FillTableThread: TFillTableThread;
    IsClosing: bool;
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
    TotalDay, StepDay: integer;
    Advanced: boolean;
    NumAlgo: integer;            // 0 - Biff 1, 1 - Biff 1.5, 2 - Biff 2.0, 3 - Biff 3.0
    IsBankruptcy: boolean;
    IsInflation: boolean;
    Correction: boolean;
    RatioArray: TRatioArray;
    ZeroRatioArray: TRatioArray;
    CurTable: TTable;  //array of TRatioDayArray;
    CurTableFileName: string;
    StartTimeTimer: TDateTime;

    procedure OpenPriceFile;
    procedure GetAllParameter;
    procedure LoadIniFile;
    procedure SaveIniFile;

    procedure CalculateEV;
    procedure CalculateEVAdv;
    procedure CalculateTest;
    procedure Statistic;
    procedure FindBestRatioProcedure;
    function FindBestRatio(ACapital, ARasxod, APercent: real; ANumDay, ANumSim: integer): integer;  // Result 0..100 Perc for UPRO
    function FindBestRatioAdv(ACapital, ARasxod, APercent: real; ANumDay, ANumSim, AStepDay: integer): integer;  // Result 0..100 Perc for UPRO
    //function FindTablePercent(ACapital, ARasxod, APercent: real; ANumDay, ANumSim, AStepDay: integer; ATable: TTable): integer;  // Result 0..100 Perc for UPRO
    function FindTablePercent(ACapital, ARasxod, APercent: real; ARatio, ANumDay, ANumSim, AStepDay: integer; var ATable: TTable): integer;  // Result 0..100 Perc for UPRO

    function FillRatioForDays(ANumDay, AStepDay: integer; APercent:real): TRatioDayArray;
    procedure FillAllRatio(var ARatioDayArray: TRatioDayArray);
    function FindTableRatio(ACapital: real; DayLeft: integer; ATable: TTable): integer;
    procedure FillAllTableProcedure();
    procedure FillAllTable(ANumDay, AStepDay: integer);
    procedure SaveTable;
    procedure LoadTable;
    function SetTableName: string;
    function SetTableMask: string;
    function GetTableList(AFileMask: string): string;
    procedure StartTimer(Restart: boolean; AStr: string);
    function TableIsCorrect: boolean;
    procedure ConvertTableToTxt;
    function CorrectPerc(ACapital, APercent: real; ARatio, ANumDay, ACurDay, AStepDay: integer;
                             var ATable: TTable; var AFinalRisk: real): real;  // New correct percent


  //  procedure GetTableName;

  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

//================================================
constructor TBestRatioThread.Create(value: bool);
begin
  inherited create(value);
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
  Form1.EnableControls(true);
  inherited
end;


constructor TFillTableThread.Create(value: bool);
begin
  inherited create(value);
  FreeOnTerminate := true;
  Priority := tpNormal;
end;

procedure TFillTableThread.Execute;
begin
  Form1.EnableControls(false);
  Form1.FillAllTableProcedure();
end;

procedure TFillTableThread.DoTerminate;
begin
  Form1.EnableControls(true);
end;
//================================================

procedure TForm1.FormCreate(Sender: TObject);
var i: integer;
begin
  // Update decimal separator only for currect application.
  Application.UpdateFormatSettings := false;
  DecimalSeparator := '.';

  IsClosing := false;
  ProgressBar.DoubleBuffered := true;
  LoadIniFile;
  GetAllParameter;
  OpenPriceFile;
  LoadTable;
  Randomize;
  for i:= 0 to MaxI do begin
    with ZeroRatioArray[i] do begin
      UPROPerc:= i / MaxI;
      VOOPerc:= 1 - UPROPerc;
      Total:= 0;
      Bankruptcy:= 0;
      FRatio:= 0;
    end;
  end;
//  StatusBar1.Update;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  SaveIniFile;
end;

procedure TForm1.ButtonTestClick(Sender: TObject);
begin
  CalculateTest;
end;

procedure TForm1.ButtonUPROClick(Sender: TObject);
begin
  GetAllParameter;
{  if Advanced then begin
    LoadTable;
    if TableIsCorrect then
      CalculateEVAdv;
  end else
    CalculateEV;  }
  if NumAlgo = 0 then
    CalculateEV
  else begin        // all other use Table
    LoadTable;
    if TableIsCorrect then
      CalculateEVAdv;
  end;
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
  Advanced:= CheckBoxAdv.Checked;
  IsInflation:= CheckBoxInflation.Checked;
  NumAlgo:= RadioGroupBiff.ItemIndex;
end;

procedure TForm1.LoadIniFile;
var
  AIniFile: INIFiles.TIniFile;
  AFileName: string;
  ScanPeriod: integer;
  MouseDelay: real;
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
    CheckBoxAdv.Checked:= AIniFile.ReadBool('Common', 'Advanced', CheckBoxAdv.Checked);
    CheckBoxInflation.Checked:= AIniFile.ReadBool('Common', 'IsInflation', CheckBoxInflation.Checked);
    CurTableFileName:= AIniFile.ReadString('Common', 'Table File Name', '');
    RadioGroupBiff.ItemIndex:= AIniFile.ReadInteger('Common', 'Num Algo', RadioGroupBiff.ItemIndex);
  finally
    FreeAndNil(AIniFile);
  end;
end;

procedure TForm1.SaveIniFile;
var
  AIniFile: INIFiles.TIniFile;
  AFileName: string;
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
    AIniFile.WriteBool('Common', 'Advanced', Advanced);
    AIniFile.WriteBool('Common', 'IsInflation', IsInflation);
    AIniFile.WriteString('Common', 'Table File Name', CurTableFileName);
    AIniFile.WriteInteger('Common', 'Num Algo', RadioGroupBiff.ItemIndex);
  finally
    FreeAndNil(AIniFile);
  end;
end;



procedure TForm1.CalculateTest;
var i, k, N, Index, Win, VOOBankrot, UPROBankrot: integer;
  VOOCapital, UPROCapital, TotalCapital: real;
  StartVOO, StartUPRO, RasxodVOO, RasxodUPRO: real;
  VOO_EV, UPRO_EV: real;
  VOO_Day, UPRO_Day: real;
  VOOPer, UPROPer: real;
  StartTime: TdateTime;
begin
  StartCapital:= StrToFloatDef(EditCapital.Text, 100000);
  Rasxod:=  StrToFloatDef(EditRasxod.Text, 10);
  NumDay:= StrToIntDef(EditDays.Text, 250);
  NumSim:= StrToIntDef(EditSims.Text, 1000000);
  N:= Length(PriceData);
  UPROPer:= (StrToFloatDef(EditUPROPer.Text, 100)) / 100;
  VOOPer:= 1 - UPROPer;
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
var i, k, N, Index, Win, VOOBankrot, UPROBankrot: integer;
  VOOCapital, UPROCapital, TotalCapital: real;
  StartVOO, StartUPRO, RasxodVOO, RasxodUPRO, UPROPart: real;
  VOO_EV, UPRO_EV, Total_EV: Real;
  VOO_Day, UPRO_Day, Total_Day: real;
  VOOPer, UPROPer, RePerc: real;
  StartTime: TdateTime;
  CanRebalance: boolean;
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
  VOO_EV:= 0;
  UPRO_EV:= 0;
  Total_EV:= 0;
  Win:= 0;
  VOOBankrot:= 0;
  UPROBankrot:= 0;
  StartVOO:= StartCapital * VOOPer;
  StartUPRO:= StartCapital * UPROPer;
  RasxodVOO:= Rasxod * VOOPer;
  RasxodUPRO:= Rasxod * UPROPer;
  StartTime:= Now;
  for i:= 1 to NumSim do begin
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
  end;
  StartTime:= Now - StartTime;
  Total_EV:= Total_EV / NumSim;
  Total_Day:= Power(Total_EV / StartCapital, 1 / NumDay);;
  Total_Day:= (Total_Day - 1) * 100;  // in percent
  Memo1.Lines.Add('Time: ' + TimeToStr(StartTime) + '  UPRO: ' + FloatToStr(UPROPer * 100) + ' %' );
  Memo1.Lines.Add(Format('EV:  Total: %f ', [Total_EV]));
  Memo1.Lines.Add(Format('EV daily:  %.6f ', [Total_Day]));
  Memo1.Lines.Add(Format('Bankruptcy:  %d ( %f ) ', [UPROBankrot, UPROBankrot * 100 / NumSim]));
  Memo1.Lines.Add('');
  Timer1.Enabled:= false;
end;

procedure TForm1.CalculateEVAdv;
var
  N, UPROBankruptcy: integer;
  VOOPer, UPROPer, Total_EV, Total_Day: real;
  StartTime: TDateTime;


procedure CalcNumBankruptcyEV(ACapital, ARasxod: real; ANumDay, ANumSim, AStepDay: integer);
var i, k, y, Index, NumBlock: integer;
  TotalCapital, UPROPart: real;
  CurVOOPerc, CurUPROPerc: real;
  label ZeroCapital;
begin
  NumBlock:= ANumDay div AStepDay;
  for i:= 1 to ANumSim do begin
    TotalCapital:= ACapital;
    for y:= NumBlock downto 1 do begin
      if y = NumBlock then begin           // first block
        CurVOOPerc:= VOOPer;
        CurUPROPerc:= UPROPer;
      end else begin                     // all other block get Ratio from Table
        CurUPROPerc:= FindTableRatio(TotalCapital, y * AStepDay, CurTable) / MaxI;
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
            Inc(UPROBankruptcy);
            TotalCapital:= 0;
            Goto ZeroCapital;
            //Break;
          end;
        end;
      end;
    end;
    ZeroCapital://
    Total_EV:= Total_EV + TotalCapital;    // if need EV
  end;
   // Memo1.Lines.Add(Format('Ratio: %d , %f ', [ACurRatio, FRatio * 100]));
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
    CalcNumBankruptcyEV(StartCapital / Rasxod, 1, NumDay, NumSim, StepDay);
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
  Timer1.Enabled:= false;
end;


function TForm1.FindBestRatio(ACapital, ARasxod, APercent: real; ANumDay, ANumSim: integer): integer;  // Result 0..100 Perc for UPRO
var
  N, InnerNumSim, CurRatio, First, Last: integer;
  StartRatioArray: TRatioArray;
  StartTime: TDateTime;
  CurMyBankr: real;

procedure CalcNumBankruptcy(AInnerNumSim, ACurRatio: integer);
var i, k, Index: integer;
  TotalCapital, UPROPart: real;
begin
  with StartRatioArray[ACurRatio] do begin
    for i:= 1 to AInnerNumSim do begin
      TotalCapital:= ACapital;
      for k:= 1 to ANumDay do begin
        Index:= Random(N);
        with PriceData[Index] do begin
          UPROPart:= UPROPerc * UPRO;
          if IsBankruptcy then begin
            if Random(UPROBankr) = 0 then
              UPROPart:= 0;
          end;
          TotalCapital:= TotalCapital * (VOOPerc * VOO + UPROPart) - ARasxod;
          if TotalCapital <= 0 then begin
            Inc(Bankruptcy);
            TotalCapital:= 0;
            Break;
          end;
        end;
      end;
    end;
    Total:= Total + InnerNumSim;
    FRatio:= Bankruptcy / Total;
  end;
end;

begin
//  StartTimer('Finding simple Best Ratio ...');
  Memo1.Lines.Add('');
  Memo1.Lines.Add(Format('Biff: %d, Capital: %.0f, Rasxod: %.0f, Percent: %f, Days: %d, Sim: %d ',
                         [NumAlgo, ACapital, ARasxod, APercent*100, ANumDay, ANumSim]));
  StartRatioArray:= ZeroRatioArray;
  N:= Length(PriceData);
  StartTime:= Now;
  InnerNumSim:= ANumSim div 5;
{  CurRatio:= 100;
  CalcNumBankruptcy(InnerNumSim, CurRatio);
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
    CalcNumBankruptcy(ANumSim, CurRatio);
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
  //repeat
    if Last - First = 1 then begin
      if StartRatioArray[First].Total > StartRatioArray[Last].Total  then
        CurRatio:= Last
      else
        CurRatio:= First;
    end else begin
      CurRatio:= (First + Last) div 2;
    end;
    CalcNumBankruptcy(InnerNumSim, CurRatio);
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



function TForm1.FindBestRatioAdv(ACapital, ARasxod, APercent: real; ANumDay, ANumSim, AStepDay: integer): integer;  // Result 0..100 Perc for UPRO
var
  N, InnerNumSim, CurRatio, First, Last: integer;
  StartRatioArray: TRatioArray;
  StartTime: TDateTime;
  NumBankr: integer;
  CurMyBankr: real;

procedure CalcNumBankruptcy1(AInnerNumSim, ACurRatio: integer);  //  copy from simple
var i, k, Index: integer;
  TotalCapital, UPROPart: real;
begin
  with StartRatioArray[ACurRatio] do begin
    for i:= 1 to AInnerNumSim do begin
      TotalCapital:= ACapital;
      for k:= 1 to ANumDay do begin
        Index:= Random(N);
        with PriceData[Index] do begin
          UPROPart:= UPROPerc * UPRO;
          if IsBankruptcy then begin
            if Random(UPROBankr) = 0 then
              UPROPart:= 0;
          end;
          TotalCapital:= TotalCapital * (VOOPerc * VOO + UPROPart) - ARasxod;
          if TotalCapital <= 0 then begin
            Inc(Bankruptcy);
            TotalCapital:= 0;
            Break;
          end;
        end;
      end;
    end;
    Total:= Total + InnerNumSim;
    FRatio:= Bankruptcy / Total;
  end;
end;

procedure CalcNumBankruptcy(AInnerNumSim, ACurRatio: integer);
var i, k, y, Index, NumBlock: integer;
  TotalCapital, UPROPart: real;
  CurVOOPerc, CurUPROPerc: real;
  label ZeroCapital;
begin
  NumBlock:= ANumDay div AStepDay;
  with StartRatioArray[ACurRatio] do begin
   for i:= 1 to AInnerNumSim do begin
    TotalCapital:= ACapital;
    for y:= NumBlock downto 1 do begin
      if y = NumBlock then begin           // first block
        CurVOOPerc:= VOOPerc;
        CurUPROPerc:= UPROPerc;
      end else begin                     // all other block get Ratio from Table
        CurUPROPerc:= FindTableRatio(TotalCapital, y * AStepDay, CurTable) / MaxI;
        CurVOOPerc:= 1 - CurUPROPerc;
      end;
      for k:= 1 to AStepDay do begin
        Index:= Random(N);
        with PriceData[Index] do begin
          UPROPart:= CurUPROPerc * UPRO;
          if IsBankruptcy then begin
            if Random(UPROBankr) = 0 then begin
              Inc(NumBankr);
              UPROPart:= 0;
            end;
          end;
          TotalCapital:= TotalCapital * (CurVOOPerc * VOO + UPROPart) - ARasxod;
          if TotalCapital <= 0 then begin
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
  // Total_EV:= Total_EV + TotalCapital;     if need EV
  Total:= Total + InnerNumSim;
  FRatio:= Bankruptcy / Total;
 // Memo1.Lines.Add(Format('Ratio: %d , %f ', [ACurRatio, FRatio * 100]));
 end;
end;

begin
//  StartTimer('Finding Best Ratio Advantage...');
  Memo1.Lines.Add('');
  Memo1.Lines.Add(Format('Capital: %.0f, Rasxod: %.0f, Percent: %f, Days: %d, Sim: %d ',
                         [ACapital, ARasxod, APercent*100, ANumDay, ANumSim]));

  NumBankr:= 0;
  StartRatioArray:= ZeroRatioArray;
  N:= Length(PriceData);
  StartTime:= Now;
  InnerNumSim:= ANumSim div 5;
 {
  CurRatio:= 100;
  CalcNumBankruptcy(InnerNumSim, CurRatio);
  with StartRatioArray[CurRatio] do begin
    if FRatio > MyBankr then begin
      First:= 0;
    end else begin
      First:= CurRatio;
    end;
    Last:= CurRatio;
  end;
  }
   /////////////    New Algo   !!!!!!!!!!!!    //////////////////
 if Correction then begin
  CurRatio:= 0;
  CalcNumBankruptcy1(ANumSim, CurRatio);
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
  //repeat
  while Result < 0 do begin
    if Last - First = 1 then begin
      if StartRatioArray[First].Total > StartRatioArray[Last].Total  then
        CurRatio:= Last
      else
        CurRatio:= First;
    end else begin
      CurRatio:= (First + Last) div 2;
    end;
    CalcNumBankruptcy(InnerNumSim, CurRatio);
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
  //until Result >= 0;
  end; // while
  StartTime:= Now - StartTime;
  //Timer1.Enabled:= false;;
//  Memo1.Lines.Add('');
  Memo1.Lines.Add('Time: ' + TimeToStr(StartTime));
 // Memo1.Lines.Add(Format('Num UPRO Bankr: %d ', [NumBankr]));
  Memo1.Lines.Add(Format('Day Left: %d,  Best Ratio: %f ', [ANumDay, Result * 100 / MaxI]));
  //EditUPROPer.Text:= IntToStr(Result);
  EditUPROPer.Text:= FloatToStr(Result * 100 / MaxI);

end;

//function FindTablePercent(ACapital, ARasxod, APercent: real; ANumDay, ANumSim, AStepDay: integer): integer;  // Result 0..100 Perc for UPRO
//StartCapital, Percent, StartRatio, NumDay, i * StepDay, StepDay,
//                       CurTable, FinalRisk);  // New correct percent

function TForm1.FindTablePercent(ACapital, ARasxod, APercent: real; ARatio, ANumDay, ANumSim, AStepDay: integer; var ATable: TTable): integer;  // Result 0..100 Perc for UPRO
var
  N, T, InnerNumSim : integer;
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
begin
  ProgressBar.Position := 0;
  BestRatioThread := TBestRatioThread.Create(false);
end;

procedure TForm1.FindBestRatioProcedure();
var
  BestRatio: integer;
  TempTable: TTable;
begin
  GetAllParameter;
  Correction:= false;
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
  //Timer1.Enabled:= false;
  EditUPROPer.Text:= FloatToStr(BestRatio * 100 / MaxI);
end;

function TForm1.FillRatioForDays(ANumDay, AStepDay: integer; APercent: real): TRatioDayArray;
var
  StartM, StepM : real;
  UPROFail, CurStartCapital: real;
  i, k, BestRatio, LastRatio, DiffRatio, MaxRatio: integer;
  I10, I1: integer;
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
  if UPROFail > MyBankr then begin
    MaxRatio:= MaxI - 1;  // maybe Round(MaxI * 0.99) ??
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
  I10:= MaxI div 10;
  I1:= MaxI div 100;
  CurSim:= Round(NumSim * ((TotalDay / ANumDay) / 100)) * 100;
  repeat
    CurStartCapital:= ANumDay * StartM;
    if {Advanced} NumAlgo = 2 then
      BestRatio:= FindBestRatioAdv(CurStartCapital, {Rasxod} 1, APercent, ANumDay, CurSim, AStepDay)
    else
      BestRatio:= FindBestRatio(CurStartCapital, {Rasxod} 1, APercent, ANumDay, CurSim);

    if LastRatio >=0 then begin
      DiffRatio:= BestRatio - LastRatio;
      if DiffRatio > I10 then begin
        StepM:= Sqrt(StepM);
      end
    //  else if DiffRatio <= 1 then
    //    StepM:= StepM * 1.5
    //  else if DiffRatio <= 2 then
    //    StepM:= StepM * 1.2
      else  if (DiffRatio <= I1) and (DiffRatio >= 0) then
        StepM:= StepM * 1.1;
    end;

    LastRatio:= BestRatio;
    StartM:= StartM * StepM;
    RatioForDay[BestRatio].FCapital:= CurStartCapital;
    RatioForDay[BestRatio].FNumSim:= RatioForDay[BestRatio].FNumSim + CurSim;
    //AddCapital(CurStartCapital, BestRatio);
   // Memo1.Lines.Add(Format('Capital: %f , Best Ratio: %d ', [CurStartCapital, BestRatio]));
  until (BestRatio >= MaxRatio) or (RatioForDay[BestRatio].FNumSim >= 5 * CurSim);

  if RatioForDay[0].FNumSim = 0 then begin   // not Calculated yet for Ratio = 0
    StepM:= 1.1;
    StartM:= 2 / StepM;
    LastRatio:= -1;
    repeat
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
 FillAllRatio(Result);
 Result.FPercent:= APercent;
 for i:= 0 to 100 do begin
   k:= i * (MaxI div 100);
   Memo1.Lines.Add(Format('%d: %f ', [k, Result.RatioForDay[k].FCapital]));
 end;
end;

procedure TForm1.FillAllRatio(var ARatioDayArray: TRatioDayArray);
var
  i, K1, K2: integer;
  Step: real;

  function FindNotZero(FromIndex: integer): integer;
  var i: integer;
  begin
    i:= FromIndex;
    repeat
      Dec(i);
    until (not IsZero(ARatioDayArray.RatioForDay[i].FCapital)) or (i = 0);
    Result:= i;
  end;

begin
 try
  with ARatioDayArray do begin
    {if RatioForDay[100].FCapital > 0 then
      K1:= 100
    else
      K1:= 99;    }
    K1:= FindNotZero(MaxI + 1);
    if K1 = 0 then begin
      for i:= 0 to MaxI do begin
        RatioForDay[i].FCapital:= StartCapital * 1000; // RatioForDay[K1].FCapital * 10;
      end;
      Exit;
    end;
    for i:= K1 + 1 to MaxI do begin
      RatioForDay[i].FCapital:= StartCapital * 1000; // RatioForDay[K1].FCapital * 10;
    end;
    repeat
      K2:= FindNotZero(K1);
      if RatioForDay[K1].FCapital < RatioForDay[K2].FCapital then begin
        RatioForDay[K2].FCapital:= 0;
        Memo1.Lines.Add('Deleting wrong Capital.') ;
        //ShowMessage('Deleting wrong Capital.');
        Continue;
      end;
      if K1 - K2 > 1 then begin
        Step:= Power(RatioForDay[K1].FCapital / RatioForDay[K2].FCapital, 1 / (K1 - K2));
        for i:= K1 - 1 downto K2 + 1 do begin
          RatioForDay[i].FCapital:= RatioForDay[i + 1].FCapital / Step;
        end;
      end;
      K1:= K2;
    until K2 = 0;
  end;
 except
   Memo1.Lines.Add('Error in FillAllRatio...')
 end;
end ;

function TForm1.FindTableRatio(ACapital: real; DayLeft: integer; ATable: TTable): integer;
var
  i, Index, First, Last, Pivot: integer;
begin
  Index:= -1;
  for i:= 0 to High(ATable) do begin
    if CurTable[i].FDay = DayLeft then begin
      Index:= i;
      Break;
    end;
  end;
  if Index >= 0 then begin
    with ATable[Index] do begin
      if IsZero(RatioForDay[100].FCapital)  then
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

procedure TForm1.ButtonFillRatioClick(Sender: TObject);
begin
  GetAllParameter;
  FillRatioForDays(NumDay, StepDay, MyBankr);
end;
       {
procedure TForm1.ButtonFindAdvClick(Sender: TObject);
var
  BestRatio: integer;
begin
  GetAllParameter;
  BestRatio:= FindBestRatioAdv(StartCapital, Rasxod, NumDay, NumSim, StepDay);
end;
        }
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
      GetAllParameter;
      SaveIniFile;
      Correction:= false;
      FillTableThread := TFillTableThread.Create(false);
    end;
  end;
end;

procedure TForm1.FillAllTableProcedure();
begin
  ProgressBar.Position := 0;
  //Memo1.Lines.BeginUpdate;
  CurTableFileName:= SetTableName;
  FillAllTable(TotalDay, StepDay);
  //Memo1.Lines.EndUpdate;
  ProgressBar.Position := ProgressBar.Max;
  SaveTable;
  SaveIniFile;
end;

procedure TForm1.FillAllTable(ANumDay, AStepDay: integer);
var
  i, k, m, NumBlock, StartRatio: integer;
  Percent, NewPercent, StartPercent, DiffPercent, FinalRisk, StepPercent: real;
label
  ExitUntil;
begin
  if NumAlgo = 0 then begin
    Memo1.Lines.Add(Format('Not need create table for Biff 1.0 ', []));
    Exit;
  end;
  NumBlock:= ANumDay div AStepDay;
  ProgressBar.Step := ProgressBar.Max div NumBlock;
  SetLength(CurTable, NumBlock);
    if not IsZero(FUPROPerc) then           // Calculate StartRatio for both Biff 3 and Biff 2
      StartRatio:= Round(FUPROPerc *  MaxI)
    else
      StartRatio:= FindBestRatio(StartCapital, Rasxod, MyBankr, NumDay, NumSim);  // Biff 1

  if NumAlgo = 3 then begin
    StartTimer(true, 'Creating Table by Biff 3.0...');
   { if not IsZero(FUPROPerc) then
      StartRatio:= Round(FUPROPerc *  MaxI)
    else
      StartRatio:= FindBestRatio(StartCapital, Rasxod, MyBankr, NumDay, NumSim);  // Biff 1
    }
    Memo1.Lines.Add(Format('Biff 1 Start Ratio:: %f ', [StartRatio * 100 / MaxI]));
    Percent:= MyBankr;
    DiffPercent:= 0;
    for i:= NumBlock - 1 downto 1 do begin
      StatusBar1.Panels[1].Text:= Format('Calculating table for days: %d / %d ', [(i) * AStepDay, ANumDay]);
      StartPercent:= Percent;
      if DiffPercent >= Percent then
        Percent:= Percent / 2
      else
        Percent:= Percent - DiffPercent;
      CurTable[i-1]:= FillRatioForDays((i) * AStepDay, AStepDay, Percent);
      //for k:= 1 to 2 do begin
      k:= 0;
      repeat
        Inc(k);
        m:= 0;
        repeat
          Memo1.Lines.Add(Format('Correction %d _ %d', [k, m]));
          NewPercent:= CorrectPerc(StartCapital / Rasxod, Percent, StartRatio,
                      NumDay, i * StepDay, StepDay, CurTable, FinalRisk);  // New correct percent
          if (m = 0) and (FinalRisk < MyBankr) and (Abs(FinalRisk - MyBankr) < MyBankr * 0.01) then begin
            Memo1.Lines.Add(Format('End Correction, Final Risk =  %f', [FinalRisk * 100]));
            Goto ExitUntil;
          end;
          if NewPercent < 0 then begin
            Percent:= Percent * 0.95;
            Inc(m);
          end;
        until NewPercent > 0;
        Percent:= NewPercent;
        CurTable[i-1]:= FillRatioForDays((i) * AStepDay, AStepDay, Percent);
      //end;
      until k > 9;
      Memo1.Lines.Add(Format('End Correction on 10 iterration, Final Risk =  %f', [FinalRisk * 100]));
      ExitUntil:
      DiffPercent:= StartPercent - Percent;
      //CorrectPerc(StartCapital, Percent, StartRatio, NumDay, i * StepDay, StepDay, CurTable, FinalRisk);  // New correct percent

      SaveTable;
      PostMessage(Form1.Handle, WM_UPDATE_PB, 0, 0);
    end;
  end else begin
   StartTimer(true, 'Creating Table by Biff 2.0...');
   Memo1.Lines.Add(Format('Biff 1 Start Ratio:: %f ', [StartRatio * 100 / MaxI]));
 //  FindTablePercent(StartCapital, Rasxod, MyBankr, StartRatio, NumDay, NumSim, StepDay, CurTable);
   StepPercent:= MyBankr / NumBlock;
   for i:= 0 to NumBlock - 1 do begin
    StatusBar1.Panels[1].Text:= Format('Calculating table for days: %d / %d ', [(i+1) * AStepDay, ANumDay]);
    CurTable[i]:= FillRatioForDays((i+1) * AStepDay, AStepDay, (i+1) * StepPercent);
//    CurTable[i]:= FillRatioForDays((i+1) * AStepDay, AStepDay,CurTable[i].FPercent);

    SaveTable;
    PostMessage(Form1.Handle, WM_UPDATE_PB, 0, 0);
   end;
  end;
 StatusBar1.Panels[1].Text:='Ready';
 Timer1.Enabled:= false;
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
//  AddStr('N', FloatToStr(NumSim));
  AddStr('N', Format('%d' , [NumSim]));
  AddStr('R', Format('%.1f', [MyBankr * 100]));
  AddStr('B', Format('%d' , [UPROBankr]));
  AddStr('D', Format('%d' , [TotalDay]));
  AddStr('C', Format('%d' , [StepDay]));
  AddStr('A', Format('%d' , [NumAlgo]));

 // AddBool('A', Advanced);
  AddBool('E', IsInflation);
  TotalStr:= TotalStr + FormatDateTime('yyyy-mm-dd-hh-nn-ss', Now);
  TotalStr:= TotalStr + '.biff';
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
  AddStr('R', Format('%.1f', [MyBankr * 100]));
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
var i: integer;
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

procedure TForm1.ConvertTableToTxt;
var
  i, k, StartLine: integer;
  CurStr: string;
  FileStr: string;
  F: Textfile;
begin
  StartLine:= Memo1.Lines.Count;
  with CurTable[0] do begin
    CurStr:= Format('Risk of Ruin: %f, UPRO Daily Fail 1 / %d ', [FMyBankr * 100, FUPROBankr]);
    Memo1.Lines.Add(CurStr);
  end;
    CurStr:= 'Days:' + #9;
    for k:= 0 to High(CurTable) do begin
      with CurTable[k] do begin
        CurStr:= CurStr + Format('%7d' + #9, [FDay]);
      end;
    end;
    Memo1.Lines.Add(CurStr);
    CurStr:= 'Percent:' + #9;
    for k:= 0 to High(CurTable) do begin
      with CurTable[k] do begin
        CurStr:= CurStr + Format('%7.3f' + #9, [FPercent * 100]);
      end;
    end;
    Memo1.Lines.Add(CurStr);

  for i:= 0 to 100 do begin
    CurStr:= IntToStr(i) + '.' + #9;
    for k:= 0 to High(CurTable) do begin
      with CurTable[k].RatioForDay[i * MAxI div 100] do begin
        CurStr:= CurStr + Format('%7.0f' + #9, [FCapital]);
      end;
    end;
    Memo1.Lines.Add(CurStr);
  end;

  FileStr:= CurTableFileName + '.txt';
  AssignFile(F, FileStr);
  Rewrite(F);
  for i:= StartLine to Memo1.Lines.Count - 1 do begin
    Writeln(F, Memo1.Lines[i]);
  end;
  CloseFile(F);
end;

procedure TForm1.ButtonConvertTableClick(Sender: TObject);
begin
  ConvertTableToTxt;
end;

function TForm1.CorrectPerc(ACapital, APercent: real; ARatio, ANumDay, ACurDay, AStepDay: integer;
                             var ATable: TTable; var AFinalRisk: real): real;  // New correct percent
var
  N: integer; //InnerNumSim, CurRatio, First, Last: integer;
  StartRatioArray: TRatioArray;
  StartTime: TDateTime;
  X, Y, R0Perc, R100Perc, DeltaR: real;

procedure CalcNumBankruptcy(AInnerNumSim, ACurRatio: integer);
var i, k, y, Index, NumBlock, CurBlock: integer;
  TotalCapital, UPROPart: real;
  CurVOOPerc, CurUPROPerc: real;
  label ZeroCapital;
begin
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
        CurUPROPerc:= FindTableRatio(TotalCapital, y * AStepDay, ATable) / MaxI;
        CurVOOPerc:= 1 - CurUPROPerc;
      end;
      if y = CurBlock then begin
        If IsZero(CurUPROPerc) then  // Ratio = 0
          Inc(R0)
        else if IsZero(CurUPROPerc - 1) then  // // Ratio = 100
          Inc(R100);
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
  // Total_EV:= Total_EV + TotalCapital;     if need EV
  Total:= Total + AInnerNumSim;
  FRatio:= Bankruptcy / Total;
 // Memo1.Lines.Add(Format('Ratio: %d , %f ', [ACurRatio, FRatio * 100]));
 end;
end;

begin
  StartTimer(false, Format('Correcting table for %d / %d days ...', [ACurDay, ANumDay]));
  StartRatioArray:= ZeroRatioArray;
  N:= Length(PriceData);
  StartTime:= Now;
 // InnerNumSim:= ANumSim div 5;
  CalcNumBankruptcy(NumSim, ARatio);
  with StartRatioArray[ARatio] do begin
    R0Perc:= R0 / Total;
    R100Perc:= R100 / Total;
    DeltaR:= R0Perc + R100Perc;
    if IsZero(DeltaR) then begin
      X:= 0;
      Y:= APercent;
    end else begin
      X:= (FRatio - (1 - DeltaR) * APercent) / DeltaR;
      Y:= (MyBankr{APercent} - DeltaR * X) / (1 - DeltaR);
    end;
    AFinalRisk:= FRatio;
    Memo1.Lines.Add(Format('R0 = %f, R100 = %f, FinalRisk = %f ',
                           [R0Perc * 100, R100Perc * 100, FRatio * 100]));
    Memo1.Lines.Add(Format('Start Percent = %f, X = %f, Y = %f ', [APercent *100, X *100, Y * 100]));
                           
  end;
  Result:= Y;
end;

procedure TForm1.CheckBoxInflationClick(Sender: TObject);
begin
  IsInflation:= CheckBoxInflation.Checked;
  OpenPriceFile;
end;

procedure TForm1.RadioGroupBiffClick(Sender: TObject);
begin
  NumAlgo:= RadioGroupBiff.ItemIndex;
end;

procedure TForm1.EnableControls(enable: bool);
begin
  if IsClosing then
    Exit;
  Form1.ButtonBestRatio.Enabled := enable;
  Form1.ButtonFillTable.Enabled := enable;
  Form1.ButtonUPRO.Enabled := enable;
end;

procedure TForm1.WMUpdatePB(var msg: TMessage);
begin
  ProgressBar.StepIt;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IsClosing := true;
end;

end.

