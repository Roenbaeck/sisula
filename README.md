sisula
======

sisula, short for "simple substitution language", is a language for producing text output from XML input.

The current version is built in [JavaScript](https://en.wikipedia.org/wiki/JavaScript) and should run using [HTA](https://en.wikipedia.org/wiki/HTML_Application) in any Windows version from the last decade. There are no special requirements or dependencies. A legacy version using [JScript](http://en.wikipedia.org/wiki/JScript) in [Windows Scripting Host](http://en.wikipedia.org/wiki/Windows_Script_Host) is also available.

### ETL
The ETL branch contains an SQL driven ELT framework for data warehouse automation. This framework can be used with SQL Server and is particularly useful for [Anchor Modeling](http://www.anchormodeling.com). There is a playlist of video tutorials on how to use it available here: https://www.youtube.com/playlist?list=PLG6-3kKEOyYlWEaEFzhcARtjqHU6zn1cH

###  Sisulator
The sisulator takes an XML file as input and converts this into a
JSON-compatible object according to a mapping ruleset. It will then
process a number of sisulets as specified in the given directive, which
recieve the object as input. The sisulets are parsed and the sisula
language substituted to JavaScript/JScript using regular expressions, after which
the JavaScript/JScript is evaluated and the output stored.

### History
sisula was introduced in [Anchor Modeling](http://www.anchormodeling.com) in order to replace XSLT for producing text output, and a first JavaScript version of the Sisulator is built into its [modeling tool](http://code.google.com/p/anchormodeler). This version is derived from that work.
