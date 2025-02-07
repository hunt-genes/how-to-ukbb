# UKBpheWAS

Perform phenome-wide association study (PheWAS) in UK Biobank on the `hunt-ukbb` lab.

### Step 1. Download

`sh download.sh`

The best resource for comprehensive UK Biobank summary statistics as of May, 2022 is [Pan UKBB](https://pan-dev.ukbb.broadinstitute.org). You can view the manifest and sort for the traits you are intersted in. Information regarding downloads is [here](https://pan-dev.ukbb.broadinstitute.org/downloads). Be sure to cite `Pan-UKB team. https://pan.ukbb.broadinstitute.org. 2020.` In this example, I've donwloaded a .tsv file from the Google Sheet manifest with only the subset of traits I'm interested in. Note, these are in the human genome reference hg19/GRCh37.

Bash script takes arguments in this order
1) the name of the latest Pan UKBB manifest in a tab separated variable (.tsv) file.  (i.e. Pan-UK_Biobank_phecode_manifest.tsv)
2) Trait type (biomarkers, continuous, categorical, icd10, phecode, prescriptions) from 1st column of manifest file
3) Path to the output directory where you want the download made. 

* Script creates `wget` command for all the results that you want. Do understand this utility, `wget -help`

For example:
`wget -O /home/bwolford/scratch/panukb/continuous-100001-both_sexes-irnt.tsv.bgz https://pan-ukb-us-east-1.s3.amazonaws.com/sumstats_flat_files/continuous-100001-both_sexes-irnt.tsv.bgz`

* We want to use `nohup` so the downloads won't get interrupted, and & so it runs in the background. `nohup` will write to nohup.out by default, but we can customize the output files.

`nohup bash download.sh <file> <trait_type> <output/dir/>  >out 2>err &`

For example:
`nohup bash how-to-ukbb/UKBpheWAS/download.sh Pan-UKBiobank_phenotype_manifest.tsv continuous /home/bwolford/scratch/panukbb >continuous.out 2>continuous.err &`

You may want to run this command for multiple trait categories (e.g. phecode, biomakers). Note, this script checks to see if teh file already exists, but it doesn't check to see if it's complete. You will also want to check that the number of downloaded files is what you expect from the manifest. You can use `ls -laF *bgz* | wc -l` to check the number of files in a directory. And you can check the output file (e.g. continuous.out) to see how many files began downloading. You may also want to eyeball and be sure there are no visible errors in the .out or .err files, in case an assumption about the manifest file is no longer true.

* If you wanted to do this one by one and download into the current working directory, the command would look something like

`wget https://pan-ukb-us-east-1.s3.amazonaws.com/sumstats_flat_files/phecode-008-both_sexes.tsv.bgz`

* You also need to download the tabix index file (.tbi) which helps us query the markers quickly 

`wget https://pan-ukb-us-east-1.s3.amazonaws.com/sumstats_flat_files_tabix/phecode-008-both_sexes.tsv.bgz.tbi`

### Step 2. Query a single variant 

We will take advantage of the tabix indexed summary statistics and use tabix to query the results for variants of interest from another GWAS. If you have one index variant and one PanUKBB results file, the command you want looks like this:

`tabix <file> <coord>` for example
`tabix ~/scratch/panukbb/biomarkers/biomarkers-30860-both_sexes-irnt.tsv.bgz 3:45785914-45785915`

Notes:
* make sure the reference genome used for your summary statistics and lead variants	is the same.
* If you are warned that `The index file is older than the data file` this is likely due to the order files were downloaded or the date created. If you are worried about it, you can create a new index file from bgzipped file with `tabix index`
* Positions may be 0-based or 1-based and represent the start or end of a variant, which may itself be a single nucleotide polymorphism or a multilength insertion/deletion. You can read more about this [here](https://www.biostars.org/p/84686/) and [here](https://arnaudceol.wordpress.com/2014/09/18/chromosome-coordinate-systems-0-based-1-based/).

But you likely have multiple summary statistics (phenome-wide could be thousands) and multiple variants of interest. So we will use `-R --region` command in `tabix` to look through everything. 

First, we need to create a regions bed file (.bed) or tab-delimited file (.tab) with our index variant coordinates. You can read more [here](http://www.htslib.org/doc/tabix.html).

`less top_hits.csv  | awk 'NR > 1 {print $0}a' | cut -d "," -f 5,6 | sed 's/,/\t/g' | awk '{print $1"\t"$2"\t"$2}' > top_hits.tab`

Second, we want to perform a tabix query on every file, and write out the results, along with which phecode or trait they are from. We can do with a quick one-liner:

```
nohup sh -c  'for f in `ls /home/bwolford/scratch/panukbb/phecode/*.tsv.bgz`; do base=`basename $f -both_sexes.tsv.bgz`; tabix $f -R top_hits.tab | awk -v base=$base '\''{print $0"\t"base}'\''; done >> phecode.query.txt' &
```

But the `query.sh` file will combine these steps if you provide
1) a config file with one summary stat file per line, make sure to include the full path and that the file has been tabix and bgzipped with ending .tsv.bgz
2) Your comma or tab separated file with variant information
3) the full, absolute path of an output file 
do this for a comma or tab separated file if you provide columns for chromosome, position, and position-to with coordinates that are 1-based and inclusive. 

`bash query.sh <file_dir> <region_file> <output_string> <chrom column number> <pos column number> <concatenate TRUE/FALSE>`

This could also be parallelized with [BlueBox](https://github.com/huntdatacenter/BlueBox) to run many queries at once. 

You might want to know if there were any of your top hits that couldn't be found in the PheWAS lookup. You can get a list of all the unique SNPs that were found in your query, and then use that file to search with `grep`, but use the `-v` option to find original top SNPs that aren't in the query file.

```
cut -f 1,2 phecode.query.txt | sort | uniq > variants_found.txt
grep top_hits.tab -f variants_found.txt -v
```

### Step 3. Visualize results by plotting in R

We will use the phenotype manifest file to convert the UKB phenocode with the description and category and desired plotting color in R.

`Rscript plot_phewas.R` 
