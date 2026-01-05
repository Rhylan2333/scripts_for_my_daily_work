# SraRunTable.[your PRJNAXXXX ID].csv: Download Total-Metadata from https://trace.ncbi.nlm.nih.gov/Traces/study/?acc=[your PRJNAXXXX ID]&o=acc_s%3Aa. Get SraRunTable.csv, then rename.
# filereport_read_run_[your PRJNAXXXX ID].tsv: Choose "run_accession", "fastq_bytes", "fastq_md5", "fastq_aspera" cols, download TSV report from https://www.ebi.ac.uk/ena/browser/view/[your PRJNAXXXX ID]

awk 'BEGIN{FS=OFS="\t"} {
  split($2, arr2, ";")
  split($3, arr3, ";")
  split($4, arr4, ";")
  for (i=1; i<=length(arr2); i++) {
    print $1, arr2[i], arr3[i], arr4[i]
  }
}' < filereport_read_run_[your PRJNAXXXX ID].tsv > filereport_read_run_[your PRJNAXXXX ID].not_merged.tsv

mkdir [your PRJNAXXXX ID]-ascp/
sd 'fasp.+/' '' < filereport_read_run_[your PRJNAXXXX ID].not_merged.tsv | csvtk -t cut -f 'fastq_md5,fastq_aspera' -U -D ' ' | sort -k 2  > [your PRJNAXXXX ID]-ascp/fastq_md5.should_be.md5

csvtk -t cut -f 'fastq_aspera' filereport_read_run_[your PRJNAXXXX ID].not_merged.tsv -U | sd '^fasp' 'ascp -v -QT -P 33001 -k 1 -l 200m -i /home/caicai/.local/share/mamba/envs/aspera-cli/etc/asperaweb_id_dsa.openssh "era-fasp@fasp' | sd '.gz$' '.gz" ./[your PRJNAXXXX ID]-ascp/' > filereport_read_run_[your PRJNAXXXX ID].not_merged.ascp.sh
chmod +x filereport_read_run_[your PRJNAXXXX ID].not_merged.ascp.sh

./filereport_read_run_[your PRJNAXXXX ID].not_merged.ascp.sh
