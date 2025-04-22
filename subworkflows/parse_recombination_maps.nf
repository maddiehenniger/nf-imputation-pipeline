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
            .fromList(samplesheetToList(recombinationMaps, "${projectDir}/assets/schema_recombination.json"))
            .map { metaChromosome, recombinationMapPath -> // Entire line read in here from the input for samplesheetToList()
                   def chromosomeNumber = metaChromosome.chromosomeNum.toInteger() // Converts to integer
                   tuple(chromosomeNumber, recombinationMapPath) // Creates tuple with above values
            }
            .set { ch_recombination_map } // Sets the name of the channel
    
    emit:
        recombination_maps = ch_recombination_map
}