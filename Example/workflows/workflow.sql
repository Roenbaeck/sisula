------------------------------- NYPD_Vehicle_Workflow -------------------------------
USE msdb;
GO
IF EXISTS (select job_id from [dbo].[sysjobs] where name = 'NYPD_Vehicle_Staging')
EXEC sp_delete_job
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging';
GO
sp_add_job
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging';
GO
sp_add_jobserver
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging';
GO
sp_add_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Log starting of job',
    @step_id = 1,
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStarting @workflowName = ''NYPD_Vehicle_Workflow'', @jobName = ''NYPD_Vehicle_Staging'', @agentJobId = $(ESCAPE_NONE(JOBID))',
    @on_success_action = 3; -- go to the next step
GO
sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC NYPD_Vehicle_CreateRawTable @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Create raw table';
GO
sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC NYPD_Vehicle_CreateInsertView @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Create insert view';
GO
sp_add_jobstep
    @subsystem = 'PowerShell',
    @command = '
            $files = @(Get-ChildItem -Recurse FileSystem::"C:\sisula\Example\data" | Where-Object {$_.Name -match "[0-9]{5}_Collisions_.*\.csv"})
            If ($files.length -eq 0) {
              Throw "No matching files were found in C:\sisula\Example\data"
            } Else {
                ForEach ($file in $files) {
                    $fullFilename = $file.FullName
                    $modifiedDate = $file.LastWriteTime
                    Invoke-Sqlcmd "EXEC NYPD_Vehicle_BulkInsert ''$fullFilename'', ''$modifiedDate'', @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))" -Database "Stage" -ErrorAction Stop -QueryTimeout 0
                    Write-Output "Loaded file: $fullFilename"
                }
            }
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Bulk insert';
GO
sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC NYPD_Vehicle_CreateSplitViews @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Create split views';
GO
sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC NYPD_Vehicle_CreateErrorViews @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Create error views';
GO
sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC NYPD_Vehicle_CreateTypedTables @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Create typed tables';
GO
sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC NYPD_Vehicle_SplitRawIntoTyped @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Split raw into typed';
GO
sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC NYPD_Vehicle_AddKeysToTyped @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Add keys to typed';
GO
sp_add_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Log success of job',
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStopping @name = ''NYPD_Vehicle_Staging'', @status = ''Success''',
    @on_success_action = 1; -- quit with success
GO
sp_add_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Log failure of job',
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStopping @name = ''NYPD_Vehicle_Staging'', @status = ''Failure''',
    @on_success_action = 2; -- quit with failure
GO
sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 2,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11;
GO
sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 3,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11;
GO
sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 4,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11;
GO
sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 5,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11;
GO
sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 6,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11;
GO
sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 7,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11;
GO
sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 8,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11;
GO
sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 9,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 11;
GO
IF EXISTS (select job_id from [dbo].[sysjobs] where name = 'NYPD_Vehicle_Loading')
EXEC sp_delete_job
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Loading';
GO
sp_add_job
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Loading';
GO
sp_add_jobserver
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Loading';
GO
sp_add_jobstep
    @job_name = 'NYPD_Vehicle_Loading',
    @step_name = 'Log starting of job',
    @step_id = 1,
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStarting @workflowName = ''NYPD_Vehicle_Workflow'', @jobName = ''NYPD_Vehicle_Loading'', @agentJobId = $(ESCAPE_NONE(JOBID))',
    @on_success_action = 3; -- go to the next step
