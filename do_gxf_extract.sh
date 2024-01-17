for i in $(<haogs2-28-08-2016-fixed.gene-p450.idlist); do
echo $i;
./extract_one_gene_from_a_gff_file.sh -q "$i" -s pearce_stephen_16_jan_2024/data/haogs2-17089_fixed_7-04-15_note-added.gff3 >> haogs2-17089_fixed_7-04-15_note-added.all-p450.gff3
done
