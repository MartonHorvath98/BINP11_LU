# De novo sequencing project

## Directory tree
```bash
.
├── README.md
├── data/
│   ├── GCF_000146045.2_R64_genomic.fna
│   └── SRR13577846_1.fastq
├── results/
│   ├── 00_fastqc/
│   │   ├── multiqc_data/
│   │   └── multiqc_report.html
│   ├── 01_quality/
│   ├── 02_assembly/
│   │   ├── 00-assembly/
│   │   ├── 10-consensus/
│   │   ├── 20-repeat/
│   │   ├── 30-contigger/
│   │   ├── 40-polishing/
│   │   ├── assembly.fasta
│   │   ├── flye.log
│   └── 03_quast/
│       ├── aligned_stats/
│       ├── basic_stats/
│       ├── contigs_reports/
│       ├── genome_stats/
│       ├── multiqc_data/
│       ├── multiqc_report.html
│       ├── report.txt
├── environment.yml
└── workflow.sh
```
## 1. Data acquisition
I downloaded the sequence file - SRR13577846 - from NCBI's sequence read archive ([SRA](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR13577846&display=metadata)) database, made the file(s) write-protected from all users and groups and. The raw data files are added to the `.gitignore` file to keep them from being uploaded to GitHub.
```bash
prefetch SRR13577846 -O data
fastq-dump --split-files data/SRR13577846 -O data/
chmod -R a-wx data/

cd data && wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/146/045/GCF_000146045.2_R64/GCF_000146045.2_R64_genomic.fna.gz
```
## 2. Quality control
The quality of the reads was assessed using the fastQC (0.12.1) and multiQC (1.19) tools, the reads were found to be of very high quality and without significant contamination or other source of errors, hence no trimming was done.
```bash
fastqc -o results/00_fastqc -f fastq -t 10 ${indir}/SRR13577846.fastq
```

## 3. Long-read assembly
I chose to work with Flye (v2.9.3) de novo assembler, then execute polishing via QUAST (5.2.0).