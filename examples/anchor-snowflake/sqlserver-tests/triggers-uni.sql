-- Trigger tests, uni-temporal: what inserts, updates and deletes through the views store.
--
-- Runs against the output for models/sqlserver-triggers.xml (golden/sqlserver-triggers/_full.sql) in an empty
-- database; tools/sqlserver-tests.ps1 does both. Each check adds a row to #result; the list is shown at the end, and
-- the script ends with an error if a check failed. A check that expects an error catches it. Each group of checks
-- marks itself finished as its last statement, so a group that stops early, on an error it does not catch or because
-- it does not compile, counts as a failure too. Every group uses rows of its own, and gives its times explicitly where
-- the rule does not depend on now.
-- The rules are in Anchor's docs/ANCHOR.md, "Loading through the latest views".
SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result;
IF OBJECT_ID('tempdb..#group') IS NOT NULL DROP TABLE #group;
CREATE TABLE #result (id int IDENTITY(1,1) PRIMARY KEY, test nvarchar(400) NOT NULL, passed bit NOT NULL, detail nvarchar(2048) NULL);
CREATE TABLE #group (name char(3) PRIMARY KEY, finished bit NOT NULL DEFAULT 0);
INSERT INTO #group (name) VALUES ('u01'), ('u02'), ('u03'), ('u04'), ('u05'), ('u06'), ('u07'), ('u08'), ('u09'), ('u10'), ('u11');
INSERT INTO dbo.GRD_Grade (GRD_ID, GRD_Grade, Metadata_GRD) VALUES (1, N'A', 0), (2, N'B', 0), (3, N'C', 0);
GO

-- u01 an insert through the latest view stores each value given
DECLARE @s int, @n int;
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_COD_Subject_Code, SU_GRD_GRD_ID, SU_NOT_Subject_Note,
    SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_STA_Subject_State, SU_STA_ChangedAt, SU_LBL_Subject_Label, SU_LBL_ChangedAt,
    SU_TAG_Subject_Tag, SU_TAG_ChangedAt, SU_LVL_GRD_ID, SU_LVL_ChangedAt, SU_TXT_Subject_Text, SU_TXT_ChangedAt,
    SU_ASR_Subject_Assessment, SU_ASR_ChangedAt, SU_ERS_Subject_Erasable, SU_ERS_ChangedAt)
VALUES (0, N'name', N'code', 1, N'note', N'title', '2020-01-01', N'state', '2020-01-01', N'label', '2020-01-01',
    N'tag', '2020-01-01', 1, '2020-01-01', N'text', '2020-01-01', N'assessment', '2020-01-01', N'erasable', '2020-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
SET @n = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name WHERE SU_NAM_SU_ID = @s) + (SELECT COUNT(*) FROM dbo.SU_COD_Subject_Code WHERE SU_COD_SU_ID = @s)
       + (SELECT COUNT(*) FROM dbo.SU_GRD_Subject_Grade WHERE SU_GRD_SU_ID = @s) + (SELECT COUNT(*) FROM dbo.SU_NOT_Subject_Note WHERE SU_NOT_SU_ID = @s)
       + (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title WHERE SU_TTL_SU_ID = @s) + (SELECT COUNT(*) FROM dbo.SU_STA_Subject_State WHERE SU_STA_SU_ID = @s)
       + (SELECT COUNT(*) FROM dbo.SU_LBL_Subject_Label WHERE SU_LBL_SU_ID = @s) + (SELECT COUNT(*) FROM dbo.SU_TAG_Subject_Tag WHERE SU_TAG_SU_ID = @s)
       + (SELECT COUNT(*) FROM dbo.SU_LVL_Subject_Level WHERE SU_LVL_SU_ID = @s) + (SELECT COUNT(*) FROM dbo.SU_TXT_Subject_Text WHERE SU_TXT_SU_ID = @s)
       + (SELECT COUNT(*) FROM dbo.SU_ASR_Subject_Assessment WHERE SU_ASR_SU_ID = @s) + (SELECT COUNT(*) FROM dbo.SU_ERS_Subject_Erasable WHERE SU_ERS_SU_ID = @s);
