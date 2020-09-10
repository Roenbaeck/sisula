-- Restore historical data into the new model structure
IF EXISTS (
	select * 
	  from sys.tables t
	  join sys.schemas s
	    on s.schema_id = t.schema_id
	 where t.[name] like 'old[_]%'
	   and s.[name] = 'metadata'
)
BEGIN
	-- load knot and fetch history from the old table
	IF EXISTS (
		select * 
		 from sys.tables t
		 join sys.schemas s
		   on s.schema_id = t.schema_id
		where t.[name] = 'old_JB_NAM_Job_Name'
		  and s.[name] = 'metadata'
	)
	BEGIN
		INSERT INTO metadata.JON_JobName (
			[JON_JobName]
		)
		SELECT DISTINCT
			JB_NAM_Job_Name
		FROM 
			metadata.old_JB_NAM_Job_Name;

		INSERT INTO metadata.JB_NAM_Job_Name (
			[JB_NAM_JB_ID], 
			[JB_NAM_JON_ID]
		)
		SELECT
			old.JB_NAM_JB_ID,
			knot.JON_ID
		FROM
			metadata.old_JB_NAM_Job_Name old
		JOIN 
			metadata.JON_JobName knot
		ON
			knot.JON_JobName = old.JB_NAM_Job_Name;

		DROP TABLE metadata.old_JB_NAM_Job_Name;
	END

	IF EXISTS (
		select * 
		 from sys.tables t
		 join sys.schemas s
		   on s.schema_id = t.schema_id
		where t.[name] = 'old_JB_AID_Job_AgentJobId'
		  and s.[name] = 'metadata'
	)
	BEGIN
		INSERT INTO metadata.AID_AgentJobId (
			[AID_AgentJobId]
		)
		SELECT DISTINCT
			JB_AID_Job_AgentJobId
		FROM 
			metadata.old_JB_AID_Job_AgentJobId;

		INSERT INTO metadata.JB_AID_Job_AgentJobId (
			[JB_AID_JB_ID], 
			[JB_AID_AID_ID]
		)
		SELECT
			old.JB_AID_JB_ID,
			knot.AID_ID
		FROM
			metadata.old_JB_AID_Job_AgentJobId old
		JOIN 
			metadata.AID_AgentJobId knot
		ON
			knot.AID_AgentJobId = old.JB_AID_Job_AgentJobId;

		DROP TABLE metadata.old_JB_AID_Job_AgentJobId;
	END

	IF EXISTS (
		select * 
		 from sys.tables t
		 join sys.schemas s
		   on s.schema_id = t.schema_id
		where t.[name] = 'old_WO_NAM_Work_Name'
		  and s.[name] = 'metadata'
	)
	BEGIN
		INSERT INTO [metadata].[WON_WorkName] (
			[WON_WorkName]
		)
		SELECT DISTINCT
			WO_NAM_Work_Name
		FROM 
			metadata.old_WO_NAM_Work_Name;

		INSERT INTO metadata.WO_NAM_Work_Name (
			WO_NAM_WO_ID,
			WO_NAM_WON_ID
		)
		SELECT
			old.WO_NAM_WO_ID,
			knot.WON_ID
		FROM
			metadata.old_WO_NAM_Work_Name old
		JOIN 
			[metadata].[WON_WorkName] knot
		ON
			knot.WON_WorkName = old.WO_NAM_Work_Name;

		DROP TABLE metadata.old_WO_NAM_Work_Name;
	END

	IF EXISTS (
		select * 
		 from sys.tables t
		 join sys.schemas s
		   on s.schema_id = t.schema_id
		where t.[name] = 'old_WO_USR_Work_InvocationUser'
		  and s.[name] = 'metadata'
	)
	BEGIN
		INSERT INTO [metadata].[WIU_WorkInvocationUser] (
			[WIU_WorkInvocationUser]
		)
		SELECT DISTINCT
			WO_USR_Work_InvocationUser
		FROM 
			metadata.old_WO_USR_Work_InvocationUser;

		INSERT INTO metadata.WO_USR_Work_InvocationUser (
			WO_USR_WO_ID,
			WO_USR_WIU_ID
		)
		SELECT
			old.WO_USR_WO_ID,
			knot.WIU_ID
		FROM
			metadata.old_WO_USR_Work_InvocationUser old
		JOIN 
			[metadata].[WIU_WorkInvocationUser] knot
		ON
			knot.WIU_WorkInvocationUser = old.WO_USR_Work_InvocationUser;

		DROP TABLE metadata.old_WO_USR_Work_InvocationUser;
	END

	IF EXISTS (
		select * 
		 from sys.tables t
		 join sys.schemas s
		   on s.schema_id = t.schema_id
		where t.[name] = 'old_WO_ROL_Work_InvocationRole'
		  and s.[name] = 'metadata'
	)
	BEGIN
		INSERT INTO [metadata].[WIR_WorkInvocationRole] (
			[WIR_WorkInvocationRole]
		)
		SELECT DISTINCT
			WO_ROL_Work_InvocationRole
		FROM 
			metadata.old_WO_ROL_Work_InvocationRole;

		INSERT INTO metadata.WO_ROL_Work_InvocationRole (
			WO_ROL_WO_ID,
			WO_ROL_WIR_ID
		)
		SELECT
			old.WO_ROL_WO_ID,
			knot.WIR_ID
		FROM
			metadata.old_WO_ROL_Work_InvocationRole old
		JOIN 
			[metadata].[WIR_WorkInvocationRole] knot
		ON
			knot.WIR_WorkInvocationRole = old.WO_ROL_Work_InvocationRole;

		DROP TABLE metadata.old_WO_ROL_Work_InvocationRole;
	END

END
