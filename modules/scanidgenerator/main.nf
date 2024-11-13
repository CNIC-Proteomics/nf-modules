process SCANID_GENERATOR {
    tag "${order}"
    label 'process_medium'

    input:
    val  order
    path input_file
    path params_file

    output:
    path "${input_file.baseName}_ScanID.txt", emit: ofile

    script:
    """
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${PTMTOOLS_HOME}/ScanIDgenerator.py -i "${input_file}" -c "${params_file}"
    """
}
