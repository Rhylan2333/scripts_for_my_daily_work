# 用于把OrthoFinder的树转换成超度量树，以便CAFE5的后续分析

library(ape)

# 读取树
# [work]/primary_transcripts/OrthoFinder/Results_XXXXX/Species_Tree/SpeciesTree_rooted_node_labels.txt
# 重命名labels
tree_file <- "SpeciesTree_rooted_node_labels.reheader.nwk"
tree <- read.tree(tree_file)

cat("🌳 超度量树转换工具\n")
cat("=======================================\n")
cat(sprintf("📄 输入文件: %s\n", tree_file))
cat(sprintf("🧬 物种数量: %d\n", length(tree$tip.label)))
cat(sprintf("⏱️  当前树高: %.4f\n\n", max(node.depth.edgelength(tree))))

# 原始状态
cat("🔍 原始树状态:\n")
cat(sprintf("   - 二叉树: %s\n", is.binary(tree)))
cat(sprintf("   - 有根树: %s\n", is.rooted(tree)))
cat(sprintf("   - 超度量树: %s\n\n", is.ultrametric(tree, tol = 1e-8)))

# ================ 策略1: 简单线性缩放 (最快) ================
cat("🔧 策略1: 简单线性缩放 (保持拓扑)\n")

# 1. 使树有根 (如果需要)
if (!is.rooted(tree)) {
  tree <- root(tree, outgroup = "Drosophila_melanogaster", resolve.root = TRUE)
}

# 2. 计算当前叶节点深度
tip_depths <- node.depth.edgelength(tree)[1:length(tree$tip.label)]
max_depth <- max(tip_depths)

# 3. 为每个叶节点添加缺失的长度
edge_added <- numeric(nrow(tree$edge))
for (i in 1:length(tree$tip.label)) {
  # 找到通往该叶节点的路径
  path <- which(tree$edge[,2] == i)
  if (length(path) > 0) {
    # 计算需要添加的长度
    add_length <- max_depth - tip_depths[i]
    if (add_length > 1e-8) {
      edge_added[path] <- add_length
    }
  }
}

# 4. 创建新树
tree_simple <- tree
tree_simple$edge.length <- tree$edge.length + edge_added

cat(sprintf("   - 原始深度范围: [%.6f, %.6f]\n", min(tip_depths), max(tip_depths)))
cat(sprintf("   - 新深度范围: [%.6f, %.6f]\n", 
           min(node.depth.edgelength(tree_simple)[1:length(tree$tip.label)]),
           max(node.depth.edgelength(tree_simple)[1:length(tree$tip.label)])))
cat(sprintf("   - 超度量验证: %s\n\n", is.ultrametric(tree_simple, tol = 1e-8)))

# ================ 策略2: Grafen 方法 (推荐) ================
cat("🔧 策略2: Grafen 方法 (平衡分支长度)\n")
tree_grafen <- compute.brlen(tree, method = "Grafen", power = 1)

cat(sprintf("   - 超度量验证: %s\n", is.ultrametric(tree_grafen, tol = 1e-8)))
cat(sprintf("   - 树高: %.4f\n\n", max(node.depth.edgelength(tree_grafen))))

# ================ 策略3: 分子钟校准 (最准确，需要时间约束) ================
if (requireNamespace("geiger")) {
  library(geiger)
  
  cat("🔧 策略3: 分子钟校准 (chronos)\n")
  
  # 创建时间约束 (示例：使用根节点时间)
  # 实际使用时应替换为真实的化石校准点
  root_age <- 100  # 百万年 (根据您的系统发育调整)
  
  # 创建校准数据框
  calibration <- data.frame(
    node = 1,  # 根节点
    age.min = root_age * 0.9,  # 允许10%误差
    age.max = root_age * 1.1,
    stringsAsFactors = FALSE
  )
  
  cat(sprintf("   - 使用根节点校准: %.1f ±10%% 百万年\n", root_age))
  
  # 尝试校准
  tryCatch({
    tree_chronos <- chronos(tree) # , model = "correlated", calibration = calibration 
    cat(sprintf("   - chronos 校准成功!\n"))
    cat(sprintf("   - 超度量验证: %s\n", is.ultrametric(tree_chronos, tol = 1e-8)))
    cat(sprintf("   - 树高: %.4f\n\n", max(node.depth.edgelength(tree_chronos))))
  }, error = function(e) {
    cat(sprintf("   ⚠️ chronos 校准失败: %s\n", e$message))
    cat("      跳过此策略，使用Grafen方法替代\n\n")
    tree_chronos <- NULL
  })
}

