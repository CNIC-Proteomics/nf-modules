include {
    updateParams
} from '../../../lib/Utils'

process RECOM_FILTERER {
    tag "${order}"
    label 'process_medium'

    input:
    val  order
    path input_file
    val  params_file

    output:
    path "${input_file.baseName}_RECOMfiltered.feather", emit: oRecomfiltered
    path "*_log.txt", emit: log

    script:
    // update the parameters: join the fixed params and the user params
    def updated_params_file = updateParams(params, params_file)

    """
    source ${SHIFTS_HOME}/env/bin/activate && python ${SHIFTS_HOME}/RECOMfilterer.py -i "${input_file}" -c "${updated_params_file}"
    """
}
