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
var job, j = 0;
while(job = workflow.job[workflow.jobs[j++]]) {
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


// do the actual replacement
replaceVariables(VARIABLES, workflow.variable);

if(workflow.variables && workflow.variables.length > 0) {
    for(var v = 0; v < workflow.variables.length; v++) {
        var name = workflow.variables[v];
        var resolvedValue = workflow.variable[name].value;
        workflow.VARIABLES[name] = resolvedValue;
    }
}

replaceVariables(workflow.VARIABLES, workflow);
