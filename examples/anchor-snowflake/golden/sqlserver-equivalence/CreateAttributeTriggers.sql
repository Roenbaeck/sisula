-- ATTRIBUTE TRIGGERS ------------------------------------------------------------------------------------------------
--
-- The following triggers on the attributes make them behave like tables.
-- There is one 'instead of' trigger for: insert.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_DAT_Event_Date instead of INSERT trigger on EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_DAT_Event_Date', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_DAT_Event_Date];
GO
CREATE TRIGGER [dbo].[it_EV_DAT_Event_Date] ON [dbo].[EV_DAT_Event_Date]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_DAT_EQ,
            i.EV_DAT_EV_ID
        FROM
            inserted i
        JOIN
            [dbo].[EV_DAT_Event_Date] x
        ON
            x.EV_DAT_EQ = i.EV_DAT_EQ
        AND
            x.EV_DAT_EV_ID = i.EV_DAT_EV_ID
        WHERE NOT (
            x.EV_DAT_Event_Date = i.EV_DAT_Event_Date
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_DAT_Event_Date for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[EV_DAT_Event_Date] (
        Metadata_EV_DAT,
        EV_DAT_EV_ID,
        EV_DAT_EQ,
        EV_DAT_Event_Date
    )
    SELECT
        Metadata_EV_DAT,
        EV_DAT_EV_ID,
        EV_DAT_EQ,
        EV_DAT_Event_Date
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.EV_DAT_EV_ID
        FROM
            [dbo].[EV_DAT_Event_Date] x
        WHERE
            x.EV_DAT_EQ = i.EV_DAT_EQ
        AND 
            x.EV_DAT_EV_ID = i.EV_DAT_EV_ID
        AND
            x.EV_DAT_Event_Date = i.EV_DAT_Event_Date
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_AUD_Event_Audience instead of INSERT trigger on EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_AUD_Event_Audience', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_AUD_Event_Audience];
GO
CREATE TRIGGER [dbo].[it_EV_AUD_Event_Audience] ON [dbo].[EV_AUD_Event_Audience]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_AUD_EV_ID
        FROM
            inserted i
        JOIN
            [dbo].[EV_AUD_Event_Audience] x
        ON
            x.EV_AUD_EV_ID = i.EV_AUD_EV_ID
        WHERE NOT (
            x.EV_AUD_Event_Audience = i.EV_AUD_Event_Audience
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_AUD_Event_Audience for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[EV_AUD_Event_Audience] (
        Metadata_EV_AUD,
        EV_AUD_EV_ID,
        EV_AUD_Event_Audience
    )
    SELECT
        Metadata_EV_AUD,
        EV_AUD_EV_ID,
        EV_AUD_Event_Audience
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.EV_AUD_EV_ID
        FROM
            [dbo].[EV_AUD_Event_Audience] x
        WHERE
            x.EV_AUD_EV_ID = i.EV_AUD_EV_ID
        AND
            x.EV_AUD_Event_Audience = i.EV_AUD_Event_Audience
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_REV_Event_Revenue instead of INSERT trigger on EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_REV_Event_Revenue', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_REV_Event_Revenue];
GO
CREATE TRIGGER [dbo].[it_EV_REV_Event_Revenue] ON [dbo].[EV_REV_Event_Revenue]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_REV_EQ,
            i.EV_REV_EV_ID
        FROM
            inserted i
        JOIN
            [dbo].[EV_REV_Event_Revenue] x
        ON
            x.EV_REV_EQ = i.EV_REV_EQ
        AND
            x.EV_REV_EV_ID = i.EV_REV_EV_ID
        WHERE NOT (
            x.EV_REV_Event_Revenue = i.EV_REV_Event_Revenue
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_REV_Event_Revenue for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[EV_REV_Event_Revenue] (
        Metadata_EV_REV,
        EV_REV_EV_ID,
        EV_REV_EQ,
        EV_REV_Event_Revenue
    )
    SELECT
        Metadata_EV_REV,
        EV_REV_EV_ID,
        EV_REV_EQ,
        EV_REV_Event_Revenue
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.EV_REV_EV_ID
        FROM
            [dbo].[EV_REV_Event_Revenue] x
        WHERE
            x.EV_REV_EQ = i.EV_REV_EQ
        AND 
            x.EV_REV_EV_ID = i.EV_REV_EV_ID
        AND
            x.EV_REV_Event_Revenue = i.EV_REV_Event_Revenue
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_NAM_Stage_Name instead of INSERT trigger on ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_NAM_Stage_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_NAM_Stage_Name];
GO
CREATE TRIGGER [dbo].[it_ST_NAM_Stage_Name] ON [dbo].[ST_NAM_Stage_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @ST_NAM_Stage_Name TABLE (
    ST_NAM_ST_ID int not null,
        ST_NAM_EQ tinyint not null,
        Metadata_ST_NAM int not null,
        ST_NAM_ChangedAt datetime2 not null,
        ST_NAM_Stage_Name nvarchar(42) not null,
        ST_NAM_Checksum varbinary(16) not null,
        ST_NAM_StatementType char(1) not null,
        primary key (
            ST_NAM_EQ asc,
            ST_NAM_ST_ID asc, 
            ST_NAM_ChangedAt desc
        )
    );
    INSERT INTO @ST_NAM_Stage_Name
    SELECT
        i.ST_NAM_ST_ID,
        i.ST_NAM_EQ,
        i.Metadata_ST_NAM,
        i.ST_NAM_ChangedAt,
        i.ST_NAM_Stage_Name,
        dbo.MD5(cast(i.ST_NAM_Stage_Name as varbinary(max))),
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.ST_NAM_ST_ID
        FROM
            [dbo].[ST_NAM_Stage_Name] x
        WHERE
            x.ST_NAM_EQ = i.ST_NAM_EQ
        AND 
            x.ST_NAM_ST_ID = i.ST_NAM_ST_ID
        AND
            x.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
        AND
            x.ST_NAM_Checksum = dbo.MD5(cast(i.ST_NAM_Stage_Name as varbinary(max))) 
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_NAM_EQ,
            i.ST_NAM_ST_ID,
            i.ST_NAM_ChangedAt
        FROM
            @ST_NAM_Stage_Name i
        JOIN
            [dbo].[ST_NAM_Stage_Name] x
        ON
            x.ST_NAM_EQ = i.ST_NAM_EQ
        AND
            x.ST_NAM_ST_ID = i.ST_NAM_ST_ID
        AND
            x.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_NAM_Stage_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[ST_NAM_Stage_Name] (
        Metadata_ST_NAM,
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_EQ,
        ST_NAM_Stage_Name
    )
    SELECT
        Metadata_ST_NAM,
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_EQ,
        ST_NAM_Stage_Name
    FROM
        @ST_NAM_Stage_Name
    WHERE
        ST_NAM_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_LOC_Stage_Location instead of INSERT trigger on ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_LOC_Stage_Location', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_LOC_Stage_Location];
GO
CREATE TRIGGER [dbo].[it_ST_LOC_Stage_Location] ON [dbo].[ST_LOC_Stage_Location]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_LOC_EQ,
            i.ST_LOC_ST_ID
        FROM
            inserted i
        JOIN
            [dbo].[ST_LOC_Stage_Location] x
        ON
            x.ST_LOC_EQ = i.ST_LOC_EQ
        AND
            x.ST_LOC_ST_ID = i.ST_LOC_ST_ID
        WHERE NOT (
            x.ST_LOC_Checksum = dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max))) 
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_LOC_Stage_Location for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[ST_LOC_Stage_Location] (
        Metadata_ST_LOC,
        ST_LOC_ST_ID,
        ST_LOC_EQ,
        ST_LOC_Stage_Location
    )
    SELECT
        Metadata_ST_LOC,
        ST_LOC_ST_ID,
        ST_LOC_EQ,
        ST_LOC_Stage_Location
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.ST_LOC_ST_ID
        FROM
            [dbo].[ST_LOC_Stage_Location] x
        WHERE
            x.ST_LOC_EQ = i.ST_LOC_EQ
        AND 
            x.ST_LOC_ST_ID = i.ST_LOC_ST_ID
        AND
            x.ST_LOC_Checksum = dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max))) 
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_AVG_Stage_Average instead of INSERT trigger on ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_AVG_Stage_Average', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_AVG_Stage_Average];
GO
CREATE TRIGGER [dbo].[it_ST_AVG_Stage_Average] ON [dbo].[ST_AVG_Stage_Average]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @ST_AVG_Stage_Average TABLE (
    ST_AVG_ST_ID int not null,
        Metadata_ST_AVG int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_UTL_ID tinyint not null, 
        ST_AVG_StatementType char(1) not null,
        primary key (
            ST_AVG_ST_ID asc, 
            ST_AVG_ChangedAt desc
        )
    );
    INSERT INTO @ST_AVG_Stage_Average
    SELECT
        i.ST_AVG_ST_ID,
        i.Metadata_ST_AVG,
        i.ST_AVG_ChangedAt,
        i.ST_AVG_UTL_ID,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.ST_AVG_ST_ID
        FROM
            [dbo].[ST_AVG_Stage_Average] x
        WHERE
            x.ST_AVG_ST_ID = i.ST_AVG_ST_ID
        AND
            x.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
        AND
            x.ST_AVG_UTL_ID = i.ST_AVG_UTL_ID
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_AVG_ST_ID,
            i.ST_AVG_ChangedAt
        FROM
            @ST_AVG_Stage_Average i
        JOIN
            [dbo].[ST_AVG_Stage_Average] x
        ON
            x.ST_AVG_ST_ID = i.ST_AVG_ST_ID
        AND
            x.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_AVG_Stage_Average for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @ST_AVG_Stage_Average
    SELECT
        i.ST_AVG_ST_ID,
        p.Metadata_ST_AVG,
        p.ST_AVG_ChangedAt,
        p.ST_AVG_UTL_ID,
        'X' -- existing data
    FROM (
        SELECT DISTINCT 
            ST_AVG_ST_ID 
        FROM 
            @ST_AVG_Stage_Average
    ) i
    JOIN
        [dbo].[ST_AVG_Stage_Average] p
    ON
        p.ST_AVG_ST_ID = i.ST_AVG_ST_ID;
    DECLARE @restated TABLE (
    ST_AVG_ST_ID int not null,
        ST_AVG_ChangedAt datetime2 not null
    );
    INSERT INTO @restated
    SELECT 
        x.ST_AVG_ST_ID,
        x.ST_AVG_ChangedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*
        FROM 
            @ST_AVG_Stage_Average a
        OUTER APPLY (
            SELECT TOP 1
                h.ST_AVG_UTL_ID
            FROM 
                @ST_AVG_Stage_Average h
            WHERE
                h.ST_AVG_ST_ID = a.ST_AVG_ST_ID
            AND
                h.ST_AVG_ChangedAt < a.ST_AVG_ChangedAt
            ORDER BY 
                h.ST_AVG_ChangedAt DESC
        ) pre
        WHERE
            a.ST_AVG_UTL_ID = pre.ST_AVG_UTL_ID
    ) x
    WHERE
        x.ST_AVG_StatementType = 'X';
    -- remove the quenches (should happen rarely)
	DELETE a
	FROM 
		[dbo].[ST_AVG_Stage_Average] a
	JOIN 
		@restated d
	ON 
		d.ST_AVG_ST_ID = a.ST_AVG_ST_ID
	AND 
		d.ST_AVG_ChangedAt = a.ST_AVG_ChangedAt; 
    INSERT INTO [dbo].[ST_AVG_Stage_Average] (
        Metadata_ST_AVG,
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    )
    SELECT
        Metadata_ST_AVG,
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    FROM
        @ST_AVG_Stage_Average
    WHERE
        ST_AVG_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_MIN_Stage_Minimum instead of INSERT trigger on ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_MIN_Stage_Minimum', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_MIN_Stage_Minimum];
