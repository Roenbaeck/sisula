-- ATTRIBUTE RESTATEMENT CONSTRAINTS ----------------------------------------------------------------------------------
--
-- Attributes may be prevented from storing restatements.
-- A restatement is when the same value occurs for two adjacent points
-- in changing time. Note that restatement checking is not done for
-- unreliable information as this could prevent demotion.
--
-- If actual deletes are made, the remaining information will not
-- be checked for restatements.
--
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_SU_STA_Subject_State (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rt_SU_STA_Subject_State', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[rt_SU_STA_Subject_State];
GO
CREATE TRIGGER [dbo].[rt_SU_STA_Subject_State] ON [dbo].[SU_STA_Subject_State_Annex]
AFTER INSERT 
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @SU_STA_Subject_State TABLE (
        SU_STA_ID int not null,
        SU_STA_SU_ID int not null,
        Metadata_SU_STA int not null,
        SU_STA_ChangedAt datetime2 not null,
        SU_STA_PositedAt datetime2 not null,
        SU_STA_Reliability decimal(5,2) not null,
        SU_STA_Subject_State nvarchar(42) not null,
        primary key (
            SU_STA_SU_ID asc, 
            SU_STA_ChangedAt desc,
            SU_STA_PositedAt desc
        ),
        unique (
            SU_STA_ID,
            SU_STA_PositedAt
        )
    );
    INSERT INTO @SU_STA_Subject_State (
        SU_STA_ID,
        SU_STA_SU_ID,
        Metadata_SU_STA,
        SU_STA_ChangedAt,
        SU_STA_PositedAt,
        SU_STA_Reliability,
        SU_STA_Subject_State
    )
    SELECT
        i.SU_STA_ID,
        p.SU_STA_SU_ID,
        i.Metadata_SU_STA,
        p.SU_STA_ChangedAt,
        i.SU_STA_PositedAt,
        i.SU_STA_Reliability,
        p.SU_STA_Subject_State
    FROM 
        inserted i
    JOIN 
        [dbo].[SU_STA_Subject_State_Posit] p
    ON 
        p.SU_STA_ID = i.SU_STA_ID; -- the posit has already been created
    INSERT INTO @SU_STA_Subject_State (
        SU_STA_ID,
        SU_STA_SU_ID,
        Metadata_SU_STA,
        SU_STA_ChangedAt,
        SU_STA_PositedAt,
        SU_STA_Reliability,
        SU_STA_Subject_State
    )
    SELECT
        p.SU_STA_ID,
        p.SU_STA_SU_ID,
        p.Metadata_SU_STA,
        p.SU_STA_ChangedAt,
        p.SU_STA_PositedAt,
        p.SU_STA_Reliability,
        p.SU_STA_Subject_State
    FROM 
        (SELECT DISTINCT SU_STA_SU_ID FROM @SU_STA_Subject_State) i
    JOIN
        [dbo].[SU_STA_Subject_State] p
    ON 
        p.SU_STA_SU_ID = i.SU_STA_SU_ID
    LEFT JOIN 
        @SU_STA_Subject_State x
    ON
        x.SU_STA_ID = p.SU_STA_ID
    AND
        x.SU_STA_PositedAt = p.SU_STA_PositedAt
    WHERE
        x.SU_STA_ID is null;
    -- no need to check retracted information
    DELETE a 
    FROM 
        @SU_STA_Subject_State a
    OUTER APPLY (
        SELECT TOP 1
            x.SU_STA_Reliability
        FROM 
            @SU_STA_Subject_State x
        WHERE
            x.SU_STA_ID = a.SU_STA_ID
        AND
            x.SU_STA_PositedAt < a.SU_STA_PositedAt
        ORDER BY
            x.SU_STA_PositedAt DESC
    ) pre 
    OUTER APPLY (
        SELECT TOP 1
            x.SU_STA_Reliability
        FROM 
            @SU_STA_Subject_State x
        WHERE
            x.SU_STA_ID = a.SU_STA_ID
        AND
            x.SU_STA_PositedAt > a.SU_STA_PositedAt
        ORDER BY
            x.SU_STA_PositedAt ASC
    ) fol 
    WHERE
        (a.SU_STA_Reliability = 1 AND fol.SU_STA_Reliability = 0)
    OR
        (a.SU_STA_Reliability = 0 AND pre.SU_STA_Reliability = 1);
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @SU_STA_Subject_State a
        CROSS APPLY (
            SELECT TOP 1
                h.SU_STA_SU_ID,
                h.SU_STA_ChangedAt,
                h.SU_STA_Subject_State
            FROM 
                @SU_STA_Subject_State h
            WHERE
                h.SU_STA_SU_ID = a.SU_STA_SU_ID
            AND
                h.SU_STA_ChangedAt < a.SU_STA_ChangedAt
            ORDER BY 
                h.SU_STA_ChangedAt DESC,
                h.SU_STA_PositedAt DESC
        ) pre
        WHERE
            a.SU_STA_Subject_State = pre.SU_STA_Subject_State
        AND
            a.SU_STA_Reliability = 1
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in SU_STA_Subject_State for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_SU_LBL_Subject_Label (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rt_SU_LBL_Subject_Label', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[rt_SU_LBL_Subject_Label];
GO
CREATE TRIGGER [dbo].[rt_SU_LBL_Subject_Label] ON [dbo].[SU_LBL_Subject_Label_Annex]
AFTER INSERT 
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @SU_LBL_Subject_Label TABLE (
        SU_LBL_ID int not null,
        SU_LBL_SU_ID int not null,
        Metadata_SU_LBL int not null,
        SU_LBL_ChangedAt datetime2 not null,
        SU_LBL_PositedAt datetime2 not null,
        SU_LBL_Reliability decimal(5,2) not null,
        SU_LBL_Subject_Label nvarchar(42) not null,
        primary key (
            SU_LBL_SU_ID asc, 
            SU_LBL_ChangedAt desc,
            SU_LBL_PositedAt desc
        ),
        unique (
            SU_LBL_ID,
            SU_LBL_PositedAt
        )
    );
    INSERT INTO @SU_LBL_Subject_Label (
        SU_LBL_ID,
        SU_LBL_SU_ID,
        Metadata_SU_LBL,
        SU_LBL_ChangedAt,
        SU_LBL_PositedAt,
        SU_LBL_Reliability,
        SU_LBL_Subject_Label
    )
    SELECT
        i.SU_LBL_ID,
        p.SU_LBL_SU_ID,
        i.Metadata_SU_LBL,
        p.SU_LBL_ChangedAt,
        i.SU_LBL_PositedAt,
        i.SU_LBL_Reliability,
        p.SU_LBL_Subject_Label
    FROM 
        inserted i
    JOIN 
        [dbo].[SU_LBL_Subject_Label_Posit] p
    ON 
        p.SU_LBL_ID = i.SU_LBL_ID; -- the posit has already been created
    INSERT INTO @SU_LBL_Subject_Label (
        SU_LBL_ID,
        SU_LBL_SU_ID,
        Metadata_SU_LBL,
        SU_LBL_ChangedAt,
        SU_LBL_PositedAt,
        SU_LBL_Reliability,
        SU_LBL_Subject_Label
    )
    SELECT
        p.SU_LBL_ID,
        p.SU_LBL_SU_ID,
        p.Metadata_SU_LBL,
        p.SU_LBL_ChangedAt,
        p.SU_LBL_PositedAt,
        p.SU_LBL_Reliability,
        p.SU_LBL_Subject_Label
    FROM 
        (SELECT DISTINCT SU_LBL_SU_ID FROM @SU_LBL_Subject_Label) i
    JOIN
        [dbo].[SU_LBL_Subject_Label] p
    ON 
        p.SU_LBL_SU_ID = i.SU_LBL_SU_ID
    LEFT JOIN 
        @SU_LBL_Subject_Label x
    ON
        x.SU_LBL_ID = p.SU_LBL_ID
    AND
        x.SU_LBL_PositedAt = p.SU_LBL_PositedAt
    WHERE
        x.SU_LBL_ID is null;
    -- no need to check retracted information
    DELETE a 
    FROM 
        @SU_LBL_Subject_Label a
    OUTER APPLY (
        SELECT TOP 1
            x.SU_LBL_Reliability
        FROM 
            @SU_LBL_Subject_Label x
        WHERE
            x.SU_LBL_ID = a.SU_LBL_ID
        AND
            x.SU_LBL_PositedAt < a.SU_LBL_PositedAt
        ORDER BY
            x.SU_LBL_PositedAt DESC
    ) pre 
    OUTER APPLY (
        SELECT TOP 1
            x.SU_LBL_Reliability
        FROM 
            @SU_LBL_Subject_Label x
        WHERE
            x.SU_LBL_ID = a.SU_LBL_ID
        AND
            x.SU_LBL_PositedAt > a.SU_LBL_PositedAt
        ORDER BY
            x.SU_LBL_PositedAt ASC
    ) fol 
    WHERE
        (a.SU_LBL_Reliability = 1 AND fol.SU_LBL_Reliability = 0)
    OR
        (a.SU_LBL_Reliability = 0 AND pre.SU_LBL_Reliability = 1);
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM 
            @SU_LBL_Subject_Label a
        CROSS APPLY (
            SELECT TOP 1
                h.SU_LBL_SU_ID,
                h.SU_LBL_ChangedAt,
                h.SU_LBL_Subject_Label
            FROM 
                @SU_LBL_Subject_Label h
            WHERE
                h.SU_LBL_SU_ID = a.SU_LBL_SU_ID
            AND
                h.SU_LBL_ChangedAt < a.SU_LBL_ChangedAt
            ORDER BY 
                h.SU_LBL_ChangedAt DESC,
                h.SU_LBL_PositedAt DESC
        ) pre
        WHERE
            a.SU_LBL_Subject_Label = pre.SU_LBL_Subject_Label
        AND
            a.SU_LBL_Reliability = 1
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in SU_LBL_Subject_Label for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