INSERT INTO #result SELECT N'u01 an insert through the latest view stores each value', CASE WHEN @n = 12 THEN 1 ELSE 0 END, CONCAT(@n, ' rows, expected 12');
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_GRD_GRD_Grade) VALUES (0, N'B');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
SET @n = (SELECT SU_GRD_GRD_ID FROM dbo.SU_GRD_Subject_Grade WHERE SU_GRD_SU_ID = @s);
INSERT INTO #result SELECT N'u01 an insert by knot value stores the knot', CASE WHEN @n = 2 THEN 1 ELSE 0 END, CONCAT('knot ', @n, ', expected 2');
UPDATE #group SET finished = 1 WHERE name = 'u01';
GO

-- u02 an update that leaves every value as it is states nothing (State is not restatable and Name is static: both
--     used to fail, as a restatement at now and on the key)
DECLARE @s int, @before int, @after int, @error nvarchar(2048);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_COD_Subject_Code, SU_GRD_GRD_ID, SU_NOT_Subject_Note,
    SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_STA_Subject_State, SU_STA_ChangedAt, SU_LBL_Subject_Label, SU_LBL_ChangedAt,
    SU_TAG_Subject_Tag, SU_TAG_ChangedAt, SU_LVL_GRD_ID, SU_LVL_ChangedAt, SU_TXT_Subject_Text, SU_TXT_ChangedAt,
    SU_ASR_Subject_Assessment, SU_ASR_ChangedAt, SU_ERS_Subject_Erasable, SU_ERS_ChangedAt)
VALUES (0, N'name', N'code', 1, N'note', N'title', '2020-01-01', N'state', '2020-01-01', N'label', '2020-01-01',
    N'tag', '2020-01-01', 1, '2020-01-01', N'text', '2020-01-01', N'assessment', '2020-01-01', N'erasable', '2020-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
SET @before = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name) + (SELECT COUNT(*) FROM dbo.SU_COD_Subject_Code) + (SELECT COUNT(*) FROM dbo.SU_GRD_Subject_Grade)
       + (SELECT COUNT(*) FROM dbo.SU_NOT_Subject_Note) + (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title) + (SELECT COUNT(*) FROM dbo.SU_STA_Subject_State)
       + (SELECT COUNT(*) FROM dbo.SU_LBL_Subject_Label) + (SELECT COUNT(*) FROM dbo.SU_TAG_Subject_Tag) + (SELECT COUNT(*) FROM dbo.SU_LVL_Subject_Level)
       + (SELECT COUNT(*) FROM dbo.SU_TXT_Subject_Text) + (SELECT COUNT(*) FROM dbo.SU_ASR_Subject_Assessment) + (SELECT COUNT(*) FROM dbo.SU_ERS_Subject_Erasable);
