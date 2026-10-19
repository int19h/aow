"""Emit Pascal unit skeletons: one unit per game module, every class with its fields at the right offsets
and its methods in VMT order, plus stub implementations so that Free Pascal can compile the result.

Usage: emit_pascal.py <classes.json> <signatures dir> <out dir> [module ...]

Sources:
  classes.json          class -> module, parent, size, vmt slots (offset, name, target), fields (offset -> name/type/size)
  signatures/<mod>.json Ghidra functions: name "Unit.TClass.Method@hash" or "TClass.vmtNN", params, return type

What the skeleton preserves on purpose: class hierarchy, instance size and field offsets (padding fills the
gaps), the order of virtual methods (the VMT layout), and method parameter counts. Parameter and field
types are the decompiler's guesses and are marked as such. The Borland packages (vcl30 and friends) are
emitted as skeletons too, so the result depends on nothing but the System unit. Nothing here is final
source; it is the frame that recovered method bodies get pasted into.
"""
import json, os, re, sys, collections

C_TO_PAS = {'byte': 'Byte', 'undefined1': 'Byte', 'bool': 'Boolean', 'char': 'Shortint', 'short': 'Smallint',
            'ushort': 'Word', 'word': 'Word', 'undefined2': 'Word', 'int': 'Integer', 'undefined4': 'Integer',
            'uint': 'Cardinal', 'undefined': 'Byte', 'float': 'Single', 'double': 'Double', 'longlong': 'Int64',
            'ulonglong': 'QWord', 'AnsiString': 'string', 'pointer': 'Pointer', 'void': ''}
SIZE_OF = {'Byte': 1, 'Boolean': 1, 'Shortint': 1, 'Smallint': 2, 'Word': 2, 'Integer': 4, 'Cardinal': 4,
           'Single': 4, 'Double': 8, 'Int64': 8, 'QWord': 8, 'string': 4, 'Pointer': 4, 'PChar': 4}
PAS_KEYWORDS = set('and array as asm begin case class const constructor destructor dispinterface div do downto else end '
                   'except exports file finalization finally for function goto if implementation in inherited initialization '
                   'inline interface is label library mod nil not object of or out packed procedure program property raise '
                   'record repeat resourcestring set shl shr string then threadvar to try type unit until uses var while with xor '
                   'absolute abstract assembler automated cdecl default dynamic export external far forward index message name '
                   'near nodefault override pascal private protected public published read readonly register reintroduce '
                   'resident safecall stdcall stored virtual write writeonly result self operator'.split())
# the Borland runtime packages, emitted first; everything else may depend on them
BASE_MODULES = ['vcl30.dpl', 'VCLX30.DPL', 'VCLDB30.DPL']


def ident(s):
    s = re.sub(r'[^A-Za-z0-9_]', '_', s or '')
    if not s or s[0].isdigit():
        s = '_' + s
    if s.lower() in PAS_KEYWORDS:
        s += '_'
    return s


def unit_of(module):
    return ident(re.sub(r'\.(dpl|exe)$', '', module, flags=re.I))


