#!/usr/bin/python
import sys
import fileinput


def outputMinRepVcf(inputVcf, outputVcf):
    '''
    (str, str) -> None
    output a vcf file with the minimum representation of REF and ALT
    inputVcf should be a vcf run through vcflib vcfbreakmulti to split the multi allelic variants into multiple lines.
    if inputVcf is "-" it will take from STDIN.
    '''
    with open(outputVcf, 'w') as output:
        for line in fileinput.input(inputVcf):
            if line[0] == "#":
                output.write(line)
            else:
                line_list = line.split('\t')
                oldPos = int(line_list[1])
                oldRef = line_list[3]
                oldAlt = line_list[4]
                if "," in oldAlt:
                    print('Still MNPs in vcf.  Did you use vcflib vcfbreakmulti?')
                    sys.exit(1)
                line_list[1], line_list[3], line_list[4] = get_minimal_representation(oldPos, oldRef, oldAlt)
                output.write('\t'.join(line_list))
    fileinput.close()
                





def get_minimal_representation(pos, ref, alt):
    '''
    (int, str, str) -> (str, str, str)
    return the minimal representation of pos, ref, alt
    ''' 
    # If it's a simple SNV, don't remap anything
    if len(ref) == 1 and len(alt) == 1: 
        return str(pos), ref, alt
    else:
        # strip off identical suffixes
        while(alt[-1] == ref[-1] and min(len(alt),len(ref)) > 1):
            alt = alt[:-1]
            ref = ref[:-1]
        # strip off identical prefixes and increment position
        while(alt[0] == ref[0] and min(len(alt),len(ref)) > 1):
            alt = alt[1:]
            ref = ref[1:]
            pos += 1
        #print 'returning: ', pos, ref, alt
        return str(pos), ref, alt
        
        
def main():
    args = sys.argv[1:]
    if len(args) != 2:
        print ("error: usage: module load python/2.7.5;python MinimalRepVcf.py /path/to/input.vcf /path/to/output.vcf")
        sys.exit(1)
    else:
        outputMinRepVcf(args[0], args[1])
        


if __name__ == "__main__":
    main()
