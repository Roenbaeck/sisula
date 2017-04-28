------------------------------- NYPD_Vehicle_Workflow -------------------------------
USE msdb;
GO
DECLARE @scheduleId int;
DECLARE @scheduleName varchar(128);
SELECT
    s.schedule_id,
    s.name
INTO
    [#schedules NYPD_Vehicle_Staging]
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
    j.name = 'NYPD_Vehicle_Staging';
DECLARE schedules SCROLL CURSOR FOR SELECT schedule_id, name FROM [#schedules NYPD_Vehicle_Staging];
OPEN schedules;
IF EXISTS (select job_id from [dbo].[sysjobs] where name = 'NYPD_Vehicle_Staging')
BEGIN
    FETCH FIRST FROM schedules INTO @scheduleId, @scheduleName;
    WHILE(@@FETCH_STATUS = 0)
    BEGIN
        --PRINT 'Detaching schedule "' + @scheduleName + '" from NYPD_Vehicle_Staging';
        EXEC msdb.dbo.sp_detach_schedule @job_name = 'NYPD_Vehicle_Staging', @schedule_id = @scheduleId;
        FETCH NEXT FROM schedules INTO @scheduleId, @scheduleName;
    END
    EXEC sp_delete_job
        -- mandatory parameters below and optional ones above this line
        @job_name = 'NYPD_Vehicle_Staging';
END
EXEC sp_add_job
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging';
EXEC sp_add_jobserver
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging';
EXEC sp_add_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Log starting of job',
    @step_id = 1,
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStarting @workflowName = ''NYPD_Vehicle_Workflow'', @jobName = ''NYPD_Vehicle_Staging'', @agentJobId = $(ESCAPE_NONE(JOBID))',
    @on_success_action = 3; -- go to the next step
EXEC sp_add_jobstep
    @subsystem = 'PowerShell',
    @command = '
            $files = @(Get-ChildItem FileSystem::"C:\sisula\Example\data\incoming" | Where-Object {$_.Name -match "[0-9]{5}_Collisions_.*\.csv"})
            If ($files.length -eq 0) {
              Throw "No matching files were found in C:\sisula\Example\data\incoming"
            } Else {
                ForEach ($file in $files) {
                    $fullFilename = $file.FullName
                    Move-Item $fullFilename C:\sisula\Example\data\work -force
                    Write-Output "Moved file: $fullFilename to C:\sisula\Example\data\work"
                }
            }
        ',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Check for and move files';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC etl.NYPD_Vehicle_CreateRawTable @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Create raw table';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC etl.NYPD_Vehicle_CreateInsertView @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Create insert view';
EXEC sp_add_jobstep
    @subsystem = 'PowerShell',
    @command = '
            $files = @(Get-ChildItem -Recurse FileSystem::"C:\sisula\Example\data\work" | Where-Object {$_.Name -match "[0-9]{5}_Collisions_.*\.csv"})
            If ($files.length -eq 0) {
              Throw "No matching files were found in C:\sisula\Example\data\work"
            } Else {
                ForEach ($file in $files) {
                    $fullFilename = $file.FullName
                    $modifiedDate = $file.LastWriteTime
                    Invoke-Sqlcmd "EXEC etl.NYPD_Vehicle_BulkInsert ''$fullFilename'', ''$modifiedDate'', @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))" -Database "Stage" -ErrorAction Stop -QueryTimeout 0
                    Write-Output "Loaded file: $fullFilename"
                    Move-Item $fullFilename C:\sisula\Example\data\archive -force
                    Write-Output "Moved file: $fullFilename to C:\sisula\Example\data\archive"
                }
            }
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Bulk insert';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC etl.NYPD_Vehicle_CreateSplitViews @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Create split views';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC etl.NYPD_Vehicle_CreateErrorViews @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Create error views';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC etl.NYPD_Vehicle_CreateTypedTables @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Create typed tables';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC etl.NYPD_Vehicle_SplitRawIntoTyped @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Split raw into typed';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC etl.NYPD_Vehicle_AddKeysToTyped @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Add keys to typed';
EXEC sp_add_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Log success of job',
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStopping @name = ''NYPD_Vehicle_Staging'', @status = ''Success''',
    @on_success_action = 1; -- quit with success
EXEC sp_add_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_name = 'Log failure of job',
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStopping @name = ''NYPD_Vehicle_Staging'', @status = ''Failure''',
    @on_success_action = 2; -- quit with failure
EXEC sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 2,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 3,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 4,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 5,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 6,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 7,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 8,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 9,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 10,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Staging',
    @step_id = 10,
    -- ensure logging when last step succeeds
    @on_success_action = 4, -- go to step with id
    @on_success_step_id = 11;
FETCH FIRST FROM schedules INTO @scheduleId, @scheduleName;
WHILE(@@FETCH_STATUS = 0)
BEGIN
    --PRINT 'Attaching schedule "' + @scheduleName + '" to NYPD_Vehicle_Staging';
    EXEC msdb.dbo.sp_attach_schedule @job_name = 'NYPD_Vehicle_Staging', @schedule_id = @scheduleId;
    FETCH NEXT FROM schedules INTO @scheduleId, @scheduleName;
END
CLOSE schedules;
DEALLOCATE schedules;
DROP TABLE [#schedules NYPD_Vehicle_Staging];
SELECT
    s.schedule_id,
    s.name
INTO
    [#schedules NYPD_Vehicle_Loading]
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
    j.name = 'NYPD_Vehicle_Loading';
DECLARE schedules SCROLL CURSOR FOR SELECT schedule_id, name FROM [#schedules NYPD_Vehicle_Loading];
OPEN schedules;
IF EXISTS (select job_id from [dbo].[sysjobs] where name = 'NYPD_Vehicle_Loading')
BEGIN
    FETCH FIRST FROM schedules INTO @scheduleId, @scheduleName;
    WHILE(@@FETCH_STATUS = 0)
    BEGIN
        --PRINT 'Detaching schedule "' + @scheduleName + '" from NYPD_Vehicle_Loading';
        EXEC msdb.dbo.sp_detach_schedule @job_name = 'NYPD_Vehicle_Loading', @schedule_id = @scheduleId;
        FETCH NEXT FROM schedules INTO @scheduleId, @scheduleName;
    END
    EXEC sp_delete_job
        -- mandatory parameters below and optional ones above this line
        @job_name = 'NYPD_Vehicle_Loading';
END
EXEC sp_add_job
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Loading';
EXEC sp_add_jobserver
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Loading';
EXEC sp_add_jobstep
    @job_name = 'NYPD_Vehicle_Loading',
    @step_name = 'Log starting of job',
    @step_id = 1,
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStarting @workflowName = ''NYPD_Vehicle_Workflow'', @jobName = ''NYPD_Vehicle_Loading'', @agentJobId = $(ESCAPE_NONE(JOBID))',
    @on_success_action = 3; -- go to the next step
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC etl.[lST_Street__NYPD_Vehicle_Collision_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Loading',
    @step_name = 'Load streets';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC etl.[lIS_Intersection__NYPD_Vehicle_Collision_Typed__1] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Loading',
    @step_name = 'Load intersection pass 1';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC etl.[lST_intersecting_IS_of_ST_crossing__NYPD_Vehicle_Collision_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Loading',
    @step_name = 'Load ST ST IS tie';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC etl.[lIS_Intersection__NYPD_Vehicle_Collision_Typed__2] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'Stage',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'NYPD_Vehicle_Loading',
    @step_name = 'Load intersection pass 2';
EXEC sp_add_jobstep
    @job_name = 'NYPD_Vehicle_Loading',
    @step_name = 'Log success of job',
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStopping @name = ''NYPD_Vehicle_Loading'', @status = ''Success''',
    @on_success_action = 1; -- quit with success
EXEC sp_add_jobstep
    @job_name = 'NYPD_Vehicle_Loading',
    @step_name = 'Log failure of job',
    @subsystem = 'TSQL',
    @database_name = 'Stage',
    @command = 'EXEC metadata._JobStopping @name = ''NYPD_Vehicle_Loading'', @status = ''Failure''',
    @on_success_action = 2; -- quit with failure
EXEC sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Loading',
    @step_id = 2,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 7;
EXEC sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Loading',
    @step_id = 3,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 7;
EXEC sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Loading',
    @step_id = 4,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 7;
EXEC sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Loading',
    @step_id = 5,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 7;
EXEC sp_update_jobstep
    @job_name = 'NYPD_Vehicle_Loading',
    @step_id = 5,
    -- ensure logging when last step succeeds
    @on_success_action = 4, -- go to step with id
    @on_success_step_id = 6;
FETCH FIRST FROM schedules INTO @scheduleId, @scheduleName;
WHILE(@@FETCH_STATUS = 0)
BEGIN
    --PRINT 'Attaching schedule "' + @scheduleName + '" to NYPD_Vehicle_Loading';
    EXEC msdb.dbo.sp_attach_schedule @job_name = 'NYPD_Vehicle_Loading', @schedule_id = @scheduleId;
    FETCH NEXT FROM schedules INTO @scheduleId, @scheduleName;
END
CLOSE schedules;
DEALLOCATE schedules;
DROP TABLE [#schedules NYPD_Vehicle_Loading];
-- The workflow definition used when generating the above
DECLARE @xml XML = N'<workflow name="NYPD_Vehicle_Workflow">
	<variable name="stage" value="Stage"/>
	<variable name="incomingPath" value="C:\sisula\Example\data\incoming"/>
	<variable name="workPath" value="C:\sisula\Example\data\work"/>
	<variable name="archivePath" value="C:\sisula\Example\data\archive"/>
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
		<jobstep name="Check for and move files" subsystem="PowerShell" on_success_action="3">
            $files = @(Get-ChildItem FileSystem::"%SisulaPath%Example\data\incoming" | Where-Object {$_.Name -match "[0-9]{5}_Collisions_.*\.csv"})
            If ($files.length -eq 0) {
              Throw "No matching files were found in %SisulaPath%Example\data\incoming"
            } Else {
                ForEach ($file in $files) {
                    $fullFilename = $file.FullName
                    Move-Item $fullFilename %SisulaPath%Example\data\work -force
                    Write-Output "Moved file: $fullFilename to %SisulaPath%Example\data\work"
                }
            }
        </jobstep>
		<jobstep name="Create raw table" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC etl.NYPD_Vehicle_CreateRawTable @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Create insert view" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC etl.NYPD_Vehicle_CreateInsertView @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Bulk insert" database_name="%SourceDatabase%" subsystem="PowerShell" on_success_action="3">
            $files = @(Get-ChildItem -Recurse FileSystem::"%SisulaPath%Example\data\work" | Where-Object {$_.Name -match "[0-9]{5}_Collisions_.*\.csv"})
            If ($files.length -eq 0) {
              Throw "No matching files were found in %SisulaPath%Example\data\work"
            } Else {
                ForEach ($file in $files) {
                    $fullFilename = $file.FullName
                    $modifiedDate = $file.LastWriteTime
                    Invoke-Sqlcmd "EXEC etl.NYPD_Vehicle_BulkInsert ''$fullFilename'', ''$modifiedDate'', @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))" -Database "%SourceDatabase%" -ErrorAction Stop -QueryTimeout 0
                    Write-Output "Loaded file: $fullFilename"
                    Move-Item $fullFilename %SisulaPath%Example\data\archive -force
                    Write-Output "Moved file: $fullFilename to %SisulaPath%Example\data\archive"
                }
            }
        </jobstep>
		<jobstep name="Create split views" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC etl.NYPD_Vehicle_CreateSplitViews @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Create error views" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC etl.NYPD_Vehicle_CreateErrorViews @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Create typed tables" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC etl.NYPD_Vehicle_CreateTypedTables @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Split raw into typed" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC etl.NYPD_Vehicle_SplitRawIntoTyped @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Add keys to typed" database_name="%SourceDatabase%" subsystem="TSQL">
            EXEC etl.NYPD_Vehicle_AddKeysToTyped @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
	</job>
	<job name="NYPD_Vehicle_Loading">
		<jobstep name="Load streets" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC etl.[lST_Street__NYPD_Vehicle_Collision_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Load intersection pass 1" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC etl.[lIS_Intersection__NYPD_Vehicle_Collision_Typed__1] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Load ST ST IS tie" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC etl.[lST_intersecting_IS_of_ST_crossing__NYPD_Vehicle_Collision_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Load intersection pass 2" database_name="%SourceDatabase%" subsystem="TSQL">
            EXEC etl.[lIS_Intersection__NYPD_Vehicle_Collision_Typed__2] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
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
