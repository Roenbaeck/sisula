<#
    Checks the Anchor Modeler's data type converter (modules/DataTypeConverter.js in the Anchor checkout), which changes the
    data types of a model from one database to another, through the generic types, when a database is picked in the modeler
    and the data types are to follow.

    Run under Jint, with the pure part of the converter (convertText), so no browser is needed. It checks

      - the mappings that Snowflake and BigQuery were given, both ways, against a table of what each type has to become,
      - that every one of the 49 pairs of databases (the six, and Generic) can be converted, that the result is well-formed
        XML (read by modules/XmlTree.js), and that nothing but the values of the attributes that hold a data type changes,
        on every model of this example, on Anchor's own example.xml, and on a model with names that look like types,
      - that converting a model to the database it is already for changes nothing,
      - that an unknown database says so.

    Usage:
      converter-check.ps1 [-Anchor <checkout>]
#>
param([string] $Anchor)
$ErrorActionPreference = 'Stop'
$example = Split-Path -Parent $PSScriptRoot
if (-not $Anchor) { $Anchor = Join-Path $PSScriptRoot '..\..\..\..\anchor' }
$Anchor = (Resolve-Path $Anchor).Path
Add-Type -Path (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\lib\Jint.2.11.58.dll'))
$utf8 = [Text.Encoding]::UTF8
$engine = New-Object Jint.Engine
$engine.Execute([IO.File]::ReadAllText((Join-Path $Anchor 'modules\XmlTree.js'), $utf8)) | Out-Null
$engine.Execute([IO.File]::ReadAllText((Join-Path $Anchor 'modules\DataTypeConverter.js'), $utf8)) | Out-Null

$models = @{}
foreach ($m in Get-ChildItem (Join-Path $example 'models') -Filter *.xml | Sort-Object Name) { $models[$m.BaseName] = [IO.File]::ReadAllText($m.FullName, $utf8) }
$models['anchor-example'] = [IO.File]::ReadAllText((Join-Path $Anchor 'example.xml'), $utf8)
# names that are types, in the places where a name is not a type: nothing of this may change
$models['names-like-types'] = @'
<schema format="0.101.2">
<metadata encapsulation="dbo" identity="int" chronon="datetime2(7)" now="sysdatetime()" databaseTarget="SQLServer"/>
<knot mnemonic="INT" descriptor="Text" identity="tinyint" dataRange="varchar(42)">
<metadata capsule="dbo" generator="false"/>
<description>int text bit real datetime "float" number(1)</description>
</knot>
<anchor mnemonic="DT" descriptor="Datetime" identity="int">
<metadata capsule="dbo" generator="true"/>
<attribute mnemonic="DAT" descriptor="Date" timeRange="datetime" dataRange="datetime2(3)">
<metadata capsule="dbo"/>
</attribute>
<attribute mnemonic="TXT" descriptor="Float" knotRange="INT">
<metadata capsule="dbo"/>
</attribute>
</anchor>
</schema>
'@

$models.Keys | ForEach-Object { $engine.SetValue("m_$($_ -replace '[^A-Za-z0-9]', '_')", $models[$_]) | Out-Null }
$names = ($models.Keys | Sort-Object | ForEach-Object { "'$_': m_$($_ -replace '[^A-Za-z0-9]', '_')" }) -join ', '
$engine.Execute("var MODELS = { $names };") | Out-Null

$script = @'
var failures = [], checked = 0;
function fail(message) { failures.push(message); }
function convert(text, from, to) { return DataTypeConverter.convertText(text, from, to); }
function value(type, from, to) { return convert(' dataRange="' + type + '"', from, to).replace(/^ dataRange="|"$/g, ''); }

// ---- what the types of Snowflake and BigQuery become, and come from -------------------------------------------------------
var EXPECT = {
    'Generic>Snowflake': {
        'integer': 'integer', 'datetime': 'datetime', 'double': 'double', 'decimal(10,2)': 'number(10,2)', 'decimal': 'number',
        'money': 'number(19,4)', 'timetz(3)': 'time(3)', 'timestamp': 'timestamp_ntz', 'timestamp(9)': 'timestamp_ntz(9)',
        'timestamptz': 'timestamp_tz', 'timestamptz(6)': 'timestamp_tz(6)', 'nchar(10)': 'char(10)', 'nvarchar(42)': 'varchar(42)',
        'longvarchar': 'varchar', 'clob': 'varchar', 'nclob': 'varchar', 'longvarbinary': 'binary', 'blob': 'binary',
        'xml': 'varchar', 'json': 'variant', 'guid': 'varchar(36)', 'current_timestamp': 'sysdate()'
    },
    'Snowflake>Generic': {
        'number(1,0)': 'tinyint', 'number(2)': 'tinyint', 'number(4,0)': 'smallint', 'number(9)': 'integer', 'number(12,0)': 'bigint',
        'number(20,0)': 'decimal(20,0)', 'number(10,2)': 'decimal(10,2)', 'number': 'decimal(38,0)', 'int': 'integer', 'byteint': 'tinyint',
        'float': 'double', 'float8': 'double', 'double precision': 'double', 'datetime': 'timestamp', 'timestamp_ntz(9)': 'timestamp(9)',
        'timestamp_ntz': 'timestamp', 'timestamp_tz(3)': 'timestamptz(3)', 'timestamp_ltz': 'timestamptz', 'varchar(42)': 'nvarchar(42)',
        'varchar(4000)': 'nvarchar(4000)', 'varchar(4001)': 'nlongvarchar', 'varchar(16777216)': 'nlongvarchar', 'varchar': 'nlongvarchar',
        'string': 'nlongvarchar', 'text': 'nlongvarchar', 'char(10)': 'nchar(10)', 'binary': 'longvarbinary', 'varbinary': 'longvarbinary',
        'variant': 'json', 'array': 'json', 'sysdate()': 'current_timestamp', 'geography': 'geography', 'boolean': 'boolean', 'date': 'date'
    },
    'Generic>BigQuery': {
        'tinyint': 'int64', 'bigint': 'int64', 'decimal(10,2)': 'numeric(10,2)', 'decimal(38,9)': 'numeric(38,9)',
        'decimal(38,10)': 'bignumeric(38,10)', 'decimal(40,12)': 'bignumeric(40,12)', 'decimal(10)': 'numeric(10)', 'decimal': 'numeric',
        'float': 'float64', 'double': 'float64', 'boolean': 'bool', 'money': 'numeric(19,4)', 'time(3)': 'time', 'timetz': 'time',
        'datetime': 'datetime', 'timestamp(9)': 'datetime', 'timestamptz': 'timestamp', 'char(10)': 'string(10)', 'nvarchar(42)': 'string(42)',
        'longvarchar': 'string', 'binary(16)': 'bytes(16)', 'blob': 'bytes', 'xml': 'string', 'guid': 'string(36)', 'current_timestamp': 'current_datetime()'
    },
    'BigQuery>Generic': {
        'int64': 'bigint', 'int': 'integer', 'byteint': 'tinyint', 'numeric': 'decimal(38,9)', 'numeric(10,2)': 'decimal(10,2)', 'numeric(10)': 'decimal(10)',
        'bignumeric': 'decimal(38,18)', 'bignumeric(30,20)': 'decimal(30,20)', 'bignumeric(70,40)': 'decimal(38,18)', 'float64': 'double',
        'bool': 'boolean', 'datetime': 'timestamp(6)', 'timestamp': 'timestamptz(6)', 'string(42)': 'nvarchar(42)', 'string(4000)': 'nvarchar(4000)',
        'string(4001)': 'nlongvarchar', 'string': 'nlongvarchar', 'bytes(16)': 'varbinary(16)', 'bytes(8001)': 'longvarbinary', 'bytes': 'longvarbinary',
        'current_datetime()': 'current_timestamp', 'current_timestamp()': 'current_timestamp', 'json': 'json', 'geography': 'geography'
    },
    // the two that were wrong in the original rule lists, where a rule's result was changed again by the next one
    'SQLServer>Oracle': { 'real': 'binary_float', 'smalldatetime': 'date' },
    'SQLServer>PostgreSQL': { 'real': 'real' }
};
for (var pair in EXPECT) {
    var ends = pair.split('>');
    for (var type in EXPECT[pair]) {
        checked++;
        var got = value(type, ends[0], ends[1]);
        if (got != EXPECT[pair][type]) fail(pair + ': ' + type + ' became ' + got + ', not ' + EXPECT[pair][type]);
    }
}

// ---- the databases ----------------------------------------------------------------------------------------------------------
var dbs = DataTypeConverter.databases();
['Generic', 'SQLServer', 'Oracle', 'PostgreSQL', 'Vertica', 'Snowflake', 'BigQuery'].forEach(function(d) {
    checked++;
    if (dbs.indexOf(d) < 0) fail('the converter does not list ' + d + ' (it lists ' + dbs.join(', ') + ')');
});

// ---- every pair, on every model: well-formed, and only data types change ----------------------------------------------------
var attributes = DataTypeConverter.ATTRIBUTES;
var blank = new RegExp('(\\s(?:' + attributes.join('|') + ')=)"[^"]*"', 'g');
function frame(text) { return text.replace(blank, '$1""'); }
function values(text) { var out = [], m, re = new RegExp('\\s(?:' + attributes.join('|') + ')="([^"]*)"', 'g'); while ((m = re.exec(text)) !== null) out.push(m[1]); return out; }
for (var name in MODELS) {
    var text = MODELS[name], skeleton = frame(text);
    dbs.forEach(function(from) { dbs.forEach(function(to) {
        checked++;
        var label = name + ' ' + from + '>' + to;
        var out;
        try { out = convert(text, from, to); } catch (e) { fail(label + ': ' + e.message); return; }
        if (from == to) { if (out !== text) fail(label + ': changed a model that is already for that database'); return; }
        if (frame(out) !== skeleton) fail(label + ': changed something that is not the value of a data type attribute');
        try { XmlTree.parse(out); } catch (e) { fail(label + ': not well-formed: ' + e.message); }
    }); });
}
// the model of names that look like types: not one value outside the attributes may be touched, which the frame check shows;
// and the data types in it are converted
checked++;
var trap = convert(MODELS['names-like-types'], 'SQLServer', 'Snowflake');
if (trap.indexOf('descriptor="Text"') < 0 || trap.indexOf('mnemonic="INT"') < 0 || trap.indexOf('<description>int text bit real datetime "float" number(1)</description>') < 0)
    fail('a name that looks like a type was changed');
if (trap.indexOf('dataRange="datetime2(3)"') >= 0 || trap.indexOf('dataRange="timestamp_ntz(3)"') < 0) fail('a data type was not converted in the model of names that look like types: ' + trap.match(/dataRange="[^"]*"/g).join(' '));
if (trap.indexOf('encapsulation="public"') < 0 || trap.indexOf('now="sysdate()"') < 0) fail('the schema and now of a SQL Server model did not become those of Snowflake');

// ---- an unknown database -------------------------------------------------------------------------------------------------------
checked++;
try { convert(' dataRange="int"', 'Informix', 'Snowflake'); fail('no error for an unknown source'); }
catch (e) { if (e.message.indexOf('from Informix') < 0) fail('the error for an unknown source does not name it: ' + e.message); }
checked++;
try { convert(' dataRange="int"', 'SQLServer', 'Informix'); fail('no error for an unknown target'); }
catch (e) { if (e.message.indexOf('to Informix') < 0) fail('the error for an unknown target does not name it: ' + e.message); }

'checked ' + checked + '\n' + failures.join('\n');
'@
$result = $engine.Execute($script).GetCompletionValue().AsString()
$lines = @($result -split "`n")
Write-Host $lines[0]
$failures = @($lines | Select-Object -Skip 1 | Where-Object { $_ })
foreach ($f in $failures | Select-Object -First 40) { Write-Host "FAIL  $f" }
if ($failures.Count -gt 40) { Write-Host "...and $($failures.Count - 40) more" }
if ($failures.Count -eq 0) { Write-Host 'PASS  the converter does what it is expected to, for every pair of databases'; exit 0 }
Write-Host "$($failures.Count) failure(s)"
exit 1
