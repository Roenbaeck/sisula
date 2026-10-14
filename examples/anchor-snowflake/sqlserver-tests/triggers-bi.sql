-- Trigger tests, bitemporal: what inserts, updates and deletes through the views store.
--
-- Runs against the output for models/sqlserver-triggers-bi.xml (golden/sqlserver-triggers-bi/_full.sql) in an empty
-- database; tools/sqlserver-tests.ps1 does both. Each check adds a row to #result; the list is shown at the end, and
-- the script ends with an error if a check failed. A check that expects an error catches it. Each group of checks
-- marks itself finished as its last statement, so a group that stops early, on an error it does not catch or because
-- it does not compile, counts as a failure too. Every group uses rows of its own, and gives its times explicitly where
-- the rule does not depend on now; in particular two statements about the same posit get positing times of their own,
-- since statements in a row can get the same sysdatetime().
-- The rules are in Anchor's docs/ANCHOR.md, "Loading through the latest views".
SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result;
IF OBJECT_ID('tempdb..#group') IS NOT NULL DROP TABLE #group;
CREATE TABLE #result (id int IDENTITY(1,1) PRIMARY KEY, test nvarchar(400) NOT NULL, passed bit NOT NULL, detail nvarchar(2048) NULL);
CREATE TABLE #group (name char(3) PRIMARY KEY, finished bit NOT NULL DEFAULT 0);
INSERT INTO #group (name) VALUES ('b01'), ('b02'), ('b03'), ('b04'), ('b05'), ('b06'), ('b07'), ('b08'), ('b09'), ('b10'), ('b11'), ('b12'), ('b13'), ('b14'), ('b15');
INSERT INTO dbo.GRD_Grade (GRD_ID, GRD_Grade, Metadata_GRD) VALUES (1, N'A', 0), (2, N'B', 0), (3, N'C', 0);
GO

-- b01 an insert through the latest view: a posit and an assertion for each value
DECLARE @s int, @posits int, @assertions int;
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_COD_Subject_Code, SU_GRD_GRD_ID, SU_NOT_Subject_Note,
    SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_STA_Subject_State, SU_STA_ChangedAt, SU_LBL_Subject_Label, SU_LBL_ChangedAt,
    SU_TAG_Subject_Tag, SU_TAG_ChangedAt, SU_LVL_GRD_ID, SU_LVL_ChangedAt, SU_TXT_Subject_Text, SU_TXT_ChangedAt,
    SU_ASR_Subject_Assessment, SU_ASR_ChangedAt, SU_ERS_Subject_Erasable, SU_ERS_ChangedAt)
VALUES (0, N'name', N'code', 1, N'note', N'title', '2020-01-01', N'state', '2020-01-01', N'label', '2020-01-01',
    N'tag', '2020-01-01', 1, '2020-01-01', N'text', '2020-01-01', N'assessment', '2020-01-01', N'erasable', '2020-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
SET @posits = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Posit WHERE SU_NAM_SU_ID = @s) + (SELECT COUNT(*) FROM dbo.SU_COD_Subject_Code_Posit WHERE SU_COD_SU_ID = @s)
       + (SELECT COUNT(*) FROM dbo.SU_GRD_Subject_Grade_Posit WHERE SU_GRD_SU_ID = @s) + (SELECT COUNT(*) FROM dbo.SU_NOT_Subject_Note_Posit WHERE SU_NOT_SU_ID = @s)
       + (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Posit WHERE SU_TTL_SU_ID = @s) + (SELECT COUNT(*) FROM dbo.SU_STA_Subject_State_Posit WHERE SU_STA_SU_ID = @s)
       + (SELECT COUNT(*) FROM dbo.SU_LBL_Subject_Label_Posit WHERE SU_LBL_SU_ID = @s) + (SELECT COUNT(*) FROM dbo.SU_TAG_Subject_Tag_Posit WHERE SU_TAG_SU_ID = @s)
       + (SELECT COUNT(*) FROM dbo.SU_LVL_Subject_Level_Posit WHERE SU_LVL_SU_ID = @s) + (SELECT COUNT(*) FROM dbo.SU_TXT_Subject_Text_Posit WHERE SU_TXT_SU_ID = @s)
       + (SELECT COUNT(*) FROM dbo.SU_ASR_Subject_Assessment_Posit WHERE SU_ASR_SU_ID = @s) + (SELECT COUNT(*) FROM dbo.SU_ERS_Subject_Erasable_Posit WHERE SU_ERS_SU_ID = @s);
