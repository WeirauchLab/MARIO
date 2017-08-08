# MARIO pipeline

The MARIO (Measurement of Allelic Ratio Informatics Operator) pipeline was designed to identify
Allele-Specific Behavior (ASB) at heterozygous positions based on known genotyping information.

Additionaly, the flexible design allows for multiple uses (detailed in diagram below)

## External dependencies

 * fastqc
 * fastq-dump
 * hisat2
 * bowtie2
 * STAR
 * samtools
 * bedtools
 * picard-tools MarkDuplicates
 * macs2
 * moods (provided as a locally-modified version)

## Usage examples
### Download SRA file from NCBI based on SRR ID (the downloaded SRA file is 89Mb in size)
        MARIO -I SRR1608989
        MARIO -I SRR1608989,SRR1608990   (this one downloads two SRA files -89Mb and 99Mb files)

### Download and generate FASTQ files from SRR ID
        MARIO -fI SRR1608989 -C config_3.2.txt

### ChIP-seq experiments or similar:
#### Align FASTQ reads to hg19 genome (starting from downloaded SRA file)
        MARIO -aS SRR1608989.sra -C config_3.2.txt -X path_to_BOWTIE2_aligner_index_files/hg19

### RNA-seq experiments:
#### Align FASTQ reads to hg19 genome (starting from downloaded SRA file)
        MARIO -aS SRR1608989.sra -C config_3.2.txt -sX path_to_STAR_aligner_index_files
        MARIO -aS SRR1608989.sra -C config_3.2.txt -tX path_to_HISAT2_aligner_index_files/hg19

### Align to genome using paired-end reads
        MARIO -aF SRR1_1.fq.gz:SRR1_2.fq.gz -C config_3.2.txt -sX path_to_STAR_aligner_index_files

### Align to genome using single and paired-end reads from different experiments
        MARIO -aF SRR1_1.fq.gz:SRR1_2.fq.gz,SRR2.fq.gz -C config_3.2.txt -sX path_to_STAR_aligner_index_files

### Call peaks on BAM files
        MARIO -cA SRR1.bam,SRR2.bam -C config_3.2.txt

### Find ASBs from BAM files
        MARIO -dA SRR1.bam,SRR2.bam -C config_3.2.txt -G path_to_genotyping_file/hetpos.txt

## Scheme of the MARIO pipeline

```
+-----------------------------------------------------------+
|                                                           |
| +-----[I]                       +-----[B]       +-----[G] |
| | SRAID |                       |  BED  | ----> |  GEN  | |
| +-------+                       +-------+  (b)  +-------+ |
|     |                               ^               |     | 
|     |                               | (c)           |     |
|     v                               |               v     |
| +-----[S]       +-----[F]       +-----[A]       +-----[D] |       +=======+       +-----[C]
| |  SRA  | ----> | FASTQ | ----> |  BAM  | ----> |  DAT  | | ----> |  ASB  | <---- | ANNOT |
| +-------+  (f)  +-------+  (a)  +-------+  (d)  +-------+ |       +=======+  (n)  +-------+
|                    (q)              ^                     |           |
|                                     |                     |           |
|                                     |                     |           v
|                                 +-----[X]                 |       +=======+       +-----[M]
|                                 | INDEX |                 |       |  HIT  | <---- | MOTIF |
|                                 +-------+                 |       +=======+       +-------+
|                                                           |
+-----------------------------------------------------------+
```
### Input files:

```
-I  SRA ID (i.e. SRR1608989 )
-S  SRA file (i.e. SRR1608989.sra)
-F  Fastq file (paired-end reads should be given separated with \":\", like: FQ1:FQ2)
-A  Alignment file (BAM format)
-D  DAT file (first ouput of the MARIO pipeline containing raw allelic counts)

Priority of input files:
  If multiple input files are privided (e.g.: SRA_ID, FASTQ and BAM files),
  the pipeline starts with the file with the highest priority.

  I<S<F<A<D (the DAT file has the highest priority)

-G  Genotyping file with heterozygous positions
-X  Index files for corresponding aligner (STAR, HISAT2 and BOWTIE2 are supported)
      For BOWTIE2, add to the end of the index path the base name common
       to all the .bt2 files, like /path_to_index_files/hg19
      For HISAT2, add to the end of the index path the base name common
       to all the .ht2 files, like /path_to_index_files/hg19
      For STAR, nothing need to be added to the index path
-C  Configuration file (can be generated with the -y option)
-M  (optional) File with a list of motifs (PWMs)
```

### Optional parameters:

```
-f  Generate FASTQ files from SRA files
-a  Align FASTQ reads to the genome (generates BAM file)
-d  Find positions with ASBs (allele-specific behavior)

-B  (optional) Peaks file in BED format
-O  Name of output folder (all files are saved here)
-c  Call peaks
-b  Do not require het-SNPs to fall within peaks
-n  Annotate ASB results
      It will use the GENANNO_FILE and/or DISANNO_FILE specified in the configuration file
-p  Number of threads (default: use all available threads)
-q  Perform quality control on FASTQ files
-r  Keep duplicate reads
-s  Input data is RNA-seq (STAR alignment)
-t  Input data is RNA-seq (HISAT2 alignment)
```

### Output files:

```
(ASB) Allele-specific behavior at each heterozygous positions, including
      reproducibility score (ARS) and annotations
(HIT) If motif files are given, the ASB file is further annotated with motif
      hits on each heterozygous position
```

## Change log:
### MARIO version 3.2
* Enhanced data input. It creates context-based environment, meaning that requires only the minimal amount
  of inputs, depending on the requested operations
* You can now decide whether to annotate ASB file or not, using the "-n" option

### MARIO version 3.1
* Added support for gzipped genotyping files
* Added aligning capabilities with the HISAT2 aligner (not recommended to use with masked genomes)
* Added quality control of FASTQ files through the -q option
* Added use of BED file to generate a fake het-SNPs file spanning all positions
  in the BED file. This behavior is triggered if no genotyping file is given
  or the option -g is provided
* It now uses "bedtools closest" to annotate positions with disease SNPs and genes

### MARIO version 3.0
* Major rearrangement of the logic of the program
  It now has more control on the provided inputs and outputs

## How to cite

_fill this in whenever the publication details are available_

## Authors

| Name              | Email                       | Institution                    |
|-------------------|-----------------------------|--------------------------------|
| Dr. Mario Pujato  | mario.pujato -at- cchmc.org | Cincinnati Children's Hospital |
