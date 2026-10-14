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
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PN_Person
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_PN_Person_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_PN_Person_1st];
GO
CREATE VIEW [dbo].[key_PN_Person_1st] AS
SELECT
    [PN].PN_ID,
    [s2].AC_NAM_Actor_Name AS subset_AC_NAM_Actor_Name
FROM
    [dbo].[PN_Person] [PN]
LEFT JOIN
    [dbo].[lAC_subset_PN_of] [s1]
ON
    [s1].PN_ID_of = [PN].PN_ID
LEFT JOIN
    [dbo].[lAC_Actor] [s2]
ON
    [s2].AC_ID = [s1].AC_ID_subset
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
    [PN].PN_ID,
    [s2].AC_NAM_Actor_Name AS subset_AC_NAM_Actor_Name
FROM
    [dbo].[PN_Person] [PN]
LEFT JOIN
    [dbo].[pAC_subset_PN_of](@changingTimepoint) [s1]
ON
    [s1].PN_ID_of = [PN].PN_ID
LEFT JOIN
    [dbo].[pAC_Actor](@changingTimepoint) [s2]
ON
    [s2].AC_ID = [s1].AC_ID_subset
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
            d.subset_AC_NAM_Actor_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        subset_AC_NAM_Actor_Name,
        COUNT(DISTINCT PN_ID) AS Occurrences
    FROM
        [dbo].[key_PN_Person_1st]
    WHERE
        subset_AC_NAM_Actor_Name is not null
    GROUP BY
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
            d.PN_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        PN_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_PN_Person_1st]
    GROUP BY
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
    PN_ID int not null,
    subset_AC_NAM_Actor_Name nvarchar(42) not null,
    constraint pkPN_Person_1st primary key (
        PN_ID
    ),
    constraint uqPN_Person_1st unique (
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
        PN_ID,
        subset_AC_NAM_Actor_Name
    )
    SELECT
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
            d.ST_LOC_Checksum
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        ST_LOC_Checksum,
        COUNT(DISTINCT ST_ID) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_1st]
    WHERE
        ST_LOC_Checksum is not null
    GROUP BY
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
            d.ST_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        ST_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_1st]
    GROUP BY
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
    ST_ID int not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum varbinary(16) not null,
    constraint pkST_Stage_1st primary key (
        ST_ID
    ),
    constraint uqST_Stage_1st unique (
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
        ST_ID,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum
    )
    SELECT
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
            d.ST_NAM_Stage_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        ST_NAM_Stage_Name,
        COUNT(DISTINCT ST_ID) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_2nd]
    WHERE
        ST_NAM_Stage_Name is not null
    GROUP BY
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
            d.ST_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        ST_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_2nd]
    GROUP BY
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
    ST_ID int not null,
    ST_NAM_Stage_Name nvarchar(42) not null,
    constraint pkST_Stage_2nd primary key (
        ST_ID
    ),
    constraint uqST_Stage_2nd unique (
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
        ST_ID,
        ST_NAM_Stage_Name
    )
    SELECT
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
            d.ST_MIN_UTL_Utilization,
            d.ST_NAM_Stage_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
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
            d.ST_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        ST_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_3rd]
    GROUP BY
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
    ST_ID int not null,
    ST_MIN_UTL_Utilization tinyint not null,
    ST_NAM_Stage_Name nvarchar(42) not null,
    constraint pkST_Stage_3rd primary key (
        ST_ID
    ),
    constraint uqST_Stage_3rd unique (
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
        ST_ID,
        ST_MIN_UTL_Utilization,
        ST_NAM_Stage_Name
    )
    SELECT
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
    [ST].ST_ID,
    [s1].EV_DAT_Event_Date AS wasHeldAt_EV_DAT_Event_Date
FROM
    [dbo].[lST_Stage] [ST]
LEFT JOIN
    [dbo].[lEV_Event] [s1]
ON
    [s1].ST_ID_wasHeldAt = [ST].ST_ID
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
            d.wasHeldAt_EV_DAT_Event_Date
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        wasHeldAt_EV_DAT_Event_Date,
        COUNT(DISTINCT ST_ID) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_4th]
    WHERE
        wasHeldAt_EV_DAT_Event_Date is not null
    GROUP BY
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
            d.ST_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        ST_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_ST_Stage_4th]
    GROUP BY
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
    ST_ID int not null,
    wasHeldAt_EV_DAT_Event_Date datetime2 not null,
    constraint pkST_Stage_4th primary key (
        ST_ID
    ),
    constraint uqST_Stage_4th unique (
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
        ST_ID,
        wasHeldAt_EV_DAT_Event_Date
    )
    SELECT
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
            d.AC_NAM_Actor_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        AC_NAM_Actor_Name,
        COUNT(DISTINCT AC_ID) AS Occurrences
    FROM
        [dbo].[key_AC_Actor_1st]
    WHERE
        AC_NAM_Actor_Name is not null
    GROUP BY
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
            d.AC_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        AC_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_AC_Actor_1st]
    GROUP BY
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
    AC_ID int not null,
    AC_NAM_Actor_Name nvarchar(42) not null,
    constraint pkAC_Actor_1st primary key (
        AC_ID
    ),
    constraint uqAC_Actor_1st unique (
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
        AC_ID,
        AC_NAM_Actor_Name
    )
    SELECT
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
    [AC].AC_ID,
    [s2].AC_NAM_Actor_Name AS with_AC_NAM_Actor_Name
