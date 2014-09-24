// create some qualified names
var load;
while(load = target.nextLoad()) {
    load.qualified = load.target + '__' + load.source;
}
