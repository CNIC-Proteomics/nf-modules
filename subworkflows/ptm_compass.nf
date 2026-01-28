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

    // get the fixed parameter file based on the type of input
    def fixed_input_params_file = (
        params.containsKey('is_refmod_input') && params.is_refmod_input
            ? params.fixed_msfragger_refmod_params_file
            : params.fixed_msfragger_params_file
    )

    // stop from the missing parameters
    def requiredParams = ['sch_files','exp_table','database','sitelist_file','groupmaker_file','decoy_prefix']
    printErrorMissingParams(params, requiredParams)

    // create channels from input files
    ch_sch_files = Channel.fromPath("${params.sch_files}", checkIfExists: true)

    // create channels from input files
    ch_exp_table       = Channel.fromPath("${params.exp_table}", checkIfExists: true)
    ch_sitelist_file   = Channel.fromPath("${params.sitelist_file}", checkIfExists: true)
    ch_peak_file       = file("${params.peak_file}", checkIfExists: true)
    // these files will be used multiple times; So, we have to create a Value Channel and then, check if file exists
    File file_db = new File("${params.database}")
    if (!file_db.isAbsolute()) { file_db = file_db.getCanonicalFile() }
    if ( file_db.exists() ) {
        ch_database = Channel.value(file_db.getAbsolutePath())
    } else { exit 1, "ERROR: The 'database' file does not exist" }
    File file_gm = new File("${params.groupmaker_file}")
    if (!file_gm.isAbsolute()) { file_gm = file_gm.getCanonicalFile() }
    if ( file_gm.exists() ) {
        ch_groupmaker_file = Channel.value(file_gm.getAbsolutePath())
    } else { exit 1, "ERROR: The 'groupmaker_file' file does not exist" }

    // update the given parameter into the fixed parameter file
    def redefinedParams = ['decoyprefix': params.decoy_prefix, 'decoy_prefix': params.decoy_prefix]
    def updated_params_str = updateParamsFile(fixed_input_params_file, redefinedParams)
    def fixed_params_file = writeStrIntoFile(updated_params_str, "${params.paramdir}/params.ini")

    // merge the files that contain both the fixed parametes and the variable parameters
    def merged_params_str = mergeIniFiles(fixed_params_file, params.params_file)
    def updated_params_file = writeStrIntoFile(merged_params_str, "${params.paramdir}/params.ini")

    // create channel for params file
    // these files will be used multiple times; So, we have to create a Value Channel and then, check if file exists
    ch_params_file = Channel.value("${updated_params_file}")

    // copy input files into params directory
    copyFileToFolder("${params.exp_table}", "${params.paramdir}/")
    copyFileToFolder("${params.database}", "${params.paramdir}/")
    copyFileToFolder("${params.sitelist_file}", "${params.paramdir}/")
    copyFileToFolder("${params.groupmaker_file}", "${params.paramdir}/")


    emit:
    ch_sch_files
    ch_exp_table
    ch_database
    ch_sitelist_file
    ch_groupmaker_file
    ch_peak_file
    ch_params_file
}
