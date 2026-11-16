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
| `examples/anchor/` | What checks the Anchor Modeler's Sisula templates for Snowflake and SQL Server (uni, bi and crt), which live in the Anchor repository: the models, the golden files, the tools that compare, and tests of what the SQL Server triggers do. See its README. |

### Hosts

`core/sisula.js` runs unchanged as a Snowflake JavaScript UDF, in a browser, in Node and in ES5 engines such as Jint. `sisula-mssql` implements the same language in C# for SQLCLR and is kept in step by running the same fixtures. A change to the language starts here: add a fixture, make it pass in `core/sisula.js`, then bring the other implementations up to it.

### The previous engine

Earlier versions of this repository held a different engine, the "Sisulator", which translated templates to JScript with regular expressions and evaluated the result against an object built from XML. It is retired. It is no longer here, and since 2026-11-16 it is not in the Anchor Modeler (0.101.16: `modules/Objectifier.js` turns a model into the object that the bindings are made from, and the templates are rendered by this engine) or in the ETL framework [dw-framework](https://github.com/Roenbaeck/dw-framework) either, which renders every output with this engine too. The old code is in their histories: Anchor before `cec2a7b`, dw-framework before `7e620ea` (its last commit that has `Sisulator.js` is `273eccf`), and the full history of the old ETL branch is in dw-framework.

### History

sisula was introduced in [Anchor Modeling](http://www.anchormodeling.com) in order to replace XSLT for producing text output.
