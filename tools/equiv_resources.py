"""Delphi TResStringRec: opaque resource semantics, never numeric-ID equality."""
import collections
import struct
import sys


def text(image, identifier):
    """Return every language's raw UTF-16LE text; all reads pass through bytes_at."""
    if not 0 < identifier < 65536: raise ValueError('invalid resourcestring ID')
    directory = image.pe.OPTIONAL_HEADER.DATA_DIRECTORY[2]
    if hasattr(directory,'get_file_offset'):
        if image.bytes_at(image.base+directory.get_file_offset(),8)!=struct.pack('<II',directory.VirtualAddress,directory.Size):
            raise ValueError('resource directory header differs from parsed PE')
    base, limit = image.base + directory.VirtualAddress, directory.Size
    if not directory.VirtualAddress or not 16 <= limit <= 16*1024*1024:
        raise ValueError('missing/bad RT_STRING directory')
    def read(offset, size):
        if offset < 0 or offset+size > limit: raise ValueError('bad resource directory bound')
        data = image.bytes_at(base+offset, size)
        if len(data) != size: raise ValueError('truncated resource directory')
        return data
    def entries(offset):
        named, count = struct.unpack_from('<HH', read(offset,16),12)
        if named or count > 4096: raise ValueError('named/oversized resource directory')
        values = dict()
        for i in range(count):
            key, value = struct.unpack('<II',read(offset+16+i*8,8))
            if key in values or key & 0x80000000: raise ValueError('ambiguous resource entry')
            values[key] = value
        return values
    at = 0
    for key in (6, (identifier >> 4)+1):
        value = entries(at).get(key)
        if value is None or not value & 0x80000000: raise ValueError('unresolved RT_STRING ID')
        at = value & 0x7fffffff
    result = []
    for language, offset in sorted(entries(at).items()):
        if language>65535 or offset & 0x80000000: raise ValueError('bad RT_STRING language leaf')
        rva, size, _, reserved = struct.unpack('<IIII',read(offset,16))
        if reserved or not 32 <= size <= 131104: raise ValueError('bad RT_STRING block size')
        data = read(rva-directory.VirtualAddress,size)
        if len(data) != size: raise ValueError('truncated RT_STRING block')
        pos = 0; selected = None
        for index in range(16):
            if pos+2 > size: raise ValueError('truncated RT_STRING length')
            length = int.from_bytes(data[pos:pos+2],'little'); pos += 2
            if pos+2*length > size: raise ValueError('truncated RT_STRING text')
            if index == identifier & 15: selected = data[pos:pos+2*length]
            pos += 2*length
        if any(data[pos:]) or selected is None or not selected:
            raise ValueError('missing text or bad RT_STRING padding')
        result.append((language,selected))
    if not result: raise ValueError('unresolved RT_STRING language')
    return tuple(result)


def handle(d, side):
    """Recognize DLL hinstDLL / EXE GetModuleHandleA(NULL) startup stores."""
    image = (d.old,d.new)[side]; e = sys.modules[type(d).__module__]
    header = getattr(image.pe,'OPTIONAL_HEADER',None)
    if header is None: return None
    start = image.base+header.AddressOfEntryPoint
    code = e.decode(image,start,64)
    if code and code[0].mnemonic == 'jmp' and code[0].operands[0].type == e.X.X86_OP_IMM:
        start = code[0].operands[0].imm; code = e.decode(image,start,64)
    raw = image.bytes_at(start,35)
    if raw[:11] == bytes.fromhex('558bec53568b5d0c8b4508') and raw[11:13] == b'\xc6\x05' and raw[18:20] == b'\xc6\x05' and raw[25:26] == b'\xa3' and raw[30:31] == b'\xa3':
        return int.from_bytes(raw[31:35],'little')
    for ins in code:
        if ins.mnemonic != 'call' or ins.operands[0].type != e.X.X86_OP_IMM: continue
        target = ins.operands[0].imm; raw = image.bytes_at(target,32)
        cell = 15 if raw[13:15]==b'\x52\xa3' else 16 if raw[13:16]==b'\x52\x89\x05' else None
        if cell is None or raw[:4] != b'\x50\x6a\x00\xe8' or raw[8:9] != b'\xba' or raw[cell+4:cell+7] != b'\x89\x42\x04': continue
        called = target+8+int.from_bytes(raw[4:8],'little',signed=True)
        if (d.names[side].get(called,'').split('.')[-1] == 'GetModuleHandleA'
                or side==1 and d.map_addresses.get('GetModuleHandleA')==called):
            return int.from_bytes(raw[cell:cell+4],'little')
    return None


def records(d, side):
    image = (d.old,d.new)[side]; anchor = handle(d,side)
    result = {}
    if anchor is None: return result
    for address in sorted(d.relocs[side]):
        if address & 3 or not d.readonly(side,address,8): continue
        if d.u32(image,address) != anchor: continue
        raw = image.bytes_at(address,8)
        if len(raw) != 8 or not 0 < int.from_bytes(raw[4:],'little') < 65536: continue
        try: value = text(image,int.from_bytes(raw[4:],'little')); reason = ''
        except (ValueError,IndexError,AttributeError) as error: value = None; reason = str(error)
        result[address] = dict(module=anchor,id=int.from_bytes(raw[4:],'little'),text=value,reason=reason)
    return result


