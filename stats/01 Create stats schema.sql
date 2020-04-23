if not exists (select top 1 [name] from sys.schemas where [name] = 'stats')
begin
	EXEC('create schema [stats]');
end
