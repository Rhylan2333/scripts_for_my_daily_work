# scripts_for_my_daily_work
---
## cal_fasta_seq_len.py

统计一个FASTA文件中所有序列的长度然后以CSV格式输出，一般选最长的作为参考序列。示例：

```zsh
python3 ./cal_fasta_seq_len.py -i ./XXX_protein.faa -o ./XXX_pro_seq_len.csv
# 进行多序列比对
clustalo -i ./XXX_protein.faa -o ./XXX_pro_MSA_result.clustal --outfmt=clustal -v --force
```
将 .csv 与 .clustal 两个文件结合判断，可以选出合适的序列用于进一步研究。
