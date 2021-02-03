#!/usr/bin/env python
import argparse
import datetime as dt

def create_cycle_yaml(template, inputdir, outputdir, cycle):
    """
    find and replace strings in a template file with the correct
    strings and write to an output file in a working directory

    create_cycle_yaml(template, inputdir, outputdir, cycle)
    template - str of basename of file 'template.yaml'
    inputdir - str path of directory containing template file
    outputdir - str path of directory to save final file to
    cycle - datetime object of valid time
    """


parser = argparse.ArgumentParser(description='Generate YAML from templates'+\
                                ' to run BUMP and a JEDI analysis')
parser.add_argument('-i', '--input', type=str,
                    help='path to directory of template YAML files',
                    required=True)
parser.add_argument('-o', '--output', type=str,
                    help='path to output working directory',
                    required=True)
parser.add_argument('-y', '--yaml', type=str,
                    help='list of template YAML files to process',
                    nargs='+', required=True)
parser.add_argument('-c', '--cycle', help='analysis cycle time',
                    type=str, metavar='YYYYMMDDHH', required=True)
args = parser.parse_args()

cycle = dt.datetime.strptime(args.cycle, "%Y%m%d%H")

for template in args.yaml:
    create_cycle_yaml(template, args.input, args.output, cycle)
