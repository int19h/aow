import pefile,capstone,re,sys
exe=sys.argv[1]; mp=exe[:-4]+'.map'; pat=sys.argv[2] if len(sys.argv)>2 else r'\w+'
pe=pefile.PE(exe); base=pe.OPTIONAL_HEADER.ImageBase; data=pe.get_memory_mapped_image()
md=capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_32)
text=base+pe.sections[0].VirtualAddress
seen=set()
syms=[]
for l in open(mp):
    m=re.match(r'\s*0001:([0-9A-F]{8})\s+(\S+)\s*$',l)
    if m and m.group(2) not in seen: seen.add(m.group(2)); syms.append((int(m.group(1),16),m.group(2)))
syms.sort()
for k,(off,n) in enumerate(syms):
    if not re.fullmatch(pat,n): continue
    end=syms[k+1][0] if k+1<len(syms) else off+64
    va=text+off
    print('==', n)
    for i in md.disasm(bytes(data[va-base:text+end-base]),va): print('   ', i.mnemonic, i.op_str)
