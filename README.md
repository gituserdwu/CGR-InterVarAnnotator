# InterVarAnnotator
## Add full InterVar annotation to VCF file

### Note:  This pipeline splits multi-allelic variants to multiple lines and reformats positions and alleles to minimal representations. Therefore the POS, REF, and ALT in the final VCF output will not match the input VCF for every variant. If you need to match these variants to the original VCF there is a field added to the INFO of the output VCF called "OldVcfAlleles", which corresponds to CHROM_POS_REF_ALT of input file.  In addition the InterVar annotation is added to INFO in a field called "InterVar", which contains a "|" seperated list of gene:prediction.


**USAGE:**

*Clone the repo in the directory where you want the output. Preferablly a clean directory with nothing else in it.*

**On helix:**

```sh
cd /data/username/desired/output/directory
module load git
git clone https://github.com/ekarlins/InterVarAnnotator.git
cd InterVarAnnotator
```

*Edit "config.yaml" to give the path to your input vcf.gz (at the very least).  The pipeline defaults to assuming that the VCF is the result of variant calling from WES or WGS and is quite large.  If your VCF contains a small number of variants you can edit the "small_vcf" field in "config.yaml" to "YES".  This will run one chromosome at a time instead of the default of 5MB chunks and will result in many fewer jobs being submitted.  This should work well if your chromsome with the most variants contains fewer than 50,000 variants.*

**On Biowulf:**

```sh
cd /data/username/desired/output/directory/InterVarAnnotator
sbatch --mail-type=BEGIN,TIME_LIMIT_90,END --cpus-per-task=2 --mem=2g --partition=norm --time=24:00:00 mainSnake.sh
```

*runtime, etc. for all possible input vcf.gz files has not been tested.  You may need to change the time above or parameters in cluster.json accordingly. If pipeline fails due to going over time, simply resubmit using the same command.  It will pick up where it left off.*



