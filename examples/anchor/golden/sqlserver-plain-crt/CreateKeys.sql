-- NATURAL KEYS -------------------------------------------------------------------------------------------------------
--
-- A natural key is a route in the model: the values that identify an anchor or a nexus, reached from it through its
-- attributes, its roles and ties (see naturalKeys() in Helpers.js for the rules a route follows). For each route of
-- each anchor and nexus there is
--
--   key_<anchor or nexus>_<route>          the key of every identity, from the latest values, with one column for
--                                          each value; a value with a checksum, such as a geography, is followed by
--                                          its checksum, which is what it is matched on
--   pkey_<anchor or nexus>_<route>(time)   the key of every identity at a changing time, for a route that passes
--                                          something historized, since its key can change
--   ic_key_<anchor or nexus>_<route>       the keys that more than one identity has, and the identities that have
--                                          more than one key; a view that returns nothing has nothing wrong
--   <anchor or nexus>_<route>              a table with the key of every identity that has all of its values, and a
--   refresh_<anchor or nexus>_<route>      procedure that fills it from the key view; its unique constraint makes the
--                                          procedure fail when two identities have the same key, and it can be indexed
--
-- Every key is per positor, as the perspectives are.
--
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_ST_Stage_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_ST_Stage_1st];
GO
CREATE VIEW [dbo].[key_ST_Stage_1st] AS
SELECT
    [ST].Positor,
    [ST].ST_ID,
    [ST].ST_LOC_Stage_Location AS ST_LOC_Stage_Location,
    [ST].ST_LOC_Checksum AS ST_LOC_Checksum
FROM
    [dbo].[lST_Stage] [ST]
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_ST_Stage_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_ST_Stage_1st];
GO
CREATE VIEW [dbo].[ic_key_ST_Stage_1st] AS
SELECT
    'key_ST_Stage_1st' AS Construct,
    'duplicate natural key' AS Violation,
    CONCAT(
        'Positor=', d.Positor, ', ',
        'ST_LOC_Checksum=', CONVERT(varchar(max), d.ST_LOC_Checksum, 1)
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Positor,
        ST_LOC_Checksum,
        COUNT(DISTINCT ST_ID) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_1st]
    WHERE
        ST_LOC_Checksum is not null
    GROUP BY
        Positor,
        ST_LOC_Checksum
    HAVING
        COUNT(DISTINCT ST_ID) > 1
) d
UNION ALL
SELECT
    'key_ST_Stage_1st',
    'more than one natural key',
    CONCAT(
        'Positor=', d.Positor, ', ',
        'ST_ID=', d.ST_ID
    ),
    d.Occurrences
FROM (
    SELECT
        Positor,
        ST_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_1st]
    GROUP BY
        Positor,
        ST_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage, filled by refresh_ST_Stage_1st
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_Stage_1st', 'U') IS NOT NULL
DROP TABLE [dbo].[ST_Stage_1st];
GO
CREATE TABLE [dbo].[ST_Stage_1st] (
    Positor tinyint not null,
    ST_ID int not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum varbinary(16) not null,
    constraint pkST_Stage_1st primary key (
        Positor,
        ST_ID
    ),
    constraint uqST_Stage_1st unique (
        Positor,
        ST_LOC_Checksum
    )
);
GO
IF Object_ID('dbo.refresh_ST_Stage_1st', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_ST_Stage_1st];
GO
CREATE PROCEDURE [dbo].[refresh_ST_Stage_1st] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[ST_Stage_1st];
    INSERT INTO [dbo].[ST_Stage_1st] (
        Positor,
        ST_ID,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum
    )
    SELECT
        Positor,
        ST_ID,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum
    FROM
        [dbo].[key_ST_Stage_1st]
    WHERE
        ST_LOC_Checksum is not null
    ;
    COMMIT;
END
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_ST_Stage_2nd', 'V') IS NOT NULL
DROP VIEW [dbo].[key_ST_Stage_2nd];
GO
CREATE VIEW [dbo].[key_ST_Stage_2nd] AS
SELECT
    [ST].Positor,
    [ST].ST_ID,
    [ST].ST_NAM_Stage_Name AS ST_NAM_Stage_Name
FROM
    [dbo].[lST_Stage] [ST]
