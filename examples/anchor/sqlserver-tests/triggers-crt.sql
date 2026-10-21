-- Trigger tests, concurrent-reliance-temporal: what inserts, updates and deletes through the views store.
--
-- Runs against the output for models/sqlserver-triggers-crt.xml (golden/sqlserver-triggers-crt/_full.sql) in an empty
-- database; tools/sqlserver-tests.ps1 does both. Each check adds a row to #result; the list is shown at the end, and
-- the script ends with an error if a check failed. A check that expects an error catches it. Each group of checks
-- marks itself finished as its last statement, so a group that stops early, on an error it does not catch or because
-- it does not compile, counts as a failure too. Every group uses rows of its own, and gives its times explicitly where
-- the rule does not depend on now; in particular two statements about the same posit get positing times of their own,
-- since statements in a row can get the same sysdatetime(). Everything is stated by positor 0 unless a check says
-- otherwise.
-- The rules are in Anchor's docs/ANCHOR.md, "Loading through the latest views".
SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result;
IF OBJECT_ID('tempdb..#group') IS NOT NULL DROP TABLE #group;
CREATE TABLE #result (id int IDENTITY(1,1) PRIMARY KEY, test nvarchar(400) NOT NULL, passed bit NOT NULL, detail nvarchar(2048) NULL);
CREATE TABLE #group (name char(3) PRIMARY KEY, finished bit NOT NULL DEFAULT 0);
INSERT INTO #group (name) VALUES ('c01'), ('c02'), ('c03'), ('c04'), ('c05'), ('c06'), ('c07'), ('c08'), ('c09'), ('c10'), ('c11'), ('c12'), ('c13'), ('c14'), ('c15'), ('c16'), ('c17'), ('c18'), ('c19'), ('c20'), ('c21'), ('c22'), ('c23'), ('c24'), ('c25'), ('c26'), ('c27'), ('c28');
INSERT INTO dbo.GRD_Grade (GRD_ID, GRD_Grade, Metadata_GRD) VALUES (1, N'A', 0), (2, N'B', 0), (3, N'C', 0);
GO

-- c01 an insert through the latest view: a posit and an assertion for each value
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
SET @assertions = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex a JOIN dbo.SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID WHERE p.SU_TTL_SU_ID = @s AND a.SU_TTL_Positor = 0);
INSERT INTO #result SELECT N'c01 an insert through the latest view stores a posit for each value', CASE WHEN @posits = 12 AND @assertions = 1 THEN 1 ELSE 0 END, CONCAT(@posits, ' posits, expected 12; ', @assertions, ' assertions of the title by positor 0');
UPDATE #group SET finished = 1 WHERE name = 'c01';
GO

-- c02 an update that leaves every value and reliability as it is states nothing (State is not restatable: this
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
    WHERE SU_ID = @s AND Positor = 0;
    UPDATE dbo.lSU_Subject SET SU_GRD_GRD_Grade = SU_GRD_GRD_Grade, Reliability = 1 WHERE SU_ID = @s AND Positor = 0;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @after = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex) + (SELECT COUNT(*) FROM dbo.SU_GRD_Subject_Grade_Annex) + (SELECT COUNT(*) FROM dbo.SU_NOT_Subject_Note_Annex)
       + (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex) + (SELECT COUNT(*) FROM dbo.SU_STA_Subject_State_Annex) + (SELECT COUNT(*) FROM dbo.SU_LVL_Subject_Level_Annex)
       + (SELECT COUNT(*) FROM dbo.SU_TXT_Subject_Text_Annex);
INSERT INTO #result SELECT N'c02 an update that leaves everything as it is states nothing', CASE WHEN @error IS NULL AND @after = @before THEN 1 ELSE 0 END, CONCAT(@after - @before, ' new assertions', ' ' + @error);
UPDATE #group SET finished = 1 WHERE name = 'c02';
GO

-- c03 a new value of a historized attribute is a new version from now
DECLARE @s int, @n int, @shown nvarchar(42), @changed datetime2;
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt) VALUES (0, N'first', '2020-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N'second' WHERE SU_ID = @s AND Positor = 0;
SELECT @shown = SU_TTL_Subject_Title, @changed = SU_TTL_ChangedAt FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Posit WHERE SU_TTL_SU_ID = @s);
INSERT INTO #result SELECT N'c03 a new value is a new version from now', CASE WHEN @n = 2 AND @shown = N'second' AND @changed > '2025-01-01' THEN 1 ELSE 0 END, CONCAT(@n, ' posits, shown ', @shown, ' from ', @changed);
UPDATE #group SET finished = 1 WHERE name = 'c03';
GO

-- c04 the same value with a changing time of its own is a restatement, and the settings decide (in crt the check of
--     an attribute that is not restatable is a constraint on the annex)
DECLARE @s int, @n int, @error nvarchar(2048);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_STA_Subject_State, SU_STA_ChangedAt,
    SU_LBL_Subject_Label, SU_LBL_ChangedAt, SU_TAG_Subject_Tag, SU_TAG_ChangedAt, SU_LVL_GRD_ID, SU_LVL_ChangedAt, SU_TXT_Subject_Text, SU_TXT_ChangedAt)
VALUES (0, N'x', '2020-01-01', N'x', '2020-01-01', N'x', '2020-01-01', N'x', '2020-01-01', 1, '2020-01-01', N'x', '2020-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N'x', SU_TTL_ChangedAt = '2021-01-01' WHERE SU_ID = @s AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Posit WHERE SU_TTL_SU_ID = @s);
INSERT INTO #result SELECT N'c04 restatable: a restatement is stored', CASE WHEN @n = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' posits, expected 2');
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lSU_Subject SET SU_STA_Subject_State = N'x', SU_STA_ChangedAt = '2021-01-01' WHERE SU_ID = @s AND Positor = 0;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.SU_STA_Subject_State_Posit WHERE SU_STA_SU_ID = @s);
INSERT INTO #result SELECT N'c04 not restatable: a restatement is an error', CASE WHEN @error LIKE N'%rcSU_STA_Subject_State_Annex%' AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' posits; ', ISNULL(@error, 'no error'));
UPDATE dbo.lSU_Subject SET SU_LBL_Subject_Label = N'x', SU_LBL_ChangedAt = '2021-01-01' WHERE SU_ID = @s AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_LBL_Subject_Label_Posit WHERE SU_LBL_SU_ID = @s);
INSERT INTO #result SELECT N'c04 not restatable, idempotent: a restatement is skipped', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' posits, expected 1');
UPDATE dbo.lSU_Subject SET SU_TAG_Subject_Tag = N'x', SU_TAG_ChangedAt = '2021-01-01' WHERE SU_ID = @s AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TAG_Subject_Tag_Posit WHERE SU_TAG_SU_ID = @s);
INSERT INTO #result SELECT N'c04 restatable, idempotent: a restatement is skipped', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' posits, expected 1');
UPDATE dbo.lSU_Subject SET SU_LVL_GRD_ID = 1, SU_LVL_ChangedAt = '2021-01-01' WHERE SU_ID = @s AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_LVL_Subject_Level_Posit WHERE SU_LVL_SU_ID = @s);
INSERT INTO #result SELECT N'c04 knotted, restatable: a restatement is stored', CASE WHEN @n = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' posits, expected 2');
UPDATE dbo.lSU_Subject SET SU_TXT_Subject_Text = N'x', SU_TXT_ChangedAt = '2021-01-01' WHERE SU_ID = @s AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TXT_Subject_Text_Posit WHERE SU_TXT_SU_ID = @s);
INSERT INTO #result SELECT N'c04 with a checksum, restatable: a restatement is stored', CASE WHEN @n = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' posits, expected 2');
UPDATE #group SET finished = 1 WHERE name = 'c04';
GO

