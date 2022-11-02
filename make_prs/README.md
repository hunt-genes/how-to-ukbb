# make_prs

# Warning!
Do not transfer individual-level data off the lab    
Summary-level data can be tranfered as per our ethics application and UKBB approval   

## Description
This script is to creat a PRS in PLINK2 

## Dependencies
To make a PRS you need to already have a pgen file from PLINK with genotype dosages.    
If you need to extract this, please follow these intructions:        
[Extract a genotype file](https://github.com/hunt-genes/how-to-ukbb/blob/main/extract/extract.md)    

## Step 1
Run this command from your folder with the input files:     
username@hunt-ukbb-home:`/mnt/scratch/repo/how-to-ukbb/make_prs.sh ukb_imp_extract_35snps example_weights.txt example_prs`

Where `ukb_imp_extract_35snps` is the output from [Extract a genotype file](https://github.com/hunt-genes/how-to-ukbb/blob/main/extract/extract.md)     

Where `example_weights.txt` Columns MUST be in this order!       

1	rs1933064	A	0.0155068    
1	rs76798800	G	0.0173898    
1	rs6672758	T	0.0156301    
2	rs727857	G	0.0109131    
2	rs1047891	C	0.0126572    

Where `example_prs` is the prefix for the output files (can include output directory)        

[BACK-TO-HOME-PAGE](https://github.com/hunt-genes/how-to-ukbb)
