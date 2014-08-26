IF Object_ID('sp_SMHI_Weather_CreateRawTable', 'P') IS NOT NULL
DROP PROCEDURE [sp_SMHI_Weather_CreateRawTable];
GO
CREATE PROCEDURE [sp_SMHI_Weather_CreateRawTable] 
AS
BEGIN
    IF Object_ID('SMHI_Weather_Raw', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_Raw];
    CREATE TABLE [SMHI_Weather_Raw] (
        _id int identity(1,1) not null primary key,
        _row varchar(max) 
    );
END
GO
IF Object_ID('sp_SMHI_Weather_CreateTypedTables', 'P') IS NOT NULL
DROP PROCEDURE [sp_SMHI_Weather_CreateTypedTables];
GO
CREATE PROCEDURE [sp_SMHI_Weather_CreateTypedTables] 
AS
BEGIN
    IF Object_ID('SMHI_Weather_Temperature_Typed', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_Temperature_Typed];
    CREATE TABLE SMHI_Weather_Temperature_Typed (
        _id int not null,
        [date] datetime null, 
        [hour] char(2) null, 
        [centigrade] decimal(19,10) null
    );
    IF Object_ID('SMHI_Weather_Pressure_Typed', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_Pressure_Typed];
    CREATE TABLE SMHI_Weather_Pressure_Typed (
        _id int not null,
        [date] datetime null, 
        [hour] char(2) null, 
        [pressure] decimal(19,10) null
    );
    IF Object_ID('SMHI_Weather_Wind_Typed', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_Wind_Typed];
    CREATE TABLE SMHI_Weather_Wind_Typed (
        _id int not null,
        [date] datetime null, 
        [hour] char(2) null, 
        [direction] int null, 
        [speed] decimal(19,10) null
    );
END
GO