SET @assertions = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex a JOIN dbo.SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID WHERE p.SU_TTL_SU_ID = @s);
INSERT INTO #result SELECT N'b01 an insert through the latest view stores a posit for each value', CASE WHEN @posits = 12 AND @assertions = 1 THEN 1 ELSE 0 END, CONCAT(@posits, ' posits, expected 12; ', @assertions, ' assertions of the title');
UPDATE #group SET finished = 1 WHERE name = 'b01';
GO

-- b02 an update that leaves every value and reliability as it is states nothing (State is not restatable: this
--     used to fail as a restatement at now)
DECLARE @s int, @before int, @after int, @error nvarchar(2048);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_GRD_GRD_ID, SU_NOT_Subject_Note, SU_TTL_Subject_Title, SU_TTL_ChangedAt,
    SU_STA_Subject_State, SU_STA_ChangedAt, SU_LVL_GRD_ID, SU_LVL_ChangedAt, SU_TXT_Subject_Text, SU_TXT_ChangedAt)
VALUES (0, N'name', 1, N'note', N'title', '2020-01-01', N'state', '2020-01-01', 1, '2020-01-01', N'text', '2020-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
SET @before = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex) + (SELECT COUNT(*) FROM dbo.SU_GRD_Subject_Grade_Annex) + (SELECT COUNT(*) FROM dbo.SU_NOT_Subject_Note_Annex)
       + (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex) + (SELECT COUNT(*) FROM dbo.SU_STA_Subject_State_Annex) + (SELECT COUNT(*) FROM dbo.SU_LVL_Subject_Level_Annex)
       + (SELECT COUNT(*) FROM dbo.SU_TXT_Subject_Text_Annex);
BEGIN TRY
    UPDATE dbo.lSU_Subject SET SU_NAM_Subject_Name = SU_NAM_Subject_Name, SU_GRD_GRD_ID = SU_GRD_GRD_ID, SU_NOT_Subject_Note = SU_NOT_Subject_Note,
        SU_TTL_Subject_Title = SU_TTL_Subject_Title, SU_STA_Subject_State = SU_STA_Subject_State, SU_LVL_GRD_ID = SU_LVL_GRD_ID,
        SU_TXT_Subject_Text = SU_TXT_Subject_Text, SU_TTL_Reliability = SU_TTL_Reliability
    WHERE SU_ID = @s;
    UPDATE dbo.lSU_Subject SET SU_GRD_GRD_Grade = SU_GRD_GRD_Grade, Reliability = 1 WHERE SU_ID = @s;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @after = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex) + (SELECT COUNT(*) FROM dbo.SU_GRD_Subject_Grade_Annex) + (SELECT COUNT(*) FROM dbo.SU_NOT_Subject_Note_Annex)
       + (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex) + (SELECT COUNT(*) FROM dbo.SU_STA_Subject_State_Annex) + (SELECT COUNT(*) FROM dbo.SU_LVL_Subject_Level_Annex)
       + (SELECT COUNT(*) FROM dbo.SU_TXT_Subject_Text_Annex);
INSERT INTO #result SELECT N'b02 an update that leaves everything as it is states nothing', CASE WHEN @error IS NULL AND @after = @before THEN 1 ELSE 0 END, CONCAT(@after - @before, ' new assertions', ' ' + @error);
UPDATE #group SET finished = 1 WHERE name = 'b02';
GO

-- b03 a new value of a historized attribute is a new version from now
DECLARE @s int, @n int, @shown nvarchar(42), @changed datetime2;
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt) VALUES (0, N'first', '2020-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N'second' WHERE SU_ID = @s;
SELECT @shown = SU_TTL_Subject_Title, @changed = SU_TTL_ChangedAt FROM dbo.lSU_Subject WHERE SU_ID = @s;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Posit WHERE SU_TTL_SU_ID = @s);
INSERT INTO #result SELECT N'b03 a new value is a new version from now', CASE WHEN @n = 2 AND @shown = N'second' AND @changed > '2025-01-01' THEN 1 ELSE 0 END, CONCAT(@n, ' posits, shown ', @shown, ' from ', @changed);
UPDATE #group SET finished = 1 WHERE name = 'b03';
GO

