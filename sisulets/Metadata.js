var METADATA = VARIABLES.MetaDatabase ? true : false;
var METADATABASE = VARIABLES.MetaDatabase;

function beginMetadata(name) {
    if(METADATA) {
/*~
DECLARE @metadataId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC ${METADATABASE}$.metadata._StartingWork 
    @WO_ID = @metadataId OUTPUT, 
    @name  = '$name';

BEGIN TRY
~*/
    }        
}
function endMetadata() {
    if(METADATA) {
/*~
    EXEC metadata._StoppingWork @metadataId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
        
    EXEC ${METADATABASE}$.metadata._StoppingWork 
        @WO_ID = @metadataId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    
    THROW; -- Propagate the error
END CATCH
~*/
    }    
}