<#
    Runs the user-interface tests of the Anchor Modeler (ui-tests.js) in its own page, in headless Microsoft Edge, with no
    other software. The tests drive the page the way a user does and look at what it then holds; see ui-tests.js. What they
    record (the fingerprints of the saved model after each step, the numbers of fields and operations, and so on) is compared
    with ui-golden.json, the way check.ps1 compares SQL with its golden files. A change in the page that is meant to change
    one of those values is approved with -Update.

    Usage:
      ui-check.ps1 [-Anchor <checkout>] [-Only <part of a test name>,...] [-Update] [-Edge <msedge.exe>] [-TimeoutSeconds 180]

    Nothing is written to the Anchor checkout. A copy of index.html is made in a temporary folder with a <base> pointing at
    the checkout (the Google Fonts links of older versions are left out, so that no network is needed), and the tests added.
    The page's alert, confirm and prompt are answered (confirm says yes), and fetch is served through XMLHttpRequest, since
    Chromium's fetch cannot read file:// URLs. Exits 1 if a test fails or a recorded value differs.
#>
[CmdletBinding()]
param(
    [string] $Anchor,
    [string[]] $Only,
    [switch] $Update,
    [string] $Edge,
    [int] $TimeoutSeconds = 180
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $Anchor) { $Anchor = Join-Path (Split-Path -Parent (Split-Path -Parent $root)) 'anchor' }
$Anchor = (Resolve-Path $Anchor).Path
if (-not $Edge) {
    $Edge = @('C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe', 'C:\Program Files\Microsoft\Edge\Application\msedge.exe') | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $Edge) { throw 'Microsoft Edge was not found; pass -Edge.' }
if ($Only -and $Only.Count -eq 1 -and $Only[0] -match ',') { $Only = $Only[0] -split ',' }
$utf8 = New-Object Text.UTF8Encoding($false)
$bs = [string][char]92
$dq = [string][char]34

function Quote([string] $text) {
    $dq + $text.Replace($bs, $bs + $bs).Replace($dq, $bs + $dq).Replace("`r", $bs + 'r').Replace("`n", $bs + 'n').Replace('</', '<' + $bs + '/') + $dq
}

$page = [IO.File]::ReadAllText((Join-Path $Anchor 'index.html'), [Text.Encoding]::UTF8)
foreach ($f in [regex]::Matches($page, '<link href=''https://fonts\.googleapis\.com/[^>]*>')) { $page = $page.Replace($f.Value, '') }
$headAt = $page.IndexOf('<head>')
$bodyEndAt = $page.LastIndexOf('</body>')
if ($headAt -lt 0 -or $headAt -gt 500 -or $bodyEndAt -lt $page.Length - 500) { throw 'Could not find the <head> and </body> of index.html where expected.' }
$baseHref = 'file:///' + $Anchor.Replace($bs, '/').TrimEnd('/') + '/'
$models = '{' + ((@('example.xml', 'examples/roastery.xml') | ForEach-Object { (Quote $_) + ':' + (Quote ([IO.File]::ReadAllText((Join-Path $Anchor $_), [Text.Encoding]::UTF8))) }) -join ',') + '}'
$onlyJs = if ($Only) { '[' + (($Only | ForEach-Object { Quote $_ }) -join ',') + ']' } else { 'null' }
$head = "`n<base href=`"$baseHref`"><script>window.__errs=[];window.addEventListener('error',function(e){window.__errs.push(e.message+' @'+e.lineno)});window.__MODELS=$models;window.__ONLY=$onlyJs;</script>"
$page = $page.Insert($headAt + '<head>'.Length, $head)
$bodyEndAt = $page.LastIndexOf('</body>')
$harness = @'
<pre id="ui-result">PENDING</pre>
<script>
window.alert = function () {};
window.confirm = function () { return true; };
window.prompt = function (message, defaultValue) { return defaultValue; };
window.fetch = function (url) {
    return new Promise(function (resolve, reject) {
        var request = new XMLHttpRequest();
        request.open('GET', url, true);
        request.onload = function () { resolve({ ok: true, status: 200, text: function () { return Promise.resolve(request.responseText); } }); };
        request.onerror = function () { reject(new Error('could not read ' + url)); };
        request.send();
    });
};
window.addEventListener('unhandledrejection', function (e) { document.getElementById('ui-result').textContent = 'ERROR ' + (e.reason && e.reason.stack || e.reason); });
</script>
<script>
__TESTS__
</script>
<script>
window.addEventListener('load', function () { setTimeout(function () { window.__runUiTests().catch(function (e) { document.getElementById('ui-result').textContent = 'ERROR ' + (e && e.stack || e); }); }, 1000); });
</script>
'@
$tests = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'ui-tests.js'), [Text.Encoding]::UTF8)
$html = $page.Insert($bodyEndAt, $harness.Replace('__TESTS__', $tests))
$work = Join-Path ([IO.Path]::GetTempPath()) ('anchor-ui-check-' + [Guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force $work | Out-Null
$pagePath = Join-Path $work 'page.html'
[IO.File]::WriteAllText($pagePath, $html, $utf8)
# Edge now and then dumps the page before the tests have finished (headless virtual time); that is tried again, twice
for ($attempt = 1; $attempt -le 3; $attempt++) {
$profileDir = Join-Path $work "profile$attempt"
$dumpPath = Join-Path $work "dump$attempt.html"
$arguments = @('--headless', '--disable-gpu', '--no-first-run', '--no-default-browser-check', '--disable-extensions', '--allow-file-access-from-files',
    "--user-data-dir=`"$profileDir`"", '--window-size=1440,900', '--virtual-time-budget=900000', '--dump-dom', ('"file:///' + $pagePath.Replace($bs, '/') + '"'))
