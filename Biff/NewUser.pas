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
    ButtonCalcRisk: TButton;
    ButtonGoMainForm: TButton;
    Label10: TLabel;
    EditTodayDayLeft: TEdit;
    CheckBoxShowCalculating: TCheckBox;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    ButtonAddUser: TButton;
    procedure ButtonAddNewUserClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBoxAdvancedClick(Sender: TObject);
    procedure ButtonCalcRiskClick(Sender: TObject);
    procedure ButtonGoMainFormClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure NumericEditKeyPress(Sender: TObject; var Key: Char);
    procedure FloatEditKeyPress(Sender: TObject; var Key: Char);
    procedure ButtonAddUserClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function GetNewUserParameter: boolean;
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
  GetNewUserParameter;
  MessageOnQuitNewUser:= 'Do you really want to close?'; 
end;


procedure TFormNewUser.CheckBoxAdvancedClick(Sender: TObject);
var IsEnabled: boolean;
begin
  IsEnabled:= CheckBoxAdvanced.Checked;
  EditNumSim.Enabled:= IsEnabled;
  EditUPROBankr.Enabled:= IsEnabled;
  CheckBoxBankruptcy.Enabled:= IsEnabled;
end;

function TFormNewUser.GetNewUserParameter: boolean;
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
    EditBusinessDaysLeft.Text:= IntToStr(BusinessDaysLeft);
    EditTodayDayLeft.Text:= IntToStr(TodayDayLeft);
    CurProfile:= ScreenName;
    Result:= false;
    if TodayDayLeft < 0 then begin
      TodayDayLeft:= 0;
      MemoLinesAdd('You will never be broke.');
      MemoLinesAdd('Your gold assets are enough for the rest of your life.');
      MemoLinesAdd('Invest all your stock money to UPRO and have fun.');
      MemoLinesAdd('YOU DON''T NEED BIFF.');
    end else if TargetRisk < 0.01 then begin
      MemoLinesAdd('Your Risk is too small.');
      MemoLinesAdd('Your Risk should be beetween 1% - 99%');
    end else if TargetRisk > 0.99 then begin
      MemoLinesAdd('Your Risk is too big.');
      MemoLinesAdd('Your Risk should be beetween 1% - 99%');
    end else begin
      Result:= true;
    end;
  end;

end;

procedure TFormNewUser.ButtonAddUserClick(Sender: TObject);
var i: integer;
begin
  if not CheckEmpty(EditScreenName, 'Screen Name') then Exit;
  if not CheckEmptyAndLimit(EditTargetRisk, 'Target Risk') then Exit;
  if not CheckEmptyAndLimit(EditTargetRisk, 'Target Risk') then Exit;
  if not CheckEmptyAndLimit(EditStocks, 'Stocks') then Exit;
  if not CheckEmptyAndLimit(EditGold, 'Gold', -1) then Exit;
  if not CheckEmptyAndLimit(EditMonthlyExpences, 'Monthly Expences') then Exit;
  if not CheckEmptyAndLimit(EditNumSim, 'Number of Simulations', 999) then Exit;
  if not CheckEmptyAndLimit(EditUPROBankr, 'UPRO Daily Fail') then Exit;

  MessageOnQuitNewUser:= 'Do you really want to close?'; 
  for i:= 0 to AllProfiles.Count - 1 do begin
    if Allprofiles[i] = EditScreenName.Text then begin
      MessageDlg('Your screenname already exists. Please choose another.' , mtError, [mbYes], 0);
      Exit;
    end;
  end;

  CurForm:= Self;
  //ForceDirectories(ExtractFilePath(GetModuleName(0)) + '\Profiles\' + EditScreenName.Text);

  if not GetNewUserParameter then Exit;

  ButtonAddUser.Enabled:= false;
  EditScreenName.Enabled:= false;
  DateTimePicker1.Enabled:= false;
  EditTargetRisk.Enabled:= false;
  EditStocks.Enabled:= false;
  EditGold.Enabled:= false;
  EditMonthlyExpences.Enabled:= false;
  CheckBoxAdvanced.Enabled:= false;
  EditNumSim.Enabled:= false;
  EditUPROBankr.Enabled:= false;
  CheckBoxBankruptcy.Enabled:= false;

  CalculationIsRuning := true;
  TCaclulationThread.Create(CaseDailyRisk);
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
  if GetNewUserParameter then begin
    SaveIniFile;
    SaveProfileIniFile;
    ButtonCalcRisk.Enabled:= true
  end else begin
    ButtonCalcRisk.Enabled:= false;
  end;
end;

procedure TFormNewUser.ButtonCalcRiskClick(Sender: TObject);
begin
  if not GetNewUserParameter then Exit;
  CalculationIsRuning := true;
  CurForm:= Self;
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
  CanClose := false;
  //IsClosing:= MessageDlg('Do you really want to close?', mtCustom, [mbYes, mbNo], 0) = mrYes;
  IsClosing:= MessageDlg(MessageOnQuitNewUser, mtCustom, [mbYes, mbNo], 0) = mrYes;

  if (not IsClosing) then
    Exit;

  if (CurForm <> nil) and (not CalculationIsRuning) then begin
    SaveIniFile;
    SaveProfileIniFile;
  end;

  Terminating := IsClosing;

  if Assigned(Form1) then  begin
    IsClosing:= true;
    Form1.Close;
  end;
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
