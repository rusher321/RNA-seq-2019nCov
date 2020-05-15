# RNA-seq-2019nCov
RNA-seq pipeline 

## Introduction
 >The raw metatranscriptomic reads were processed using **Fastp** to filter low-quality data and adapter contaminations and generate the clean reads for further analyses. Human-derived reads were identified with the following steps: 1) identification of human ribosomal RNA (rRNA) by aligning clean reads to human rRNA sequences using **BWA-MEM** ; 2) identification of human transcripts by mapping reads to the hg19 reference genome using the RNA-seq aligner **HISAT2** ; and 3) a second-round identification of human reads by aligning remaining reads to hg 38 using **Kraken 2**. All human RNA reads were then removed to generate qualified non-human RNA-seq data.
 
 >The remaining non-human non-rRNA reads were processed by **Kraken 2X v2.08 beta**. Non-viral microbial taxon assignment of the non-human non-rRNA reads was performed using clade-specific marker gene-based **MetaPhAln2** with the default parameter options for non-viral microbial composition(--ignore-viruses).

![Image aling="center"](https://github.com/rusher321/RNA-seq-2019nCov/blob/master/pipeline.png)

## Requirements:
python: vXXXX   
  

Software for This pipeline:  
* Kraken v1.1 (https://github.com/DerrickWood/kraken)  

## Installation
```
git clone https://github.com/rusher321/RNA-seq-2019nCov.git
```
Notes: The above dependent software needs to be installed separately according to their instructions. After installing, the users should edit the input.config file, and change the software path to your own path.

## Usage
### 1.Build the index for database

### 2.Run the pipeline.



