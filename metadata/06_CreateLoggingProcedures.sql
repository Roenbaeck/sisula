/*
             CREATE PROCEDURES FOR LOGGING
*/

if Object_Id('metadata._Now', 'FN') is not null
drop function metadata._Now;
go

create function metadata._Now()
returns datetime2(7)
as
begin
	return SYSUTCDATETIME();
end
go

--------------------------- Starting Job ----------------------------
if Object_Id('metadata._JobStarting', 'P') is not null
drop procedure metadata._JobStarting;
go

create procedure metadata._JobStarting (
	@workflowName varchar(255),
	@jobName varchar(255),
	@agentJobId uniqueidentifier,
	@start datetime2(7) = null
)
as
begin
	-- prevent deadlocks when jobs run in parallel
	EXEC sp_getapplock 	@Resource    = 'metadata',  
     					@LockOwner   = 'Session',
     					@LockMode    = 'Exclusive',
						@LockTimeout = 60000;

	set @start = isnull(@start, metadata._Now());
	declare @JB_ID int;
	declare @CF_ID int;

	-- knot lookup
	declare @JON_ID int = (
		select JON_ID from metadata.JON_JobName where JON_JobName = @jobName
	);

	declare @AID_ID int = (
		select AID_ID from metadata.AID_AgentJobId where AID_AgentJobId = @agentJobId
	);

	if @AID_ID is null
	begin
		set @AID_ID = (
			select AID_ID from metadata.AID_AgentJobId where AID_AgentJobId = (
				select top 1 JB_AID_AID_AgentJobId
				from metadata.lJB_Job where JB_NAM_JON_ID = @JON_ID
			)
		);
	end

	declare @EST_ID tinyint = (
		select EST_ID from metadata.EST_ExecutionStatus where EST_ExecutionStatus = 'Running'
	);

	-- is this job already started?
	select 
		@JB_ID = JB_EST_JB_ID
	from (
		select top 1 
			est.JB_EST_JB_ID, 
			est.JB_EST_EST_ID
		from 
			metadata.JB_AID_Job_AgentJobId aid
		join 
			metadata.JB_NAM_Job_Name nam
		on 
			nam.JB_NAM_JB_ID = aid.JB_AID_JB_ID
		and 
			nam.JB_NAM_JON_ID = @JON_ID
		join
			metadata.JB_EST_Job_ExecutionStatus est 
		on
			est.JB_EST_JB_ID = nam.JB_NAM_JB_ID
		where
			aid.JB_AID_AID_ID = @AID_ID
		order by 
			est.JB_EST_ChangedAt desc
	) jb
	where 
		jb.JB_EST_EST_ID = @EST_ID;

	-- start it if it is not running
	if(@JB_ID is null)
	begin
		-- add to knot if it is not already there
		insert into metadata.JON_JobName (
			JON_JobName
		)
		select
			@jobName
		where not exists (
			select 
				JON_JobName
			from
				metadata.JON_JobName
			where
				JON_JobName = @jobName
		);

		-- add to knot if it is not already there
		insert into metadata.AID_AgentJobId (
			AID_AgentJobId
		)
		select
			@agentJobId
		where not exists (
			select 
				AID_AgentJobId
			from
				metadata.AID_AgentJobId
			where
				AID_AgentJobId = @agentJobId
		);

		insert into metadata.lJB_Job (
			JB_NAM_JON_JobName,
			JB_STA_Job_Start,
			JB_AID_AID_AgentJobId,
			JB_EST_ChangedAt,
			JB_EST_EST_ExecutionStatus
		)
		values (
			@jobName,
			@start,
			@agentJobId,
			@start, -- same as job start
			'Running'
		);

		set @JB_ID = IDENT_CURRENT('metadata.JB_Job');
	end

	-- see if this job has a stored configuration
	select
		@CF_ID = CF_ID
	from
		metadata.lCF_Configuration
	where
		CF_NAM_Configuration_Name = @workflowName
	and
		CF_TYP_CFT_ConfigurationType = 'Workflow';

	if(@CF_ID is not null)
	begin
		-- connect the job with the configuration
		merge metadata.lJB_formed_CF_from as jbcf
		using (
			values (
				@JB_ID,
				@CF_ID
			)
		) v (JB_ID, CF_ID)
		on
			v.JB_ID = jbcf.JB_ID_formed
		when not matched then
		insert (
			JB_ID_formed,
			CF_ID_from
		)
		values (
			v.JB_ID,
			v.CF_ID
		);
	end

	EXEC sp_releaseapplock 	@Resource  = 'metadata',  
     						@LockOwner = 'Session';
