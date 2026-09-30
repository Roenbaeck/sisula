# Third-party binaries

| File | What | Source | License |
|---|---|---|---|
| `Jint.2.11.58.dll` | [Jint](https://github.com/sebastienros/jint) 2.11.58, an ES5 JavaScript interpreter for .NET. The PowerShell test runners use it to run `core/sisula.js` where Node is not installed. | NuGet package `Jint` 2.11.58 | BSD 2-Clause, see `Jint.LICENSE.txt` |

SHA-256 of `Jint.2.11.58.dll`: `ed618668ae9e7c02c7c2b7332dd09079168cca96432a051044683c996337001c`

Jint 2.x is used on purpose: it is ES5-only, like the SQL Server and Snowflake hosts, so
code that runs under it stays portable. Nothing in `core/` depends on it.
