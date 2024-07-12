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
    def requiredParams = [['refmod_files','recom_files'],'exp_table']
    printErrorMissingParams(params, requiredParams)

    // create channels from input files. By default, msfragger
    def fixed_method_params_file = params.fixed_msfragger_params_file
    if ( params.containsKey('refmod_files') ) {
        re_files = Channel.fromPath("${params.refmod_files}", checkIfExists: true)
        fixed_method_params_file = params.fixed_msfragger_params_file
    } else if ( params.containsKey('recom_files') ) {
        re_files = Channel.fromPath("${params.recom_files}", checkIfExists: true)
        fixed_method_params_file = params.fixed_comet_params_file
    }    
    exp_table       = Channel.fromPath("${params.exp_table}", checkIfExists: true)

    // update the given parameter into the fixed parameter file
    def redefinedParams = []
    def updated_params_str = updateParamsFile(fixed_method_params_file, redefinedParams)
    def fixed_params_file = writeStrIntoFile(updated_params_str, "${params.paramdir}/params.ini")

    // merge the files that contain both the fixed parametes and the variable parameters
    def merged_params_str = mergeIniFiles(fixed_params_file, params.params_file)
    def updated_params_file = writeStrIntoFile(merged_params_str, "${params.paramdir}/params.ini")

    // create channel for params file
    // these files will be used multiple times; So, we have to create a Value Channel and then, check if file exists
    params_file = Channel.value("${updated_params_file}")


    emit:
    ch_re_files         = re_files
    ch_exp_table        = exp_table
    ch_params_file      = params_file
}

// workflow CREATE_INPUT_CHANNEL_SHIFTS {
//     main:

//     // stop from the missing parameters
//     def requiredParams = ['re_files','exp_table']
//     printErrorMissingParams(params, requiredParams)

//     // create channels from input files
//     re_files        = Channel.fromPath("${params.re_files}", checkIfExists: true)
//     exp_table       = Channel.fromPath("${params.exp_table}", checkIfExists: true)

//     // update the given parameter into the fixed parameter file
//     def redefinedParams = []
//     def updated_params_str = updateParamsFile(params.params_file, redefinedParams)
//     def updated_params_file = writeStrIntoFile(updated_params_str, "${params.paramdir}/params.ini")

//     // create channel for params file
//     params_file = Channel.value("${updated_params_file}")


//     emit:
//     ch_re_files         = re_files
//     ch_exp_table        = exp_table
//     ch_params_file      = params_file
// }
