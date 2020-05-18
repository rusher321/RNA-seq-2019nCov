rule metaphlan2:
    input:
        expand(os.path.join(config["results"]["sortmerna"],"{{sample}}/out/{{sample}}.sortmerna{ID}.fq.gz"),ID = ["_fwd","_rev"] if IS_PE else "")
    output:
        bt2out = os.path.join(config["results"]["metaphlan2"],"bt2out/{sample}.bt2out"),
        profile = os.path.join(config["results"]["metaphlan2"],"profile/{sample}.profile.txt")
    params:
        threads = config['params']['metaphlan2']['threads']
    shell:
        '''
        metaphlan2.py {input[0]},{input[1]} --input_type fastq --bowtie2out {output.bt2out} --nproc {params.threads} > {output.profile}
        '''
