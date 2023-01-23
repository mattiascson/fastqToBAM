#!/usr/bin/bash

# Move all BAM bai files, that were resequenced, from BAM to BAM/firstSequenced.
for fileReseq in $(ls BAM/STAR/resequenced | grep -v "bai")
do
#Sample=$(echo $fileReseq | cut -d"-" -f1) #Needed?
#fileFirstseq=$(ls BAM/STAR | grep -v "bai" | grep ^$Sample-) #Needed?
fileFix=$(echo $fileReseq | cut -d"." -f1)

FileBAM=$(ls BAM/STAR | grep $fileFix | grep -v "bai")
FileBai=$(ls BAM/STAR | grep $fileFix | grep "bai")

mv BAM/STAR/$FileBAM BAM/STAR/firstSequenced/
mv BAM/STAR/$FileBai BAM/STAR/firstSequenced/

samtools merge -o BAM/STAR/merged/$fileFix"_merged-unsorted.bam" BAM/STAR/resequenced/$fileReseq BAM/STAR/firstSequenced/$FileBAM
samtools sort BAM/STAR/merged/$fileFix"_merged-unsorted.bam" -o BAM/STAR/merged/$fileFix"_merged.bam"
rm BAM/STAR/merged/$fileFix"_merged-unsorted.bam"
samtools index BAM/STAR/merged/$fileFix"_merged.bam"
done