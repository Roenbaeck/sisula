# Anchor to Snowflake, in Sisula dialect B

The Anchor Modeler's Snowflake generators (uni-, bi- and concurrent-reliance-temporal), ported from
JScript sisulets that are `eval`'d against a live object graph to declarative Sisula templates
over JSON.

**The templates live in the Anchor repository now**, as `SQL/Snowflake/{uni,bi,crt}/*.sisula`, listed by
Anchor's `Snowflake_{uni,bi,crt}.directive`, and the modeler renders them with the vendored engine
(`modules/sisula.js`). This folder is what proves them: the models, the golden files made by the
original engine, and the tools that compare. Anchor's `Snowflake_*.legacy.directive` and the
original `.js` sisulets are kept for as long as the golden files are made from them.

The port is complete for what the modeler generates: 13 templates for uni, 10 for bi and 11 for crt
(bi and crt share uni's `AddDescriptions`). For every model in `models/` the output is
**byte-identical** to the original engine's, checked these ways:

| Check | Compares | Needs |
|---|---|---|
| `tools\run-all.ps1` | Anchor's templates' output, per template and as a whole, with the golden files | PowerShell, an Anchor checkout |
| `tools\csharp-check.ps1` | the same templates and bindings through the C# renderer that runs inside SQL Server | an Anchor checkout, `sisula-mssql`'s `FixtureRunner.exe` |
| `tools\regenerate-golden.ps1` | makes the golden files: the modeler's original engine and sisulets, run under Jint | an Anchor checkout |
| `tools\browser-check.ps1` | the golden files with the modeler itself: its `index.html` in headless Edge, opening the model and pressing Generate SQL | an Anchor checkout, Edge |

The golden files are committed, so the everyday check, `run-all.ps1`, needs only PowerShell and
the Anchor checkout next to this repository.
The engines run under the Jint in `../../lib`; there is no Node on the development machine.

## How it works

```
model.xml --xml-to-tree--> neutral tree --dom-facade--> DOM
   DOM --Sisulator.objectify, then the scripts the directive starts with--> schema
   schema --Resolver.resolve--> bindings JSON --sisulate(template), in directive order--> SQL
```

All of it is Anchor's own code, read from the checkout; the tools here only supply a DOM (Jint has
none) and compare.

