/*
 * Uncompress and prepare reference genome files
*/

params.gffread_options = [:]
params.genome_options  = [:]

include {
    GUNZIP as GUNZIP_FASTA
    GUNZIP as GUNZIP_GTF
    GUNZIP as GUNZIP_GFF
    GUNZIP as GUNZIP_GENE_BED
    GUNZIP as GUNZIP_ADDITIONAL_FASTA } from '../process/gunzip'                   addParams( options: params.genome_options  )
include { GTF2BED                     } from '../process/gtf2bed'                  addParams( options: params.genome_options  )
include { CAT_ADDITIONAL_FASTA        } from '../process/cat_additional_fasta'     addParams( options: params.genome_options  )
include { GFFREAD                     } from '../../nf-core/software/gffread/main' addParams( options: params.gffread_options )

workflow PREPARE_GENOME {
    take:
    fasta            // file: /path/to/genome.fasta
    gtf              // file: /path/to/genome.gtf
    gff              // file: /path/to/genome.gff
    gene_bed         // file: /path/to/gene.bed
    additional_fasta // file: /path/to/additional.fasta

    main:
    /*
     * Uncompress genome fasta file if required
     */
    if (fasta.endsWith('.gz')) {
        ch_fasta = GUNZIP_FASTA ( fasta ).gunzip
    } else {
        ch_fasta = file(fasta)
    }

    /*
     * Uncompress GTF annotation file or create from GFF3 if required
     */
    gffread_version = Channel.empty()
    if (gtf) {
        if (gtf.endsWith('.gz')) {
            ch_gtf = GUNZIP_GTF ( gtf ).gunzip
        } else {
            ch_gtf = file(gtf)
        }
    } else if (gff) {
        if (gff.endsWith('.gz')) {
            ch_gff = GUNZIP_GFF ( gff ).gunzip
        } else {
            ch_gff = file(gff)
        }
        ch_gtf = GFFREAD ( ch_gff ).gtf
        gffread_version = GFFREAD.out.version
    }

    /*
     * Uncompress additional fasta file and concatenate with reference fasta and gtf files
     */
    if (additional_fasta) {
        if (additional_fasta.endsWith('.gz')) {
            ch_add_fasta = GUNZIP_ADDITIONAL_FASTA ( additional_fasta ).gunzip
        } else {
            ch_add_fasta = file(additional_fasta)
        }
        CAT_ADDITIONAL_FASTA ( ch_fasta, ch_gtf, ch_add_fasta )
        ch_fasta = CAT_ADDITIONAL_FASTA.out.fasta
        ch_gtf   = CAT_ADDITIONAL_FASTA.out.gtf
    }

    /*
     * Uncompress gene BED annotation file or create from GTF if required
     */
    if (gene_bed) {
        if (gene_bed.endsWith('.gz')) {
            ch_gene_bed = GUNZIP_GENE_BED ( gene_bed ).gunzip
        } else {
            ch_gene_bed = file(gene_bed)
        }
    } else {
        ch_gene_bed = GTF2BED ( ch_gtf )
    }

    emit:
    fasta           = ch_fasta     // path: genome.fasta
    gtf             = ch_gtf       // path: genome.gtf
    gene_bed        = ch_gene_bed  // path: gene.bed
    gffread_version                // path: *.version.txt
}
