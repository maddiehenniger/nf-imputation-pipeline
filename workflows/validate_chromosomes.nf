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
        bcftools_query_references(references)

    emit:
        sample_chromosomes    = bcftools_query_samples.out.sampleChromosomes
        reference_chromosomes = bcftools_query_references.out.refChromosomes
}