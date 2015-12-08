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


IF EXISTS (
	SELECT
		*
	FROM
		sys.assemblies
	WHERE
		name = '${S_SCHEMA}$Utilities'
)
DROP ASSEMBLY ${S_SCHEMA}$Utilities;

BEGIN TRY -- using Microsoft.SQLServer.Types version 11 (2012+)
	CREATE ASSEMBLY ${S_SCHEMA}$Utilities
	AUTHORIZATION dbo
	FROM '${VARIABLES.SisulaPath}$\code\\Utilities2012.dll'
	WITH PERMISSION_SET = SAFE;
END TRY
BEGIN CATCH -- using Microsoft.SQLServer.Types version 10 (2008)
	CREATE ASSEMBLY ${S_SCHEMA}$Utilities
	AUTHORIZATION dbo
	FROM '${VARIABLES.SisulaPath}$\code\\Utilities2008.dll'
	WITH PERMISSION_SET = SAFE;
END CATCH
GO

CREATE FUNCTION [$S_SCHEMA].Splitter(@row AS nvarchar(max), @pattern AS nvarchar(4000))
RETURNS TABLE (
	[match] nvarchar(max)
) AS EXTERNAL NAME ${S_SCHEMA}$Utilities.Splitter.InitMethod;
GO

CREATE FUNCTION [$S_SCHEMA].IsType(@dataValue AS nvarchar(max), @dataType AS nvarchar(4000))
RETURNS BIT
AS EXTERNAL NAME ${S_SCHEMA}$Utilities.IsType.InitMethod;
GO

CREATE PROCEDURE [$S_SCHEMA].ColumnSplitter(
	@table AS nvarchar(4000), 
	@column AS nvarchar(4000), 
	@pattern AS nvarchar(4000),
	@includeColumns AS nvarchar(4000)
)
AS EXTERNAL NAME etlUtilities.ColumnSplitter.InitMethod;
GO

sp_configure 'clr enabled', 1
GO
reconfigure with override
GO
~*/
