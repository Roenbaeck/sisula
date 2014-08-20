------------------------------- Load DW -------------------------------
USE msdb;
GO
sp_delete_job
    -- mandatory parameters below and optional ones above this line
    @job_name = 'Staging';
GO
sp_add_job 
    @description = '
        This is the staging job.
        ',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'Staging';
GO
sp_add_jobstep 
    @step_id = 1, 
    @subsystem = 'TSQL', 
    @command = '
          SELECT 
            e-lronnback
          FROM
            MyTable
        ',
    @on_success_action = 3,
    -- mandatory parameters below and optional ones above this line
    @job_name = 'Staging', 
    @step_name = 'Load Eco files'; 
GO
sp_add_jobstep 
    @step_id = 2, 
    @subsystem = 'TSQL', 
    @command = '
          SELECT 
            *
          FROM
            MyTable
        ',
    @database_name = 'MyDB',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'Staging', 
    @step_name = 'Transform Eco data'; 
GO
sp_delete_job
    -- mandatory parameters below and optional ones above this line
    @job_name = 'Loading';
GO
sp_add_job 
    -- mandatory parameters below and optional ones above this line
    @job_name = 'Loading';
GO
sp_add_jobstep 
    @step_id = 1, 
    @subsystem = 'TSQL', 
    @command = '
          SELECT 
            *
          FROM
            Hello World!
        ',
    -- mandatory parameters below and optional ones above this line
    @job_name = 'Loading', 
    @step_name = 'Load DW tables'; 
GO
