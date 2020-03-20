------------------------------- PGA_Kaggle_Workflow -------------------------------
USE msdb;
GO
DECLARE @AgentJobID uniqueidentifier;
-- check for existing job
SET @AgentJobID = (
    select job_id from [dbo].[sysjobs] where name = 'PGA_Kaggle_Staging'
);
IF (@AgentJobID is null)
BEGIN
    EXEC sp_add_job
        -- mandatory parameters below and optional ones above this line
        @job_name = 'PGA_Kaggle_Staging',
        -- capture the newly created job id 
        @job_id = @AgentJobID OUTPUT;
    EXEC sp_add_jobserver
        -- mandatory parameters below and optional ones above this line
        @job_name = 'PGA_Kaggle_Staging';
END
ELSE
BEGIN
    -- deleting the magical step 0 removes all job steps (this is documented behavior)
    EXEC sp_delete_jobstep @job_Id = @AgentJobID, @step_id = 0;
END
EXEC sp_add_jobstep
    @job_id = @AgentJobID,
    @step_name = 'Log starting of job',
    @step_id = 1,
    @subsystem = 'TSQL',
    @database_name = 'GolfDW',
    @command = 'EXEC metadata._JobStarting @workflowName = ''PGA_Kaggle_Workflow'', @jobName = ''PGA_Kaggle_Staging'', @agentJobId = $(ESCAPE_NONE(JOBID))',
    @on_success_action = 3; -- go to the next step
EXEC sp_add_jobstep
    @subsystem = 'PowerShell',
    @command = '
            $files = @(Get-ChildItem FileSystem::"G:\Versionshanterat\sisula\Golf\data\incoming" | Where-Object {$_.Name -match ".*\.csv"})
            If ($files.length -eq 0) {
              Throw "No matching files were found in G:\Versionshanterat\sisula\Golf\data\incoming"
            } Else {
                ForEach ($file in $files) {
                    $fullFilename = $file.FullName
                    Move-Item $fullFilename G:\Versionshanterat\sisula\Golf\data\work -force
                    Write-Output "Moved file: $fullFilename to G:\Versionshanterat\sisula\Golf\data\work"
                }
            }
        ',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_id = @AgentJobID,
    @step_name = 'Check for and move files';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC PGA_Kaggle_CreateRawSplitTable @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'GolfStage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_id = @AgentJobID,
    @step_name = 'Create raw split table';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC dbo.PGA_Kaggle_CreateInsertView @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'GolfStage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_id = @AgentJobID,
    @step_name = 'Create insert view';
EXEC sp_add_jobstep
    @subsystem = 'PowerShell',
    @command = '
            $files = @(Get-ChildItem -Recurse FileSystem::"G:\Versionshanterat\sisula\Golf\data\work" | Where-Object {$_.Name -match ".*\.csv"})
            If ($files.length -eq 0) {
              Throw "No matching files were found in G:\Versionshanterat\sisula\Golf\data\work"
            } Else {
                ForEach ($file in $files) {
                    $fullFilename = $file.FullName
                    $modifiedDate = $file.LastWriteTime
                    Invoke-Sqlcmd "EXEC dbo.PGA_Kaggle_BulkInsert ''$fullFilename'', ''$modifiedDate'', @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))" -Database "GolfStage" -ErrorAction Stop -QueryTimeout 0
                    Write-Output "Loaded file: $fullFilename"
                    Move-Item $fullFilename G:\Versionshanterat\sisula\Golf\data\archive -force
                    Write-Output "Moved file: $fullFilename to G:\Versionshanterat\sisula\Golf\data\archive"
                }
            }
        ',
    @database_name = 'GolfStage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_id = @AgentJobID,
    @step_name = 'Bulk insert';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC dbo.PGA_Kaggle_CreateSplitViews @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'GolfStage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_id = @AgentJobID,
    @step_name = 'Create split views';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC dbo.PGA_Kaggle_CreateErrorViews @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'GolfStage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_id = @AgentJobID,
    @step_name = 'Create error views';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC dbo.PGA_Kaggle_CreateTypedTables @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'GolfStage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_id = @AgentJobID,
    @step_name = 'Create typed tables';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC dbo.PGA_Kaggle_SplitRawIntoTyped @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'GolfStage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_id = @AgentJobID,
    @step_name = 'Split raw into typed';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC dbo.PGA_Kaggle_AddKeysToTyped @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'GolfStage',
    -- mandatory parameters below and optional ones above this line
    @job_id = @AgentJobID,
    @step_name = 'Add keys to typed';