-- b04 the same value with a changing time of its own is a restatement, and the settings decide
DECLARE @s int, @n int, @error nvarchar(2048);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_STA_Subject_State, SU_STA_ChangedAt,
    SU_LBL_Subject_Label, SU_LBL_ChangedAt, SU_TAG_Subject_Tag, SU_TAG_ChangedAt, SU_LVL_GRD_ID, SU_LVL_ChangedAt, SU_TXT_Subject_Text, SU_TXT_ChangedAt)
VALUES (0, N'x', '2020-01-01', N'x', '2020-01-01', N'x', '2020-01-01', N'x', '2020-01-01', 1, '2020-01-01', N'x', '2020-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N'x', SU_TTL_ChangedAt = '2021-01-01' WHERE SU_ID = @s;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Posit WHERE SU_TTL_SU_ID = @s);
INSERT INTO #result SELECT N'b04 restatable: a restatement is stored', CASE WHEN @n = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' posits, expected 2');
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lSU_Subject SET SU_STA_Subject_State = N'x', SU_STA_ChangedAt = '2021-01-01' WHERE SU_ID = @s;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.SU_STA_Subject_State_Posit WHERE SU_STA_SU_ID = @s);
INSERT INTO #result SELECT N'b04 not restatable: a restatement is an error', CASE WHEN @error LIKE N'Restatement in SU_STA_Subject_State%' AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' posits; ', ISNULL(@error, 'no error'));
UPDATE dbo.lSU_Subject SET SU_LBL_Subject_Label = N'x', SU_LBL_ChangedAt = '2021-01-01' WHERE SU_ID = @s;
SET @n = (SELECT COUNT(*) FROM dbo.SU_LBL_Subject_Label_Posit WHERE SU_LBL_SU_ID = @s);
INSERT INTO #result SELECT N'b04 not restatable, idempotent: a restatement is skipped', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' posits, expected 1');
UPDATE dbo.lSU_Subject SET SU_TAG_Subject_Tag = N'x', SU_TAG_ChangedAt = '2021-01-01' WHERE SU_ID = @s;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TAG_Subject_Tag_Posit WHERE SU_TAG_SU_ID = @s);
INSERT INTO #result SELECT N'b04 restatable, idempotent: a restatement is skipped', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' posits, expected 1');
UPDATE dbo.lSU_Subject SET SU_LVL_GRD_ID = 1, SU_LVL_ChangedAt = '2021-01-01' WHERE SU_ID = @s;
SET @n = (SELECT COUNT(*) FROM dbo.SU_LVL_Subject_Level_Posit WHERE SU_LVL_SU_ID = @s);
INSERT INTO #result SELECT N'b04 knotted, restatable: a restatement is stored', CASE WHEN @n = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' posits, expected 2');
UPDATE dbo.lSU_Subject SET SU_TXT_Subject_Text = N'x', SU_TXT_ChangedAt = '2021-01-01' WHERE SU_ID = @s;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TXT_Subject_Text_Posit WHERE SU_TXT_SU_ID = @s);
INSERT INTO #result SELECT N'b04 with a checksum, restatable: a restatement is stored', CASE WHEN @n = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' posits, expected 2');
UPDATE #group SET finished = 1 WHERE name = 'b04';
GO

