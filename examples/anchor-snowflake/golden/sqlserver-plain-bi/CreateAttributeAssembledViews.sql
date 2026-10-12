-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines the posit and annex table of the attribute.
-- It can be used to maintain entity integrity through a primary key, which cannot be
-- defined elsewhere.
--
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
        p.ST_ID,
        p.ST_NAM_Stage_Name,
        p.ST_NAM_ChangedAt,
        a.ST_NAM_PositedAt,
        a.ST_NAM_Reliability
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
        ST_ID asc,
        ST_NAM_ChangedAt desc,
        ST_NAM_PositedAt desc
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
        p.ST_ID,
        p.ST_LOC_Checksum,
        p.ST_LOC_Stage_Location,
        a.ST_LOC_PositedAt,
        a.ST_LOC_Reliability
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
        ST_ID asc,
        ST_LOC_PositedAt desc
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
        p.ST_ID,
        p.UTL_ID,
        p.ST_AVG_ChangedAt,
        a.ST_AVG_PositedAt,
        a.ST_AVG_Reliability
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
        ST_ID asc,
        ST_AVG_ChangedAt desc,
        ST_AVG_PositedAt desc
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
        p.ST_ID,
        p.UTL_ID,
        a.ST_MIN_PositedAt,
        a.ST_MIN_Reliability
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
        ST_ID asc,
        ST_MIN_PositedAt desc
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
        p.AC_ID,
        p.AC_NAM_Actor_Name,
        p.AC_NAM_ChangedAt,
        a.AC_NAM_PositedAt,
        a.AC_NAM_Reliability
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
        AC_ID asc,
        AC_NAM_ChangedAt desc,
        AC_NAM_PositedAt desc
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
        p.AC_ID,
        p.GEN_ID,
        a.AC_GEN_PositedAt,
        a.AC_GEN_Reliability
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
        AC_ID asc,
        AC_GEN_PositedAt desc
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
        p.AC_ID,
        p.PLV_ID,
        p.AC_PLV_ChangedAt,
        a.AC_PLV_PositedAt,
        a.AC_PLV_Reliability
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
        AC_ID asc,
        AC_PLV_ChangedAt desc,
        AC_PLV_PositedAt desc
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
        p.PR_ID,
        p.PR_NAM_Program_Name,
        a.PR_NAM_PositedAt,
        a.PR_NAM_Reliability
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
        PR_ID asc,
        PR_NAM_PositedAt desc
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
        p.PR_ID,
        p.PR_LEN_Program_Length,
        p.PR_LEN_ChangedAt,
        a.PR_LEN_PositedAt,
        a.PR_LEN_Reliability
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
        PR_ID asc,
        PR_LEN_ChangedAt desc,
        PR_LEN_PositedAt desc
    );
    ');
END
GO
