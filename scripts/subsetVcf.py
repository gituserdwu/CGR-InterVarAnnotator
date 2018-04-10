#!/usr/bin/python
import sys
import pysam

def outputVcfChunk(inVcf, outVcf, chrom, start, end):
    vcf = pysam.TabixFile(inVcf)
    with open(outVcf, 'w') as output:
        for head in vcf.header:
            if not head.startswith('#CHROM'):
                output.write(head + '\n')
        output.write('##INFO=<ID=OldVcfAlleles,Number=1,Type=String,Description="CHROM, POS, REF, ALT from the original vcf, concatenated with underscores.">\n')
        output.write(head + '\n')
        for line in vcf.fetch(chrom, int(start), int(end)):
            line_list = line.split()
            (chrom, pos, snp, ref, alt) = line_list[:5]
            newAlt = '_'.join(alt.split(','))
            newId = '_'.join([chrom, pos, ref, newAlt])
            info = line_list[7]
            line_list[7] = info + ';OldVcfAlleles=' + newId 
            output.write('\t'.join(line_list) + '\n')
    vcf.close()



        
def main():
    args = sys.argv[1:]
    if len(args) != 5:
        print ("error: usage: module load python/2.7;python subsetVcf.py /path/to/input.vcf.gz /path/to/output.vcf CHROM START END")
        sys.exit(1)
    else:
        outputVcfChunk(args[0], args[1], args[2], args[3], args[4])
        


if __name__ == "__main__":
    main()
