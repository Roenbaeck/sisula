var load, map;
while(load = target.nextLoad()) {
    load.targetTable = load.anchor || load.target.match(/l(.*)/)[1];
    load.anchorMnemonic = (load.anchor && load.anchor.match(/(..)\_.*/)[1]) || load.target.match(/l(..)\_.*/)[1];
    load.toAnchor = function() {
        return load.anchor || load.target.match(/^l..\_[^\_]*$/);
    }
    while(map = load.nextMap()) {
        map.isValueColumn = function() {
            return map.attribute && !map.target.match(/^.*\_(ChangedAt|ID)$/) && !map.target.match(/^Metadata\_.*$/);
        }
    }
}
