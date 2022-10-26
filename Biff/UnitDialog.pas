unit UnitDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFormDialog = class(TForm)
    ButtonOk: TButton;
    ButtonCancel: TButton;
    Label4: TLabel;
    EditSims: TEdit;
    Label6: TLabel;
    EditMyBankr: TEdit;
    CheckBoxBankruptcy: TCheckBox;
    EditUPROBankr: TEdit;
    CheckBoxAdv: TCheckBox;
    Panel1: TPanel;
    Label1: TLabel;
    Label5: TLabel;
    Label2: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    EditTotalDay: TEdit;
    EditStepDay: TEdit;
    CheckBoxInflation: TCheckBox;
    RadioGroupBiff: TRadioGroup;
    CheckBoxUseCurTable: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormDialog: TFormDialog;

implementation

uses
  Biff_Main;

  {$R *.dfm}


end.
