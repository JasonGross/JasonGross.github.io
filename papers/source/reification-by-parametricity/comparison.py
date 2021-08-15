#!/usr/bin/env python2
from __future__ import with_statement
import re, sys

STATS_RES = [re.compile(r'Doing (%s)\s+\(n= ([0-9]+) \) on ([^ ]+) with ([^ ]+) :\nTactic call ran for ([0-9\.]+) secs \(([0-9\.]+)u,([0-9\.]+)s\)' % ty,
                        flags=re.DOTALL|re.MULTILINE)
             for ty in ('identity cbv', 'identity lazy', 'identity vm_compute', 'identity native_compute', 'identity simpl', 'identity cbn', 'refine let', 'cbv Denote', 'lazy Denote', 'cbn Denote', 'simpl Denote')]

NON_REIF_RES = [re.compile(res, flags=re.DOTALL|re.MULTILINE) for res in
                [r'(Aggregate) time \(n= ([0-9]+) \) for "([^"]+)" with ([^ ]+) :\nTactic call aggregate ran for ([0-9\.]+) secs \(([0-9\.]+)u,([0-9\.]+)s\)'] +
                [(r'Doing (%s)\s+\(n= ([0-9]+) \) for "([^"]+)" with ([^ ]+) :\nTactic call %s ran for ([0-9\.]+) secs \(([0-9\.]+)u,([0-9\.]+)s\)' % (ty, ty))
                 for ty in ('cbv', 'pre', 'post')]]

REIF_PRE_RE = re.compile(r'Doing reif\s+\(n= ([0-9]+) \) for "([^"]+)" with ([^ ]+) :\n' +
                         r'(.*?\n' +
                         r'Tactic call reif ran for [^\n]+)',
                         flags=re.DOTALL|re.MULTILINE)
REIF_RE = re.compile('Tactic call ([^\n]*?) ran for ([0-9\.]+) secs \(([0-9\.]+)u,([0-9\.]+)s\)',
                     flags=re.DOTALL|re.MULTILINE)

def fix_num(val):
    if val == '0.': return '0'
    return val

def fix_times(real, user, system):
    return (fix_num(real), fix_num(user), fix_num(system))

def dict_set(d, value, *keys):
    for k in keys[:-1]:
        d[k] = d.get(k, {})
        d = d[k]
    d[keys[-1]] = value

def process(fname):
    with open(fname, 'r') as f:
        contents = f.read()


    # contents = contents.replace(':\nTactic call ran', ': Tactic call ran')

    ret = {'big':{'PHOAS':{}}}

    for reg in STATS_RES:
        for name, count, kind, const, real, user, system in reg.findall(contents):
            dict_set(ret, fix_times(real, user, system), const, kind, name, int(count))

    for reg in NON_REIF_RES:
        for name, count, kind, const, real, user, system in reg.findall(contents):
            dict_set(ret, fix_times(real, user, system), const, kind, name, int(count))

    for count, kind, const, body in REIF_PRE_RE.findall(contents):
        for name, real, user, system in REIF_RE.findall(body):
            dict_set(ret, fix_times(real, user, system), const, kind, name, int(count))

    return ret

def cmp_for_kind(d, const, name):
    def do_cmp(kind1, kind2):
        if kind1 == kind2: return cmp(kind1, kind2)
        if kind1 in d[const].keys() and kind2 in d[const].keys():
            if name in d[const][kind1].keys() and name in d[const][kind2].keys():
                count1, (real1, user1, system1) = sorted(d[const][kind1][name].items())[-1]
                count2, (real2, user2, system2) = sorted(d[const][kind2][name].items())[-1]
                return cmp((count1, -float(real1), -float(user1), -float(system1), kind1),
                           (count2, -float(real2), -float(user2), -float(system2), kind2))
            elif name in d[const][kind1].keys(): return -1
            elif name in d[const][kind2].keys(): return 1
            else: return cmp(kind1, kind2)
        elif kind1 in d[const].keys(): return -1
        elif kind2 in d[const].keys(): return 1
        else: return cmp(kind1, kind2)
    return do_cmp

def print_mathematica(d):
    ret = ''
    ret += '(* ::Package:: *)\n\n'
    ret += 'ClearAll[data,Consts,Kinds,DataNames];\n\n'
    ret += 'Consts = {%s};\n' % ', '.join(sorted(set('"%s"' % const for const in d.keys())))
    ret += 'Kinds = {%s};\n' % ', '.join(sorted(set('"%s"' % kind for const, d2 in d.items() for kind in d2.keys())))
    ret += 'DataNames = {%s};\n' % ', '.join(sorted(set('"%s"' % name for const, d2 in d.items() for kind, d3 in d2.items() for name in d3.keys())))
    ret += '\n'
    for const, d2 in sorted(d.items()):
        for name in sorted(set(name for kind, d3 in d2.items() for name in d3.keys())):
            ret += 'KindsSortedFor["%s"]["%s"] = {%s};\n' % (const, name, ', '.join('"%s"' % kind for kind in sorted(d2.keys(), cmp=cmp_for_kind(d, const, name))))
        ret += '\n'
        for kind, d3 in sorted(d2.items()):
            for name, d4 in sorted(d3.items()):
                reals = [(count, real) for count, (real, user, system) in sorted(d4.items())]
                users = [(count, user) for count, (real, user, system) in sorted(d4.items())]
                systems = [(count, system) for count, (real, user, system) in sorted(d4.items())]
                str_reals = '{' + ', '.join('{' + ','.join(map(str, v)) + '}' for v in reals) + '}'
                str_users = '{' + ', '.join('{' + ','.join(map(str, v)) + '}' for v in users) + '}'
                str_systems = '{' + ', '.join('{' + ','.join(map(str, v)) + '}' for v in systems) + '}'
                ret += 'data["%(const)s"]["%(kind)s"]["%(name)s"]["real"] = %(str_reals)s;\n' % locals()
                ret += 'data["%(const)s"]["%(kind)s"]["%(name)s"]["user"] = %(str_users)s;\n' % locals()
                ret += 'data["%(const)s"]["%(kind)s"]["%(name)s"]["system"] = %(str_systems)s;\n' % locals()
    return ret

if __name__ == '__main__':
    d = process('comparison.log')
    if '--mathematica' in sys.argv:
        print(print_mathematica(d))
