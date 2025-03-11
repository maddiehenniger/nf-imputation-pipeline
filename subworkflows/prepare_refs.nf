include { bcftools_index_reference } from '../modules/bcftools_index_reference.nf'

workflow Prepare_Refs {
    take:
        reference

    main:
        ch_reference = Channel.value(file(reference))
        bcftools_index_reference(ch_reference)

    emit:
        reference       = ch_reference
        reference_index = ch_reference_index

}