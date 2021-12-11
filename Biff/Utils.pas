unit Utils;

interface

uses Classes, Sysutils;

type
  TUtils = class(TObject)
  private

  public
    constructor Create;
    destructor Destroy; override;
    function StrToDateEx(value: string): TDateTime;
  end;

implementation

{ TUtils }

constructor TUtils.Create;
begin
  inherited;
  // add code for constructor
end;

destructor TUtils.Destroy;
begin
  // add code for destructor
  inherited;
end;

function TUtils.StrToDateEx(value: string): TDateTime;
var  fmt     : TFormatSettings;
     dt      : TDateTime;
begin
  fmt.ShortDateFormat:='dd.mm.yyyy';
  fmt.DateSeparator  :='.';
  fmt.LongTimeFormat :='hh:nn:ss';
  fmt.TimeSeparator  :=':';
  result := StrToDate(value, fmt);
end;

end.
