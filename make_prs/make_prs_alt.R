# Make some alternative PRS calulations using PLINK2 and R

# Example data is take from the vit D and mortality project
sunlight_dose.txt.raw

library(data.table)

#Add weights to extracted genotype
df1 <- read.delim2('sunlight_dose.txt.raw', as.is=T, header=T, dec=".")
effects <- fread('sunlight_weights.txt',header=F)
effects$V5 <- paste0(effects$V2, "_", effects$V3)
effects <- effects[1:4,c(5,4)]
effects <- effects[1:4,]

# Alternative 1
# Shift column numbers from start(eg.7) to end plus buffer (+6)
# Update effect column names

startCol<-7
eaCol<-"V5"
weight<-"V4"

buffer=startCol-1
for (rsid in names(df1[7:as.integer(nrow(effects)+6)])){df1[,rsid] <- df1[,rsid]*effects[V5==rsid]$V4}

df1$grs_marta <- rowSums(df1[7:10])

# Alternative 2 - Weighted sum
df2 <- read.delim2('sunlight_dose.txt.raw', as.is=T, header=T, dec=".")
df2$w_score <- (df2[,7]*as.numeric(effects[1,2]) + df2[,8]*as.numeric(effects[2,2]) + df2[,9]*as.numeric(effects[3,2]) + df2[,10]*as.numeric(effects[4,2]))

df1$w_score <- (df1[7]*effects[1,2])
0.0061

# Alternative 3 - Total weighted number of SNPs
df2$w_avg_score <- ((df2$rs6671730_G*0.0061000 + df2$rs35408430_C*0.0236985 + df2$rs7522116_C*0.0116727 + df2$rs7528419_G*0.0179046)/(0.0061000+0.0236985+0.0116727+0.0179046))*4

# Alternative 4 - PLINK v2  --score cols=+scoresums
# Run this from the terminal
/mnt/work/software/plink/2/plink2 \
        --out sunlight_prs_4snps \
        --pfile /mnt/scratch/benb/extractsnp/20221025/ukb_imp_extract_35snps \
        --score sunlight_weights_4snps.txt 2 3 4 cols=+scoresums

# Alternative 5 - Total weighted number of SNPs automated PLINK+R
# Run Altternative 4 +
plink <- read.delim2('sunlight_prs_4snps.sscore', as.is=T, header=T, dec=".")
n_snps <- 4
plink$w_t_score2 <- ((plink$SCORE1_AVG*(n_snps*2))/sum(effects$V4))*n_snps

# Alternative 6 - Total weighted number of SNPs R ONLY
df1 <- read.delim2('sunlight_dose.txt.raw', as.is=T, header=T, dec=".")
effects <- fread('sunlight_weights.txt',header=F)
effects$V5 <- paste0(effects$V2, "_", effects$V3)
effects <- effects[1:4,c(5,4)]
effects <- effects[1:4,]

for (rsid in names(df1[7:as.integer(nrow(effects)+6)]))
        {df1[,rsid] <- df1[,rsid]*effects[V5==rsid]$V4}

df1$grs_marta2 <- (rowSums(df1[7:as.integer(nrow(effects)+6)])/sum(effects$V4))*as.integer(nrow(effects))

write.table(df1,"/home/benb/scratch/benb/vitD/w_grs_alternatives.txt", sep=",", quote=FALSE,row.names=FALSE,col.names=TRUE)