class Emitter:
    def __init__(self, classes, sig_dir):
        self.classes = classes
        self.sig_dir = sig_dir
        self.slots = {}          # cls -> list of dicts {name, params, ret, kind, introduced_in}
        self.children = collections.defaultdict(list)
        for c, e in classes.items():
            self.children[e['parent']].append(c)

    # ---------- types
    def pas_type(self, ctype, size=0):
        t = (ctype or '').strip()
        base = t.rstrip('* ').strip()
        stars = t.count('*')
        if base.startswith('T') and base in self.classes and stars <= 1:
            return base
        if base.endswith('_vtbl'):
            return 'Pointer'
        if stars >= 1:
            return 'PChar' if base == 'char' else 'Pointer'
        if t.startswith('byte['):
            return 'array[0..%d] of Byte' % (int(t[5:-1]) - 1)
        if t in C_TO_PAS:
            return C_TO_PAS[t]
        m = re.match(r'(\w+)\((tk\w+)\)', t)         # RTTI style "Boolean(tkEnumeration)"
        if m:
            b, kind = m.groups()
            if b in self.classes: return b
            if kind == 'tkInteger': return {1: 'Byte', 2: 'Word'}.get(size, 'Integer')
            if kind == 'tkEnumeration': return 'Boolean' if b == 'Boolean' else 'Byte'
            if kind in ('tkString', 'tkLString'): return 'string'
            if kind == 'tkMethod': return 'TMethod'
            if kind == 'tkClass': return 'TObject'
            if kind == 'tkFloat': return 'Double' if size == 8 else 'Single'
            return 'Integer'
        if size == 1: return 'Byte'
        if size == 2: return 'Word'
        if size == 8: return 'Double'
        return 'Integer'

    # ---------- signatures
    def load_signatures(self, module):
        path = os.path.join(self.sig_dir, module + '.json')
        by_addr = {}
        if os.path.exists(path):
            for fn in json.load(open(path, encoding='utf-8')):
                by_addr[int(fn['addr'], 16)] = fn
        return by_addr

    def sig_from(self, fn):
        params, ret = [], ''
        if fn:
            for p in fn['params'][1:]:            # skip Self
                pname = ident(p['name'])
                if pname.startswith('param_'):
                    pname = 'A' + pname[6:]
                params.append((pname, self.pas_type(p['type'])))
            if fn['ret'] not in ('void', 'undefined', None):
                ret = self.pas_type(fn['ret'])
        return params, ret

    # ---------- per-class slot tables (parents first)
    def build_slots(self, cls, sigs_by_module):
        if cls in self.slots:
            return self.slots[cls]
        e = self.classes[cls]
        parent = e['parent'] if e['parent'] in self.classes else None
        pslots = self.build_slots(parent, sigs_by_module) if parent else []
        sigs = sigs_by_module.setdefault(e['module'], self.load_signatures(e['module']))
        out = []
        for i, slot in enumerate(e['vmt']):
            fn = sigs.get(int(slot['target'], 16))
            own = bool(slot.get('own'))
            if i < len(pslots):
                base = dict(pslots[i])
                base['kind'] = 'override' if own else 'inherited'
                base['fn'] = fn if own else None
                out.append(base)
            else:
                params, ret = self.sig_from(fn)
                name = ident(slot['name'] or 'vmt%02X' % slot['offset'])
                out.append(dict(name=name, params=params, ret=ret, kind='virtual' if own else 'abstract',
                                introduced_in=cls, fn=fn))
        # unique names within the class (two different slots may carry the same short name)
        seen = collections.Counter()
        for s in out:
            seen[s['name'].lower()] += 1
        dup = collections.Counter()
        for s in out:
            k = s['name'].lower()
            if seen[k] > 1 and s.get('introduced_in') == cls:
                dup[k] += 1
                if dup[k] > 1:
                    s['name'] = '%s_%d' % (s['name'], dup[k])
        self.slots[cls] = out
        return out

    # ---------- emission
    # TObject methods that a class may override; their shape is fixed by System, not by the decompiler
    SYSTEM_OVERRIDES = {
        'newinstance': ('class function NewInstance: TObject; override;',
                        'class function %s.NewInstance: TObject;\nbegin\n  Result := inherited NewInstance;\nend;\n'),
        'freeinstance': ('procedure FreeInstance; override;',
                         'procedure %s.FreeInstance;\nbegin\n  inherited FreeInstance;\nend;\n'),
        'defaulthandler': ('procedure DefaultHandler(var Message); override;',
                           'procedure %s.DefaultHandler(var Message);\nbegin\n  inherited DefaultHandler(Message);\nend;\n'),
        'safecallexception': None, 'dispatch': None, 'classtype': None, 'free': None, 'instancesize': None,
        'afterconstruction': None, 'beforedestruction': None, 'cleanupinstance': None, 'initinstance': None,
    }

    def decl(self, cls, name, params, ret, kind, directive):
        if name.lower() in self.SYSTEM_OVERRIDES:
            spec = self.SYSTEM_OVERRIDES[name.lower()]
            if spec is None:
                return None, None
            return spec[0], spec[1] % cls
        plist = '(%s)' % '; '.join('%s: %s' % p for p in params) if params else ''
        if kind == 'constructor':
            head = 'constructor %s%s;' % (name, plist)
            body = 'constructor %s.%s%s;\nbegin\nend;\n' % (cls, name, plist)
        elif kind == 'destructor':
            head = 'destructor %s;' % name
            body = 'destructor %s.%s;\nbegin\nend;\n' % (cls, name)
        elif ret:
            head = 'function %s%s: %s;' % (name, plist, ret)
            body = 'function %s.%s%s: %s;\nbegin\n  Result := Default(%s);\nend;\n' % (cls, name, plist, ret, ret)
        else:
            head = 'procedure %s%s;' % (name, plist)
            body = 'procedure %s.%s%s;\nbegin\nend;\n' % (cls, name, plist)
        if directive:
            head += ' ' + directive
        return head, body

    def emit_module(self, module, out_dir, sigs_by_module):
        classes = self.classes
        # parents before children, so that forward references only go through the forward block
        ordered, seen = [], set()
        def visit(c):
            if c in seen or classes[c]['module'] != module or c == 'TObject':
                return                        # TObject is System's; never redeclare it
            p = classes[c]['parent']
            if p in classes and classes[p]['module'] == module:
                visit(p)
            seen.add(c); ordered.append(c)
        for c in sorted(classes):
            if classes[c]['module'] == module and c != 'TObject':
                visit(c)
        if not ordered:
            return 0
        sigs = sigs_by_module.setdefault(module, self.load_signatures(module))
        deps = set()
        for c in ordered:
            e = classes[c]
            for t in [e['parent']] + [(fd.get('type') or '').rstrip('* ') for fd in e['fields'].values()]:
                if t in classes and classes[t]['module'] != module and t != 'TObject':
                    deps.add(classes[t]['module'])
            for s in self.build_slots(c, sigs_by_module):
                for _, pt in s['params']:
                    if pt in classes and classes[pt]['module'] != module:
                        deps.add(classes[pt]['module'])
                if s['ret'] in classes and classes[s['ret']]['module'] != module:
                    deps.add(classes[s['ret']]['module'])
        deps.discard(module)
        L = []
        L.append('unit %s;' % unit_of(module))
        L.append('')
        L.append('{$MODE DELPHI}{$H+}{$WARNINGS OFF}{$HINTS OFF}')
        L.append('{ Skeleton generated by tools/emit_pascal.py from the game binaries. Field offsets, instance sizes and the')
        L.append('  order of virtual methods follow the original VMTs. Types are decompiler guesses unless noted. }')
        L.append('')
        L.append('interface')
        L.append('')
        if deps:
            L.append('uses')
            L.append('  %s;' % ', '.join(unit_of(d) for d in sorted(deps)))
            L.append('')
        L.append('type')
        L.append('  TMethod = record Code, Data: Pointer; end;' if module in BASE_MODULES[:1] else '  { forward declarations }')
        for c in ordered:
            L.append('  %s = class;' % c)
        L.append('')
        impl = []
        nmethods = 0
        for c in ordered:
            e = classes[c]
            parent = e['parent'] if e['parent'] in classes else 'TObject'
            psize = classes[parent]['size'] if parent in classes else 4
            slots = self.build_slots(c, sigs_by_module)
            L.append('  { instance size %d, VMT %s, %d virtual slots }' % (e['size'], e.get('vmt_va', '?'), len(slots)))
            L.append('  %s = class(%s)' % (c, parent))
            # ---- fields
            own = sorted((int(o), fd) for o, fd in e['fields'].items() if psize <= int(o) < e['size'])
            L.append('  private')
            pos = psize
            used = set()
            for off, fd in own:
                if off < pos:
                    continue
                if off > pos:
                    L.append('    _pad_%X: array[0..%d] of Byte;' % (pos, off - pos - 1))
                    pos = off
                t = self.pas_type(fd.get('type'), fd.get('size') or 0)
                if t.startswith('array'):
                    tsize = int(re.search(r'\.\.(\d+)', t).group(1)) + 1
                else:
                    tsize = SIZE_OF.get(t, 4)
                if pos + tsize > e['size']:
                    break
                name = ident(fd.get('name') or 'field_%X' % off)
                base_name, k = name, 2
                while name.lower() in used or name.lower() == c.lower():
                    name = '%s_%d' % (base_name, k); k += 1
                used.add(name.lower())
                L.append('    { +$%02X %s } %s: %s;' % (off, fd.get('src', ''), name, t))
                pos += tsize
            if pos < e['size']:
                L.append('    _pad_%X: array[0..%d] of Byte;' % (pos, e['size'] - pos - 1))
            # ---- methods
            L.append('  public')
            declared = set()
            for i, s in enumerate(slots):
                if s['kind'] == 'inherited':
                    continue
                name = s['name']
                kind = 'constructor' if name.lower() == 'create' else 'method'
                if s['kind'] == 'abstract':
                    directive = 'virtual; abstract;'
                elif s['kind'] == 'virtual':
                    directive = 'virtual;'
                else:
                    directive = 'override;'
                head, body = self.decl(c, name, s['params'], s['ret'], kind, directive)
                if head is None:
                    continue
                L.append('    { slot +$%03X } %s' % (4 * i, head))
                if s['kind'] != 'abstract':
                    impl.append(body)
                declared.add(name.lower())
                nmethods += 1
            fx = e['fixed'].get('Destroy', {})
            if (fx.get('symbol') or '').split('.')[-2:-1] == [c]:
                head, body = self.decl(c, 'Destroy', [], '', 'destructor', 'override;')
                L.append('    %s' % head)
                impl.append(body)
                declared.add('destroy')
                nmethods += 1
            statics = []
            for addr, fn in sigs.items():
                m = method_of(fn['name'], c)
                if m and not m.startswith('vmt') and ident(m).lower() not in declared:
                    statics.append((addr, ident(m), fn))
            for addr, m, fn in sorted(statics):
                if m.lower() in declared:
                    continue
                params, ret = self.sig_from(fn)
                kind = 'constructor' if m.lower() == 'create' else ('destructor' if m.lower() == 'destroy' else 'method')
                head, body = self.decl(c, m, params, ret, kind, '')
                declared.add(m.lower())
                if head is None:
                    continue
                L.append('    %s' % head)
                impl.append(body)
                nmethods += 1
            L.append('  end;')
            L.append('')
        L.append('implementation')
        L.append('')
        L.extend(impl)
        L.append('end.')
        os.makedirs(out_dir, exist_ok=True)
        with open(os.path.join(out_dir, unit_of(module) + '.pas'), 'w', encoding='latin1', errors='replace') as fh:
            fh.write('\n'.join(L) + '\n')
        return nmethods


def method_of(fn_name, cls):
    n = fn_name.split('@')[0]
    parts = n.split('.')
    if len(parts) >= 2 and parts[-2] == cls:
        return parts[-1]
    return None


def main():
    classes = json.load(open(sys.argv[1], encoding='utf-8'))['classes']
    sig_dir, out_dir = sys.argv[2], sys.argv[3]
    all_modules = sorted(set(e['module'] for e in classes.values()))
    modules = sys.argv[4:] or [m for m in BASE_MODULES if m in all_modules] + [m for m in all_modules if m not in BASE_MODULES]
    em = Emitter(classes, sig_dir)
    sigs_by_module = {}
    total = 0
    for m in modules:
        n = em.emit_module(m, out_dir, sigs_by_module)
        print('%-18s %6d methods' % (m, n))
        total += n
    print('total methods:', total)


if __name__ == '__main__':
    main()
