process DUPLICATE_REMOVER {
    tag "${order}"
    label 'process_medium'

    input:
    val  order
    path input_file
    val  params_file

    output:
    path "${input_file.baseName}_Unique.feather", emit: ofile
    path "*_log.txt", emit: log

    script:
    """
    source ${SHIFTS_HOME}/env/bin/activate && python ${SHIFTS_HOME}/DuplicateRemover_v2.py -i "${input_file}" -c "${params_file}"
    """

}
