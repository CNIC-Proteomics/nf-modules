process PEAK_FDRER {
    tag "${order}"
    label 'process_high'

    input:
    val  order
    path input_file
    path apexlist_file
    path exp_table
    val  params_str

    output:
    path "${input_file.baseName}_FDRfiltered.tsv", emit: oFDRfiltered
    path "${input_file.baseName}_FDR.tsv", emit: oFDR
    path "${input_file.baseName}_peak_frequency.tsv", emit: oPeakFrequency
    path "*_log.txt", emit: log

    script:
    // define params file
    def params_file = "params.ini"
    """
    # create the new parameter file
    echo "${params_str}" > "${params_file}"
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${SHIFTS_HOME}/PeakFDRer.py -i "${input_file}" -a "${apexlist_file}" -e "${exp_table}" -c "${params_file}"
    """
}
