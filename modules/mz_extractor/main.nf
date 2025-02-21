process MZ_EXTRACTOR {
    tag "${order}"
    label 'process_high'

    input:
    val order
    tuple path(ident_file), path(mz_file)
    path ion_file

    // when:
    // // execute this process depending on the given flag
    // ion_file.name != 'NO_FILE' ? true : false

    output:
    path "${ident_file.baseName}.tsv", emit: ofile
    path "*.log", emit: log

    script:
    // define log file
    def log_file ="${ident_file.baseName}.log"

    // execute process, then the output files overwrite the inputs (*.tsv)
    """
    source ${SEARCHTOOLKIT_HOME}/env/bin/activate && python ${SEARCHTOOLKIT_HOME}/mz_extractor.py -i "${ident_file}" -z "${mz_file}" -r "${ion_file}" -o "output" > "${log_file}" 2>&1
    mv output/* .
    """
}
