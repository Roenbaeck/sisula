// helper functions
function alert(str) {
    WScript.Echo(str);
}
function exit(code) {
    WScript.Quit(code);
}

// global variables 
ERROR = 42;
VALID = 0;

// This is the main() where we start with parsing the command line
var commandLineOptions = {
    _opts_:         {
                        // option, description, mandatory
        path:           ['-d', 'The path in which to search for matching filenames.', true],
        pattern:        ['-p', 'A filename pattern in regular expression format.', true]
    }
};
 
var o, option, description, map, list = 'Command line options:';
// if no arguments were provided then list the options and exit
if(WScript.Arguments.length == 0) {
    for(o in commandLineOptions._opts_) {
        option = commandLineOptions._opts_[o][0];
        description = commandLineOptions._opts_[o][1];
        list += '\n' + option + '\t' + description;
    }
    alert(list);
    exit(ERROR);
}
 
// ergo, we have arguments, so make them a regular array
var i, commandLineArguments = [];
for(i = 0; i < WScript.Arguments.length; i++)
    commandLineArguments.push(WScript.Arguments.Item(i));
 
// parse the given arguments
var pattern, argument, delim = ';';
var joinedArguments = commandLineArguments.join(delim);
for(o in commandLineOptions._opts_) {
    option = commandLineOptions._opts_[o][0];
    if(joinedArguments.indexOf(option) >= 0) {
        pattern = new RegExp(option + delim + '?([^' + delim + ']*)');
        argumentMatch = joinedArguments.match(pattern);
        if(argumentMatch) {
            commandLineOptions[o] = argumentMatch[1];
        }
    }
}
 
// check mandatory options and exit if not provided
var mandatory;
for(o in commandLineOptions._opts_) {
    mandatory = commandLineOptions._opts_[o][2];
    if(mandatory) {
        if(!commandLineOptions[o] || commandLineOptions[o].length == 0) {
            option = commandLineOptions._opts_[o][0];
            description = commandLineOptions._opts_[o][1];
            alert("The option " + option + " is mandatory with the description:\n" + description);
            exit(ERROR);
        }
    }
}

var pattern = new RegExp(commandLineOptions.pattern);
var reader = new ActiveXObject("Scripting.FileSystemObject");
var folder = reader.GetFolder(commandLineOptions.path);
var files = new Enumerator(folder.Files);
while(!files.atEnd()) {
    var path = files.item().path;
    var filename = files.item().name;
    var match = filename.match(pattern);
    if(match) alert(path);
    files.moveNext();
}

