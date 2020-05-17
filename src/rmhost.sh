# select the non-human id 

cat $1 | \
grep "(taxid 9606)"|cut -f 2 > $4"/"$5".human.list" && \

cat $4"/"$5".human.list" |awk '{{print $0 "/1"}}' |seqtk subseq -r $2  - |pigz -p 8 -c > $4"/"$5".rmhost.1.fq.gz" && \
cat $4"/"$5".human.list" |awk '{{print $0 "/2"}}' |seqtk subseq -r $3  - |pigz -p 8 -c > $4"/"$5".rmhost.2.fq.gz" && \

rm $4"/"$5".human.list" 
#rm $1 



