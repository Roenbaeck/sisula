/*~
------------------------------- $workflow.name -------------------------------
USE msdb;
GO
~*/
var job, step;
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
    $(job.owner_login_name)?        @owner_login_name       = '$job.owner_login_name',
    $(job.notify_level_eventlog)?   @notify_level_eventlog  = $job.notify_level_eventlog,
    $(job.notify_level_email)?      @notify_level_email     = $job.notify_level_email,
    $(job.notify_level_netsend)?    @notify_level_netsend   = $job.notify_level_netsend,
    $(job.notify_level_page)?       @notify_level_page      = $job.notify_level_page,
    $(job.notify_email_operator_name)?      @notify_email_operator_name     = '$job.notify_email_operator_name',
    $(job.notify_netsend_operator_name)?    @notify_netsend_operator_name   = '$job.notify_netsend_operator_name',
    $(job.notify_page_operator_name)?       @notify_page_operator_name      = '$job.notify_page_operator_name',
    $(job.delete_level)?            @delete_level           = $job.delete_level,
    -- mandatory parameters below and optional ones above this line
    @job_name   = '$job.name';
GO
~*/
    while(step = job.nextStep()) {
/*~
sp_add_jobstep 
    $(step.job_id)?                 @job_id                 = $step.job_id,
    $(step.id)?                     @step_id                = $step.id, 
    $(step.subsystem)?              @subsystem              = '$step.subsystem', 
    $(step._jobstep)?               @command                = '$step._jobstep',
    $(step.additional_parameters)?  @additional_parameters  = '$step.additional_parameters',
    $(step.cmdexec_success_code)?   @cmdexec_success_code   = $step.cmdexec_success_code,
    $(step.on_success_action)?      @on_success_action      = $step.on_success_action,
    $(step.on_success_step_id)?     @on_success_step_id     = $step.on_success_step_id,
    $(step.on_fail_action)?         @on_fail_action         = $step.on_fail_action,
    $(step.on_fail_step_id)?        @on_fail_step_id        = $step.on_fail_step_id,
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
    -- mandatory parameters below and optional ones above this line
    @job_name       = '$job.name', 
    @step_name      = '$step.name'; 
GO
~*/        
    }
}