-- c05 another static value is a correction (a value-only update used to be ignored); the same states nothing
DECLARE @s int, @before int, @after int, @name nvarchar(42), @code nvarchar(42), @grade tinyint, @note nvarchar(max);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_NAM_PositedAt, SU_COD_Subject_Code, SU_COD_PositedAt, SU_GRD_GRD_ID, SU_GRD_PositedAt, SU_NOT_Subject_Note, SU_NOT_PositedAt)
VALUES (0, N'n1', '2024-01-01', N'c1', '2024-01-01', 1, '2024-01-01', N'note one', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
SET @before = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex) + (SELECT COUNT(*) FROM dbo.SU_COD_Subject_Code_Annex) + (SELECT COUNT(*) FROM dbo.SU_GRD_Subject_Grade_Annex) + (SELECT COUNT(*) FROM dbo.SU_NOT_Subject_Note_Annex);
UPDATE dbo.lSU_Subject SET SU_NAM_Subject_Name = N'n1', SU_COD_Subject_Code = N'c1', SU_GRD_GRD_Grade = N'A', SU_NOT_Subject_Note = N'note one' WHERE SU_ID = @s AND Positor = 0;
SET @after = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex) + (SELECT COUNT(*) FROM dbo.SU_COD_Subject_Code_Annex) + (SELECT COUNT(*) FROM dbo.SU_GRD_Subject_Grade_Annex) + (SELECT COUNT(*) FROM dbo.SU_NOT_Subject_Note_Annex);
INSERT INTO #result SELECT N'c05 the same static value states nothing', CASE WHEN @after = @before THEN 1 ELSE 0 END, CONCAT(@after - @before, ' new assertions');
UPDATE dbo.lSU_Subject SET SU_NAM_Subject_Name = N'n2', SU_COD_Subject_Code = N'c2', SU_GRD_GRD_Grade = N'B', SU_NOT_Subject_Note = N'note two',
    SU_NAM_PositedAt = '2024-02-01', SU_COD_PositedAt = '2024-02-01', SU_GRD_PositedAt = '2024-02-01', SU_NOT_PositedAt = '2024-02-01' WHERE SU_ID = @s AND Positor = 0;
SELECT @name = SU_NAM_Subject_Name, @code = SU_COD_Subject_Code, @grade = SU_GRD_GRD_ID, @note = SU_NOT_Subject_Note FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0;
INSERT INTO #result SELECT N'c05 another static value is a correction', CASE WHEN @name = N'n2' AND @code = N'c2' AND @grade = 2 AND @note = N'note two' THEN 1 ELSE 0 END, CONCAT('shown ', @name, ', ', @code, ', ', @grade, ', ', @note);
UPDATE #group SET finished = 1 WHERE name = 'c05';
GO

-- c06 the shown value asserted again at a positing time of its own: stored when assertive, skipped when not
DECLARE @s int, @title int, @assessment int;
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_ASR_Subject_Assessment, SU_ASR_ChangedAt, SU_ASR_PositedAt)
VALUES (0, N't', '2020-01-01', '2024-01-01', N'a', '2020-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N't', SU_TTL_PositedAt = '2024-06-01', SU_ASR_Subject_Assessment = N'a', SU_ASR_PositedAt = '2024-06-01' WHERE SU_ID = @s AND Positor = 0;
SET @title = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex a JOIN dbo.SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID WHERE p.SU_TTL_SU_ID = @s);
SET @assessment = (SELECT COUNT(*) FROM dbo.SU_ASR_Subject_Assessment_Annex a JOIN dbo.SU_ASR_Subject_Assessment_Posit p ON p.SU_ASR_ID = a.SU_ASR_ID WHERE p.SU_ASR_SU_ID = @s);
INSERT INTO #result SELECT N'c06 assertive: a re-assertion is stored', CASE WHEN @title = 2 THEN 1 ELSE 0 END, CONCAT(@title, ' assertions, expected 2');
INSERT INTO #result SELECT N'c06 not assertive: a re-assertion is skipped', CASE WHEN @assessment = 1 THEN 1 ELSE 0 END, CONCAT(@assessment, ' assertions, expected 1');
UPDATE #group SET finished = 1 WHERE name = 'c06';
GO

-- c07 not assertive: A, then B, then A again at the same changing time shows A
DECLARE @s int, @shown nvarchar(42);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_ASR_Subject_Assessment, SU_ASR_ChangedAt, SU_ASR_PositedAt) VALUES (0, N'A', '2020-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_ASR_Subject_Assessment = N'B', SU_ASR_ChangedAt = '2020-01-01', SU_ASR_PositedAt = '2024-02-01' WHERE SU_ID = @s AND Positor = 0;
SET @shown = (SELECT SU_ASR_Subject_Assessment FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'c07 a value at the same changing time corrects the shown one', CASE WHEN @shown = N'B' THEN 1 ELSE 0 END, CONCAT('shown ', @shown);
UPDATE dbo.lSU_Subject SET SU_ASR_Subject_Assessment = N'A', SU_ASR_ChangedAt = '2020-01-01', SU_ASR_PositedAt = '2024-03-01' WHERE SU_ID = @s AND Positor = 0;
SET @shown = (SELECT SU_ASR_Subject_Assessment FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'c07 not assertive: switching back to an earlier value is stored', CASE WHEN @shown = N'A' THEN 1 ELSE 0 END, CONCAT('shown ', @shown, ', expected A');
UPDATE #group SET finished = 1 WHERE name = 'c07';
GO

-- c08 reliabilities: unchanged states nothing; another one re-rates the shown version at its own changing time
--     (through the attribute's own column that used to make a new version at now); 0 retracts it, through either
--     column
DECLARE @s int, @t int, @shown nvarchar(42), @reliability decimal(5,2), @changed datetime2, @posits int, @before int, @after int;
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt) VALUES (0, N'x', '2020-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N'y', SU_TTL_ChangedAt = '2021-01-01', SU_TTL_PositedAt = '2024-02-01' WHERE SU_ID = @s AND Positor = 0;
SET @before = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex);
UPDATE dbo.lSU_Subject SET Reliability = 1 WHERE SU_ID = @s AND Positor = 0;
SET @after = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex);
INSERT INTO #result SELECT N'c08 an unchanged reliability states nothing', CASE WHEN @after = @before THEN 1 ELSE 0 END, CONCAT(@after - @before, ' new assertions');
UPDATE dbo.lSU_Subject SET SU_TTL_Reliability = 0.5, SU_TTL_PositedAt = '2024-03-01' WHERE SU_ID = @s AND Positor = 0;
SELECT @shown = SU_TTL_Subject_Title, @reliability = SU_TTL_Reliability, @changed = SU_TTL_ChangedAt FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0;
SET @posits = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Posit WHERE SU_TTL_SU_ID = @s);
INSERT INTO #result SELECT N'c08 another reliability re-rates the shown version', CASE WHEN @shown = N'y' AND @reliability = 0.5 AND @changed = '2021-01-01' AND @posits = 2 THEN 1 ELSE 0 END, CONCAT('shown ', @shown, ' with ', @reliability, ' from ', @changed, '; ', @posits, ' posits');
UPDATE dbo.lSU_Subject SET SU_TTL_Reliability = 0, SU_TTL_PositedAt = '2024-04-01' WHERE SU_ID = @s AND Positor = 0;
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'c08 reliability 0 in the attribute''s own column retracts the shown version', CASE WHEN @shown = N'x' THEN 1 ELSE 0 END, CONCAT('shown ', @shown, ', expected x');
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_STA_Subject_State, SU_STA_ChangedAt, SU_STA_PositedAt) VALUES (0, N's', '2020-01-01', '2024-01-01');
SET @t = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET Reliability = 0, SU_STA_PositedAt = '2024-02-01' WHERE SU_ID = @t AND Positor = 0;
SET @shown = (SELECT SU_STA_Subject_State FROM dbo.lSU_Subject WHERE SU_ID = @t AND Positor = 0);
INSERT INTO #result SELECT N'c08 reliability 0 in the Reliability column retracts the shown version', CASE WHEN @shown IS NULL THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'));
UPDATE #group SET finished = 1 WHERE name = 'c08';
GO

