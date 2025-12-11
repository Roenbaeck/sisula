/*
	These provide a slight performance improvement when you have 
	collected lots of metadata (for example more than 5 million 
	WO_Work instances) and the time it takes to run _WorkStarting 
	is a significant portion of the total job time.

*/
-----------------------------------------------------------------
DROP INDEX IF EXISTS ix_WO_part_JB_of
ON [metadata].[WO_part_JB_of];

CREATE NONCLUSTERED INDEX ix_WO_part_JB_of
ON [metadata].[WO_part_JB_of] ([JB_ID_of]);
-----------------------------------------------------------------
DROP INDEX IF EXISTS ix_WO_NAM_Work_Name
ON [metadata].[WO_NAM_Work_Name];

CREATE NONCLUSTERED INDEX ix_WO_NAM_Work_Name
ON [metadata].[WO_NAM_Work_Name] ([WO_NAM_WON_ID])
INCLUDE (WO_NAM_WO_ID);
-----------------------------------------------------------------
DROP INDEX IF EXISTS ix_JB_EST_Job_ExecutionStatus
ON [metadata].[JB_EST_Job_ExecutionStatus];

CREATE NONCLUSTERED INDEX ix_JB_EST_Job_ExecutionStatus
ON [metadata].[JB_EST_Job_ExecutionStatus] ([JB_EST_EST_ID])
INCLUDE (JB_EST_JB_ID);
-----------------------------------------------------------------
DROP INDEX IF EXISTS ix_JB_AID_Job_AgentJobId
ON [metadata].[JB_AID_Job_AgentJobId];

CREATE NONCLUSTERED INDEX ix_JB_AID_Job_AgentJobId
ON [metadata].[JB_AID_Job_AgentJobId] ([JB_AID_AID_ID])
INCLUDE (JB_AID_JB_ID);
-----------------------------------------------------------------
DROP INDEX IF EXISTS ix_JB_NAM_Job_Name
ON [metadata].[JB_NAM_Job_Name];

CREATE NONCLUSTERED INDEX ix_JB_NAM_Job_Name
ON [metadata].[JB_NAM_Job_Name] ([JB_NAM_JON_ID])
INCLUDE (JB_NAM_JB_ID);
-----------------------------------------------------------------
-- We will set up "hot" indexes to find recent running tasks.
-- These are added as agent jobs since they need daily updating.
-----------------------------------------------------------------
DECLARE @jobId BINARY(16);
DECLARE @db varchar(555) = DB_NAME();

DECLARE @job varchar(555) = 'Update Work hot metadata index in ' + @db;

IF EXISTS (select * from msdb.dbo.sysjobs where [name] = @job)
EXEC msdb.dbo.sp_delete_job @job_name = @job;

EXEC msdb.dbo.sp_add_job 
		@job_name=@job, 
		@enabled=1, 
		@job_id = @jobId OUTPUT;

EXEC msdb.dbo.sp_add_jobstep 
		@job_id=@jobId, 
		@step_name=N'Recreate hot index', 
		@step_id=1, 
		@subsystem=N'TSQL',
		@database_name=@db, 
		@command=N'
		SET QUOTED_IDENTIFIER ON;

		DROP INDEX IF EXISTS ix_WO_EST_Work_ExecutionStatus
		ON [metadata].[WO_EST_Work_ExecutionStatus]

		DECLARE @yesterday DATETIME2(7) = cast(dateadd(day, -1, getdate()) as date);
		DECLARE @EST_ID__running INT = (select EST_ID from metadata.EST_ExecutionStatus where EST_ExecutionStatus = ''Running'')
		DECLARE @SQL VARCHAR(max);

		SET @SQL = ''
			CREATE NONCLUSTERED INDEX ix_WO_EST_Work_ExecutionStatus
			ON [metadata].[WO_EST_Work_ExecutionStatus] ([WO_EST_EST_ID])
			INCLUDE (WO_EST_WO_ID)
			WHERE WO_EST_EST_ID = '' + cast(@EST_ID__running as varchar(10)) + '' AND WO_EST_ChangedAt >= '''''' + convert(char(27), @yesterday, 121) + ''''''
		'';
		EXEC(@SQL);
		';

EXEC msdb.dbo.sp_add_jobschedule 
		@job_id=@jobId, 
		@name=N'Daily just after midnight', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@active_start_time=0;

EXEC msdb.dbo.sp_add_jobserver 
		@job_id = @jobId, 
		@server_name = N'(local)';

EXEC msdb.dbo.sp_start_job @job_name = @job;
GO
-----------------------------------------------------------------
DECLARE @jobId BINARY(16)
DECLARE @db varchar(555) = DB_NAME();

DECLARE @job varchar(555) = 'Update Job hot metadata index in ' + @db;

IF EXISTS (select * from msdb.dbo.sysjobs where [name] = @job)
EXEC msdb.dbo.sp_delete_job @job_name = @job;

EXEC msdb.dbo.sp_add_job 
		@job_name=@job, 
		@enabled=1, 
		@job_id = @jobId OUTPUT;

EXEC msdb.dbo.sp_add_jobstep 
		@job_id=@jobId, 
		@step_name=N'Recreate hot index', 
		@step_id=1, 
		@subsystem=N'TSQL',
		@database_name=@db, 
		@command=N'
		SET QUOTED_IDENTIFIER ON;

		DROP INDEX IF EXISTS ix_JB_EST_Job_ExecutionStatus
		ON [metadata].[JB_EST_Job_ExecutionStatus]

		DECLARE @yesterday DATETIME2(7) = cast(dateadd(day, -1, getdate()) as date);
		DECLARE @EST_ID__running INT = (select EST_ID from metadata.EST_ExecutionStatus where EST_ExecutionStatus = ''Running'')
		DECLARE @SQL VARCHAR(max);

		SET @SQL = ''
			CREATE NONCLUSTERED INDEX ix_JB_EST_Job_ExecutionStatus
			ON [metadata].[JB_EST_Job_ExecutionStatus] ([JB_EST_EST_ID])
			INCLUDE (JB_EST_JB_ID)
			WHERE JB_EST_EST_ID = '' + cast(@EST_ID__running as varchar(10)) + '' AND JB_EST_ChangedAt >= '''''' + convert(char(27), @yesterday, 121) + ''''''
		'';
		EXEC(@SQL);
		';

EXEC msdb.dbo.sp_add_jobschedule 
		@job_id=@jobId, 
		@name=N'Daily just after midnight', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@active_start_time=0;

EXEC msdb.dbo.sp_add_jobserver 
		@job_id = @jobId, 
		@server_name = N'(local)';

EXEC msdb.dbo.sp_start_job @job_name = @job;
GO
-----------------------------------------------------------------
		