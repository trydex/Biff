program biff;

uses
  Forms,
  Biff_Main in 'Biff_Main.pas' {Form1},
  UnitDialog in 'UnitDialog.pas' {FormDialog};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormDialog, FormDialog);
  Application.Run;
end.
