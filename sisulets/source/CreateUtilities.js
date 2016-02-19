/*~
-- creates utility functions needed in the staging
IF Object_Id('${S_SCHEMA}$.Splitter', 'FT') IS NOT NULL
DROP FUNCTION [$S_SCHEMA].[Splitter];
GO

IF Object_Id('${S_SCHEMA}$.IsType', 'FS') IS NOT NULL
DROP FUNCTION [$S_SCHEMA].[IsType];
GO

IF Object_Id('${S_SCHEMA}$.ColumnSplitter', 'PC') IS NOT NULL
DROP PROCEDURE [$S_SCHEMA].[ColumnSplitter];
GO

IF Object_Id('${S_SCHEMA}$.ToLocalTime', 'FS') IS NOT NULL
DROP FUNCTION [$S_SCHEMA].[ToLocalTime];
GO


IF EXISTS (
	SELECT
		*
	FROM
		sys.assemblies
	WHERE
		name = '${S_SCHEMA}$Utilities'
)
DROP ASSEMBLY ${S_SCHEMA}$Utilities;

IF NOT EXISTS (
	SELECT
		*
	FROM
		sys.assemblies
	WHERE
		name = '${S_SCHEMA}$Utilities'
)
BEGIN TRY -- using Microsoft.SQLServer.Types version 13 (2016)
	CREATE ASSEMBLY ${S_SCHEMA}$Utilities
	AUTHORIZATION dbo
	FROM '${VARIABLES.SisulaPath}$\code\\Utilities2016.dll'
	WITH PERMISSION_SET = SAFE;
	PRINT 'The .NET CLR for SQL Server 2016 was installed.'
END TRY
BEGIN CATCH
	PRINT 'The .NET CLR for SQL Server 2016 was NOT installed.'
END CATCH

IF NOT EXISTS (
	SELECT
		*
	FROM
		sys.assemblies
	WHERE
		name = '${S_SCHEMA}$Utilities'
)
BEGIN TRY -- using Microsoft.SQLServer.Types version 12 (2014)
	CREATE ASSEMBLY ${S_SCHEMA}$Utilities
	AUTHORIZATION dbo
	FROM '${VARIABLES.SisulaPath}$\code\\Utilities2014.dll'
	WITH PERMISSION_SET = SAFE;
	PRINT 'The .NET CLR for SQL Server 2014 was installed.'
END TRY
BEGIN CATCH
	PRINT 'The .NET CLR for SQL Server 2014 was NOT installed.'
END CATCH

IF NOT EXISTS (
	SELECT
		*
	FROM
		sys.assemblies
	WHERE
		name = '${S_SCHEMA}$Utilities'
)
BEGIN TRY -- using Microsoft.SQLServer.Types version 11 (2012)
	CREATE ASSEMBLY ${S_SCHEMA}$Utilities
	AUTHORIZATION dbo
	FROM '${VARIABLES.SisulaPath}$\code\\Utilities2012.dll'
	WITH PERMISSION_SET = SAFE;
	PRINT 'The .NET CLR for SQL Server 2012 was installed.'
END TRY
BEGIN CATCH
	PRINT 'The .NET CLR for SQL Server 2012 was NOT installed.'
END CATCH

IF NOT EXISTS (
	SELECT
		*
	FROM
		sys.assemblies
	WHERE
		name = '${S_SCHEMA}$Utilities'
)
BEGIN TRY -- using Microsoft.SQLServer.Types version 10 (2008)
	CREATE ASSEMBLY ${S_SCHEMA}$Utilities
	AUTHORIZATION dbo
	FROM '${VARIABLES.SisulaPath}$\code\\Utilities2008.dll'
	WITH PERMISSION_SET = SAFE;
	PRINT 'The .NET CLR for SQL Server 2008 was installed.'
END TRY
BEGIN CATCH
	PRINT 'The .NET CLR for SQL Server 2008 was NOT installed.'
END CATCH
GO

CREATE FUNCTION [$S_SCHEMA].Splitter(@row AS nvarchar(max), @pattern AS nvarchar(4000))
RETURNS TABLE (
	[match] nvarchar(max),
	[index] int
) AS EXTERNAL NAME ${S_SCHEMA}$Utilities.Splitter.InitMethod;
GO

CREATE FUNCTION [$S_SCHEMA].IsType(@dataValue AS nvarchar(max), @dataType AS nvarchar(4000))
RETURNS bit
AS EXTERNAL NAME ${S_SCHEMA}$Utilities.IsType.InitMethod;
GO

CREATE FUNCTION [$S_SCHEMA].ToLocalTime(@sqlDatetime AS datetime)
RETURNS datetime
AS EXTERNAL NAME ${S_SCHEMA}$Utilities.ToLocalTime.InitMethod;
GO

CREATE PROCEDURE [$S_SCHEMA].ColumnSplitter(
	@table AS nvarchar(4000),
	@column AS nvarchar(4000),
	@pattern AS nvarchar(4000),
	@includeColumns AS nvarchar(4000) = null
)
AS EXTERNAL NAME ${S_SCHEMA}$Utilities.ColumnSplitter.InitMethod;
GO

IF NOT EXISTS (
    SELECT value
    FROM sys.configurations
    WHERE name  = 'clr enabled'
      AND value = 1
)
BEGIN
    EXEC sp_configure 'clr enabled', 1;
    reconfigure with override;
END
GO
~*/