end
go

--------------------------- Stopping Job ----------------------------
if Object_Id('metadata._JobStopping', 'P') is not null
drop procedure metadata._JobStopping;
go

create procedure metadata._JobStopping (
	@name varchar(255),
	@status varchar(42) = 'Success',
	@stop datetime2(7) = null
)
as
begin
	-- prevent deadlocks when jobs run in parallel
	EXEC sp_getapplock 	@Resource    = 'metadata',  
     					@LockOwner   = 'Session',
     					@LockMode    = 'Exclusive',
						@LockTimeout = 60000;

	-- add a chronon in order to guarantee uniqueness (if shorter duration)
	set @stop = isnull(@stop, dateadd(nanosecond, 100, metadata._Now()));
	set @status = isnull(@status, 'Success');

	declare @agentJobId uniqueidentifier;
	declare @JB_ID int;

	-- knot lookup
	declare @JON_ID int = (
		select JON_ID from metadata.JON_JobName where JON_JobName = @name
	);

	declare @AID_ID int = (
		select AID_ID from metadata.AID_AgentJobId where AID_AgentJobId = @agentJobId
	);

	if @AID_ID is null
	begin
		set @AID_ID = (
			select AID_ID from metadata.AID_AgentJobId where AID_AgentJobId = (
				select top 1 JB_AID_AID_AgentJobId
				from metadata.lJB_Job where JB_NAM_JON_ID = @JON_ID
			)
		);
	end

	declare @EST_ID tinyint = (
		select EST_ID from metadata.EST_ExecutionStatus where EST_ExecutionStatus = 'Running'
	);


	-- ensure this job is running!
	select top 1 
		@agentJobId = JB_AID_AID_AgentJobId,
		@JB_ID = JB_ID
	from
		metadata.lJB_Job
	where
		JB_NAM_JON_ID = @JON_ID
	and
		JB_EST_EST_ID = @EST_ID
	order by
		JB_ID desc;

	if(@JB_ID is not null)
	begin
		if(@status = 'Success')
		begin
			update jb
			set
				jb.JB_END_Job_End = @stop,
				jb.JB_EST_ChangedAt = @stop, -- same as job stop
				jb.JB_EST_EST_ExecutionStatus = 'Success'
			from
				metadata.lJB_Job jb
			where
				jb.JB_ID = @JB_ID;
		end
		if(@status = 'Failure')
		begin
			update jb
			set
				jb.JB_END_Job_End = @stop,
				jb.JB_EST_ChangedAt = @stop, -- same as job stop
				jb.JB_EST_EST_ExecutionStatus = 'Failure'
			from
				metadata.lJB_Job jb
			where
				jb.JB_ID = @JB_ID;
		end
	end

	-- if this job has running work they need to be stopped
	-- which can happen when statement-level recompilation errors occur
	-- such as a missing table
	select
		wo.WO_ID,
		wo.WO_AID_Work_AgentStepId
	into
		#WO_ID
	from 
		metadata.lJB_Job jb
	join
		metadata.lWO_part_JB_of wojb
	on
		wojb.JB_ID_of = jb.JB_ID
	join
		metadata.lWO_Work wo
	on
		wo.WO_ID = wojb.WO_ID_part 
	and
		wo.WO_EST_EST_ID = @EST_ID
	where
		jb.JB_ID = @JB_ID;

	-- try to figure out the error message from the agent job history
	if exists (
		select top 1 WO_ID from #WO_ID
	)
	begin
		merge metadata.lWO_Work wo
		using (
			select
				wo.WO_ID,
				lh.[message]
			from 
				#WO_ID wo
			cross apply (
				select top 1
					[message]
				from
					MSDB.dbo.sysjobhistory history
				where
					history.job_id = @agentJobId
				and
					history.run_status = 0 -- unclean exit
			    and
			    	history.step_id = wo.WO_AID_Work_AgentStepId
			    order by 
			    	history.run_date desc, history.run_time desc
		    ) lh
		) fail
		on 
			wo.WO_ID = fail.WO_ID
		when matched then update
		set
			wo.WO_END_Work_End = @stop,
			wo.WO_EST_ChangedAt = @stop, 
			wo.WO_EST_EST_ExecutionStatus = @status,
			wo.WO_ERM_Work_ErrorMessage = case when @status = 'Failure' then fail.[message] end;
	end

	EXEC sp_releaseapplock 	@Resource  = 'metadata',  
     						@LockOwner = 'Session';
