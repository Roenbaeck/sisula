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
FROM 'G:\sisula\code\Splitter.dll' -- SUBSTITUTE WITH YOUR PATH!
WITH PERMISSION_SET = SAFE;
GO

CREATE FUNCTION Splitter(@row AS nvarchar(max), @pattern AS nvarchar(555))
RETURNS TABLE (
	[match] nvarchar(max)
) AS EXTERNAL NAME StringUtilities.Splitter.InitMethod;
GO

sp_configure 'clr enabled', 1
GO
reconfigure with override
GO

/*
with strgen as (
	select
		'Hello World' as s,
		1 as n
	union all 
	select
		s,
		n + 1
	from 
		strgen
	where
		n < 100000
)
select
	*
from 
	strgen
cross apply (
	select 
		[match],
		ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as i
	from
		dbo.Splitter(N'Hello World', N'(.{2}).*(Wo)(rl).*')
) s
pivot (
	max(match) for i in ([2], [3], [4], [5])
) p
option (maxrecursion 0);
*/




