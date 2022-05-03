#!/usr/bin/env python3
import re, math, csv, sys
from functools import reduce

def pretty_prime(prime):
    return prime.replace('-', '+-').replace('p', '+').replace('m', '+-').replace('e', '^').replace('x', '*')

def latex_prime(prime):
    def latex_exps(expr):
        return expr if '^' not in expr else '%s^{%s}' % tuple(expr.split('^'))
    def latex_prods(expr): return r' \cdot '.join(latex_exps(v) for v in expr.split('*'))
    def latex_sums(expr): return ' + '.join(latex_prods(v) for v in expr.split('+')).replace('+ -', '- ')
    return latex_sums(pretty_prime(prime))

def eval_prime(prime):
    def eval_exps(expr): return int(expr) if '^' not in expr else pow(*map(int, expr.split('^')))
    def eval_prods(expr): return math.prod(eval_exps(v) for v in expr.split('*'))
    def eval_sums(expr): return sum(eval_prods(v) for v in expr.split('+'))
    return eval_sums(pretty_prime(prime))

LINE_REG = re.compile(r'^[^ ]*?(montgomery|solinas)([0-9]+)_([^_]+)_([0-9]+)limbs/([^\./]+)\.vo\s+\(real: ([0-9\.]+), user: ([0-9\.]+), sys: ([0-9\.]+), mem: ([0-9]+) ko\)')
def parse_prime_line(line):
    for kind, bitwidth, prime, nlimbs, operation, realt, usert, syst, memko in LINE_REG.findall(line):
        return {'kind': {'montgomery':'WordByWordMontgomery','solinas':'UnsaturatedSolinas'}[kind],
                'operation': operation,
                'bitwidth': bitwidth,
                'prime': eval_prime(prime),
                'prime-str': prime,
                'prime-tex': latex_prime(prime),
                'nlimbs': nlimbs,
                'real': realt,
                'user': usert,
                'sys': syst,
                'mem': memko
                }

def rows_to_dict(keys, rows, descr=''):
    rtn = {}
    for i, row in enumerate(rows):
        if row is None: continue
        try:
            key = tuple(f(row[k]) for k, f in keys)
        except:
            print('Invalid row %d: %s' % (i, str(row)))
            raise
        if key not in rtn.keys(): rtn[key] = []
        rtn[key].append(row)
    return rtn

def add_div_fields(row):
    special_kind_keys = ([base_kind + kind_tag
                          for base_kind in ('NewVM', 'NewExtraction')
                          for kind_tag in ('NBE', 'Full')] +
                         ['OldVM', 'OldCbv', 'OldSynthesis', 'OldSynthesisAndPackage'])
    for time_kind in ('user', 'real', 'sys', 'mem'):
        for prefix in [''] + ['%s-x%s-' % (kind, bitwidth)
                              for kind in ('WordByWordMontgomery', 'UnsaturatedSolinas')
                              for bitwidth in ('32', '64')]:
            for num_pre_key in special_kind_keys:
                extra_vals = []
                for den_pre_key in special_kind_keys:
                    num_key = '%s%s-%s' % (prefix, num_pre_key, time_kind)
                    den_key = '%s%s-%s' % (prefix, den_pre_key, time_kind)
                    over_key = '%s%s-over-%s-%s' % (prefix, num_pre_key, den_pre_key, time_kind)
                    num = row.get(num_key, '')
                    den = row.get(den_key, '')
                    if (isinstance(den, float) and den < 1e-10) or num == '' or den == '' or (isinstance(den, str) and den.strip('.0') == ''): continue
                    extra_vals.append((over_key, float(num) / float(den)))
                if len(extra_vals) > 1:
                    row.update(dict(extra_vals))
    return row

def make_shorter_key(row):
    kind_tag = 'NBE' if 'NBE' in row['descr1'] else 'Full' if 'FullToStrings' in row['descr1'] else ''

    if 'lazy' in row['descr2'] or '(1)' in row['descr2'] or 'native_compute' in row['descr2']: return None
    if 'Pipeline' in row['descr1'] and kind_tag == '': return None
    if 'Pipeline' in row['descr1'] and 'cbv' in row['descr2']: return None
    if 'Pipeline' not in row['descr1'] and 'GallinaAxOf' not in row['descr1']: return None

    if 'Pipeline' not in row['descr1'] and 'vm_compute' in row['descr2']: return 'OldVM' + kind_tag
    if 'Pipeline' in row['descr1'] and 'vm_compute' in row['descr2']: return 'NewVM' + kind_tag
    if 'Pipeline' in row['descr1'] and 'extraction' in row['descr2']: return 'NewExtraction' + kind_tag
    if 'Pipeline' not in row['descr1'] and 'cbv' in row['descr2']: return 'OldCbv' + kind_tag

    return None

