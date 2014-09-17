@ECHO OFF
REM -------------------------------------------------------------------
REM   This file needs to be saved as UTF-8 with the option "No Mark" 
REM -------------------------------------------------------------------
for /f "tokens=2 delims=:." %%x in ('chcp') do set DEFAULT_CODEPAGE=%%x
chcp 65001>NUL
REM -------------------------------------------------------------------
REM   Change the following variables to reflect your desired settings
REM -------------------------------------------------------------------
set System=SMHI
set Source=Weather
set Database=Stage
REM -------------------------------------------------------------------

echo Running the Sisulator for work generation...
Sisulator.js -x source.xml -m Source -d work.directive -o work.sql
echo Done, and the result is in work.sql.

echo Running the Sisulator for job generation...
Sisulator.js -x job.xml -m Job -d job.directive -o job.sql
echo Done, and the result is in job.sql.

chcp %DEFAULT_CODEPAGE%>NUL
