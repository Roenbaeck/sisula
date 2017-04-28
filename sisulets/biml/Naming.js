// create some qualified names
var load, pass;
while(load = target.nextLoad()) {
    pass = load.pass ? '__' + load.pass : '';
    load.qualified = load.target + '__' + load.source + pass;
}
