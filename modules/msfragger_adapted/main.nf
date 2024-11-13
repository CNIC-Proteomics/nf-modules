process MSFRAGGER_ADAPTED {
    tag "${order}"
    label 'process_single'

    input:
    val order
    path ident_file

    output:
    path("*_adapt.tsv", emit: ofile)
    path("*.log", emit: log)

    script:
    // define log file
    def log_file ="${ident_file.baseName}.log"

    """
    source ${SEARCHTOOLKIT_HOME}/env/bin/activate && python ${SEARCHTOOLKIT_HOME}/add_scanid.py -i "${ident_file}" -d "scannum,charge" -o "." > "${log_file}" 2>&1
    """
}
