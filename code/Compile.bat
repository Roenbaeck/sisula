@ECHO OFF

REM ---- Find the oldest installation ----
FOR /F "tokens=*" %%i in ('reg query "HKLM\Software\Microsoft\NET Framework Setup" /s /t REG_SZ /v InstallPath ^| cscript /NoLogo match.js ".*\sInstallPath\s+REG_SZ\s+(.*)" ^| sort /R') DO SET DotNetPath=%%i
ECHO ---------------------------------------------------------------------------
ECHO Using .NET path: %DotNetPath%
ECHO ---------------------------------------------------------------------------
ECHO.

REM *** Code 100 is SQL Server 2008 *** 
REM *** Code 110 is SQL Server 2012 *** 
REM *** Code 120 is SQL Server 2014 *** 
REM *** Code 130 is SQL Server 2016 *** 
REM *** Code 140 is SQL Server 2017 *** 
REM *** Code 150 is SQL Server 2019 *** 

REM ----- Compile -----

SET Assembly=DLL\Microsoft.SqlServer.Types.100.dll
for %%f in (%Assembly%) do echo ---- Compiling for: %%~nf (2008) ----
%DotNetPath%\csc.exe /optimize /debug- /target:library /reference:"%Assembly%" /out:Utilities2008.dll Utilities.cs

SET Assembly=DLL\Microsoft.SqlServer.Types.110.dll
for %%f in (%Assembly%) do echo ---- Compiling for: %%~nf (2012) ----
%DotNetPath%\csc.exe /optimize /debug- /target:library /reference:"%Assembly%" /out:Utilities2012.dll Utilities.cs

SET Assembly=DLL\Microsoft.SqlServer.Types.120.dll
for %%f in (%Assembly%) do echo ---- Compiling for: %%~nf (2014) ----
%DotNetPath%\csc.exe /optimize /debug- /target:library /reference:"%Assembly%" /out:Utilities2014.dll Utilities.cs

SET Assembly=DLL\Microsoft.SqlServer.Types.130.dll
for %%f in (%Assembly%) do echo ---- Compiling for: %%~nf (2016) ----
%DotNetPath%\csc.exe /optimize /debug- /target:library /reference:"%Assembly%" /out:Utilities2016.dll Utilities.cs

SET Assembly=DLL\Microsoft.SqlServer.Types.140.dll
for %%f in (%Assembly%) do echo ---- Compiling for: %%~nf (2017) ----
%DotNetPath%\csc.exe /optimize /debug- /target:library /reference:"%Assembly%" /out:Utilities2017.dll Utilities.cs

SET Assembly=DLL\Microsoft.SqlServer.Types.150.dll
for %%f in (%Assembly%) do echo ---- Compiling for: %%~nf (2019) ----
%DotNetPath%\csc.exe /optimize /debug- /target:library /reference:"%Assembly%" /out:Utilities2019.dll Utilities.cs
