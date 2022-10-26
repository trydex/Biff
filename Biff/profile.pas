unit profile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, variables;

type
  TFormProfile = class(TForm)
    ButtonNewUser: TButton;
    ButtonLogin: TButton;
    procedure ButtonLoginClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormProfile: TFormProfile;

implementation

uses
  Biff_Main;


{$R *.dfm}

procedure TFormProfile.ButtonLoginClick(Sender: TObject);
begin
//  Form1.Visible:= true;
//  FormProfile.Visible:= false;
end;

procedure TFormProfile.FormCreate(Sender: TObject);
begin
  if AllProfiles.Count = 0 then
    ButtonLogin.Enabled:= false
  else
    ButtonLogin.Enabled:= true;

end;

end.