end
go

--------------------------- Starting Work ---------------------------
if Object_Id('metadata._WorkStarting', 'P') is not null
drop procedure metadata._WorkStarting;
go

create procedure metadata._WorkStarting (
	@configurationName varchar(255),
	@configurationType varchar(42),
	@WO_ID int output,
	@name varchar(255),
	@agentStepId smallint = null,
	@agentJobId uniqueidentifier = null,
	@start datetime2(7) = null,
	@user varchar(555) = null,
	@role varchar(42) = null
)
as
begin
	-- prevent deadlocks when jobs run in parallel
	EXEC sp_getapplock 	@Resource    = 'metadata',  
     					@LockOwner   = 'Session',
     					@LockMode    = 'Exclusive',
						@LockTimeout = 60000;

	set @start = isnull(@start, metadata._Now());
	set @user = isnull(@user, SYSTEM_USER);
	set @role = isnull(@role, USER);

	declare @JB_ID int;
	declare @CF_ID int;

	-- knot lookup
	declare @WON_ID int = (
		select WON_ID from metadata.WON_WorkName where WON_WorkName = @name
	);

	declare @AID_ID int = (
		select AID_ID from metadata.AID_AgentJobId where AID_AgentJobId = @agentJobId
	);

	if @AID_ID is null
	begin
		set @AID_ID = (
			select AID_ID from metadata.AID_AgentJobId where AID_AgentJobId = (
				select top 1 jb.JB_AID_AID_AgentJobId
				from metadata.lWO_Work wo
				join metadata.lWO_part_JB_of wojb
				on wojb.WO_ID_part = wo.WO_ID
				join metadata.lJB_Job jb
				on jb.JB_ID = wojb.JB_ID_of
				where wo.WO_NAM_WON_ID = @WON_ID
				order by jb.JB_STA_Job_Start desc
			)
		);
	end

	declare @EST_ID tinyint = (
		select EST_ID from metadata.EST_ExecutionStatus where EST_ExecutionStatus = 'Running'
	);

	-- find the running job
	set @JB_ID = (
		select top 1 
			aid.JB_AID_JB_ID
		from metadata.JB_AID_Job_AgentJobId aid
		cross apply (
			select top 1 JB_EST_EST_ID
			from metadata.JB_EST_Job_ExecutionStatus
			where JB_EST_JB_ID = aid.JB_AID_JB_ID
			order by JB_EST_ChangedAt desc
		) est
		where aid.JB_AID_AID_ID = @AID_ID
		and est.JB_EST_EST_ID = @EST_ID
		order by aid.JB_AID_JB_ID desc
	);

	-- find if this work is running and connected
	set @WO_ID = (
		select top 1 wojb.WO_ID_part
		from metadata.lWO_part_JB_of wojb
		cross apply (
			select top 1 wo_est.WO_EST_EST_ID
			from metadata.WO_EST_Work_ExecutionStatus wo_est
			join metadata.WO_NAM_Work_Name wo_nam
			on wo_nam.WO_NAM_WO_ID = wo_est.WO_EST_WO_ID
			and wo_nam.WO_NAM_WON_ID = @WON_ID
			where wo_est.WO_EST_WO_ID = wojb.WO_ID_part
			order by wo_est.WO_EST_ChangedAt desc
		) est
		where wojb.JB_ID_of = @JB_ID
		and est.WO_EST_EST_ID = @EST_ID
		order by wojb.WO_ID_part desc
	)

	if(@WO_ID is null)
	begin
		-- add to knot if it is not already there
		insert into metadata.WON_WorkName (
			WON_WorkName
		)
		select
			@name
		where not exists (
			select 
				WON_WorkName
			from
				metadata.WON_WorkName
			where
				WON_WorkName = @name
		);

		-- add to knot if it is not already there
		insert into metadata.WIU_WorkInvocationUser (
			WIU_WorkInvocationUser
		)
		select
			@user
		where not exists (
			select 
				WIU_WorkInvocationUser
			from
				metadata.WIU_WorkInvocationUser
			where
				WIU_WorkInvocationUser = @user
		);

		-- add to knot if it is not already there
		insert into metadata.WIR_WorkInvocationRole (
			WIR_WorkInvocationRole
		)
		select
			@role
		where not exists (
			select 
				WIR_WorkInvocationRole
			from
				metadata.WIR_WorkInvocationRole
			where
				WIR_WorkInvocationRole = @role
		);

		insert into metadata.lWO_Work (
			WO_NAM_WON_WorkName,
			WO_STA_Work_Start,
			WO_USR_WIU_WorkInvocationUser,
			WO_ROL_WIR_WorkInvocationRole,
			WO_AID_Work_AgentStepId,
			WO_EST_ChangedAt,
			WO_EST_EST_ExecutionStatus
		)
		values (
			@name,
			@start,
			@user,
			@role,
			@agentStepId,
			@start, -- same as job start
			'Running'
		);

		set @WO_ID = IDENT_CURRENT('metadata.WO_Work');
	end

	if(@JB_ID is not null)
	begin
		merge metadata.lWO_part_JB_of as wojb
		using (
			values (
				@WO_ID,
				@JB_ID
			)
		) v (WO_ID, JB_ID)
		on
			v.WO_ID = wojb.WO_ID_part
		when not matched then
		insert (
			WO_ID_part,
			JB_ID_of
		)
		values (
			v.WO_ID,
			v.JB_ID
		);
	end

	-- see if this work has a stored configuration
	select
		@CF_ID = CF_ID
	from
		metadata.lCF_Configuration
	where
		CF_NAM_Configuration_Name = @configurationName
	and
		CF_TYP_CFT_ConfigurationType = @configurationType;

	if(@CF_ID is not null)
	begin
		-- connect the work with the configuration
		merge metadata.lWO_formed_CF_from as wocf
		using (
			values (
				@WO_ID,
				@CF_ID
			)
		) v (WO_ID, CF_ID)
		on
			v.WO_ID = wocf.WO_ID_formed
		when not matched then
		insert (
			WO_ID_formed,
			CF_ID_from
		)
		values (
			v.WO_ID,
			v.CF_ID
		);
	end

	EXEC sp_releaseapplock 	@Resource  = 'metadata',  
     						@LockOwner = 'Session';
