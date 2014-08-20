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

// local copies with additions and overrides (workflow level)
workflow.VARIABLES = copyVariables(VARIABLES);
if(workflow.variables && workflow.variables.length > 0) {
    var name, value;
    for(var v = 0; v < workflow.variables.length; v++) {
        name = workflow.variables[v];
        value = workflow.variable[name].value;
        workflow.VARIABLES[name] = value;
    }
}

// local copies with additions and overrides (job level)
var job;
while(job = workflow.nextJob()) {
    job.VARIABLES = copyVariables(workflow.VARIABLES);
    if(job.variables && job.variables.length > 0) {
        var name, value;
        for(var v = 0; v < job.variables.length; v++) {
            name = job.variables[v];
            value = job.variable[name].value;
            job.VARIABLES[name] = value;
        }
    }
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
replaceVariables(VARIABLES, workflow);