def merge_data(old_data, rewriter_data):
    old_data_dict = rows_to_dict((('prime', int), ('prime-str', (lambda x: x)), ('nlimbs', str), ('kind', str), ('bitwidth', str)), old_data)
    rewriter_data_dict = rows_to_dict((('prime', int), ('prime_str', (lambda x: x.replace('^', 'e').replace('-', 'm').replace('+', 'p').replace('*', 'x'))), ('nlimbs', str), ('kind', str), ('bitwidth', str)), rewriter_data)
    prime_keys = sorted(set(old_data_dict.keys()).union(set(rewriter_data_dict.keys())))
    rtn = []
    time_kinds = ('user', 'real', 'sys', 'mem')
    rewriter_time_kinds = ('user', 'real')
    for prime_key in prime_keys:
        prime, prime_str, nlimbs, kind, bitwidth = prime_key
        cur = {'prime': prime, 'prime-str': prime_str, 'nlimbs': nlimbs, 'prime-tex': latex_prime(prime_str), 'kind': kind, 'bitwidth': bitwidth}
        for row in old_data_dict.get(prime_key, []):
            if row['operation'] != 'Synthesis': continue
            for time_kind in time_kinds:
                for key in ('%s-x%s-OldSynthesisPackage-%s' % (row['kind'], row['bitwidth'], time_kind),
                            'OldSynthesisPackage-%s' % time_kind):
                    if key in cur: print('Warning: Overwriting %s (%s limbs) %s from %s to %s' % (cur['prime-str'], cur['nlimbs'], key, cur[key], row[time_kind]), file=sys.stderr)
                    cur[key] = row[time_kind]
            extra_fields = [k for k in row.keys() if k not in ('prime', 'prime-str', 'prime-tex', 'nlimbs', 'kind', 'bitwidth', 'operation') and k not in time_kinds]
            if len(extra_fields) != 0: print('Warning: Discarding fields %s for %s' % (', '.join(extra_fields), str(row)))
        for row in old_data_dict.get(prime_key, []):
            if row['operation'] != 'femul': continue
            for time_kind in time_kinds:
                for pre_key in ('%s-x%s-OldSynthesis' % (row['kind'], row['bitwidth']),
                                'OldSynthesis'):
                    key = '%s-%s' % (pre_key, time_kind)
                    package_key = '%sPackage-%s' % (pre_key, time_kind)
                    and_package_key = '%sAndPackage-%s' % (pre_key, time_kind)
                    if key in cur: print('Warning: Overwriting %s (%s limbs) %s from %s to %s' % (cur['prime-str'], cur['nlimbs'], key, cur[key], row[time_kind]), file=sys.stderr)
                    cur[key] = row[time_kind]
                    if package_key in cur.keys():
                        cur[and_package_key] = float(cur[key]) + float(cur[package_key])
                    else:
                        print('Warning: Missing key %s from %s (%s limbs)' % (package_key, cur['prime-str'], cur['nlimbs']), file=sys.stderr)
            extra_fields = [k for k in row.keys() if k not in ('prime', 'prime-str', 'prime-tex', 'nlimbs', 'kind', 'bitwidth', 'operation') and k not in time_kinds]
            if len(extra_fields) != 0: print('Warning: Discarding fields %s for %s' % (', '.join(extra_fields), str(row)))
        for row in rewriter_data_dict.get(prime_key, []):
            for pre_key in ('%s|%s' % (row['descr1'], row['descr2']),
                            make_shorter_key(row)):
                if pre_key is None: continue
                for time_kind in rewriter_time_kinds:
                    for key in ('%s-x%s-%s-%s' % (row['kind'], row['bitwidth'], pre_key, time_kind),
                                '%s-%s' % (pre_key, time_kind)):
                        if key in cur: print('Warning: Overwriting %s (%s limbs) %s from %s to %s' % (cur['prime-str'], cur['nlimbs'], key, cur[key], row[time_kind]), file=sys.stderr)
                        cur[key] = row[time_kind]
            extra_fields = [k for k in row.keys() if k not in ('prime', 'prime_str', 'nlimbs', 'kind', 'bitwidth', 'descr1', 'descr2', 'index') and k not in time_kinds]
            if len(extra_fields) != 0: print('Warning: Discarding fields %s for %s' % (', '.join(extra_fields), str(row)), file=sys.stderr)

        rtn.append(add_div_fields(cur))

    return rtn

if __name__ == '__main__':
    with open('perf-fiat-crypto-old-synthesis-8.11.1.txt', 'r') as f:
        lines = f.readlines()

    with open('perf-fiat-crypto-rewriter.csv', 'r', newline='') as f:
        reader = csv.DictReader(f)
        perfrows = list(reader)
        perfheader = reader.fieldnames

    data = sorted(merge_data(map(parse_prime_line, lines), perfrows),
                  key=(lambda v: (int(v['prime']), int(v['nlimbs']) if v['nlimbs'] != '' else 0)))

    fieldnames = ['prime', 'prime-str', 'prime-tex', 'nlimbs', 'kind', 'bitwidth']
    fieldnames += sorted([k for k in set.union(*[set(row.keys()) for row in data]) if k not in fieldnames],
                         key=(lambda v: (not ('WordByWordMontgomery' in v),
                                         not ('UnsaturatedSolinas' in v),
                                         not ('-x32-' in v),
                                         not ('-x64-' in v),
                                         not ('OldSynthesis' in v and '-over-' not in v),
                                         not ('OldVM' in v and '-over-' not in v),
                                         not ('NewVM' in v and '-over-' not in v),
                                         not ('NewExtraction' in v and '-over-' not in v),
                                         not ('OldCbv' in v and '-over-' not in v),
                                         not ('Full' in v),
                                         not ('NBE' in v),
                                         not ('-over-' in v),
                                         not ('-user' in v),
                                         not ('-real' in v),
                                         not ('-sys' in v),
                                         not ('-mem' in v),
                                         v)))

    # See https://docs.python.org/3/library/csv.html#id3 for newline=''
    with open('perf-fiat-crypto.csv', 'w', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames, lineterminator='\n')
        writer.writeheader()
        for row in data:
            writer.writerow(row)