end
go

--------------------------- Stopping Work ---------------------------
if Object_Id('metadata._WorkStopping', 'P') is not null
drop procedure metadata._WorkStopping;
go

create procedure metadata._WorkStopping (
	@WO_ID int,
	@status varchar(42) = 'Success',
	@errorLine int = null,
	@errorMessage varchar(555) = null,
	@stop datetime2(7) = null
)
as
begin
	-- prevent deadlocks when jobs run in parallel
	EXEC sp_getapplock 	@Resource    = 'metadata',  
     					@LockOwner   = 'Session',
     					@LockMode    = 'Exclusive',
						@LockTimeout = 60000;

	-- add a chronon in order to guarantee uniqueness (if shorter duration)
	set @stop = isnull(@stop, dateadd(nanosecond, 100, metadata._Now()));
	set @status = isnull(@status, 'Success');

	declare @EST_ID tinyint = (
		select EST_ID from metadata.EST_ExecutionStatus where EST_ExecutionStatus = 'Running'
	);

	-- ensure this work is running!
	select
		@WO_ID = WO_ID
	from
		metadata.lWO_Work
	where
		WO_ID = @WO_ID
	and
		WO_EST_EST_ID = @EST_ID;

	if(@WO_ID is not null)
	begin
		if(@status = 'Success')
		begin
			update metadata.lWO_Work
			set
				WO_END_Work_End = @stop,
				WO_EST_ChangedAt = @stop, -- same as job stop
				WO_EST_EST_ExecutionStatus = 'Success'
			where
				WO_ID = @WO_ID;
		end
		if(@status = 'Failure')
		begin
			update metadata.lWO_Work
			set
				WO_END_Work_End = @stop,
				WO_EST_ChangedAt = @stop, -- same as job stop
				WO_EST_EST_ExecutionStatus = 'Failure',
				WO_ERL_Work_ErrorLine = @errorLine,
				WO_ERM_Work_ErrorMessage = @errorMessage
			where
				WO_ID = @WO_ID;
		end
	end

	EXEC sp_releaseapplock 	@Resource  = 'metadata',  
     						@LockOwner = 'Session';
