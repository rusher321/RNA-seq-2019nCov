rule kraken2x:
    input:
        reads = expand(os.path.join(config["results"]["sortmerna"], "{{sample}}/out/{{sample}}.sortmerna{read}.fq.gz"),read=["_fwd", "_rev"] if IS_PE else "")
    output:
        out = os.path.join(config["results"]["kraken2x"], "{sample}.kraken2x.output"),
        report = os.path.join(config["results"]["kraken2x"], "{sample}.kraken2x.report")
    params:
        database = config["params"]["kraken2x"]["database"]
    threads:
        config["params"]["kraken2x"]["threads"]
    log:
        os.path.join(config["logs"]["kraken2x"], "{sample}.kraken2x.log")
    run:
        if IS_PE:
            shell("kraken2 \
                   --threads {threads} \
                   --db {params.database} \
                   --output {output.out} \
                   --report {output.report} \
                   --paired \
                   --gzip-compressed \
                   {input.reads[0]} {input.reads[1]} 2> {log}")

