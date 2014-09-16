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
    @subsystem = 'TSQL', 
    @command = '
          EXEC SMHI_Weather_CreateRawTable
        ',
    @on_success_action = 3,
    @database_name = 'Test',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Create raw table'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
          EXEC SMHI_Weather_CreateInsertView
        ',
    @on_success_action = 3,
    @database_name = 'Test',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Create insert view'; 
GO
sp_add_jobstep 
    @subsystem = 'PowerShell', 
    @command = '
            $files = @(Get-ChildItem FileSystem::C:\sisula\data | Where-Object {$_.Name -match "Weather.*\.txt"})
            If ($files.length -eq 0) {
              Throw "No matching files were found in C:\sisula\data:"
            } Else {
                ForEach ($file in $files) {
                    Invoke-Sqlcmd "EXEC SMHI_Weather_BulkInsert ''C:\sisula\data\$file''" -Database "Test" -ErrorAction Stop
                    Write-Output "Loaded file: C:\sisula\data\$file"
                }
            }
        ',
    @on_success_action = 3,
    @database_name = 'Test',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Bulk insert'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
          EXEC SMHI_Weather_CreateSplitViews
        ',
    @on_success_action = 3,
    @database_name = 'Test',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Create split views'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
          EXEC SMHI_Weather_CreateErrorViews
        ',
    @on_success_action = 3,
    @database_name = 'Test',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Create error views'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
          EXEC SMHI_Weather_CreateTypedTables
        ',
    @on_success_action = 3,
    @database_name = 'Test',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Create typed tables'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
          EXEC SMHI_Weather_SplitRawIntoTyped
        ',
    @on_success_action = 3,
    @database_name = 'Test',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Split raw into typed'; 
GO
sp_add_jobstep 
    @subsystem = 'TSQL', 
    @command = '
          EXEC SMHI_Weather_AddKeysToTyped
        ',
    @database_name = 'Test',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Staging', 
    @step_name = 'Add keys to typed'; 
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
    @subsystem = 'TSQL', 
    -- mandatory parameters below and optional ones above this line
    @job_name = 'SMHI_Weather_Loading', 
    @step_name = 'Load DW tables'; 
GO
