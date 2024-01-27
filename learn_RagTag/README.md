# 探索 RagTag 的用法

`ragtag.py patch ...` 的本质就是调用了那三个比对算法。在我的环境下，我无法成功调用 nucmer 程序，只能调用 minimap2 进行 path（作者建议用 nucmer）。
因此，为了实现 patch，我可以使用 `Nucmer + ALLMAPS` 的办法完成个性化的补齐。
