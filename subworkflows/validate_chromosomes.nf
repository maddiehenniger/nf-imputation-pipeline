include { bcftools_index_samples                          } from '../modules/bcftools_index_samples.nf'
include { bcftools_index_references as index_intermediate } from '../modules/bcftools_index_references.nf'
include { bcftools_index_references as index_twostep      } from '../modules/bcftools_index_references.nf'
include { bcftools_query_samples                          } from '../modules/bcftools_query_samples.nf'
include { bcftools_query_references as query_intermediate } from '../modules/bcftools_query_references.nf'
include { bcftools_query_references as query_twostep      } from '../modules/bcftools_query_references.nf'

/**
 * Index and query the number of chromosomes present in the input VCF/BCF files provided in the user-provided samplesheet and reference(s) files.
 * 
 * Tuples the VCF/BCF file and associated index together for downs
 * Wrangles the input samples into the format of channels expected by downstream processes.
 *
 * @take samples, references - A LinkedHashMap containing the metadata, file path to VCF/BCF, and file path to the associated indexed VCF/BCF file. 
 * @emit chromosomes - chromosome numbers present in a respective file.
 **/

workflow Validate_Chromosomes {
    take:
        samples
        reference_intermediate
        reference_twostep
    
    main:         
        // Index the input samples using bcftools index
        bcftools_index_samples(
            samples
        )

        // Index the references using bcftools index
        // ...the intermediate reference...
        index_intermediate(
            reference_intermediate
        )
        // ..the twostep reference...
        index_twostep(
            reference_twostep
        )
        // The outputs from indexing to be used to query chromosomes present in each file
        samples_idx      = bcftools_index_samples.out.indexedPair
        intermediate_idx = index_intermediate.out.indexedPair
        twostep_idx      = index_twostep.out.indexedPair

        // Identify the chromosomes present in the input samples using bcftools query
        bcftools_query_samples(
            samples_idx
        )
        // The output of the chromosomes present in the input sample(s)
        samples_chr = bcftools_query_samples.out.chromosomes
            .map {
                it.readLines() // Prints the numbers present in the file
            }

        // Identify the chromosomes present in the reference(s) using bcftools query
        // Query the intermediate reference panel
        query_intermediate(
            intermediate_idx
        )
        intermediate_chr = query_intermediate.out.chromosomes
            .map {
                it.readLines()
            }

        // Query the twostep reference panel
        query_twostep(
            twostep_idx
        )
        twostep_chr = query_twostep.out.chromosomes
            .map {
                it.readLines()
            }

        // Join the intermediate and twostep chromosomes
        references_chr = intermediate_chr
            .join(twostep_chr)
            .unique()

        // Create a channel that consists of only the number of chromosomes to be used downstream
        ch_chromosomes = samples_chr
            .join(references_chr)
            .unique()

    emit:
        samples_idx      = samples_idx
        intermediate_idx = intermediate_idx
        twostep_idx      = twostep_idx
        chromosomes      = ch_chromosomes
}