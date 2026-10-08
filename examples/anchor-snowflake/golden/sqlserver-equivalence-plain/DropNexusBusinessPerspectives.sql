-- NEXUS TEMPORAL BUSINESS PERSPECTIVES -----------------------------------------------------------------------------
--
-- Drop perspectives -------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EQ_Difference_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Difference_Event];
IF Object_ID('dbo.EQ_Current_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Current_Event];
IF Object_ID('dbo.EQ_Point_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Point_Event];
IF Object_ID('dbo.EQ_Latest_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[EQ_Latest_Event];
IF Object_ID('dbo.Difference_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Difference_Event];
IF Object_ID('dbo.Current_Event', 'V') IS NOT NULL
DROP VIEW [dbo].[Current_Event];
IF Object_ID('dbo.Point_Event', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[Point_Event];
IF Object_ID('dbo.Latest_Event', 'V') IS NOT NULL
DROP VIEW [dbo].[Latest_Event];
GO
