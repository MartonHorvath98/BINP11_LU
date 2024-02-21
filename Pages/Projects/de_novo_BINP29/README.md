# De novo sequencing project

## 1. Setting up the environment
I set up a new work environment in Conda, named 'denovo' where I downloaded the sratoolkit from the conda repository using:
```bash
(denovo)$ conda install bioconda::sra-tools
```
Then, I downloaded the sequence file - SRR13577846 - from NCBI's sequence read archive ([SRA](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR13577846&display=metadata)) database, made the file(s) write-protected from all users and groups and. The raw data files are added to the `.gitignore` file to keep them from being uploaded to GitHub.
```bash
(denovo)$ prefetch SRR13577846 -O data

2024-02-21T09:49:38 prefetch.3.0.10: Current preference is set to retrieve SRA Normalized Format files with full base quality scores.
2024-02-21T09:49:38 prefetch.3.0.10: 1) Downloading 'SRR13577846'...
2024-02-21T09:49:38 prefetch.3.0.10: SRA Normalized Format file is being retrieved, if this is different from your preference, it may be due to current file availability.
2024-02-21T09:49:38 prefetch.3.0.10:  Downloading via HTTPS...
2024-02-21T09:50:10 prefetch.3.0.10:  HTTPS download succeed
2024-02-21T09:50:13 prefetch.3.0.10:  'SRR13577846' is valid
2024-02-21T09:50:13 prefetch.3.0.10: 1) 'SRR13577846' was downloaded successfully
2024-02-21T09:50:13 prefetch.3.0.10: 'SRR13577846' has 0 unresolved dependencies

(denovo)$ fastq-dump --split-files data/SRR13577846 -O data/
Read 117525 spots for SRR13577846
Written 117525 spots for SRR13577846

(denovo)$ chmod -R a-wx data/
```
