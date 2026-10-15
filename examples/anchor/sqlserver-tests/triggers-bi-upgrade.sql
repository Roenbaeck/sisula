-- Makes the bitemporal trigger test database look like one that older generated SQL made, before
-- tools/sqlserver-tests.ps1 runs the generated SQL on it again and triggers-bi-upgraded.sql checks the result.
--
-- The constraints of the assembled views used to have no reliability, which a correction and the retraction it makes at
-- the same positing time need. These three are made again the old way: an attribute that the tests leave without
-- corrections, a historized one, and a tie with identifiers. The generated SQL is to make them again with the
-- reliability, and keep the rest as it is.
SET NOCOUNT ON;
CREATE UNIQUE CLUSTERED INDEX [pkOB_NAM_Object_Name]
ON [dbo].[OB_NAM_Object_Name] (
    OB_NAM_OB_ID asc,
    OB_NAM_PositedAt desc
)
WITH (DROP_EXISTING = ON);
CREATE UNIQUE CLUSTERED INDEX [pkSU_STA_Subject_State]
ON [dbo].[SU_STA_Subject_State] (
    SU_STA_SU_ID asc,
    SU_STA_ChangedAt desc,
    SU_STA_PositedAt desc
)
WITH (DROP_EXISTING = ON);
CREATE UNIQUE CLUSTERED INDEX [pkSU_keeper_OB_thing_GRD_rank]
ON [dbo].[SU_keeper_OB_thing_GRD_rank] (
    SU_ID_keeper asc,
    OB_ID_thing asc,
    SU_keeper_OB_thing_GRD_rank_ChangedAt desc,
    SU_keeper_OB_thing_GRD_rank_PositedAt desc
)
WITH (DROP_EXISTING = ON);
GO
