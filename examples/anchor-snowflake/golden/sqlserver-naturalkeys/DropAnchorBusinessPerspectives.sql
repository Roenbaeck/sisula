-- ANCHOR TEMPORAL BUSINESS PERSPECTIVES ------------------------------------------------------------------------------
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('anchors.Difference_Person', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[Difference_Person];
IF Object_ID('anchors.Current_Person', 'V') IS NOT NULL
DROP VIEW [anchors].[Current_Person];
IF Object_ID('anchors.Point_Person', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[Point_Person];
IF Object_ID('anchors.Latest_Person', 'V') IS NOT NULL
DROP VIEW [anchors].[Latest_Person];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('anchors.Difference_Stage', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[Difference_Stage];
IF Object_ID('anchors.Current_Stage', 'V') IS NOT NULL
DROP VIEW [anchors].[Current_Stage];
IF Object_ID('anchors.Point_Stage', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[Point_Stage];
IF Object_ID('anchors.Latest_Stage', 'V') IS NOT NULL
DROP VIEW [anchors].[Latest_Stage];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('anchors.Difference_Actor', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[Difference_Actor];
IF Object_ID('anchors.Current_Actor', 'V') IS NOT NULL
DROP VIEW [anchors].[Current_Actor];
IF Object_ID('anchors.Point_Actor', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[Point_Actor];
IF Object_ID('anchors.Latest_Actor', 'V') IS NOT NULL
DROP VIEW [anchors].[Latest_Actor];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('anchors.Difference_Program', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[Difference_Program];
IF Object_ID('anchors.Current_Program', 'V') IS NOT NULL
DROP VIEW [anchors].[Current_Program];
IF Object_ID('anchors.Point_Program', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[Point_Program];
IF Object_ID('anchors.Latest_Program', 'V') IS NOT NULL
DROP VIEW [anchors].[Latest_Program];
GO
