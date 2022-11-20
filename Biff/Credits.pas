unit Credits;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, shellapi;

type
  TFormCredits = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LabelMercator: TLabel;
    LabelMercatorsSite: TLabel;
    LabelGalax: TLabel;
    LabelGalaxSite: TLabel;
    LabelProoshift: TLabel;
    LabelElovution: TLabel;
    LabelGalax2: TLabel;
    procedure LabelMercatorClick(Sender: TObject);
    procedure LabelMercatorsSiteClick(Sender: TObject);
    procedure LabelGalaxClick(Sender: TObject);
    procedure LabelGalaxSiteClick(Sender: TObject);
    procedure LabelProoshiftClick(Sender: TObject);
    procedure LabelElovutionClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormCredits: TFormCredits;

implementation

{$R *.dfm}

procedure TFormCredits.LabelMercatorClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('https://www.gipsyteam.ru/profile/mercator'), '', '', SW_SHOWNORMAL);
end;

procedure TFormCredits.LabelMercatorsSiteClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('https://forum.gipsyteam.ru/index.php?viewtopic=80577'), '', '', SW_SHOWNORMAL);
end;

procedure TFormCredits.LabelGalaxClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('https://www.gipsyteam.ru/profile/galax'), '', '', SW_SHOWNORMAL);
end;

procedure TFormCredits.LabelGalaxSiteClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('https://forum.gipsyteam.ru/index.php?viewtopic=65198'), '', '', SW_SHOWNORMAL);
end;

procedure TFormCredits.LabelProoshiftClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('https://www.gipsyteam.ru/profile/prooshift'), '', '', SW_SHOWNORMAL);
end;

procedure TFormCredits.LabelElovutionClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('https://www.gipsyteam.ru/profile/3voluti0n'), '', '', SW_SHOWNORMAL);
end;

end.