end
go

--------------------------- Source to Target ---------------------------
if Object_Id('metadata._WorkSourceToTarget', 'P') is not null
drop procedure metadata._WorkSourceToTarget;
go

create procedure metadata._WorkSourceToTarget (
	@OP_ID int output,
	@WO_ID int,
	@sourceName varchar(555),
	@targetName varchar(555),
	@sourceType varchar(42) = 'Table',
	@targetType varchar(42) = 'Table',
	@sourceCreated datetime = null,
	@targetCreated datetime = null
)
as
begin
	-- prevent deadlocks when jobs run in parallel
	EXEC sp_getapplock 	@Resource    = 'metadata',  
     					@LockOwner   = 'Session',
     					@LockMode    = 'Exclusive',
						@LockTimeout = 60000;

	declare @now datetime = metadata._Now();
	set @sourceType = isnull(@sourceType, 'Table');
	set @targetType = isnull(@targetType, 'Table');
	set @sourceCreated = isnull(@sourceCreated, metadata._Now());
	set @targetCreated = isnull(@targetCreated, metadata._Now());

	-- ensure this work is running!
	select
		@WO_ID = WO_ID
	from
		metadata.lWO_Work
	where
		WO_ID = @WO_ID
	and
		WO_EST_EST_ExecutionStatus = 'Running';

	if(@WO_ID is not null)
	begin
		declare @CO_ID_source int;
		select
			@CO_ID_source = CO_ID
		from
			metadata.lCO_Container
		where
			CO_NAM_Container_Name = @sourceName
		and
			CO_TYP_COT_ContainerType = @sourceType
		and
			-- files are new containers if they have a different created date but same name
			case
				when @sourceType = 'File' and CO_CRE_Container_Created <> @sourceCreated
				then 0
				else 1
			end = 1;

		-- create the container if it does not exist
		if(@CO_ID_source is null)
		begin
			insert into lCO_Container (
				CO_NAM_Container_Name,
				CO_TYP_COT_ContainerType,
				CO_CRE_Container_Created,
				CO_DSC_Container_Discovered
			)
			values (
				@sourceName,
				@sourceType,
				@sourceCreated,
				@now
			);

			select
				@CO_ID_source = CO_ID
			from
				lCO_Container
			where
				CO_NAM_Container_Name = @sourceName
			and
				CO_TYP_COT_ContainerType = @sourceType
			and
				CO_CRE_Container_Created = @sourceCreated;
		end
		-- otherwise update the discovery (but only done for files)
		else if (@sourceType = 'File')
		begin
			update lCO_Container
			set
				CO_DSC_Container_Discovered = @now
			where
				CO_ID = @CO_ID_source;
		end

		declare @CO_ID_target int;
		select
			@CO_ID_target = CO_ID
		from
			lCO_Container
		where
			CO_NAM_Container_Name = @targetName
		and
			CO_TYP_COT_ContainerType = @targetType
		and
			-- files are new containers even if they have the same name
			case
				when @targetType = 'File' and CO_CRE_Container_Created <> @targetCreated
				then 0
				else 1
			end = 1;

		-- create the container if it does not exist
		if(@CO_ID_target is null)
		begin
			insert into lCO_Container (
				CO_NAM_Container_Name,
				CO_TYP_COT_ContainerType,
				CO_CRE_Container_Created,
				CO_DSC_Container_Discovered
			)
			values (
				@targetName,
				@targetType,
				@targetCreated,
				@now
			);

			select
				@CO_ID_target = CO_ID
			from
				lCO_Container
			where
				CO_NAM_Container_Name = @targetName
			and
				CO_TYP_COT_ContainerType = @targetType
			and
				CO_CRE_Container_Created = @targetCreated
		end
		-- otherwise update the discovery (but only done for files)
		else if (@sourceType = 'File')
		begin
			update lCO_Container
			set
				CO_DSC_Container_Discovered = @now
			where
				CO_ID = @CO_ID_target;
		end

		select
			@OP_ID = OP_ID_with
		from
			lWO_operates_CO_source_CO_target_OP_with
		where
			WO_ID_operates = @WO_ID
		and
			CO_ID_source = @CO_ID_source
		and
			CO_ID_target = @CO_ID_target;

		if(@OP_ID is null)
		begin
			declare @keys table (
				OP_ID int not null
			);

			insert @keys
			exec metadata.kOP_Operations 1;

			set	@OP_ID = (select top 1 OP_ID from @keys);

			insert into lWO_operates_CO_source_CO_target_OP_with (
				WO_ID_operates,
				CO_ID_source,
				CO_ID_target,
				OP_ID_with
			)
			values (
				@WO_ID,
				@CO_ID_source,
				@CO_ID_target,
				@OP_ID
			);
		end
	end

	EXEC sp_releaseapplock 	@Resource  = 'metadata',  
     						@LockOwner = 'Session';
