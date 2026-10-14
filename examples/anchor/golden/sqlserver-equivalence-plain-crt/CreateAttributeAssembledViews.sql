-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines the posit and annex table of the attribute.
-- It can be used to maintain entity integrity through a primary key, which cannot be
-- defined elsewhere.
--
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date assembled view of the posit and annex tables,
-- pkEV_DAT_Event_Date optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_DAT_Event_Date', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[EV_DAT_Event_Date]
    WITH SCHEMABINDING AS
    SELECT
        p.EV_DAT_ID,
        p.EV_DAT_EV_ID,
        p.EV_DAT_Event_Date,
        a.EV_DAT_PositedAt,
        a.EV_DAT_Positor,
        a.EV_DAT_Reliability,
        a.EV_DAT_Assertion
    FROM
        [dbo].[EV_DAT_Event_Date_Posit] p
    JOIN
        [dbo].[EV_DAT_Event_Date_Annex] a
    ON
        a.EV_DAT_ID = p.EV_DAT_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_DAT_Event_Date]
    ON [dbo].[EV_DAT_Event_Date] (
        EV_DAT_Assertion desc, 
        EV_DAT_EV_ID asc,
        EV_DAT_PositedAt desc,
        EV_DAT_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience assembled view of the posit and annex tables,
-- pkEV_AUD_Event_Audience optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_AUD_Event_Audience', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[EV_AUD_Event_Audience]
    WITH SCHEMABINDING AS
    SELECT
        p.EV_AUD_ID,
        p.EV_AUD_EV_ID,
        p.EV_AUD_Event_Audience,
        a.EV_AUD_PositedAt,
        a.EV_AUD_Positor,
        a.EV_AUD_Reliability,
        a.EV_AUD_Assertion
    FROM
        [dbo].[EV_AUD_Event_Audience_Posit] p
    JOIN
        [dbo].[EV_AUD_Event_Audience_Annex] a
    ON
        a.EV_AUD_ID = p.EV_AUD_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_AUD_Event_Audience]
    ON [dbo].[EV_AUD_Event_Audience] (
        EV_AUD_Assertion desc, 
        EV_AUD_EV_ID asc,
        EV_AUD_PositedAt desc,
        EV_AUD_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue assembled view of the posit and annex tables,
-- pkEV_REV_Event_Revenue optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_REV_Event_Revenue', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[EV_REV_Event_Revenue]
    WITH SCHEMABINDING AS
    SELECT
        p.EV_REV_ID,
        p.EV_REV_EV_ID,
        p.EV_REV_Event_Revenue,
        a.EV_REV_PositedAt,
        a.EV_REV_Positor,
        a.EV_REV_Reliability,
        a.EV_REV_Assertion
    FROM
        [dbo].[EV_REV_Event_Revenue_Posit] p
    JOIN
        [dbo].[EV_REV_Event_Revenue_Annex] a
    ON
        a.EV_REV_ID = p.EV_REV_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_REV_Event_Revenue]
    ON [dbo].[EV_REV_Event_Revenue] (
        EV_REV_Assertion desc, 
        EV_REV_EV_ID asc,
        EV_REV_PositedAt desc,
        EV_REV_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name assembled view of the posit and annex tables,
-- pkST_NAM_Stage_Name optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_NAM_Stage_Name', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[ST_NAM_Stage_Name]
    WITH SCHEMABINDING AS
    SELECT
        p.ST_NAM_ID,
        p.ST_NAM_ST_ID,
        p.ST_NAM_Checksum,
        p.ST_NAM_Stage_Name,
        p.ST_NAM_ChangedAt,
        a.ST_NAM_PositedAt,
        a.ST_NAM_Positor,
        a.ST_NAM_Reliability,
        a.ST_NAM_Assertion
    FROM
        [dbo].[ST_NAM_Stage_Name_Posit] p
    JOIN
        [dbo].[ST_NAM_Stage_Name_Annex] a
    ON
        a.ST_NAM_ID = p.ST_NAM_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_NAM_Stage_Name]
    ON [dbo].[ST_NAM_Stage_Name] (
        ST_NAM_Assertion desc, 
        ST_NAM_ST_ID asc,
        ST_NAM_ChangedAt desc,
        ST_NAM_PositedAt desc,
        ST_NAM_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location assembled view of the posit and annex tables,
-- pkST_LOC_Stage_Location optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_LOC_Stage_Location', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[ST_LOC_Stage_Location]
    WITH SCHEMABINDING AS
    SELECT
        p.ST_LOC_ID,
        p.ST_LOC_ST_ID,
        p.ST_LOC_Checksum,
        p.ST_LOC_Stage_Location,
        a.ST_LOC_PositedAt,
        a.ST_LOC_Positor,
        a.ST_LOC_Reliability,
        a.ST_LOC_Assertion
    FROM
        [dbo].[ST_LOC_Stage_Location_Posit] p
    JOIN
        [dbo].[ST_LOC_Stage_Location_Annex] a
    ON
        a.ST_LOC_ID = p.ST_LOC_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_LOC_Stage_Location]
    ON [dbo].[ST_LOC_Stage_Location] (
        ST_LOC_Assertion desc, 
        ST_LOC_ST_ID asc,
        ST_LOC_PositedAt desc,
        ST_LOC_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average assembled view of the posit and annex tables,
-- pkST_AVG_Stage_Average optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_AVG_Stage_Average', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[ST_AVG_Stage_Average]
    WITH SCHEMABINDING AS
    SELECT
        p.ST_AVG_ID,
        p.ST_AVG_ST_ID,
        p.ST_AVG_UTL_ID,
        p.ST_AVG_ChangedAt,
        a.ST_AVG_PositedAt,
        a.ST_AVG_Positor,
        a.ST_AVG_Reliability,
        a.ST_AVG_Assertion
    FROM
        [dbo].[ST_AVG_Stage_Average_Posit] p
    JOIN
        [dbo].[ST_AVG_Stage_Average_Annex] a
    ON
        a.ST_AVG_ID = p.ST_AVG_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_AVG_Stage_Average]
    ON [dbo].[ST_AVG_Stage_Average] (
        ST_AVG_Assertion desc, 
        ST_AVG_ST_ID asc,
        ST_AVG_ChangedAt desc,
        ST_AVG_PositedAt desc,
        ST_AVG_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum assembled view of the posit and annex tables,
-- pkST_MIN_Stage_Minimum optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_MIN_Stage_Minimum', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[ST_MIN_Stage_Minimum]
    WITH SCHEMABINDING AS
    SELECT
        p.ST_MIN_ID,
        p.ST_MIN_ST_ID,
        p.ST_MIN_UTL_ID,
        a.ST_MIN_PositedAt,
        a.ST_MIN_Positor,
        a.ST_MIN_Reliability,
        a.ST_MIN_Assertion
    FROM
        [dbo].[ST_MIN_Stage_Minimum_Posit] p
    JOIN
        [dbo].[ST_MIN_Stage_Minimum_Annex] a
    ON
        a.ST_MIN_ID = p.ST_MIN_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_MIN_Stage_Minimum]
    ON [dbo].[ST_MIN_Stage_Minimum] (
        ST_MIN_Assertion desc, 
        ST_MIN_ST_ID asc,
        ST_MIN_PositedAt desc,
        ST_MIN_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name assembled view of the posit and annex tables,
-- pkAC_NAM_Actor_Name optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_NAM_Actor_Name', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[AC_NAM_Actor_Name]
    WITH SCHEMABINDING AS
    SELECT
        p.AC_NAM_ID,
        p.AC_NAM_AC_ID,
        p.AC_NAM_Checksum,
        p.AC_NAM_Actor_Name,
        p.AC_NAM_ChangedAt,
        a.AC_NAM_PositedAt,
        a.AC_NAM_Positor,
        a.AC_NAM_Reliability,
        a.AC_NAM_Assertion
    FROM
        [dbo].[AC_NAM_Actor_Name_Posit] p
    JOIN
        [dbo].[AC_NAM_Actor_Name_Annex] a
    ON
        a.AC_NAM_ID = p.AC_NAM_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_NAM_Actor_Name]
    ON [dbo].[AC_NAM_Actor_Name] (
        AC_NAM_Assertion desc, 
        AC_NAM_AC_ID asc,
        AC_NAM_ChangedAt desc,
        AC_NAM_PositedAt desc,
        AC_NAM_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender assembled view of the posit and annex tables,
-- pkAC_GEN_Actor_Gender optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_GEN_Actor_Gender', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[AC_GEN_Actor_Gender]
    WITH SCHEMABINDING AS
    SELECT
        p.AC_GEN_ID,
        p.AC_GEN_AC_ID,
        p.AC_GEN_GEN_ID,
        a.AC_GEN_PositedAt,
        a.AC_GEN_Positor,
        a.AC_GEN_Reliability,
        a.AC_GEN_Assertion
    FROM
        [dbo].[AC_GEN_Actor_Gender_Posit] p
    JOIN
        [dbo].[AC_GEN_Actor_Gender_Annex] a
    ON
        a.AC_GEN_ID = p.AC_GEN_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_GEN_Actor_Gender]
    ON [dbo].[AC_GEN_Actor_Gender] (
        AC_GEN_Assertion desc, 
        AC_GEN_AC_ID asc,
        AC_GEN_PositedAt desc,
        AC_GEN_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel assembled view of the posit and annex tables,
-- pkAC_PLV_Actor_ProfessionalLevel optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_PLV_Actor_ProfessionalLevel', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[AC_PLV_Actor_ProfessionalLevel]
    WITH SCHEMABINDING AS
    SELECT
        p.AC_PLV_ID,
        p.AC_PLV_AC_ID,
        p.AC_PLV_PLV_ID,
        p.AC_PLV_ChangedAt,
        a.AC_PLV_PositedAt,
        a.AC_PLV_Positor,
        a.AC_PLV_Reliability,
        a.AC_PLV_Assertion
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
    JOIN
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] a
    ON
        a.AC_PLV_ID = p.AC_PLV_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_PLV_Actor_ProfessionalLevel]
    ON [dbo].[AC_PLV_Actor_ProfessionalLevel] (
        AC_PLV_Assertion desc, 
        AC_PLV_AC_ID asc,
        AC_PLV_ChangedAt desc,
        AC_PLV_PositedAt desc,
        AC_PLV_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name assembled view of the posit and annex tables,
-- pkPR_NAM_Program_Name optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_NAM_Program_Name', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[PR_NAM_Program_Name]
    WITH SCHEMABINDING AS
    SELECT
        p.PR_NAM_ID,
        p.PR_NAM_PR_ID,
        p.PR_NAM_Program_Name,
        a.PR_NAM_PositedAt,
        a.PR_NAM_Positor,
        a.PR_NAM_Reliability,
        a.PR_NAM_Assertion
    FROM
        [dbo].[PR_NAM_Program_Name_Posit] p
    JOIN
        [dbo].[PR_NAM_Program_Name_Annex] a
    ON
        a.PR_NAM_ID = p.PR_NAM_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkPR_NAM_Program_Name]
    ON [dbo].[PR_NAM_Program_Name] (
        PR_NAM_Assertion desc, 
        PR_NAM_PR_ID asc,
        PR_NAM_PositedAt desc,
        PR_NAM_Positor asc
    );
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length assembled view of the posit and annex tables,
-- pkPR_LEN_Program_Length optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_LEN_Program_Length', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[PR_LEN_Program_Length]
    WITH SCHEMABINDING AS
    SELECT
        p.PR_LEN_ID,
        p.PR_LEN_PR_ID,
        p.PR_LEN_Program_Length,
        p.PR_LEN_ChangedAt,
        a.PR_LEN_PositedAt,
        a.PR_LEN_Positor,
        a.PR_LEN_Reliability,
        a.PR_LEN_Assertion
    FROM
        [dbo].[PR_LEN_Program_Length_Posit] p
    JOIN
        [dbo].[PR_LEN_Program_Length_Annex] a
    ON
        a.PR_LEN_ID = p.PR_LEN_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkPR_LEN_Program_Length]
    ON [dbo].[PR_LEN_Program_Length] (
        PR_LEN_Assertion desc, 
        PR_LEN_PR_ID asc,
        PR_LEN_ChangedAt desc,
        PR_LEN_PositedAt desc,
        PR_LEN_Positor asc
    );
    ');
END
GO
