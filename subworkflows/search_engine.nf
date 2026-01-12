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
    copyFileToFolder;
    getAbsolutePath;
    updateParamsFile;
    writeStrIntoFile
} from '../lib/Utils'


/*
========================================================================================
    DEFINED WORKFLOWS
========================================================================================
*/

workflow CREATE_INPUT_CHANNEL_SEARCH_ENGINE {
    main:

    // stop from the missing parameters
    def requiredParams = ['raw_files','database','msf_params_file']
    printErrorMissingParams(params, requiredParams)

    // create channels from input files
    ch_raw_files = Channel.fromPath("${params.raw_files}", checkIfExists: true)
    ch_database = Channel.fromPath("${params.database}", checkIfExists: true)
    copyFileToFolder("${params.database}", "${params.paramdir}/") // copy input file into params directory

    // create channel for params file
    // update the given parameter into the fixed parameter file
    def redefinedParams = ['database_name': getAbsolutePath("${params.database}"), 'decoy_prefix': params.decoy_prefix, 'output_format': params.msf_output_format, 'num_threads': 0]
    def updated_params_str = updateParamsFile(params.msf_params_file, redefinedParams)
    def updated_params_file = writeStrIntoFile(updated_params_str, "${params.paramdir}/msfragger.params") // create file into params directory
    ch_msf_param_file = Channel.value("${updated_params_file}")

    // create channels from input files
    // this file will be used multiple times, so, it is why the variable changes to file
    ch_reporter_ion_isotopic = file("${params.NO_FILE}", checkIfExists: true)
    if ( params.containsKey('reporter_ion_isotopic') ) {
        reporter_ion_isotopic_str = getAbsolutePath("${params.reporter_ion_isotopic}")
        ch_reporter_ion_isotopic = file("${reporter_ion_isotopic_str}", checkIfExists: true)
        copyFileToFolder("${params.reporter_ion_isotopic}", "${params.paramdir}/") // copy input file into params directory
    }

    // create channels from input files
    // this file will be used multiple times, so, it is why the variable changes to file
    ch_dm_file = file("${params.NO_FILE}", checkIfExists: true)
    if ( params.containsKey('dm_file') ) {
        dm_file_str = getAbsolutePath("${params.dm_file}")
        ch_dm_file = file("${dm_file_str}", checkIfExists: true)
        copyFileToFolder("${params.dm_file}", "${params.paramdir}/") // copy input file into params directory
    }

    // create channels from input files
    // this file will be used multiple times, so, it is why the variable changes to file
    ch_refmod_param_file = file("${params.NO_FILE}", checkIfExists: true)
    if ( params.containsKey('refmod_params_file') ) {
        // update the given parameter into the fixed parameter file
        def redefinedReParams_refmod = ['decoy_prefix': params.decoy_prefix]
        def updated_params_str_refmod = updateParamsFile(params.refmod_params_file, redefinedReParams_refmod)
        def updated_params_file_refmod = writeStrIntoFile(updated_params_str_refmod, "${params.paramdir}/refmod.params") // create file into params directory
        ch_refmod_param_file = file("${updated_params_file_refmod}", checkIfExists: true)
    }
    
    emit:
    ch_raw_files
    ch_database
    ch_msf_param_file
    ch_dm_file
    ch_refmod_param_file
    ch_reporter_ion_isotopic
}
