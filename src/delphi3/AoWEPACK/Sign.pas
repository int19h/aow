unit Sign;

{ Sign of AoWEPACK.dpl: recovered bodies and original instance layouts.
  Remaining inherited declaration constraints are documented at local ABI adapters. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TSign = class;
  TSignResource = class;
  TUpdateSignTE = class;


  { TSign (instance size 56, VMT 557A4098): +$30 FText, +$34 FTextSeen. }
  TSign = class(TStructure)
  public
    FText: TStringList;
    FTextSeen: TBitList;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetOverlay(Index: Integer): Shortint; override;
    procedure Select; override;
    function GetTextSeen(Player: Shortint): Boolean;
    procedure SetText(Text: TStrings);
    function CanChangeText: Boolean;
    function ChangeText(Player: Integer; Text: TStrings): Boolean;
  end;

  { TSignResource (instance size 100, VMT 557A42EC) }
  TSignResource = class(TStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    procedure Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
  end;

  { TUpdateSignTE (instance size 24, VMT 557A43DC): +$10 FText, +$14 FXhx, +$15 FYhx, +$16 FLhx. }
  TUpdateSignTE = class(TTokenEvent)
  public
    FText: TStringList;
    FXhx: Shortint;
    FYhx: Shortint;
    FLhx: Shortint;
    F_UpdateSignTE_17: array[0..0] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

procedure RegisterSign(AEngine: TEngine);

implementation

type
  PAoWHSMap = ^TAoWHSMap;
  PSignSurfaceDesc = ^TSurfaceDesc;
  TSignMapFields = packed record
    Reserved: array[0..163] of Byte;
    CurrentPlayer, SeatedPlayer: Shortint;
    ReservedA6: array[$A6..$139] of Byte;
    StorageType: Byte;
  end;
const
  WorldMap: PAoWHSMap = @AoWE.AoWHSMap;

{ needs: draft AoWE result signatures; adapters preserve the proven register ABI. }
function SignArmyHS(Field: TAoWMapField): TArmyHS; assembler;
asm JMP TAoWMapField.GetArmyHS end;
function SignPlayer(List: TPlayerList; Index: Integer): TPlayer; assembler;
asm JMP TPlayerList.GetPlayers end;
function SignPlayerBusy(Player: TPlayer): Boolean; assembler;
asm JMP TPlayer.GetBusy end;
function TranslateSignName(const S: string): string; assembler;
asm JMP AoWE.TranslateRStr end;

constructor TSign.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FText := TStringList.Create;
  FTextSeen := TBitList.Create;
end;

destructor TSign.Destroy;
begin
  FText.Free;
  FTextSeen.Free;
  inherited Destroy;
end;

class function TSign.ClassID: Integer;
begin Result := $20102; end;

function TSign.GetOverlay(Index: Integer): Shortint;
asm OR EAX,-1 end;

procedure TSign.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStrings(FText, 7);
  if (WorldMap^ <> nil) and (TSignMapFields(Pointer(WorldMap^)^).StorageType <> 1) then
    Stream.rwStreamProc(8, FTextSeen.LoadFromStream, FTextSeen.SaveToStream);
end;

function TSign.GetTextSeen(Player: Shortint): Boolean;
begin Result := FTextSeen[Player]; end;

procedure TSign.SetText(Text: TStrings);
begin FText.Assign(Text); Update; end;

procedure TSign.Select;
begin
  inherited Select;
  if not (msEditting in WorldMap^.Status) then FTextSeen[TSignMapFields(Pointer(WorldMap^)^).SeatedPlayer] := True;
end;

function TSign.CanChangeText: Boolean;
var
  ArmyHS: TArmyHS;
begin
  ArmyHS := SignArmyHS(TAoWMapField(Owner));
  Result := (ArmyHS <> nil) and (Byte(TArmy(ArmyHS.FArmy).FPlayer) =
    Byte(TSignMapFields(Pointer(WorldMap^)^).SeatedPlayer));
end;

function TSign.ChangeText(Player: Integer; Text: TStrings): Boolean;
var
  Event: TUpdateSignTE;
begin
  if not SignPlayerBusy(SignPlayer(TPlayerList(WorldMap^.FPlayers), Player)) and CanChangeText then
  begin
    Event := TUpdateSignTE.Create(nil);
    Event.FXhx := GetXhx;
    Event.FYhx := GetYhx;
    Event.FLhx := GetLhx;
    Event.FText.Assign(Text);
    TTokenManager(WorldMap^.FTokenManager).GetTokenControl(Player).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

constructor TSignResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  F_StructureResource_45 := 0;
  F_StructureResource_44 := 0;
end;

class function TSignResource.ClassID: Integer;
begin Result := $20103; end;

class function TSignResource.ResourceEditName: string;
begin Result := TranslateSignName(LoadResString(@SignRStr)); end;

function TSignResource.ResourceUserClassID: Integer;
begin Result := $20102; end;

procedure TSignResource.Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
var
  Sequence: TImageSequence;
  Index, Offset, Image: Integer;
  Animate: Boolean;
begin
  { needs: TStructureResource.Show(X, Y: Integer; const SD: TSurfaceDesc; Obj: TStructure). }
  if FImageSequenceList <> nil then
  begin
    Index := TSign(A4).ImageIndex;
    Offset := TMapField(TSign(A4).Owner).Xhx + TMapField(TSign(A4).Owner).Yhx * 16;
    Animate := (TSignMapFields(Pointer(WorldMap^)^).SeatedPlayer < 0) or
      not TSign(A4).GetTextSeen(TSignMapFields(Pointer(WorldMap^)^).SeatedPlayer);
    if Index < FImageSequenceList.Count then Sequence := TImageSequence(FImageSequenceList.List^[Index])
    else Sequence := nil;
    while Sequence <> nil do
    begin
      if Animate then Image := Sequence.GetFrameIndex(WorldMap^.Frame, Offset)
      else Image := Sequence.GetUnloopedFrameIndex(0);
      if Image <> -1 then
        if TSign(A4).GetSelected and (WorldMap^.Frame and 6 = 6) then
          Sequence.ImageLibrary[Image].ShowTransparent(A1 + Sequence.dXshift, A2 + Sequence.dYshift, PSignSurfaceDesc(A3)^)
        else
          Sequence.ImageLibrary[Image].Show(A1 + Sequence.dXshift, A2 + Sequence.dYshift, PSignSurfaceDesc(A3)^);
      Sequence := Sequence.Next;
    end;
  end;
end;

constructor TUpdateSignTE.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); FText := TStringList.Create; end;

destructor TUpdateSignTE.Destroy;
begin FText.Free; inherited Destroy; end;

class function TUpdateSignTE.ClassID: Integer;
begin Result := $2010F; end;

procedure TUpdateSignTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStrings(FText, 15);
  Stream.rwByte(Byte(FXhx), 16);
  Stream.rwByte(Byte(FYhx), 17);
  Stream.rwByte(Byte(FLhx), 18);
end;

function TUpdateSignTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var
  Sign: TSign;
begin
  Sign := TSign(WorldMap^.MapContainer.GetField(FXhx, FYhx, FLhx).FindOwnedChild($20102));
  if Sign <> nil then
  begin
    Sign.SetText(FText);
    Sign.FTextSeen.Clear;
    Sign.FTextSeen[TSignMapFields(Pointer(WorldMap^)^).CurrentPlayer] := True;
    Result := erDone;
  end
  else Result := erDoneHalt;
end;

procedure RegisterSign(AEngine: TEngine);
begin AEngine.RegisterEClasses([TSign, TSignResource, TUpdateSignTE]); end;


initialization
finalization

end.
