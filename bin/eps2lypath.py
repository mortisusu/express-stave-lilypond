#!/usr/bin/env python3

import re
import sys

def debug(s):
    pass
    # print(s)

def extract_path_data(filename):
    with open(filename, 'r') as f:
        content = f.read()
    
    # Split by the starting delimiter and take the second part
    # Then split by the ending delimiter and take the first part
    s = content.split('0 g')[1].split(' h')[0]
    return s

def parse(s, scale):
    s = s.strip()
    items = re.split(r'\s+', s)
    debug(f'items={items}')

    start = 0
    out = list()
    for i in range(len(items)):
        p = items[i]
        if re.match(r'[clm]', p):
            
            if p == 'm':
                lycmd = "moveto"

            elif p == 'l':
                lycmd = "lineto"

            elif p == 'c':
                lycmd = "curveto"

            out.append(f'\n{lycmd}')

            isY = False
            for j in range(start, i):
                f = float(items[j]) * scale
                if isY:
                    f = -1 * f

                isY = not isY
                out.append(f' {f:.4f}')

            start = i + 1

    out.append('\nclosepath')
    print(''.join(out))


if __name__ == "__main__":
    if len(sys.argv) == 1:
        print('Converts an eps path to a lilypond path')
        print(f'Usage: {sys.argv[0]} <filename> [scale=1]')
        sys.exit(1)
        
    filename = sys.argv[1]
    if len(sys.argv) > 2:
        scale = float(sys.argv[2])
    else:
        scale = 1

    s = extract_path_data(filename)
    parse(s, scale)