-- b05 another static value is a correction (it used to be ignored once a value was shown); the same states nothing
DECLARE @s int, @before int, @after int, @name nvarchar(42), @code nvarchar(42), @grade tinyint, @note nvarchar(max);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_NAM_PositedAt, SU_COD_Subject_Code, SU_COD_PositedAt, SU_GRD_GRD_ID, SU_GRD_PositedAt, SU_NOT_Subject_Note, SU_NOT_PositedAt)
VALUES (0, N'n1', '2024-01-01', N'c1', '2024-01-01', 1, '2024-01-01', N'note one', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
SET @before = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex) + (SELECT COUNT(*) FROM dbo.SU_COD_Subject_Code_Annex) + (SELECT COUNT(*) FROM dbo.SU_GRD_Subject_Grade_Annex) + (SELECT COUNT(*) FROM dbo.SU_NOT_Subject_Note_Annex);
UPDATE dbo.lSU_Subject SET SU_NAM_Subject_Name = N'n1', SU_COD_Subject_Code = N'c1', SU_GRD_GRD_Grade = N'A', SU_NOT_Subject_Note = N'note one' WHERE SU_ID = @s;
SET @after = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex) + (SELECT COUNT(*) FROM dbo.SU_COD_Subject_Code_Annex) + (SELECT COUNT(*) FROM dbo.SU_GRD_Subject_Grade_Annex) + (SELECT COUNT(*) FROM dbo.SU_NOT_Subject_Note_Annex);
INSERT INTO #result SELECT N'b05 the same static value states nothing', CASE WHEN @after = @before THEN 1 ELSE 0 END, CONCAT(@after - @before, ' new assertions');
UPDATE dbo.lSU_Subject SET SU_NAM_Subject_Name = N'n2', SU_COD_Subject_Code = N'c2', SU_GRD_GRD_Grade = N'B', SU_NOT_Subject_Note = N'note two',
    SU_NAM_PositedAt = '2024-02-01', SU_COD_PositedAt = '2024-02-01', SU_GRD_PositedAt = '2024-02-01', SU_NOT_PositedAt = '2024-02-01' WHERE SU_ID = @s;
SELECT @name = SU_NAM_Subject_Name, @code = SU_COD_Subject_Code, @grade = SU_GRD_GRD_ID, @note = SU_NOT_Subject_Note FROM dbo.lSU_Subject WHERE SU_ID = @s;
INSERT INTO #result SELECT N'b05 another static value is a correction', CASE WHEN @name = N'n2' AND @code = N'c2' AND @grade = 2 AND @note = N'note two' THEN 1 ELSE 0 END, CONCAT('shown ', @name, ', ', @code, ', ', @grade, ', ', @note);
UPDATE #group SET finished = 1 WHERE name = 'b05';
GO

-- b06 the shown value asserted again at a positing time of its own: stored when assertive, skipped when not
DECLARE @s int, @title int, @assessment int;
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_ASR_Subject_Assessment, SU_ASR_ChangedAt, SU_ASR_PositedAt)
VALUES (0, N't', '2020-01-01', '2024-01-01', N'a', '2020-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N't', SU_TTL_PositedAt = '2024-06-01', SU_ASR_Subject_Assessment = N'a', SU_ASR_PositedAt = '2024-06-01' WHERE SU_ID = @s;
SET @title = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex a JOIN dbo.SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID WHERE p.SU_TTL_SU_ID = @s);
SET @assessment = (SELECT COUNT(*) FROM dbo.SU_ASR_Subject_Assessment_Annex a JOIN dbo.SU_ASR_Subject_Assessment_Posit p ON p.SU_ASR_ID = a.SU_ASR_ID WHERE p.SU_ASR_SU_ID = @s);
INSERT INTO #result SELECT N'b06 assertive: a re-assertion is stored', CASE WHEN @title = 2 THEN 1 ELSE 0 END, CONCAT(@title, ' assertions, expected 2');
INSERT INTO #result SELECT N'b06 not assertive: a re-assertion is skipped', CASE WHEN @assessment = 1 THEN 1 ELSE 0 END, CONCAT(@assessment, ' assertions, expected 1');
UPDATE #group SET finished = 1 WHERE name = 'b06';
GO

