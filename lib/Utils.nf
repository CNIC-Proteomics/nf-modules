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


/*
========================================================================================
    LOCAL FUNCIOTNS
========================================================================================
*/

//
// Define a function to check if a path is absolute
//
boolean isAbsolutePath(String path) {
    return new File(path).isAbsolute()
}

//
// Define a function to convert a relative path to an absolute path
//
String toAbsolutePath(String path) {
    return new File(path).absolutePath
}

//
// Get path of a file with the absolute path
//
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
        

//
// Retrieves the name file without extension
//
def getBaseName(filePath) {
    def basename = new File(filePath).getBaseName()
    return basename
}

//
// Get the method name
//
def getCurrentMethodName(){
    def marker = new Throwable()
    return StackTraceUtils.sanitize(marker).stackTrace[1].methodName
}

//
// Function to check if at least one element of a list exists in a JSON object
//
def checkIfAnyParamExist(params, required_params) {
    for (param in required_params) {
        if (params.containsKey(param)) {
            return true
        }
    }
    return false
}

//
// Define a function to check which parameters are missing
//
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

//
// Print an error message for the missing parameters
//
def printErrorMissingParams(params, required_params) {
    // check which parameters are missing in the dict
    def missingParams = getMissingParams(params, required_params)
    // stop from the missing parameters
    if (!missingParams.isEmpty()) {
        exit 1, "ERROR: Missing parameters: ${missingParams}"
    }
}

//
// Join two channels based on the file name
//
def joinChannelsFromFilename(ifiles1, ifiles2) {

    // create a list of tuples with the base name and the file name.
    def files1 = ifiles1
                    // .flatten()
                    .map{  file -> tuple(file.baseName, file) }
                    // .view()
                    // .set { files1 }

    // create a list of tuples with the base name and the file name.
    def files2 = ifiles2
                    .map { file -> tuple(file.baseName, file) }
                    // .view()
                    // .set { files2 }

    // join both channels based on the first element (base name)
    def files3 = files1
                    .join(files2)
                    .map { name, f1, f2 -> [f1, f2] }
                    // .view { "value: $it" }
                    // .set { files3 }

    return files3
}


//
// Joins two channels based on file name prefix matching
// Return A channel containing tuples of paired files where one file name starts with the prefix of the other.
//
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

// //
// // Join two channels based on the prefix of filenames (up to the last underscore)
// //
// def joinChannelsFromPrefix(ifiles1, ifiles2) {

//     // create a list of tuples with the prefix and the file
//     def files1 = ifiles1
//                     .map { file ->
//                         def baseName = file.baseName
//                         def prefix = baseName.substring(0, baseName.lastIndexOf('_'))
//                         tuple(prefix, file)
//                     }
//                     .view()
//                     // .set { files1 }


//     // create a list of tuples with the prefix and the file
//     def files2 = ifiles2
//                     .map { file ->
//                         def baseName = file.baseName
//                         def prefix = baseName.substring(0, baseName.lastIndexOf('_'))
//                         tuple(prefix, file)
//                     }
//                     .view()
//                     // .set { files2 }

//     // join both channels based on the extracted prefix
//     def files3 = files1
//                     .join(files2)
//                     .map { prefix, f1, f2 -> [f1, f2] }
//                     .view { "value: $it" }
//                     // .set { files3 }

//     return files3
// }

//
// Print file from the given string
//
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

//
// Create String in Ini format from report (map of sections: {key,value}
//
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

//
// Create report (list of maps) from an INI file
//
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
                    // Add the key-value pair to the current section
                    result[currentSection][keyValue[0]] = keyValue[1]
                }
            }
        }
    } catch(Exception ex) {
        println("ERROR: ${new Object(){}.getClass().getEnclosingMethod().getName()}: $ex.")
        System.exit(1)
    }
    return result
}

//
// Extract the parameter section from a parameter file (INI)
//
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

//
// Update the parameter file (INI) with the provided parameters
//
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

//
// Extract the parameter section from a parameter file (INI)
//
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

//
// Define the functions to update parameters and merge INI files.
// Return the final updated params file path.
//
def updateParams(params, params_file) {
    def redefinedParams = ['decoyprefix': params.decoy_prefix, 'decoy_prefix': params.decoy_prefix]
    def updated_params_str = updateParamsFile(params.fixed_params_file, redefinedParams)
    def fixed_params_file = writeStrIntoFile(updated_params_str, "${params.paramdir}/params.ini")

    def merged_params_str = mergeIniFiles(fixed_params_file, params_file)
    def updated_params_file = writeStrIntoFile(merged_params_str, "${params.paramdir}/params.ini")

    return updated_params_file
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
