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

// TODO: add helpers for keys and components in keys


// --------------------- MOZILLA POLYFILL ------------------------
if (!Array.prototype.indexOf) {
  Array.prototype.indexOf = function (searchElement, fromIndex) {

    var k;

    // 1. Let O be the result of calling ToObject passing
    //    the this value as the argument.
    if (this == null) {
      throw new TypeError('"this" is null or not defined');
    }

    var O = Object(this);

    // 2. Let lenValue be the result of calling the Get
    //    internal method of O with the argument "length".
    // 3. Let len be ToUint32(lenValue).
    var len = O.length >>> 0;

    // 4. If len is 0, return -1.
    if (len === 0) {
      return -1;
    }

    // 5. If argument fromIndex was passed let n be
    //    ToInteger(fromIndex); else let n be 0.
    var n = +fromIndex || 0;

    if (Math.abs(n) === Infinity) {
      n = 0;
    }

    // 6. If n >= len, return -1.
    if (n >= len) {
      return -1;
    }

    // 7. If n >= 0, then Let k be n.
    // 8. Else, n<0, Let k be len - abs(n).
    //    If k is less than 0, then let k be 0.
    k = Math.max(n >= 0 ? n : len - Math.abs(n), 0);

    // 9. Repeat, while k < len
    while (k < len) {
      // a. Let Pk be ToString(k).
      //   This is implicit for LHS operands of the in operator
      // b. Let kPresent be the result of calling the
      //    HasProperty internal method of O with argument Pk.
      //   This step can be combined with c
      // c. If kPresent is true, then
      //    i.  Let elementK be the result of calling the Get
      //        internal method of O with the argument ToString(k).
      //   ii.  Let same be the result of applying the
      //        Strict Equality Comparison Algorithm to
      //        searchElement and elementK.
      //  iii.  If same is true, return k.
      if (k in O && O[k] === searchElement) {
        return k;
      }
      k++;
    }
    return -1;
  };
}


