process PEAK_INSPECTOR {
    tag "${order}"
    label 'process_medium'

    input:
    val  order
    path input_file
    path peak_file
    val  params_str

    output:
    path "${input_file.baseName}_plot.html", emit: oHistogramPlot
    path "*_log.txt", emit: log

    script:
    // add the optional parameters
    def optional_params = peak_file.name != 'NO_FILE' ? "-p \"${peak_file}\"" : ''    
    // define params file
    def params_file = "params.ini"
    """
    # create the new parameter file
    echo "${params_str}" > "${params_file}"
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${SHIFTS_HOME}/PeakInspector.py -i "${input_file}" -c "${params_file}" ${optional_params}
    """
}
