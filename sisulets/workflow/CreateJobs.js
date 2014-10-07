/*~
------------------------------- $workflow.name -------------------------------
USE msdb;
GO
~*/

var job, step, id, lastId;
while(job = workflow.nextJob()) {
/*~
sp_delete_job
    -- mandatory parameters below and optional ones above this line
    @job_name   = '$job.name';
GO
sp_add_job 
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
    -- mandatory parameters below and optional ones above this line
    @owner_login_name = 'NT SERVICE\\SQLSERVERAGENT', -- remove hard coding later
    @job_name   = '$job.name';
GO
sp_add_jobserver 
    -- mandatory parameters below and optional ones above this line
    @job_name   = '$job.name';
GO
~*/
    if(METADATA) {
/*~
sp_add_jobstep 
    @job_name           = '$job.name', 
    @step_name          = 'Log starting of job',
    @step_id            = 1,
    @subsystem          = 'TSQL',
    @database_name      = '${METADATABASE}$',
    @command            = 'EXEC metadata._JobStarting @workflowName = ''$workflow.name'', @jobName = ''$job.name'', @agentJobId = $$(ESCAPE_NONE(JOBID))',
    @on_success_action  = 3; -- go to the next step
GO    
~*/
    }
    while(step = job.nextStep()) {
/*~
sp_add_jobstep 
    $(step.job_id)?                 @job_id                 = $step.job_id,
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
    @job_name       = '$job.name', 
    @step_name      = '$step.name'; 
GO
~*/        
    }
    if(METADATA) {
/*~
sp_add_jobstep 
    @job_name           = '$job.name', 
    @step_name          = 'Log success of job',
    @subsystem          = 'TSQL',
    @database_name      = '${METADATABASE}$',
    @command            = 'EXEC metadata._JobStopping @name = ''$job.name'', @status = ''Success''',
    @on_success_action  = 1; -- quit with success
GO

sp_add_jobstep 
    @job_name           = '$job.name', 
    @step_name          = 'Log failure of job',
    @subsystem          = 'TSQL',
    @database_name      = '${METADATABASE}$',
    @command            = 'EXEC metadata._JobStopping @name = ''$job.name'', @status = ''Failure''',
    @on_success_action  = 2; -- quit with failure
GO
~*/
        id = 2;
        lastId = job.jobsteps.length;
        while(step = job.nextStep()) {
/*~
sp_update_jobstep
    @job_name           = '$job.name',
    @step_id            = ${(id++)}$,
    -- ensure logging when any step fails
    @on_fail_action     = 4, -- go to step with id
    @on_fail_step_id    = ${(lastId + 3)}$,
    @on_success_action  = 3; -- go to the next step
GO
~*/
        }
    }
}
