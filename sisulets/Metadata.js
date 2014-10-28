function beginMetadata(workName, configurationName, configurationType) {
    if(METADATA) {
/*~
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
DECLARE @theErrorSeverity int;
DECLARE @theErrorState int;

EXEC ${METADATABASE}$.metadata._WorkStarting
    @configurationName = $(configurationName)? '$configurationName', : null,
    @configurationType = $(configurationType)? '$configurationType', : null,
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
    EXEC ${METADATABASE}$.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE(),
        @theErrorSeverity = ERROR_SEVERITY(),
        @theErrorState = ERROR_STATE();
        
    EXEC ${METADATABASE}$.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    
    -- Propagate the error
    RAISERROR(
        @theErrorMessage,
        @theErrorSeverity,
        @theErrorState
    ); 
END CATCH
~*/
    }    
}

function setSourceToTargetMetadata(sourceName, sourceType, sourceCreated, targetName, targetType, targetCreated) {
    if(METADATA) {
/*~
EXEC ${METADATABASE}$.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = $(sourceName)? $sourceName, : DEFAULT,
    @targetName = $(targetName)? $targetName, : DEFAULT,
    @sourceType = $(sourceType)? $sourceType, : DEFAULT,
    @targetType = $(targetType)? $targetType, : DEFAULT,
    @sourceCreated = $(sourceCreated)? $sourceCreated, : DEFAULT,
    @targetCreated = $(targetCreated)? $targetCreated; : DEFAULT;
~*/
    }
}

function setInsertsMetadata(sqlVariableName) {
    if(METADATA) {
/*~
    EXEC ${METADATABASE}$.metadata._WorkSetInserts @workId, @operationsId, $sqlVariableName;
~*/
    }
}
function setUpdatesMetadata(sqlVariableName) {
    if(METADATA) {
/*~
    EXEC ${METADATABASE}$.metadata._WorkSetUpdates @workId, @operationsId, $sqlVariableName;
~*/
    }
}
function setDeletesMetadata(sqlVariableName) {
    if(METADATA) {
/*~
    EXEC ${METADATABASE}$.metadata._WorkSetDeletes @workId, @operationsId, $sqlVariableName;
~*/
    }
}
