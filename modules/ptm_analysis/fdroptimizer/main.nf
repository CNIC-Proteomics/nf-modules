process FDR_OPTIMIZER {
    tag "${order}"
    label 'process_single'

    input:
    val  order
    path input_file
    val  params_str

    output:
    path "*_FDR.tsv", emit: ofile
    path "*.log", emit: log, optional: true

    script:
    // define files
    def log_file ="${input_file.baseName}.log"
    def output_file = "${input_file.baseName}_FDR.tsv"

    // define params file
    def params_file = "params.yml"
    
    """
    # create the new parameter file
    echo "${params_str}" > "${params_file}"
    
    source ${REPORTANALYSIS_HOME}/env/bin/activate && python ${REPORTANALYSIS_HOME}/3_FDRoptimizer/FDRoptimizer.py  -i "${input_file}" -c "${params_file}" -o "${output_file}" 2>&1
    """
}

