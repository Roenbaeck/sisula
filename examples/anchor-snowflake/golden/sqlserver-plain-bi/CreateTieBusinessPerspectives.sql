-- TIE TEMPORAL BUSINESS PERSPECTIVES ---------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each tie. There are four types of perspectives: latest,
-- point-in-time, difference, and now.
--
-- The latest perspective shows the latest available information for each tie.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-e perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Actor_partner_Actor_with_currently_Ongoing viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Actor_partner_Actor_with_currently_Ongoing] AS
SELECT
    tie.AC_ID_partner as [Actor_partner_Id],
    tie.AC_ID_with as [Actor_with_Id],
    tie.ONG_Ongoing AS [currently_Ongoing]
FROM
    [dbo].[lAC_partner_AC_with_ONG_currently] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Actor_partner_Actor_with_currently_Ongoing viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Actor_partner_Actor_with_currently_Ongoing] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.AC_ID_partner as [Actor_partner_Id],
    tie.AC_ID_with as [Actor_with_Id],
    tie.ONG_Ongoing AS [currently_Ongoing]
FROM
    [dbo].[pAC_partner_AC_with_ONG_currently](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Actor_partner_Actor_with_currently_Ongoing viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Actor_partner_Actor_with_currently_Ongoing]
AS
SELECT
    *
FROM
    [dbo].[Point_Actor_partner_Actor_with_currently_Ongoing](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Difference_Actor_partner_Actor_with_currently_Ongoing showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Difference_Actor_partner_Actor_with_currently_Ongoing] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt as [Time_of_Change],
    tie.AC_ID_partner as [Actor_partner_Id],
    tie.AC_ID_with as [Actor_with_Id],
    tie.ONG_Ongoing AS [currently_Ongoing]
FROM
    [dbo].[dAC_partner_AC_with_ONG_currently](@intervalStart, @intervalEnd) tie;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Actor_subset_Person_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Actor_subset_Person_of] AS
SELECT
    tie.AC_ID_subset as [Actor_subset_Id],
    tie.PN_ID_of as [Person_of_Id]
FROM
    [dbo].[lAC_subset_PN_of] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Actor_subset_Person_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Actor_subset_Person_of] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.AC_ID_subset as [Actor_subset_Id],
    tie.PN_ID_of as [Person_of_Id]
FROM
    [dbo].[pAC_subset_PN_of](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Actor_subset_Person_of viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Actor_subset_Person_of]
AS
SELECT
    *
FROM
    [dbo].[Point_Actor_subset_Person_of](sysdatetime());
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_in_Unknown_Actor_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_in_Unknown_Actor_wasCast] AS
SELECT
    tie.EV_ID_in as [in_Unknown_Id],
    tie.AC_ID_wasCast as [Actor_wasCast_Id]
FROM
    [dbo].[lEV_in_AC_wasCast] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_in_Unknown_Actor_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_in_Unknown_Actor_wasCast] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.EV_ID_in as [in_Unknown_Id],
    tie.AC_ID_wasCast as [Actor_wasCast_Id]
FROM
    [dbo].[pEV_in_AC_wasCast](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_in_Unknown_Actor_wasCast viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_in_Unknown_Actor_wasCast]
AS
SELECT
    *
FROM
    [dbo].[Point_in_Unknown_Actor_wasCast](sysdatetime());
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Actor_part_Program_in_got_Rating viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Actor_part_Program_in_got_Rating] AS
SELECT
    tie.AC_ID_part as [Actor_part_Id],
    tie.PR_ID_in as [Program_in_Id],
    tie.RAT_Rating AS [got_Rating]
FROM
    [dbo].[lAC_part_PR_in_RAT_got] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Actor_part_Program_in_got_Rating viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Actor_part_Program_in_got_Rating] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.AC_ID_part as [Actor_part_Id],
    tie.PR_ID_in as [Program_in_Id],
    tie.RAT_Rating AS [got_Rating]
