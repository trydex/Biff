unit NewUser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, variables, ExtCtrls;

type
  TFormNewUser = class(TForm)
    Label1: TLabel;
    EditStocks: TEdit;
    Label2: TLabel;
    EditMonthlyExpences: TEdit;
    EditBusinessDaysLeft: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    EditNumSim: TEdit;
    Label6: TLabel;
    EditTargetRisk: TEdit;
    CheckBoxBankruptcy: TCheckBox;
    EditUPROBankr: TEdit;
    Label5: TLabel;
    EditScreenName: TEdit;
    ButtonAddNewUser: TButton;
    Memo1: TMemo;
    Label7: TLabel;
    DateTimePicker1: TDateTimePicker;
    Label8: TLabel;
    EditGold: TEdit;
    Label9: TLabel;
    EditTotalBankroll: TEdit;
    CheckBoxAdvanced: TCheckBox;
    ButtonCalculateRisk: TButton;
    ButtonGoMainForm: TButton;
    Label10: TLabel;
    EditTodayDayLeft: TEdit;
    CheckBoxShowCalculating: TCheckBox;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    procedure ButtonAddNewUserClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBoxAdvancedClick(Sender: TObject);
    procedure ButtonCalculateRiskClick(Sender: TObject);
    procedure ButtonGoMainFormClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure NumericEditKeyPress(Sender: TObject; var Key: Char);
    procedure FloatEditKeyPress(Sender: TObject; var Key: Char);
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


procedure TFormNewUser.FormCreate(Sender: TObject);
begin
  DateTimePicker1.MaxDate:= Date - Round(15 * 365.25);
  DateTimePicker1.MinDate:= Date - Round(84 * 365.25);
  DateTimePicker1.Date:= Date - Round(54 * 365.25);
  CurForm:= Self;
  LoadIniFile;
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
    TodayRisk:= TargetRisk;
    StocksCapital:= StrToFloatDef(EditStocks.Text, 0);
    GoldCapital:= StrToFloatDef(EditGold.Text, 0);
    //TotalCapital:= StrToFloatDef(EditTotalCapital.Text, 0);
    TotalBankroll:= StocksCapital + GoldCapital;
    EditTotalBankroll.Text:= FloatToStr(TotalBankroll);
    MonthlyExpences:= StrToFloatDef(EditMonthlyExpences.Text, 0);
    AdvancedUser:= CheckBoxAdvanced.Checked;
    FNumSim:= StrToIntDef(EditNumSim.Text, 25000);
    IsBankruptcy:= CheckBoxBankruptcy.Checked;
    UPROBankr:= StrToIntDef(EditUPROBankr.Text, 50000);
    CalculateDayLeft(Date);
    {
    DailyExpences:= MonthlyExpences / 20.933;   // Check it !!!
    BusinessDaysLeft:= Trunc(DateofBirth + 85 * 365.25)  - Trunc(Date);
    BusinessDaysLeft:= Round(BusinessDaysLeft * 251.2 / 365.25);
    TodayDayLeft:= BusinessDaysLeft - Round(GoldCapital / DailyExpences);
   }
    EditBusinessDaysLeft.Text:= IntToStr(BusinessDaysLeft);
    if TodayDayLeft < 0 then begin
      TodayDayLeft:= 0;
      MemoLinesAdd('You will never be broke.');
      MemoLinesAdd('Your gold assets are enough for the rest of your life.');
      MemoLinesAdd('Invest all your stock money to UPRO and have fun.');
      MemoLinesAdd('YOU DON''T NEED BIFF.');
    end;
    EditTodayDayLeft.Text:= IntToStr(TodayDayLeft);
    CurProfile:= ScreenName;
  end;

end;

procedure TFormNewUser.ButtonAddNewUserClick(Sender: TObject);
var i: integer;
begin
  for i:= 0 to AllProfiles.Count - 1 do begin
    if Allprofiles[i] = EditScreenName.Text then begin
      MessageDlg('Your screenname already exists. Please choose another.' , mtError, [mbYes], 0);
      Exit;
    end;
  end;

  CurForm:= Self;
  ForceDirectories(ExtractFilePath(GetModuleName(0)) + '\Profiles\' + EditScreenName.Text);
  GetParameter;
  SaveIniFile;
  SaveProfileIniFile;
  if CurParameter.TodayDayLeft > 0 then
    ButtonCalculateRisk.Enabled:= true
  else
    ButtonCalculateRisk.Enabled:= false;
end;

procedure TFormNewUser.ButtonCalculateRiskClick(Sender: TObject);
begin
  GetParameter;
  CurForm:= Self;
  with CurParameter do begin
    Memo1.Lines.Add('');
    Memo1.Lines.Add('Calculate min risk for your parameter ...');
    TodayRisk:= TargetRisk;
    Form1.StartTimer(true, 'Calculate min risk for your parameter ...');
    if Form1.CalculateRisk(StocksCapital, DailyExpences, TodayRisk, TodayDayLeft, FNumSim * 4) then begin
      Memo1.Lines.Add('');
      Memo1.Lines.Add('Calculating is finished.');
      Form1.StopTimer('Calculating is finished.');
      Exit;
    end;
  end;
  TCaclulationThread.Create(CaseDailyRisk);
end;

procedure TFormNewUser.ButtonGoMainFormClick(Sender: TObject);
begin
  CurForm:= Self;
  SaveIniFile;
  CurForm:= Form1;
  LoadIniFile;
  Form1.SetParameter;
  Form1.GetMainParameter;
  Form1.Visible:= true;
  Self.Visible:= false;
end;

procedure TFormNewUser.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if CurForm <> nil then begin
    SaveIniFile;
  //  CurForm:= Self;
    SaveProfileIniFile;
  end;
  if Assigned(Form1) then  begin
    Form1.IsClosing:= true;
    Form1.Close;
  end;

end;

procedure TFormNewUser.FormDestroy(Sender: TObject);
begin
//  SaveIniFile;
//  SaveProfileIniFile;
end;

procedure TFormNewUser.NumericEditKeyPress(Sender: TObject; var Key: Char);
begin
  Form1.NumericEditKeyPress(Sender,  Key);
end;

procedure TFormNewUser.FloatEditKeyPress(Sender: TObject; var Key: Char);
begin
  Form1.FloatEditKeyPress(Sender, Key);
end;

end.