EXEC sp_add_jobstep
    @job_id = @AgentJobID,
    @step_name = 'Log success of job',
    @subsystem = 'TSQL',
    @database_name = 'GolfDW',
    @command = 'EXEC metadata._JobStopping @name = ''PGA_Kaggle_Staging'', @status = ''Success''',
    @on_success_action = 1; -- quit with success
EXEC sp_add_jobstep
    @job_id = @AgentJobID,
    @step_name = 'Log failure of job',
    @subsystem = 'TSQL',
    @database_name = 'GolfDW',
    @command = 'EXEC metadata._JobStopping @name = ''PGA_Kaggle_Staging'', @status = ''Failure''',
    @on_success_action = 2; -- quit with failure
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 2,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 3,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 4,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 5,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 6,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 7,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 8,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 9,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 10,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 12;
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 10,
    -- ensure logging when last step succeeds
    @on_success_action = 4, -- go to step with id
    @on_success_step_id = 11;
-- end of job creation
-- check for existing job
SET @AgentJobID = (
    select job_id from [dbo].[sysjobs] where name = 'PGA_Kaggle_Loading'
);
IF (@AgentJobID is null)
BEGIN
    EXEC sp_add_job
        -- mandatory parameters below and optional ones above this line
        @job_name = 'PGA_Kaggle_Loading',
        -- capture the newly created job id 
        @job_id = @AgentJobID OUTPUT;
    EXEC sp_add_jobserver
        -- mandatory parameters below and optional ones above this line
        @job_name = 'PGA_Kaggle_Loading';
END
ELSE
BEGIN
    -- deleting the magical step 0 removes all job steps (this is documented behavior)
    EXEC sp_delete_jobstep @job_Id = @AgentJobID, @step_id = 0;
