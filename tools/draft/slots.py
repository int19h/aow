import json, glob, os, re, sys, collections
R = 'C:/git/int19h/aow/notes/'
classes = json.load(open(R + 'classes.json'))['classes']
sigs = {}
for f in glob.glob(R + 'signatures/*.json'):
    mod = os.path.basename(f)[:-5]
    for s in json.load(open(f)):
        sigs[(mod, int(s['addr'], 16))] = s
modmap = {c['module'] for c in classes.values()}
def sig_at(cls, target):
    mod = classes[cls]['module']
    return sigs.get((mod, int(target, 16)))
def fmt(s):
    if not s: return '?'
    ps = s['params'][1:]
    reg = [p for p in ps if not p['storage'].startswith('Stack')]
    stk = [p for p in ps if p['storage'].startswith('Stack')]
    stk.sort(key=lambda p: -int(re.search(r'0x([0-9a-f]+)', p['storage']).group(1), 16))
    return '(%s) -> %s' % (', '.join('%s@%s' % (p['type'], p['storage'].split(':')[0]) for p in reg + stk), s['ret'])
children = collections.defaultdict(list)
for n, c in classes.items(): children[c['parent']].append(n)
def descendants(n):
    out = []
    for ch in children[n]:
        out.append(ch); out += descendants(ch)
    return out
def nslots(n):
    return len(classes[n]['vmt']) if n in classes else 0
unit = sys.argv[1]
for n, c in sorted(classes.items(), key=lambda kv: kv[1].get('vmt_va', '')):
    if c['module'] != 'HSEPack.dpl': continue
    syms = [v['symbol'] for v in c['vmt'] if v['own']]
    # unit of the class: from own symbols or Destroy
    us = {s.split('.')[0] for s in syms} | {v['symbol'].split('.')[0] for v in c['fixed'].values() if v['symbol'].split('.')[1] == n}
    if unit not in us and unit != '*': continue
    p = c['parent']
    ps = nslots(p)
    print('== %s(%s) size=%d vmt=%s slots=%d parent_slots=%d units=%s' % (n, p, c['size'], c['vmt_va'], len(c['vmt']), ps, us))
    for k, v in c['fixed'].items():
        if v['symbol'].split('.')[-2:-1] == [n]: print('   fixed', k, fmt(sig_at(n, v['target'])))
    for i, v in enumerate(c['vmt']):
        intro = i >= ps
        if not v['own'] and not intro: continue
        # gather implementations in descendants
        impls = []
        if intro:
            for d in [n] + descendants(n):
                if d not in classes or i >= len(classes[d]['vmt']): continue
                vv = classes[d]['vmt'][i]
                if vv['own'] or d == n:
                    s = sig_at(d, vv['target'])
                    impls.append((d, vv['symbol'], fmt(s)))
        tag = 'NEW ' if intro else 'over'
        print('  %s +%03X %-28s %s' % (tag, v['offset'], v['name'], v['symbol'] if not v['own'] else ''))
        if intro:
            seen = set()
            for d, sym, f in impls:
                if f in seen: continue
                seen.add(f)
                print('         %-30s %s' % (d, f))
        else:
            print('         %s' % fmt(sig_at(n, v['target'])))
