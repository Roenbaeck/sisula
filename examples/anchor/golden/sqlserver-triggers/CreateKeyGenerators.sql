-- KEY GENERATORS -----------------------------------------------------------------------------------------------------
--
-- These stored procedures can be used to generate identities of entities.
-- Corresponding anchors must have an incrementing identity column.
--
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kSU_Subject identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kSU_Subject', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kSU_Subject] (
        @requestedNumberOfIdentities bigint,
        @metadata int
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
            INSERT INTO [dbo].[SU_Subject] (
                Metadata_SU
            )
            OUTPUT
                inserted.SU_ID
            SELECT
                @metadata
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kOB_Object identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kOB_Object', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kOB_Object] (
        @requestedNumberOfIdentities bigint,
        @metadata int
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
            INSERT INTO [dbo].[OB_Object] (
                Metadata_OB
            )
            OUTPUT
                inserted.OB_ID
            SELECT
                @metadata
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
        @requestedNumberOfIdentities bigint,
        @metadata int
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
                Metadata_EV
            )
            OUTPUT inserted.EV_ID
            SELECT @metadata FROM idGenerator OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
