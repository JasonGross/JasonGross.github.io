#!/usr/bin/env python
from __future__ import with_statement
import sys, re

VALID_URLS = ('https://github.com',
              'http://coq.inria.fr/pylons',
              'http://coq.inria.fr',
              'http://www.cs.berkeley.edu/~megacz',
              'http://mattam.org/repos',
              'http://ncatlab.org',
              'http://homotopytypetheory.org/2011/',
              'http://mathoverflow.net/')

def is_doi_line(line):
    return re.match(r'^[^a-zA-Z]+doi = .+$', line) is not None

def is_url_line(line):
    return re.match(r'^[^a-zA-Z]+url = .+$', line) is not None \
        or re.match(r'^[^a-zA-Z]+eprint = .+$', line) is not None

def url_line_is_valid(line):
    for url in VALID_URLS:
        if re.match(r'^[^a-zA-Z]+url = {' + url + '.+$', line) is not None:
            return True
    return False

def fixline(line):
    return line.replace(r'@MASTERSTHESIS{spiwackverified,', r'@THESIS{spiwackverified,')

if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f:
        contents = f.readlines()
    for i in contents:
        if (not (is_url_line(i) or is_doi_line(i))) or url_line_is_valid(i):
            print(fixline(i.strip('\n')))
