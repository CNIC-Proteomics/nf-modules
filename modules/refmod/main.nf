process REF_MOD {
    tag "${order}"
    label 'process_single'

    input:
    val order
    tuple path(ident_file), path(mz_file)
    path dm_file
    path params_file

    output:
    path "${ident_file.baseName}.tsv", emit: ofile
    path "${mz_file.baseName}_SUMMARY.tsv", emit: summary_file
    path "*.log", emit: log

    script:
    // define files
    def log_file ="${ident_file.baseName}.log"

    """
    source ${REFMOD_HOME}/env/bin/activate && python ${REFMOD_HOME}/ReFrag.py -w "${task.cpus}" -i "${ident_file}" -r "${mz_file}" -d "${dm_file}" -c "${params_file}" -o "output" > "${log_file}" 2>&1
    mv output/* .
    """
}