def install(d):
    d.resourcestrings = [records(d,s) for s in (0,1)]
    anchors = [handle(d,s) for s in (0,1)]
    if None in anchors or not d.bind(*anchors,'typed-content-record:module-startup-handle'): return
    for s,a in enumerate(anchors): d.names[s].setdefault(a,'resourcestring-module-handle')
    groups = [collections.defaultdict(set),collections.defaultdict(set)]
    for side in (0,1):
        for a,record in d.resourcestrings[side].items():
            if record['text'] is not None: groups[side][record['text']].add(a)
    for value, left in sorted(groups[0].items()):
        right = groups[1].get(value,set())
        pairs = {(a,d.forward[a]) for a in left if d.forward.get(a) in right}
        if len(left) == len(right) == 1: pairs.add((next(iter(left)),next(iter(right))))
        for a,b in sorted(pairs):
            if not all(d.readonly(s,p,8) for s,p in enumerate((a,b))): continue
            if d.bind(a,b,'typed-content-record:resourcestring'):
                d.storage_objects.append((a,b,8,'immutable-data','Delphi resourcestring record'))


def validate(relation,row):
    d = relation.d; values = []
    for side,a in enumerate(row[:2]):
        image = (d.old,d.new)[side]; raw = image.bytes_at(a,8)
        if len(raw) != 8 or a not in d.relocs[side]: relation.fail('bad resourcestring record at '+hex(a))
        try: values.append(text(image,int.from_bytes(raw[4:],'little')))
        except (ValueError,IndexError,AttributeError) as error: relation.fail('resourcestring '+hex(a)+': '+str(error))
    if values[0] != values[1]: relation.fail('RT_STRING text differs at %s / %s' % tuple(hex(a) for a in row[:2]))
    relation.checked[row]['resourcestring'] = dict(ids=[d.u32(img,a+4) for img,a in zip((d.old,d.new),row[:2])],
        texts=[dict(language=lang,utf16le=value.hex()) for lang,value in values[0]],module_identity='typed-content-record:module-startup-handle')
    # IDs have build-local meaning. Explicit observation of them remains forbidden.
    relation.opaque.add((row[0]+4,4))
    return {k:0 for k in range(4,8)}


def write_witness(d,side,address):
    """Search every executable byte, not a linear disassembly of mixed code/data."""
    e = sys.modules[type(d).__module__]; image = (d.old,d.new)[side]
    decoder = e.CS.Cs(e.CS.CS_ARCH_X86,e.CS.CS_MODE_32); decoder.detail=True
    references={a for a in d.relocs[side] if address<=d.u32(image,a)<address+8}; approved=set()
    for section in image.pe.sections:
        if not section.Characteristics & 0x20000000: continue
        start = image.base+section.VirtualAddress; data = image.bytes_at(start,section.Misc_VirtualSize)
        # 512 covers the largest x86 memory-write operand (FXSAVE). Decode every
        # possible instruction start before a matching displacement, including
        # unselected functions and instructions after embedded data/padding.
        for target in range(max(0,address-511),address+8):
            pattern = struct.pack('<I',target); pos = data.find(pattern)
            while pos >= 0:
                for begin in range(max(0,pos-14),pos):
                    ins = next(decoder.disasm(data[begin:begin+15],start+begin,count=1),None)
                    if not ins: continue
                    reference=(ins.address+ins.imm_offset==start+pos or ins.mnemonic=='lea' and ins.address+ins.disp_offset==start+pos)
                    if address <= target < address+8 and reference and ins.operands[0].type==e.X.X86_OP_REG and ins.mnemonic in ('mov','lea'):
                        # An address materialized outside the selection must have
                        # a checked read-only use too. No global indirect writer
                        # can hide behind an unrelated caller's H5 premise.
                        pointers={ins.operands[0].reg:target}; allowed=False
                        for use in decoder.disasm(data[begin+ins.size:begin+ins.size+128],ins.address+ins.size):
                            if use.mnemonic=='call':
                                callee=use.operands[0].imm if use.operands[0].type==e.X.X86_OP_IMM else None
                                name=d.names[side].get(callee,'')
                                if side==1 and d.map_addresses.get('LoadResString')==callee:name='LoadResString'
                                allowed=name in ('System.LoadResString','LoadResString') and pointers.get(e.X.X86_REG_EAX)==address
                                break
                            if use.mnemonic.startswith(('j','ret')): break
                            if any(o.type==e.X.X86_OP_MEM and o.access & e.CS.CS_AC_WRITE and (o.mem.base in pointers or o.mem.index in pointers) for o in use.operands):
                                return use.address,use.mnemonic+' '+use.op_str
                            if set(use.regs_access()[0]) & pointers.keys() and not (use.mnemonic=='mov' and len(use.operands)==2 and all(o.type==e.X.X86_OP_REG for o in use.operands)):
                                return use.address,'resourcestring pointer has unchecked use: '+use.mnemonic+' '+use.op_str
                            for o in use.operands:
                                if o.type==e.X.X86_OP_REG and o.access & e.CS.CS_AC_WRITE:
                                    value=pointers.get(use.operands[1].reg) if use.mnemonic=='mov' and len(use.operands)==2 and use.operands[1].type==e.X.X86_OP_REG else None
                                    pointers.pop(o.reg,None)
                                    if value is not None:pointers[o.reg]=value
                        if not allowed:return ins.address,'resourcestring address has unchecked use: '+ins.mnemonic+' '+ins.op_str
                        approved.add(start+pos)
                    if ins.address+ins.disp_offset != start+pos: continue
                    for op in ins.operands:
                        if op.type == e.X.X86_OP_MEM and op.access & e.CS.CS_AC_WRITE and not (op.mem.base or op.mem.index or op.mem.segment) and max(op.mem.disp & 0xffffffff,address)<min((op.mem.disp & 0xffffffff)+op.size,address+8):
                            return ins.address,ins.mnemonic+' '+ins.op_str
                pos = data.find(pattern,pos+1)
    if references-approved:return min(references-approved),'resourcestring address escapes into an unchecked relocation cell'
    return None
