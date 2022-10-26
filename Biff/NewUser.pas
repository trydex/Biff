unit NewUser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, variables;

type
  TFormNewUser = class(TForm)
    Label1: TLabel;
    EditStocks: TEdit;
    Label2: TLabel;
    EditMonthlyExpences: TEdit;
    EditDaysLeft: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    EditNumSim: TEdit;
    Label6: TLabel;
    EditTargetRisk: TEdit;
    CheckBoxBankruptcy: TCheckBox;
    EditUPROBankr: TEdit;
    Label5: TLabel;
    EditScreenName: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    Label7: TLabel;
    DateTimePicker1: TDateTimePicker;
    Label8: TLabel;
    EditGold: TEdit;
    Label9: TLabel;
    EditTotalCapital: TEdit;
    CheckBoxAdvanced: TCheckBox;
    ButtonRefresh: TButton;
    ButtoncalculateRisk: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBoxAdvancedClick(Sender: TObject);
    procedure ButtonRefreshClick(Sender: TObject);
    procedure ButtoncalculateRiskClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GetParameter;
  end;

var
  FormNewUser: TFormNewUser;

implementation

uses Biff_Main;

{$R *.dfm}

procedure TFormNewUser.Button1Click(Sender: TObject);
begin
  ForceDirectories(ExtractFilePath(GetModuleName(0)) + '\Profiles\' + EditScreenName.Text);
end;

procedure TFormNewUser.FormCreate(Sender: TObject);
begin
  DateTimePicker1.MaxDate:= Date - Round(15 * 365.25);
  DateTimePicker1.MinDate:= Date - Round(84 * 365.25);
  //DateTimePicker1.Date:= Date - Round(8 * 365.25);
  GetParameter;
end;


procedure TFormNewUser.CheckBoxAdvancedClick(Sender: TObject);
var IsEnabled: boolean;
begin
  IsEnabled:= CheckBoxAdvanced.Checked;
  EditNumSim.Enabled:= IsEnabled;
  EditUPROBankr.Enabled:= IsEnabled;
  CheckBoxBankruptcy.Enabled:= IsEnabled;
end;

procedure TFormNewUser.GetParameter;
begin
  with CurParameter do begin
    ScreenName:= EditScreenName.Text;
    DateofBirth:= DateTimePicker1.Date;
    TargetRisk:= StrToFloatDef(EditTargetRisk.Text, 5) / 100;
    StocksCapital:= StrToFloatDef(EditStocks.Text, 0);
    GoldCapital:= StrToFloatDef(EditGold.Text, 0);
    //TotalCapital:= StrToFloatDef(EditTotalCapital.Text, 0);
    TotalCapital:= StocksCapital + GoldCapital;
    EditTotalCapital.Text:= FloatToStr(TotalCapital);
    MonthlyExpences:= StrToFloatDef(EditMonthlyExpences.Text, 0);
    AdvancedUser:= CheckBoxAdvanced.Checked;
    FNumSim:= StrToIntDef(EditNumSim.Text, 25000);
    IsBankruptcy:= CheckBoxBankruptcy.Checked;
    UPROBankr:= StrToIntDef(EditUPROBankr.Text, 50000);

    DailyExpences:= MonthlyExpences / 20.933;   // Check it !!!
    BusinessDaysLeft:= Trunc(DateofBirth + 85 * 365.25)  - Trunc(Date);
    BusinessDaysLeft:= Round(BusinessDaysLeft * 251.2 / 365.25);
    TodayDayLeft:= BusinessDaysLeft - Round(GoldCapital / DailyExpences);
    EditDaysLeft.Text:= IntToStr(TodayDayLeft);
  end;

end;

procedure TFormNewUser.ButtonRefreshClick(Sender: TObject);
begin
  GetParameter;
end;

procedure TFormNewUser.ButtoncalculateRiskClick(Sender: TObject);
begin
  with Form1, CurParameter do begin
    GetParameter;
    CurForm:= Self;
    TodayRisk:= TargetRisk;
    MemoLinesAdd(Format('TodayRisk = %f',[TodayRisk * 100]));
    BestRatioThread := TBestRatioThread.Create();    // first iteration with TargetRisk
    CalculateDayRisk(StocksCapital, DailyExpences, TargetRisk, TodayDayLeft, FNumSim * 10); // for find TodayRisk
    MemoLinesAdd(Format('TodayRisk = %f',[TodayRisk * 100]));
    BestRatioThread := TBestRatioThread.Create();    // second iteration with TodayRisk
    CreateTableDayRisk(StocksCapital, DailyExpences, TodayRisk, TodayDayLeft, FNumSim * 10);
  end;
end;

procedure TFormNewUser.Button2Click(Sender: TObject);
begin
  GetParameter;
  CurForm:= Self;
  with CurParameter do begin
    Form1.CalculateDayRisk(StocksCapital, DailyExpences, TargetRisk, TodayDayLeft, FNumSim);
 // CalculateEV;
  //SaveLog;
  end;

end;

end.
