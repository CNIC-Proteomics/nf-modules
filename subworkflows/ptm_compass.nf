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
    copyFileToFolder;
    updateParamsFile;
    writeStrIntoFile;
    mergeIniFiles
} from '../lib/Utils'


/*
========================================================================================
    DEFINED WORKFLOWS
========================================================================================
*/

workflow CREATE_INPUT_CHANNEL_PTMCOMPASS {
    main:

    // stop from the missing parameters
    def requiredParams = ['msf_files','exp_table','database','sitelist_file','groupmaker_file','decoy_prefix']
    printErrorMissingParams(params, requiredParams)

    // create channels from input files
    msf_files = Channel.fromPath("${params.msf_files}", checkIfExists: true)

    // create channels from input files
    exp_table       = Channel.fromPath("${params.exp_table}", checkIfExists: true)
    // database        = Channel.fromPath("${params.database}", checkIfExists: true)
    sitelist_file   = Channel.fromPath("${params.sitelist_file}", checkIfExists: true)
    // groupmaker_file = Channel.fromPath("${params.groupmaker_file}", checkIfExists: true)
    peak_file       = file("${params.peak_file}", checkIfExists: true)
    // these files will be used multiple times; So, we have to create a Value Channel and then, check if file exists
    File file_db = new File("${params.database}")
    if (!file_db.isAbsolute()) { file_db = file_db.getCanonicalFile() }
    if ( file_db.exists() ) {
        database = Channel.value(file_db.getAbsolutePath())
    } else { exit 1, "ERROR: The 'database' file does not exist" }
    File file_gm = new File("${params.groupmaker_file}")
    if (!file_gm.isAbsolute()) { file_gm = file_gm.getCanonicalFile() }
    if ( file_gm.exists() ) {
        groupmaker_file = Channel.value(file_gm.getAbsolutePath())
    } else { exit 1, "ERROR: The 'groupmaker_file' file does not exist" }

    // update the given parameter into the fixed parameter file
    def redefinedParams = ['decoyprefix': params.decoy_prefix, 'decoy_prefix': params.decoy_prefix]
    def updated_params_str = updateParamsFile(params.fixed_msfragger_params_file, redefinedParams)
    def fixed_params_file = writeStrIntoFile(updated_params_str, "${params.paramdir}/params.ini")

    // merge the files that contain both the fixed parametes and the variable parameters
    def merged_params_str = mergeIniFiles(fixed_params_file, params.params_file)
    def updated_params_file = writeStrIntoFile(merged_params_str, "${params.paramdir}/params.ini")

    // create channel for params file
    // these files will be used multiple times; So, we have to create a Value Channel and then, check if file exists
    params_file = Channel.value("${updated_params_file}")

    // copy input files into params directory
    copyFileToFolder("${params.exp_table}", "${params.paramdir}/")
    copyFileToFolder("${params.database}", "${params.paramdir}/")
    copyFileToFolder("${params.sitelist_file}", "${params.paramdir}/")
    copyFileToFolder("${params.groupmaker_file}", "${params.paramdir}/")


    emit:
    ch_msf_files        = msf_files
    ch_exp_table        = exp_table
    ch_database         = database
    ch_sitelist_file    = sitelist_file
    ch_groupmaker_file  = groupmaker_file
    ch_peak_file        = peak_file
    ch_params_file      = params_file
}

