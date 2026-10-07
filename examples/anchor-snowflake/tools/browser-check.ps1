<#
    Runs the Anchor Modeler itself, its index.html in headless Microsoft Edge, on the models in
    models/. For each model the page loads it the way a user opening the file would, accepting the
    model's settings, and then either

      (default)      runs the modeler's own Generate SQL and compares the SQL, byte for byte, with
                     golden/<model>/_full.sql, or
      -Canonicalize  saves the model the way the modeler's "Save model to local file" does, and
                     writes that back to models/<model>.xml.

    The golden files are rendered by check.ps1, which runs the engine under Jint with a small
    DOM, straight from the model file. The default mode closes the remaining gap: a real browser
    engine, a real DOM, and the modeler's own path from file to SQL (Model.fromXML, Model.toXML,
    Actions.generateSQL).

    -Canonicalize exists because that path is not the identity. When the modeler loads a file it
    fills every flag the file leaves out from its current defaults (for example equivalent, from
    the model's equivalence setting) and applies its own rules (a knotted attribute is never
    equivalent), and it writes all of them out when it saves. A hand-edited model can therefore
    mean something else to the modeler than to a direct reading. A canonical model is one the
    modeler would have saved itself, so both readings agree.

      -Bindings    calls the modeler's own "JSON bindings" (Actions.bindings, the Generate menu) and
                   compares what it produces with the bindings that check.ps1 resolves for the
                   same model with the resolver in tools/resolve-model.js. Both start from the
                   same Anchor scripts; this shows that the modeler, with a real DOM, produces
                   exactly the JSON that the templates were verified against.

    Usage:
      browser-check.ps1 [-Variant <name>,...] [-Canonicalize | -Bindings] [-Anchor <checkout>] [-Edge <msedge.exe>] [-KeepOutput <dir>]

    Nothing is written to the Anchor checkout. A copy of index.html is made in a temporary folder
    with a <base> pointing at the checkout, so every script, directive and sisulet is read from it
    unchanged. The copy leaves out the two Google Fonts links, so the run needs no network, and
    adds one script that
      - answers the modeler's alert and confirm dialogs (confirm answers yes, as a user accepting
        the model's settings would),
      - serves fetch() through XMLHttpRequest, since Chromium's fetch cannot read file:// URLs,
      - after the page has initialised, calls Actions._applyLoadedModel, which is what opening a
        file does, and then Actions.generateSQL, capturing the text the modeler would display, or
        serialises Model.toXML(false), exactly as saving does.
#>
[CmdletBinding()]
param(
    [string[]] $Variant,
    [switch] $Canonicalize,
    [switch] $Bindings,
    [string] $Anchor,
    [string] $Edge,
    [string] $KeepOutput,
    [int] $TimeoutSeconds = 120
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $Anchor) { $Anchor = Join-Path $PSScriptRoot '..\..\..\..\anchor' }
$Anchor = (Resolve-Path $Anchor).Path
if (-not $Edge) {
    $Edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") |
        Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $Edge) { throw 'Microsoft Edge was not found; pass -Edge.' }
