"""Fable's below-prologue publication mutants and side-address collisions."""
from types import SimpleNamespace as NS
import unittest
import equiv as e
import equiv_events as events
from .support import build,call,Case


def published_temporary(kind,mutant):
    pub=bytes.fromhex('89e0a300204000');one=bytes.fromhex('c7042401000000');two=bytes.fromhex('c7042402000000')
    head=bytes.fromhex('6a00' if kind=='F7' else '50')
    tail=bytes.fromhex('83c40431c0c3' if kind=='F7' else '5831c0c3');extra=[]
    if kind=='F9_ext0':
        head+=b'\x54';head+=call(len(head))
        extra=[(0x1100,bytes.fromhex('8b442404a300204000c20400'))]
    else:head+=pub
    c,f=build(head+one+two+tail,head+((two+one if kind=='F8' else two) if mutant else one+two)+tail,
              extras_a=extra,extras_b=extra,bindings=[(0x402000,0x402000),(0x401100,0x401100)])
    for side in (0,1):c.inp.addresses.names[side][0x402000]='Fixture.Published'
    return c,f


def initialized_argument(mutant):
    head=lambda n:bytes.fromhex('83ec04c70424')+n.to_bytes(4,'little')+b'\x54'
    a,b=head(1),head(2 if mutant else 1);tail=bytes.fromhex('83c404c3')
    helper=bytes.fromhex('8b4424048b00c20400')
    return build(a+call(len(a))+tail,b+call(len(b))+tail,
                 extras_a=[(0x1100,helper)],extras_b=[(0x1100,helper)],bindings=[(0x401100,0x401100)])


def cases():
    for mutant in (True,False):
        yield Case('initialized_private_arg_'+('mut' if mutant else 'ctl'),
            lambda m=mutant:(lambda c,f:c.check(f))(*initialized_argument(m)),
            'reject' if mutant else 'prove:H1,H3,H6','Outgoing private argument loads must not create a false public-load H1 premise.')
    for kind in ('F5','F7','F8','F9_ext0'):
        for mutant in (True,False):
            yield Case(kind+('_swap' if kind=='F8' else '_mut') if mutant else kind+'_ctl',
                lambda k=kind,m=mutant:(lambda c,f:c.check(f))(*published_temporary(k,m)),
                'reject' if mutant else 'prove:H1,H6' if kind!='F9_ext0' else 'prove:H1,H3,H6',
                'A published or retained temporary must remain observable below the prologue extent.')


class EventOwnership(unittest.TestCase):
    def test_published_temporary_mutants_and_controls(self):
        for kind in ('F5','F7','F8','F9_ext0'):
            for mutant in (True,False):
                with self.subTest(kind=kind,mutant=mutant):
                    c,f=published_temporary(kind,mutant);r=c.check(f)
                    self.assertEqual(not mutant,r[0].startswith('PROVEN'),r)
    def record_collision(self,forward,cells,addr):
        st=e.arbitrary(e.DIAG,e.FLAGS)[0]
        addresses=NS(forward=forward,pointer_cells=[{},cells],immutable_data=[{},{}])
        st.ownership=NS(side=1,checker=NS(inp=NS(addresses=addresses)),base=st.regs['esp'],low=0,lowest=0)
        st.record_access=True;st.access_ins=NS(address=0x401000,mnemonic='mov',op_str='eax, [x]')
        events.record(st,'read',e.bv(addr),4,e.bv(5))
        return len(st.events)
    def test_compiled_mutable_address_is_not_remapped_to_a_cell(self):
        self.assertEqual(1,self.record_collision({0x402000:0x402008},{0x402008:(1,'r')},0x402000))
    def test_compiled_pointer_cell_is_not_remapped_away(self):
        self.assertEqual(0,self.record_collision({0x402008:0x402010},{0x402008:(1,'r')},0x402008))

    def test_unknown_esp_fails_closed_with_instruction(self):
        c,f=build('90c3','90c3');code=c.instructions(f)[0]
        info=dict(code=code,side=0,low=0,before={0:({'esp':0},),1:({},)})
        with self.assertRaisesRegex(e.Unsupported,'H2 ESP unknown at 0x401001'):
            e.Ownership(c,info,e.bv(0x10000))
    def test_unsupported_full_retry_keeps_h2_reason(self):
        from unittest.mock import patch
        c,f=build('90c3','90c3');attempts=[]
        def run(*args):
            attempts.append(1)
            if len(attempts)==1:
                c.ownership_failure=dict(pc='0x401000',instruction='push eax')
                return 'NOT PROVEN','ownership'
            return 'UNSUPPORTED','full-access route unavailable'
        with patch.object(c,'check_raw',side_effect=run):r=c._check(f)
        self.assertEqual('NOT PROVEN',r[0]);self.assertIn('H2 ownership unestablished at 0x401000 (push eax)',r[1])

    def test_initialized_private_argument_mutation(self):
        for mutant in (True,False):
            c,f=initialized_argument(mutant);r=c.check(f)
            self.assertEqual(not mutant,r[0].startswith('PROVEN'),r)
