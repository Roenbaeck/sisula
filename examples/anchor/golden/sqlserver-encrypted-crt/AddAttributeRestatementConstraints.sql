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
-- rfEV_STA_Event_Status restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcEV_STA_Event_Status restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rfEV_STA_Event_Status', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rfEV_STA_Event_Status] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id numeric(12,0);
    DECLARE @value nvarchar(20);
    DECLARE @changed datetime2;
    SELECT
        @id = EV_STA_EV_ID,
        @value = EV_STA_Event_Status,
        @changed = EV_STA_ChangedAt
    FROM
        [attributes].[EV_STA_Event_Status_Posit]
    WHERE
        EV_STA_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [attributes].[preEV_STA_Event_Status] (
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
                @value = [attributes].[folEV_STA_Event_Status] (
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
-- rfEV_LVL_Event_Level restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcEV_LVL_Event_Level restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rfEV_LVL_Event_Level', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rfEV_LVL_Event_Level] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id numeric(12,0);
    DECLARE @value tinyint;
    DECLARE @changed date;
    SELECT
        @id = EV_LVL_EV_ID,
        @value = EV_LVL_PLV_ID,
        @changed = EV_LVL_ChangedAt
    FROM
        [attributes].[EV_LVL_Event_Level_Posit]
    WHERE
        EV_LVL_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [attributes].[preEV_LVL_Event_Level] (
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
                @value = [attributes].[folEV_LVL_Event_Level] (
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
-- rfST_NAM_Stage_Name restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcST_NAM_Stage_Name restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rfST_NAM_Stage_Name', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rfST_NAM_Stage_Name] (
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
        @id = ST_NAM_ST_ID,
        @value = ST_NAM_Stage_Name,
        @changed = ST_NAM_ChangedAt
    FROM
        [attributes].[ST_NAM_Stage_Name_Posit]
    WHERE
        ST_NAM_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [attributes].[preST_NAM_Stage_Name] (
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
                @value = [attributes].[folST_NAM_Stage_Name] (
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
-- rfST_AVG_Stage_Average restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcST_AVG_Stage_Average restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rfST_AVG_Stage_Average', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rfST_AVG_Stage_Average] (
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
        @id = ST_AVG_ST_ID,
        @value = ST_AVG_UTL_ID,
        @changed = ST_AVG_ChangedAt
    FROM
        [attributes].[ST_AVG_Stage_Average_Posit]
    WHERE
        ST_AVG_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [attributes].[preST_AVG_Stage_Average] (
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
                @value = [attributes].[folST_AVG_Stage_Average] (
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
    ALTER TABLE [attributes].[ST_AVG_Stage_Average_Annex]
    ADD CONSTRAINT [rcST_AVG_Stage_Average_Annex] CHECK (
        [attributes].[rfST_AVG_Stage_Average] (
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Positor,
            ST_AVG_Assertion
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfAC_NAM_Actor_Name restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcAC_NAM_Actor_Name restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rfAC_NAM_Actor_Name', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rfAC_NAM_Actor_Name] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id smallint;
    DECLARE @value nvarchar(42);
    DECLARE @changed datetime2;
    SELECT
        @id = AC_NAM_AC_ID,
        @value = AC_NAM_Actor_Name,
        @changed = AC_NAM_ChangedAt
    FROM
        [attributes].[AC_NAM_Actor_Name_Posit]
    WHERE
        AC_NAM_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [attributes].[preAC_NAM_Actor_Name] (
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
                @value = [attributes].[folAC_NAM_Actor_Name] (
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
    ALTER TABLE [attributes].[AC_NAM_Actor_Name_Annex]
    ADD CONSTRAINT [rcAC_NAM_Actor_Name_Annex] CHECK (
        [attributes].[rfAC_NAM_Actor_Name] (
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Positor,
            AC_NAM_Assertion
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfAC_PLV_Actor_ProfessionalLevel restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcAC_PLV_Actor_ProfessionalLevel restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rfAC_PLV_Actor_ProfessionalLevel', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rfAC_PLV_Actor_ProfessionalLevel] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id smallint;
    DECLARE @value tinyint;
    DECLARE @changed datetime2;
    SELECT
        @id = AC_PLV_AC_ID,
        @value = AC_PLV_PLV_ID,
        @changed = AC_PLV_ChangedAt
    FROM
        [attributes].[AC_PLV_Actor_ProfessionalLevel_Posit]
    WHERE
        AC_PLV_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [attributes].[preAC_PLV_Actor_ProfessionalLevel] (
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
                @value = [attributes].[folAC_PLV_Actor_ProfessionalLevel] (
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
-- rfPR_LEN_Program_Length restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcPR_LEN_Program_Length restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rfPR_LEN_Program_Length', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rfPR_LEN_Program_Length] (
        @posit int,
        @posited datetime2,
        @positor tinyint,
        @assertion char(1)
    )
    RETURNS tinyint AS
    BEGIN
    DECLARE @id bigint;
    DECLARE @value time;
    DECLARE @changed date;
    SELECT
        @id = PR_LEN_PR_ID,
        @value = PR_LEN_Program_Length,
        @changed = PR_LEN_ChangedAt
    FROM
        [attributes].[PR_LEN_Program_Length_Posit]
    WHERE
        PR_LEN_ID = @posit;
    RETURN (
        CASE
        WHEN @assertion = ''?''
        THEN 0
        WHEN EXISTS (
            SELECT
                @value
            WHERE
                @value = [attributes].[prePR_LEN_Program_Length] (
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
                @value = [attributes].[folPR_LEN_Program_Length] (
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
