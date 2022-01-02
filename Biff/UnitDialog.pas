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
    procedure CopyParameterFromMain;
    procedure CopyParameterToMain;
  end;

var
  FormDialog: TFormDialog;

implementation

uses
  Biff_Main;

  {$R *.dfm}

procedure TFormDialog.CopyParameterFromMain;
begin
  EditSims.Text:= Form1.EditSims.Text;
  EditMyBankr.Text:= Form1.EditMyBankr.Text;
  EditUPROBankr.Text:= Form1.EditUPROBankr.Text;
  EditTotalDay.Text:= Form1.EditTotalDay.Text;
  EditStepDay.Text:= Form1.EditStepDay.Text;
  CheckBoxAdv.Checked:= Form1.CheckBoxAdv.Checked;
  CheckBoxInflation.Checked:= Form1.CheckBoxInflation.Checked;
  RadioGroupBiff.ItemIndex:= Form1.RadioGroupBiff.ItemIndex;
end;

procedure TFormDialog.CopyParameterToMain;
begin
  Form1.EditSims.Text:= EditSims.Text;
  Form1.EditMyBankr.Text:= EditMyBankr.Text;
  Form1.EditUPROBankr.Text:= EditUPROBankr.Text;
  Form1.EditTotalDay.Text:= EditTotalDay.Text;
  Form1.EditStepDay.Text:= EditStepDay.Text;
  Form1.CheckBoxAdv.Checked:= CheckBoxAdv.Checked;
  Form1.CheckBoxInflation.Checked:= CheckBoxInflation.Checked;
  Form1.RadioGroupBiff.ItemIndex:= RadioGroupBiff.ItemIndex;
end;


end.