BEGIN TRY
    UPDATE dbo.lSU_Subject SET SU_NAM_Subject_Name = SU_NAM_Subject_Name, SU_COD_Subject_Code = SU_COD_Subject_Code,
        SU_GRD_GRD_ID = SU_GRD_GRD_ID, SU_NOT_Subject_Note = SU_NOT_Subject_Note, SU_TTL_Subject_Title = SU_TTL_Subject_Title,
        SU_STA_Subject_State = SU_STA_Subject_State, SU_LBL_Subject_Label = SU_LBL_Subject_Label, SU_TAG_Subject_Tag = SU_TAG_Subject_Tag,
        SU_LVL_GRD_ID = SU_LVL_GRD_ID, SU_TXT_Subject_Text = SU_TXT_Subject_Text, SU_ASR_Subject_Assessment = SU_ASR_Subject_Assessment,
        SU_ERS_Subject_Erasable = SU_ERS_Subject_Erasable
    WHERE SU_ID = @s;
    UPDATE dbo.lSU_Subject SET SU_GRD_GRD_Grade = SU_GRD_GRD_Grade, SU_LVL_GRD_Grade = SU_LVL_GRD_Grade WHERE SU_ID = @s;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @after = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name) + (SELECT COUNT(*) FROM dbo.SU_COD_Subject_Code) + (SELECT COUNT(*) FROM dbo.SU_GRD_Subject_Grade)
       + (SELECT COUNT(*) FROM dbo.SU_NOT_Subject_Note) + (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title) + (SELECT COUNT(*) FROM dbo.SU_STA_Subject_State)
       + (SELECT COUNT(*) FROM dbo.SU_LBL_Subject_Label) + (SELECT COUNT(*) FROM dbo.SU_TAG_Subject_Tag) + (SELECT COUNT(*) FROM dbo.SU_LVL_Subject_Level)
       + (SELECT COUNT(*) FROM dbo.SU_TXT_Subject_Text) + (SELECT COUNT(*) FROM dbo.SU_ASR_Subject_Assessment) + (SELECT COUNT(*) FROM dbo.SU_ERS_Subject_Erasable);
INSERT INTO #result SELECT N'u02 an update that leaves every value as it is states nothing', CASE WHEN @error IS NULL AND @after = @before THEN 1 ELSE 0 END, CONCAT(@after - @before, ' new rows', ' ' + @error);
UPDATE #group SET finished = 1 WHERE name = 'u02';
GO

-- u03 a new value of a historized attribute is a new version from now
DECLARE @s int, @n int, @shown nvarchar(42), @changed datetime2;
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt) VALUES (0, N'first', '2020-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N'second' WHERE SU_ID = @s;
SELECT @shown = SU_TTL_Subject_Title, @changed = SU_TTL_ChangedAt FROM dbo.lSU_Subject WHERE SU_ID = @s;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title WHERE SU_TTL_SU_ID = @s);
INSERT INTO #result SELECT N'u03 a new value is a new version from now', CASE WHEN @n = 2 AND @shown = N'second' AND @changed > '2025-01-01' THEN 1 ELSE 0 END, CONCAT(@n, ' versions, shown ', @shown, ' from ', @changed);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N'third', SU_TTL_ChangedAt = '2022-01-01' WHERE SU_ID = @s;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title WHERE SU_TTL_SU_ID = @s AND SU_TTL_ChangedAt = '2022-01-01' AND SU_TTL_Subject_Title = N'third');
INSERT INTO #result SELECT N'u03 a new value with a changing time is a version from that time', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' versions at 2022, expected 1');
UPDATE #group SET finished = 1 WHERE name = 'u03';
GO

-- u04 the same value with a changing time of its own is a restatement, and the settings decide
DECLARE @s int, @n int, @error nvarchar(2048);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_STA_Subject_State, SU_STA_ChangedAt,
    SU_LBL_Subject_Label, SU_LBL_ChangedAt, SU_TAG_Subject_Tag, SU_TAG_ChangedAt, SU_LVL_GRD_ID, SU_LVL_ChangedAt, SU_TXT_Subject_Text, SU_TXT_ChangedAt)
