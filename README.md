# RNA-seq-2019nCov
RNA-seq pipeline 

## Introduction
 >The raw metatranscriptomic reads were processed using **Fastp** to filter low-quality data and adapter contaminations and generate the clean reads for further analyses. Human-derived reads were identified with the following steps: 1) identification of human ribosomal RNA (rRNA) by aligning clean reads to human rRNA sequences using **BWA-MEM** ; 2) identification of human transcripts by mapping reads to the hg19 reference genome using the RNA-seq aligner **HISAT2** ; and 3) a second-round identification of human reads by aligning remaining reads to hg 38 using **Kraken 2**. All human RNA reads were then removed to generate qualified non-human RNA-seq data.
 
 >The remaining non-human non-rRNA reads were processed by **Kraken 2X v2.08 beta**. Non-viral microbial taxon assignment of the non-human non-rRNA reads was performed using clade-specific marker gene-based **MetaPhAln2** with the default parameter options for non-viral microbial composition(--ignore-viruses).

<div align=center><img width="300" height="600" src="https://github.com/rusher321/RNA-seq-2019nCov/blob/master/pipeline.png"/></div>
 
## Requirements:

python: v3+   
  
Software for This pipeline:
* [fastp 0.20.1](https://github.com/OpenGene/fastp)
* [Kraken v2](https://ccb.jhu.edu/software/kraken2/index.shtm)
* [bracken 2.5](https://github.com/jenniferlu717/Bracken)
* [bwa 0.7.17-r1188](https://github.com/lh3/bwa)
* [HISAT2 2.1.0](https://ccb.jhu.edu/software/hisat2/index.shtml)
* [SorMeRNA 4.2.0](https://github.com/biocore/sortmerna)
* [Metaphlan2](https://github.com/biobakery/metaphlan)



## Installation
```
git clone https://github.com/rusher321/RNA-seq-2019nCov.git
```
Notes: The above dependent software needs to be installed separately according to their instructions. After installing, the users should edit the config.yaml file, and change the software path to your own path.

## Usage
### 1.Build the index for database
1) bulit the human rna index for bwa
```
      bwa index Human_rRNA_NCBI.fa
```
      
2) bulit the human genome index  for HISAT2
```
      hisat2-build index hg19.fa hg19 -p 6
```
3) bulit the kraken2 database index
```
      kraken-build --build --threads 8 --db ./YourDBpath/
      # add the human genome to the database 
      kraken2-build --add-to-library hg38.fa --db  ./YourDBpath/
      # add the HCoV-19 genome to the database 
      kraken2-build --add-to-library HCoV-19.fa --db  ./YourDBpath/
```
Here we used the **MiniKraken2_v2_8GB: (5.5GB) 8GB Kraken 2 Database built from the Refseq bacteria, archaea, and viral libraries and the GRCh38 human genome**
      
4) bulit the kraken2x database index
```
     kraken2-build --build --protein --db $DBNAME
```
5) Edit the config.yaml file, and change the database path to your own path


### 2.Run the pipeline.
**Input requirements**  
generate a sample information file like below:  
| id | fq1           | fq2           |
|----|---------------|---------------|
| demo1 | demo1.1.fq.gz    | demo1.2.fq.gz    |
| demo2 | demo2.1.fq.gz    | demo2.2.fq.gz    |
  
The header must be: id fq1 fq2.

**Init**  
`cd` to your workdir and run:
```
python /path/to/git/RNAseq init -d ./ -s samples.tsv 
```

**After that, in `yourdir` directory, inital files will be generated**  
```
ls ./
  
assay
results
scripts
sources
study
config.yaml
cluster.yaml
```
**generate command line and just run it on local computer**  
```
python /path/to/your/git/RNAseq commandline -d ./ -u all
```
  
```
snakemake --snakefile /path/to/your/git/Snakefile --configfile config.yaml --until all
```

   
**Or submit to cluster using qsub**  
```
snakemake --snakefile /path/to/git/Snakefile \
    --configfile ./config.yaml \
    --cluster-config ./cluster.yaml \
    --jobs 80 \
    --cluster "qsub -S /bin/bash -cwd \
               -q {cluster.queue} \
               -P {cluster.project} \
               -l vf={cluster.mem},p={cluster.cores} \
               -binding linear:{cluster.cores} \
               -o {cluster.output} \
               -e {cluster.error}" \
    --latency-wait 360 \
    -k \
    --until all
```
       

 
## Support & Bug Reports


Please log an issue on [github issue](https://github.com/rusher321/RNA-seq-2019nCov/issues)

 
## Contributors

- Huahui Ren 
- Zhun Shi

Thanks the support from **Jie Zhu - @alienzj**, **Jiahui Zhu**, **Fangming Yang**.

# License

Released under the MIT license.
 
