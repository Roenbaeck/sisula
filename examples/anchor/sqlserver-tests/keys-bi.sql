-- Natural key tests, bitemporal: what the key views, point-in-time keys, integrity checks and key tables give.
--
-- Runs against the output for models/sqlserver-keys-bi.xml (golden/sqlserver-keys-bi/_full.sql) in an empty database;
-- tools/sqlserver-tests.ps1 does both. The data is loaded through the latest views, and each check adds a row to
-- #result, as in the trigger tests: the list is shown at the end, the script ends with an error if a check failed, and
-- a group that stops early counts as a failure. The routes are listed in tools/make-keys-models.ps1; the rules they
-- follow are in Anchor's docs/ANCHOR.md, "Keys and identifiers".
SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result;
IF OBJECT_ID('tempdb..#group') IS NOT NULL DROP TABLE #group;
IF OBJECT_ID('tempdb..#id') IS NOT NULL DROP TABLE #id;
CREATE TABLE #result (id int IDENTITY(1,1) PRIMARY KEY, test nvarchar(400) NOT NULL, passed bit NOT NULL, detail nvarchar(2048) NULL);
CREATE TABLE #group (name char(3) PRIMARY KEY, finished bit NOT NULL DEFAULT 0);
-- the identities that the groups make, by name, so that a later group can use them
CREATE TABLE #id (name varchar(20) PRIMARY KEY, id int NOT NULL);
INSERT INTO #group (name) VALUES ('k01'), ('k02'), ('k03'), ('k04'), ('k05'), ('k06'), ('k07'), ('k08'), ('k09'), ('k10');
INSERT INTO dbo.UTL_Utilization (UTL_ID, UTL_Utilization, Metadata_UTL) VALUES (1, 50, 0), (2, 80, 0);
INSERT INTO dbo.ETY_EventType (ETY_ID, ETY_EventType, Metadata_ETY) VALUES (1, N'premiere', 0), (2, N'regular', 0);
INSERT INTO dbo.RAT_Rating (RAT_ID, RAT_Rating, Metadata_RAT) VALUES (1, N'good', 0), (2, N'bad', 0);
GO

-- k01 the key of an anchor's own attribute: the value and its checksum, which a lookup matches on
DECLARE @st int, @n int, @checksum varbinary(16);
INSERT INTO dbo.lST_Stage (Metadata_ST, ST_NAM_Stage_Name, ST_NAM_ChangedAt, ST_LOC_Stage_Location, ST_MIN_UTL_ID)
VALUES (0, N'Globen', '2020-01-01', geography::Point(59.2936, 18.0831, 4326), 1);
SET @st = (SELECT MAX(ST_ID) FROM dbo.ST_Stage);
INSERT INTO #id VALUES ('stage', @st);
SET @checksum = (SELECT ST_LOC_Checksum FROM dbo.ST_LOC_Stage_Location WHERE ST_LOC_ST_ID = @st);
SET @n = (SELECT COUNT(*) FROM dbo.key_ST_Stage_1st WHERE ST_ID = @st AND ST_LOC_Checksum = @checksum
    AND ST_LOC_Stage_Location.STEquals(geography::Point(59.2936, 18.0831, 4326)) = 1);
INSERT INTO #result SELECT N'k01 the key view has the value and its checksum', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' rows, expected 1');
SET @n = (SELECT COUNT(*) FROM dbo.key_ST_Stage_1st WHERE ST_LOC_Checksum = @checksum);
INSERT INTO #result SELECT N'k01 a lookup by the checksum finds the one stage', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' rows, expected 1');
UPDATE #group SET finished = 1 WHERE name = 'k01';
GO

