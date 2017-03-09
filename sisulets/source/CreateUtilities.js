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

-- BEGIN! LEGACY --
IF EXISTS (
	SELECT
		*
	FROM
		sys.assemblies
	WHERE
		name = '${S_SCHEMA}$Utilities'
)
DROP ASSEMBLY ${S_SCHEMA}$Utilities;
-- END! LEGACY --

declare @version char(4) =
	case
		when @@VERSION like '% 2016 %' then '2016'
		when @@VERSION like '% 2014 %' then '2014'
		when @@VERSION like '% 2012 %' then '2012'
		when @@VERSION like '% 2008 %' then '2008'
		else '????'
	end

IF EXISTS (
	SELECT
		*
	FROM
		sys.assemblies
	WHERE
		name = 'Utilities'
)
BEGIN TRY
	ALTER ASSEMBLY Utilities
	FROM '${VARIABLES.SisulaPath}$\code\\Utilities' + @version + '.dll'
	WITH PERMISSION_SET = SAFE;
	PRINT 'The .NET CLR for SQL Server ' + @version + ' was updated.'
END TRY BEGIN CATCH END CATCH
ELSE -- assembly does not exist
BEGIN TRY
	CREATE ASSEMBLY Utilities
	AUTHORIZATION dbo
	FROM '${VARIABLES.SisulaPath}$\code\\Utilities' + @version + '.dll'
	WITH PERMISSION_SET = SAFE;
	PRINT 'The .NET CLR for SQL Server ' + @version + ' was installed.'
END TRY BEGIN CATCH END CATCH
GO

CREATE FUNCTION [$S_SCHEMA].Splitter(@row AS nvarchar(max), @pattern AS nvarchar(4000))
RETURNS TABLE (
	[match] nvarchar(max),
	[index] int
) AS EXTERNAL NAME Utilities.Splitter.InitMethod;
GO

CREATE FUNCTION [$S_SCHEMA].IsType(@dataValue AS nvarchar(max), @dataType AS nvarchar(4000))
RETURNS bit
AS EXTERNAL NAME Utilities.IsType.InitMethod;
GO

CREATE FUNCTION [$S_SCHEMA].ToLocalTime(@sqlDatetime AS datetime)
RETURNS datetime
AS EXTERNAL NAME Utilities.ToLocalTime.InitMethod;
GO

CREATE PROCEDURE [$S_SCHEMA].ColumnSplitter(
	@table AS nvarchar(4000),
	@column AS nvarchar(4000),
	@pattern AS nvarchar(4000),
	@includeColumns AS nvarchar(4000) = null
)
AS EXTERNAL NAME Utilities.ColumnSplitter.InitMethod;
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
