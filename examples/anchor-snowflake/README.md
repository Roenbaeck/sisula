# Anchor to Snowflake, uni-temporal, in Sisula dialect B

A feasibility spike: can the Anchor Modeler's Snowflake generator be expressed as declarative
Sisula templates over JSON, instead of JScript that is `eval`'d against a live object graph?

For the four table-creating sisulets (knots, anchors, attributes, ties) the answer is yes. The
templates in `templates/` reproduce the original output exactly, apart from blank lines and
trailing whitespace, for four model variants.

## How it works

```
model.xml --xml-to-tree--> neutral tree --dom-facade--> DOM
   DOM --objectify + Helpers.js + NamingConvention.js (unchanged)--> schema
   schema --serializeSchema--> bindings JSON --sisulate(template)--> SQL
```

- `tools/resolve-model.js` builds the same `schema` object the modeler builds, by running
  Anchor's own `Helpers.js` and naming conventions unchanged, and then flattens it: keyed maps
  and id lists become arrays, `isX()`/`hasX()` predicates become booleans, back-references become
  shallow summaries. Templates never see a function or a cycle.
- `templates/*.sisula` are the dialect B ports of `SQL/Snowflake/uni/Create{Knots,Anchors,Attributes,Ties}.js`.
- The XML step is DOM-agnostic. Here the DOM is a small facade over a tree made from .NET
  `XmlDocument`; in a browser it would be `DOMParser`, in Node `xmldom`.

## Checking

```
powershell -File tools\run-all.ps1
```

renders every template for every model in `models/` and compares it with `golden/<variant>/`.
Needs `Jint.dll` 2.x (see `-JintPath`) and nothing else; there is no Node on this machine.

| Variant | Reaches |
|---|---|
| `base` | the Anchor Modeler's Snowflake example: all four attribute flavours, knotted ties, identifiers, one-to-one ties, nexus attributes, checksums |
| `equivalence` | equivalent knots (identity and value tables), generator knots, equivalent attributes, references to equivalent knots |
| `plain` | no metadata columns, the original naming convention, partitioning |
| `equivalence-plain` | the dummy column equivalent knots get without metadata |

The golden files come from the **original** engine: `tools/golden.ps1` runs the Anchor Modeler's
`Sisulator.js`, `Map.js`, `Helpers.js` and sisulets, byte for byte from an Anchor checkout, under
Jint. The only change is stripping `async`/`await`, which Jint 2 cannot parse. They are committed, so
the checks do not need Anchor; `tools/regenerate-golden.ps1` rebuilds them. `tools/make-variants.ps1`
derives the variant models from `models/base.xml`.

Blank lines and trailing whitespace are ignored when comparing. The two engines treat the
newlines around `/*~ ~*/` blocks differently, which means nothing in SQL.

## What the port needed from the language

Two engine changes, both now in `core/sisula.js` with fixtures: `not`/`!` in conditions, and empty
arrays being falsy. Nothing else was missing for these sisulets: no variables, no includes.
Patterns that replace the original JScript:

| Original | Dialect B |
|---|---|
| `while (x = schema.nextX())` | `$/ foreach x in schema.xs` |
| `$(cond)? a : b` on one line | block `$/ if cond` ... `$/ else` ... `$/ endif` |
| `$x.y` and `${x.y}$` | `$x.y$` always, with a closing `$` |
| `tie.hasMoreRoles()` for separators | `$/ if not role.last() ,$/ endif` |
| `!cond` | `not cond` |
| `var knotTableName = ...` | an `if` on `knot.isEquivalent` at the point of use |
| `${a + b}$` | adjacent tokens: `$a$$b$` |

Whitespace: a space after `$/ endif` is swallowed, so put it inside the branch:
`$/ if x $x$ $/ else 0 $/ endif units`.

## Observations about the original

- `tie.isKnotted()` in `Helpers.js` returns `!!this['knotRole']`, but `knotRole` is initialised to
  `{}` for every tie, so it is true for all of them. Ties without a knot role get the header
  comment "Knotted static tie table". Only the comment is affected. Reproduced as is.
- In the key-naming pass of `NamingConvention.js`, `role` leaks from one stop to the next.
- The bindings hold both `schema.metadata` and `schema.METADATA`. JSON consumers that ignore case
  (PowerShell's `ConvertFrom-Json`) reject that; the real parsers do not.
- Every object that appears in several lists is serialised in full each time: about 480 KB of
  bindings for a 14 KB model. References by id would scale better.

## Not done

Everything else in `SQL/Snowflake/uni`: nexuses, the equivalence and default views, rewinders,
the perspectives (750 and 1,000 lines), descriptions and the rest. `bi` and `crt` as well. Several
of those use helper functions such as `describe()`, which is where dialect B will meet its first
real test.
