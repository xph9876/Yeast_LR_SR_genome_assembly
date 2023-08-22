rule all:
    input:
        'busco'

rule trimming_illumina:
    input:
        'raw_reads/illumina.fastq.gz'
    output:
        directory('trimmed_reads')
    shell:
        "trim_galore -o {output} {input} -j 4"

rule flye_assembly:
    input:
        'raw_reads/nanopore.fastq.gz'
    output:
        directory('flye_assembly')
    threads:
        24
    shell:
        "flye --nano-raw {input} --o {output} --threads {threads}"

rule bwa_index:
    input:
        'flye_assembly/assembly.fasta'
    output:
        'flye_assembly/assembly.fasta.bwt',
    shell:
        "bwa index {input}"


rule SR_alignment:
    input:
        reads='trimmed_reads/illumina_trimmed.fq.gz',
        ref='flye_assembly/assembly.fasta'
    output:
        'align_reads/sr.bam'
    threads:
        24
    shell:
        "bwa mem {input.ref} {input.reads} -t {threads} | samtools sort - -o {output}"


rule bam_index:
    input:
        'align_reads/sr.bam'
    output:
        'align_reads/sr.bam.bai'
    shell:
        "samtools index {input} -o {output}"


rule pilon_polish:
    input:
        ref='flye_assembly/assembly.fasta',
        bam='align_reads/sr.bam',
        bai='align_reads/sr.bam.bai'
    output:
        directory('polished_assembly')
    threads:
        24
    shell:
        "pilon --genome {input.ref} --unpaired {input.bam} --outdir {output} --changes --vcf"


rule busco_eval:
    input:
        'polished_assembly/pilon.fasta'
    output:
        directory('busco')
    params:
        linage='saccharomycetes_odb10'
    threads:
        24
    shell:
        "busco -i {input} -l {params.linage} -m genome -o {output} -c {threads}"

