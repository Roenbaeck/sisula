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
-- 1st key of PN_Person
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_PN_Person_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_PN_Person_1st];
GO
CREATE VIEW [dbo].[key_PN_Person_1st] AS
SELECT
    p.Positor,
    [PN].PN_ID,
    [s2].AC_NAM_Actor_Name AS subset_AC_NAM_Actor_Name
FROM
    [dbo].[_Positor] p
CROSS JOIN
    [dbo].[PN_Person] [PN]
LEFT JOIN
    [dbo].[lAC_subset_PN_of] [s1]
ON
    [s1].PN_ID_of = [PN].PN_ID
AND
    [s1].Positor = p.Positor
LEFT JOIN
    [dbo].[lAC_Actor] [s2]
ON
    [s2].AC_ID = [s1].AC_ID_subset
AND
    [s2].Positor = p.Positor
;
GO
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of PN_Person at a changing time
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.pkey_PN_Person_1st', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pkey_PN_Person_1st];
GO
CREATE FUNCTION [dbo].[pkey_PN_Person_1st] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    p.Positor,
    [PN].PN_ID,
    [s2].AC_NAM_Actor_Name AS subset_AC_NAM_Actor_Name
FROM
    [dbo].[_Positor] p
CROSS JOIN
    [dbo].[PN_Person] [PN]
LEFT JOIN
    [dbo].[pAC_subset_PN_of](@changingTimepoint) [s1]
ON
    [s1].PN_ID_of = [PN].PN_ID
AND
    [s1].Positor = p.Positor
LEFT JOIN
    [dbo].[pAC_Actor](@changingTimepoint) [s2]
ON
    [s2].AC_ID = [s1].AC_ID_subset
AND
    [s2].Positor = p.Positor
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PN_Person
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_PN_Person_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_PN_Person_1st];
GO
CREATE VIEW [dbo].[ic_key_PN_Person_1st] AS
SELECT
    'key_PN_Person_1st' AS Construct,
    'duplicate natural key' AS Violation,
    (
        SELECT
            d.Positor,
            d.subset_AC_NAM_Actor_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Positor,
        subset_AC_NAM_Actor_Name,
        COUNT(DISTINCT PN_ID) AS Occurrences
    FROM
        [dbo].[key_PN_Person_1st]
    WHERE
        subset_AC_NAM_Actor_Name is not null
    GROUP BY
        Positor,
        subset_AC_NAM_Actor_Name
    HAVING
        COUNT(DISTINCT PN_ID) > 1
) d
UNION ALL
SELECT
    'key_PN_Person_1st',
    'more than one natural key',
    (
        SELECT
            d.Positor,
            d.PN_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        Positor,
        PN_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_PN_Person_1st]
    GROUP BY
        Positor,
        PN_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 1st key of PN_Person, filled by refresh_PN_Person_1st
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PN_Person_1st', 'U') IS NOT NULL
DROP TABLE [dbo].[PN_Person_1st];
GO
CREATE TABLE [dbo].[PN_Person_1st] (
    Positor tinyint not null,
    PN_ID int not null,
    subset_AC_NAM_Actor_Name nvarchar(42) not null,
    constraint pkPN_Person_1st primary key (
        Positor,
        PN_ID
    ),
    constraint uqPN_Person_1st unique (
        Positor,
        subset_AC_NAM_Actor_Name
    )
);
GO
IF Object_ID('dbo.refresh_PN_Person_1st', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_PN_Person_1st];
GO
CREATE PROCEDURE [dbo].[refresh_PN_Person_1st] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[PN_Person_1st];
    INSERT INTO [dbo].[PN_Person_1st] (
        Positor,
        PN_ID,
        subset_AC_NAM_Actor_Name
    )
    SELECT
        Positor,
        PN_ID,
        subset_AC_NAM_Actor_Name
    FROM
        [dbo].[key_PN_Person_1st]
    WHERE
        subset_AC_NAM_Actor_Name is not null
    ;
    COMMIT;
