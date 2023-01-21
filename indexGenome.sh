#!/usr/bin/bash
# Create Saccharomyces cerevisiae index in genome directory
../barracuda_0.7.107h/barracuda/bin/barracuda  index genome/Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.106.fa

# Or using STAR
STAR --runMode genomeGenerate --genomeSAindexNbases 10 --runThreadN 4 --genomeDir ./genome --genomeFastaFiles ./genome/Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.106.fa --sjdbGTFfile ./genome/Saccharomyces_cerevisiae.R64-1-1.106.gtf
