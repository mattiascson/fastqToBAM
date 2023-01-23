#!/usr/bin/bash

### for exon counts
rm RAMdrive/fifoA
rm RAMdrive/fifoB
mkfifo RAMdrive/fifoA
mkfifo RAMdrive/fifoB

# Set up genes(names), from any count file
countFile=$(ls featurecounts/STAR/ | grep "exon" | grep -v "summary" | head -n1)
genes=$(cat featurecounts/STAR/$countFile | awk 'NR>2 { print $1 }')

# Init counts tabla
echo -e "Genes\n""$genes" > RAMdrive/exonTable.csv
sample=$(echo $countFile | cut -d"_" -f1)

# for each countfile check order of genes and add counts to table
for countFile in $(ls featurecounts/STAR/ | grep "exon" | grep -v "summary")
do
echo $countFile
sample=$(echo $countFile | cut -d"_" -f1)
newGenes=$(cat featurecounts/STAR/$countFile | awk 'NR>2 { print $1 }')
  if [[ $genes == $newGenes ]]
  then
    echo "Equal genes"
    cat RAMdrive/exonTable.csv > RAMdrive/fifoA &
    cat featurecounts/STAR/$countFile | awk -v sampl=$sample ' NR==1{print sampl};NR>2 { print $7 }' > RAMdrive/fifoB &
    paste RAMdrive/fifoA RAMdrive/fifoB > RAMdrive/exonTable.temp
    mv RAMdrive/exonTable.temp RAMdrive/exonTable.csv
  else
    echo "Non-equal genes error"
    exit 1
  fi
done
cp RAMdrive/exonTable.csv featurecounts/STAR/

sleep 5

### For gene counts
rm RAMdrive/fifoA
rm RAMdrive/fifoB
mkfifo RAMdrive/fifoA
mkfifo RAMdrive/fifoB

# Set up genes(names), from any count file
countFile=$(ls featurecounts/STAR/ | grep "gene" | grep -v "summary" | head -n1)
genes=$(cat featurecounts/STAR/$countFile | awk 'NR>2 { print $1 }')

# Init counts tabla
echo -e "Genes\n""$genes" > RAMdrive/geneTable.csv
sample=$(echo $countFile | cut -d"_" -f1)

# for each countfile check order of genes and add counts to table
for countFile in $(ls featurecounts/STAR/ | grep "gene" | grep -v "summary")
do
echo $countFile
sample=$(echo $countFile | cut -d"_" -f1)
newGenes=$(cat featurecounts/STAR/$countFile | awk 'NR>2 { print $1 }')
  if [[ $genes == $newGenes ]]
  then
    echo "Equal genes"
    cat RAMdrive/geneTable.csv > RAMdrive/fifoA &
    cat featurecounts/STAR/$countFile | awk -v sampl=$sample ' NR==1{print sampl};NR>2 { print $7 }' > RAMdrive/fifoB &
    paste RAMdrive/fifoA RAMdrive/fifoB > RAMdrive/geneTable.temp
    mv RAMdrive/geneTable.temp RAMdrive/geneTable.csv
  else
    echo "Non-equal genes error"
    exit 1
  fi
done
cp RAMdrive/geneTable.csv featurecounts/STAR/