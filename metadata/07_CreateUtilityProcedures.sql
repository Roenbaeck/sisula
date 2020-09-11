/*
	Script that deletes metadata older than a given date.

	Note that anchor identities will remain in order to 
	indicate that they have once been assigned and to 
	avoid any possible future reuse. Any rows in attributes 
	or ties referencing these will be deleted, so pruning
	old values will result in both storage and performance
	benefits.

	EXEC metadata._DeleteMetadata @olderThan = '2019-01-01', @dryRun = 1;
	EXEC metadata._DeleteMetadata @olderThan = '2019-01-01';
*/
if OBJECT_ID('metadata._DeleteMetadata', 'P') is not null
drop procedure metadata._DeleteMetadata;
go

create procedure metadata._DeleteMetadata (
	@olderThan datetime, 
	@dryRun bit = 0
)
as
begin
	-- this is to prevent the log from filling up
	declare @deleteBatchSize int = 300000;

	if OBJECT_ID('tempdb..#old_jobs') is not null
	drop table #old_jobs;

	select
		JB_ID
	into
		#old_jobs
	from 
		lJB_Job jb
	where
		jb.JB_STA_Job_Start < @olderThan;

	alter table #old_jobs add primary key (JB_ID);

	if OBJECT_ID('tempdb..#old_works') is not null
	drop table #old_works;

	select
		wojb.WO_ID_part as WO_ID
	into
		#old_works
	from
		#old_jobs jb
	join 
		metadata.lWO_part_JB_of wojb
	on 
		wojb.JB_ID_of = jb.JB_ID;

	alter table #old_works add primary key (WO_ID);

	if OBJECT_ID('tempdb..#old_operations') is not null
	drop table #old_operations;

	select
		wococoop.OP_ID_with as OP_ID
	into
		#old_operations
	from
		#old_works wo
	join 
		metadata.lWO_operates_CO_source_CO_target_OP_with wococoop
	on 
		wococoop.WO_ID_operates = wo.WO_ID;

	alter table #old_operations add primary key (OP_ID);

	if (@dryRun = 0)
	begin -- begin of not dry run
		declare @remaining bigint;
		declare @deleted bigint = 0;

		-------------------------- OP_Operations --------------------------
		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.WO_operates_CO_source_CO_target_OP_with (OP)';
			delete top (@deleteBatchSize) x
			from metadata.WO_operates_CO_source_CO_target_OP_with x
			join #old_operations old on old.OP_ID = x.OP_ID_with;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.OP_INS_Operations_Inserts (OP)';
			delete top (@deleteBatchSize) x
			from metadata.OP_INS_Operations_Inserts x
			join #old_operations old on old.OP_ID = x.OP_INS_OP_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.OP_UPD_Operations_Updates (OP)';
			delete top (@deleteBatchSize) x
			from metadata.OP_UPD_Operations_Updates x
			join #old_operations old on old.OP_ID = x.OP_UPD_OP_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.OP_DEL_Operations_Deletes (OP)';
			delete top (@deleteBatchSize) x
			from metadata.OP_DEL_Operations_Deletes x
			join #old_operations old on old.OP_ID = x.OP_DEL_OP_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		-------------------------- WO_Work --------------------------
		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.WO_operates_CO_source_CO_target_OP_with (WO)';
			delete top (@deleteBatchSize) x
			from metadata.WO_operates_CO_source_CO_target_OP_with x
			join #old_works old on old.WO_ID = x.WO_ID_operates;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.WO_formed_CF_from (WO)';
			delete top (@deleteBatchSize) x
			from metadata.WO_formed_CF_from x
			join #old_works old on old.WO_ID = x.WO_ID_formed;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.WO_part_JB_of (WO)';
			delete top (@deleteBatchSize) x
			from metadata.WO_part_JB_of x
			join #old_works old on old.WO_ID = x.WO_ID_part;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.WO_USR_Work_InvocationUser (WO)';
			delete top (@deleteBatchSize) x
			from metadata.WO_USR_Work_InvocationUser x
			join #old_works old on old.WO_ID = x.WO_USR_WO_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.WO_ROL_Work_InvocationRole (WO)';
			delete top (@deleteBatchSize) x
			from metadata.WO_ROL_Work_InvocationRole x
			join #old_works old on old.WO_ID = x.WO_ROL_WO_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.WO_STA_Work_Start (WO)';
			delete top (@deleteBatchSize) x
			from metadata.WO_STA_Work_Start x
			join #old_works old on old.WO_ID = x.WO_STA_WO_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end
	
		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.WO_END_Work_End (WO)';
			delete top (@deleteBatchSize) x
			from metadata.WO_END_Work_End x
			join #old_works old on old.WO_ID = x.WO_END_WO_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.WO_NAM_Work_Name (WO)';
			delete top (@deleteBatchSize) x
			from metadata.WO_NAM_Work_Name x
			join #old_works old on old.WO_ID = x.WO_NAM_WO_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.WO_ERL_Work_ErrorLine (WO)';
			delete top (@deleteBatchSize) x
			from metadata.WO_ERL_Work_ErrorLine x
			join #old_works old on old.WO_ID = x.WO_ERL_WO_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.WO_ERM_Work_ErrorMessage (WO)';
			delete top (@deleteBatchSize) x
			from metadata.WO_ERM_Work_ErrorMessage x
			join #old_works old on old.WO_ID = x.WO_ERM_WO_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.WO_AID_Work_AgentStepId (WO)';
			delete top (@deleteBatchSize) x
			from metadata.WO_AID_Work_AgentStepId x
			join #old_works old on old.WO_ID = x.WO_AID_WO_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.WO_EST_Work_ExecutionStatus (WO)';
			delete top (@deleteBatchSize) x
			from metadata.WO_EST_Work_ExecutionStatus x
			join #old_works old on old.WO_ID = x.WO_EST_WO_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		-------------------------- JB_Job --------------------------
		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.WO_part_JB_of (JB)';
			delete top (@deleteBatchSize) x
			from metadata.WO_part_JB_of x
			join #old_jobs old on old.JB_ID = x.JB_ID_of;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.JB_formed_CF_from (JB)';
			delete top (@deleteBatchSize) x
			from metadata.JB_formed_CF_from x
			join #old_jobs old on old.JB_ID = x.JB_ID_formed;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.JB_STA_Job_Start (JB)';
			delete top (@deleteBatchSize) x
			from metadata.JB_STA_Job_Start x
			join #old_jobs old on old.JB_ID = x.JB_STA_JB_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.JB_END_Job_End (JB)';
			delete top (@deleteBatchSize) x
			from metadata.JB_END_Job_End x
			join #old_jobs old on old.JB_ID = x.JB_END_JB_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.JB_NAM_Job_Name (JB)';
			delete top (@deleteBatchSize) x
			from metadata.JB_NAM_Job_Name x
			join #old_jobs old on old.JB_ID = x.JB_NAM_JB_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.JB_AID_Job_AgentJobId (JB)';
			delete top (@deleteBatchSize) x
			from metadata.JB_AID_Job_AgentJobId x
			join #old_jobs old on old.JB_ID = x.JB_AID_JB_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		set @remaining = 1;
		while (@remaining > 0)
		begin
			print 'DELETE: metadata.JB_EST_Job_ExecutionStatus (JB)';
			delete top (@deleteBatchSize) x
			from metadata.JB_EST_Job_ExecutionStatus x
			join #old_jobs old on old.JB_ID = x.JB_EST_JB_ID;
			set @remaining = @@ROWCOUNT;
			set @deleted = @deleted + @remaining;
		end

		----------------------------------------------------------------------
		print 'Total number of deletes: '  + cast(@deleted as varchar(42));
	end -- end of not dry run
	else
	begin -- begin of dry run
		select count(*) as NumberOfDeletedJobs, @olderThan as WhichAreOlderThan from #old_jobs;
		select count(*) as NumberOfDeletedWorks, @olderThan as WhichAreOlderThan from #old_works;
		select count(*) as NumberOfDeletedOperations, @olderThan as WhichAreOlderThan from #old_operations;
	end -- end of dry run

	drop table #old_jobs;
	drop table #old_works;
	drop table #old_operations;

end
go
