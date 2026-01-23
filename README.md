# scripts_for_my_daily_work

## [crabz](https://github.com/sstadick/crabz)

```shell
# Compress
tar -I 'crabz -l 9 -p 12' -cvf <archive>.tar.gz <input_dir>
tar -cf - <input_dir> | crabz -l 9 -p 12 > <archive>.tar.gz
# Decompress
crabz -d -p 12 <archive>.tar.gz | tar -xvf -
```

## [pigz](https://github.com/madler/pigz)

```shell
# Compress
tar -I 'pigz -9 -p 12' -cvf <archive>.tar.gz <input_dir>
tar -cvf - <input_dir> | pigz -9 -p 12 > <archive>.tar.gz
# Decompress
tar -I 'pigz -d -p 12' -xvf <archive>.tar.gz
pigz -d -p 12 <archive>.tar.gz && tar -xvf <archive>.tar && rm <archive>.tar
```

## [AnnoSINE_v2](https://github.com/liaoherui/AnnoSINE_v2)

```shell
mamba activate AnnoSINE
# If set arg "-a" to 0, then Hmmer will search SINE using the plant hmm file. (default: 0)
python $ANNOSINE_HOME/bin/AnnoSINE_v2.py -t 8 -a 1 -f 'y' 3 <input_filename> <output_dir>
script -c 'python $ANNOSINE_HOME/bin/AnnoSINE_v2.py -t 8 -a 1 -f y 3 <input_filename> <output_dir>' <output_dir>/<output_filename>.script.log

```

## extract_one_gene_from_a_gff_file.sh

从一个GFF3文件中提取指向某个基因的数行。实列：

```shell
for i in $(<{input.id_list}); do echo "$i"; ./extract_one_gene_from_a_gff_file.sh -q "$i" -s {input.ori_gff} >> {output}; done
# 另一个办法
while read line; do id=$(echo "$line" | sd '[prefix or suffix]' ''); echo "$id"; rg "$id" ./[input.gff] | rg '\tgene' > ./[input.gene.gff]; done < [input.id_list]
```

## cal_fasta_seq_len.py

统计一个FASTA文件中所有序列的长度然后以CSV格式输出，一般选最长的作为参考序列。示例：

```shell
python3 ./cal_fasta_seq_len.py -i ./XXX_protein.faa -o ./XXX_pro_seq_len.csv
grep '>' ./XXX_protein.faa
# 进行多序列比对
clustalo -i ./XXX_protein.faa -o ./XXX_pro_MSA_result.clustal --outfmt=clustal --full --iterations=5 -v --force
```

将 .csv 与 .clustal 两个文件结合判断，可以选出合适的序列用于进一步研究。

## vina_docking-log_parser.py

处理AutoDock Vina的对接日志。传入对接结果（输出的log），此脚本的输出文件为一个CSV文件，它件包含有关对接mode的亲和力、RMSD信息。

```
mode |   affinity | dist from best mode
     | (kcal/mol) | rmsd l.b.| rmsd u.b.
-----+------------+----------+----------
   1       -4.091          0          0
   2        -3.98      2.247       2.37
   3       -3.915       16.1       16.9
   ...
```

👇

| mode | affinity (kcal/mol) | dist from best mode (rmsd l.b.) | dist from best mode (rmsd u.b.) |
|------|---------------------|---------------------------------|---------------------------------|
| 1    | -4.091              | 0                               | 0                               |
| 2    | -3.98               | 2.247                           | 2.37                            |
| 3    | -3.915              | 16.1                            | 16.9                            |
| ...  | ...                 | ...                             | ...                             |

示例：

```shell
python3 ./vina_docking-log_parser.py -i ./XXX.vina.out.log -o ./XXX.vina.out.log.csv
```

然后查看CSV文件就可以知道亲和力、RMSD了☺️

## 我的 Docker 常用指令

```
docker container ls  # 查看需要push的container
docker commit -a "Yuhao Cai" e1079b1cf715 caicai0/my_debian:v1.2  # “e1079b1cf715”是container的ID。
docker push caicai0/my_debian:v1.2
# 接下来是启动pull下来的容器
docker run -it -d --name="nvidia-devel_ubuntu22.04" --hostname="caicai" --volume="C:\Users\cauca\Desktop\work":"/home/work" --workdir="/home/work" --privileged=true --gpus all nvidia/cuda:12.3.1-devel-ubuntu22.04
docker run -it -d --name='nvidia-devel_ubuntu22.04' --hostname='caicai' --volume='C:\Users\tx4cai\Desktop\work':'/home/work' --workdir='/home/work' --privileged=true --gpus all -e 'TZ=Asia/Shanghai' --publish-all 'caicai0/my_bio_env-nvidia-cuda-12.3.1-devel-ubuntu22.04:v1.5_for_2024-06-03'

# 没必要的如下：
docker run -it -d --name="nvidia-devel_ubuntu22.04" --hostname="caicai" --volume="C:\Users\cauca\Desktop\work":"/home/work" --workdir="/home/work" --privileged=true --gpus all -e NVIDIA_DRIVER_CAPABILITIES=compute,utility -e NVIDIA_VISIBLE_DEVICES=all nvidia/cuda:12.3.1-devel-ubuntu22.04
```

