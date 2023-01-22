#!/usr/bin/bash

# Move all BAM bai files, that were resequenced, from BAM to BAM/firstSequenced.
for fileReseq in $(ls BAM/resequenced | grep -v "bai")
do
Sample=$(echo $fileReseq | cut -d"-" -f1)
fileFirstseq=$(ls BAM | grep -v "bai" | grep ^$Sample-)
fileFix=$(echo $fileReseq | cut -d_ -f1)

FileBAM=$(ls BAM | grep $fileFix | grep -v "bai")
FileBai=$(ls BAM | grep $fileFix | grep "bai")

mv BAM/$FileBAM BAM/firstSequenced/
mv BAM/$FileBai BAM/firstSequenced/

samtools merge -o BAM/merged/$fileFix"_fastp-dedup-merged-unsorted.bam" BAM/resequenced/$fileReseq BAM/firstSequenced/$FileBAM
samtools sort BAM/merged/$fileFix"_fastp-dedup-merged-unsorted.bam" -o BAM/merged/$fileFix"_fastp-dedup-merged.bam"
rm BAM/merged/$fileFix"_fastp-dedup-merged-unsorted.bam"
samtools index BAM/merged/$fileFix"_fastp-dedup-merged.bam"
done