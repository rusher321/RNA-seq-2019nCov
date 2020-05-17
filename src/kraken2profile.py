#!/usr/bin/env python

import sys 
import os
import argparse
from collections import defaultdict

'''
writing a script to take kraken2 summary files and make one file in the format 
taxaID	taxa	sample1	sample2	sample3	sample4 ....
'''

#concatenating the kraken reports from multiple file using a dictionary
def kraken_cat_report(filelist, rank, col, out):
	h=defaultdict(dict)
	for file in filelist:
		openfi=open(filelist[file], 'r')
		for line in openfi:
			fields=line.split('\t')
			if (fields[3] == rank):
				taxa=fields[5].strip()
				taxa=f"{fields[4]}\t{taxa}"
				h[taxa][file] = fields[col-1]

	print (f"Writing {rank} profile")
	out_name = f"{out}.profile.{rank}.txt"
	with open (out_name, 'w') as fout:
		samples = sorted(list(filelist.keys()))
		tmp = "\t".join(samples)
		fout.write(f"TaxaID\tTaxa\t{tmp}\n")
		for key1 in h:
			fout.write(f"{key1}")
			for key2 in samples:
				if key2 not in h[key1]:
					fout.write(f"\t0")
				else:
					fout.write(f"\t{h[key1][key2]}")
			fout.write("\n")

def Processing(dir, rank, col, out):
    filelist=input_dir(dir)
    if rank == "A":
        all_rank = ['U','R','D','K','P','C','O','F','G','S']
        for x in all_rank:
            kraken_cat_report(filelist,x,col,out)
    else:
        kraken_cat_report(filelist,rank,col,out)

#function that open the directory and confirms there are files, and checks to see that the files are summary files 
def input_dir(dir):
	files=os.listdir(dir)
	assert (len(files)!=0), "The directory is empty"
	path={}
	for f in files:
		fipath=os.path.join(dir,f)
		f_name = f.split(".")[0]
		path[f_name] = fipath
		report=open(fipath, 'r')
		for line in report:
			fields=line.split('\t')
			cols=len(fields)
			assert (cols==6), "The %s file is not kraken2 summary report" %report
			break
	print ("Checking input file done")	
	return (path)


if __name__=='__main__' :
	parser=argparse.ArgumentParser(description="Take multiple kraken output files and consolidate them to one output")
	parser.add_argument ('-d', dest='directory', help='Enter a directory with kraken summary reports')
	parser.add_argument ('-r', dest='rank', choices=['A','U','R','D','K','P','C','O','F','G','S'],default="A", help='Enter a rank code')
	parser.add_argument ('-c', dest='column', type=int, choices=range(1,7),default=2, help="Enter the column number in the report you would like to include in the output")
	parser.add_argument ('-o', dest='output', help='Enter the output file name')
	results=parser.parse_args()
	#input_dir(results.directory)
	Processing(results.directory, results.rank, results.column, results.output)