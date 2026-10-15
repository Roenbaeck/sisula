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
IF Object_ID('attributes.EV_DAT_Event_Date', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [attributes].[EV_DAT_Event_Date]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_EV_DAT,
        p.EV_DAT_ID,
        p.EV_DAT_EV_ID,
        p.EV_DAT_Event_Date,
        a.EV_DAT_PositedAt,
        a.EV_DAT_Reliability
    FROM
        [attributes].[EV_DAT_Event_Date_Posit] p
    JOIN
        [attributes].[EV_DAT_Event_Date_Annex] a
    ON
        a.EV_DAT_ID = p.EV_DAT_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_DAT_Event_Date]
    ON [attributes].[EV_DAT_Event_Date] (
        EV_DAT_EV_ID asc,
        EV_DAT_PositedAt desc,
        EV_DAT_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('attributes.EV_DAT_Event_Date', 'V')
    AND
        x.name = 'pkEV_DAT_Event_Date'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'EV_DAT_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_DAT_Event_Date]
    ON [attributes].[EV_DAT_Event_Date] (
        EV_DAT_EV_ID asc,
        EV_DAT_PositedAt desc,
        EV_DAT_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience assembled view of the posit and annex tables,
-- pkEV_AUD_Event_Audience optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_AUD_Event_Audience', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [attributes].[EV_AUD_Event_Audience]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_EV_AUD,
        p.EV_AUD_ID,
        p.EV_AUD_EV_ID,
        p.EV_AUD_Event_Audience,
        a.EV_AUD_PositedAt,
        a.EV_AUD_Reliability
    FROM
        [attributes].[EV_AUD_Event_Audience_Posit] p
    JOIN
        [attributes].[EV_AUD_Event_Audience_Annex] a
    ON
        a.EV_AUD_ID = p.EV_AUD_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_AUD_Event_Audience]
    ON [attributes].[EV_AUD_Event_Audience] (
        EV_AUD_EV_ID asc,
        EV_AUD_PositedAt desc,
        EV_AUD_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('attributes.EV_AUD_Event_Audience', 'V')
    AND
        x.name = 'pkEV_AUD_Event_Audience'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'EV_AUD_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_AUD_Event_Audience]
    ON [attributes].[EV_AUD_Event_Audience] (
        EV_AUD_EV_ID asc,
        EV_AUD_PositedAt desc,
        EV_AUD_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue assembled view of the posit and annex tables,
-- pkEV_REV_Event_Revenue optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_REV_Event_Revenue', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [attributes].[EV_REV_Event_Revenue]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_EV_REV,
        p.EV_REV_ID,
        p.EV_REV_EV_ID,
        p.EV_REV_Event_Revenue,
        a.EV_REV_PositedAt,
        a.EV_REV_Reliability
    FROM
        [attributes].[EV_REV_Event_Revenue_Posit] p
    JOIN
        [attributes].[EV_REV_Event_Revenue_Annex] a
    ON
        a.EV_REV_ID = p.EV_REV_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_REV_Event_Revenue]
    ON [attributes].[EV_REV_Event_Revenue] (
        EV_REV_EV_ID asc,
        EV_REV_PositedAt desc,
        EV_REV_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('attributes.EV_REV_Event_Revenue', 'V')
    AND
        x.name = 'pkEV_REV_Event_Revenue'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'EV_REV_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_REV_Event_Revenue]
    ON [attributes].[EV_REV_Event_Revenue] (
        EV_REV_EV_ID asc,
        EV_REV_PositedAt desc,
        EV_REV_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- EV_STA_Event_Status assembled view of the posit and annex tables,
-- pkEV_STA_Event_Status optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_STA_Event_Status', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [attributes].[EV_STA_Event_Status]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_EV_STA,
        p.EV_STA_ID,
        p.EV_STA_EV_ID,
        p.EV_STA_Event_Status,
        p.EV_STA_ChangedAt,
        a.EV_STA_PositedAt,
        a.EV_STA_Reliability
    FROM
        [attributes].[EV_STA_Event_Status_Posit] p
    JOIN
        [attributes].[EV_STA_Event_Status_Annex] a
    ON
        a.EV_STA_ID = p.EV_STA_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_STA_Event_Status]
    ON [attributes].[EV_STA_Event_Status] (
        EV_STA_EV_ID asc,
        EV_STA_ChangedAt desc,
        EV_STA_PositedAt desc,
        EV_STA_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('attributes.EV_STA_Event_Status', 'V')
    AND
        x.name = 'pkEV_STA_Event_Status'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'EV_STA_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_STA_Event_Status]
    ON [attributes].[EV_STA_Event_Status] (
        EV_STA_EV_ID asc,
        EV_STA_ChangedAt desc,
        EV_STA_PositedAt desc,
        EV_STA_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization assembled view of the posit and annex tables,
-- pkEV_UTL_Event_Utilization optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_UTL_Event_Utilization', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [attributes].[EV_UTL_Event_Utilization]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_EV_UTL,
        p.EV_UTL_ID,
        p.EV_UTL_EV_ID,
        p.EV_UTL_UTL_ID,
        a.EV_UTL_PositedAt,
        a.EV_UTL_Reliability
    FROM
        [attributes].[EV_UTL_Event_Utilization_Posit] p
    JOIN
        [attributes].[EV_UTL_Event_Utilization_Annex] a
    ON
        a.EV_UTL_ID = p.EV_UTL_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_UTL_Event_Utilization]
    ON [attributes].[EV_UTL_Event_Utilization] (
        EV_UTL_EV_ID asc,
        EV_UTL_PositedAt desc,
        EV_UTL_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('attributes.EV_UTL_Event_Utilization', 'V')
    AND
        x.name = 'pkEV_UTL_Event_Utilization'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'EV_UTL_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_UTL_Event_Utilization]
    ON [attributes].[EV_UTL_Event_Utilization] (
        EV_UTL_EV_ID asc,
        EV_UTL_PositedAt desc,
        EV_UTL_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- EV_LVL_Event_Level assembled view of the posit and annex tables,
-- pkEV_LVL_Event_Level optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.EV_LVL_Event_Level', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [attributes].[EV_LVL_Event_Level]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_EV_LVL,
        p.EV_LVL_ID,
        p.EV_LVL_EV_ID,
        p.EV_LVL_PLV_ID,
        p.EV_LVL_ChangedAt,
        a.EV_LVL_PositedAt,
        a.EV_LVL_Reliability
    FROM
        [attributes].[EV_LVL_Event_Level_Posit] p
    JOIN
        [attributes].[EV_LVL_Event_Level_Annex] a
    ON
        a.EV_LVL_ID = p.EV_LVL_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_LVL_Event_Level]
    ON [attributes].[EV_LVL_Event_Level] (
        EV_LVL_EV_ID asc,
        EV_LVL_ChangedAt desc,
        EV_LVL_PositedAt desc,
        EV_LVL_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('attributes.EV_LVL_Event_Level', 'V')
    AND
        x.name = 'pkEV_LVL_Event_Level'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'EV_LVL_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_LVL_Event_Level]
    ON [attributes].[EV_LVL_Event_Level] (
        EV_LVL_EV_ID asc,
        EV_LVL_ChangedAt desc,
        EV_LVL_PositedAt desc,
        EV_LVL_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name assembled view of the posit and annex tables,
-- pkST_NAM_Stage_Name optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_NAM_Stage_Name', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [attributes].[ST_NAM_Stage_Name]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_ST_NAM,
        p.ST_NAM_ID,
        p.ST_NAM_ST_ID,
        p.ST_NAM_Stage_Name,
        p.ST_NAM_ChangedAt,
        a.ST_NAM_PositedAt,
        a.ST_NAM_Reliability
    FROM
        [attributes].[ST_NAM_Stage_Name_Posit] p
    JOIN
        [attributes].[ST_NAM_Stage_Name_Annex] a
    ON
        a.ST_NAM_ID = p.ST_NAM_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_NAM_Stage_Name]
    ON [attributes].[ST_NAM_Stage_Name] (
        ST_NAM_ST_ID asc,
        ST_NAM_ChangedAt desc,
        ST_NAM_PositedAt desc,
        ST_NAM_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('attributes.ST_NAM_Stage_Name', 'V')
    AND
        x.name = 'pkST_NAM_Stage_Name'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'ST_NAM_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_NAM_Stage_Name]
    ON [attributes].[ST_NAM_Stage_Name] (
        ST_NAM_ST_ID asc,
        ST_NAM_ChangedAt desc,
        ST_NAM_PositedAt desc,
        ST_NAM_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location assembled view of the posit and annex tables,
-- pkST_LOC_Stage_Location optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_LOC_Stage_Location', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [attributes].[ST_LOC_Stage_Location]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_ST_LOC,
        p.ST_LOC_ID,
        p.ST_LOC_ST_ID,
        p.ST_LOC_Checksum,
        p.ST_LOC_Stage_Location,
        a.ST_LOC_PositedAt,
        a.ST_LOC_Reliability
    FROM
        [attributes].[ST_LOC_Stage_Location_Posit] p
    JOIN
        [attributes].[ST_LOC_Stage_Location_Annex] a
    ON
        a.ST_LOC_ID = p.ST_LOC_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_LOC_Stage_Location]
    ON [attributes].[ST_LOC_Stage_Location] (
        ST_LOC_ST_ID asc,
        ST_LOC_PositedAt desc,
        ST_LOC_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('attributes.ST_LOC_Stage_Location', 'V')
    AND
        x.name = 'pkST_LOC_Stage_Location'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'ST_LOC_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_LOC_Stage_Location]
    ON [attributes].[ST_LOC_Stage_Location] (
        ST_LOC_ST_ID asc,
        ST_LOC_PositedAt desc,
        ST_LOC_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average assembled view of the posit and annex tables,
-- pkST_AVG_Stage_Average optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_AVG_Stage_Average', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [attributes].[ST_AVG_Stage_Average]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_ST_AVG,
        p.ST_AVG_ID,
        p.ST_AVG_ST_ID,
        p.ST_AVG_UTL_ID,
        p.ST_AVG_ChangedAt,
        a.ST_AVG_PositedAt,
        a.ST_AVG_Reliability
    FROM
        [attributes].[ST_AVG_Stage_Average_Posit] p
    JOIN
        [attributes].[ST_AVG_Stage_Average_Annex] a
    ON
        a.ST_AVG_ID = p.ST_AVG_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_AVG_Stage_Average]
    ON [attributes].[ST_AVG_Stage_Average] (
        ST_AVG_ST_ID asc,
        ST_AVG_ChangedAt desc,
        ST_AVG_PositedAt desc,
        ST_AVG_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('attributes.ST_AVG_Stage_Average', 'V')
    AND
        x.name = 'pkST_AVG_Stage_Average'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'ST_AVG_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_AVG_Stage_Average]
    ON [attributes].[ST_AVG_Stage_Average] (
        ST_AVG_ST_ID asc,
        ST_AVG_ChangedAt desc,
        ST_AVG_PositedAt desc,
        ST_AVG_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum assembled view of the posit and annex tables,
-- pkST_MIN_Stage_Minimum optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.ST_MIN_Stage_Minimum', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [attributes].[ST_MIN_Stage_Minimum]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_ST_MIN,
        p.ST_MIN_ID,
        p.ST_MIN_ST_ID,
        p.ST_MIN_UTL_ID,
        a.ST_MIN_PositedAt,
        a.ST_MIN_Reliability
    FROM
        [attributes].[ST_MIN_Stage_Minimum_Posit] p
    JOIN
        [attributes].[ST_MIN_Stage_Minimum_Annex] a
    ON
        a.ST_MIN_ID = p.ST_MIN_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_MIN_Stage_Minimum]
    ON [attributes].[ST_MIN_Stage_Minimum] (
        ST_MIN_ST_ID asc,
        ST_MIN_PositedAt desc,
        ST_MIN_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('attributes.ST_MIN_Stage_Minimum', 'V')
    AND
        x.name = 'pkST_MIN_Stage_Minimum'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'ST_MIN_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_MIN_Stage_Minimum]
    ON [attributes].[ST_MIN_Stage_Minimum] (
        ST_MIN_ST_ID asc,
        ST_MIN_PositedAt desc,
        ST_MIN_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name assembled view of the posit and annex tables,
-- pkAC_NAM_Actor_Name optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_NAM_Actor_Name', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [attributes].[AC_NAM_Actor_Name]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_AC_NAM,
        p.AC_NAM_ID,
        p.AC_NAM_AC_ID,
        p.AC_NAM_Actor_Name,
        p.AC_NAM_ChangedAt,
        a.AC_NAM_PositedAt,
        a.AC_NAM_Reliability
    FROM
        [attributes].[AC_NAM_Actor_Name_Posit] p
    JOIN
        [attributes].[AC_NAM_Actor_Name_Annex] a
    ON
        a.AC_NAM_ID = p.AC_NAM_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_NAM_Actor_Name]
    ON [attributes].[AC_NAM_Actor_Name] (
        AC_NAM_AC_ID asc,
        AC_NAM_ChangedAt desc,
        AC_NAM_PositedAt desc,
        AC_NAM_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('attributes.AC_NAM_Actor_Name', 'V')
    AND
        x.name = 'pkAC_NAM_Actor_Name'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'AC_NAM_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_NAM_Actor_Name]
    ON [attributes].[AC_NAM_Actor_Name] (
        AC_NAM_AC_ID asc,
        AC_NAM_ChangedAt desc,
        AC_NAM_PositedAt desc,
        AC_NAM_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender assembled view of the posit and annex tables,
-- pkAC_GEN_Actor_Gender optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_GEN_Actor_Gender', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [attributes].[AC_GEN_Actor_Gender]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_AC_GEN,
        p.AC_GEN_ID,
        p.AC_GEN_AC_ID,
        p.AC_GEN_GEN_ID,
        a.AC_GEN_PositedAt,
        a.AC_GEN_Reliability
    FROM
        [attributes].[AC_GEN_Actor_Gender_Posit] p
    JOIN
        [attributes].[AC_GEN_Actor_Gender_Annex] a
    ON
        a.AC_GEN_ID = p.AC_GEN_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_GEN_Actor_Gender]
    ON [attributes].[AC_GEN_Actor_Gender] (
        AC_GEN_AC_ID asc,
        AC_GEN_PositedAt desc,
        AC_GEN_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('attributes.AC_GEN_Actor_Gender', 'V')
    AND
        x.name = 'pkAC_GEN_Actor_Gender'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'AC_GEN_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_GEN_Actor_Gender]
    ON [attributes].[AC_GEN_Actor_Gender] (
        AC_GEN_AC_ID asc,
        AC_GEN_PositedAt desc,
        AC_GEN_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel assembled view of the posit and annex tables,
-- pkAC_PLV_Actor_ProfessionalLevel optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.AC_PLV_Actor_ProfessionalLevel', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [attributes].[AC_PLV_Actor_ProfessionalLevel]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_AC_PLV,
        p.AC_PLV_ID,
        p.AC_PLV_AC_ID,
        p.AC_PLV_PLV_ID,
        p.AC_PLV_ChangedAt,
        a.AC_PLV_PositedAt,
        a.AC_PLV_Reliability
    FROM
        [attributes].[AC_PLV_Actor_ProfessionalLevel_Posit] p
    JOIN
        [attributes].[AC_PLV_Actor_ProfessionalLevel_Annex] a
    ON
        a.AC_PLV_ID = p.AC_PLV_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_PLV_Actor_ProfessionalLevel]
    ON [attributes].[AC_PLV_Actor_ProfessionalLevel] (
        AC_PLV_AC_ID asc,
        AC_PLV_ChangedAt desc,
        AC_PLV_PositedAt desc,
        AC_PLV_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('attributes.AC_PLV_Actor_ProfessionalLevel', 'V')
    AND
        x.name = 'pkAC_PLV_Actor_ProfessionalLevel'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'AC_PLV_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_PLV_Actor_ProfessionalLevel]
    ON [attributes].[AC_PLV_Actor_ProfessionalLevel] (
        AC_PLV_AC_ID asc,
        AC_PLV_ChangedAt desc,
        AC_PLV_PositedAt desc,
        AC_PLV_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name assembled view of the posit and annex tables,
-- pkPR_NAM_Program_Name optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.PR_NAM_Program_Name', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [attributes].[PR_NAM_Program_Name]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_PR_NAM,
        p.PR_NAM_ID,
        p.PR_NAM_PR_ID,
        p.PR_NAM_Program_Name,
        a.PR_NAM_PositedAt,
        a.PR_NAM_Reliability
    FROM
        [attributes].[PR_NAM_Program_Name_Posit] p
    JOIN
        [attributes].[PR_NAM_Program_Name_Annex] a
    ON
        a.PR_NAM_ID = p.PR_NAM_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkPR_NAM_Program_Name]
    ON [attributes].[PR_NAM_Program_Name] (
        PR_NAM_PR_ID asc,
        PR_NAM_PositedAt desc,
        PR_NAM_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('attributes.PR_NAM_Program_Name', 'V')
    AND
        x.name = 'pkPR_NAM_Program_Name'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'PR_NAM_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkPR_NAM_Program_Name]
    ON [attributes].[PR_NAM_Program_Name] (
        PR_NAM_PR_ID asc,
        PR_NAM_PositedAt desc,
        PR_NAM_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length assembled view of the posit and annex tables,
-- pkPR_LEN_Program_Length optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.PR_LEN_Program_Length', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [attributes].[PR_LEN_Program_Length]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_PR_LEN,
        p.PR_LEN_ID,
        p.PR_LEN_PR_ID,
        p.PR_LEN_Program_Length,
        p.PR_LEN_ChangedAt,
        a.PR_LEN_PositedAt,
        a.PR_LEN_Reliability
    FROM
        [attributes].[PR_LEN_Program_Length_Posit] p
    JOIN
        [attributes].[PR_LEN_Program_Length_Annex] a
    ON
        a.PR_LEN_ID = p.PR_LEN_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkPR_LEN_Program_Length]
    ON [attributes].[PR_LEN_Program_Length] (
        PR_LEN_PR_ID asc,
        PR_LEN_ChangedAt desc,
        PR_LEN_PositedAt desc,
        PR_LEN_Reliability desc
    );
    ');
END
GO
-- the constraint of an assembled view made before corrections retracted what they correct has no reliability
IF EXISTS (
    SELECT TOP 1
        42
    FROM
        sys.indexes x
    WHERE
        x.object_id = Object_ID('attributes.PR_LEN_Program_Length', 'V')
    AND
        x.name = 'pkPR_LEN_Program_Length'
    AND NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            sys.index_columns c
        JOIN
            sys.columns k
        ON
            k.object_id = c.object_id
        AND
            k.column_id = c.column_id
        WHERE
            c.object_id = x.object_id
        AND
            c.index_id = x.index_id
        AND
            k.name = 'PR_LEN_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkPR_LEN_Program_Length]
    ON [attributes].[PR_LEN_Program_Length] (
        PR_LEN_PR_ID asc,
        PR_LEN_ChangedAt desc,
        PR_LEN_PositedAt desc,
        PR_LEN_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
