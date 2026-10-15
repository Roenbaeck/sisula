-- Trigger tests, concurrent-reliance-temporal without decisiveness: corrections and alternatives.
--
-- Runs against the output for models/sqlserver-indecisive-crt.xml (golden/sqlserver-indecisive-crt/_full.sql), which is
-- models/sqlserver-triggers-crt.xml with decisiveness off, in an empty database; tools/sqlserver-tests.ps1 does both.
-- Without decisiveness a positor may hold several values at once, so an insert of another value adds an alternative and
-- retracts nothing, while an update of the shown value at the same changing time is a correction, which also retracts
-- the shown posit. The checks are written as in triggers-crt.sql: each adds a row to #result, each group marks itself
-- finished as its last statement, and two statements about the same posit get positing times of their own.
-- Everything is stated by positor 0.
-- The rules are in Anchor's docs/ANCHOR.md, "Loading through the latest views".
SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result;
IF OBJECT_ID('tempdb..#group') IS NOT NULL DROP TABLE #group;
CREATE TABLE #result (id int IDENTITY(1,1) PRIMARY KEY, test nvarchar(400) NOT NULL, passed bit NOT NULL, detail nvarchar(2048) NULL);
CREATE TABLE #group (name char(3) PRIMARY KEY, finished bit NOT NULL DEFAULT 0);
INSERT INTO #group (name) VALUES ('i01'), ('i02'), ('i03'), ('i04'), ('i05'), ('i06');
INSERT INTO dbo.GRD_Grade (GRD_ID, GRD_Grade, Metadata_GRD) VALUES (1, N'A', 0), (2, N'B', 0), (3, N'C', 0);
GO

-- i01 an insert of another static value adds an alternative, which retracts nothing
DECLARE @s int, @n int, @held int, @shown nvarchar(42), @error nvarchar(2048);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
BEGIN TRY
    INSERT INTO dbo.SU_NAM_Subject_Name (Metadata_SU_NAM, SU_NAM_SU_ID, SU_NAM_Subject_Name, SU_NAM_PositedAt, SU_NAM_Positor, SU_NAM_Reliability)
    VALUES (0, @s, N'n1', '2024-01-01', 0, 0.6), (0, @s, N'n2', '2024-02-01', 0, 0.4);
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex a JOIN dbo.SU_NAM_Subject_Name_Posit p ON p.SU_NAM_ID = a.SU_NAM_ID
    WHERE p.SU_NAM_SU_ID = @s AND a.SU_NAM_Reliability = 0);
SET @held = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex a JOIN dbo.SU_NAM_Subject_Name_Posit p ON p.SU_NAM_ID = a.SU_NAM_ID
    WHERE p.SU_NAM_SU_ID = @s AND a.SU_NAM_Reliability > 0);
SET @shown = (SELECT SU_NAM_Subject_Name FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'i01 another value inserted is an alternative, and the latest one is shown', CASE WHEN @error IS NULL AND @n = 0 AND @held = 2 AND @shown = N'n2' THEN 1 ELSE 0 END,
    CONCAT(@n, ' retractions, ', @held, ' assertions; shown ', ISNULL(@shown, 'nothing'), ' ' + @error);
UPDATE #group SET finished = 1 WHERE name = 'i01';
GO

-- i02 an update of a static value is a correction, which retracts the shown posit and leaves the alternatives
DECLARE @s int, @n int, @shown nvarchar(42);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_NAM_PositedAt) VALUES (0, N'n1', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_NAM_Subject_Name = N'n2', SU_NAM_PositedAt = '2024-02-01' WHERE SU_ID = @s AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex a JOIN dbo.SU_NAM_Subject_Name_Posit p ON p.SU_NAM_ID = a.SU_NAM_ID
    WHERE p.SU_NAM_SU_ID = @s AND p.SU_NAM_Subject_Name = N'n1' AND a.SU_NAM_PositedAt = '2024-02-01' AND a.SU_NAM_Reliability = 0);
INSERT INTO #result SELECT N'i02 an update of a static value retracts the shown posit at its positing time', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' retractions of n1, expected 1');
UPDATE dbo.lSU_Subject SET SU_NAM_Reliability = 0, SU_NAM_PositedAt = '2024-03-01' WHERE SU_ID = @s AND Positor = 0;
SET @shown = (SELECT SU_NAM_Subject_Name FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'i02 retracting the correction leaves nothing in effect', CASE WHEN @shown IS NULL THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'));
-- with an alternative: the correction replaces the shown value only
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
INSERT INTO dbo.SU_NAM_Subject_Name (Metadata_SU_NAM, SU_NAM_SU_ID, SU_NAM_Subject_Name, SU_NAM_PositedAt, SU_NAM_Positor, SU_NAM_Reliability)
VALUES (0, @s, N'n1', '2024-01-01', 0, 0.6), (0, @s, N'n2', '2024-02-01', 0, 0.4);
UPDATE dbo.lSU_Subject SET SU_NAM_Subject_Name = N'n3', SU_NAM_PositedAt = '2024-03-01' WHERE SU_ID = @s AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex a JOIN dbo.SU_NAM_Subject_Name_Posit p ON p.SU_NAM_ID = a.SU_NAM_ID
    WHERE p.SU_NAM_SU_ID = @s AND a.SU_NAM_Reliability = 0);
