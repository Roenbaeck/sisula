-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
-- Knots are unfolded when using equivalence.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- TYP_Type table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.TYP_Type', 'U') IS NULL
CREATE TABLE [metadata].[TYP_Type] (
    TYP_ID tinyint not null,
    TYP_Type varchar(42) not null,
    constraint pkTYP_Type primary key (
        TYP_ID asc
    ),
    constraint uqTYP_Type unique (
        TYP_Type
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- EST_ExecutionStatus table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.EST_ExecutionStatus', 'U') IS NULL
CREATE TABLE [metadata].[EST_ExecutionStatus] (
    EST_ID tinyint not null,
    EST_ExecutionStatus varchar(42) not null,
    constraint pkEST_ExecutionStatus primary key (
        EST_ID asc
    ),
    constraint uqEST_ExecutionStatus unique (
        EST_ExecutionStatus
    )
);
GO
-- ANCHORS AND ATTRIBUTES ---------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
-- Attributes are used to store values for properties of entities.
-- Attributes are mutable, their values may change over one or more types of time.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
-- Anchors may have zero or more adjoined attributes.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- JB_Job table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JB_Job', 'U') IS NULL
CREATE TABLE [metadata].[JB_Job] (
    JB_ID int IDENTITY(1,1) not null,
    JB_Dummy bit null,
    constraint pkJB_Job primary key (
        JB_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- JB_STA_Job_Start table (on JB_Job)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JB_STA_Job_Start', 'U') IS NULL
CREATE TABLE [metadata].[JB_STA_Job_Start] (
    JB_STA_JB_ID int not null,
    JB_STA_Job_Start datetime not null,
    constraint fkJB_STA_Job_Start foreign key (
        JB_STA_JB_ID
    ) references [metadata].[JB_Job](JB_ID),
    constraint pkJB_STA_Job_Start primary key (
        JB_STA_JB_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- JB_END_Job_End table (on JB_Job)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JB_END_Job_End', 'U') IS NULL
CREATE TABLE [metadata].[JB_END_Job_End] (
    JB_END_JB_ID int not null,
    JB_END_Job_End datetime not null,
    constraint fkJB_END_Job_End foreign key (
        JB_END_JB_ID
    ) references [metadata].[JB_Job](JB_ID),
    constraint pkJB_END_Job_End primary key (
        JB_END_JB_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- JB_NAM_Job_Name table (on JB_Job)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JB_NAM_Job_Name', 'U') IS NULL
CREATE TABLE [metadata].[JB_NAM_Job_Name] (
    JB_NAM_JB_ID int not null,
    JB_NAM_Job_Name varchar(255) not null,
    constraint fkJB_NAM_Job_Name foreign key (
        JB_NAM_JB_ID
    ) references [metadata].[JB_Job](JB_ID),
    constraint pkJB_NAM_Job_Name primary key (
        JB_NAM_JB_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- SR_Source table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.SR_Source', 'U') IS NULL
CREATE TABLE [metadata].[SR_Source] (
    SR_ID int IDENTITY(1,1) not null,
    SR_Dummy bit null,
    constraint pkSR_Source primary key (
        SR_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- SR_NAM_Source_Name table (on SR_Source)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.SR_NAM_Source_Name', 'U') IS NULL
CREATE TABLE [metadata].[SR_NAM_Source_Name] (
    SR_NAM_SR_ID int not null,
    SR_NAM_Source_Name varchar(2000) not null,
    constraint fkSR_NAM_Source_Name foreign key (
        SR_NAM_SR_ID
    ) references [metadata].[SR_Source](SR_ID),
    constraint pkSR_NAM_Source_Name primary key (
        SR_NAM_SR_ID asc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SR_CFG_Source_Configuration table (on SR_Source)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.SR_CFG_Source_Configuration', 'U') IS NULL
CREATE TABLE [metadata].[SR_CFG_Source_Configuration] (
    SR_CFG_SR_ID int not null,
    SR_CFG_Source_Configuration xml not null,
    SR_CFG_Checksum as cast(HashBytes('MD5', cast(SR_CFG_Source_Configuration as varbinary(max))) as varbinary(16)) PERSISTED,
    SR_CFG_ChangedAt datetime not null,
    constraint fkSR_CFG_Source_Configuration foreign key (
        SR_CFG_SR_ID
    ) references [metadata].[SR_Source](SR_ID),
    constraint pkSR_CFG_Source_Configuration primary key (
        SR_CFG_SR_ID asc,
        SR_CFG_ChangedAt desc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- CO_Container table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CO_Container', 'U') IS NULL
CREATE TABLE [metadata].[CO_Container] (
    CO_ID int IDENTITY(1,1) not null,
    CO_Dummy bit null,
    constraint pkCO_Container primary key (
        CO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- CO_NAM_Container_Name table (on CO_Container)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CO_NAM_Container_Name', 'U') IS NULL
CREATE TABLE [metadata].[CO_NAM_Container_Name] (
    CO_NAM_CO_ID int not null,
    CO_NAM_Container_Name varchar(2000) not null,
    constraint fkCO_NAM_Container_Name foreign key (
        CO_NAM_CO_ID
    ) references [metadata].[CO_Container](CO_ID),
    constraint pkCO_NAM_Container_Name primary key (
        CO_NAM_CO_ID asc
    )
);
GO
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- CO_TYP_Container_Type table (on CO_Container)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CO_TYP_Container_Type', 'U') IS NULL
CREATE TABLE [metadata].[CO_TYP_Container_Type] (
    CO_TYP_CO_ID int not null,
    CO_TYP_TYP_ID tinyint not null,
    constraint fk_A_CO_TYP_Container_Type foreign key (
        CO_TYP_CO_ID
    ) references [metadata].[CO_Container](CO_ID),
    constraint fk_K_CO_TYP_Container_Type foreign key (
        CO_TYP_TYP_ID
    ) references [metadata].[TYP_Type](TYP_ID),
    constraint pkCO_TYP_Container_Type primary key (
        CO_TYP_CO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- CO_PTH_Container_Path table (on CO_Container)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CO_PTH_Container_Path', 'U') IS NULL
CREATE TABLE [metadata].[CO_PTH_Container_Path] (
    CO_PTH_CO_ID int not null,
    CO_PTH_Container_Path varchar(2000) not null,
    constraint fkCO_PTH_Container_Path foreign key (
        CO_PTH_CO_ID
    ) references [metadata].[CO_Container](CO_ID),
    constraint pkCO_PTH_Container_Path primary key (
        CO_PTH_CO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- CO_DSC_Container_Discovered table (on CO_Container)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CO_DSC_Container_Discovered', 'U') IS NULL
CREATE TABLE [metadata].[CO_DSC_Container_Discovered] (
    CO_DSC_CO_ID int not null,
    CO_DSC_Container_Discovered datetime not null,
    constraint fkCO_DSC_Container_Discovered foreign key (
        CO_DSC_CO_ID
    ) references [metadata].[CO_Container](CO_ID),
    constraint pkCO_DSC_Container_Discovered primary key (
        CO_DSC_CO_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- WO_Work table (with 11 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_Work', 'U') IS NULL
CREATE TABLE [metadata].[WO_Work] (
    WO_ID int IDENTITY(1,1) not null,
    WO_Dummy bit null,
    constraint pkWO_Work primary key (
        WO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_STA_Work_Start table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_STA_Work_Start', 'U') IS NULL
CREATE TABLE [metadata].[WO_STA_Work_Start] (
    WO_STA_WO_ID int not null,
    WO_STA_Work_Start datetime not null,
    constraint fkWO_STA_Work_Start foreign key (
        WO_STA_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_STA_Work_Start primary key (
        WO_STA_WO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_END_Work_End table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_END_Work_End', 'U') IS NULL
CREATE TABLE [metadata].[WO_END_Work_End] (
    WO_END_WO_ID int not null,
    WO_END_Work_End datetime not null,
    constraint fkWO_END_Work_End foreign key (
        WO_END_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_END_Work_End primary key (
        WO_END_WO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_UPD_Work_Updates table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_UPD_Work_Updates', 'U') IS NULL
CREATE TABLE [metadata].[WO_UPD_Work_Updates] (
    WO_UPD_WO_ID int not null,
    WO_UPD_Work_Updates int not null,
    constraint fkWO_UPD_Work_Updates foreign key (
        WO_UPD_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_UPD_Work_Updates primary key (
        WO_UPD_WO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_NAM_Work_Name table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_NAM_Work_Name', 'U') IS NULL
CREATE TABLE [metadata].[WO_NAM_Work_Name] (
    WO_NAM_WO_ID int not null,
    WO_NAM_Work_Name varchar(255) not null,
    constraint fkWO_NAM_Work_Name foreign key (
        WO_NAM_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_NAM_Work_Name primary key (
        WO_NAM_WO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_INS_Work_Inserts table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_INS_Work_Inserts', 'U') IS NULL
CREATE TABLE [metadata].[WO_INS_Work_Inserts] (
    WO_INS_WO_ID int not null,
    WO_INS_Work_Inserts int not null,
    constraint fkWO_INS_Work_Inserts foreign key (
        WO_INS_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_INS_Work_Inserts primary key (
        WO_INS_WO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_DEL_Work_Deletes table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_DEL_Work_Deletes', 'U') IS NULL
CREATE TABLE [metadata].[WO_DEL_Work_Deletes] (
    WO_DEL_WO_ID int not null,
    WO_DEL_Work_Deletes int not null,
    constraint fkWO_DEL_Work_Deletes foreign key (
        WO_DEL_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_DEL_Work_Deletes primary key (
        WO_DEL_WO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_USR_Work_InvocationUser table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_USR_Work_InvocationUser', 'U') IS NULL
CREATE TABLE [metadata].[WO_USR_Work_InvocationUser] (
    WO_USR_WO_ID int not null,
    WO_USR_Work_InvocationUser varchar(555) not null,
    constraint fkWO_USR_Work_InvocationUser foreign key (
        WO_USR_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_USR_Work_InvocationUser primary key (
        WO_USR_WO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_ROL_Work_InvocationRole table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_ROL_Work_InvocationRole', 'U') IS NULL
CREATE TABLE [metadata].[WO_ROL_Work_InvocationRole] (
    WO_ROL_WO_ID int not null,
    WO_ROL_Work_InvocationRole varchar(42) not null,
    constraint fkWO_ROL_Work_InvocationRole foreign key (
        WO_ROL_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_ROL_Work_InvocationRole primary key (
        WO_ROL_WO_ID asc
    )
);
GO
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- WO_EST_Work_ExecutionStatus table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_EST_Work_ExecutionStatus', 'U') IS NULL
CREATE TABLE [metadata].[WO_EST_Work_ExecutionStatus] (
    WO_EST_WO_ID int not null,
    WO_EST_EST_ID tinyint not null,
    WO_EST_ChangedAt datetime not null,
    constraint fk_A_WO_EST_Work_ExecutionStatus foreign key (
        WO_EST_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint fk_K_WO_EST_Work_ExecutionStatus foreign key (
        WO_EST_EST_ID
    ) references [metadata].[EST_ExecutionStatus](EST_ID),
    constraint pkWO_EST_Work_ExecutionStatus primary key (
        WO_EST_WO_ID asc,
        WO_EST_ChangedAt desc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_ERL_Work_ErrorLine table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_ERL_Work_ErrorLine', 'U') IS NULL
CREATE TABLE [metadata].[WO_ERL_Work_ErrorLine] (
    WO_ERL_WO_ID int not null,
    WO_ERL_Work_ErrorLine int not null,
    constraint fkWO_ERL_Work_ErrorLine foreign key (
        WO_ERL_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_ERL_Work_ErrorLine primary key (
        WO_ERL_WO_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WO_ERM_Work_ErrorMessage table (on WO_Work)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_ERM_Work_ErrorMessage', 'U') IS NULL
CREATE TABLE [metadata].[WO_ERM_Work_ErrorMessage] (
    WO_ERM_WO_ID int not null,
    WO_ERM_Work_ErrorMessage varchar(555) not null,
    constraint fkWO_ERM_Work_ErrorMessage foreign key (
        WO_ERM_WO_ID
    ) references [metadata].[WO_Work](WO_ID),
    constraint pkWO_ERM_Work_ErrorMessage primary key (
        WO_ERM_WO_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- WF_Workflow table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WF_Workflow', 'U') IS NULL
CREATE TABLE [metadata].[WF_Workflow] (
    WF_ID int IDENTITY(1,1) not null,
    WF_Dummy bit null,
    constraint pkWF_Workflow primary key (
        WF_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- WF_NAM_Workflow_Name table (on WF_Workflow)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WF_NAM_Workflow_Name', 'U') IS NULL
CREATE TABLE [metadata].[WF_NAM_Workflow_Name] (
    WF_NAM_WF_ID int not null,
    WF_NAM_Workflow_Name varchar(255) not null,
    constraint fkWF_NAM_Workflow_Name foreign key (
        WF_NAM_WF_ID
    ) references [metadata].[WF_Workflow](WF_ID),
    constraint pkWF_NAM_Workflow_Name primary key (
        WF_NAM_WF_ID asc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- WF_CFG_Workflow_Configuration table (on WF_Workflow)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WF_CFG_Workflow_Configuration', 'U') IS NULL
CREATE TABLE [metadata].[WF_CFG_Workflow_Configuration] (
    WF_CFG_WF_ID int not null,
    WF_CFG_Workflow_Configuration xml not null,
    WF_CFG_Checksum as cast(HashBytes('MD5', cast(WF_CFG_Workflow_Configuration as varbinary(max))) as varbinary(16)) PERSISTED,
    WF_CFG_ChangedAt datetime not null,
    constraint fkWF_CFG_Workflow_Configuration foreign key (
        WF_CFG_WF_ID
    ) references [metadata].[WF_Workflow](WF_ID),
    constraint pkWF_CFG_Workflow_Configuration primary key (
        WF_CFG_WF_ID asc,
        WF_CFG_ChangedAt desc
    )
);
GO
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- Static tie table ---------------------------------------------------------------------------------------------------
-- JB_of_WO_part table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JB_of_WO_part', 'U') IS NULL
CREATE TABLE [metadata].[JB_of_WO_part] (
    JB_ID_of int not null, 
    WO_ID_part int not null, 
    constraint JB_of_WO_part_fkJB_of foreign key (
        JB_ID_of
    ) references [metadata].[JB_Job](JB_ID), 
    constraint JB_of_WO_part_fkWO_part foreign key (
        WO_ID_part
    ) references [metadata].[WO_Work](WO_ID), 
    constraint pkJB_of_WO_part primary key (
        JB_ID_of asc,
        WO_ID_part asc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- JB_formed_WF_from table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.JB_formed_WF_from', 'U') IS NULL
CREATE TABLE [metadata].[JB_formed_WF_from] (
    JB_ID_formed int not null, 
    WF_ID_from int not null, 
    constraint JB_formed_WF_from_fkJB_formed foreign key (
        JB_ID_formed
    ) references [metadata].[JB_Job](JB_ID), 
    constraint JB_formed_WF_from_fkWF_from foreign key (
        WF_ID_from
    ) references [metadata].[WF_Workflow](WF_ID), 
    constraint pkJB_formed_WF_from primary key (
        JB_ID_formed asc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- WO_formed_SR_from table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.WO_formed_SR_from', 'U') IS NULL
CREATE TABLE [metadata].[WO_formed_SR_from] (
    WO_ID_formed int not null, 
    SR_ID_from int not null, 
    constraint WO_formed_SR_from_fkWO_formed foreign key (
        WO_ID_formed
    ) references [metadata].[WO_Work](WO_ID), 
    constraint WO_formed_SR_from_fkSR_from foreign key (
        SR_ID_from
    ) references [metadata].[SR_Source](SR_ID), 
    constraint pkWO_formed_SR_from primary key (
        WO_ID_formed asc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- CO_target_CO_source_WO_involves table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.CO_target_CO_source_WO_involves', 'U') IS NULL
CREATE TABLE [metadata].[CO_target_CO_source_WO_involves] (
    CO_ID_target int not null, 
    CO_ID_source int not null, 
    WO_ID_involves int not null, 
    constraint CO_target_CO_source_WO_involves_fkCO_target foreign key (
        CO_ID_target
    ) references [metadata].[CO_Container](CO_ID), 
    constraint CO_target_CO_source_WO_involves_fkCO_source foreign key (
        CO_ID_source
    ) references [metadata].[CO_Container](CO_ID), 
    constraint CO_target_CO_source_WO_involves_fkWO_involves foreign key (
        WO_ID_involves
    ) references [metadata].[WO_Work](WO_ID), 
    constraint pkCO_target_CO_source_WO_involves primary key (
        CO_ID_target asc,
        CO_ID_source asc
    )
);
GO
-- KNOT EQUIVALENCE VIEWS ---------------------------------------------------------------------------------------------
--
-- Equivalence views combine the identity and equivalent parts of a knot into a single view, making
-- it look and behave like a regular knot. They also make it possible to retrieve data for only the
-- given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- ATTRIBUTE EQUIVALENCE VIEWS ----------------------------------------------------------------------------------------
--
-- Equivalence views of attributes make it possible to retrieve data for only the given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- ATTRIBUTE RESTATEMENT CONSTRAINTS ----------------------------------------------------------------------------------
--
-- Attributes may be prevented from storing restatements.
-- A restatement is when the same value occurs for two adjacent points
-- in changing time.
--
-- returns 1 for at least one equal surrounding value, 0 for different surrounding values
--
-- @id the identity of the anchored entity
-- @eq the equivalent (when applicable)
-- @value the value of the attribute
-- @changed the point in time from which this value shall represent a change
--
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfSR_CFG_Source_Configuration restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcSR_CFG_Source_Configuration restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rfSR_CFG_Source_Configuration', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rfSR_CFG_Source_Configuration] (
        @id int,
        @value varbinary(16),
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.SR_CFG_Checksum
                    FROM
                        [metadata].[SR_CFG_Source_Configuration] pre
                    WHERE
                        pre.SR_CFG_SR_ID = @id
                    AND
                        pre.SR_CFG_ChangedAt < @changed
                    ORDER BY
                        pre.SR_CFG_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.SR_CFG_Checksum
                    FROM
                        [metadata].[SR_CFG_Source_Configuration] fol
                    WHERE
                        fol.SR_CFG_SR_ID = @id
                    AND
                        fol.SR_CFG_ChangedAt > @changed
                    ORDER BY
                        fol.SR_CFG_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [metadata].[SR_CFG_Source_Configuration]
    ADD CONSTRAINT [rcSR_CFG_Source_Configuration] CHECK (
        [metadata].[rfSR_CFG_Source_Configuration] (
            SR_CFG_SR_ID,
            SR_CFG_Checksum,
            SR_CFG_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfWO_EST_Work_ExecutionStatus restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcWO_EST_Work_ExecutionStatus restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rfWO_EST_Work_ExecutionStatus', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rfWO_EST_Work_ExecutionStatus] (
        @id int,
        @value tinyint,
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.WO_EST_EST_ID
                    FROM
                        [metadata].[WO_EST_Work_ExecutionStatus] pre
                    WHERE
                        pre.WO_EST_WO_ID = @id
                    AND
                        pre.WO_EST_ChangedAt < @changed
                    ORDER BY
                        pre.WO_EST_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.WO_EST_EST_ID
                    FROM
                        [metadata].[WO_EST_Work_ExecutionStatus] fol
                    WHERE
                        fol.WO_EST_WO_ID = @id
                    AND
                        fol.WO_EST_ChangedAt > @changed
                    ORDER BY
                        fol.WO_EST_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [metadata].[WO_EST_Work_ExecutionStatus]
    ADD CONSTRAINT [rcWO_EST_Work_ExecutionStatus] CHECK (
        [metadata].[rfWO_EST_Work_ExecutionStatus] (
            WO_EST_WO_ID,
            WO_EST_EST_ID,
            WO_EST_ChangedAt
        ) = 0
    );
END
GO
-- Restatement Finder Function and Constraint -------------------------------------------------------------------------
-- rfWF_CFG_Workflow_Configuration restatement finder, also used by the insert and update triggers for idempotent attributes
-- rcWF_CFG_Workflow_Configuration restatement constraint (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rfWF_CFG_Workflow_Configuration', 'FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rfWF_CFG_Workflow_Configuration] (
        @id int,
        @value varbinary(16),
        @changed datetime
    )
    RETURNS tinyint AS
    BEGIN RETURN (
        CASE WHEN EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        pre.WF_CFG_Checksum
                    FROM
                        [metadata].[WF_CFG_Workflow_Configuration] pre
                    WHERE
                        pre.WF_CFG_WF_ID = @id
                    AND
                        pre.WF_CFG_ChangedAt < @changed
                    ORDER BY
                        pre.WF_CFG_ChangedAt DESC
                )
        ) OR EXISTS (
            SELECT
                @value 
            WHERE
                @value = (
                    SELECT TOP 1
                        fol.WF_CFG_Checksum
                    FROM
                        [metadata].[WF_CFG_Workflow_Configuration] fol
                    WHERE
                        fol.WF_CFG_WF_ID = @id
                    AND
                        fol.WF_CFG_ChangedAt > @changed
                    ORDER BY
                        fol.WF_CFG_ChangedAt ASC
                )
        )
        THEN 1
        ELSE 0
        END
    );
    END
    ');
    ALTER TABLE [metadata].[WF_CFG_Workflow_Configuration]
    ADD CONSTRAINT [rcWF_CFG_Workflow_Configuration] CHECK (
        [metadata].[rfWF_CFG_Workflow_Configuration] (
            WF_CFG_WF_ID,
            WF_CFG_Checksum,
            WF_CFG_ChangedAt
        ) = 0
    );
END
GO
-- KEY GENERATORS -----------------------------------------------------------------------------------------------------
--
-- These stored procedures can be used to generate identities of entities.
-- Corresponding anchors must have an incrementing identity column.
--
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kJB_Job identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.kJB_Job', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [metadata].[kJB_Job] (
        @requestedNumberOfIdentities bigint
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [metadata].[JB_Job] (
                JB_Dummy
            )
            OUTPUT
                inserted.JB_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kSR_Source identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.kSR_Source', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [metadata].[kSR_Source] (
        @requestedNumberOfIdentities bigint
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [metadata].[SR_Source] (
                SR_Dummy
            )
            OUTPUT
                inserted.SR_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kCO_Container identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.kCO_Container', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [metadata].[kCO_Container] (
        @requestedNumberOfIdentities bigint
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [metadata].[CO_Container] (
                CO_Dummy
            )
            OUTPUT
                inserted.CO_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kWO_Work identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.kWO_Work', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [metadata].[kWO_Work] (
        @requestedNumberOfIdentities bigint
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [metadata].[WO_Work] (
                WO_Dummy
            )
            OUTPUT
                inserted.WO_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kWF_Workflow identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.kWF_Workflow', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [metadata].[kWF_Workflow] (
        @requestedNumberOfIdentities bigint
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [metadata].[WF_Workflow] (
                WF_Dummy
            )
            OUTPUT
                inserted.WF_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute table to the given
-- point in changing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time.
--
-- @changingTimepoint the point in changing time to rewind to
--
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSR_CFG_Source_Configuration rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rSR_CFG_Source_Configuration','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rSR_CFG_Source_Configuration] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SR_CFG_SR_ID,
        SR_CFG_Checksum,
        SR_CFG_Source_Configuration,
        SR_CFG_ChangedAt
    FROM
        [metadata].[SR_CFG_Source_Configuration]
    WHERE
        SR_CFG_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rWO_EST_Work_ExecutionStatus rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rWO_EST_Work_ExecutionStatus','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rWO_EST_Work_ExecutionStatus] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        WO_EST_WO_ID,
        WO_EST_EST_ID,
        WO_EST_ChangedAt
    FROM
        [metadata].[WO_EST_Work_ExecutionStatus]
    WHERE
        WO_EST_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rWF_CFG_Workflow_Configuration rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.rWF_CFG_Workflow_Configuration','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [metadata].[rWF_CFG_Workflow_Configuration] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        WF_CFG_WF_ID,
        WF_CFG_Checksum,
        WF_CFG_Workflow_Configuration,
        WF_CFG_ChangedAt
    FROM
        [metadata].[WF_CFG_Workflow_Configuration]
    WHERE
        WF_CFG_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each anchor. There are four types of perspectives: latest,
-- point-in-time, difference, and now. They also denormalize the anchor, its attributes,
-- and referenced knots from sixth to third normal form.
--
-- The latest perspective shows the latest available information for each anchor.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints, and for
-- changes in all or a selection of attributes.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
-- @selection a list of mnemonics for tracked attributes, ie 'MNE MON ICS', or null for all
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-e perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dJB_Job', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dJB_Job];
IF Object_ID('metadata.nJB_Job', 'V') IS NOT NULL
DROP VIEW [metadata].[nJB_Job];
IF Object_ID('metadata.pJB_Job', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pJB_Job];
IF Object_ID('metadata.lJB_Job', 'V') IS NOT NULL
DROP VIEW [metadata].[lJB_Job];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lJB_Job viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lJB_Job] WITH SCHEMABINDING AS
SELECT
    [JB].JB_ID,
    [STA].JB_STA_JB_ID,
    [STA].JB_STA_Job_Start,
    [END].JB_END_JB_ID,
    [END].JB_END_Job_End,
    [NAM].JB_NAM_JB_ID,
    [NAM].JB_NAM_Job_Name
FROM
    [metadata].[JB_Job] [JB]
LEFT JOIN
    [metadata].[JB_STA_Job_Start] [STA]
ON
    [STA].JB_STA_JB_ID = [JB].JB_ID
LEFT JOIN
    [metadata].[JB_END_Job_End] [END]
ON
    [END].JB_END_JB_ID = [JB].JB_ID
LEFT JOIN
    [metadata].[JB_NAM_Job_Name] [NAM]
ON
    [NAM].JB_NAM_JB_ID = [JB].JB_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pJB_Job viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pJB_Job] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [JB].JB_ID,
    [STA].JB_STA_JB_ID,
    [STA].JB_STA_Job_Start,
    [END].JB_END_JB_ID,
    [END].JB_END_Job_End,
    [NAM].JB_NAM_JB_ID,
    [NAM].JB_NAM_Job_Name
FROM
    [metadata].[JB_Job] [JB]
LEFT JOIN
    [metadata].[JB_STA_Job_Start] [STA]
ON
    [STA].JB_STA_JB_ID = [JB].JB_ID
LEFT JOIN
    [metadata].[JB_END_Job_End] [END]
ON
    [END].JB_END_JB_ID = [JB].JB_ID
LEFT JOIN
    [metadata].[JB_NAM_Job_Name] [NAM]
ON
    [NAM].JB_NAM_JB_ID = [JB].JB_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nJB_Job viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nJB_Job]
AS
SELECT
    *
FROM
    [metadata].[pJB_Job](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dSR_Source', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dSR_Source];
IF Object_ID('metadata.nSR_Source', 'V') IS NOT NULL
DROP VIEW [metadata].[nSR_Source];
IF Object_ID('metadata.pSR_Source', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pSR_Source];
IF Object_ID('metadata.lSR_Source', 'V') IS NOT NULL
DROP VIEW [metadata].[lSR_Source];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSR_Source viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lSR_Source] WITH SCHEMABINDING AS
SELECT
    [SR].SR_ID,
    [NAM].SR_NAM_SR_ID,
    [NAM].SR_NAM_Source_Name,
    [CFG].SR_CFG_SR_ID,
    [CFG].SR_CFG_ChangedAt,
    [CFG].SR_CFG_Checksum,
    [CFG].SR_CFG_Source_Configuration
FROM
    [metadata].[SR_Source] [SR]
LEFT JOIN
    [metadata].[SR_NAM_Source_Name] [NAM]
ON
    [NAM].SR_NAM_SR_ID = [SR].SR_ID
LEFT JOIN
    [metadata].[SR_CFG_Source_Configuration] [CFG]
ON
    [CFG].SR_CFG_SR_ID = [SR].SR_ID
AND
    [CFG].SR_CFG_ChangedAt = (
        SELECT
            max(sub.SR_CFG_ChangedAt)
        FROM
            [metadata].[SR_CFG_Source_Configuration] sub
        WHERE
            sub.SR_CFG_SR_ID = [SR].SR_ID
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSR_Source viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pSR_Source] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [SR].SR_ID,
    [NAM].SR_NAM_SR_ID,
    [NAM].SR_NAM_Source_Name,
    [CFG].SR_CFG_SR_ID,
    [CFG].SR_CFG_ChangedAt,
    [CFG].SR_CFG_Checksum,
    [CFG].SR_CFG_Source_Configuration
FROM
    [metadata].[SR_Source] [SR]
LEFT JOIN
    [metadata].[SR_NAM_Source_Name] [NAM]
ON
    [NAM].SR_NAM_SR_ID = [SR].SR_ID
LEFT JOIN
    [metadata].[rSR_CFG_Source_Configuration](@changingTimepoint) [CFG]
ON
    [CFG].SR_CFG_SR_ID = [SR].SR_ID
AND
    [CFG].SR_CFG_ChangedAt = (
        SELECT
            max(sub.SR_CFG_ChangedAt)
        FROM
            [metadata].[rSR_CFG_Source_Configuration](@changingTimepoint) sub
        WHERE
            sub.SR_CFG_SR_ID = [SR].SR_ID
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSR_Source viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nSR_Source]
AS
SELECT
    *
FROM
    [metadata].[pSR_Source](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dSR_Source showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[dSR_Source] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pSR].*
FROM (
    SELECT DISTINCT
        SR_CFG_SR_ID AS SR_ID,
        SR_CFG_ChangedAt AS inspectedTimepoint,
        'CFG' AS mnemonic
    FROM
        [metadata].[SR_CFG_Source_Configuration]
    WHERE
        (@selection is null OR @selection like '%CFG%')
    AND
        SR_CFG_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [metadata].[pSR_Source](timepoints.inspectedTimepoint) [pSR]
WHERE
    [pSR].SR_ID = timepoints.SR_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dCO_Container', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dCO_Container];
IF Object_ID('metadata.nCO_Container', 'V') IS NOT NULL
DROP VIEW [metadata].[nCO_Container];
IF Object_ID('metadata.pCO_Container', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pCO_Container];
IF Object_ID('metadata.lCO_Container', 'V') IS NOT NULL
DROP VIEW [metadata].[lCO_Container];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lCO_Container viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lCO_Container] WITH SCHEMABINDING AS
SELECT
    [CO].CO_ID,
    [NAM].CO_NAM_CO_ID,
    [NAM].CO_NAM_Container_Name,
    [TYP].CO_TYP_CO_ID,
    [kTYP].TYP_Type AS CO_TYP_TYP_Type,
    [TYP].CO_TYP_TYP_ID,
    [PTH].CO_PTH_CO_ID,
    [PTH].CO_PTH_Container_Path,
    [DSC].CO_DSC_CO_ID,
    [DSC].CO_DSC_Container_Discovered
FROM
    [metadata].[CO_Container] [CO]
LEFT JOIN
    [metadata].[CO_NAM_Container_Name] [NAM]
ON
    [NAM].CO_NAM_CO_ID = [CO].CO_ID
LEFT JOIN
    [metadata].[CO_TYP_Container_Type] [TYP]
ON
    [TYP].CO_TYP_CO_ID = [CO].CO_ID
LEFT JOIN
    [metadata].[TYP_Type] [kTYP]
ON
    [kTYP].TYP_ID = [TYP].CO_TYP_TYP_ID
LEFT JOIN
    [metadata].[CO_PTH_Container_Path] [PTH]
ON
    [PTH].CO_PTH_CO_ID = [CO].CO_ID
LEFT JOIN
    [metadata].[CO_DSC_Container_Discovered] [DSC]
ON
    [DSC].CO_DSC_CO_ID = [CO].CO_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pCO_Container viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pCO_Container] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [CO].CO_ID,
    [NAM].CO_NAM_CO_ID,
    [NAM].CO_NAM_Container_Name,
    [TYP].CO_TYP_CO_ID,
    [kTYP].TYP_Type AS CO_TYP_TYP_Type,
    [TYP].CO_TYP_TYP_ID,
    [PTH].CO_PTH_CO_ID,
    [PTH].CO_PTH_Container_Path,
    [DSC].CO_DSC_CO_ID,
    [DSC].CO_DSC_Container_Discovered
FROM
    [metadata].[CO_Container] [CO]
LEFT JOIN
    [metadata].[CO_NAM_Container_Name] [NAM]
ON
    [NAM].CO_NAM_CO_ID = [CO].CO_ID
LEFT JOIN
    [metadata].[CO_TYP_Container_Type] [TYP]
ON
    [TYP].CO_TYP_CO_ID = [CO].CO_ID
LEFT JOIN
    [metadata].[TYP_Type] [kTYP]
ON
    [kTYP].TYP_ID = [TYP].CO_TYP_TYP_ID
LEFT JOIN
    [metadata].[CO_PTH_Container_Path] [PTH]
ON
    [PTH].CO_PTH_CO_ID = [CO].CO_ID
LEFT JOIN
    [metadata].[CO_DSC_Container_Discovered] [DSC]
ON
    [DSC].CO_DSC_CO_ID = [CO].CO_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nCO_Container viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nCO_Container]
AS
SELECT
    *
FROM
    [metadata].[pCO_Container](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dWO_Work', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dWO_Work];
IF Object_ID('metadata.nWO_Work', 'V') IS NOT NULL
DROP VIEW [metadata].[nWO_Work];
IF Object_ID('metadata.pWO_Work', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pWO_Work];
IF Object_ID('metadata.lWO_Work', 'V') IS NOT NULL
DROP VIEW [metadata].[lWO_Work];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lWO_Work viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lWO_Work] WITH SCHEMABINDING AS
SELECT
    [WO].WO_ID,
    [STA].WO_STA_WO_ID,
    [STA].WO_STA_Work_Start,
    [END].WO_END_WO_ID,
    [END].WO_END_Work_End,
    [UPD].WO_UPD_WO_ID,
    [UPD].WO_UPD_Work_Updates,
    [NAM].WO_NAM_WO_ID,
    [NAM].WO_NAM_Work_Name,
    [INS].WO_INS_WO_ID,
    [INS].WO_INS_Work_Inserts,
    [DEL].WO_DEL_WO_ID,
    [DEL].WO_DEL_Work_Deletes,
    [USR].WO_USR_WO_ID,
    [USR].WO_USR_Work_InvocationUser,
    [ROL].WO_ROL_WO_ID,
    [ROL].WO_ROL_Work_InvocationRole,
    [EST].WO_EST_WO_ID,
    [EST].WO_EST_ChangedAt,
    [kEST].EST_ExecutionStatus AS WO_EST_EST_ExecutionStatus,
    [EST].WO_EST_EST_ID,
    [ERL].WO_ERL_WO_ID,
    [ERL].WO_ERL_Work_ErrorLine,
    [ERM].WO_ERM_WO_ID,
    [ERM].WO_ERM_Work_ErrorMessage
FROM
    [metadata].[WO_Work] [WO]
LEFT JOIN
    [metadata].[WO_STA_Work_Start] [STA]
ON
    [STA].WO_STA_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_END_Work_End] [END]
ON
    [END].WO_END_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_UPD_Work_Updates] [UPD]
ON
    [UPD].WO_UPD_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_NAM_Work_Name] [NAM]
ON
    [NAM].WO_NAM_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_INS_Work_Inserts] [INS]
ON
    [INS].WO_INS_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_DEL_Work_Deletes] [DEL]
ON
    [DEL].WO_DEL_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_USR_Work_InvocationUser] [USR]
ON
    [USR].WO_USR_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_ROL_Work_InvocationRole] [ROL]
ON
    [ROL].WO_ROL_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_EST_Work_ExecutionStatus] [EST]
ON
    [EST].WO_EST_WO_ID = [WO].WO_ID
AND
    [EST].WO_EST_ChangedAt = (
        SELECT
            max(sub.WO_EST_ChangedAt)
        FROM
            [metadata].[WO_EST_Work_ExecutionStatus] sub
        WHERE
            sub.WO_EST_WO_ID = [WO].WO_ID
   )
LEFT JOIN
    [metadata].[EST_ExecutionStatus] [kEST]
ON
    [kEST].EST_ID = [EST].WO_EST_EST_ID
LEFT JOIN
    [metadata].[WO_ERL_Work_ErrorLine] [ERL]
ON
    [ERL].WO_ERL_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_ERM_Work_ErrorMessage] [ERM]
ON
    [ERM].WO_ERM_WO_ID = [WO].WO_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pWO_Work viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pWO_Work] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [WO].WO_ID,
    [STA].WO_STA_WO_ID,
    [STA].WO_STA_Work_Start,
    [END].WO_END_WO_ID,
    [END].WO_END_Work_End,
    [UPD].WO_UPD_WO_ID,
    [UPD].WO_UPD_Work_Updates,
    [NAM].WO_NAM_WO_ID,
    [NAM].WO_NAM_Work_Name,
    [INS].WO_INS_WO_ID,
    [INS].WO_INS_Work_Inserts,
    [DEL].WO_DEL_WO_ID,
    [DEL].WO_DEL_Work_Deletes,
    [USR].WO_USR_WO_ID,
    [USR].WO_USR_Work_InvocationUser,
    [ROL].WO_ROL_WO_ID,
    [ROL].WO_ROL_Work_InvocationRole,
    [EST].WO_EST_WO_ID,
    [EST].WO_EST_ChangedAt,
    [kEST].EST_ExecutionStatus AS WO_EST_EST_ExecutionStatus,
    [EST].WO_EST_EST_ID,
    [ERL].WO_ERL_WO_ID,
    [ERL].WO_ERL_Work_ErrorLine,
    [ERM].WO_ERM_WO_ID,
    [ERM].WO_ERM_Work_ErrorMessage
FROM
    [metadata].[WO_Work] [WO]
LEFT JOIN
    [metadata].[WO_STA_Work_Start] [STA]
ON
    [STA].WO_STA_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_END_Work_End] [END]
ON
    [END].WO_END_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_UPD_Work_Updates] [UPD]
ON
    [UPD].WO_UPD_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_NAM_Work_Name] [NAM]
ON
    [NAM].WO_NAM_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_INS_Work_Inserts] [INS]
ON
    [INS].WO_INS_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_DEL_Work_Deletes] [DEL]
ON
    [DEL].WO_DEL_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_USR_Work_InvocationUser] [USR]
ON
    [USR].WO_USR_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_ROL_Work_InvocationRole] [ROL]
ON
    [ROL].WO_ROL_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[rWO_EST_Work_ExecutionStatus](@changingTimepoint) [EST]
ON
    [EST].WO_EST_WO_ID = [WO].WO_ID
AND
    [EST].WO_EST_ChangedAt = (
        SELECT
            max(sub.WO_EST_ChangedAt)
        FROM
            [metadata].[rWO_EST_Work_ExecutionStatus](@changingTimepoint) sub
        WHERE
            sub.WO_EST_WO_ID = [WO].WO_ID
   )
LEFT JOIN
    [metadata].[EST_ExecutionStatus] [kEST]
ON
    [kEST].EST_ID = [EST].WO_EST_EST_ID
LEFT JOIN
    [metadata].[WO_ERL_Work_ErrorLine] [ERL]
ON
    [ERL].WO_ERL_WO_ID = [WO].WO_ID
LEFT JOIN
    [metadata].[WO_ERM_Work_ErrorMessage] [ERM]
ON
    [ERM].WO_ERM_WO_ID = [WO].WO_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nWO_Work viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nWO_Work]
AS
SELECT
    *
FROM
    [metadata].[pWO_Work](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dWO_Work showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[dWO_Work] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pWO].*
FROM (
    SELECT DISTINCT
        WO_EST_WO_ID AS WO_ID,
        WO_EST_ChangedAt AS inspectedTimepoint,
        'EST' AS mnemonic
    FROM
        [metadata].[WO_EST_Work_ExecutionStatus]
    WHERE
        (@selection is null OR @selection like '%EST%')
    AND
        WO_EST_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [metadata].[pWO_Work](timepoints.inspectedTimepoint) [pWO]
WHERE
    [pWO].WO_ID = timepoints.WO_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dWF_Workflow', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dWF_Workflow];
IF Object_ID('metadata.nWF_Workflow', 'V') IS NOT NULL
DROP VIEW [metadata].[nWF_Workflow];
IF Object_ID('metadata.pWF_Workflow', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pWF_Workflow];
IF Object_ID('metadata.lWF_Workflow', 'V') IS NOT NULL
DROP VIEW [metadata].[lWF_Workflow];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lWF_Workflow viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lWF_Workflow] WITH SCHEMABINDING AS
SELECT
    [WF].WF_ID,
    [NAM].WF_NAM_WF_ID,
    [NAM].WF_NAM_Workflow_Name,
    [CFG].WF_CFG_WF_ID,
    [CFG].WF_CFG_ChangedAt,
    [CFG].WF_CFG_Checksum,
    [CFG].WF_CFG_Workflow_Configuration
FROM
    [metadata].[WF_Workflow] [WF]
LEFT JOIN
    [metadata].[WF_NAM_Workflow_Name] [NAM]
ON
    [NAM].WF_NAM_WF_ID = [WF].WF_ID
LEFT JOIN
    [metadata].[WF_CFG_Workflow_Configuration] [CFG]
ON
    [CFG].WF_CFG_WF_ID = [WF].WF_ID
AND
    [CFG].WF_CFG_ChangedAt = (
        SELECT
            max(sub.WF_CFG_ChangedAt)
        FROM
            [metadata].[WF_CFG_Workflow_Configuration] sub
        WHERE
            sub.WF_CFG_WF_ID = [WF].WF_ID
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pWF_Workflow viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pWF_Workflow] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [WF].WF_ID,
    [NAM].WF_NAM_WF_ID,
    [NAM].WF_NAM_Workflow_Name,
    [CFG].WF_CFG_WF_ID,
    [CFG].WF_CFG_ChangedAt,
    [CFG].WF_CFG_Checksum,
    [CFG].WF_CFG_Workflow_Configuration
FROM
    [metadata].[WF_Workflow] [WF]
LEFT JOIN
    [metadata].[WF_NAM_Workflow_Name] [NAM]
ON
    [NAM].WF_NAM_WF_ID = [WF].WF_ID
LEFT JOIN
    [metadata].[rWF_CFG_Workflow_Configuration](@changingTimepoint) [CFG]
ON
    [CFG].WF_CFG_WF_ID = [WF].WF_ID
AND
    [CFG].WF_CFG_ChangedAt = (
        SELECT
            max(sub.WF_CFG_ChangedAt)
        FROM
            [metadata].[rWF_CFG_Workflow_Configuration](@changingTimepoint) sub
        WHERE
            sub.WF_CFG_WF_ID = [WF].WF_ID
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nWF_Workflow viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nWF_Workflow]
AS
SELECT
    *
FROM
    [metadata].[pWF_Workflow](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dWF_Workflow showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[dWF_Workflow] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pWF].*
FROM (
    SELECT DISTINCT
        WF_CFG_WF_ID AS WF_ID,
        WF_CFG_ChangedAt AS inspectedTimepoint,
        'CFG' AS mnemonic
    FROM
        [metadata].[WF_CFG_Workflow_Configuration]
    WHERE
        (@selection is null OR @selection like '%CFG%')
    AND
        WF_CFG_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [metadata].[pWF_Workflow](timepoints.inspectedTimepoint) [pWF]
WHERE
    [pWF].WF_ID = timepoints.WF_ID;
GO
-- ATTRIBUTE TRIGGERS ------------------------------------------------------------------------------------------------
--
-- The following triggers on the attributes make them behave like tables.
-- There is one 'instead of' trigger for: insert.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_JB_STA_Job_Start instead of INSERT trigger on JB_STA_Job_Start
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_JB_STA_Job_Start', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_JB_STA_Job_Start];
GO
CREATE TRIGGER [metadata].[it_JB_STA_Job_Start] ON [metadata].[JB_STA_Job_Start]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @JB_STA_Job_Start TABLE (
        JB_STA_JB_ID int not null,
        JB_STA_Job_Start datetime not null,
        JB_STA_Version bigint not null,
        JB_STA_StatementType char(1) not null,
        primary key(
            JB_STA_Version,
            JB_STA_JB_ID
        )
    );
    INSERT INTO @JB_STA_Job_Start
    SELECT
        i.JB_STA_JB_ID,
        i.JB_STA_Job_Start,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(JB_STA_Version),
        @currentVersion = 0
    FROM
        @JB_STA_Job_Start;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.JB_STA_StatementType =
                CASE
                    WHEN [STA].JB_STA_JB_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @JB_STA_Job_Start v
        LEFT JOIN
            [metadata].[JB_STA_Job_Start] [STA]
        ON
            [STA].JB_STA_JB_ID = v.JB_STA_JB_ID
        AND
            [STA].JB_STA_Job_Start = v.JB_STA_Job_Start
        WHERE
            v.JB_STA_Version = @currentVersion;
        INSERT INTO [metadata].[JB_STA_Job_Start] (
            JB_STA_JB_ID,
            JB_STA_Job_Start
        )
        SELECT
            JB_STA_JB_ID,
            JB_STA_Job_Start
        FROM
            @JB_STA_Job_Start
        WHERE
            JB_STA_Version = @currentVersion
        AND
            JB_STA_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_JB_END_Job_End instead of INSERT trigger on JB_END_Job_End
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_JB_END_Job_End', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_JB_END_Job_End];
GO
CREATE TRIGGER [metadata].[it_JB_END_Job_End] ON [metadata].[JB_END_Job_End]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @JB_END_Job_End TABLE (
        JB_END_JB_ID int not null,
        JB_END_Job_End datetime not null,
        JB_END_Version bigint not null,
        JB_END_StatementType char(1) not null,
        primary key(
            JB_END_Version,
            JB_END_JB_ID
        )
    );
    INSERT INTO @JB_END_Job_End
    SELECT
        i.JB_END_JB_ID,
        i.JB_END_Job_End,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(JB_END_Version),
        @currentVersion = 0
    FROM
        @JB_END_Job_End;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.JB_END_StatementType =
                CASE
                    WHEN [END].JB_END_JB_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @JB_END_Job_End v
        LEFT JOIN
            [metadata].[JB_END_Job_End] [END]
        ON
            [END].JB_END_JB_ID = v.JB_END_JB_ID
        AND
            [END].JB_END_Job_End = v.JB_END_Job_End
        WHERE
            v.JB_END_Version = @currentVersion;
        INSERT INTO [metadata].[JB_END_Job_End] (
            JB_END_JB_ID,
            JB_END_Job_End
        )
        SELECT
            JB_END_JB_ID,
            JB_END_Job_End
        FROM
            @JB_END_Job_End
        WHERE
            JB_END_Version = @currentVersion
        AND
            JB_END_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_JB_NAM_Job_Name instead of INSERT trigger on JB_NAM_Job_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_JB_NAM_Job_Name', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_JB_NAM_Job_Name];
GO
CREATE TRIGGER [metadata].[it_JB_NAM_Job_Name] ON [metadata].[JB_NAM_Job_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @JB_NAM_Job_Name TABLE (
        JB_NAM_JB_ID int not null,
        JB_NAM_Job_Name varchar(255) not null,
        JB_NAM_Version bigint not null,
        JB_NAM_StatementType char(1) not null,
        primary key(
            JB_NAM_Version,
            JB_NAM_JB_ID
        )
    );
    INSERT INTO @JB_NAM_Job_Name
    SELECT
        i.JB_NAM_JB_ID,
        i.JB_NAM_Job_Name,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(JB_NAM_Version),
        @currentVersion = 0
    FROM
        @JB_NAM_Job_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.JB_NAM_StatementType =
                CASE
                    WHEN [NAM].JB_NAM_JB_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @JB_NAM_Job_Name v
        LEFT JOIN
            [metadata].[JB_NAM_Job_Name] [NAM]
        ON
            [NAM].JB_NAM_JB_ID = v.JB_NAM_JB_ID
        AND
            [NAM].JB_NAM_Job_Name = v.JB_NAM_Job_Name
        WHERE
            v.JB_NAM_Version = @currentVersion;
        INSERT INTO [metadata].[JB_NAM_Job_Name] (
            JB_NAM_JB_ID,
            JB_NAM_Job_Name
        )
        SELECT
            JB_NAM_JB_ID,
            JB_NAM_Job_Name
        FROM
            @JB_NAM_Job_Name
        WHERE
            JB_NAM_Version = @currentVersion
        AND
            JB_NAM_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SR_NAM_Source_Name instead of INSERT trigger on SR_NAM_Source_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_SR_NAM_Source_Name', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_SR_NAM_Source_Name];
GO
CREATE TRIGGER [metadata].[it_SR_NAM_Source_Name] ON [metadata].[SR_NAM_Source_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SR_NAM_Source_Name TABLE (
        SR_NAM_SR_ID int not null,
        SR_NAM_Source_Name varchar(2000) not null,
        SR_NAM_Version bigint not null,
        SR_NAM_StatementType char(1) not null,
        primary key(
            SR_NAM_Version,
            SR_NAM_SR_ID
        )
    );
    INSERT INTO @SR_NAM_Source_Name
    SELECT
        i.SR_NAM_SR_ID,
        i.SR_NAM_Source_Name,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(SR_NAM_Version),
        @currentVersion = 0
    FROM
        @SR_NAM_Source_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SR_NAM_StatementType =
                CASE
                    WHEN [NAM].SR_NAM_SR_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @SR_NAM_Source_Name v
        LEFT JOIN
            [metadata].[SR_NAM_Source_Name] [NAM]
        ON
            [NAM].SR_NAM_SR_ID = v.SR_NAM_SR_ID
        AND
            [NAM].SR_NAM_Source_Name = v.SR_NAM_Source_Name
        WHERE
            v.SR_NAM_Version = @currentVersion;
        INSERT INTO [metadata].[SR_NAM_Source_Name] (
            SR_NAM_SR_ID,
            SR_NAM_Source_Name
        )
        SELECT
            SR_NAM_SR_ID,
            SR_NAM_Source_Name
        FROM
            @SR_NAM_Source_Name
        WHERE
            SR_NAM_Version = @currentVersion
        AND
            SR_NAM_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SR_CFG_Source_Configuration instead of INSERT trigger on SR_CFG_Source_Configuration
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_SR_CFG_Source_Configuration', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_SR_CFG_Source_Configuration];
GO
CREATE TRIGGER [metadata].[it_SR_CFG_Source_Configuration] ON [metadata].[SR_CFG_Source_Configuration]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SR_CFG_Source_Configuration TABLE (
        SR_CFG_SR_ID int not null,
        SR_CFG_ChangedAt datetime not null,
        SR_CFG_Source_Configuration xml not null,
        SR_CFG_Checksum varbinary(16) not null,
        SR_CFG_Version bigint not null,
        SR_CFG_StatementType char(1) not null,
        primary key(
            SR_CFG_Version,
            SR_CFG_SR_ID
        )
    );
    INSERT INTO @SR_CFG_Source_Configuration
    SELECT
        i.SR_CFG_SR_ID,
        i.SR_CFG_ChangedAt,
        i.SR_CFG_Source_Configuration,
        ISNULL(i.SR_CFG_Checksum, HashBytes('MD5', cast(i.SR_CFG_Source_Configuration as varbinary(max)))),
        DENSE_RANK() OVER (
            PARTITION BY
                i.SR_CFG_SR_ID
            ORDER BY
                i.SR_CFG_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(SR_CFG_Version),
        @currentVersion = 0
    FROM
        @SR_CFG_Source_Configuration;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SR_CFG_StatementType =
                CASE
                    WHEN [CFG].SR_CFG_SR_ID is not null
                    THEN 'D' -- duplicate
                    WHEN [metadata].[rfSR_CFG_Source_Configuration](
                        v.SR_CFG_SR_ID,
                        v.SR_CFG_Checksum, 
                        v.SR_CFG_ChangedAt
                    ) = 1
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @SR_CFG_Source_Configuration v
        LEFT JOIN
            [metadata].[SR_CFG_Source_Configuration] [CFG]
        ON
            [CFG].SR_CFG_SR_ID = v.SR_CFG_SR_ID
        AND
            [CFG].SR_CFG_ChangedAt = v.SR_CFG_ChangedAt
        AND
            [CFG].SR_CFG_Checksum = v.SR_CFG_Checksum 
        WHERE
            v.SR_CFG_Version = @currentVersion;
        INSERT INTO [metadata].[SR_CFG_Source_Configuration] (
            SR_CFG_SR_ID,
            SR_CFG_ChangedAt,
            SR_CFG_Source_Configuration
        )
        SELECT
            SR_CFG_SR_ID,
            SR_CFG_ChangedAt,
            SR_CFG_Source_Configuration
        FROM
            @SR_CFG_Source_Configuration
        WHERE
            SR_CFG_Version = @currentVersion
        AND
            SR_CFG_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_CO_NAM_Container_Name instead of INSERT trigger on CO_NAM_Container_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_CO_NAM_Container_Name', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_CO_NAM_Container_Name];
GO
CREATE TRIGGER [metadata].[it_CO_NAM_Container_Name] ON [metadata].[CO_NAM_Container_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @CO_NAM_Container_Name TABLE (
        CO_NAM_CO_ID int not null,
        CO_NAM_Container_Name varchar(2000) not null,
        CO_NAM_Version bigint not null,
        CO_NAM_StatementType char(1) not null,
        primary key(
            CO_NAM_Version,
            CO_NAM_CO_ID
        )
    );
    INSERT INTO @CO_NAM_Container_Name
    SELECT
        i.CO_NAM_CO_ID,
        i.CO_NAM_Container_Name,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(CO_NAM_Version),
        @currentVersion = 0
    FROM
        @CO_NAM_Container_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.CO_NAM_StatementType =
                CASE
                    WHEN [NAM].CO_NAM_CO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @CO_NAM_Container_Name v
        LEFT JOIN
            [metadata].[CO_NAM_Container_Name] [NAM]
        ON
            [NAM].CO_NAM_CO_ID = v.CO_NAM_CO_ID
        AND
            [NAM].CO_NAM_Container_Name = v.CO_NAM_Container_Name
        WHERE
            v.CO_NAM_Version = @currentVersion;
        INSERT INTO [metadata].[CO_NAM_Container_Name] (
            CO_NAM_CO_ID,
            CO_NAM_Container_Name
        )
        SELECT
            CO_NAM_CO_ID,
            CO_NAM_Container_Name
        FROM
            @CO_NAM_Container_Name
        WHERE
            CO_NAM_Version = @currentVersion
        AND
            CO_NAM_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_CO_TYP_Container_Type instead of INSERT trigger on CO_TYP_Container_Type
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_CO_TYP_Container_Type', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_CO_TYP_Container_Type];
GO
CREATE TRIGGER [metadata].[it_CO_TYP_Container_Type] ON [metadata].[CO_TYP_Container_Type]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @CO_TYP_Container_Type TABLE (
        CO_TYP_CO_ID int not null,
        CO_TYP_TYP_ID tinyint not null, 
        CO_TYP_Version bigint not null,
        CO_TYP_StatementType char(1) not null,
        primary key(
            CO_TYP_Version,
            CO_TYP_CO_ID
        )
    );
    INSERT INTO @CO_TYP_Container_Type
    SELECT
        i.CO_TYP_CO_ID,
        i.CO_TYP_TYP_ID,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(CO_TYP_Version),
        @currentVersion = 0
    FROM
        @CO_TYP_Container_Type;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.CO_TYP_StatementType =
                CASE
                    WHEN [TYP].CO_TYP_CO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @CO_TYP_Container_Type v
        LEFT JOIN
            [metadata].[CO_TYP_Container_Type] [TYP]
        ON
            [TYP].CO_TYP_CO_ID = v.CO_TYP_CO_ID
        AND
            [TYP].CO_TYP_TYP_ID = v.CO_TYP_TYP_ID
        WHERE
            v.CO_TYP_Version = @currentVersion;
        INSERT INTO [metadata].[CO_TYP_Container_Type] (
            CO_TYP_CO_ID,
            CO_TYP_TYP_ID
        )
        SELECT
            CO_TYP_CO_ID,
            CO_TYP_TYP_ID
        FROM
            @CO_TYP_Container_Type
        WHERE
            CO_TYP_Version = @currentVersion
        AND
            CO_TYP_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_CO_PTH_Container_Path instead of INSERT trigger on CO_PTH_Container_Path
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_CO_PTH_Container_Path', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_CO_PTH_Container_Path];
GO
CREATE TRIGGER [metadata].[it_CO_PTH_Container_Path] ON [metadata].[CO_PTH_Container_Path]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @CO_PTH_Container_Path TABLE (
        CO_PTH_CO_ID int not null,
        CO_PTH_Container_Path varchar(2000) not null,
        CO_PTH_Version bigint not null,
        CO_PTH_StatementType char(1) not null,
        primary key(
            CO_PTH_Version,
            CO_PTH_CO_ID
        )
    );
    INSERT INTO @CO_PTH_Container_Path
    SELECT
        i.CO_PTH_CO_ID,
        i.CO_PTH_Container_Path,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(CO_PTH_Version),
        @currentVersion = 0
    FROM
        @CO_PTH_Container_Path;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.CO_PTH_StatementType =
                CASE
                    WHEN [PTH].CO_PTH_CO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @CO_PTH_Container_Path v
        LEFT JOIN
            [metadata].[CO_PTH_Container_Path] [PTH]
        ON
            [PTH].CO_PTH_CO_ID = v.CO_PTH_CO_ID
        AND
            [PTH].CO_PTH_Container_Path = v.CO_PTH_Container_Path
        WHERE
            v.CO_PTH_Version = @currentVersion;
        INSERT INTO [metadata].[CO_PTH_Container_Path] (
            CO_PTH_CO_ID,
            CO_PTH_Container_Path
        )
        SELECT
            CO_PTH_CO_ID,
            CO_PTH_Container_Path
        FROM
            @CO_PTH_Container_Path
        WHERE
            CO_PTH_Version = @currentVersion
        AND
            CO_PTH_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_CO_DSC_Container_Discovered instead of INSERT trigger on CO_DSC_Container_Discovered
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_CO_DSC_Container_Discovered', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_CO_DSC_Container_Discovered];
GO
CREATE TRIGGER [metadata].[it_CO_DSC_Container_Discovered] ON [metadata].[CO_DSC_Container_Discovered]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @CO_DSC_Container_Discovered TABLE (
        CO_DSC_CO_ID int not null,
        CO_DSC_Container_Discovered datetime not null,
        CO_DSC_Version bigint not null,
        CO_DSC_StatementType char(1) not null,
        primary key(
            CO_DSC_Version,
            CO_DSC_CO_ID
        )
    );
    INSERT INTO @CO_DSC_Container_Discovered
    SELECT
        i.CO_DSC_CO_ID,
        i.CO_DSC_Container_Discovered,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(CO_DSC_Version),
        @currentVersion = 0
    FROM
        @CO_DSC_Container_Discovered;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.CO_DSC_StatementType =
                CASE
                    WHEN [DSC].CO_DSC_CO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @CO_DSC_Container_Discovered v
        LEFT JOIN
            [metadata].[CO_DSC_Container_Discovered] [DSC]
        ON
            [DSC].CO_DSC_CO_ID = v.CO_DSC_CO_ID
        AND
            [DSC].CO_DSC_Container_Discovered = v.CO_DSC_Container_Discovered
        WHERE
            v.CO_DSC_Version = @currentVersion;
        INSERT INTO [metadata].[CO_DSC_Container_Discovered] (
            CO_DSC_CO_ID,
            CO_DSC_Container_Discovered
        )
        SELECT
            CO_DSC_CO_ID,
            CO_DSC_Container_Discovered
        FROM
            @CO_DSC_Container_Discovered
        WHERE
            CO_DSC_Version = @currentVersion
        AND
            CO_DSC_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_STA_Work_Start instead of INSERT trigger on WO_STA_Work_Start
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_STA_Work_Start', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_STA_Work_Start];
GO
CREATE TRIGGER [metadata].[it_WO_STA_Work_Start] ON [metadata].[WO_STA_Work_Start]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_STA_Work_Start TABLE (
        WO_STA_WO_ID int not null,
        WO_STA_Work_Start datetime not null,
        WO_STA_Version bigint not null,
        WO_STA_StatementType char(1) not null,
        primary key(
            WO_STA_Version,
            WO_STA_WO_ID
        )
    );
    INSERT INTO @WO_STA_Work_Start
    SELECT
        i.WO_STA_WO_ID,
        i.WO_STA_Work_Start,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_STA_Version),
        @currentVersion = 0
    FROM
        @WO_STA_Work_Start;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_STA_StatementType =
                CASE
                    WHEN [STA].WO_STA_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_STA_Work_Start v
        LEFT JOIN
            [metadata].[WO_STA_Work_Start] [STA]
        ON
            [STA].WO_STA_WO_ID = v.WO_STA_WO_ID
        AND
            [STA].WO_STA_Work_Start = v.WO_STA_Work_Start
        WHERE
            v.WO_STA_Version = @currentVersion;
        INSERT INTO [metadata].[WO_STA_Work_Start] (
            WO_STA_WO_ID,
            WO_STA_Work_Start
        )
        SELECT
            WO_STA_WO_ID,
            WO_STA_Work_Start
        FROM
            @WO_STA_Work_Start
        WHERE
            WO_STA_Version = @currentVersion
        AND
            WO_STA_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_END_Work_End instead of INSERT trigger on WO_END_Work_End
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_END_Work_End', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_END_Work_End];
GO
CREATE TRIGGER [metadata].[it_WO_END_Work_End] ON [metadata].[WO_END_Work_End]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_END_Work_End TABLE (
        WO_END_WO_ID int not null,
        WO_END_Work_End datetime not null,
        WO_END_Version bigint not null,
        WO_END_StatementType char(1) not null,
        primary key(
            WO_END_Version,
            WO_END_WO_ID
        )
    );
    INSERT INTO @WO_END_Work_End
    SELECT
        i.WO_END_WO_ID,
        i.WO_END_Work_End,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_END_Version),
        @currentVersion = 0
    FROM
        @WO_END_Work_End;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_END_StatementType =
                CASE
                    WHEN [END].WO_END_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_END_Work_End v
        LEFT JOIN
            [metadata].[WO_END_Work_End] [END]
        ON
            [END].WO_END_WO_ID = v.WO_END_WO_ID
        AND
            [END].WO_END_Work_End = v.WO_END_Work_End
        WHERE
            v.WO_END_Version = @currentVersion;
        INSERT INTO [metadata].[WO_END_Work_End] (
            WO_END_WO_ID,
            WO_END_Work_End
        )
        SELECT
            WO_END_WO_ID,
            WO_END_Work_End
        FROM
            @WO_END_Work_End
        WHERE
            WO_END_Version = @currentVersion
        AND
            WO_END_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_UPD_Work_Updates instead of INSERT trigger on WO_UPD_Work_Updates
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_UPD_Work_Updates', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_UPD_Work_Updates];
GO
CREATE TRIGGER [metadata].[it_WO_UPD_Work_Updates] ON [metadata].[WO_UPD_Work_Updates]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_UPD_Work_Updates TABLE (
        WO_UPD_WO_ID int not null,
        WO_UPD_Work_Updates int not null,
        WO_UPD_Version bigint not null,
        WO_UPD_StatementType char(1) not null,
        primary key(
            WO_UPD_Version,
            WO_UPD_WO_ID
        )
    );
    INSERT INTO @WO_UPD_Work_Updates
    SELECT
        i.WO_UPD_WO_ID,
        i.WO_UPD_Work_Updates,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_UPD_Version),
        @currentVersion = 0
    FROM
        @WO_UPD_Work_Updates;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_UPD_StatementType =
                CASE
                    WHEN [UPD].WO_UPD_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_UPD_Work_Updates v
        LEFT JOIN
            [metadata].[WO_UPD_Work_Updates] [UPD]
        ON
            [UPD].WO_UPD_WO_ID = v.WO_UPD_WO_ID
        AND
            [UPD].WO_UPD_Work_Updates = v.WO_UPD_Work_Updates
        WHERE
            v.WO_UPD_Version = @currentVersion;
        INSERT INTO [metadata].[WO_UPD_Work_Updates] (
            WO_UPD_WO_ID,
            WO_UPD_Work_Updates
        )
        SELECT
            WO_UPD_WO_ID,
            WO_UPD_Work_Updates
        FROM
            @WO_UPD_Work_Updates
        WHERE
            WO_UPD_Version = @currentVersion
        AND
            WO_UPD_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_NAM_Work_Name instead of INSERT trigger on WO_NAM_Work_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_NAM_Work_Name', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_NAM_Work_Name];
GO
CREATE TRIGGER [metadata].[it_WO_NAM_Work_Name] ON [metadata].[WO_NAM_Work_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_NAM_Work_Name TABLE (
        WO_NAM_WO_ID int not null,
        WO_NAM_Work_Name varchar(255) not null,
        WO_NAM_Version bigint not null,
        WO_NAM_StatementType char(1) not null,
        primary key(
            WO_NAM_Version,
            WO_NAM_WO_ID
        )
    );
    INSERT INTO @WO_NAM_Work_Name
    SELECT
        i.WO_NAM_WO_ID,
        i.WO_NAM_Work_Name,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_NAM_Version),
        @currentVersion = 0
    FROM
        @WO_NAM_Work_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_NAM_StatementType =
                CASE
                    WHEN [NAM].WO_NAM_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_NAM_Work_Name v
        LEFT JOIN
            [metadata].[WO_NAM_Work_Name] [NAM]
        ON
            [NAM].WO_NAM_WO_ID = v.WO_NAM_WO_ID
        AND
            [NAM].WO_NAM_Work_Name = v.WO_NAM_Work_Name
        WHERE
            v.WO_NAM_Version = @currentVersion;
        INSERT INTO [metadata].[WO_NAM_Work_Name] (
            WO_NAM_WO_ID,
            WO_NAM_Work_Name
        )
        SELECT
            WO_NAM_WO_ID,
            WO_NAM_Work_Name
        FROM
            @WO_NAM_Work_Name
        WHERE
            WO_NAM_Version = @currentVersion
        AND
            WO_NAM_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_INS_Work_Inserts instead of INSERT trigger on WO_INS_Work_Inserts
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_INS_Work_Inserts', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_INS_Work_Inserts];
GO
CREATE TRIGGER [metadata].[it_WO_INS_Work_Inserts] ON [metadata].[WO_INS_Work_Inserts]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_INS_Work_Inserts TABLE (
        WO_INS_WO_ID int not null,
        WO_INS_Work_Inserts int not null,
        WO_INS_Version bigint not null,
        WO_INS_StatementType char(1) not null,
        primary key(
            WO_INS_Version,
            WO_INS_WO_ID
        )
    );
    INSERT INTO @WO_INS_Work_Inserts
    SELECT
        i.WO_INS_WO_ID,
        i.WO_INS_Work_Inserts,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_INS_Version),
        @currentVersion = 0
    FROM
        @WO_INS_Work_Inserts;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_INS_StatementType =
                CASE
                    WHEN [INS].WO_INS_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_INS_Work_Inserts v
        LEFT JOIN
            [metadata].[WO_INS_Work_Inserts] [INS]
        ON
            [INS].WO_INS_WO_ID = v.WO_INS_WO_ID
        AND
            [INS].WO_INS_Work_Inserts = v.WO_INS_Work_Inserts
        WHERE
            v.WO_INS_Version = @currentVersion;
        INSERT INTO [metadata].[WO_INS_Work_Inserts] (
            WO_INS_WO_ID,
            WO_INS_Work_Inserts
        )
        SELECT
            WO_INS_WO_ID,
            WO_INS_Work_Inserts
        FROM
            @WO_INS_Work_Inserts
        WHERE
            WO_INS_Version = @currentVersion
        AND
            WO_INS_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_DEL_Work_Deletes instead of INSERT trigger on WO_DEL_Work_Deletes
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_DEL_Work_Deletes', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_DEL_Work_Deletes];
GO
CREATE TRIGGER [metadata].[it_WO_DEL_Work_Deletes] ON [metadata].[WO_DEL_Work_Deletes]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_DEL_Work_Deletes TABLE (
        WO_DEL_WO_ID int not null,
        WO_DEL_Work_Deletes int not null,
        WO_DEL_Version bigint not null,
        WO_DEL_StatementType char(1) not null,
        primary key(
            WO_DEL_Version,
            WO_DEL_WO_ID
        )
    );
    INSERT INTO @WO_DEL_Work_Deletes
    SELECT
        i.WO_DEL_WO_ID,
        i.WO_DEL_Work_Deletes,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_DEL_Version),
        @currentVersion = 0
    FROM
        @WO_DEL_Work_Deletes;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_DEL_StatementType =
                CASE
                    WHEN [DEL].WO_DEL_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_DEL_Work_Deletes v
        LEFT JOIN
            [metadata].[WO_DEL_Work_Deletes] [DEL]
        ON
            [DEL].WO_DEL_WO_ID = v.WO_DEL_WO_ID
        AND
            [DEL].WO_DEL_Work_Deletes = v.WO_DEL_Work_Deletes
        WHERE
            v.WO_DEL_Version = @currentVersion;
        INSERT INTO [metadata].[WO_DEL_Work_Deletes] (
            WO_DEL_WO_ID,
            WO_DEL_Work_Deletes
        )
        SELECT
            WO_DEL_WO_ID,
            WO_DEL_Work_Deletes
        FROM
            @WO_DEL_Work_Deletes
        WHERE
            WO_DEL_Version = @currentVersion
        AND
            WO_DEL_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_USR_Work_InvocationUser instead of INSERT trigger on WO_USR_Work_InvocationUser
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_USR_Work_InvocationUser', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_USR_Work_InvocationUser];
GO
CREATE TRIGGER [metadata].[it_WO_USR_Work_InvocationUser] ON [metadata].[WO_USR_Work_InvocationUser]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_USR_Work_InvocationUser TABLE (
        WO_USR_WO_ID int not null,
        WO_USR_Work_InvocationUser varchar(555) not null,
        WO_USR_Version bigint not null,
        WO_USR_StatementType char(1) not null,
        primary key(
            WO_USR_Version,
            WO_USR_WO_ID
        )
    );
    INSERT INTO @WO_USR_Work_InvocationUser
    SELECT
        i.WO_USR_WO_ID,
        i.WO_USR_Work_InvocationUser,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_USR_Version),
        @currentVersion = 0
    FROM
        @WO_USR_Work_InvocationUser;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_USR_StatementType =
                CASE
                    WHEN [USR].WO_USR_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_USR_Work_InvocationUser v
        LEFT JOIN
            [metadata].[WO_USR_Work_InvocationUser] [USR]
        ON
            [USR].WO_USR_WO_ID = v.WO_USR_WO_ID
        AND
            [USR].WO_USR_Work_InvocationUser = v.WO_USR_Work_InvocationUser
        WHERE
            v.WO_USR_Version = @currentVersion;
        INSERT INTO [metadata].[WO_USR_Work_InvocationUser] (
            WO_USR_WO_ID,
            WO_USR_Work_InvocationUser
        )
        SELECT
            WO_USR_WO_ID,
            WO_USR_Work_InvocationUser
        FROM
            @WO_USR_Work_InvocationUser
        WHERE
            WO_USR_Version = @currentVersion
        AND
            WO_USR_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_ROL_Work_InvocationRole instead of INSERT trigger on WO_ROL_Work_InvocationRole
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_ROL_Work_InvocationRole', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_ROL_Work_InvocationRole];
GO
CREATE TRIGGER [metadata].[it_WO_ROL_Work_InvocationRole] ON [metadata].[WO_ROL_Work_InvocationRole]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_ROL_Work_InvocationRole TABLE (
        WO_ROL_WO_ID int not null,
        WO_ROL_Work_InvocationRole varchar(42) not null,
        WO_ROL_Version bigint not null,
        WO_ROL_StatementType char(1) not null,
        primary key(
            WO_ROL_Version,
            WO_ROL_WO_ID
        )
    );
    INSERT INTO @WO_ROL_Work_InvocationRole
    SELECT
        i.WO_ROL_WO_ID,
        i.WO_ROL_Work_InvocationRole,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_ROL_Version),
        @currentVersion = 0
    FROM
        @WO_ROL_Work_InvocationRole;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_ROL_StatementType =
                CASE
                    WHEN [ROL].WO_ROL_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_ROL_Work_InvocationRole v
        LEFT JOIN
            [metadata].[WO_ROL_Work_InvocationRole] [ROL]
        ON
            [ROL].WO_ROL_WO_ID = v.WO_ROL_WO_ID
        AND
            [ROL].WO_ROL_Work_InvocationRole = v.WO_ROL_Work_InvocationRole
        WHERE
            v.WO_ROL_Version = @currentVersion;
        INSERT INTO [metadata].[WO_ROL_Work_InvocationRole] (
            WO_ROL_WO_ID,
            WO_ROL_Work_InvocationRole
        )
        SELECT
            WO_ROL_WO_ID,
            WO_ROL_Work_InvocationRole
        FROM
            @WO_ROL_Work_InvocationRole
        WHERE
            WO_ROL_Version = @currentVersion
        AND
            WO_ROL_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_EST_Work_ExecutionStatus instead of INSERT trigger on WO_EST_Work_ExecutionStatus
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_EST_Work_ExecutionStatus', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_EST_Work_ExecutionStatus];
GO
CREATE TRIGGER [metadata].[it_WO_EST_Work_ExecutionStatus] ON [metadata].[WO_EST_Work_ExecutionStatus]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_EST_Work_ExecutionStatus TABLE (
        WO_EST_WO_ID int not null,
        WO_EST_ChangedAt datetime not null,
        WO_EST_EST_ID tinyint not null, 
        WO_EST_Version bigint not null,
        WO_EST_StatementType char(1) not null,
        primary key(
            WO_EST_Version,
            WO_EST_WO_ID
        )
    );
    INSERT INTO @WO_EST_Work_ExecutionStatus
    SELECT
        i.WO_EST_WO_ID,
        i.WO_EST_ChangedAt,
        i.WO_EST_EST_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.WO_EST_WO_ID
            ORDER BY
                i.WO_EST_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_EST_Version),
        @currentVersion = 0
    FROM
        @WO_EST_Work_ExecutionStatus;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_EST_StatementType =
                CASE
                    WHEN [EST].WO_EST_WO_ID is not null
                    THEN 'D' -- duplicate
                    WHEN [metadata].[rfWO_EST_Work_ExecutionStatus](
                        v.WO_EST_WO_ID,
                        v.WO_EST_EST_ID,
                        v.WO_EST_ChangedAt
                    ) = 1
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_EST_Work_ExecutionStatus v
        LEFT JOIN
            [metadata].[WO_EST_Work_ExecutionStatus] [EST]
        ON
            [EST].WO_EST_WO_ID = v.WO_EST_WO_ID
        AND
            [EST].WO_EST_ChangedAt = v.WO_EST_ChangedAt
        AND
            [EST].WO_EST_EST_ID = v.WO_EST_EST_ID
        WHERE
            v.WO_EST_Version = @currentVersion;
        INSERT INTO [metadata].[WO_EST_Work_ExecutionStatus] (
            WO_EST_WO_ID,
            WO_EST_ChangedAt,
            WO_EST_EST_ID
        )
        SELECT
            WO_EST_WO_ID,
            WO_EST_ChangedAt,
            WO_EST_EST_ID
        FROM
            @WO_EST_Work_ExecutionStatus
        WHERE
            WO_EST_Version = @currentVersion
        AND
            WO_EST_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_ERL_Work_ErrorLine instead of INSERT trigger on WO_ERL_Work_ErrorLine
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_ERL_Work_ErrorLine', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_ERL_Work_ErrorLine];
GO
CREATE TRIGGER [metadata].[it_WO_ERL_Work_ErrorLine] ON [metadata].[WO_ERL_Work_ErrorLine]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_ERL_Work_ErrorLine TABLE (
        WO_ERL_WO_ID int not null,
        WO_ERL_Work_ErrorLine int not null,
        WO_ERL_Version bigint not null,
        WO_ERL_StatementType char(1) not null,
        primary key(
            WO_ERL_Version,
            WO_ERL_WO_ID
        )
    );
    INSERT INTO @WO_ERL_Work_ErrorLine
    SELECT
        i.WO_ERL_WO_ID,
        i.WO_ERL_Work_ErrorLine,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_ERL_Version),
        @currentVersion = 0
    FROM
        @WO_ERL_Work_ErrorLine;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_ERL_StatementType =
                CASE
                    WHEN [ERL].WO_ERL_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_ERL_Work_ErrorLine v
        LEFT JOIN
            [metadata].[WO_ERL_Work_ErrorLine] [ERL]
        ON
            [ERL].WO_ERL_WO_ID = v.WO_ERL_WO_ID
        AND
            [ERL].WO_ERL_Work_ErrorLine = v.WO_ERL_Work_ErrorLine
        WHERE
            v.WO_ERL_Version = @currentVersion;
        INSERT INTO [metadata].[WO_ERL_Work_ErrorLine] (
            WO_ERL_WO_ID,
            WO_ERL_Work_ErrorLine
        )
        SELECT
            WO_ERL_WO_ID,
            WO_ERL_Work_ErrorLine
        FROM
            @WO_ERL_Work_ErrorLine
        WHERE
            WO_ERL_Version = @currentVersion
        AND
            WO_ERL_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_ERM_Work_ErrorMessage instead of INSERT trigger on WO_ERM_Work_ErrorMessage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_ERM_Work_ErrorMessage', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_ERM_Work_ErrorMessage];
GO
CREATE TRIGGER [metadata].[it_WO_ERM_Work_ErrorMessage] ON [metadata].[WO_ERM_Work_ErrorMessage]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WO_ERM_Work_ErrorMessage TABLE (
        WO_ERM_WO_ID int not null,
        WO_ERM_Work_ErrorMessage varchar(555) not null,
        WO_ERM_Version bigint not null,
        WO_ERM_StatementType char(1) not null,
        primary key(
            WO_ERM_Version,
            WO_ERM_WO_ID
        )
    );
    INSERT INTO @WO_ERM_Work_ErrorMessage
    SELECT
        i.WO_ERM_WO_ID,
        i.WO_ERM_Work_ErrorMessage,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WO_ERM_Version),
        @currentVersion = 0
    FROM
        @WO_ERM_Work_ErrorMessage;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WO_ERM_StatementType =
                CASE
                    WHEN [ERM].WO_ERM_WO_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WO_ERM_Work_ErrorMessage v
        LEFT JOIN
            [metadata].[WO_ERM_Work_ErrorMessage] [ERM]
        ON
            [ERM].WO_ERM_WO_ID = v.WO_ERM_WO_ID
        AND
            [ERM].WO_ERM_Work_ErrorMessage = v.WO_ERM_Work_ErrorMessage
        WHERE
            v.WO_ERM_Version = @currentVersion;
        INSERT INTO [metadata].[WO_ERM_Work_ErrorMessage] (
            WO_ERM_WO_ID,
            WO_ERM_Work_ErrorMessage
        )
        SELECT
            WO_ERM_WO_ID,
            WO_ERM_Work_ErrorMessage
        FROM
            @WO_ERM_Work_ErrorMessage
        WHERE
            WO_ERM_Version = @currentVersion
        AND
            WO_ERM_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WF_NAM_Workflow_Name instead of INSERT trigger on WF_NAM_Workflow_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WF_NAM_Workflow_Name', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WF_NAM_Workflow_Name];
GO
CREATE TRIGGER [metadata].[it_WF_NAM_Workflow_Name] ON [metadata].[WF_NAM_Workflow_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WF_NAM_Workflow_Name TABLE (
        WF_NAM_WF_ID int not null,
        WF_NAM_Workflow_Name varchar(255) not null,
        WF_NAM_Version bigint not null,
        WF_NAM_StatementType char(1) not null,
        primary key(
            WF_NAM_Version,
            WF_NAM_WF_ID
        )
    );
    INSERT INTO @WF_NAM_Workflow_Name
    SELECT
        i.WF_NAM_WF_ID,
        i.WF_NAM_Workflow_Name,
        1,
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WF_NAM_Version),
        @currentVersion = 0
    FROM
        @WF_NAM_Workflow_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WF_NAM_StatementType =
                CASE
                    WHEN [NAM].WF_NAM_WF_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @WF_NAM_Workflow_Name v
        LEFT JOIN
            [metadata].[WF_NAM_Workflow_Name] [NAM]
        ON
            [NAM].WF_NAM_WF_ID = v.WF_NAM_WF_ID
        AND
            [NAM].WF_NAM_Workflow_Name = v.WF_NAM_Workflow_Name
        WHERE
            v.WF_NAM_Version = @currentVersion;
        INSERT INTO [metadata].[WF_NAM_Workflow_Name] (
            WF_NAM_WF_ID,
            WF_NAM_Workflow_Name
        )
        SELECT
            WF_NAM_WF_ID,
            WF_NAM_Workflow_Name
        FROM
            @WF_NAM_Workflow_Name
        WHERE
            WF_NAM_Version = @currentVersion
        AND
            WF_NAM_StatementType in ('N');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WF_CFG_Workflow_Configuration instead of INSERT trigger on WF_CFG_Workflow_Configuration
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WF_CFG_Workflow_Configuration', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WF_CFG_Workflow_Configuration];
GO
CREATE TRIGGER [metadata].[it_WF_CFG_Workflow_Configuration] ON [metadata].[WF_CFG_Workflow_Configuration]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @WF_CFG_Workflow_Configuration TABLE (
        WF_CFG_WF_ID int not null,
        WF_CFG_ChangedAt datetime not null,
        WF_CFG_Workflow_Configuration xml not null,
        WF_CFG_Checksum varbinary(16) not null,
        WF_CFG_Version bigint not null,
        WF_CFG_StatementType char(1) not null,
        primary key(
            WF_CFG_Version,
            WF_CFG_WF_ID
        )
    );
    INSERT INTO @WF_CFG_Workflow_Configuration
    SELECT
        i.WF_CFG_WF_ID,
        i.WF_CFG_ChangedAt,
        i.WF_CFG_Workflow_Configuration,
        ISNULL(i.WF_CFG_Checksum, HashBytes('MD5', cast(i.WF_CFG_Workflow_Configuration as varbinary(max)))),
        DENSE_RANK() OVER (
            PARTITION BY
                i.WF_CFG_WF_ID
            ORDER BY
                i.WF_CFG_ChangedAt ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(WF_CFG_Version),
        @currentVersion = 0
    FROM
        @WF_CFG_Workflow_Configuration;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.WF_CFG_StatementType =
                CASE
                    WHEN [CFG].WF_CFG_WF_ID is not null
                    THEN 'D' -- duplicate
                    WHEN [metadata].[rfWF_CFG_Workflow_Configuration](
                        v.WF_CFG_WF_ID,
                        v.WF_CFG_Checksum, 
                        v.WF_CFG_ChangedAt
                    ) = 1
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @WF_CFG_Workflow_Configuration v
        LEFT JOIN
            [metadata].[WF_CFG_Workflow_Configuration] [CFG]
        ON
            [CFG].WF_CFG_WF_ID = v.WF_CFG_WF_ID
        AND
            [CFG].WF_CFG_ChangedAt = v.WF_CFG_ChangedAt
        AND
            [CFG].WF_CFG_Checksum = v.WF_CFG_Checksum 
        WHERE
            v.WF_CFG_Version = @currentVersion;
        INSERT INTO [metadata].[WF_CFG_Workflow_Configuration] (
            WF_CFG_WF_ID,
            WF_CFG_ChangedAt,
            WF_CFG_Workflow_Configuration
        )
        SELECT
            WF_CFG_WF_ID,
            WF_CFG_ChangedAt,
            WF_CFG_Workflow_Configuration
        FROM
            @WF_CFG_Workflow_Configuration
        WHERE
            WF_CFG_Version = @currentVersion
        AND
            WF_CFG_StatementType in ('N');
    END
END
GO
-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lJB_Job instead of INSERT trigger on lJB_Job
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lJB_Job] ON [metadata].[lJB_Job]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @JB TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        JB_ID int not null
    );
    INSERT INTO [metadata].[JB_Job] (
        JB_Dummy
    )
    OUTPUT
        inserted.JB_ID
    INTO
        @JB
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.JB_ID is null;
    DECLARE @inserted TABLE (
        JB_ID int not null,
        JB_STA_JB_ID int null,
        JB_STA_Job_Start datetime null,
        JB_END_JB_ID int null,
        JB_END_Job_End datetime null,
        JB_NAM_JB_ID int null,
        JB_NAM_Job_Name varchar(255) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.JB_ID, a.JB_ID),
        ISNULL(ISNULL(i.JB_STA_JB_ID, i.JB_ID), a.JB_ID),
        i.JB_STA_Job_Start,
        ISNULL(ISNULL(i.JB_END_JB_ID, i.JB_ID), a.JB_ID),
        i.JB_END_Job_End,
        ISNULL(ISNULL(i.JB_NAM_JB_ID, i.JB_ID), a.JB_ID),
        i.JB_NAM_Job_Name
    FROM (
        SELECT
            JB_ID,
            JB_STA_JB_ID,
            JB_STA_Job_Start,
            JB_END_JB_ID,
            JB_END_Job_End,
            JB_NAM_JB_ID,
            JB_NAM_Job_Name,
            ROW_NUMBER() OVER (PARTITION BY JB_ID ORDER BY JB_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @JB a
    ON
        a.Row = i.Row;
    INSERT INTO [metadata].[JB_STA_Job_Start] (
        JB_STA_JB_ID,
        JB_STA_Job_Start
    )
    SELECT
        i.JB_STA_JB_ID,
        i.JB_STA_Job_Start
    FROM
        @inserted i
    WHERE
        i.JB_STA_Job_Start is not null;
    INSERT INTO [metadata].[JB_END_Job_End] (
        JB_END_JB_ID,
        JB_END_Job_End
    )
    SELECT
        i.JB_END_JB_ID,
        i.JB_END_Job_End
    FROM
        @inserted i
    WHERE
        i.JB_END_Job_End is not null;
    INSERT INTO [metadata].[JB_NAM_Job_Name] (
        JB_NAM_JB_ID,
        JB_NAM_Job_Name
    )
    SELECT
        i.JB_NAM_JB_ID,
        i.JB_NAM_Job_Name
    FROM
        @inserted i
    WHERE
        i.JB_NAM_Job_Name is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lJB_Job instead of UPDATE trigger on lJB_Job
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lJB_Job] ON [metadata].[lJB_Job]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(JB_ID))
        RAISERROR('The identity column JB_ID is not updatable.', 16, 1);
    IF(UPDATE(JB_STA_JB_ID))
        RAISERROR('The foreign key column JB_STA_JB_ID is not updatable.', 16, 1);
    IF(UPDATE(JB_STA_Job_Start))
    BEGIN
        INSERT INTO [metadata].[JB_STA_Job_Start] (
            JB_STA_JB_ID,
            JB_STA_Job_Start
        )
        SELECT
            ISNULL(i.JB_STA_JB_ID, i.JB_ID),
            i.JB_STA_Job_Start
        FROM
            inserted i
        WHERE
            i.JB_STA_Job_Start is not null;
    END
    IF(UPDATE(JB_END_JB_ID))
        RAISERROR('The foreign key column JB_END_JB_ID is not updatable.', 16, 1);
    IF(UPDATE(JB_END_Job_End))
    BEGIN
        INSERT INTO [metadata].[JB_END_Job_End] (
            JB_END_JB_ID,
            JB_END_Job_End
        )
        SELECT
            ISNULL(i.JB_END_JB_ID, i.JB_ID),
            i.JB_END_Job_End
        FROM
            inserted i
        WHERE
            i.JB_END_Job_End is not null;
    END
    IF(UPDATE(JB_NAM_JB_ID))
        RAISERROR('The foreign key column JB_NAM_JB_ID is not updatable.', 16, 1);
    IF(UPDATE(JB_NAM_Job_Name))
    BEGIN
        INSERT INTO [metadata].[JB_NAM_Job_Name] (
            JB_NAM_JB_ID,
            JB_NAM_Job_Name
        )
        SELECT
            ISNULL(i.JB_NAM_JB_ID, i.JB_ID),
            i.JB_NAM_Job_Name
        FROM
            inserted i
        WHERE
            i.JB_NAM_Job_Name is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lJB_Job instead of DELETE trigger on lJB_Job
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lJB_Job] ON [metadata].[lJB_Job]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [STA]
    FROM
        [metadata].[JB_STA_Job_Start] [STA]
    JOIN
        deleted d
    ON
        d.JB_STA_JB_ID = [STA].JB_STA_JB_ID;
    DELETE [END]
    FROM
        [metadata].[JB_END_Job_End] [END]
    JOIN
        deleted d
    ON
        d.JB_END_JB_ID = [END].JB_END_JB_ID;
    DELETE [NAM]
    FROM
        [metadata].[JB_NAM_Job_Name] [NAM]
    JOIN
        deleted d
    ON
        d.JB_NAM_JB_ID = [NAM].JB_NAM_JB_ID;
    DELETE [JB]
    FROM
        [metadata].[JB_Job] [JB]
    LEFT JOIN
        [metadata].[JB_STA_Job_Start] [STA]
    ON
        [STA].JB_STA_JB_ID = [JB].JB_ID
    LEFT JOIN
        [metadata].[JB_END_Job_End] [END]
    ON
        [END].JB_END_JB_ID = [JB].JB_ID
    LEFT JOIN
        [metadata].[JB_NAM_Job_Name] [NAM]
    ON
        [NAM].JB_NAM_JB_ID = [JB].JB_ID
    WHERE
        [STA].JB_STA_JB_ID is null
    AND
        [END].JB_END_JB_ID is null
    AND
        [NAM].JB_NAM_JB_ID is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSR_Source instead of INSERT trigger on lSR_Source
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lSR_Source] ON [metadata].[lSR_Source]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @SR TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        SR_ID int not null
    );
    INSERT INTO [metadata].[SR_Source] (
        SR_Dummy
    )
    OUTPUT
        inserted.SR_ID
    INTO
        @SR
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.SR_ID is null;
    DECLARE @inserted TABLE (
        SR_ID int not null,
        SR_NAM_SR_ID int null,
        SR_NAM_Source_Name varchar(2000) null,
        SR_CFG_SR_ID int null,
        SR_CFG_ChangedAt datetime null,
        SR_CFG_Source_Configuration xml null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.SR_ID, a.SR_ID),
        ISNULL(ISNULL(i.SR_NAM_SR_ID, i.SR_ID), a.SR_ID),
        i.SR_NAM_Source_Name,
        ISNULL(ISNULL(i.SR_CFG_SR_ID, i.SR_ID), a.SR_ID),
        ISNULL(i.SR_CFG_ChangedAt, @now),
        i.SR_CFG_Source_Configuration
    FROM (
        SELECT
            SR_ID,
            SR_NAM_SR_ID,
            SR_NAM_Source_Name,
            SR_CFG_SR_ID,
            SR_CFG_ChangedAt,
            SR_CFG_Source_Configuration,
            ROW_NUMBER() OVER (PARTITION BY SR_ID ORDER BY SR_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @SR a
    ON
        a.Row = i.Row;
    INSERT INTO [metadata].[SR_NAM_Source_Name] (
        SR_NAM_SR_ID,
        SR_NAM_Source_Name
    )
    SELECT
        i.SR_NAM_SR_ID,
        i.SR_NAM_Source_Name
    FROM
        @inserted i
    WHERE
        i.SR_NAM_Source_Name is not null;
    INSERT INTO [metadata].[SR_CFG_Source_Configuration] (
        SR_CFG_SR_ID,
        SR_CFG_ChangedAt,
        SR_CFG_Source_Configuration
    )
    SELECT
        i.SR_CFG_SR_ID,
        i.SR_CFG_ChangedAt,
        i.SR_CFG_Source_Configuration
    FROM
        @inserted i
    WHERE
        i.SR_CFG_Source_Configuration is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSR_Source instead of UPDATE trigger on lSR_Source
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lSR_Source] ON [metadata].[lSR_Source]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(SR_ID))
        RAISERROR('The identity column SR_ID is not updatable.', 16, 1);
    IF(UPDATE(SR_NAM_SR_ID))
        RAISERROR('The foreign key column SR_NAM_SR_ID is not updatable.', 16, 1);
    IF(UPDATE(SR_NAM_Source_Name))
    BEGIN
        INSERT INTO [metadata].[SR_NAM_Source_Name] (
            SR_NAM_SR_ID,
            SR_NAM_Source_Name
        )
        SELECT
            ISNULL(i.SR_NAM_SR_ID, i.SR_ID),
            i.SR_NAM_Source_Name
        FROM
            inserted i
        WHERE
            i.SR_NAM_Source_Name is not null;
    END
    IF(UPDATE(SR_CFG_SR_ID))
        RAISERROR('The foreign key column SR_CFG_SR_ID is not updatable.', 16, 1);
    IF(UPDATE(SR_CFG_Source_Configuration))
    BEGIN
        INSERT INTO [metadata].[SR_CFG_Source_Configuration] (
            SR_CFG_SR_ID,
            SR_CFG_ChangedAt,
            SR_CFG_Source_Configuration
        )
        SELECT
            ISNULL(i.SR_CFG_SR_ID, i.SR_ID),
            cast(CASE
                WHEN i.SR_CFG_Source_Configuration is null THEN i.SR_CFG_ChangedAt
                WHEN UPDATE(SR_CFG_ChangedAt) THEN i.SR_CFG_ChangedAt
                ELSE @now
            END as datetime),
            i.SR_CFG_Source_Configuration
        FROM
            inserted i
        WHERE
            i.SR_CFG_Source_Configuration is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSR_Source instead of DELETE trigger on lSR_Source
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lSR_Source] ON [metadata].[lSR_Source]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [metadata].[SR_NAM_Source_Name] [NAM]
    JOIN
        deleted d
    ON
        d.SR_NAM_SR_ID = [NAM].SR_NAM_SR_ID;
    DELETE [CFG]
    FROM
        [metadata].[SR_CFG_Source_Configuration] [CFG]
    JOIN
        deleted d
    ON
        d.SR_CFG_ChangedAt = [CFG].SR_CFG_ChangedAt
    AND
        d.SR_CFG_SR_ID = [CFG].SR_CFG_SR_ID;
    DELETE [SR]
    FROM
        [metadata].[SR_Source] [SR]
    LEFT JOIN
        [metadata].[SR_NAM_Source_Name] [NAM]
    ON
        [NAM].SR_NAM_SR_ID = [SR].SR_ID
    LEFT JOIN
        [metadata].[SR_CFG_Source_Configuration] [CFG]
    ON
        [CFG].SR_CFG_SR_ID = [SR].SR_ID
    WHERE
        [NAM].SR_NAM_SR_ID is null
    AND
        [CFG].SR_CFG_SR_ID is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lCO_Container instead of INSERT trigger on lCO_Container
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lCO_Container] ON [metadata].[lCO_Container]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @CO TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        CO_ID int not null
    );
    INSERT INTO [metadata].[CO_Container] (
        CO_Dummy
    )
    OUTPUT
        inserted.CO_ID
    INTO
        @CO
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.CO_ID is null;
    DECLARE @inserted TABLE (
        CO_ID int not null,
        CO_NAM_CO_ID int null,
        CO_NAM_Container_Name varchar(2000) null,
        CO_TYP_CO_ID int null,
        CO_TYP_TYP_Type varchar(42) null,
        CO_TYP_TYP_ID tinyint null,
        CO_PTH_CO_ID int null,
        CO_PTH_Container_Path varchar(2000) null,
        CO_DSC_CO_ID int null,
        CO_DSC_Container_Discovered datetime null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.CO_ID, a.CO_ID),
        ISNULL(ISNULL(i.CO_NAM_CO_ID, i.CO_ID), a.CO_ID),
        i.CO_NAM_Container_Name,
        ISNULL(ISNULL(i.CO_TYP_CO_ID, i.CO_ID), a.CO_ID),
        i.CO_TYP_TYP_Type,
        i.CO_TYP_TYP_ID,
        ISNULL(ISNULL(i.CO_PTH_CO_ID, i.CO_ID), a.CO_ID),
        i.CO_PTH_Container_Path,
        ISNULL(ISNULL(i.CO_DSC_CO_ID, i.CO_ID), a.CO_ID),
        i.CO_DSC_Container_Discovered
    FROM (
        SELECT
            CO_ID,
            CO_NAM_CO_ID,
            CO_NAM_Container_Name,
            CO_TYP_CO_ID,
            CO_TYP_TYP_Type,
            CO_TYP_TYP_ID,
            CO_PTH_CO_ID,
            CO_PTH_Container_Path,
            CO_DSC_CO_ID,
            CO_DSC_Container_Discovered,
            ROW_NUMBER() OVER (PARTITION BY CO_ID ORDER BY CO_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @CO a
    ON
        a.Row = i.Row;
    INSERT INTO [metadata].[CO_NAM_Container_Name] (
        CO_NAM_CO_ID,
        CO_NAM_Container_Name
    )
    SELECT
        i.CO_NAM_CO_ID,
        i.CO_NAM_Container_Name
    FROM
        @inserted i
    WHERE
        i.CO_NAM_Container_Name is not null;
    INSERT INTO [metadata].[CO_TYP_Container_Type] (
        CO_TYP_CO_ID,
        CO_TYP_TYP_ID
    )
    SELECT
        i.CO_TYP_CO_ID,
        ISNULL(i.CO_TYP_TYP_ID, [kTYP].TYP_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[TYP_Type] [kTYP]
    ON
        [kTYP].TYP_Type = i.CO_TYP_TYP_Type
    WHERE
        ISNULL(i.CO_TYP_TYP_ID, [kTYP].TYP_ID) is not null;
    INSERT INTO [metadata].[CO_PTH_Container_Path] (
        CO_PTH_CO_ID,
        CO_PTH_Container_Path
    )
    SELECT
        i.CO_PTH_CO_ID,
        i.CO_PTH_Container_Path
    FROM
        @inserted i
    WHERE
        i.CO_PTH_Container_Path is not null;
    INSERT INTO [metadata].[CO_DSC_Container_Discovered] (
        CO_DSC_CO_ID,
        CO_DSC_Container_Discovered
    )
    SELECT
        i.CO_DSC_CO_ID,
        i.CO_DSC_Container_Discovered
    FROM
        @inserted i
    WHERE
        i.CO_DSC_Container_Discovered is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lCO_Container instead of UPDATE trigger on lCO_Container
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lCO_Container] ON [metadata].[lCO_Container]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(CO_ID))
        RAISERROR('The identity column CO_ID is not updatable.', 16, 1);
    IF(UPDATE(CO_NAM_CO_ID))
        RAISERROR('The foreign key column CO_NAM_CO_ID is not updatable.', 16, 1);
    IF(UPDATE(CO_NAM_Container_Name))
    BEGIN
        INSERT INTO [metadata].[CO_NAM_Container_Name] (
            CO_NAM_CO_ID,
            CO_NAM_Container_Name
        )
        SELECT
            ISNULL(i.CO_NAM_CO_ID, i.CO_ID),
            i.CO_NAM_Container_Name
        FROM
            inserted i
        WHERE
            i.CO_NAM_Container_Name is not null;
    END
    IF(UPDATE(CO_TYP_CO_ID))
        RAISERROR('The foreign key column CO_TYP_CO_ID is not updatable.', 16, 1);
    IF(UPDATE(CO_TYP_TYP_ID) OR UPDATE(CO_TYP_TYP_Type))
    BEGIN
        INSERT INTO [metadata].[CO_TYP_Container_Type] (
            CO_TYP_CO_ID,
            CO_TYP_TYP_ID
        )
        SELECT
            ISNULL(i.CO_TYP_CO_ID, i.CO_ID),
            CASE WHEN UPDATE(CO_TYP_TYP_ID) THEN i.CO_TYP_TYP_ID ELSE [kTYP].TYP_ID END
        FROM
            inserted i
        LEFT JOIN
            [metadata].[TYP_Type] [kTYP]
        ON
            [kTYP].TYP_Type = i.CO_TYP_TYP_Type
        WHERE
            ISNULL(i.CO_TYP_TYP_ID, [kTYP].TYP_ID) is not null;
    END
    IF(UPDATE(CO_PTH_CO_ID))
        RAISERROR('The foreign key column CO_PTH_CO_ID is not updatable.', 16, 1);
    IF(UPDATE(CO_PTH_Container_Path))
    BEGIN
        INSERT INTO [metadata].[CO_PTH_Container_Path] (
            CO_PTH_CO_ID,
            CO_PTH_Container_Path
        )
        SELECT
            ISNULL(i.CO_PTH_CO_ID, i.CO_ID),
            i.CO_PTH_Container_Path
        FROM
            inserted i
        WHERE
            i.CO_PTH_Container_Path is not null;
    END
    IF(UPDATE(CO_DSC_CO_ID))
        RAISERROR('The foreign key column CO_DSC_CO_ID is not updatable.', 16, 1);
    IF(UPDATE(CO_DSC_Container_Discovered))
    BEGIN
        INSERT INTO [metadata].[CO_DSC_Container_Discovered] (
            CO_DSC_CO_ID,
            CO_DSC_Container_Discovered
        )
        SELECT
            ISNULL(i.CO_DSC_CO_ID, i.CO_ID),
            i.CO_DSC_Container_Discovered
        FROM
            inserted i
        WHERE
            i.CO_DSC_Container_Discovered is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lCO_Container instead of DELETE trigger on lCO_Container
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lCO_Container] ON [metadata].[lCO_Container]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [metadata].[CO_NAM_Container_Name] [NAM]
    JOIN
        deleted d
    ON
        d.CO_NAM_CO_ID = [NAM].CO_NAM_CO_ID;
    DELETE [TYP]
    FROM
        [metadata].[CO_TYP_Container_Type] [TYP]
    JOIN
        deleted d
    ON
        d.CO_TYP_CO_ID = [TYP].CO_TYP_CO_ID;
    DELETE [PTH]
    FROM
        [metadata].[CO_PTH_Container_Path] [PTH]
    JOIN
        deleted d
    ON
        d.CO_PTH_CO_ID = [PTH].CO_PTH_CO_ID;
    DELETE [DSC]
    FROM
        [metadata].[CO_DSC_Container_Discovered] [DSC]
    JOIN
        deleted d
    ON
        d.CO_DSC_CO_ID = [DSC].CO_DSC_CO_ID;
    DELETE [CO]
    FROM
        [metadata].[CO_Container] [CO]
    LEFT JOIN
        [metadata].[CO_NAM_Container_Name] [NAM]
    ON
        [NAM].CO_NAM_CO_ID = [CO].CO_ID
    LEFT JOIN
        [metadata].[CO_TYP_Container_Type] [TYP]
    ON
        [TYP].CO_TYP_CO_ID = [CO].CO_ID
    LEFT JOIN
        [metadata].[CO_PTH_Container_Path] [PTH]
    ON
        [PTH].CO_PTH_CO_ID = [CO].CO_ID
    LEFT JOIN
        [metadata].[CO_DSC_Container_Discovered] [DSC]
    ON
        [DSC].CO_DSC_CO_ID = [CO].CO_ID
    WHERE
        [NAM].CO_NAM_CO_ID is null
    AND
        [TYP].CO_TYP_CO_ID is null
    AND
        [PTH].CO_PTH_CO_ID is null
    AND
        [DSC].CO_DSC_CO_ID is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lWO_Work instead of INSERT trigger on lWO_Work
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lWO_Work] ON [metadata].[lWO_Work]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @WO TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        WO_ID int not null
    );
    INSERT INTO [metadata].[WO_Work] (
        WO_Dummy
    )
    OUTPUT
        inserted.WO_ID
    INTO
        @WO
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.WO_ID is null;
    DECLARE @inserted TABLE (
        WO_ID int not null,
        WO_STA_WO_ID int null,
        WO_STA_Work_Start datetime null,
        WO_END_WO_ID int null,
        WO_END_Work_End datetime null,
        WO_UPD_WO_ID int null,
        WO_UPD_Work_Updates int null,
        WO_NAM_WO_ID int null,
        WO_NAM_Work_Name varchar(255) null,
        WO_INS_WO_ID int null,
        WO_INS_Work_Inserts int null,
        WO_DEL_WO_ID int null,
        WO_DEL_Work_Deletes int null,
        WO_USR_WO_ID int null,
        WO_USR_Work_InvocationUser varchar(555) null,
        WO_ROL_WO_ID int null,
        WO_ROL_Work_InvocationRole varchar(42) null,
        WO_EST_WO_ID int null,
        WO_EST_ChangedAt datetime null,
        WO_EST_EST_ExecutionStatus varchar(42) null,
        WO_EST_EST_ID tinyint null,
        WO_ERL_WO_ID int null,
        WO_ERL_Work_ErrorLine int null,
        WO_ERM_WO_ID int null,
        WO_ERM_Work_ErrorMessage varchar(555) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.WO_ID, a.WO_ID),
        ISNULL(ISNULL(i.WO_STA_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_STA_Work_Start,
        ISNULL(ISNULL(i.WO_END_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_END_Work_End,
        ISNULL(ISNULL(i.WO_UPD_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_UPD_Work_Updates,
        ISNULL(ISNULL(i.WO_NAM_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_NAM_Work_Name,
        ISNULL(ISNULL(i.WO_INS_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_INS_Work_Inserts,
        ISNULL(ISNULL(i.WO_DEL_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_DEL_Work_Deletes,
        ISNULL(ISNULL(i.WO_USR_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_USR_Work_InvocationUser,
        ISNULL(ISNULL(i.WO_ROL_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_ROL_Work_InvocationRole,
        ISNULL(ISNULL(i.WO_EST_WO_ID, i.WO_ID), a.WO_ID),
        ISNULL(i.WO_EST_ChangedAt, @now),
        i.WO_EST_EST_ExecutionStatus,
        i.WO_EST_EST_ID,
        ISNULL(ISNULL(i.WO_ERL_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_ERL_Work_ErrorLine,
        ISNULL(ISNULL(i.WO_ERM_WO_ID, i.WO_ID), a.WO_ID),
        i.WO_ERM_Work_ErrorMessage
    FROM (
        SELECT
            WO_ID,
            WO_STA_WO_ID,
            WO_STA_Work_Start,
            WO_END_WO_ID,
            WO_END_Work_End,
            WO_UPD_WO_ID,
            WO_UPD_Work_Updates,
            WO_NAM_WO_ID,
            WO_NAM_Work_Name,
            WO_INS_WO_ID,
            WO_INS_Work_Inserts,
            WO_DEL_WO_ID,
            WO_DEL_Work_Deletes,
            WO_USR_WO_ID,
            WO_USR_Work_InvocationUser,
            WO_ROL_WO_ID,
            WO_ROL_Work_InvocationRole,
            WO_EST_WO_ID,
            WO_EST_ChangedAt,
            WO_EST_EST_ExecutionStatus,
            WO_EST_EST_ID,
            WO_ERL_WO_ID,
            WO_ERL_Work_ErrorLine,
            WO_ERM_WO_ID,
            WO_ERM_Work_ErrorMessage,
            ROW_NUMBER() OVER (PARTITION BY WO_ID ORDER BY WO_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @WO a
    ON
        a.Row = i.Row;
    INSERT INTO [metadata].[WO_STA_Work_Start] (
        WO_STA_WO_ID,
        WO_STA_Work_Start
    )
    SELECT
        i.WO_STA_WO_ID,
        i.WO_STA_Work_Start
    FROM
        @inserted i
    WHERE
        i.WO_STA_Work_Start is not null;
    INSERT INTO [metadata].[WO_END_Work_End] (
        WO_END_WO_ID,
        WO_END_Work_End
    )
    SELECT
        i.WO_END_WO_ID,
        i.WO_END_Work_End
    FROM
        @inserted i
    WHERE
        i.WO_END_Work_End is not null;
    INSERT INTO [metadata].[WO_UPD_Work_Updates] (
        WO_UPD_WO_ID,
        WO_UPD_Work_Updates
    )
    SELECT
        i.WO_UPD_WO_ID,
        i.WO_UPD_Work_Updates
    FROM
        @inserted i
    WHERE
        i.WO_UPD_Work_Updates is not null;
    INSERT INTO [metadata].[WO_NAM_Work_Name] (
        WO_NAM_WO_ID,
        WO_NAM_Work_Name
    )
    SELECT
        i.WO_NAM_WO_ID,
        i.WO_NAM_Work_Name
    FROM
        @inserted i
    WHERE
        i.WO_NAM_Work_Name is not null;
    INSERT INTO [metadata].[WO_INS_Work_Inserts] (
        WO_INS_WO_ID,
        WO_INS_Work_Inserts
    )
    SELECT
        i.WO_INS_WO_ID,
        i.WO_INS_Work_Inserts
    FROM
        @inserted i
    WHERE
        i.WO_INS_Work_Inserts is not null;
    INSERT INTO [metadata].[WO_DEL_Work_Deletes] (
        WO_DEL_WO_ID,
        WO_DEL_Work_Deletes
    )
    SELECT
        i.WO_DEL_WO_ID,
        i.WO_DEL_Work_Deletes
    FROM
        @inserted i
    WHERE
        i.WO_DEL_Work_Deletes is not null;
    INSERT INTO [metadata].[WO_USR_Work_InvocationUser] (
        WO_USR_WO_ID,
        WO_USR_Work_InvocationUser
    )
    SELECT
        i.WO_USR_WO_ID,
        i.WO_USR_Work_InvocationUser
    FROM
        @inserted i
    WHERE
        i.WO_USR_Work_InvocationUser is not null;
    INSERT INTO [metadata].[WO_ROL_Work_InvocationRole] (
        WO_ROL_WO_ID,
        WO_ROL_Work_InvocationRole
    )
    SELECT
        i.WO_ROL_WO_ID,
        i.WO_ROL_Work_InvocationRole
    FROM
        @inserted i
    WHERE
        i.WO_ROL_Work_InvocationRole is not null;
    INSERT INTO [metadata].[WO_EST_Work_ExecutionStatus] (
        WO_EST_WO_ID,
        WO_EST_ChangedAt,
        WO_EST_EST_ID
    )
    SELECT
        i.WO_EST_WO_ID,
        i.WO_EST_ChangedAt,
        ISNULL(i.WO_EST_EST_ID, [kEST].EST_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[EST_ExecutionStatus] [kEST]
    ON
        [kEST].EST_ExecutionStatus = i.WO_EST_EST_ExecutionStatus
    WHERE
        ISNULL(i.WO_EST_EST_ID, [kEST].EST_ID) is not null;
    INSERT INTO [metadata].[WO_ERL_Work_ErrorLine] (
        WO_ERL_WO_ID,
        WO_ERL_Work_ErrorLine
    )
    SELECT
        i.WO_ERL_WO_ID,
        i.WO_ERL_Work_ErrorLine
    FROM
        @inserted i
    WHERE
        i.WO_ERL_Work_ErrorLine is not null;
    INSERT INTO [metadata].[WO_ERM_Work_ErrorMessage] (
        WO_ERM_WO_ID,
        WO_ERM_Work_ErrorMessage
    )
    SELECT
        i.WO_ERM_WO_ID,
        i.WO_ERM_Work_ErrorMessage
    FROM
        @inserted i
    WHERE
        i.WO_ERM_Work_ErrorMessage is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lWO_Work instead of UPDATE trigger on lWO_Work
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lWO_Work] ON [metadata].[lWO_Work]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(WO_ID))
        RAISERROR('The identity column WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_STA_WO_ID))
        RAISERROR('The foreign key column WO_STA_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_STA_Work_Start))
    BEGIN
        INSERT INTO [metadata].[WO_STA_Work_Start] (
            WO_STA_WO_ID,
            WO_STA_Work_Start
        )
        SELECT
            ISNULL(i.WO_STA_WO_ID, i.WO_ID),
            i.WO_STA_Work_Start
        FROM
            inserted i
        WHERE
            i.WO_STA_Work_Start is not null;
    END
    IF(UPDATE(WO_END_WO_ID))
        RAISERROR('The foreign key column WO_END_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_END_Work_End))
    BEGIN
        INSERT INTO [metadata].[WO_END_Work_End] (
            WO_END_WO_ID,
            WO_END_Work_End
        )
        SELECT
            ISNULL(i.WO_END_WO_ID, i.WO_ID),
            i.WO_END_Work_End
        FROM
            inserted i
        WHERE
            i.WO_END_Work_End is not null;
    END
    IF(UPDATE(WO_UPD_WO_ID))
        RAISERROR('The foreign key column WO_UPD_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_UPD_Work_Updates))
    BEGIN
        INSERT INTO [metadata].[WO_UPD_Work_Updates] (
            WO_UPD_WO_ID,
            WO_UPD_Work_Updates
        )
        SELECT
            ISNULL(i.WO_UPD_WO_ID, i.WO_ID),
            i.WO_UPD_Work_Updates
        FROM
            inserted i
        WHERE
            i.WO_UPD_Work_Updates is not null;
    END
    IF(UPDATE(WO_NAM_WO_ID))
        RAISERROR('The foreign key column WO_NAM_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_NAM_Work_Name))
    BEGIN
        INSERT INTO [metadata].[WO_NAM_Work_Name] (
            WO_NAM_WO_ID,
            WO_NAM_Work_Name
        )
        SELECT
            ISNULL(i.WO_NAM_WO_ID, i.WO_ID),
            i.WO_NAM_Work_Name
        FROM
            inserted i
        WHERE
            i.WO_NAM_Work_Name is not null;
    END
    IF(UPDATE(WO_INS_WO_ID))
        RAISERROR('The foreign key column WO_INS_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_INS_Work_Inserts))
    BEGIN
        INSERT INTO [metadata].[WO_INS_Work_Inserts] (
            WO_INS_WO_ID,
            WO_INS_Work_Inserts
        )
        SELECT
            ISNULL(i.WO_INS_WO_ID, i.WO_ID),
            i.WO_INS_Work_Inserts
        FROM
            inserted i
        WHERE
            i.WO_INS_Work_Inserts is not null;
    END
    IF(UPDATE(WO_DEL_WO_ID))
        RAISERROR('The foreign key column WO_DEL_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_DEL_Work_Deletes))
    BEGIN
        INSERT INTO [metadata].[WO_DEL_Work_Deletes] (
            WO_DEL_WO_ID,
            WO_DEL_Work_Deletes
        )
        SELECT
            ISNULL(i.WO_DEL_WO_ID, i.WO_ID),
            i.WO_DEL_Work_Deletes
        FROM
            inserted i
        WHERE
            i.WO_DEL_Work_Deletes is not null;
    END
    IF(UPDATE(WO_USR_WO_ID))
        RAISERROR('The foreign key column WO_USR_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_USR_Work_InvocationUser))
    BEGIN
        INSERT INTO [metadata].[WO_USR_Work_InvocationUser] (
            WO_USR_WO_ID,
            WO_USR_Work_InvocationUser
        )
        SELECT
            ISNULL(i.WO_USR_WO_ID, i.WO_ID),
            i.WO_USR_Work_InvocationUser
        FROM
            inserted i
        WHERE
            i.WO_USR_Work_InvocationUser is not null;
    END
    IF(UPDATE(WO_ROL_WO_ID))
        RAISERROR('The foreign key column WO_ROL_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_ROL_Work_InvocationRole))
    BEGIN
        INSERT INTO [metadata].[WO_ROL_Work_InvocationRole] (
            WO_ROL_WO_ID,
            WO_ROL_Work_InvocationRole
        )
        SELECT
            ISNULL(i.WO_ROL_WO_ID, i.WO_ID),
            i.WO_ROL_Work_InvocationRole
        FROM
            inserted i
        WHERE
            i.WO_ROL_Work_InvocationRole is not null;
    END
    IF(UPDATE(WO_EST_WO_ID))
        RAISERROR('The foreign key column WO_EST_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_EST_EST_ID) OR UPDATE(WO_EST_EST_ExecutionStatus))
    BEGIN
        INSERT INTO [metadata].[WO_EST_Work_ExecutionStatus] (
            WO_EST_WO_ID,
            WO_EST_ChangedAt,
            WO_EST_EST_ID
        )
        SELECT
            ISNULL(i.WO_EST_WO_ID, i.WO_ID),
            cast(CASE
                WHEN i.WO_EST_EST_ID is null AND [kEST].EST_ID is null THEN i.WO_EST_ChangedAt
                WHEN UPDATE(WO_EST_ChangedAt) THEN i.WO_EST_ChangedAt
                ELSE @now
            END as datetime),
            CASE WHEN UPDATE(WO_EST_EST_ID) THEN i.WO_EST_EST_ID ELSE [kEST].EST_ID END
        FROM
            inserted i
        LEFT JOIN
            [metadata].[EST_ExecutionStatus] [kEST]
        ON
            [kEST].EST_ExecutionStatus = i.WO_EST_EST_ExecutionStatus
        WHERE
            ISNULL(i.WO_EST_EST_ID, [kEST].EST_ID) is not null;
    END
    IF(UPDATE(WO_ERL_WO_ID))
        RAISERROR('The foreign key column WO_ERL_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_ERL_Work_ErrorLine))
    BEGIN
        INSERT INTO [metadata].[WO_ERL_Work_ErrorLine] (
            WO_ERL_WO_ID,
            WO_ERL_Work_ErrorLine
        )
        SELECT
            ISNULL(i.WO_ERL_WO_ID, i.WO_ID),
            i.WO_ERL_Work_ErrorLine
        FROM
            inserted i
        WHERE
            i.WO_ERL_Work_ErrorLine is not null;
    END
    IF(UPDATE(WO_ERM_WO_ID))
        RAISERROR('The foreign key column WO_ERM_WO_ID is not updatable.', 16, 1);
    IF(UPDATE(WO_ERM_Work_ErrorMessage))
    BEGIN
        INSERT INTO [metadata].[WO_ERM_Work_ErrorMessage] (
            WO_ERM_WO_ID,
            WO_ERM_Work_ErrorMessage
        )
        SELECT
            ISNULL(i.WO_ERM_WO_ID, i.WO_ID),
            i.WO_ERM_Work_ErrorMessage
        FROM
            inserted i
        WHERE
            i.WO_ERM_Work_ErrorMessage is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lWO_Work instead of DELETE trigger on lWO_Work
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lWO_Work] ON [metadata].[lWO_Work]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [STA]
    FROM
        [metadata].[WO_STA_Work_Start] [STA]
    JOIN
        deleted d
    ON
        d.WO_STA_WO_ID = [STA].WO_STA_WO_ID;
    DELETE [END]
    FROM
        [metadata].[WO_END_Work_End] [END]
    JOIN
        deleted d
    ON
        d.WO_END_WO_ID = [END].WO_END_WO_ID;
    DELETE [UPD]
    FROM
        [metadata].[WO_UPD_Work_Updates] [UPD]
    JOIN
        deleted d
    ON
        d.WO_UPD_WO_ID = [UPD].WO_UPD_WO_ID;
    DELETE [NAM]
    FROM
        [metadata].[WO_NAM_Work_Name] [NAM]
    JOIN
        deleted d
    ON
        d.WO_NAM_WO_ID = [NAM].WO_NAM_WO_ID;
    DELETE [INS]
    FROM
        [metadata].[WO_INS_Work_Inserts] [INS]
    JOIN
        deleted d
    ON
        d.WO_INS_WO_ID = [INS].WO_INS_WO_ID;
    DELETE [DEL]
    FROM
        [metadata].[WO_DEL_Work_Deletes] [DEL]
    JOIN
        deleted d
    ON
        d.WO_DEL_WO_ID = [DEL].WO_DEL_WO_ID;
    DELETE [USR]
    FROM
        [metadata].[WO_USR_Work_InvocationUser] [USR]
    JOIN
        deleted d
    ON
        d.WO_USR_WO_ID = [USR].WO_USR_WO_ID;
    DELETE [ROL]
    FROM
        [metadata].[WO_ROL_Work_InvocationRole] [ROL]
    JOIN
        deleted d
    ON
        d.WO_ROL_WO_ID = [ROL].WO_ROL_WO_ID;
    DELETE [EST]
    FROM
        [metadata].[WO_EST_Work_ExecutionStatus] [EST]
    JOIN
        deleted d
    ON
        d.WO_EST_ChangedAt = [EST].WO_EST_ChangedAt
    AND
        d.WO_EST_WO_ID = [EST].WO_EST_WO_ID;
    DELETE [ERL]
    FROM
        [metadata].[WO_ERL_Work_ErrorLine] [ERL]
    JOIN
        deleted d
    ON
        d.WO_ERL_WO_ID = [ERL].WO_ERL_WO_ID;
    DELETE [ERM]
    FROM
        [metadata].[WO_ERM_Work_ErrorMessage] [ERM]
    JOIN
        deleted d
    ON
        d.WO_ERM_WO_ID = [ERM].WO_ERM_WO_ID;
    DELETE [WO]
    FROM
        [metadata].[WO_Work] [WO]
    LEFT JOIN
        [metadata].[WO_STA_Work_Start] [STA]
    ON
        [STA].WO_STA_WO_ID = [WO].WO_ID
    LEFT JOIN
        [metadata].[WO_END_Work_End] [END]
    ON
        [END].WO_END_WO_ID = [WO].WO_ID
    LEFT JOIN
        [metadata].[WO_UPD_Work_Updates] [UPD]
    ON
        [UPD].WO_UPD_WO_ID = [WO].WO_ID
    LEFT JOIN
        [metadata].[WO_NAM_Work_Name] [NAM]
    ON
        [NAM].WO_NAM_WO_ID = [WO].WO_ID
    LEFT JOIN
        [metadata].[WO_INS_Work_Inserts] [INS]
    ON
        [INS].WO_INS_WO_ID = [WO].WO_ID
    LEFT JOIN
        [metadata].[WO_DEL_Work_Deletes] [DEL]
    ON
        [DEL].WO_DEL_WO_ID = [WO].WO_ID
    LEFT JOIN
        [metadata].[WO_USR_Work_InvocationUser] [USR]
    ON
        [USR].WO_USR_WO_ID = [WO].WO_ID
    LEFT JOIN
        [metadata].[WO_ROL_Work_InvocationRole] [ROL]
    ON
        [ROL].WO_ROL_WO_ID = [WO].WO_ID
    LEFT JOIN
        [metadata].[WO_EST_Work_ExecutionStatus] [EST]
    ON
        [EST].WO_EST_WO_ID = [WO].WO_ID
    LEFT JOIN
        [metadata].[WO_ERL_Work_ErrorLine] [ERL]
    ON
        [ERL].WO_ERL_WO_ID = [WO].WO_ID
    LEFT JOIN
        [metadata].[WO_ERM_Work_ErrorMessage] [ERM]
    ON
        [ERM].WO_ERM_WO_ID = [WO].WO_ID
    WHERE
        [STA].WO_STA_WO_ID is null
    AND
        [END].WO_END_WO_ID is null
    AND
        [UPD].WO_UPD_WO_ID is null
    AND
        [NAM].WO_NAM_WO_ID is null
    AND
        [INS].WO_INS_WO_ID is null
    AND
        [DEL].WO_DEL_WO_ID is null
    AND
        [USR].WO_USR_WO_ID is null
    AND
        [ROL].WO_ROL_WO_ID is null
    AND
        [EST].WO_EST_WO_ID is null
    AND
        [ERL].WO_ERL_WO_ID is null
    AND
        [ERM].WO_ERM_WO_ID is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lWF_Workflow instead of INSERT trigger on lWF_Workflow
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lWF_Workflow] ON [metadata].[lWF_Workflow]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @WF TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        WF_ID int not null
    );
    INSERT INTO [metadata].[WF_Workflow] (
        WF_Dummy
    )
    OUTPUT
        inserted.WF_ID
    INTO
        @WF
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.WF_ID is null;
    DECLARE @inserted TABLE (
        WF_ID int not null,
        WF_NAM_WF_ID int null,
        WF_NAM_Workflow_Name varchar(255) null,
        WF_CFG_WF_ID int null,
        WF_CFG_ChangedAt datetime null,
        WF_CFG_Workflow_Configuration xml null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.WF_ID, a.WF_ID),
        ISNULL(ISNULL(i.WF_NAM_WF_ID, i.WF_ID), a.WF_ID),
        i.WF_NAM_Workflow_Name,
        ISNULL(ISNULL(i.WF_CFG_WF_ID, i.WF_ID), a.WF_ID),
        ISNULL(i.WF_CFG_ChangedAt, @now),
        i.WF_CFG_Workflow_Configuration
    FROM (
        SELECT
            WF_ID,
            WF_NAM_WF_ID,
            WF_NAM_Workflow_Name,
            WF_CFG_WF_ID,
            WF_CFG_ChangedAt,
            WF_CFG_Workflow_Configuration,
            ROW_NUMBER() OVER (PARTITION BY WF_ID ORDER BY WF_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @WF a
    ON
        a.Row = i.Row;
    INSERT INTO [metadata].[WF_NAM_Workflow_Name] (
        WF_NAM_WF_ID,
        WF_NAM_Workflow_Name
    )
    SELECT
        i.WF_NAM_WF_ID,
        i.WF_NAM_Workflow_Name
    FROM
        @inserted i
    WHERE
        i.WF_NAM_Workflow_Name is not null;
    INSERT INTO [metadata].[WF_CFG_Workflow_Configuration] (
        WF_CFG_WF_ID,
        WF_CFG_ChangedAt,
        WF_CFG_Workflow_Configuration
    )
    SELECT
        i.WF_CFG_WF_ID,
        i.WF_CFG_ChangedAt,
        i.WF_CFG_Workflow_Configuration
    FROM
        @inserted i
    WHERE
        i.WF_CFG_Workflow_Configuration is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lWF_Workflow instead of UPDATE trigger on lWF_Workflow
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lWF_Workflow] ON [metadata].[lWF_Workflow]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(WF_ID))
        RAISERROR('The identity column WF_ID is not updatable.', 16, 1);
    IF(UPDATE(WF_NAM_WF_ID))
        RAISERROR('The foreign key column WF_NAM_WF_ID is not updatable.', 16, 1);
    IF(UPDATE(WF_NAM_Workflow_Name))
    BEGIN
        INSERT INTO [metadata].[WF_NAM_Workflow_Name] (
            WF_NAM_WF_ID,
            WF_NAM_Workflow_Name
        )
        SELECT
            ISNULL(i.WF_NAM_WF_ID, i.WF_ID),
            i.WF_NAM_Workflow_Name
        FROM
            inserted i
        WHERE
            i.WF_NAM_Workflow_Name is not null;
    END
    IF(UPDATE(WF_CFG_WF_ID))
        RAISERROR('The foreign key column WF_CFG_WF_ID is not updatable.', 16, 1);
    IF(UPDATE(WF_CFG_Workflow_Configuration))
    BEGIN
        INSERT INTO [metadata].[WF_CFG_Workflow_Configuration] (
            WF_CFG_WF_ID,
            WF_CFG_ChangedAt,
            WF_CFG_Workflow_Configuration
        )
        SELECT
            ISNULL(i.WF_CFG_WF_ID, i.WF_ID),
            cast(CASE
                WHEN i.WF_CFG_Workflow_Configuration is null THEN i.WF_CFG_ChangedAt
                WHEN UPDATE(WF_CFG_ChangedAt) THEN i.WF_CFG_ChangedAt
                ELSE @now
            END as datetime),
            i.WF_CFG_Workflow_Configuration
        FROM
            inserted i
        WHERE
            i.WF_CFG_Workflow_Configuration is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lWF_Workflow instead of DELETE trigger on lWF_Workflow
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lWF_Workflow] ON [metadata].[lWF_Workflow]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [metadata].[WF_NAM_Workflow_Name] [NAM]
    JOIN
        deleted d
    ON
        d.WF_NAM_WF_ID = [NAM].WF_NAM_WF_ID;
    DELETE [CFG]
    FROM
        [metadata].[WF_CFG_Workflow_Configuration] [CFG]
    JOIN
        deleted d
    ON
        d.WF_CFG_ChangedAt = [CFG].WF_CFG_ChangedAt
    AND
        d.WF_CFG_WF_ID = [CFG].WF_CFG_WF_ID;
    DELETE [WF]
    FROM
        [metadata].[WF_Workflow] [WF]
    LEFT JOIN
        [metadata].[WF_NAM_Workflow_Name] [NAM]
    ON
        [NAM].WF_NAM_WF_ID = [WF].WF_ID
    LEFT JOIN
        [metadata].[WF_CFG_Workflow_Configuration] [CFG]
    ON
        [CFG].WF_CFG_WF_ID = [WF].WF_ID
    WHERE
        [NAM].WF_NAM_WF_ID is null
    AND
        [CFG].WF_CFG_WF_ID is null;
END
GO
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each tie. There are four types of perspectives: latest,
-- point-in-time, difference, and now.
--
-- The latest perspective shows the latest available information for each tie.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-e perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dJB_of_WO_part', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dJB_of_WO_part];
IF Object_ID('metadata.nJB_of_WO_part', 'V') IS NOT NULL
DROP VIEW [metadata].[nJB_of_WO_part];
IF Object_ID('metadata.pJB_of_WO_part', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pJB_of_WO_part];
IF Object_ID('metadata.lJB_of_WO_part', 'V') IS NOT NULL
DROP VIEW [metadata].[lJB_of_WO_part];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lJB_of_WO_part viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lJB_of_WO_part] WITH SCHEMABINDING AS
SELECT
    tie.JB_ID_of,
    tie.WO_ID_part
FROM
    [metadata].[JB_of_WO_part] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pJB_of_WO_part viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pJB_of_WO_part] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.JB_ID_of,
    tie.WO_ID_part
FROM
    [metadata].[JB_of_WO_part] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nJB_of_WO_part viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nJB_of_WO_part]
AS
SELECT
    *
FROM
    [metadata].[pJB_of_WO_part](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dJB_formed_WF_from', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dJB_formed_WF_from];
IF Object_ID('metadata.nJB_formed_WF_from', 'V') IS NOT NULL
DROP VIEW [metadata].[nJB_formed_WF_from];
IF Object_ID('metadata.pJB_formed_WF_from', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pJB_formed_WF_from];
IF Object_ID('metadata.lJB_formed_WF_from', 'V') IS NOT NULL
DROP VIEW [metadata].[lJB_formed_WF_from];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lJB_formed_WF_from viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lJB_formed_WF_from] WITH SCHEMABINDING AS
SELECT
    tie.JB_ID_formed,
    tie.WF_ID_from
FROM
    [metadata].[JB_formed_WF_from] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pJB_formed_WF_from viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pJB_formed_WF_from] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.JB_ID_formed,
    tie.WF_ID_from
FROM
    [metadata].[JB_formed_WF_from] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nJB_formed_WF_from viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nJB_formed_WF_from]
AS
SELECT
    *
FROM
    [metadata].[pJB_formed_WF_from](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dWO_formed_SR_from', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dWO_formed_SR_from];
IF Object_ID('metadata.nWO_formed_SR_from', 'V') IS NOT NULL
DROP VIEW [metadata].[nWO_formed_SR_from];
IF Object_ID('metadata.pWO_formed_SR_from', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pWO_formed_SR_from];
IF Object_ID('metadata.lWO_formed_SR_from', 'V') IS NOT NULL
DROP VIEW [metadata].[lWO_formed_SR_from];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lWO_formed_SR_from viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lWO_formed_SR_from] WITH SCHEMABINDING AS
SELECT
    tie.WO_ID_formed,
    tie.SR_ID_from
FROM
    [metadata].[WO_formed_SR_from] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pWO_formed_SR_from viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pWO_formed_SR_from] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.WO_ID_formed,
    tie.SR_ID_from
FROM
    [metadata].[WO_formed_SR_from] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nWO_formed_SR_from viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nWO_formed_SR_from]
AS
SELECT
    *
FROM
    [metadata].[pWO_formed_SR_from](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dCO_target_CO_source_WO_involves', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dCO_target_CO_source_WO_involves];
IF Object_ID('metadata.nCO_target_CO_source_WO_involves', 'V') IS NOT NULL
DROP VIEW [metadata].[nCO_target_CO_source_WO_involves];
IF Object_ID('metadata.pCO_target_CO_source_WO_involves', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pCO_target_CO_source_WO_involves];
IF Object_ID('metadata.lCO_target_CO_source_WO_involves', 'V') IS NOT NULL
DROP VIEW [metadata].[lCO_target_CO_source_WO_involves];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lCO_target_CO_source_WO_involves viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lCO_target_CO_source_WO_involves] WITH SCHEMABINDING AS
SELECT
    tie.CO_ID_target,
    tie.CO_ID_source,
    tie.WO_ID_involves
FROM
    [metadata].[CO_target_CO_source_WO_involves] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pCO_target_CO_source_WO_involves viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pCO_target_CO_source_WO_involves] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.CO_ID_target,
    tie.CO_ID_source,
    tie.WO_ID_involves
FROM
    [metadata].[CO_target_CO_source_WO_involves] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nCO_target_CO_source_WO_involves viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nCO_target_CO_source_WO_involves]
AS
SELECT
    *
FROM
    [metadata].[pCO_target_CO_source_WO_involves](sysdatetime());
GO
-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent ties, only changes that represent values different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_JB_of_WO_part instead of INSERT trigger on JB_of_WO_part
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_JB_of_WO_part', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_JB_of_WO_part];
GO
CREATE TRIGGER [metadata].[it_JB_of_WO_part] ON [metadata].[JB_of_WO_part]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        JB_ID_of int not null,
        WO_ID_part int not null,
        primary key (
            JB_ID_of,
            WO_ID_part
        )
    );
    INSERT INTO @inserted
    SELECT
        i.JB_ID_of,
        i.WO_ID_part
    FROM
        inserted i
    WHERE
        i.JB_ID_of is not null
    AND
        i.WO_ID_part is not null;
    INSERT INTO [metadata].[JB_of_WO_part] (
        JB_ID_of,
        WO_ID_part
    )
    SELECT
        i.JB_ID_of,
        i.WO_ID_part
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[JB_of_WO_part] tie
    ON
        tie.JB_ID_of = i.JB_ID_of
    AND
        tie.WO_ID_part = i.WO_ID_part
    WHERE
        tie.WO_ID_part is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lJB_of_WO_part instead of INSERT trigger on lJB_of_WO_part
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lJB_of_WO_part] ON [metadata].[lJB_of_WO_part]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [metadata].[JB_of_WO_part] (
        JB_ID_of,
        WO_ID_part
    )
    SELECT
        i.JB_ID_of,
        i.WO_ID_part
    FROM
        inserted i; 
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lJB_of_WO_part instead of DELETE trigger on lJB_of_WO_part
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lJB_of_WO_part] ON [metadata].[lJB_of_WO_part]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [metadata].[JB_of_WO_part] tie
    JOIN
        deleted d
    ON
        d.JB_ID_of = tie.JB_ID_of
    AND
        d.WO_ID_part = tie.WO_ID_part;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_JB_formed_WF_from instead of INSERT trigger on JB_formed_WF_from
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_JB_formed_WF_from', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_JB_formed_WF_from];
GO
CREATE TRIGGER [metadata].[it_JB_formed_WF_from] ON [metadata].[JB_formed_WF_from]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        JB_ID_formed int not null,
        WF_ID_from int not null,
        primary key (
            JB_ID_formed
        )
    );
    INSERT INTO @inserted
    SELECT
        i.JB_ID_formed,
        i.WF_ID_from
    FROM
        inserted i
    WHERE
        i.JB_ID_formed is not null;
    INSERT INTO [metadata].[JB_formed_WF_from] (
        JB_ID_formed,
        WF_ID_from
    )
    SELECT
        i.JB_ID_formed,
        i.WF_ID_from
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[JB_formed_WF_from] tie
    ON
        tie.JB_ID_formed = i.JB_ID_formed
    WHERE
        tie.JB_ID_formed is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lJB_formed_WF_from instead of INSERT trigger on lJB_formed_WF_from
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lJB_formed_WF_from] ON [metadata].[lJB_formed_WF_from]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [metadata].[JB_formed_WF_from] (
        JB_ID_formed,
        WF_ID_from
    )
    SELECT
        i.JB_ID_formed,
        i.WF_ID_from
    FROM
        inserted i; 
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lJB_formed_WF_from instead of UPDATE trigger on lJB_formed_WF_from
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lJB_formed_WF_from] ON [metadata].[lJB_formed_WF_from]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(JB_ID_formed))
        RAISERROR('The identity column JB_ID_formed is not updatable.', 16, 1);
    INSERT INTO [metadata].[JB_formed_WF_from] (
        JB_ID_formed,
        WF_ID_from
    )
    SELECT
        i.JB_ID_formed,
        i.WF_ID_from
    FROM
        inserted i; 
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lJB_formed_WF_from instead of DELETE trigger on lJB_formed_WF_from
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lJB_formed_WF_from] ON [metadata].[lJB_formed_WF_from]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [metadata].[JB_formed_WF_from] tie
    JOIN
        deleted d
    ON
        d.JB_ID_formed = tie.JB_ID_formed;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_WO_formed_SR_from instead of INSERT trigger on WO_formed_SR_from
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_WO_formed_SR_from', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_WO_formed_SR_from];
GO
CREATE TRIGGER [metadata].[it_WO_formed_SR_from] ON [metadata].[WO_formed_SR_from]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        WO_ID_formed int not null,
        SR_ID_from int not null,
        primary key (
            WO_ID_formed
        )
    );
    INSERT INTO @inserted
    SELECT
        i.WO_ID_formed,
        i.SR_ID_from
    FROM
        inserted i
    WHERE
        i.WO_ID_formed is not null;
    INSERT INTO [metadata].[WO_formed_SR_from] (
        WO_ID_formed,
        SR_ID_from
    )
    SELECT
        i.WO_ID_formed,
        i.SR_ID_from
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[WO_formed_SR_from] tie
    ON
        tie.WO_ID_formed = i.WO_ID_formed
    WHERE
        tie.WO_ID_formed is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lWO_formed_SR_from instead of INSERT trigger on lWO_formed_SR_from
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lWO_formed_SR_from] ON [metadata].[lWO_formed_SR_from]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [metadata].[WO_formed_SR_from] (
        WO_ID_formed,
        SR_ID_from
    )
    SELECT
        i.WO_ID_formed,
        i.SR_ID_from
    FROM
        inserted i; 
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lWO_formed_SR_from instead of UPDATE trigger on lWO_formed_SR_from
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lWO_formed_SR_from] ON [metadata].[lWO_formed_SR_from]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(WO_ID_formed))
        RAISERROR('The identity column WO_ID_formed is not updatable.', 16, 1);
    INSERT INTO [metadata].[WO_formed_SR_from] (
        WO_ID_formed,
        SR_ID_from
    )
    SELECT
        i.WO_ID_formed,
        i.SR_ID_from
    FROM
        inserted i; 
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lWO_formed_SR_from instead of DELETE trigger on lWO_formed_SR_from
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lWO_formed_SR_from] ON [metadata].[lWO_formed_SR_from]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [metadata].[WO_formed_SR_from] tie
    JOIN
        deleted d
    ON
        d.WO_ID_formed = tie.WO_ID_formed;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_CO_target_CO_source_WO_involves instead of INSERT trigger on CO_target_CO_source_WO_involves
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_CO_target_CO_source_WO_involves', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_CO_target_CO_source_WO_involves];
GO
CREATE TRIGGER [metadata].[it_CO_target_CO_source_WO_involves] ON [metadata].[CO_target_CO_source_WO_involves]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        CO_ID_target int not null,
        CO_ID_source int not null,
        WO_ID_involves int not null,
        primary key (
            CO_ID_target,
            CO_ID_source
        )
    );
    INSERT INTO @inserted
    SELECT
        i.CO_ID_target,
        i.CO_ID_source,
        i.WO_ID_involves
    FROM
        inserted i
    WHERE
        i.CO_ID_target is not null
    AND
        i.CO_ID_source is not null;
    INSERT INTO [metadata].[CO_target_CO_source_WO_involves] (
        CO_ID_target,
        CO_ID_source,
        WO_ID_involves
    )
    SELECT
        i.CO_ID_target,
        i.CO_ID_source,
        i.WO_ID_involves
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[CO_target_CO_source_WO_involves] tie
    ON
        tie.CO_ID_target = i.CO_ID_target
    AND
        tie.CO_ID_source = i.CO_ID_source
    WHERE
        tie.CO_ID_source is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lCO_target_CO_source_WO_involves instead of INSERT trigger on lCO_target_CO_source_WO_involves
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lCO_target_CO_source_WO_involves] ON [metadata].[lCO_target_CO_source_WO_involves]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [metadata].[CO_target_CO_source_WO_involves] (
        CO_ID_target,
        CO_ID_source,
        WO_ID_involves
    )
    SELECT
        i.CO_ID_target,
        i.CO_ID_source,
        i.WO_ID_involves
    FROM
        inserted i; 
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lCO_target_CO_source_WO_involves instead of UPDATE trigger on lCO_target_CO_source_WO_involves
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lCO_target_CO_source_WO_involves] ON [metadata].[lCO_target_CO_source_WO_involves]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(CO_ID_target))
        RAISERROR('The identity column CO_ID_target is not updatable.', 16, 1);
    IF(UPDATE(CO_ID_source))
        RAISERROR('The identity column CO_ID_source is not updatable.', 16, 1);
    INSERT INTO [metadata].[CO_target_CO_source_WO_involves] (
        CO_ID_target,
        CO_ID_source,
        WO_ID_involves
    )
    SELECT
        i.CO_ID_target,
        i.CO_ID_source,
        i.WO_ID_involves
    FROM
        inserted i; 
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lCO_target_CO_source_WO_involves instead of DELETE trigger on lCO_target_CO_source_WO_involves
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lCO_target_CO_source_WO_involves] ON [metadata].[lCO_target_CO_source_WO_involves]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [metadata].[CO_target_CO_source_WO_involves] tie
    JOIN
        deleted d
    ON
        d.CO_ID_target = tie.CO_ID_target
    AND
        d.CO_ID_source = tie.CO_ID_source;
END
GO
-- SCHEMA EVOLUTION ---------------------------------------------------------------------------------------------------
--
-- The following tables, views, and functions are used to track schema changes
-- over time, as well as providing every XML that has been 'executed' against
-- the database.
--
-- Schema table -------------------------------------------------------------------------------------------------------
-- The schema table holds every xml that has been executed against the database
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Schema', 'U') IS NULL
   CREATE TABLE [metadata].[_Schema] (
      [version] int identity(1, 1) not null primary key,
      [activation] datetime2(7) not null,
      [schema] xml not null
   );
GO
-- Insert the XML schema (as of now)
INSERT INTO [metadata].[_Schema] (
   [activation],
   [schema]
)
SELECT
   current_timestamp,
   N'<schema format="0.98" date="2014-09-30" time="12:57:19"><metadata changingRange="datetime" encapsulation="metadata" identity="int" metadataPrefix="Metadata" metadataType="int" metadataUsage="false" changingSuffix="ChangedAt" identitySuffix="ID" positIdentity="int" positGenerator="true" positingRange="datetime" positingSuffix="PositedAt" positorRange="tinyint" positorSuffix="Positor" reliabilityRange="tinyint" reliabilitySuffix="Reliability" reliableCutoff="1" deleteReliability="0" reliableSuffix="Reliable" partitioning="false" entityIntegrity="true" restatability="false" idempotency="true" assertiveness="false" naming="improved" positSuffix="Posit" annexSuffix="Annex" chronon="datetime2(7)" now="sysdatetime()" dummySuffix="Dummy" versionSuffix="Version" statementTypeSuffix="StatementType" checksumSuffix="Checksum" businessViews="false" equivalence="false" equivalentSuffix="EQ" equivalentRange="tinyint" databaseTarget="SQLServer" temporalization="uni"/><knot mnemonic="TYP" descriptor="Type" identity="tinyint" dataRange="varchar(42)"><metadata capsule="metadata" generator="false"/><layout x="660.61" y="964.81" fixed="false"/></knot><anchor mnemonic="JB" descriptor="Job" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="STA" descriptor="Start" dataRange="datetime"><metadata capsule="metadata"/><layout x="774.27" y="157.76" fixed="false"/></attribute><attribute mnemonic="END" descriptor="End" dataRange="datetime"><metadata capsule="metadata"/><layout x="808.72" y="118.11" fixed="false"/></attribute><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(255)"><metadata capsule="metadata"/><layout x="837.04" y="264.77" fixed="false"/></attribute><layout x="810.67" y="210.93" fixed="false"/></anchor><anchor mnemonic="SR" descriptor="Source" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(2000)"><metadata capsule="metadata"/><layout x="432.83" y="235.37" fixed="false"/></attribute><attribute mnemonic="CFG" descriptor="Configuration" timeRange="datetime" dataRange="xml"><metadata capsule="metadata" checksum="true" restatable="false" idempotent="true"/><layout x="424.30" y="313.03" fixed="false"/></attribute><layout x="486.07" y="284.35" fixed="false"/></anchor><anchor mnemonic="CO" descriptor="Container" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(2000)"><metadata capsule="metadata"/><layout x="752.71" y="800.78" fixed="false"/></attribute><attribute mnemonic="TYP" descriptor="Type" knotRange="TYP"><metadata capsule="metadata"/><layout x="668.40" y="877.83" fixed="false"/></attribute><attribute mnemonic="PTH" descriptor="Path" dataRange="varchar(2000)"><metadata capsule="metadata"/><layout x="614.67" y="771.79" fixed="false"/></attribute><attribute mnemonic="DSC" descriptor="Discovered" dataRange="datetime"><metadata capsule="metadata"/><layout x="642.12" y="806.96" fixed="false"/></attribute><layout x="688.82" y="736.06" fixed="false"/></anchor><anchor mnemonic="WO" descriptor="Work" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="STA" descriptor="Start" dataRange="datetime"><metadata capsule="metadata"/><layout x="727.57" y="408.40" fixed="false"/></attribute><attribute mnemonic="END" descriptor="End" dataRange="datetime"><metadata capsule="metadata"/><layout x="723.51" y="444.19" fixed="true"/></attribute><attribute mnemonic="UPD" descriptor="Updates" dataRange="int"><metadata capsule="metadata"/><layout x="530.34" y="449.87" fixed="false"/></attribute><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(255)"><metadata capsule="metadata"/><layout x="718.22" y="473.64" fixed="true"/></attribute><attribute mnemonic="INS" descriptor="Inserts" dataRange="int"><metadata capsule="metadata"/><layout x="502.03" y="422.82" fixed="true"/></attribute><attribute mnemonic="DEL" descriptor="Deletes" dataRange="int"><metadata capsule="metadata"/><layout x="580.05" y="487.99" fixed="true"/></attribute><attribute mnemonic="USR" descriptor="InvocationUser" dataRange="varchar(555)"><metadata capsule="metadata"/><layout x="717.12" y="512.74" fixed="true"/></attribute><attribute mnemonic="ROL" descriptor="InvocationRole" dataRange="varchar(42)"><metadata capsule="metadata"/><layout x="722.74" y="552.04" fixed="true"/></attribute><attribute mnemonic="EST" descriptor="ExecutionStatus" timeRange="datetime" knotRange="EST"><metadata capsule="metadata" restatable="false" idempotent="true"/><layout x="581.43" y="537.07" fixed="true"/></attribute><attribute mnemonic="ERL" descriptor="ErrorLine" dataRange="int"><metadata capsule="metadata"/><layout x="753.90" y="365.32" fixed="true"/></attribute><attribute mnemonic="ERM" descriptor="ErrorMessage" dataRange="varchar(555)"><metadata capsule="metadata"/><layout x="759.07" y="338.76" fixed="true"/></attribute><layout x="645.14" y="439.29" fixed="false"/></anchor><anchor mnemonic="WF" descriptor="Workflow" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(255)"><metadata capsule="metadata"/><layout x="875.45" y="-3.10" fixed="false"/></attribute><attribute mnemonic="CFG" descriptor="Configuration" timeRange="datetime" dataRange="xml"><metadata capsule="metadata" checksum="true" restatable="false" idempotent="true"/><layout x="933.60" y="-0.03" fixed="false"/></attribute><layout x="887.35" y="37.98" fixed="true"/></anchor><tie><anchorRole role="of" type="JB" identifier="true"/><anchorRole role="part" type="WO" identifier="true"/><metadata capsule="metadata"/><layout x="732.11" y="303.88" fixed="false"/></tie><tie><anchorRole role="formed" type="JB" identifier="true"/><anchorRole role="from" type="WF" identifier="false"/><metadata capsule="metadata"/><layout x="866.17" y="118.41" fixed="false"/></tie><tie><anchorRole role="formed" type="WO" identifier="true"/><anchorRole role="from" type="SR" identifier="false"/><metadata capsule="metadata"/><layout x="547.73" y="353.65" fixed="false"/></tie><tie><anchorRole role="target" type="CO" identifier="true"/><anchorRole role="source" type="CO" identifier="true"/><anchorRole role="involves" type="WO" identifier="false"/><metadata capsule="metadata"/><layout x="661.91" y="609.13" fixed="true"/></tie><knot mnemonic="EST" descriptor="ExecutionStatus" identity="tinyint" dataRange="varchar(42)"><metadata capsule="metadata" generator="false"/><layout x="496.45" y="562.96" fixed="false"/></knot></schema>';
GO
-- Schema expanded view -----------------------------------------------------------------------------------------------
-- A view of the schema table that expands the XML attributes into columns
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Schema_Expanded', 'V') IS NOT NULL
DROP VIEW [metadata].[_Schema_Expanded]
GO
CREATE VIEW [metadata].[_Schema_Expanded]
AS
SELECT
	[version],
	[activation],
	[schema],
	[schema].value('schema[1]/@format', 'nvarchar(max)') as [format],
	[schema].value('schema[1]/@date', 'date') as [date],
	[schema].value('schema[1]/@time', 'time(0)') as [time],
	[schema].value('schema[1]/metadata[1]/@temporalization', 'nvarchar(max)') as [temporalization], 
	[schema].value('schema[1]/metadata[1]/@databaseTarget', 'nvarchar(max)') as [databaseTarget],
	[schema].value('schema[1]/metadata[1]/@changingRange', 'nvarchar(max)') as [changingRange],
	[schema].value('schema[1]/metadata[1]/@encapsulation', 'nvarchar(max)') as [encapsulation],
	[schema].value('schema[1]/metadata[1]/@identity', 'nvarchar(max)') as [identity],
	[schema].value('schema[1]/metadata[1]/@metadataPrefix', 'nvarchar(max)') as [metadataPrefix],
	[schema].value('schema[1]/metadata[1]/@metadataType', 'nvarchar(max)') as [metadataType],
	[schema].value('schema[1]/metadata[1]/@metadataUsage', 'nvarchar(max)') as [metadataUsage],
	[schema].value('schema[1]/metadata[1]/@changingSuffix', 'nvarchar(max)') as [changingSuffix],
	[schema].value('schema[1]/metadata[1]/@identitySuffix', 'nvarchar(max)') as [identitySuffix],
	[schema].value('schema[1]/metadata[1]/@positIdentity', 'nvarchar(max)') as [positIdentity],
	[schema].value('schema[1]/metadata[1]/@positGenerator', 'nvarchar(max)') as [positGenerator],
	[schema].value('schema[1]/metadata[1]/@positingRange', 'nvarchar(max)') as [positingRange],
	[schema].value('schema[1]/metadata[1]/@positingSuffix', 'nvarchar(max)') as [positingSuffix],
	[schema].value('schema[1]/metadata[1]/@positorRange', 'nvarchar(max)') as [positorRange],
	[schema].value('schema[1]/metadata[1]/@positorSuffix', 'nvarchar(max)') as [positorSuffix],
	[schema].value('schema[1]/metadata[1]/@reliabilityRange', 'nvarchar(max)') as [reliabilityRange],
	[schema].value('schema[1]/metadata[1]/@reliabilitySuffix', 'nvarchar(max)') as [reliabilitySuffix],
	[schema].value('schema[1]/metadata[1]/@reliableCutoff', 'nvarchar(max)') as [reliableCutoff],
	[schema].value('schema[1]/metadata[1]/@deleteReliability', 'nvarchar(max)') as [deleteReliability],
	[schema].value('schema[1]/metadata[1]/@reliableSuffix', 'nvarchar(max)') as [reliableSuffix],
	[schema].value('schema[1]/metadata[1]/@partitioning', 'nvarchar(max)') as [partitioning],
	[schema].value('schema[1]/metadata[1]/@entityIntegrity', 'nvarchar(max)') as [entityIntegrity],
	[schema].value('schema[1]/metadata[1]/@restatability', 'nvarchar(max)') as [restatability],
	[schema].value('schema[1]/metadata[1]/@idempotency', 'nvarchar(max)') as [idempotency],
	[schema].value('schema[1]/metadata[1]/@assertiveness', 'nvarchar(max)') as [assertiveness],
	[schema].value('schema[1]/metadata[1]/@naming', 'nvarchar(max)') as [naming],
	[schema].value('schema[1]/metadata[1]/@positSuffix', 'nvarchar(max)') as [positSuffix],
	[schema].value('schema[1]/metadata[1]/@annexSuffix', 'nvarchar(max)') as [annexSuffix],
	[schema].value('schema[1]/metadata[1]/@chronon', 'nvarchar(max)') as [chronon],
	[schema].value('schema[1]/metadata[1]/@now', 'nvarchar(max)') as [now],
	[schema].value('schema[1]/metadata[1]/@dummySuffix', 'nvarchar(max)') as [dummySuffix],
	[schema].value('schema[1]/metadata[1]/@statementTypeSuffix', 'nvarchar(max)') as [statementTypeSuffix],
	[schema].value('schema[1]/metadata[1]/@checksumSuffix', 'nvarchar(max)') as [checksumSuffix],
	[schema].value('schema[1]/metadata[1]/@businessViews', 'nvarchar(max)') as [businessViews],
	[schema].value('schema[1]/metadata[1]/@equivalence', 'nvarchar(max)') as [equivalence],
	[schema].value('schema[1]/metadata[1]/@equivalentSuffix', 'nvarchar(max)') as [equivalentSuffix],
	[schema].value('schema[1]/metadata[1]/@equivalentRange', 'nvarchar(max)') as [equivalentRange]
FROM 
	_Schema;
GO
-- Anchor view --------------------------------------------------------------------------------------------------------
-- The anchor view shows information about all the anchors in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Anchor', 'V') IS NOT NULL
DROP VIEW [metadata].[_Anchor]
GO
CREATE VIEW [metadata].[_Anchor]
AS
SELECT
   S.version,
   S.activation,
   Nodeset.anchor.value('concat(@mnemonic, "_", @descriptor)', 'nvarchar(max)') as [name],
   Nodeset.anchor.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.anchor.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.anchor.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.anchor.value('@identity', 'nvarchar(max)') as [identity],
   Nodeset.anchor.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.anchor.value('count(attribute)', 'int') as [numberOfAttributes]
FROM
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as Nodeset(anchor);
GO
-- Knot view ----------------------------------------------------------------------------------------------------------
-- The knot view shows information about all the knots in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Knot', 'V') IS NOT NULL
DROP VIEW [metadata].[_Knot]
GO
CREATE VIEW [metadata].[_Knot]
AS
SELECT
   S.version,
   S.activation,
   Nodeset.knot.value('concat(@mnemonic, "_", @descriptor)', 'nvarchar(max)') as [name],
   Nodeset.knot.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.knot.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.knot.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.knot.value('@identity', 'nvarchar(max)') as [identity],
   Nodeset.knot.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.knot.value('@dataRange', 'nvarchar(max)') as [dataRange],
   isnull(Nodeset.knot.value('metadata[1]/@checksum', 'nvarchar(max)'), 'false') as [checksum],
   isnull(Nodeset.knot.value('metadata[1]/@equivalent', 'nvarchar(max)'), 'false') as [equivalent]
FROM
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/knot') as Nodeset(knot);
GO
-- Attribute view -----------------------------------------------------------------------------------------------------
-- The attribute view shows information about all the attributes in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Attribute', 'V') IS NOT NULL
DROP VIEW [metadata].[_Attribute]
GO
CREATE VIEW [metadata].[_Attribute]
AS
SELECT
   S.version,
   S.activation,
   ParentNodeset.anchor.value('concat(@mnemonic, "_")', 'nvarchar(max)') +
   Nodeset.attribute.value('concat(@mnemonic, "_")', 'nvarchar(max)') +
   ParentNodeset.anchor.value('concat(@descriptor, "_")', 'nvarchar(max)') +
   Nodeset.attribute.value('@descriptor', 'nvarchar(max)') as [name],
   Nodeset.attribute.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.attribute.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.attribute.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.attribute.value('@identity', 'nvarchar(max)') as [identity],
   isnull(Nodeset.attribute.value('metadata[1]/@equivalent', 'nvarchar(max)'), 'false') as [equivalent],
   Nodeset.attribute.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.attribute.value('metadata[1]/@assertive', 'nvarchar(max)') as [assertive],
   isnull(Nodeset.attribute.value('metadata[1]/@checksum', 'nvarchar(max)'), 'false') as [checksum],
   Nodeset.attribute.value('metadata[1]/@restatable', 'nvarchar(max)') as [restatable],
   Nodeset.attribute.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent],
   ParentNodeset.anchor.value('@mnemonic', 'nvarchar(max)') as [anchorMnemonic],
   ParentNodeset.anchor.value('@descriptor', 'nvarchar(max)') as [anchorDescriptor],
   ParentNodeset.anchor.value('@identity', 'nvarchar(max)') as [anchorIdentity],
   Nodeset.attribute.value('@dataRange', 'nvarchar(max)') as [dataRange],
   Nodeset.attribute.value('@knotRange', 'nvarchar(max)') as [knotRange],
   Nodeset.attribute.value('@timeRange', 'nvarchar(max)') as [timeRange]
FROM
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as ParentNodeset(anchor)
OUTER APPLY
   ParentNodeset.anchor.nodes('attribute') as Nodeset(attribute);
GO
-- Tie view -----------------------------------------------------------------------------------------------------------
-- The tie view shows information about all the ties in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Tie', 'V') IS NOT NULL
DROP VIEW [metadata].[_Tie]
GO
CREATE VIEW [metadata].[_Tie]
AS
SELECT
   S.version,
   S.activation,
   REPLACE(Nodeset.tie.query('
      for $role in *[local-name() = "anchorRole" or local-name() = "knotRole"]
      return concat($role/@type, "_", $role/@role)
   ').value('.', 'nvarchar(max)'), ' ', '_') as [name],
   Nodeset.tie.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.tie.value('count(anchorRole) + count(knotRole)', 'int') as [numberOfRoles],
   Nodeset.tie.query('
      for $role in *[local-name() = "anchorRole" or local-name() = "knotRole"]
      return string($role/@role)
   ').value('.', 'nvarchar(max)') as [roles],
   Nodeset.tie.value('count(anchorRole)', 'int') as [numberOfAnchors],
   Nodeset.tie.query('
      for $role in anchorRole
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [anchors],
   Nodeset.tie.value('count(knotRole)', 'int') as [numberOfKnots],
   Nodeset.tie.query('
      for $role in knotRole
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [knots],
   Nodeset.tie.value('count(*[local-name() = "anchorRole" or local-name() = "knotRole"][@identifier = "true"])', 'int') as [numberOfIdentifiers],
   Nodeset.tie.query('
      for $role in *[local-name() = "anchorRole" or local-name() = "knotRole"][@identifier = "true"]
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [identifiers],
   Nodeset.tie.value('@timeRange', 'nvarchar(max)') as [timeRange],
   Nodeset.tie.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.tie.value('metadata[1]/@assertive', 'nvarchar(max)') as [assertive],
   Nodeset.tie.value('metadata[1]/@restatable', 'nvarchar(max)') as [restatable],
   Nodeset.tie.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent]
FROM
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/tie') as Nodeset(tie);
GO
-- Evolution function -------------------------------------------------------------------------------------------------
-- The evolution function shows what the schema looked like at the given
-- point in time with additional information about missing or added
-- modeling components since that time.
--
-- @timepoint The point in time to which you would like to travel.
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Evolution', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[_Evolution];
GO
CREATE FUNCTION [metadata].[_Evolution] (
    @timepoint AS DATETIME2(7)
)
RETURNS TABLE
RETURN
SELECT
   V.[version],
   ISNULL(S.[name], T.[name]) AS [name],
   ISNULL(V.[activation], T.[create_date]) AS [activation],
   CASE
      WHEN S.[name] is null THEN
         CASE
            WHEN T.[create_date] > (
               SELECT
                  ISNULL(MAX([activation]), @timepoint)
               FROM
                  [metadata].[_Schema]
               WHERE
                  [activation] <= @timepoint
            ) THEN 'Future'
            ELSE 'Past'
         END
      WHEN T.[name] is null THEN 'Missing'
      ELSE 'Present'
   END AS Existence
FROM (
   SELECT
      MAX([version]) as [version],
      MAX([activation]) as [activation]
   FROM
      [metadata].[_Schema]
   WHERE
      [activation] <= @timepoint
) V
JOIN (
   SELECT
      [name],
      [version]
   FROM
      [metadata].[_Anchor] a
   UNION ALL
   SELECT
      [name],
      [version]
   FROM
      [metadata].[_Knot] k
   UNION ALL
   SELECT
      [name],
      [version]
   FROM
      [metadata].[_Attribute] b
   UNION ALL
   SELECT
      [name],
      [version]
   FROM
      [metadata].[_Tie] t
) S
ON
   S.[version] = V.[version]
FULL OUTER JOIN (
   SELECT
      [name],
      [create_date]
   FROM
      sys.tables
   WHERE
      [type] like '%U%'
   AND
      LEFT([name], 1) <> '_'
) T
ON
   S.[name] = T.[name];
GO
-- Drop Script Generator ----------------------------------------------------------------------------------------------
-- generates a drop script, that must be run separately, dropping everything in an Anchor Modeled database
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._GenerateDropScript', 'P') IS NOT NULL
DROP PROCEDURE [metadata].[_GenerateDropScript];
GO
CREATE PROCEDURE [metadata]._GenerateDropScript (
   @exclusionPattern varchar(42) = '[_]%', -- exclude Metadata by default
   @inclusionPattern varchar(42) = '%' -- include everything by default
)
AS
BEGIN
   DECLARE @xml XML;
   WITH objects AS (
      SELECT
         'DROP ' + ft.[type] + ' ' + fn.[name] + '; -- ' + fn.[description] as [statement],
         row_number() OVER (
            ORDER BY
               -- restatement finders last
               CASE dc.[description]
                  WHEN 'restatement finder' THEN 1
                  ELSE 0
               END ASC,
               -- order based on type
               CASE ft.[type]
                  WHEN 'PROCEDURE' THEN 1
                  WHEN 'FUNCTION' THEN 2
                  WHEN 'VIEW' THEN 3
                  WHEN 'TABLE' THEN 4
                  ELSE 5
               END ASC,
               -- order within type
               CASE dc.[description]
                  WHEN 'key generator' THEN 1
                  WHEN 'latest perspective' THEN 2
                  WHEN 'current perspective' THEN 3
                  WHEN 'difference perspective' THEN 4
                  WHEN 'point-in-time perspective' THEN 5
                  WHEN 'time traveler' THEN 6
                  WHEN 'rewinder' THEN 7
                  WHEN 'assembled view' THEN 8
                  WHEN 'annex table' THEN 9
                  WHEN 'posit table' THEN 10
                  WHEN 'table' THEN 11
                  WHEN 'restatement finder' THEN 12
                  ELSE 13
               END,
               -- order within description
               CASE ft.[type]
                  WHEN 'TABLE' THEN
                     CASE cl.[class]
                        WHEN 'Attribute' THEN 1
                        WHEN 'Attribute Annex' THEN 2
                        WHEN 'Attribute Posit' THEN 3
                        WHEN 'Tie' THEN 4
                        WHEN 'Anchor' THEN 5
                        WHEN 'Knot' THEN 6
                        ELSE 7
                     END
                  ELSE
                     CASE cl.[class]
                        WHEN 'Anchor' THEN 1
                        WHEN 'Attribute' THEN 2
                        WHEN 'Attribute Annex' THEN 3
                        WHEN 'Attribute Posit' THEN 4
                        WHEN 'Tie' THEN 5
                        WHEN 'Knot' THEN 6
                        ELSE 7
                     END
               END,
               -- finally alphabetically
               o.[name] ASC
         ) AS [ordinal]
      FROM
         sys.objects o
      JOIN
         sys.schemas s
      ON
         s.[schema_id] = o.[schema_id]
      CROSS APPLY (
         SELECT
            CASE
               WHEN o.[name] LIKE '[_]%'
               COLLATE Latin1_General_BIN THEN 'Metadata'
               WHEN o.[name] LIKE '%[A-Z][A-Z][_][a-z]%[A-Z][A-Z][_][a-z]%'
               COLLATE Latin1_General_BIN THEN 'Tie'
               WHEN o.[name] LIKE '%[A-Z][A-Z][_][A-Z][A-Z][A-Z][_][A-Z]%[_]%'
               COLLATE Latin1_General_BIN THEN 'Attribute'
               WHEN o.[name] LIKE '%[A-Z][A-Z][A-Z][_][A-Z]%'
               COLLATE Latin1_General_BIN THEN 'Knot'
               WHEN o.[name] LIKE '%[A-Z][A-Z][_][A-Z]%'
               COLLATE Latin1_General_BIN THEN 'Anchor'
               ELSE 'Other'
            END
      ) cl ([class])
      CROSS APPLY (
         SELECT
            CASE o.[type]
               WHEN 'P' THEN 'PROCEDURE'
               WHEN 'IF' THEN 'FUNCTION'
               WHEN 'FN' THEN 'FUNCTION'
               WHEN 'V' THEN 'VIEW'
               WHEN 'U' THEN 'TABLE'
            END
      ) ft ([type])
      CROSS APPLY (
         SELECT
            CASE
               WHEN ft.[type] = 'PROCEDURE' AND cl.[class] = 'Anchor' AND o.[name] LIKE 'k%'
               COLLATE Latin1_General_BIN THEN 'key generator'
               WHEN ft.[type] = 'FUNCTION' AND o.[name] LIKE 't%'
               COLLATE Latin1_General_BIN THEN 'time traveler'
               WHEN ft.[type] = 'FUNCTION' AND o.[name] LIKE 'rf%'
               COLLATE Latin1_General_BIN THEN 'restatement finder'
               WHEN ft.[type] = 'FUNCTION' AND o.[name] LIKE 'r%'
               COLLATE Latin1_General_BIN THEN 'rewinder'
               WHEN ft.[type] = 'VIEW' AND o.[name] LIKE 'l%'
               COLLATE Latin1_General_BIN THEN 'latest perspective'
               WHEN ft.[type] = 'FUNCTION' AND o.[name] LIKE 'p%'
               COLLATE Latin1_General_BIN THEN 'point-in-time perspective'
               WHEN ft.[type] = 'VIEW' AND o.[name] LIKE 'n%'
               COLLATE Latin1_General_BIN THEN 'current perspective'
               WHEN ft.[type] = 'FUNCTION' AND o.[name] LIKE 'd%'
               COLLATE Latin1_General_BIN THEN 'difference perspective'
               WHEN ft.[type] = 'VIEW' AND cl.[class] = 'Attribute'
               COLLATE Latin1_General_BIN THEN 'assembled view'
               WHEN ft.[type] = 'TABLE' AND o.[name] LIKE '%Annex'
               COLLATE Latin1_General_BIN THEN 'annex table'
               WHEN ft.[type] = 'TABLE' AND o.[name] LIKE '%Posit'
               COLLATE Latin1_General_BIN THEN 'posit table'
               WHEN ft.[type] = 'TABLE'
               COLLATE Latin1_General_BIN THEN 'table'
               ELSE 'other'
            END
      ) dc ([description])
      CROSS APPLY (
         SELECT
            s.[name] + '.' + o.[name],
            cl.[class] + ' ' + dc.[description]
      ) fn ([name], [description])
      WHERE
         o.[type] IN ('P', 'IF', 'FN', 'V', 'U')
      AND
         o.[name] NOT LIKE ISNULL(@exclusionPattern, '')
      AND
         o.[name] LIKE ISNULL(@inclusionPattern, '%')
   )
   SELECT @xml = (
       SELECT
          [statement] + CHAR(13) as [text()]
       FROM
          objects
       ORDER BY
          [ordinal]
       FOR XML PATH('')
   );
   SELECT isnull(@xml.value('.', 'varchar(max)'), ''); 
END
GO
-- Database Copy Script Generator -------------------------------------------------------------------------------------
-- generates a copy script, that must be run separately, copying all data between two identically modeled databases
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._GenerateCopyScript', 'P') IS NOT NULL
DROP PROCEDURE [metadata].[_GenerateCopyScript];
GO
CREATE PROCEDURE [metadata]._GenerateCopyScript (
	@source varchar(123),
	@target varchar(123)
)
as 
begin
	declare @R char(1) = CHAR(13);
	-- stores the built SQL code
	declare @sql varchar(max) = 'USE ' + @target + ';' + @R;
	declare @xml xml;
	-- find which version of the schema that is in effect
	declare @version int;
	select 
		@version = max([version]) 
	from
		_Schema;
	-- declare and set other variables we need
	declare @equivalentSuffix varchar(42);
	declare @identitySuffix varchar(42);
	declare @annexSuffix varchar(42);
	declare @positSuffix varchar(42);
	declare @temporalization varchar(42);
	select
		@equivalentSuffix = equivalentSuffix,
		@identitySuffix = identitySuffix,
		@annexSuffix = annexSuffix,
		@positSuffix = positSuffix,
		@temporalization = temporalization
	from
		_Schema_Expanded 
	where
		[version] = @version;
	-- build non-equivalent knot copy
	set @xml = (
		select 
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' ON;' + @R 
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' OFF;' + @R 
			end
		from 
			_Knot x
		cross apply (
			select stuff((
				select 
					', ' + [name]
				from
					sys.columns 
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		and
			isnull(equivalent, 'false') = 'false'
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build equivalent knot copy
	set @xml = (
		select 
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @identitySuffix + ' ON;' + @R 
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @identitySuffix + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @identitySuffix + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @identitySuffix + ' OFF;' + @R 
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @equivalentSuffix + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @equivalentSuffix + ';' + @R
		from 
			_Knot x
		cross apply (
			select stuff((
				select 
					', ' + [name]
				from
					sys.columns 
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		and
			isnull(equivalent, 'false') = 'true'
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build anchor copy
	set @xml = (
		select 
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' ON;' + @R 
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' OFF;' + @R 
			end
		from 
			_Anchor x
		cross apply (
			select stuff((
				select 
					', ' + [name]
				from
					sys.columns 
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build attribute copy
	if (@temporalization = 'crt')
	begin
		set @xml = (
			select 
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' ON;' + @R 
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @positSuffix + '(' + [positColumns] + ')' + @R +
				'SELECT ' + [positColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @positSuffix + ';' + @R,
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' OFF;' + @R 
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @annexSuffix + '(' + [annexColumns] + ')' + @R +
				'SELECT ' + [annexColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @annexSuffix + ';' + @R
			from 
				_Attribute x
			cross apply (
				select stuff((
					select 
						', ' + [name]
					from
						sys.columns 
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @positSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) pc ([positColumns])
			cross apply (
				select stuff((
					select 
						', ' + [name]
					from
						sys.columns 
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @annexSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) ac ([annexColumns])
			where
				[version] = @version
			for xml path('')
		);
	end
	else -- uni
	begin
		set @xml = (
			select 
				'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
				'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R
			from 
				_Attribute x
			cross apply (
				select stuff((
					select 
						', ' + [name]
					from
						sys.columns 
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) c ([columns])
			where
				[version] = @version
			for xml path('')
		);
	end
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build tie copy
	if (@temporalization = 'crt')
	begin
		set @xml = (
			select 
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' ON;' + @R 
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @positSuffix + '(' + [positColumns] + ')' + @R +
				'SELECT ' + [positColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @positSuffix + ';' + @R,
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' OFF;' + @R 
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @annexSuffix + '(' + [annexColumns] + ')' + @R +
				'SELECT ' + [annexColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @annexSuffix + ';' + @R
			from 
				_Tie x
			cross apply (
				select stuff((
					select 
						', ' + [name]
					from
						sys.columns 
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @positSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) pc ([positColumns])
			cross apply (
				select stuff((
					select 
						', ' + [name]
					from
						sys.columns 
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @annexSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) ac ([annexColumns])
			where
				[version] = @version
			for xml path('')
		);
	end
	else -- uni
	begin
		set @xml = (
			select 
				'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
				'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R
			from 
				_Tie x
			cross apply (
				select stuff((
					select 
						', ' + [name]
					from
						sys.columns 
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) c ([columns])
			where
				[version] = @version
			for xml path('')
		);
	end
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	select @sql;
end
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------