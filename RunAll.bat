@ECHO OFF

set System=SMHI
set Source=Weather

echo Running the Sisulator for job generation...
Sisulator.js -x job.xml -m Job -d job.directive -o job.sql
echo Done, and the result is in job.sql.

echo Running the Sisulator for work generation...
Sisulator.js -x source.xml -m Source -d source.directive -o source.sql
echo Done, and the result is in source.sql.
