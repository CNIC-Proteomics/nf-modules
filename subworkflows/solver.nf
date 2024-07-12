//
// Create channel for input files
//


/*
========================================================================================
    IMPORT MODULES
========================================================================================
*/

import org.yaml.snakeyaml.Yaml

include {
    printErrorMissingParams;
    updateParamsFile;
    writeStrIntoFile;
    mergeIniFiles
} from '../lib/Utils'


/*
========================================================================================
    DEFINED WORKFLOWS
========================================================================================
*/

workflow CREATE_INPUT_CHANNEL_SOLVER {
    main:

    // stop from the missing parameters
    def requiredParams = ['peak_fdr','apex_list','database','decoy_prefix']
    printErrorMissingParams(params, requiredParams)

    // create channels from input files
    peak_fdr        = Channel.fromPath("${params.peak_fdr}", checkIfExists: true)
    apex_list       = Channel.fromPath("${params.apex_list}", checkIfExists: true)
    database        = Channel.fromPath("${params.database}", checkIfExists: true)
    sitelist_file   = Channel.fromPath("${params.sitelist_file}", checkIfExists: true)
    groupmaker_file = Channel.fromPath("${params.groupmaker_file}", checkIfExists: true)

    // update the given parameter into the fixed parameter file
    def redefinedParams = ['decoy_prefix': params.decoy_prefix]
    def updated_params_str = updateParamsFile(params.params_file, redefinedParams)
    def updated_params_file = writeStrIntoFile(updated_params_str, "${params.paramdir}/params.ini")

    // create channel for params file
    params_file = Channel.value("${updated_params_file}")


    emit:
    ch_peakfdr_file     = peak_fdr
    ch_apexlist_file    = apex_list
    ch_database         = database
    ch_sitelist_file    = sitelist_file
    ch_groupmaker_file  = groupmaker_file
    ch_params_file      = params_file
}