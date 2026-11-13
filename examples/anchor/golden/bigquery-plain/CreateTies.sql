-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- BigQuery has no unique constraints: a tie without identifiers is one to one because the load keeps it so.
--
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_partner_AC_with_ONG_currently` (
    `AC_ID_partner` int64 not null, 
    `AC_ID_with` int64 not null, 
    `ONG_ID_currently` int64 not null,
    `AC_partner_AC_with_ONG_currently_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_ID_partner`,
        `AC_ID_with`,
        `ONG_ID_currently`,
        `AC_partner_AC_with_ONG_currently_ChangedAt`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_fkAC_partner` FOREIGN KEY (`AC_ID_partner`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_fkAC_with` FOREIGN KEY (`AC_ID_with`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_fkONG_currently` FOREIGN KEY (`ONG_ID_currently`) REFERENCES
        public.`ONG_Ongoing`(`ONG_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_partner`
;
-- Static tie table ---------------------------------------------------------------------------------------------------
-- AC_subset_PN_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_subset_PN_of` (
    `AC_ID_subset` int64 not null, 
    `PN_ID_of` int64 not null, 
    PRIMARY KEY (
        `AC_ID_subset`,
        `PN_ID_of`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_fkAC_subset` FOREIGN KEY (`AC_ID_subset`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_fkPN_of` FOREIGN KEY (`PN_ID_of`) REFERENCES
        public.`PN_Person`(`PN_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_subset`
;
-- Static tie table ---------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_in_AC_wasCast` (
    `EV_ID_in` int64 not null, 
    `AC_ID_wasCast` int64 not null, 
    PRIMARY KEY (
        `EV_ID_in`,
        `AC_ID_wasCast`
    ) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_wasCast_fkEV_in` FOREIGN KEY (`EV_ID_in`) REFERENCES
        public.`EV_Event`(`EV_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_wasCast_fkAC_wasCast` FOREIGN KEY (`AC_ID_wasCast`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY
    `EV_ID_in`
;
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_part_PR_in_RAT_got` (
    `AC_ID_part` int64 not null, 
    `PR_ID_in` int64 not null, 
    `RAT_ID_got` int64 not null,
    `AC_part_PR_in_RAT_got_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_ID_part`,
        `PR_ID_in`,
        `AC_part_PR_in_RAT_got_ChangedAt`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_fkAC_part` FOREIGN KEY (`AC_ID_part`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_fkPR_in` FOREIGN KEY (`PR_ID_in`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_fkRAT_got` FOREIGN KEY (`RAT_ID_got`) REFERENCES
        public.`RAT_Rating`(`RAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_part`
;
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_at_PR_isPlaying` (
    `ST_ID_at` int64 not null, 
    `PR_ID_isPlaying` int64 not null, 
    `ST_at_PR_isPlaying_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_ID_at`,
        `PR_ID_isPlaying`,
        `ST_at_PR_isPlaying_ChangedAt`
    ) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_isPlaying_fkST_at` FOREIGN KEY (`ST_ID_at`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_isPlaying_fkPR_isPlaying` FOREIGN KEY (`PR_ID_isPlaying`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY
    `ST_ID_at`
;
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_parent_AC_child_PAT_having` (
    `AC_ID_parent` int64 not null, 
    `AC_ID_child` int64 not null, 
    `PAT_ID_having` int64 not null,
    PRIMARY KEY (
        `AC_ID_parent`,
        `AC_ID_child`,
        `PAT_ID_having`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_fkAC_parent` FOREIGN KEY (`AC_ID_parent`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_fkAC_child` FOREIGN KEY (`AC_ID_child`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_fkPAT_having` FOREIGN KEY (`PAT_ID_having`) REFERENCES
        public.`PAT_ParentalType`(`PAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_parent`
;
-- Static tie table ---------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`PR_content_ST_location_EV_of` (
    `PR_ID_content` int64 not null, 
    `ST_ID_location` int64 not null, 
    `EV_ID_of` int64 not null, 
    PRIMARY KEY (
        `EV_ID_of`
    ) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_fkPR_content` FOREIGN KEY (`PR_ID_content`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_fkST_location` FOREIGN KEY (`ST_ID_location`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_fkEV_of` FOREIGN KEY (`EV_ID_of`) REFERENCES
        public.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY
    `PR_ID_content`
;
