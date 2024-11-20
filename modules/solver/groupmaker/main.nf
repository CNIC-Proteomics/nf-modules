process GROUP_MAKER {
    tag "${order}"
    label 'process_medium'

    input:
    val  order
    path input_file
    path groupmaker_file
    val  params_str

    output:
    path "*_GM.txt", emit: ofile
    path "*_log.txt", emit: log

    script:
    // define params file
    def params_file = "params.ini"
    """
    # create the new parameter file
    echo "${params_str}" > "${params_file}"
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${SOLVER_HOME}/GroupMaker.py -i "${input_file}" -u "${groupmaker_file}" -c "${params_file}"
    """
}
