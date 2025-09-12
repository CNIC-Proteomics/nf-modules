process LIMMA_COMPARE {
    tag "${order}"
    label 'process_single'

    input:
    val  order
    path input_file
    path compa_file
    val  params_str

    output:
    path "*_LIMMA.tsv", emit: ofile
    path "*.log", emit: log, optional: true

    script:
    // define files
    def log_file ="${input_file.baseName}.log"
    def output_file = "${input_file.baseName}_LIMMA.tsv"

    // define params file
    def params_file = "params.yml"
    
    """
    # create the new parameter file
    echo "${params_str}" > "${params_file}"
    
    Rscript --vanilla ${REPORTANALYSIS_HOME}/3_ReportLimma_wo_GUI/app_wo_GUI.R  -i "${input_file}" -c "${params_file}" -s "${compa_file}" -o "${output_file}" 2>&1
    """
}

