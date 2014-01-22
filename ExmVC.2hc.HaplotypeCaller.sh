#!/bin/bash
#$ -cwd 

while getopts i:d:s:l:j: opt; do
  case "$opt" in
      i) BamLst="$OPTARG";;
      d) BamDir="$OPTARG";;
      s) Settings="$OPTARG";;
      l) LogFil="$OPTARG";;
	  j) NumJobs="$OPTARG";;
  esac
done

#load settings file
. $Settings

#Set local Variables
JobNum=$SGE_TASK_ID
JobNm=${JOB_NAME#*.}
TmpLog=$LogFil.CallVC.$JobNum.log
# The target file needs to be divided evenly between all the jobs. i.e. if the target file is 1000 lines long and there are 40 jobs, each job should have 25 lines of the target file
# bash arithmetic division actually gives the quotient, so if there are 1010 lines and 40 jobs the division would still give 25 lines per a job and the last 10 lines would be lost
# to compensate for this we will find the remainder (RemTar) and then add an extra line to the first $RemTar jobs
TarLen=$(cat $TARGET | wc -l) 
RemTar=$(( TarLen % NumJobs )) # get remainder of target file length and number of jobs
QuoTar=$(( TarLen / NumJobs )) # get quotient of target file length and number of jobs
FinLn=0
for ((i=1; i <= $JobNum; i++)); do
	SttLn=$(( FinLn + 1 ))
	if [[ $i -le $RemTar ]]; then
		DivLen=$(( QuoTar + 1 ))
		else
		DivLen=$QuoTar
	fi
	FinLn=$(( FinLn + DivLen ))
done
Range=$TmpDir/Range$JobNum.bed #exome capture range
tail -n+$SttLn $TARGET | head -n $DivLen > $Range #get exome capture range
BamLstDir=$TmpDir/$JobNm.$JobNum.bam.list #add path to file list
awk -v x=$BamDir '{print x"/"$1}' $BamLst >> $BamLstDir
#Output File
VcfDir=$JobNm"_VCF_final"
VcfFil=$VcfDir$JobNm.$JobNum.raw_variants.vcf
mkdir -p $VcfDir
#Annotation fields to output into vcf files
infofields="-A AlleleBalance -A BaseQualityRankSumTest -A Coverage -A HaplotypeScore -A HomopolymerRun -A MappingQualityRankSumTest -A MappingQualityZero -A QualByDepth -A RMSMappingQuality -A SpanningDeletions "

uname -a >> $TmpLog
echo "Start Variant Calling on Chromosome $CHR with GATK HaplotypeCaller - $0:`date`" >> $TmpLog
echo "" >> $TmpLog
echo "Job name: "$JOB_NAME >> $TmpLog
echo "Job ID: "$JOB_ID >> $TmpLog
echo "Output Directory: "$VcfDir >> $TmpLog
echo "Output File: "$VcfFil >> $TmpLog
echo "Target file line range: $SttLn - $FinLn" >> $TmpLog


TmpDir=$JobNm.$JobNum.VC 
mkdir -p $TmpDir


##Run Joint Variant Calling
echo "Variant Calling with GATK HaplotypeCaller..." >> $TmpLog
cmd="$JAVA7BIN -Xmx7G -Djava.io.tmpdir=$TmpDir -jar $GATKJAR  -T HaplotypeCaller -R $REF -L $Range -nct $NumCores -I $BamLstDir --genotyping_mode DISCOVERY -stand_emit_conf 10 -stand_call_conf 30 -o $VcfDir/$VcfFil $DBSNP135 --comp:HapMapV3 $HpMpV3 $infofields -rf BadCigar"
echo $cmd >> $TmpLog
$cmd
echo "" >> $TmpLog
echo "Variant Calling done." >> $TmpLog
echo "" >> $TmpLog

#Need to wait for all HaplotypeCaller jobs to finish and then remerge all the vcfs
#calculate an amount of time to wait based on the chromosome and the current time past the hour
#ensures that even if all the jobs finish at the same time they will each execute the next bit of code at 5 second intervals rather than all at once
Sekunds=`date +%-S`
Minnits=`date +%-M`
Minnits=$((Minnits*60))
Sekunds=$((Sekunds+Minnits))
Sekunds=$((Sekunds/5))
NoTime=$((Sekunds%NumJobs))
WaitTime=$((JobNum-NoTime))
if [[ $WaitTime -lt 0 ]]; then
WaitTime=$((NumJobs+WaitTime))
fi
WaitTime=$((WaitTime*5))
echo "" >> $TmpLog
echo "Test for completion Time:" `date +%M:%S` >> $TmpLog
echo "Sleeping for "$WaitTime" seconds..." >> $TmpLog
sleep $WaitTime

VCsrunning=$(qstat | grep $JOB_ID | wc -l)
qstat | grep $JOB_ID >> $TmpLog
if [ $VCsrunning -eq 1 ]; then
	echo "All completed:`date`" >> $TmpLog
	echo "----------------------------------------------------------------" >> $TmpLog
	echo "" >> $TmpLog
	echo "Call Merge with vcftools ...:" >> $TmpLog
	echo ""
	cmd="qsub -l $RmgVCFAlloc -N RmgVCF.$JobNm -o stdostde/ -e stdostde/ $EXOMSCR/ExmVC.3.MergeVCF.sh -d $VcfDir -s $Settings -l $LogFil"
	echo $cmd  >> $TmpLog
	$cmd
	echo "" >> $TmpLog
else
	echo "HaplotypeCallers still running: "$VCsrunning" "`date` >> $TmpLog
	echo "Exiting..."
fi

echo "End Variant Calling with GATK HaplotypeCaller on Chromosome $Chr $0:`date`" >> $TmpLog
echo ""
qstat -j $JOB_ID | grep -E "usage *$SGE_TASK_ID:" >> $TmpLog
echo "" >> $TmpLog
echo "===========================================================================================" >> $TmpLog
echo "" >> $TmpLog
cat $TmpLog >> $LogFil
rm -r $TmpLog $TmpDir