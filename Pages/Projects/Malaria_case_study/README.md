# The origin of human malaria

The species - belonging to the genera *Plasmodium* - that causes most malaria infections in humans is *Plasmodium falciparum*. Working with a set of genomes from *Plasmodium* parasites, including a newly sequenced species - *Haemoproteus tartakovskyi* - that infects birds, we try to uncover the phylogeny of the human pathogen.  

## Directory tree
```bash
.
├── README.md
├── data
│   ├── raw_genomes
│   ├── clean_genomes
│   └── uniprot
├── environment.yml
├── results
│   ├── 01_QC
│   │   ├── raw
│   │   ├── clean
│   ├── 02_gene_prediction
│   │   ├── raw
│   │   ├── clean
│   ├── 03_cleaned_genomes
│   │   ├── gene_prediction
│   │   ├── blastp
│   │   ├── clean_genome
│   └── 04_busco
│       └── BUSCO_assembly.fasta
└── workflow.sh
```
## Set up the environment
Download and install mamba through the recommended miniforge [installation](https://github.com/conda-forge/miniforge) process.
```bash
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh
```
Then, use mamba to set up the environment based on the *.yaml* file.
```bash
mamba create -f environment.yml
mamba activate malaria
```
## Usage
After the environment is all set up, we can run the whole script to go through the analysis process.
```bash
bash workflow.sh --clean Haemoproteus_tartakovskyi
```
## Quality check

(base) hmarton (Malaria) Malaria_case_study> awk -v pattern="^>" '{print} $0 ~ pattern {getline; next}' Plasmodium_knowlesi.genome | less

seqkit stats ../../data/Haemoproteus_tartakovskyi.genome -Ta -o H_tartakovskyi.stats

awk '/^>/ {printf("%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < Haemoproteus_tartakovskyi.genome | sed 's/>/\n>/g' > Haemoproteus_tartakovskyi.oneline 

cd results/01_qc/
python3 ~/binp29/Malaria/bin/removeScaffold.py  ~/binp29/Malaria/data/Haemoproteus_tartakovskyi.genome 27 HT.27.genome 3000
python3 ~/binp29/Malaria/bin/removeScaffold.py  ~/binp29/Malaria/data/Haemoproteus_tartakovskyi.genome 30 HT.30.genome 3000

## Predicting genes
gmes_petap.pl --ES --min_contig 3000 --cores 30 --sequence HT.27.clean.genome --work_dir GC27


cat results/02_gene_prediction/genemark.HT27.gtf | sed -e "s/\sGC=.*Length=[[:digit:]]*\b//gm" > genemark.HT27_fixed.gtf 

## Extract protein and dna sequences from the assembly 
perl bin/gffParse.pl -i results/01_qc/HT.27.genome -g results/02_gene_prediction/genemark.HT27_fixed.gtf -d results/03_clean_sequence/GC27 -b HT27  -p -c

Download bird protein names from UniProtDB - filtered for taxonomy - taxid=8782 (Aves):
uniprotkb_taxid_aves.tsv (5.7 million proteins)

## Blasting the predicted proteins with blastp algorithm on the SwissProt database
Run BLATSP on the UniProt database (1098 hits), then filter out hits with expect value lower than 0.05 (718 hits):
blastp -query ../04_clean_sequence/GC27/HT27.fna -db SwissProt -outfmt 6 -num_threads 16 -out  HT27_blastp_hits.tsv
cat ../03_blastp/HT27_blastp_hits.tsv | awk '$11 < 0.05 {print}' > HT27_blastp_exp05.tsv 

1. Approach - Remove any proteins that have hits in birds (315 hits):
cat ../03_blastp/HT27_blastp_exp05.tsv | grep -Ff <(cut -f 2 ../../data/uniprotkb_taxid_aves.tsv) | cut -f1 | sort | uniq > ../03_blastp/bird_genes.txt
cat HT27_blastp_exp05.tsv | grep -vFf bird_genes.txt > HT27_blastp_nobird.tsv

2. Approach - Remove protiens where one of the top five hits is from a bird (656 hits):
cat ../03_blastp/HT27_blastp_exp05.tsv | awk 'NR==1 {value=$1; count=1} $1!=value {value=$1; count=1} $1==value && count<=5 {print; count++}' | grep -Ff <(cut -f 2 ../../data/uniprotkb_taxid_aves.tsv) | cut -f1 | sort | uniq > ../03_blastp/bird_top5_genes.txt
cat HT27_blastp_exp05.tsv | grep -vFf bird_top5_genes.txt > HT27_blastp_nobird_top5.tsv

## Removing contigs with bird protein encoding genes
Get contigs that contain bird related proteins: in case of using a GC threshold of 27, there were 1602 scaffolds containing 2788 genes.
1. Searching for genes with top bird blastp hit, 15 (0.93%) contigs were excluded
2. Searching for proteins, where bird was among the top 5 hits, 67 (4.18%) scaffold were excluded

cat genemark.HT27_fixed.gtf | grep -wFf ../03_blastp/GC27/GC27_top.txt | cut -f1 | sort | uniq > GC27_top_contig.txt

Get contigs that contain bird related proteins: in case of using a GC threshold of 30, there were 2114 scaffolds containing 3688 genes.
1. Searching for genes with top bird blastp hit, 23 (0.62%) contigs were excluded
2. Searching for proteins, where bird was among the top 5 hits, 105 (2.85%) scaffold were excluded

cat genemark.HT30_fixed.gtf | grep -wFf ../03_blastp/GC30/GC30_top.txt | cut -f1 | sort | uniq > GC30_top_contig.txt

Top 5 hits excluded less than 5% of the contigs, hence I went with it end removed these contigs from the genome that has been previously filtered for GC content and assembly length previously. For the GC27 and GC30 genomes, this step removed 5.47% and 6.5% of the total sequences. 

cat ../01_qc/HT.27.genome | grep -vFf ../02_gene_prediction/GC27_top5_contig.txt | grep -A 1 "^>" --no-group-separator > HT.27.clean.genome
cat ../01_qc/HT.30.genome | grep -vFf ../02_gene_prediction/GC30_top5_contig.txt | grep -A 1 "^>" --no-group-separator > HT.30.clean.genome









