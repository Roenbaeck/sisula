IF Object_Id('dbo.Splitter', 'FT') IS NOT NULL
DROP FUNCTION [dbo].[Splitter];
GO

IF EXISTS (
	SELECT
		*
	FROM
		sys.assemblies
	WHERE
		name = 'StringUtilities'
)
DROP ASSEMBLY StringUtilities;

CREATE ASSEMBLY StringUtilities 
AUTHORIZATION dbo 
FROM 'C:\sisula\code\Splitter.dll'
WITH PERMISSION_SET = SAFE;
GO

CREATE FUNCTION Splitter(@row AS nvarchar(max), @pattern AS nvarchar(555))
RETURNS TABLE (match nvarchar(max)) AS EXTERNAL NAME StringUtilities.Splitter.InitMethod;
GO

sp_configure 'clr enabled', 1
GO
reconfigure with override
GO

-- select * from dbo.Splitter(N'Hello World', N'(.{2}).*(Wo)(rl).*')

