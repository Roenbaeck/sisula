<#
    Checks the syntax of an Oracle SQL / PL/SQL script without an Oracle server. The script is parsed by the ANTLR grammar for
    PL/SQL of the grammars-v4 project, as SQL*Plus would read it: statements ended by a semicolon and PL/SQL blocks (triggers,
    functions, anonymous blocks) ended by a slash on a line of its own. Only the syntax is checked; whether a table or a column
    exists is not, and a construct that Oracle accepts but the grammar does not know is reported as an error (see the patch below).

    Nothing has to be installed and no administrator rights are needed. The first run sets up a cache directory (about 100 MB):
      - Eclipse Temurin JDK 21 (zip from api.adoptium.net), only to compile; a minimal runtime made with jlink is what is kept,
      - the ANTLR 4.13.2 complete jar (Maven Central),
      - PlSqlLexer.g4 and PlSqlParser.g4 and the Java base classes from github.com/antlr/grammars-v4 (sql/plsql), at a fixed commit,
        with three patches for what Oracle accepts and the grammar did not (they are in Initialize-Cache, with their reasons):
        SQL_MACRO(TABLE), a SQL macro called in FROM without TABLE(), and CREATE TABLE IF NOT EXISTS (Oracle 23ai); and
        one for SQL*Plus: a PROMPT line is a comment, so that it can stand between two statements.
    from which a parser is generated and compiled (the generated parser is about 8 MB of Java; javac takes -Xmx2g for it).
    Later runs only parse, with the SLL mode of ANTLR first and the full LL mode only for a script that failed in the first.
    The cache is outside every repository. The downloads need curl.exe (part of Windows 10 and 11) and the network, once.

    Usage:
      oracle-syntax.ps1 -File <script.sql> [-Cache <directory>] [-Rebuild]

    Prints "ok" and exits 0 if the script parses, otherwise prints one line per error, "<line>:<column> <message>", and exits 1.
    Exits 2 if the setup failed. -Rebuild deletes the cache and sets it up again. The default cache is
    %LOCALAPPDATA%\anchor-oracle-syntax.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string] $File,
    [string] $Cache,
    [switch] $Rebuild
)
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$antlrVersion = '4.13.2'
$grammarCommit = '9fa9f94b20cd3225bd84f27554515da207ec39ff'
$jdkUrl = 'https://api.adoptium.net/v3/binary/latest/21/ga/windows/x64/jdk/hotspot/normal/eclipse'
$antlrUrl = "https://repo1.maven.org/maven2/org/antlr/antlr4/$antlrVersion/antlr4-$antlrVersion-complete.jar"
$grammarUrl = "https://raw.githubusercontent.com/antlr/grammars-v4/$grammarCommit/sql/plsql"
$stamp = "antlr $antlrVersion, grammar $grammarCommit, patches 1-4"

if (-not $Cache) { $Cache = Join-Path $env:LOCALAPPDATA 'anchor-oracle-syntax' }
$runtime = Join-Path $Cache 'runtime'
$classes = Join-Path $Cache 'classes'
$jar = Join-Path $Cache 'antlr.jar'
$ready = Join-Path $Cache 'ready.txt'

# The Java side: parses the whole file, prints "<line>:<column> <message>" for every error.
$mainJava = @'
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.PredictionMode;
import org.antlr.v4.runtime.misc.ParseCancellationException;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;

public class Main {
    static class Collector extends BaseErrorListener {
        final List<String> errors = new ArrayList<>();
        @Override
        public void syntaxError(Recognizer<?, ?> r, Object symbol, int line, int col, String msg, RecognitionException e) {
            // the list of tokens that would have been right can be hundreds long: keep the first of them
            int at = msg.indexOf(" expecting {");
            if (at >= 0) {
                String[] list = msg.substring(at + 12, msg.length() - 1).split(", ");
                if (list.length > 8) {
                    msg = msg.substring(0, at) + " expecting one of {" + String.join(", ", Arrays.copyOf(list, 8)) + ", ...}";
                }
            }
            errors.add(line + ":" + (col + 1) + " " + msg);
        }
    }

