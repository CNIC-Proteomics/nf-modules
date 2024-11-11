process PEAK_SELECTOR {
    tag "${order}"
    label 'process_medium'

    input:
    val  order
    path input_file
    path params_file

    output:
    path "PeakSelector_DMHistogram.tsv", emit: oHistogram
    path "PeakSelector_ApexList.txt", emit: oApexlist
    path "PeakSelector_Plot.html", emit: oPlot
    path "*_log.txt", emit: log

    script:
    """
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${SHIFTS_HOME}/PeakSelector.py -i "${input_file}" -c "${params_file}"
    """
}
