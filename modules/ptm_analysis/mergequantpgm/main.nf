process MERGE_QUANT_PGM {
    tag "${order}"
    label 'process_single'

    input:
    val  order
    path quant_file
    path pgm_file

    output:
    path "quant_pgm.tsv", emit: ofile
    path "*.log", emit: log, optional: true

    script:
    // define files
    def log_file ="${quant_file.baseName}.log"
    def output_file = "quant_pgm.tsv"
    
    """
    source ${REPORTANALYSIS_HOME}/env/bin/activate && python ${REPORTANALYSIS_HOME}/src/mergeiSanxotPGM.py  -i "${quant_file}" -p "${pgm_file}" -o "${output_file}" 2>&1
    """
}

