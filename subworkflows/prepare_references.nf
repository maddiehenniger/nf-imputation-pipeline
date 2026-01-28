include { bcftools_view_samples              } from "../modules/bcftools_view_samples.nf"

/**
 * Prepares the samples and references for phasing. 
 * 
 * 
 *
 * @take
 *
 * @emit 
 */

 workflow Prepare_References {
    take:
        references
        data_type
        samples

    main:
        switch( data_type.toUpperCase() ) {
            case 'ARRAY':
                prepare_references_array(
                    references
                )
                ch_references = prepare_references_array.out.arrayReferences
                break
            
            case 'LPWGS':
                prepare_references_lpwgs(
                    references
                )
                ch_references = prepare_references_lpwgs.out.lpwgsReferences
                break
        }

        bcftools_identify_chromosomes(
            samples
        )
        ch_chromosomes = bcftools_identify_chromosomes.out.chromosomes
            .readLines()

        bcftools_split_samples(
            samples,
            ch_chromosomes
        )

        ch_split_samples = bcftools_split_samples.out.splitSamples

    emit:
        prepared_references = ch_references
        split_samples = ch_split_samples

 }