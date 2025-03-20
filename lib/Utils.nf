//
// This file holds several Groovy functions that could be useful for any Nextflow pipeline
//

/*
========================================================================================
    IMPORT MODULES
========================================================================================
*/


import java.io.File
import org.codehaus.groovy.runtime.StackTraceUtils

import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.StandardCopyOption
import org.yaml.snakeyaml.Yaml


/*
========================================================================================
    LOCAL FUNCIOTNS
========================================================================================
*/


/**
 * Checks if a path is absolute.
 *
 * @param path - The path to check
 * @return True if the path is absolute, otherwise false
 */
boolean isAbsolutePath(String path) {
    return new File(path).isAbsolute()
}


/**
 * Converts a relative path to an absolute path.
 *
 * @param path - The relative path to convert
 * @return The absolute path as a string
 */
String toAbsolutePath(String path) {
    return new File(path).absolutePath
}


/**
 * Retrieves the absolute path of a given file or directory.
 *
 * @param path - The input path as a string or File object
 * @return The absolute path as a string
 */
String getAbsolutePath(path) {
    def ofile = ''
    try {
        def path_str = ''
        // convert to string if given variable is a File
        if (path instanceof File) {
            path_str = path.getPath()
        } else {
            path_str = path
        }
        // check if the paths are absolute or relative and convert if necessary
        if (!isAbsolutePath(path_str)) {
            ofile = toAbsolutePath(path_str)
        } else {
            ofile = path_str
        }
    } catch(Exception ex) {
        println("ERROR: ${new Object(){}.getClass().getEnclosingMethod().getName()}: $ex.")
        System.exit(1)
    }
    return ofile
}
        

/**
 * Retrieves the base name of a file (filename without extension).
 *
 * @param filePath - The full path of the file
 * @return The base name of the file as a string
 */
def getBaseName(filePath) {
    def basename = new File(filePath).getBaseName()
    return basename
}


/**
 * Retrieves the current method name.
 *
 * @return The name of the method as a string
 */
def getCurrentMethodName(){
    def marker = new Throwable()
    return StackTraceUtils.sanitize(marker).stackTrace[1].methodName
}


/**
 * Checks if at least one element of a list exists in a JSON object.
 *
 * @param params - The JSON object containing parameters
 * @param required_params - A list of required parameter names
 * @return True if at least one parameter exists, otherwise false
 */
def checkIfAnyParamExist(params, required_params) {
    for (param in required_params) {
        if (params.containsKey(param)) {
            return true
        }
    }
    return false
}


/**
 * Identifies missing parameters from a list of required parameters.
 *
 * @param params - The JSON object containing parameters
 * @param required_params - A list of required parameter names
 * @return A list of missing parameter names
 */
def getMissingParams(params, required_params) {
    def missingParams = []
    // Iterate over each parameter in the list
    for (required_param in required_params) {
        // First, check if required_param is a list
        if (required_param instanceof List) {
            // Check if at least one parameter exists
            if (!checkIfAnyParamExist(params, required_param)) {
                // If any parameter exists, add all of them to the list of missing parameters
                missingParams.addAll(required_param)
            }
        }
        else {
            // Check if the parameter exists in the params
            if (!params.containsKey(required_param)) {
                // If parameter is missing, add it to the list of missing parameters
                missingParams.add(required_param)
            }
        }
    }
    // Return the list of missing parameters
    return missingParams
}


/**
 * Prints an error message for missing parameters and exits.
 *
 * @param params - The JSON object containing parameters
 * @param required_params - A list of required parameter names
 */
def printErrorMissingParams(params, required_params) {
    // check which parameters are missing in the dict
    def missingParams = getMissingParams(params, required_params)
    // stop from the missing parameters
    if (!missingParams.isEmpty()) {
        exit 1, "ERROR: Missing parameters: ${missingParams}"
    }
}


/**
 * Joins two channels based on the file name.
 *
 * @param ifiles1 - First input channel
 * @param ifiles2 - Second input channel
 * @return A channel containing tuples of paired files
 */
