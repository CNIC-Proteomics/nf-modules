process MSF {
    tag "${order}"
    label 'process_very_high'
    label 'process_long_time'

    input:
    val order
    path input_files
    val  params_str

    output:
    path "*.tsv", emit: ofile
    path "*.pin", optional: true
    path "*.pepXML", optional: true
    path "*.log", emit: log, optional: true

    script:
    // get the extension from the first input file. Should be equal in the channel collect.
    def prefix = input_files.first().getExtension()
    // define log file
    def log_file ="${task.process.tokenize(':')[-1].toLowerCase()}.log"
    // define the task memory
    def task_memory = task.memory.toString().replace(' ','').replace('GB','g').replace('MB','m')
    // define params file
    def params_file = "params.txt"
    
    """
# create the new parameter file
cat > "${params_file}" <<'EOF'
${params_str}
EOF
    java -Xmx"${task_memory}" -jar ${MSFRAGGER_HOME}/MSFragger.jar "${params_file}"  *.${prefix}  > "${log_file}" 2>&1
    """

}
