import pandas as pd

# singularity: "docker://continuumio/miniconda3:4.6.14"
configfile: "config.yaml"

HISTONES=["H3K4me1", "H3K27ac"]

rule all:
    input:
        # fastqc
        # GM_html=expand("results/2018-10-03/fastqc/{sample}.html",sample=GM_SAMPLES),
        # GM_zip=expand("results/2018-10-03/fastqc/{sample}.zip",sample=GM_SAMPLES),
        # IMR_html=expand("results/2018-12-01/fastqc/{sample}.html",sample=IMR_SAMPLES),
        # IMR_zip=expand("results/2018-12-01/fastqc/{sample}.zip",sample=IMR_SAMPLES),
        # GM hg18
        # eRNAliftOverhg19="results/2018-11-25/hg19_eRNA_overlaps.bed",
        # GM18_test1="results/2018-11-10/hg18_eRNA_overlaps.bed",
        # GM18_test2="results/2018-11-25/hg19_eRNA_overlaps.bed",
        # GM hg19
        GM_counts=expand("results/2019-01-28/GM/{unit}_groseq_peak.bed", unit=GM_SAMPLES),
        # hg19eRNA="results/2018-11-29/eRNA_GM_hg19.bed",
        # GM19_test1="results/2018-11-30/hg19_eRNA_overlaps_Peng.bed",
        # GM19_test2="results/2018-11-30/hg19_eRNA_overlaps_liftOver.bed",
        # IMR hg19
        IMR_counts=expand("results/2019-01-28/IMR/{unit}_groseq_peak.bed", unit=IMR_SAMPLES),
        # IMR_eRNA="results/2018-12-02/eRNA_IMR_hg19.bed",
        IMR_test1="results/2018-11-10/test/IMR_eRNA_vs_Peng.bed",
        IMR_test2="results/2018-11-10/test/IMR_eRNA_vs_GM19.bed",
        IMR_test3="results/2018-11-10/test/IMR_eRNA_vs_liftOver.bed",
        # Differential Analysis
        # GM_diff="results/2018-01-30/GM19_eRNA_diffPeaks.txt",
        # IMR_diff="results/2018-01-30/IMR_eRNA_diffPeaks.txt",
        # GM_annotation=expand("results/2019-02-05/GM/{unit}_outputannotation.txt", unit=GM_SAMPLES),
        GM19_limma="results/2019-06-26/dge/limma/GM19_limma.txt",
        IMR_limma="results/2019-06-26/dge/limma/IMR_limma.txt",
        GM19_grohmm="results/2019-06-26/dge/grohmm/GM19_grohmm.txt",
        IMR_grohmm="results/2019-06-26/dge/grohmm/IMR_grohmm.txt",

include: "rules/data.smk"

include: "rules/GM18/bowtie2.smk"
include: "rules/GM18/homer.smk"
include: "rules/GM18/removeGenes.smk"
include: "rules/GM18/keepHistones.smk"
include: "rules/GM18/liftOver.smk"
include: "rules/GM18/test_peng_eRNAs.smk"

include: "rules/GM19/fastqc.smk"
include: "rules/GM19/bowtie2.smk"
include: "rules/GM19/homer.smk"
include: "rules/GM19/removeGenes.smk"
include: "rules/GM19/keepHistones.smk"
include: "rules/GM19/test_eRNAs.smk"

include: "rules/IMR/fastqc.smk"
include: "rules/IMR/bowtie2.smk"
include: "rules/IMR/homer.smk"
include: "rules/IMR/removeGenes.smk"
include: "rules/IMR/keepHistones.smk"
include: "rules/IMR/test_eRNAs.smk"

include: "rules/eRNAcleaning.smk"
include: "rules/countReads.smk"
include: "rules/dge.smk"
