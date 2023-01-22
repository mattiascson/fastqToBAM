#!/usr/bin/bash

for Read1 in $(ls fastq/resequenced | grep "R1")
do
Sample=$(echo $Read1 | cut -d"-" -f1)
Read2=$(ls fastq/resequenced | grep "R2" | grep ^$Sample-)
fileFix=$(echo $Read1 | cut -d_ -f1)

# Generate processed fastq
../fastp/fastp -w 4 -f 15 -l 35 -c --dedup --detect_adapter_for_pe  -i ./fastq/resequenced/$Read1 -I ./fastq/resequenced/$Read2 -o ./RAMdrive/fastp_"$Read1" -O ./RAMdrive/fastp_"$Read2"
# Move fastp QC-files
mv fastp.json fastp/resequenced/$fileFix.json
mv fastp.html fastp/resequenced/$fileFix.html

# Align using STAR instead
#STAR --runMode alignReads --genomeDir "./genome" --runThreadN 8 --limitBAMsortRAM 1200000000 --readFilesCommand zcat --readFilesIn ./RAMdrive/fastp_"$Read1"  ./RAMdrive/fastp_"$Read2" --sjdbGTFfile "./genome/Saccharomyces_cerevisiae.R64-1-1.106.gtf" --outFileNamePrefix ./STAR/$fileFix --outSAMtype BAM SortedByCoordinate
#mv STAR/* /media/mattias/data2/SF-2245/STAR/

# Align first pair
../barracuda_0.7.107h/barracuda/bin/barracuda aln ./genome/Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.106.fa ./RAMdrive/fastp_"$Read1" > aln_sa1.sai

# Align second pair
../barracuda_0.7.107h/barracuda/bin/barracuda aln ./genome/Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.106.fa ./RAMdrive/fastp_"$Read2" > aln_sa2.sai

# Combine to SAM-file and fifo to BAM compressor
../barracuda_0.7.107h/barracuda/bin/barracuda sampe -V -t 8 genome/Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.106.fa aln_sa1.sai aln_sa2.sai ./RAMdrive/fastp_"$Read1" ./RAMdrive/fastp_"$Read2" > ./aln.sam
#../sam2bam/build/samtools/samtools sam2bam -Fsort_by_coordinate: -Fpre_filter:q=12 -o$(pwd)/aln.bam aln.sam
# sam2bam fails with resequenced data use regular samtools
samtools view -S -b aln.sam > aln_unsorted.bam
samtools sort aln_unsorted.bam -o aln.bam
rm aln_unsorted.bam
samtools index aln.bam

# Move BAMfile
mv aln.bam BAM/resequenced/"$fileFix"_fastp-dedup.bam
mv aln.bam.bai BAM/resequenced/"$fileFix"_fastp-dedup.bam.bai

# Empty RAMdrive
rm ./RAMdrive/fastp_"$Read1"
rm ./RAMdrive/fastp_"$Read2"
done