if (-not $Variant) {
    # handwritten is, on purpose, not a model the modeler would save (see make-variants.ps1), so
    # the modeler reads it differently, so it is left out here and only run through check.ps1.
    $Variant = Get-ChildItem (Join-Path $root 'models') -Filter *.xml | Sort-Object Name |
        ForEach-Object { $_.BaseName } | Where-Object { $_ -notmatch '^handwritten' }
}
$Variant = @($Variant | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$utf8 = New-Object Text.UTF8Encoding($false)
if ($KeepOutput) { New-Item -ItemType Directory -Force $KeepOutput | Out-Null }

$work = Join-Path ([IO.Path]::GetTempPath()) ('sisula-browser-check-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory $work | Out-Null

$page = [IO.File]::ReadAllText((Join-Path $Anchor 'index.html'), [Text.Encoding]::UTF8)
$baseHref = 'file:///' + ($Anchor -replace '\\', '/').TrimEnd('/') + '/'
$fonts = [regex]::Matches($page, '<link href=''https://fonts\.googleapis\.com/[^>]*>')
if ($fonts.Count -ne 2) { throw "Expected two Google Fonts links in index.html, found $($fonts.Count)." }
foreach ($f in $fonts) { $page = $page.Replace($f.Value, '') }
# The page's own <head> is the first one and its </body> the last; the others are inside a
# JavaScript string that writes a documentation page.
$headAt = $page.IndexOf('<head>')
$bodyEndAt = $page.LastIndexOf('</body>')
if ($headAt -lt 0 -or $headAt -gt 500 -or $bodyEndAt -lt $page.Length - 500) {
    throw 'Could not find the <head> and </body> of index.html where expected.'
}
$page = $page.Insert($headAt + '<head>'.Length, "`n<base href=`"$baseHref`">")
$bodyEndAt = $page.LastIndexOf('</body>')

$harness = @'
<pre id="sisula-result">PENDING</pre>
<script>
(function () {
    var MODEL = __MODEL__;
    var MODE = __MODE__;
    var TEMPORALIZATION = __TEMPORALIZATION__;
    var DATABASE = __DATABASE__;
    function report(text) { document.getElementById('sisula-result').textContent = text; }
    function toBase64(s) { return btoa(unescape(encodeURIComponent(s))); }
    window.alert = function () {};
    window.confirm = function () { return true; };
    window.prompt = function (message, defaultValue) { return defaultValue; };
    window.fetch = function (url) {
        return new Promise(function (resolve, reject) {
            var request = new XMLHttpRequest();
            request.open('GET', url, true);
            request.onload = function () {
                resolve({ ok: true, status: 200, text: function () { return Promise.resolve(request.responseText); } });
            };
            request.onerror = function () { reject(new Error('could not read ' + url)); };
            request.send();
        });
    };
    window.addEventListener('unhandledrejection', function (e) { report('ERROR ' + (e.reason && e.reason.stack || e.reason)); });
    window.addEventListener('load', function () {
        setTimeout(function () {
            try {
                Actions._applyLoadedModel(new DOMParser().parseFromString(MODEL, 'text/xml'), false);
                if (MODE === 'bindings') {
                    Actions.bindings().then(function (json) { report('BASE64:' + toBase64(json)); },
                                            function (e) { report('ERROR ' + (e && e.stack || e)); });
                    return;
                }
                if (MODE === 'save') {
                    report('BASE64:' + toBase64(new XMLSerializer().serializeToString(Model.toXML(false))));
                    return;
                }
                if (Defaults.databaseTarget !== DATABASE || Defaults.temporalization !== TEMPORALIZATION) {
                    report('ERROR the model did not select ' + DATABASE + ' ' + TEMPORALIZATION + ': ' + Defaults.databaseTarget + ' ' + Defaults.temporalization);
                    return;
                }
                var display = Actions.preformat;
                Actions.preformat = function (sql) {
                    report('BASE64:' + toBase64(sql));
                    return display.call(Actions, sql);
                };
                Actions.generateSQL();
            } catch (e) {
                report('ERROR ' + (e && e.stack || e));
            }
        }, 500);
    });
})();
</script>
'@

# Runs the harness page for one model in headless Edge and returns what it reported: the text
# after BASE64:, decoded, or $null after printing why there is none.
function Invoke-Modeler([string] $name, [string] $model, [string] $mode) {
    # The model goes into the page as a JavaScript string literal.
    $literal = '"' + ($model -replace '\\', '\\' -replace '"', '\"' -replace "`r", '\r' -replace "`n", '\n' -replace '</', '<\/') + '"'
    $html = $page.Insert($bodyEndAt, $harness.Replace('__MODEL__', $literal).Replace('__MODE__', "'$mode'").Replace('__TEMPORALIZATION__', "'$(([regex]::Match($model, 'temporalization="(\w+)"')).Groups[1].Value)'").Replace('__DATABASE__', "'$(([regex]::Match($model, 'databaseTarget="(\w+)"')).Groups[1].Value)'"))
    $pagePath = Join-Path $work "$name.html"
    [IO.File]::WriteAllText($pagePath, $html, $utf8)
    $profileDir = Join-Path $work "profile-$name"
    $dumpPath = Join-Path $work "$name.dump.html"
    $errPath = Join-Path $work "$name.err.txt"
    $arguments = @('--headless', '--disable-gpu', '--no-first-run', '--no-default-browser-check',
        '--disable-extensions', '--allow-file-access-from-files', "--user-data-dir=`"$profileDir`"",
        '--virtual-time-budget=60000', '--dump-dom', ('"file:///' + ($pagePath -replace '\\', '/') + '"'))
    $process = Start-Process -FilePath $Edge -ArgumentList $arguments -RedirectStandardOutput $dumpPath `
        -RedirectStandardError $errPath -PassThru -WindowStyle Hidden
    # The process started here is not the only one: Edge runs the page in helper processes that
    # share the redirected output. The run is over when none using this profile remain.
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    $dump = $null
    while ($null -eq $dump -and (Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 500
        $running = @(Get-CimInstance Win32_Process -Filter "Name = 'msedge.exe'" |
            Where-Object { $_.CommandLine -and $_.CommandLine.Contains($profileDir) })
        if ($process.HasExited -and $running.Count -eq 0) {
            try { $dump = [IO.File]::ReadAllText($dumpPath, [Text.Encoding]::UTF8) } catch [IO.IOException] { }
        }
    }
    if ($null -eq $dump) {
        Get-CimInstance Win32_Process -Filter "Name = 'msedge.exe'" |
            Where-Object { $_.CommandLine -and $_.CommandLine.Contains($profileDir) } |
            ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
        Write-Host ("FAIL  {0}: Edge did not finish within {1} s" -f $name, $TimeoutSeconds)
        return $null
    }
    $m = [regex]::Match($dump, '<pre id="sisula-result">([^<]*)</pre>')
    if (-not $m.Success) { Write-Host ("FAIL  {0}: no result in the page" -f $name); return $null }
    $result = [Net.WebUtility]::HtmlDecode($m.Groups[1].Value)
    if (-not $result.StartsWith('BASE64:')) { Write-Host ("FAIL  {0}: {1}" -f $name, $result); return $null }
    $utf8.GetString([Convert]::FromBase64String($result.Substring(7)))
}

# The first difference between two parsed JSON values, as a path and the two values, or $null.
function Compare-Json($a, $b, [string] $path) {
    if ($null -eq $a -or $null -eq $b) {
        if ($null -eq $a -and $null -eq $b) { return $null }
        return "$path`: modeler [$a] resolver [$b]"
    }
    if ($a -is [System.Collections.IDictionary] -or $b -is [System.Collections.IDictionary]) {
        if (-not ($a -is [System.Collections.IDictionary] -and $b -is [System.Collections.IDictionary])) { return "$path`: object against non-object" }
        foreach ($k in $a.Keys) { if (-not $b.ContainsKey($k)) { return "$path.$k`: only in the modeler's JSON" } }
        foreach ($k in $b.Keys) { if (-not $a.ContainsKey($k)) { return "$path.$k`: only in the resolver's JSON" } }
        foreach ($k in $a.Keys) { $d = Compare-Json $a[$k] $b[$k] "$path.$k"; if ($d) { return $d } }
        return $null
    }
    if (($a -is [System.Collections.IEnumerable] -and $a -isnot [string]) -or ($b -is [System.Collections.IEnumerable] -and $b -isnot [string])) {
        if (-not (($a -is [System.Collections.IEnumerable] -and $a -isnot [string]) -and ($b -is [System.Collections.IEnumerable] -and $b -isnot [string]))) { return "$path`: array against non-array" }
        $x = @($a); $y = @($b)
        if ($x.Count -ne $y.Count) { return "$path`: modeler has $($x.Count) items, resolver $($y.Count)" }
        for ($i = 0; $i -lt $x.Count; $i++) { $d = Compare-Json $x[$i] $y[$i] "$path[$i]"; if ($d) { return $d } }
        return $null
    }
    if ($a.GetType() -ne $b.GetType() -or $a -cne $b) { return "$path`: modeler [$a] ($($a.GetType().Name)) resolver [$b] ($($b.GetType().Name))" }
    return $null
}

