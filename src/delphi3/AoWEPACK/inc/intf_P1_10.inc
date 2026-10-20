{ Interface declaration run owned by P1. }
  { TFlagControl (instance size 20, VMT 557149F8) }
  TFlagControl = class(TEControlStyleObject)
  public
    F_FlagControl_0C: Integer;
    F_FlagControl_10: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ShowFlag(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure ShowFlagEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
    procedure ShowStructureFlag(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure ShowStructureFlagEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
  end;

  { TAoWHSSet (instance size 160, VMT 55714AB8) }
  TAoWHSSet = class(THSSet)
  public
    F_AoWHSSet_48: Integer;
    F_AoWHSSet_4C: Integer;
    F_AoWHSSet_50: Integer;
    F_AoWHSSet_54: Integer;
    F_AoWHSSet_58: Integer;
    F_AoWHSSet_5C: Integer;
    F_AoWHSSet_60: Integer;
    F_AoWHSSet_64: Integer;
    F_AoWHSSet_68: Integer;
    F_AoWHSSet_6C: Integer;
    F_AoWHSSet_70: Integer;
    F_AoWHSSet_74: Integer;
    F_AoWHSSet_78: Integer;
    F_AoWHSSet_7C: Integer;
    F_AoWHSSet_80: Integer;
    F_AoWHSSet_84: Integer;
    F_AoWHSSet_88: Integer;
    F_AoWHSSet_8C: Integer;
    F_AoWHSSet_90: Integer;
    F_AoWHSSet_94: Integer;
    F_AoWHSSet_98: Integer;
    F_AoWHSSet_9C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetFileCRC(A1: Integer; A2: Integer);  { draft }
    procedure RetrieveHSSCRC;  { draft }
  end;

