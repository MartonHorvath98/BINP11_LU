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
Then, use mamba to set up the Snakemake environment, to run the scripts.
```bash
mamba create -c conda-forge -c bioconda -n snakemake snakemake
mamba activate snakemake
```
## Usage
After the environment is all set up, we can run the whole script to go through the analysis process.
```bash
snakemake -p -j 16 --config ht="Haemoproteus_tartakovskyi"
# where -j [--cores] is a mandatory argument assigning the number of cores for parallel computations
#       --config is a user argument to select which genome should be addressed for cleaning 
```
## Quality check

After a quick preliminary quality check we can realise that one of the genome files has an errorenous format with the fasta header lines being repeated, that we have to correct before running anything:
```bash  
awk -v pattern="^>" '{print} $0 ~ pattern {getline; next}' Plasmodium_knowlesi.genome
```

Consequentially, we can run an initial quality control (QC) check on the genome file using the `stats` function from the seqkit package (v.2.7.0). As an intermediate rule of the snakemake pipeline we call the QC.sh script from the /bin folder to execute the quality check:

```bash
# Running the seqkit stats function
seqkit stats $file -Ta >> ${out_dir}/stats.txt
# End then cleaning up the output table with awk
awk 'NR==1 || NR%2==0' ${out_dir}/stats.txt | awk -F'\t' -v OFS='\t' '{sub(".*/", "", $1)} 1' > $out_dir1/stats_table.tsv 
```
| **file**                             | **format** | **type** | **num_seqs** | **sum_len**   | **min_len** | **avg_len**  | **max_len**  | **Q1**      | **Q2**      | **Q3**      | **sum_gap** | **N50**     | **Q20(%)** | **Q30(%)** | **AvgQual** | **GC(%)** |
|----------------------------------|--------|------|----------|-----------|---------|----------|----------|---------|---------|---------|---------|---------|--------|--------|---------|-------|
| Haemoproteus_tartakovskyi.genome | FASTA  | DNA  | 15048    | 27426784  | 100     | 1822.6   | 64494    | 335.0   | 725.0   | 1613.5  | 0       | 5219    | 0.00   | 0.00   | 0.00    | 27.40 |
| Plasmodium_berghei.genome        | FASTA  | DNA  | 7479     | 17954629  | 22      | 2400.7   | 37075    | 783.0   | 1240.0  | 2823.5  | 0       | 4226    | 0.00   | 0.00   | 0.00    | 23.71 |
| Plasmodium_cynomolgi.genome      | FASTA  | DNA  | 1663     | 26181343  | 1000    | 15743.4  | 3118530  | 1236.0  | 1593.0  | 2255.0  | 0       | 1717921 | 0.00   | 0.00   | 0.00    | 39.08 |
| Plasmodium_faciparum.genome      | FASTA  | DNA  | 15       | 23270305  | 5967    | 1551353.7| 3291871  | 1132099.5| 1419563.0| 1862996.0| 0       | 1687655 | 0.00   | 0.00   | 0.00    | 19.36 |
| Plasmodium_knowlesi.genome       | FASTA  | DNA  | 14       | 23462187  | 726886  | 1675870.5| 3159095  | 973297.0 | 1491037.5| 2200295.0| 0       | 2147124 | 0.00   | 0.00   | 0.00    | 37.54 |
| Plasmodium_vivax.genome          | FASTA  | DNA  | 2747     | 27007701  | 200     | 9831.7   | 3120417  | 809.5   | 986.0   | 1401.5  | 0       | 1678596 | 0.00   | 0.00   | 0.00    | 42.20 |
| Plasmodium_yoelii.genome         | FASTA  | DNA  | 130      | 22222369  | 1006    | 170941.3 | 2606237  | 2084.0  | 11133.5 | 54526.0 | 0       | 1027135 | 0.00   | 0.00   | 0.00    | 20.78 |
| Toxoplasma_gondii.genome         | FASTA  | DNA  | 2290     | 128105889 | 207     | 55941.4  | 7486190  | 797.0   | 1011.0  | 1241.0  | 0       | 5069724 | 0.00   | 0.00   | 0.00    | 52.20 |

We can see there are huge differences in the scaffold sizes of the assemblies and between the GC content of the individual species' genomic sequences as well.

## Predicting genes

The gene prediction step was executed from the Genemark-ES.hmm3 algorithm from the gmes suite using the `gmes_petap.pl` function. It is a rather time consuming step as well as the suite requires a licence to allow usage, hence this step must be run on the university servers. COnsidering that there was many assemblies with low contig length, I used a low contig length of 1000 for the initial round of gene prediction. 

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









