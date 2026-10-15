-- Checks the bitemporal trigger test database after an upgrade: triggers-bi-upgrade.sql made three constraints of
-- assembled views the old way, without the reliability, and tools/sqlserver-tests.ps1 then ran the generated SQL again.
-- Written as triggers-bi.sql is.
SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result;
IF OBJECT_ID('tempdb..#group') IS NOT NULL DROP TABLE #group;
CREATE TABLE #result (id int IDENTITY(1,1) PRIMARY KEY, test nvarchar(400) NOT NULL, passed bit NOT NULL, detail nvarchar(2048) NULL);
CREATE TABLE #group (name char(3) PRIMARY KEY, finished bit NOT NULL DEFAULT 0);
INSERT INTO #group (name) VALUES ('u01');
GO

-- u01 the generated SQL makes an older constraint again with the reliability, so that corrections work
DECLARE @n int, @o int, @retracted int, @shown nvarchar(42), @error nvarchar(2048);
SET @n = (SELECT COUNT(*) FROM sys.indexes x
    JOIN sys.index_columns c ON c.object_id = x.object_id AND c.index_id = x.index_id
    JOIN sys.columns k ON k.object_id = c.object_id AND k.column_id = c.column_id
    WHERE x.name IN (N'pkOB_NAM_Object_Name', N'pkSU_STA_Subject_State', N'pkSU_keeper_OB_thing_GRD_rank')
    AND k.name LIKE N'%[_]Reliability');
INSERT INTO #result SELECT N'u01 the older constraints have been made again with the reliability', CASE WHEN @n = 3 THEN 1 ELSE 0 END, CONCAT(@n, ' of 3');
BEGIN TRY
    INSERT INTO dbo.lOB_Object (Metadata_OB, OB_NAM_Object_Name, OB_NAM_PositedAt) VALUES (0, N'o1', '2024-01-01');
    SET @o = (SELECT MAX(OB_ID) FROM dbo.OB_Object);
    UPDATE dbo.lOB_Object SET OB_NAM_Object_Name = N'o2', OB_NAM_PositedAt = '2024-02-01' WHERE OB_ID = @o;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @error = ERROR_MESSAGE();
END CATCH
SET @retracted = (SELECT COUNT(*) FROM dbo.OB_NAM_Object_Name_Annex a JOIN dbo.OB_NAM_Object_Name_Posit p ON p.OB_NAM_ID = a.OB_NAM_ID
    WHERE p.OB_NAM_OB_ID = @o AND p.OB_NAM_Object_Name = N'o1' AND a.OB_NAM_PositedAt = '2024-02-01' AND a.OB_NAM_Reliability = 0);
SET @shown = (SELECT OB_NAM_Object_Name FROM dbo.lOB_Object WHERE OB_ID = @o);
INSERT INTO #result SELECT N'u01 a correction after the upgrade', CASE WHEN @error IS NULL AND @retracted = 1 AND @shown = N'o2' THEN 1 ELSE 0 END,
    CONCAT(@retracted, ' retractions; shown ', ISNULL(@shown, 'nothing'), ' ' + @error);
UPDATE #group SET finished = 1 WHERE name = 'u01';
GO

-- the result
INSERT INTO #result SELECT name + N' did not run to the end (its error is in the output above)', 0, NULL FROM #group WHERE finished = 0;
SELECT CASE WHEN passed = 1 THEN 'PASS' ELSE 'FAIL' END + ' ' + test + ISNULL(' (' + detail + ')', '') AS result FROM #result ORDER BY id;
DECLARE @failed int = (SELECT COUNT(*) FROM #result WHERE passed = 0), @total int = (SELECT COUNT(*) FROM #result);
PRINT CONCAT(@total - @failed, ' of ', @total, ' checks passed');
IF @failed > 0 THROW 50000, 'Some upgrade checks failed', 1;
GO