    static PlSqlParser parser(String text, Collector c) {
        PlSqlLexer lexer = new PlSqlLexer(CharStreams.fromString(text));
        lexer.removeErrorListeners();
        lexer.addErrorListener(c);
        PlSqlParser p = new PlSqlParser(new CommonTokenStream(lexer));
        p.removeErrorListeners();
        p.addErrorListener(c);
        return p;
    }

    public static void main(String[] args) throws Exception {
        String text = new String(Files.readAllBytes(Paths.get(args[0])), StandardCharsets.UTF_8);
        if (text.startsWith("\uFEFF")) text = text.substring(1);
        // first SLL, bailing out at the first error; only a script that failed there is parsed again, in full LL, with the report
        Collector quiet = new Collector();
        PlSqlParser p = parser(text, quiet);
        p.getInterpreter().setPredictionMode(PredictionMode.SLL);
        p.setErrorHandler(new BailErrorStrategy());
        boolean ok = true;
        try {
            p.sql_script();
        } catch (ParseCancellationException e) {
            ok = false;
        }
        if (ok && quiet.errors.isEmpty()) {
            System.out.println("ok");
            return;
        }
        Collector c = new Collector();
        p = parser(text, c);
        p.getInterpreter().setPredictionMode(PredictionMode.LL);
        p.sql_script();
        if (c.errors.isEmpty()) {
            System.out.println("ok");
            return;
        }
        for (String e : c.errors) System.out.println(e);
        System.exit(1);
    }
}
'@

function Invoke-Native([string] $what, [string] $exe, [string[]] $arguments) {
    & $exe @arguments
    if ($LASTEXITCODE -ne 0) { throw "$what failed (exit code $LASTEXITCODE)." }
}

function Get-Download([string] $url, [string] $to) {
    # --ssl-no-revoke: behind some proxies Windows cannot reach the certificate revocation list, which makes curl refuse the connection
    Invoke-Native "Downloading $url" 'curl.exe' @('-sSL', '--fail', '--ssl-no-revoke', '-o', $to, $url)
}

