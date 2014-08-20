CREATE TABLE SMHI_Weather_Raw (
    _id int identity(1,1) not null primary key,
    _row varchar(max) 
);
CREATE TABLE SMHI_Weather_Temperature_Typed (
    _id int not null,
    [date] datetime null, 
    [hour] char(2) null, 
    [centigrade] decimal(19,10) null
);
CREATE TABLE SMHI_Weather_Pressure_Typed (
    _id int not null,
    [date] datetime null, 
    [hour] char(2) null, 
    [pressure] decimal(19,10) null
);
CREATE TABLE SMHI_Weather_Wind_Typed (
    _id int not null,
    [date] datetime null, 
    [hour] char(2) null, 
    [direction] int null, 
    [speed] decimal(19,10) null
);
