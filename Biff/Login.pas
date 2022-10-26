unit Login;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, variables;

type
  TFormLogin = class(TForm)
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormLogin: TFormLogin;

implementation

{$R *.dfm}

procedure TFormLogin.FormCreate(Sender: TObject);
var i: integer;
begin
  for i:= 0 to AllProfiles.Count - 1 do begin
    ListBox1.Items.Add(AllProfiles[i]);
  end;
  ListBox1.ItemIndex:= 0;
end;

end.
