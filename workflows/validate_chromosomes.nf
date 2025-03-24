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
    
    main:
        bcftools_query_samples(samples)

    emit:
        sample_chromosomes    = bcftools_query_samples.out.sampleChromosomes
}