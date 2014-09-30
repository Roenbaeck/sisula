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

INSERT INTO metadata.TYP_Type (
	TYP_ID, 
	TYP_Type
) VALUES 
(1, 'File'),
(2, 'Table');
