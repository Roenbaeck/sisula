/*
	These provide a slight performance improvement when you have 
	collected lots of metadata (for example more than 5 million 
	WO_Work instances) and the time it takes to run _WorkStarting 
	is a significant portion of the total job time.

*/
CREATE NONCLUSTERED INDEX ix_WO_EST_Work_ExecutionStatus
ON [metadata].[WO_EST_Work_ExecutionStatus] ([WO_EST_EST_ID])

CREATE NONCLUSTERED INDEX ix_WO_NAM_Work_Name
ON [metadata].[WO_NAM_Work_Name] ([WO_NAM_WON_ID])

CREATE NONCLUSTERED INDEX ix_WO_part_JB_of
ON [metadata].[WO_part_JB_of] ([JB_ID_of])

CREATE NONCLUSTERED INDEX ix_JB_EST_Job_ExecutionStatus
ON [metadata].[JB_EST_Job_ExecutionStatus] ([JB_EST_EST_ID])

CREATE NONCLUSTERED INDEX ix_JB_AID_Job_AgentJobId
ON [metadata].[JB_AID_Job_AgentJobId] ([JB_AID_AID_ID])

CREATE NONCLUSTERED INDEX ix_JB_NAM_Job_Name
ON [metadata].[JB_NAM_Job_Name] ([JB_NAM_JON_ID])
