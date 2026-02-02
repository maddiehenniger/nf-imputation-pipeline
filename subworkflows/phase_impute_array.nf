include { shapeit5_phase_common } from '../modules/shapeit5/shapeit5_phase_common.nf'
include { imp5chunker_chunk_samples } from '../modules/impute5/imp5chunker_chunk_samples.nf'
include { impute5_impute_samples } from '../modules/impute5/impute5_impute_samples.nf'
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
        shapeit5_phase_common(
            split_samples
        )
        ch_phased_samples = shapeit5_phase_common.out.phasedSamples
        
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

        // // Perform imputation with IMPUTE5
        // impute5_impute_samples(
        //     ch_chunked_regions
        // )
        // ch_imputed_samples = impute5_impute_samples.out.imputedSamples

        // Ligate samples back together, per chromosome

        // 

    emit:
        phasedSamples    = ch_phased_samples
        phasedSamplesTwo = ch_phased_two
}