workflow CREATE_INPUT_CHANNEL_PTMCOMPASS_REFMOD {
    main:

    // stop from the missing parameters
    def requiredParams = ['raw_files','msf_files','dm_file','exp_table','database','decoy_prefix']
    printErrorMissingParams(params, requiredParams)

    // create channels from input files
    raw_files = Channel.fromPath("${params.raw_files}", checkIfExists: true)
    msf_files = Channel.fromPath("${params.msf_files}", checkIfExists: true)
    // join two channels based on the file name
    msf_raw_files = joinChannelsFromFilename(raw_files, msf_files)

    // these files will be used multiple times; So, we have to create a Value Channel and then, check if file exists
    File file_dm = new File("${params.dm_file}")
    if (!file_dm.isAbsolute()) { file_dm = file_dm.getCanonicalFile() }
    if ( file_dm.exists() ) {
        dm_file = Channel.value(file_dm.getAbsolutePath())
    } else { exit 1, "ERROR: The 'dm_file' file does not exist" }

    // create channels from input files
    exp_table       = Channel.fromPath("${params.exp_table}", checkIfExists: true)
    // database        = Channel.fromPath("${params.database}", checkIfExists: true)
    sitelist_file   = Channel.fromPath("${params.sitelist_file}", checkIfExists: true)
    // groupmaker_file = Channel.fromPath("${params.groupmaker_file}", checkIfExists: true)
    // these files will be used multiple times; So, we have to create a Value Channel and then, check if file exists
    File file_db = new File("${params.database}")
    if (!file_db.isAbsolute()) { file_db = file_db.getCanonicalFile() }
    if ( file_db.exists() ) {
        database = Channel.value(file_db.getAbsolutePath())
    } else { exit 1, "ERROR: The 'database' file does not exist" }
    File file_gm = new File("${params.groupmaker_file}")
    if (!file_gm.isAbsolute()) { file_gm = file_gm.getCanonicalFile() }
    if ( file_gm.exists() ) {
        groupmaker_file = Channel.value(file_gm.getAbsolutePath())
    } else { exit 1, "ERROR: The 'groupmaker_file' file does not exist" }

    // update the given parameter into the fixed parameter file
    def redefinedParams = ['decoyprefix': params.decoy_prefix, 'decoy_prefix': params.decoy_prefix]
    def updated_params_str = updateParamsFile(params.fixed_msfragger_params_file, redefinedParams)
    def fixed_params_file = writeStrIntoFile(updated_params_str, "${params.paramdir}/params.ini")

    // merge the files that contain both the fixed parametes and the variable parameters
    def merged_params_str = mergeIniFiles(fixed_params_file, params.params_file)
    def updated_params_file = writeStrIntoFile(merged_params_str, "${params.paramdir}/params.ini")

    // create channel for params file
    // these files will be used multiple times; So, we have to create a Value Channel and then, check if file exists
    params_file = Channel.value("${updated_params_file}")

    // copy input files into params directory
    copyFileToFolder("${params.exp_table}", "${params.paramdir}/")
    copyFileToFolder("${params.database}", "${params.paramdir}/")
    copyFileToFolder("${params.sitelist_file}", "${params.paramdir}/")
    copyFileToFolder("${params.groupmaker_file}", "${params.paramdir}/")
    copyFileToFolder("${params.dm_file}", "${params.paramdir}/")


    emit:
    ch_msf_raw_files    = msf_raw_files
    ch_dm_file          = dm_file
    ch_exp_table        = exp_table
    ch_database         = database
    ch_sitelist_file    = sitelist_file
    ch_groupmaker_file  = groupmaker_file
    ch_params_file      = params_file
}

workflow CREATE_INPUT_CHANNEL_PTMCOMPASS_RECOM {
    main:

    // stop from the missing parameters
    def requiredParams = [['refmod_files','recom_files'],'exp_table','database','decoy_prefix']
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
    // database        = Channel.fromPath("${params.database}", checkIfExists: true)
    sitelist_file   = Channel.fromPath("${params.sitelist_file}", checkIfExists: true)
    // groupmaker_file = Channel.fromPath("${params.groupmaker_file}", checkIfExists: true)
    // these files will be used multiple times; So, we have to create a Value Channel and then, check if file exists
    File file_db = new File("${params.database}")
    if (!file_db.isAbsolute()) { file_db = file_db.getCanonicalFile() }
    if ( file_db.exists() ) {
        database = Channel.value(file_db.getAbsolutePath())
    } else { exit 1, "ERROR: The 'database' file does not exist" }
    File file_gm = new File("${params.groupmaker_file}")
    if (!file_gm.isAbsolute()) { file_gm = file_gm.getCanonicalFile() }
    if ( file_gm.exists() ) {
        groupmaker_file = Channel.value(file_gm.getAbsolutePath())
    } else { exit 1, "ERROR: The 'groupmaker_file' file does not exist" }

    // update the given parameter into the fixed parameter file
    def redefinedParams = ['decoyprefix': params.decoy_prefix, 'decoy_prefix': params.decoy_prefix]
    def updated_params_str = updateParamsFile(fixed_method_params_file, redefinedParams)
    def fixed_params_file = writeStrIntoFile(updated_params_str, "${params.paramdir}/params.ini")

    // merge the files that contain both the fixed parametes and the variable parameters
    def merged_params_str = mergeIniFiles(fixed_params_file, params.params_file)
    def updated_params_file = writeStrIntoFile(merged_params_str, "${params.paramdir}/params.ini")

    // create channel for params file
    // these files will be used multiple times; So, we have to create a Value Channel and then, check if file exists
    params_file = Channel.value("${updated_params_file}")

    // copy input files into params directory
    copyFileToFolder("${params.exp_table}", "${params.paramdir}/")
    copyFileToFolder("${params.database}", "${params.paramdir}/")
    copyFileToFolder("${params.sitelist_file}", "${params.paramdir}/")
    copyFileToFolder("${params.groupmaker_file}", "${params.paramdir}/")


    emit:
    ch_re_files         = re_files
    ch_exp_table        = exp_table
    ch_database         = database
    ch_sitelist_file    = sitelist_file
    ch_groupmaker_file  = groupmaker_file
    ch_params_file      = params_file
}
