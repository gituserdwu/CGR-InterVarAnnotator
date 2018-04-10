#!/usr/bin/python
import sys
import pysam


def makeVcfToAvDict(avinput):
    vcfToAvDict = {}
    with open(avinput) as f:
        for line in f:
            line_list = line.split()
            avId = '_'.join(line_list[:5])
            vcfId = line_list[12]
            vcfToAvDict[vcfId] = avId
    return vcfToAvDict

def makeIntervarDict(intervarFile, tabVcf):
    vcf = pysam.TabixFile(tabVcf)
    CHROMOSOMES = vcf.contigs
    vcf.close()
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



def outputAnnotated(inVcf, outVcf, avinput, intervar, tabVcf):
    vcfToAvDict = makeVcfToAvDict(avinput)
    interVarDict = makeIntervarDict(intervar, tabVcf)
    with open(inVcf) as f, open(outVcf, 'w') as out:
        line = f.readline()
        while not line.startswith('#CHROM'):
            out.write(line)
            line = f.readline()
        out.write('##INFO=<ID=InterVar,Number=.,Type=String,Description="InterVar predicted pathogenicity for each overlapping gene">\n')
        out.write(line)
        line = f.readline()
        while line != '':
            line_list = line.split()
            (chrom, pos, snp, ref, alt) = line_list[:5]
            vcfId = '_'.join([chrom, pos, ref, alt])
            avId = vcfToAvDict[vcfId]
            geneDict = interVarDict[avId]
            predictions = []
            for gene in sorted(geneDict.keys()):
                predict = geneDict[gene]
                predictions.append(gene + ':' + predict)
            interVar = 'InterVar=' + '|'.join(predictions)
            info = line_list[7]
            line_list[7] = info + ';' + interVar
            out.write('\t'.join(line_list) + '\n')
            line = f.readline()


        
def main():
    args = sys.argv[1:]
    if len(args) != 5:
        print ("error: usage: module load python/2.7;python annotateVcf.py /path/to/input.vcf /path/to/output.vcf /path/to/file.avinput /path/to/file.intervar /path/to/full.vcf.gz")
        sys.exit(1)
    else:
        outputAnnotated(args[0], args[1], args[2], args[3], args[4])
        


if __name__ == "__main__":
    main()
