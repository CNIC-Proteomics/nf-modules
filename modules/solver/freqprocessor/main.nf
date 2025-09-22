process FREQ_PROCESSOR {
    tag "${order}"
    label 'process_very_low'

    input:
    val  order
    path input_file

    output:
    path "*_PDM_Table_pgmFreq.tsv", emit: ofilePdm
    path "*_PGM_Table_pgmFreq.tsv", emit: ofilePgm
    path "*.log", emit: log

    script:
    // define files
    def log_file ="${input_file.baseName}.log"
    def out_pdm  = "${input_file.baseName}_PDM_Table_pgmFreq.tsv"
    def out_pgm  = "${input_file.baseName}_PGM_Table_pgmFreq.tsv"

    """
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${SOLVER_HOME}/FreqProcessor.py -i "${input_file}" -od "${out_pdm}" -og "${out_pgm}" > "${log_file}" 2>&1
    """
}
