<#
    Makes models/sqlserver-tieflags-bi.xml and models/sqlserver-tieflags-crt.xml from the flags models
    (models/sqlserver-flags-bi.xml, -crt.xml): every tie idempotent and assertive, and a tie that was restatable
    not restatable. No other model has an idempotent tie, so the code that handles one (the restatement of a
    historized tie, the statement types of the posit and annex rows) would otherwise never be compared with the
    original. Like the others, each model then has to be saved through the modeler (browser-check.ps1 -Canonicalize).

    Usage:
      make-sqlserver-tieflags-models.ps1
      browser-check.ps1 -Canonicalize -Variant sqlserver-tieflags-bi,sqlserver-tieflags-crt
#>
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$models = Join-Path (Split-Path -Parent $PSScriptRoot) 'models'
$utf8 = New-Object Text.UTF8Encoding($false)
$pattern = '(<tie [^>]*>(?:(?!</tie>).)*?)<metadata capsule="ties" generator="true" assertive="false"( restatable="(?:true|false)")?( deletable="false")? idempotent="false"/>'
foreach ($t in 'bi', 'crt') {
    $text = [IO.File]::ReadAllText((Join-Path $models "sqlserver-flags-$t.xml"), $utf8)
    $copy = [regex]::Replace($text, $pattern, {
        param($m)
        $m.Groups[1].Value + '<metadata capsule="ties" generator="true" assertive="true"' + $(if ($m.Groups[2].Success) { ' restatable="false"' } else { '' }) + ' deletable="false" idempotent="true"/>'
    }, 'Singleline')
    $count = ([regex]::Matches($copy, 'assertive="true"( restatable="false")? deletable="false" idempotent="true"/>')).Count
    $ties = ([regex]::Matches($text, '<tie ')).Count
    if ($count -ne $ties) { throw "sqlserver-flags-${t}: $count of $ties ties were changed" }
    [IO.File]::WriteAllText((Join-Path $models "sqlserver-tieflags-$t.xml"), $copy, $utf8)
    Write-Host "sqlserver-tieflags-$t ($ties ties)"
}
