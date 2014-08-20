@ECHO OFF

set MyOwnEnvVar=Hello World!

echo Running the Sisulator...
Sisulator.js -x job.xml -m Job -d job.directive -o code.sql
echo Done, and the result is in code.sql.
