program biff;

uses
  Forms,
  Biff_Main in 'Biff_Main.pas' {Form1},
  profile in 'profile.pas' {FormProfile},
  variables in 'variables.pas',
  New_Main in 'New_Main.pas' {Form3},
  NewUser in 'NewUser.pas' {FormNewUser},
  Login in 'Login.pas' {FormLogin};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormNewUser, FormNewUser);
  Application.ShowMainForm:= false;
  Application.Run;
end.
