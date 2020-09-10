-- Prepare upgrade of model
IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'metadata')
BEGIN
	-- is job name not knotted?
	IF EXISTS (
		select * 
		 from sys.tables t
		 join sys.columns c
		   on c.object_id = t.object_id
		 join sys.schemas s
		   on s.schema_id = t.schema_id
		where t.[name] = 'JB_NAM_Job_Name'
		  and c.[name] = 'JB_NAM_Job_Name'
		  and s.[name] = 'metadata'
	)
	BEGIN
		SELECT * 
		INTO metadata.old_JB_NAM_Job_Name
		FROM metadata.JB_NAM_Job_Name;

		IF OBJECT_ID('metadata.lJB_Job') is not null 
		DROP VIEW metadata.lJB_Job;
		IF OBJECT_ID('metadata.pJB_Job') is not null 
		DROP FUNCTION metadata.pJB_Job;

		DROP TABLE metadata.JB_NAM_Job_Name;
	END

	IF EXISTS (
		select * 
		 from sys.tables t
		 join sys.columns c
		   on c.object_id = t.object_id
		 join sys.schemas s
		   on s.schema_id = t.schema_id
		where t.[name] = 'JB_AID_Job_AgentJobId'
		  and c.[name] = 'JB_AID_Job_AgentJobId'
		  and s.[name] = 'metadata'
	)
	BEGIN
		SELECT * 
		INTO metadata.old_JB_AID_Job_AgentJobId
		FROM metadata.JB_AID_Job_AgentJobId;

		IF OBJECT_ID('metadata.lJB_Job') is not null 
		DROP VIEW metadata.lJB_Job;
		IF OBJECT_ID('metadata.pJB_Job') is not null 
		DROP FUNCTION metadata.pJB_Job;

		DROP TABLE metadata.JB_AID_Job_AgentJobId;
	END

	IF EXISTS (
		select * 
		 from sys.tables t
		 join sys.columns c
		   on c.object_id = t.object_id
		 join sys.schemas s
		   on s.schema_id = t.schema_id
		where t.[name] = 'WO_NAM_Work_Name'
		  and c.[name] = 'WO_NAM_Work_Name'
		  and s.[name] = 'metadata'
	)
	BEGIN
		SELECT * 
		INTO metadata.old_WO_NAM_Work_Name
		FROM metadata.WO_NAM_Work_Name;

		IF OBJECT_ID('metadata.lWO_Work') is not null 
		DROP VIEW metadata.lWO_Work;
		IF OBJECT_ID('metadata.pWO_Work') is not null 
		DROP FUNCTION metadata.pWO_Work;

		DROP TABLE metadata.WO_NAM_Work_Name;
	END

	IF EXISTS (
		select * 
		 from sys.tables t
		 join sys.columns c
		   on c.object_id = t.object_id
		 join sys.schemas s
		   on s.schema_id = t.schema_id
		where t.[name] = 'WO_USR_Work_InvocationUser'
		  and c.[name] = 'WO_USR_Work_InvocationUser'
		  and s.[name] = 'metadata'
	)
	BEGIN
		SELECT * 
		INTO metadata.old_WO_USR_Work_InvocationUser
		FROM metadata.WO_USR_Work_InvocationUser;

		IF OBJECT_ID('metadata.lWO_Work') is not null 
		DROP VIEW metadata.lWO_Work;
		IF OBJECT_ID('metadata.pWO_Work') is not null 
		DROP FUNCTION metadata.pWO_Work;

		DROP TABLE metadata.WO_USR_Work_InvocationUser;
	END

	IF EXISTS (
		select * 
		 from sys.tables t
		 join sys.columns c
		   on c.object_id = t.object_id
		 join sys.schemas s
		   on s.schema_id = t.schema_id
		where t.[name] = 'WO_ROL_Work_InvocationRole'
		  and c.[name] = 'WO_ROL_Work_InvocationRole'
		  and s.[name] = 'metadata'
	)
	BEGIN
		SELECT * 
		INTO metadata.old_WO_ROL_Work_InvocationRole
		FROM metadata.WO_ROL_Work_InvocationRole;

		IF OBJECT_ID('metadata.lWO_Work') is not null 
		DROP VIEW metadata.lWO_Work;
		IF OBJECT_ID('metadata.pWO_Work') is not null 
		DROP FUNCTION metadata.pWO_Work;

		DROP TABLE metadata.WO_ROL_Work_InvocationRole;
	END

END




