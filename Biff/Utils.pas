unit Utils;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Dialogs;

const
  BiffShortDateFormat = 'dd.mm.yyyy';
  BiffDateSeparator  = '.';
  BiffDecimalSeparator  = '.';

type
  TUtils = class(TObject)
  private
  public
    function StrToDateEx(value: string): TDateTime;
    function StrToDateDefEx(value: string; Default: TDateTime): TDateTime;
    function GetCpuCount(): Cardinal;
    function GetDirectoryName(NumGroup: integer): string;
  end;

implementation

{ TUtils }

function TUtils.StrToDateEx(value: string): TDateTime;
var  fmt     : TFormatSettings;
begin
  fmt.ShortDateFormat:= BiffShortDateFormat;
  fmt.DateSeparator  := BiffDateSeparator;
  fmt.LongTimeFormat := 'hh:nn:ss';
  fmt.TimeSeparator  := ':';
  result := StrToDate(value, fmt);
end;

function TUtils.StrToDateDefEx(value: string; Default: TDateTime): TDateTime;
var  fmt     : TFormatSettings;
begin
  fmt.ShortDateFormat:= BiffShortDateFormat;
  fmt.DateSeparator  := BiffDateSeparator;
  fmt.LongTimeFormat := 'hh:nn:ss';
  fmt.TimeSeparator  := ':';
  result := StrToDateDef(value, Default, fmt);
end;


function TUtils.GetCpuCount: Cardinal;
var Info: TSystemInfo;
begin
  GetSystemInfo(Info);
  Result := Info.dwNumberOfProcessors;
end;


function TUtils.GetDirectoryName(NumGroup: integer): string;
var
  SR: TSearchRec;
  FindRes: integer;
  SL: TStringList;
  AFileMask, FileStr, FileRootStr: string;
begin
  SL:= TStringList.Create;
  try
    try
      AFileMask:= IntToStr(NumGroup) + ')*';
      FileRootStr:= ExtractFilePath(ParamStr(0)) + '\Prices\';
      FindRes:= FindFirst(FileRootStr + AFileMask, faAnyFile, SR);
      while FindRes = 0 do begin
        SR.Name:= FileRootStr + SR.Name ;
        SL.Add(SR.Name);
        FindRes:= FindNext(SR);
      end;
    finally
      FindClose(SR);
    end;
    if SL.Count = 1 then begin
      FileStr:= SL[0];
    end else begin
      ShowMessage('Directory for group ' + IntToStr(NumGroup) + 'not finded.');
      FileStr:= '';
    end;
  finally
    FreeAndNil(SL);
  end;
  Result:= FileStr + '\';
end;


end.