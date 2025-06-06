process SITE_SOLVER {
    tag "${order}"
    label 'process_medium'

    input:
    val  order
    path input_file
    path sitelist_file
    val  params_str

    output:
    path "${input_file.baseName}_SS.txt", emit: ofile
    path "*_log.txt", emit: log

    script:
    // define params file
    def params_file = "params.ini"
    """
    # create the new parameter file
    echo "${params_str}" > "${params_file}"
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${SOLVER_HOME}/SiteSolver.py -i "${input_file}" -pl "${sitelist_file}" -c "${params_file}"
    """
}
