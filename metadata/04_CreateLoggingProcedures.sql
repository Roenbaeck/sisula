/*
             CREATE PROCEDURES FOR LOGGING 
*/
--------------------------- Starting Work ---------------------------
if Object_Id('metadata._StartingWork', 'P') is not null
drop procedure metadata._StartingWork;
go
 
create procedure metadata._StartingWork (
	@WO_ID int output,
	@name varchar(255),
	@start datetime = null,
	@user varchar(555) = null,
	@role varchar(42) = null
)
as
begin
	set @start = isnull(@start, getdate());
	set @user = isnull(@user, SYSTEM_USER);
	set @role = isnull(@role, USER);

	-- is this work already started?
	select
		@WO_ID = WO_ID
	from
		lWO_Work
	where
		WO_NAM_Work_Name = @name
	and
		WO_EST_EST_ExecutionStatus = 'Running';

	if(@WO_ID is null)
	begin
		insert into lWO_Work (
			WO_NAM_Work_Name, 
			WO_STA_Work_Start, 
			WO_USR_Work_InvocationUser, 
			WO_ROL_Work_InvocationRole, 
			WO_EST_ChangedAt, 
			WO_EST_EST_ExecutionStatus
		)
		values ( 
			@name,
			@start,
			@user,
			@role,
			@start, -- same as job start
			'Running'
		);

		select
			@WO_ID = WO_ID
		from
			lWO_Work
		where
			WO_NAM_Work_Name = @name
		and
			WO_STA_Work_Start = @start;
	end
end
go

--------------------------- Stopping Work ---------------------------
if Object_Id('metadata._StoppingWork', 'P') is not null
drop procedure metadata._StoppingWork;
go
 
create procedure metadata._StoppingWork (
	@WO_ID int,
	@status varchar(42) = 'Success',
	@errorLine int = null,
	@errorMessage varchar(555) = null,
	@stop datetime = null
)
as
begin
	set @stop = isnull(@stop, getdate());
	set @status = isnull(@status, 'Success');

	select 'Before', @WO_ID;

	-- ensure this work is running!
	select
		@WO_ID = WO_ID
	from
		lWO_Work
	where
		WO_ID = @WO_ID
	and
		WO_EST_EST_ExecutionStatus = 'Running';

	select 'After', @WO_ID;

	if(@WO_ID is not null)
	begin
		if(@status = 'Success')
		begin
			update lWO_Work 
			set
				WO_END_Work_End = @stop,
				WO_EST_ChangedAt = @stop, -- same as job stop
				WO_EST_EST_ExecutionStatus = 'Success'
			where
				WO_ID = @WO_ID;
		end
		if(@status = 'Failure')
		begin
			update lWO_Work 
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
