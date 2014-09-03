USE Test;
GO
IF Object_ID('SMHI_Weather_CreateRawTable', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_CreateRawTable];
GO
CREATE PROCEDURE [SMHI_Weather_CreateRawTable] 
AS
BEGIN
    SET NOCOUNT ON;
    IF Object_ID('SMHI_Weather_Raw', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_Raw];
    CREATE TABLE [SMHI_Weather_Raw] (
        [row] nvarchar(max)
    );
END
GO
IF Object_ID('SMHI_Weather_BulkInsert', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_BulkInsert];
GO
CREATE PROCEDURE [SMHI_Weather_BulkInsert] (
	@filename varchar(2000)
)
AS
BEGIN
    SET NOCOUNT ON;
    IF Object_ID('SMHI_Weather_Raw', 'U') IS NOT NULL
	EXEC('
		BULK INSERT [SMHI_Weather_Raw]
		FROM ''' + @filename + '''
        WITH (
            CODEPAGE = ''ACP'',
            DATAFILETYPE = ''char'',
            FIELDTERMINATOR = ''\r\n'',
            TABLOCK 
        );
	');
END
GO
IF Object_ID('SMHI_Weather_AddKeyToRawTable', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_AddKeyToRawTable];
GO
CREATE PROCEDURE [SMHI_Weather_AddKeyToRawTable] 
AS
BEGIN
    SET NOCOUNT ON;
    IF Object_ID('SMHI_Weather_Raw', 'U') IS NOT NULL
    ALTER TABLE [SMHI_Weather_Raw]
    ADD _id int identity(1,1) not null primary key;
END
GO
IF Object_ID('SMHI_Weather_CreateTypedTables', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_CreateTypedTables];
GO
CREATE PROCEDURE [SMHI_Weather_CreateTypedTables] 
AS
BEGIN
    SET NOCOUNT ON;
    IF Object_ID('SMHI_Weather_Temperature_Typed', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_Temperature_Typed];
    CREATE TABLE SMHI_Weather_Temperature_Typed (
        _id int not null,
        [date] datetime not null, 
        [hour] char(2) not null, 
        [degrees] int null, 
        [fraction] int null
    );
    IF Object_ID('SMHI_Weather_Pressure_Typed', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_Pressure_Typed];
    CREATE TABLE SMHI_Weather_Pressure_Typed (
        _id int not null,
        [date] datetime not null, 
        [hour] char(2) not null, 
        [pressure] decimal(19,10) null
    );
    IF Object_ID('SMHI_Weather_Wind_Typed', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_Wind_Typed];
    CREATE TABLE SMHI_Weather_Wind_Typed (
        _id int not null,
        [date] datetime not null, 
        [hour] char(2) not null, 
        [direction] int null, 
        [speed] decimal(19,10) null
    );
END
GO
IF Object_ID('SMHI_Weather_SplitRawIntoTyped', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_SplitRawIntoTyped];
GO
CREATE PROCEDURE [SMHI_Weather_SplitRawIntoTyped] 
AS
BEGIN
    SET NOCOUNT ON;
    IF Object_ID('SMHI_Weather_Temperature_Typed', 'U') IS NOT NULL
    INSERT INTO [SMHI_Weather_Temperature_Typed] (
        [date], 
        [hour], 
        [degrees], 
        [fraction]
    )
    SELECT
        c1.[date], 
        c2.[hour], 
        c3.[degrees], 
        c4.[fraction]
    FROM ( 
        SELECT * FROM SMHI_Weather_Raw WHERE [row] LIKE 'TEMP%'
        ) src 
    CROSS APPLY (SELECT SUBSTRING(src.[row], 5, 2147483647)) c0 ([row])
    CROSS APPLY (SELECT NULLIF(LEFT(c0.[row], 6), ''), SUBSTRING(c0.[row], 7, 2147483647)) c1 ([date], [row])
    CROSS APPLY (SELECT NULLIF(LEFT(c1.[row], 4), ''), SUBSTRING(c1.[row], 5, 2147483647)) c2 ([hour], [row])
    CROSS APPLY (SELECT NULLIF(CHARINDEX(' ', c2.[row]), 0)) d2 (p)
    CROSS APPLY (SELECT NULLIF(LEFT(c2.[row], d2.p - 1), ''), SUBSTRING(c2.[row], d2.p + 1, 2147483647)) c3 ([degrees], [row])
    CROSS APPLY (SELECT NULLIF(CHARINDEX(' ', c3.[row]), 0)) d3 (p)
    CROSS APPLY (SELECT NULLIF(LEFT(c3.[row], d3.p - 1), ''), SUBSTRING(c3.[row], d3.p + 1, 2147483647)) c4 ([fraction], [row]);
    IF Object_ID('SMHI_Weather_Pressure_Typed', 'U') IS NOT NULL
    INSERT INTO [SMHI_Weather_Pressure_Typed] (
        [date], 
        [hour], 
        [pressure]
    )
    SELECT
        c1.[date], 
        c2.[hour], 
        c3.[pressure]
    FROM (
        SELECT * FROM SMHI_Weather_Raw WHERE [row] LIKE 'PRSR%'
        ) src 
    CROSS APPLY (SELECT [row]) c0 ([row])
    CROSS APPLY (SELECT NULLIF(LEFT(c0.[row], 6), ''), SUBSTRING(c0.[row], 7, 2147483647)) c1 ([date], [row])
    CROSS APPLY (SELECT NULLIF(LEFT(c1.[row], 4), ''), SUBSTRING(c1.[row], 5, 2147483647)) c2 ([hour], [row])
    CROSS APPLY (SELECT NULLIF(LEFT(c2.[row], 10), ''), SUBSTRING(c2.[row], 11, 2147483647)) c3 ([pressure], [row]); 
    IF Object_ID('SMHI_Weather_Wind_Typed', 'U') IS NOT NULL
    INSERT INTO [SMHI_Weather_Wind_Typed] (
        [date], 
        [hour], 
        [direction], 
        [speed]
    )
    SELECT
        c1.[date], 
        c2.[hour], 
        c3.[direction], 
        c4.[speed]
    FROM (
        SELECT * FROM SMHI_Weather_Raw WHERE [row] LIKE 'WNDS%'
        ) src 
    CROSS APPLY (SELECT [row]) c0 ([row])
    CROSS APPLY (SELECT NULLIF(LEFT(c0.[row], 6), ''), SUBSTRING(c0.[row], 7, 2147483647)) c1 ([date], [row])
    CROSS APPLY (SELECT NULLIF(LEFT(c1.[row], 4), ''), SUBSTRING(c1.[row], 5, 2147483647)) c2 ([hour], [row])
    CROSS APPLY (SELECT NULLIF(LEFT(c2.[row], 10), ''), SUBSTRING(c2.[row], 11, 2147483647)) c3 ([direction], [row])
    CROSS APPLY (SELECT NULLIF(LEFT(c3.[row], 10), ''), SUBSTRING(c3.[row], 11, 2147483647)) c4 ([speed], [row]); 
END
GO
