-- TIE TEMPORAL BUSINESS PERSPECTIVES ---------------------------------------------------------------------------------
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('ties.EQ_Difference_Actor_partner_Actor_with_currently_Ongoing', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Difference_Actor_partner_Actor_with_currently_Ongoing];
IF Object_ID('ties.EQ_Current_Actor_partner_Actor_with_currently_Ongoing', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Current_Actor_partner_Actor_with_currently_Ongoing];
IF Object_ID('ties.EQ_Point_Actor_partner_Actor_with_currently_Ongoing', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Point_Actor_partner_Actor_with_currently_Ongoing];
IF Object_ID('ties.EQ_Latest_Actor_partner_Actor_with_currently_Ongoing', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Latest_Actor_partner_Actor_with_currently_Ongoing];
IF Object_ID('ties.Difference_Actor_partner_Actor_with_currently_Ongoing', 'IF') IS NOT NULL
DROP FUNCTION [ties].[Difference_Actor_partner_Actor_with_currently_Ongoing];
IF Object_ID('ties.Current_Actor_partner_Actor_with_currently_Ongoing', 'V') IS NOT NULL
DROP VIEW [ties].[Current_Actor_partner_Actor_with_currently_Ongoing];
IF Object_ID('ties.Point_Actor_partner_Actor_with_currently_Ongoing', 'IF') IS NOT NULL
DROP FUNCTION [ties].[Point_Actor_partner_Actor_with_currently_Ongoing];
IF Object_ID('ties.Latest_Actor_partner_Actor_with_currently_Ongoing', 'V') IS NOT NULL
DROP VIEW [ties].[Latest_Actor_partner_Actor_with_currently_Ongoing];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('ties.EQ_Difference_Actor_subset_Person_of', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Difference_Actor_subset_Person_of];
IF Object_ID('ties.EQ_Current_Actor_subset_Person_of', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Current_Actor_subset_Person_of];
IF Object_ID('ties.EQ_Point_Actor_subset_Person_of', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Point_Actor_subset_Person_of];
IF Object_ID('ties.EQ_Latest_Actor_subset_Person_of', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Latest_Actor_subset_Person_of];
IF Object_ID('ties.Difference_Actor_subset_Person_of', 'IF') IS NOT NULL
DROP FUNCTION [ties].[Difference_Actor_subset_Person_of];
IF Object_ID('ties.Current_Actor_subset_Person_of', 'V') IS NOT NULL
DROP VIEW [ties].[Current_Actor_subset_Person_of];
IF Object_ID('ties.Point_Actor_subset_Person_of', 'IF') IS NOT NULL
DROP FUNCTION [ties].[Point_Actor_subset_Person_of];
IF Object_ID('ties.Latest_Actor_subset_Person_of', 'V') IS NOT NULL
DROP VIEW [ties].[Latest_Actor_subset_Person_of];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('ties.EQ_Difference_in_Unknown_Actor_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Difference_in_Unknown_Actor_wasCast];
IF Object_ID('ties.EQ_Current_in_Unknown_Actor_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Current_in_Unknown_Actor_wasCast];
IF Object_ID('ties.EQ_Point_in_Unknown_Actor_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Point_in_Unknown_Actor_wasCast];
IF Object_ID('ties.EQ_Latest_in_Unknown_Actor_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Latest_in_Unknown_Actor_wasCast];
IF Object_ID('ties.Difference_in_Unknown_Actor_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [ties].[Difference_in_Unknown_Actor_wasCast];
IF Object_ID('ties.Current_in_Unknown_Actor_wasCast', 'V') IS NOT NULL
DROP VIEW [ties].[Current_in_Unknown_Actor_wasCast];
IF Object_ID('ties.Point_in_Unknown_Actor_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [ties].[Point_in_Unknown_Actor_wasCast];
IF Object_ID('ties.Latest_in_Unknown_Actor_wasCast', 'V') IS NOT NULL
DROP VIEW [ties].[Latest_in_Unknown_Actor_wasCast];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('ties.EQ_Difference_Actor_part_Program_in_got_Rating', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Difference_Actor_part_Program_in_got_Rating];
IF Object_ID('ties.EQ_Current_Actor_part_Program_in_got_Rating', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Current_Actor_part_Program_in_got_Rating];
IF Object_ID('ties.EQ_Point_Actor_part_Program_in_got_Rating', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Point_Actor_part_Program_in_got_Rating];
IF Object_ID('ties.EQ_Latest_Actor_part_Program_in_got_Rating', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Latest_Actor_part_Program_in_got_Rating];
IF Object_ID('ties.Difference_Actor_part_Program_in_got_Rating', 'IF') IS NOT NULL
DROP FUNCTION [ties].[Difference_Actor_part_Program_in_got_Rating];
IF Object_ID('ties.Current_Actor_part_Program_in_got_Rating', 'V') IS NOT NULL
DROP VIEW [ties].[Current_Actor_part_Program_in_got_Rating];
IF Object_ID('ties.Point_Actor_part_Program_in_got_Rating', 'IF') IS NOT NULL
DROP FUNCTION [ties].[Point_Actor_part_Program_in_got_Rating];
IF Object_ID('ties.Latest_Actor_part_Program_in_got_Rating', 'V') IS NOT NULL
DROP VIEW [ties].[Latest_Actor_part_Program_in_got_Rating];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('ties.EQ_Difference_Stage_at_Program_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Difference_Stage_at_Program_isPlaying];
IF Object_ID('ties.EQ_Current_Stage_at_Program_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Current_Stage_at_Program_isPlaying];
IF Object_ID('ties.EQ_Point_Stage_at_Program_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Point_Stage_at_Program_isPlaying];
IF Object_ID('ties.EQ_Latest_Stage_at_Program_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Latest_Stage_at_Program_isPlaying];
IF Object_ID('ties.Difference_Stage_at_Program_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [ties].[Difference_Stage_at_Program_isPlaying];
IF Object_ID('ties.Current_Stage_at_Program_isPlaying', 'V') IS NOT NULL
DROP VIEW [ties].[Current_Stage_at_Program_isPlaying];
IF Object_ID('ties.Point_Stage_at_Program_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [ties].[Point_Stage_at_Program_isPlaying];
IF Object_ID('ties.Latest_Stage_at_Program_isPlaying', 'V') IS NOT NULL
DROP VIEW [ties].[Latest_Stage_at_Program_isPlaying];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('ties.EQ_Difference_Actor_parent_Actor_child_having_ParentalType', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Difference_Actor_parent_Actor_child_having_ParentalType];
IF Object_ID('ties.EQ_Current_Actor_parent_Actor_child_having_ParentalType', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Current_Actor_parent_Actor_child_having_ParentalType];
IF Object_ID('ties.EQ_Point_Actor_parent_Actor_child_having_ParentalType', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Point_Actor_parent_Actor_child_having_ParentalType];
IF Object_ID('ties.EQ_Latest_Actor_parent_Actor_child_having_ParentalType', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Latest_Actor_parent_Actor_child_having_ParentalType];
IF Object_ID('ties.Difference_Actor_parent_Actor_child_having_ParentalType', 'IF') IS NOT NULL
DROP FUNCTION [ties].[Difference_Actor_parent_Actor_child_having_ParentalType];
IF Object_ID('ties.Current_Actor_parent_Actor_child_having_ParentalType', 'V') IS NOT NULL
DROP VIEW [ties].[Current_Actor_parent_Actor_child_having_ParentalType];
IF Object_ID('ties.Point_Actor_parent_Actor_child_having_ParentalType', 'IF') IS NOT NULL
DROP FUNCTION [ties].[Point_Actor_parent_Actor_child_having_ParentalType];
IF Object_ID('ties.Latest_Actor_parent_Actor_child_having_ParentalType', 'V') IS NOT NULL
DROP VIEW [ties].[Latest_Actor_parent_Actor_child_having_ParentalType];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('ties.EQ_Difference_Program_content_Stage_location_of_Unknown', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Difference_Program_content_Stage_location_of_Unknown];
IF Object_ID('ties.EQ_Current_Program_content_Stage_location_of_Unknown', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Current_Program_content_Stage_location_of_Unknown];
IF Object_ID('ties.EQ_Point_Program_content_Stage_location_of_Unknown', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Point_Program_content_Stage_location_of_Unknown];
IF Object_ID('ties.EQ_Latest_Program_content_Stage_location_of_Unknown', 'IF') IS NOT NULL
DROP FUNCTION [ties].[EQ_Latest_Program_content_Stage_location_of_Unknown];
IF Object_ID('ties.Difference_Program_content_Stage_location_of_Unknown', 'IF') IS NOT NULL
DROP FUNCTION [ties].[Difference_Program_content_Stage_location_of_Unknown];
IF Object_ID('ties.Current_Program_content_Stage_location_of_Unknown', 'V') IS NOT NULL
DROP VIEW [ties].[Current_Program_content_Stage_location_of_Unknown];
IF Object_ID('ties.Point_Program_content_Stage_location_of_Unknown', 'IF') IS NOT NULL
DROP FUNCTION [ties].[Point_Program_content_Stage_location_of_Unknown];
IF Object_ID('ties.Latest_Program_content_Stage_location_of_Unknown', 'V') IS NOT NULL
DROP VIEW [ties].[Latest_Program_content_Stage_location_of_Unknown];
GO
