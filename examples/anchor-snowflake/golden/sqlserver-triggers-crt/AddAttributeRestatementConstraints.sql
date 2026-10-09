-- ATTRIBUTE RESTATEMENT CONSTRAINTS ----------------------------------------------------------------------------------
--
-- Attributes may be prevented from storing restatements.
-- A restatement is when the same value occurs for two adjacent points
-- in changing time. Note that restatement checking is not done for
-- unreliable information as this could prevent demotion.
--
-- returns 1 for at least one equal surrounding value, 0 for different surrounding values
--
-- @posit the id of the posit that should be checked
-- @posited the time when this posit was made
-- @positor the one who made the posit
-- @assertion whether this posit is positively or negatively asserted, or unreliable
--
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_TTL_Subject_Title restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_TTL_Subject_Title restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_TTL_Subject_Title', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_TTL_Subject_Title] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value nvarchar(42);
    DECLARE @changed datetime2;
    SELECT
        @id = SU_TTL_SU_ID,
        @value = SU_TTL_Subject_Title,
        @changed = SU_TTL_ChangedAt
    FROM
        [dbo].[SU_TTL_Subject_Title_Posit]
    WHERE
        SU_TTL_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_TTL_Subject_Title] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_TTL_Subject_Title] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_STA_Subject_State restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_STA_Subject_State restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_STA_Subject_State', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_STA_Subject_State] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value nvarchar(42);
    DECLARE @changed datetime2;
    SELECT
        @id = SU_STA_SU_ID,
        @value = SU_STA_Subject_State,
        @changed = SU_STA_ChangedAt
    FROM
        [dbo].[SU_STA_Subject_State_Posit]
    WHERE
        SU_STA_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_STA_Subject_State] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_STA_Subject_State] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [dbo].[SU_STA_Subject_State_Annex]
    ADD CONSTRAINT [rcSU_STA_Subject_State_Annex] CHECK (
        [dbo].[rfSU_STA_Subject_State] (
            SU_STA_ID,
            SU_STA_PositedAt,
            SU_STA_Positor,
            SU_STA_Assertion
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_LBL_Subject_Label restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_LBL_Subject_Label restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_LBL_Subject_Label', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_LBL_Subject_Label] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value nvarchar(42);
    DECLARE @changed datetime2;
    SELECT
        @id = SU_LBL_SU_ID,
        @value = SU_LBL_Subject_Label,
        @changed = SU_LBL_ChangedAt
    FROM
        [dbo].[SU_LBL_Subject_Label_Posit]
    WHERE
        SU_LBL_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_LBL_Subject_Label] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_LBL_Subject_Label] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [dbo].[SU_LBL_Subject_Label_Annex]
    ADD CONSTRAINT [rcSU_LBL_Subject_Label_Annex] CHECK (
        [dbo].[rfSU_LBL_Subject_Label] (
            SU_LBL_ID,
            SU_LBL_PositedAt,
            SU_LBL_Positor,
            SU_LBL_Assertion
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_TAG_Subject_Tag restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_TAG_Subject_Tag restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_TAG_Subject_Tag', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_TAG_Subject_Tag] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value nvarchar(42);
    DECLARE @changed datetime2;
    SELECT
        @id = SU_TAG_SU_ID,
        @value = SU_TAG_Subject_Tag,
        @changed = SU_TAG_ChangedAt
    FROM
        [dbo].[SU_TAG_Subject_Tag_Posit]
    WHERE
        SU_TAG_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_TAG_Subject_Tag] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_TAG_Subject_Tag] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_LVL_Subject_Level restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_LVL_Subject_Level restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_LVL_Subject_Level', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_LVL_Subject_Level] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value tinyint;
    DECLARE @changed datetime2;
    SELECT
        @id = SU_LVL_SU_ID,
        @value = SU_LVL_GRD_ID,
        @changed = SU_LVL_ChangedAt
    FROM
        [dbo].[SU_LVL_Subject_Level_Posit]
    WHERE
        SU_LVL_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_LVL_Subject_Level] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_LVL_Subject_Level] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_TXT_Subject_Text restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_TXT_Subject_Text restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_TXT_Subject_Text', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_TXT_Subject_Text] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value varbinary(16);
    DECLARE @changed datetime2;
    SELECT
        @id = SU_TXT_SU_ID,
        @value = SU_TXT_Checksum,
        @changed = SU_TXT_ChangedAt
    FROM
        [dbo].[SU_TXT_Subject_Text_Posit]
    WHERE
        SU_TXT_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_TXT_Subject_Text] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_TXT_Subject_Text] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_ASR_Subject_Assessment restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_ASR_Subject_Assessment restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_ASR_Subject_Assessment', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_ASR_Subject_Assessment] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value nvarchar(42);
    DECLARE @changed datetime2;
    SELECT
        @id = SU_ASR_SU_ID,
        @value = SU_ASR_Subject_Assessment,
        @changed = SU_ASR_ChangedAt
    FROM
        [dbo].[SU_ASR_Subject_Assessment_Posit]
    WHERE
        SU_ASR_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_ASR_Subject_Assessment] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_ASR_Subject_Assessment] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSU_ERS_Subject_Erasable restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSU_ERS_Subject_Erasable restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rfSU_ERS_Subject_Erasable', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rfSU_ERS_Subject_Erasable] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id int;
    DECLARE @value nvarchar(42);
    DECLARE @changed datetime2;
    SELECT
        @id = SU_ERS_SU_ID,
        @value = SU_ERS_Subject_Erasable,
        @changed = SU_ERS_ChangedAt
    FROM
        [dbo].[SU_ERS_Subject_Erasable_Posit]
    WHERE
        SU_ERS_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[preSU_ERS_Subject_Erasable] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        ) OR EXISTS (
            SELECT
                @value
            WHERE
                @value = [dbo].[folSU_ERS_Subject_Erasable] (
                    @id,
                    @positor,
                    @changed,
                    @posited, 
                    @assertion
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
END
GO
