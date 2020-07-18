# MARIO pipeline

The MARIO (Measurement of Allelic Ratio Informatics Operator) pipeline was
designed to identify Allele-Dependent Behavior (ADB) within a sequencing
experiment at heterozygous positions identified through genotyping data.

The pipeline's flexible design allows for multiple uses, including downloading
SRA files from NCBI, quality control on FASTQ files, aligning to a genome using
three different aligners, etc. (detailed in diagram below).

The "Usage examples" section, below, demonstrates commands for various use cases.

For the associated publication, see [_Transcription factors operate across
disease loci, with EBNA2 implicated in autoimmunity._][doi], _Nature
Genetics_ 2018, by Harley JB, _et. al._; citation information for the MARIO
pipeline software itself can be found [below](#how-to-cite).

## External dependencies

 * [fastqc][]
 * [fastq-dump][fastqdump] (part of the [NCBI SRA Toolkit][sratk])
 * [hisat2][]
 * [bowtie2][]
 * [STAR][] ~ 2.5.x
 * [samtools][]
 * [bedtools][]
 * [picard-tools MarkDuplicates][pmd] (part of [Picard][])
 * [macs2][] (also installable [from PyPi][macspypi])

The MARIO pipeline also requires a locally-modified version of [MOODS][],
included in this repository.

MARIO is written in Perl and has a single third-party [CPAN][] dependency,
[Parallel::ForkManager][pfm], which might already be installed by your
sysadmin. If not, you could ask nicely for it to be installed, or refer to the
"Third-party Perl modules" section below for instructions on how to do it
yourself.

## Installation

You may download the latest release as a compressed archive
[from GitHub][grel], or clone the repository with Git:

    # GitHub
    git clone https://github.com/WeirauchLab/MARIO.git

    # Weirauch Lab GitLab
    git clone https://tfinternal.research.cchmc.org/gitlab/puj6ug/MARIO_pipeline.git

Then test your installation by run `./MARIO -h` from within the cloned repo or
expanded archive. If you receive an error about missing Perl modules, see the
next section.

The tool will automatically verify the presence of required external tools
(listed above) based on the mode of operation.

### Third-party Perl modules

The recommended way to install the required third-party CPAN module as
a non-root user is to set up [local::lib][ll], then type

    cpan Parallel::ForkManager

Newer versions of CPAN.pm support local::lib internally, and make the
necessary changes to your `~/.bashrc` during initial setup.

On systems with older (1.x) versions of CPAN, where local::lib is available (try
`perl -Mlocal::lib`), perform these steps:

1. add this line to your shell's rcfile (_e.g._, `~/.bashrc`)

        eval `perl -Mlocal::lib`

2. re-source your shell's rcfile (or quit and re-open your terminal session),
   then install the package with CPAN

        source ~/.bashrc
        cpan Parallel::ForkManager

If your system does not have local::lib available, you could ask your sysadmin
to install it globally, or else follow the [bootstrapping instructions][llboot]
in the local::lib documentation.

#### See also

* [this step-by-step local::lib tutorial][mojo] on the Mojolicous wiki
* if you get the error message `mkdir /root/.cpan - permission denied` when
  attempting to install the package with CPAN, refer to [this post][pm] on
  perlmonks.org


## Usage examples

_Hint: running `MARIO -h` produces a help screen, which you can then pipe through
`less`._

### Download and generate FASTQ files from SRR ID

    MARIO -I SRR1608989 -C config_3.4.0.txt

### ChIP-seq experiments or similar:

#### Align FASTQ reads to hg19 genome (starting from SRA file)

    MARIO -I SRR1608989.sra -C config_3.4.0.txt -uX path_to_BOWTIE2_aligner_index_files/hg19

### RNA-seq experiments:

#### Align FASTQ reads to hg19 genome (starting from SRA file)

    MARIO -I SRR1608989.sra -C config_3.4.0.txt -sX path_to_STAR_aligner_index_files
    
    MARIO -I SRR1608989.sra -C config_3.4.0.txt -tX path_to_HISAT2_aligner_index_files/hg19

### Align to genome using paired-end reads

    MARIO -F SRR1_1.fq.gz:SRR1_2.fq.gz -C config_3.4.0.txt -sX \
      path_to_STAR_aligner_index_files

### Align to genome using single and paired-end reads from different experiments

    MARIO -F SRR1_1.fq.gz:SRR1_2.fq.gz,SRR2.fq.gz -C config_3.4.0.txt -sX \
      path_to_STAR_aligner_index_files

### Call peaks on BAM files

    MARIO -cA SRR1.bam,SRR2.bam -C config_3.4.0.txt

### Find ADBs from BAM files

    MARIO -dA SRR1.bam,SRR2.bam -C config_3.4.0.txt -G path_to_genotyping_file/hetpos.txt

## Scheme of the MARIO pipeline

```
+-------------------------------------------+
|                                           |
| +-----[I]       +-----[B]       +-----[G] |
| | SRAID |       |  BED  | ----> |  GEN  | |
| +-------+       +-------+  (b)  +-------+ |
|     |               ^               |     | 
|     |               | (c)           |     |
|     v               |               v     |
| +-----[F]       +-----[A]       +-----[D] |       +=======+       +-----[C]
| | FASTQ | ----> |  BAM  | ----> |  DAT  | | ----> |  ADB  | <---- | ANNOT |
| +-------+  (a)  +-------+  (d)  +-------+ |       +=======+  (n)  +-------+
|    (q)              ^                     |           |
|                     |                     |           |
|                     |                     |           v
|                 +-----[X]                 |       +=======+       +-----[M]
|                 | INDEX |                 |       |  HIT  | <---- | MOTIF |
|                 +-------+                 |       +=======+       +-------+
|                                           |
+-------------------------------------------+
              BASIC FUNCTIONS                      ALLELE-DEPENDENT FUNCTIONS
```

### Input files:

```
-I  SRA ID (i.e. SRR1608989 )
-F  Fastq file (paired-end reads should be separated with \":\", like: FQ1:FQ2)
-A  Alignment file (BAM format)
-D  DAT file (first ouput of the MARIO pipeline containing raw allelic counts)

Priority of input files:
  If multiple input files are privided (e.g.: SRA_ID, FASTQ and BAM files),
  the pipeline starts with the file with the highest priority.

  I<S<F<A<D (the DAT file has the highest priority)

-G  Genotyping file with heterozygous positions
-X  Index files for corresponding aligner (STAR, HISAT2 and BOWTIE2 supported)
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
-a  Align FASTQ reads to the genome (generates BAM file)
-d  Find positions with ADBs (allele-dependent behavior)

-B  (optional) Peaks file in BED format
-O  Name of output folder (all files are saved here)
-c  Call peaks
-b  Do not require het-SNPs to fall within peaks
-i  Integrate or concatenate multiple FASTQ files (input with -I of -F options)
    Sometimes a single FASTQ file is split into multiple ones in GEO for a
    single experiment
-n  Annotate ADB results
    It will use the GENANNO_FILE and/or DISANNO_FILE specified in config file
-p  Number of threads (default: use all available threads)
-q  Perform quality control on FASTQ files
-r  Keep duplicate reads
-u  Perform aligment with BOWTIE2 (suitable for ChIP-seq)
-s  Perform alignment with STAR (suitable for RNA-seq)
-t  Perform alignment with HISAT2 (suitable for RNA-seq)
```

### Output files:

```
(BED) If the -c option is given, MACS2 called peaks are produced as a BED file.
      The BED file has 4 additional columns (6 through 9):
        6.  Number of reads under the peak
        7.  Peak width
        8.  RPKM, measured as the number of reads divided by the peak width,
             multiplied by 1,000,000 divided by the total number of reads under
             all peaks
        9.  TIER1 flag. If 1, the peak passed the minimum peak RPKM  requirement
        10. TIER2 flag. If 1, the peak passed the minimum peak width requirement
        11. TIER3 flag. If 1, the peak passed the minimum peak reads requirement
(ADB) Allele-dependent behavior at each heterozygous positions, including
      reproducibility score (ARS) and annotations.
(HIT) If motif files are given, the ADB file is further annotated with motif
      hits on each heterozygous position.
```

## Change log:

### MARIO version 3.8.1

* BugFix. Failed producing multiple BED files correctly

### MARIO version 3.8.0

* Peak BED files now report entire MACS2 output (for compatibility with IDR
  calculations) plus RPKMs and number of reads under peaks
* Expanded trimming capabilities: Trims adapter sequences if QC on reads fails
  on "Per base sequence quality" and "Per sequence quality scores"
* Bugfix. Trimming failed when having paired-end reads due to file naming issues
* Bugfix. BAM sorting failed due changing option in samtools
 (can only use samtools version 1.3 or higher now)
* Updated README.md
* Create CONFIG.txt instead of config_3.6.txt
* Better organization of the CONFIG.txt file

### MARIO version 3.7.0

* Added multiple ways of calling peaks with MACS2
* Added MD5 checksum check on downloaded SRA file
* Create config_3.6.txt instead of config_3.6.2.txt

### MARIO version 3.6.2

* Help output now includes description of -n option
* BugFix. BAM not sorted if dup reads not removed
* Improved output to screen for QC analysis
* Bugfix: temp sorted BAM files were not stored in correct directory
* BugFix. Path removed in file base name under -i option

### MARIO version 3.6.1

* Bugfix. Bug was introduced with the -i option

### MARIO version 3.6.0

* Added -i option to integrate or concatenate multiple FASTQ files into one

### MARIO version 3.5.0

* Downloads SRA files via FTP site using wget
  Before was downloaded via fastq-dump, but was too slow

### MARIO version 3.4.0

* Added functionality. Trims adapter sequences if QC on reads fails on "Adapter Content"
* Updated README.md

### MARIO version 3.3.2

* Bug fix. The program fastqc was hard-coded
* Bug fix. Couldn't do QC on fastq files alone
* Bug fix. Code not stopping if peak calls failed
* Bug fix. Fixed FASTQ file naming issues
* Corrections made to README.md
* Fixed inconsistensies in README.md

### MARIO version 3.3.0

* It can now annotate the DAT file with multiple arbitrary bed files
* Fixed input logic problems

### MARIO version 3.2.2

* Enhanced data input. It creates context-based environment, meaning that
  requires only the minimal amount of inputs, depending on the requested
  operations
* You can now decide whether to annotate ADB file or not, using the `-n` option

### MARIO version 3.1.0

* Added support for gzipped genotyping files
* Added aligning capabilities with the HISAT2 aligner (not recommended to use
* with masked genomes)
* Added quality control of FASTQ files through the `-q` option
* Added use of BED file to generate a fake het-SNPs file spanning all positions
  in the BED file. This behavior is triggered if no genotyping file is given
  or the option `-g` is provided
* It now uses "bedtools closest" to annotate positions with disease SNPs and
  genes

### MARIO version 3.0.0

* Major rearrangement of the logic of the program; now has more control on the
  provided inputs and outputs

## How to cite

Mario Pujato, The MARIO Pipeline, (2018), GitHub repository,
https://github.com/WeirauchLab/MARIO

### Associated _Nature Genetics_ publication 

[_Transcription factors operate across disease loci, with EBNA2 implicated in
autoimmunity._][pubmed]

Harley JB, Chen X, Pujato M, Miller D, Maddox A, Forney C, Magnusen AF, Lynch A,
Chetal K, Yukawa M, Barski A, Salomonis N, Kaufman KM, Kottyan LC, Weirauch MT.

_Nat Genet._ 2018 Apr 16. doi: [10.1038/s41588-018-0102-3][doi].

PMID: 29662164

## Feedback

Please report any issues with the MARIO pipeline (or feature suggestions) in our
[GitHub issue tracker][gi].

With other questions, you may contact [Dr. Matthew Weirauch][matt] via email.

## Contributors

| Name              | Institution                    | Remarks
|-------------------|--------------------------------|--------
| Dr. Mario Pujato  | Cincinnati Children's Hospital | _primary author_

## License

[GNU General Public License, v2][gplv2]. See [`LICENSE.txt`](LICENSE.txt).


[fastqc]: http://www.bioinformatics.babraham.ac.uk/projects/fastqc/
[fastqdump]: https://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?view=toolkit_doc&f=fastq-dump
[sratk]: https://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?view=software
[hisat2]: https://ccb.jhu.edu/software/hisat2/index.shtml
[bowtie2]: http://bowtie-bio.sourceforge.net/bowtie2/index.shtml
[star]: https://github.com/alexdobin/STAR
[samtools]: http://www.htslib.org/
[bedtools]: http://bedtools.readthedocs.io/en/latest/
[pmd]: https://broadinstitute.github.io/picard/command-line-overview.html#MarkDuplicates
[picard]: https://broadinstitute.github.io/picard/
[macs2]: https://github.com/taoliu/MACS/
[macspypi]: https://pypi.python.org/pypi/MACS2
[moods]: https://www.cs.helsinki.fi/group/pssmfind/
[cpan]: https://metacpan.org/pod/distribution/CPAN/scripts/cpan
[pfm]: https://metacpan.org/pod/Parallel::ForkManager
[ll]: https://metacpan.org/pod/local::lib
[pm]: http://www.perlmonks.org/?node_id=601013
[mojo]: https://github.com/kraih/mojo/wiki/Dreamhost#configuring-perl-with-locallib
[llboot]: https://metacpan.org/pod/local::lib#The-bootstrapping-technique
[gi]: https://github.com/WeirauchLab/MARIO/issues
[grel]: https://github.com/WeirauchLab/MARIO/releases
[matt]: mailto:Matthew.Weirauch@cchmc.org?subject=MARIO%20pipeline%20feedback)
[pubmed]: https://www.ncbi.nlm.nih.gov/pubmed/29662164
[doi]: https://dx.doi.org/10.1038/s41588-018-0102-3
[gplv2]: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html

