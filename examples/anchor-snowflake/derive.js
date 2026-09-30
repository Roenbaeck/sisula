// derive.js: the values the Snowflake templates need that Anchor's sisulets compute with helper
// functions at generation time. The resolver runs it after Helpers.js and the naming
// conventions, in the same scope, so it can use their helpers and iterators.
//
// Only facts are derived here, never SQL. Where a sisulet calls columnCommentClause(x) or
// viewCommentClause(x), both thin wrappers over describe(x) in SQL/Snowflake/NamingConvention.js,
// the template reads x.comment and writes the COMMENT clause itself.
//
//   comment      the description as the body of a Snowflake string literal (describe(x)), or null
//   hasComment   whether there is one. Tested instead of `comment`, which a template would read
//                as false for a description that is literally "0", "false" or "null".

function deriveComment(construct) {
    var comment = describe(construct);
    construct.comment = comment;
    construct.hasComment = comment !== null;
}

deriveComment(schema);

var knot;
while (knot = schema.nextKnot()) deriveComment(knot);

var anchor;
while (anchor = schema.nextAnchor()) deriveComment(anchor);

var attribute;
while (attribute = schema.nextAttribute()) deriveComment(attribute);

var nexus, role;
while (nexus = schema.nextNexus()) {
    deriveComment(nexus);
    while (role = nexus.nextRole()) deriveComment(role);
}

var tie;
while (tie = schema.nextTie()) {
    deriveComment(tie);
    while (role = tie.nextRole()) deriveComment(role);
}