$process = Start-Process -FilePath $Edge -ArgumentList $arguments -RedirectStandardOutput $dumpPath -RedirectStandardError (Join-Path $work 'err.txt') -PassThru -WindowStyle Hidden
$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
$dump = $null
while ($null -eq $dump -and (Get-Date) -lt $deadline) {
    Start-Sleep -Milliseconds 500
    $running = @(Get-CimInstance Win32_Process -Filter "Name = 'msedge.exe'" | Where-Object { $_.CommandLine -and $_.CommandLine.Contains($profileDir) })
    if ($process.HasExited -and $running.Count -eq 0) { try { $dump = [IO.File]::ReadAllText($dumpPath, [Text.Encoding]::UTF8) } catch [IO.IOException] { } }
}
if ($null -eq $dump) {
    Get-CimInstance Win32_Process -Filter "Name = 'msedge.exe'" | Where-Object { $_.CommandLine -and $_.CommandLine.Contains($profileDir) } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    Write-Host "FAIL  Edge did not finish within $TimeoutSeconds s"; exit 1
}
Remove-Item -Recurse -Force $profileDir -ErrorAction SilentlyContinue
$m = [regex]::Match($dump, '<pre id="ui-result">([^<]*)</pre>')
if (-not $m.Success) { Write-Host 'FAIL  no result in the page'; exit 1 }
$text = [Net.WebUtility]::HtmlDecode($m.Groups[1].Value)
if ($text.StartsWith('PENDING') -and $attempt -lt 3) { Write-Host "NOTE  the page had not finished ($text); trying again"; continue }
break
}
if (-not $text.StartsWith('BASE64:')) { Write-Host "FAIL  $text"; exit 1 }
Add-Type -AssemblyName System.Web.Extensions
$serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
$serializer.MaxJsonLength = 100MB
$outcome = $serializer.DeserializeObject($utf8.GetString([Convert]::FromBase64String($text.Substring(7))))
$failed = 0
foreach ($r in $outcome['results']) {
    if ($r['ok']) { Write-Host ('PASS  ' + $r['name']) } else { Write-Host ('FAIL  ' + $r['name'] + ': ' + $r['message']); $failed++ }
}
$goldenPath = Join-Path $PSScriptRoot 'ui-golden.json'
$observed = $outcome['observed']
if ($Update) {
    $sorted = [ordered]@{}
    foreach ($k in ($observed.Keys | Sort-Object)) { $sorted[$k] = $observed[$k] }
    [IO.File]::WriteAllText($goldenPath, ((($sorted | ConvertTo-Json) -replace "`r`n", "`n") + "`n"), $utf8)
    Write-Host "Wrote $goldenPath ($($observed.Count) values)"
}
elseif (Test-Path $goldenPath) {
    $golden = $serializer.DeserializeObject([IO.File]::ReadAllText($goldenPath, [Text.Encoding]::UTF8))
    foreach ($k in ($observed.Keys | Sort-Object)) {
        if (-not $golden.ContainsKey($k)) { Write-Host "FAIL  recorded $k = $($observed[$k]), but the golden file has no such value"; $failed++ }
        elseif ("$($golden[$k])" -ne "$($observed[$k])") { Write-Host "FAIL  recorded $k differs: was [$($golden[$k])], is now [$($observed[$k])]"; $failed++ }
    }
    if (-not $Only) { foreach ($k in $golden.Keys) { if (-not $observed.ContainsKey($k)) { Write-Host "FAIL  the golden file has $k, which was not recorded"; $failed++ } } }
    if ($failed -eq 0) { Write-Host "PASS  recorded values equal the golden file ($($observed.Count))" }
}
else { Write-Host "NOTE  no golden file yet; run with -Update" }
Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
if ($failed -gt 0) { exit 1 }
