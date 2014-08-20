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
source.hasMoreParts = function() {
    if(!this.parts) return false;
    return source._iterator.part < this.parts.length;
};
source.isFirstPart = function() {
    return source._iterator.part == 1;
};

var part;
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
}


