include { samplesheetToList } from 'plugin/nf-schema'

/**
 * Parse the input referencesheet.
 * 
 * Validate and parse the input referencesheet with nf-schema `samplesheetToList`.
 * Wrangles the input reference(s) into the format of channels expected by downstream processes.
 *
 * @take recombination - File object to input recombination maps.
 * @emit List - channel of samples of shape [ metadata, [ recombinationMapPath ] ].
 */

workflow Parse_Recombination_Maps {
    take:
        recombinationMaps
    
    main:
        Channel
            .fromList(samplesheetToList(recombination, "${projectDir}/assets/schema_recombination.json"))
            .map { metaChromosome, recombinationMapPath -> tuple(metaChromosome, recombinationMapPath) }
            .set { ch_recombination_map }
    
    emit:
        recombination_maps = ch_recombination_map
}