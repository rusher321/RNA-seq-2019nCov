import shutil

rule sortmerna:
    input:
        expand(os.path.join(config["results"]["rmhost"], "{{sample}}.rmhost{read}.fq.gz"),read=[".1", ".2"] if IS_PE else "")
    output:
        expand(os.path.join(config["results"]["sortmerna"],"{{sample}}/out/{{sample}}.sortmerna{ID}.fq.gz"),ID = ["_fwd","_rev"] if IS_PE else "")
    params:
        ref = config['params']['sortmerna']['ref'],
        options = config['params']['sortmerna']['options'],
        workdir = os.path.join(config["results"]["sortmerna"],"{sample}"),
        others = os.path.join(config["results"]["sortmerna"],"{sample}/out/{sample}.sortmerna"),
        fq = config["results"]["sortmerna"]+"/{sample}/out/{sample}.sortmerna*.fq"
    run:
        if os.path.exists(params.workdir):
            shell("rm -r {params.workdir}")
        shell('''
        sortmerna {params.ref} {params.options} --reads {input[0]} --reads {input[1]} --workdir {params.workdir} --other {params.others} &&
        gzip {params.fq}
        ''')
