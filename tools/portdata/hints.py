"""Run-time class hints for view bases whose declared type is too weak (TObject, Pointer, an
ancestor smaller than the offset).  Each rule: (file suffix, base-expression regex, runtime
class, evidence).  The runtime class may be ('field-type', Class, offset): the declared type
of Class's field at that offset.  Hints only feed the "recommended" cast; the "resolution"
reported for the use stays the one the declared types give.
"""
import re

RULES = [
    ('AoWEPACK/MapCtrl.pas', r'^GetPlayersABI\(', 'TPlayer',
     'GetPlayersABI tail-jumps to TPlayerList.GetPlayers; the list is TAoWHSMap.FPlayers ($140)'),
    ('AoWEPACK/MapCtrl.pas', r'^Player$', 'TPlayer',
     'handler registered on a TPlayer event list ($C/$10/$14/$18 of GetPlayers(I), MapCtrl.pas:236-239); Sender is the player'),
    ('AoWEPACK/MapCtrl.pas', r'^Control$', ('field-type', 'TPlayer', 0x54),
     'PlayerMagicChanged is registered on Fields[$48] of the object at TPlayer+$54 (MapCtrl.pas:240); Sender is that object'),
    ('AoWEPACK/MapCtrl.pas', r'^(HS|Selection\.EventHS)$', 'TArmyHS',
     'guarded by Selection.EventHS is TArmyHS / Selection.FindClass(TArmyHS)'),
    ('', r'^Info\.MapField$', 'TAoWMapField',
     'AoW map fields are TAoWMapField; the $18 flags word is TAoWMapField.FFieldFlags'),
    ('AoWEPACK/Cave.pas', r'^Info\.Sender$', 'TMoveControl',
     'the same statement calls TMoveControl(Info.Sender).ExecuteExternalMove'),
    ('AoWEPACK/inc/Unit.PAS', r'^Owner$', 'TArmy',
     'the loop bound is TArmy(Owner).Count; units are owned by their army'),
    ('AoWEPACK/inc/Unit.PAS', r'^P2Spell\(TSpellControl\(AoWHSSet\.FSpellControl\), *(17|56)\)$', 'TUnitSpell',
     'low confidence: spells 17/56 feed a unit enchantment; the only Byte at $3C among TSpell descendants used for units is TUnitSpell.FUnitDispelResistance'),
    ('AoWEPACK/inc/Unit.PAS', r'^TUnitEnchantmentAbilityData\(P2AbilityData\(Self, *126\)\)\.FEnchantment$', 'TCosmeticSurgeryEnchantment',
     'ability 126 is cosmetic surgery; the only TUnitEnchantment descendant with a field at $20 is TCosmeticSurgeryEnchantment.FFaceIndex'),
    ('AoWEPACK/GlobalTargetSpells.pas', r'^A1$', 'TAoWEngine',
     'RegisterGlobalTargetSpells receives AoWE.AoWEngine (AoWEReg.pas:76); TAoWEngine.FGameSet at $64 is the TAoWHSSet the view reads'),
    ('AoWEPACK/GlobalTargetSpells.pas', r'^(Sender|Target)$', 'TTargetSelectionControl',
     'OnTargetSelectionChange is registered on TTargetSelectionControl change events; the view comment names TTargetSelectionControl'),
    ('AoWEPACK/inc/Unit.PAS', r'^Ability$', 'TAbility',
     'P2VMTAbility returns items of a TAbilityTypeList (TAbility objects)'),
]

# fields of external (VCL) classes, for views over objects whose class has no source here
EXTERNAL_FIELDS = {
    'TList': {0x4: ('FList', 'PPointerList', 'private'), 0x8: ('FCount', 'Integer', 'private'),
              0xC: ('FCapacity', 'Integer', 'private')},
}


def hint_for(file, base):
    for suffix, rx, cls, why in RULES:
        if file.endswith(suffix) and re.search(rx, base):
            return cls, why
    return None


RUNTIME_HINTS = None  # legacy name, unused