VALUES (0, N'x', '2020-01-01', N'x', '2020-01-01', N'x', '2020-01-01', N'x', '2020-01-01', 1, '2020-01-01', N'x', '2020-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N'x', SU_TTL_ChangedAt = '2021-01-01' WHERE SU_ID = @s;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title WHERE SU_TTL_SU_ID = @s);
INSERT INTO #result SELECT N'u04 restatable: a restatement is stored', CASE WHEN @n = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' versions, expected 2');
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lSU_Subject SET SU_STA_Subject_State = N'x', SU_STA_ChangedAt = '2021-01-01' WHERE SU_ID = @s;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.SU_STA_Subject_State WHERE SU_STA_SU_ID = @s);
INSERT INTO #result SELECT N'u04 not restatable: a restatement is an error', CASE WHEN @error LIKE N'Restatement in SU_STA_Subject_State%' AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' versions; ', ISNULL(@error, 'no error'));
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lSU_Subject SET SU_LBL_Subject_Label = N'x', SU_LBL_ChangedAt = '2021-01-01' WHERE SU_ID = @s;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.SU_LBL_Subject_Label WHERE SU_LBL_SU_ID = @s);
INSERT INTO #result SELECT N'u04 not restatable, idempotent: a restatement is skipped', CASE WHEN @error IS NULL AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' versions', ' ' + @error);
UPDATE dbo.lSU_Subject SET SU_TAG_Subject_Tag = N'x', SU_TAG_ChangedAt = '2021-01-01' WHERE SU_ID = @s;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TAG_Subject_Tag WHERE SU_TAG_SU_ID = @s);
INSERT INTO #result SELECT N'u04 restatable, idempotent: a restatement is skipped', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' versions, expected 1');
UPDATE dbo.lSU_Subject SET SU_LVL_GRD_ID = 1, SU_LVL_ChangedAt = '2021-01-01' WHERE SU_ID = @s;
SET @n = (SELECT COUNT(*) FROM dbo.SU_LVL_Subject_Level WHERE SU_LVL_SU_ID = @s);
INSERT INTO #result SELECT N'u04 knotted, restatable: a restatement is stored', CASE WHEN @n = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' versions, expected 2');
UPDATE dbo.lSU_Subject SET SU_TXT_Subject_Text = N'x', SU_TXT_ChangedAt = '2021-01-01' WHERE SU_ID = @s;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TXT_Subject_Text WHERE SU_TXT_SU_ID = @s);
INSERT INTO #result SELECT N'u04 with a checksum, restatable: a restatement is stored', CASE WHEN @n = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' versions, expected 2');
UPDATE #group SET finished = 1 WHERE name = 'u04';
GO

-- u05 a static value: a missing one is filled, the same one states nothing, another one is a contradiction
DECLARE @s int, @n int, @v nvarchar(max), @error nvarchar(2048);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
UPDATE dbo.lSU_Subject SET SU_NAM_Subject_Name = N'n1', SU_COD_Subject_Code = N'c1', SU_GRD_GRD_Grade = N'A', SU_NOT_Subject_Note = N'note one' WHERE SU_ID = @s;
SET @n = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name WHERE SU_NAM_SU_ID = @s) + (SELECT COUNT(*) FROM dbo.SU_COD_Subject_Code WHERE SU_COD_SU_ID = @s)
       + (SELECT COUNT(*) FROM dbo.SU_GRD_Subject_Grade WHERE SU_GRD_SU_ID = @s AND SU_GRD_GRD_ID = 1) + (SELECT COUNT(*) FROM dbo.SU_NOT_Subject_Note WHERE SU_NOT_SU_ID = @s);
