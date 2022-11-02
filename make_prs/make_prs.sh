plink=/mnt/work/software/plink/2/plink2

pfile=$1
weights=$2
prefix=$3

$plink \
    --pfile $pfile \
    --score $weights 2 3 4 \
    --out $prefix
