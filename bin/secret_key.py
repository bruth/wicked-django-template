#!/usr/bin/env python
from random import choice

def generate_secret_key():
    return ''.join(choice('abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)') for i in xrange(50))

if __name__ == '__main__':
    print generate_secret_key()
