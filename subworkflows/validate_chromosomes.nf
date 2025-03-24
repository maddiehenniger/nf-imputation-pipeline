include { bcftools_query_samples    } from '../modules/bcftools_query_samples.nf'
include { bcftools_query_references } from '../modules/bcftools_query_references.nf'

/**
 * Workflow
 * 
 * 
 */

workflow VALIDATE_CHROMOSOMES {
    take:
        samples
        references
    
    main:
        bcftools_query_samples(samples)
        ch_sample_chromosomes = bcftools_query_samples.out.sampleChromosomes

        bcftools_query_references(references)
        ch_reference_chromosomes = bcftools_query_references.out.refChromosomes

        ch_reference_chromosomes = Channel.empty()
            bcftools_query_reference.out.refChromsomes

    emit:
        
}