process PEAK_MODELLER {
    tag "${order}"
    label 'process_high'

    input:
    val  order
    path input_file
    path params_file

    output:
    path "DMTable.feather", emit: oDMtable
    path "DMHistogram.tsv", emit: oHistogram

    path "DMTable_target.feather", emit: oDMtableTarget, optional: true
    path "DMHistogram_target.tsv", emit: oHistogramTarget, optional: true
    path "DMTable_decoy.feather", emit: oDMtableDecoy, optional: true
    path "DMHistogram_decoy.tsv", emit: oHistogramDecoy, optional: true
    path "target_decoy.html", emit: oPlot, optional: true

    path "*_log.txt", emit: log

    script:
    """
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${SHIFTS_HOME}/PeakModeller.py -w "${task.cpus}" -i "*_Unique_calibrated.feather" -c "${params_file}"
    """
}