-- k02 a key through the roles of a nexus (the event by its date, the location of its stage and the name of its
--     program), and one with the knot of a nexus role (its type)
DECLARE @st int = (SELECT id FROM #id WHERE name = 'stage'), @pr int, @ev int, @found int, @n int, @type nvarchar(42);
INSERT INTO dbo.lPR_Program (Metadata_PR, PR_NAM_Program_Name) VALUES (0, N'Hamlet');
SET @pr = (SELECT MAX(PR_ID) FROM dbo.PR_Program);
INSERT INTO #id VALUES ('program', @pr);
INSERT INTO dbo.lEV_Event (Metadata_EV, ST_ID_wasHeldAt, PR_ID_wasPlayed, ETY_ID_of, EV_DAT_Event_Date) VALUES (0, @st, @pr, 1, '2024-05-01 19:00');
SET @ev = (SELECT MAX(EV_ID) FROM dbo.EV_Event);
INSERT INTO #id VALUES ('event', @ev);
SELECT @found = MAX(EV_ID), @n = COUNT(*) FROM dbo.key_EV_Event_1st
WHERE EV_DAT_Event_Date = '2024-05-01 19:00' AND wasPlayed_PR_NAM_Program_Name = N'Hamlet'
  AND wasHeldAt_ST_LOC_Checksum = (SELECT ST_LOC_Checksum FROM dbo.ST_LOC_Stage_Location WHERE ST_LOC_ST_ID = @st);
INSERT INTO #result SELECT N'k02 a lookup by a key through nexus roles finds the event', CASE WHEN @n = 1 AND @found = @ev THEN 1 ELSE 0 END, CONCAT(@n, ' rows, event ', @found, ', expected ', @ev);
SET @type = (SELECT of_ETY_EventType FROM dbo.key_EV_Event_2nd WHERE EV_ID = @ev);
INSERT INTO #result SELECT N'k02 a key with the knot of a nexus role has its value', CASE WHEN @type = N'premiere' THEN 1 ELSE 0 END, CONCAT('type ', ISNULL(@type, 'nothing'), ', expected premiere');
UPDATE #group SET finished = 1 WHERE name = 'k02';
GO

-- k03 a key that changes: the key view has the latest value, the point-in-time key the value at a time
DECLARE @st int = (SELECT id FROM #id WHERE name = 'stage'), @now nvarchar(42), @then nvarchar(42);
UPDATE dbo.lST_Stage SET ST_NAM_Stage_Name = N'Avicii Arena', ST_NAM_ChangedAt = '2021-05-19' WHERE ST_ID = @st;
SET @now = (SELECT ST_NAM_Stage_Name FROM dbo.key_ST_Stage_2nd WHERE ST_ID = @st);
SET @then = (SELECT ST_NAM_Stage_Name FROM dbo.pkey_ST_Stage_2nd('2020-06-01') WHERE ST_ID = @st);
INSERT INTO #result SELECT N'k03 the key view has the latest value', CASE WHEN @now = N'Avicii Arena' THEN 1 ELSE 0 END, CONCAT('name ', ISNULL(@now, 'nothing'), ', expected Avicii Arena');
INSERT INTO #result SELECT N'k03 the point-in-time key has the value at the time', CASE WHEN @then = N'Globen' THEN 1 ELSE 0 END, CONCAT('name ', ISNULL(@then, 'nothing'), ', expected Globen');
UPDATE #group SET finished = 1 WHERE name = 'k03';
GO

-- k04 a key through a tie (the event, by the name of the program its content is), and a knotted attribute with a
--     historized one (the stage by its minimum utilization and name)
DECLARE @st int = (SELECT id FROM #id WHERE name = 'stage'), @pr int = (SELECT id FROM #id WHERE name = 'program'),
    @ev int = (SELECT id FROM #id WHERE name = 'event'), @name nvarchar(42), @minimum tinyint, @stage nvarchar(42);
INSERT INTO dbo.lPR_content_ST_location_EV_of (Metadata_PR_content_ST_location_EV_of, PR_ID_content, ST_ID_location, EV_ID_of) VALUES (0, @pr, @st, @ev);
SET @name = (SELECT content_PR_NAM_Program_Name FROM dbo.key_EV_Event_3rd WHERE EV_ID = @ev);
INSERT INTO #result SELECT N'k04 a key through a tie has the value at its end', CASE WHEN @name = N'Hamlet' THEN 1 ELSE 0 END, CONCAT('name ', ISNULL(@name, 'nothing'), ', expected Hamlet');
SELECT @minimum = ST_MIN_UTL_Utilization, @stage = ST_NAM_Stage_Name FROM dbo.key_ST_Stage_3rd WHERE ST_ID = @st;
INSERT INTO #result SELECT N'k04 a knotted attribute gives the value of its knot', CASE WHEN @minimum = 50 AND @stage = N'Avicii Arena' THEN 1 ELSE 0 END, CONCAT(@minimum, ' and ', ISNULL(@stage, 'nothing'), ', expected 50 and Avicii Arena');
UPDATE #group SET finished = 1 WHERE name = 'k04';
GO

-- k05 the key of an anchor without attributes, which has no perspectives (a person, by the name of the actor it is a
--     subset of)
DECLARE @pn int, @ac int, @name nvarchar(42);
INSERT INTO dbo.PN_Person (Metadata_PN) VALUES (0);
SET @pn = (SELECT MAX(PN_ID) FROM dbo.PN_Person);
INSERT INTO dbo.lAC_Actor (Metadata_AC, AC_NAM_Actor_Name, AC_NAM_ChangedAt) VALUES (0, N'Stellan', '2020-01-01');
SET @ac = (SELECT MAX(AC_ID) FROM dbo.AC_Actor);
INSERT INTO #id VALUES ('actor', @ac);
INSERT INTO dbo.lAC_subset_PN_of (Metadata_AC_subset_PN_of, AC_ID_subset, PN_ID_of) VALUES (0, @ac, @pn);
SET @name = (SELECT subset_AC_NAM_Actor_Name FROM dbo.key_PN_Person_1st WHERE PN_ID = @pn);
INSERT INTO #result SELECT N'k05 an anchor without attributes has its key', CASE WHEN @name = N'Stellan' THEN 1 ELSE 0 END, CONCAT('name ', ISNULL(@name, 'nothing'), ', expected Stellan');
UPDATE #group SET finished = 1 WHERE name = 'k05';
GO

-- k06 nothing is wrong with keys that only one identity has
DECLARE @n int = (SELECT COUNT(*) FROM dbo.ic_key_ST_Stage_1st) + (SELECT COUNT(*) FROM dbo.ic_key_EV_Event_1st) + (SELECT COUNT(*) FROM dbo.ic_key_PR_Program_1st);
INSERT INTO #result SELECT N'k06 the checks of unique keys are empty', CASE WHEN @n = 0 THEN 1 ELSE 0 END, CONCAT(@n, ' violations, expected none');
UPDATE #group SET finished = 1 WHERE name = 'k06';
GO

-- k07 the refresh procedure fills the key table
DECLARE @pr int = (SELECT id FROM #id WHERE name = 'program'), @n int, @error nvarchar(2048);
BEGIN TRY
    EXEC dbo.refresh_PR_Program_1st;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.PR_Program_1st WHERE PR_ID = @pr AND PR_NAM_Program_Name = N'Hamlet');
INSERT INTO #result SELECT N'k07 the refresh procedure fills the key table', CASE WHEN @error IS NULL AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' rows', ' ' + @error);
UPDATE #group SET finished = 1 WHERE name = 'k07';
GO

-- k08 a key that two identities have: the check reports it, and the refresh procedure fails and keeps what it had
DECLARE @n int, @occurrences int, @error nvarchar(2048);
INSERT INTO dbo.lPR_Program (Metadata_PR, PR_NAM_Program_Name) VALUES (0, N'Hamlet');
SELECT @n = COUNT(*), @occurrences = MAX(Occurrences) FROM dbo.ic_key_PR_Program_1st WHERE Violation = 'duplicate natural key';
INSERT INTO #result SELECT N'k08 the check reports a key of two identities', CASE WHEN @n = 1 AND @occurrences = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' violations of ', @occurrences, ', expected one of 2');
BEGIN TRY
    EXEC dbo.refresh_PR_Program_1st;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.PR_Program_1st);
INSERT INTO #result SELECT N'k08 the refresh procedure fails on it and keeps the table as it was', CASE WHEN @error IS NOT NULL AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' rows, ', ISNULL(@error, 'no error'));
UPDATE #group SET finished = 1 WHERE name = 'k08';
GO

-- k09 a route that is not functional (a program by the rating got for a part in it): two parts give the program two
--     keys, which the check reports
DECLARE @pr int = (SELECT id FROM #id WHERE name = 'program'), @ac int = (SELECT id FROM #id WHERE name = 'actor'), @other int,
    @keys int, @n int, @occurrences int;
INSERT INTO dbo.lAC_Actor (Metadata_AC, AC_NAM_Actor_Name, AC_NAM_ChangedAt) VALUES (0, N'Alicia', '2020-01-01');
SET @other = (SELECT MAX(AC_ID) FROM dbo.AC_Actor);
INSERT INTO dbo.lAC_part_PR_in_RAT_got (Metadata_AC_part_PR_in_RAT_got, AC_part_PR_in_RAT_got_ChangedAt, AC_ID_part, PR_ID_in, RAT_ID_got)
VALUES (0, '2024-01-01', @ac, @pr, 1), (0, '2024-01-01', @other, @pr, 2);
SET @keys = (SELECT COUNT(*) FROM dbo.key_PR_Program_2nd WHERE PR_ID = @pr);
SELECT @n = COUNT(*), @occurrences = MAX(Occurrences) FROM dbo.ic_key_PR_Program_2nd WHERE Violation = 'more than one natural key';
INSERT INTO #result SELECT N'k09 a route that is not functional can give an identity more than one key', CASE WHEN @keys = 2 THEN 1 ELSE 0 END, CONCAT(@keys, ' keys, expected 2');
INSERT INTO #result SELECT N'k09 the check reports it', CASE WHEN @n = 1 AND @occurrences = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' violations of ', @occurrences, ', expected one of 2');
UPDATE #group SET finished = 1 WHERE name = 'k09';
GO

-- k10 the routes that break a rule are not generated, and those that do not are
DECLARE @missing int, @made int;
SET @missing = CASE WHEN OBJECT_ID('dbo.key_EV_Event_4th') IS NULL THEN 1 ELSE 0 END + CASE WHEN OBJECT_ID('dbo.key_EV_Event_5th') IS NULL THEN 1 ELSE 0 END
    + CASE WHEN OBJECT_ID('dbo.key_ST_Stage_5th') IS NULL THEN 1 ELSE 0 END + CASE WHEN OBJECT_ID('dbo.key_AC_Actor_4th') IS NULL THEN 1 ELSE 0 END
    + CASE WHEN OBJECT_ID('dbo.key_PR_Program_3rd') IS NULL THEN 1 ELSE 0 END;
SET @made = CASE WHEN OBJECT_ID('dbo.key_AC_Actor_2nd') IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN OBJECT_ID('dbo.pkey_AC_Actor_2nd') IS NOT NULL THEN 1 ELSE 0 END
    + CASE WHEN OBJECT_ID('dbo.key_AC_Actor_3rd') IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN OBJECT_ID('dbo.key_ST_Stage_4th') IS NOT NULL THEN 1 ELSE 0 END
    + CASE WHEN OBJECT_ID('dbo.ic_key_EV_Event_3rd') IS NOT NULL THEN 1 ELSE 0 END;
INSERT INTO #result SELECT N'k10 the routes that break a rule are not generated', CASE WHEN @missing = 5 THEN 1 ELSE 0 END, CONCAT(@missing, ' of 5 missing');
INSERT INTO #result SELECT N'k10 and the others are', CASE WHEN @made = 5 THEN 1 ELSE 0 END, CONCAT(@made, ' of 5 there');
UPDATE #group SET finished = 1 WHERE name = 'k10';
GO

-- the result
INSERT INTO #result SELECT name + N' did not run to the end (its error is in the output above)', 0, NULL FROM #group WHERE finished = 0;
SELECT CASE WHEN passed = 1 THEN 'PASS' ELSE 'FAIL' END + ' ' + test + ISNULL(' (' + detail + ')', '') AS result FROM #result ORDER BY id;
DECLARE @failed int = (SELECT COUNT(*) FROM #result WHERE passed = 0), @total int = (SELECT COUNT(*) FROM #result);
PRINT CONCAT(@total - @failed, ' of ', @total, ' checks passed');
IF @failed > 0 THROW 50000, 'Some key checks failed', 1;
GO
