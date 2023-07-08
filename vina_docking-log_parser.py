import argparse
import re
import csv


def main(input_file, output_file):
    """
    从 Vina 的输出文件中提取分子对接结果，并将结果保存为 CSV 文件。

    :param input_file: 输入文件的名称。
    :param output_file: 输出文件的名称。
    """
    # 读取文件内容
    with open(input_file, 'r') as f:
        content = f.read()

    # 使用正则表达式匹配表格内容
    pattern = r'^\s*\d+\s+(-?\d+\.\d+)\s+(-?\d+(?:\.\d+)?)\s+(-?\d+(?:\.\d+)?)\s*$'
    matches = re.findall(pattern, content, re.MULTILINE)

    # 将匹配结果转化为 CSV 格式并写入文件
    with open(output_file, 'w', newline='') as f:
        writer = csv.writer(f)
        # 写入表头
        writer.writerow(['mode', 'affinity (kcal/mol)', 'dist from best mode (rmsd l.b.)', 'dist from best mode (rmsd u.b.)'])
        # 写入每一行数据
        for i, match in enumerate(matches):
            mode = i + 1
            affinity, rmsd_lb, rmsd_ub = match
            writer.writerow([mode, affinity, rmsd_lb, rmsd_ub])


if __name__ == '__main__':
    # 创建解析器对象
    parser = argparse.ArgumentParser(description="Process AutoDock Vina\'s docking logs. Pass in the docking result (output log), and the output file is in CSV format. This CSV file contains information about the affinity, RMSD of the docking mode.")
    # 添加参数
    parser.add_argument('-i', '--input', type=str, required=True, help='input file name')
    parser.add_argument('-o', '--output', type=str, required=True, help='output file name')
    # 解析命令行参数
    args = parser.parse_args()
    # 调用主函数
    main(args.input, args.output)
    # 打印输入文件和输出文件的路径
    print("Done! Check the output file~")
    print(f"Input file: {args.input}")
    print(f"Output file: {args.output}")