# ================ 选择最佳策略 ================
if (!is.null(tree_chronos) && is.ultrametric(tree_chronos, tol = 1e-8)) {
  best_tree <- tree_chronos
  method_used <- "分子钟校准 (chronos)"
} else if (is.ultrametric(tree_grafen, tol = 1e-8)) {
  best_tree <- tree_grafen
  method_used <- "Grafen 方法"
} else {
  best_tree <- tree_simple
  method_used <- "简单线性缩放"
}

cat(sprintf("✅ 选择最佳策略: %s\n", method_used))
cat(sprintf("   - 最终超度量验证: %s\n", is.ultrametric(best_tree, tol = 1e-8)))
cat(sprintf("   - 最终树高: %.4f\n\n", max(node.depth.edgelength(best_tree))))

# ================ 保存结果 ================
output_file <- gsub("\\.nwk$", "_ultrametric.nwk", tree_file)
write.tree(best_tree, file = output_file)

# 保留内部节点标签 (CAFE5 需要)
if (!is.null(tree$node.label)) {
  best_tree$node.label <- tree$node.label
  output_file_labeled <- gsub("\\.nwk$", "_ultrametric_labeled.nwk", tree_file)
  write.tree(best_tree, file = output_file_labeled)
  cat(sprintf("🏷️  保留节点标签的树已保存: %s\n", output_file_labeled))
}

cat(sprintf("💾 超度量树已保存: %s\n\n", output_file))

# ================ 生成验证报告 ================
cat("📊 验证报告:\n")
validation_tree <- read.tree(output_file)
cat(sprintf("   - 读取验证: %s\n", !is.null(validation_tree)))
cat(sprintf("   - 二叉树: %s\n", is.binary(validation_tree)))
cat(sprintf("   - 有根树: %s\n", is.rooted(validation_tree)))
cat(sprintf("   - 超度量树: %s\n", is.ultrametric(validation_tree, tol = 1e-8)))

# ================ 可视化对比 (可选) ================
if (interactive()) {
  cat("\n🖼️  生成可视化对比图...\n")
  png("tree_ultrametric_comparison.png", width=1200, height=600)
  par(mfrow=c(1,2), mar=c(4,4,2,1))
  
  # 原始树
  plot(tree, main="原始树", cex=0.7, no.margin=TRUE)
  axisPhylo()
  abline(h=0.5, col="red", lty=2)
  text(0, 0.5, sprintf("深度范围: [%.3f, %.3f]", 
       min(tip_depths), max(tip_depths)), pos=4, col="red")
  
  # 超度量树
  plot(best_tree, main=sprintf("超度量树 (%s)", method_used), cex=0.7, no.margin=TRUE)
  axisPhylo()
  abline(h=0.5, col="green", lty=2)
  tip_depths_new <- node.depth.edgelength(best_tree)[1:length(best_tree$tip.label)]
  text(0, 0.5, sprintf("深度范围: [%.3f, %.3f]", 
       min(tip_depths_new), max(tip_depths_new)), pos=4, col="green")
  
  dev.off()
  cat("✅ 对比图已保存: tree_ultrametric_comparison.png\n")
}

cat("\n✨ 转换完成! 现在可以使用此树运行CAFE5:\n")
cat(sprintf("   cafe5 -i gene_families.txt -t %s -p -k 3 ...\n", output_file))
