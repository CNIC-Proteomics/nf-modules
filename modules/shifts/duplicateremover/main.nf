process DUPLICATE_REMOVER {
    tag "${order}"
    label 'process_medium'

    input:
    val  order
    path input_file
    val  params_str

    output:
    path "${input_file.baseName}_Unique.feather", emit: ofile
    path "*_log.txt", emit: log

    script:
    // define params file
    def params_file = "params.ini"
    """
    # create the new parameter file
    echo "${params_str}" > "${params_file}"
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${SHIFTS_HOME}/DuplicateRemover.py -i "${input_file}" -c "${params_file}"
    """
}
