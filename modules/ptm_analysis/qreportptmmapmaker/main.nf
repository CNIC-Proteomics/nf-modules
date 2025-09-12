process QREPORT_PTMMAP_MAKER {
    tag "${order}"
    label 'process_single'

    input:
    val  order
    path input_file
    path qmeta_file
    val  params_str

    output:
    path "PTMmaps", emit: PTMmaps
    path "PTMmaps_filtered", emit: PTMmaps_filtered
    path "qReports", emit: qReports
    path "FreqTables", emit: FreqTables
    path "*.log", emit: log, optional: true

    script:
    // add the optional parameters
    def optional_params = qmeta_file.name != 'NO_FILE' ? "-q \"${qmeta_file}\"" : ''    

    // define params file
    def params_file = "params.yml"
    
    """
    # create the new parameter file
    echo "${params_str}" > "${params_file}"
    
    source ${REPORTANALYSIS_HOME}/env/bin/activate && python ${REPORTANALYSIS_HOME}/5_PTMMap/PTMMap.py  -i "${input_file}" -c "${params_file}" -o "." 2>&1

    source ${REPORTANALYSIS_HOME}/env/bin/activate && python ${REPORTANALYSIS_HOME}/6_qTableReport/qReportMaker.py  -i "${input_file}" -c "${params_file}" -p "." ${optional_params} -o "." 2>&1
    """
}

