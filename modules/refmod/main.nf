// process REF_MOD {
//     tag "${order}"
//     label 'process_high'

//     input:
//     val order
//     tuple path(raw_files), path(msf_files)
//     path dm_file
//     path params_file

//     output:
//     path "${raw_files.baseName}_REFMOD.tsv", emit: ofile
//     path "*.log", emit: log

//     script:
//     // define files
//     def log_file ="${msf_files.baseName}.log"

//     """
//     source ${REFMOD_HOME}/env/bin/activate && python ${REFMOD_HOME}/ReFrag.py -w "${task.cpus}" -i "${msf_files}" -r "${raw_files}" -d "${dm_file}" -c "${params_file}"
//     """
// }

process REF_MOD {
    tag "${order}"
    label 'process_high'

    input:
    val order
    tuple path(raw_files), path(msf_files)
    path dm_file
    path params_file

    output:
    path "${msf_files.baseName}_pos.tsv", emit: ofile
    path "*.log", emit: log

    script:
    // define files
    def log_file ="${msf_files.baseName}.log"

    """
    source ${REFMOD_HOME}/env/bin/activate && python ${REFMOD_HOME}/msf_adaptor.py -i "${msf_files}" > "${log_file}" 2>&1
    """
}
