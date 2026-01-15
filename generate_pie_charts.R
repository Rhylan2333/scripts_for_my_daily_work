# generate_pie_charts.R
# 当前路径：cafe_Results/，包含results_pk2/……results_pk5/

library(ggplot2)
library(dplyr)
library(tidyr)

# 1. 读取数据
# seqkit stats -T -b ../primary_transcripts/*.fa -o seqkit_stats.tsv
seqkit_stats <- read.delim("seqkit_stats.tsv", stringsAsFactors = FALSE)

data <- read.delim(
    "results_pk3/Gamma_clade_results.txt",
    check.names = FALSE, # 保留原始列名
    stringsAsFactors = FALSE
) %>%
    rename(Taxon_ID = `#Taxon_ID`) # 重命名特殊列名

# # 2. 优化：正确处理节点标签，识别内部节点（<数字>）和叶节点（物种名<数字>）
data <- data %>%
    mutate(
        # 识别内部节点（<数字>）和叶节点（<物种名>）
        label = ifelse(
            grepl("^<\\d+>$", Taxon_ID), # 匹配内部节点
            Taxon_ID, # 保留原始格式（如<25>）
            gsub("<\\d+>$", "", Taxon_ID) # 移除叶节点结尾的<数字>（如<8>）
        ),
        # 转换数值列
        num_expansion = as.numeric(Increase),
        num_contraction = as.numeric(Decrease)
    )

# 3. 计算比例（节点级别）
data <- data %>%
    mutate(
        total_node = num_expansion + num_contraction,
        prop_expansion = num_expansion / total_node,
        prop_contraction = num_contraction / total_node
    ) %>%
    # 4. 添加分支数据（用于分支比例）
    left_join(
        seqkit_stats %>%
            select(label = file, total_genes = num_seqs),
        by = "label"
    ) %>%
    # 5. 修正ifelse错误：确保三个参数都存在
    mutate(
        prop_branch_expansion = ifelse(
            is.na(total_genes),
            NA_real_,
            num_expansion / total_genes
        ),
        prop_branch_contraction = ifelse(
            is.na(total_genes),
            NA_real_,
            num_contraction / total_genes
        ),
        prop_branch_no_change = ifelse(
            is.na(total_genes),
            NA_real_,
            (total_genes - num_expansion - num_contraction) / total_genes
        )
    )

# 6. 生成节点比例饼图（核心分析）
node_pie_data <- data %>%
    select(label, prop_expansion, prop_contraction) %>%
    pivot_longer(
        cols = c(prop_expansion, prop_contraction),
        names_to = "category",
        values_to = "proportion"
    ) %>%
    mutate(
        category = case_when(
            category == "prop_expansion" ~ "Expansion",
            category == "prop_contraction" ~ "Contraction"
        )
    )

# 7. 生成分支比例饼图（补充分析）
branch_pie_data <- data %>%
    select(
        label,
        prop_branch_expansion,
        prop_branch_contraction,
        prop_branch_no_change
    ) %>%
    pivot_longer(
        cols = c(
            prop_branch_expansion,
            prop_branch_contraction,
            prop_branch_no_change
        ),
        names_to = "category",
        values_to = "proportion"
    ) %>%
    mutate(
        category = case_when(
            category == "prop_branch_expansion" ~ "Expansion",
            category == "prop_branch_contraction" ~ "Contraction",
            category == "prop_branch_no_change" ~ "No Change"
        )
    )

# 8. 创建饼图
node_pie <- ggplot(
    node_pie_data,
    aes(x = "", y = proportion, fill = category)
) +
    geom_bar(stat = "identity", width = 1) +
    coord_polar("y", start = 0) +
    scale_fill_manual(
        values = c("Expansion" = "#D15354", "Contraction" = "#5094D5")
    ) +
    theme_void() +
    theme(
        legend.position = "none",
        plot.title = element_text(hjust = 0.5)
    ) +
    facet_wrap(~label, scales = "free") +
    labs(title = "Gene Family Expansion/Contraction (Node-Level)")

branch_pie <- ggplot(
    branch_pie_data,
    aes(x = "", y = proportion, fill = category)
) +
    geom_bar(stat = "identity", width = 1) +
    coord_polar("y", start = 0) +
    scale_fill_manual(
        values = c("Expansion" = "#D15354", "Contraction" = "#5094D5", "No Change" = "#BEBADA")
    ) +
    theme_void() +
    theme(
        legend.position = "none",
        plot.title = element_text(hjust = 0.5)
    ) +
    facet_wrap(~label, scales = "free") +
    labs(title = "Gene Family Evolution (Branch-Level)")

# 9. 保存结果
ggsave("pie_charts_node.pdf", node_pie, width = 12, height = 16, dpi = 300)
ggsave("pie_charts_branch.pdf", branch_pie, width = 12, height = 16, dpi = 300)

# 10. 生成详细报告
report <- data %>%
    select(
        label,
        num_expansion,
        num_contraction,
        prop_expansion,
        prop_contraction,
        total_genes,
        prop_branch_expansion,
        prop_branch_contraction,
        prop_branch_no_change
    ) %>%
    mutate(
        # 格式化比例
        prop_expansion = sprintf("%.1f%%", prop_expansion * 100),
        prop_contraction = sprintf("%.1f%%", prop_contraction * 100),
        prop_branch_expansion = sprintf(
            "%.1f%%",
            prop_branch_expansion * 100
        ),
        prop_branch_contraction = sprintf(
            "%.1f%%",
            prop_branch_contraction * 100
        ),
        prop_branch_no_change = sprintf(
            "%.1f%%",
            prop_branch_no_change * 100
        )
    ) %>%
    select(
        label,
        num_expansion,
        num_contraction,
        prop_expansion,
        prop_contraction,
        prop_branch_expansion,
        prop_branch_contraction,
        prop_branch_no_change
    )

write.table(report, "cafe5_summary_report.tsv", sep = "\t", row.names = FALSE)

print("饼图和报告已生成！")
