// Create a raw table suitable for bulk insert
/*~
CREATE TABLE $source.qualified$_Raw (
    _id int identity(1,1) not null primary key,
    _row $(source.characterType == 'char')? varchar(max) : nvarchar(max)
);
~*/
