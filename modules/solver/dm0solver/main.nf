include {
    extractParamSection
} from '../../../lib/Utils'

process DM0SOLVER {
    tag "${order}"
    label 'process_medium'

    input:
    val  order
    path input_file
    path input_file2
    val  params_file
    val  params_sections

    output:
    path "${input_file.baseName}_DM0S.txt", emit: ofile
    path "*_log.txt", emit: log

    script:
    // extract the parameter section and create a new parameter file
    def params_str = extractParamSection(params_file, params_sections)
    params_str = params_str.replaceAll(/\[DM0Solver_Parameters_[^\]]*\]/, '[DM0Solver_Parameters]')

    // create a new parameter file
    def re_params_file = "params.ini"

    """
    # create the new parameter file
    echo "${params_str}" > "${re_params_file}"

    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${SOLVER_HOME}/DM0Solver.py -i "${input_file}" -a "${input_file2}" -c "${re_params_file}"
    """
}