FROM
    [dbo].[lAC_Actor] [AC]
LEFT JOIN
    [dbo].[lAC_partner_AC_with_ONG_currently] [s1]
ON
    [s1].AC_ID_partner = [AC].AC_ID
LEFT JOIN
    [dbo].[lAC_Actor] [s2]
ON
    [s2].AC_ID = [s1].AC_ID_with
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
    [AC].AC_ID,
    [s2].AC_NAM_Actor_Name AS with_AC_NAM_Actor_Name
FROM
    [dbo].[pAC_Actor](@changingTimepoint) [AC]
LEFT JOIN
    [dbo].[pAC_partner_AC_with_ONG_currently](@changingTimepoint) [s1]
ON
    [s1].AC_ID_partner = [AC].AC_ID
LEFT JOIN
    [dbo].[pAC_Actor](@changingTimepoint) [s2]
ON
    [s2].AC_ID = [s1].AC_ID_with
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
            d.with_AC_NAM_Actor_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        with_AC_NAM_Actor_Name,
        COUNT(DISTINCT AC_ID) AS Occurrences
    FROM
        [dbo].[key_AC_Actor_2nd]
    WHERE
        with_AC_NAM_Actor_Name is not null
    GROUP BY
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
            d.AC_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        AC_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_AC_Actor_2nd]
    GROUP BY
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
    AC_ID int not null,
    with_AC_NAM_Actor_Name nvarchar(42) not null,
    constraint pkAC_Actor_2nd primary key (
        AC_ID
    ),
    constraint uqAC_Actor_2nd unique (
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
        AC_ID,
        with_AC_NAM_Actor_Name
    )
    SELECT
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
    [AC].AC_ID,
    [s4].PR_NAM_Program_Name AS child_in_PR_NAM_Program_Name
FROM
    [dbo].[lAC_Actor] [AC]
LEFT JOIN
    [dbo].[lAC_parent_AC_child_PAT_having] [s1]
ON
    [s1].AC_ID_parent = [AC].AC_ID
LEFT JOIN
    [dbo].[lAC_part_PR_in_RAT_got] [s3]
ON
    [s3].AC_ID_part = [s1].AC_ID_child
LEFT JOIN
    [dbo].[lPR_Program] [s4]
ON
    [s4].PR_ID = [s3].PR_ID_in
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
    [AC].AC_ID,
    [s4].PR_NAM_Program_Name AS child_in_PR_NAM_Program_Name
FROM
    [dbo].[pAC_Actor](@changingTimepoint) [AC]
LEFT JOIN
    [dbo].[pAC_parent_AC_child_PAT_having](@changingTimepoint) [s1]
ON
    [s1].AC_ID_parent = [AC].AC_ID
LEFT JOIN
    [dbo].[pAC_part_PR_in_RAT_got](@changingTimepoint) [s3]
ON
    [s3].AC_ID_part = [s1].AC_ID_child
LEFT JOIN
    [dbo].[pPR_Program](@changingTimepoint) [s4]
ON
    [s4].PR_ID = [s3].PR_ID_in
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
            d.child_in_PR_NAM_Program_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        child_in_PR_NAM_Program_Name,
        COUNT(DISTINCT AC_ID) AS Occurrences
    FROM
        [dbo].[key_AC_Actor_3rd]
    WHERE
        child_in_PR_NAM_Program_Name is not null
    GROUP BY
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
            d.AC_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        AC_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_AC_Actor_3rd]
    GROUP BY
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
    AC_ID int not null,
    child_in_PR_NAM_Program_Name nvarchar(42) not null,
    constraint pkAC_Actor_3rd primary key (
        AC_ID
    ),
    constraint uqAC_Actor_3rd unique (
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
        AC_ID,
        child_in_PR_NAM_Program_Name
    )
    SELECT
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
            d.PR_NAM_Program_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        PR_NAM_Program_Name,
        COUNT(DISTINCT PR_ID) AS Occurrences
    FROM
        [dbo].[key_PR_Program_1st]
    WHERE
        PR_NAM_Program_Name is not null
    GROUP BY
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
            d.PR_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        PR_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_PR_Program_1st]
    GROUP BY
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
    PR_ID int not null,
    PR_NAM_Program_Name nvarchar(42) not null,
    constraint pkPR_Program_1st primary key (
        PR_ID
    ),
    constraint uqPR_Program_1st unique (
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
        PR_ID,
        PR_NAM_Program_Name
    )
    SELECT
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
    [PR].PR_ID,
    [s1].got_RAT_Rating AS got_RAT_Rating