end
go


--------------------------- Inserted by Work ---------------------------
if Object_Id('metadata._WorkSetInserts', 'P') is not null
drop procedure metadata._WorkSetInserts;
go

create procedure metadata._WorkSetInserts (
	@WO_ID int,
	@OP_ID int,
	@numberOfRows int,
	@at datetime2(7) = null
)
as
begin
	-- prevent deadlocks when jobs run in parallel
	EXEC sp_getapplock 	@Resource    = 'metadata',  
     					@LockOwner   = 'Session',
     					@LockMode    = 'Exclusive',
						@LockTimeout = 60000;

	set @at = isnull(@at, metadata._Now());

	-- ensure this work is running!
	select
		@WO_ID = WO_ID
	from
		metadata.lWO_Work
	where
		WO_ID = @WO_ID
	and
		WO_EST_EST_ExecutionStatus = 'Running';

	if(@WO_ID is not null and @OP_ID is not null)
	begin
		declare @latestChangedAt datetime2(7);
		set @latestChangedAt = (
			select 
				MAX(OP_INS_ChangedAt)
			from 
				metadata.OP_INS_Operations_Inserts
			where
				OP_INS_OP_ID = @OP_ID
		);
		if (@at <= @latestChangedAt)
		begin 
			set @at = DATEADD(NANOSECOND, 100, @latestChangedAt);
		end

		update metadata.lOP_Operations
		set
			OP_INS_ChangedAt = @at,
			OP_INS_Operations_Inserts = @numberOfRows
		where
			OP_ID = @OP_ID;
	end

	EXEC sp_releaseapplock 	@Resource  = 'metadata',  
     						@LockOwner = 'Session';