GO
sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC [dbo].[lST_Street__NYPD_Vehicle_Collision_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Loading',
    @step_name = 'Load streets';
GO
sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC [dbo].[lIS_Intersection__NYPD_Vehicle_Collision_Typed__1] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Loading',
    @step_name = 'Load intersection pass 1';
GO
sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC [dbo].[lST_intersecting_IS_of_ST_crossing__NYPD_Vehicle_Collision_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Loading',
    @step_name = 'Load ST ST IS tie';
GO
sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC [dbo].[lIS_Intersection__NYPD_Vehicle_Collision_Typed__2] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Loading',
    @step_name = 'Load intersection pass 2';
GO
sp_add_jobstep
    @job_name = 'NYPD_Vehicle_Loading',
    @step_name = 'Log success of job',
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStopping @name = ''NYPD_Vehicle_Loading'', @status = ''Success''',
    @on_success_action = 1; -- quit with success
GO
sp_add_jobstep
    @job_name = 'NYPD_Vehicle_Loading',
    @step_name = 'Log failure of job',
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStopping @name = ''NYPD_Vehicle_Loading'', @status = ''Failure''',
    @on_success_action = 2; -- quit with failure
GO
sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Loading',
    @step_id = 2,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 7;
GO
sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Loading',
    @step_id = 3,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 7;
GO
sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Loading',
    @step_id = 4,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 7;
GO
sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Loading',
    @step_id = 5,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 7;
GO
-- The workflow definition used when generating the above
DECLARE @xml XML = N'<workflow name="NYPD_Vehicle_Workflow">
	<variable name="stage" value="Stage"/>
	<variable name="path" value="C:\sisula\Example\data"/>
	<variable name="filenamePattern" value="[0-9]{5}_Collisions_.*\.csv"/>
	<variable name="quitWithSuccess" value="1"/>
	<variable name="quitWithFailure" value="2"/>
	<variable name="goToTheNextStep" value="3"/>
	<variable name="goToStepWithId" value="4"/>
	<variable name="queryTimeout" value="0"/>
	<variable name="extraOptions" value="-Recurse"/>
	<variable name="parameters" value="@agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))"/>
	<job name="NYPD_Vehicle_Staging">
		<variable name="tableName" value="MyTable"/>
		<jobstep name="Create raw table" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC NYPD_Vehicle_CreateRawTable @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Create insert view" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC NYPD_Vehicle_CreateInsertView @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Bulk insert" database_name="%SourceDatabase%" subsystem="PowerShell" on_success_action="3">
            $files = @(Get-ChildItem -Recurse FileSystem::"%SisulaPath%Example\data" | Where-Object {$_.Name -match "[0-9]{5}_Collisions_.*\.csv"})
            If ($files.length -eq 0) {
              Throw "No matching files were found in %SisulaPath%Example\data"
            } Else {
                ForEach ($file in $files) {
                    $fullFilename = $file.FullName
                    $modifiedDate = $file.LastWriteTime
                    Invoke-Sqlcmd "EXEC NYPD_Vehicle_BulkInsert ''$fullFilename'', ''$modifiedDate'', @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))" -Database "%SourceDatabase%" -ErrorAction Stop -QueryTimeout 0
                    Write-Output "Loaded file: $fullFilename"
                }
            }
        </jobstep>
		<jobstep name="Create split views" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC NYPD_Vehicle_CreateSplitViews @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Create error views" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC NYPD_Vehicle_CreateErrorViews @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Create typed tables" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC NYPD_Vehicle_CreateTypedTables @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Split raw into typed" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC NYPD_Vehicle_SplitRawIntoTyped @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Add keys to typed" database_name="%SourceDatabase%" subsystem="TSQL">
            EXEC NYPD_Vehicle_AddKeysToTyped @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
	</job>
	<job name="NYPD_Vehicle_Loading">
		<jobstep name="Load streets" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC [dbo].[lST_Street__NYPD_Vehicle_Collision_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Load intersection pass 1" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC [dbo].[lIS_Intersection__NYPD_Vehicle_Collision_Typed__1] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Load ST ST IS tie" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC [dbo].[lST_intersecting_IS_of_ST_crossing__NYPD_Vehicle_Collision_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Load intersection pass 2" database_name="%SourceDatabase%" subsystem="TSQL">
            EXEC [dbo].[lIS_Intersection__NYPD_Vehicle_Collision_Typed__2] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
	</job>
</workflow>
';
DECLARE @name varchar(255) = @xml.value('/workflow[1]/@name', 'varchar(255)');
DECLARE @CF_ID int;
SELECT
    @CF_ID = CF_ID
FROM
    Stage.metadata.lCF_Configuration
WHERE
    CF_NAM_Configuration_Name = @name;
IF(@CF_ID is null) 
BEGIN
    INSERT INTO Stage.metadata.lCF_Configuration (
        CF_TYP_CFT_ConfigurationType,
        CF_NAM_Configuration_Name,
        CF_XML_Configuration_XMLDefinition
    )
    VALUES (
        'Workflow',
        @name,
        @xml
    );
END
ELSE
BEGIN
    UPDATE Stage.metadata.lCF_Configuration
    SET
        CF_XML_Configuration_XMLDefinition = @xml
    WHERE
        CF_NAM_Configuration_Name = @name;
END
