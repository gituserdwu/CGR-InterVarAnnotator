#!/usr/bin/python
import sys


        
def main():
    args = sys.argv[1:]
    if len(args) != 2:
        print ("error: usage: module load python/2.7.5;python MinimalRepVcf.py /path/to/input.vcf /path/to/output.vcf")
        sys.exit(1)
    else:
        outputMinRepVcf(args[0], args[1])
        


if __name__ == "__main__":
    main()
