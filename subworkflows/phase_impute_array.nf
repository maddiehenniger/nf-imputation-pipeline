include { shapeit5_phase_common_noref } from '../modules/shapeit5/shapeit5_phase_common_noref.nf'
include { shapeit5_phase_common_reference } from '../modules/shapeit5/shapeit5_phase_common_reference.nf'
include { shapeit4_phase_common_noref } from '../modules/shapeit5/shapeit4_phase_common_noref.nf'
include { imp5chunker_chunk_samples } from '../modules/impute5/imp5chunker_chunk_samples.nf'
include { impute5_impute_samples } from '../modules/impute5/impute5_impute_samples.nf'
// include { impute5_impute_samples as impute5_impute_samples_again } from '../modules/impute5/impute5_impute_samples.nf'

/**
 * Workflow to phase test samples using SHAPEIT5, identify imputation and buffer regions on a chromosome-by-chromosome basis, and then perform imputation using IMPUTE5.
 * 
 * 
 */

workflow Phase_Impute_Array {
    take:
        split_samples
        reference_one
        reference_two

    main:
        // Phase samples to the reference defined as round 'one'
        switch( phasingModel.toUpperCase() ) {
            // If the SHAPEIT5 phasing model is defined to use the reference panel for informing priors for phasing, the 'one' reference panel will be used for phasing
            case 'USE_REFERENCE':
                shapeit5_phase_common_reference(
                    split_samples
                 )
                ch_phased_samples = shapeit5_phase_common_reference.out.phasedSamples
            break

            // If the SHAPEIT5 phasingModel is defined to use no reference for informing priors for phasing, no reference will be used for phasing
            case 'NO_REFERENCE':
                shapeit5_phase_common_noref(
                    split_samples
                 )
                ch_phased_samples = shapeit5_phase_common_noref.out.phasedSamples
            break

            // Performed if the SHAPEIT phasingModel indicates to use SHAPEIT4 to perform sample phasing without using a reference (for cases in <50 individuals) - use at your own risk!
            case 'SHAPEIT4_NO_REFERENCE':
                shapeit4_phase_common_noref(
                    split_samples
                 )
                ch_phased_samples = shapeit4_phase_common_noref.out.phasedSamples
            break
        }
        
        // If round two is provided, combine the round two reference files with the test samples by chromosome
        ch_phased_two = ch_phased_samples.combine(reference_two, by:0)
            .map { chr, sampleMetadata, phasedSample, phasedIndex, referenceMetadata, reference, referenceIndices, geneticMap, referenceMetadata2, reference2, referenceIndices2, geneticMap2 ->
                tuple(chr, sampleMetadata, phasedSample, phasedIndex, referenceMetadata, reference2, referenceIndices2, geneticMap2)
            }

        // Identifying imputation and buffer regions
        imp5chunker_chunk_samples(
            ch_phased_samples
        )
        ch_chunked_regions = imp5chunker_chunk_samples.out.chunkedRegions

        // Perform imputation with IMPUTE5
        impute5_impute_samples(
            ch_chunked_regions
        )
        ch_imputed_samples = impute5_impute_samples.out.imputedSamples

        // Ligate samples back together, per chromosome

        // 

    emit:
        phasedSamples    = ch_phased_samples
        phasedSamplesTwo = ch_phased_two
        imputedSamples   = ch_imputed_samples
}