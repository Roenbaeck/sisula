-- ANCHOR TEMPORAL BUSINESS PERSPECTIVES ------------------------------------------------------------------------------
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EQ_Difference_Person', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Difference_Person];
IF Object_ID('dbo.EQ_Current_Person', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Current_Person];
IF Object_ID('dbo.EQ_Point_Person', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Point_Person];
IF Object_ID('dbo.EQ_Latest_Person', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Latest_Person];
IF Object_ID('dbo.Difference_Person', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Person];
IF Object_ID('dbo.Current_Person', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Person];
IF Object_ID('dbo.Point_Person', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Person];
IF Object_ID('dbo.Latest_Person', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Person];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EQ_Difference_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Difference_Stage];
IF Object_ID('dbo.EQ_Current_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Current_Stage];
IF Object_ID('dbo.EQ_Point_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Point_Stage];
IF Object_ID('dbo.EQ_Latest_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Latest_Stage];
IF Object_ID('dbo.Difference_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Stage];
IF Object_ID('dbo.Current_Stage', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Stage];
IF Object_ID('dbo.Point_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Stage];
IF Object_ID('dbo.Latest_Stage', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Stage];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EQ_Difference_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Difference_Actor];
IF Object_ID('dbo.EQ_Current_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Current_Actor];
IF Object_ID('dbo.EQ_Point_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Point_Actor];
IF Object_ID('dbo.EQ_Latest_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Latest_Actor];
IF Object_ID('dbo.Difference_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Actor];
IF Object_ID('dbo.Current_Actor', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Actor];
IF Object_ID('dbo.Point_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Actor];
IF Object_ID('dbo.Latest_Actor', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Actor];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EQ_Difference_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Difference_Program];
IF Object_ID('dbo.EQ_Current_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Current_Program];
IF Object_ID('dbo.EQ_Point_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Point_Program];
IF Object_ID('dbo.EQ_Latest_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Latest_Program];
IF Object_ID('dbo.Difference_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Program];
IF Object_ID('dbo.Current_Program', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Program];
IF Object_ID('dbo.Point_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Program];
IF Object_ID('dbo.Latest_Program', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Program];
GO
