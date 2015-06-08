// set up some iterators for the different components
source._iterator = {};
source._iterator.part = 0;
source._iterator.term = 0;
source._iterator.calculation = 0;
source._iterator.key = 0;
source._iterator.component = 0;

// set up helpers for parts
source.nextPart = function() {
    if(!this.parts) return null;
    if(source._iterator.part == this.parts.length) {
        source._iterator.part = 0;
        return null;
    }
    return this.part[this.parts[source._iterator.part++]];
};
source.firstPart = function() {
    return this.part[this.parts[0]];
};
source.hasMoreParts = function() {
    if(!this.parts) return false;
    return source._iterator.part < this.parts.length;
};
source.isFirstPart = function() {
    return source._iterator.part == 1;
};
source.hasPart = function(part) {
    return this.parts.indexOf(part.name) >= 0;
};

var part, term, key;
while(part = source.nextPart()) {
    part.nextTerm = function() {
        if(!this.terms) return null;
        if(source._iterator.term == this.terms.length) {
            source._iterator.term = 0;
            return null;
        }
        return this.term[this.terms[source._iterator.term++]];
    };
    part.hasMoreTerms = function() {
        if(!this.terms) return false;
        return source._iterator.term < this.terms.length;
    };
    part.isFirstTerm = function() {
        return source._iterator.term == 1;
    };
    part.hasTerm = function(term) {
        return this.terms.indexOf(term.name) >= 0;
    };
    part.nextCalculation = function() {
        if(!this.calculations) return null;
        if(source._iterator.calculation == this.calculations.length) {
            source._iterator.calculation = 0;
            return null;
        }
        return this.calculation[this.calculations[source._iterator.calculation++]];
    };
    part.hasMoreCalculations = function() {
        if(!this.calculations) return false;
        return source._iterator.calculation < this.calculations.length;
    };
    part.isFirstCalculation = function() {
        return source._iterator.term == 1;
    };
    part.hasCalculation = function(calculation) {
        return this.calculations.indexOf(calculation.name) >= 0;
    };
    part.nextKey = function() {
        if(!this.keys) return null;
        if(source._iterator.key == this.keys.length) {
            source._iterator.key = 0;
            return null;
        }
        return this.key[this.keys[source._iterator.key++]];
    };
    part.hasMoreKeys = function() {
        if(!this.keys) return false;
        return source._iterator.key < this.keys.length;
    };
    part.isFirstKey = function() {
        return source._iterator.key == 1;
    };
    part.hasKey = function(key) {
        return this.keys.indexOf(key.name) >= 0;
    };
    while(key = part.nextKey()) {
        key.nextComponent = function() {
            if(!this.components) return null;
            if(source._iterator.component == this.components.length) {
                source._iterator.component = 0;
                return null;
            }
            return this.component[this.components[source._iterator.component++]];
        };
        key.hasMoreComponents = function() {
            if(!this.components) return false;
            return source._iterator.component < this.components.length;
        };
        key.isFirstComponent = function() {
            return source._iterator.component == 1;
        };
        key.hasComponent = function(component) {
            return this.components.indexOf(component.name) >= 0;
        };
    }
}