-- b07 not assertive: A, then B, then A again at the same changing time shows A (the last A used to be lost)
DECLARE @s int, @shown nvarchar(42);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_ASR_Subject_Assessment, SU_ASR_ChangedAt, SU_ASR_PositedAt) VALUES (0, N'A', '2020-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_ASR_Subject_Assessment = N'B', SU_ASR_ChangedAt = '2020-01-01', SU_ASR_PositedAt = '2024-02-01' WHERE SU_ID = @s;
SET @shown = (SELECT SU_ASR_Subject_Assessment FROM dbo.lSU_Subject WHERE SU_ID = @s);
INSERT INTO #result SELECT N'b07 a value at the same changing time corrects the shown one', CASE WHEN @shown = N'B' THEN 1 ELSE 0 END, CONCAT('shown ', @shown);
UPDATE dbo.lSU_Subject SET SU_ASR_Subject_Assessment = N'A', SU_ASR_ChangedAt = '2020-01-01', SU_ASR_PositedAt = '2024-03-01' WHERE SU_ID = @s;
SET @shown = (SELECT SU_ASR_Subject_Assessment FROM dbo.lSU_Subject WHERE SU_ID = @s);
INSERT INTO #result SELECT N'b07 not assertive: switching back to an earlier value is stored', CASE WHEN @shown = N'A' THEN 1 ELSE 0 END, CONCAT('shown ', @shown, ', expected A');
UPDATE #group SET finished = 1 WHERE name = 'b07';
GO

-- b08 a reliability of 0 retracts the shown version, through the attribute's own column (that used to be lost) and
--     through the Reliability column; an unchanged reliability states nothing
DECLARE @s int, @t int, @shown nvarchar(42), @before int, @after int;
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt) VALUES (0, N'x', '2020-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N'y', SU_TTL_ChangedAt = '2021-01-01', SU_TTL_PositedAt = '2024-02-01' WHERE SU_ID = @s;
SET @before = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex);
UPDATE dbo.lSU_Subject SET Reliability = 1 WHERE SU_ID = @s;
SET @after = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex);
INSERT INTO #result SELECT N'b08 an unchanged reliability states nothing', CASE WHEN @after = @before THEN 1 ELSE 0 END, CONCAT(@after - @before, ' new assertions');
UPDATE dbo.lSU_Subject SET SU_TTL_Reliability = 0, SU_TTL_PositedAt = '2024-03-01' WHERE SU_ID = @s;
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s);
INSERT INTO #result SELECT N'b08 reliability 0 in the attribute''s own column retracts the shown version', CASE WHEN @shown = N'x' THEN 1 ELSE 0 END, CONCAT('shown ', @shown, ', expected x');
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_STA_Subject_State, SU_STA_ChangedAt, SU_STA_PositedAt) VALUES (0, N's', '2020-01-01', '2024-01-01');
SET @t = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET Reliability = 0, SU_STA_PositedAt = '2024-02-01' WHERE SU_ID = @t;
SET @shown = (SELECT SU_STA_Subject_State FROM dbo.lSU_Subject WHERE SU_ID = @t);
INSERT INTO #result SELECT N'b08 reliability 0 in the Reliability column retracts the shown version', CASE WHEN @shown IS NULL THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'));
UPDATE #group SET finished = 1 WHERE name = 'b08';
GO

-- b09 null retracts the shown version; a value after that is a new version
DECLARE @s int, @shown nvarchar(42);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt) VALUES (0, N'x', '2020-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = NULL, SU_TTL_PositedAt = '2024-02-01' WHERE SU_ID = @s;
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s);
INSERT INTO #result SELECT N'b09 null retracts the shown version', CASE WHEN @shown IS NULL THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'));
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N'y' WHERE SU_ID = @s;
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s);
INSERT INTO #result SELECT N'b09 a value after a retraction is stated', CASE WHEN @shown = N'y' THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'));
UPDATE #group SET finished = 1 WHERE name = 'b09';
GO

-- b10 a delete retracts each shown posit once, also one asserted twice (that used to collide on the annex key)
DECLARE @s int, @title nvarchar(42), @name nvarchar(42), @error nvarchar(2048);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt) VALUES (0, N'n', N't', '2020-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N't', SU_TTL_PositedAt = '2024-06-01' WHERE SU_ID = @s;
BEGIN TRY
    DELETE FROM dbo.lSU_Subject WHERE SU_ID = @s;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SELECT @title = SU_TTL_Subject_Title, @name = SU_NAM_Subject_Name FROM dbo.lSU_Subject WHERE SU_ID = @s;
INSERT INTO #result SELECT N'b10 a delete retracts the shown posits', CASE WHEN @error IS NULL AND @title IS NULL AND @name IS NULL THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@title, 'nothing'), ' and ', ISNULL(@name, 'nothing'), ' ' + @error);
UPDATE #group SET finished = 1 WHERE name = 'b10';
GO

-- b11 inserts straight into the assembled views: the identical is ignored
DECLARE @s int, @n int, @error nvarchar(2048);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
BEGIN TRY
    INSERT INTO dbo.SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Reliability) VALUES (0, @s, N't', '2020-01-01', '2024-01-01', 1);
    INSERT INTO dbo.SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Reliability) VALUES (0, @s, N't', '2020-01-01', '2024-01-01', 1);
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex a JOIN dbo.SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID WHERE p.SU_TTL_SU_ID = @s);
INSERT INTO #result SELECT N'b11 the identical inserted again is ignored', CASE WHEN @error IS NULL AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' assertions', ' ' + @error);
UPDATE #group SET finished = 1 WHERE name = 'b11';
GO

