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

  TArrayReal = array of real;    // for sort array of Total_EV

  TArrVolGroup = array[0..22] of real;

  TParameter = record
    ScreenName: string;
    DateOfBirth: TDate;
    TargetRisk, RiskWithDeath, TodayRisk: real;
    StocksCapital, GoldCapital, TotalCapital: real;
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
  public
    constructor Create();
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

 // procedure FindBestRatioProcedure();
  procedure GetAllProfiles;
  procedure MemoLinesAdd(AText: string);

implementation

uses
  Biff_Main, NewUser;

//================================================
constructor TBestRatioThread.Create();
begin
  inherited create(false);
  FreeOnTerminate := true;
  Priority := tpNormal;
end;

procedure TBestRatioThread.Execute;
begin
  with Form1 do begin  // Old Form1
    //EnableControls(false);
    FindBestRatioProcedure();
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
  {
procedure FindBestRatioProcedure();
var
  i, BestRatio: integer;
begin
  with Form1 do begin
  if CurForm is TFormNewUser then begin
    with TFormNewUser(CurForm).Memo1 do begin
      //GetParameter;
      Lines.Add('Start...');
      OrigArrVolGroup:= CreateArrVolGroup(MyBankr);
      Memo1.Lines.Add('Original Array of Volatility Group:');
      ShowArrVolGroup(OrigArrVolGroup);
      BestRatio:= FindBestRatio_12DayVol(StartCapital, Rasxod, MyBankr, NumDay, NumSim);
      BestRatio:= BestRatio - Round(0.5 * MaxI);
      Lines.Add('Final Array of Volatility Group:');
      OrigArrVolGroup:= ArrVolGroup;
      ShowArrVolGroup(ArrVolGroup);
  //SaveLog;
    end;
  end;
  end;
end;
    }
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
      TFormNewUser(CurForm).Memo1.Lines.Add(AText);
    end else if CurForm is TForm1 then begin
      TForm1(CurForm).Memo1.Lines.Add(AText);
    end;
  end;
end;

end.