-- c09 null retracts the shown version; a value after that is a new version
DECLARE @s int, @shown nvarchar(42);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt) VALUES (0, N'x', '2020-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = NULL, SU_TTL_PositedAt = '2024-02-01' WHERE SU_ID = @s AND Positor = 0;
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'c09 null retracts the shown version', CASE WHEN @shown IS NULL THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'));
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N'y' WHERE SU_ID = @s AND Positor = 0;
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'c09 a value after a retraction is stated', CASE WHEN @shown = N'y' THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'));
UPDATE #group SET finished = 1 WHERE name = 'c09';
GO

-- c10 a delete retracts each shown posit once, also one asserted twice (that used to collide on the annex key)
DECLARE @s int, @title nvarchar(42), @name nvarchar(42), @error nvarchar(2048);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt) VALUES (0, N'n', N't', '2020-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N't', SU_TTL_PositedAt = '2024-06-01' WHERE SU_ID = @s AND Positor = 0;
BEGIN TRY
    DELETE FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SELECT @title = SU_TTL_Subject_Title, @name = SU_NAM_Subject_Name FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0;
INSERT INTO #result SELECT N'c10 a delete retracts the shown posits', CASE WHEN @error IS NULL AND @title IS NULL AND @name IS NULL THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@title, 'nothing'), ' and ', ISNULL(@name, 'nothing'), ' ' + @error);
UPDATE #group SET finished = 1 WHERE name = 'c10';
GO

-- c11 the same assertion inserted twice straight into the assembled view is ignored the second time (the attribute
--     is assertive, which used to insert it again and collide on the annex key)
DECLARE @s int, @n int, @error nvarchar(2048);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
BEGIN TRY
    INSERT INTO dbo.SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Positor, SU_TTL_Reliability) VALUES (0, @s, N't', '2020-01-01', '2024-01-01', 0, 1);
    INSERT INTO dbo.SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Positor, SU_TTL_Reliability) VALUES (0, @s, N't', '2020-01-01', '2024-01-01', 0, 1);
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex a JOIN dbo.SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID WHERE p.SU_TTL_SU_ID = @s);
INSERT INTO #result SELECT N'c11 the identical inserted again is ignored', CASE WHEN @error IS NULL AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' assertions', ' ' + @error);
UPDATE #group SET finished = 1 WHERE name = 'c11';
GO

-- c12 idempotent, out of order: an earlier version with the same value as the next one keeps the earlier start (the
--     earlier one used to be dropped)
DECLARE @s int, @changed datetime2;
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
INSERT INTO dbo.SU_LBL_Subject_Label (Metadata_SU_LBL, SU_LBL_SU_ID, SU_LBL_Subject_Label, SU_LBL_ChangedAt, SU_LBL_PositedAt, SU_LBL_Positor, SU_LBL_Reliability) VALUES (0, @s, N'x', '2021-01-01', '2024-01-01', 0, 1);
INSERT INTO dbo.SU_LBL_Subject_Label (Metadata_SU_LBL, SU_LBL_SU_ID, SU_LBL_Subject_Label, SU_LBL_ChangedAt, SU_LBL_PositedAt, SU_LBL_Positor, SU_LBL_Reliability) VALUES (0, @s, N'x', '2020-01-01', '2024-02-01', 0, 1);
SET @changed = (SELECT SU_LBL_ChangedAt FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'c12 idempotent: the value counts from the earlier time', CASE WHEN @changed = '2020-01-01' THEN 1 ELSE 0 END, CONCAT('shown from ', @changed);
UPDATE #group SET finished = 1 WHERE name = 'c12';
GO

-- c13 a second positor: an update of its row is its statement (a row without a value used to fall back to positor 0),
--     the other positor is not affected, and a delete of its row retracts only its own posits
DECLARE @s int, @shown nvarchar(42), @positor tinyint, @error nvarchar(2048);
IF NOT EXISTS (SELECT 1 FROM dbo._Positor WHERE Positor = 1) INSERT INTO dbo._Positor (Positor) VALUES (1);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt) VALUES (0, N'zero', '2020-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N'one', SU_TTL_ChangedAt = '2021-01-01', SU_TTL_PositedAt = '2024-01-01' WHERE SU_ID = @s AND Positor = 1;
SELECT @shown = SU_TTL_Subject_Title, @positor = SU_TTL_Positor FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 1;
INSERT INTO #result SELECT N'c13 an update of a positor''s row is its statement', CASE WHEN @shown = N'one' AND @positor = 1 THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'), ' by ', ISNULL(CAST(@positor AS varchar), 'nobody'));
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'c13 the other positor is not affected', CASE WHEN @shown = N'zero' THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'), ', expected zero');
BEGIN TRY
    DELETE FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 1;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 1);
INSERT INTO #result SELECT N'c13 a delete retracts the posits of the positor of the row', CASE WHEN @error IS NULL AND @shown IS NULL THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'), ' ' + @error);
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'c13 and not those of the other positors', CASE WHEN @shown = N'zero' THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'), ', expected zero');
UPDATE #group SET finished = 1 WHERE name = 'c13';
GO

-- c14 ties
DECLARE @s1 int, @s2 int, @o int, @o2 int, @n int, @shown nvarchar(42), @owner int, @positor tinyint, @error nvarchar(2048);
IF NOT EXISTS (SELECT 1 FROM dbo._Positor WHERE Positor = 1) INSERT INTO dbo._Positor (Positor) VALUES (1);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s1 = SCOPE_IDENTITY();
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s2 = SCOPE_IDENTITY();
INSERT INTO dbo.OB_Object (Metadata_OB) VALUES (0); SET @o = SCOPE_IDENTITY();
INSERT INTO dbo.OB_Object (Metadata_OB) VALUES (0); SET @o2 = SCOPE_IDENTITY();
-- historized, with identifiers and a value
INSERT INTO dbo.lSU_holder_OB_item_GRD_grade (Metadata_SU_holder_OB_item_GRD_grade, SU_holder_OB_item_GRD_grade_ChangedAt, SU_holder_OB_item_GRD_grade_PositedAt, SU_ID_holder, OB_ID_item, GRD_ID_grade)
VALUES (0, '2020-01-01', '2024-01-01', @s1, @o, 1);
UPDATE dbo.lSU_holder_OB_item_GRD_grade SET GRD_ID_grade = 1 WHERE SU_ID_holder = @s1 AND OB_ID_item = @o AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_holder_OB_item_GRD_grade_Annex a JOIN dbo.SU_holder_OB_item_GRD_grade_Posit p ON p.SU_holder_OB_item_GRD_grade_ID = a.SU_holder_OB_item_GRD_grade_ID WHERE p.SU_ID_holder = @s1 AND p.OB_ID_item = @o);
INSERT INTO #result SELECT N'c14 a tie: unchanged values state nothing', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' assertions, expected 1');
UPDATE dbo.lSU_holder_OB_item_GRD_grade SET grade_GRD_Grade = N'B', SU_holder_OB_item_GRD_grade_ChangedAt = '2021-01-01', SU_holder_OB_item_GRD_grade_PositedAt = '2024-02-01' WHERE SU_ID_holder = @s1 AND OB_ID_item = @o AND Positor = 0;
SET @shown = (SELECT grade_GRD_Grade FROM dbo.lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = @s1 AND OB_ID_item = @o AND Positor = 0);
INSERT INTO #result SELECT N'c14 a tie: a new value by knot value is a new version', CASE WHEN @shown = N'B' THEN 1 ELSE 0 END, CONCAT('shown ', @shown);
BEGIN TRY
    UPDATE dbo.lSU_holder_OB_item_GRD_grade SET GRD_ID_grade = NULL, SU_holder_OB_item_GRD_grade_PositedAt = '2024-03-01' WHERE SU_ID_holder = @s1 AND OB_ID_item = @o AND Positor = 0;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @shown = (SELECT grade_GRD_Grade FROM dbo.lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = @s1 AND OB_ID_item = @o AND Positor = 0);
