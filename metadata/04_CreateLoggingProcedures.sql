/*
             CREATE PROCEDURES FOR LOGGING 
*/
--------------------------- Starting Job ----------------------------
if Object_Id('metadata._JobStarting', 'P') is not null
drop procedure metadata._JobStarting;
go

create procedure metadata._JobStarting (
	@name varchar(255),
	@agentJobId uniqueidentifier,
	@start datetime2(7) = null
)
as
begin
	set @start = isnull(@start, SYSDATETIME());
	declare @JB_ID int;

	-- is this job already started?
	select
		@JB_ID = JB_ID
	from
		metadata.lJB_Job
	where
		JB_NAM_Job_Name = @name
	and
		JB_EST_EST_ExecutionStatus = 'Running';

	if(@JB_ID is null)
	begin
		insert into metadata.lJB_Job (
			JB_NAM_Job_Name, 
			JB_STA_Job_Start,
			JB_AID_Job_AgentJobId, 
			JB_EST_ChangedAt, 
			JB_EST_EST_ExecutionStatus
		)
		values ( 
			@name,
			@start,
			@agentJobId,
			@start, -- same as job start
			'Running'
		);
	end	
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
	set @stop = isnull(@stop, SYSDATETIME());
	set @status = isnull(@status, 'Success');
	declare @JB_ID int;

	-- ensure this job is running!
	select
		@JB_ID = JB_ID
	from
		metadata.lJB_Job
	where
		JB_NAM_Job_Name = @name
	and
		JB_EST_EST_ExecutionStatus = 'Running';

	if(@JB_ID is not null)
	begin
		if(@status = 'Success')
		begin
			update metadata.lJB_Job
			set
				JB_END_Job_End = @stop,
				JB_EST_ChangedAt = @stop, -- same as job stop
				JB_EST_EST_ExecutionStatus = 'Success'
			where
				JB_ID = @JB_ID;
		end
		if(@status = 'Failure')
		begin
			update metadata.lJB_Job 
			set
				JB_END_Job_End = @stop,
				JB_EST_ChangedAt = @stop, -- same as job stop
				JB_EST_EST_ExecutionStatus = 'Failure'
			where
				JB_ID = @JB_ID;
		end
	end
end
go

--------------------------- Starting Work ---------------------------
if Object_Id('metadata._WorkStarting', 'P') is not null
drop procedure metadata._WorkStarting;
go
 
create procedure metadata._WorkStarting (
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
	set @start = isnull(@start, SYSDATETIME());
	set @user = isnull(@user, SYSTEM_USER);
	set @role = isnull(@role, USER);

	-- is this work already started?
	select
		@WO_ID = WO_ID
	from
		metadata.lWO_Work
	where
		WO_NAM_Work_Name = @name
	and
		WO_EST_EST_ExecutionStatus = 'Running';

	if(@WO_ID is null)
	begin
		insert into metadata.lWO_Work (
			WO_NAM_Work_Name, 
			WO_STA_Work_Start, 
			WO_USR_Work_InvocationUser, 
			WO_ROL_Work_InvocationRole, 
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

		select
			@WO_ID = WO_ID
		from
			metadata.lWO_Work
		where
			WO_NAM_Work_Name = @name
		and
			WO_STA_Work_Start = @start;

		-- try to find job id
		declare @JB_ID int;
		select
			@JB_ID = JB_ID
		from
			metadata.lJB_Job
		where
			JB_AID_Job_AgentJobId = @agentJobId
		and
			JB_EST_EST_ExecutionStatus = 'Running';

		if(@JB_ID is not null)
		begin
			insert into metadata.lWO_part_JB_of (
				WO_ID_part, 
				JB_ID_of
			)
			values (
				@WO_ID,
				@JB_ID
			);
		end
	end
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
	set @stop = isnull(@stop, SYSDATETIME());
	set @status = isnull(@status, 'Success');

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
end
go