FROM
    [dbo].[lPR_Program] [PR]
LEFT JOIN
    [dbo].[lAC_part_PR_in_RAT_got] [s1]
ON
    [s1].PR_ID_in = [PR].PR_ID
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
    [PR].PR_ID,
    [s1].got_RAT_Rating AS got_RAT_Rating
FROM
    [dbo].[pPR_Program](@changingTimepoint) [PR]
LEFT JOIN
    [dbo].[pAC_part_PR_in_RAT_got](@changingTimepoint) [s1]
ON
    [s1].PR_ID_in = [PR].PR_ID
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
            d.got_RAT_Rating
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        got_RAT_Rating,
        COUNT(DISTINCT PR_ID) AS Occurrences
    FROM
        [dbo].[key_PR_Program_2nd]
    WHERE
        got_RAT_Rating is not null
    GROUP BY
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
            d.PR_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        PR_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_PR_Program_2nd]
    GROUP BY
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
    PR_ID int not null,
    got_RAT_Rating nvarchar(42) not null,
    constraint pkPR_Program_2nd primary key (
        PR_ID
    ),
    constraint uqPR_Program_2nd unique (
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
        PR_ID,
        got_RAT_Rating
    )
    SELECT
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
LEFT JOIN
    [dbo].[lPR_Program] [s4]
ON
    [s4].PR_ID = [EV].PR_ID_wasPlayed
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
            d.EV_DAT_Event_Date,
            d.wasHeldAt_ST_LOC_Checksum,
            d.wasPlayed_PR_NAM_Program_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
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
            d.EV_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        EV_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_EV_Event_1st]
    GROUP BY
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
    EV_ID int not null,
    EV_DAT_Event_Date datetime2 not null,
    wasHeldAt_ST_LOC_Stage_Location geography not null,
    wasHeldAt_ST_LOC_Checksum varbinary(16) not null,
    wasPlayed_PR_NAM_Program_Name nvarchar(42) not null,
    constraint pkEV_Event_1st primary key (
        EV_ID
    ),
    constraint uqEV_Event_1st unique (
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
        EV_ID,
        EV_DAT_Event_Date,
        wasHeldAt_ST_LOC_Stage_Location,
        wasHeldAt_ST_LOC_Checksum,
        wasPlayed_PR_NAM_Program_Name
    )
    SELECT
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
            d.of_ETY_EventType,
            d.EV_DAT_Event_Date
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
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
            d.EV_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        EV_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_EV_Event_2nd]
    GROUP BY
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
    EV_ID int not null,
    of_ETY_EventType nvarchar(42) not null,
    EV_DAT_Event_Date datetime2 not null,
    constraint pkEV_Event_2nd primary key (
        EV_ID
    ),
    constraint uqEV_Event_2nd unique (
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
        EV_ID,
        of_ETY_EventType,
        EV_DAT_Event_Date
    )
    SELECT
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
    [EV].EV_ID,
    [s2].PR_NAM_Program_Name AS content_PR_NAM_Program_Name
FROM
    [dbo].[lEV_Event] [EV]
LEFT JOIN
    [dbo].[lPR_content_ST_location_EV_of] [s1]
ON
    [s1].EV_ID_of = [EV].EV_ID
LEFT JOIN
    [dbo].[lPR_Program] [s2]
ON
    [s2].PR_ID = [s1].PR_ID_content
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
            d.content_PR_NAM_Program_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        content_PR_NAM_Program_Name,
        COUNT(DISTINCT EV_ID) AS Occurrences
    FROM
        [dbo].[key_EV_Event_3rd]
    WHERE
        content_PR_NAM_Program_Name is not null
    GROUP BY
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
            d.EV_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        EV_ID,
        COUNT(*) AS Occurrences
    FROM
        [dbo].[key_EV_Event_3rd]
    GROUP BY
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
    EV_ID int not null,
    content_PR_NAM_Program_Name nvarchar(42) not null,
    constraint pkEV_Event_3rd primary key (
        EV_ID
    ),
    constraint uqEV_Event_3rd unique (
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
        EV_ID,
        content_PR_NAM_Program_Name
    )
    SELECT
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
