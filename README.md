# fastqToBAM

## fastp and barraCUDA

-   fastp for filtering, trimming and deduplication of reads.\
    fastp used min. read length 35 to prevent memory error in barraCUDA.\
    Both pairs are generated as RAMdrive files. fifo strategy does not work due to file being used both in alignment and during SAM generation.\

-   baraCUDA for alignment and SAM generation.\
    Uses three steps:\

    -   GPU aligns first pair processed fastq file generation from RAMdrive.\

    -   GPU aligns second pair processed fastq file generation from RAMdrive.\

    -   CPU combines both alignments on disk with fastq on RAMdrive.\

-   sam2bam sorts by coordinate, keeps MAPQ\>12, and set to run in RAM which makes deduplication already in fastp advisable.\
