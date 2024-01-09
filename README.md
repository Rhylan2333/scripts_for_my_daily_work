# scripts_for_my_daily_work

## cal_fasta_seq_len.py

统计一个FASTA文件中所有序列的长度然后以CSV格式输出，一般选最长的作为参考序列。示例：

```shell
python3 ./cal_fasta_seq_len.py -i ./XXX_protein.faa -o ./XXX_pro_seq_len.csv
grep '>' ./XXX_protein.faa
# 进行多序列比对
clustalo -i ./XXX_protein.faa -o ./XXX_pro_MSA_result.clustal --outfmt=clustal -v --force
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
docker run -it -d --name="nvidia-devel_ubuntu22.04" --hostname="caicai" --volume="C:\Users\cauca\Desktop\work":"/home/work" --workdir="/home/work" --privileged=true --gpus all -e TZ=Asia/Shanghai nvidia/cuda:12.3.1-devel-ubuntu22.04
1289e918d0505208081924e2cb36a13f97411283ea97386d2fdd61d1432ac64e
# 或者没必要的如下：
docker run -it -d --name="nvidia-devel_ubuntu22.04" --hostname="caicai" --volume="C:\Users\cauca\Desktop\work":"/home/work" --workdir="/home/work" --privileged=true --gpus all -e NVIDIA_DRIVER_CAPABILITIES=compute,utility -e NVIDIA_VISIBLE_DEVICES=all nvidia/cuda:12.3.1-devel-ubuntu22.04
```

- 强烈建议使用 GPU，[NVIDIA Docker：让 GPU 服务器应用程序部署变得容易](https://developer.nvidia.com/zh-cn/blog/nvidia-docker-gpu-server-application-deployment-made-easy/)

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

```
imgcat -d 24bit -RH my_github_avatar.jpg
```

图像清晰度最好。


## [termimage](https://github.com/nabijaczleweli/termimage) 查看图像

```
termimage -s [width]x[height] my_github_avatar.jpg
```
图像清晰度次于 imgcat。

## [viu](https://github.com/atanunq/viu) 查看图像

```
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
