# InterVarAnnotator
## Add full InterVar annotation to VCF file

### Note:  This pipeline splits multi-allelic variants to multiple lines and reformats positions and alleles to minimal representations. Therefore the POS, REF, and ALT in the final VCF output will not match the input VCF for every variant. The ID field of the output file will either match the ID for the input file, or if input is "." it will match CHROM_POS_REF_ALT of input file.


**USAGE:**

Clone the repo in the directory where you want the output.

**On helix:**

cd /data/username/desired/output/directory

module load git

git clone https://github.com/ekarlins/InterVarAnnotator.git

*Edit "config.yaml" to give the path to your input vcf.gz (at the very least)*

**On Biowulf:**

cd /data/username/desired/output/directory

sbatch --cpus-per-task=2 --mem=2g --partition=norm --time=24:00:00 mainSnake.sh

*runtime, etc. for all possible input vcf.gz files has not been tested.  You may need to change the time above or parameters in cluster.json accordingly*



