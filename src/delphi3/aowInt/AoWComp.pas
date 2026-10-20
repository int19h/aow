unit AoWComp;

{ The AoWComp unit of aowInt.dpl (the Age of Wonders user interface controls) written for the
  original compiler (Delphi 3.02) and byte-matched against the game's module class by class
  (tools/match.py). TAoWComponent is the root of every control and window: it keeps the child
  list, the alignment rules, and two lists of dirty rectangles (the rectangles to redraw and the
  rectangles to blit to the screen), which AddDrawRect and AddBltRect keep free of overlaps.
  Declarations follow the original instance layouts and VMT orders (notes/classes.json); the
  published properties follow notes/rtti/aowInt.dpl.txt. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib;

type
  TButtonType = (btText, btIcon);
  TaowTextAlign = (taLeft, taCenter, taRight);
  TAOWAlignHeight = (ahNone, ahTop, ahBottom, ahBoth, ahCenter);
  TAOWAlignWidth = (awNone, awLeft, awRight, awBoth, awCenter);
  TAOWDrawMethod = (dmBlank, dmBorderless, dmHollowBox, dmFilledBox);

  TAoWComponent = class;

  TAoWOnDrawEvent = procedure(Sender: TAoWComponent; SurfDesc: TSurfaceDesc) of object;
  TAoWOnDrawBackEvent = procedure(Sender: TAoWComponent; SurfDesc: TSurfaceDesc) of object;
  TAoWOnDrawItemEvent = procedure(Sender: TAoWComponent; const DrawRect: TRect;
    DrawItem: Integer; var SurfDesc: TSurfaceDesc) of object;
  TAoWOnDebugEvent = procedure(Dtext: string) of object;

  { AoWComp.TAOWAlignment (instance size 44): how a component sizes and places itself inside its
    owner (ReAlign). +4 FWidthPercent, +5 FHeightPercent, +8 FLeftOffPercent, +$C
    FRightOffPercent, +$10 FTopOffPercent, +$14 FBottomOffPercent, +$18 FLeftOffset, +$1C
    FRightOffset, +$20 FTopOffset, +$24 FBottomOffset, +$28 FAlignWidth, +$29 FAlignHeight.
    It does not override Assign, so TAoWComponent.SetAlign raises EConvertError (original bug). }
  TAOWAlignment = class(TPersistent)
  private
    FWidthPercent: Byte;
    FHeightPercent: Byte;
    FLeftOffPercent: Integer;
    FRightOffPercent: Integer;
    FTopOffPercent: Integer;
    FBottomOffPercent: Integer;
    FLeftOffset: Integer;
    FRightOffset: Integer;
    FTopOffset: Integer;
    FBottomOffset: Integer;
    FAlignWidth: TAOWAlignWidth;
    FAlignHeight: TAOWAlignHeight;
  published
    property AlignWidth: TAOWAlignWidth read FAlignWidth write FAlignWidth;
    property AlignHeight: TAOWAlignHeight read FAlignHeight write FAlignHeight;
    property HeightPercent: Byte read FHeightPercent write FHeightPercent;
    property WidthPercent: Byte read FWidthPercent write FWidthPercent;
    property LeftOffPercent: Integer read FLeftOffPercent write FLeftOffPercent;
    property RightOffPercent: Integer read FRightOffPercent write FRightOffPercent;
    property TopOffPercent: Integer read FTopOffPercent write FTopOffPercent;
    property BottomOffPercent: Integer read FBottomOffPercent write FBottomOffPercent;
    property LeftOffset: Integer read FLeftOffset write FLeftOffset;
    property RightOffset: Integer read FRightOffset write FRightOffset;
    property TopOffset: Integer read FTopOffset write FTopOffset;
    property BottomOffset: Integer read FBottomOffset write FBottomOffset;
  end;

  { AoWComp.TaowRect (instance size 24): one entry of the dirty rectangle lists. +4 R, +$14 Owner
    (the component that asked for the redraw; AddDrawRect only) }
  TaowRect = class(TObject)
  public
    R: TRect;
    Owner: TAoWComponent;
  end;

  { AoWComp.TAoWComponent (instance size 260). Fields: +$24 FColor, +$28 FSelColor, +$2C FValid
    (Validate found everything it needs), +$2D FAligned, +$2E FSized, +$30 FCursor, +$34 FOnDraw,
    +$3C FOnPreDraw, +$44 FOnMouseDown, +$4C FOnMouseUp, +$54 FOnMouseMove, +$5C FOnKeyPress, +$64
    FOnKeyDown, +$6C FOnChange, +$74 FMouseDown, +$75 FVisible, +$78 FHandled (a Check* method
    consumed the input), +$7C FWinWidth, +$80 FWinHeight, +$84 FWinLeft, +$88 FWinTop, +$8C
    FAOWFont, +$90 FText, +$94 FRedraw, +$98 FBorderWidth, +$9C FBorderHeight, +$A0 FPriority,
    +$A4 FDrawn (the component is drawn as it is now), +$A5 FFirstDraw, +$A6 FMouseIn, +$A8
    FToolTipCount, +$AC FRadioIndex, +$B0 FChecked, +$B4 FOwnerItem, +$B8 FOnUpdate, +$C0
    FCaptureInput, +$C4 FOnDebugMessage, +$CC FAOWOwner, +$D0 FChildren (sorted by FPriority),
    +$D4 FAlignment, +$D8 FMasked, +$DC FBltList, +$E0 FDrawList (TaowRect), +$E4 FBltCount, +$E8
    FDrawCount, +$EC FToolTipLeft, +$F0 FOldRect, +$100 FHidden, +$101 FDoubleBuffered, +$102
    FSurfaceValid.
    VMT (after TComponent's): Create, OnChangeText, Validate, SetSize, ReAlign, Setup, Update,
    ClearDrawList, ClearBltList, InvalidateRect, AddBltRect, AddDrawRect, SetOwner, SetWinLeft,
    SetWinTop, SetWidth, SetHeight, SetPriority, SetVisible, SetColor, SetSelColor, DrawSurface,
    DrawSurfDesc, Draw, CheckMouseDown, CheckMouseUp, CheckMouseMove, CheckKeyPress,
    CheckKeyDown }
  TAoWComponent = class(TComponent)
  public
    FColor: TColor;
    FSelColor: TColor;
    FValid: Boolean;
    FAligned: Boolean;
    FSized: Boolean;
    FCursor: TCursor;
    FOnDraw: TAoWOnDrawEvent;
    FOnPreDraw: TAoWOnDrawEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseUp: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnKeyPress: TKeyPressEvent;
    FOnKeyDown: TKeyEvent;
    FOnChange: TNotifyEvent;
    FMouseDown: Boolean;
    FVisible: Boolean;
    FHandled: LongBool;
    FWinWidth: Integer;
    FWinHeight: Integer;
    FWinLeft: Integer;
    FWinTop: Integer;
    FAOWFont: TImageLibraryFont;
    FText: string;
    FRedraw: LongBool;
    FBorderWidth: Integer;
    FBorderHeight: Integer;
    FPriority: Integer;
    FDrawn: Boolean;
    FFirstDraw: Boolean;
    FMouseIn: Boolean;
    FToolTipCount: Integer;
    FRadioIndex: Integer;
    FChecked: Boolean;
    FOwnerItem: Integer;
    FOnUpdate: TNotifyEvent;
    FCaptureInput: Boolean;
    FOnDebugMessage: TAoWOnDebugEvent;
    FAOWOwner: TAoWComponent;
    FChildren: TList;
    FAlignment: TAOWAlignment;
    FMasked: Boolean;
    FBltList: TList;
    FDrawList: TList;
    FBltCount: Integer;
    FDrawCount: Integer;
    FToolTipLeft: Integer;
    FOldRect: TRect;
    FHidden: Boolean;
    FDoubleBuffered: Boolean;
    FSurfaceValid: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OnChangeText(Sender: TObject); virtual;
    procedure Validate; virtual;
    procedure SetSize; virtual;
    procedure ReAlign; virtual;
    procedure Setup; virtual;
    procedure Update; virtual;
    procedure ClearDrawList; virtual;
    procedure ClearBltList; virtual;
    procedure InvalidateRect(Index: Integer; var ARect: TRect; Sender: TAoWComponent); virtual;
    procedure AddBltRect(var ARect: TRect; Sender: TAoWComponent); virtual;
    procedure AddDrawRect(var ARect: TRect; Sender: TAoWComponent); virtual;
    procedure SetOwner(Value: TAoWComponent); virtual;
    procedure SetWinLeft(Value: Integer); virtual;
    procedure SetWinTop(Value: Integer); virtual;
    procedure SetWidth(Value: Integer); virtual;
    procedure SetHeight(Value: Integer); virtual;
    procedure SetPriority(Value: Integer); virtual;
    procedure SetVisible(Value: Boolean); virtual;
    procedure SetColor(Value: TColor); virtual;
    procedure SetSelColor(Value: TColor); virtual;
    procedure DrawSurface(Surface: TSurface); virtual;
    procedure DrawSurfDesc(SurfDesc: TSurfaceDesc); virtual;
    procedure Draw(SurfDesc: TSurfaceDesc); virtual;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure CheckKeyPress(var Key: Char); virtual;
    procedure CheckKeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure SetAlign(Value: TAOWAlignment);
    property Priority: Integer read FPriority write SetPriority;
    property WinLeft: Integer read FWinLeft write SetWinLeft;
    property WinTop: Integer read FWinTop write SetWinTop;
    property WinWidth: Integer read FWinWidth write SetWidth;
    property WinHeight: Integer read FWinHeight write SetHeight;
    property TextColor: TColor read FColor write SetColor;
    property TextSelColor: TColor read FSelColor write SetSelColor;
    property AOWOwner: TAoWComponent read FAOWOwner write SetOwner;
    property Alignment: TAOWAlignment read FAlignment write SetAlign;
    property Masked: Boolean read FMasked write FMasked;
    property CaptureInput: Boolean read FCaptureInput write FCaptureInput;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnPreDraw: TAoWOnDrawEvent read FOnPreDraw write FOnPreDraw;
    property OnDraw: TAoWOnDrawEvent read FOnDraw write FOnDraw;
    property OnUpdate: TNotifyEvent read FOnUpdate write FOnUpdate;
    property Visible: Boolean read FVisible write SetVisible default True;
    property OnDebugMessage: TAoWOnDebugEvent read FOnDebugMessage write FOnDebugMessage;
  end;

implementation

{ TAoWComponent }

procedure TAoWComponent.ClearDrawList;
var
  I: Integer;
begin
  FDrawCount := 0;
  for I := 0 to FChildren.Count - 1 do
    if TAoWComponent(FChildren[I]).FVisible then
      TAoWComponent(FChildren[I]).ClearDrawList;
end;

procedure TAoWComponent.ClearBltList;
var
  I: Integer;
begin
  FBltCount := 0;
  for I := 0 to FChildren.Count - 1 do
    if TAoWComponent(FChildren[I]).FVisible then
      TAoWComponent(FChildren[I]).ClearBltList;
end;

constructor TAoWComponent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FVisible := True;
  FFirstDraw := True;
  FAlignment := TAOWAlignment.Create;
  FChildren := TList.Create;
  FBltList := TList.Create;
  FDrawList := TList.Create;
end;

destructor TAoWComponent.Destroy;
var
  I: Integer;
begin
  SetOwner(nil);
  while FChildren.Count > 0 do
    TAoWComponent(FChildren[0]).SetOwner(nil);
  FChildren.Free;
  FAlignment.Free;
  for I := 0 to FDrawList.Count - 1 do
    TaowRect(FDrawList[I]).Free;
  for I := 0 to FBltList.Count - 1 do
    TaowRect(FBltList[I]).Free;
  FBltList.Free;
  FDrawList.Free;
  inherited Destroy;
end;

procedure TAoWComponent.OnChangeText(Sender: TObject);
begin
  FSized := False;
end;

procedure TAoWComponent.SetAlign(Value: TAOWAlignment);
begin
  FAlignment.Assign(Value);
  FAligned := False;
end;

procedure TAoWComponent.SetOwner(Value: TAoWComponent);
var
  I, NewIndex, OldIndex: Integer;
begin
  if FAOWOwner <> nil then
  begin
    OldIndex := FAOWOwner.FChildren.IndexOf(Self);
    FAOWOwner.FChildren.Delete(OldIndex);
  end
  else
    OldIndex := -2;
  if Value <> FAOWOwner then
    FValid := False;
  FAOWOwner := Value;
  NewIndex := -1;
  if FAOWOwner <> nil then
  begin
    I := 0;
    while I < FAOWOwner.FChildren.Count do
      if TAoWComponent(FAOWOwner.FChildren[I]).FPriority > FPriority then
      begin
        NewIndex := I;
        I := FAOWOwner.FChildren.Count;
      end
      else
        Inc(I);
    if NewIndex = -1 then
      FAOWOwner.FChildren.Add(Self)
    else
      FAOWOwner.FChildren.Insert(NewIndex, Self);
  end;
  if NewIndex <> OldIndex then
    if FDoubleBuffered then
      FSurfaceValid := False
    else
      FDrawn := False;
end;

procedure TAoWComponent.Validate;
var
  I: Integer;
begin
  FSized := False;
  FAligned := False;
  for I := 0 to FChildren.Count - 1 do
    TAoWComponent(FChildren[I]).FValid := False;
end;

{ AddBltRect adds ARect to the rectangles to blit, clipped against the rectangles already in the
  list so that no two overlap: the parts of ARect that another rectangle covers are cut off (a
  cut that leaves two pieces adds one of them as a new rectangle), and an old rectangle that ARect
  covers on one side is trimmed or emptied. }
procedure TAoWComponent.AddBltRect(var ARect: TRect; Sender: TAoWComponent);
var
  N: TaowRect;
  I, Count: Integer;
  Add: Boolean;
  R: TaowRect;
begin
  if FValid and FVisible then
  begin
    I := 0;
    Count := FBltCount;
    Add := True;
    if ARect.Left < 0 then ARect.Left := 0;
    if ARect.Top < 0 then ARect.Top := 0;
    if (ARect.Right < ARect.Left) or (ARect.Bottom < ARect.Top) then
      Add := False
    else
      while (I < Count) and Add do
      begin
        R := FBltList[I];
        if (ARect.Right >= R.R.Left) and (ARect.Left <= R.R.Right) and
          (ARect.Bottom >= R.R.Top) and (ARect.Top <= R.R.Bottom) then
          if R.R.Left <= ARect.Left then
          begin
            if ARect.Right <= R.R.Right then
            begin
              if ARect.Top >= R.R.Top then
              begin
                if ARect.Bottom <= R.R.Bottom then
                  Add := False
                else
                  ARect.Top := R.R.Bottom + 1;
              end
              else if ARect.Bottom <= R.R.Bottom then
                ARect.Bottom := R.R.Top - 1
              else
              begin
                if FBltCount = FBltList.Count then
                  FBltList.Add(TaowRect.Create);
                N := FBltList[FBltCount];
                N.R := Rect(ARect.Left, ARect.Top, ARect.Right, R.R.Top - 1);
                Inc(FBltCount);
                ARect.Top := R.R.Bottom + 1;
              end;
            end
            else if ARect.Top >= R.R.Top then
            begin
              if ARect.Bottom <= R.R.Bottom then
                ARect.Left := R.R.Right + 1
              else
              begin
                if FBltCount = FBltList.Count then
                  FBltList.Add(TaowRect.Create);
                N := FBltList[FBltCount];
                N.R := Rect(ARect.Left, R.R.Bottom + 1, R.R.Right, ARect.Bottom);
                Inc(FBltCount);
                ARect.Left := R.R.Right + 1;
              end;
            end
            else if ARect.Bottom <= R.R.Bottom then
            begin
              if FBltCount = FBltList.Count then
                FBltList.Add(TaowRect.Create);
              N := FBltList[FBltCount];
              N.R := Rect(ARect.Left, ARect.Top, R.R.Right, R.R.Top - 1);
              Inc(FBltCount);
              ARect.Left := R.R.Right + 1;
            end
            else
              R.R.Right := ARect.Left - 1;
          end
          else if ARect.Right <= R.R.Right then
          begin
            if ARect.Top >= R.R.Top then
            begin
              if ARect.Bottom <= R.R.Bottom then
                ARect.Right := R.R.Left - 1
              else
              begin
                if FBltCount = FBltList.Count then
                  FBltList.Add(TaowRect.Create);
                N := FBltList[FBltCount];
                N.R := Rect(R.R.Left, R.R.Bottom + 1, ARect.Right, ARect.Bottom);
                Inc(FBltCount);
                ARect.Right := R.R.Left - 1;
              end;
            end
            else if ARect.Bottom <= R.R.Bottom then
            begin
              if FBltCount = FBltList.Count then
                FBltList.Add(TaowRect.Create);
              N := FBltList[FBltCount];
              N.R := Rect(R.R.Left, ARect.Top, ARect.Right, R.R.Top - 1);
              Inc(FBltCount);
              ARect.Right := R.R.Left - 1;
            end
            else
              R.R.Left := ARect.Right + 1;
          end
          else if ARect.Top >= R.R.Top then
          begin
            if ARect.Bottom <= R.R.Bottom then
            begin
              if FBltCount = FBltList.Count then
                FBltList.Add(TaowRect.Create);
              N := FBltList[FBltCount];
              N.R := Rect(ARect.Left, ARect.Top, R.R.Left - 1, ARect.Bottom);
              Inc(FBltCount);
              ARect.Left := R.R.Right + 1;
            end
            else
              R.R.Bottom := ARect.Top - 1;
          end
          else if ARect.Bottom <= R.R.Bottom then
            R.R.Top := ARect.Bottom + 1
          else
            R.R := Rect(0, 0, 0, 0);
        Inc(I);
      end;
    if Add then
    begin
      if FBltCount = FBltList.Count then
        FBltList.Add(TaowRect.Create);
      R := FBltList[FBltCount];
      R.R := ARect;
      Inc(FBltCount);
    end;
  end;
end;

{ AddDrawRect: the same for the rectangles to redraw; the rectangle added last records Sender }
procedure TAoWComponent.AddDrawRect(var ARect: TRect; Sender: TAoWComponent);
var
  N: TaowRect;
  I, Count: Integer;
  Add: Boolean;
  R: TaowRect;
begin
  if FValid and FVisible then
  begin
    I := 0;
    Count := FDrawCount;
    Add := True;
    if ARect.Left < 0 then ARect.Left := 0;
    if ARect.Top < 0 then ARect.Top := 0;
    if (ARect.Right < ARect.Left) or (ARect.Bottom < ARect.Top) then
      Add := False
    else
      while (I < Count) and Add do
      begin
        R := FDrawList[I];
        if (ARect.Right >= R.R.Left) and (ARect.Left <= R.R.Right) and
          (ARect.Bottom >= R.R.Top) and (ARect.Top <= R.R.Bottom) then
          if R.R.Left <= ARect.Left then
          begin
            if ARect.Right <= R.R.Right then
            begin
              if ARect.Top >= R.R.Top then
              begin
                if ARect.Bottom <= R.R.Bottom then
                  Add := False
                else
                  ARect.Top := R.R.Bottom + 1;
              end
              else if ARect.Bottom <= R.R.Bottom then
                ARect.Bottom := R.R.Top - 1
              else
              begin
                if FDrawCount = FDrawList.Count then
                  FDrawList.Add(TaowRect.Create);
                N := FDrawList[FDrawCount];
                N.R := Rect(ARect.Left, ARect.Top, ARect.Right, R.R.Top - 1);
                Inc(FDrawCount);
                ARect.Top := R.R.Bottom + 1;
              end;
            end
            else if ARect.Top >= R.R.Top then
            begin
              if ARect.Bottom <= R.R.Bottom then
                ARect.Left := R.R.Right + 1
              else
              begin
                if FDrawCount = FDrawList.Count then
                  FDrawList.Add(TaowRect.Create);
                N := FDrawList[FDrawCount];
                N.R := Rect(ARect.Left, R.R.Bottom + 1, R.R.Right, ARect.Bottom);
                Inc(FDrawCount);
                ARect.Left := R.R.Right + 1;
              end;
            end
            else if ARect.Bottom <= R.R.Bottom then
            begin
              if FDrawCount = FDrawList.Count then
                FDrawList.Add(TaowRect.Create);
              N := FDrawList[FDrawCount];
              N.R := Rect(ARect.Left, ARect.Top, R.R.Right, R.R.Top - 1);
              Inc(FDrawCount);
              ARect.Left := R.R.Right + 1;
            end
            else
              R.R.Right := ARect.Left - 1;
          end
          else if ARect.Right <= R.R.Right then
          begin
            if ARect.Top >= R.R.Top then
            begin
              if ARect.Bottom <= R.R.Bottom then
                ARect.Right := R.R.Left - 1
              else
              begin
                if FDrawCount = FDrawList.Count then
                  FDrawList.Add(TaowRect.Create);
                N := FDrawList[FDrawCount];
                N.R := Rect(R.R.Left, R.R.Bottom + 1, ARect.Right, ARect.Bottom);
                Inc(FDrawCount);
                ARect.Right := R.R.Left - 1;
              end;
            end
            else if ARect.Bottom <= R.R.Bottom then
            begin
              if FDrawCount = FDrawList.Count then
                FDrawList.Add(TaowRect.Create);
              N := FDrawList[FDrawCount];
              N.R := Rect(R.R.Left, ARect.Top, ARect.Right, R.R.Top - 1);
              Inc(FDrawCount);
              ARect.Right := R.R.Left - 1;
            end
            else
              R.R.Left := ARect.Right + 1;
          end
          else if ARect.Top >= R.R.Top then
          begin
            if ARect.Bottom <= R.R.Bottom then
            begin
              if FDrawCount = FDrawList.Count then
                FDrawList.Add(TaowRect.Create);
              N := FDrawList[FDrawCount];
              N.R := Rect(ARect.Left, ARect.Top, R.R.Left - 1, ARect.Bottom);
              Inc(FDrawCount);
              ARect.Left := R.R.Right + 1;
            end
            else
              R.R.Bottom := ARect.Top - 1;
          end
          else if ARect.Bottom <= R.R.Bottom then
            R.R.Top := ARect.Bottom + 1
          else
            R.R := Rect(0, 0, 0, 0);
        Inc(I);
      end;
    if Add then
    begin
      if FDrawCount = FDrawList.Count then
        FDrawList.Add(TaowRect.Create);
      R := FDrawList[FDrawCount];
      R.R := ARect;
      R.Owner := Sender;
      Inc(FDrawCount);
    end;
  end;
end;

procedure TAoWComponent.InvalidateRect(Index: Integer; var ARect: TRect; Sender: TAoWComponent);
begin
end;

procedure TAoWComponent.SetWinLeft(Value: Integer);
begin
  FWinLeft := Value;
  FDrawn := False;
end;

procedure TAoWComponent.SetWinTop(Value: Integer);
begin
  FWinTop := Value;
  FDrawn := False;
end;

procedure TAoWComponent.SetWidth(Value: Integer);
begin
  FWinWidth := Value;
  FSized := False;
end;

procedure TAoWComponent.SetHeight(Value: Integer);
begin
  FWinHeight := Value;
  FSized := False;
end;

procedure TAoWComponent.SetPriority(Value: Integer);
begin
  FPriority := Value;
  SetOwner(FAOWOwner);
end;

procedure TAoWComponent.SetVisible(Value: Boolean);
begin
  if Value <> FVisible then
  begin
    FVisible := Value;
    FDrawn := False;
    if FVisible then
    begin
      FHidden := False;
      ClearBltList;
      ClearDrawList;
      if not FValid or not FAligned or not FSized then
        Setup;
    end
    else
      FHidden := True;
  end;
end;

procedure TAoWComponent.SetColor(Value: TColor);
begin
  FColor := Value;
  FDrawn := False;
end;

procedure TAoWComponent.SetSelColor(Value: TColor);
begin
  FSelColor := Value;
  FDrawn := False;
end;

procedure TAoWComponent.DrawSurface(Surface: TSurface);
begin
end;

procedure TAoWComponent.DrawSurfDesc(SurfDesc: TSurfaceDesc);
begin
end;

procedure TAoWComponent.Draw(SurfDesc: TSurfaceDesc);
begin
end;

procedure TAoWComponent.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
end;

procedure TAoWComponent.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
end;

procedure TAoWComponent.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
end;

procedure TAoWComponent.CheckKeyPress(var Key: Char);
begin
  FHandled := False;
end;

procedure TAoWComponent.CheckKeyDown(var Key: Word; Shift: TShiftState);
begin
  FHandled := False;
end;

procedure TAoWComponent.SetSize;
var
  I: Integer;
begin
  FSized := True;
  FDrawn := False;
  FBltCount := 0;
  FDrawCount := 0;
  for I := 0 to FChildren.Count - 1 do
    TAoWComponent(FChildren[I]).FAligned := False;
end;

procedure TAoWComponent.ReAlign;
var
  I: Integer;
begin
  if (FAOWOwner <> nil) and ((FAlignment.FAlignWidth <> awNone) or (FAlignment.FAlignHeight <> ahNone)) then
    begin
      with FAlignment do
      case FAlignWidth of
          awLeft:
            begin
              FWinLeft := FAOWOwner.FWinWidth * FLeftOffPercent div 100 + FLeftOffset;
              if FAlignment.FWidthPercent > 0 then
                FWinWidth := FAOWOwner.FWinWidth * FAlignment.FWidthPercent div 100;
            end;
          awRight:
            begin
              if FWidthPercent > 0 then
                FWinWidth := FAOWOwner.FWinWidth * FWidthPercent div 100;
              FWinLeft := FAOWOwner.FWinWidth - FAlignment.FRightOffset - FWinWidth -
                FAOWOwner.FWinWidth * FAlignment.FRightOffPercent div 100;
            end;
          awBoth:
            begin
              FWinLeft := FAOWOwner.FWinWidth * FLeftOffPercent div 100 + FLeftOffset;
              FWinWidth := FAOWOwner.FWinWidth - FWinLeft - FAlignment.FRightOffset -
                FAOWOwner.FWinWidth * FAlignment.FRightOffPercent div 100;
            end;
          awCenter:
            FWinLeft := FAOWOwner.FWinWidth div 2 - FWinWidth div 2;
        end;
      with FAlignment do
      case FAlignHeight of
          ahTop:
            begin
              FWinTop := FAOWOwner.FWinHeight * FTopOffPercent div 100 + FTopOffset;
              if FAlignment.FHeightPercent > 0 then
                FWinHeight := FAOWOwner.FWinHeight * FAlignment.FHeightPercent div 100;
            end;
          ahBottom:
            begin
              if FHeightPercent > 0 then
                FWinHeight := FAOWOwner.FWinHeight * FHeightPercent div 100;
              FWinTop := FAOWOwner.FWinHeight - FAlignment.FBottomOffset - FWinHeight -
                FAOWOwner.FWinHeight * FAlignment.FBottomOffPercent div 100;
            end;
          ahBoth:
            begin
              FWinTop := FAOWOwner.FWinHeight * FTopOffPercent div 100 + FTopOffset;
              FWinHeight := FAOWOwner.FWinHeight - FWinTop - FAlignment.FBottomOffset -
                FAOWOwner.FWinHeight * FAlignment.FBottomOffPercent div 100;
            end;
          ahCenter:
            FWinTop := FAOWOwner.FWinHeight div 2 - FWinHeight div 2;
        end;
    end;
  FAligned := True;
  FSized := False;
  for I := 0 to FChildren.Count - 1 do
    TAoWComponent(FChildren[I]).FAligned := False;
end;

{ Setup brings the component up to date: Validate, SetSize and ReAlign when their flag is clear,
  then Setup of every visible child; an exception in any step is reported in a message box }
procedure TAoWComponent.Setup;
var
  I: Integer;
begin
  if FVisible then
  begin
    try
      if not FValid then
        Validate;
    except
      MessageBox(0, 'Exception during Validate', Pointer('Error - ' + Name), 0);
    end;
    if FValid then
    begin
      try
        if not FSized then
          SetSize;
      except
        MessageBox(0, 'Exception during SetSize', Pointer('Error - ' + Name), 0);
      end;
      try
        if not FAligned then
          ReAlign;
      except
        MessageBox(0, 'Exception during ReAlign', Pointer('Error - ' + Name), 0);
      end;
      try
        if not FSized then
          SetSize;
      except
        MessageBox(0, 'Exception during SetSize', Pointer('Error - ' + Name), 0);
      end;
      try
        for I := 0 to FChildren.Count - 1 do
          if TAoWComponent(FChildren[I]).FVisible then
            TAoWComponent(FChildren[I]).Setup;
      except
        MessageBox(0, 'Exception during Setup', Pointer('Error - ' + Name), 0);
      end;
    end;
  end;
end;

procedure TAoWComponent.Update;
var
  I: Integer;
begin
  try
    if FValid and FVisible then
    begin
      if Assigned(FOnUpdate) then
        FOnUpdate(Self);
      for I := FChildren.Count - 1 downto 0 do
        TAoWComponent(FChildren[I]).Update;
      if not FValid or not FAligned or not FSized then
        Setup;
    end;
  except
    MessageBox(0, 'Exception during Update', Pointer('Error - ' + Name), 0);
  end;
end;

end.
