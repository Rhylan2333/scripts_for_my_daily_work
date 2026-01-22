#!/bin/bash

# Genome Resequencing and Variant Calling Pipeline Using BWA-MEME and GATK
#
# This pipeline processes resequencing data through multiple stages:
# 1. Sequence alignment using bwa-meme
# 2. Genome analysis using GATK (sorting, duplicate removal, read group addition)
# 3. Variant calling using bcftools
# 4. Annotation using ANNOVAR
#
# Author: 蔡雨豪
# Date: 2026-01-22

./ena_fastq_ascp_download.sh

script -c 'for fq in [your PRJNA...]-ascp/*.fastq.gz; do id=$(basename $fq | cut -d _ -f 1); mkdir -pv "[your PRJNA...]-ascp/$id"; mv -v $fq "[your PRJNA...]-ascp/$id/"; done' log.mv_fastq.log
# script -c 'for fq in $(fd '.fastq.gz$' [your PRJNA...]-ascp/); do mv -v $fq [your PRJNA...]-ascp/; done' log.mv_fastq_there.log

# script -c '''
#   bwa index ../[your reference genome]_genomic.fa
#   bwa-meme index -a meme -t 12 ../[your reference genome]_genomic.fa
# ''' ./log.bwa_index.[your reference genome].log

# script -c '''
#   build_rmis_dna.sh ../[your reference genome]_genomic.fa
# ''' ./log.build_rmis_dna.[your reference genome].log

# `samtools view -m 150` for PE150
script -c '''
  mkdir -pv s1_output_bwa
  input_dir="[your PRJNA...]-ascp"
  for subdir in $input_dir/*; do
    if [ -d $subdir ]; then
      id=$(basename $subdir)
      output_file="s1_output_bwa/${id}.min-qlen-150.bam"
      if [ -f $output_file ]; then
        echo "$(date) $output_file exists, skip"
      else
        echo "$(date) Processing $id"
        fq1=$(fd -tf '_1.fastq.gz' "${input_dir}/${id}/")
        fq2=$(fd -tf '_2.fastq.gz' "${input_dir}/${id}/")
        bwa-meme mem -7 -M -Y -t 12 \
          ../[your reference genome]_genomic.fa \
          $fq1 $fq2 | \
        samtools view -@ 12 -T ../[your reference genome]_genomic.fa -m 150 -b -o $output_file
        echo "$(date) Saved to $output_file"
      fi
    fi
  done
''' ./log.bwa_mem.[your reference genome].log

script -c '''
  for bam in s1_output_bwa/*.bam; do
  echo "samtools flagstat $bam:"
  samtools flagstat -@ 12 $bam
  echo
  done
''' ./log.samtools_flagstat.[your reference genome].log

script -c '''
  mkdir -pv s2_output_gatk
  for input_file in s1_output_bwa/*.bam; do
    output_file="s2_output_gatk/$(basename -s .bam $input_file).gatk_SortSam-queryname.bam"
    echo "$(date) Processing $input_file"
    gatk SortSam \
      -I $input_file \
      -O $output_file \
      -SO queryname
    echo -e "$(date) Saved to $output_file\n"
  done
''' ./log.gatk_SortSam.[your reference genome].log

script -c '''
  for input_file in s2_output_gatk/*.gatk_SortSam-queryname.bam; do
    id=$(basename -s '.min-qlen-150.gatk_SortSam-queryname.bam' $input_file)
    output_file="s2_output_gatk/${id}.marked_duplicates.bam"
    echo "$(date) Processing $input_file"
    gatk MarkDuplicates \
      -I $input_file \
      -O $output_file \
      -M "s2_output_gatk/metrics.${id}.txt" \
      -REMOVE_DUPLICATES true
    echo -e "$(date) Saved to $output_file\n"
  done
''' ./log.gatk_MarkDuplicates.[your reference genome].log

script -c '''
  for input_file in s2_output_gatk/*.marked_duplicates.bam; do
    output_file="s2_output_gatk/$(basename -s .bam $input_file).samtools_sort.bam"
    echo "$(date) Processing $input_file"
    samtools sort -@ 12 -o $output_file $input_file
    echo -e "$(date) Saved to $output_file\n"
  done
''' ./log.samtools_sort.[your reference genome].log

script -c '''
  mkdir -pv s3_output_bcftools
  for input_file in s2_output_gatk/*.samtools_sort.bam; do
    output_file="s3_output_bcftools/$(basename -s .bam $input_file).bcftools.vcf.gz"
    echo "$(date) Processing $input_file"
    bcftools mpileup \
      --threads 12 -f ../[your reference genome]_genomic.fa $input_file | \
    bcftools call --threads 12 -mv -Oz9 -o $output_file
    echo -e "$(date) Saved to $output_file\n"
  done
''' ./log.bcftools_mpileup-bcftools_call.1.[your reference genome].log