SET @shown = (SELECT SU_NAM_Subject_Name FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'i02 a correction retracts the shown value and not the alternative', CASE WHEN @n = 1 AND @shown = N'n3' THEN 1 ELSE 0 END, CONCAT(@n, ' retractions; shown ', ISNULL(@shown, 'nothing'));
UPDATE dbo.lSU_Subject SET SU_NAM_Reliability = 0, SU_NAM_PositedAt = '2024-04-01' WHERE SU_ID = @s AND Positor = 0;
SET @shown = (SELECT SU_NAM_Subject_Name FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'i02 retracting the correction shows the alternative that is still held', CASE WHEN @shown = N'n1' THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'), ', expected n1');
UPDATE #group SET finished = 1 WHERE name = 'i02';
GO

-- i03 historized: an update at the changing time of the shown version is a correction of it; one from now is a new
--     version, which retracts nothing
DECLARE @s int, @n int, @shown nvarchar(42);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt) VALUES (0, N't1', '2020-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N't2', SU_TTL_ChangedAt = '2020-01-01', SU_TTL_PositedAt = '2024-02-01' WHERE SU_ID = @s AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex a JOIN dbo.SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID
    WHERE p.SU_TTL_SU_ID = @s AND p.SU_TTL_Subject_Title = N't1' AND a.SU_TTL_PositedAt = '2024-02-01' AND a.SU_TTL_Reliability = 0);
INSERT INTO #result SELECT N'i03 an update at the changing time of the shown version retracts it', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' retractions of t1, expected 1');
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N't3', SU_TTL_PositedAt = '2024-03-01' WHERE SU_ID = @s AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex a JOIN dbo.SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID
    WHERE p.SU_TTL_SU_ID = @s AND a.SU_TTL_Reliability = 0);
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'i03 a new version from now retracts nothing', CASE WHEN @n = 1 AND @shown = N't3' THEN 1 ELSE 0 END, CONCAT(@n, ' retractions; shown ', ISNULL(@shown, 'nothing'));
UPDATE #group SET finished = 1 WHERE name = 'i03';
GO

-- i04 a correction of a knotted attribute, by the value of its knot, and of one with a checksum
DECLARE @s int, @n int;
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_GRD_GRD_ID, SU_GRD_PositedAt, SU_NOT_Subject_Note, SU_NOT_PositedAt) VALUES (0, 1, '2024-01-01', N'note one', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_GRD_GRD_Grade = N'B', SU_GRD_PositedAt = '2024-02-01', SU_NOT_Subject_Note = N'note two', SU_NOT_PositedAt = '2024-02-01' WHERE SU_ID = @s AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_GRD_Subject_Grade_Annex a JOIN dbo.SU_GRD_Subject_Grade_Posit p ON p.SU_GRD_ID = a.SU_GRD_ID
        WHERE p.SU_GRD_SU_ID = @s AND p.SU_GRD_GRD_ID = 1 AND a.SU_GRD_PositedAt = '2024-02-01' AND a.SU_GRD_Reliability = 0)
    + (SELECT COUNT(*) FROM dbo.SU_NOT_Subject_Note_Annex a JOIN dbo.SU_NOT_Subject_Note_Posit p ON p.SU_NOT_ID = a.SU_NOT_ID
        WHERE p.SU_NOT_SU_ID = @s AND p.SU_NOT_Subject_Note = N'note one' AND a.SU_NOT_PositedAt = '2024-02-01' AND a.SU_NOT_Reliability = 0);
INSERT INTO #result SELECT N'i04 a correction of a knotted attribute and of one with a checksum retracts the shown posits', CASE WHEN @n = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' retractions, expected 2');
UPDATE #group SET finished = 1 WHERE name = 'i04';
GO

