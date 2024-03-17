# The origin of human malaria

The species - belonging to the genera *Plasmodium* - that causes most malaria infections in humans is *Plasmodium falciparum*. Working with a set of genomes from *Plasmodium* parasites, including a newly sequenced species - *Haemoproteus tartakovskyi* - that infects birds, we try to uncover the phylogeny of the human pathogen.  

## Directory tree
```bash
.
├── bin
│   ├── cleanAves.sh
│   ├── genePred.sh
│   ├── gffParse.pl
│   ├── QC.sh
│   └── removeScaffold.py
├── data
│   ├── raw_genomes
│   └── uniprot
├── environment.yml
├── __pycache__
│   └── utils.cpython-312.pyc
├── results
│   ├── 01_QC
│   ├── 02_gene_prediction
│   └── 03_cleaned_genomes
├── Snakefile
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

The gene prediction step was executed from the Genemark-ES.hmm3 algorithm from the gmes suite using the `gmes_petap.pl` function. It is a rather time consuming step as well as the suite requires a licence to allow usage, hence this step must be run on the university servers. COnsidering that there was many assemblies with low contig length, I used a low contig length of 1000 for the initial round of gene prediction.  As an intermediate rule of the snakemake pipeline we call the genePred.sh script from the /bin folder to execute the quality check:

```bash
# Running the Genemark-ES.hmm3 algorithm
gmes_petap.pl --ES --min_contig ${min_contig} --cores 100 --sequence ${f} --work_dir ${wd}
# --min_contig was set to 1000, individual output directories were created for each species 
# using their initials - e.g., Haemoproteus tartakovskyi => Ht
```
Because `gmes_petap.pl` attaches extra information to the header of the fasta sequences on its output .gtf file, we have to execute an extra step to remove these for further steps of the workflow. Otherwise, we will face compatibility issues. I used a for loop to copy and modify each output .gtf file:
```bash
# Visit the output directory, move the gene prediction files to the main output directory
for d in ${out_dir}/*; do
    echo "$out_dir"
    if [ -d "$d" ]; then
        species=$(basename $d)
        cat ${out_dir}/${d}/genemark.gtf | sed -e "s/\s*length=[[:digit:]]*.*numreads=[[:digit:]]*\b//gm" > ${out_dir}/genemark.${species}.gtf
        # remove the length and numreads labels and rename the files to include the species names
    fi
done
```

## Removing contamination from avian hosts from the *H. tartakovskyi* genome

To execute this action, the cleanAves.sh script was called from the bin/ folder during during the next rule in the Snakefile workflow. This script is used to remove contigs from the genome assembly that map to bird genomes! It takes the assembly in fasta format and a gtf file as input and outputs a filtered genome assembly in fasta format. The script uses the custom scripts removeScaffold.py and gffParser.pl: 
1. removeScaffold.py is used to remove contigs below a given GC threshold and length 
```bash
# Run the removeScaffold.py script
python bin/removeScaffold.py $fasta $gc_threshold $gene_dir/$output"_GC"$gc_threshold 3000
# removeScaffold.py usage: removeScaffolds.py [arg1] [arg2] [arg3] [arg4]
#   -   sys.argv[1] is input fasta file name
#   -   sys.argv[2] is threshold GC content as integer
#   -   sys.argv[3] is the output file
#   -   sys.argv[4] is the minimum length for scaffolds to keep
```
2. gffParser.pl is used to extract hypothetical proteins from the genome assembly.
```bash
# Run the gffParser.pl script
perl bin/gffParse.pl -i $gene_dir/$output"_GC"$gc_threshold".fa" -g $gtf -d $gene_dir/pred -b $output"_GC"$gc_threshold"_pred" -p -c    
# gffParser.py usage: gffParser.py -i -g -d -b -p* -c*
#   -   [-i] input fasta file
#   -   [-g] input gff file
#   -   [-d] output directory (MUST BE A NEW DIRECTORY)
#   -   [-b] output basename
#   -   [-p] if set the program outputs a protein file
#   -   [-c] if set, when an internal stop codon is found the program will try the next reading frame
```
The removeScaffold script already executes a prefiltration step to remove short sequences and sequences with a GC bias different from the species *H. tartakovskyi*. I selected to exclude anything abouve the mean GC (27%). Then, the script uses blastp to compare the proteins to the bird protein database downloaded from SwissProt and removes contigs that match any bird proteins among the top 5 hits. 
```bash
# Run blastp to compare the proteins to the bird protein database
blastp -query $gene_dir/$output"_GC"$gc_threshold"_pred.faa" -db SwissProt -outfmt 6 \
    -num_threads 160 -evalue 0.05 -out $blast_dir/$output"_GC"$gc_threshold"_hits.tsv" 
    # evalue cutoff is set to 0.05; the output format is tabular (6); the number of threads is set to 16
```
With 16 cores the blast search takes hours to run, using 160 cores on the server it was done within a few minutes. The bird database that has been used to select matching hits was download from UniProtDB. Taxonomy filter was set to taxid=8782 (Aves) and the resulting table was downloaded - `uniprotkb_taxid_aves.tsv`: including around 5.7 million proteins.

![fig1](results/01_QC/Ht_GC27.png)

Removing contigs with bird protein encoding genes in case of using a GC threshold of 27, there were 5074 scaffolds containing 6736 genes. Searching for proteins, where bird was among the top 5 hits, 67 (1.35%) scaffold were excluded. The top 5 hits excluded less than 2% of the contigs, hence I went with it end removed these contigs from the genome that has been previously filtered for GC content and assembly length previously. For the GC27 and GC30 genomes, this step removed 5.47% and 6.5% of the total sequences. Together with the GC and length filter 57.8% of the original assemlby was got filtered out.
```bash
cat $blast_dir/$output"_GC"$gc_threshold"_hits.tsv" |\
     awk 'NR==1 {value=$1; count=1} $1!=value {value=$1; count=1} $1==value && count<=5 {print; count++}' |\
     grep -Ff <(cut -f2 $bird_db) | cut -f1 | sort | uniq > $filtered_dir/$output"_GC"$gc_threshold"_genes.txt"
    # Find the contigs where the genes encoding these proteins are located
    cat $gtf | grep -wFf $filtered_dir/$output"_GC"$gc_threshold"_genes.txt" | cut -f1 | sort | uniq >\
     $filtered_dir/$output"_GC"$gc_threshold"_contigs.txt"
    # Remove these contigs from the genome assembly
    cat $gene_dir/$output"_GC"$gc_threshold".fa" |\
        grep -vFf $filtered_dir/$output"_GC"$gc_threshold"_contigs.txt" | grep -A 1 "^>" --no-group-separator >\
        $filtered_dir/$(basename $fasta)
```