INSERT INTO #result SELECT N'u05 a missing static value is filled by an update', CASE WHEN @n = 4 THEN 1 ELSE 0 END, CONCAT(@n, ' values, expected 4');
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lSU_Subject SET SU_NAM_Subject_Name = N'n1', SU_COD_Subject_Code = N'c1', SU_GRD_GRD_ID = 1, SU_NOT_Subject_Note = N'note one' WHERE SU_ID = @s;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
INSERT INTO #result SELECT N'u05 the same static value states nothing', CASE WHEN @error IS NULL THEN 1 ELSE 0 END, @error;
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lSU_Subject SET SU_NAM_Subject_Name = N'n2' WHERE SU_ID = @s;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @v = (SELECT SU_NAM_Subject_Name FROM dbo.SU_NAM_Subject_Name WHERE SU_NAM_SU_ID = @s);
INSERT INTO #result SELECT N'u05 another static value is a contradiction', CASE WHEN @error LIKE N'Contradiction in SU_NAM_Subject_Name%' AND @v = N'n1' THEN 1 ELSE 0 END, CONCAT(@v, '; ', ISNULL(@error, 'no error'));
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lSU_Subject SET SU_COD_Subject_Code = N'c2' WHERE SU_ID = @s;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
INSERT INTO #result SELECT N'u05 idempotent: another static value is still a contradiction', CASE WHEN @error LIKE N'Contradiction in SU_COD_Subject_Code%' THEN 1 ELSE 0 END, ISNULL(@error, 'no error');
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lSU_Subject SET SU_GRD_GRD_Grade = N'B' WHERE SU_ID = @s;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
INSERT INTO #result SELECT N'u05 knotted: another knot value is a contradiction', CASE WHEN @error LIKE N'Contradiction in SU_GRD_Subject_Grade%' THEN 1 ELSE 0 END, ISNULL(@error, 'no error');
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lSU_Subject SET SU_NOT_Subject_Note = N'note two' WHERE SU_ID = @s;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
INSERT INTO #result SELECT N'u05 with a checksum: another value is a contradiction', CASE WHEN @error LIKE N'Contradiction in SU_NOT_Subject_Note%' THEN 1 ELSE 0 END, ISNULL(@error, 'no error');
UPDATE #group SET finished = 1 WHERE name = 'u05';
GO

-- u06 inserts straight into the attribute tables: the identical is ignored, another value for the same slot is a
--     contradiction, and a restatement of an attribute that is not restatable is an error
DECLARE @s int, @n int, @error nvarchar(2048);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_STA_Subject_State, SU_STA_ChangedAt)
VALUES (0, N'n', N't', '2020-01-01', N's', '2020-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
SET @error = NULL;
BEGIN TRY
    INSERT INTO dbo.SU_NAM_Subject_Name (SU_NAM_SU_ID, SU_NAM_Subject_Name, Metadata_SU_NAM) VALUES (@s, N'n', 0);
    INSERT INTO dbo.SU_TTL_Subject_Title (SU_TTL_SU_ID, SU_TTL_ChangedAt, SU_TTL_Subject_Title, Metadata_SU_TTL) VALUES (@s, '2020-01-01', N't', 0);
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name WHERE SU_NAM_SU_ID = @s) + (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title WHERE SU_TTL_SU_ID = @s);
INSERT INTO #result SELECT N'u06 the identical inserted again is ignored (it used to fail on the key for a static attribute)', CASE WHEN @error IS NULL AND @n = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' rows', ' ' + @error);
SET @error = NULL;
BEGIN TRY
    INSERT INTO dbo.SU_TTL_Subject_Title (SU_TTL_SU_ID, SU_TTL_ChangedAt, SU_TTL_Subject_Title, Metadata_SU_TTL) VALUES (@s, '2020-01-01', N'other', 0);
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
INSERT INTO #result SELECT N'u06 another value at a changing time that has one is a contradiction', CASE WHEN @error LIKE N'Contradiction in SU_TTL_Subject_Title%' THEN 1 ELSE 0 END, ISNULL(@error, 'no error');
SET @error = NULL;
BEGIN TRY
    INSERT INTO dbo.SU_STA_Subject_State (SU_STA_SU_ID, SU_STA_ChangedAt, SU_STA_Subject_State, Metadata_SU_STA) VALUES (@s, '2021-01-01', N's', 0);
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
INSERT INTO #result SELECT N'u06 not restatable: an inserted restatement is an error', CASE WHEN @error LIKE N'Restatement in SU_STA_Subject_State%' THEN 1 ELSE 0 END, ISNULL(@error, 'no error');
UPDATE #group SET finished = 1 WHERE name = 'u06';
GO

