#!/usr/bin/python


'''
This is to run a SnakeMake to add InterVar annotation to a VCF file
'''

import glob
import sys
import os
import pysam
import shutil
from snakemake.utils import R

configfile: "config.yaml"

vcf = config['vcf']
size_file = config['size']
chunk_size = int(config['chunk'])

tabVcf = pysam.TabixFile(vcf)
CHROMOSOMES = tabVcf.contigs
tabVcf.close()

chromEndDict = {}
with open(size_file) as f:
    for line in f:
        line_list = line.split()
        chrom = line_list[0]
        end = int(line_list[1])
        chromEndDict[chrom] = end

CHUNKS = []
for chrom in CHROMOSOMES:
    if not chrom.startswith('chr'):
        chrom = 'chr' + chrom
    if not chromEndDict.get(chrom):
        print('Chromsome ' + chrom + ' not in size file.')
        sys.exit(1)
    chromEnd = chromEndDict[chrom]
    for i in range(0, chromEnd, chunk_size):
        start = str(i)
        end = str(i + chunk_size)
        CHUNKS.append('.'.join([chrom, start, end]))
    



rule all:
    input:
        'InterVar_annotated/' + os.path.basename(vcf)



rule subset_vcf:
    input:
        vcf
    output:
        'vcf_chunks/{chunk}.vcf'
    run:
        (chrom, start, end) = wildcards.chunk.split('.')
        vcf = pysam.TabixFile(input[0])
        with open(output[0], 'w') as out:
            for line in vcf.header:
                a = line.decode("utf-8")
                if not a.startswith('#CHROM'):
                    out.write(a + '\n')
            head_list = a.split()
            out.write('\t'.join(head_list[:9]))
            firstColumns = []
            all_genotypes = []
            maxGenos = 0
            for line in vcf.fetch(chrom, int(start), int(end)):
                line_list = line.split()
                (chrom, pos, snp, ref, alt) = line_list[:5]
                newAlt = '_'.join(alt.split(','))
                newId = '_'.join([chrom, pos, ref, newAlt])
                line_list[7] = newId
                genotypes = line_list[9:]
                keepGenos = []
                for geno in genotypes:
                    keepGenos.append(geno.split(':')[0])
                if len(set(keepGenos)) > maxGenos:
                    maxGenos = len(set(keepGenos))
                firstColumns.append(line_list[:9])
                all_genotypes.append(set(keepGenos))
            c = 1
            for i in range(maxGenos):
                out.write('\tSamp' + str(c))
                c += 1
            out.write('\n')
            for i in range(len(firstColumns)):
                colList = firstColumns[i]
                out.write('\t'.join(colList))
                myGenos = list(all_genotypes[i])
                while len(myGenos) < maxGenos:
                    myGenos = myGenos + myGenos
                for j in range(maxGenos):
                    out.write('\t' + myGenos[j])
                out.write('\n')
        vcf.close()



rule make_avinput:
    input:
        'vcf_chunks/{chunk}.vcf'
    output:
        'avinput/{chunk}.avinput'
    run:
        (chrom, start, end) = wildcards.chunk.split('.')
        shell('perl /usr/local/apps/ANNOVAR/2017-07-16/convert2annovar.pl --format vcf4 --includeinfo {input} --allsample --outfile {input}.avinput')
        sampFiles = glob.glob(input[0] + '.avinput.Samp*.avinput')
        with open(input[0]) as f:
            line = f.readline()
            while line[0] == '#':
                line = f.readline()
        line_list = line.split()
        samples = line_list[9:]
        if len(samples) != len(sampFiles):
            print('Number of samples in ' + input[0] + ' do not match av sample files')
            sys.exit(1)
        lineDict = {}
        for sampFile in sampFiles:
            with open(sampFile) as f:
                for line in f:
                    line_list = line.split()
                    (chrom, start, end, ref, alt) = line_list[:5]
                    pos = int(start)
                    if not lineDict.get(pos):
                        lineDict[pos] = []
                    newLine = '\t'.join(line_list[:-2]) + '\n'
                    lineDict[pos].append(newLine)
        with open(output[0], 'w') as out:
            for pos in sorted(lineDict.keys()):
                lines = set(lineDict[pos])
                for line in lines:
                    out.write(line)

rule run_intervar:
    input:
        'avinput/{chunk}.avinput'
    output:
        'InterVar_chunks/{chunk}.InterVarOutput.hg19_multianno.txt.intervar'
    params:
        'InterVar_chunks/{chunk}.InterVarOutput'
    shell:
        'InterVar -i {input} -d $ANNOVAR_DATA/hg19 -o {params}'