;
GO
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage at a changing time
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.pkey_ST_Stage_2nd', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pkey_ST_Stage_2nd];
GO
CREATE FUNCTION [dbo].[pkey_ST_Stage_2nd] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [ST].Positor,
    [ST].ST_ID,
    [ST].ST_NAM_Stage_Name AS ST_NAM_Stage_Name
FROM
    [dbo].[pST_Stage](@changingTimepoint) [ST]
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_ST_Stage_2nd', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_ST_Stage_2nd];
GO
CREATE VIEW [dbo].[ic_key_ST_Stage_2nd] AS
SELECT
    'key_ST_Stage_2nd' AS Construct,
    'duplicate natural key' AS Violation,
    CONCAT(
        'Positor=', d.Positor, ', ',
        'ST_NAM_Stage_Name=', d.ST_NAM_Stage_Name
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Positor,
        ST_NAM_Stage_Name,
        COUNT(DISTINCT ST_ID) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_2nd]
    WHERE
        ST_NAM_Stage_Name is not null
    GROUP BY
        Positor,
        ST_NAM_Stage_Name
    HAVING
        COUNT(DISTINCT ST_ID) > 1
) d
UNION ALL
SELECT
    'key_ST_Stage_2nd',
    'more than one natural key',
    CONCAT(
        'Positor=', d.Positor, ', ',
        'ST_ID=', d.ST_ID
    ),
    d.Occurrences
FROM (
    SELECT
        Positor,
        ST_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_2nd]
    GROUP BY
        Positor,
        ST_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage, filled by refresh_ST_Stage_2nd
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_Stage_2nd', 'U') IS NOT NULL
DROP TABLE [dbo].[ST_Stage_2nd];
GO
CREATE TABLE [dbo].[ST_Stage_2nd] (
    Positor tinyint not null,
    ST_ID int not null,
    ST_NAM_Stage_Name nvarchar(42) not null,
    constraint pkST_Stage_2nd primary key (
        Positor,
        ST_ID
    ),
    constraint uqST_Stage_2nd unique (
        Positor,
        ST_NAM_Stage_Name
    )
);
GO
IF Object_ID('dbo.refresh_ST_Stage_2nd', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_ST_Stage_2nd];
GO
CREATE PROCEDURE [dbo].[refresh_ST_Stage_2nd] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[ST_Stage_2nd];
    INSERT INTO [dbo].[ST_Stage_2nd] (
        Positor,
        ST_ID,
        ST_NAM_Stage_Name
    )
    SELECT
        Positor,
        ST_ID,
        ST_NAM_Stage_Name
    FROM
        [dbo].[key_ST_Stage_2nd]
    WHERE
        ST_NAM_Stage_Name is not null
    ;
    COMMIT;
END
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_AC_Actor_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_AC_Actor_1st];
GO
CREATE VIEW [dbo].[key_AC_Actor_1st] AS
SELECT
    [AC].Positor,
    [AC].AC_ID,
    [AC].AC_NAM_Actor_Name AS AC_NAM_Actor_Name
FROM
    [dbo].[lAC_Actor] [AC]
;
GO
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor at a changing time
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.pkey_AC_Actor_1st', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pkey_AC_Actor_1st];
GO
CREATE FUNCTION [dbo].[pkey_AC_Actor_1st] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [AC].Positor,
    [AC].AC_ID,
    [AC].AC_NAM_Actor_Name AS AC_NAM_Actor_Name
FROM
    [dbo].[pAC_Actor](@changingTimepoint) [AC]
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_AC_Actor_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_AC_Actor_1st];
GO
CREATE VIEW [dbo].[ic_key_AC_Actor_1st] AS
SELECT
    'key_AC_Actor_1st' AS Construct,
    'duplicate natural key' AS Violation,
    CONCAT(
        'Positor=', d.Positor, ', ',
        'AC_NAM_Actor_Name=', d.AC_NAM_Actor_Name
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Positor,
        AC_NAM_Actor_Name,
        COUNT(DISTINCT AC_ID) AS Occurrences
    FROM
        [dbo].[key_AC_Actor_1st]
    WHERE
        AC_NAM_Actor_Name is not null
    GROUP BY
        Positor,
        AC_NAM_Actor_Name
    HAVING
        COUNT(DISTINCT AC_ID) > 1
) d
UNION ALL
SELECT
    'key_AC_Actor_1st',
    'more than one natural key',
    CONCAT(
        'Positor=', d.Positor, ', ',
        'AC_ID=', d.AC_ID
    ),
    d.Occurrences
