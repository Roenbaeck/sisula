@ECHO OFF

echo  * Setting variables found in:
echo    %~f0

REM -------------------------------------------------------------------
REM   Change the following variables to reflect your desired settings
REM -------------------------------------------------------------------
set System=NYPD
set Source=Vehicle
set TargetDatabase=Traffic
set TargetSchema=dbo
set TargetServer=localhost
set SourceDatabase=Stage
set SourceSchema=etl
set SourceServer=localhost
set MetaDatabase=Traffic
REM -------------------------------------------------------------------
