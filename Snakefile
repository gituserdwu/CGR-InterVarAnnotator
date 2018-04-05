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

def makeIntervarDict(intervarFile):
    interVarDict = {}
    with open(intervarFile) as f:
        head = f.readline()
        line = f.readline()
        while line != '':
            line_list = line.rstrip().split('\t')
            (chrom, start, end, ref, alt) = line_list[:5]
            if chrom not in CHROMOSOMES and 'chr' + chrom in CHROMOSOMES:
                chrom = 'chr' + chrom
            avId = '_'.join([chrom, start, end, ref, alt])
            gene = line_list[5]
            prediction = '_'.join(line_list[13].split('PVS1=')[0].split()[1:])
            if not interVarDict.get(avId):
                interVarDict[avId] = {}
            interVarDict[avId][gene] = prediction
            line = f.readline()
    return interVarDict




include: 'modules/Snakefile_splitVcf'
include: 'modules/Snakefile_avinput'
include: 'modules/Snakefile_InterVar'
include: 'modules/Snakefile_annotate'

rule all:
    input:
        'InterVar_bed/build.intervar.bed.gz.tbi',
        'InterVar_annotated.vcf.gz.tbi'
