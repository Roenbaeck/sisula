// set up some iterators for the different components
target._iterator = {};
target._iterator.load = 0;
target._iterator.map = 0;

// default temporalization
target.temporalization = target.temporalization ? target.temporalization : 'uni';

// set up helpers for loads
target.nextLoad = function() {
    if(!this.loads) return null;
    if(target._iterator.load == this.loads.length) {
        target._iterator.load = 0;
        return null;
    }
    return this.load[this.loads[target._iterator.load++]];
};
target.hasMoreLoads = function() {
    if(!this.loads) return false;
    return target._iterator.load < this.loads.length;
};
target.isFirstLoad = function() {
    return target._iterator.load == 1;
};
target.hasLoad = function(load) {
    return this.loads.indexOf(load.name) >= 0;
};

var load, map;
while(load = target.nextLoad()) {
    load.targetTable = load.anchor || load.target.match(/l(.*)/)[1];
    load.anchorMnemonic = (load.anchor && load.anchor.match(/(..)\_.*/)[1]) || load.target.match(/l(..)\_.*/)[1];
    load.toAnchor = function() {
        return load.anchor || load.target.match(/^l..\_[^\_]*$/);
    }
    load.nextMap = function() {
        if(!this.maps) return null;
        if(target._iterator.map == this.maps.length) {
            target._iterator.map = 0;
            return null;
        }
        return this.map[this.maps[target._iterator.map++]];
    };
    load.hasMoreMaps = function() {
        if(!this.maps) return false;
        return target._iterator.map < this.maps.length;
    };
    load.isFirstMap = function() {
        return target._iterator.map == 1;
    };
    load.hasMap = function(map) {
        return this.maps.indexOf(map.name) >= 0;
    };
    load.type = load.type ? load.type : 'merge';
    load.condition = load.condition && load.condition.singleton && load.condition.singleton._condition ? load.condition.singleton._condition : null;
}

while(load = target.nextLoad()) {
    while(map = load.nextMap()) {
        map.isValueColumn = function() {
            return map.attribute && !map.target.match(/^.*\_(ChangedAt|ID)$/) && !map.target.match(/^Metadata\_.*$/);
        }
    }
}
