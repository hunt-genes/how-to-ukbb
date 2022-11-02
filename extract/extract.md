# ukb_extract

# Warning!
Do not transfer individual-level data off the lab    
Summary-level data can be tranfered as per our ethics application and UKBB approval   

## Description
These scripts are to subset the main phenotype and genotype files    

## extract_phe
Extract phenotypes. Phenotypes are any variable contained in a field.    
Fields can be found using the UKB data showcase:     
https://biobank.ndph.ox.ac.uk/ukb/search.cgi     

Once you have a list of fields you can extract them using the below command:    
username@hunt-ukbb-home:~/scratch/repo/ukb_extract/extract_phe$ `bash extract_phe.sh ~/projects/example/input_example.txt`

where `input_example.txt` contains the list of fields:    
Field_ID     
34   
22001   
22006   
22009  
22000      

Pleas note: ~/projects/example/input_example.txt is just an example

## extract_snp
Most of the genotypes in biobank are found in the bulk downloads. The most common genotypes of interest are SNPs.    
Variants can be found using the UKB data showcase:     
https://biobank.ctsu.ox.ac.uk/crystal/gsearch.cgi
  
Once you have a list of variants you can extract them using the below command:     
username@hunt-ukbb-home:~/scratch/repo/ukb_extract/extract_snp$ `bash extract_snp.sh ch_rsid.txt dose`

where `ch_rsid.txt` contains the chromosome and rsid:     
2 rs142760803       
4 rs1917332       
13 rs74737349      

Please note: the output format can be `bgen`, `vcf`, `dose` or `plink2`.

[BACK-TO-HOME-PAGE](https://github.com/hunt-genes/how-to-ukbb)
