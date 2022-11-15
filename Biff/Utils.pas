unit Utils;

interface

uses Windows, Messages, SysUtils, Variants, Classes;

const
  BiffShortDateFormat = 'dd.mm.yyyy';
  BiffDateSeparator  = '.';

type
  TUtils = class(TObject)
  private
    LastXorShiftSeed: integer;
  public
    constructor Create;
    destructor Destroy; override;
    function StrToDateEx(value: string): TDateTime;
    function StrToDateDefEx(value: string; Default: TDateTime): TDateTime;

    function GetCpuCount(): Cardinal;
    procedure Shuffle(var listOfT: TList);
    procedure ShuffleArray(var iArray: array of integer);
    function XorShift(limit : integer) : Cardinal;
  end;

implementation

{ TUtils }

constructor TUtils.Create;
begin
  inherited;
  LastXorShiftSeed := Random(MaxInt);
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
  fmt.ShortDateFormat:= BiffShortDateFormat;
  fmt.DateSeparator  := BiffDateSeparator;
  fmt.LongTimeFormat := 'hh:nn:ss';
  fmt.TimeSeparator  := ':';
  result := StrToDate(value, fmt);
end;

function TUtils.StrToDateDefEx(value: string; Default: TDateTime): TDateTime;
var  fmt     : TFormatSettings;
     dt      : TDateTime;
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

procedure TUtils.Shuffle(var listOfT: TList);
//randomize positions by swapping the position of two elements randomly
var
  randomIndex: integer;
  cnt: integer;
begin 
  for cnt := 0 to listOfT.Count - 1 do
  begin
    randomIndex := Random(listOfT.Count - cnt);
    listOfT.Exchange(cnt, cnt + randomIndex);
  end;
end;

procedure TUtils.ShuffleArray(var iArray: array of integer);
var
  iIndex: TList;
  i, j, len: integer;
begin
  len := Length(iArray);
  iIndex := TList.Create;
  try
    iIndex.Count := len;
    for i := 0 to Pred(len) do
      iIndex[i] := Pointer(I);

    Shuffle(iIndex);

    for i := Low(iArray) to High(iArray) do
    begin
      //j := Random(iIndex.Count);
      iArray[Integer(iIndex[i])] := i;
      //iIndex.Delete(j);
    end;
  finally
    iIndex.Free;
  end;
end;

function TUtils.XorShift(limit : integer) : Cardinal;
var
  buf, seed : Int64;
begin
  seed:=int64(LastXorShiftSeed);
  buf:=seed xor (seed shl 13);
  buf:=buf xor (buf shr 17);
  buf:=buf xor (buf shl 5);
  //seed:=buf;
  InterlockedExchange(LastXorShiftSeed, buf);
  //Result:=seed and $FFFFFFFF;
  Result:=(LastXorShiftSeed and $FFFFFFFF) mod limit;
end;


end.