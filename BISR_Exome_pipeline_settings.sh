## Resource Directories
export EXOMSCR="/ifs/home/c2b2/af_lab/ads2202/scratch/Exome_Seq/scripts/BISR_pipeline_scripts" # Directory containing pipeline shell scripts
export EXOMRES="/ifs/home/c2b2/af_lab/ads2202/scratch/Exome_Seq/resources" # Directory containing resources/references for pipeline
export MYBIN="/ifs/home/c2b2/af_lab/ads2202/scratch/bin" # Directory containing software binaries
export MYSRC="/ifs/home/c2b2/af_lab/ads2202/scratch/src" # Directory containing software sources
## Software/Tools
export GATKJAR="$MYSRC/GenomeAnalysisTK_Current/GenomeAnalysisTK.jar" # GATK jar file
export JAVA7BIN="$MYBIN/jre1.7.0_40/bin/java" # java 7 binary
export BWA="$MYSRC/bwa-0.7.5a/bwa" # bwa
export SAMTOOLS="$MYSRC/samtools-0.1.19/samtools" # samtools 
export PICARD="$MYSRC/picard-tools-1.101" # picard
export VCFTOOLS="$MYSRC/vcftools_0.1.11/bin/" #vcftools
export TABIX="$MYBIN/tabix"
## References
export DBSNP="$EXOMRES/b37/dbsnp_137.b37.vcf" # dbSNP vcf from GATK
export INDEL="$EXOMRES/b37/Mills_and_1000G_gold_standard.indels.b37.vcf" # Gold standard INDEL reference from GATK
export REF="$EXOMRES/b37/human_g1k_v37.fasta" # human 1000 genome assembly from GATK
export HpMpV3="$EXOMRES/b37/hapmap_3.3.b37.vcf" # hapmap vcf from GATK
export TGVCF="$EXOMRES/b37/1000G_omni2.5.b37.vcf" 
export OneKG="$EXOMRES/b37/1000G_phase1.snps.high_confidence.b37.vcf" # 1000 genome SNPs vcf
export TARGET="$EXOMRES/SureSelect_Human_All_Exon_V5_UTRs_Covered.orderandbuffered.bed" # Exome capture targets
## Hard resource limits for ExomeAnalysis pipeline jobs
#Number of cores dependent on Cluster
#case $(/bin/hostname) in
#	*.titan) NumCores=8;;
#	*.hpc) NumCores=12;
#esac
export NumCores=6
#Alignment scripts
export mapExmAlloc="mem=4G,time=4::" # ExmAln.2.Align_BWA.sh - 2 or 4 cores 
export ConvS2BAlloc="mem=8G,time=6::" # ExmAln.3.ConvSamtoBam.sh
export GCstatAlloc="mem=8G,time=:45:" # ExmAln.4.GC_metrics.sh
export realnAlloc="mem=2G,time=2::" # ExmAln.5.LocalRealignment.sh - 8 or 12 cores (depending on cluster) 
#export RemergeAlloc="mem=1G,time=10::" # ExmAln.6.MergeBam.sh
#export BQSRAlloc="mem=2G,time=24::" # ExmAln.7.RecalibrateBaseQuality.sh - 8 or 12 cores (depending on cluster) 
export GenBQSRAlloc="mem=2G,time=8::" # ExmAln.7.RecalibrateBaseQuality.sh - 8 or 12 cores (depending on cluster) 
export AppBQSRAlloc="mem=2G,time=1::" # ExmAln.7.RecalibrateBaseQuality.sh - 8 or 12 cores (depending on cluster) 
export AnaCovAlloc="mem=2G,time=12::" # ExmAln.7a.ExmAln.7a.AnalyseCovariation.sh- 8 or 12 cores (depending on cluster)
export RRAlloc="mem=10G,time=2::" # ExmAln.8.ReduceReads.sh
export DepofCovAlloc="mem=2G,time=6::" # ExmAln.9.DepthofCoverage.sh - 8 or 12 cores (depending on cluster) 
#Variant Calling
export vcHapCExmAlloc="mem=2G,time=12::" # ExmVC.2.HaplotypeCaller.sh - 8 or 12 cores (depending on cluster) 
export vcUniGExmAlloc="mem=2G,time=12::" # ExmVC.2.HaplotypeCaller.sh - 8 or 12 cores (depending on cluster) 
export RmgVCFAlloc="mem=8G,time=6::" # ExmVC.3.MergeVCF.sh
export VQSRAlloc="mem=2G,time=24::" # ExmVC.4.RecalibrateVariantQuality.sh - 8 or 12 cores (depending on cluster) 

#hpc workarounds
if [[ /bin/hostname==*.hpc ]]; then 
source /etc/profile.d/sge.sh  # SGE commands from within node
source /ifs/home/c2b2/af_lab/ads2202/.bash_profile
fi
#export PERL5LIB="/ifs/home/c2b2/af_lab/ads2202/scratch/src/vcftools_0.1.11/perl/" # vcftool perl 
#PATH=/nfs/apps/R/3.0.1/bin/:$PATH; export PATH ;  # Rscript for GATK