#!/usr/bin/env python3
# Copyright (c) 2024 Ethan Sifferman.
# All rights reserved. Distribution Prohibited.

import sys
import re

def process_verilog_file_list(file_list):
    makefile_allowed_extensions = ['.sv', '.v', '.svh', '.vh', 'vlt']

    with open(file_list, 'r') as f:
        lines = f.readlines()
    processed_lines = []

    for line in lines:
        line = re.sub(r'//.*', '', line)
        line = ' '.join(line.split())
        if any(line.endswith(ext) for ext in makefile_allowed_extensions):
            processed_lines.append(line)

    print(' '.join(processed_lines))

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <verilog_file_list>")
        sys.exit(1)

    verilog_file_list = sys.argv[1]
    process_verilog_file_list(verilog_file_list)