GO
CREATE TRIGGER [dbo].[it_ST_MIN_Stage_Minimum] ON [dbo].[ST_MIN_Stage_Minimum]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_MIN_ST_ID
        FROM
            inserted i
        JOIN
            [dbo].[ST_MIN_Stage_Minimum] x
        ON
            x.ST_MIN_ST_ID = i.ST_MIN_ST_ID
        WHERE NOT (
            x.ST_MIN_UTL_ID = i.ST_MIN_UTL_ID
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_MIN_Stage_Minimum for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[ST_MIN_Stage_Minimum] (
        Metadata_ST_MIN,
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID
    )
    SELECT
        Metadata_ST_MIN,
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.ST_MIN_ST_ID
        FROM
            [dbo].[ST_MIN_Stage_Minimum] x
        WHERE
            x.ST_MIN_ST_ID = i.ST_MIN_ST_ID
        AND
            x.ST_MIN_UTL_ID = i.ST_MIN_UTL_ID
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_NAM_Actor_Name instead of INSERT trigger on AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_NAM_Actor_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_NAM_Actor_Name];
GO
CREATE TRIGGER [dbo].[it_AC_NAM_Actor_Name] ON [dbo].[AC_NAM_Actor_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @AC_NAM_Actor_Name TABLE (
    AC_NAM_AC_ID int not null,
        AC_NAM_EQ tinyint not null,
        Metadata_AC_NAM int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_Actor_Name nvarchar(42) not null,
        AC_NAM_Checksum varbinary(16) not null,
        AC_NAM_StatementType char(1) not null,
        primary key (
            AC_NAM_EQ asc,
            AC_NAM_AC_ID asc, 
            AC_NAM_ChangedAt desc
        )
    );
    INSERT INTO @AC_NAM_Actor_Name
    SELECT
        i.AC_NAM_AC_ID,
        i.AC_NAM_EQ,
        i.Metadata_AC_NAM,
        i.AC_NAM_ChangedAt,
        i.AC_NAM_Actor_Name,
        dbo.MD5(cast(i.AC_NAM_Actor_Name as varbinary(max))),
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.AC_NAM_AC_ID
        FROM
            [dbo].[AC_NAM_Actor_Name] x
        WHERE
            x.AC_NAM_EQ = i.AC_NAM_EQ
        AND 
            x.AC_NAM_AC_ID = i.AC_NAM_AC_ID
        AND
            x.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
        AND
            x.AC_NAM_Checksum = dbo.MD5(cast(i.AC_NAM_Actor_Name as varbinary(max))) 
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_NAM_EQ,
            i.AC_NAM_AC_ID,
            i.AC_NAM_ChangedAt
        FROM
            @AC_NAM_Actor_Name i
        JOIN
            [dbo].[AC_NAM_Actor_Name] x
        ON
            x.AC_NAM_EQ = i.AC_NAM_EQ
        AND
            x.AC_NAM_AC_ID = i.AC_NAM_AC_ID
        AND
            x.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_NAM_Actor_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[AC_NAM_Actor_Name] (
        Metadata_AC_NAM,
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_EQ,
        AC_NAM_Actor_Name
    )
    SELECT
        Metadata_AC_NAM,
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_EQ,
        AC_NAM_Actor_Name
    FROM
        @AC_NAM_Actor_Name
    WHERE
        AC_NAM_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_GEN_Actor_Gender instead of INSERT trigger on AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_GEN_Actor_Gender', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_GEN_Actor_Gender];
GO
CREATE TRIGGER [dbo].[it_AC_GEN_Actor_Gender] ON [dbo].[AC_GEN_Actor_Gender]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_GEN_AC_ID
        FROM
            inserted i
        JOIN
            [dbo].[AC_GEN_Actor_Gender] x
        ON
            x.AC_GEN_AC_ID = i.AC_GEN_AC_ID
        WHERE NOT (
            x.AC_GEN_GEN_ID = i.AC_GEN_GEN_ID
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_GEN_Actor_Gender for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[AC_GEN_Actor_Gender] (
        Metadata_AC_GEN,
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID
    )
    SELECT
        Metadata_AC_GEN,
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.AC_GEN_AC_ID
        FROM
            [dbo].[AC_GEN_Actor_Gender] x
        WHERE
            x.AC_GEN_AC_ID = i.AC_GEN_AC_ID
        AND
            x.AC_GEN_GEN_ID = i.AC_GEN_GEN_ID
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_PLV_Actor_ProfessionalLevel instead of INSERT trigger on AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_PLV_Actor_ProfessionalLevel', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_PLV_Actor_ProfessionalLevel];
GO
CREATE TRIGGER [dbo].[it_AC_PLV_Actor_ProfessionalLevel] ON [dbo].[AC_PLV_Actor_ProfessionalLevel]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @AC_PLV_Actor_ProfessionalLevel TABLE (
    AC_PLV_AC_ID int not null,
        Metadata_AC_PLV int not null,
        AC_PLV_ChangedAt datetime2 not null,
        AC_PLV_PLV_ID tinyint not null, 
        AC_PLV_StatementType char(1) not null,
        primary key (
            AC_PLV_AC_ID asc, 
            AC_PLV_ChangedAt desc
        )
    );
    INSERT INTO @AC_PLV_Actor_ProfessionalLevel
    SELECT
        i.AC_PLV_AC_ID,
        i.Metadata_AC_PLV,
        i.AC_PLV_ChangedAt,
        i.AC_PLV_PLV_ID,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.AC_PLV_AC_ID
        FROM
            [dbo].[AC_PLV_Actor_ProfessionalLevel] x
        WHERE
            x.AC_PLV_AC_ID = i.AC_PLV_AC_ID
        AND
            x.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
        AND
            x.AC_PLV_PLV_ID = i.AC_PLV_PLV_ID
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_PLV_AC_ID,
            i.AC_PLV_ChangedAt
        FROM
            @AC_PLV_Actor_ProfessionalLevel i
        JOIN
            [dbo].[AC_PLV_Actor_ProfessionalLevel] x
        ON
            x.AC_PLV_AC_ID = i.AC_PLV_AC_ID
        AND
            x.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel] (
        Metadata_AC_PLV,
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    )
    SELECT
        Metadata_AC_PLV,
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    FROM
        @AC_PLV_Actor_ProfessionalLevel
    WHERE
        AC_PLV_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_NAM_Program_Name instead of INSERT trigger on PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_PR_NAM_Program_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_PR_NAM_Program_Name];