INSERT INTO #result SELECT N'c14 a tie: null retracts the shown version (it used to fail)', CASE WHEN @error IS NULL AND @shown = N'A' THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'), ', expected A', ' ' + @error);
UPDATE dbo.lSU_holder_OB_item_GRD_grade SET SU_holder_OB_item_GRD_grade_Reliability = 0 WHERE SU_ID_holder = @s1 AND OB_ID_item = @o AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = @s1 AND OB_ID_item = @o AND Positor = 0);
INSERT INTO #result SELECT N'c14 a tie: reliability 0 retracts the shown version', CASE WHEN @n = 0 THEN 1 ELSE 0 END, CONCAT(@n, ' shown, expected 0');
-- by positor 1: an insert that gives only Positor, and an update of its row
INSERT INTO dbo.lSU_holder_OB_item_GRD_grade (Positor, Metadata_SU_holder_OB_item_GRD_grade, SU_holder_OB_item_GRD_grade_ChangedAt, SU_ID_holder, OB_ID_item, GRD_ID_grade)
VALUES (1, 0, '2020-01-01', @s1, @o2, 1);
SET @positor = (SELECT SU_holder_OB_item_GRD_grade_Positor FROM dbo.lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = @s1 AND OB_ID_item = @o2 AND Positor = 1);
INSERT INTO #result SELECT N'c14 a tie inserted with only Positor given is that positor''s statement (it used to be positor 0''s)', CASE WHEN @positor = 1 THEN 1 ELSE 0 END, CONCAT('by ', ISNULL(CAST(@positor AS varchar), 'nobody'));
UPDATE dbo.lSU_holder_OB_item_GRD_grade SET GRD_ID_grade = 2, SU_holder_OB_item_GRD_grade_ChangedAt = '2021-01-01' WHERE SU_ID_holder = @s1 AND OB_ID_item = @o2 AND Positor = 1;
SET @n = (SELECT COUNT(*) FROM dbo.SU_holder_OB_item_GRD_grade_Annex a JOIN dbo.SU_holder_OB_item_GRD_grade_Posit p ON p.SU_holder_OB_item_GRD_grade_ID = a.SU_holder_OB_item_GRD_grade_ID WHERE p.OB_ID_item = @o2 AND a.SU_holder_OB_item_GRD_grade_Positor = 0);
SET @shown = (SELECT grade_GRD_Grade FROM dbo.lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = @s1 AND OB_ID_item = @o2 AND Positor = 1);
INSERT INTO #result SELECT N'c14 an update of a positor''s tie row is its statement (it used to be positor 0''s)', CASE WHEN @shown = N'B' AND @n = 0 THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'), ', ', @n, ' assertions by positor 0');
-- historized, not assertive
INSERT INTO dbo.lSU_keeper_OB_thing_GRD_rank (Metadata_SU_keeper_OB_thing_GRD_rank, SU_keeper_OB_thing_GRD_rank_ChangedAt, SU_keeper_OB_thing_GRD_rank_PositedAt, SU_ID_keeper, OB_ID_thing, GRD_ID_rank)
VALUES (0, '2020-01-01', '2024-01-01', @s1, @o, 1);
UPDATE dbo.lSU_keeper_OB_thing_GRD_rank SET GRD_ID_rank = 1, SU_keeper_OB_thing_GRD_rank_PositedAt = '2024-06-01' WHERE SU_ID_keeper = @s1 AND OB_ID_thing = @o AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_keeper_OB_thing_GRD_rank_Annex a JOIN dbo.SU_keeper_OB_thing_GRD_rank_Posit p ON p.SU_keeper_OB_thing_GRD_rank_ID = a.SU_keeper_OB_thing_GRD_rank_ID WHERE p.SU_ID_keeper = @s1 AND p.OB_ID_thing = @o);
INSERT INTO #result SELECT N'c14 a tie that is not assertive: a re-assertion is skipped', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' assertions, expected 1');
-- static, with an identifier and a value
INSERT INTO dbo.lOB_part_SU_owner (Metadata_OB_part_SU_owner, OB_part_SU_owner_PositedAt, OB_ID_part, SU_ID_owner) VALUES (0, '2024-01-01', @o, @s1);
UPDATE dbo.lOB_part_SU_owner SET SU_ID_owner = @s2 WHERE OB_ID_part = @o AND Positor = 0;
SET @owner = (SELECT SU_ID_owner FROM dbo.lOB_part_SU_owner WHERE OB_ID_part = @o AND Positor = 0);
INSERT INTO #result SELECT N'c14 a static tie: another value is a correction', CASE WHEN @owner = @s2 THEN 1 ELSE 0 END, CONCAT('shown owner ', @owner);
-- historized, without identifiers
INSERT INTO dbo.lSU_partner_SU_with (Metadata_SU_partner_SU_with, SU_partner_SU_with_ChangedAt, SU_ID_partner, SU_ID_with) VALUES (0, '2020-01-01', @s1, @s2);
UPDATE dbo.lSU_partner_SU_with SET SU_ID_with = @s2 WHERE SU_ID_partner = @s1 AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_partner_SU_with_Annex a JOIN dbo.SU_partner_SU_with_Posit p ON p.SU_partner_SU_with_ID = a.SU_partner_SU_with_ID WHERE p.SU_ID_partner = @s1);
INSERT INTO #result SELECT N'c14 a tie without identifiers: unchanged values state nothing', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' assertions, expected 1');
UPDATE #group SET finished = 1 WHERE name = 'c14';
GO

-- c15 a nexus with an attribute, through its latest view (it used to fail: there was no assembled view, and the
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
INSERT INTO #result SELECT N'c15 a nexus with an attribute through its latest view', CASE WHEN @error IS NULL AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' values', ' ' + @error);
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
INSERT INTO #result SELECT N'c15 several new nexus rows in one insert keep their own values', CASE WHEN @error IS NULL AND @made = 3 AND @matched = 3 THEN 1 ELSE 0 END, CONCAT(@made, ' rows, ', @matched, ' with their own values', ' ' + @error);
UPDATE #group SET finished = 1 WHERE name = 'c15';
GO

-- c16 a posit asserted again by a positor at a positing time that already has an assertion of it by that positor: the
--     same reliability states nothing, another one is a contradiction (it used to be skipped as if it were the
--     identical)
DECLARE @s int, @o int, @n int, @shown nvarchar(42), @error nvarchar(2048);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt) VALUES (0, N'x', '2020-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N'x', SU_TTL_PositedAt = '2024-01-01' WHERE SU_ID = @s AND Positor = 0;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex a JOIN dbo.SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID WHERE p.SU_TTL_SU_ID = @s);
INSERT INTO #result SELECT N'c16 the same reliability at a positing time that is taken states nothing', CASE WHEN @error IS NULL AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' assertions', ' ' + @error);
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lSU_Subject SET SU_TTL_Reliability = 0, SU_TTL_PositedAt = '2024-01-01' WHERE SU_ID = @s AND Positor = 0;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'c16 another reliability at a positing time that is taken is a contradiction', CASE WHEN @error LIKE N'Contradiction in SU_TTL_Subject_Title%' AND @shown = N'x' THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'), '; ', ISNULL(@error, 'no error'));
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
INSERT INTO dbo.OB_Object (Metadata_OB) VALUES (0); SET @o = SCOPE_IDENTITY();
INSERT INTO dbo.lSU_holder_OB_item_GRD_grade (Metadata_SU_holder_OB_item_GRD_grade, SU_holder_OB_item_GRD_grade_ChangedAt, SU_holder_OB_item_GRD_grade_PositedAt, SU_ID_holder, OB_ID_item, GRD_ID_grade)
VALUES (0, '2020-01-01', '2024-01-01', @s, @o, 1);
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lSU_holder_OB_item_GRD_grade SET SU_holder_OB_item_GRD_grade_Reliability = 0, SU_holder_OB_item_GRD_grade_PositedAt = '2024-01-01' WHERE SU_ID_holder = @s AND OB_ID_item = @o AND Positor = 0;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = @s AND OB_ID_item = @o AND Positor = 0);
INSERT INTO #result SELECT N'c16 a tie: another reliability at a positing time that is taken is a contradiction', CASE WHEN @error LIKE N'Contradiction in SU_holder_OB_item_GRD_grade%' AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' shown; ', ISNULL(@error, 'no error'));
UPDATE #group SET finished = 1 WHERE name = 'c16';
GO