FROM (
    SELECT
        Positor,
        AC_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_AC_Actor_1st]
    GROUP BY
        Positor,
        AC_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor, filled by refresh_AC_Actor_1st
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_Actor_1st', 'U') IS NOT NULL
DROP TABLE [dbo].[AC_Actor_1st];
GO
CREATE TABLE [dbo].[AC_Actor_1st] (
    Positor tinyint not null,
    AC_ID int not null,
    AC_NAM_Actor_Name nvarchar(42) not null,
    constraint pkAC_Actor_1st primary key (
        Positor,
        AC_ID
    ),
    constraint uqAC_Actor_1st unique (
        Positor,
        AC_NAM_Actor_Name
    )
);
GO
IF Object_ID('dbo.refresh_AC_Actor_1st', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_AC_Actor_1st];
GO
CREATE PROCEDURE [dbo].[refresh_AC_Actor_1st] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[AC_Actor_1st];
    INSERT INTO [dbo].[AC_Actor_1st] (
        Positor,
        AC_ID,
        AC_NAM_Actor_Name
    )
    SELECT
        Positor,
        AC_ID,
        AC_NAM_Actor_Name
    FROM
        [dbo].[key_AC_Actor_1st]
    WHERE
        AC_NAM_Actor_Name is not null
    ;
    COMMIT;
END
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_PR_Program_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_PR_Program_1st];
GO
CREATE VIEW [dbo].[key_PR_Program_1st] AS
SELECT
    [PR].Positor,
    [PR].PR_ID,
    [PR].PR_NAM_Program_Name AS PR_NAM_Program_Name
FROM
    [dbo].[lPR_Program] [PR]
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_PR_Program_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_PR_Program_1st];
GO
CREATE VIEW [dbo].[ic_key_PR_Program_1st] AS
SELECT
    'key_PR_Program_1st' AS Construct,
    'duplicate natural key' AS Violation,
    CONCAT(
        'Positor=', d.Positor, ', ',
        'PR_NAM_Program_Name=', d.PR_NAM_Program_Name
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Positor,
        PR_NAM_Program_Name,
        COUNT(DISTINCT PR_ID) AS Occurrences
    FROM
        [dbo].[key_PR_Program_1st]
    WHERE
        PR_NAM_Program_Name is not null
    GROUP BY
        Positor,
        PR_NAM_Program_Name
    HAVING
        COUNT(DISTINCT PR_ID) > 1
) d
UNION ALL
SELECT
    'key_PR_Program_1st',
    'more than one natural key',
    CONCAT(
        'Positor=', d.Positor, ', ',
        'PR_ID=', d.PR_ID
    ),
    d.Occurrences
FROM (
    SELECT
        Positor,
        PR_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_PR_Program_1st]
    GROUP BY
        Positor,
        PR_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program, filled by refresh_PR_Program_1st
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_Program_1st', 'U') IS NOT NULL
DROP TABLE [dbo].[PR_Program_1st];
GO
CREATE TABLE [dbo].[PR_Program_1st] (
    Positor tinyint not null,
    PR_ID int not null,
    PR_NAM_Program_Name nvarchar(42) not null,
    constraint pkPR_Program_1st primary key (
        Positor,
        PR_ID
    ),
    constraint uqPR_Program_1st unique (
        Positor,
        PR_NAM_Program_Name
    )
);
GO
IF Object_ID('dbo.refresh_PR_Program_1st', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_PR_Program_1st];
GO
CREATE PROCEDURE [dbo].[refresh_PR_Program_1st] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[PR_Program_1st];
    INSERT INTO [dbo].[PR_Program_1st] (
        Positor,
        PR_ID,
        PR_NAM_Program_Name
    )
    SELECT
        Positor,
        PR_ID,
        PR_NAM_Program_Name
    FROM
        [dbo].[key_PR_Program_1st]
    WHERE
        PR_NAM_Program_Name is not null
    ;
    COMMIT;
END
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_EV_Event_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_EV_Event_1st];
GO
CREATE VIEW [dbo].[key_EV_Event_1st] AS
SELECT
    [EV].Positor,
    [EV].EV_ID,
    [EV].EV_DAT_Event_Date AS EV_DAT_Event_Date,
    [s2].ST_LOC_Stage_Location AS wasHeldAt_ST_LOC_Stage_Location,
    [s2].ST_LOC_Checksum AS wasHeldAt_ST_LOC_Checksum,
    [s4].PR_NAM_Program_Name AS wasPlayed_PR_NAM_Program_Name