-- u07 idempotent, out of order: an earlier version with the same value as the next one keeps the earlier start
DECLARE @s int, @n int, @changed datetime2;
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
INSERT INTO dbo.SU_LBL_Subject_Label (SU_LBL_SU_ID, SU_LBL_ChangedAt, SU_LBL_Subject_Label, Metadata_SU_LBL) VALUES (@s, '2021-01-01', N'x', 0);
INSERT INTO dbo.SU_LBL_Subject_Label (SU_LBL_SU_ID, SU_LBL_ChangedAt, SU_LBL_Subject_Label, Metadata_SU_LBL) VALUES (@s, '2020-01-01', N'x', 0);
SELECT @n = COUNT(*), @changed = MIN(SU_LBL_ChangedAt) FROM dbo.SU_LBL_Subject_Label WHERE SU_LBL_SU_ID = @s;
INSERT INTO #result SELECT N'u07 idempotent: the value counts from the earlier time', CASE WHEN @n = 1 AND @changed = '2020-01-01' THEN 1 ELSE 0 END, CONCAT(@n, ' versions from ', @changed);
UPDATE #group SET finished = 1 WHERE name = 'u07';
GO

-- u08 null: nothing for an attribute that is not deletable, nothing without the deletable column, and the history
--     moved to the deletion table with it
DECLARE @s int, @n int, @deleted int, @shown nvarchar(42);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_ERS_Subject_Erasable, SU_ERS_ChangedAt) VALUES (0, N't', '2020-01-01', N'e', '2020-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_ERS_Subject_Erasable = N'f', SU_ERS_ChangedAt = '2021-01-01' WHERE SU_ID = @s;
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = NULL WHERE SU_ID = @s;
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s);
INSERT INTO #result SELECT N'u08 null changes nothing when not deletable', CASE WHEN @shown = N't' THEN 1 ELSE 0 END, CONCAT('shown ', @shown);
UPDATE dbo.lSU_Subject SET SU_ERS_Subject_Erasable = NULL WHERE SU_ID = @s;
SET @n = (SELECT COUNT(*) FROM dbo.SU_ERS_Subject_Erasable WHERE SU_ERS_SU_ID = @s);
INSERT INTO #result SELECT N'u08 null without the deletable column changes nothing', CASE WHEN @n = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' versions, expected 2');
UPDATE dbo.lSU_Subject SET SU_ERS_Subject_Erasable = NULL, Deletable_SU_ERS = 1 WHERE SU_ID = @s;
SET @n = (SELECT COUNT(*) FROM dbo.SU_ERS_Subject_Erasable WHERE SU_ERS_SU_ID = @s);
SET @deleted = (SELECT COUNT(*) FROM dbo.SU_ERS_Subject_Erasable_Deleted WHERE SU_ERS_SU_ID = @s);
INSERT INTO #result SELECT N'u08 null with the deletable column moves the history to the deletion table', CASE WHEN @n = 0 AND @deleted = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' left, ', @deleted, ' moved');
UPDATE #group SET finished = 1 WHERE name = 'u08';
GO

-- u09 a delete through the latest view removes the shown versions
DECLARE @s int, @n int, @shown nvarchar(42);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_TTL_Subject_Title, SU_TTL_ChangedAt) VALUES (0, N'n', N'one', '2020-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N'two', SU_TTL_ChangedAt = '2021-01-01' WHERE SU_ID = @s;
DELETE FROM dbo.lSU_Subject WHERE SU_ID = @s;
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s);
SET @n = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name WHERE SU_NAM_SU_ID = @s);
INSERT INTO #result SELECT N'u09 a delete removes the shown versions', CASE WHEN @shown = N'one' AND @n = 0 THEN 1 ELSE 0 END, CONCAT('shown ', @shown, ', ', @n, ' names left');
UPDATE #group SET finished = 1 WHERE name = 'u09';
GO

