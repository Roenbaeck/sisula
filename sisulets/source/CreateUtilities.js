/*~
-- creates utility functions needed in the staging
IF Object_Id('${S_SCHEMA}$.Splitter', 'FT') IS NOT NULL
DROP FUNCTION [$S_SCHEMA].[Splitter];
GO

IF Object_Id('${S_SCHEMA}$.MultiSplitter', 'FT') IS NOT NULL
DROP FUNCTION [$S_SCHEMA].[MultiSplitter];
GO

IF Object_Id('${S_SCHEMA}$.ColumnSplitter', 'PC') IS NOT NULL
DROP PROCEDURE [$S_SCHEMA].[ColumnSplitter];
GO

IF Object_Id('${S_SCHEMA}$.MultiColumnSplitter', 'PC') IS NOT NULL
DROP PROCEDURE [$S_SCHEMA].[MultiColumnSplitter];
GO

IF Object_Id('${S_SCHEMA}$.IsType', 'FS') IS NOT NULL
DROP FUNCTION [$S_SCHEMA].[IsType];
GO

IF Object_Id('${S_SCHEMA}$.ToLocalTime', 'FS') IS NOT NULL
DROP FUNCTION [$S_SCHEMA].[ToLocalTime];
GO

IF Object_Id('${S_SCHEMA}$.ToUniversalTime', 'FS') IS NOT NULL 
DROP FUNCTION [$S_SCHEMA].[ToUniversalTime]; 
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
		when patindex('% 2[0-2][0-9][0-9] %', @@VERSION) > 0
		then substring(@@VERSION, patindex('% 2[0-2][0-9][0-9] %', @@VERSION) + 1, 4)
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
	PRINT 'The .NET CLR for SQL Server ' + @version + ' was updated.';
END TRY BEGIN CATCH 
	DECLARE @msg VARCHAR(2000) = ERROR_MESSAGE();
	IF(PATINDEX('%identical%', @msg) > 0) 
	BEGIN 
		PRINT 'The .NET CLR for SQL Server ' + @version + ' has already been installed.';
	END
	ELSE
	BEGIN TRY
		DROP ASSEMBLY Utilities;
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH
END CATCH

IF NOT EXISTS (
	SELECT
		*
	FROM
		sys.assemblies
	WHERE
		name = 'Utilities'
)
BEGIN TRY
    -- since some version of 2017 assemblies must be explicitly whitelisted
    IF(@version >= 2017 AND OBJECT_ID('sys.sp_add_trusted_assembly') IS NOT NULL) 
    BEGIN
		CREATE TABLE #hash([hash] varbinary(64));
		EXEC('INSERT INTO #hash SELECT CONVERT(varbinary(64), ''0x'' + H, 1) FROM OPENROWSET(BULK ''${VARIABLES.SisulaPath}$\code\\Utilities' + @version + '.SHA512'', SINGLE_CLOB) T(H);');
		DECLARE @hash varbinary(64);
		SELECT @hash = [hash] FROM #hash;
        IF NOT EXISTS(SELECT [hash] FROM sys.trusted_assemblies WHERE [hash] = @hash)
            EXEC sys.sp_add_trusted_assembly @hash, N'Utilities';
	END
	CREATE ASSEMBLY Utilities
	AUTHORIZATION dbo
	FROM '${VARIABLES.SisulaPath}$\code\\Utilities' + @version + '.dll'
	WITH PERMISSION_SET = SAFE;
	PRINT 'The .NET CLR for SQL Server ' + @version + ' was installed.'
END TRY BEGIN CATCH 
	PRINT ERROR_MESSAGE();
END CATCH
GO

CREATE FUNCTION [$S_SCHEMA].Splitter(@row AS nvarchar(max), @pattern AS nvarchar(4000))
RETURNS TABLE (
	[match] nvarchar(max),
	[index] int
) AS EXTERNAL NAME Utilities.Splitter.InitMethod;
GO

CREATE FUNCTION [$S_SCHEMA].MultiSplitter(@row AS nvarchar(max), @pattern AS nvarchar(4000))
RETURNS TABLE (
	[match] nvarchar(max),
	[index] int, 
	[group] nvarchar(max)
) AS EXTERNAL NAME Utilities.MultiSplitter.InitMethod;
GO

CREATE FUNCTION [$S_SCHEMA].IsType(@dataValue AS nvarchar(max), @dataType AS nvarchar(4000))
RETURNS bit
AS EXTERNAL NAME Utilities.IsType.InitMethod;
GO

CREATE FUNCTION [$S_SCHEMA].ToLocalTime(@sqlDatetime AS datetime)
RETURNS datetime
AS EXTERNAL NAME Utilities.ToLocalTime.InitMethod;
GO

CREATE FUNCTION [$S_SCHEMA].ToUniversalTime(@sqlDatetime AS datetime) 
RETURNS datetime 
AS EXTERNAL NAME Utilities.ToUniversalTime.InitMethod;
GO

CREATE PROCEDURE [$S_SCHEMA].ColumnSplitter(
	@table AS nvarchar(4000),
	@column AS nvarchar(4000),
	@pattern AS nvarchar(4000),
	@includeColumns AS nvarchar(4000) = null
)
AS EXTERNAL NAME Utilities.ColumnSplitter.InitMethod;
GO

CREATE PROCEDURE [$S_SCHEMA].MultiColumnSplitter(
	@table AS nvarchar(4000),
	@column AS nvarchar(4000),
	@pattern AS nvarchar(4000),
	@includeColumns AS nvarchar(4000) = null
)
AS EXTERNAL NAME Utilities.MultiColumnSplitter.InitMethod;
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
