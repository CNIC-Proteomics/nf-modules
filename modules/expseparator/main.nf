process EXPERIMENT_SEPARATOR {
    tag "${order}"
    label 'process_single'

    input:
    val  order
    path input_file
    path exp_table

    output:
    path "*_FDR.tsv", emit: ofile
    path "*_log.txt", emit: log

    script:
    """
    source ${PTMCOMPASS_HOME}/env/bin/activate && python ${PTMTOOLS_HOME}/ExperimentSeparator.py -i "${input_file}" -c "Experiment" -o "."
    """
}
