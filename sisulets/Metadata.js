var METADATA = VARIABLES.MetaDatabase ? true : false;
var METADATABASE = VARIABLES.MetaDatabase;

function beginMetadata(workName) {
    if(METADATA) {
/*~
DECLARE @metadataId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);

EXEC ${METADATABASE}$.metadata._WorkStarting
    @WO_ID = @metadataId OUTPUT, 
    @name  = '$workName',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId

BEGIN TRY
~*/
    }        
}
function endMetadata() {
    if(METADATA) {
/*~
    EXEC metadata._WorkStopping @metadataId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
        
    EXEC ${METADATABASE}$.metadata._WorkStopping
        @WO_ID = @metadataId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    
    THROW; -- Propagate the error
END CATCH
~*/
    }    
}