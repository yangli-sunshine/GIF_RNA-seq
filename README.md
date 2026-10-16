# GIF_RNA-seq

RNA-seq analysis scripts, organized into two independent modules:

- `analys_count/` - a Snakemake workflow that computes a gene expression **count** matrix from SRA data.
- `count_to_FPKM/` - an R script that converts a count matrix into **FPKM**.

## Directory Structure

```text
GIF_RNA-seq/
├── analys_count/               # Module 1: count calculation (Snakemake)
│   ├── config.yaml             # samples, reference genome, annotation, sequencing type
│   └── Snakefile               # main workflow
└── count_to_FPKM/              # Module 2: count -> FPKM (R)
    ├── FPKM.R                  # main script
    ├── species-list.txt        # species to process
    └── count/                  # input count matrices
        └── P.patens_count.txt  # example
```

Running the workflow creates `genome_index/`, `sra/`, `fastq/`, `clean/`, `bam/`, `logs/`, `results/` and `count/` inside `analys_count/`.

## Files

| File | Description |
| --- | --- |
| `analys_count/config.yaml` | Single configuration entry point: `samples` (SRA accessions), `species`, `genome_fasta`, `annotation_gtf`, `seq_type` (SE/PE), Trimmomatic jar and adapter file |
| `analys_count/Snakefile` | 10 rules: build HISAT2 index -> merge adapters -> prefetch -> vdb-validate -> fastq-dump -> Trimmomatic -> HISAT2 alignment -> samtools sort -> featureCounts -> tidy table |
| `count_to_FPKM/FPKM.R` | Computes RPK / TPM / FPKM from counts, averages replicates per group, writes `<species>FPKM.txt` |
| `count_to_FPKM/species-list.txt` | One species prefix per line, matching `count/<prefix>_count.txt` |

## Requirements

- Module 1: Snakemake, SRA Toolkit (`prefetch` / `vdb-validate` / `fastq-dump`), Trimmomatic (requires Java), HISAT2, SAMtools, featureCounts (Subread)
- Module 2: R (>= 4.1), `dplyr`, `tidyr`

## Usage

### 1. Count matrices (Snakemake)

```bash
cd analys_count

# edit config.yaml: sample accessions, reference FASTA, GTF annotation, SE/PE, Trimmomatic paths

snakemake -np            # dry run, inspect jobs and commands
snakemake --cores 16     # run
snakemake --cores 16 --rerun-incomplete   # resume an interrupted run
```

Output tables:

- `results/all_samples_counts.txt` - raw featureCounts output
- `count/<species>_counts.txt` - `Geneid`, `Length` and the per-sample count columns only

### 2. FPKM (R)

```bash
cd count_to_FPKM         # the script uses relative paths, run it inside count_to_FPKM/
Rscript FPKM.R
```

- Input: `count/<species>_count.txt` - column 1 is the gene ID, column 2 is the gene length (bp), the remaining columns are per-sample counts; `species-list.txt` holds one species prefix per line.
- Output: `<species>FPKM.txt` with columns `Gene`, `FPKM1`, `FPKM2`, ...
- Grouping: a trailing `.<digits>` is stripped from each column name and used as the group, then replicates are averaged, so name replicate samples `protonema.1`, `protonema.2`, `protonema.3`.

## License

Unlicense (public domain).
