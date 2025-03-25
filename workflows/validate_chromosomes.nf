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
        ch_chromosomes = bcftools_query_references.out.refChromosomes
            .join(bcftools_query_samples.out.sampleChromosomes)

    emit:
        chromosomes           = ch_chromosomes
        sample_chromosomes    = bcftools_query_samples.out.sampleChromosomes
        reference_chromosomes = bcftools_query_references.out.refChromosomes
}