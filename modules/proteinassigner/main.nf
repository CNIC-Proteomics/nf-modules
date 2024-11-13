include {
    extractParamSection
} from '../../lib/Utils'

process PROTEIN_ASSIGNER {
    tag "${order}"
    label 'process_medium'

    input:
    val  order
    path input_file
    path database
    val  params_file
    val  params_sections

    output:
    path("${input_file.baseName}_PA.tsv", emit: ofile)
    path "*_log.txt", emit: log

    script:
    // define files
    def log_file ="${input_file.baseName}_log.txt"
    def output_file ="${input_file.baseName}_PA.tsv"

    // extract the parameter section and create a new parameter file
    def params_str = extractParamSection(params_file, params_sections)
    params_str = params_str.replaceAll(/\[ProteinAssigner_[^\]]*\]/, '[ProteinAssigner]')

    // create a new parameter file
    // def re_params_file = writeStrIntoFile(params_str, "peak_assignator_params.ini")
    def re_params_file = "protein_assigner_params.ini"

    """
    # create the new parameter file
    echo "${params_str}" > "${re_params_file}"

    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${PTMTOOLS_HOME}/ProteinAssigner.py -i "${input_file}" -f "${database}" -o "${output_file}" -c "${re_params_file}" &> "${log_file}"
    """
}