-- c17 decisive: another value at the same changing time is a correction, which retracts what it corrects at its own
--     positing time, so retracting the correction leaves nothing of the corrected value in effect (it used to come
--     back)
DECLARE @s int, @n int, @shown nvarchar(42);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_NAM_PositedAt) VALUES (0, N'n1', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_NAM_Subject_Name = N'n2', SU_NAM_PositedAt = '2024-02-01' WHERE SU_ID = @s AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex a JOIN dbo.SU_NAM_Subject_Name_Posit p ON p.SU_NAM_ID = a.SU_NAM_ID
    WHERE p.SU_NAM_SU_ID = @s AND p.SU_NAM_Subject_Name = N'n1' AND a.SU_NAM_Positor = 0 AND a.SU_NAM_PositedAt = '2024-02-01' AND a.SU_NAM_Reliability = 0);
INSERT INTO #result SELECT N'c17 a static correction retracts the corrected posit at its positing time', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' retractions of n1, expected 1');
UPDATE dbo.lSU_Subject SET SU_NAM_Reliability = 0, SU_NAM_PositedAt = '2024-03-01' WHERE SU_ID = @s AND Positor = 0;
SET @shown = (SELECT SU_NAM_Subject_Name FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'c17 retracting a static correction leaves nothing in effect', CASE WHEN @shown IS NULL THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'));
-- historized: a value at the changing time of the shown version corrects it, and only it
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt) VALUES (0, N'early', '2019-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N't1', SU_TTL_ChangedAt = '2020-01-01', SU_TTL_PositedAt = '2024-02-01' WHERE SU_ID = @s AND Positor = 0;
UPDATE dbo.lSU_Subject SET SU_TTL_Subject_Title = N't2', SU_TTL_ChangedAt = '2020-01-01', SU_TTL_PositedAt = '2024-03-01' WHERE SU_ID = @s AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TTL_Subject_Title_Annex a JOIN dbo.SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID
    WHERE p.SU_TTL_SU_ID = @s AND a.SU_TTL_Reliability = 0);
INSERT INTO #result SELECT N'c17 a historized correction retracts the version it corrects and no other', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' retractions, expected 1');
UPDATE dbo.lSU_Subject SET SU_TTL_Reliability = 0, SU_TTL_PositedAt = '2024-04-01' WHERE SU_ID = @s AND Positor = 0;
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'c17 retracting a historized correction shows the version before it', CASE WHEN @shown = N'early' THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'), ', expected early');
-- knotted, by the value of the knot, and with a checksum
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_GRD_GRD_ID, SU_GRD_PositedAt, SU_NOT_Subject_Note, SU_NOT_PositedAt) VALUES (0, 1, '2024-01-01', N'note one', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_GRD_GRD_Grade = N'B', SU_GRD_PositedAt = '2024-02-01', SU_NOT_Subject_Note = N'note two', SU_NOT_PositedAt = '2024-02-01' WHERE SU_ID = @s AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_GRD_Subject_Grade_Annex a JOIN dbo.SU_GRD_Subject_Grade_Posit p ON p.SU_GRD_ID = a.SU_GRD_ID
        WHERE p.SU_GRD_SU_ID = @s AND p.SU_GRD_GRD_ID = 1 AND a.SU_GRD_PositedAt = '2024-02-01' AND a.SU_GRD_Reliability = 0)
    + (SELECT COUNT(*) FROM dbo.SU_NOT_Subject_Note_Annex a JOIN dbo.SU_NOT_Subject_Note_Posit p ON p.SU_NOT_ID = a.SU_NOT_ID
        WHERE p.SU_NOT_SU_ID = @s AND p.SU_NOT_Subject_Note = N'note one' AND a.SU_NOT_PositedAt = '2024-02-01' AND a.SU_NOT_Reliability = 0);
INSERT INTO #result SELECT N'c17 a correction of a knotted attribute and of one with a checksum retracts the corrected posits', CASE WHEN @n = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' retractions, expected 2');
UPDATE #group SET finished = 1 WHERE name = 'c17';
GO

-- c18 decisive: a positive assertion retracts what the same positor held before it, also within one insert into the
--     assembled view, and leaves the other positors alone; a value that two positors state in one insert is one posit
--     (it used to be made twice, which broke the key of the posit table)
DECLARE @s int, @n int, @zero int, @shown nvarchar(42), @other nvarchar(42), @error nvarchar(2048);
IF NOT EXISTS (SELECT 1 FROM dbo._Positor WHERE Positor = 1) INSERT INTO dbo._Positor (Positor) VALUES (1);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
BEGIN TRY
    INSERT INTO dbo.SU_NAM_Subject_Name (Metadata_SU_NAM, SU_NAM_SU_ID, SU_NAM_Subject_Name, SU_NAM_PositedAt, SU_NAM_Positor, SU_NAM_Reliability)
    VALUES (0, @s, N'a', '2024-01-01', 0, 1), (0, @s, N'a', '2024-01-01', 1, 1), (0, @s, N'b', '2024-02-01', 1, 1);
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex a JOIN dbo.SU_NAM_Subject_Name_Posit p ON p.SU_NAM_ID = a.SU_NAM_ID
    WHERE p.SU_NAM_SU_ID = @s AND p.SU_NAM_Subject_Name = N'a' AND a.SU_NAM_Positor = 1 AND a.SU_NAM_PositedAt = '2024-02-01' AND a.SU_NAM_Reliability = 0);
SET @zero = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex a JOIN dbo.SU_NAM_Subject_Name_Posit p ON p.SU_NAM_ID = a.SU_NAM_ID
    WHERE p.SU_NAM_SU_ID = @s AND a.SU_NAM_Reliability = 0 AND a.SU_NAM_Positor = 0);
SET @shown = (SELECT SU_NAM_Subject_Name FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 1);
SET @other = (SELECT SU_NAM_Subject_Name FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'c18 a later value in the same insert retracts the earlier one of its positor, and only of its positor', CASE WHEN @error IS NULL AND @n = 1 AND @zero = 0 AND @shown = N'b' AND @other = N'a' THEN 1 ELSE 0 END,
    CONCAT(@n, ' retractions of a by positor 1, ', @zero, ' by positor 0; shown ', ISNULL(@shown, 'nothing'), ' and ', ISNULL(@other, 'nothing'), ' ' + @error);
INSERT INTO dbo.SU_NAM_Subject_Name (Metadata_SU_NAM, SU_NAM_SU_ID, SU_NAM_Subject_Name, SU_NAM_PositedAt, SU_NAM_Positor, SU_NAM_Reliability)
VALUES (0, @s, N'a', '2024-03-01', 1, 1);
SET @n = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex a JOIN dbo.SU_NAM_Subject_Name_Posit p ON p.SU_NAM_ID = a.SU_NAM_ID
    WHERE p.SU_NAM_SU_ID = @s AND p.SU_NAM_Subject_Name = N'b' AND a.SU_NAM_Positor = 1 AND a.SU_NAM_PositedAt = '2024-03-01' AND a.SU_NAM_Reliability = 0);
SET @shown = (SELECT SU_NAM_Subject_Name FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 1);
INSERT INTO #result SELECT N'c18 asserting an earlier value again retracts the one held since', CASE WHEN @n = 1 AND @shown = N'a' THEN 1 ELSE 0 END, CONCAT(@n, ' retractions of b; shown ', ISNULL(@shown, 'nothing'));
UPDATE #group SET finished = 1 WHERE name = 'c18';
GO

