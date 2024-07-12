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
    joinChannelsFromFilename;
    updateParamsFile;
    writeStrIntoFile;
    mergeIniFiles
} from '../lib/Utils'


/*
========================================================================================
    DEFINED WORKFLOWS
========================================================================================
*/

workflow CREATE_INPUT_CHANNEL_REFRAG {
    main:

    // stop from the missing parameters
    def requiredParams = ['raw_files','msf_files','dm_file','decoy_prefix']
    printErrorMissingParams(params, requiredParams)

    // create channels from input files
    raw_files = Channel.fromPath("${params.raw_files}", checkIfExists: true)
    msf_files = Channel.fromPath("${params.msf_files}", checkIfExists: true)
    // join two channels based on the file name
    msf_raw_files = joinChannelsFromFilename(raw_files, msf_files)

    // these files will be used multiple times; So, we have to create a Value Channel and then, check if file exists
    File file = new File("${params.dm_file}")
    if ( file.exists() ) {
        dm_file = Channel.value("${params.dm_file}")
    } else { exit 1, "ERROR: The 'dm_file' file does not exist" }

    // update the given parameter into the fixed parameter file
    def redefinedParams = ['decoyprefix': params.decoy_prefix, 'decoy_prefix': params.decoy_prefix]
    def updated_params_str = updateParamsFile(params.fixed_params_file, redefinedParams)
    def fixed_params_file = writeStrIntoFile(updated_params_str, "${params.paramdir}/params.ini")

    // merge the files that contain both the fixed parametes and the variable parameters
    def merged_params_str = mergeIniFiles(fixed_params_file, params.params_file)
    def updated_params_file = writeStrIntoFile(merged_params_str, "${params.paramdir}/params.ini")

    // // update the given parameter into the fixed parameter file
    // def redefinedParams = ['decoy_prefix': params.decoy_prefix]
    // def updated_params_str = updateParamsFile(params.params_file, redefinedParams)
    // def updated_params_file = writeStrIntoFile(updated_params_str, "${params.paramdir}/params.ini")

    // create channel for params file
    // these files will be used multiple times; So, we have to create a Value Channel and then, check if file exists
    params_file = Channel.value("${updated_params_file}")

    emit:
    ch_msf_raw_files  = msf_raw_files
    ch_dm_file        = dm_file
    ch_params_file    = params_file
}
