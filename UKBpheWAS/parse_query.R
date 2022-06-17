#!/usr/bin/R

if(!require(optparse)){
    install.packages("optparse")
    library(optparse)
}
library(dplyr)
library(data.table)
library(readxl)

option_list <- list(
  make_option("--prefix",type="character",default="",help="prefix for files to merge"),
  make_option("--path",type="character",default="",help="path for files to merge"),
  make_option("--output",type="character",default="output.tab","output file name"),
  make_option("--filter",type="character",default=".xlsx file to filter results")
  )

parser <- OptionParser(usage="%prog [options]", option_list=option_list)

args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

print(nrow(all))

my_files<-list.files(path=opt$path,pattern=paste0(opt$prefix,"*"))
print(my_files)

for (f in 1:length(my_files)){
    if (f==1){
        all<-fread(my_files[f])
     } else {
	df<-fread(my_files[f],header=TRUE)
	all<-dplyr::bind_rows(all,df)
}}

print("Number of traits in query")
print(nrow(all))
print(length(unique(all$file)))

if (file.exists(opt$filter)){
   print("Filtering")
   df<-read_excel(opt$filter)
   df$filename<-ifelse(is.na(df$modifier),
   paste(sep="-",df$trait_type,df$phenocode,df$pheno_sex),
    paste(sep="-",df$trait_type,df$phenocode,df$pheno_sex,df$modifier))
   filter_list<-unique(df$filename)
   print(length(filter_list))
   #required names are  trait_type phenocode pheno_sex modifier
   #make file name that should match the file column from query 
   filtered<-all %>% filter(file %in% filter_list)
   print(nrow(filtered))
   write.table(filtered,file=opt$output,quote=FALSE,sep="\t",row.names=FALSE)

} else {
  write.table(all,file=opt$output,quote=FALSE,sep="\t",row.names=FALSE)
}



