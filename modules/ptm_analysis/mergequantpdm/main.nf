process MERGE_QUANT_PDM {
    tag "${order}"
    label 'process_single'

    input:
    val  order
    path quant_file
    path pdm_file

    output:
    path "quant_pdm.tsv", emit: ofile
    path "*.log", emit: log, optional: true

    script:
    // define files
    def log_file ="${quant_file.baseName}.log"
    def output_file = "quant_pdm.tsv"
    
    """
    source ${REPORTANALYSIS_HOME}/env/bin/activate && python ${REPORTANALYSIS_HOME}/1_MergeiSanxotPDM/MergeiSanxotPDM.py  -i "${quant_file}" -p "${pdm_file}" -o "${output_file}" 2>&1
    """
}

