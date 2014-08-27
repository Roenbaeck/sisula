@ECHO OFF

set System=SMHI
set Source=Weather
set Database=Test

echo Running the Sisulator for work generation...
Sisulator.js -x source.xml -m Source -d work.directive -o work.sql
echo Done, and the result is in work.sql.

echo Running the Sisulator for job generation...
Sisulator.js -x job.xml -m Job -d job.directive -o job.sql
echo Done, and the result is in job.sql.

