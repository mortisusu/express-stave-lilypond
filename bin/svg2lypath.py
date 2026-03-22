#!/usr/bin/env python3

import re
import sys
import argparse

def debug(s):
    pass
    # print(s)

def mymin(a, b):
    return b if a is None else a if b is None else min(a, b)

def mymax(a, b):
    return b if a is None else a if b is None else max(a, b)

class PathCommand:
    def __init__(self, lycmd, length):
        self.lycmd = lycmd
        self.length = length

# A path operation
class Op:
    cmd2ly = {
        'm': PathCommand('moveto', 2),
        'l': PathCommand('lineto', 2),
        'c': PathCommand('curveto', 6),
        'z': PathCommand('closepath', 0),
        'v': PathCommand('lineto', 1),
        'h': PathCommand('lineto', 1),
    }
        
    def __init__(self, cmd, items=None, lastOp=None):
        self.cmdl = cmd.lower()
        if self.cmdl not in self.cmd2ly:
            raise Exception(f'Unknown command {cmd}')
        
        self.lycmd = self.cmd2ly[self.cmdl].lycmd
        self.lastOp = lastOp
        self.relative = cmd.islower()
        self.pos = []
        if items:
            self.addItems(items)

    def addItems(self, items):

        if self.cmdl == 'v':
            items.insert(0, 0 if self.relative else self.lastOp.x)

        if self.cmdl == 'h':
            items.append(0 if self.relative else self.lastOp.y)

        for i in range(0, len(items), 2):
            self.addItem(float(items[i]), float(items[i+1]))

    def addItem(self, x, y):
        if self.relative and self.lastOp:

            x += self.lastOp.x
            y += self.lastOp.y

        self.pos.append(x)
        self.pos.append(y)

    @property
    def x(self):
        return self.pos[-2] if len(self.pos) > 0 else None
    
    @property
    def y(self):
        return self.pos[-1] if len(self.pos) > 0 else None
    
    def scale(self, translatey, factor, xmin, ymin):
        isX = True
        for i in range(len(self.pos)):
            if isX:
                self.pos[i] -= xmin
            else:
                self.pos[i] = (self.pos[i] -ymin) * (-1 if factor < 0 else 1)
            
            self.pos[i] *= abs(factor)

            if not isX:
                self.pos[i] += translatey
            
            isX = not isX

    def posstr(self):
        return [f"{round(p, 3):g}" for p in self.pos]
    
    def __str__(self):
        return f'{self.lycmd} {" ".join(self.posstr())}'
    
    def output(self):
        return [self.lycmd] + self.posstr()


def extract_path_data(filename):
    with open(filename, 'r') as f:
        content = f.read()
    
    # the path is expected within a <path d="..."> section
    paths = re.findall(r'<path\s+[^<>]*\bd="([^"]+)"', content)
    if not paths:
        raise Exception("Unable to find path data")
    
    return paths
    
    

def parse(paths, size, translatey, rowlen):

    items = list()
    commands = list()

    for s in paths:
        split = re.split(r'[\s,]+', s)
        debug(f'items={split}')

        for i in range(len(split)):
            # print(f'{i} item={split[i]}')
            p = split[i]
            if p.lower().endswith('z'):

                
                item = p[:-1].strip()
                if item:
                    items.append(item)

                commands.append(('z', len(items)))
                debug(f'---- cmd=z idx={len(items)}')

                continue

            c0 = p[0]
            if re.match(r'[a-y]', c0, re.IGNORECASE):
                commands.append((c0, len(items)))
                debug(f'---- cmd={c0} idx={len(items)}')
                item = p[1:].strip()
                if item:
                    items.append(item)  # remove the item without the first char

                continue

            items.append(p)

        commands.append(('p', len(items)))    # p signifies a part end.

    def verify():
        if length > 0 and (idx2 - idx) % length != 0:
            print(items[idx:idx+length])
            raise ValueError(f'invalid length for {cmd} command at index  {idx} ({items[idx]}) and {idx2} ({items[idx2]}), length: {idx2 - idx}')
        
    ops = []
    lastOp = None
    debug(f'commands={commands}')
    for ci in range(len(commands)):
        cmd, idx = commands[ci]

        if cmd == 'p':
            lastOp = None   # a part ends, so we need to reset the lastOp
            continue
        
        if cmd == 'z':
            ops.append(Op(cmd))
            continue

        if ci < len(commands) - 1:
            cmd2, idx2 = commands[ci+1]
        else:
            cmd2 = None
            idx2 = len(items)

        debug(f'cmd={cmd} idx={idx}')

        length = Op.cmd2ly[cmd.lower()].length

        verify()
        
        for part in range(idx, idx2, length):
            op = Op(cmd, items[part:part+length], lastOp)
            ops.append(op)
            lastOp = op

    if size is not None: 
        xmin = xmax = ymin = ymax = None
        for op in ops:
            xmin = mymin(xmin, op.x)
            xmax = mymax(xmax, op.x)
            ymin = mymin(ymin, op.y)
            ymax = mymax(ymax, op.y)
        
        max_range = max(xmax - xmin, ymax - ymin)
        factor = size / max_range
        for op in ops:
            op.scale(translatey * abs(size), factor, xmin, ymin)
            
    if rowlen == 0:
        print('\n'.join(str(op) for op in ops))
    else:
        items = [item for op in ops for item in op.output()]
        for i in range(0, len(items), rowlen):
            chunk = items[i : i + rowlen]
            print(" ".join(map(str, chunk)))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Converts an svg path to a lilypond path",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    
    parser.add_argument(
        "filename", 
        help="SVG file to convert"
    )
    
    parser.add_argument(
        "size", 
        type=float, 
        nargs="?", 
        default=1.0,
        help="Size of the resulting lilypond path. Use negative values to flip vertically."
    )
    
    parser.add_argument(
        "translatey", 
        type=float, 
        nargs="?", 
        default=0.0,
        help="Translate the path in the y direction"
    )

    parser.add_argument(
        "rowlen", 
        type=float, 
        nargs="?", 
        default=15,
        help="The number of elements per output row. Use 0 to show one operation per line."
    )

    args = parser.parse_args()

    paths = extract_path_data(args.filename)
    parse(paths, args.size, args.translatey, args.rowlen)