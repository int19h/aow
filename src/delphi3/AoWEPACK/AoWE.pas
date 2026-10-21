unit AoWE;

{ Draft declarations of AoWE, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, EventLog, Animation, AoWReg;

{$I inc\intf_P1_01.inc}
{$I inc\intf_P2_01.inc}
{$I inc\intf_P1_02.inc}
{$I inc\intf_P4_01.inc}
{$I inc\intf_P1_03.inc}
{$I inc\intf_P5_01.inc}
{$I inc\intf_P1_04.inc}
{$I inc\intf_P2_02.inc}
{$I inc\intf_P1_05.inc}
{$I inc\intf_P2_03.inc}
{$I inc\intf_P1_06.inc}
{$I inc\intf_P2_04.inc}
{$I inc\intf_P1_07.inc}
{$I inc\intf_P2_05.inc}
{$I inc\intf_P1_08.inc}
{$I inc\intf_P2_06.inc}
{$I inc\intf_P5_02.inc}
{$I inc\intf_P2_07.inc}
{$I inc\intf_P1_09.inc}
{$I inc\intf_P5_03.inc}
{$I inc\intf_P1_10.inc}
{$I inc\intf_P5_04.inc}
{$I inc\intf_P1_11.inc}
{$I inc\intf_P3_01.inc}
{$I inc\intf_P5_05.inc}
{$I inc\intf_P3_02.inc}
{$I inc\intf_P5_06.inc}
{$I inc\intf_P1_12.inc}
{$I inc\intf_P5_07.inc}
{$I inc\intf_P4_02.inc}
{$I inc\intf_P5_08.inc}
{$I inc\intf_P2_08.inc}
{$I inc\intf_P1_13.inc}
{$I inc\intf_P2_09.inc}
{$I inc\intf_P4_03.inc}
{$I inc\intf_P2_10.inc}
{$I inc\intf_P1_14.inc}
{$I inc\intf_P5_09.inc}

implementation

uses ExptIntf;


{$I inc\P1.inc}
{$I inc\P2.inc}
{$I inc\P3.inc}
{$I inc\P4.inc}
{$I inc\P5.inc}

initialization
  TPlayerTypeRStr[0] := HumanRStr;
  TPlayerTypeRStr[1] := CPUWarriorRStr;
  TPlayerTypeRStr[2] := CPUKnightRStr;
  TPlayerTypeRStr[3] := CPULordRStr;
  TPlayerTypeRStr[4] := IndependentRStr;
  TPlayerTypeRStr[5] := FreeRStr;
  TPlayerTypeRStr[6] := CPUKingRStr;
  TPlayerTypeRStr[7] := CPUEmperorRStr;
finalization

end.
