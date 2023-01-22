#!/bin/bash

# Count over exons in BAM
for File in $(ls BAM | grep "bam"| grep -v "bai")
do
Sample=$(echo $File | cut -d_ -f 1)
featureCounts \
-a "./genome/Saccharomyces_cerevisiae.R64-1-1.106.gtf" \
-o "./featurecounts/barraCUDA/${Sample}_exon.txt" \
-F "GTF" \
-t "exon" \
-g "gene_id" \
-p \
-s 2 \
-T 8 \
./BAM/$File
done

# Count over exons in BAM/merged
for File in $(ls BAM/merged | grep "bam"| grep -v "bai")
do
Sample=$(echo $File | cut -d_ -f 1)
featureCounts \
-a "./genome/Saccharomyces_cerevisiae.R64-1-1.106.gtf" \
-o "./featurecounts/barraCUDA/${Sample}_exon.txt" \
-F "GTF" \
-t "exon" \
-g "gene_id" \
-p \
-s 2 \
-T 8 \
./BAM/merged/$File
done

# Count over gene in BAM
for File in $(ls BAM | grep "bam"| grep -v "bai")
do
Sample=$(echo $File | cut -d_ -f 1)
featureCounts \
-a "./genome/Saccharomyces_cerevisiae.R64-1-1.106.gtf" \
-o "./featurecounts/barraCUDA/${Sample}_gene.txt" \
-F "GTF" \
-t "gene" \
-g "gene_id" \
-p \
-s 2 \
-T 8 \
./BAM/$File
done

# Count over gene in BAM/merged
for File in $(ls BAM/merged | grep "bam"| grep -v "bai")
do
Sample=$(echo $File | cut -d_ -f 1)
featureCounts \
-a "./genome/Saccharomyces_cerevisiae.R64-1-1.106.gtf" \
-o "./featurecounts/barraCUDA/${Sample}_gene.txt" \
-F "GTF" \
-t "gene" \
-g "gene_id" \
-p \
-s 2 \
-T 8 \
./BAM/merged/$File
done