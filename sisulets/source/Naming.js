// create some qualified names
source.qualified = source.name;
if(VARIABLES.System) source.qualified = VARIABLES.System + '_' + source.qualified;

var part;
while(part = source.nextPart()) {
    part.qualified = source.name + '_' + part.name;
    if(VARIABLES.System) part.qualified = VARIABLES.System + '_' + part.qualified;
}