-- c19 decisive ties: other values of a static tie are a correction, which retracts what it corrects; one insert may
--     have two positors, or two versions, of the same tie (that used to break the key of the trigger's own table)
DECLARE @s1 int, @s2 int, @o int, @n int, @owner int, @other int, @error nvarchar(2048);
IF NOT EXISTS (SELECT 1 FROM dbo._Positor WHERE Positor = 1) INSERT INTO dbo._Positor (Positor) VALUES (1);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s1 = SCOPE_IDENTITY();
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s2 = SCOPE_IDENTITY();
INSERT INTO dbo.OB_Object (Metadata_OB) VALUES (0); SET @o = SCOPE_IDENTITY();
BEGIN TRY
    INSERT INTO dbo.OB_part_SU_owner (Metadata_OB_part_SU_owner, OB_ID_part, SU_ID_owner, OB_part_SU_owner_PositedAt, OB_part_SU_owner_Positor, OB_part_SU_owner_Reliability)
    VALUES (0, @o, @s1, '2024-01-01', 0, 1), (0, @o, @s1, '2024-01-01', 1, 1), (0, @o, @s2, '2024-02-01', 1, 1);
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @owner = (SELECT SU_ID_owner FROM dbo.lOB_part_SU_owner WHERE OB_ID_part = @o AND Positor = 1);
SET @other = (SELECT SU_ID_owner FROM dbo.lOB_part_SU_owner WHERE OB_ID_part = @o AND Positor = 0);
SET @n = (SELECT COUNT(*) FROM dbo.OB_part_SU_owner_Annex a JOIN dbo.OB_part_SU_owner_Posit p ON p.OB_part_SU_owner_ID = a.OB_part_SU_owner_ID
    WHERE p.OB_ID_part = @o AND p.SU_ID_owner = @s1 AND a.OB_part_SU_owner_Positor = 1 AND a.OB_part_SU_owner_PositedAt = '2024-02-01' AND a.OB_part_SU_owner_Reliability = 0);
INSERT INTO #result SELECT N'c19 one insert with two positors and two versions of a static tie', CASE WHEN @error IS NULL AND @owner = @s2 AND @other = @s1 AND @n = 1 THEN 1 ELSE 0 END,
    CONCAT('owners ', @owner, ' and ', @other, ', ', @n, ' retractions by positor 1', ' ' + @error);
UPDATE dbo.lOB_part_SU_owner SET SU_ID_owner = @s2, OB_part_SU_owner_PositedAt = '2024-03-01' WHERE OB_ID_part = @o AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.OB_part_SU_owner_Annex a JOIN dbo.OB_part_SU_owner_Posit p ON p.OB_part_SU_owner_ID = a.OB_part_SU_owner_ID
    WHERE p.OB_ID_part = @o AND p.SU_ID_owner = @s1 AND a.OB_part_SU_owner_Positor = 0 AND a.OB_part_SU_owner_PositedAt = '2024-03-01' AND a.OB_part_SU_owner_Reliability = 0);
INSERT INTO #result SELECT N'c19 a static tie correction retracts the corrected posit at its positing time', CASE WHEN @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' retractions, expected 1');
UPDATE dbo.lOB_part_SU_owner SET OB_part_SU_owner_Reliability = 0, OB_part_SU_owner_PositedAt = '2024-04-01' WHERE OB_ID_part = @o AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.lOB_part_SU_owner WHERE OB_ID_part = @o AND Positor = 0);
INSERT INTO #result SELECT N'c19 retracting a static tie correction leaves nothing in effect', CASE WHEN @n = 0 THEN 1 ELSE 0 END, CONCAT(@n, ' shown, expected 0');
UPDATE #group SET finished = 1 WHERE name = 'c19';
GO

-- c20 a nexus is updated and deleted through its latest view, as an anchor is (there were no such triggers), and its
--     roles are not updatable
DECLARE @s int, @s2 int, @e int, @n int, @quantity int, @for int, @error nvarchar(2048);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s2 = SCOPE_IDENTITY();
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
INSERT INTO #result SELECT N'c20 an update of a nexus attribute through the latest view is a correction', CASE WHEN @error IS NULL AND @quantity = 6 AND @n = 1 THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(CAST(@quantity AS varchar), 'nothing'), ', ', @n, ' retractions of 5', ' ' + @error);
SET @error = NULL;
BEGIN TRY
    UPDATE dbo.lEV_Event SET SU_ID_for = @s2 WHERE EV_ID = @e AND Positor = 0;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @for = (SELECT SU_ID_for FROM dbo.EV_Event WHERE EV_ID = @e);
INSERT INTO #result SELECT N'c20 a role of a nexus is not updatable', CASE WHEN @error LIKE N'The role column SU_ID_for is not updatable%' AND @for = @s THEN 1 ELSE 0 END, CONCAT('for ', @for, '; ', ISNULL(@error, 'no error'));
SET @error = NULL;
BEGIN TRY
    DELETE FROM dbo.lEV_Event WHERE EV_ID = @e AND Positor = 0;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @quantity = (SELECT EV_QTY_Event_Quantity FROM dbo.lEV_Event WHERE EV_ID = @e AND Positor = 0);
INSERT INTO #result SELECT N'c20 a delete through the latest view of a nexus retracts its shown values', CASE WHEN @error IS NULL AND @quantity IS NULL THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(CAST(@quantity AS varchar), 'nothing'), ' ' + @error);
UPDATE #group SET finished = 1 WHERE name = 'c20';
GO

-- c21 the schema tracking views read the roles of ties as the modeler writes them now (role elements, which they used
--     to miss), and know nexuses and their attributes
DECLARE @tie nvarchar(400), @anchors int, @knots int, @nexuses int, @attribute int, @evolution int;
SELECT TOP 1 @tie = [name], @anchors = numberOfAnchors, @knots = numberOfKnots FROM dbo._Tie WHERE [name] LIKE N'SU[_]holder%' ORDER BY [version] DESC;
INSERT INTO #result SELECT N'c21 the tie view names a tie by its roles', CASE WHEN @tie = N'SU_holder_OB_item_GRD_grade' AND @anchors = 2 AND @knots = 1 THEN 1 ELSE 0 END, CONCAT(ISNULL(@tie, 'no tie'), ', ', @anchors, ' anchors, ', @knots, ' knots');
SET @nexuses = (SELECT COUNT(*) FROM dbo._Nexus WHERE [name] = N'EV_Event' AND numberOfRoles = 1 AND numberOfAttributes = 2);
SET @attribute = (SELECT COUNT(*) FROM dbo._Attribute WHERE [name] = N'EV_QTY_Event_Quantity' AND [parent] = N'nexus');
INSERT INTO #result SELECT N'c21 the nexus view shows the nexus, and the attribute view its attribute', CASE WHEN @nexuses > 0 AND @attribute > 0 THEN 1 ELSE 0 END, CONCAT(@nexuses, ' nexus rows, ', @attribute, ' attribute rows');
SET @evolution = (SELECT COUNT(*) FROM dbo._Evolution(sysdatetime()) WHERE [name] IN (N'dbo.EV_Event', N'dbo.EV_QTY_Event_Quantity_Posit', N'dbo.SU_holder_OB_item_GRD_grade_Annex') AND Existence = 'Present');
INSERT INTO #result SELECT N'c21 the evolution function finds the nexus, its attribute and the ties present', CASE WHEN @evolution = 3 THEN 1 ELSE 0 END, CONCAT(@evolution, ' of 3 present');
UPDATE #group SET finished = 1 WHERE name = 'c21';
GO

