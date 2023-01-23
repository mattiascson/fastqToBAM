#!/usr/bin/bash

for Read1 in $(ls fastq | grep "R1")
do
Sample=$(echo $Read1 | cut -d"-" -f1)
Read2=$(ls fastq | grep "R2" | grep ^$Sample-)
fileFix=$(echo $Read1 | cut -d_ -f1)

# Generate processed fastq
../fastp/fastp -w 4 -f 15 -l 35 -c --dedup --detect_adapter_for_pe  -i ./fastq/$Read1 -I ./fastq/$Read2 -o ./RAMdrive/fastp_"$Read1" -O ./RAMdrive/fastp_"$Read2"
# Move fastp QC-files
#mv fastp.json fastp/$fileFix.json
#mv fastp.html fastp/$fileFix.html

# Align using STAR instead
STAR --runMode alignReads --genomeDir "./genome" --runThreadN 8 --limitBAMsortRAM 1200000000 --readFilesCommand zcat --readFilesIn ./RAMdrive/fastp_"$Read1"  ./RAMdrive/fastp_"$Read2" --sjdbGTFfile "./genome/Saccharomyces_cerevisiae.R64-1-1.106.gtf" --outFileNamePrefix ./STAR/"$fileFix"_ --outSAMtype BAM SortedByCoordinate
mv STAR/"$fileFix"_Aligned.sortedByCoord.out.bam STAR/"$fileFix".bam
samtools index STAR/"$fileFix".bam
mv STAR/*.bam ./BAM/STAR/firstSequenced/
mv STAR/*.bai ./BAM/STAR/firstSequenced/
rm -R STAR/*

# Empty RAMdrive
rm ./RAMdrive/fastp_"$Read1"
rm ./RAMdrive/fastp_"$Read2"
done
