process DM0SOLVER {
    tag "${order}"
    label 'process_medium'

    input:
    val  order
    path input_file
    path input_file2
    val  params_str

    output:
    path "${input_file.baseName}_DM0S.txt", emit: ofile
    path "*_log.txt", emit: log

    script:
    // define params file
    def params_file = "params.ini"

    """
    # create the new parameter file
    echo "${params_str}" > "${params_file}"
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${SOLVER_HOME}/DM0Solver.py -i "${input_file}" -a "${input_file2}" -c "${params_file}"
    """
}
