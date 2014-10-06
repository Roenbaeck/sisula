------------------------------- SMHI_Weather_Workflow -------------------------------
USE msdb;
GO
sp_delete_job
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging';
GO
sp_add_job 
    @description = '
        This is the staging job.
        ',
    -- mandatory parameters below and optional ones above this line
    @owner_login_name = 'NT SERVICE\SQLSERVERAGENT', -- remove hard coding later
    @job_name = 'SMHI_Weather_Staging';
GO
sp_add_jobserver 
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging';
GO
sp_add_jobstep 
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Log starting of job',
    @step_id = 1,
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStarting @name = ''SMHI_Weather_Staging'', @agentJobId = $(ESCAPE_NONE(JOBID))',
    @on_success_action = 3; -- go to the next step
GO 
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
            EXEC SMHI_Weather_CreateRawTable @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Create raw table'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
            EXEC SMHI_Weather_CreateInsertView @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Create insert view'; 
GO
sp_add_jobstep 
    @subsystem = 'PowerShell', 
    @command = '
            $files = @(Get-ChildItem -Recurse FileSystem::G:\sisula\data | Where-Object {$_.Name -match "Weather.*\.txt"})
            If ($files.length -eq 0) {
              Throw "No matching files were found in G:\sisula\data:"
            } Else {
                ForEach ($file in $files) {
                    $fullFilename = $file.FullName
                    $modifiedDate = $file.LastWriteTime
                    Invoke-Sqlcmd "EXEC SMHI_Weather_BulkInsert ''$fullFilename'', ''$modifiedDate'', @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))" -Database "Stage" -ErrorAction Stop
                    Write-Output "Loaded file: $fullFilename"
                }
            }
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Bulk insert'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
            EXEC SMHI_Weather_CreateSplitViews @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Create split views'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
            EXEC SMHI_Weather_CreateErrorViews @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Create error views'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
            EXEC SMHI_Weather_CreateTypedTables @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Create typed tables'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
            EXEC SMHI_Weather_SplitRawIntoTyped @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Split raw into typed'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
            EXEC SMHI_Weather_AddKeysToTyped @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Add keys to typed'; 
GO
sp_add_jobstep 
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Log success of job',
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStopping @name = ''SMHI_Weather_Staging'', @status = ''Success''',
    @on_success_action = 1; -- quit with success
GO
sp_add_jobstep 
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Log failure of job',
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStopping @name = ''SMHI_Weather_Staging'', @status = ''Failure''',
    @on_success_action = 2; -- quit with failure
GO
sp_update_jobstep
    @job_name = 'SMHI_Weather_Staging',
    @step_id = 2,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11,
    @on_success_action = 3; -- go to the next step
GO
sp_update_jobstep
    @job_name = 'SMHI_Weather_Staging',
    @step_id = 3,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11,
    @on_success_action = 3; -- go to the next step
GO
sp_update_jobstep
    @job_name = 'SMHI_Weather_Staging',
    @step_id = 4,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11,
    @on_success_action = 3; -- go to the next step
GO
sp_update_jobstep
    @job_name = 'SMHI_Weather_Staging',
    @step_id = 5,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11,
    @on_success_action = 3; -- go to the next step
GO
sp_update_jobstep
    @job_name = 'SMHI_Weather_Staging',
    @step_id = 6,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11,
    @on_success_action = 3; -- go to the next step
GO
sp_update_jobstep
    @job_name = 'SMHI_Weather_Staging',
    @step_id = 7,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11,
    @on_success_action = 3; -- go to the next step
GO
sp_update_jobstep
    @job_name = 'SMHI_Weather_Staging',
    @step_id = 8,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11,
    @on_success_action = 3; -- go to the next step
GO
sp_update_jobstep
    @job_name = 'SMHI_Weather_Staging',
    @step_id = 9,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11,
    @on_success_action = 3; -- go to the next step
GO
sp_delete_job
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Loading';
GO
sp_add_job 
    -- mandatory parameters below and optional ones above this line
    @owner_login_name = 'NT SERVICE\SQLSERVERAGENT', -- remove hard coding later
    @job_name = 'SMHI_Weather_Loading';
GO
sp_add_jobserver 
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Loading';
GO
sp_add_jobstep 
    @job_name = 'SMHI_Weather_Loading', 
    @step_name = 'Log starting of job',
    @step_id = 1,
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStarting @name = ''SMHI_Weather_Loading'', @agentJobId = $(ESCAPE_NONE(JOBID))',
    @on_success_action = 3; -- go to the next step
GO 
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
            EXEC [dbo].[lMM_Measurement__SMHI_Weather_Temperature_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Loading', 
    @step_name = 'Load temperature'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
            EXEC [dbo].[lMM_Measurement__SMHI_Weather_TemperatureNew_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Loading', 
    @step_name = 'Load temperature (new format)'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
            EXEC [dbo].[lMM_Measurement__SMHI_Weather_Pressure_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Loading', 
    @step_name = 'Load pressure'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
            EXEC [dbo].[lMM_Measurement__SMHI_Weather_Wind_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Loading', 
    @step_name = 'Load wind'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
            EXEC [dbo].[lOC_Occasion__SMHI_Weather_TemperatureNewMetadata_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Loading', 
    @step_name = 'Load occasion'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
            EXEC [dbo].[lMM_taken_OC_on__SMHI_Weather_TemperatureNew_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Loading', 
    @step_name = 'Load measurement relationship with occasion'; 
GO
sp_add_jobstep 
    @job_name = 'SMHI_Weather_Loading', 
    @step_name = 'Log success of job',
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStopping @name = ''SMHI_Weather_Loading'', @status = ''Success''',
    @on_success_action = 1; -- quit with success
GO
sp_add_jobstep 
    @job_name = 'SMHI_Weather_Loading', 
    @step_name = 'Log failure of job',
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStopping @name = ''SMHI_Weather_Loading'', @status = ''Failure''',
    @on_success_action = 2; -- quit with failure
GO
sp_update_jobstep
    @job_name = 'SMHI_Weather_Loading',
    @step_id = 2,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 9,
    @on_success_action = 3; -- go to the next step
GO
sp_update_jobstep
    @job_name = 'SMHI_Weather_Loading',
    @step_id = 3,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 9,
    @on_success_action = 3; -- go to the next step
GO
sp_update_jobstep
    @job_name = 'SMHI_Weather_Loading',
    @step_id = 4,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 9,
    @on_success_action = 3; -- go to the next step
GO
sp_update_jobstep
    @job_name = 'SMHI_Weather_Loading',
    @step_id = 5,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 9,
    @on_success_action = 3; -- go to the next step
GO
sp_update_jobstep
    @job_name = 'SMHI_Weather_Loading',
    @step_id = 6,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 9,
    @on_success_action = 3; -- go to the next step
GO
sp_update_jobstep
    @job_name = 'SMHI_Weather_Loading',
    @step_id = 7,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 9,
    @on_success_action = 3; -- go to the next step
GO