-- i05 a static tie: an update of its other values is a correction, which retracts the shown posit; an insert of other
--     values is an alternative
DECLARE @s1 int, @s2 int, @s3 int, @o int, @n int, @owner int;
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s1 = SCOPE_IDENTITY();
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s2 = SCOPE_IDENTITY();
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s3 = SCOPE_IDENTITY();
INSERT INTO dbo.OB_Object (Metadata_OB) VALUES (0); SET @o = SCOPE_IDENTITY();
INSERT INTO dbo.lOB_part_SU_owner (Metadata_OB_part_SU_owner, OB_part_SU_owner_PositedAt, OB_ID_part, SU_ID_owner) VALUES (0, '2024-01-01', @o, @s1);
UPDATE dbo.lOB_part_SU_owner SET SU_ID_owner = @s2, OB_part_SU_owner_PositedAt = '2024-02-01' WHERE OB_ID_part = @o AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.OB_part_SU_owner_Annex a JOIN dbo.OB_part_SU_owner_Posit p ON p.OB_part_SU_owner_ID = a.OB_part_SU_owner_ID
    WHERE p.OB_ID_part = @o AND p.SU_ID_owner = @s1 AND a.OB_part_SU_owner_PositedAt = '2024-02-01' AND a.OB_part_SU_owner_Reliability = 0);
INSERT INTO #result SELECT N'i05 an update of a static tie retracts the shown posit', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' retractions, expected 1');
INSERT INTO dbo.OB_part_SU_owner (Metadata_OB_part_SU_owner, OB_ID_part, SU_ID_owner, OB_part_SU_owner_PositedAt, OB_part_SU_owner_Positor, OB_part_SU_owner_Reliability)
VALUES (0, @o, @s3, '2024-03-01', 0, 1);
SET @n = (SELECT COUNT(*) FROM dbo.OB_part_SU_owner_Annex a JOIN dbo.OB_part_SU_owner_Posit p ON p.OB_part_SU_owner_ID = a.OB_part_SU_owner_ID
    WHERE p.OB_ID_part = @o AND a.OB_part_SU_owner_Reliability = 0);
SET @owner = (SELECT SU_ID_owner FROM dbo.lOB_part_SU_owner WHERE OB_ID_part = @o AND Positor = 0);
INSERT INTO #result SELECT N'i05 an insert of other values of a static tie is an alternative', CASE WHEN @n = 1 AND @owner = @s3 THEN 1 ELSE 0 END, CONCAT(@n, ' retractions; shown owner ', @owner);
UPDATE #group SET finished = 1 WHERE name = 'i05';
GO

-- i06 an update of a nexus attribute through the latest view is a correction, which retracts the shown posit
DECLARE @s int, @e int, @n int, @quantity int, @error nvarchar(2048);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
INSERT INTO dbo.lEV_Event (Metadata_EV, SU_ID_for, EV_QTY_Event_Quantity, EV_QTY_PositedAt) VALUES (0, @s, 5, '2024-01-01');
SET @e = (SELECT MAX(EV_ID) FROM dbo.EV_Event WHERE SU_ID_for = @s);
BEGIN TRY
    UPDATE dbo.lEV_Event SET EV_QTY_Event_Quantity = 6, EV_QTY_PositedAt = '2024-02-01' WHERE EV_ID = @e AND Positor = 0;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @quantity = (SELECT EV_QTY_Event_Quantity FROM dbo.lEV_Event WHERE EV_ID = @e AND Positor = 0);
SET @n = (SELECT COUNT(*) FROM dbo.EV_QTY_Event_Quantity_Annex a JOIN dbo.EV_QTY_Event_Quantity_Posit p ON p.EV_QTY_ID = a.EV_QTY_ID
    WHERE p.EV_QTY_EV_ID = @e AND p.EV_QTY_Event_Quantity = 5 AND a.EV_QTY_PositedAt = '2024-02-01' AND a.EV_QTY_Reliability = 0);
INSERT INTO #result SELECT N'i06 an update of a nexus attribute is a correction', CASE WHEN @error IS NULL AND @quantity = 6 AND @n = 1 THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(CAST(@quantity AS varchar), 'nothing'), ', ', @n, ' retractions of 5', ' ' + @error);
UPDATE #group SET finished = 1 WHERE name = 'i06';
GO

-- the result
INSERT INTO #result SELECT name + N' did not run to the end (its error is in the output above)', 0, NULL FROM #group WHERE finished = 0;
SELECT CASE WHEN passed = 1 THEN 'PASS' ELSE 'FAIL' END + ' ' + test + ISNULL(' (' + detail + ')', '') AS result FROM #result ORDER BY id;
DECLARE @failed int = (SELECT COUNT(*) FROM #result WHERE passed = 0), @total int = (SELECT COUNT(*) FROM #result);
PRINT CONCAT(@total - @failed, ' of ', @total, ' checks passed');
IF @failed > 0 THROW 50000, 'Some trigger checks failed', 1;
GO
