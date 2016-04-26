/*~
------------------------------- $workflow.name -------------------------------
USE msdb;
GO

DECLARE @scheduleId int;
DECLARE @scheduleName varchar(128);
~*/

var job, step, id, lastId;
while(job = workflow.nextJob()) {
/*~
SELECT
    s.schedule_id,
    s.name
INTO
    [#schedules $job.name]
FROM
    dbo.sysschedules s
JOIN
    dbo.sysjobschedules js
ON
    js.schedule_id = s.schedule_id
JOIN
    dbo.sysjobs j
ON
    j.job_id = js.job_id
WHERE
    j.name = '$job.name';

DECLARE schedules SCROLL CURSOR FOR SELECT schedule_id, name FROM [#schedules $job.name];
OPEN schedules;

IF EXISTS (select job_id from [dbo].[sysjobs] where name = '$job.name')
BEGIN
    FETCH FIRST FROM schedules INTO @scheduleId, @scheduleName;
    WHILE(@@FETCH_STATUS = 0) 
    BEGIN
        --PRINT 'Detaching schedule "' + @scheduleName + '" from $job.name';
        EXEC msdb.dbo.sp_detach_schedule @job_name = '$job.name', @schedule_id = @scheduleId;
        FETCH NEXT FROM schedules INTO @scheduleId, @scheduleName;
    END

    EXEC sp_delete_job
        -- mandatory parameters below and optional ones above this line
        @job_name   = '$job.name';
END

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
    @job_name   = '$job.name';

EXEC sp_add_jobserver
    -- mandatory parameters below and optional ones above this line
    @job_name   = '$job.name';

~*/
    if(METADATA) {
/*~
EXEC sp_add_jobstep
    @job_name           = '$job.name',
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
~*/
    }
    if(METADATA) {
/*~
EXEC sp_add_jobstep
    @job_name           = '$job.name',
    @step_name          = 'Log success of job',
    @subsystem          = 'TSQL',
    @database_name      = '${METADATABASE}$',
    @command            = 'EXEC metadata._JobStopping @name = ''$job.name'', @status = ''Success''',
    @on_success_action  = 1; -- quit with success

EXEC sp_add_jobstep
    @job_name           = '$job.name',
    @step_name          = 'Log failure of job',
    @subsystem          = 'TSQL',
    @database_name      = '${METADATABASE}$',
    @command            = 'EXEC metadata._JobStopping @name = ''$job.name'', @status = ''Failure''',
    @on_success_action  = 2; -- quit with failure
~*/
        id = 2;
        lastId = job.jobsteps.length;
        while(step = job.nextStep()) {
/*~
EXEC sp_update_jobstep
    @job_name           = '$job.name',
    @step_id            = ${(id++)}$,
    -- ensure logging when any step fails
    @on_fail_action     = 4, -- go to step with id
    @on_fail_step_id    = ${(lastId + 3)}$;
~*/
        }
/*~
EXEC sp_update_jobstep
    @job_name           = '$job.name',
    @step_id            = ${(lastId + 1)}$,
    -- ensure logging when last step succeeds
    @on_success_action  = 4, -- go to step with id
    @on_success_step_id = ${(lastId + 2)}$;
~*/
    }
/*~
FETCH FIRST FROM schedules INTO @scheduleId, @scheduleName;
WHILE(@@FETCH_STATUS = 0) 
BEGIN
    --PRINT 'Attaching schedule "' + @scheduleName + '" to $job.name';
    EXEC msdb.dbo.sp_attach_schedule @job_name = '$job.name', @schedule_id = @scheduleId;
    FETCH NEXT FROM schedules INTO @scheduleId, @scheduleName;
END
CLOSE schedules;
DEALLOCATE schedules;
DROP TABLE [#schedules $job.name];
~*/    
}
