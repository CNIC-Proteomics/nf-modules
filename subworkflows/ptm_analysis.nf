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
    mergeYmlFiles;
    writeStrIntoFile
} from '../lib/Utils'


/*
========================================================================================
    DEFINED WORKFLOWS
========================================================================================
*/

workflow CREATE_INPUT_CHANNEL_PTM_ANALYSIS {
    main:

    // stop from the missing parameters
    def requiredParams = ['quant_file','pdm_file','params_file','compa_file']
    printErrorMissingParams(params, requiredParams)

    // create channels from input files
    quant_file = Channel.fromPath("${params.quant_file}", checkIfExists: true)
    pdm_file = Channel.fromPath("${params.pdm_file}", checkIfExists: true)
    compa_file = Channel.fromPath("${params.compa_file}", checkIfExists: true)

    // merge the files that contain both the fixed parametes and the variable parameters
    def merged_params_str = mergeYmlFiles(params.fixed_params_file, params.params_file)
    def updated_params_file = writeStrIntoFile(merged_params_str, "${params.paramdir}/params.yml")

    // create channel for params file
    params_file = Channel.fromPath("${updated_params_file}", checkIfExists: true)

    // create channels from input files
    // this file will be used multiple times, so, it is why the variable changes to file
    qmeta_file = Channel.fromPath("${params.NO_FILE}", checkIfExists: true)
    if ( params.containsKey('qmeta_file') ) {
        qmeta_file = Channel.fromPath("${params.qmeta_file}", checkIfExists: true)
        copyFileToFolder("${params.qmeta_file}", "${params.paramdir}/")
    }

    // copy input files into params directory
    copyFileToFolder("${params.quant_file}", "${params.paramdir}/")
    copyFileToFolder("${params.pdm_file}", "${params.paramdir}/")
    copyFileToFolder("${params.compa_file}", "${params.paramdir}/")

    emit:
    ch_quant_file         = quant_file
    ch_pdm_file           = pdm_file
    ch_params_file        = params_file
    ch_compa_file         = compa_file
    ch_qmeta_file         = qmeta_file
}
