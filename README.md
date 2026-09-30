sisula
======

sisula, short for "simple substitution language", is a small template language for producing text, typically SQL, from structured data.

This repository holds the **core engine**: one renderer, one language reference and one set of conformance fixtures that every host implementation is checked against.

| Path | Contents |
|---|---|
| `core/sisula.js` | The renderer. Plain ES5, no dependencies, no `eval`. `sisulate(template, bindingsJson)` returns the rendered text. |
| `docs/LANGUAGE.md` | The language reference. |
| `tests/fixtures/*.json` | Conformance cases: `{ name, template, bindings, expected }`. Language-neutral, so other implementations can run them too. |
| `tests/run.js` | Runs the fixtures with Node: `node tests/run.js`. |
| `tests/run.ps1` | Runs the fixtures with Jint, where Node is not installed: `powershell -File tests\run.ps1`. |
| `lib/` | Jint 2.11.58 (BSD 2-Clause), the ES5 engine the PowerShell runners use. See `lib/README.md`. |
| `examples/anchor-snowflake/` | The Anchor Modeler's Snowflake uni-temporal generator as Sisula templates, byte-identical to the modeler's output. See its README. |

### Hosts

`core/sisula.js` runs unchanged as a Snowflake JavaScript UDF, in a browser, in Node and in ES5 engines such as Jint. `sisula-mssql` implements the same language in C# for SQLCLR and is kept in step by running the same fixtures. A change to the language starts here: add a fixture, make it pass in `core/sisula.js`, then bring the other implementations up to it.

### The previous engine

Earlier versions of this repository held a different engine (the "Sisulator"), which translated templates to JScript with regular expressions and evaluated the result against an object built from XML. That dialect lives on in the ETL framework, which is moving to its own repository, and in the Anchor Modeler's built-in generator. The history is preserved on the `ETL` branch.

### History

sisula was introduced in [Anchor Modeling](http://www.anchormodeling.com) in order to replace XSLT for producing text output.
