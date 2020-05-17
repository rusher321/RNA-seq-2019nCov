#!/usr/bin/env python
import argparse
import os
import sys
import pandas as pd
from metapi import config



workflow_steps = [
    "trimming_fastp",
    "multiqc_fastp",
    "kraken2_bracken",
    "all"
]


def initialization(args):
    if args.workdir:
        project = config.metaconfig(args.workdir)
        print(project.__str__())
        project.create_dirs()
        configuration, cluster = project.get_config()

        if args.samples:
            configuration["params"]["samples"] = args.samples
        else:
            print("please supply a samples list!")
        if args.queue:
            cluster["__default__"]["queue"] = args.queue
        if args.project:
            cluster["__default__"]["project"] = args.project

        config.update_config(
            project.config_file, project.new_config_file, configuration, remove=False)
        config.update_config(
            project.cluster_file,
            project.new_cluster_file,
            cluster,
            remove=False)
    else:
        print("please supply a workdir!")
        sys.exit(1)




def workflow(args):
    if args.workdir:
        config_file = os.path.join(args.workdir, "config.yaml")
        configuration = config.parse_yaml(config_file)
        if not os.path.exists(configuration["params"]["samples"]):
            print("please specific samples list on initialization step")
            sys.exit(1)
    else:
        print("please supply a workdir!")
        sys.exit(1)

    snakecmd = "snakemake --snakefile %s --configfile %s --until %s" % (
        configuration["snakefile"], configuration["configfile"], args.step)
    print(snakecmd)


def main():
    parser = argparse.ArgumentParser(
        prog='metapi',
        usage='metapi [subcommand] [options]',
        description='metapi, a pipeline to construct a genome catalogue from metagenomics data')
    parser.add_argument(
        '-v',
        '--version',
        action='store_true',
        default=False,
        help='print software version and exit')

    parent_parser = argparse.ArgumentParser(add_help=False)
    parent_parser.add_argument(
        '-d', '--workdir', type=str, metavar='<str>', help='project workdir')

    subparsers = parser.add_subparsers(
        title='available subcommands', metavar='')
    parser_init = subparsers.add_parser(
        'init',
        parents=[parent_parser],
        prog='metapi init',
        description='a metagenomics project initialization',
        help='a metagenomics project initialization')

    parser_init.add_argument(
        '-q', '--queue', default='st.q', help='cluster queue')
    parser_init.add_argument(
        '-p', '--project', default='st.m', help='project id')
    parser_init.add_argument('-s', '--samples', help='raw fastq samples list')
    parser_init.add_argument(
        '-b',
        '--begin',
        type=str,
        default='raw',
        choices=['raw', 'assembly'],
        help='begin to run pipeline from a specific step')
    parser_init._optionals.title = 'arguments'
    parser_init.set_defaults(func=initialization)


    parser_workflow.add_argument(
        '-r',
        '--rmhost',
        action='store_true',
        default=False,
        help='need to remove host sequence? default: False')
    parser_workflow._optionals.title = 'arguments'
    parser_workflow.set_defaults(func=workflow)

    args = parser.parse_args()
    try:
        if args.version:
            print("metapi version %s" % __version__)
            sys.exit(0)
        args.func(args)
    except AttributeError as e:
        print(e)
        parser.print_help()


if __name__ == '__main__':
    main()