FROM
    [dbo].[pAC_part_PR_in_RAT_got](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Actor_part_Program_in_got_Rating viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Actor_part_Program_in_got_Rating]
AS
SELECT
    *
FROM
    [dbo].[Point_Actor_part_Program_in_got_Rating](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Difference_Actor_part_Program_in_got_Rating showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Difference_Actor_part_Program_in_got_Rating] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt as [Time_of_Change],
    tie.AC_ID_part as [Actor_part_Id],
    tie.PR_ID_in as [Program_in_Id],
    tie.RAT_Rating AS [got_Rating]
FROM
    [dbo].[dAC_part_PR_in_RAT_got](@intervalStart, @intervalEnd) tie;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Stage_at_Program_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Stage_at_Program_isPlaying] AS
SELECT
    tie.ST_ID_at as [Stage_at_Id],
    tie.PR_ID_isPlaying as [Program_isPlaying_Id]
FROM
    [dbo].[lST_at_PR_isPlaying] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Stage_at_Program_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Stage_at_Program_isPlaying] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.ST_ID_at as [Stage_at_Id],
    tie.PR_ID_isPlaying as [Program_isPlaying_Id]
FROM
    [dbo].[pST_at_PR_isPlaying](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Stage_at_Program_isPlaying viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Stage_at_Program_isPlaying]
AS
SELECT
    *
FROM
    [dbo].[Point_Stage_at_Program_isPlaying](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Difference_Stage_at_Program_isPlaying showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Difference_Stage_at_Program_isPlaying] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.ST_at_PR_isPlaying_ChangedAt as [Time_of_Change],
    tie.ST_ID_at as [Stage_at_Id],
    tie.PR_ID_isPlaying as [Program_isPlaying_Id]
FROM
    [dbo].[dST_at_PR_isPlaying](@intervalStart, @intervalEnd) tie;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Actor_parent_Actor_child_having_ParentalType viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Actor_parent_Actor_child_having_ParentalType] AS
SELECT
    tie.AC_ID_parent as [Actor_parent_Id],
    tie.AC_ID_child as [Actor_child_Id],
    tie.PAT_ParentalType AS [having_ParentalType]
FROM
    [dbo].[lAC_parent_AC_child_PAT_having] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Actor_parent_Actor_child_having_ParentalType viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Actor_parent_Actor_child_having_ParentalType] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.AC_ID_parent as [Actor_parent_Id],
    tie.AC_ID_child as [Actor_child_Id],
    tie.PAT_ParentalType AS [having_ParentalType]
FROM
    [dbo].[pAC_parent_AC_child_PAT_having](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Actor_parent_Actor_child_having_ParentalType viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Actor_parent_Actor_child_having_ParentalType]
AS
SELECT
    *
FROM
    [dbo].[Point_Actor_parent_Actor_child_having_ParentalType](sysdatetime());
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- Latest_Program_content_Stage_location_of_Unknown viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Latest_Program_content_Stage_location_of_Unknown] AS
SELECT
    tie.PR_ID_content as [Program_content_Id],
    tie.ST_ID_location as [Stage_location_Id],
    tie.EV_ID_of as [of_Unknown_Id]
FROM
    [dbo].[lPR_content_ST_location_EV_of] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Program_content_Stage_location_of_Unknown viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[Point_Program_content_Stage_location_of_Unknown] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.PR_ID_content as [Program_content_Id],
    tie.ST_ID_location as [Stage_location_Id],
    tie.EV_ID_of as [of_Unknown_Id]
FROM
    [dbo].[pPR_content_ST_location_EV_of](@changingTimepoint) tie
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Program_content_Stage_location_of_Unknown viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[Current_Program_content_Stage_location_of_Unknown]
AS
SELECT
    *
FROM
    [dbo].[Point_Program_content_Stage_location_of_Unknown](sysdatetime());
GO
