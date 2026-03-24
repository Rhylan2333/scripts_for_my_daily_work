# 1. 安装并加载必要的R包
# install.packages("ggplot2")
# install.packages("dplyr")
# install.packages("GGally")
# install.packages("viridis")
# install.packages("gridExtra")
# install.packages("cowplot")
# install.packages("patchwork")

library(ggplot2)
library(ggsci)
library(dplyr)
library(GGally)
library(viridis)
library(gridExtra)
library(cowplot)
library(patchwork)

# 2. 加载数据
# Load eigenvalues, eigenvectors and population info
# 获取命令行参数
args <- commandArgs(trailingOnly = TRUE)

# 检查是否提供了正确的参数数量
if (length(args) != 4) {
    stop("需要提供三个文件路径：PCA特征值文件, PCA特征向量文件, 表型信息文件；以及一个输出文件的后缀：如“all”。")
}

# 根据命令行参数读取数据
pca_eigenval <- read.table(args[1], stringsAsFactors = FALSE)
pca_eigenvec <- read.table(args[2], stringsAsFactors = FALSE)
pop_info <- read.table(args[3], header = TRUE, stringsAsFactors = FALSE)

# 打印确认信息（可选）
cat("加载了以下文件:\n",
    "PCA特征值文件:", args[1], "\n",
    "PCA特征向量文件:", args[2], "\n",
    "表型信息文件:", args[3], "\n",
    "输出文件的后缀:", args[4], "\n")

# Rename columns for easier handling
colnames(pca_eigenvec) <- c("FID", "IID", paste0("PC", 1:(ncol(pca_eigenvec)-2)))

# Merge PCA data with population info based on IID
merged_data <- merge(pca_eigenvec, pop_info, by.x = "FID", by.y = "IID", all.x = TRUE)
# 确保 PHENOTYPE 是因子
merged_data$PHENOTYPE <- as.factor(merged_data$PHENOTYPE)

# Check the merged data structure
tail(merged_data)
# 检查是否有缺失值，并处理缺失值
summary(merged_data)
# show(merged_data)
## 如果PHENOTYPE列存在<NA>，说明phenotype.tsv的IID列下的行并不一一对应于plink_pca.eigenvec的第一列下的行。
# merged_data <- merged_data %>% na.omit()  # 删除含有缺失值的行

# 3.1 计算累积贡献率
## 计算每个主成分解释的总方差百分比以及累积百分比，这对于选择显示哪些主成分很有帮助。
explained_variance <- pca_eigenval$V1 / sum(pca_eigenval$V1)
cumulative_variance <- cumsum(explained_variance)
df_var = data.frame(PC = 1:length(explained_variance),
    Explained_Variance = explained_variance,
    Cumulative_Variance = cumulative_variance)
print(df_var)
# 绘制落石图
plot_screen <- ggplot(df_var,
    aes(x = PC, y = Explained_Variance)
    ) + geom_line() + geom_point()

ggsave(filename = sprintf("plot.pca.explained_variance.%s.png", args[4]),
    plot = plot_screen,
    width = 6,
    height = 6,
    dpi = 600)

# 4. 使用ggpairs()绘制散点图矩阵
pca_columns <- paste0("PC", 1:3)
pca_subset <- merged_data[, c(pca_columns, "PHENOTYPE")]

# 自定义上三角函数：相关系数 + 更大间距
upper_fn <- function(data, mapping, ...) {
  cor_val <- cor(data[,1], data[,2])
  p_val <- cor.test(data[,1], data[,2])$p.value
  sig <- ifelse(p_val < 0.001, "***", ifelse(p_val < 0.01, "**", ifelse(p_val < 0.05, "*", "")))
  
  text_data <- data.frame(
    x = mean(range(data[,1])),
    y = mean(range(data[,2])),
    label = paste0("Cor: ", round(cor_val, 3), sig)
  )
  
  ggplot(data = data, mapping = mapping) +
    geom_text(data = text_data, aes(x = x, y = y, label = label),
              size = 4.0,
              color = "black",
              fontface = "bold",
              vjust = -1,
              nudge_y = 0.05)
}

# 自定义下三角绘图函数：散点 + PHENOTYPE 标签
lower_fn <- function(data, mapping, ...) {
  ggplot(data = data, mapping = mapping) +
    geom_point(aes(color = PHENOTYPE), size = 1.5)
    # geom_point(aes(color = PHENOTYPE), size = 1.5) +
    # geom_text(aes(label = PHENOTYPE), hjust = -0.1, vjust = -0.1, size = 1.5)
}

# 构建 ggpairs 图
# my_colors <- c(pal_npg()(10), pal_flatui()(6))
my_colors <- c(pal_d3(palette = "category20c")(16))
print(my_colors)
plot_pca_pairs <- ggpairs(
    data = pca_subset,
    columns = pca_columns,
    mapping = aes(color = PHENOTYPE, alpha = 0.8),
    upper = list(continuous = wrap("cor", size = 3.0)),
    lower = list(continuous = lower_fn),
    ) +
  # scale_color_viridis(option = "turbo", discrete = TRUE)  # 高对比度 viridis 调色板
  # scale_fill_tron()  # 高对比度 viridis 调色板
  # scale_color_manual(values = my_colors)    # 👈 关键：用 manual + 自定义颜色
  # scale_fill_manual(values = my_colors)     # 如果 lower_fn 用 fill
  scale_color_d3(palette = "category20", alpha = 0.8)

ggsave(filename = sprintf("plot.pca_scatterplot_matrix_new.%s.pdf", args[4]),
    plot = plot_pca_pairs,
    width = 10,
    height = 10,
    dpi = 600)
ggsave(filename = sprintf("plot.pca_scatterplot_matrix_new.%s.png", args[4]),
    plot = plot_pca_pairs,
    width = 10,
    height = 10,
    dpi = 600)

warnings()