-- b12 idempotent, out of order: an earlier version with the same value as the next one keeps the earlier start
DECLARE @s int, @changed datetime2;
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
INSERT INTO dbo.SU_LBL_Subject_Label (Metadata_SU_LBL, SU_LBL_SU_ID, SU_LBL_Subject_Label, SU_LBL_ChangedAt, SU_LBL_PositedAt, SU_LBL_Reliability) VALUES (0, @s, N'x', '2021-01-01', '2024-01-01', 1);
INSERT INTO dbo.SU_LBL_Subject_Label (Metadata_SU_LBL, SU_LBL_SU_ID, SU_LBL_Subject_Label, SU_LBL_ChangedAt, SU_LBL_PositedAt, SU_LBL_Reliability) VALUES (0, @s, N'x', '2020-01-01', '2024-02-01', 1);
SET @changed = (SELECT SU_LBL_ChangedAt FROM dbo.lSU_Subject WHERE SU_ID = @s);
INSERT INTO #result SELECT N'b12 idempotent: the value counts from the earlier time', CASE WHEN @changed = '2020-01-01' THEN 1 ELSE 0 END, CONCAT('shown from ', @changed);
UPDATE #group SET finished = 1 WHERE name = 'b12';
GO

-- b13 ties
DECLARE @s1 int, @s2 int, @o int, @n int, @shown nvarchar(42), @owner int, @error nvarchar(2048);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s1 = SCOPE_IDENTITY();
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s2 = SCOPE_IDENTITY();
INSERT INTO dbo.OB_Object (Metadata_OB) VALUES (0); SET @o = SCOPE_IDENTITY();
-- historized, with identifiers and a value
INSERT INTO dbo.lSU_holder_OB_item_GRD_grade (Metadata_SU_holder_OB_item_GRD_grade, SU_holder_OB_item_GRD_grade_ChangedAt, SU_holder_OB_item_GRD_grade_PositedAt, SU_ID_holder, OB_ID_item, GRD_ID_grade)
VALUES (0, '2020-01-01', '2024-01-01', @s1, @o, 1);
UPDATE dbo.lSU_holder_OB_item_GRD_grade SET GRD_ID_grade = 1 WHERE SU_ID_holder = @s1 AND OB_ID_item = @o;
SET @n = (SELECT COUNT(*) FROM dbo.SU_holder_OB_item_GRD_grade_Annex a JOIN dbo.SU_holder_OB_item_GRD_grade_Posit p ON p.SU_holder_OB_item_GRD_grade_ID = a.SU_holder_OB_item_GRD_grade_ID WHERE p.SU_ID_holder = @s1 AND p.OB_ID_item = @o);
INSERT INTO #result SELECT N'b13 a tie: unchanged values state nothing', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' assertions, expected 1');
UPDATE dbo.lSU_holder_OB_item_GRD_grade SET grade_GRD_Grade = N'B', SU_holder_OB_item_GRD_grade_ChangedAt = '2021-01-01', SU_holder_OB_item_GRD_grade_PositedAt = '2024-02-01' WHERE SU_ID_holder = @s1 AND OB_ID_item = @o;
SET @shown = (SELECT grade_GRD_Grade FROM dbo.lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = @s1 AND OB_ID_item = @o);
INSERT INTO #result SELECT N'b13 a tie: a new value by knot value is a new version', CASE WHEN @shown = N'B' THEN 1 ELSE 0 END, CONCAT('shown ', @shown);
BEGIN TRY
    UPDATE dbo.lSU_holder_OB_item_GRD_grade SET GRD_ID_grade = NULL, SU_holder_OB_item_GRD_grade_PositedAt = '2024-03-01' WHERE SU_ID_holder = @s1 AND OB_ID_item = @o;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @shown = (SELECT grade_GRD_Grade FROM dbo.lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = @s1 AND OB_ID_item = @o);
