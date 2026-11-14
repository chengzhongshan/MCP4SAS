#!/usr/bin/env python3
import argparse
from MCP4SAS_Use_Python.tempfiles import cleanup
def main():
    parser=argparse.ArgumentParser(description='Preview/remove inactive MCP4SAS-owned scratch only.')
    parser.add_argument('--apply',action='store_true')
    parser.add_argument('--directory',default='.')
    parser.add_argument('--older-than-hours',type=float,default=24)
    args=parser.parse_args()
    cleanup(args.directory,args.older_than_hours,args.apply)
if __name__=='__main__':
    main()
