@ECHO OFF
REM -------------------------------------------------------------------
REM   This file needs to be saved as UTF-8 with the option "No Mark" 
REM -------------------------------------------------------------------
for /f "tokens=2 delims=:." %%x in ('chcp') do set DEFAULT_CODEPAGE=%%x
chcp 65001>NUL
REM -------------------------------------------------------------------
REM   Change the following variables to reflect your desired settings
REM -------------------------------------------------------------------
set System=NYPD
set Source=Vehicle
set TargetDatabase=Traffic
set SourceDatabase=Stage
set MetaDatabase=Stage
set SisulaPath=%~dp0
REM -------------------------------------------------------------------
echo Using %SisulaPath% as path to the Sisulator.
pushd "%SisulaPath%"

echo Running the Sisulator for source generation...
Sisulator.js -x source.xml -m Source -d source.directive -o source.sql
echo Done, and the result is in source.sql.

echo Running the Sisulator for target generation...
Sisulator.js -x target.xml -m Target -d target.directive -o target.sql
echo Done, and the result is in target.sql.

echo Running the Sisulator for workflow generation...
Sisulator.js -x workflow.xml -m Workflow -d workflow.directive -o workflow.sql
echo Done, and the result is in workflow.sql.

popd
chcp %DEFAULT_CODEPAGE%>NUL
