rule kraken2:
    input:
        reads = expand(os.path.join(config["results"]["rmrRna"], "{{sample}}.rmrRna{read}.fq.gz"),
                                        read=[".1", ".2"] if IS_PE else "")
    output:
        out = os.path.join(config["results"]["kraken2"], "{sample}.kraken2.output"),
        report = os.path.join(config["results"]["kraken2"], "{sample}.kraken2.report")
    params:
        database = config["params"]["kraken2"]["database"]
    threads:
        config["params"]["kraken2"]["threads"]
    log:
        os.path.join(config["logs"]["kraken2"], "{sample}.kraken2.log")
    run:
        if IS_PE:
            shell("kraken2 \
                    --use-names \
                    --threads {threads} \
                    --db {params.database} \
                    --output {output.out} \
                    --report {output.report} \
                    --report-zero-counts \
                    --paired \
                    --gzip-compressed \
                    {input.reads[0]} {input.reads[1]} 2> {log}")


rule bracken:
     input:
        os.path.join(config["results"]["kraken2"], "{sample}.kraken2.report")
     output:
        os.path.join(config["results"]["bracken"], "{sample}.bracken.output")
     params:
        database = config["params"]["bracken"]["database"], 
        threshold = config["params"]["bracken"]["threshold"]
     log:
        os.path.join(config["logs"]["bracken"], "{sample}.bracken.log")
     shell:
        '''
        /ldfssz1/ST_INFECTION/2019-nCoV/liangtianzhu/Braken/braken/Bracken-2.5/bracken \
        -d {params.database} \
        -i {input} \
        -o {output} \
        -t {params.threshold}\
        2> {log}
        '''

