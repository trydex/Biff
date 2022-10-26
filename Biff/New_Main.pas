unit New_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Math, INIFiles, ComCtrls, ExtCtrls, UnitDialog, Utils, StrUtils,
  profile, variables, NewUser, Login ;

type
  TForm3 = class(TForm)
    ButtonBestRatio: TButton;
    Label1: TLabel;
    EditCapital: TEdit;
    Label2: TLabel;
    Editrasxod: TEdit;
    Label3: TLabel;
    EditDays: TEdit;
    Label4: TLabel;
    EditSims: TEdit;
    Label6: TLabel;
    EditMyBankr: TEdit;
    CheckBoxBankruptcy: TCheckBox;
    EditUPROBankr: TEdit;
    StatusBar1: TStatusBar;
    Memo1: TMemo;
    ProgressBar: TProgressBar;
    Button1: TButton;
    procedure ButtonBestRatioClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    BestRatioThread: TBestRatioThread;
    CalculationIsRuning: bool;
    MaxThreads: integer;
    TotalSteps: integer;
    TotalStepsTime: real;
    StepsThrottling: Cardinal;
    Version: string;
    procedure WMUpdatePB(var msg: TMessage); message WM_UPDATE_PB;

  public
    { Public declarations }
    PriceData: TArrPriceData;
    PriceData2Dim: array of TArrPriceData;
    StartCapital: real;
    Rasxod: real;
    NumDay: integer;
    NumSim: int64;
    MyBankr: real;
    UPROBankr: integer;
    TotalDay: integer;
    IsBankruptcy: boolean;
    IsInflation: boolean;
    RatioArray: TRatioArray;
    ZeroRatioArray: TRatioArray;
    LogFileName: string;
    NumVolGroup: integer;     // temporally
    ArrVolGroup: TArrVolGroup;  //array[0..22] of real;
    OrigArrVolGroup: TArrVolGroup;
    ArrProbDeath: array of real;
    IsClosing: bool;

  end;

var
  Form3: TForm3;
  Utils: TUtils;
  Terminating : bool;


implementation

uses Biff_Main;


{$R *.dfm}

procedure TForm3.FormCreate(Sender: TObject);
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
    FormNewUser.ShowModal;

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
 {
  LoadIniFile;
  GetAllParameter;
  if IsInflation = false then
    OpenPriceFile; // load price file only if it wasn't loaded before
  //LoadTable; // uncomment to auto-load a table on start
  GetProbDeath;
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
  }
end;


procedure TForm3.WMUpdatePB(var msg: TMessage);
begin
  ProgressBar.StepIt;
end;

procedure TForm3.ButtonBestRatioClick(Sender: TObject);
begin
  //ProgressBar.Position := 0;
  BestRatioThread := TBestRatioThread.Create(CaseSomeNameForm3);
end;



procedure TForm3.Button1Click(Sender: TObject);
begin
  GetAllProfiles;
end;

procedure TForm3.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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

procedure TForm3.FormDestroy(Sender: TObject);
begin
//  SaveLog;
//  SaveIniFile;
end;

end.