end
go

--------------------------- Updated by Work ---------------------------
if Object_Id('metadata._WorkSetUpdates', 'P') is not null
drop procedure metadata._WorkSetUpdates;
go

create procedure metadata._WorkSetUpdates (
	@WO_ID int,
	@OP_ID int,
	@numberOfRows int,
	@at datetime2(7) = null
)
as
begin
	-- prevent deadlocks when jobs run in parallel
	EXEC sp_getapplock 	@Resource    = 'metadata',  
     					@LockOwner   = 'Session',
     					@LockMode    = 'Exclusive',
						@LockTimeout = 60000;

	set @at = isnull(@at, metadata._Now());

	-- ensure this work is running!
	select
		@WO_ID = WO_ID
	from
		metadata.lWO_Work
	where
		WO_ID = @WO_ID
	and
		WO_EST_EST_ExecutionStatus = 'Running';

	if(@WO_ID is not null and @OP_ID is not null)
	begin
		declare @latestChangedAt datetime2(7);
		set @latestChangedAt = (
			select 
				MAX(OP_UPD_ChangedAt)
			from 
				metadata.OP_UPD_Operations_Updates
			where
				OP_UPD_OP_ID = @OP_ID
		);
		if (@at <= @latestChangedAt)
		begin 
			set @at = DATEADD(NANOSECOND, 100, @latestChangedAt);
		end

		update metadata.lOP_Operations
		set
			OP_UPD_ChangedAt = @at,
			OP_UPD_Operations_Updates = @numberOfRows
		where
			OP_ID = @OP_ID;
	end

	EXEC sp_releaseapplock 	@Resource  = 'metadata',  
     						@LockOwner = 'Session';
end
go

--------------------------- Deleted by Work ---------------------------
if Object_Id('metadata._WorkSetDeletes', 'P') is not null
drop procedure metadata._WorkSetDeletes;
go

create procedure metadata._WorkSetDeletes (
	@WO_ID int,
	@OP_ID int,
	@numberOfRows int,
	@at datetime2(7) = null
)
as
begin
	-- prevent deadlocks when jobs run in parallel
	EXEC sp_getapplock 	@Resource    = 'metadata',  
     					@LockOwner   = 'Session',
     					@LockMode    = 'Exclusive',
						@LockTimeout = 60000;

	set @at = isnull(@at, metadata._Now());

	-- ensure this work is running!
	select
		@WO_ID = WO_ID
	from
		metadata.lWO_Work
	where
		WO_ID = @WO_ID
	and
		WO_EST_EST_ExecutionStatus = 'Running';

	if(@WO_ID is not null and @OP_ID is not null)
	begin
		declare @latestChangedAt datetime2(7);
		set @latestChangedAt = (
			select 
				MAX(OP_DEL_ChangedAt)
			from 
				metadata.OP_DEL_Operations_Deletes
			where
				OP_DEL_OP_ID = @OP_ID
		);
		if (@at <= @latestChangedAt)
		begin 
			set @at = DATEADD(NANOSECOND, 100, @latestChangedAt);
		end

		update metadata.lOP_Operations
		set
			OP_DEL_ChangedAt = @at,
			OP_DEL_Operations_Deletes = @numberOfRows
		where
			OP_ID = @OP_ID;
	end

	EXEC sp_releaseapplock 	@Resource  = 'metadata',  
     						@LockOwner = 'Session';
end
go

