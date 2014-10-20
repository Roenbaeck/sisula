if(METADATA) {
/*~
-- The workflow definition used when generating the above
DECLARE @xml XML = N'${workflow._xml.escape()}$';
DECLARE @name varchar(255) = @xml.value('/workflow[1]/@name', 'varchar(255)');
DECLARE @CF_ID int;
SELECT
    @CF_ID = CF_ID
FROM
    ${METADATABASE}$.metadata.lCF_Configuration
WHERE
    CF_NAM_Configuration_Name = @name;
    
IF(@CF_ID is null) 
BEGIN
    INSERT INTO ${METADATABASE}$.metadata.lCF_Configuration (
        CF_TYP_CFT_ConfigurationType,
        CF_NAM_Configuration_Name,
        CF_XML_Configuration_XMLDefinition
    )
    VALUES (
        'Workflow',
        @name,
        @xml
    );
END
ELSE
BEGIN
    UPDATE ${METADATABASE}$.metadata.lCF_Configuration
    SET
        CF_XML_Configuration_XMLDefinition = @xml
    WHERE
        CF_NAM_Configuration_Name = @name;
END
~*/
}