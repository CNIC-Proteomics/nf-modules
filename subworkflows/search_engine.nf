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
    copyFileToFolder("${params.database}", "${params.paramdir}/") // copy input file into params directory

    // create channel for params file
    // update the given parameter into the fixed parameter file
    def redefinedParams = ['database_name': getAbsolutePath("${params.database}"), 'decoy_prefix': params.decoy_prefix, 'output_format': params.msf_output_format, 'num_threads': 0]
    def updated_params_str = updateParamsFile(params.msf_params_file, redefinedParams)
    def updated_params_file = writeStrIntoFile(updated_params_str, "${params.paramdir}/msfragger.params") // create file into params directory
    msf_param_file = Channel.value("${updated_params_file}")

    // create channels from input files
    // this file will be used multiple times, so, it is why the variable changes to file
    reporter_ion_isotopic = file("${params.NO_FILE}", checkIfExists: true)
    if ( params.containsKey('reporter_ion_isotopic') ) {
        reporter_ion_isotopic_str = getAbsolutePath("${params.reporter_ion_isotopic}")
        reporter_ion_isotopic = file("${reporter_ion_isotopic_str}", checkIfExists: true)
        copyFileToFolder("${params.reporter_ion_isotopic}", "${params.paramdir}/") // copy input file into params directory
    }

    // create channels from input files
    // this file will be used multiple times, so, it is why the variable changes to file
    dm_file = file("${params.NO_FILE}", checkIfExists: true)
    if ( params.containsKey('dm_file') ) {
        dm_file_str = getAbsolutePath("${params.dm_file}")
        dm_file = file("${dm_file_str}", checkIfExists: true)
        copyFileToFolder("${params.dm_file}", "${params.paramdir}/") // copy input file into params directory
    }

    // create channels from input files
    // this file will be used multiple times, so, it is why the variable changes to file
    refmod_param_file = file("${params.NO_FILE}", checkIfExists: true)
    if ( params.containsKey('refmod_params_file') ) {
        // update the given parameter into the fixed parameter file
        def redefinedReParams_refmod = ['decoy_prefix': params.decoy_prefix]
        def updated_params_str_refmod = updateParamsFile(params.refmod_params_file, redefinedReParams_refmod)
        def updated_params_file_refmod = writeStrIntoFile(updated_params_str_refmod, "${params.paramdir}/refmod.params") // create file into params directory
        refmod_param_file = file("${updated_params_file_refmod}", checkIfExists: true)
    }
    
    emit:
    ch_raws                   = raw_files
    ch_database               = database
    ch_msf_param_file         = msf_param_file
    ch_dm_file                = dm_file
    ch_refmod_param_file      = refmod_param_file
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
    // this file will be used multiple times, so, it is why the variable changes to file
    reporter_ion_isotopic = file("${params.NO_FILE}", checkIfExists: true)
    if ( params.containsKey('reporter_ion_isotopic') ) {
        reporter_ion_isotopic_str = getAbsolutePath("${params.reporter_ion_isotopic}")
        reporter_ion_isotopic = file("${reporter_ion_isotopic_str}", checkIfExists: true)
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
    // this file will be used multiple times, so, it is why the variable changes to file
    reporter_ion_isotopic = file("${params.NO_FILE}", checkIfExists: true)
    if ( params.containsKey('reporter_ion_isotopic') ) {
        reporter_ion_isotopic_str = getAbsolutePath("${params.reporter_ion_isotopic}")
        reporter_ion_isotopic = file("${reporter_ion_isotopic_str}", checkIfExists: true)
    }
    else {
        exit 1, "ERROR: The 'reporter_ion_isotopic' file does not exist"
    }
    
    emit:
    ch_reporter_ion_isotopic       = reporter_ion_isotopic
}
