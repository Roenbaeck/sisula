// resolve-model.js: turns an Anchor model into the JSON bindings the Sisula templates render.
//
//   var bindings = resolveModel(dom, MAP, preludeScripts);
//
// It does not reimplement Anchor's model logic. It builds the same `schema` object the Anchor
// Modeler builds (objectify, then Helpers.js and the naming conventions, unchanged), and then
// flattens that object into plain acyclic data:
//
//   - keyed maps plus their id lists (knot/knots, anchor/anchors, role/roles, ...) become one
//     array of objects, so templates can `foreach` over them;
//   - isX()/hasX() predicates are called once and stored as booleans under the same name;
//   - iterator plumbing and other functions are dropped;
//   - back-references (parent, knot, anchor, nexus, entity) become shallow summaries, which is
//     what breaks the cycles. A summary holds the scalar fields, the predicates and the
//     metadata/description of the referenced object, not its collections.
//
// `schema.attributes` is the modeler's global attribute list (`allAttributes`), in its order.
// ES5 only: this runs under Jint as well as in Node and browsers.

// Copied from the Anchor Modeler's modules/Sisulator.js, where it is `Sisulator.objectify`. It
// is written against the DOM and needs nothing else, so any DOM-shaped document works.
function objectify(xml, map) {
    var listSuffix = 's';
    function objectifier(xmlFragment, map, object) {
        // element node
        if (xmlFragment.nodeType === 1) {
            // if there are children or attributes we need a container
            if (xmlFragment.attributes.length > 0 || xmlFragment.firstChild) {
                if (!object[xmlFragment.nodeName])
                    object[xmlFragment.nodeName] = new Object();
                var partialObject = object[xmlFragment.nodeName];
                if (typeof map.key[xmlFragment.nodeName] === 'function') {
                    var key = map.key[xmlFragment.nodeName](xml, xmlFragment);
                    if (key) {
                        partialObject = partialObject[key] = new Object();
                        partialObject.id = key;
                        var name = xmlFragment.nodeName + listSuffix;
                        name = map.replacer ? map.replacer(name) : name;
                        // reference the object from the array
                        if (!object[name])
                            object[name] = [];
                        object[name].push(key);
                    }
                }
                // process attributes
                if (xmlFragment.attributes.length > 0) {
                    for (var j = 0; j < xmlFragment.attributes.length; j++) {
                        var attribute = xmlFragment.attributes.item(j);
                        partialObject[attribute.nodeName] = attribute.nodeValue;
                    }
                }
                // process children
                var child = xmlFragment.firstChild;
                if (child) objectifier(child, map, partialObject);
            }
        }
        // text node
        else if (xmlFragment.nodeType === 3) {
            // add content with underscore naming
            if (xmlFragment.nodeValue)
                object['_' + xmlFragment.parentNode.nodeName] = xmlFragment.nodeValue;
        }
        // process siblings
        var sibling = xmlFragment.nextSibling;
        if (sibling) objectifier(sibling, map, object);
        return object;
    }
    return objectifier(xml.documentElement, map, {});
}

// Properties that point back at another entity. They are serialised as summaries.
var REFERENCES = { parent: 1, knot: 1, anchor: 1, nexus: 1, entity: 1 };
// Inside an entity's `keys` (route -> stops), these point at entities too.
var KEY_REFERENCES = { attribute: 1, tie: 1, role: 1, anchor: 1 };

function isArray(v) { return Object.prototype.toString.call(v) === '[object Array]'; }
function isObject(v) { return v !== null && typeof v === 'object' && !isArray(v); }
function isBlank(s) { return typeof s === 'string' && !/\S/.test(s); }
function isPredicate(name) { return /^(is|has)[A-Z]/.test(name) && !/^(isFirst|hasMore)/.test(name); }

function allIn(ids, map) {
    for (var i = 0; i < ids.length; i++) {
        if (typeof ids[i] !== 'string' || !Object.prototype.hasOwnProperty.call(map, ids[i])) return false;
    }
    return true;
}

// Finds the keyed map that an array of ids points into. The map named after the array without
// its plural 's' wins (roles/role, knotRoles/knotRole); otherwise any sibling map holding all ids.
function findMap(obj, name, ids) {
    var single = name === 'nexuses' ? 'nexus' : name.replace(/s$/, '');
    if (single !== name && isObject(obj[single]) && allIn(ids, obj[single])) return { key: single, map: obj[single], paired: true };
    for (var k in obj) {
        if (Object.prototype.hasOwnProperty.call(obj, k) && k !== name && isObject(obj[k]) && allIn(ids, obj[k])) {
            return { key: k, map: obj[k], paired: false };
        }
    }
    return null;
}

function serializeSchema(schema) {
    function serializeValue(v, inKeys) {
        if (isArray(v)) {
            var items = [];
            for (var i = 0; i < v.length; i++) items.push(serializeValue(v[i], inKeys));
            return items;
        }
        if (isObject(v)) return serializeObject(v, false, inKeys);
        return v;
    }

    function serializeObject(obj, summary, inKeys) {
        var out = {}, handled = {}, name, v;

        // Id lists become arrays of the objects they point at.
        if (!summary) {
            for (name in obj) {
                if (!Object.prototype.hasOwnProperty.call(obj, name)) continue;
                v = obj[name];
                if (!isArray(v) || v.length === 0 || typeof v[0] !== 'string') continue;
                var found = findMap(obj, name, v);
                if (!found) continue;
                var resolved = [];
                for (var i = 0; i < v.length; i++) resolved.push(serializeValue(found.map[v[i]], inKeys));
                out[name] = resolved;
                handled[name] = true;
                if (found.paired) handled[found.key] = true;
            }
        }

        for (name in obj) {
            if (!Object.prototype.hasOwnProperty.call(obj, name) || handled[name]) continue;
            v = obj[name];
            if (typeof v === 'function') {
                if (isPredicate(name)) out[name] = !!v.call(obj);
                else if (name === 'getEncryptionGroup') out.encryptionGroup = v.call(obj) || null;
                continue;
            }
            if (v === undefined) continue;
            // Internals start with an underscore. Text content is stored the same way
            // (`_description`), but whitespace between elements is noise.
            if (name.charAt(0) === '_' && !(typeof v === 'string' && !isBlank(v))) continue;
            if (isObject(v) && (REFERENCES[name] || (inKeys && KEY_REFERENCES[name]))) {
                out[name] = serializeObject(v, true, false);
            } else if (summary) {
                if (!isObject(v) || name === 'metadata' || name === 'description') out[name] = serializeValue(v, false);
            } else {
                out[name] = serializeValue(v, inKeys || name === 'keys');
            }
        }
        return out;
    }

    var result = serializeObject(schema, false, false);
    // The modeler's global attribute list, under a name that reads naturally in templates.
    result.attributes = serializeValue(schema.allAttributes, false);
    delete result.allAttributes;
    return result;
}

// dom: a DOM-shaped document. MAP: Anchor's map. preludeScripts: the texts of Helpers.js and the
// naming conventions, in the order the directive lists them.
function resolveModel(dom, MAP, preludeScripts) {
    var schema = objectify(dom, MAP)[MAP.root];
    var run = new Function('schema', 'DEBUG', 'alert', 'console', preludeScripts.join('\n'));
    run(schema, false, function () {}, { log: function () {}, error: function () {} });
    return { schema: serializeSchema(schema) };
}
