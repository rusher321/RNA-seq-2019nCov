rule rmkrahost:
    input:
        reads = expand(os.path.join(config["results"]["rmrRna"], "{{sample}}.rmrRna{read}.fq.gz"),
                                        read=[".1", ".2"] if IS_PE else ""),
        kraout = expand(os.path.join(config["results"]["kraken2"] , "{{sample}}.kraken2.output"))
    output:
        out = expand(os.path.join(config["results"]["rmhost"], "{{sample}}.rmhost{read}.fq.gz"),
                                        read=[".1", ".2"] if IS_PE else "")
    threads:
        config["params"]["rmkrahost"]["threads"]
    shell:
        '''
        cat {input.kraout}|grep -v "(taxid 9606)"|cut -f 2 | \
                    tee >(awk '{{print $0 "/1"}}'  - | seqtk subseq {input.reads[0]} - | pigz -p {threads} -c > {output.out[0]}) | \
                          awk '{{print $0 "/2"}}'  - | seqtk subseq {input.reads[1]} - | pigz -p {threads} -c > {output.out[1]}
        '''
