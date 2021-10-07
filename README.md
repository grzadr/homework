# Homework

Author: Adrian Grzemski  
EMail: adrian.grzemski@gmail.com

## Description

This repository contains solution for "homework" task given by the "Company". The aim of this exercise is to perform transformation of given example log file.

## Setup

TThe transformation is performed by `run_homework.sh` bash script, which executes all the operations in a Docker environment. Docker environment **is not** build from scratch by default. This behavior can be change by running script with `-b` argument. 

The proper scripts which generates final CSVs are located in `src` directory. There are 2 scripts responsible for generating CSV (BASH script was made just for fun):

1. `export_csv_bash.sh` - BASH script which uses AWK to perform the transformation. Input can be read from `standard input` or a file name can be passed as a first argument. The final CSV file is being outputted to `standard output`.
2. `export_csv_python.py` - Python3 script which uses standard modules to perform transformation.

Generated CSVs are being saved to `output` directory.
