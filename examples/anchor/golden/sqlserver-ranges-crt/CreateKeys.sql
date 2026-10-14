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
IF Object_ID('anchors.key_ST_Stage_1st', 'V') IS NOT NULL
DROP VIEW [anchors].[key_ST_Stage_1st];
GO
CREATE VIEW [anchors].[key_ST_Stage_1st] AS
SELECT
    [ST].Who,
    [ST].ST_ID,
    [ST].ST_LOC_Stage_Location AS ST_LOC_Stage_Location,
    [ST].ST_LOC_Checksum AS ST_LOC_Checksum
FROM
    [anchors].[lST_Stage] [ST]
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.ic_key_ST_Stage_1st', 'V') IS NOT NULL
DROP VIEW [anchors].[ic_key_ST_Stage_1st];
GO
CREATE VIEW [anchors].[ic_key_ST_Stage_1st] AS
SELECT
    'key_ST_Stage_1st' AS Construct,
    'duplicate natural key' AS Violation,
    (
        SELECT
            d.Who,
            d.ST_LOC_Checksum
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Who,
        ST_LOC_Checksum,
        COUNT(DISTINCT ST_ID) AS Occurrences
    FROM
        [anchors].[key_ST_Stage_1st]
    WHERE
        ST_LOC_Checksum is not null
    GROUP BY
        Who,
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
            d.Who,
            d.ST_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        Who,
        ST_ID,
        COUNT(*) AS Occurrences
    FROM
        [anchors].[key_ST_Stage_1st]
    GROUP BY
        Who,
        ST_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage, filled by refresh_ST_Stage_1st
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.ST_Stage_1st', 'U') IS NOT NULL
DROP TABLE [anchors].[ST_Stage_1st];
GO
CREATE TABLE [anchors].[ST_Stage_1st] (
    Who smallint not null,
    ST_ID int not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum varbinary(16) not null,
    constraint pkST_Stage_1st primary key (
        Who,
        ST_ID
    ),
    constraint uqST_Stage_1st unique (
        Who,
        ST_LOC_Checksum
    )
);
GO
IF Object_ID('anchors.refresh_ST_Stage_1st', 'P') IS NOT NULL
DROP PROCEDURE [anchors].[refresh_ST_Stage_1st];
GO
CREATE PROCEDURE [anchors].[refresh_ST_Stage_1st] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [anchors].[ST_Stage_1st];
    INSERT INTO [anchors].[ST_Stage_1st] (
        Who,
        ST_ID,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum
    )
    SELECT
        Who,
        ST_ID,
        ST_LOC_Stage_Location,
        ST_LOC_Checksum
    FROM
        [anchors].[key_ST_Stage_1st]
    WHERE
        ST_LOC_Checksum is not null
    ;
    COMMIT;
END
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.key_ST_Stage_2nd', 'V') IS NOT NULL
DROP VIEW [anchors].[key_ST_Stage_2nd];
GO
CREATE VIEW [anchors].[key_ST_Stage_2nd] AS
SELECT
    [ST].Who,
    [ST].ST_ID,
    [ST].ST_NAM_Stage_Name AS ST_NAM_Stage_Name
FROM
    [anchors].[lST_Stage] [ST]
;
GO
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage at a changing time
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.pkey_ST_Stage_2nd', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[pkey_ST_Stage_2nd];
GO
CREATE FUNCTION [anchors].[pkey_ST_Stage_2nd] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [ST].Who,
    [ST].ST_ID,
    [ST].ST_NAM_Stage_Name AS ST_NAM_Stage_Name
FROM
    [anchors].[pST_Stage](@changingTimepoint) [ST]
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.ic_key_ST_Stage_2nd', 'V') IS NOT NULL
DROP VIEW [anchors].[ic_key_ST_Stage_2nd];
GO
CREATE VIEW [anchors].[ic_key_ST_Stage_2nd] AS
SELECT
    'key_ST_Stage_2nd' AS Construct,
    'duplicate natural key' AS Violation,
    (
        SELECT
            d.Who,
            d.ST_NAM_Stage_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Who,
        ST_NAM_Stage_Name,
        COUNT(DISTINCT ST_ID) AS Occurrences
    FROM
        [anchors].[key_ST_Stage_2nd]
    WHERE
        ST_NAM_Stage_Name is not null
    GROUP BY
        Who,
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
            d.Who,
            d.ST_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        Who,
        ST_ID,
        COUNT(*) AS Occurrences
    FROM
        [anchors].[key_ST_Stage_2nd]
    GROUP BY
        Who,
        ST_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage, filled by refresh_ST_Stage_2nd
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.ST_Stage_2nd', 'U') IS NOT NULL
DROP TABLE [anchors].[ST_Stage_2nd];
GO
CREATE TABLE [anchors].[ST_Stage_2nd] (
    Who smallint not null,
    ST_ID int not null,
    ST_NAM_Stage_Name nvarchar(42) not null,
    constraint pkST_Stage_2nd primary key (
        Who,
        ST_ID
    ),
    constraint uqST_Stage_2nd unique (
        Who,
        ST_NAM_Stage_Name
    )
);
GO
IF Object_ID('anchors.refresh_ST_Stage_2nd', 'P') IS NOT NULL
DROP PROCEDURE [anchors].[refresh_ST_Stage_2nd];
GO
CREATE PROCEDURE [anchors].[refresh_ST_Stage_2nd] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [anchors].[ST_Stage_2nd];
    INSERT INTO [anchors].[ST_Stage_2nd] (
        Who,
        ST_ID,
        ST_NAM_Stage_Name
    )
    SELECT
        Who,
        ST_ID,
        ST_NAM_Stage_Name
    FROM
        [anchors].[key_ST_Stage_2nd]
    WHERE
        ST_NAM_Stage_Name is not null
    ;
    COMMIT;
END
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.key_AC_Actor_1st', 'V') IS NOT NULL
DROP VIEW [anchors].[key_AC_Actor_1st];
GO
CREATE VIEW [anchors].[key_AC_Actor_1st] AS
SELECT
    [AC].Who,
    [AC].AC_ID,
    [AC].AC_NAM_Actor_Name AS AC_NAM_Actor_Name
FROM
    [anchors].[lAC_Actor] [AC]
;
GO
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor at a changing time
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.pkey_AC_Actor_1st', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[pkey_AC_Actor_1st];
GO
CREATE FUNCTION [anchors].[pkey_AC_Actor_1st] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [AC].Who,
    [AC].AC_ID,
    [AC].AC_NAM_Actor_Name AS AC_NAM_Actor_Name
FROM
    [anchors].[pAC_Actor](@changingTimepoint) [AC]
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.ic_key_AC_Actor_1st', 'V') IS NOT NULL
DROP VIEW [anchors].[ic_key_AC_Actor_1st];
GO
CREATE VIEW [anchors].[ic_key_AC_Actor_1st] AS
SELECT
    'key_AC_Actor_1st' AS Construct,
    'duplicate natural key' AS Violation,
    (
        SELECT
            d.Who,
            d.AC_NAM_Actor_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Who,
        AC_NAM_Actor_Name,
        COUNT(DISTINCT AC_ID) AS Occurrences
    FROM
        [anchors].[key_AC_Actor_1st]
    WHERE
        AC_NAM_Actor_Name is not null
    GROUP BY
        Who,
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
            d.Who,
            d.AC_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        Who,
        AC_ID,
        COUNT(*) AS Occurrences
    FROM
        [anchors].[key_AC_Actor_1st]
    GROUP BY
        Who,
        AC_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- The 1st key of AC_Actor has no key table: AC_NAM_Actor_Name is a (max) type, which a unique index cannot
-- hold; give its attribute a checksum.
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.key_PR_Program_1st', 'V') IS NOT NULL
DROP VIEW [anchors].[key_PR_Program_1st];
GO
CREATE VIEW [anchors].[key_PR_Program_1st] AS
SELECT
    [PR].Who,
    [PR].PR_ID,
    [PR].PR_NAM_Program_Name AS PR_NAM_Program_Name
FROM
    [anchors].[lPR_Program] [PR]
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.ic_key_PR_Program_1st', 'V') IS NOT NULL
DROP VIEW [anchors].[ic_key_PR_Program_1st];
GO
CREATE VIEW [anchors].[ic_key_PR_Program_1st] AS
SELECT
    'key_PR_Program_1st' AS Construct,
    'duplicate natural key' AS Violation,
    (
        SELECT
            d.Who,
            d.PR_NAM_Program_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Who,
        PR_NAM_Program_Name,
        COUNT(DISTINCT PR_ID) AS Occurrences
    FROM
        [anchors].[key_PR_Program_1st]
    WHERE
        PR_NAM_Program_Name is not null
    GROUP BY
        Who,
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
            d.Who,
            d.PR_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        Who,
        PR_ID,
        COUNT(*) AS Occurrences
    FROM
        [anchors].[key_PR_Program_1st]
    GROUP BY
        Who,
        PR_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program, filled by refresh_PR_Program_1st
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.PR_Program_1st', 'U') IS NOT NULL
DROP TABLE [anchors].[PR_Program_1st];
GO
CREATE TABLE [anchors].[PR_Program_1st] (
    Who smallint not null,
    PR_ID bigint not null,
    PR_NAM_Program_Name nvarchar(42) not null,
    constraint pkPR_Program_1st primary key (
        Who,
        PR_ID
    ),
    constraint uqPR_Program_1st unique (
        Who,
        PR_NAM_Program_Name
    )
);
GO
IF Object_ID('anchors.refresh_PR_Program_1st', 'P') IS NOT NULL
DROP PROCEDURE [anchors].[refresh_PR_Program_1st];
GO
CREATE PROCEDURE [anchors].[refresh_PR_Program_1st] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [anchors].[PR_Program_1st];
    INSERT INTO [anchors].[PR_Program_1st] (
        Who,
        PR_ID,
        PR_NAM_Program_Name
    )
    SELECT
        Who,
        PR_ID,
        PR_NAM_Program_Name
    FROM
        [anchors].[key_PR_Program_1st]
    WHERE
        PR_NAM_Program_Name is not null
    ;
    COMMIT;
END
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('nexuses.key_EV_Event_1st', 'V') IS NOT NULL
DROP VIEW [nexuses].[key_EV_Event_1st];
GO
CREATE VIEW [nexuses].[key_EV_Event_1st] AS
SELECT
    [EV].Who,
    [EV].EV_ID,
    [EV].EV_DAT_Event_Date AS EV_DAT_Event_Date,
    [s2].ST_LOC_Stage_Location AS wasHeldAt_ST_LOC_Stage_Location,
    [s2].ST_LOC_Checksum AS wasHeldAt_ST_LOC_Checksum,
    [s4].PR_NAM_Program_Name AS wasPlayed_PR_NAM_Program_Name
FROM
    [nexuses].[lEV_Event] [EV]
LEFT JOIN
    [anchors].[lST_Stage] [s2]
ON
    [s2].ST_ID = [EV].ST_ID_wasHeldAt
AND
    [s2].Who = [EV].Who
LEFT JOIN
    [anchors].[lPR_Program] [s4]
ON
    [s4].PR_ID = [EV].PR_ID_wasPlayed
AND
    [s4].Who = [EV].Who
;
GO
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('nexuses.ic_key_EV_Event_1st', 'V') IS NOT NULL
DROP VIEW [nexuses].[ic_key_EV_Event_1st];
GO
CREATE VIEW [nexuses].[ic_key_EV_Event_1st] AS
SELECT
    'key_EV_Event_1st' AS Construct,
    'duplicate natural key' AS Violation,
    (
        SELECT
            d.Who,
            d.EV_DAT_Event_Date,
            d.wasHeldAt_ST_LOC_Checksum,
            d.wasPlayed_PR_NAM_Program_Name
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS ViolationKey,
    d.Occurrences
FROM (
    SELECT
        Who,
        EV_DAT_Event_Date,
        wasHeldAt_ST_LOC_Checksum,
        wasPlayed_PR_NAM_Program_Name,
        COUNT(DISTINCT EV_ID) AS Occurrences
    FROM
        [nexuses].[key_EV_Event_1st]
    WHERE
        EV_DAT_Event_Date is not null
    AND
        wasHeldAt_ST_LOC_Checksum is not null
    AND
        wasPlayed_PR_NAM_Program_Name is not null
    GROUP BY
        Who,
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
            d.Who,
            d.EV_ID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),
    d.Occurrences
FROM (
    SELECT
        Who,
        EV_ID,
        COUNT(*) AS Occurrences
    FROM
        [nexuses].[key_EV_Event_1st]
    GROUP BY
        Who,
        EV_ID
    HAVING
        COUNT(*) > 1
) d;
GO
-- Key table ----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event, filled by refresh_EV_Event_1st
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('nexuses.EV_Event_1st', 'U') IS NOT NULL
DROP TABLE [nexuses].[EV_Event_1st];
GO
CREATE TABLE [nexuses].[EV_Event_1st] (
    Who smallint not null,
    EV_ID numeric(12,0) not null,
    EV_DAT_Event_Date datetime2 not null,
    wasHeldAt_ST_LOC_Stage_Location geography not null,
    wasHeldAt_ST_LOC_Checksum varbinary(16) not null,
    wasPlayed_PR_NAM_Program_Name nvarchar(42) not null,
    constraint pkEV_Event_1st primary key (
        Who,
        EV_ID
    ),
    constraint uqEV_Event_1st unique (
        Who,
        EV_DAT_Event_Date,
        wasHeldAt_ST_LOC_Checksum,
        wasPlayed_PR_NAM_Program_Name
    )
);
GO
IF Object_ID('nexuses.refresh_EV_Event_1st', 'P') IS NOT NULL
DROP PROCEDURE [nexuses].[refresh_EV_Event_1st];
GO
CREATE PROCEDURE [nexuses].[refresh_EV_Event_1st] AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DELETE FROM [nexuses].[EV_Event_1st];
    INSERT INTO [nexuses].[EV_Event_1st] (
        Who,
        EV_ID,
        EV_DAT_Event_Date,
        wasHeldAt_ST_LOC_Stage_Location,
        wasHeldAt_ST_LOC_Checksum,
        wasPlayed_PR_NAM_Program_Name
    )
    SELECT
        Who,
        EV_ID,
        EV_DAT_Event_Date,
        wasHeldAt_ST_LOC_Stage_Location,
        wasHeldAt_ST_LOC_Checksum,
        wasPlayed_PR_NAM_Program_Name
    FROM
        [nexuses].[key_EV_Event_1st]
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
