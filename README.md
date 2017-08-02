# MARIO pipeline

_A one-sentence or one paragraph description of the pipeline, with some example
use cases._

## Installation requirements

fastqc, fastq-dump, hisat2, bowtie2, STAR, samtools, bedtools, picard-tools
MarkDuplicates, macs2, moods (locally-modified version)

## Usage

_two or three example use cases which could be run by the reviewers, and don't
require massive external datasets_

## Scheme of MARIO version 3.1 pipeline

```
+-----------------------------------------------------------+
|                                                           |
| +-----[I]                       +-----[B]       +-----[G] |
| | SRAID |                       |  BED  | ----> |  GEN  | |
| +-------+                       +-------+       +-------+ |
|     |                               ^               |     | 
|     |                               | (c)           |     |
|     v                               |               v     |
| +-----[S]       +-----[F]       +-----[A]       +-----[D] |       +=======+       +-----[P]
| |  SRA  | ----> | FASTQ | ----> |  BAM  | ----> |  DAT  | | ----> |  ASB  | <---- |  ANNO |
| +-------+       +-------+       +-------+       +-------+ |       +=======+       +-------+
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
[I] SRA ID (i.e. SRR292383 )
[S] SRA file (i.e. SRR292383.sra)
[F] Fastq file (paired-end reads should be given separated with ":", like: FQ1:FQ2)
[A] Alignment file (BAM format)
[D] DAT file (first ouput of the MARIO pipeline containing raw allelic counts)

Priority of input files:
  If multiple input files are privided (e.g.: SRA_ID, FASTQ and BAM files),
  the pipeline starts with the file with the highest priority.
  Priority:
  I<S<F<A<D (the DAT file has the highest priority)

(G) Genotyping file with heterozygous positions
    (required to generate DAT files)
(X) Index files for corresponding aligner
    (required to align reads to genome)
    (STAR index files for RNA-seq and BOWTIE2 index files for any other
    experiment type)
(P) Parameter file
(M) File with a list of motifs (PWMs)
    (optional)
```

### Optional parameters:

```
[f] Download SRA file and exit
[a] Generate FASTQ files and exit
[d] Generate BAM file and exit

Priority of switches:
  Priority:
  d<a<f
  If -f is called, the pipeline generates FASTQ files and exits, even if
  the -a or -d options are concurrently given

(B) Peaks file in BED format (optional)
(O) Name of output folder
(c) Do not call peaks
(b) Do not require het-SNPs to fall within peaks
(p) Number of threads (default: use all available threads)
(q) Do not perform quality control on FASTQ files
(r) Keep duplicate reads
(s) Input data is RNA-seq (STAR alignment)
(t) Input data is RNA-seq (HISAT2 alignment)
```


### Output files:

```
(ASB) Allele-specific behavior at each heterozygous positions, including
      reproducibility score (ARS) and annotations
(HIT) If motif files are given, the ASB file is further annotated with motif
      hits on each heterozygous position
```

## Change log:
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
