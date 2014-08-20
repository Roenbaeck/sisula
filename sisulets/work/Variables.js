// global variable
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
    for(var p in obj) {
        switch(typeof obj[p]) {
            case 'string':
                var match = obj[p].match(/%(.*)%/g);
                // check if string contains variable substitutions
                if(match) {
                    for(var i = 0; i < match.length; i++) {
                        // workaround for buggy capturing groups in JScript
                        var name = match[i].replace(/%/g, ''); 
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
    }
}

// do the actual replacement
replaceVariables(VARIABLES, source);
