program biff;

uses
  Forms,
  Biff_Main in 'Biff_Main.pas' {Form1},
  UnitDialog in 'UnitDialog.pas' {FormDialog},
  profile in 'profile.pas' {FormProfile};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormProfile, FormProfile);
  Application.CreateForm(TFormDialog, FormDialog);
  Application.Run;
end.
