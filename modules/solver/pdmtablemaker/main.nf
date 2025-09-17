process PGMTABLE_MAKER {
    tag "${order}"
    label 'process_medium' , 'process_long_time'

    input:
    val  order
    path input_file
    path database
    val  params_str

    output:
    path "*_PDMTable.txt", emit: ofile
    path "*_log.txt", emit: log

    script:
    // create the input file
    def re_input_file = "experiment.txt"
    // define params file
    def params_file = "params.ini"
    """
    # create the input file with the path of files
    echo "${input_file}" > "${re_input_file}"
    # create the new parameter file
    echo "${params_str}" > "${params_file}"
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${SOLVER_HOME}/PDMTableMaker.py -i "${re_input_file}" -f "${database}" -c "${params_file}"
    """
}
