program biff;

uses
  Forms,
  Biff_Main in 'Biff_Main.pas' {Form1},
  profile in 'profile.pas' {FormProfile},
  variables in 'variables.pas',
  NewUser in 'NewUser.pas' {FormNewUser},
  Login in 'Login.pas' {FormLogin},
  Utils in 'Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.ShowMainForm:= false;
  Application.Run;
end.
