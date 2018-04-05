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
    




def makeVcfToAvDict(avinput):
    vcfToAvDict = {}
    with open(avinput) as f:
        for line in f:
            line_list = line.split()
            avId = '_'.join(line_list[:5])
            vcfId = line_list[12]
            vcfToAvDict[vcfId] = avId
    return vcfToAvDict







include: 'modules/Snakefile_splitVcf'
include: 'modules/Snakefile_avinput'
include: 'modules/Snakefile_InterVar'

rule all:
    input:
        'InterVar_bed/build.intervar.bed.gz.tbi'