-- u10 ties
DECLARE @s1 int, @s2 int, @s3 int, @o int, @n int, @shown nvarchar(42), @error nvarchar(2048);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s1 = SCOPE_IDENTITY();
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s2 = SCOPE_IDENTITY();
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s3 = SCOPE_IDENTITY();
INSERT INTO dbo.OB_Object (Metadata_OB) VALUES (0); SET @o = SCOPE_IDENTITY();
-- historized, with identifiers and a value
INSERT INTO dbo.lSU_holder_OB_item_GRD_grade (Metadata_SU_holder_OB_item_GRD_grade, SU_holder_OB_item_GRD_grade_ChangedAt, SU_ID_holder, OB_ID_item, GRD_ID_grade) VALUES (0, '2020-01-01', @s1, @o, 1);
UPDATE dbo.lSU_holder_OB_item_GRD_grade SET GRD_ID_grade = 1 WHERE SU_ID_holder = @s1 AND OB_ID_item = @o;
SET @n = (SELECT COUNT(*) FROM dbo.SU_holder_OB_item_GRD_grade WHERE SU_ID_holder = @s1);
INSERT INTO #result SELECT N'u10 a tie: unchanged values state nothing', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' versions, expected 1');
UPDATE dbo.lSU_holder_OB_item_GRD_grade SET grade_GRD_Grade = N'B', SU_holder_OB_item_GRD_grade_ChangedAt = '2021-01-01' WHERE SU_ID_holder = @s1 AND OB_ID_item = @o;
SET @shown = (SELECT grade_GRD_Grade FROM dbo.lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = @s1 AND OB_ID_item = @o);
INSERT INTO #result SELECT N'u10 a tie: a new value by knot value is a new version', CASE WHEN @shown = N'B' THEN 1 ELSE 0 END, CONCAT('shown ', @shown);
UPDATE dbo.lSU_holder_OB_item_GRD_grade SET GRD_ID_grade = 2, SU_holder_OB_item_GRD_grade_ChangedAt = '2022-01-01' WHERE SU_ID_holder = @s1 AND OB_ID_item = @o;
SET @n = (SELECT COUNT(*) FROM dbo.SU_holder_OB_item_GRD_grade WHERE SU_ID_holder = @s1);
INSERT INTO #result SELECT N'u10 a restatable tie: a restatement is stored', CASE WHEN @n = 3 THEN 1 ELSE 0 END, CONCAT(@n, ' versions, expected 3');
-- historized, idempotent and not restatable
INSERT INTO dbo.lSU_keeper_OB_thing_GRD_rank (Metadata_SU_keeper_OB_thing_GRD_rank, SU_keeper_OB_thing_GRD_rank_ChangedAt, SU_ID_keeper, OB_ID_thing, GRD_ID_rank) VALUES (0, '2020-01-01', @s1, @o, 1);
UPDATE dbo.lSU_keeper_OB_thing_GRD_rank SET GRD_ID_rank = 1, SU_keeper_OB_thing_GRD_rank_ChangedAt = '2021-01-01' WHERE SU_ID_keeper = @s1 AND OB_ID_thing = @o;
SET @n = (SELECT COUNT(*) FROM dbo.SU_keeper_OB_thing_GRD_rank WHERE SU_ID_keeper = @s1);
INSERT INTO #result SELECT N'u10 an idempotent tie: a restatement is skipped', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' versions, expected 1');
-- static, with an identifier and a value
INSERT INTO dbo.lOB_part_SU_owner (Metadata_OB_part_SU_owner, OB_ID_part, SU_ID_owner) VALUES (0, @o, @s1);
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lOB_part_SU_owner SET SU_ID_owner = @s1 WHERE OB_ID_part = @o;
    INSERT INTO dbo.lOB_part_SU_owner (Metadata_OB_part_SU_owner, OB_ID_part, SU_ID_owner) VALUES (0, @o, @s1);
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.OB_part_SU_owner WHERE OB_ID_part = @o);
INSERT INTO #result SELECT N'u10 a static tie: the same values state nothing and are not inserted twice', CASE WHEN @error IS NULL AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' rows', ' ' + @error);
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lOB_part_SU_owner SET SU_ID_owner = @s2 WHERE OB_ID_part = @o;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT SU_ID_owner FROM dbo.OB_part_SU_owner WHERE OB_ID_part = @o);
INSERT INTO #result SELECT N'u10 a static tie: another value is a contradiction (it used to be ignored)', CASE WHEN @error LIKE N'Contradiction in OB_part_SU_owner%' AND @n = @s1 THEN 1 ELSE 0 END, ISNULL(@error, 'no error');
-- historized, without identifiers
INSERT INTO dbo.lSU_partner_SU_with (Metadata_SU_partner_SU_with, SU_partner_SU_with_ChangedAt, SU_ID_partner, SU_ID_with) VALUES (0, '2020-01-01', @s1, @s2);
UPDATE dbo.lSU_partner_SU_with SET SU_ID_with = @s2 WHERE SU_ID_partner = @s1;
SET @n = (SELECT COUNT(*) FROM dbo.SU_partner_SU_with WHERE SU_ID_partner = @s1);
INSERT INTO #result SELECT N'u10 a tie without identifiers: unchanged values state nothing', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' rows, expected 1');
UPDATE dbo.lSU_partner_SU_with SET SU_ID_with = @s3, SU_partner_SU_with_ChangedAt = '2021-01-01' WHERE SU_ID_partner = @s1;
SET @n = (SELECT COUNT(*) FROM dbo.SU_partner_SU_with WHERE SU_ID_partner = @s1);
INSERT INTO #result SELECT N'u10 a tie without identifiers: other values are a row of their own', CASE WHEN @n = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' rows, expected 2');
UPDATE #group SET finished = 1 WHERE name = 'u10';
GO

