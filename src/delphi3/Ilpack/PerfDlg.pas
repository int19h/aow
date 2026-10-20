unit PerfDlg;

{ The PerfDlg unit of Ilpack.dpl: the performance dialog of the image library editor (the
  "Performance" item of the edit grid's popup menu). A thread draws the selected image into a
  memory surface again and again, in the show mode and pixel format the dialog selects, and
  shows frames per second, the time per frame and the processor cycles per frame. The form's
  components are plain published fields (no DFM is linked here). }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  GFXE, ImageLib;

type
  TPerformanceThread = class;

  { PerfDlg.TPerformanceDlg (instance size 564): +$1DC the components, +$224 FImage (the image
    tested), +$228 FPixelFormatID (of the test surface), +$22C FThread, +$230 FReserved (never
    used). }
  TPerformanceDlg = class(TForm)
    CloseBtn: TButton;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    AlignMnt: TComboBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    FPS: TEdit;
    GroupBox3: TGroupBox;
    IntervalSize: TComboBox;
    Label2: TLabel;
    ElapsedTime: TEdit;
    GroupBox4: TGroupBox;
    ClrCache: TCheckBox;
    Label3: TLabel;
    RDTSCEdit: TEdit;
    GroupBox5: TGroupBox;
    PFBox: TComboBox;
    ShowModeBox: TRadioGroup;
    procedure CloseBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IntervalSizeChange(Sender: TObject);
    procedure PFBoxChange(Sender: TObject);
  private
    FImage: TLibraryImage;
    FPixelFormatID: Integer;
    FThread: TPerformanceThread;
    FReserved: Integer;
    procedure SetPixelFormatID(Value: Integer);
  public
    constructor CreateDialog(AOwner: TComponent; AImage: TLibraryImage);
    destructor Destroy; override;
    property PixelFormatID: Integer read FPixelFormatID write SetPixelFormatID;
  end;

  { PerfDlg.TPerformanceThread (instance size 100): +$28 FImage, +$2C FImageLibrary (copies of
    the image, up to 256 KB of them, drawn in turn when the dialog's "clear cache" box is
    checked), +$30 FSurface (the test surface), +$34 FFramesPerSecond, +$40 FElapsed (ms), +$44
    FCycles, +$48 FDlg, +$4C FDone (never read), +$50 FOrigin (never set, so always 0), +$60
    FReset (set when the interval changes: the running test stops drawing). }
  TPerformanceThread = class(TThread)
  private
    FImage: TLibraryImage;
    FImageLibrary: TCustomImageLibrary;
    FSurface: TDataSurface;
    FFramesPerSecond: Extended;
    FElapsed: Integer;
    FCycles: Integer;
    FDlg: TPerformanceDlg;
    FDone: Boolean;
    FOrigin: TRect;
    FReset: Boolean;
    procedure SetPerformance;
    procedure UpdatePixelFormat;
    procedure ExecutePerformanceTest;
  protected
    procedure Execute; override;
  public
    constructor Create(ADlg: TPerformanceDlg; AImage: TLibraryImage);
    destructor Destroy; override;
  end;

implementation

{ TPerformanceThread }

procedure TPerformanceThread.SetPerformance;
begin
  if not Terminated then
  begin
    FDlg.FPS.Text := FloatToStrF(FFramesPerSecond, ffFixed, 10, 0);
    FDlg.ElapsedTime.Text := IntToStr(Round(FElapsed * 1000 / StrToInt(FDlg.IntervalSize.Text)));
    FDlg.RDTSCEdit.Text := IntToStr(Round(FCycles / StrToInt(FDlg.IntervalSize.Text)));
  end;
end;

procedure TPerformanceThread.UpdatePixelFormat;
var
  SD: TSurfaceDesc;
begin
  if not Terminated then
  begin
    FSurface.Lock(SD);
    if FDlg.PixelFormatID <> SD.PixelFormatID then
    begin
      FSurface.Free;
      FSurface := TDataSurface.Create(FImage.Width + 4, FImage.Height, FDlg.PixelFormatID, nil);
    end;
    FSurface.Unlock;
  end;
end;

procedure TPerformanceThread.ExecutePerformanceTest;
var
  StartTime, StartCycles, X, Count, Index, MaxIndex: Integer;
  SD: TSurfaceDesc;
  I, EndTime, EndCycles: Integer;
begin
  if not Terminated then
  begin
    FSurface.Lock(SD);
    Inc(SD.ClipRect.Left);
    Dec(SD.ClipRect.Right);
    FReset := False;
    X := FDlg.AlignMnt.ItemIndex;
    Count := StrToInt(FDlg.IntervalSize.Text);
    StartTime := GetElapsedMilliSeconds;
    StartCycles := RDTSC;
    if not FDlg.ClrCache.Checked then
    begin
      if FDlg.ShowModeBox.ItemIndex = 0 then
      begin
        for I := 0 to Count - 1 do
          if not FReset then
            FImage.ShowOpaque(X - FOrigin.Left, -FOrigin.Top, SD);
      end
      else if FDlg.ShowModeBox.ItemIndex = 1 then
      begin
        for I := 0 to Count - 1 do
          if not FReset then
            FImage.ShowTransparent(X - FOrigin.Left, -FOrigin.Top, SD);
      end
      else if FDlg.ShowModeBox.ItemIndex = 2 then
      begin
        for I := 0 to Count - 1 do
          if not FReset then
            FImage.ShowBlended(X - FOrigin.Left, -FOrigin.Top, SD, AlphaBlendTable.LookupTables[50]);
      end;
    end;
    if FDlg.ClrCache.Checked then
    begin
      MaxIndex := FImageLibrary.Count - 1;
      Index := 0;
      if FDlg.ShowModeBox.ItemIndex = 0 then
      begin
        for I := 0 to Count - 1 do
          if not FReset then
          begin
            FImageLibrary[Index].ShowOpaque(X - FOrigin.Left, -FOrigin.Top, SD);
            Inc(Index);
            if Index >= MaxIndex then Index := 0;
          end;
      end
      else if FDlg.ShowModeBox.ItemIndex = 1 then
      begin
        for I := 0 to Count - 1 do
          if not FReset then
          begin
            FImageLibrary[Index].ShowTransparent(X - FOrigin.Left, -FOrigin.Top, SD);
            Inc(Index);
            if Index >= MaxIndex then Index := 0;
          end;
      end
      else if FDlg.ShowModeBox.ItemIndex = 2 then
      begin
        for I := 0 to Count - 1 do
          if not FReset then
          begin
            FImageLibrary[Index].ShowBlended(X - FOrigin.Left, -FOrigin.Top, SD,
              AlphaBlendTable.LookupTables[50]);
            Inc(Index);
            if Index >= MaxIndex then Index := 0;
          end;
      end;
    end;
    EndCycles := RDTSC;
    EndTime := GetElapsedMilliSeconds;
    FElapsed := EndTime - StartTime;
    FCycles := EndCycles - StartCycles;
    FSurface.Unlock;
    if (EndTime <> StartTime) and not FReset then
    begin
      FFramesPerSecond := Count;
      FFramesPerSecond := FFramesPerSecond * 1000 / (EndTime - StartTime);
    end
    else
      FFramesPerSecond := 0;
    SetPerformance;
    UpdatePixelFormat;
  end;
end;

procedure TPerformanceThread.Execute;
begin
  while not Terminated do
    try
      Synchronize(ExecutePerformanceTest);
    except
      Terminate;
    end;
end;

constructor TPerformanceThread.Create(ADlg: TPerformanceDlg; AImage: TLibraryImage);
var
  Stream: TMemoryStream;
  N, I: Integer;
begin
  FreeOnTerminate := True;
  FDone := False;
  FImage := AImage;
  FImageLibrary := TImageLibrary.Create(nil);
  Stream := TMemoryStream.Create;
  FImage.SaveToStream(Stream);
  N := $40000 div Stream.Position;
  Stream.Free;
  if N = 0 then N := 1;
  if N > 100 then N := 100;
  for I := 1 to N do
    FImageLibrary.Add(FImage.Copy);
  FDlg := ADlg;
  if AImage.SupportShowMode(smOpaque, pfRGB565) then
    FDlg.PixelFormatID := pfRGB565
  else if AImage.SupportShowMode(smOpaque, pfPAL8) then
    FDlg.PixelFormatID := pfPAL8
  else if AImage.SupportShowMode(smOpaque, pfRGB24) then
    FDlg.PixelFormatID := pfRGB24
  else if AImage.SupportShowMode(smOpaque, pfRGB32) then
    FDlg.PixelFormatID := pfRGB32
  else
    raise Exception.Create('No default Pixelformats supported by image');
  FSurface := TDataSurface.Create(AImage.Width + 4, AImage.Height, FDlg.PixelFormatID, nil);
  inherited Create(False);
end;

destructor TPerformanceThread.Destroy;
begin
  FSurface.Destroy;
  FImageLibrary.Destroy;
  inherited Destroy;
end;

{ TPerformanceDlg }

constructor TPerformanceDlg.CreateDialog(AOwner: TComponent; AImage: TLibraryImage);
begin
  FImage := AImage;
  inherited Create(AOwner);
end;

destructor TPerformanceDlg.Destroy;
begin
  if FThread <> nil then
    FThread.Terminate;
  inherited Destroy;
end;

procedure TPerformanceDlg.CloseBtnClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TPerformanceDlg.FormCreate(Sender: TObject);
begin
  AlignMnt.ItemIndex := 0;
  IntervalSize.ItemIndex := 0;
  FThread := TPerformanceThread.Create(Self, FImage);
end;

procedure TPerformanceDlg.PFBoxChange(Sender: TObject);
begin
  case PFBox.ItemIndex of
    0: FPixelFormatID := pfPAL8;
    1: FPixelFormatID := pfRGB555;
    2: FPixelFormatID := pfRGB565;
    3: FPixelFormatID := pfRGB24;
    4: FPixelFormatID := pfRGB32;
  end;
end;

procedure TPerformanceDlg.SetPixelFormatID(Value: Integer);
begin
  case Value of
    pfPAL8: PFBox.ItemIndex := 0;
    pfRGB555: PFBox.ItemIndex := 1;
    pfRGB565: PFBox.ItemIndex := 2;
    pfRGB24: PFBox.ItemIndex := 3;
    pfRGB32: PFBox.ItemIndex := 4;
  end;
  FPixelFormatID := Value;
end;

procedure TPerformanceDlg.IntervalSizeChange(Sender: TObject);
begin
  FThread.FReset := True;
end;

end.
