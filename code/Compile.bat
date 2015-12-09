@ECHO OFF

REM ---- Find the oldest installation ----
FOR /F "tokens=*" %%i in ('reg query "HKLM\Software\Microsoft\NET Framework Setup" /s /t REG_SZ /v InstallPath ^| cscript /NoLogo match.js ".*\sInstallPath\s+REG_SZ\s+(.*)" ^| sort /R') DO SET DotNetPath=%%i
ECHO Using .NET path: %DotNetPath%

ECHO You have the following Assemblies that can be referenced:
FOR /F "tokens=*" %%i in ('reg query "HKLM\Software\Microsoft\Microsoft SQL Server" /s /t REG_SZ /v SharedCode ^| cscript /NoLogo match.js ".*\sSharedCode\s+REG_SZ\s+(.*)"') DO DIR /B /S "%%i\Microsoft.SqlServer.Types.dll" 2>nul | cscript /NoLogo match.js "(.*Microsoft.SqlServer.Types.dll)" | sort /R

REM ----- Change this reference accordingly -----
REM SET Assembly=C:\Program Files (x86)\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Types.dll
SET Assembly=C:\Program Files\Microsoft SQL Server\110\Shared\Microsoft.SqlServer.Types.dll
REM SET Assembly=C:\Program Files\Microsoft SQL Server\120\Shared\Microsoft.SqlServer.Types.dll
REM SET Assembly=C:\Program Files\Microsoft SQL Server\130\Shared\Microsoft.SqlServer.Types.dll

REM ----- Compile -----
ECHO The following command will now be executed:
ECHO %DotNetPath%\csc.exe /optimize /debug- /target:library /reference:"%Assembly%" /out:Utilities.dll Utilities.cs

%DotNetPath%\csc.exe /optimize /debug- /target:library /reference:"%Assembly%" /out:Utilities.dll Utilities.cs