FROM
    [dbo].[lEV_Event] [EV]
LEFT JOIN
    [dbo].[lST_Stage] [s2]
ON
    [s2].ST_ID = [EV].ST_ID_wasHeldAt
AND
    [s2].Positor = [EV].Positor
LEFT JOIN
    [dbo].[lPR_Program] [s4]
ON
    [s4].PR_ID = [EV].PR_ID_wasPlayed
AND
    [s4].Positor = [EV].Positor
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_EV_Event_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_EV_Event_1st];
GO
CREATE VIEW [dbo].[ic_key_EV_Event_1st] AS
SELECT
    'key_EV_Event_1st' AS Construct,
    'duplicate natural key' AS Violation,
    CONCAT(
        'Positor=', d.Positor, ', ',
        'EV_DAT_Event_Date=', d.EV_DAT_Event_Date, ', ',
        'wasHeldAt_ST_LOC_Checksum=', CONVERT(varchar(max), d.wasHeldAt_ST_LOC_Checksum, 1), ', ',
        'wasPlayed_PR_NAM_Program_Name=', d.wasPlayed_PR_NAM_Program_Name
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Positor,
        EV_DAT_Event_Date,
        wasHeldAt_ST_LOC_Checksum,
        wasPlayed_PR_NAM_Program_Name,
        COUNT(DISTINCT EV_ID) AS Occurrences
    FROM
        [dbo].[key_EV_Event_1st]
    WHERE
        EV_DAT_Event_Date is not null
    AND
        wasHeldAt_ST_LOC_Checksum is not null
    AND
        wasPlayed_PR_NAM_Program_Name is not null
    GROUP BY
        Positor,
        EV_DAT_Event_Date,
        wasHeldAt_ST_LOC_Checksum,
        wasPlayed_PR_NAM_Program_Name
    HAVING
        COUNT(DISTINCT EV_ID) > 1
) d
UNION ALL
SELECT
    'key_EV_Event_1st',
    'more than one natural key',
    CONCAT(
        'Positor=', d.Positor, ', ',
        'EV_ID=', d.EV_ID
    ),
    d.Occurrences
FROM (
    SELECT
        Positor,
        EV_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_EV_Event_1st]
    GROUP BY
        Positor,
        EV_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event, filled by refresh_EV_Event_1st
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_Event_1st', 'U') IS NOT NULL
DROP TABLE [dbo].[EV_Event_1st];
GO
CREATE TABLE [dbo].[EV_Event_1st] (
    Positor tinyint not null,
    EV_ID int not null,
    EV_DAT_Event_Date datetime2 not null,
    wasHeldAt_ST_LOC_Stage_Location geography not null,
    wasHeldAt_ST_LOC_Checksum varbinary(16) not null,
    wasPlayed_PR_NAM_Program_Name nvarchar(42) not null,
    constraint pkEV_Event_1st primary key (
        Positor,
        EV_ID
    ),
    constraint uqEV_Event_1st unique (
        Positor,
        EV_DAT_Event_Date,
        wasHeldAt_ST_LOC_Checksum,
        wasPlayed_PR_NAM_Program_Name
    )
);
GO
IF Object_ID('dbo.refresh_EV_Event_1st', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_EV_Event_1st];
GO
CREATE PROCEDURE [dbo].[refresh_EV_Event_1st] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[EV_Event_1st];
    INSERT INTO [dbo].[EV_Event_1st] (
        Positor,
        EV_ID,
        EV_DAT_Event_Date,
        wasHeldAt_ST_LOC_Stage_Location,
        wasHeldAt_ST_LOC_Checksum,
        wasPlayed_PR_NAM_Program_Name
    )
    SELECT
        Positor,
        EV_ID,
        EV_DAT_Event_Date,
        wasHeldAt_ST_LOC_Stage_Location,
        wasHeldAt_ST_LOC_Checksum,
        wasPlayed_PR_NAM_Program_Name
    FROM
        [dbo].[key_EV_Event_1st]
    WHERE
        EV_DAT_Event_Date is not null
    AND
        wasHeldAt_ST_LOC_Checksum is not null
    AND
        wasPlayed_PR_NAM_Program_Name is not null
    ;
    COMMIT;
END
GO
