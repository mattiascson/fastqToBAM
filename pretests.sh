#!/usr/bin/bash

# Determine the largest fastq.gz files. Around 2 GB for each read in pair
# du ./fastq/ -a | sort -n 

Read1=$(ls fastq | grep "191" | grep "R1")
Read2=$(ls fastq | grep "191" | grep "R2")

# Mount ramdrive in terminal
sudo mount -t tmpfs -o size=2g tmpfs RAMdrive

# Clock copy time from external HDD to RAMDrive
 /usr/bin/time -v cp fastq/191-Wt-35C-4h-5_S108_L002_R* RAMdrive

# Check fastp max memory and time usage when processed directly from external HDD.
# 4 treads -w, base correction -c, and autodetect adapters, removes 15 bases in the front, default quality threshold.
# Storing processed files on internal fast SSD
/usr/bin/time -v fastp -w 4 -f 15 -l 33 -c --detect_adapter_for_pe -i ./fastq/191-Wt-35C-4h-5_S108_L002_R1_001.fastq.gz -I ./fastq/191-Wt-35C-4h-5_S108_L002_R2_001.fastq.gz -o ./fastp_191-Wt-35C-4h-5_S108_L002_R1_001.fastq.gz -O ./fastp_191-Wt-35C-4h-5_S108_L002_R2_001.fastq.gz
/usr/bin/time -v fastp -w 4 -f 15 -l 33 -c --detect_adapter_for_pe  -i ./fastq/$Read1 -I ./fastq/$Read2 -o ./fastp_"$Read1" -O ./fastp_"$Read2"

# Using -w 4 -L -f 15 -c --detect_adapter_for_pe
#   Breaks FastQVAlidator Raw Sequence is shorter than the min read length and barraCUDA memory error
# Using -w 4 -L -c --detect_adapter_for_pe
#   Breaks FastQVAlidator Raw Sequence is shorter than the min read length and barraCUDA memory error
# Using -w 4 -c --detect_adapter_for_pe
#   FastQVAlidator works and barraCUDA memory error
# Using -w 4 -f 15 -c --detect_adapter_for_pe
#   FastQVAlidator works and barraCUDA memory error
# Using no parameters
#   FastQVAlidator works and barraCUDA memory error
# Using -w 4 -f 15 -l 15 -c --detect_adapter_for_pe
#   FastQVAlidator works and barraCUDA memory error
# Using gunzip to remove gz, from -w 4 -f 15 -l 15 -c --detect_adapter_for_pe
#   FastQVAlidator works and barraCUDA memory error
# Using -w 4 -f 15 -l 36 -c --detect_adapter_for_pe
#   FastQVAlidator works and barraCUDA Works!!!!!!!!!
# -w 4 -l 30 -f 15 -c Does not work barraCUDA memory error
# -w 4 -f 15 -l 30 -c Does not work barraCUDA memory error
# -w 4 -f 15 -l 33 -c --detect_adapter_for_pe Works
# -l 31 does not work, but -l 32 does work!!!!!!

#Using trimmomatic
TrimmomaticPE -threads 8 -phred33 ./fastq/191-Wt-35C-4h-5_S108_L002_R1_001.fastq.gz ./fastq/191-Wt-35C-4h-5_S108_L002_R2_001.fastq.gz trim_pair_191-Wt-35C-4h-5_S108_L002_R1_001.fastq trim_unpair_191-Wt-35C-4h-5_S108_L002_R1_001.fastq trim_pair_191-Wt-35C-4h-5_S108_L002_R2_001.fastq trim_unpair_191-Wt-35C-4h-5_S108_L002_R2_001.fastq HEADCROP:15 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
# Can two barraCUDA run
# Read 1
../barracuda_0.7.107h/barracuda/bin/barracuda aln ./genome/Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.106.fa ./trim_pair_191-Wt-35C-4h-5_S108_L002_R1_001.fastq > aln_sa1.sai
# Read 2
../barracuda_0.7.107h/barracuda/bin/barracuda aln ./genome/Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.106.fa ./trim_pair_191-Wt-35C-4h-5_S108_L002_R2_001.fastq > aln_sa2.sai
# No with MINLEN 15 but 36 works

#Using RAMdrive instead
/usr/bin/time -v fastp -w 4 -f 15 -c --detect_adapter_for_pe -i ./RAMdrive/$Read1 -I ./RAMdrive/$Read2 -o ./RAMdrive/fastp_"$Read1" -O ./RAMdrive/fastp_"$Read2"

# Using FastQCValidator
../FastQValidator.0.1.1/fastQValidator_0.1.1/bin/fastQValidator --file fastp_191-Wt-35C-4h-5_S108_L002_R1_001.fastq.gz
../FastQValidator.0.1.1/fastQValidator_0.1.1/bin/fastQValidator --file fastp_191-Wt-35C-4h-5_S108_L002_R1_001.fastq.gz

# Can two barraCUDA aligners run at same time? No out of memory
# Read 1
../barracuda_0.7.107h/barracuda/bin/barracuda aln ./genome/Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.106.fa ./fastp_191-Wt-35C-4h-5_S108_L002_R1_001.fastq.gz > aln_sa1.sai
# Read 2
../barracuda_0.7.107h/barracuda/bin/barracuda aln ./genome/Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.106.fa ./fastp_191-Wt-35C-4h-5_S108_L002_R2_001.fastq.gz > aln_sa2.sai

# Can barraCUDA take output fastq file from fastp for alignment from during run for first pair? No outruns fastp and terminates

# Can barraCUDA take piped/fifo fastq from fastp for alignment from RAMdrive/fastqToAlign for first pair? Yes
fastp -w 4 -f 15 -l 33 -c --detect_adapter_for_pe -i ./fastq/191-Wt-35C-4h-5_S108_L002_R1_001.fastq.gz -I ./fastq/191-Wt-35C-4h-5_S108_L002_R2_001.fastq.gz -o ./RAMdrive/fastqToAlign -O ./fastp_191-Wt-35C-4h-5_S108_L002_R2_001.fastq.gz
../barracuda_0.7.107h/barracuda/bin/barracuda aln ./genome/Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.106.fa ./RAMdrive/fastqToAlign > aln_sa1.sai



# Align using STAR
STAR --runMode alignReads --genomeDir "./genome" --runThreadN 8 --readFilesCommand zcat --readFilesIn ./fastp_191-Wt-35C-4h-5_S108_L002_R1_001.fastq.gz  ./fastp_191-Wt-35C-4h-5_S108_L002_R2_001.fastq.gz --sjdbGTFfile "./genome/Saccharomyces_cerevisiae.R64-1-1.106.gtf" --outFileNamePrefix ./STAR/$fileFix --outSAMtype BAM SortedByCoordinate