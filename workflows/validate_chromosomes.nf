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
            .map { 
                it.getText()
             }

        bcftools_query_references(references)
        ch_reference_chromosomes = bcftools_query_references.out.refChromosomes
            .map {
                it.getText()
            }
        
        ch_chromosomes = ch_sample_chromosomes
            .join(ch_reference_chromosomes)

    emit:
        sample_chromosomes    = ch_sample_chromosomes
        reference_chromosomes = ch_reference_chromosomes
        chromosomes           = ch_chromosomes
}