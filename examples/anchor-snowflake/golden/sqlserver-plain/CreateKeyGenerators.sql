-- KEY GENERATORS -----------------------------------------------------------------------------------------------------
--
-- These stored procedures can be used to generate identities of entities.
-- Corresponding anchors must have an incrementing identity column.
--
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kPN_Person identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kPN_Person', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kPN_Person] (
        @requestedNumberOfIdentities bigint
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [dbo].[PN_Person] (
                PN_Dummy
            )
            OUTPUT
                inserted.PN_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kST_Stage identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kST_Stage', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kST_Stage] (
        @requestedNumberOfIdentities bigint
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [dbo].[ST_Stage] (
                ST_Dummy
            )
            OUTPUT
                inserted.ST_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kAC_Actor identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kAC_Actor', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kAC_Actor] (
        @requestedNumberOfIdentities bigint
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [dbo].[AC_Actor] (
                AC_Dummy
            )
            OUTPUT
                inserted.AC_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kPR_Program identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kPR_Program', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kPR_Program] (
        @requestedNumberOfIdentities bigint
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [dbo].[PR_Program] (
                PR_Dummy
            )
            OUTPUT
                inserted.PR_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kEV_Event identity by surrogate key generation stored procedure (nexus)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kEV_Event', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kEV_Event] (
        @requestedNumberOfIdentities bigint
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT 1
                UNION ALL SELECT idNumber + 1 FROM idGenerator WHERE idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [dbo].[EV_Event] (
                EV_Dummy
            )
            OUTPUT inserted.EV_ID
            SELECT null FROM idGenerator OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