END
GO
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
    (
        SELECT
            d.Positor,
            d.ST_LOC_Checksum
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
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
    (
        SELECT
            d.Positor,
            d.ST_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
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
    (
        SELECT
            d.Positor,
            d.ST_NAM_Stage_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
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
    (
        SELECT
            d.Positor,
            d.ST_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
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
-- 3rd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_ST_Stage_3rd', 'V') IS NOT NULL
DROP VIEW [dbo].[key_ST_Stage_3rd];
GO
CREATE VIEW [dbo].[key_ST_Stage_3rd] AS
SELECT
    [ST].Positor,
    [ST].ST_ID,
    [ST].ST_MIN_UTL_Utilization AS ST_MIN_UTL_Utilization,
    [ST].ST_NAM_Stage_Name AS ST_NAM_Stage_Name
FROM
    [dbo].[lST_Stage] [ST]
;
GO
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 3rd key of ST_Stage at a changing time
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.pkey_ST_Stage_3rd', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pkey_ST_Stage_3rd];
GO
CREATE FUNCTION [dbo].[pkey_ST_Stage_3rd] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [ST].Positor,
    [ST].ST_ID,
    [ST].ST_MIN_UTL_Utilization AS ST_MIN_UTL_Utilization,
    [ST].ST_NAM_Stage_Name AS ST_NAM_Stage_Name
FROM
    [dbo].[pST_Stage](@changingTimepoint) [ST]
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 3rd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_ST_Stage_3rd', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_ST_Stage_3rd];
GO
CREATE VIEW [dbo].[ic_key_ST_Stage_3rd] AS
SELECT
    'key_ST_Stage_3rd' AS Construct,
    'duplicate natural key' AS Violation,
    (
        SELECT
            d.Positor,
            d.ST_MIN_UTL_Utilization,
            d.ST_NAM_Stage_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Positor,
        ST_MIN_UTL_Utilization,
        ST_NAM_Stage_Name,
        COUNT(DISTINCT ST_ID) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_3rd]
    WHERE
        ST_MIN_UTL_Utilization is not null
    AND
        ST_NAM_Stage_Name is not null
    GROUP BY
        Positor,
        ST_MIN_UTL_Utilization,
        ST_NAM_Stage_Name
    HAVING
        COUNT(DISTINCT ST_ID) > 1
) d
UNION ALL
SELECT
    'key_ST_Stage_3rd',
    'more than one natural key',
    (
        SELECT
            d.Positor,
            d.ST_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        Positor,
        ST_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_3rd]
    GROUP BY
        Positor,
        ST_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 3rd key of ST_Stage, filled by refresh_ST_Stage_3rd
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_Stage_3rd', 'U') IS NOT NULL
DROP TABLE [dbo].[ST_Stage_3rd];
GO
CREATE TABLE [dbo].[ST_Stage_3rd] (
    Positor tinyint not null,
    ST_ID int not null,
    ST_MIN_UTL_Utilization tinyint not null,
    ST_NAM_Stage_Name nvarchar(42) not null,
    constraint pkST_Stage_3rd primary key (
        Positor,
        ST_ID
    ),
    constraint uqST_Stage_3rd unique (
        Positor,
        ST_MIN_UTL_Utilization,
        ST_NAM_Stage_Name
    )
);
GO
IF Object_ID('dbo.refresh_ST_Stage_3rd', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_ST_Stage_3rd];
GO
CREATE PROCEDURE [dbo].[refresh_ST_Stage_3rd] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[ST_Stage_3rd];
    INSERT INTO [dbo].[ST_Stage_3rd] (
        Positor,
        ST_ID,
        ST_MIN_UTL_Utilization,
        ST_NAM_Stage_Name
    )
    SELECT
        Positor,
        ST_ID,
        ST_MIN_UTL_Utilization,
        ST_NAM_Stage_Name
    FROM
        [dbo].[key_ST_Stage_3rd]
    WHERE
        ST_MIN_UTL_Utilization is not null
    AND
        ST_NAM_Stage_Name is not null
    ;
    COMMIT;
END
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 4th key of ST_Stage
-- Note: ST_Stage can be wasHeldAt in more than one EV_Event, so an identity can have more than one key
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_ST_Stage_4th', 'V') IS NOT NULL
DROP VIEW [dbo].[key_ST_Stage_4th];
GO
CREATE VIEW [dbo].[key_ST_Stage_4th] AS
SELECT
    [ST].Positor,
    [ST].ST_ID,
    [s1].EV_DAT_Event_Date AS wasHeldAt_EV_DAT_Event_Date
FROM
    [dbo].[lST_Stage] [ST]
LEFT JOIN
    [dbo].[lEV_Event] [s1]
ON
    [s1].ST_ID_wasHeldAt = [ST].ST_ID
AND
    [s1].Positor = [ST].Positor
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 4th key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_ST_Stage_4th', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_ST_Stage_4th];
GO
CREATE VIEW [dbo].[ic_key_ST_Stage_4th] AS
SELECT
    'key_ST_Stage_4th' AS Construct,
    'duplicate natural key' AS Violation,
    (
        SELECT
            d.Positor,
            d.wasHeldAt_EV_DAT_Event_Date
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Positor,
        wasHeldAt_EV_DAT_Event_Date,
        COUNT(DISTINCT ST_ID) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_4th]
    WHERE
        wasHeldAt_EV_DAT_Event_Date is not null
    GROUP BY
        Positor,
        wasHeldAt_EV_DAT_Event_Date
    HAVING
        COUNT(DISTINCT ST_ID) > 1
) d
UNION ALL
SELECT
    'key_ST_Stage_4th',
    'more than one natural key',
    (
        SELECT
            d.Positor,
            d.ST_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        Positor,
        ST_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_4th]
    GROUP BY
        Positor,
        ST_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 4th key of ST_Stage, filled by refresh_ST_Stage_4th
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_Stage_4th', 'U') IS NOT NULL
DROP TABLE [dbo].[ST_Stage_4th];
GO
CREATE TABLE [dbo].[ST_Stage_4th] (
    Positor tinyint not null,
    ST_ID int not null,
    wasHeldAt_EV_DAT_Event_Date datetime2 not null,
    constraint pkST_Stage_4th primary key (
        Positor,
        ST_ID
    ),
    constraint uqST_Stage_4th unique (
        Positor,
        wasHeldAt_EV_DAT_Event_Date
    )
);
GO
IF Object_ID('dbo.refresh_ST_Stage_4th', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_ST_Stage_4th];
GO
CREATE PROCEDURE [dbo].[refresh_ST_Stage_4th] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[ST_Stage_4th];
    INSERT INTO [dbo].[ST_Stage_4th] (
        Positor,
        ST_ID,
        wasHeldAt_EV_DAT_Event_Date
    )
    SELECT
        Positor,
        ST_ID,
        wasHeldAt_EV_DAT_Event_Date
    FROM
        [dbo].[key_ST_Stage_4th]
    WHERE
        wasHeldAt_EV_DAT_Event_Date is not null
    ;
    COMMIT;
END
GO
-- The 5th key of ST_Stage is not generated: more than one element is stop 1
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
    (
        SELECT
            d.Positor,
            d.AC_NAM_Actor_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
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
    (
        SELECT
            d.Positor,
            d.AC_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
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
-- 2nd key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_AC_Actor_2nd', 'V') IS NOT NULL
DROP VIEW [dbo].[key_AC_Actor_2nd];
GO
CREATE VIEW [dbo].[key_AC_Actor_2nd] AS
SELECT
    [AC].Positor,
    [AC].AC_ID,
    [s2].AC_NAM_Actor_Name AS with_AC_NAM_Actor_Name
FROM
    [dbo].[lAC_Actor] [AC]
LEFT JOIN
    [dbo].[lAC_partner_AC_with_ONG_currently] [s1]
ON
    [s1].AC_ID_partner = [AC].AC_ID
AND
    [s1].Positor = [AC].Positor
LEFT JOIN
    [dbo].[lAC_Actor] [s2]
ON
    [s2].AC_ID = [s1].AC_ID_with
AND
    [s2].Positor = [AC].Positor
;
GO
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of AC_Actor at a changing time
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.pkey_AC_Actor_2nd', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pkey_AC_Actor_2nd];
GO
CREATE FUNCTION [dbo].[pkey_AC_Actor_2nd] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [AC].Positor,
    [AC].AC_ID,
    [s2].AC_NAM_Actor_Name AS with_AC_NAM_Actor_Name
FROM
    [dbo].[pAC_Actor](@changingTimepoint) [AC]
LEFT JOIN
    [dbo].[pAC_partner_AC_with_ONG_currently](@changingTimepoint) [s1]
ON
    [s1].AC_ID_partner = [AC].AC_ID
AND
    [s1].Positor = [AC].Positor
LEFT JOIN
    [dbo].[pAC_Actor](@changingTimepoint) [s2]
ON
    [s2].AC_ID = [s1].AC_ID_with
AND
    [s2].Positor = [AC].Positor
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_AC_Actor_2nd', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_AC_Actor_2nd];
GO
CREATE VIEW [dbo].[ic_key_AC_Actor_2nd] AS
SELECT
    'key_AC_Actor_2nd' AS Construct,
    'duplicate natural key' AS Violation,
    (
        SELECT
            d.Positor,
            d.with_AC_NAM_Actor_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Positor,
        with_AC_NAM_Actor_Name,
        COUNT(DISTINCT AC_ID) AS Occurrences
    FROM
        [dbo].[key_AC_Actor_2nd]
    WHERE
        with_AC_NAM_Actor_Name is not null
    GROUP BY
        Positor,
        with_AC_NAM_Actor_Name
    HAVING
        COUNT(DISTINCT AC_ID) > 1
) d
UNION ALL
SELECT
    'key_AC_Actor_2nd',
    'more than one natural key',
    (
        SELECT
            d.Positor,
            d.AC_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        Positor,
        AC_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_AC_Actor_2nd]
    GROUP BY
        Positor,
        AC_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 2nd key of AC_Actor, filled by refresh_AC_Actor_2nd
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_Actor_2nd', 'U') IS NOT NULL
DROP TABLE [dbo].[AC_Actor_2nd];
GO
CREATE TABLE [dbo].[AC_Actor_2nd] (
    Positor tinyint not null,
    AC_ID int not null,
    with_AC_NAM_Actor_Name nvarchar(42) not null,
    constraint pkAC_Actor_2nd primary key (
        Positor,
        AC_ID
    ),
    constraint uqAC_Actor_2nd unique (
        Positor,
        with_AC_NAM_Actor_Name
    )
);
GO
IF Object_ID('dbo.refresh_AC_Actor_2nd', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_AC_Actor_2nd];
GO
CREATE PROCEDURE [dbo].[refresh_AC_Actor_2nd] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[AC_Actor_2nd];
    INSERT INTO [dbo].[AC_Actor_2nd] (
        Positor,
        AC_ID,
        with_AC_NAM_Actor_Name
    )
    SELECT
        Positor,
        AC_ID,
        with_AC_NAM_Actor_Name
    FROM
        [dbo].[key_AC_Actor_2nd]
    WHERE
        with_AC_NAM_Actor_Name is not null
    ;
    COMMIT;
END
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor
-- Note: AC_parent_AC_child_PAT_having has identifiers other than parent, so it can lead to more than one child and an identity to more than one key
-- Note: AC_part_PR_in_RAT_got has identifiers other than part, so it can lead to more than one in and an identity to more than one key
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_AC_Actor_3rd', 'V') IS NOT NULL
DROP VIEW [dbo].[key_AC_Actor_3rd];
GO
CREATE VIEW [dbo].[key_AC_Actor_3rd] AS
SELECT
    [AC].Positor,
    [AC].AC_ID,
    [s4].PR_NAM_Program_Name AS child_in_PR_NAM_Program_Name
FROM
    [dbo].[lAC_Actor] [AC]
LEFT JOIN
    [dbo].[lAC_parent_AC_child_PAT_having] [s1]
ON
    [s1].AC_ID_parent = [AC].AC_ID
AND
    [s1].Positor = [AC].Positor
LEFT JOIN
    [dbo].[lAC_part_PR_in_RAT_got] [s3]
ON
    [s3].AC_ID_part = [s1].AC_ID_child
AND
    [s3].Positor = [AC].Positor
LEFT JOIN
    [dbo].[lPR_Program] [s4]
ON
    [s4].PR_ID = [s3].PR_ID_in
AND
    [s4].Positor = [AC].Positor
;
GO
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor at a changing time
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.pkey_AC_Actor_3rd', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pkey_AC_Actor_3rd];
GO
CREATE FUNCTION [dbo].[pkey_AC_Actor_3rd] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [AC].Positor,
    [AC].AC_ID,
    [s4].PR_NAM_Program_Name AS child_in_PR_NAM_Program_Name
FROM
    [dbo].[pAC_Actor](@changingTimepoint) [AC]
LEFT JOIN
    [dbo].[pAC_parent_AC_child_PAT_having](@changingTimepoint) [s1]
ON
    [s1].AC_ID_parent = [AC].AC_ID
AND
    [s1].Positor = [AC].Positor
LEFT JOIN
    [dbo].[pAC_part_PR_in_RAT_got](@changingTimepoint) [s3]
ON
    [s3].AC_ID_part = [s1].AC_ID_child
AND
    [s3].Positor = [AC].Positor
LEFT JOIN
    [dbo].[pPR_Program](@changingTimepoint) [s4]
ON
    [s4].PR_ID = [s3].PR_ID_in
AND
    [s4].Positor = [AC].Positor
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_AC_Actor_3rd', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_AC_Actor_3rd];
GO
CREATE VIEW [dbo].[ic_key_AC_Actor_3rd] AS
SELECT
    'key_AC_Actor_3rd' AS Construct,
    'duplicate natural key' AS Violation,
    (
        SELECT
            d.Positor,
            d.child_in_PR_NAM_Program_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Positor,
        child_in_PR_NAM_Program_Name,
        COUNT(DISTINCT AC_ID) AS Occurrences
    FROM
        [dbo].[key_AC_Actor_3rd]
    WHERE
        child_in_PR_NAM_Program_Name is not null
    GROUP BY
        Positor,
        child_in_PR_NAM_Program_Name
    HAVING
        COUNT(DISTINCT AC_ID) > 1
) d
UNION ALL
SELECT
    'key_AC_Actor_3rd',
    'more than one natural key',
    (
        SELECT
            d.Positor,
            d.AC_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        Positor,
        AC_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_AC_Actor_3rd]
    GROUP BY
        Positor,
        AC_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor, filled by refresh_AC_Actor_3rd
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_Actor_3rd', 'U') IS NOT NULL
DROP TABLE [dbo].[AC_Actor_3rd];
GO
CREATE TABLE [dbo].[AC_Actor_3rd] (
    Positor tinyint not null,
    AC_ID int not null,
    child_in_PR_NAM_Program_Name nvarchar(42) not null,
    constraint pkAC_Actor_3rd primary key (
        Positor,
        AC_ID
    ),
    constraint uqAC_Actor_3rd unique (
        Positor,
        child_in_PR_NAM_Program_Name
    )
);
GO
IF Object_ID('dbo.refresh_AC_Actor_3rd', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_AC_Actor_3rd];
GO
CREATE PROCEDURE [dbo].[refresh_AC_Actor_3rd] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[AC_Actor_3rd];
    INSERT INTO [dbo].[AC_Actor_3rd] (
        Positor,
        AC_ID,
        child_in_PR_NAM_Program_Name
    )
    SELECT
        Positor,
        AC_ID,
        child_in_PR_NAM_Program_Name
    FROM
        [dbo].[key_AC_Actor_3rd]
    WHERE
        child_in_PR_NAM_Program_Name is not null
    ;
    COMMIT;
END
GO
-- The 4th key of AC_Actor is not generated: stop 1: ST_NAM_Stage_Name is not an attribute of AC_Actor
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
    (
        SELECT
            d.Positor,
            d.PR_NAM_Program_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
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
    (
        SELECT
            d.Positor,
            d.PR_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
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
-- 2nd key of PR_Program
-- Note: AC_part_PR_in_RAT_got has identifiers other than in, so it can lead to more than one got and an identity to more than one key
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_PR_Program_2nd', 'V') IS NOT NULL
DROP VIEW [dbo].[key_PR_Program_2nd];
GO
CREATE VIEW [dbo].[key_PR_Program_2nd] AS
SELECT
    [PR].Positor,
    [PR].PR_ID,
    [s1].got_RAT_Rating AS got_RAT_Rating
FROM
    [dbo].[lPR_Program] [PR]
LEFT JOIN
    [dbo].[lAC_part_PR_in_RAT_got] [s1]
ON
    [s1].PR_ID_in = [PR].PR_ID
AND
    [s1].Positor = [PR].Positor
;
GO
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of PR_Program at a changing time
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.pkey_PR_Program_2nd', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pkey_PR_Program_2nd];
GO
CREATE FUNCTION [dbo].[pkey_PR_Program_2nd] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [PR].Positor,
    [PR].PR_ID,
    [s1].got_RAT_Rating AS got_RAT_Rating
FROM
    [dbo].[pPR_Program](@changingTimepoint) [PR]
LEFT JOIN
    [dbo].[pAC_part_PR_in_RAT_got](@changingTimepoint) [s1]
ON
    [s1].PR_ID_in = [PR].PR_ID
AND
    [s1].Positor = [PR].Positor
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_PR_Program_2nd', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_PR_Program_2nd];
GO
CREATE VIEW [dbo].[ic_key_PR_Program_2nd] AS
SELECT
    'key_PR_Program_2nd' AS Construct,
    'duplicate natural key' AS Violation,
    (
        SELECT
            d.Positor,
            d.got_RAT_Rating
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Positor,
        got_RAT_Rating,
        COUNT(DISTINCT PR_ID) AS Occurrences
    FROM
        [dbo].[key_PR_Program_2nd]
    WHERE
        got_RAT_Rating is not null
    GROUP BY
        Positor,
        got_RAT_Rating
    HAVING
        COUNT(DISTINCT PR_ID) > 1
) d
UNION ALL
SELECT
    'key_PR_Program_2nd',
    'more than one natural key',
    (
        SELECT
            d.Positor,
            d.PR_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        Positor,
        PR_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_PR_Program_2nd]
    GROUP BY
        Positor,
        PR_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 2nd key of PR_Program, filled by refresh_PR_Program_2nd
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_Program_2nd', 'U') IS NOT NULL
DROP TABLE [dbo].[PR_Program_2nd];
GO
CREATE TABLE [dbo].[PR_Program_2nd] (
    Positor tinyint not null,
    PR_ID int not null,
    got_RAT_Rating nvarchar(42) not null,
    constraint pkPR_Program_2nd primary key (
        Positor,
        PR_ID
    ),
    constraint uqPR_Program_2nd unique (
        Positor,
        got_RAT_Rating
    )
);
GO
IF Object_ID('dbo.refresh_PR_Program_2nd', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_PR_Program_2nd];
GO
CREATE PROCEDURE [dbo].[refresh_PR_Program_2nd] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[PR_Program_2nd];
    INSERT INTO [dbo].[PR_Program_2nd] (
        Positor,
        PR_ID,
        got_RAT_Rating
    )
    SELECT
        Positor,
        PR_ID,
        got_RAT_Rating
    FROM
        [dbo].[key_PR_Program_2nd]
    WHERE
        got_RAT_Rating is not null
    ;
    COMMIT;
END
GO
-- The 3rd key of PR_Program is not generated: branch 1 does not end in a value, an attribute or a knot
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
    (
        SELECT
            d.Positor,
            d.EV_DAT_Event_Date,
            d.wasHeldAt_ST_LOC_Checksum,
            d.wasPlayed_PR_NAM_Program_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
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
    (
        SELECT
            d.Positor,
            d.EV_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
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
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_EV_Event_2nd', 'V') IS NOT NULL
DROP VIEW [dbo].[key_EV_Event_2nd];
GO
CREATE VIEW [dbo].[key_EV_Event_2nd] AS
SELECT
    [EV].Positor,
    [EV].EV_ID,
    [EV].of_ETY_EventType AS of_ETY_EventType,
    [EV].EV_DAT_Event_Date AS EV_DAT_Event_Date
FROM
    [dbo].[lEV_Event] [EV]
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_EV_Event_2nd', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_EV_Event_2nd];
GO
CREATE VIEW [dbo].[ic_key_EV_Event_2nd] AS
SELECT
    'key_EV_Event_2nd' AS Construct,
    'duplicate natural key' AS Violation,
    (
        SELECT
            d.Positor,
            d.of_ETY_EventType,
            d.EV_DAT_Event_Date
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Positor,
        of_ETY_EventType,
        EV_DAT_Event_Date,
        COUNT(DISTINCT EV_ID) AS Occurrences
    FROM
        [dbo].[key_EV_Event_2nd]
    WHERE
        of_ETY_EventType is not null
    AND
        EV_DAT_Event_Date is not null
    GROUP BY
        Positor,
        of_ETY_EventType,
        EV_DAT_Event_Date
    HAVING
        COUNT(DISTINCT EV_ID) > 1
) d
UNION ALL
SELECT
    'key_EV_Event_2nd',
    'more than one natural key',
    (
        SELECT
            d.Positor,
            d.EV_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        Positor,
        EV_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_EV_Event_2nd]
    GROUP BY
        Positor,
        EV_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 2nd key of EV_Event, filled by refresh_EV_Event_2nd
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_Event_2nd', 'U') IS NOT NULL
DROP TABLE [dbo].[EV_Event_2nd];
GO
CREATE TABLE [dbo].[EV_Event_2nd] (
    Positor tinyint not null,
    EV_ID int not null,
    of_ETY_EventType nvarchar(42) not null,
    EV_DAT_Event_Date datetime2 not null,
    constraint pkEV_Event_2nd primary key (
        Positor,
        EV_ID
    ),
    constraint uqEV_Event_2nd unique (
        Positor,
        of_ETY_EventType,
        EV_DAT_Event_Date
    )
);
GO
IF Object_ID('dbo.refresh_EV_Event_2nd', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_EV_Event_2nd];
GO
CREATE PROCEDURE [dbo].[refresh_EV_Event_2nd] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[EV_Event_2nd];
    INSERT INTO [dbo].[EV_Event_2nd] (
        Positor,
        EV_ID,
        of_ETY_EventType,
        EV_DAT_Event_Date
    )
    SELECT
        Positor,
        EV_ID,
        of_ETY_EventType,
        EV_DAT_Event_Date
    FROM
        [dbo].[key_EV_Event_2nd]
    WHERE
        of_ETY_EventType is not null
    AND
        EV_DAT_Event_Date is not null
    ;
    COMMIT;
END
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 3rd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_EV_Event_3rd', 'V') IS NOT NULL
DROP VIEW [dbo].[key_EV_Event_3rd];
GO
CREATE VIEW [dbo].[key_EV_Event_3rd] AS
SELECT
    [EV].Positor,
    [EV].EV_ID,
    [s2].PR_NAM_Program_Name AS content_PR_NAM_Program_Name
FROM
    [dbo].[lEV_Event] [EV]
LEFT JOIN
    [dbo].[lPR_content_ST_location_EV_of] [s1]
ON
    [s1].EV_ID_of = [EV].EV_ID
AND
    [s1].Positor = [EV].Positor
LEFT JOIN
    [dbo].[lPR_Program] [s2]
ON
    [s2].PR_ID = [s1].PR_ID_content
AND
    [s2].Positor = [EV].Positor
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 3rd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ic_key_EV_Event_3rd', 'V') IS NOT NULL
DROP VIEW [dbo].[ic_key_EV_Event_3rd];
GO
CREATE VIEW [dbo].[ic_key_EV_Event_3rd] AS
SELECT
    'key_EV_Event_3rd' AS Construct,
    'duplicate natural key' AS Violation,
    (
        SELECT
            d.Positor,
            d.content_PR_NAM_Program_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Positor,
        content_PR_NAM_Program_Name,
        COUNT(DISTINCT EV_ID) AS Occurrences
    FROM
        [dbo].[key_EV_Event_3rd]
    WHERE
        content_PR_NAM_Program_Name is not null
    GROUP BY
        Positor,
        content_PR_NAM_Program_Name
    HAVING
        COUNT(DISTINCT EV_ID) > 1
) d
UNION ALL
SELECT
    'key_EV_Event_3rd',
    'more than one natural key',
    (
        SELECT
            d.Positor,
            d.EV_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        Positor,
        EV_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_EV_Event_3rd]
    GROUP BY
        Positor,
        EV_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 3rd key of EV_Event, filled by refresh_EV_Event_3rd
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_Event_3rd', 'U') IS NOT NULL
DROP TABLE [dbo].[EV_Event_3rd];
GO
CREATE TABLE [dbo].[EV_Event_3rd] (
    Positor tinyint not null,
    EV_ID int not null,
    content_PR_NAM_Program_Name nvarchar(42) not null,
    constraint pkEV_Event_3rd primary key (
        Positor,
        EV_ID
    ),
    constraint uqEV_Event_3rd unique (
        Positor,
        content_PR_NAM_Program_Name
    )
);
GO
IF Object_ID('dbo.refresh_EV_Event_3rd', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[refresh_EV_Event_3rd];
GO
CREATE PROCEDURE [dbo].[refresh_EV_Event_3rd] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [dbo].[EV_Event_3rd];
    INSERT INTO [dbo].[EV_Event_3rd] (
        Positor,
        EV_ID,
        content_PR_NAM_Program_Name
    )
    SELECT
        Positor,
        EV_ID,
        content_PR_NAM_Program_Name
    FROM
        [dbo].[key_EV_Event_3rd]
    WHERE
        content_PR_NAM_Program_Name is not null
    ;
    COMMIT;
END
GO
-- The 4th key of EV_Event is not generated: stop 1: a tie takes two stops in a row in one branch, the role it is entered by and the role it is left by
-- The 5th key of EV_Event is not generated: stop 1 is on the knot ETY_EventType, which a route reaches through a knotted attribute or a knot role instead