- 强烈建议使用 GPU，[NVIDIA Docker：让 GPU 服务器应用程序部署变得容易](https://developer.nvidia.com/zh-cn/blog/nvidia-docker-gpu-server-application-deployment-made-easy/)

## 使用 Docker-JupyterLab-R

```
docker run -it -d --name="my_bio_env_jupyter" --hostname="caicai" --user root --volume="/home/caicai/work":"/home/work" --workdir="/home/work" --privileged=true -e TZ=Asia/Shanghai --publish-all docker.io/jupyter/r-notebook:x86_64-r-4.3.1 /bin/bash -c "jupyter lab --allow-root"
```

然后在 Podman Desktop 查看启动的容器，在 `Containers > Container Details` 的右上角点击“↗”（Open Browser），再执行 `jupyter server list` 命令获取 token 以登录，如下图：

![这是图片](/images/podman_for_R.jpg "podman for R")
![这是图片](/images/JupyterLab_for_R.jpg "JupyterLab for R")

## MSA 软件常用命令

### [PROBCONS](http://probcons.stanford.edu/)

- 使用mamba安装。

### [MAFFT](https://gitlab.com/sysimm/mafft)

> [使用 MAFFT 进行多序列比对](http://www.chenlianfu.com/?p=2214)
> [](https://mafft.cbrc.jp/alignment/software/manual/manual.html#lbAI)
- 编译完成后需要先执行软链接命令，以使用 `mafft --man`：

```shell
$ mafft --man
man: /root/mafft-master/libexec/mafft/mafft.1: No such file or directory
No manual entry for /root/mafft-master/libexec/mafft/mafft.1
$ fd "mafft.1" ~/mafft-master
/root/mafft-master/core/mafft.1
/root/mafft-master/share/man/man1/mafft.1
$ md5sum /root/mafft-master/core/mafft.1 /root/mafft-master/share/man/man1/mafft.1
1eadd020af7e4f50baaf479f70823408  /root/mafft-master/core/mafft.1
1eadd020af7e4f50baaf479f70823408  /root/mafft-master/share/man/man1/mafft.1
$ ln -s /root/mafft-master/share/man/man1/mafft.1 /root/mafft-master/libexec/mafft/mafft.1
$ mafft --man | head -n 5
MAFFT(1)                                   Mafft Manual                                  MAFFT(1)

THIS MANUAL IS FOR V6.2XX (2007)
       Recent versions (v7.1xx; 2013 Jan.) have more features than those described below.  See
       also the tips page at http://mafft.cbrc.jp/alignment/software/tips0.html
```

```shell
mafft --clustalout --auto [input.fasta] > [output.clustal]
script -c 'time mafft --maxiterate 1000 --auto [input.fasta] > [output.fasta]' [output.fasta.log]
```

### [T-Coffee](https://tcoffee.org/Projects/tcoffee/index.html)

会输出[三个文件](https://tcoffee.org/Projects/tcoffee/documentation/index.html#t-coffee)。

```
When aligning, T-Coffee will always at least generate three files:

        sample_seq1.aln : Multiple Sequence Alignment (ClustalW format by default)

        sample_seq1.dnd : guide tree (Newick format)

        sample_seq1.html : colored MSA according to consistency (html format)
```

```shell
t_coffee [input.fasta] -mode quickaln
```

### [Clustal Omega](http://www.clustal.org/omega/)

## [trimAl](https://vicfero.github.io/trimal/)

> [Welcome to trimAl’s documentation!](https://trimal.readthedocs.io/en/latest/index.html)

```shell
trimal -in [input.fasta] -out[output.fasta] -automated1
```

## [IQ-TREE](https://github.com/iqtree/iqtree2) 常用命令

> [IQ-tree2构建系统发育树使用小结](https://www.jianshu.com/p/aa0192f37657)
建议单独创立一个路径用于存放建树用的 \[input.fasta\]、\[MSAoutput.phy\]、[qitree.output ...]。

```shell
# 无根树
iqtree2 -s [MSA-aligned-output.ply] -B 1000 -nt 16 --prefix my_iqtree2 -gz --redo-tree
script -c 'iqtree2-mpi -s [MSA-aligned-output.trimal.fa] -B 1000 -nt 12 --prefix my_iqtree2-mpi -gz --redo-tree' my_iqtree2-mpi.script.log
```

## PyMOL 教育版，申请起来比较容易

- [PyMOL教育版安装教程](https://zhuanlan.zhihu.com/p/598711018)
- [PyMOL 官网](https://pymol.org/2/)，下载。
- [PyMod 如虎添翼](https://pymolwiki.org/index.php/PyMod)，可视化地使用 modeller。
- [能用 conda 安装 modeller](https://salilab.org/modeller/download_installation.html) 的话，绝不用软件库或解压包，因为环境依赖问题。
- 通过 conda 创建 pymol-open-source 的运行环境，安装 pymol-open-source、biopython；然后将 modeller 安装在 pymol-open-source 的这个环境。
- 启动 pymol-open-source 后，安装 pymod3 插件，并重启。
- 启动 pymod，在其导航栏的 help 选项中点击”Install PyMod Components“，完成其余安装。
- 然后就可以借助 PyMod 使用 Modeller 进行同源建模了。

## [imgcat](https://github.com/eddieantonio/imgcat) 查看图像

```shell
imgcat -d 24bit -RH my_github_avatar.jpg
```

图像清晰度最好。


## [termimage](https://github.com/nabijaczleweli/termimage) 查看图像

```shell
termimage -s [width]x[height] my_github_avatar.jpg
```
图像清晰度次于 imgcat。

## [viu](https://github.com/atanunq/viu) 查看图像

```shell
viu -b my_github_avatar.jpg
```

图像着色十分“复古”。

## 一些 rust 命令行工具

```
bat    btm    cargo-binstall  cargo-fmt   clippy-driver  difft   dust  exa  lfs  mcfly  procs  rls            rust-gdb     rust-lldb  rustdoc  rustup     tldr      viu  zoxide
broot  cargo  cargo-clippy    cargo-miri  delta          dprint  eva   fd   lsd  ouch   rip    rust-analyzer  rust-gdbgui  rustc      rustfmt  termimage  topgrade  xcp 
```

---

## 我想玩 [VIM Adventures](https://zhuanlan.zhihu.com/p/628613725)

### 破解版

```shell
git clone https://github.com/AkshayGupta8/Vim-adventure.git
cd Vim-adventure/vim-adventures
conda create -n vim-adventure -y
conda activate vim-adventure
conda install -c conda-forge nodejs -y
npm install -g npm@6
npm install
node bin/www.js
cd ..
cd ..
conda deactivate
conda env remove --name vim-adventure
rm -rf Vim-adventure
```

### [Interactive Vim tutorial](https://www.openvim.com/)，好！

### [Terminus](http://web.mit.edu/mprat/Public/web/Terminus/Web/main.html)

## 批量下载hmm

```shell
hmm_path='./hmm_files'

while read line; do
  id=$(echo $line | tr -d '\n')
  printf "Downloading %s ... " $id
  curl "https://www.ebi.ac.uk/interpro/wwwapi//entry/pfam/$($id)\?annotation\=hmm" -o "${hmm_path}/${line}".hmm.gz
  echo 'Done.'
  done < ./PFXXXXX.IDlist.txt

```

## [seqkit](https://bioinf.shenwei.me/seqkit/)

### 使用`seqkit replace`重命名FASTA ID

```
$ cat test.fa
>seq1 desc1
CCCCAAAACCCCATGATCATGGATC
>seq2 desc2
CCCCAAAACCCCATGGCATCATTCA
>seq3 desc3
CCCCAAAACCCCATGTTGCTACTAG

$ cat test.0.fa
>seq1
CCCCAAAACCCCATGATCATGGATC
>seq2
CCCCAAAACCCCATGGCATCATTCA
>seq3
CCCCAAAACCCCATGTTGCTACTAG

$ cat renameID.tsv
seq1     renamed_seq1
seq2     renamed_seq2
seq3     renamed_seq3

# 根据kv-file映射文件，只修改ID，并保留描述
$ seqkit replace -p '^(\S+) (.+?)$' -r '{kv} ${2}' -k renameID.tsv test.fa
[INFO] read key-value file: renameID.tsv
[INFO] 3 pairs of key-value loaded
>renamed_seq1 name1
CCCCAAAACCCCATGATCATGGATC
>renamed_seq2 name2
CCCCAAAACCCCATGGCATCATTCA
>renamed_seq3 name3
CCCCAAAACCCCATGTTGCTACTAG

# 根据kv-file映射文件，只修改ID，并保留旧的ID和描述
$ seqkit replace -p '^(\S+) (.+?)$' -r '{kv} ${1} ${2}' -k renameID.tsv test.fa
[INFO] read key-value file: renameID.tsv
[INFO] 3 pairs of key-value loaded
>renamed_seq1 seq1 name1
CCCCAAAACCCCATGATCATGGATC
>renamed_seq2 seq2 name2
CCCCAAAACCCCATGGCATCATTCA
>renamed_seq3 seq3 name3
CCCCAAAACCCCATGTTGCTACTAG

# 对于缺少描述部分的FASTA，根据kv-file映射文件，只修改ID
$ seqkit replace -p '^(\S+)$' -r '{kv}' -k renameID.tsv test.0.fa
[INFO] read key-value file: renameID.tsv
[INFO] 3 pairs of key-value loaded
>renamed_seq1
CCCCAAAACCCCATGATCATGGATC
>renamed_seq2
CCCCAAAACCCCATGGCATCATTCA
>renamed_seq3
CCCCAAAACCCCATGTTGCTACTAG

# 对于缺少描述部分的FASTA，根据kv-file映射文件，只修改ID，并保留旧的ID
$ seqkit replace -p '^(\S+)$' -r '{kv} ${1}' -k renameID.tsv test.0.fa
[INFO] read key-value file: renameID.tsv
[INFO] 3 pairs of key-value loaded
>renamed_seq1 seq1
CCCCAAAACCCCATGATCATGGATC
>renamed_seq2 seq2
CCCCAAAACCCCATGGCATCATTCA
>renamed_seq3 seq3
CCCCAAAACCCCATGTTGCTACTAG

awk -F'\t' 'NR==FNR {map[$1]=$2; next} {if ($1 in map) print map[$1]; else print $1}' ids.map.tsv ids.txt > ids.renamed.txt
awk -F'\t' 'BEGIN{OFS="\t"} NR==FNR {map[$1]=$2; next} /^#/ {print; next} ($1 in map) {$1=map[$1]} {print}' id.map.tsv old.gff > new.gff

```

## [DESeq2](https://bioconductor.org/packages//release/bioc/html/DESeq2.html)

安装这个R包：

```
mamba create -n DESeq2
mamamba activate DESeq2
mamba install -c bioconda bioconductor-genomeinfodb  # 先装GenomeInfoDb，顺序不能变
mamba install -c bioconda -c conda-forge bioconductor-deseq2

#   bioconductor-biobase               2.66.0        r44h3df3fcb_0         bioconda
#   bioconductor-biocgenerics          0.52.0        r44hdfd78af_3         bioconda
#   bioconductor-biocparallel          1.40.0        r44he5774e6_1         bioconda
#   bioconductor-data-packages         20250625      hdfd78af_0            bioconda
#   bioconductor-delayedarray          0.32.0        r44h3df3fcb_1         bioconda
#   bioconductor-deseq2                1.46.0        r44he5774e6_1         bioconda
#   bioconductor-genomeinfodb          1.42.0        r44hdfd78af_2         bioconda
#   bioconductor-genomeinfodbdata      1.2.13        r44hdfd78af_0         bioconda
#   bioconductor-genomicranges         1.58.0        r44h3df3fcb_2         bioconda
#   bioconductor-iranges               2.40.0        r44h3df3fcb_2         bioconda
#   bioconductor-matrixgenerics        1.18.0        r44hdfd78af_0         bioconda
#   bioconductor-s4arrays              1.6.0         r44h3df3fcb_1         bioconda
#   bioconductor-s4vectors             0.44.0        r44h3df3fcb_2         bioconda
#   bioconductor-sparsearray           1.6.0         r44h3df3fcb_1         bioconda
#   bioconductor-summarizedexperiment  1.36.0        r44hdfd78af_0         bioconda
#   bioconductor-ucsc.utils            1.2.0         r44h9ee0642_1         bioconda
#   bioconductor-xvector               0.46.0        r44h15a9599_2         bioconda
#   bioconductor-zlibbioc              1.52.0        r44h3df3fcb_2         bioconda

R

library(DESeq2)

```

## [Minimap2](https://github.com/lh3/minimap2)

```
script -c 'minimap2 -t 12 -o minimap2_out.paf <target.fa> [query.fa]' minimap2_out.log
```

## [dotPlotly](https://github.com/tpoorten/dotPlotly)

```
git clone https://github.com/Rhylan2333/dotPlotly.git
script -c '../dotPlotly/pafCoordsDotPlotly.R -i minimap2_out.paf -o dotPlotly.minimap2.plot -k [number of autosomes and sex chromosomes + 1] -s -t -l -p 10' dotPlotly.minimap2.plot.log
```
