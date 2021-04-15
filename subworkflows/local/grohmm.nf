/*
 * TODO
 */

params.makeucscfile_options         = [:] // Collapses both strands, used as default value
params.transcriptcalling_options    = [:]
params.picard_mergesamfiles_options = [:]
params.parametertuning_options      = [:]

include { GROHMM_MAKEUCSCFILE      } from '../../modules/local/grohmm/makeucscfile/main.nf'      addParams( options: params.makeucscfile_options  )
include { GROHMM_TRANSCRIPTCALLING } from '../../modules/local/grohmm/transcriptcalling/main.nf' addParams( options: params.transcriptcalling_options )
include { PICARD_MERGESAMFILES     } from '../../modules/nf-core/software/picard/mergesamfiles/main'        addParams( options: picard_mergesamfiles_options )
include { GROHMM_PARAMETERTUNING   } from '../../modules/local/grohmm/parametertuning/main.nf'   addParams( options: params.parametertuning_options )


/*
 * Note meta refers to all merged files
 */
workflow GROHMM {
    take:
    bam // channel: [ val(meta), [ bam ] ]

    main:
    bam
        .map {
            meta, bam ->
            fmeta = meta.findAll { it.key != 'read_group' }
            fmeta.id = "meta"
            [ fmeta, bam ] }
        .groupTuple(by: [0])
        .map { it ->  [ it[0], it[1].flatten() ] }
        .set { meta_bam }

    PICARD_MERGESAMFILES (
        meta_bam
    )

    // Generate UCSC files
    GROHMM_MAKEUCSCFILE ( PICARD_MERGESAMFILES.out.bam )
    // Run Meta
    GROHMM_TRANSCRIPTCALLING ( PICARD_MERGESAMFILES.out.bam )

    emit:
    transcripts = GROHMM_TRANSCRIPTCALLING.out.transcripts
    bed         = GROHMM_TRANSCRIPTCALLING.out.transcripts_bed
    wig         = GROHMM_MAKEUCSCFILE.out.wig
    plus_wig    = GROHMM_MAKEUCSCFILE.out.minuswig
    minus_wig   = GROHMM_MAKEUCSCFILE.out.pluswig
}

