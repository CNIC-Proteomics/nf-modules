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

workflow CREATE_INPUT_CHANNEL_SHIFTS {
    main:

    // stop from the missing parameters
    def requiredParams = ['re_files','exp_table']
    printErrorMissingParams(params, requiredParams)

    // create channels from input files
    re_files        = Channel.fromPath("${params.re_files}", checkIfExists: true)
    exp_table       = Channel.fromPath("${params.exp_table}", checkIfExists: true)

    // update the given parameter into the fixed parameter file
    def redefinedParams = []
    def updated_params_str = updateParamsFile(params.params_file, redefinedParams)
    def updated_params_file = writeStrIntoFile(updated_params_str, "${params.paramdir}/params.ini")

    // create channel for params file
    params_file = Channel.value("${updated_params_file}")


    emit:
    ch_re_files         = re_files
    ch_exp_table        = exp_table
    ch_params_file      = params_file
}
