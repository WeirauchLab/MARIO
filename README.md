# MARIO pipeline

## MARIO version 3.1
* Added quality control of FASTQ files through the -q option
* Added use of BED file to generate a fake het-SNPs file spanning all positions
  in the BED file. This behavior is triggered if no genotyping file is given
  or the option -g is provided
* It now uses "bedtools closest" to annotate positions with disease SNPs and genes

## MARIO version 3.0
* Major rearrangement of the logic of the program
  It now has more control on the provided inputs and outputs
