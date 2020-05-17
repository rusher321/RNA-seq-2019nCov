#!/usr/bin/env snakemake
import sys
from metapi import sample
from metapi import summary
#from metapi import merger
#from metapi import uploader

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

rule all:
	input:
		all_target

