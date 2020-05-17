rule rmrRna:
    input:
        reads = expand(os.path.join(config["results"]["trimming"], "{{sample}}.trimmed{read}.fq.gz"),
                                        read=[".1", ".2"] if IS_PE else "")
    output:
        out = temp(expand(os.path.join(config["results"]["rmrRna"], "{{sample}}.rmrRna{read}.fq.gz"),
                                        read=[".1", ".2"] if IS_PE else "")),
        report1 = expand(os.path.join(config["results"]["rmrRna"], "{{sample}}.flagstat")),
        report2 = expand(os.path.join(config["results"]["rmrRna"], "{{sample}}.Hisat2Genome.MapReadsStat.xls"))
    params:
        rmRNA = config["params"]["rmrRna"]["database"],
        hg19 = config["params"]["rmrRna"]["database2"],
        hg38 = config["params"]["rmrRna"]["database3"],
        src = config["params"]["src"],
        sample_id = "{sample}",
        outdir = config["results"]["rmrRna"]
    threads:
        config["params"]["rmrRna"]["threads"]
    run:
        if IS_PE:
            shell("sh {params.src}rm_RNA.sh \
                    -a {input.reads[0]} \
                    -b {input.reads[1]} \
                    -s {params.sample_id} \
                    -d {params.rmRNA} \
                    -m1 {params.hg19} \
                    -m2 {params.hg38} \
                    -p {threads} \
                    -r {output.report1} \
                    -x {output.report2} \
                    -o {params.outdir}")
