/*~
------------------------------- $workflow.name -------------------------------
USE msdb;
GO
~*/

var job, step, id, lastId;
while(job = workflow.nextJob()) {
/*~
DECLARE @AgentJobID uniqueidentifier = (
    select job_id from [dbo].[sysjobs] where name = '$job.name'
);

IF (@AgentJobID is null)
BEGIN
    EXEC sp_add_job
        $(job.enabled)?                 @enabled                = $job.enabled,
        $(job._job)?                    @description            = '$job._job',
        $(job.start_step_id)?           @start_step_id          = $job.start_step_id,
        $(job.category_name)?           @category_name          = '$job.category_name',
        $(job.category_id)?             @category_id            = $job.category_id,
        $(job.notify_level_eventlog)?   @notify_level_eventlog  = $job.notify_level_eventlog,
        $(job.notify_level_email)?      @notify_level_email     = $job.notify_level_email,
        $(job.notify_level_netsend)?    @notify_level_netsend   = $job.notify_level_netsend,
        $(job.notify_level_page)?       @notify_level_page      = $job.notify_level_page,
        $(job.notify_email_operator_name)?      @notify_email_operator_name     = '$job.notify_email_operator_name',
        $(job.notify_netsend_operator_name)?    @notify_netsend_operator_name   = '$job.notify_netsend_operator_name',
        $(job.notify_page_operator_name)?       @notify_page_operator_name      = '$job.notify_page_operator_name',
        $(job.delete_level)?            @delete_level           = $job.delete_level,
        $(job.owner_login_name)?        @owner_login_name       = $job.owner_login_name,
        -- mandatory parameters below and optional ones above this line
        @job_name   = '$job.name',
        -- capture the newly created job id 
        @job_id = @AgentJobID OUTPUT;

    EXEC sp_add_jobserver
        -- mandatory parameters below and optional ones above this line
        @job_name   = '$job.name';
END
ELSE
BEGIN
    -- deleting the magical step 0 removes all job steps (this is documented behavior)
    EXEC sp_delete_jobstep @job_Id = @AgentJobID, @step_id = 0;
END

~*/
    if(METADATA) {
/*~
EXEC sp_add_jobstep
    @job_id             = @AgentJobID,
    @step_name          = 'Log starting of job',
    @step_id            = 1,
    @subsystem          = 'TSQL',
    @database_name      = '${METADATABASE}$',
    @command            = 'EXEC metadata._JobStarting @workflowName = ''$workflow.name'', @jobName = ''$job.name'', @agentJobId = $$(ESCAPE_NONE(JOBID))',
    @on_success_action  = 3; -- go to the next step
~*/
    }
    while(step = job.nextStep()) {
/*~
EXEC sp_add_jobstep
    $(step.step_id)?                @step_id                = $step.step_id,
    $(step.subsystem)?              @subsystem              = '$step.subsystem',
    $(step._jobstep)?               @command                = '${step._jobstep.replace(/'/g, '\'\'')}$',
    $(step.additional_parameters)?  @additional_parameters  = '$step.additional_parameters',
    $(step.cmdexec_success_code)?   @cmdexec_success_code   = $step.cmdexec_success_code,
    $(step.server)?                 @server                 = '$step.server',
    $(step.database_name)?          @database_name          = '$step.database_name',
    $(step.database_user_name)?     @database_user_name     = '$step.database_user_name',
    $(step.retry_attempts)?         @retry_attempts         = $step.retry_attempts,
    $(step.retry_interval)?         @retry_interval         = $step.retry_interval,
    $(step.os_run_priority)?        @os_run_priority        = $step.os_run_priority,
    $(step.output_file_name)?       @output_file_name       = '$step.output_file_name',
    $(step.flags)?                  @flags                  = $step.flags,
    $(step.proxy_id)?               @proxy_id               = $step.proxy_id,
    $(step.proxy_name)?             @proxy_name             = '$step.proxy_name',
    $(step.on_fail_action)?         @on_fail_action         = $step.on_fail_action,
    $(step.on_fail_step_id)?        @on_fail_step_id        = $step.on_fail_step_id,
    $(step.on_success_action)?      @on_success_action      = $step.on_success_action,
    $(step.on_success_step_id)?     @on_success_step_id     = $step.on_success_step_id,
    -- mandatory parameters below and optional ones above this line
    @job_id         = @AgentJobID,
    @step_name      = '$step.name';
~*/
    }
    if(METADATA) {
/*~
EXEC sp_add_jobstep
    @job_id             = @AgentJobID,
    @step_name          = 'Log success of job',
    @subsystem          = 'TSQL',
    @database_name      = '${METADATABASE}$',
    @command            = 'EXEC metadata._JobStopping @name = ''$job.name'', @status = ''Success''',
    @on_success_action  = 1; -- quit with success

EXEC sp_add_jobstep
    @job_id             = @AgentJobID,
    @step_name          = 'Log failure of job',
    @subsystem          = 'TSQL',
    @database_name      = '${METADATABASE}$',
    @command            = 'EXEC metadata._JobStopping @name = ''$job.name'', @status = ''Failure''',
    @on_success_action  = 2; -- quit with failure

declare @log_success_step_id int = (
    select step_id 
    from msdb.dbo.sysjobs j
    join msdb.dbo.sysjobsteps s
    on s.job_id = j.job_id
    and s.step_name = 'Log success of job'
    where j.job_id = @AgentJobID
);

declare @log_failure_step_id int = (
    select step_id 
    from msdb.dbo.sysjobs j
    join msdb.dbo.sysjobsteps s
    on s.job_id = j.job_id
    and s.step_name = 'Log failure of job'
    where j.job_id = @AgentJobID
);

declare @step_id int = 0;
declare @on_success_action int;
declare @on_fail_action int;

while @step_id is not null
begin 
    set @step_id = null;
    select top 1 
        @step_id = s.step_id, 
        @on_success_action = s.on_success_action,
        @on_fail_action = s.on_fail_action
    from msdb.dbo.sysjobs j
    join msdb.dbo.sysjobsteps s
    on s.job_id = j.job_id
    and (
        -- quit job with success (1) or fail (2)
        s.on_success_action in (1, 2) 
     or s.on_fail_action in (1, 2)
    )
    and s.step_name not in (
        'Log starting of job',
        'Log success of job',
        'Log failure of job'
    )
    where j.job_id = @AgentJobID;

    if @step_id is not null
    begin
        if @on_success_action = 1       
        exec msdb.dbo.sp_update_jobstep
            @job_id             = @AgentJobID,
            @step_id            = @step_id,
            @on_success_action  = 4, -- go to step with id
            @on_success_step_id = @log_success_step_id

        if @on_success_action = 2       
        exec msdb.dbo.sp_update_jobstep
            @job_id             = @AgentJobID,
            @step_id            = @step_id,
            @on_success_action  = 4, -- go to step with id
            @on_success_step_id = @log_failure_step_id

        if @on_fail_action = 1      
        exec msdb.dbo.sp_update_jobstep
            @job_id             = @AgentJobID,
            @step_id            = @step_id,
            @on_fail_action     = 4, -- go to step with id
            @on_fail_step_id    = @log_success_step_id

        if @on_fail_action = 2      
        exec msdb.dbo.sp_update_jobstep
            @job_id             = @AgentJobID,
            @step_id            = @step_id,
            @on_fail_action     = 4, -- go to step with id
            @on_fail_step_id    = @log_failure_step_id
    end
end
~*/
    }
/*~
GO
-- end of job creation
~*/
}