Add-Type -AssemblyName System.Web.Extensions
$failed = 0
try {
    foreach ($v in $Variant) {
        $modelPath = Join-Path $root "models\$v.xml"
        $model = [IO.File]::ReadAllText($modelPath, [Text.Encoding]::UTF8)
        if ($Canonicalize) {
            $saved = Invoke-Modeler $v $model 'save'
            if ($null -eq $saved) { $failed++; continue }
            # Saving stamps the current date and time on the schema element; keep the file's own,
            # so a canonical model stays byte-identical when it is canonicalised again. Then put
            # every element on a line of its own: the serializer writes them all on one line, and
            # a line break between two tags adds only whitespace text, which the generator ignores.
            $stamp = [regex]::Match($model, '<schema [^>]*?date="([^"]*)" time="([^"]*)"')
            if ($stamp.Success) {
                $saved = [regex]::Replace($saved, '^(<schema [^>]*?date=")[^"]*(" time=")[^"]*(")',
                    '${1}' + $stamp.Groups[1].Value + '${2}' + $stamp.Groups[2].Value + '${3}')
            }
            $saved = $saved.Replace('><', ">`n<")
            $changed = $saved -cne ($model -replace "`r`n", "`n")
            [IO.File]::WriteAllText($modelPath, $saved, $utf8)
            Write-Host ("{0}  {1}: saved as the modeler would save it" -f $(if ($changed) { 'WROTE' } else { 'SAME ' }), $v)
            continue
        }
        if ($Bindings) {
            $json = Invoke-Modeler $v $model 'bindings'
            if ($null -eq $json) { $failed++; continue }
            if ($KeepOutput) { [IO.File]::WriteAllText((Join-Path $KeepOutput "$v.bindings.json"), $json, $utf8) }
            $reference = Join-Path $work "$v.reference.json"
            & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'check.ps1') -Variant $v -Name CreateAnchors -KeepBindings $reference | Out-Null
            $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
            $serializer.MaxJsonLength = [int]::MaxValue
            $serializer.RecursionLimit = 1000
            $actual = $serializer.DeserializeObject($json)
            $expected = $serializer.DeserializeObject([IO.File]::ReadAllText($reference, [Text.Encoding]::UTF8))
            $wrapper = ($actual.Keys | Sort-Object) -join ','
            if ($wrapper -cne 'bindingsVersion,database,schema,temporalization' -or $actual['bindingsVersion'] -ne 1 -or
                $actual['database'] -cne ([regex]::Match($model, 'databaseTarget="(\w+)"').Groups[1].Value) -or $actual['temporalization'] -cne ([regex]::Match($model, 'temporalization="(\w+)"').Groups[1].Value)) {
                Write-Host ("FAIL  {0}: unexpected wrapper ({1}; {2} {3})" -f $v, $wrapper, $actual['database'], $actual['temporalization'])
                $failed++; continue
            }
            # The modeler's input to generation embeds the model's own XML, with a time stamp, as
            # schema.serialization (SQL Server and PostgreSQL schema tracking read it). The models
            # the resolver reads are plain files without it, so check that it is there and leave it out.
            $embedded = $actual['schema']['serialization']
            if ($null -eq $embedded -or -not ([string]$embedded['_serialization']).StartsWith('<schema ')) {
                Write-Host ("FAIL  {0}: schema.serialization is missing or is not the model's XML" -f $v)
                $failed++; continue
            }
            $actual['schema'].Remove('serialization') | Out-Null
            # The stamps that the modeler writes when it saves: its version and the date and time.
            # No generator reads them, and a model file keeps the ones from when it was saved.
            foreach ($stamp in 'format', 'date', 'time') {
                $actual['schema'].Remove($stamp) | Out-Null
                $expected['schema'].Remove($stamp) | Out-Null
            }
            # Key order inside an object is not significant to a template; order of arrays is.
            $difference = Compare-Json $actual['schema'] $expected['schema'] 'schema'
            if ($null -eq $difference) {
                Write-Host ("PASS  {0}: the modeler's JSON bindings equal the resolver's ({1:N0} characters)" -f $v, $json.Length)
            } else {
                Write-Host ("FAIL  {0}: {1}" -f $v, $difference)
                $failed++
            }
            continue
        }
        $sql = Invoke-Modeler $v $model 'sql'
        if ($null -eq $sql) { $failed++; continue }
        if ($KeepOutput) { [IO.File]::WriteAllText((Join-Path $KeepOutput "$v.sql"), $sql, $utf8) }
        $golden = [IO.File]::ReadAllText((Join-Path $root "golden\$v\_full.sql"), [Text.Encoding]::UTF8) -replace "`r`n", "`n"
        if ($sql -ceq $golden) {
            Write-Host ("PASS  {0}: the modeler's output is identical to the golden file ({1:N0} characters)" -f $v, $sql.Length)
        } else {
            $a = $golden -split "`n"; $b = $sql -split "`n"
            $i = 0
            while ($i -lt [Math]::Min($a.Count, $b.Count) -and $a[$i] -ceq $b[$i]) { $i++ }
            Write-Host ("FAIL  {0}: differs from the golden file at line {1}" -f $v, ($i + 1))
            Write-Host ("   golden  [{0}]" -f $(if ($i -lt $a.Count) { $a[$i] } else { '(end)' }))
            Write-Host ("   modeler [{0}]" -f $(if ($i -lt $b.Count) { $b[$i] } else { '(end)' }))
            $failed++
        }
    }
} finally {
    Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
}
if ($failed -gt 0) { exit 1 }
