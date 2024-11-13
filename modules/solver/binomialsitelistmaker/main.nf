process BINOMIAL_SITELIST_MAKER {
    tag "${order}"
    label 'process_medium'

    input:
    val  order
    path input_file
    path params_file

    output:
    path "BinomialSiteListMaker_PEAKS_Output.xlsx", emit: ofile
    path "*.log", emit: log

    script:
    // define files
    def output_file = "BinomialSiteListMaker_PEAKS_Output.xlsx"

    """
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${SOLVER_HOME}/BinomialSiteListMaker.py -i "${input_file}" -o "${output_file}" -c "${params_file}"
    """
}
