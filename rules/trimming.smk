def raw_reads(wildcards):
    if IS_PE:
        return [sample.get_reads(_samples, wildcards, "fq1"),
                sample.get_reads(_samples, wildcards, "fq2")]
    else:
        return [sample.get_reads(_samples, wildcards, "fq1")]


if config["params"]["trimming"]["fastp"]["do"]:
    rule trimming_fastp:
        input:
            unpack(raw_reads)
        output:
            reads = temp(expand(os.path.join(config["results"]["trimming"], "{{sample}}.trimmed{read}.fq.gz"),
                                read=[".1", ".2"] if IS_PE else "")),
            html = os.path.join(config["results"]["trimming"], "{sample}.fastp.html"),
            json = os.path.join(config["results"]["trimming"], "{sample}.fastp.json")
        params:
            prefix = "{sample}",
            compression = config["params"]["trimming"]["fastp"]["compression"],
            cut_front_window_size = config["params"]["trimming"]["fastp"]["cut_front_window_size"],
            cut_front_mean_quality = config["params"]["trimming"]["fastp"]["cut_front_mean_quality"],
            cut_tail_window_size = config["params"]["trimming"]["fastp"]["cut_tail_window_size"],
            cut_tail_mean_quality = config["params"]["trimming"]["fastp"]["cut_tail_mean_quality"],
            cut_right_window_size = config["params"]["trimming"]["fastp"]["cut_right_window_size"],
            cut_right_mean_quality = config["params"]["trimming"]["fastp"]["cut_right_mean_quality"],
            length_required = config["params"]["trimming"]["fastp"]["length_required"],
            n_base_limit = config["params"]["trimming"]["fastp"]["n_base_limit"],
            adapter_trimming = '--disable_adapter_trimming' if config["params"]["trimming"]["fastp"]["disable_adapter_trimming"] else ""
        log:
            os.path.join(config["logs"]["trimming"], "{sample}.fastp.log")
        threads:
            config["params"]["trimming"]["fastp"]["threads"]
        run:
            reads_num = len(input)
            if IS_PE:
                if reads_num == 2:
                    if config["params"]["trimming"]["fastp"]["use_slide_window"]:
                        shell("fastp --in1 {input[0]} --in2 {input[1]} --out1 {output.reads[0]} --out2 {output.reads[1]} \
                               --compression {params.compression} {params.adapter_trimming} \
                               --cut_window_size {params.cut_front_window_size} \
                               --cut_mean_quality {params.cut_front_mean_quality} \
                               --n_base_limit {params.n_base_limit} --length_required {params.length_required} \
                               --thread {threads} --html {output.html} --json {output.json} 2> {log}")
                    else:
                        shell("fastp --in1 {input[0]} --in2 {input[1]} --out1 {output.reads[0]} --out2 {output.reads[1]} \
                               --compression {params.compression} {params.adapter_trimming} \
                               --cut_front_window_size {params.cut_front_window_size} \
                               --cut_front_mean_quality {params.cut_front_mean_quality} \
                               --cut_tail_window_size {params.cut_tail_window_size} \
                               --cut_tail_mean_quality {params.cut_tail_mean_quality} \
                               --n_base_limit {params.n_base_limit} --length_required {params.length_required} \
                               --thread {threads} --html {output.html} --json {output.json} 2> {log}")
                else:
                    r1_str = " ".join(input[0:reads_num//2])
                    r2_str = " ".join(input[reads_num//2:])
                    r1 = os.path.join(config["results"]["trimming"], "%s.raw.1.fq.gz" % params.prefix)
                    r2 = os.path.join(config["results"]["trimming"], "%s.raw.2.fq.gz" % params.prefix)
                    shell("cat %s > %s" % (r1_str, r1))
                    shell("cat %s > %s" % (r2_str, r2))
                    if config["params"]["trimming"]["fastp"]["use_slide_window"]:
                        shell("fastp --in1 %s --in2 %s --out1 {output.reads[0]} --out2 {output.reads[1]} \
                               --compression {params.compression} {params.adapter_trimming} \
                               --cut_front_window_size {params.cut_front_window_size} \
                               --cut_front_mean_quality {params.cut_front_mean_quality} \
                               --cut_right_window_size {params.cut_tail_window_size} \
                               --cut_right_mean_quality {params.cut_tail_mean_quality} \
                               --n_base_limit {params.n_base_limit} --length_required {params.length_required} \
                               --thread {threads} --html {output.html} --json {output.json} 2> {log}" % (r1, r2))
                    else:
                        shell("fastp --in1 %s --in2 %s --out1 {output.reads[0]} --out2 {output.reads[1]} \
                               --compression {params.compression} {params.adapter_trimming} \
                               --cut_front_window_size {params.cut_front_window_size} \
                               --cut_front_mean_quality {params.cut_front_mean_quality} \
                               --cut_tail_window_size {params.cut_tail_window_size} \
                               --cut_tail_mean_quality {params.cut_tail_mean_quality} \
                               --n_base_limit {params.n_base_limit} --length_required {params.length_required} \
                               --thread {threads} --html {output.html} --json {output.json} 2> {log}" % (r1, r2))
                    shell("rm -rf %s" % r1)
                    shell("rm -rf %s" % r2)
            else:
                if reads_num == 1:
                    if config["params"]["trimming"]["fastp"]["use_slide_window"]:
                        shell("fastp --in1 {input[0]} --out1 {output.reads[0]} \
                               --compression {params.compression} {params.adapter_trimming} \
                               --cut_front_window_size {params.cut_front_window_size} \
                               --cut_front_mean_quality {params.cut_front_mean_quality} \
                               --cut_right_window_size {params.cut_tail_window_size} \
                               --cut_right_mean_quality {params.cut_tail_mean_quality} \
                               --n_base_limit {params.n_base_limit} --length_required {params.length_required} \
                               --thread {threads} --html {output.html} --json {output.json} 2> {log}")
                    else:
                        shell("fastp --in1 {input[0]} --out1 {output.reads[0]} \
                               --compression {params.compression} {params.adapter_trimming} \
                               --cut_front_window_size {params.cut_front_window_size} \
                               --cut_front_mean_quality {params.cut_front_mean_quality} \
                               --cut_tail_window_size {params.cut_tail_window_size} \
                               --cut_tail_mean_quality {params.cut_tail_mean_quality} \
                               --n_base_limit {params.n_base_limit} --length_required {params.length_required} \
                               --thread {threads} --html {output.html} --json {output.json} 2> {log}")
                else:
                    r_str = " ".join(input)
                    r = os.path.join(config["results"]["trimming"], "%s.raw.fq.gz" % params.prefix)
                    shell("cat %s > %s" % (r_str, r))
                    if config["params"]["trimming"]["fastp"]["use_slide_window"]:
                        shell("fastp --in1 %s --out1 {output.reads[0]} \
                               --compression {params.compression} {params.adapter_trimming} \
                               --cut_front_window_size {params.cut_front_window_size} \
                               --cut_front_mean_quality {params.cut_front_mean_quality} \
                               --cut_right_window_size {params.cut_tail_window_size} \
                               --cut_right_mean_quality {params.cut_tail_mean_quality} \
                               --n_base_limit {params.n_base_limit} --length_required {params.length_required} \
                               --thread {threads} --html {output.html} --json {output.json} 2> {log}" % r)
                    else:
                        shell("fastp --in1 %s --out1 {output.reads[0]} \
                               --compression {params.compression} {params.adapter_trimming} \
                               --cut_front_window_size {params.cut_front_window_size} \
                               --cut_front_mean_quality {params.cut_front_mean_quality} \
                               --cut_tail_window_size {params.cut_tail_window_size} \
                               --cut_tail_mean_quality {params.cut_tail_mean_quality} \
                               --n_base_limit {params.n_base_limit} --length_required {params.length_required} \
                               --thread {threads} --html {output.html} --json {output.json} 2> {log}" % r1)
                    shell("rm -rf %s" % r)

rule multiqc_fastp:
        input:
            expand("{trimming}/{sample}.fastp.json",
                   trimming=config["results"]["trimming"],
                   sample=_samples.index.unique())
        output:
            html = os.path.join(config["results"]["trimming"], "fastp_multiqc_report.html"),
            data_dir = directory(os.path.join(config["results"]["trimming"], "fastp_multiqc_report_data"))
        log:
            os.path.join(config["logs"]["trimming"], "multiqc_fastp.log")
        params:
            outdir = config["results"]["trimming"]
        shell:
            '''
            multiqc --outdir {params.outdir} --title fastp --module fastp {input} 2> {log}
            '''


rule trimming_report:
    input:
        reads = expand(os.path.join(config["results"]["trimming"], "{{sample}}.trimmed{read}.fq.gz"),
                       read=[".1", ".2"] if IS_PE else "")
    output:
        os.path.join(config["results"]["report"]["trimming"], "{sample}.trimming.stats.tsv")
    params:
        fq_encoding = config["params"]["report"]["seqkit"]["fq_encoding"],
        sample_id = "{sample}"
    threads:
        config["params"]["report"]["seqkit"]["threads"]
    run:
        from metapi import reporter
        if IS_PE:
            shell("seqkit stats --all --basename --tabular \
                  --fq-encoding %s \
                  --out-file %s \
                  --threads %d %s" % (params.fq_encoding, output, threads, " ".join(input)))
            reporter.change(output[0], params.sample_id, "trimming", "pe", ["fq1", "fq2"])
        else:
            shell("seqkit stats --all --basename --tabular \
                  --fq-encoding %s \
                  --out-file %s \
                  --threads %d %s" % (params.fq_encoding, output, threads, input))
            reporter.change(output[0], params.sample_id, "trimming", "se", ["fq1"])


rule merge_trimming_report:
    input:
        expand("{reportout}/{sample}.trimming.stats.tsv",
               reportout=config["results"]["report"]["trimming"],
               sample=_samples.index.unique())
    output:
        os.path.join(config["results"]["report"]["base_dir"], "trimming.stats.tsv")
    run:
        from metapi import reporter
        reporter.merge(input, 8, save=True, output=output[0])
