# GIF_RNA-seq

RNA-seq 分析脚本，包含两个可独立使用的模块：

- `analys_count/`：用 Snakemake 管理，从 SRA 数据计算基因表达 **count** 矩阵。
- `count_to_FPKM/`：用 R 脚本把 count 矩阵换算为 **FPKM**。

## 目录结构

```text
GIF_RNA-seq/
├── analys_count/               # 模块一：count 计算（Snakemake）
│   ├── config.yaml             # 样本、参考基因组、注释、测序类型等配置
│   └── Snakefile               # 主流程
└── count_to_FPKM/              # 模块二：count -> FPKM（R）
    ├── FPKM.R                  # 主脚本
    ├── species-list.txt        # 待处理物种列表
    └── count/                  # 输入 count 矩阵
        └── P.patens_count.txt  # 示例
```

流程运行后会在 `analys_count/` 下自动生成 `genome_index/`、`sra/`、`fastq/`、`clean/`、`bam/`、`logs/`、`results/`、`count/`。

## 文件说明

| 文件 | 说明 |
| --- | --- |
| `analys_count/config.yaml` | 唯一配置入口：`samples`（SRA accession）、`species`、`genome_fasta`、`annotation_gtf`、`seq_type`（SE/PE）、Trimmomatic jar 与接头文件 |
| `analys_count/Snakefile` | 10 条 rule：建 HISAT2 索引 -> 合并接头 -> prefetch 下载 -> vdb-validate 校验 -> fastq-dump 转 FASTQ -> Trimmomatic 质控 -> HISAT2 比对 -> samtools 排序 -> featureCounts 计数 -> 整理表格 |
| `count_to_FPKM/FPKM.R` | 由 count 计算 RPK / TPM / FPKM，按分组取重复均值，输出 `<物种>FPKM.txt` |
| `count_to_FPKM/species-list.txt` | 每行一个物种前缀，对应 `count/<前缀>_count.txt` |

## 依赖

- 模块一：Snakemake、SRA Toolkit（`prefetch` / `vdb-validate` / `fastq-dump`）、Trimmomatic（需 Java）、HISAT2、SAMtools、featureCounts（Subread）
- 模块二：R（>= 4.1）、`dplyr`、`tidyr`

## 使用方法

### 一、计算 count（Snakemake）

```bash
cd "analys_count"        # 目录名含空格，需要引号

# 编辑 config.yaml：样本号、参考基因组 FASTA、GTF 注释、SE/PE、Trimmomatic 路径与接头文件

snakemake -np            # 试运行，检查任务与命令
snakemake --cores 16     # 正式运行
snakemake --cores 16 --rerun-incomplete   # 中断后接续
```

结果表：

- `results/all_samples_counts.txt`：featureCounts 原始输出
- `count/<species>_counts.txt`：只保留 `Geneid`、`Length` 及各样本 count 列

### 二、计算 FPKM（R）

```bash
cd count_to_FPKM         # 脚本使用相对路径，必须在 count_to_FPKM/ 下运行
Rscript FPKM.R
```

- 输入：`count/<物种>_count.txt`，第 1 列基因 ID，第 2 列基因长度（bp），其余列为各样本 count；`species-list.txt` 每行一个前缀。
- 输出：`<物种>FPKM.txt`，列为 `Gene` + `FPKM1`、`FPKM2` ...
- 分组：列名末尾的 `.<数字>` 会被去掉作为分组名并取组内均值，重复样本建议命名为 `protonema.1`、`protonema.2`、`protonema.3`。

## 备注

- `analys_count/` 目录名含空格，命令行中必须加引号。
- 示例 `count/P.patens_count.txt` 为制表符分隔，而 `FPKM.R` 按逗号读取（`sep = ','`），两者需统一，否则会读成空矩阵。
- 建议将本地运行残留（`.RData`、`.Rhistory`）加入 `.gitignore`。

## 许可证

Unlicense（公有领域）。
