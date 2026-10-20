# write a file with CRLF line endings: w.py <dest> < content
import sys
data = sys.stdin.read().replace('\r\n', '\n').replace('\n', '\r\n')
open(sys.argv[1], 'w', newline='').write(data)
