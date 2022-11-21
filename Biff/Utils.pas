unit Utils;

interface

uses Windows, Messages, SysUtils, Variants, Classes;

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


end.