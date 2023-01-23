#!/usr/bin/bash

for Read1 in $(ls fastq/resequenced | grep "R1")
do
Sample=$(echo $Read1 | cut -d"-" -f1)
Read2=$(ls fastq/resequenced | grep "R2" | grep ^$Sample-)
fileFix=$(echo $Read1 | cut -d_ -f1)

# Generate processed fastq
../fastp/fastp -w 4 -f 15 -l 35 -c --dedup --detect_adapter_for_pe  -i ./fastq/resequenced/$Read1 -I ./fastq/resequenced/$Read2 -o ./RAMdrive/fastp_"$Read1" -O ./RAMdrive/fastp_"$Read2"
# Move fastp QC-files
#mv fastp.json fastp/resequenced/$fileFix.json
#mv fastp.html fastp/resequenced/$fileFix.html

# Align using STAR instead
STAR --runMode alignReads --genomeDir "./genome" --runThreadN 8 --limitBAMsortRAM 1200000000 --readFilesCommand zcat --readFilesIn ./RAMdrive/fastp_"$Read1"  ./RAMdrive/fastp_"$Read2" --sjdbGTFfile "./genome/Saccharomyces_cerevisiae.R64-1-1.106.gtf" --outFileNamePrefix ./STAR/"$fileFix"_ --outSAMtype BAM SortedByCoordinate
mv STAR/"$fileFix"_Aligned.sortedByCoord.out.bam STAR/"$fileFix".bam
samtools index STAR/"$fileFix".bam
mv STAR/*.bam ./BAM/STAR/resequenced/
mv STAR/*.bai ./BAM/STAR/resequenced/
rm -R STAR/*


# Empty RAMdrive
rm ./RAMdrive/fastp_"$Read1"
rm ./RAMdrive/fastp_"$Read2"
done