INSERT INTO #result SELECT N'b13 a tie: null retracts the shown version (it used to fail)', CASE WHEN @error IS NULL AND @shown = N'A' THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'), ', expected A', ' ' + @error);
UPDATE dbo.lSU_holder_OB_item_GRD_grade SET SU_holder_OB_item_GRD_grade_Reliability = 0 WHERE SU_ID_holder = @s1 AND OB_ID_item = @o;
SET @n = (SELECT COUNT(*) FROM dbo.lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = @s1 AND OB_ID_item = @o);
INSERT INTO #result SELECT N'b13 a tie: reliability 0 retracts the shown version', CASE WHEN @n = 0 THEN 1 ELSE 0 END, CONCAT(@n, ' shown, expected 0');
-- historized, not assertive
INSERT INTO dbo.lSU_keeper_OB_thing_GRD_rank (Metadata_SU_keeper_OB_thing_GRD_rank, SU_keeper_OB_thing_GRD_rank_ChangedAt, SU_keeper_OB_thing_GRD_rank_PositedAt, SU_ID_keeper, OB_ID_thing, GRD_ID_rank)
VALUES (0, '2020-01-01', '2024-01-01', @s1, @o, 1);
UPDATE dbo.lSU_keeper_OB_thing_GRD_rank SET GRD_ID_rank = 1, SU_keeper_OB_thing_GRD_rank_PositedAt = '2024-06-01' WHERE SU_ID_keeper = @s1 AND OB_ID_thing = @o;
SET @n = (SELECT COUNT(*) FROM dbo.SU_keeper_OB_thing_GRD_rank_Annex a JOIN dbo.SU_keeper_OB_thing_GRD_rank_Posit p ON p.SU_keeper_OB_thing_GRD_rank_ID = a.SU_keeper_OB_thing_GRD_rank_ID WHERE p.SU_ID_keeper = @s1 AND p.OB_ID_thing = @o);
INSERT INTO #result SELECT N'b13 a tie that is not assertive: a re-assertion is skipped', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' assertions, expected 1');
-- static, with an identifier and a value
INSERT INTO dbo.lOB_part_SU_owner (Metadata_OB_part_SU_owner, OB_part_SU_owner_PositedAt, OB_ID_part, SU_ID_owner) VALUES (0, '2024-01-01', @o, @s1);
UPDATE dbo.lOB_part_SU_owner SET SU_ID_owner = @s2 WHERE OB_ID_part = @o;
SET @owner = (SELECT SU_ID_owner FROM dbo.lOB_part_SU_owner WHERE OB_ID_part = @o);
INSERT INTO #result SELECT N'b13 a static tie: another value is a correction', CASE WHEN @owner = @s2 THEN 1 ELSE 0 END, CONCAT('shown owner ', @owner);
-- historized, without identifiers
INSERT INTO dbo.lSU_partner_SU_with (Metadata_SU_partner_SU_with, SU_partner_SU_with_ChangedAt, SU_ID_partner, SU_ID_with) VALUES (0, '2020-01-01', @s1, @s2);
UPDATE dbo.lSU_partner_SU_with SET SU_ID_with = @s2 WHERE SU_ID_partner = @s1;
SET @n = (SELECT COUNT(*) FROM dbo.SU_partner_SU_with_Annex a JOIN dbo.SU_partner_SU_with_Posit p ON p.SU_partner_SU_with_ID = a.SU_partner_SU_with_ID WHERE p.SU_ID_partner = @s1);
INSERT INTO #result SELECT N'b13 a tie without identifiers: unchanged values state nothing', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' assertions, expected 1');
UPDATE #group SET finished = 1 WHERE name = 'b13';
GO

