unit AoWReg;

{ Draft declarations of AoWReg, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TAoWRegistry = class;

  TDetailLevel = (dtlLow, dtlNormal, dtlHigh);  { ot=1 }
  TReadWriteMode = (rwRead, rwWrite);  { ot=1 }
  TWindowPopupEvent = (wpCombat, wpDiplomacy, wpSpellResearched, wpSpellReady, wpRebellion, wpPartyDamage, wpHeroUpgrade, wpHeroJoin);  { ot=1 }
  TWindowPopupEvents = set of TWindowPopupEvent; { ot=1 }
  TCombatResolveMode = (crmChoose, crmAlwaysFC, crmAlwaysTC);  { ot=1 }
  TMovementSpeed = (mmsNormal, mmsFast, mmsTurbo);  { ot=1 }
  TAoWLanguage = (alAuto, alEnglish, alGerman, alFrench, alSpanish, alItalian);  { ot=1 }

  { TAoWRegistry (instance size 24, VMT 55703984) }
  TAoWRegistry = class(TRegistry)
  public
    procedure AssociateAoWMap(A1: Integer);  { draft }
    procedure rwInteger(A1: Integer; A2: Integer);  { draft }
    procedure rwBool(A1: Integer; A2: Integer);  { draft }
    procedure rwString(A1: Integer; A2: Integer);  { draft }
    procedure rwBinaryData(A1: Integer; A2: Integer);  { draft }
    procedure rwRect(A1: Integer; A2: Integer);  { draft }
    procedure GetRectangle(A1: Integer; A2: Integer);  { draft }
    procedure SetRectangle(A1: Integer; A2: Integer);  { draft }
    procedure GetBoolean(A1: Integer);  { draft }
    procedure SetBoolean(A1: Integer; A2: Byte);  { draft }
    procedure GetString(A1: Integer; A2: Integer);  { draft }
    procedure SetString(A1: Integer; A2: Integer);  { draft }
    procedure GetInteger(A1: Integer);  { draft }
    procedure SetInteger(A1: Integer; A2: Integer);  { draft }
    procedure GetDeveloper;  { draft }
    procedure SetDeveloper(A1: Byte; A2: Integer);  { draft }
    procedure GetSkipIntro(A1: Integer; A2: Integer);  { draft }
    procedure SetSkipIntro(A1: Byte; A2: Integer);  { draft }
    procedure GetDisplayMode(A1: Integer; A2: Integer);  { draft }
    procedure SetDisplayMode(A1: Integer; A2: Integer);  { draft }
    procedure GetDisplayWidth(A1: Integer; A2: Integer);  { draft }
    procedure SetDisplayWidth(A1: Integer; A2: Integer);  { draft }
    procedure GetDisplayHeight(A1: Integer; A2: Integer);  { draft }
    procedure SetDisplayHeight(A1: Integer; A2: Integer);  { draft }
    procedure GetSurfaceInVMem(A1: Integer; A2: Integer);  { draft }
    procedure SetSurfaceInVMem(A1: Byte; A2: Integer);  { draft }
    procedure GetAllowResolutionSwitches(A1: Integer; A2: Integer);  { draft }
    procedure SetAllowResolutionSwitches(A1: Byte; A2: Integer);  { draft }
    procedure GetDebugMode(A1: Integer; A2: Integer);  { draft }
    procedure SetDebugMode(A1: Byte; A2: Integer);  { draft }
    procedure GetRootDirectory(A1: Integer);  { draft }
    procedure SetRootDirectory(A1: Integer; A2: Integer);  { draft }
    procedure GetLanguage(A1: Integer; A2: Integer);  { draft }
    procedure SetLanguage(A1: Integer; A2: Integer);  { draft }
    procedure GetSoundQuality(A1: Integer; A2: Integer);  { draft }
    procedure SetSoundQuality(A1: Integer; A2: Integer);  { draft }
    procedure GetMusicVolume(A1: Integer; A2: Integer);  { draft }
    procedure SetMusicVolume(A1: Integer; A2: Integer);  { draft }
    procedure GetSFXVolume(A1: Integer; A2: Integer);  { draft }
    procedure SetSFXVolume(A1: Integer; A2: Integer);  { draft }
    procedure GetMainWindowPosition(A1: Integer);  { draft }
    procedure SetMainWindowPosition(A1: Integer);  { draft }
    procedure GetMainWindowState(A1: Integer; A2: Integer);  { draft }
    procedure SetMainWindowState(A1: Integer; A2: Integer);  { draft }
    procedure GetMapWindowPosition(A1: Integer);  { draft }
    procedure SetMapWindowPosition(A1: Integer);  { draft }
    procedure GetShadowsEnabled(A1: Integer; A2: Integer);  { draft }
    procedure SetShadowsEnabled(A1: Byte; A2: Integer);  { draft }
    procedure GetSFXEnabled(A1: Integer; A2: Integer);  { draft }
    procedure SetSFXEnabled(A1: Byte; A2: Integer);  { draft }
    procedure GetMusicEnabled(A1: Integer; A2: Integer);  { draft }
    procedure SetMusicEnabled(A1: Byte; A2: Integer);  { draft }
    procedure GetUseDirectSound(A1: Integer; A2: Integer);  { draft }
    procedure SetUseDirectSound(A1: Byte; A2: Integer);  { draft }
    procedure GetDetailLevel(A1: Integer; A2: Integer);  { draft }
    procedure SetDetailLevel(A1: Integer; A2: Integer);  { draft }
    procedure GetStartupDirectory(A1: Integer);  { draft }
    procedure SetStartupDirectory(A1: Integer; A2: Integer);  { draft }
    procedure GetLogTokenEvents(A1: Integer; A2: Integer);  { draft }
    procedure SetLogTokenEvents(A1: Byte; A2: Integer);  { draft }
    procedure GetAutoSave(A1: Integer; A2: Integer);  { draft }
    procedure SetAutoSave(A1: Byte; A2: Integer);  { draft }
    procedure GetAutoDebugSave(A1: Integer; A2: Integer);  { draft }
    procedure SetAutoDebugSave(A1: Byte; A2: Integer);  { draft }
    procedure GetFastMovementEnabled(A1: Integer; A2: Integer);  { draft }
    procedure SetFastMovementEnabled(A1: Byte; A2: Integer);  { draft }
    procedure GetClassicWindowPopupEvents(A1: Integer; A2: Integer);  { draft }
    procedure SetClassicWindowPopupEvents(A1: Byte; A2: Integer);  { draft }
    procedure GetSimultaneousWindowPopupEvents(A1: Integer; A2: Integer);  { draft }
    procedure SetSimultaneousWindowPopupEvents(A1: Byte; A2: Integer);  { draft }
    procedure GetCombatResolveMode(A1: Integer; A2: Integer);  { draft }
    procedure SetCombatResolveMode(A1: Byte; A2: Integer);  { draft }
    procedure GetMovementSpeed(A1: Integer; A2: Integer);  { draft }
    procedure SetMovementSpeed(A1: Byte; A2: Integer);  { draft }
    procedure GetLocalEmailAddress(A1: Integer);  { draft }
    procedure SetLocalEmailAddress(A1: Integer; A2: Integer);  { draft }
    procedure GetSMTPServer(A1: Integer);  { draft }
    procedure SetSMTPServer(A1: Integer; A2: Integer);  { draft }
    procedure GetPOP3Server(A1: Integer);  { draft }
    procedure SetPOP3Server(A1: Integer; A2: Integer);  { draft }
    procedure GetPOP3UserName(A1: Integer);  { draft }
    procedure SetPOP3UserName(A1: Integer; A2: Integer);  { draft }
    procedure GetPOP3Password(A1: Integer);  { draft }
    procedure SetPOP3Password(A1: Integer);  { draft }
    procedure GetAttachmentDirectory(A1: Integer);  { draft }
    procedure SetAttachmentDirectory(A1: Integer; A2: Integer);  { draft }
    procedure GetCheckEmailFrequency(A1: Integer; A2: Integer);  { draft }
    procedure SetCheckEmailFrequency(A1: Integer; A2: Integer);  { draft }
    procedure GetEmailGamesCRC;  { draft }
    procedure SetEmailGamesCRC(A1: Integer);  { draft }
    procedure RegisterDPlayLobbyServer;  { draft }
  end;

procedure ValidAoWCD(A1: Byte);  { draft }
procedure AoWCDInserted(A1: Integer; A2: Integer; A3: Integer);  { draft }
procedure GuaranteeAoWCD(A1: Integer; A2: Integer);  { draft }

implementation

procedure TAoWRegistry.AssociateAoWMap(A1: Integer);
begin end;

procedure TAoWRegistry.rwInteger(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.rwBool(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.rwString(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.rwBinaryData(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.rwRect(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetRectangle(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetRectangle(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetBoolean(A1: Integer);
begin end;

procedure TAoWRegistry.SetBoolean(A1: Integer; A2: Byte);
begin end;

procedure TAoWRegistry.GetString(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetString(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetInteger(A1: Integer);
begin end;

procedure TAoWRegistry.SetInteger(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetDeveloper;
begin end;

procedure TAoWRegistry.SetDeveloper(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetSkipIntro(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetSkipIntro(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetDisplayMode(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetDisplayMode(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetDisplayWidth(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetDisplayWidth(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetDisplayHeight(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetDisplayHeight(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetSurfaceInVMem(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetSurfaceInVMem(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetAllowResolutionSwitches(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetAllowResolutionSwitches(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetDebugMode(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetDebugMode(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetRootDirectory(A1: Integer);
begin end;

procedure TAoWRegistry.SetRootDirectory(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetLanguage(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetLanguage(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetSoundQuality(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetSoundQuality(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetMusicVolume(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetMusicVolume(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetSFXVolume(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetSFXVolume(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetMainWindowPosition(A1: Integer);
begin end;

procedure TAoWRegistry.SetMainWindowPosition(A1: Integer);
begin end;

procedure TAoWRegistry.GetMainWindowState(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetMainWindowState(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetMapWindowPosition(A1: Integer);
begin end;

procedure TAoWRegistry.SetMapWindowPosition(A1: Integer);
begin end;

procedure TAoWRegistry.GetShadowsEnabled(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetShadowsEnabled(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetSFXEnabled(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetSFXEnabled(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetMusicEnabled(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetMusicEnabled(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetUseDirectSound(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetUseDirectSound(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetDetailLevel(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetDetailLevel(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetStartupDirectory(A1: Integer);
begin end;

procedure TAoWRegistry.SetStartupDirectory(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetLogTokenEvents(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetLogTokenEvents(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetAutoSave(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetAutoSave(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetAutoDebugSave(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetAutoDebugSave(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetFastMovementEnabled(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetFastMovementEnabled(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetClassicWindowPopupEvents(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetClassicWindowPopupEvents(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetSimultaneousWindowPopupEvents(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetSimultaneousWindowPopupEvents(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetCombatResolveMode(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetCombatResolveMode(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetMovementSpeed(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetMovementSpeed(A1: Byte; A2: Integer);
begin end;

procedure TAoWRegistry.GetLocalEmailAddress(A1: Integer);
begin end;

procedure TAoWRegistry.SetLocalEmailAddress(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetSMTPServer(A1: Integer);
begin end;

procedure TAoWRegistry.SetSMTPServer(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetPOP3Server(A1: Integer);
begin end;

procedure TAoWRegistry.SetPOP3Server(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetPOP3UserName(A1: Integer);
begin end;

procedure TAoWRegistry.SetPOP3UserName(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetPOP3Password(A1: Integer);
begin end;

procedure TAoWRegistry.SetPOP3Password(A1: Integer);
begin end;

procedure TAoWRegistry.GetAttachmentDirectory(A1: Integer);
begin end;

procedure TAoWRegistry.SetAttachmentDirectory(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetCheckEmailFrequency(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.SetCheckEmailFrequency(A1: Integer; A2: Integer);
begin end;

procedure TAoWRegistry.GetEmailGamesCRC;
begin end;

procedure TAoWRegistry.SetEmailGamesCRC(A1: Integer);
begin end;

procedure TAoWRegistry.RegisterDPlayLobbyServer;
begin end;

procedure ValidAoWCD(A1: Byte);
begin end;

procedure AoWCDInserted(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure GuaranteeAoWCD(A1: Integer; A2: Integer);
begin end;


initialization
finalization

end.
