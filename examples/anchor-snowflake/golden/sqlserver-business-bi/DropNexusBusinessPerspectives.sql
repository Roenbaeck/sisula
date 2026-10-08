-- NEXUS TEMPORAL BUSINESS PERSPECTIVES -----------------------------------------------------------------------------
--
-- Drop perspectives -------------------------------------------------------------------------------------------------
IF Object_ID('nexuses.Difference_Event', 'IF') IS NOT NULL
DROP FUNCTION [nexuses].[Difference_Event];
IF Object_ID('nexuses.Current_Event', 'V') IS NOT NULL
DROP VIEW [nexuses].[Current_Event];
IF Object_ID('nexuses.Point_Event', 'IF') IS NOT NULL
DROP FUNCTION [nexuses].[Point_Event];
IF Object_ID('nexuses.Latest_Event', 'V') IS NOT NULL
DROP VIEW [nexuses].[Latest_Event];
GO