def joinChannelsFromFilename(ifiles1, ifiles2) {

    // create a list of tuples with the base name and the file name.
    def files1 = ifiles1
                    // .flatten()
                    .map{  file -> tuple(file.baseName, file) }
                    // .view { "value_ifile1: $it" }
                    // .set { files1 }

    // create a list of tuples with the base name and the file name.
    def files2 = ifiles2
                    .map { file -> tuple(file.baseName, file) }
                    // .view { "value_ifile2: $it" }
                    // .set { files2 }

    // join both channels based on the first element (base name)
    def files3 = files1
                    .join(files2)
                    .map { name, f1, f2 -> [f1, f2] }
                    // .view { "value: $it" }
                    // .set { files3 }

    return files3
}


/**
 * Joins two channels based on file name prefix matching.
 *
 * @param ifiles1 - First input channel
 * @param ifiles2 - Second input channel
 * @return A channel containing tuples of paired files
 */
def joinChannelsFromPrefix(ifiles1, ifiles2) {

    // create a list of tuples with the base name (prefix) and the file itself for ifiles1.
    def files1 = ifiles1
                    .map { file -> tuple(file.baseName, file) }

    // create a list of tuples with the base name (prefix) and the file itself for ifiles2.
    def files2 = ifiles2
                    .map { file -> tuple(file.baseName, file) }

    // join channels based on prefix matching.
    def files3 = files1
                    .flatMap { prefix1, f1 -> 
                        files2
                            .filter { prefix2, f2 -> 
                                f1.name.startsWith(prefix2) || f2.name.startsWith(prefix1)
                            }
                            .map { prefix2, f2 -> [f1, f2] }
                    }
    // def files3 = files1
    //             .flatMap { prefix1, f1 -> 
    //                 files2List
    //                     .findAll { prefix2, f2 -> 
    //                         f1.name.startsWith(prefix2) || f2.name.startsWith(prefix1)
    //                     }
    //                     .collect { prefix2, f2 -> [prefix1, f1, f2] }
    //             }
                // .view { "Joined Pair: ${it[1].name}, ${it[2].name}" }
                .view()

    return files3
}


/**
 * Copies a file to a folder with the destination file name matching the source file name.
 *
 * @param sourcePath - The path to the source file
 * @param destinationFolderPath - The path to the destination folder
 * @throws IOException if the file operation fails
 */
def copyFileToFolder(sourcePath, destinationFolderPath) {
    try {
        Path source = Path.of(sourcePath)
        Path destinationFolder = Path.of(destinationFolderPath)
        // ensure the destination folder exists
        if (!Files.exists(destinationFolder)) {
            Files.createDirectories(destinationFolder)
        }
        // append the source file name to the destination folder path
        Path destinationFile = destinationFolder.resolve(source.fileName)
        // copy the file and overwrite if the destination file exists
        Files.copy(source, destinationFile, StandardCopyOption.REPLACE_EXISTING)
        // println("File copied from ${sourcePath} to ${destinationFile}")
    } catch (IOException ex) {
        println("ERROR: ${new Object(){}.getClass().getEnclosingMethod().getName()}: $ex.")
        System.exit(1)
    }
}


/**
 * Writes the given content into a specified file.
 *
 * @param content - The string content to write to the file
 * @param ifile - The path of the file where the content will be written
 * @return The absolute path of the written file
 */
def writeStrIntoFile(content, ifile) {
    // declare variable
    def ofile = ''
    try {
        def of = new File(ifile)
        of.write(content)
        // check if the paths are absolute or relative and convert if necessary
        ofile = getAbsolutePath(of)
    } catch(Exception ex) {
        println("ERROR: ${new Object(){}.getClass().getEnclosingMethod().getName()}: $ex.")
        System.exit(1)
    }
    return ofile
}



/* -------------------- METHODS FOR INI FILES -------------------- */


/**
 * Creates a string in INI format from a report map of sections and key-value pairs.
 *
 * @param report - A map where each section is associated with its parameters
 * @return A formatted string in INI format
 */
