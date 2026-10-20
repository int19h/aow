M=2**32
inv5=pow(5,-1,M)
V={'Integer':0xB585C686,'Shortint':0x708564D0,'Byte':0xE2E6A189,'Boolean':0xBE8E9287,'Word':0xE2FF1222,'Char':0x73B29A84,
   'Smallint':0x75C81A3A,'Cardinal':0x5F4DF326,'ByteBool':0x5C480289,'WordBool':0x4F570022,'LongBool':0x41FA2DC8,'Pointer':0xBCFDB771,'PChar':0x70CBD8F4}
SZ={'Integer':4,'Shortint':1,'Byte':1,'Boolean':1,'Word':2,'Char':1,'Smallint':2,'Cardinal':4,'ByteBool':1,'WordBool':2,'LongBool':4,'Pointer':4,'PChar':4}
def nh(s):
    h=0
    for c in s: h=(h*17+ord(c))%M
    return h
def rec(fields, name='', packed=False, ths=None):
    h=0x0B17B67F; off=0
    for f in fields:
        t = ths[f] if ths and f in ths else V[f]
        a = 1 if packed else SZ.get(f,4)
        off=(off+a-1)//a*a
        h=(5*h+0x73336EA7+5*(t+off))%M
        off+=SZ.get(f,4)
    return (h+nh(name))%M
