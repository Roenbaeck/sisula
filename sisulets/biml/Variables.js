// local copies with additions and overrides (target level)
target.VARIABLES = copyVariables(VARIABLES);
if(target.variables && target.variables.length > 0) {
    var name, value;
    for(var v = 0; v < target.variables.length; v++) {
        name = target.variables[v];
        value = target.variable[name].value;
        target.VARIABLES[name] = value;
    }
}

// local copies with additions and overrides (load level)
var load, j = 0;
while(load = target.load[target.loads[j++]]) {
    load.VARIABLES = copyVariables(target.VARIABLES);
    if(load.variables && load.variables.length > 0) {
        var name, value;
        for(var v = 0; v < load.variables.length; v++) {
            name = load.variables[v];
            value = load.variable[name].value;
            load.VARIABLES[name] = value;
        }
    }
}

// do the actual replacement
replaceVariables(VARIABLES, target);

// global
var MAXLEN = 2147483647;
var S_SCHEMA = VARIABLES.SourceSchema ? VARIABLES.SourceSchema : 'dbo';
var T_SCHEMA = VARIABLES.TargetSchema ? VARIABLES.TargetSchema : 'dbo';