def createIniStr(report) {
    def result = ''
    try {
        report.each { section,params ->
            result += "[${section}]\n"
            params.each { key,val ->
                result += "${key} = ${val}\n"
            }
            result += "\n"
        }
    } catch(Exception ex) {
        println("ERROR: ${new Object(){}.getClass().getEnclosingMethod().getName()}: $ex.")
        System.exit(1)
    }
    return result
}


/**
 * Parses an INI file and creates a map representing its structure.
 *
 * @param ifile - Path to the INI file
 * @return A map where keys are section names and values are key-value pairs of parameters
 */
def parseIniFile(ifile) {
    def result = [:]
    try {
        def fileReader = new File(ifile.toString()).text
        def currentSection = null
        fileReader.split("\n").each() { line ->
            line = line.trim()
            line = line.replaceAll(/(#).*/, '')
            if (line.startsWith("[")) {
                // It's a section header
                currentSection = line.replaceAll("\\[|\\]", "").trim()
                result[currentSection] = [:]
            } else if (line && !line.startsWith("#")) {
                // It's a key-value pair (not empty and not a comment)
                def keyValue = line.split('=').collect { it.split('/(#)/')[0].trim() }
                if (currentSection) {
                    def key = keyValue[0]
                    def val = keyValue[1] ? keyValue[1] : '' // empty if null
                    // Add the key-value pair to the current section
                    result[currentSection][key] = val
                }
            }
        }
    } catch(Exception ex) {
        println("ERROR: ${new Object(){}.getClass().getEnclosingMethod().getName()}: $ex.")
        System.exit(1)
    }
    return result
}


/**
 * Extracts specified sections from an INI file and creates a string with their parameters.
 *
 * @param ifile - Path to the INI file
 * @param sections - List of sections to extract
 * @return A string representing the extracted sections in INI format
 */
def extractParamSection(ifile, sections) {
    // declare variable
    def params_str = ''
    try {
        // parse Ini file
        def params = parseIniFile(ifile)
        // get parameters from the given sections
        def params_data = [:]
        sections.each { section ->
            if ( params.containsKey(section) ) {
                params_data[section] = params[section]
            }
            else {
                throw new Exception("Key '$replace.key' is not in the parameter file.")
            }
        }
        // create str with Ini report
        params_str = createIniStr(params_data)
    } catch(Exception ex) {
        println("ERROR: ${new Object(){}.getClass().getEnclosingMethod().getName()}: $ex.")
        System.exit(1)
    }
    return params_str
}


/**
 * Generates an updated parameter string by extracting specific sections and applying replacements.
 *
 * @param ifile - Path to the input parameter file
 * @param sections - List of sections to extract and update
 * @param replacements - List of tuples (regex, replacement) for dynamic replacements (optional)
 * @return A string containing the updated parameters
 */
def generateUpdatedParamStr(ifile, sections, replacements = []) {
    // declare variable
    def paramsStr = ''
    try {
        // extract the parameter section using the existing extractParamSection method
        paramsStr = extractParamSection(ifile, sections)
        // apply replacements if provided
        replacements.each { replacement -> paramsStr = paramsStr.replaceAll(replacement[0], replacement[1]) }
        // // create a new parameter file
        // def re_params_file = writeStrIntoFile(paramsStr, reParamsFile)
    } catch (Exception ex) {
        println("ERROR: ${new Object(){}.getClass().getEnclosingMethod().getName()}: $ex.")
        System.exit(1)
    }
    return paramsStr
}

/**
 * Generates a parameter string channel based on the given sections, parameter file, and replacements.
 *
 * @param paramsFile - Channel representing the parameter file path
 * @param sections - List of sections to extract from the parameter file
 * @param replacements - List of tuples (regex, replacement) for dynamic replacements (optional)
 * @return A channel emitting the updated parameter string
 */
def createParamStrChannel(paramsFile, sections, replacements = []) {
    return paramsFile.map { file ->
        generateUpdatedParamStr(file, sections, replacements)
    }
}


/**
 * Updates an INI file with the provided key-value pairs.
 *
 * @param ifile - Path to the input INI file
 * @param replaces - A map containing key-value pairs to update
 * @return A string representing the updated parameters
 */
def updateParamsFile(ifile, replaces) {
    // declare variable
    def ofile = ''
    def content = ''
    try {
        // read the file contents into a variable
        def f = new File(ifile.toString())
        content = f.text
        // replace attributes by the given ones
        replaces.each { replace ->
            def pattern = ~/${replace.key}\s*=.*/
            content = content.replaceAll(pattern,"${replace.key}=${replace.value}")
        }
        // // define output file
        // def ofilename = "${f.getParent()}${File.separator}updated_${f.name}"
        // // write the output parameter file
        // ofile = new File(ofilename)
        // ofile.write(content)
    } catch(Exception ex) {
        println("ERROR: ${new Object(){}.getClass().getEnclosingMethod().getName()}: $ex.")
        System.exit(1)
    }
    // return ofile
    return content
}


/**
 * Merges two INI files by combining their sections and parameters.
 *
 * @param ifile1 - Path to the first INI file
 * @param ifile2 - Path to the second INI file
 * @return A string representing the merged parameters in INI format
 */
def mergeIniFiles(ifile1, ifile2) {
    // declare variable
    def params_str = ''
    try {
        // parse Ini files
        def params1 = parseIniFile(ifile1)
        def params2 = parseIniFile(ifile2)
        // add the section/parameters (params2) into fixed parameters (params1)
        def params_data = params1
        params2.each { section, params ->
            // the section from params2 are within params_data
            if ( params_data.containsKey(section) ) {
                params.each { key,val ->
                    // // We add the parameters from params2 into params_data if they do not exist
                    // if ( !params_data[section].containsKey(key) ) {
                    //     params_data[section][key] = val
                    // }
                    
                    // We add the parameters from params2 into params_data, owerwriting if exist
                    params_data[section][key] = val
                }
            }
            else { // add the new section from params2 into params_data
                params_data[section] = params
            }
        }
        // create str with Ini report
        params_str = createIniStr(params_data)
    } catch(Exception ex) {
        println("ERROR: ${new Object(){}.getClass().getEnclosingMethod().getName()}: $ex.")
        System.exit(1)
    }
    return params_str
}


/**
 * Updates parameters and merges INI files into a final updated parameter file.
 *
 * @param params - A map containing parameters and their values
 * @param params_file - Path to the additional parameters file
 * @return Path to the final updated parameters file
 */
def updateParams(params, params_file) {
    def redefinedParams = ['decoyprefix': params.decoy_prefix, 'decoy_prefix': params.decoy_prefix]
    def updated_params_str = updateParamsFile(params.fixed_params_file, redefinedParams)
    def fixed_params_file = writeStrIntoFile(updated_params_str, "${params.paramdir}/params.ini")

    def merged_params_str = mergeIniFiles(fixed_params_file, params_file)
    def updated_params_file = writeStrIntoFile(merged_params_str, "${params.paramdir}/params.ini")

    return updated_params_file
}



/* -------------------- METHODS FOR YAML FILES -------------------- */


/**
 * Extracts specified sections from a YAML file and returns them as a string.
 *
 * @param ifile - Path to the YAML file
 * @param sections - List of sections to extract
 * @return A string representing the extracted sections in YAML format
 */
def extractYamlSections(ifile, sections) {
    def yaml = new Yaml()
    def yamlFile = (ifile instanceof Path) ? ifile.toFile() : ifile // ensure we handle both Path and File objects
    def yamlData = yaml.load(yamlFile.newInputStream())

    def extractedData = [:]
    sections.each { section ->
        if (yamlData.containsKey(section)) {
            extractedData[section] = yamlData[section]
        } else {
            throw new Exception("Key '${section}' is not in the YAML file.")
        }
    }

    return new Yaml().dump(extractedData)
}


/**
 * Generates an updated parameter string by extracting specific sections and applying replacements.
 *
 * @param ifile - Path to the input YAML file
 * @param sections - List of sections to extract and update
 * @param replacements - List of tuples (regex, replacement) for dynamic replacements (optional)
 * @return A string containing the updated parameters in YAML format
 */
def generateUpdatedYamlStr(ifile, sections, replacements = []) {
    def yamlStr = ''
    try {
        yamlStr = extractYamlSections(ifile, sections)

        replacements.each { replacement ->
            yamlStr = yamlStr.replaceAll(replacement[0], replacement[1])
        }
    } catch (Exception ex) {
        println("ERROR: ${new Object(){}.getClass().getEnclosingMethod().getName()}: $ex.")
        System.exit(1)
    }
    return yamlStr
}


/**
 * Generates a YAML parameter string channel based on the given sections and replacements.
 *
 * @param paramsFile - Channel representing the YAML file path
 * @param sections - List of sections to extract from the YAML file
 * @param replacements - List of tuples (regex, replacement) for dynamic replacements (optional)
 * @return A channel emitting the updated YAML string
 */
def createYamlParamStrChannel(paramsFile, sections, replacements = []) {
    return paramsFile.map { file ->
        generateUpdatedYamlStr(file, sections, replacements)
    }
}


/**
 * Recursive merging of two maps (deep merge).
 * @param target - The target map (to be updated).
 * @param source - The source map (overrides).
 */
def mergeMaps(target, source) {
    source.each { key, value ->
        // preserve target value if source value is null
        if (value == null) { return }
        // recursive merge for nested maps
        if (value instanceof Map && target[key] instanceof Map) {
            mergeMaps(target[key], value)
        // Override target with source value
        } else {            
            target[key] = value
        }
    }
}


/**
 * Merges parameters from the source YAML into the target YAML.
 * @param sourceYaml - The source YAML file (overrides).
 * @param targetYaml - The target YAML file (to be updated).
 * @return Merged YAML content as a string.
 */
def mergeYmlFiles(ifile1, ifile2) {
    // declare variable
    def params_str = ''
    try {
        // read input files
        File targetFile = new File(ifile1)
        File sourceFile = new File(ifile2)

        // parse YAML content to maps
        Yaml yaml = new Yaml()
        Map targetData = yaml.load(targetFile.newInputStream())
        Map sourceData = yaml.load(sourceFile.newInputStream())
        
        // merge maps
        mergeMaps(targetData, sourceData)

        // convert merged map to YAML string
        params_str = new Yaml().dump(targetData)
    } catch(Exception ex) {
        println("ERROR: ${new Object(){}.getClass().getEnclosingMethod().getName()}: $ex.")
        System.exit(1)
    }
    return params_str
}


// //
// // Create report (map) with the parameters from the MSFragger file
// //
// def parseMsfFile(fileName) {
//     // declare variables
//     def result = [:]
//     try {
//         def fileReader = new File(fileName).text
//         def currentSection = null
//         fileReader.split("\n").each() { line ->
//             line = line.trim()
//             if (line && !line.startsWith("#")) {
//                 // It's a key-value pair (not empty and not a comment)
//                 def keyValue = line.split('=').collect { it.split('#')[0].trim() }
//                 def key = keyValue[0]
//                 def val = keyValue[1]
//                 if ( !result.containsKey(key) ) {
//                     result[key] = val
//                 }
//                 else {
//                     throw new Exception("Key '$key' is duplicated in the parameter file.")
//                 }
//             }
//         }

//     } catch(Exception ex) {
//         println("ERROR:${new Object(){}.getClass().getEnclosingMethod().getName()}:$ex")
//         System.exit(1)
//     }

//     return result
// }

// //
// // Update the MSFragger parameter file with the provided parameters
// //
// def updateMsfParams(String ifile, replaces) {
//     // parse the MSF file
//     def param_data = parseMsfFile(ifile.toString())
//     // update the given attributes
//     try {
//         replaces.each { replace ->
//             if ( param_data.containsKey(replace.key) ) {
//                 param_data[replace.key] = replace.value
//             }
//             else {
//                 throw new Exception("Key '$replace.key' is not in the parameter file.")
//             }
//         }
//     } catch(Exception ex) {
//         println("ERROR:${new Object(){}.getClass().getEnclosingMethod().getName()}:$ex")
//         System.exit(1)
//     }
//     return param_data
// }
