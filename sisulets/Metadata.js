var METADATA = VARIABLES.MetaDatabase ? true : false;
var METADATABASE = VARIABLES.MetaDatabase;

function beginMetadata(workName) {
    if(METADATA) {
/*~
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);

EXEC ${METADATABASE}$.metadata._WorkStarting
    @WO_ID = @workId OUTPUT, 
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
    EXEC metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
        
    EXEC ${METADATABASE}$.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    
    THROW; -- Propagate the error
END CATCH
~*/
    }    
}

// TODO: Create sourceToTargetMetadata here!

function setInsertsMetadata(sqlVariable) {
    if(METADATA) {
/*~
    EXEC metadata._WorkSetInserts @workId, @operationsId, $sqlVariable;
~*/
    }
}
function setUpdatesMetadata(sqlVariable) {
    if(METADATA) {
/*~
    EXEC metadata._WorkSetUpdates @workId, @operationsId, $sqlVariable;
~*/
    }
}
function setDeletesMetadata(sqlVariable) {
    if(METADATA) {
/*~
    EXEC metadata._WorkSetDeletes @workId, @operationsId, $sqlVariable;
~*/
    }
}
