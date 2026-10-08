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
    ST_ID int not null,
        ST_NAM_ChangedAt datetime2 not null,
        ST_NAM_Stage_Name nvarchar(42) not null,
        ST_NAM_StatementType char(1) not null,
        primary key (
            ST_ID asc, 
            ST_NAM_ChangedAt desc
        )
    );
    INSERT INTO @ST_NAM_Stage_Name
    SELECT
        i.ST_ID,
        i.ST_NAM_ChangedAt,
        i.ST_NAM_Stage_Name,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.ST_ID
        FROM
            [dbo].[ST_NAM_Stage_Name] x
        WHERE
            x.ST_ID = i.ST_ID
        AND
            x.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
        AND
            x.ST_NAM_Stage_Name = i.ST_NAM_Stage_Name
    ); -- the posit must be different (exclude the identical)
    INSERT INTO [dbo].[ST_NAM_Stage_Name] (
        ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    )
    SELECT
        ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    FROM
        @ST_NAM_Stage_Name
    WHERE
        ST_NAM_StatementType = 'P';
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
    ST_ID int not null,
        ST_AVG_ChangedAt datetime2 not null,
        UTL_ID tinyint not null, 
        ST_AVG_StatementType char(1) not null,
        primary key (
            ST_ID asc, 
            ST_AVG_ChangedAt desc
        )
    );
    INSERT INTO @ST_AVG_Stage_Average
    SELECT
        i.ST_ID,
        i.ST_AVG_ChangedAt,
        i.UTL_ID,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.ST_ID
        FROM
            [dbo].[ST_AVG_Stage_Average] x
        WHERE
            x.ST_ID = i.ST_ID
        AND
            x.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
        AND
            x.UTL_ID = i.UTL_ID
    ); -- the posit must be different (exclude the identical)
    INSERT INTO @ST_AVG_Stage_Average
    SELECT
        i.ST_ID,
        p.ST_AVG_ChangedAt,
        p.UTL_ID,
        'X' -- existing data
    FROM (
        SELECT DISTINCT 
            ST_ID 
        FROM 
            @ST_AVG_Stage_Average
    ) i
    JOIN
        [dbo].[ST_AVG_Stage_Average] p
    ON
        p.ST_ID = i.ST_ID;
    DECLARE @restated TABLE (
    ST_ID int not null,
        ST_AVG_ChangedAt datetime2 not null
    );
    INSERT INTO @restated
    SELECT 
        x.ST_ID,
        x.ST_AVG_ChangedAt
    FROM (
        DELETE a
        OUTPUT 
            deleted.*
        FROM 
            @ST_AVG_Stage_Average a
        OUTER APPLY (
            SELECT TOP 1
                h.UTL_ID
            FROM 
                @ST_AVG_Stage_Average h
            WHERE
                h.ST_ID = a.ST_ID
            AND
                h.ST_AVG_ChangedAt < a.ST_AVG_ChangedAt
            ORDER BY 
                h.ST_AVG_ChangedAt DESC
        ) pre
        WHERE
            a.UTL_ID = pre.UTL_ID
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
		d.ST_ID = a.ST_ID
	AND 
		d.ST_AVG_ChangedAt = a.ST_AVG_ChangedAt; 
    INSERT INTO [dbo].[ST_AVG_Stage_Average] (
        ST_ID,
        ST_AVG_ChangedAt,
        UTL_ID
    )
    SELECT
        ST_ID,
        ST_AVG_ChangedAt,
        UTL_ID
    FROM
        @ST_AVG_Stage_Average
    WHERE
        ST_AVG_StatementType = 'P';
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
    AC_ID int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_Actor_Name nvarchar(42) not null,
        AC_NAM_StatementType char(1) not null,
        primary key (
            AC_ID asc, 
            AC_NAM_ChangedAt desc
        )
    );
    INSERT INTO @AC_NAM_Actor_Name
    SELECT
        i.AC_ID,
        i.AC_NAM_ChangedAt,
        i.AC_NAM_Actor_Name,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.AC_ID
        FROM
            [dbo].[AC_NAM_Actor_Name] x
        WHERE
            x.AC_ID = i.AC_ID
        AND
            x.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
        AND
            x.AC_NAM_Actor_Name = i.AC_NAM_Actor_Name
    ); -- the posit must be different (exclude the identical)
    INSERT INTO [dbo].[AC_NAM_Actor_Name] (
        AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    SELECT
        AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    FROM
        @AC_NAM_Actor_Name
    WHERE
        AC_NAM_StatementType = 'P';
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
    AC_ID int not null,
        AC_PLV_ChangedAt datetime2 not null,
        PLV_ID tinyint not null, 
        AC_PLV_StatementType char(1) not null,
        primary key (
            AC_ID asc, 
            AC_PLV_ChangedAt desc
        )
    );
    INSERT INTO @AC_PLV_Actor_ProfessionalLevel
    SELECT
        i.AC_ID,
        i.AC_PLV_ChangedAt,
        i.PLV_ID,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.AC_ID
        FROM
            [dbo].[AC_PLV_Actor_ProfessionalLevel] x
        WHERE
            x.AC_ID = i.AC_ID
        AND
            x.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
        AND
            x.PLV_ID = i.PLV_ID
    ); -- the posit must be different (exclude the identical)
    INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel] (
        AC_ID,
        AC_PLV_ChangedAt,
        PLV_ID
    )
    SELECT
        AC_ID,
        AC_PLV_ChangedAt,
        PLV_ID
    FROM
        @AC_PLV_Actor_ProfessionalLevel
    WHERE
        AC_PLV_StatementType = 'P';
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
    PR_ID int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_Program_Length time not null,
        PR_LEN_StatementType char(1) not null,
        primary key (
            PR_ID asc, 
            PR_LEN_ChangedAt desc
        )
    );
    INSERT INTO @PR_LEN_Program_Length
    SELECT
        i.PR_ID,
        i.PR_LEN_ChangedAt,
        i.PR_LEN_Program_Length,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.PR_ID
        FROM
            [dbo].[PR_LEN_Program_Length] x
        WHERE
            x.PR_ID = i.PR_ID
        AND
            x.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
        AND
            x.PR_LEN_Program_Length = i.PR_LEN_Program_Length
    ); -- the posit must be different (exclude the identical)
    INSERT INTO @PR_LEN_Program_Length
    SELECT
        i.PR_ID,
        p.PR_LEN_ChangedAt,
        p.PR_LEN_Program_Length,
        'X' -- existing data
    FROM (
        SELECT DISTINCT 
            PR_ID 
        FROM 
            @PR_LEN_Program_Length
    ) i
    JOIN
        [dbo].[PR_LEN_Program_Length] p
    ON
        p.PR_ID = i.PR_ID;
    DECLARE @restated TABLE (
    PR_ID int not null,
        PR_LEN_ChangedAt date not null
    );
    INSERT INTO @restated
    SELECT 
        x.PR_ID,
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
                h.PR_ID = a.PR_ID
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
		d.PR_ID = a.PR_ID
	AND 
		d.PR_LEN_ChangedAt = a.PR_LEN_ChangedAt; 
    INSERT INTO [dbo].[PR_LEN_Program_Length] (
        PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    )
    SELECT
        PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    FROM
        @PR_LEN_Program_Length
    WHERE
        PR_LEN_StatementType = 'P';
END
GO
