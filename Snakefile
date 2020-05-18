#!/usr/bin/env snakemake
import sys
import sample

shell.executable("bash")

configfile: "config.yaml"

IS_PE = True if config["params"]["reads_layout"] == "pe" else False

_samples = sample.parse_samples(config["params"]["samples"],
                                config["params"]["reads_format"],
                                IS_PE, True)


include: "rules/step.smk"
include: "rules/trimming.smk"
include: "rules/rmRna.smk"
include: "rules/kraken2_bracken.smk"
include: "rules/rmHost.smk"
include: "rules/sortmerna.smk"
include: "rules/kraken2x.smk"
include: "rules/metaphlan2.smk"

rule all:
	input:
		all_target

