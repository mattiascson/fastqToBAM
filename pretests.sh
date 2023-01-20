#! /usr/bin/bash

# Determine the largest fastq.gz files. Around 2 GB for each read in pair
#du ./fastq/ -a | sort -n 
Read1=$(ls fastq | grep "191" | grep "R1")
Read2=$(ls fastq | grep "191" | grep "R2")

# Mount ramdrive in terminal
# sudo mount -t tmpfs -o size=10g tmpfs RAMdrive

# Clock copy time from external HDD to RAMDrive
# /usr/bin/time -v cp fastq/191-Wt-35C-4h-5_S108_L002_R* RAMdrive

# Check fastp max memory and time usage when processed directly from external HDD.
# 4 treads -w, base correction -c, and autodetect adapters
# Storing processed files on internal fast SSD
#/usr/bin/time -v fastp -w 4 -c --detect_adapter_for_pe -i ./fastq/$Read1 -I ./fastq/$Read2 -o ./fastp_"$Read1" -O ./fastp_"$Read2"
#Using RAMdrive
/usr/bin/time -v fastp -w 4 -c --detect_adapter_for_pe -i ./RAMdrive/$Read1 -I ./RAMdrive/$Read2 -o ./RAMdrive/fastp_"$Read1" -O ./RAMdrive/fastp_"$Read2"