-- c22 a historized attribute of a nexus: a new value is a new version, which the difference perspective shows (it
--     used to call functions that are not made), and a restatement is an error when the attribute is not restatable
--     (the restatement constraints used to leave the attributes of nexuses out)
DECLARE @s int, @e int, @n int, @place nvarchar(42), @error nvarchar(2048);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
INSERT INTO dbo.lEV_Event (Metadata_EV, SU_ID_for, EV_PLC_Event_Place, EV_PLC_ChangedAt, EV_PLC_PositedAt) VALUES (0, @s, N'p1', '2020-01-01', '2024-01-01');
SET @e = (SELECT MAX(EV_ID) FROM dbo.EV_Event WHERE SU_ID_for = @s);
UPDATE dbo.lEV_Event SET EV_PLC_Event_Place = N'p2', EV_PLC_ChangedAt = '2021-01-01', EV_PLC_PositedAt = '2024-02-01' WHERE EV_ID = @e AND Positor = 0;
SET @place = (SELECT EV_PLC_Event_Place FROM dbo.lEV_Event WHERE EV_ID = @e AND Positor = 0);
SET @n = (SELECT COUNT(*) FROM dbo.dEV_Event('2019-01-01', '2022-01-01', NULL) WHERE EV_ID = @e AND Positor = 0);
INSERT INTO #result SELECT N'c22 a new value of a historized nexus attribute is a new version, which the difference perspective shows', CASE WHEN @place = N'p2' AND @n = 2 THEN 1 ELSE 0 END,
    CONCAT('shown ', ISNULL(@place, 'nothing'), ', ', @n, ' differences, expected 2');
BEGIN TRY
    UPDATE dbo.lEV_Event SET EV_PLC_Event_Place = N'p2', EV_PLC_ChangedAt = '2022-01-01', EV_PLC_PositedAt = '2024-03-01' WHERE EV_ID = @e AND Positor = 0;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.EV_PLC_Event_Place_Posit WHERE EV_PLC_EV_ID = @e);
INSERT INTO #result SELECT N'c22 a restatement of a nexus attribute that is not restatable is an error', CASE WHEN @error LIKE N'%rcEV_PLC_Event_Place_Annex%' AND @n = 2 THEN 1 ELSE 0 END, CONCAT(@n, ' posits; ', ISNULL(@error, 'no error'));
UPDATE #group SET finished = 1 WHERE name = 'c22';
GO

-- c23 the sheet stacks run, for an attribute of an anchor and of a nexus (their statement could not see the parameter
--     of the procedure, so they always failed); each shows its sheets as result sets of its own
DECLARE @s int, @e int, @error nvarchar(2048);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt) VALUES (0, N'sheet', '2020-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
INSERT INTO dbo.lEV_Event (Metadata_EV, SU_ID_for, EV_PLC_Event_Place, EV_PLC_ChangedAt, EV_PLC_PositedAt) VALUES (0, @s, N'sheet', '2020-01-01', '2024-01-01');
SET @e = (SELECT MAX(EV_ID) FROM dbo.EV_Event WHERE SU_ID_for = @s);
BEGIN TRY
    EXEC dbo.ssSU_TTL_Subject_Title @SU_ID = @s;
    EXEC dbo.ssEV_PLC_Event_Place @EV_ID = @e;
END TRY
BEGIN CATCH
    SET @error = ERROR_MESSAGE();
END CATCH
INSERT INTO #result SELECT N'c23 the sheet stacks of an anchor attribute and of a nexus attribute run', CASE WHEN @error IS NULL THEN 1 ELSE 0 END, @error;
UPDATE #group SET finished = 1 WHERE name = 'c23';
GO

-- c24 the difference perspectives name the positor of each row (they had no such column, so the rows of different
--     positors could not be told apart)
DECLARE @s int, @zero int, @one int, @error nvarchar(2048);
IF NOT EXISTS (SELECT 1 FROM dbo._Positor WHERE Positor = 1) INSERT INTO dbo._Positor (Positor) VALUES (1);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
INSERT INTO dbo.SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Positor, SU_TTL_Reliability)
VALUES (0, @s, N'zero', '2020-01-01', '2024-01-01', 0, 1), (0, @s, N'one', '2021-01-01', '2024-01-01', 1, 1);
SET @zero = (SELECT COUNT(*) FROM dbo.dSU_Subject('2019-01-01', '2022-01-01', NULL) WHERE SU_ID = @s AND Positor = 0 AND SU_TTL_Subject_Title = N'zero');
SET @one = (SELECT COUNT(*) FROM dbo.dSU_Subject('2019-01-01', '2022-01-01', NULL) WHERE SU_ID = @s AND Positor = 1 AND SU_TTL_Subject_Title = N'one');
INSERT INTO #result SELECT N'c24 the difference perspective of an anchor names the positor of each row', CASE WHEN @zero = 1 AND @one = 1 THEN 1 ELSE 0 END,
    CONCAT(@zero, ' rows by positor 0 and ', @one, ' by positor 1, expected 1 each');
UPDATE #group SET finished = 1 WHERE name = 'c24';
GO

-- c25 decisive: another value by the same positor at a positing time that already has one is a contradiction, in
--     another statement and within one insert (one used to be refused by an index, the other by a key)
DECLARE @s int, @n int, @error nvarchar(2048);
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_NAM_PositedAt) VALUES (0, N'n1', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
BEGIN TRY
    INSERT INTO dbo.SU_NAM_Subject_Name (Metadata_SU_NAM, SU_NAM_SU_ID, SU_NAM_Subject_Name, SU_NAM_PositedAt, SU_NAM_Positor, SU_NAM_Reliability) VALUES (0, @s, N'n2', '2024-01-01', 0, 1);
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Posit WHERE SU_NAM_SU_ID = @s);
INSERT INTO #result SELECT N'c25 another value at a positing time that has one is a contradiction', CASE WHEN @error LIKE N'Contradiction in SU_NAM_Subject_Name%' AND @n = 1 THEN 1 ELSE 0 END, CONCAT(@n, ' posits; ', ISNULL(@error, 'no error'));
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
SET @error = NULL;
BEGIN TRY
    INSERT INTO dbo.SU_NAM_Subject_Name (Metadata_SU_NAM, SU_NAM_SU_ID, SU_NAM_Subject_Name, SU_NAM_PositedAt, SU_NAM_Positor, SU_NAM_Reliability)
    VALUES (0, @s, N'a', '2024-01-01', 0, 1), (0, @s, N'b', '2024-01-01', 0, 1);
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @n = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Posit WHERE SU_NAM_SU_ID = @s);
INSERT INTO #result SELECT N'c25 two values at one positing time in one insert are a contradiction', CASE WHEN @error LIKE N'Contradiction in SU_NAM_Subject_Name%' AND @n = 0 THEN 1 ELSE 0 END, CONCAT(@n, ' posits; ', ISNULL(@error, 'no error'));
UPDATE #group SET finished = 1 WHERE name = 'c25';
GO

-- c26 decisive, idempotent: a correction to the value of the version before retracts what it corrects, although the
--     restatement itself is skipped (the corrected version used to stay)
DECLARE @s int, @n int, @shown nvarchar(42), @changed datetime2;
INSERT INTO dbo.lSU_Subject (Metadata_SU, SU_TAG_Subject_Tag, SU_TAG_ChangedAt, SU_TAG_PositedAt) VALUES (0, N'A', '2020-01-01', '2024-01-01');
SET @s = (SELECT MAX(SU_ID) FROM dbo.SU_Subject);
UPDATE dbo.lSU_Subject SET SU_TAG_Subject_Tag = N'B', SU_TAG_ChangedAt = '2021-01-01', SU_TAG_PositedAt = '2024-02-01' WHERE SU_ID = @s AND Positor = 0;
UPDATE dbo.lSU_Subject SET SU_TAG_Subject_Tag = N'A', SU_TAG_ChangedAt = '2021-01-01', SU_TAG_PositedAt = '2024-03-01' WHERE SU_ID = @s AND Positor = 0;
SELECT @shown = SU_TAG_Subject_Tag, @changed = SU_TAG_ChangedAt FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0;
SET @n = (SELECT COUNT(*) FROM dbo.SU_TAG_Subject_Tag_Posit WHERE SU_TAG_SU_ID = @s);
INSERT INTO #result SELECT N'c26 idempotent: a correction to the value of the version before retracts the corrected version', CASE WHEN @shown = N'A' AND @changed = '2020-01-01' AND @n = 2 THEN 1 ELSE 0 END,
    CONCAT('shown ', ISNULL(@shown, 'nothing'), ' from ', @changed, ', ', @n, ' posits, expected A from 2020-01-01 and 2 posits');
