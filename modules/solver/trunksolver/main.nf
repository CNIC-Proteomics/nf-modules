process TRUNK_SOLVER {
    tag "${order}"
    label 'process_medium'

    input:
    val  order
    path input_file
    path database
    path params_file

    output:
    path "${input_file.baseName}_TS.txt", emit: ofile
    path "*_log.txt", emit: log

    script:
    """
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${SOLVER_HOME}/TrunkSolver.py -i "${input_file}" -f "${database}" -c "${params_file}"
    """
}
