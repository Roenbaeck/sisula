// resolve-model.js: turns an Anchor model into the JSON bindings that the Sisula templates render.
//
//   var bindings = resolveModel(dom, MAP, scripts);
//
// It is a few lines on top of Anchor's own code, which must be loaded first: Sisulator.objectify
// (modules/Sisulator.js) builds the `schema` object from the DOM, and Resolver.resolve
// (modules/Resolver.js) runs the scripts on it (Helpers.js, the naming conventions, derive.js, in the
// order of the directive) and flattens it to plain data. This is the same path that the modeler's
// Generate > JSON bindings takes. ES5 only: this runs under Jint as well as in browsers.
function resolveModel(dom, MAP, scripts) {
    var schema = Sisulator.objectify(dom, MAP)[MAP.root];
    return { schema: Resolver.resolve(schema, scripts) };
}
