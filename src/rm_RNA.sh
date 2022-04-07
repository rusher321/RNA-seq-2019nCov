#!/bin/bash
############ rm RNA #######################
# author huahui ren
###########################################


echo ==========start at : `date` ==========
usage() {
            echo "use for rm the RNA"
            echo "sh $0 -a fq1 -b fq2 -d database -m human -p process  -f pair -o output"
            echo "-a str, fq.1, required"
            echo "-b str, fq.2 gene list, required"
            echo "-s str, sample id, required"
            echo "-d str, rna databse, required"
            echo "-m str, human database, required"
            echo "-p int,  process number, default"
            echo "-o str, output path & prefix, required"
            echo "-r1 str, report1"
            echo "-r2 str, report2"
            exit 1
            }

if [ $# == 0 ]; then
    usage
    fi

while getopts a:b:s:d:m1:m2:p:o:r:x:h opt
do
    case $opt in
        a) a=$OPTARG ;;
        b) b=$OPTARG ;;
        s) s=$OPTARG ;;
        d) d=$OPTARG ;;
        m1) m1=$OPTARG ;;
        m2) m2=$OPTARG ;; 
        p) p=$OPTARG ;;
        o) o=$OPTARG ;;
        r) r=$OPTARG ;;
        x) x=$OPTARG ;;
        h) usage ;;
        \?) usage ;;
    esac
done

d="/hwfssz1/ST_META/share/database/rRNA/Human_rRNA"
m1="/hwfssz5/ST_MCHRI/REPRO/PROJECT/P18Z10200N0183/xingyanru/Database/USCS/hg19/genome/HisatIndex/hg19"
m2="/hwfssz5/ST_MCHRI/REPRO/PROJECT/P18Z10200N0183/xingyanru/Database/USCS/hg38/HisatIndex/hg38"


# soap align the Rna database
bwa mem -t $p -k 19  $d  $a  $b >$o/$s".sam" && \
samtools flagstat -@8 $o/$s".sam" > $r && \
samtools view -bS $o/$s".sam" | samtools fastq -@8 -N -f 12 -F 256 -1 $o/$s"_rRNAremoved_1.fq.gz" -2 $o/$s"_rRNAremoved_2.fq.gz" -  &&\
#rm $o/$s".sam" &&\

# align the human genome h19

/hwfssz5/ST_MCHRI/REPRO/PROJECT/P18Z10200N0183/xingyanru/Software/bin/hisat2-2.1.0/hisat2 -p $p --sensitive --no-discordant --no-mixed -I 1 -X 1000 --dta -x $m1 -1 $o/$s"_rRNAremoved_1.fq.gz" -2 $o/$s"_rRNAremoved_2.fq.gz" -S $o/$s".sam" 2> $x  && \
samtools view -@4 -SF4 $o/$s".sam" | awk -F'[/\\t]' '{{print $1}}' | sort | uniq  >$o/$s".rmhost.19.list" && \

# align the human genome h38
/hwfssz5/ST_MCHRI/REPRO/PROJECT/P18Z10200N0183/xingyanru/Software/bin/hisat2-2.1.0/hisat2 -p $p --sensitive --no-discordant --no-mixed -I 1 -X 1000 --dta -x $m2 -1 $o/$s"_rRNAremoved_1.fq.gz" -2 $o/$s"_rRNAremoved_2.fq.gz" -S $o/$s".sam" 2> $x  && \
samtools view -@4 -SF4 $o/$s".sam" | awk -F'[/\\t]' '{{print $1}}' | sort | uniq  >$o/$s".rmhost.38.list" && \
#rm $o/$s".sam" && \

cat $o/$s".rmhost.19.list" $o/$s".rmhost.38.list" |sort |uniq > $o/$s".rmhost.list"

cat $o/$s".rmhost.list" | awk '{{print $0 "/1"}}' - | seqtk subseq -r $o/$s"_rRNAremoved_1.fq.gz" - | pigz -p $p -c > $o/$s".rmrRna.1.fq.gz" && \

cat $o/$s".rmhost.list" | awk '{{print $0 "/2"}}' - | seqtk subseq -r $o/$s"_rRNAremoved_2.fq.gz" - | pigz -p $p -c > $o/$s".rmrRna.2.fq.gz" && \

#rm $o/*rRNAremoved*gz
#rm $o/$s".rmhost."*"list"

echo ==========end at : `date` ==========
