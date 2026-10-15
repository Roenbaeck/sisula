-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines the posit and annex table of the attribute.
-- It can be used to maintain entity integrity through a primary key, which cannot be
-- defined elsewhere.
--
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- EV_QTY_Event_Quantity assembled view of the posit and annex tables,
-- pkEV_QTY_Event_Quantity optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_QTY_Event_Quantity', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[EV_QTY_Event_Quantity]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_EV_QTY,
        p.EV_QTY_ID,
        p.EV_QTY_EV_ID,
        p.EV_QTY_Event_Quantity,
        a.EV_QTY_PositedAt,
        a.EV_QTY_Reliability
    FROM
        [dbo].[EV_QTY_Event_Quantity_Posit] p
    JOIN
        [dbo].[EV_QTY_Event_Quantity_Annex] a
    ON
        a.EV_QTY_ID = p.EV_QTY_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_QTY_Event_Quantity]
    ON [dbo].[EV_QTY_Event_Quantity] (
        EV_QTY_EV_ID asc,
        EV_QTY_PositedAt desc,
        EV_QTY_Reliability desc
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
        x.object_id = Object_ID('dbo.EV_QTY_Event_Quantity', 'V')
    AND
        x.name = 'pkEV_QTY_Event_Quantity'
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
            k.name = 'EV_QTY_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_QTY_Event_Quantity]
    ON [dbo].[EV_QTY_Event_Quantity] (
        EV_QTY_EV_ID asc,
        EV_QTY_PositedAt desc,
        EV_QTY_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- EV_PLC_Event_Place assembled view of the posit and annex tables,
-- pkEV_PLC_Event_Place optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_PLC_Event_Place', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[EV_PLC_Event_Place]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_EV_PLC,
        p.EV_PLC_ID,
        p.EV_PLC_EV_ID,
        p.EV_PLC_Event_Place,
        p.EV_PLC_ChangedAt,
        a.EV_PLC_PositedAt,
        a.EV_PLC_Reliability
    FROM
        [dbo].[EV_PLC_Event_Place_Posit] p
    JOIN
        [dbo].[EV_PLC_Event_Place_Annex] a
    ON
        a.EV_PLC_ID = p.EV_PLC_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_PLC_Event_Place]
    ON [dbo].[EV_PLC_Event_Place] (
        EV_PLC_EV_ID asc,
        EV_PLC_ChangedAt desc,
        EV_PLC_PositedAt desc,
        EV_PLC_Reliability desc
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
        x.object_id = Object_ID('dbo.EV_PLC_Event_Place', 'V')
    AND
        x.name = 'pkEV_PLC_Event_Place'
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
            k.name = 'EV_PLC_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_PLC_Event_Place]
    ON [dbo].[EV_PLC_Event_Place] (
        EV_PLC_EV_ID asc,
        EV_PLC_ChangedAt desc,
        EV_PLC_PositedAt desc,
        EV_PLC_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_NAM_Subject_Name assembled view of the posit and annex tables,
-- pkSU_NAM_Subject_Name optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_NAM_Subject_Name', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_NAM_Subject_Name]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_NAM,
        p.SU_NAM_ID,
        p.SU_NAM_SU_ID,
        p.SU_NAM_Subject_Name,
        a.SU_NAM_PositedAt,
        a.SU_NAM_Reliability
    FROM
        [dbo].[SU_NAM_Subject_Name_Posit] p
    JOIN
        [dbo].[SU_NAM_Subject_Name_Annex] a
    ON
        a.SU_NAM_ID = p.SU_NAM_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_NAM_Subject_Name]
    ON [dbo].[SU_NAM_Subject_Name] (
        SU_NAM_SU_ID asc,
        SU_NAM_PositedAt desc,
        SU_NAM_Reliability desc
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
        x.object_id = Object_ID('dbo.SU_NAM_Subject_Name', 'V')
    AND
        x.name = 'pkSU_NAM_Subject_Name'
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
            k.name = 'SU_NAM_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_NAM_Subject_Name]
    ON [dbo].[SU_NAM_Subject_Name] (
        SU_NAM_SU_ID asc,
        SU_NAM_PositedAt desc,
        SU_NAM_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_COD_Subject_Code assembled view of the posit and annex tables,
-- pkSU_COD_Subject_Code optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_COD_Subject_Code', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_COD_Subject_Code]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_COD,
        p.SU_COD_ID,
        p.SU_COD_SU_ID,
        p.SU_COD_Subject_Code,
        a.SU_COD_PositedAt,
        a.SU_COD_Reliability
    FROM
        [dbo].[SU_COD_Subject_Code_Posit] p
    JOIN
        [dbo].[SU_COD_Subject_Code_Annex] a
    ON
        a.SU_COD_ID = p.SU_COD_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_COD_Subject_Code]
    ON [dbo].[SU_COD_Subject_Code] (
        SU_COD_SU_ID asc,
        SU_COD_PositedAt desc,
        SU_COD_Reliability desc
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
        x.object_id = Object_ID('dbo.SU_COD_Subject_Code', 'V')
    AND
        x.name = 'pkSU_COD_Subject_Code'
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
            k.name = 'SU_COD_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_COD_Subject_Code]
    ON [dbo].[SU_COD_Subject_Code] (
        SU_COD_SU_ID asc,
        SU_COD_PositedAt desc,
        SU_COD_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_GRD_Subject_Grade assembled view of the posit and annex tables,
-- pkSU_GRD_Subject_Grade optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_GRD_Subject_Grade', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_GRD_Subject_Grade]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_GRD,
        p.SU_GRD_ID,
        p.SU_GRD_SU_ID,
        p.SU_GRD_GRD_ID,
        a.SU_GRD_PositedAt,
        a.SU_GRD_Reliability
    FROM
        [dbo].[SU_GRD_Subject_Grade_Posit] p
    JOIN
        [dbo].[SU_GRD_Subject_Grade_Annex] a
    ON
        a.SU_GRD_ID = p.SU_GRD_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_GRD_Subject_Grade]
    ON [dbo].[SU_GRD_Subject_Grade] (
        SU_GRD_SU_ID asc,
        SU_GRD_PositedAt desc,
        SU_GRD_Reliability desc
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
        x.object_id = Object_ID('dbo.SU_GRD_Subject_Grade', 'V')
    AND
        x.name = 'pkSU_GRD_Subject_Grade'
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
            k.name = 'SU_GRD_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_GRD_Subject_Grade]
    ON [dbo].[SU_GRD_Subject_Grade] (
        SU_GRD_SU_ID asc,
        SU_GRD_PositedAt desc,
        SU_GRD_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_NOT_Subject_Note assembled view of the posit and annex tables,
-- pkSU_NOT_Subject_Note optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_NOT_Subject_Note', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_NOT_Subject_Note]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_NOT,
        p.SU_NOT_ID,
        p.SU_NOT_SU_ID,
        p.SU_NOT_Checksum,
        p.SU_NOT_Subject_Note,
        a.SU_NOT_PositedAt,
        a.SU_NOT_Reliability
    FROM
        [dbo].[SU_NOT_Subject_Note_Posit] p
    JOIN
        [dbo].[SU_NOT_Subject_Note_Annex] a
    ON
        a.SU_NOT_ID = p.SU_NOT_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_NOT_Subject_Note]
    ON [dbo].[SU_NOT_Subject_Note] (
        SU_NOT_SU_ID asc,
        SU_NOT_PositedAt desc,
        SU_NOT_Reliability desc
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
        x.object_id = Object_ID('dbo.SU_NOT_Subject_Note', 'V')
    AND
        x.name = 'pkSU_NOT_Subject_Note'
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
            k.name = 'SU_NOT_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_NOT_Subject_Note]
    ON [dbo].[SU_NOT_Subject_Note] (
        SU_NOT_SU_ID asc,
        SU_NOT_PositedAt desc,
        SU_NOT_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_TTL_Subject_Title assembled view of the posit and annex tables,
-- pkSU_TTL_Subject_Title optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_TTL_Subject_Title', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_TTL_Subject_Title]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_TTL,
        p.SU_TTL_ID,
        p.SU_TTL_SU_ID,
        p.SU_TTL_Subject_Title,
        p.SU_TTL_ChangedAt,
        a.SU_TTL_PositedAt,
        a.SU_TTL_Reliability
    FROM
        [dbo].[SU_TTL_Subject_Title_Posit] p
    JOIN
        [dbo].[SU_TTL_Subject_Title_Annex] a
    ON
        a.SU_TTL_ID = p.SU_TTL_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_TTL_Subject_Title]
    ON [dbo].[SU_TTL_Subject_Title] (
        SU_TTL_SU_ID asc,
        SU_TTL_ChangedAt desc,
        SU_TTL_PositedAt desc,
        SU_TTL_Reliability desc
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
        x.object_id = Object_ID('dbo.SU_TTL_Subject_Title', 'V')
    AND
        x.name = 'pkSU_TTL_Subject_Title'
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
            k.name = 'SU_TTL_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_TTL_Subject_Title]
    ON [dbo].[SU_TTL_Subject_Title] (
        SU_TTL_SU_ID asc,
        SU_TTL_ChangedAt desc,
        SU_TTL_PositedAt desc,
        SU_TTL_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_STA_Subject_State assembled view of the posit and annex tables,
-- pkSU_STA_Subject_State optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_STA_Subject_State', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_STA_Subject_State]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_STA,
        p.SU_STA_ID,
        p.SU_STA_SU_ID,
        p.SU_STA_Subject_State,
        p.SU_STA_ChangedAt,
        a.SU_STA_PositedAt,
        a.SU_STA_Reliability
    FROM
        [dbo].[SU_STA_Subject_State_Posit] p
    JOIN
        [dbo].[SU_STA_Subject_State_Annex] a
    ON
        a.SU_STA_ID = p.SU_STA_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_STA_Subject_State]
    ON [dbo].[SU_STA_Subject_State] (
        SU_STA_SU_ID asc,
        SU_STA_ChangedAt desc,
        SU_STA_PositedAt desc,
        SU_STA_Reliability desc
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
        x.object_id = Object_ID('dbo.SU_STA_Subject_State', 'V')
    AND
        x.name = 'pkSU_STA_Subject_State'
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
            k.name = 'SU_STA_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_STA_Subject_State]
    ON [dbo].[SU_STA_Subject_State] (
        SU_STA_SU_ID asc,
        SU_STA_ChangedAt desc,
        SU_STA_PositedAt desc,
        SU_STA_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_LBL_Subject_Label assembled view of the posit and annex tables,
-- pkSU_LBL_Subject_Label optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_LBL_Subject_Label', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_LBL_Subject_Label]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_LBL,
        p.SU_LBL_ID,
        p.SU_LBL_SU_ID,
        p.SU_LBL_Subject_Label,
        p.SU_LBL_ChangedAt,
        a.SU_LBL_PositedAt,
        a.SU_LBL_Reliability
    FROM
        [dbo].[SU_LBL_Subject_Label_Posit] p
    JOIN
        [dbo].[SU_LBL_Subject_Label_Annex] a
    ON
        a.SU_LBL_ID = p.SU_LBL_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_LBL_Subject_Label]
    ON [dbo].[SU_LBL_Subject_Label] (
        SU_LBL_SU_ID asc,
        SU_LBL_ChangedAt desc,
        SU_LBL_PositedAt desc,
        SU_LBL_Reliability desc
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
        x.object_id = Object_ID('dbo.SU_LBL_Subject_Label', 'V')
    AND
        x.name = 'pkSU_LBL_Subject_Label'
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
            k.name = 'SU_LBL_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_LBL_Subject_Label]
    ON [dbo].[SU_LBL_Subject_Label] (
        SU_LBL_SU_ID asc,
        SU_LBL_ChangedAt desc,
        SU_LBL_PositedAt desc,
        SU_LBL_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_TAG_Subject_Tag assembled view of the posit and annex tables,
-- pkSU_TAG_Subject_Tag optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_TAG_Subject_Tag', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_TAG_Subject_Tag]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_TAG,
        p.SU_TAG_ID,
        p.SU_TAG_SU_ID,
        p.SU_TAG_Subject_Tag,
        p.SU_TAG_ChangedAt,
        a.SU_TAG_PositedAt,
        a.SU_TAG_Reliability
    FROM
        [dbo].[SU_TAG_Subject_Tag_Posit] p
    JOIN
        [dbo].[SU_TAG_Subject_Tag_Annex] a
    ON
        a.SU_TAG_ID = p.SU_TAG_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_TAG_Subject_Tag]
    ON [dbo].[SU_TAG_Subject_Tag] (
        SU_TAG_SU_ID asc,
        SU_TAG_ChangedAt desc,
        SU_TAG_PositedAt desc,
        SU_TAG_Reliability desc
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
        x.object_id = Object_ID('dbo.SU_TAG_Subject_Tag', 'V')
    AND
        x.name = 'pkSU_TAG_Subject_Tag'
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
            k.name = 'SU_TAG_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_TAG_Subject_Tag]
    ON [dbo].[SU_TAG_Subject_Tag] (
        SU_TAG_SU_ID asc,
        SU_TAG_ChangedAt desc,
        SU_TAG_PositedAt desc,
        SU_TAG_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_LVL_Subject_Level assembled view of the posit and annex tables,
-- pkSU_LVL_Subject_Level optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_LVL_Subject_Level', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_LVL_Subject_Level]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_LVL,
        p.SU_LVL_ID,
        p.SU_LVL_SU_ID,
        p.SU_LVL_GRD_ID,
        p.SU_LVL_ChangedAt,
        a.SU_LVL_PositedAt,
        a.SU_LVL_Reliability
    FROM
        [dbo].[SU_LVL_Subject_Level_Posit] p
    JOIN
        [dbo].[SU_LVL_Subject_Level_Annex] a
    ON
        a.SU_LVL_ID = p.SU_LVL_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_LVL_Subject_Level]
    ON [dbo].[SU_LVL_Subject_Level] (
        SU_LVL_SU_ID asc,
        SU_LVL_ChangedAt desc,
        SU_LVL_PositedAt desc,
        SU_LVL_Reliability desc
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
        x.object_id = Object_ID('dbo.SU_LVL_Subject_Level', 'V')
    AND
        x.name = 'pkSU_LVL_Subject_Level'
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
            k.name = 'SU_LVL_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_LVL_Subject_Level]
    ON [dbo].[SU_LVL_Subject_Level] (
        SU_LVL_SU_ID asc,
        SU_LVL_ChangedAt desc,
        SU_LVL_PositedAt desc,
        SU_LVL_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_TXT_Subject_Text assembled view of the posit and annex tables,
-- pkSU_TXT_Subject_Text optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_TXT_Subject_Text', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_TXT_Subject_Text]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_TXT,
        p.SU_TXT_ID,
        p.SU_TXT_SU_ID,
        p.SU_TXT_Checksum,
        p.SU_TXT_Subject_Text,
        p.SU_TXT_ChangedAt,
        a.SU_TXT_PositedAt,
        a.SU_TXT_Reliability
    FROM
        [dbo].[SU_TXT_Subject_Text_Posit] p
    JOIN
        [dbo].[SU_TXT_Subject_Text_Annex] a
    ON
        a.SU_TXT_ID = p.SU_TXT_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_TXT_Subject_Text]
    ON [dbo].[SU_TXT_Subject_Text] (
        SU_TXT_SU_ID asc,
        SU_TXT_ChangedAt desc,
        SU_TXT_PositedAt desc,
        SU_TXT_Reliability desc
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
        x.object_id = Object_ID('dbo.SU_TXT_Subject_Text', 'V')
    AND
        x.name = 'pkSU_TXT_Subject_Text'
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
            k.name = 'SU_TXT_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_TXT_Subject_Text]
    ON [dbo].[SU_TXT_Subject_Text] (
        SU_TXT_SU_ID asc,
        SU_TXT_ChangedAt desc,
        SU_TXT_PositedAt desc,
        SU_TXT_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_ASR_Subject_Assessment assembled view of the posit and annex tables,
-- pkSU_ASR_Subject_Assessment optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_ASR_Subject_Assessment', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_ASR_Subject_Assessment]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_ASR,
        p.SU_ASR_ID,
        p.SU_ASR_SU_ID,
        p.SU_ASR_Subject_Assessment,
        p.SU_ASR_ChangedAt,
        a.SU_ASR_PositedAt,
        a.SU_ASR_Reliability
    FROM
        [dbo].[SU_ASR_Subject_Assessment_Posit] p
    JOIN
        [dbo].[SU_ASR_Subject_Assessment_Annex] a
    ON
        a.SU_ASR_ID = p.SU_ASR_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_ASR_Subject_Assessment]
    ON [dbo].[SU_ASR_Subject_Assessment] (
        SU_ASR_SU_ID asc,
        SU_ASR_ChangedAt desc,
        SU_ASR_PositedAt desc,
        SU_ASR_Reliability desc
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
        x.object_id = Object_ID('dbo.SU_ASR_Subject_Assessment', 'V')
    AND
        x.name = 'pkSU_ASR_Subject_Assessment'
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
            k.name = 'SU_ASR_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_ASR_Subject_Assessment]
    ON [dbo].[SU_ASR_Subject_Assessment] (
        SU_ASR_SU_ID asc,
        SU_ASR_ChangedAt desc,
        SU_ASR_PositedAt desc,
        SU_ASR_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- SU_ERS_Subject_Erasable assembled view of the posit and annex tables,
-- pkSU_ERS_Subject_Erasable optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_ERS_Subject_Erasable', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_ERS_Subject_Erasable]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_ERS,
        p.SU_ERS_ID,
        p.SU_ERS_SU_ID,
        p.SU_ERS_Subject_Erasable,
        p.SU_ERS_ChangedAt,
        a.SU_ERS_PositedAt,
        a.SU_ERS_Reliability
    FROM
        [dbo].[SU_ERS_Subject_Erasable_Posit] p
    JOIN
        [dbo].[SU_ERS_Subject_Erasable_Annex] a
    ON
        a.SU_ERS_ID = p.SU_ERS_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_ERS_Subject_Erasable]
    ON [dbo].[SU_ERS_Subject_Erasable] (
        SU_ERS_SU_ID asc,
        SU_ERS_ChangedAt desc,
        SU_ERS_PositedAt desc,
        SU_ERS_Reliability desc
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
        x.object_id = Object_ID('dbo.SU_ERS_Subject_Erasable', 'V')
    AND
        x.name = 'pkSU_ERS_Subject_Erasable'
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
            k.name = 'SU_ERS_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_ERS_Subject_Erasable]
    ON [dbo].[SU_ERS_Subject_Erasable] (
        SU_ERS_SU_ID asc,
        SU_ERS_ChangedAt desc,
        SU_ERS_PositedAt desc,
        SU_ERS_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
-- Attribute assembled view -------------------------------------------------------------------------------------------
-- OB_NAM_Object_Name assembled view of the posit and annex tables,
-- pkOB_NAM_Object_Name optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OB_NAM_Object_Name', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[OB_NAM_Object_Name]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_OB_NAM,
        p.OB_NAM_ID,
        p.OB_NAM_OB_ID,
        p.OB_NAM_Object_Name,
        a.OB_NAM_PositedAt,
        a.OB_NAM_Reliability
    FROM
        [dbo].[OB_NAM_Object_Name_Posit] p
    JOIN
        [dbo].[OB_NAM_Object_Name_Annex] a
    ON
        a.OB_NAM_ID = p.OB_NAM_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent: one posit at a time is asserted,
    -- and a correction retracts what it corrects at the same positing time
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkOB_NAM_Object_Name]
    ON [dbo].[OB_NAM_Object_Name] (
        OB_NAM_OB_ID asc,
        OB_NAM_PositedAt desc,
        OB_NAM_Reliability desc
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
        x.object_id = Object_ID('dbo.OB_NAM_Object_Name', 'V')
    AND
        x.name = 'pkOB_NAM_Object_Name'
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
            k.name = 'OB_NAM_Reliability'
    )
)
BEGIN
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkOB_NAM_Object_Name]
    ON [dbo].[OB_NAM_Object_Name] (
        OB_NAM_OB_ID asc,
        OB_NAM_PositedAt desc,
        OB_NAM_Reliability desc
    )
    WITH (DROP_EXISTING = ON);
    ');
END
GO
