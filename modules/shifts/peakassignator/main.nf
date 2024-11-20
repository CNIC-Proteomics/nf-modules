process PEAK_ASSIGNATOR {
    tag "${order}"
    label 'process_medium'

    input:
    val  order
    path input_file
    path input_file2
    val  params_str

    output:
    path "*_PeakAssignation.*",  emit: oPeakassign
    path "*_log.txt", emit: log

    script:
    // define params file
    def params_file = "params.ini"
    """
    # create the new parameter file
    echo "${params_str}" > "${params_file}"
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${SHIFTS_HOME}/PeakAssignator.py -i "${input_file}" -a "${input_file2}" -c "${params_file}"
    """
}
