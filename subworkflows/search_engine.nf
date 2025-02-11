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
    raw_files = Channel.fromPath("${params.raw_files}", checkIfExists: true)
    database = Channel.fromPath("${params.database}", checkIfExists: true)

    // update the given parameter into the fixed parameter file
    def redefinedParams = ['database_name': getAbsolutePath("${params.database}"), 'decoy_prefix': params.decoy_prefix, 'output_format': params.msf_output_format, 'num_threads': 0]
    def updated_params_str = updateParamsFile(params.msf_params_file, redefinedParams)
    def updated_params_file = writeStrIntoFile(updated_params_str, "${params.paramdir}/msfragger.params")

    // create channel for params file
    msf_param_file = Channel.value("${updated_params_file}")

    // create channels from input files
    // this file will be used multiple times, so, we have to create a Value Channel and then, check if file exists
    if ( params.containsKey('reporter_ion_isotopic') ) {
        def reporter_ion_isotopic_str = getAbsolutePath("${params.reporter_ion_isotopic}")
        reporter_ion_isotopic = file("${reporter_ion_isotopic_str}", checkIfExists: true)
    }
    else {
        reporter_ion_isotopic = ""
    }

    // copy input files into params directory
    copyFileToFolder("${params.database}", "${params.paramdir}/")

    emit:
    ch_raws                   = raw_files
    ch_database               = database
    ch_msf_param_file         = msf_param_file
    ch_reporter_ion_isotopic  = reporter_ion_isotopic
}

workflow CREATE_INPUT_CHANNEL_DECOYPYRAT {
    main:

    // stop from the missing parameters
    def requiredParams = ['database']
    printErrorMissingParams(params, requiredParams)

    // create channels from input files
    database = Channel.fromPath("${params.database}", checkIfExists: true)

    emit:
    ch_database       = database
}

workflow CREATE_INPUT_CHANNEL_THERMORAWPARSER {
    main:

    // stop from the missing parameters
    def requiredParams = ['raw_files']
    printErrorMissingParams(params, requiredParams)

    // create channels from input files
    raw_files = Channel.fromPath("${params.raw_files}", checkIfExists: true)

    emit:
    ch_raws           = raw_files
}

workflow CREATE_INPUT_CHANNEL_MSFRAGGER {
    main:

    // stop from the missing parameters
    def requiredParams = ['raw_files','database','msf_params_file']
    printErrorMissingParams(params, requiredParams)

    // create channels from input files
    raw_files = Channel.fromPath("${params.raw_files}", checkIfExists: true)
    database = Channel.fromPath("${params.database}", checkIfExists: true)
    msf_param_file = Channel.fromPath("${params.msf_params_file}", checkIfExists: true)

    emit:
    ch_raws           = raw_files
    ch_database       = database
    ch_msf_param_file = msf_param_file
}

workflow CREATE_INPUT_CHANNEL_MSFRAGGERADAPTED {
    main:

    // stop from the missing parameters
    def requiredParams = ['mz_files','msf_files']
    printErrorMissingParams(params, requiredParams)

    // create channels from input files
    mz_files = Channel.fromPath("${params.mz_files}", checkIfExists: true)
    msf_files = Channel.fromPath("${params.msf_files}", checkIfExists: true)

    // create channels from input files
    // this file will be used multiple times, so, we have to create a Value Channel and then, check if file exists
    if ( params.containsKey('reporter_ion_isotopic') ) {
        def reporter_ion_isotopic_str = getAbsolutePath("${params.reporter_ion_isotopic}")
        reporter_ion_isotopic = file("${reporter_ion_isotopic_str}", checkIfExists: true)
    }
    else {
        reporter_ion_isotopic = ""
    }

    emit:
    ch_mz_files                 = mz_files
    ch_msf_files                = msf_files
    ch_reporter_ion_isotopic    = reporter_ion_isotopic
}

workflow CREATE_INPUT_CHANNEL_MZEXTRACTOR {
    main:

    // stop from the missing parameters
    def requiredParams = ['reporter_ion_isotopic']
    printErrorMissingParams(params, requiredParams)

    // create channels from input files
    // this file will be used multiple times, so, we have to create a Value Channel and then, check if file exists
    def reporter_ion_isotopic_str = getAbsolutePath("${params.reporter_ion_isotopic}")
    File file = new File(reporter_ion_isotopic_str)
    if ( file.exists() ) {
        reporter_ion_isotopic = Channel.value(reporter_ion_isotopic_str)
    }
    else {
        exit 1, "ERROR: The 'reporter_ion_isotopic' file does not exist"
    }
    
    emit:
    ch_reporter_ion_isotopic       = reporter_ion_isotopic
}
