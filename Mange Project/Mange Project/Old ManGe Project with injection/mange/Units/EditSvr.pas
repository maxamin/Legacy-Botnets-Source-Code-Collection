{*****************************************}
{    Edit Server Unit Coded By Bubzuru    }
{          http://bubzuru.info            }
{          http://evilzone.org            }
{             Thanx To Aphex              }
{*****************************************}
unit EditSvr;

interface

type
  SArray = array of string;

  //Loader Class
  TLoader = class(TObject)
    Settings:SArray;
    procedure LoadSettings;
  end;

  //Builder Class
  TBuilder = class(TObject)
    Settings:array[0..100] of string;
    procedure WriteSettings(filen:string);
  end;

implementation
uses
  Windows;

const
  ID = '[{#}]';

//Simple Xor Encryption
function Encrypt(s:string):string;
var i:integer;
begin
  for i := 1 to length(s) do
    s[i] := char(ord(s[i]) xor 444);
  result := s;
end;

//Split String Function To Seperate Settings
function Split(const Source,Delimiter:String):SArray;
var
  iCount,iPos,iLength: Integer;
  sTemp: String;
  aSplit:SArray;
begin
  sTemp := Source;
  iCount := 0;
  iLength := Length(Delimiter) - 1;
repeat
  iPos := Pos(Delimiter, sTemp);
  if iPos = 0 then
    break
  else begin
    Inc(iCount);
    SetLength(aSplit, iCount);
    aSplit[iCount - 1] := Copy(sTemp, 1, iPos - 1);
    Delete(sTemp, 1, iPos + iLength);
  end;
until False;
  if Length(sTemp) > 0 then begin
    Inc(iCount);
    SetLength(aSplit, iCount);
    aSplit[iCount - 1] := sTemp;
  end;
    Result := aSplit;
end;

///////////////////////////////////////////
///////// Read Settings From Exe //////////
///////////////////////////////////////////
function _LoadSettings: string;
var
  ResourceLocation: HRSRC;
  ResourceSize: dword;
  ResourceHandle: THandle;
  ResourcePointer: pointer;
begin
  ResourceLocation := FindResource(hInstance, 'BUBZ', RT_RCDATA);
  ResourceSize := SizeofResource(hInstance, ResourceLocation);
  ResourceHandle := LoadResource(hInstance, ResourceLocation);
  ResourcePointer := LockResource(ResourceHandle);
  if ResourcePointer <> nil then
  begin
    SetLength(Result, ResourceSize - 1);
    CopyMemory(@Result[1], ResourcePointer, ResourceSize);
    FreeResource(ResourceHandle);
  end;
end;

procedure TLoader.LoadSettings;
var i:integer;
begin
  Settings  := Split(_LoadSettings,ID);
  for i := 0 to High(Settings) do begin
    if Settings[i] <> '' then
      Settings[i] := Encrypt(Settings[i]);
  end;
end;
///////////////////////////////////////////


///////////////////////////////////////////
///////// Write Settings To Exe ///////////
///////////////////////////////////////////
procedure _WriteSettings(ServerFile: string; Settings: string);
var
  ResourceHandle: THandle;
  pwServerFile: PWideChar;
begin
  GetMem(pwServerFile, (Length(ServerFile) + 1) * 2);
  try
    StringToWideChar(ServerFile, pwServerFile, Length(ServerFile) * 2);
    ResourceHandle := BeginUpdateResourceW(pwServerFile, False);
    UpdateResourceW(ResourceHandle, MakeIntResourceW(10), 'BUBZ', 0, @Settings[1], Length(Settings) + 1);
    EndUpdateResourceW(ResourceHandle, False);
  finally
    FreeMem(pwServerFile);
  end;
end;

procedure TBuilder.WriteSettings(filen:string);
var
  Settingsn:string;
  i:integer;
begin
  for i := 0 to 100 do begin
    if Settings[i] <> '' then
     Settingsn := Settingsn + Encrypt(Settings[i]) + ID;
  end;
  _WriteSettings(filen, Settingsn);
end;
///////////////////////////////////////////

end.
 