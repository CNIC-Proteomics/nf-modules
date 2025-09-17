process QREPORT_MAKER {
    tag "${order}"
    label 'process_single'

    input:
    val  order
    path input_file
    path params_file
    path map_dir
    path qmeta_file

    output:
    path "qReports", emit: odir
    path "*.log", emit: log, optional: true

    script:
    // add the optional parameters
    def optional_params = qmeta_file.name != 'NO_FILE' ? "-q \"${qmeta_file}\"" : ''    

    """
    source ${REPORTANALYSIS_HOME}/env/bin/activate && python ${REPORTANALYSIS_HOME}/src/qReportMaker.py  -i "${input_file}" -c "${params_file}" -p "${map_dir}" ${optional_params} -o "." 2>&1
    mv qReports/*.log .
    """
}