-- u11 a nexus: an insert through its latest view (it used to fail: the roles were not stored), and its static
--     attribute
DECLARE @s int, @e int, @n int, @error nvarchar(2048);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
BEGIN TRY
    INSERT INTO dbo.lEV_Event (Metadata_EV, SU_ID_for, EV_QTY_Event_Quantity) VALUES (0, @s, 5);
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @e = (SELECT MAX(EV_ID) FROM dbo.EV_Event WHERE SU_ID_for = @s);
SET @n = (SELECT COUNT(*) FROM dbo.EV_QTY_Event_Quantity WHERE EV_QTY_EV_ID = @e);
INSERT INTO #result SELECT N'u11 a nexus with an attribute through its latest view', CASE WHEN @error IS NULL AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' values', ' ' + @error);
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lEV_Event SET EV_QTY_Event_Quantity = 5 WHERE EV_ID = @e;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
INSERT INTO #result SELECT N'u11 a nexus: the same value states nothing', CASE WHEN @e IS NOT NULL AND @error IS NULL THEN 1 ELSE 0 END, @error;
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lEV_Event SET EV_QTY_Event_Quantity = 6 WHERE EV_ID = @e;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
INSERT INTO #result SELECT N'u11 a nexus: another value is a contradiction', CASE WHEN @error LIKE N'Contradiction in EV_QTY_Event_Quantity%' THEN 1 ELSE 0 END, ISNULL(@error, 'no error');
UPDATE #group SET finished = 1 WHERE name = 'u11';
GO

-- the result
INSERT INTO #result SELECT name + N' did not run to the end (its error is in the output above)', 0, NULL FROM #group WHERE finished = 0;
SELECT CASE WHEN passed = 1 THEN 'PASS' ELSE 'FAIL' END + ' ' + test + ISNULL(' (' + detail + ')', '') AS result FROM #result ORDER BY id;
DECLARE @failed int = (SELECT COUNT(*) FROM #result WHERE passed = 0), @total int = (SELECT COUNT(*) FROM #result);
PRINT CONCAT(@total - @failed, ' of ', @total, ' checks passed');
IF @failed > 0 THROW 50000, 'Some trigger checks failed', 1;
GO
