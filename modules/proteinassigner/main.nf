process PROTEIN_ASSIGNER {
    tag "${order}"
    label 'process_medium'

    input:
    val  order
    path input_file
    path database
    val  params_str

    output:
    path("${input_file.baseName}_PA.tsv", emit: ofile)
    path "*_log.txt", emit: log

    script:
    // define files
    def log_file ="${input_file.baseName}_log.txt"
    def output_file ="${input_file.baseName}_PA.tsv"
    // define params file
    def params_file = "params.ini"
    """
    # create the new parameter file
    echo "${params_str}" > "${params_file}"
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${PTMTOOLS_HOME}/ProteinAssigner.py -i "${input_file}" -f "${database}" -o "${output_file}" -c "${params_file}" &> "${log_file}"
    """
}
