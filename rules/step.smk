fastp_output = expand([
    "{trimming}/{sample}.trimmed{read}.fq.gz",
    "{trimming}/{sample}.fastp.html",
    "{trimming}/{sample}.fastp.json",
    "{trimming}/fastp_multiqc_report.html",
    "{trimming}/fastp_multiqc_report_data"
],
                      sample=_samples.index.unique(),
                      trimming=config["results"]["trimming"],
                      read=[".1", ".2"] if IS_PE else "")


raw_report_output = expand(
    "{reportout}/raw.stats.tsv",
    reportout=config["results"]["report"]["base_dir"])

trimming_report_output = expand(
    "{reportout}/trimming.stats.tsv",
    reportout=config["results"]["report"]["base_dir"])


trimming_output = ([])
if config["params"]["trimming"]["fastp"]["do"]:
    trimming_output = (fastp_output)

rmrRna_output = expand([
    "{rmrRna}/{sample}.rmrRna{read}.fq.gz",
    "{rmrRna}/{sample}.flagstat",
    "{rmrRna}/{sample}.Hisat2Genome.MapReadsStat.xls"
    ],
    rmrRna = config["results"]["rmrRna"],
    sample =_samples.index.unique(),
    read=[".1", ".2"])

kraken2_output = expand([
    "{kraken2}/{sample}.kraken2.output",
    "{kraken2}/{sample}.kraken2.report"
],
    sample=_samples.index.unique(),
    kraken2=config["results"]["kraken2"]
)


bracken_output = expand([
    "{bracken}/{sample}.bracken.output"
    ],
     bracken=config["results"]["bracken"],
     sample=_samples.index.unique()
)

rmhost_output = expand([
     "{rmhost}/{sample}.rmhost{read}.fq.gz"
    ],
    rmhost = config["results"]["rmhost"],
    sample = _samples.index.unique(),
    read=[".1", ".2"])

all_target = (
    trimming_output+
    rmrRna_output+
    kraken2_output+
    bracken_output+
    rmhost_output)
