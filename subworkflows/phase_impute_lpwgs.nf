/**
 * Workflow 
 * 
 * 
 */

workflow Phase_Impute_Lpwgs {
    take:
        samples_one
        reference_one
        glimpse2Model

    main:
        
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