-- b14 a nexus with an attribute, through its latest view (it used to fail: there was no assembled view, and the
--     roles were not stored)
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
SET @n = (SELECT COUNT(*) FROM dbo.EV_QTY_Event_Quantity_Posit WHERE EV_QTY_EV_ID = @e);
INSERT INTO #result SELECT N'b14 a nexus with an attribute through its latest view', CASE WHEN @error IS NULL AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' values', ' ' + @error);
-- several new nexus rows in one insert: each keeps its own roles and values (they were paired with the new identities
-- by row numbers, in an order that SQL Server does not guarantee)
DECLARE @a int, @b int, @made int, @matched int;
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @a = SCOPE_IDENTITY();
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @b = SCOPE_IDENTITY();
SET @error = NULL;
BEGIN TRY
    INSERT INTO dbo.lEV_Event (Metadata_EV, SU_ID_for, EV_QTY_Event_Quantity) VALUES (0, @a, 7), (0, @b, 8), (0, @a, 9);
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @made = (SELECT COUNT(*) FROM dbo.EV_Event WHERE SU_ID_for IN (@a, @b));
SET @matched = (SELECT COUNT(*) FROM dbo.EV_Event e JOIN dbo.EV_QTY_Event_Quantity_Posit q ON q.EV_QTY_EV_ID = e.EV_ID
    WHERE (e.SU_ID_for = @a AND q.EV_QTY_Event_Quantity IN (7, 9)) OR (e.SU_ID_for = @b AND q.EV_QTY_Event_Quantity = 8));
INSERT INTO #result SELECT N'b14 several new nexus rows in one insert keep their own values', CASE WHEN @error IS NULL AND @made = 3 AND @matched = 3 THEN 1 ELSE 0 END, CONCAT(@made, ' rows, ', @matched, ' with their own values', ' ' + @error);
UPDATE #group SET finished = 1 WHERE name = 'b14';
GO

-- b15 a posit asserted again at a positing time that already has an assertion of it: the same reliability states
--     nothing, another one is a contradiction (it used to be skipped as if it were the identical)
DECLARE @s int, @o int, @n int, @shown nvarchar(42), @error nvarchar(2048);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt) VALUES (0, N'x', '2020-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N'x', SU_TTL_PositedAt = '2024-01-01' WHERE SU_ID = @s;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex a JOIN dbo.SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID WHERE p.SU_TTL_SU_ID = @s);
INSERT INTO #result SELECT N'b15 the same reliability at a positing time that is taken states nothing', CASE WHEN @error IS NULL AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' assertions', ' ' + @error);
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lSU_Subject SET SU_TTL_Reliability = 0, SU_TTL_PositedAt = '2024-01-01' WHERE SU_ID = @s;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s);
INSERT INTO #result SELECT N'b15 another reliability at a positing time that is taken is a contradiction', CASE WHEN @error LIKE N'Contradiction in SU_TTL_Subject_Title%' AND @shown = N'x' THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'), '; ', ISNULL(@error, 'no error'));
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
INSERT INTO dbo.OB_Object (Metadata_OB) VALUES (0); SET @o = SCOPE_IDENTITY();
INSERT INTO dbo.lSU_holder_OB_item_GRD_grade (Metadata_SU_holder_OB_item_GRD_grade, SU_holder_OB_item_GRD_grade_ChangedAt, SU_holder_OB_item_GRD_grade_PositedAt, SU_ID_holder, OB_ID_item, GRD_ID_grade)
VALUES (0, '2020-01-01', '2024-01-01', @s, @o, 1);
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lSU_holder_OB_item_GRD_grade SET SU_holder_OB_item_GRD_grade_Reliability = 0, SU_holder_OB_item_GRD_grade_PositedAt = '2024-01-01' WHERE SU_ID_holder = @s AND OB_ID_item = @o;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = @s AND OB_ID_item = @o);
INSERT INTO #result SELECT N'b15 a tie: another reliability at a positing time that is taken is a contradiction', CASE WHEN @error LIKE N'Contradiction in SU_holder_OB_item_GRD_grade%' AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' shown; ', ISNULL(@error, 'no error'));
UPDATE #group SET finished = 1 WHERE name = 'b15';
GO

-- the result
INSERT INTO #result SELECT name + N' did not run to the end (its error is in the output above)', 0, NULL FROM #group WHERE finished = 0;
SELECT CASE WHEN passed = 1 THEN 'PASS' ELSE 'FAIL' END + ' ' + test + ISNULL(' (' + detail + ')', '') AS result FROM #result ORDER BY id;
DECLARE @failed int = (SELECT COUNT(*) FROM #result WHERE passed = 0), @total int = (SELECT COUNT(*) FROM #result);
PRINT CONCAT(@total - @failed, ' of ', @total, ' checks passed');
IF @failed > 0 THROW 50000, 'Some trigger checks failed', 1;
GO
