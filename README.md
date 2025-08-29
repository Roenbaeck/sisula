sisula
======

sisula, short for "simple substitution language", is a language for producing text output from XML input.

The current version is built in [JavaScript](https://en.wikipedia.org/wiki/JavaScript) and should run using PowerShell 5.1 in any Windows version from the last few years. There are no special requirements and a JavaScript interpreter called [Jint](https://github.com/sebastienros/jint) is now bundled with the framework. Legacy versions using [HTA](https://en.wikipedia.org/wiki/HTML_Application) or [JScript](http://en.wikipedia.org/wiki/JScript) in [Windows Scripting Host](http://en.wikipedia.org/wiki/Windows_Script_Host) are also available.

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

---

### Sisula Transformation Language: Documentation & Guide

#### 1. Introduction: The Sisula Concept

Sisula is a hybrid ETL transformation engine that combines procedural JavaScript logic with embedded text generation templates. It is designed to read source XML metadata and transform it into executable SQL code, configuration files (like BCP formats), and other artifacts.

**Core Philosophy:** Sisula prioritizes developer productivity by allowing complex, stateful logic to be written in standard JavaScript, rather than a purely declarative language like XSLT. A transformation process is defined by a set of "sisulet" files which are concatenated and executed to produce a single text output.

**Key Components:**

*   **XML Metadata Files:** The input data describing sources, targets, or workflows.
*   **Sisulet Files (`.js`):** The building blocks of a transformation. These can contain either pure JavaScript logic or text templates.
*   **Directive Files (`.directive`):** A manifest file that lists, in order, all sisulet files required for a specific transformation (e.g., generating a source loading procedure).
*   **The Sisulator Engine:** The core logic (in `Sisulator.js`) that parses input, manages context, processes sisulets, and generates the final output.

---

#### 2. Getting Started: How a Transformation Works

A Sisula transformation follows a precise data flow:

1.  **Input:** The engine receives an input XML file (e.g., `MySource.xml`) and a context object containing global variables (`VARIABLES`).
2.  **Objectification:** The input XML is parsed into a JavaScript object structure. For example, `<source name="A"><part name="B"/></source>` becomes accessible via `source.name` and `source.part.B`.
3.  **Sisulet Collection:** The engine reads a directive file (e.g., `source.directive`) to gather a list of sisulet files.
4.  **Sandbox Execution:** The contents of all collected sisulets are combined and executed within a secure sandbox environment. This environment has access to the objectified XML and the context variables.
5.  **Template Processing:** The engine identifies special template blocks (`/*~ ... ~*/`) within the sisulets and processes them to generate text output, substituting variables as it goes.
6.  **Output:** The final concatenated text from the template processing is saved as the result file (e.g., `MySource.sql`).

---

#### 3. Sisulet Syntax Reference

There are two types of content within a sisulet file: **Pure JavaScript Code** and **Template Blocks**.

##### 3.1 Pure JavaScript Code

Any text outside of a template block is treated as standard ECMAScript 5.1 JavaScript. This code is executed directly. It is primarily used to define helper functions, manipulate data structures, and prepare data for the templates.

**Example (`Helpers.js`):**

```javascript
// This function adds iterator methods to the source object.
// It allows templates to use simple loops like source.nextPart().
source._iterator = {};
source._iterator.part = 0;
source.nextPart = function() {
    if(!this.parts) return null;
    if(source._iterator.part == this.parts.length) {
        source._iterator.part = 0;
        return null;
    }
    return this.part[this.parts[source._iterator.part++]];
};
```

##### 3.2 Template Blocks (`/*~ ... ~*/`)

Template blocks are sections of code specifically designed for text generation. They are initiated by `/*~` and terminated by `~*/`. The content inside these blocks is treated as literal text, except for special substitution patterns.

**Example:**

```javascript
/*~
CREATE PROCEDURE schema.sp_load_$source.name$
AS
BEGIN
~*/
// JavaScript logic can go between template blocks
var i = 1;
while(i <= 2) {
/*~
    -- Iteration $i$
~*/
    i++;
}
/*~
END;
~*/
```

**Output:**

```sql
CREATE PROCEDURE schema.sp_load_MySource
AS
BEGIN
    -- Iteration 1
    -- Iteration 2
END;
```

---

#### 4. Variable Substitution Syntax

Within template blocks, variables are substituted using a concise, custom syntax.

##### 4.1 Simple Variable Replacement: `$variable$`

Replaces a placeholder with the value of a JavaScript variable from the current scope. If the variable does not exist or is `null`, it is replaced with an empty string.

*   **Syntax:** `$variableName$` or `$object.property$`
*   **Example:** `COLUMN_NAME = $term.name$;`
*   **Output:** `COLUMN_NAME = CustomerID;`

##### 4.2 Complex Expression Replacement: `${expression}$`

Executes a JavaScript expression and replaces the placeholder with the result. This allows for calculations or function calls inline.

*   **Syntax:** `${javascriptExpression}$`
*   **Example:** `ITEM_ID = ${part.id + '_' + term.id}$;`
*   **Output:** `ITEM_ID = B_CustomerID;`

##### 4.3 Conditional Expression (Ternary Operator): `$(condition)?true_value:false_value`

Evaluates a JavaScript condition. If true, outputs `true_value`; otherwise, outputs `false_value`. This is a shorthand for a common `if/else` pattern.

*   **Syntax:** `$(condition)?output_if_true:output_if_false`
    *   Note: The `:false_value` part is optional.
*   **Example:** `IS_NULLABLE = $(term.nullable == 'true')?1:0;`
*   **Output:** `IS_NULLABLE = 1;`

---

#### 5. Core Sisulets and Best Practices

##### 5.1 Key Sisulets Explained

*   **`Polyfills.js`:** Provides implementations of modern JavaScript methods for older engines (no longer strictly necessary with Jint but kept for structure).
*   **`Variables.js`:** Contains global helper functions, such as `replaceVariables`, which performs recursive placeholder substitution on data objects. This is critical for resolving nested variables (e.g., when a variable's value contains another variable).
*   **`Helpers.js` (`source/Helpers.js`, etc.):** This is one of the most important files. It implements the iterator logic (`.nextPart()`, `.nextTerm()`) that enables simple `while` loops in other sisulets. It bridges the gap between the static data object and a stateful-iteration programming model.

##### 5.2 Best Practices and Data Flow

1.  **Data Preparation First:** Sisulets listed first in a `.directive` file (like `Helpers.js`) should focus on preparing data and defining functions. Sisulets listed later should focus on using those functions to generate output.
2.  **Context Scoping:** Variables defined in `VARIABLES` are global. The `workflow/Variables.js` script demonstrates best practice for creating scoped copies of variables for nested elements like jobs (`job.VARIABLES = copyVariables(workflow.VARIABLES);`), preventing child elements from accidentally modifying the parent's context.
3.  **Variable Resolution Order:** Be aware that variable substitution can be order-dependent. The `replaceVariables` function should be called strategically to resolve placeholders within data *before* that data is used to resolve placeholders in templates. (As we saw with the multi-stage replacement fix for workflows).

---

### Sisula Project Structure: A Guide

A Sisula project is organized into a standardized folder structure. The main `Sisulate.ps1` script is designed to look for files in specific subdirectories based on the filters (`S`, `T`, `W`) you provide. Adhering to this structure is essential for the tool to work correctly.

Based on the provided examples, here is the standard project layout:

```
<Your_Project_Folder>/
|
|-- sources/
|   |-- SourceFile1.xml
|   `-- SourceFile2.xml
|
|-- targets/
|   |-- TargetTable1.xml
|   `-- TargetTable2.xml
|
|-- workflows/
|   |-- MainWorkflow.xml
|   `-- ...
|
|-- formats/
|   |-- (This is an OUTPUT directory)
|   `-- ...
|
|-- biml/
|   |-- (This is an OUTPUT directory)
|   `-- ...
|
|-- scripts/
|   |-- HelperScript1.ps1
|   `-- ...
|
`-- Variables.BAT
```

#### Folder and File Descriptions

*   **`sources/` (Input)**
    *   **Purpose:** Contains the XML definitions of your raw data sources. Each XML file typically describes a flat file or another data source, detailing its columns, data types, and delimiters.
    *   **Used by Filter:** `S`
    *   **Generates:** BCP format files in `formats/` and source-loading SQL procedures in `sources/` (e.g., `SourceFile1.sql`).

*   **`targets/` (Input)**
    *   **Purpose:** Contains the XML definitions of your destination tables in the data warehouse. These files define the table structure and, most importantly, the mapping logic from one or more sources to the target.
    *   **Used by Filter:** `T`
    *   **Generates:** Target-loading SQL procedures in `targets/` (e.g., `TargetTable1.sql`) and Business Intelligence Markup Language files in `biml/`.

*   **`workflows/` (Input)**
    *   **Purpose:** Contains the XML definitions of the orchestration logic. These files describe the sequence of tasks to be performed, which are then transformed into SQL Server Agent Jobs. This is where you define the steps of your ETL process (e.g., "Run source A load, then run target B load").
    *   **Used by Filter:** `W`
    *   **Generates:** SQL scripts in `workflows/` that create the corresponding SQL Server Agent Jobs.

*   **`formats/` (Output)**
    *   **Purpose:** This is an **output-only** directory. The Sisulator engine places the generated BCP (Bulk Copy Program) format files here. These XML-based format files are used by SQL Server to efficiently bulk-load data from flat files.
    *   **Generated from:** `sources/`

*   **`biml/` (Output)**
    *   **Purpose:** This is an **output-only** directory. The engine places the generated BIML files here. BIML is a dialect of XML used to declare business intelligence assets. These files are typically used by tools like BimlStudio to automatically generate SSIS (SQL Server Integration Services) packages.
    *   **Generated from:** `targets/`

*   **`scripts/` (Supporting Files)**
    *   **Purpose:** A conventional location for any external helper scripts (e.g., PowerShell `.ps1`, Python `.py`, command files `.cmd`) that are executed by the steps in your workflows. For example, a job step generated from `workflows/MainWorkflow.xml` might call `PowerShell %ProjectDirectory%\scripts\HelperScript1.ps1`. The Sisulator engine itself does not directly read this folder, but the generated artifacts often rely on it.

*   **`Variables.BAT` (Configuration)**
    *   **Purpose:** This is the central configuration file for the entire project. It is used to define key-value pairs that control the behavior of the transformations. Common variables include database names (`SourceDatabase`, `TargetDatabase`), server names, and file paths (`WorkDataDirectory`, `ArchiveDataDirectory`). These variables are loaded into the `VARIABLES` object and are accessible in all sisulets, allowing for environment-specific configuration without changing the core transformation logic.