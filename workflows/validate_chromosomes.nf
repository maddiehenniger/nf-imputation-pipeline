include { bcftools_query } from '../modules/bcftools_query.nf'

/**
 * Workflow
 * 
 * 
 */

workflow VALIDATE_CHROMOSOMES {
    take:
        samples
    
    main:
        bcftools_query(samples)

    emit:
        sample_chromosomes = bcftools_query.out.sampleChromosomes
}