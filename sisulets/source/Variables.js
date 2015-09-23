// local copies with additions and overrides (source level)
source.VARIABLES = copyVariables(VARIABLES);
if(source.variables && source.variables.length > 0) {
    var name, value;
    for(var v = 0; v < source.variables.length; v++) {
        name = source.variables[v];
        value = source.variable[name].value;
        source.VARIABLES[name] = value;
    }
}

// local copies with additions and overrides (part level)
var part, j = 0;
while(part = source.part[source.parts[j++]]) {
    part.VARIABLES = copyVariables(source.VARIABLES);
    if(part.variables && part.variables.length > 0) {
        var name, value;
        for(var v = 0; v < part.variables.length; v++) {
            name = part.variables[v];
            value = part.variable[name].value;
            part.VARIABLES[name] = value;
        }
    }
}

// do the actual replacement
replaceVariables(VARIABLES, source);

// global
var MAXLEN = 2147483647;
var S_SCHEMA = VARIABLES.SourceSchema ? VARIABLES.SourceSchema : 'dbo';
var T_SCHEMA = VARIABLES.TargetSchema ? VARIABLES.TargetSchema : 'dbo';
