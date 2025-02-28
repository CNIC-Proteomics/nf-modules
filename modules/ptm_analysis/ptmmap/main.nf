process PTM_MAP {
    tag "${order}"
    label 'process_single'

    input:
    val  order
    path input_file
    path params_file

    output:
    path "PTMMaps", emit: odir
    path "*.log", emit: log, optional: true

    script:
    """
    source ${REPORTANALYSIS_HOME}/env/bin/activate && python ${REPORTANALYSIS_HOME}/4_PTMMap/PTMMap.py  -i "${input_file}" -c "${params_file}" -o "PTMMaps" 2>&1
    mv PTMMaps/*.log .
    """
}

