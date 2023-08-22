# Yeast genome assembly pipeline
This snakemake pipeline is used to generate a *de novo* genome assembly using both Nanopore long sequencing read and Illumina short reads

## Dependency
```bash
conda env create -n genome_assembly -f env.yaml
conda activate genome_assembly
```

## Run
```bash
snakemake -c 24
```
