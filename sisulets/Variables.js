// global variables are stored in the VARIABLE hash map
var VARIABLES = {};

// fetch environment variables
var oWshShell = new ActiveXObject ("WScript.Shell");
var oEnv = oWshShell.Environment("Process");
var oEnum = new Enumerator(oEnv);
while(!oEnum.atEnd()) {
    var match = oEnum.item().match(/(.*?)=(.*)/);
    if(match && match[1] && match[2]) {
        VARIABLES[match[1]] = match[2];
    }
    oEnum.moveNext();
}

// helper function to create copy a 'hash map'
function copyVariables(variables) {
    var copy = {};
    for(var v in variables) 
        copy[v] = variables[v];
    return copy;
}

// function used to replace variables
function replaceVariables(variables, obj) {
    variables = obj.VARIABLES || variables;
    var p, i, match, name, variableExpression = /%(.*?)%/g;
    for(p in obj) {
        switch(typeof obj[p]) {
            case 'string':
                match = obj[p].match(variableExpression);
                // check if string contains variable substitutions
                if(match) {
                    for(i = 0; i < match.length; i++) {
                        // workaround for buggy capturing groups in JScript
                        name = match[i].replace(/%/g, ''); 
                        // if that variable is also declared
                        if(variables[name]) {
                            // substitute
                            obj[p] = obj[p].replace('%' + name + '%', variables[name]);
                        }
                    }
                }
                break;
            case 'object':
                replaceVariables(variables, obj[p]);
                break;
            default:
                // do nothing for other types
        }
        match = p.match(variableExpression);
        var oldKey = p;
        // if the name of a 'key' also should be substituted
        if(match) {
            for(i = 0; i < match.length; i++) {
                // workaround for buggy capturing groups in JScript
                name = match[i].replace(/%/g, ''); 
                // if that variable is also declared
                if(variables[name]) {
                    // substitute
                    p = p.replace('%' + name + '%', variables[name]);
                }
            }
            obj[p] = obj[oldKey];
            delete obj[oldKey];            
        }        
    }
}

// in case we ever need to change the schema used for the metadata model it should be changed here (and only here)
var METADATA = VARIABLES.MetaDatabase ? true : false;
var METADATA_SCHEMA = "metadata";
var METADATABASE = VARIABLES.MetaDatabase;

