----------------------
-- Load knot values --
----------------------
INSERT INTO metadata.EST_ExecutionStatus (
	EST_ID, 
	EST_ExecutionStatus
) VALUES 
(1, 'Success'),
(2, 'Failure'),
(3, 'Running');

INSERT INTO metadata.COT_ContainerType (
	COT_ID, 
	COT_ContainerType
) VALUES 
(1, 'File'),
(2, 'Table'),
(3, 'View');

INSERT INTO metadata.CFT_ConfigurationType (
	CFT_ID,
	CFT_ConfigurationType
) VALUES 
(1, 'Workflow'),
(2, 'Source'),
(3, 'Target');
