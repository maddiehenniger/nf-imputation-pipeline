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
        bcftools_query_samples.out
            .flatMap { meta, samplePath, sampleIdx, chrom_string ->
                def chrom_list = chrom_string.trim().split('\n')
                def chromosomes = chrom_list.collect { chr ->
                    [ meta, samplePath, sampleIdx, chr ]
                }

                return chromosomes
            }
            .set { ch_samples_by_chr }

        // Identify the chromosomes present in the reference(s) using bcftools query
        // Query the intermediate reference panel
        query_intermediate(
            intermediate_idx
        )
        query_intermediate.out
            .flatMap { chrom_string, meta, referencePath, referenceIndex, mapPath ->
                def chrom_list = chrom_string.trim().split('\n')
                def chromosomes = chrom_list.collect { chr ->
                    [ chr, meta, referencePath, referenceIndex, mapPath ]
                }

                return chromosomes
            }
            .set { ch_intermediate_by_chr }

        // Query the twostep reference panel
        query_twostep(
            twostep_idx
        )
        query_twostep.out
            .flatMap { chrom_string, meta, referencePath, referenceIndex, mapPath ->
                def chrom_list = chrom_string.trim().split('\n')
                def chromosomes = chrom_list.collect { chr ->
                    [ chr, meta, referencePath, referenceIndex, mapPath ]
                }

                return chromosomes
            }
            .set { ch_twostep_by_chr }

    emit:
        samples_by_chr      = ch_samples_by_chr
        intermediate_by_chr = ch_intermediate_by_chr
        twostep_by_chr      = ch_twostep_by_chr
}

// //
// // From: https://github.com/nf-core/phaseimpute/blob/dev/workflows/chrcheck/function.nf
// // Check if the contig names in the input files match the reference contig names.
// //
// def checkChr(ch_chr, ch_input){
//     def chr_checked = ch_chr
//         .combine(ch_input, by:0)
//         .map{meta, chr, file, index, lst ->
//             [
//                 meta, file, index,
//                 chr.readLines()*.split(' ').collect{it[0]},
//                 lst
//             ]
//         }
//         .branch{ meta, file, index, chr, lst ->
//             def lst_diff = diffChr(chr, lst, file)
//             def diff = lst_diff[0]
//             def prefix = lst_diff[1]
//             no_rename: diff.size() == 0
//                 return [meta, file, index]
//             to_rename: true
//                 return [meta, file, index, diff, prefix]
//         }
//     return chr_checked
// }