UPDATE #group SET finished = 1 WHERE name = 'c26';
GO

-- c27 decisive: a negative assertion of another value retracts what the positor held, since a decisive positor holds
--     one assertion at a time, positive or negative
DECLARE @s int, @n int, @shown nvarchar(42);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
INSERT INTO dbo.SU_NAM_Subject_Name (Metadata_SU_NAM, SU_NAM_SU_ID, SU_NAM_Subject_Name, SU_NAM_PositedAt, SU_NAM_Positor, SU_NAM_Reliability) VALUES (0, @s, N'a', '2024-01-01', 0, 1);
INSERT INTO dbo.SU_NAM_Subject_Name (Metadata_SU_NAM, SU_NAM_SU_ID, SU_NAM_Subject_Name, SU_NAM_PositedAt, SU_NAM_Positor, SU_NAM_Reliability) VALUES (0, @s, N'b', '2024-02-01', 0, -1);
SET @n = (SELECT COUNT(*) FROM dbo.SU_NAM_Subject_Name_Annex a JOIN dbo.SU_NAM_Subject_Name_Posit p ON p.SU_NAM_ID = a.SU_NAM_ID
    WHERE p.SU_NAM_SU_ID = @s AND p.SU_NAM_Subject_Name = N'a' AND a.SU_NAM_PositedAt = '2024-02-01' AND a.SU_NAM_Reliability = 0);
SET @shown = (SELECT SU_NAM_Subject_Name FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'c27 a negative assertion of another value retracts the value held', CASE WHEN @n = 1 AND @shown IS NULL THEN 1 ELSE 0 END, CONCAT(@n, ' retractions of a; shown ', ISNULL(@shown, 'nothing'));
UPDATE #group SET finished = 1 WHERE name = 'c27';
GO

-- c28 an assertion that is not a retraction supersedes those at earlier changing times, whatever its sign: the latest
--     view shows nothing where the latest changing time has only a negative assertion (it used to show the version
--     before), the point-in-time view before that time still shows the version before, and so does the latest view once
--     the negative assertion is retracted; asserting the earlier value at the later changing time shows it again
DECLARE @s int, @t int, @o int, @e int, @n int, @shown nvarchar(42), @before nvarchar(42), @place nvarchar(42);
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @s = SCOPE_IDENTITY();
INSERT INTO dbo.SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Positor, SU_TTL_Reliability)
VALUES (0, @s, N'Red', '2000-01-01', '2012-12-12', 0, 1);
INSERT INTO dbo.SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Positor, SU_TTL_Reliability)
VALUES (0, @s, N'Green', '2001-01-01', '2012-12-13', 0, -1);
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
SET @before = (SELECT SU_TTL_Subject_Title FROM dbo.pSU_Subject('2000-06-01') WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'c28 certainly not Green from 2001 supersedes Red from 2000', CASE WHEN @shown IS NULL AND @before = N'Red' THEN 1 ELSE 0 END,
    CONCAT('shown ', ISNULL(@shown, 'nothing'), ', and ', ISNULL(@before, 'nothing'), ' in 2000');
INSERT INTO dbo.SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Positor, SU_TTL_Reliability)
VALUES (0, @s, N'Red', '2001-01-01', '2012-12-14', 0, 1);
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @s AND Positor = 0);
INSERT INTO #result SELECT N'c28 Red asserted at 2001 is shown', CASE WHEN @shown = N'Red' THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'));
INSERT INTO dbo.SU_Subject (Metadata_SU) VALUES (0); SET @t = SCOPE_IDENTITY();
INSERT INTO dbo.SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Positor, SU_TTL_Reliability)
VALUES (0, @t, N'Red', '2000-01-01', '2012-12-12', 0, 1);
INSERT INTO dbo.SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Positor, SU_TTL_Reliability)
VALUES (0, @t, N'Green', '2001-01-01', '2012-12-13', 0, -1);
INSERT INTO dbo.SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Positor, SU_TTL_Reliability)
VALUES (0, @t, N'Green', '2001-01-01', '2012-12-14', 0, 0);
SET @shown = (SELECT SU_TTL_Subject_Title FROM dbo.lSU_Subject WHERE SU_ID = @t AND Positor = 0);
INSERT INTO #result SELECT N'c28 retracting not Green shows Red from 2000 again', CASE WHEN @shown = N'Red' THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@shown, 'nothing'));
-- a historized tie with identifiers, and a historized attribute of a nexus
INSERT INTO dbo.OB_Object (Metadata_OB) VALUES (0); SET @o = SCOPE_IDENTITY();
INSERT INTO dbo.SU_holder_OB_item_GRD_grade (Metadata_SU_holder_OB_item_GRD_grade, SU_ID_holder, OB_ID_item, GRD_ID_grade,
    SU_holder_OB_item_GRD_grade_ChangedAt, SU_holder_OB_item_GRD_grade_PositedAt, SU_holder_OB_item_GRD_grade_Positor, SU_holder_OB_item_GRD_grade_Reliability)
VALUES (0, @s, @o, 1, '2020-01-01', '2012-12-12', 0, 1);
INSERT INTO dbo.SU_holder_OB_item_GRD_grade (Metadata_SU_holder_OB_item_GRD_grade, SU_ID_holder, OB_ID_item, GRD_ID_grade,
    SU_holder_OB_item_GRD_grade_ChangedAt, SU_holder_OB_item_GRD_grade_PositedAt, SU_holder_OB_item_GRD_grade_Positor, SU_holder_OB_item_GRD_grade_Reliability)
VALUES (0, @s, @o, 2, '2021-01-01', '2012-12-13', 0, -1);
SET @n = (SELECT COUNT(*) FROM dbo.lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = @s AND OB_ID_item = @o AND Positor = 0);
INSERT INTO #result SELECT N'c28 a tie: a negative assertion at a later changing time supersedes the version before', CASE WHEN @n = 0 THEN 1 ELSE 0 END, CONCAT(@n, ' shown, expected 0');
INSERT INTO dbo.lEV_Event (Metadata_EV, SU_ID_for, EV_PLC_Event_Place, EV_PLC_ChangedAt, EV_PLC_PositedAt) VALUES (0, @s, N'p1', '2020-01-01', '2012-12-12');
SET @e = (SELECT MAX(EV_ID) FROM dbo.EV_Event WHERE SU_ID_for = @s);
INSERT INTO dbo.EV_PLC_Event_Place (Metadata_EV_PLC, EV_PLC_EV_ID, EV_PLC_Event_Place, EV_PLC_ChangedAt, EV_PLC_PositedAt, EV_PLC_Positor, EV_PLC_Reliability)
VALUES (0, @e, N'p2', '2021-01-01', '2012-12-13', 0, -1);
SET @place = (SELECT EV_PLC_Event_Place FROM dbo.lEV_Event WHERE EV_ID = @e AND Positor = 0);
INSERT INTO #result SELECT N'c28 a nexus: a negative assertion at a later changing time supersedes the version before', CASE WHEN @place IS NULL THEN 1 ELSE 0 END, CONCAT('shown ', ISNULL(@place, 'nothing'));
UPDATE #group SET finished = 1 WHERE name = 'c28';
GO

-- the result
INSERT INTO #result SELECT name + N' did not run to the end (its error is in the output above)', 0, NULL FROM #group WHERE finished = 0;
SELECT CASE WHEN passed = 1 THEN 'PASS' ELSE 'FAIL' END + ' ' + test + ISNULL(' (' + detail + ')', '') AS result FROM #result ORDER BY id;
DECLARE @failed int = (SELECT COUNT(*) FROM #result WHERE passed = 0), @total int = (SELECT COUNT(*) FROM #result);
PRINT CONCAT(@total - @failed, ' of ', @total, ' checks passed');
IF @failed > 0 THROW 50000, 'Some trigger checks failed', 1;
GO
