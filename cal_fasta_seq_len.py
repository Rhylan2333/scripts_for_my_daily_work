from Bio import SeqIO
import csv
import argparse

# 添加命令行解析参数，这会创建输入fasta文件和输出csv文件的命令行参数 "-i" 和 "-o"。
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", required=True, help="Input FASTA file")
parser.add_argument("-o", "--output", required=True, help="Output CSV file")
args = parser.parse_args()
# 使用解析出的参数作为代码变量
fasta_file = args.input
csv_file = args.output

with open(csv_file, "w") as f:
    writer = csv.writer(f)
    writer.writerow(["ID", "Length"])
    for seq_record in SeqIO.parse(fasta_file, "fasta"):
        writer.writerow([seq_record.id, len(seq_record.seq)])

lengths = []
for seq_record in SeqIO.parse(fasta_file, "fasta"):
    lengths.append(len(seq_record.seq))


print('input:', fasta_file)
print('output:', csv_file)
print('count:', len(lengths))  # 输出所有序列个数
print('max_len:', max(lengths), 'min_len:', min(lengths))  # 输出最长和最短序列长度
