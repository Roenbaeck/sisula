----------------------
-- Load knot values --
----------------------
INSERT INTO metadata.EST_ExecutionStatus (
	EST_ID,
	EST_ExecutionStatus
) VALUES
(1, 'Success');

INSERT INTO metadata.EST_ExecutionStatus (
	EST_ID,
	EST_ExecutionStatus
) VALUES
(2, 'Failure');

INSERT INTO metadata.EST_ExecutionStatus (
	EST_ID,
	EST_ExecutionStatus
) VALUES
(3, 'Running');

INSERT INTO metadata.COT_ContainerType (
	COT_ID,
	COT_ContainerType
) VALUES
(1, 'File');

INSERT INTO metadata.COT_ContainerType (
	COT_ID,
	COT_ContainerType
) VALUES
(2, 'Table');

INSERT INTO metadata.COT_ContainerType (
	COT_ID,
	COT_ContainerType
) VALUES
(3, 'View');

INSERT INTO metadata.CFT_ConfigurationType (
	CFT_ID,
	CFT_ConfigurationType
) VALUES
(1, 'Workflow');

INSERT INTO metadata.CFT_ConfigurationType (
	CFT_ID,
	CFT_ConfigurationType
) VALUES
(2, 'Source');

INSERT INTO metadata.CFT_ConfigurationType (
	CFT_ID,
	CFT_ConfigurationType
) VALUES
(3, 'Target');