- `Resolver.resolve` (Anchor's `modules/Resolver.js`) builds the `schema` object the modeler
  builds by running the scripts that the directive starts with: `Helpers.js`,
  `NamingConvention.js`, `Snowflake/NamingConvention.js` and `Snowflake/derive.js`. Then it
  flattens it: keyed maps and id lists become arrays, `isX()`/`hasX()` predicates become booleans,
  back-references (`parent`, `knot`, `entity`, ...) become shallow summaries. Templates never see
  a function or a cycle. `tools/resolve-model.js` is the few lines that call it.
- `SQL/Snowflake/derive.js` runs in the same scope, after the naming conventions. It computes what
  the sisulets compute with helper functions and small expressions at generation time. For Snowflake
  uni that is the description as the body of a string literal, `comment`, which is what
  `describe()` returns (the templates write the `COMMENT` clauses themselves), and the number of
  attributes and roles of the constructs that print one in a header comment.
- `SQL/Snowflake/uni/*.sisula` are the ports, one per sisulet, rendered in the order of Anchor's
  `Snowflake_uni.directive`. `check.ps1` fails if that list differs from the legacy directive's,
  which the golden files come from.

Helper functions become data, never language features: a helper's result is a fact about the
model, so the resolver computes it once and passes it along in the JSON. That keeps the language
small, which matters because the C# implementation must follow every feature.

## Models

`models/base.xml` is the Anchor Modeler's Snowflake example. `tools/make-variants.ps1` derives
the others from it by text edits and then saves each one through the modeler itself
(`browser-check.ps1 -Canonicalize`). The last step matters: when the modeler loads a file it
fills every flag the file leaves out from its defaults (a knot without `equivalent` becomes
equivalent when the model's equivalence setting is on), applies its own rules (a knotted
attribute is never equivalent, a tie role without a description gets its anchor's), and writes
all of it when it saves. A hand-edited file can therefore mean something else to the modeler
than to the engine reading it directly. Saving it once through the modeler removes that
difference; saving it again changes nothing, and `base.xml` itself comes back byte-identical.

**A model says which temporalization it is for** (`metadata/@temporalization`), and the tools take
the directive, the scripts that prepare the schema and the templates from that (`tools/directive.ps1`).
There are 11 models for each of uni, bi and crt: the models below, named `<name>-bi` and `<name>-crt`
for the other two, which differ from the uni ones only in that setting, and `flags` and `ranges`, which
exist for all three (listed after the table). The original sisulets of bi and crt failed with a syntax
error in four of them when this was begun, so the golden files for those two exist because eight
places were corrected first; the defects that remain are listed in Anchor's `HANDOVER-sisula-port.md`.

| Model | Reaches |
|---|---|
| `base` | all four attribute flavours, knotted and historized ties, identifiers and one-to-one ties, a nexus with anchor and knot roles, a tie with a nexus role, checksums, descriptions |
| `equivalence` | equivalence on: equivalent and non-equivalent knots (one equivalent knot is a generator), equivalent historized and static attributes with checksums |
| `equivalence-plain` | the same without metadata columns, which reaches the dummy columns |
| `plain` | no metadata columns, the original naming convention, partitioning |
| `undescribed` | no descriptions: no comments and no `COMMENT` clauses |
| `distinct` | a different capsule for every kind of construct and a different identity type for every anchor and nexus, so a template taking a name or type from the wrong construct shows; non-generator anchors and nexus, checksummed knots, historized and knotted nexus attributes (the nexus difference perspective), a historized tie with a nexus role and no identifiers, an encrypted attribute, some constructs without descriptions |
| `distinct-equivalence` | distinct with equivalence on and equivalent knots and attributes of every kind, nexus attributes included |
| `equivalence-original` | distinct-equivalence with the original naming convention, where knotted columns have no equivalent or checksum names |
| `handwritten` | not saved through the modeler, on purpose: equivalent flags with equivalence off, roles without descriptions. Checked against the original engine only, which shows the templates test exactly what the sisulets test, also on files the modeler did not write |
| `flags` | `distinct-equivalence` with restatement, idempotency, assertiveness and decisiveness turned over, so the code that tests them is reached both ways |
| `ranges` | `distinct` with a type and a suffix of its own for everything that belongs to the posit, positor and reliability columns, so a template that takes one from the wrong place shows |

To see that these models can tell a correct template from a wrong one, five plausible bugs were
planted in the templates one at a time. Each was caught by at least one model, and none by
`base`, `equivalence`, `equivalence-plain` or `plain` alone:

| Planted bug | Caught by |
|---|---|
| the capsule of the attribute instead of its anchor in a foreign key | `distinct` and the models derived from it |
| the schema's default identity type instead of the anchor's | `distinct` and the models derived from it |
| equivalent knot tables without testing `schema.EQUIVALENCE` | `handwritten` |
| a view `COMMENT` written whether or not there is a description | `undescribed`, `distinct` and the models derived from it |
| no `UNION` between the selects of a nexus difference perspective | `distinct` and the models derived from it |

## Checking

```
powershell -File tools\run-all.ps1                      # the templates against the golden files
powershell -File tools\check.ps1 -Variant base -Loose   # one model, ignoring blank lines and trailing spaces
powershell -File tools\regenerate-golden.ps1            # after a change to Anchor's sisulets
powershell -File tools\browser-check.ps1                # the golden files against the modeler
powershell -File tools\browser-check.ps1 -Bindings      # the modeler's Generate > JSON bindings against the resolver's
powershell -File tools\make-variants.ps1                # after a change to base.xml
```

`golden.ps1` runs Anchor's `Sisulator.js`, `Map.js`, `Helpers.js` and sisulets, read from the
checkout, under Jint. The only change is stripping `async`/`await`, which Jint 2 cannot parse. It
runs the whole directive and splits the output per sisulet by having each one append a marker
line first; the parts are checked to add up to the unmarked output exactly.

`browser-check.ps1` leaves the Anchor checkout alone. It copies `index.html` to a temporary
folder with a `<base>` pointing at the checkout, drops the two Google Fonts links so no network
is needed, answers the modeler's dialogs (accepting the model's settings, as a user would),
serves `fetch()` through `XMLHttpRequest` because Chromium's `fetch` cannot read `file://`, and
captures what `Actions.generateSQL` would display.

## Porting the sisulets

The original engine translates templates to JScript with regular expressions, then removes
blank lines and runs of spaces after the text is generated. The templates here produce that
final text directly, trailing spaces included. The patterns:

| Original | Dialect B |
|---|---|
| `while (x = schema.nextX())` | `$/ foreach x in schema.xs` |
| `x.hasMoreY()` as "not the last one" | `not y.last()` inside `$/ foreach y in x.ys` |
| `x.hasMoreY()` before the loop, "has any" | `$/ if x.ys` (an empty array is false) |
| `$(c)? A : B` | `$/ if c A $/ else B$/ endif`, which keeps the space before the colon as the original does |
| `$(c)? A` on a line of its own | a block `$/ if c` ... `$/ endif`, so the line is dropped when false |
| `X$(c)?,` | `X$/ if c ,$/ endif` |
| `/*~;~*/` after the last loop item | `$/ if y.last() ;$/ endif` on each line that can be the last one |
| `$x.y`, `${x.y}$`, `${a + b}$` | `$x.y$` always; adjacent tokens `$a$$b$` |
| `!c`, `a && b`, `a \|\| b` | `not c`, `a and b`, `a or b` |
| `var t = c ? x : y` used later | the condition at the point of use |
| `$$$$` (an escaped `$$`) | `$$` |
| `x.attributes ? x.attributes.length : 0` | `$x.attributeCount$`, from `derive.js`: a path reaches only what the JSON holds, and JSON arrays have no `length` |
| `columnCommentClause(x)` | `$/ if x.hasComment $x.name$ COMMENT '$x.comment$'$/ else $x.name$$/ endif` |

Whitespace rules to know:

- A space after `$/ endif` is swallowed, and so is the whitespace between the condition and a
  branch. Put spaces inside a branch: `$/ if x $x$ $/ else 0 $/ endif units`.
- A line that holds only an inline `if` becomes an empty line when the branch is empty. Use a
  block `if` to drop a whole line.
- A trailing space the output needs, where no `$/ else` carries it, is written `x $--$`: the
  empty inline comment keeps editors from trimming the space. The original emits a few.
- An inline `if` cannot contain another inline `if`. Use block `if`s for nested choices.

## Engine changes the port needed

All in `core/sisula.js`, each with fixtures in `tests/fixtures/`, and each to be brought to the
C# implementation:

- `not` and `!` in conditions (they silently evaluated false before), and an error for a
  condition that cannot be parsed.
- An empty array is false.
- A line holding a complete inline `if` or `foreach` no longer counts as opening a block. Before,
  `$/ if c A $/ else B$/ endif` alone on a line inside a block `if` hid that block's `$/ else`.

## Observations about the original

Reproduced as they are, since the output must match. They are worth fixing in Anchor, after
which the golden files and templates change together.

- `CreateEquivalentAndDefault.js` writes `$schema.metadata.encapsulation._$schema.metadata.equivalentSuffix`,
  meaning `public._EQ`, but the tokenizer ends the first token at the second `$`. The generated
  SQL creates and merges into a table literally named `schema.metadata.equivalentSuffix`.
- `tie.isKnotted()` in `Helpers.js` returns `!!this['knotRole']`, but `knotRole` is set to `{}`
  for every tie, so every tie is knotted. Ties without a knot role get the header comment
  "Knotted static tie table". Only the comment is affected.
- With the original naming convention, knotted attributes and knot roles have no
  `knotEquivalentColumnName` or `knotChecksumColumnName`, so the perspectives emit empty column
  names, such as a line reading `    ,`, for equivalent or checksummed knots.
- Several sisulets test `knot.isEquivalent()` without `schema.EQUIVALENCE`, so a knot marked
  equivalent in a model with equivalence off is referenced through tables and functions that are
  never created. The modeler never saves such a model; a hand-written file can contain one.
- In the key-naming pass of `NamingConvention.js`, `role` leaks from one stop to the next.

## Other notes

- The bindings hold both `schema.metadata` and `schema.METADATA`. JSON readers that ignore case,
  such as PowerShell's `ConvertFrom-Json`, reject that; the real parsers do not.
- An object that appears in several lists is serialised in full each time, so the bindings are
  about half a megabyte for a 14 KB model. References by id would scale better.
- The resolver reads Anchor's `Map.js`, `Helpers.js` and naming conventions from a checkout next
  to this repository. Where the port ends up living decides whether they are vendored.

## Not done

- The planted-bug check above was done for uni only. For bi and crt the agreement with the original
  engine on 11 models each is the evidence; no bugs were planted.
- The Snowflake sisulets that the directive does not enable: triggers, key generators,
  restatement constraints, business perspectives and schema tracking. The modeler does not
  generate them for Snowflake.
