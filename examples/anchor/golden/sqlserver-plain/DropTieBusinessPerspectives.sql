-- TIE TEMPORAL BUSINESS PERSPECTIVES ---------------------------------------------------------------------------------
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Actor_partner_Actor_with_currently_Ongoing', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Actor_partner_Actor_with_currently_Ongoing];
IF Object_ID('dbo.Current_Actor_partner_Actor_with_currently_Ongoing', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Actor_partner_Actor_with_currently_Ongoing];
IF Object_ID('dbo.Point_Actor_partner_Actor_with_currently_Ongoing', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Actor_partner_Actor_with_currently_Ongoing];
IF Object_ID('dbo.Latest_Actor_partner_Actor_with_currently_Ongoing', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Actor_partner_Actor_with_currently_Ongoing];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Actor_subset_Person_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Actor_subset_Person_of];
IF Object_ID('dbo.Current_Actor_subset_Person_of', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Actor_subset_Person_of];
IF Object_ID('dbo.Point_Actor_subset_Person_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Actor_subset_Person_of];
IF Object_ID('dbo.Latest_Actor_subset_Person_of', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Actor_subset_Person_of];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_in_Unknown_Actor_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_in_Unknown_Actor_wasCast];
IF Object_ID('dbo.Current_in_Unknown_Actor_wasCast', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_in_Unknown_Actor_wasCast];
IF Object_ID('dbo.Point_in_Unknown_Actor_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_in_Unknown_Actor_wasCast];
IF Object_ID('dbo.Latest_in_Unknown_Actor_wasCast', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_in_Unknown_Actor_wasCast];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Actor_part_Program_in_got_Rating', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Actor_part_Program_in_got_Rating];
IF Object_ID('dbo.Current_Actor_part_Program_in_got_Rating', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Actor_part_Program_in_got_Rating];
IF Object_ID('dbo.Point_Actor_part_Program_in_got_Rating', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Actor_part_Program_in_got_Rating];
IF Object_ID('dbo.Latest_Actor_part_Program_in_got_Rating', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Actor_part_Program_in_got_Rating];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Stage_at_Program_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Stage_at_Program_isPlaying];
IF Object_ID('dbo.Current_Stage_at_Program_isPlaying', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Stage_at_Program_isPlaying];
IF Object_ID('dbo.Point_Stage_at_Program_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Stage_at_Program_isPlaying];
IF Object_ID('dbo.Latest_Stage_at_Program_isPlaying', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Stage_at_Program_isPlaying];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Actor_parent_Actor_child_having_ParentalType', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Actor_parent_Actor_child_having_ParentalType];
IF Object_ID('dbo.Current_Actor_parent_Actor_child_having_ParentalType', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Actor_parent_Actor_child_having_ParentalType];
IF Object_ID('dbo.Point_Actor_parent_Actor_child_having_ParentalType', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Actor_parent_Actor_child_having_ParentalType];
IF Object_ID('dbo.Latest_Actor_parent_Actor_child_having_ParentalType', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Actor_parent_Actor_child_having_ParentalType];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.Difference_Program_content_Stage_location_of_Unknown', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Program_content_Stage_location_of_Unknown];
IF Object_ID('dbo.Current_Program_content_Stage_location_of_Unknown', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Program_content_Stage_location_of_Unknown];
IF Object_ID('dbo.Point_Program_content_Stage_location_of_Unknown', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Program_content_Stage_location_of_Unknown];
IF Object_ID('dbo.Latest_Program_content_Stage_location_of_Unknown', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Program_content_Stage_location_of_Unknown];
GO