GO
CREATE TRIGGER [dbo].[it_PR_NAM_Program_Name] ON [dbo].[PR_NAM_Program_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.PR_NAM_PR_ID
        FROM
            inserted i
        JOIN
            [dbo].[PR_NAM_Program_Name] x
        ON
            x.PR_NAM_PR_ID = i.PR_NAM_PR_ID
        WHERE NOT (
            x.PR_NAM_Program_Name = i.PR_NAM_Program_Name
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in PR_NAM_Program_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[PR_NAM_Program_Name] (
        Metadata_PR_NAM,
        PR_NAM_PR_ID,
        PR_NAM_Program_Name
    )
    SELECT
        Metadata_PR_NAM,
        PR_NAM_PR_ID,
        PR_NAM_Program_Name
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.PR_NAM_PR_ID
        FROM
            [dbo].[PR_NAM_Program_Name] x
        WHERE
            x.PR_NAM_PR_ID = i.PR_NAM_PR_ID
        AND
            x.PR_NAM_Program_Name = i.PR_NAM_Program_Name
    ); 
END
GO 
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_LEN_Program_Length instead of INSERT trigger on PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_PR_LEN_Program_Length', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_PR_LEN_Program_Length];
GO
CREATE TRIGGER [dbo].[it_PR_LEN_Program_Length] ON [dbo].[PR_LEN_Program_Length]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @PR_LEN_Program_Length TABLE (
    PR_LEN_PR_ID int not null,
        Metadata_PR_LEN int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_Program_Length time not null,
        PR_LEN_StatementType char(1) not null,
        primary key (
            PR_LEN_PR_ID asc, 
            PR_LEN_ChangedAt desc
        )
    );
    INSERT INTO @PR_LEN_Program_Length
    SELECT
        i.PR_LEN_PR_ID,
        i.Metadata_PR_LEN,
        i.PR_LEN_ChangedAt,
        i.PR_LEN_Program_Length,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.PR_LEN_PR_ID
        FROM
            [dbo].[PR_LEN_Program_Length] x
        WHERE
            x.PR_LEN_PR_ID = i.PR_LEN_PR_ID
        AND
            x.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
        AND
            x.PR_LEN_Program_Length = i.PR_LEN_Program_Length
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.PR_LEN_PR_ID,
            i.PR_LEN_ChangedAt
        FROM
            @PR_LEN_Program_Length i
        JOIN
            [dbo].[PR_LEN_Program_Length] x
        ON
            x.PR_LEN_PR_ID = i.PR_LEN_PR_ID
        AND
            x.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in PR_LEN_Program_Length for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @PR_LEN_Program_Length
    SELECT
        i.PR_LEN_PR_ID,
        p.Metadata_PR_LEN,
        p.PR_LEN_ChangedAt,
        p.PR_LEN_Program_Length,
        'X' -- existing data
    FROM (
        SELECT DISTINCT 
            PR_LEN_PR_ID 
        FROM 
            @PR_LEN_Program_Length
    ) i
    JOIN
        [dbo].[PR_LEN_Program_Length] p
    ON
        p.PR_LEN_PR_ID = i.PR_LEN_PR_ID;
    DECLARE @restated TABLE (
    PR_LEN_PR_ID int not null,
        PR_LEN_ChangedAt date not null
    );
    INSERT INTO @restated
    SELECT 
        x.PR_LEN_PR_ID,
        x.PR_LEN_ChangedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*
        FROM 
            @PR_LEN_Program_Length a
        OUTER APPLY (
            SELECT TOP 1
                h.PR_LEN_Program_Length
            FROM 
                @PR_LEN_Program_Length h
            WHERE
                h.PR_LEN_PR_ID = a.PR_LEN_PR_ID
            AND
                h.PR_LEN_ChangedAt < a.PR_LEN_ChangedAt
            ORDER BY 
                h.PR_LEN_ChangedAt DESC
        ) pre
        WHERE
            a.PR_LEN_Program_Length = pre.PR_LEN_Program_Length
    ) x
    WHERE
        x.PR_LEN_StatementType = 'X';
    -- remove the quenches (should happen rarely)
	DELETE a
	FROM 
		[dbo].[PR_LEN_Program_Length] a
	JOIN 
		@restated d
	ON 
		d.PR_LEN_PR_ID = a.PR_LEN_PR_ID
	AND 
		d.PR_LEN_ChangedAt = a.PR_LEN_ChangedAt; 
    INSERT INTO [dbo].[PR_LEN_Program_Length] (
        Metadata_PR_LEN,
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    )
    SELECT
        Metadata_PR_LEN,
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    FROM
        @PR_LEN_Program_Length
    WHERE
        PR_LEN_StatementType = 'P';
END
GO
