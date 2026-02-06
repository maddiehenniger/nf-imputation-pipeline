include { bcftools_index_phased } from '../modules/shapeit5/bcftools_index_phased.nf'
include { bcftools_ligate_chromosomes } from '../modules/impute5/bcftools_ligate_chromosomes.nf'
include { shapeit5_phase_common_noref } from '../modules/shapeit5/shapeit5_phase_common_noref.nf'
include { shapeit5_phase_common_reference } from '../modules/shapeit5/shapeit5_phase_common_reference.nf'
include { shapeit4_phase_common_noref } from '../modules/shapeit5/shapeit4_phase_common_noref.nf'
include { imp5chunker_chunk_samples } from '../modules/impute5/imp5chunker_chunk_samples.nf'
include { imp5chunker_chunk_samples as imp5chunker_chunk_samples_again } from '../modules/impute5/imp5chunker_chunk_samples.nf'
include { impute5_impute_samples } from '../modules/impute5/impute5_impute_samples.nf'
include { impute5_impute_samples as impute5_impute_samples_again } from '../modules/impute5/impute5_impute_samples.nf'

/**
 * Workflow to phase test samples using SHAPEIT5, identify imputation and buffer regions on a chromosome-by-chromosome basis, and then perform imputation using IMPUTE5.
 * 
 * 
 */

workflow Phase_Impute_Array {
    take:
        samples_one
        reference_one
        reference_two
        phasingModel

    main:
        // Phase samples to the reference defined as round 'one'
        switch( phasingModel.toUpperCase() ) {
            // If the SHAPEIT5 phasing model is defined to use the reference panel for informing priors for phasing, the 'one' reference panel will be used for phasing
            case 'USE_REFERENCE':
                shapeit5_phase_common_reference(
                    samples_one
                 )
                ch_phased_samples = shapeit5_phase_common_reference.out.phasedSamples
            break

            // If the SHAPEIT5 phasingModel is defined to use no reference for informing priors for phasing, no reference will be used for phasing
            case 'NO_REFERENCE':
                shapeit5_phase_common_noref(
                    samples_one
                 )
                ch_phased_samples = shapeit5_phase_common_noref.out.phasedSamples
            break

            // Performed if the SHAPEIT phasingModel indicates to use SHAPEIT4 to perform sample phasing without using a reference (for cases in <50 individuals) - use at your own risk!
            case 'SHAPEIT4_NO_REFERENCE':
                shapeit4_phase_common_noref(
                    samples_one
                 )
                ch_phased_noidx = shapeit4_phase_common_noref.out.phasedSamples

                // SHAPEIT4 doesn't automatically index, so we have to index the files here
                bcftools_index_phased(
                    ch_phased_noidx
                )
                ch_phased_samples = bcftools_index_phased.out.phasedSamples
            break
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
        bcftools_ligate_chromosomes(
            ch_imputed_samples
        )
        ch_ligated_samples = bcftools_ligate_chromosomes.out.ligatedByChr
        
        // If round two exists, the imputation steps will be performed again, including chunking, imputing, and ligating
        ch_ligated_two = ch_ligated_samples.combine(reference_two, by:0)
            .map { chr, sampleMetadata, imputedSample, imputedSampleIndex, wgs, wgsIndex, referenceMetadata, reference, referenceIndices, geneticMap ->
                tuple(chr, sampleMetadata, phasedSample, phasedIndex, referenceMetadata, reference, referenceIndices, geneticMap)
            }

        // ROUND TWO: Chunk samples again to the reference panel declared as round 'two'
        imp5chunker_chunk_samples_again(
            ch_ligated_two
        )
        ch_chunked_regions_two = imp5chunker_chunk_samples_again.out.chunkedRegions
        
        // ROUND TWO: Impute the first-round imputed samples again to the reference panel declared as round 'two'
        impute5_impute_samples_again(
            ch_chunked_regions_two
        )
        ch_imputed_two = impute5_impute_samples_again.out.imputedSamples

        // ROUND TWO: Ligate the two-round imputed samples by chromosome
        bcftools_ligate_chromosomes_again(
            ch_imputed_two
        )
        ch_ligated_two = bcftools_ligate_chromosomes_again.out.ligatedByChr

    emit:
        // phasedSamples    = ch_phased_samples // Testing
        // phasedSamplesTwo = ch_phased_two // Testing
        ligatedSamples = ch_ligated_samples
        ligatedSamplesTwo = ch_ligated_two
}