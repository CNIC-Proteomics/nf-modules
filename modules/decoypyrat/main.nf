process DECOY_PY_RAT {
    tag "${order}"
    label 'process_single'

    input:
    val  order
    path input_file
    val  decoy_prefix

    output:
    path "*.target-decoy.fasta", emit: ofile
    path "*.target.fasta", emit: ofile_target, optional: true
    path "*.decoy.fasta", emit: ofile_decoy, optional: true
    path "*.log", emit: log, optional: true

    script:
    // define files
    def log_file ="${input_file.baseName}.log"
    def db_target = "${input_file.baseName}.target.fasta"
    def db_decoy = "${input_file.baseName}.decoy.fasta"
    def db_target_decoy = "${input_file.baseName}.target-decoy.fasta"

    // obtain the decoys and targets (make sequence isobaric, replace 'I' to 'L')
    // concatenate targets and decoys
    """
    source ${BIODATAHUB_HOME}/env/bin/activate && python ${BIODATAHUB_HOME}/src/decoyPYrat.v2.py  --output_fasta "${db_decoy}"  --decoy_prefix=${decoy_prefix} "${input_file}" > "${log_file}" 2>&1
    cat "${db_target}" "${db_decoy}" > "${db_target_decoy}"
    """
}



