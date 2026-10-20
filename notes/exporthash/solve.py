# solve.py target weight name=hash ... : for each built (name, hash) compute target name hash and invert
import sys, subprocess
def nh(s):
    h = 0
    for c in s: h = (h * 17 + ord(c)) & 0xffffffff
    return h
M = 2**32
target = int(sys.argv[1], 16); w = int(sys.argv[2])
inv = pow(w, -1, M)
for a in sys.argv[3:]:
    n, h = a.split('=')
    t = (nh(n) + (target - int(h, 16)) * inv) % M
    r = subprocess.run([sys.executable, 'C:/Users/int19h/AppData/Local/Temp/hse_A/tools/inv.py', str(t), '10'], capture_output=True, text=True).stdout.split()
    print(a, t, r[:20])