END
EXEC sp_add_jobstep
    @job_id = @AgentJobID,
    @step_name = 'Log starting of job',
    @step_id = 1,
    @subsystem = 'TSQL',
    @database_name = 'GolfDW',
    @command = 'EXEC metadata._JobStarting @workflowName = ''PGA_Kaggle_Workflow'', @jobName = ''PGA_Kaggle_Loading'', @agentJobId = $(ESCAPE_NONE(JOBID))',
    @on_success_action = 3; -- go to the next step
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC dbo.[lPL_Player__PGA_Kaggle_Stats_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'GolfStage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_id = @AgentJobID,
    @step_name = 'Load players';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC dbo.[SGR_StatisticGroup__PGA_Kaggle_Stats_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'GolfStage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_id = @AgentJobID,
    @step_name = 'Load statistic groups';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC dbo.[lST_Statistic__PGA_Kaggle_Stats_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'GolfStage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_id = @AgentJobID,
    @step_name = 'Load statistic';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC dbo.[lME_Measurement__PGA_Kaggle_Stats_Typed__Instance] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'GolfStage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_id = @AgentJobID,
    @step_name = 'Load measurement (instance)';
EXEC sp_add_jobstep
    @subsystem = 'TSQL',
    @command = '
            EXEC dbo.[lME_Measurement__PGA_Kaggle_Stats_Typed__Value] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        ',
    @database_name = 'GolfStage',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_id = @AgentJobID,
    @step_name = 'Load measurement (value)';
EXEC sp_add_jobstep
    @job_id = @AgentJobID,
    @step_name = 'Log success of job',
    @subsystem = 'TSQL',
    @database_name = 'GolfDW',
    @command = 'EXEC metadata._JobStopping @name = ''PGA_Kaggle_Loading'', @status = ''Success''',
    @on_success_action = 1; -- quit with success
EXEC sp_add_jobstep
    @job_id = @AgentJobID,
    @step_name = 'Log failure of job',
    @subsystem = 'TSQL',
    @database_name = 'GolfDW',
    @command = 'EXEC metadata._JobStopping @name = ''PGA_Kaggle_Loading'', @status = ''Failure''',
    @on_success_action = 2; -- quit with failure
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 2,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 8;
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 3,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 8;
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 4,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 8;
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 5,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 8;
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 6,
    -- ensure logging when any step fails
    @on_fail_action = 4, -- go to step with id
    @on_fail_step_id = 8;
EXEC sp_update_jobstep
    @job_id = @AgentJobID,
    @step_id = 6,
    -- ensure logging when last step succeeds
    @on_success_action = 4, -- go to step with id
    @on_success_step_id = 7;
-- end of job creation
-- The workflow definition used when generating the above
DECLARE @xml XML = N'<workflow name="PGA_Kaggle_Workflow">
	<variable name="stage" value="GolfStage"/>
	<variable name="incomingPath" value="G:\Versionshanterat\sisula\Golf\data\incoming"/>
	<variable name="workPath" value="G:\Versionshanterat\sisula\Golf\data\work"/>
	<variable name="archivePath" value="G:\Versionshanterat\sisula\Golf\data\archive"/>
	<variable name="filenamePattern" value=".*\.csv"/>
	<variable name="quitWithSuccess" value="1"/>
	<variable name="quitWithFailure" value="2"/>
	<variable name="goToTheNextStep" value="3"/>
	<variable name="goToStepWithId" value="4"/>
	<variable name="queryTimeout" value="0"/>
	<variable name="extraOptions" value="-Recurse"/>
	<variable name="parameters" value="@agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))"/>
	<job name="PGA_Kaggle_Staging">
		<variable name="tableName" value="MyTable"/>
		<jobstep name="Check for and move files" subsystem="PowerShell" on_success_action="3">
            $files = @(Get-ChildItem FileSystem::"%SisulaPath%Golf\data\incoming" | Where-Object {$_.Name -match ".*\.csv"})
            If ($files.length -eq 0) {
              Throw "No matching files were found in %SisulaPath%Golf\data\incoming"
            } Else {
                ForEach ($file in $files) {
                    $fullFilename = $file.FullName
                    Move-Item $fullFilename %SisulaPath%Golf\data\work -force
                    Write-Output "Moved file: $fullFilename to %SisulaPath%Golf\data\work"
                }
            }
        </jobstep>
		<jobstep name="Create raw split table" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC PGA_Kaggle_CreateRawSplitTable @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Create insert view" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC dbo.PGA_Kaggle_CreateInsertView @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Bulk insert" database_name="%SourceDatabase%" subsystem="PowerShell" on_success_action="3">
            $files = @(Get-ChildItem -Recurse FileSystem::"%SisulaPath%Golf\data\work" | Where-Object {$_.Name -match ".*\.csv"})
            If ($files.length -eq 0) {
              Throw "No matching files were found in %SisulaPath%Golf\data\work"
            } Else {
                ForEach ($file in $files) {
                    $fullFilename = $file.FullName
                    $modifiedDate = $file.LastWriteTime
                    Invoke-Sqlcmd "EXEC dbo.PGA_Kaggle_BulkInsert ''$fullFilename'', ''$modifiedDate'', @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))" -Database "%SourceDatabase%" -ErrorAction Stop -QueryTimeout 0
                    Write-Output "Loaded file: $fullFilename"
                    Move-Item $fullFilename %SisulaPath%Golf\data\archive -force
                    Write-Output "Moved file: $fullFilename to %SisulaPath%Golf\data\archive"
                }
            }
        </jobstep>
		<jobstep name="Create split views" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC dbo.PGA_Kaggle_CreateSplitViews @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Create error views" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC dbo.PGA_Kaggle_CreateErrorViews @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Create typed tables" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC dbo.PGA_Kaggle_CreateTypedTables @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Split raw into typed" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC dbo.PGA_Kaggle_SplitRawIntoTyped @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Add keys to typed" database_name="%SourceDatabase%" subsystem="TSQL">
            EXEC dbo.PGA_Kaggle_AddKeysToTyped @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
	</job>
	<job name="PGA_Kaggle_Loading">
		<jobstep name="Load players" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC dbo.[lPL_Player__PGA_Kaggle_Stats_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Load statistic groups" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC dbo.[SGR_StatisticGroup__PGA_Kaggle_Stats_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Load statistic" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC dbo.[lST_Statistic__PGA_Kaggle_Stats_Typed] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Load measurement (instance)" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC dbo.[lME_Measurement__PGA_Kaggle_Stats_Typed__Instance] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
		<jobstep name="Load measurement (value)" database_name="%SourceDatabase%" subsystem="TSQL" on_success_action="3">
            EXEC dbo.[lME_Measurement__PGA_Kaggle_Stats_Typed__Value] @agentJobId = $(ESCAPE_NONE(JOBID)), @agentStepId = $(ESCAPE_NONE(STEPID))
        </jobstep>
	</job>
</workflow>
';
DECLARE @name varchar(255) = @xml.value('/workflow[1]/@name', 'varchar(255)');
DECLARE @CF_ID int;
SELECT
    @CF_ID = CF_ID
FROM
    GolfDW.metadata.lCF_Configuration
WHERE
    CF_NAM_Configuration_Name = @name;
IF(@CF_ID is null) 
BEGIN
    INSERT INTO GolfDW.metadata.lCF_Configuration (
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
    UPDATE GolfDW.metadata.lCF_Configuration
    SET
        CF_XML_Configuration_XMLDefinition = @xml
    WHERE
        CF_NAM_Configuration_Name = @name;
END