script -c '''
  for input_file in s3_output_bcftools/*.bcftools.vcf.gz; do
    echo "$(date) Processing $input_file"
    gatk IndexFeatureFile -I $input_file
    echo -e "$(date) Done.\n"
  done
''' ./log.gatk_IndexFeatureFile.[your reference genome].log

# samtools faidx -@ 12 ../[your reference genome]_genomic.fa
# script -c '''
#   gatk CreateSequenceDictionary \
#     -R ../[your reference genome]_genomic.fa \
#     -O ../[your reference genome]_genomic.chr.dict
# ''' ./log.gatk_CreateSequenceDictionary.[your reference genome].log

script -c '''
  for input_file in s2_output_gatk/*.samtools_sort.bam; do
    id=$(basename -s '.samtools_sort.bam' $input_file)
    output_file="s2_output_gatk/$(basename -s .bam $input_file).rg_added.bam"
    echo "$(date) Processing $input_file"
    gatk AddOrReplaceReadGroups \
      -I "$input_file" \
      -O "$output_file" \
      -RGID [your PRJNA...] -RGLB lib_unsure -RGPL unsure -RGPU unit_unsure -RGSM "$id"
      # SO=coordinate
    echo -e "$(date) Saved to $output_file\n"
  done
''' ./log.gatk_AddOrReplaceReadGroups.[your reference genome].log

script -c '''
  for input_file in s2_output_gatk/*.rg_added.bam; do
    echo "$(date) Processing $input_file"
    samtools index -@ 12 $input_file
    echo -e "$(date) Done.\n"
  done
''' ./log.samtools_index.[your reference genome].log

script -c '''
  for input_file in s2_output_gatk/*.rg_added.bam; do
    id=$(basename -s '.marked_duplicates.samtools_sort.rg_added.bam' $input_file)
    vcf="s3_output_bcftools/$id.marked_duplicates.samtools_sort.bcftools.vcf.gz"
    output_file="s2_output_gatk/$(basename -s .bam $input_file).recal_data.table"
    echo "$(date) Processing $input_file"
    gatk BaseRecalibrator \
      -I $input_file \
      -R ../[your reference genome]_genomic.fa \
      --known-sites $vcf \
      -O $output_file
    echo -e "$(date) Saved to $output_file\n"
  done
''' ./log.gatk_BaseRecalibrator.[your reference genome].log

script -c '''
  for input_file in s2_output_gatk/*.rg_added.bam; do
    output_file="s2_output_gatk/$(basename -s .bam $input_file).ApplyBQSR.bam"
    echo "$(date) Processing $input_file"
    gatk ApplyBQSR \
      --bqsr-recal-file "s2_output_gatk/$(basename -s .bam $input_file).recal_data.table" \
      -I $input_file \
      -O $output_file
    echo -e "$(date) Saved to $output_file\n"
  done
''' ./log.gatk_ApplyBQSR.[your reference genome].log

script -c '''
  for input_file in s2_output_gatk/*.ApplyBQSR.bam; do
    output_file="s3_output_bcftools/$(basename -s .bam $input_file).bcftools.vcf.gz"
    echo "$(date) Processing $input_file"
    bcftools mpileup \
      --threads 12 -f ../[your reference genome]_genomic.fa -Oz9 $input_file | \
    bcftools call --threads 12 -mv -Oz9 -o $output_file
    echo -e "$(date) Saved to $output_file\n"
  done
''' ./log.bcftools_mpileup-bcftools_call.2.[your reference genome].log

script -c '''
  mkdir -pv s4_output_annovar
  for input_file in s3_output_bcftools/*.ApplyBQSR.bcftools.vcf.gz; do
    id=$(basename -s '.marked_duplicates.samtools_sort.rg_added.ApplyBQSR.bcftools.vcf.gz' $input_file)
    output_file="s4_output_annovar/$id"
    echo "$(date) Processing $input_file"
    convert2annovar.pl \
      --format vcf4 \
      --outfile $output_file \
      --allsample \
      $input_file
    echo -e "$(date) Saved to $output_file\n"
  done
''' ./log.convert2annovar.[your reference genome].log

for file in s4_output_annovar/*.avinput; do
  echo -en "$(basename -s '.avinput' $file)\t" && awk -F '\t' '{sum += $8} END {print sum}' $file
done > s4_output_annovar/sum_var.tsv

csvtk -Ht plot box -f 2 s4_output_annovar/sum_var.tsv --title 'Variation counts in total samples' -o s4_output_annovar/sum_var.box.png
