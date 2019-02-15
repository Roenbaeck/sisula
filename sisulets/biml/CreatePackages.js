// Create loading logic
var load, map, sql, i;
/*~
<Biml xmlns="http://schemas.varigence.com/biml.xsd">
    <Connections>
        <OleDbConnection Name="$VARIABLES.SourceDatabase" ConnectionString="Data Source=$VARIABLES.SourceServer;Server=$VARIABLES.SourceServer;Initial Catalog=$VARIABLES.SourceDatabase;Integrated Security=SSPI;Provider=SQLNCLI11;Packet Size=32737;" />
        <OleDbConnection Name="$VARIABLES.TargetDatabase" ConnectionString="Data Source=$VARIABLES.TargetServer;Server=$VARIABLES.TargetServer;Initial Catalog=$VARIABLES.TargetDatabase;Integrated Security=SSPI;Provider=SQLNCLI11;Packet Size=32737;" />
    </Connections>
    <Packages>
~*/
while(load = target.nextLoad()) {
    var naturalKeys = [], 
        surrogateKeys = [], 
        metadata = [],
        others = [];
    // populate some arrays
    while(map = load.nextMap()) {
        switch (map.as) {
            case 'natural key':
                naturalKeys.push(map);
                break;
            case 'surrogate key':
                surrogateKeys.push(map);
                break;
            case 'metadata':
                metadata.push(map);
                break;
            default:
                others.push(map);
        }
    }    

    var attributeMappings = [];
    var knotToAttributes = {};
    var numberOfHistorizedAttributes = 0;
    var numberOfKnottedAttributes = 0;
    if(load.toAnchor()) {
        while(map = load.nextMap()) {
            if(map.knot) {
                numberOfKnottedAttributes++;
                if(knotToAttributes[map.knot])
                    knotToAttributes[map.knot].push(map);
                else
                    knotToAttributes[map.knot] = [map];
            }
            if(map.isValueColumn()) {
                var otherMap;
                var attributeMnemonic = map.target.match(/^(..\_...)\_.*/)[1];
                for(i = 0; otherMap = others[i]; i++) {
                    if(otherMap.target == attributeMnemonic + '_ChangedAt') {
                        map.isHistorized = true;
                        numberOfHistorizedAttributes++;
                    }
                }
                attributeMappings.push(map);
            }
        }
    }
    var now = new Date();
/*~
        <Package Name="$load.qualified" ConstraintMode="Linear" ProtectionLevel="EncryptSensitiveWithPassword" PackagePassword="sisula">
            <Annotations>
                <Annotation AnnotationType="Description">BIML generated: ${new Date()}$ by $VARIABLES.USERNAME from: $VARIABLES.COMPUTERNAME in the $VARIABLES.USERDOMAIN domain</Annotation>
            </Annotations>
            <Tasks>
~*/
    if(sql = load.sql ? load.sql.before : null) {
/*~
                <ExecuteSQL Name="SQL Before" ConnectionName="$VARIABLES.SourceDatabase">
                    <DirectInput>$sql._sql</DirectInput>
                </ExecuteSQL>
~*/
    }

    if(attributeMappings.length > 0) {
/*~
                <ExecuteSQL Name="Disable triggers and constraints" ConnectionName="$VARIABLES.TargetDatabase">
                    <DirectInput>
~*/
        for(i = 0; map = attributeMappings[i]; i++) {
/*~
                    DISABLE TRIGGER ALL ON [${VARIABLES.TargetSchema}$].[${map.attribute}$];
                    ALTER TABLE [${VARIABLES.TargetSchema}$].[${map.attribute}$] NOCHECK CONSTRAINT ALL;
~*/
        }
/*~
                    </DirectInput>
                </ExecuteSQL>
~*/        
    }

    var commaStr = ',',
        andStr = 'AND';

    var loadingSQL = load._load ? load._load : "SELECT * FROM " + load.source;

    // one thread for the source + one for each destination
    var numberOfThreads; 
    if(numberOfKnottedAttributes > 0) {
        numberOfThreads = numberOfKnottedAttributes + 1;
/*~
                <Dataflow Name="Load knots" EngineThreads="$numberOfThreads">
                    <Transformations>
                        <OleDbSource Name="$load.source" ConnectionName="$VARIABLES.SourceDatabase">
                            <DirectInput>$loadingSQL</DirectInput>
                        </OleDbSource>
                        <Multicast Name="Split">
                            <OutputPaths> 
~*/
        for(i = 0; map = attributeMappings[i]; i++) {
            if(map.knot) {
/*~
                                <OutputPath Name="$map.attribute"/> 
~*/
            }
        }
/*~
                            </OutputPaths>
                        </Multicast>
~*/
        for(i = 0; map = attributeMappings[i]; i++) {
            if(map.knot) {
                var knotMnemonic = map.knot.match(/^(...)\_.*/)[1];
/*~
                        <ConditionalSplit Name="${map.attribute}$__not_Null">
                            <OutputPaths>
                                <OutputPath Name="Values">
                                    <Expression>!ISNULL([$map.source])</Expression>
                                </OutputPath>
                            </OutputPaths>
                            <InputPath OutputPathName="Split.$map.attribute" />
                        </ConditionalSplit>
                        <Aggregate Name="${map.attribute}$__Unique" GroupByKeyScale="Low" AutoExtendFactor="100">
                            <InputPath OutputPathName="${map.attribute}$__not_Null.Values" />
                            <OutputPaths>
                                <OutputPath Name="Values">
                                    <Columns>
                                        <Column Operation="GroupBy" SourceColumn="$map.source" TargetColumn="$map.knot"/>
~*/
                if(metadata[0]) {
/*~
                                        <Column Operation="Minimum" SourceColumn="${metadata[0].source}$" />
~*/                                                        
                }
/*~                                
                                    </Columns>
                                </OutputPath>
                            </OutputPaths>
                        </Aggregate>
~*/
            }
        }

        for(var knot in knotToAttributes) {
            // knot reuse
            if(knotToAttributes[knot].length > 0) {
/*~
                        <UnionAll Name="${knot}$__Union">
                            <InputPaths>
~*/
                for(i = 0; map = knotToAttributes[knot][i]; i++) {
/*~
                                <InputPath OutputPathName="${map.attribute}$__Unique.Values">
                                    <Columns>
                                        <Column SourceColumn="$map.source"/>
                                    </Columns>
                                </InputPath>
~*/
                }
/*~                            
                            </InputPaths>
                        </UnionAll>
                        <Aggregate Name="${knot}$__Unique" GroupByKeyScale="Low" AutoExtendFactor="100">
                            <OutputPaths>
                                <OutputPath Name="Values">
                                    <Columns>
                                        <Column Operation="GroupBy" SourceColumn="$knot" TargetColumn="$knot"/>
~*/
                if(metadata[0]) {
/*~
                                        <Column Operation="Minimum" SourceColumn="${metadata[0].source}$" />
~*/                                                        
                }
/*~                                
                                    </Columns>
                                </OutputPath>
                            </OutputPaths>
                        </Aggregate>
~*/                
            }

            var knotMnemonic = knot.match(/^(...)\_.*/)[1];
/*~                        
                        <Lookup Name="${knot}$__Lookup" NoMatchBehavior="RedirectRowsToNoMatchOutput" CacheMode="Full" OleDbConnectionName="$VARIABLES.TargetDatabase">
                            <ExternalTableInput Table="[$VARIABLES.TargetSchema].[${knot}$]" />
                            <Inputs>
                                <Column SourceColumn="$knot" TargetColumn="$knot" />
                            </Inputs>
                            <InputPath OutputPathName="${knot}$__Unique.Values" />
                        </Lookup>
                        <OleDbDestination Name="${knot}$" ConnectionName="$VARIABLES.TargetDatabase" BatchSize="0" MaximumInsertCommitSize="0" KeepNulls="false" KeepIdentity="false" CheckConstraints="false" UseFastLoadIfAvailable="true" TableLock="true">
                            <ErrorHandling ErrorRowDisposition="FailComponent" TruncationRowDisposition="FailComponent" />
                            <ExternalTableOutput Table="[${VARIABLES.TargetSchema}$].[${knot}$]" />
                            <InputPath OutputPathName="${knot}$__Lookup.NoMatch" />
                            <Columns>
                                <Column SourceColumn="$knot" TargetColumn="$knot" />
~*/
            if(metadata[0]) {
/*~
                                <Column SourceColumn="${metadata[0].source}$" TargetColumn="Metadata_${knotMnemonic}$" />
~*/                                                        
            }
/*~                                
                            </Columns>
                        </OleDbDestination>
~*/
        }
/*~
                    </Transformations>
                </Dataflow>
~*/        
    } // if knotted attributes exist
    // one thread for the source + two for each destination (known and unknown)
    numberOfThreads = 2 * attributeMappings.length + 1;
/*~
                <Dataflow Name="Load data" EngineThreads="$numberOfThreads">
                    <Transformations>
~*/
    if(naturalKeys.length == 0 && surrogateKeys.length == 0) {
/*~
                        <OleDbSource Name="$load.source" ConnectionName="$VARIABLES.SourceDatabase">
                            <DirectInput>$loadingSQL</DirectInput>
                        </OleDbSource>
~*/
    }
    else if(naturalKeys.length > 0 && load.toAnchor()) {
/*~
                        <OleDbSource Name="$load.source" ConnectionName="$VARIABLES.SourceDatabase">
                            <DirectInput>
                                DBCC TRACEON (610);
                                DECLARE @known INT = 0;
                                MERGE [${VARIABLES.TargetDatabase}$].[${VARIABLES.TargetSchema}$].[${load.targetTable}$] [${load.anchorMnemonic}$]
                                USING (
                                    SELECT
                                        l.${load.anchorMnemonic}$_ID,
~*/
        while(map = load.nextMap()) {
            commaStr = load.hasMoreMaps() ? ',' : '';
/*~
                                        t.${map.source + commaStr}$
~*/
        }
/*~
                                    FROM (
                                        $loadingSQL
                                    ) t
                                    LEFT JOIN
                                        [${VARIABLES.TargetDatabase}$].[${VARIABLES.TargetSchema}$].[${load.target}$] l WITH (NOLOCK)
                                    ON
~*/
        for(i = 0; map = naturalKeys[i]; i++) {
            andStr = naturalKeys[i+1] ? 'AND' : '';
/*~            
                                        t.$map.source = l.$map.target $andStr
~*/
        }
/*~
                                ) src
                                ON
                                    src.${load.anchorMnemonic}$_ID = [${load.anchorMnemonic}$].${load.anchorMnemonic}$_ID
~*/
        if(metadata[0]) {
/*~                                    
                                WHEN NOT MATCHED THEN 
                                INSERT ( Metadata_${load.anchorMnemonic}$ )
                                VALUES ( src.${metadata[0].source}$ )
~*/
        }
        else {
/*~                                    
                                WHEN NOT MATCHED THEN 
                                INSERT ( ${load.anchorMnemonic}$_Dummy )
                                VALUES ( null )
~*/            
        }
/*~
                                WHEN MATCHED THEN 
                                UPDATE SET @known = @known + 1
                                OUTPUT
                                    isnull(src.${load.anchorMnemonic}$_ID, inserted.${load.anchorMnemonic}$_ID) as ${load.anchorMnemonic}$_ID,
~*/
        var uniqueSourceColumns = [];
        while(map = load.nextMap()) {
            if(uniqueSourceColumns.indexOf(map.source) < 0) {
                uniqueSourceColumns.push(map.source);
/*~
                                    src.$map.source,
~*/
            }
        }
/*~                                    
                                    left($$action, 1) as __Operation;
                            </DirectInput>
                        </OleDbSource>
~*/
    }
    else if(surrogateKeys.length > 0 && load.toAnchor()) {
/*~
                        <OleDbSource Name="$load.source" ConnectionName="$VARIABLES.SourceDatabase">
                            <DirectInput>
                                DBCC TRACEON (610);
                                DECLARE @known INT = 0;
                                MERGE [${VARIABLES.TargetDatabase}$].[${VARIABLES.TargetSchema}$].[${load.targetTable}$] [${load.anchorMnemonic}$]
                                USING (
                                    $loadingSQL
                                ) src
                                ON
                                    src.${surrogateKeys[0].source}$ = [${load.anchorMnemonic}$].${surrogateKeys[0].target}$
~*/
        if(metadata[0]) {
/*~                                    
                                WHEN NOT MATCHED THEN 
                                INSERT ( Metadata_${load.anchorMnemonic}$ )
                                VALUES ( src.${metadata[0].source}$ )
~*/
        }
        else {
/*~                                    
                                WHEN NOT MATCHED THEN 
                                INSERT ( ${load.anchorMnemonic}$_Dummy )
                                VALUES ( null )
~*/            
        }
/*~
                                WHEN MATCHED THEN 
                                UPDATE SET @known = @known + 1
                                OUTPUT
                                    isnull(src.${surrogateKeys[0].source}$, inserted.${load.anchorMnemonic}$_ID) as ${load.anchorMnemonic}$_ID,
~*/
        var uniqueSourceColumns = [];
        while(map = load.nextMap()) {
            if(uniqueSourceColumns.indexOf(map.source) < 0 && surrogateKeys.indexOf(map) < 0) {
                uniqueSourceColumns.push(map.source);
/*~
                                    src.$map.source,
~*/
            }
        }
        if(metadata[0]) {
/*~
                                    ${metadata[0].source}$,
~*/            
        }
/*~
                                    left($$action, 1) as __Operation;
                            </DirectInput>
                        </OleDbSource>
~*/        
    }

    if(attributeMappings.length > 0) {
/*~                       
                        <ConditionalSplit Name="Known_Unknown">
                            <OutputPaths>
                                <OutputPath Name="Known">
                                    <Expression>[__Operation]=="U"</Expression>
                                </OutputPath>
                                <OutputPath Name="Unknown">
                                    <Expression>[__Operation]=="I"</Expression>
                                </OutputPath>
                            </OutputPaths>
                        </ConditionalSplit>
                        <Multicast Name="Split_Known">
                            <OutputPaths> 
~*/
            for(i = 0; map = attributeMappings[i]; i++) {
/*~
                                <OutputPath Name="$map.attribute"/> 
~*/
            }
/*~
                            </OutputPaths>
                            <InputPath OutputPathName="Known_Unknown.Known" />
                        </Multicast>
~*/
        for(i = 0; map = attributeMappings[i]; i++) {
            var attributeMnemonic = map.target.match(/^(..\_...)\_.*/)[1];
            var anchorReference = attributeMnemonic + '_' + load.anchorMnemonic + '_ID';
            var inputPath = 'Split_Known.' + map.attribute;
            var mapSource = map.source;
            var mapTarget = map.target;
/*~
                        <ConditionalSplit Name="${map.attribute}$__Known_not_Null">
                            <OutputPaths>
                                <OutputPath Name="Values">
                                    <Expression>!ISNULL([$mapSource])</Expression>
                                </OutputPath>
                            </OutputPaths>
                            <InputPath OutputPathName="$inputPath" />
                        </ConditionalSplit>
~*/                    
            inputPath = map.attribute + '__Known_not_Null.Values';
            if(map.knot) {
                var knotMnemonic = map.knot.match(/^(...)\_.*/)[1];
/*~
                        <Lookup Name="${map.attribute}$__Known_Knot_Lookup" NoMatchBehavior="FailComponent" CacheMode="Full" OleDbConnectionName="$VARIABLES.TargetDatabase">
                            <ExternalTableInput Table="[$VARIABLES.TargetSchema].[${map.knot}$]" />
                            <Inputs>
                                <Column SourceColumn="$mapSource" TargetColumn="$map.knot" />
                            </Inputs>
                            <Outputs>
                                <Column SourceColumn="${knotMnemonic}$_ID" />
                            </Outputs>
                            <InputPath OutputPathName="$inputPath" />                            
                        </Lookup>
~*/                    
                inputPath = map.attribute + '__Known_Knot_Lookup.Match';
                mapSource = knotMnemonic + '_ID';
                mapTarget = attributeMnemonic + '_' + knotMnemonic + '_ID';
            }
/*~
                        <Lookup Name="${map.attribute}$__Known_Lookup" NoMatchBehavior="RedirectRowsToNoMatchOutput" CacheMode="Partial" OleDbConnectionName="$VARIABLES.TargetDatabase">
~*/
            if(map.isHistorized) {
/*~
                            <DirectInput>
                                SELECT $anchorReference, $mapTarget, ${attributeMnemonic}$_ChangedAt 
                                FROM (
                                    SELECT $anchorReference, $mapTarget, ${attributeMnemonic}$_ChangedAt,
                                        LAST_VALUE(${attributeMnemonic}$_ChangedAt) OVER (
                                            PARTITION BY $anchorReference ORDER BY ${attributeMnemonic}$_ChangedAt RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
                                        ) as Last_ChangedAt
                                    FROM
                                        [$VARIABLES.TargetSchema].[${map.attribute}$]
                                ) a WHERE ${attributeMnemonic}$_ChangedAt = Last_ChangedAt
                            </DirectInput>
~*/
            }
            else { // static attribute
/*~
                            <ExternalTableInput Table="[$VARIABLES.TargetSchema].[${map.attribute}$]" />
~*/                
            }
/*~
                            <Inputs>
                                <Column SourceColumn="$mapSource" TargetColumn="$mapTarget" />
                                <Column SourceColumn="${load.anchorMnemonic}$_ID" TargetColumn="$anchorReference" />
                            </Inputs>
                            <InputPath OutputPathName="$inputPath" />                            
                        </Lookup>
                        <OleDbDestination Name="${map.attribute}$__Known" ConnectionName="$VARIABLES.TargetDatabase" BatchSize="0" MaximumInsertCommitSize="0" FastLoadOptions="ORDER($anchorReference ASC)" KeepNulls="false" KeepIdentity="false" CheckConstraints="false" UseFastLoadIfAvailable="true" TableLock="true">
                            <ErrorHandling ErrorRowDisposition="FailComponent" TruncationRowDisposition="FailComponent" />
                            <ExternalTableOutput Table="[${VARIABLES.TargetSchema}$].[${map.attribute}$]" />
                            <InputPath OutputPathName="${map.attribute}$__Known_Lookup.NoMatch" />
                            <Columns>
                                <Column SourceColumn="${load.anchorMnemonic}$_ID" TargetColumn="$anchorReference" />
                                <Column SourceColumn="$mapSource" TargetColumn="$mapTarget" />
~*/
            var attributeMap;
            while(attributeMap = load.nextMap()) {
                if(map != attributeMap && attributeMap.target.indexOf(attributeMnemonic) == 0) {
/*~
                                <Column SourceColumn="$attributeMap.source" TargetColumn="$attributeMap.target" />
~*/                            
                }
            }
            if(metadata[0]) {
/*~
                                <Column SourceColumn="${metadata[0].source}$" TargetColumn="Metadata_${attributeMnemonic}$" />
~*/                                                        
            }
/*~                                
                            </Columns>
                        </OleDbDestination>
~*/
        }
/*~                        
                        <Multicast Name="Split_Unknown">
                            <OutputPaths> 
~*/
        for(i = 0; map = attributeMappings[i]; i++) {
/*~
                                <OutputPath Name="$map.attribute"/> 
~*/
        }
/*~
                            </OutputPaths>
                            <InputPath OutputPathName="Known_Unknown.Unknown" />
                        </Multicast>
~*/
        for(i = 0; map = attributeMappings[i]; i++) {
            var attributeMnemonic = map.target.match(/^(..\_...)\_.*/)[1];
            var inputPath = 'Split_Unknown.' + map.attribute;
            var mapSource = map.source;
            var mapTarget = map.target;
/*~
                        <ConditionalSplit Name="${map.attribute}$__Unknown_not_Null">
                            <OutputPaths>
                                <OutputPath Name="Values">
                                    <Expression>!ISNULL([$mapSource])</Expression>
                                </OutputPath>
                            </OutputPaths>
                            <InputPath OutputPathName="$inputPath" />
                        </ConditionalSplit>
~*/
            inputPath = map.attribute + '__Unknown_not_Null.Values';
            if(map.knot) {
                var knotMnemonic = map.knot.match(/^(...)\_.*/)[1];
/*~
                        <Lookup Name="${map.attribute}$__Unknown_Knot_Lookup" NoMatchBehavior="FailComponent" CacheMode="Full" OleDbConnectionName="$VARIABLES.TargetDatabase">
                            <ExternalTableInput Table="[$VARIABLES.TargetSchema].[${map.knot}$]" />
                            <Inputs>
                                <Column SourceColumn="$mapSource" TargetColumn="$map.knot" />
                            </Inputs>
                            <Outputs>
                                <Column SourceColumn="${knotMnemonic}$_ID" />
                            </Outputs>
                            <InputPath OutputPathName="$inputPath" />                            
                        </Lookup>
~*/                    
                inputPath = map.attribute + '__Unknown_Knot_Lookup.Match';
                mapSource = knotMnemonic + '_ID';
                mapTarget = attributeMnemonic + '_' + knotMnemonic + '_ID';
            }
/*~
                        <OleDbDestination Name="${map.attribute}$__Unknown" ConnectionName="$VARIABLES.TargetDatabase" BatchSize="0" MaximumInsertCommitSize="0" FastLoadOptions="ORDER(${attributeMnemonic}$_${load.anchorMnemonic}$_ID ASC)" KeepNulls="false" KeepIdentity="false" CheckConstraints="false" UseFastLoadIfAvailable="true" TableLock="true">
                            <ErrorHandling ErrorRowDisposition="FailComponent" TruncationRowDisposition="FailComponent" />
                            <ExternalTableOutput Table="[${VARIABLES.TargetSchema}$].[${map.attribute}$]" />
                            <InputPath OutputPathName="$inputPath" />
                            <Columns>
                                <Column SourceColumn="${load.anchorMnemonic}$_ID" TargetColumn="${attributeMnemonic}$_${load.anchorMnemonic}$_ID" />
                                <Column SourceColumn="$mapSource" TargetColumn="$mapTarget" />
~*/
            var attributeMap;
            while(attributeMap = load.nextMap()) {
                if(map != attributeMap && attributeMap.target.indexOf(attributeMnemonic) == 0) {
/*~
                                <Column SourceColumn="$attributeMap.source" TargetColumn="$attributeMap.target" />
~*/                            
                }
            }
            if(metadata[0]) {
/*~
                                <Column SourceColumn="${metadata[0].source}$" TargetColumn="Metadata_${attributeMnemonic}$" />
~*/                                                        
            }
/*~                                
                            </Columns>
                        </OleDbDestination>
~*/
        }
    } // end of if attributes exist
/*~
                    </Transformations>
                </Dataflow>
~*/
    if(attributeMappings.length > 0) {
/*~
                <ExecuteSQL Name="Enable triggers and constraints" ConnectionName="$VARIABLES.TargetDatabase">
                    <DirectInput>
~*/
        for(i = 0; map = attributeMappings[i]; i++) {
/*~
                    ENABLE TRIGGER ALL ON [${VARIABLES.TargetSchema}$].[${map.attribute}$];
                    ALTER TABLE [${VARIABLES.TargetSchema}$].[${map.attribute}$] WITH NOCHECK CHECK CONSTRAINT ALL;
~*/
        }
/*~
                    </DirectInput>
                </ExecuteSQL>
~*/        
    }
    if(sql = load.sql ? load.sql.after : null) {
/*~
                <ExecuteSQL Name="SQL After" ConnectionName="$VARIABLES.SourceDatabase">
                    <DirectInput>$sql._sql</DirectInput>
                </ExecuteSQL>
~*/
    }
/*~
            </Tasks>
        </Package>
~*/
}
/*~
    </Packages>
</Biml>
~*/
