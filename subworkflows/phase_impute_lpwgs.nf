include { glimpse2_phase } from '../modules/glimpse2/glimpse2_phase.nf'
/**
 * Workflow to phase and impute lcWGS data.
 * 
 * 
 */

workflow Phase_Impute_Lpwgs {
    
    take:
        samples_one
        fasta_reference

    main:

        // Create a list of bams
        samples_one
            .map { samplePath -> samplePath.name } // Extract samplePath (3rd element)
            .collectFile(name: 'samples.txt', newLine: true)
            .set { ch_bam_list }

        // Add the list file to the channel
        ch_glimpse2_input = samples_one.combine(ch_bam_list)

        // Phase and impute samples using GLIMPSE2
        glimpse2_phase(
            ch_glimpse2_input,
            fasta_reference
        )
        ch_imputed_samples = glimpse2_phase.out.imputedSamples

        // Index the imputed samples?
        

    emit:
        imputedSamples = ch_imputed_samples
}