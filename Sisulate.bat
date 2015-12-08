@ECHO OFF
set FolderPath=%~f1
set Server=%2
set SQLFiles=

REM -------------------------------------------------------------------
REM   Print out program syntax if no arguments are given
REM -------------------------------------------------------------------
if [%FolderPath%]==[] (
  echo SYNTAX: Sisulate ^<folder name^> [server name]
  echo -----------------------------------------------------------------------
  echo You must specify in which folder your configuration files are located.
  echo Note that if no server name is given the generated SQL files must be
  echo installed manually on the server.
  echo -----------------------------------------------------------------------
  GOTO ERROR
)

echo -------------------------------------------------------------------
echo  sisula starting                            %date% %time%
echo -------------------------------------------------------------------
echo.

REM -------------------------------------------------------------------
REM   This file needs to be saved as UTF-8 with the option "No Mark"
REM -------------------------------------------------------------------
for /f "tokens=2 delims=:." %%x in ('chcp') do set DEFAULT_CODEPAGE=%%x
chcp 65001>NUL
set SisulaPath=%~dp0
echo  * Path to the sisula ETL Framework installation:
echo    %SisulaPath%
echo  * Path to the specified folder containing configuration files:
echo    %FolderPath%
pushd "%SisulaPath%"
echo  * Entered pushd directory:
echo    %CD%

REM -------------------------------------------------------------------
REM   Initiate project specific variables
REM -------------------------------------------------------------------
CALL "%FolderPath%\Variables.BAT"

SETLOCAL ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS
set i=-1

REM -------------------------------------------------------------------
REM   Create bulk format files
REM -------------------------------------------------------------------
for %%f in (%FolderPath%\sources\*.xml) do (
  set OutputFile=%FolderPath%\formats\%%~nf.xml
  echo  * Transforming source to bulk format file:
  echo    %%~f ...
  echo    !OutputFile!
  Sisulator.js -x "%%~f" -m Source -d format.directive -o "!OutputFile!"
  IF ERRORLEVEL 1 GOTO ERROR
)

REM -------------------------------------------------------------------
REM   Create source loading SQL code
REM   Note that the name of the corresponding format file is needed
REM -------------------------------------------------------------------
for %%f in (%FolderPath%\sources\*.xml) do (
  set OutputFile=%FolderPath%\sources\%%~nf.sql
  set FormatFile=%FolderPath%\formats\%%~nf.xml
  echo  * Transforming source to SQL loading stored procedures:
  echo    %%~f ...
  echo    !OutputFile!
  Sisulator.js -x "%%~f" -m Source -d source.directive -o "!OutputFile!"
  IF ERRORLEVEL 1 GOTO ERROR
  set /a i=!i!+1
  set SQLFiles[!i!]=!OutputFile!
)

REM -------------------------------------------------------------------
REM   Create target loading SQL code
REM -------------------------------------------------------------------
for %%f in (%FolderPath%\targets\*.xml) do (
  set OutputFile=%FolderPath%\targets\%%~nf.sql
  echo  * Transforming target to SQL loading stored procedures:
  echo    %%~f ...
  echo    !OutputFile!
  Sisulator.js -x "%%~f" -m Target -d target.directive -o "!OutputFile!"
  IF ERRORLEVEL 1 GOTO ERROR
  set /a i=!i!+1
  set SQLFiles[!i!]=!OutputFile!
)

REM -------------------------------------------------------------------
REM   Create SQL Server Agent job code
REM -------------------------------------------------------------------
for %%f in (%FolderPath%\workflows\*.xml) do (
  set OutputFile=%FolderPath%\workflows\%%~nf.sql
  echo  * Transforming workflow to SQL Server Agent job scripts:
  echo    %%~f ...
  echo    !OutputFile!
  Sisulator.js -x "%%~f" -m Workflow -d workflow.directive -o "!OutputFile!"
  IF ERRORLEVEL 1 GOTO ERROR
  set /a i=!i!+1
  set SQLFiles[!i!]=!OutputFile!
)

REM -------------------------------------------------------------------
REM   Install the generated SQL files in the database server
REM -------------------------------------------------------------------
if defined Server (
  for /L %%f in (0,1,!i!) do (
    echo.
    echo  * Installing SQL file:
    echo    !SQLFiles[%%f]!
    echo .
    sqlcmd -S %Server% -i "!SQLFiles[%%f]!" -I -x -b -r1 >NUL
    IF ERRORLEVEL 1 GOTO ERROR
  )
)

echo.
echo -------------------------------------------------------------------
echo  sisula ending                              %date% %time%
echo -------------------------------------------------------------------

:ERROR
REM -------------------------------------------------------------------
REM This is the end (do these things regardless of state)
REM -------------------------------------------------------------------
ENDLOCAL
chcp %DEFAULT_CODEPAGE%>NUL
popd