function Initialize-Cache {
    $work = Join-Path $Cache 'work'
    if (Test-Path $Cache) { Remove-Item $Cache -Recurse -Force }
    New-Item -ItemType Directory -Path $work | Out-Null
    $utf8 = New-Object Text.UTF8Encoding($false)
    Write-Host "Setting up $Cache (once) ..."

    Write-Host '  downloading the JDK, ANTLR and the grammar'
    Get-Download $jdkUrl (Join-Path $work 'jdk.zip')
    Get-Download $antlrUrl $jar
    $gen = Join-Path $work 'gen'
    New-Item -ItemType Directory -Path $gen | Out-Null
    foreach ($name in 'PlSqlLexer.g4', 'PlSqlParser.g4') { Get-Download "$grammarUrl/$name" (Join-Path $gen $name) }
    foreach ($name in 'PlSqlLexerBase.java', 'PlSqlParserBase.java') {
        $target = Join-Path $gen $name
        Get-Download "$grammarUrl/Java/$name" $target
        # the first line is a placeholder for a package line
        $text = [IO.File]::ReadAllText($target, $utf8) -replace '^///\{packageLine\}', ''
        [IO.File]::WriteAllText($target, $text, $utf8)
    }

    Write-Host '  unpacking the JDK'
    $jdkDir = Join-Path $work 'jdk'
    New-Item -ItemType Directory -Path $jdkDir | Out-Null
    if (Get-Command tar.exe -ErrorAction SilentlyContinue) { Invoke-Native 'Unpacking the JDK' 'tar.exe' @('-xf', (Join-Path $work 'jdk.zip'), '-C', $jdkDir) }
    else { Expand-Archive (Join-Path $work 'jdk.zip') $jdkDir }
    $jdk = @(Get-ChildItem $jdkDir -Directory)[0].FullName
    $java = Join-Path $jdk 'bin\java.exe'

    # The patches. Each one names the grammar file, the text it replaces (a regular expression that has to match, or the grammar has
    # changed and the patch has to be looked at again) and the text that takes its place.
    $patches = @(
        # 1: SQL_MACRO(TABLE) and SQL_MACRO(SCALAR), and a body of any form; the grammar had SQL_MACRO IS BEGIN RETURN '...'; END only
        @{ File = 'PlSqlParser.g4'; Find = '(?s)sql_macro_body\s*:\s*SQL_MACRO IS BEGIN RETURN quoted_string SEMICOLON END\s*;'
           With = "sql_macro_body`n    : SQL_MACRO ('(' (TABLE | id_expression) ')')? (IS | AS) DECLARE? seq_of_declare_specs? body`n    ;" },
        # 2: a SQL macro called in FROM, as in FROM pActor(current_timestamp), which Oracle 19.7 and later accepts without TABLE()
        @{ File = 'PlSqlParser.g4'; Find = '(?s)(dml_table_expression_clause\s*:\s*table_collection_expression\s*)'
           With = "`$1`n    | identifier ('.' id_expression)? '(' (argument (',' argument)*)? ')'`n" },
        # 3: CREATE TABLE IF NOT EXISTS name, Oracle 23ai; the grammar had the clause after the name only
        @{ File = 'PlSqlParser.g4'; Find = '(\)\? TABLE )(\(schema_name ''\.''\)\? table_name \(IF NOT EXISTS\)\?)'
           With = "`$1(IF NOT EXISTS)? `$2" },
        # 4: a PROMPT line of SQL*Plus is a comment (the grammar made it a command, which has to be set off from the statements around it by a semicolon)
        @{ File = 'PlSqlLexer.g4'; Find = '(PROMPT_MESSAGE:\s*''PRO''[^\r\n]*NEWLINE_EOF)(\s*;)'
           With = "`$1 -> channel(HIDDEN)`$2" }
    )
    $number = 0
    foreach ($patch in $patches) {
        $number++
        $target = Join-Path $gen $patch.File
        $text = [IO.File]::ReadAllText($target, $utf8)
        if (-not [regex]::IsMatch($text, $patch.Find)) { throw "The grammar does not have the text that patch $number is for." }
        [IO.File]::WriteAllText($target, [regex]::Replace($text, $patch.Find, $patch.With), $utf8)
    }

    Write-Host '  generating the parser'
    Invoke-Native 'ANTLR' $java @('-jar', $jar, '-Dlanguage=Java', '-no-listener', '-no-visitor', (Join-Path $gen 'PlSqlLexer.g4'), (Join-Path $gen 'PlSqlParser.g4'))
    [IO.File]::WriteAllText((Join-Path $gen 'Main.java'), $mainJava, $utf8)

    Write-Host '  compiling it (a minute or so)'
    New-Item -ItemType Directory -Path $classes | Out-Null
    $sources = @(Get-ChildItem $gen -Filter *.java | ForEach-Object { $_.FullName })
    Invoke-Native 'javac' (Join-Path $jdk 'bin\javac.exe') (@('-J-Xmx2g', '-encoding', 'UTF-8', '-cp', $jar, '-d', $classes) + $sources)

    Write-Host '  making a small runtime'
    Invoke-Native 'jlink' (Join-Path $jdk 'bin\jlink.exe') @('--add-modules', 'java.base', '--output', $runtime, '--compress', 'zip-6', '--no-header-files', '--no-man-pages')

    Remove-Item $work -Recurse -Force
    [IO.File]::WriteAllText($ready, $stamp, $utf8)
}

if ($Rebuild -or -not (Test-Path $ready) -or ([IO.File]::ReadAllText($ready) -ne $stamp)) {
    try { Initialize-Cache }
    catch { Write-Host "FAIL  setting up the cache: $($_.Exception.Message)"; exit 2 }
}

$path = (Resolve-Path $File).Path
$out = & (Join-Path $runtime 'bin\java.exe') -Xss16m -XX:+UseSerialGC -XX:TieredStopAtLevel=1 -cp "$classes;$jar" Main $path
$code = $LASTEXITCODE
$out | ForEach-Object { Write-Host $_ }
exit $code
