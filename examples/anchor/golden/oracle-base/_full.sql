-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PAT_ParentalType table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.PAT_ParentalType (
            PAT_ID number(3) not null,
            PAT_ParentalType nvarchar2(42) not null,
            Metadata_PAT number(10) not null,
            constraint PK_PAT_ParentalType primary key (
                PAT_ID
            ),
            constraint UK_PAT_ParentalType unique (
                PAT_ParentalType
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Gender table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.GEN_Gender (
            GEN_ID number(3) not null,
            GEN_Gender nvarchar2(42) not null,
            Metadata_GEN number(10) not null,
            constraint PK_GEN_Gender primary key (
                GEN_ID
            ),
            constraint UK_GEN_Gender unique (
                GEN_Gender
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.PLV_ProfessionalLevel (
            PLV_ID number(3) not null,
            PLV_ProfessionalLevel nclob not null,
            Metadata_PLV number(10) not null,
            constraint PK_PLV_ProfessionalLevel primary key (
                PLV_ID
            ),
            constraint UK_PLV_ProfessionalLevel unique (
                PLV_ProfessionalLevel
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.UTL_Utilization (
            UTL_ID number(3) not null,
            UTL_Utilization number(3) not null,
            Metadata_UTL number(10) not null,
            constraint PK_UTL_Utilization primary key (
                UTL_ID
            ),
            constraint UK_UTL_Utilization unique (
                UTL_Utilization
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Ongoing table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.ONG_Ongoing (
            ONG_ID number(3) not null,
            ONG_Ongoing nvarchar2(3) not null,
            Metadata_ONG number(10) not null,
            constraint PK_ONG_Ongoing primary key (
                ONG_ID
            ),
            constraint UK_ONG_Ongoing unique (
                ONG_Ongoing
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Rating table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.RAT_Rating (
            RAT_ID number(3) not null,
            RAT_Rating nvarchar2(42) not null,
            Metadata_RAT number(10) not null,
            constraint PK_RAT_Rating primary key (
                RAT_ID
            ),
            constraint UK_RAT_Rating unique (
                RAT_Rating
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.ETY_EventType (
            ETY_ID number(3) not null,
            ETY_EventType nvarchar2(42) not null,
            Metadata_ETY number(10) not null,
            constraint PK_ETY_EventType primary key (
                ETY_ID
            ),
            constraint UK_ETY_EventType unique (
                ETY_EventType
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
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
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.PN_Person (
            PN_ID number(10) GENERATED BY DEFAULT ON NULL AS IDENTITY not null, 
            Metadata_PN number(10) not null, 
            constraint PK_PN_Person primary key (
                PN_ID
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.ST_Stage (
            ST_ID number(10) GENERATED BY DEFAULT ON NULL AS IDENTITY not null, 
            Metadata_ST number(10) not null, 
            constraint PK_ST_Stage primary key (
                ST_ID
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.ST_NAM_Stage_Name (
            ST_NAM_ST_ID number(10) not null,
            ST_NAM_Stage_Name nvarchar2(42) not null,
            ST_NAM_ChangedAt timestamp not null,
            Metadata_ST_NAM number(10) not null,
            constraint FK_ST_NAM_Stage_Name foreign key (
                ST_NAM_ST_ID
            ) references public.ST_Stage(ST_ID),
            constraint PK_ST_NAM_Stage_Name primary key (
                ST_NAM_ST_ID,
                ST_NAM_ChangedAt
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.ST_LOC_Stage_Location (
            ST_LOC_ST_ID number(10) not null,
            ST_LOC_Stage_Location geography not null,
            Metadata_ST_LOC number(10) not null,
            constraint FK_ST_LOC_Stage_Location foreign key (
                ST_LOC_ST_ID
            ) references public.ST_Stage(ST_ID),
            constraint PK_ST_LOC_Stage_Location primary key (
                ST_LOC_ST_ID
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.ST_AVG_Stage_Average (
            ST_AVG_ST_ID number(10) not null,
            ST_AVG_UTL_ID number(3) not null,
            ST_AVG_ChangedAt timestamp not null,
            Metadata_ST_AVG number(10) not null,
            constraint FK1_ST_AVG_Stage_Average foreign key (
                ST_AVG_ST_ID
            ) references public.ST_Stage(ST_ID),
            constraint FK2_ST_AVG_Stage_Average foreign key (
                ST_AVG_UTL_ID
            ) references public.UTL_Utilization(UTL_ID),
            constraint PK_ST_AVG_Stage_Average primary key (
                ST_AVG_ST_ID,
                ST_AVG_ChangedAt
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.ST_MIN_Stage_Minimum (
            ST_MIN_ST_ID number(10) not null,
            ST_MIN_UTL_ID number(3) not null,
            Metadata_ST_MIN number(10) not null,
            constraint FK1_ST_MIN_Stage_Minimum foreign key (
                ST_MIN_ST_ID
            ) references public.ST_Stage(ST_ID),
            constraint FK2_ST_MIN_Stage_Minimum foreign key (
                ST_MIN_UTL_ID
            ) references public.UTL_Utilization(UTL_ID),
            constraint PK_ST_MIN_Stage_Minimum primary key (
                ST_MIN_ST_ID
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.AC_Actor (
            AC_ID number(10) GENERATED BY DEFAULT ON NULL AS IDENTITY not null, 
            Metadata_AC number(10) not null, 
            constraint PK_AC_Actor primary key (
                AC_ID
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.AC_NAM_Actor_Name (
            AC_NAM_AC_ID number(10) not null,
            AC_NAM_Actor_Name nvarchar2(42) not null,
            AC_NAM_ChangedAt timestamp not null,
            Metadata_AC_NAM number(10) not null,
            constraint FK_AC_NAM_Actor_Name foreign key (
                AC_NAM_AC_ID
            ) references public.AC_Actor(AC_ID),
            constraint PK_AC_NAM_Actor_Name primary key (
                AC_NAM_AC_ID,
                AC_NAM_ChangedAt
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.AC_GEN_Actor_Gender (
            AC_GEN_AC_ID number(10) not null,
            AC_GEN_GEN_ID number(3) not null,
            Metadata_AC_GEN number(10) not null,
            constraint FK1_AC_GEN_Actor_Gender foreign key (
                AC_GEN_AC_ID
            ) references public.AC_Actor(AC_ID),
            constraint FK2_AC_GEN_Actor_Gender foreign key (
                AC_GEN_GEN_ID
            ) references public.GEN_Gender(GEN_ID),
            constraint PK_AC_GEN_Actor_Gender primary key (
                AC_GEN_AC_ID
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.AC_PLV_Actor_ProfessionalLevel (
            AC_PLV_AC_ID number(10) not null,
            AC_PLV_PLV_ID number(3) not null,
            AC_PLV_ChangedAt timestamp not null,
            Metadata_AC_PLV number(10) not null,
            constraint FK1_AC_PLV_Actor_ProfessionalL foreign key (
                AC_PLV_AC_ID
            ) references public.AC_Actor(AC_ID),
            constraint FK2_AC_PLV_Actor_ProfessionalL foreign key (
                AC_PLV_PLV_ID
            ) references public.PLV_ProfessionalLevel(PLV_ID),
            constraint PK_AC_PLV_Actor_ProfessionalLe primary key (
                AC_PLV_AC_ID,
                AC_PLV_ChangedAt
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.PR_Program (
            PR_ID number(10) GENERATED BY DEFAULT ON NULL AS IDENTITY not null, 
            Metadata_PR number(10) not null, 
            constraint PK_PR_Program primary key (
                PR_ID
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.PR_NAM_Program_Name (
            PR_NAM_PR_ID number(10) not null,
            PR_NAM_Program_Name nvarchar2(42) not null,
            Metadata_PR_NAM number(10) not null,
            constraint FK_PR_NAM_Program_Name foreign key (
                PR_NAM_PR_ID
            ) references public.PR_Program(PR_ID),
            constraint PK_PR_NAM_Program_Name primary key (
                PR_NAM_PR_ID
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.PR_LEN_Program_Length (
            PR_LEN_PR_ID number(10) not null,
            PR_LEN_Program_Length timestamp not null,
            PR_LEN_ChangedAt date not null,
            Metadata_PR_LEN number(10) not null,
            constraint FK_PR_LEN_Program_Length foreign key (
                PR_LEN_PR_ID
            ) references public.PR_Program(PR_ID),
            constraint PK_PR_LEN_Program_Length primary key (
                PR_LEN_PR_ID,
                PR_LEN_ChangedAt
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.AC_partner_AC_with_ONG_currently (
            AC_ID_partner number(10) not null, 
            AC_ID_with number(10) not null, 
            ONG_ID_currently number(3) not null,
            AC_partner_AC_with_ONG_currently_ChangedAt timestamp not null,
            Metadata_AC_partner_AC_with_ONG_currently number(10) not null,
            constraint FK1_AC_partner_AC_with_ONG_cur foreign key (
                AC_ID_partner
            ) references public.AC_Actor(AC_ID), 
            constraint FK2_AC_partner_AC_with_ONG_cur foreign key (
                AC_ID_with
            ) references public.AC_Actor(AC_ID), 
            constraint FK3_AC_partner_AC_with_ONG_cur foreign key (
                ONG_ID_currently
            ) references public.ONG_Ongoing(ONG_ID),
            constraint UQ1_AC_partner_AC_with_ONG_cur unique (
                AC_ID_partner,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint UQ2_AC_partner_AC_with_ONG_cur unique (
                AC_ID_with,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint UQ3_AC_partner_AC_with_ONG_cur unique (
                ONG_ID_currently,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint PK_AC_partner_AC_with_ONG_curr primary key (
                AC_ID_partner,
                AC_ID_with,
                ONG_ID_currently,
                AC_partner_AC_with_ONG_currently_ChangedAt
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Static tie table ---------------------------------------------------------------------------------------------------
-- AC_subset_PN_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.AC_subset_PN_of (
            AC_ID_subset number(10) not null, 
            PN_ID_of number(10) not null, 
            Metadata_AC_subset_PN_of number(10) not null,
            constraint FK1_AC_subset_PN_ofAC_subset foreign key (
                AC_ID_subset
            ) references public.AC_Actor(AC_ID), 
            constraint FK2_AC_subset_PN_ofPN_of foreign key (
                PN_ID_of
            ) references public.PN_Person(PN_ID), 
            constraint UQ1_AC_subset_PN_ofAC_subset unique (
                AC_ID_subset
            ),
            constraint UQ2_AC_subset_PN_ofPN_of unique (
                PN_ID_of
            ),
            constraint PK_AC_subset_PN_of primary key (
                AC_ID_subset,
                PN_ID_of
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Static tie table ---------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.EV_in_AC_wasCast (
            EV_ID_in number(10) not null, 
            AC_ID_wasCast number(10) not null, 
            Metadata_EV_in_AC_wasCast number(10) not null,
            constraint FK1_EV_in_AC_wasCastEV_in foreign key (
                EV_ID_in
            ) references public.EV_Event(EV_ID), 
            constraint FK2_EV_in_AC_wasCastAC_wasCast foreign key (
                AC_ID_wasCast
            ) references public.AC_Actor(AC_ID), 
            constraint PK_EV_in_AC_wasCast primary key (
                EV_ID_in,
                AC_ID_wasCast
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.AC_part_PR_in_RAT_got (
            AC_ID_part number(10) not null, 
            PR_ID_in number(10) not null, 
            RAT_ID_got number(3) not null,
            AC_part_PR_in_RAT_got_ChangedAt timestamp not null,
            Metadata_AC_part_PR_in_RAT_got number(10) not null,
            constraint FK1_AC_part_PR_in_RAT_gotAC_pa foreign key (
                AC_ID_part
            ) references public.AC_Actor(AC_ID), 
            constraint FK2_AC_part_PR_in_RAT_gotPR_in foreign key (
                PR_ID_in
            ) references public.PR_Program(PR_ID), 
            constraint FK3_AC_part_PR_in_RAT_gotRAT_g foreign key (
                RAT_ID_got
            ) references public.RAT_Rating(RAT_ID),
            constraint PK_AC_part_PR_in_RAT_got primary key (
                AC_ID_part,
                PR_ID_in,
                AC_part_PR_in_RAT_got_ChangedAt
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.ST_at_PR_isPlaying (
            ST_ID_at number(10) not null, 
            PR_ID_isPlaying number(10) not null, 
            ST_at_PR_isPlaying_ChangedAt timestamp not null,
            Metadata_ST_at_PR_isPlaying number(10) not null,
            constraint FK1_ST_at_PR_isPlayingST_at foreign key (
                ST_ID_at
            ) references public.ST_Stage(ST_ID), 
            constraint FK2_ST_at_PR_isPlayingPR_isPla foreign key (
                PR_ID_isPlaying
            ) references public.PR_Program(PR_ID), 
            constraint PK_ST_at_PR_isPlaying primary key (
                ST_ID_at,
                PR_ID_isPlaying,
                ST_at_PR_isPlaying_ChangedAt
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.AC_parent_AC_child_PAT_having (
            AC_ID_parent number(10) not null, 
            AC_ID_child number(10) not null, 
            PAT_ID_having number(3) not null,
            Metadata_AC_parent_AC_child_PAT_having number(10) not null,
            constraint FK1_AC_parent_AC_child_PAT_hav foreign key (
                AC_ID_parent
            ) references public.AC_Actor(AC_ID), 
            constraint FK2_AC_parent_AC_child_PAT_hav foreign key (
                AC_ID_child
            ) references public.AC_Actor(AC_ID), 
            constraint FK3_AC_parent_AC_child_PAT_hav foreign key (
                PAT_ID_having
            ) references public.PAT_ParentalType(PAT_ID),
            constraint PK_AC_parent_AC_child_PAT_havi primary key (
                AC_ID_parent,
                AC_ID_child,
                PAT_ID_having
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- Static tie table ---------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE public.PR_content_ST_location_EV_of (
            PR_ID_content number(10) not null, 
            ST_ID_location number(10) not null, 
            EV_ID_of number(10) not null, 
            Metadata_PR_content_ST_location_EV_of number(10) not null,
            constraint FK1_PR_content_ST_location_EV_ foreign key (
                PR_ID_content
            ) references public.PR_Program(PR_ID), 
            constraint FK2_PR_content_ST_location_EV_ foreign key (
                ST_ID_location
            ) references public.ST_Stage(ST_ID), 
            constraint FK3_PR_content_ST_location_EV_ foreign key (
                EV_ID_of
            ) references public.EV_Event(EV_ID), 
            constraint PK_PR_content_ST_location_EV_o primary key (
                EV_ID_of
            )
        )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/
-- ANCHOR PERSPECTIVES ------------------------------------------------------------------------------------------------
--
-- Oracle latest (l) and now (n) perspectives.
--
CREATE OR REPLACE VIEW public.lPN_Person AS
SELECT
    *
FROM
    public.PN_Person PN
;

CREATE OR REPLACE VIEW public.nPN_Person AS
SELECT
    *
FROM
    public.lPN_Person
;
CREATE OR REPLACE VIEW public.lST_Stage AS
SELECT
    ST.ST_ID,
    ST.Metadata_ST,
    NAM.ST_NAM_ST_ID,
    NAM.Metadata_ST_NAM,
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_ST_ID,
    LOC.Metadata_ST_LOC,
    LOC.ST_LOC_Stage_Location,
    AVG.ST_AVG_ST_ID,
    AVG.Metadata_ST_AVG,
    AVG.ST_AVG_ChangedAt,
    kAVG.UTL_Utilization AS ST_AVG_UTL_Utilization,
    kAVG.Metadata_UTL AS ST_AVG_Metadata_UTL,
    AVG.ST_AVG_UTL_ID,
    MIN.ST_MIN_ST_ID,
    MIN.Metadata_ST_MIN,
    kMIN.UTL_Utilization AS ST_MIN_UTL_Utilization,
    kMIN.Metadata_UTL AS ST_MIN_Metadata_UTL,
    MIN.ST_MIN_UTL_ID
FROM
    public.ST_Stage ST
LEFT JOIN
    public.ST_NAM_Stage_Name NAM
ON
    NAM.ST_NAM_ST_ID = ST.ST_ID
LEFT JOIN
    public.ST_LOC_Stage_Location LOC
ON
    LOC.ST_LOC_ST_ID = ST.ST_ID
LEFT JOIN
    public.ST_AVG_Stage_Average AVG
ON
    AVG.ST_AVG_ST_ID = ST.ST_ID
LEFT JOIN
    public.UTL_Utilization kAVG
ON
    kAVG.UTL_ID = AVG.ST_AVG_UTL_ID
LEFT JOIN
    public.ST_MIN_Stage_Minimum MIN
ON
    MIN.ST_MIN_ST_ID = ST.ST_ID
LEFT JOIN
    public.UTL_Utilization kMIN
ON
    kMIN.UTL_ID = MIN.ST_MIN_UTL_ID
WHERE
    1 = 1
AND (
    NAM.ST_NAM_ChangedAt = (
        SELECT
            MAX(sub.ST_NAM_ChangedAt)
        FROM
            public.ST_NAM_Stage_Name sub
        WHERE
            sub.ST_NAM_ST_ID = ST.ST_ID
    )
    OR NAM.ST_NAM_ChangedAt IS NULL
)
AND (
    AVG.ST_AVG_ChangedAt = (
        SELECT
            MAX(sub.ST_AVG_ChangedAt)
        FROM
            public.ST_AVG_Stage_Average sub
        WHERE
            sub.ST_AVG_ST_ID = ST.ST_ID
    )
    OR AVG.ST_AVG_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW public.nST_Stage AS
SELECT
    *
FROM
    public.lST_Stage
;
CREATE OR REPLACE VIEW public.lAC_Actor AS
SELECT
    AC.AC_ID,
    AC.Metadata_AC,
    NAM.AC_NAM_AC_ID,
    NAM.Metadata_AC_NAM,
    NAM.AC_NAM_ChangedAt,
    NAM.AC_NAM_Actor_Name,
    GEN.AC_GEN_AC_ID,
    GEN.Metadata_AC_GEN,
    kGEN.GEN_Gender AS AC_GEN_GEN_Gender,
    kGEN.Metadata_GEN AS AC_GEN_Metadata_GEN,
    GEN.AC_GEN_GEN_ID,
    PLV.AC_PLV_AC_ID,
    PLV.Metadata_AC_PLV,
    PLV.AC_PLV_ChangedAt,
    kPLV.PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    kPLV.Metadata_PLV AS AC_PLV_Metadata_PLV,
    PLV.AC_PLV_PLV_ID
FROM
    public.AC_Actor AC
LEFT JOIN
    public.AC_NAM_Actor_Name NAM
ON
    NAM.AC_NAM_AC_ID = AC.AC_ID
LEFT JOIN
    public.AC_GEN_Actor_Gender GEN
ON
    GEN.AC_GEN_AC_ID = AC.AC_ID
LEFT JOIN
    public.GEN_Gender kGEN
ON
    kGEN.GEN_ID = GEN.AC_GEN_GEN_ID
LEFT JOIN
    public.AC_PLV_Actor_ProfessionalLevel PLV
ON
    PLV.AC_PLV_AC_ID = AC.AC_ID
LEFT JOIN
    public.PLV_ProfessionalLevel kPLV
ON
    kPLV.PLV_ID = PLV.AC_PLV_PLV_ID
WHERE
    1 = 1
AND (
    NAM.AC_NAM_ChangedAt = (
        SELECT
            MAX(sub.AC_NAM_ChangedAt)
        FROM
            public.AC_NAM_Actor_Name sub
        WHERE
            sub.AC_NAM_AC_ID = AC.AC_ID
    )
    OR NAM.AC_NAM_ChangedAt IS NULL
)
AND (
    PLV.AC_PLV_ChangedAt = (
        SELECT
            MAX(sub.AC_PLV_ChangedAt)
        FROM
            public.AC_PLV_Actor_ProfessionalLevel sub
        WHERE
            sub.AC_PLV_AC_ID = AC.AC_ID
    )
    OR PLV.AC_PLV_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW public.nAC_Actor AS
SELECT
    *
FROM
    public.lAC_Actor
;
CREATE OR REPLACE VIEW public.lPR_Program AS
SELECT
    PR.PR_ID,
    PR.Metadata_PR,
    NAM.PR_NAM_PR_ID,
    NAM.Metadata_PR_NAM,
    NAM.PR_NAM_Program_Name,
    LEN.PR_LEN_PR_ID,
    LEN.Metadata_PR_LEN,
    LEN.PR_LEN_ChangedAt,
    LEN.PR_LEN_Program_Length
FROM
    public.PR_Program PR
LEFT JOIN
    public.PR_NAM_Program_Name NAM
ON
    NAM.PR_NAM_PR_ID = PR.PR_ID
LEFT JOIN
    public.PR_LEN_Program_Length LEN
ON
    LEN.PR_LEN_PR_ID = PR.PR_ID
WHERE
    1 = 1
AND (
    LEN.PR_LEN_ChangedAt = (
        SELECT
            MAX(sub.PR_LEN_ChangedAt)
        FROM
            public.PR_LEN_Program_Length sub
        WHERE
            sub.PR_LEN_PR_ID = PR.PR_ID
    )
    OR LEN.PR_LEN_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW public.nPR_Program AS
SELECT
    *
FROM
    public.lPR_Program
;
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
CREATE OR REPLACE TRIGGER itST_Stage
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itST_Stage instead of INSERT trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lST_Stage
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN

    INSERT INTO ST_Stage (
        ST_ID,
        Metadata_ST 
    ) VALUES (
        :NEW.ST_ID,
        :NEW.Metadata_ST 
    );

    if (:NEW.ST_NAM_Stage_Name is not null) then -- insert
        INSERT INTO ST_NAM_Stage_Name (
            ST_NAM_ST_ID, -- number(10) null,
            ST_NAM_ChangedAt, -- timestamp null,
            ST_NAM_Stage_Name, --  nvarchar2(42) null,   ELSE
            Metadata_ST_NAM -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,
            nvl(:NEW.ST_NAM_ChangedAt, l_now), -- timestamp null,
            :NEW.ST_NAM_Stage_Name, --  nvarchar2(42) null,   ELSE
            nvl(:NEW.Metadata_ST_NAM, :NEW.Metadata_ST) -- null,
        );
    end if;
    if (:NEW.ST_LOC_Stage_Location is not null) then -- insert
        INSERT INTO ST_LOC_Stage_Location (
            ST_LOC_ST_ID, -- number(10) null,

            ST_LOC_Stage_Location, --  geography null,   ELSE
            Metadata_ST_LOC -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,

            :NEW.ST_LOC_Stage_Location, --  geography null,   ELSE
            nvl(:NEW.Metadata_ST_LOC, :NEW.Metadata_ST) -- null,
        );
    end if;
    if (:NEW.ST_AVG_UTL_Utilization is not null) then -- insert
        INSERT INTO ST_AVG_Stage_Average (
            ST_AVG_ST_ID, -- number(10) null,
            ST_AVG_ChangedAt, -- timestamp null,
            -- ST_AVG_UTL_Utilization, -- number(3) null,   KNOT
            -- ST_AVG_Metadata_UTL, -- number(10) null,   KNOT
            ST_AVG_UTL_ID, --  number(3) null,   KNOT
            Metadata_ST_AVG -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,
            nvl(:NEW.ST_AVG_ChangedAt, l_now), -- timestamp null,
            -- :NEW.ST_AVG_UTL_Utilization, -- number(3) null,   KNOT
            -- nvl(:NEW.ST_AVG_Metadata_UTL, :NEW.Metadata_ST), -- null,   KNOT
            (select knot.UTL_ID from UTL_Utilization knot where knot.UTL_Utilization = :NEW.ST_AVG_UTL_Utilization), -- number(3) null,    -- KNOT insert om ST_AVG_UTL_Utilization på väg in i vyn finns i UTL_Utilization
            nvl(:NEW.Metadata_ST_AVG, :NEW.Metadata_ST) -- null,
        );
    end if;
    if (:NEW.ST_MIN_UTL_Utilization is not null) then -- insert
        INSERT INTO ST_MIN_Stage_Minimum (
            ST_MIN_ST_ID, -- number(10) null,

            -- ST_MIN_UTL_Utilization, -- number(3) null,   KNOT
            -- ST_MIN_Metadata_UTL, -- number(10) null,   KNOT
            ST_MIN_UTL_ID, --  number(3) null
            Metadata_ST_MIN -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,

            -- :NEW.ST_MIN_UTL_Utilization, -- number(3) null,   KNOT
            -- nvl(:NEW.ST_MIN_Metadata_UTL, :NEW.Metadata_ST), -- null,   KNOT
            (select knot.UTL_ID from UTL_Utilization knot where knot.UTL_Utilization = :NEW.ST_MIN_UTL_Utilization), -- number(3) null
            nvl(:NEW.Metadata_ST_MIN, :NEW.Metadata_ST) -- null,
        );
    end if;
END itST_Stage;
/
CREATE OR REPLACE TRIGGER utST_Stage
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utST_Stage instead of UPDATE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF UPDATE
ON lST_Stage
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now date := sysdate;
    l_changedate date := sysdate;
    l_metadata  integer;
    -- är kolumnen förändrad, OBS tar hänsyn till NULL
    function is_changed ( in_new varchar2, in_old varchar2) return boolean is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return false;
        else
            -- TRUE
            return true;
        end if;
    end is_changed;
    -- ger changedate, OBS tar hänsyn till NULL
    function get_changedate ( in_new date, in_old date) return date is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) OR (in_new is null) then
            -- FALSE
            return l_now;
        else
            -- TRUE
            return in_new;
        end if;
    end get_changedate;
    -- ger metadata, OBS tar hänsyn till NULL
    function get_metadata ( in_new integer, in_old integer) return integer is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return 0;
        else
            -- TRUE
            return in_new;
        end if;
    end get_metadata;
BEGIN
    if is_changed(:NEW.ST_NAM_Stage_Name, :OLD.ST_NAM_Stage_Name) then -- insert
        l_changedate := get_changedate(:NEW.ST_NAM_ChangedAt, :OLD.ST_NAM_ChangedAt);
        l_metadata := get_metadata(:NEW.Metadata_ST_NAM, :OLD.Metadata_ST_NAM);
        INSERT INTO ST_NAM_Stage_Name (
            ST_NAM_ST_ID, -- number(10) null,
            ST_NAM_ChangedAt, -- timestamp null,
            ST_NAM_Stage_Name, --  nvarchar2(42) null,   ELSE
            Metadata_ST_NAM -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,
            l_changedate,
            :NEW.ST_NAM_Stage_Name, --  nvarchar2(42) null,   ELSE
            l_metadata -- number(10) null,
        );
    end if;
    if is_changed(:NEW.ST_LOC_Stage_Location, :OLD.ST_LOC_Stage_Location) then -- insert

        l_metadata := get_metadata(:NEW.Metadata_ST_LOC, :OLD.Metadata_ST_LOC);
        INSERT INTO ST_LOC_Stage_Location (
            ST_LOC_ST_ID, -- number(10) null,

            ST_LOC_Stage_Location, --  geography null,   ELSE
            Metadata_ST_LOC -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,

            :NEW.ST_LOC_Stage_Location, --  geography null,   ELSE
            l_metadata -- number(10) null,
        );
    end if;
    if is_changed(:NEW.ST_AVG_UTL_Utilization, :OLD.ST_AVG_UTL_Utilization) then -- insert
        l_changedate := get_changedate(:NEW.ST_AVG_ChangedAt, :OLD.ST_AVG_ChangedAt);
        l_metadata := get_metadata(:NEW.Metadata_ST_AVG, :OLD.Metadata_ST_AVG);
        INSERT INTO ST_AVG_Stage_Average (
            ST_AVG_ST_ID, -- number(10) null,
            ST_AVG_ChangedAt, -- timestamp null,
            -- ST_AVG_UTL_Utilization, -- number(3) null,   KNOT
            -- ST_AVG_Metadata_UTL, -- number(10) null,   KNOT
            ST_AVG_UTL_ID, --  number(3) null,   KNOT
            Metadata_ST_AVG -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,
            l_changedate,
            -- :NEW.ST_AVG_UTL_Utilization, -- number(3) null,   KNOT
            -- nvl(:NEW.ST_AVG_Metadata_UTL, :NEW.Metadata_ST), -- null,   KNOT
            (select knot.UTL_ID from UTL_Utilization knot where knot.UTL_Utilization = :NEW.ST_AVG_UTL_Utilization), -- number(3) null,    -- KNOT insert om ST_AVG_UTL_Utilization på väg in i vyn finns i UTL_Utilization
            l_metadata -- number(10) null,
        );
    end if;
    if is_changed(:NEW.ST_MIN_UTL_Utilization, :OLD.ST_MIN_UTL_Utilization) then -- insert

        l_metadata := get_metadata(:NEW.Metadata_ST_MIN, :OLD.Metadata_ST_MIN);
        INSERT INTO ST_MIN_Stage_Minimum (
            ST_MIN_ST_ID, -- number(10) null,

            -- ST_MIN_UTL_Utilization, -- number(3) null,   KNOT
            -- ST_MIN_Metadata_UTL, -- number(10) null,   KNOT
            ST_MIN_UTL_ID, --  number(3) null
            Metadata_ST_MIN -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,

            -- :NEW.ST_MIN_UTL_Utilization, -- number(3) null,   KNOT
            -- nvl(:NEW.ST_MIN_Metadata_UTL, :NEW.Metadata_ST), -- null,   KNOT
            (select knot.UTL_ID from UTL_Utilization knot where knot.UTL_Utilization = :NEW.ST_MIN_UTL_Utilization), -- number(3) null
            l_metadata -- number(10) null,
        );
    end if;
END utST_Stage;
/
CREATE OR REPLACE TRIGGER dtST_Stage
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtST_Stage instead of DELETE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lST_Stage
FOR EACH ROW
DECLARE    l_now date := sysdate;
BEGIN
    -- ta bort attribut för givet ankare och tid
    delete ST_NAM_Stage_Name where 1=1
    and ST_NAM_ST_ID = :OLD.ST_ID
    and ST_NAM_ChangedAt = :OLD.ST_NAM_ChangedAt
    ;
    -- ta bort attribut för givet ankare
    delete ST_LOC_Stage_Location where 1=1
    and ST_LOC_ST_ID = :OLD.ST_ID
    ;
    -- ta bort attribut för givet ankare och tid
    delete ST_AVG_Stage_Average where 1=1
    and ST_AVG_ST_ID = :OLD.ST_ID
    and ST_AVG_ChangedAt = :OLD.ST_AVG_ChangedAt
    ;
    -- ta bort attribut för givet ankare
    delete ST_MIN_Stage_Minimum where 1=1
    and ST_MIN_ST_ID = :OLD.ST_ID
    ;
    -- ta bort ankare om det inte längre har några attribut
    delete ST_Stage where ST_ID = :OLD.ST_ID

    and 0 = (select count(*) from ST_NAM_Stage_Name where ST_NAM_ST_ID = :OLD.ST_ID)

    and 0 = (select count(*) from ST_LOC_Stage_Location where ST_LOC_ST_ID = :OLD.ST_ID)

    and 0 = (select count(*) from ST_AVG_Stage_Average where ST_AVG_ST_ID = :OLD.ST_ID)

    and 0 = (select count(*) from ST_MIN_Stage_Minimum where ST_MIN_ST_ID = :OLD.ST_ID)
    ;
END dtST_Stage;
/
CREATE OR REPLACE TRIGGER itAC_Actor
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_Actor instead of INSERT trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lAC_Actor
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN

    INSERT INTO AC_Actor (
        AC_ID,
        Metadata_AC 
    ) VALUES (
        :NEW.AC_ID,
        :NEW.Metadata_AC 
    );

    if (:NEW.AC_NAM_Actor_Name is not null) then -- insert
        INSERT INTO AC_NAM_Actor_Name (
            AC_NAM_AC_ID, -- number(10) null,
            AC_NAM_ChangedAt, -- timestamp null,
            AC_NAM_Actor_Name, --  nvarchar2(42) null,   ELSE
            Metadata_AC_NAM -- number(10) null,
        ) VALUES (
            :NEW.AC_ID, -- number(10) null,
            nvl(:NEW.AC_NAM_ChangedAt, l_now), -- timestamp null,
            :NEW.AC_NAM_Actor_Name, --  nvarchar2(42) null,   ELSE
            nvl(:NEW.Metadata_AC_NAM, :NEW.Metadata_AC) -- null,
        );
    end if;
    if (:NEW.AC_GEN_GEN_Gender is not null) then -- insert
        INSERT INTO AC_GEN_Actor_Gender (
            AC_GEN_AC_ID, -- number(10) null,

            -- AC_GEN_GEN_Gender, -- nvarchar2(42) null,   KNOT
            -- AC_GEN_Metadata_GEN, -- number(10) null,   KNOT
            AC_GEN_GEN_ID, --  number(3) null,   KNOT
            Metadata_AC_GEN -- number(10) null,
        ) VALUES (
            :NEW.AC_ID, -- number(10) null,

            -- :NEW.AC_GEN_GEN_Gender, -- nvarchar2(42) null,   KNOT
            -- nvl(:NEW.AC_GEN_Metadata_GEN, :NEW.Metadata_AC), -- null,   KNOT
            (select knot.GEN_ID from GEN_Gender knot where knot.GEN_Gender = :NEW.AC_GEN_GEN_Gender), -- number(3) null,    -- KNOT insert om AC_GEN_GEN_Gender på väg in i vyn finns i GEN_Gender
            nvl(:NEW.Metadata_AC_GEN, :NEW.Metadata_AC) -- null,
        );
    end if;
    if (:NEW.AC_PLV_PLV_ProfessionalLevel is not null) then -- insert
        INSERT INTO AC_PLV_Actor_ProfessionalLevel (
            AC_PLV_AC_ID, -- number(10) null,
            AC_PLV_ChangedAt, -- timestamp null,
            -- AC_PLV_PLV_ProfessionalLevel, -- nclob null,   KNOT
            -- AC_PLV_Metadata_PLV, -- number(10) null,   KNOT
            AC_PLV_PLV_ID, --  number(3) null
            Metadata_AC_PLV -- number(10) null,
        ) VALUES (
            :NEW.AC_ID, -- number(10) null,
            nvl(:NEW.AC_PLV_ChangedAt, l_now), -- timestamp null,
            -- :NEW.AC_PLV_PLV_ProfessionalLevel, -- nclob null,   KNOT
            -- nvl(:NEW.AC_PLV_Metadata_PLV, :NEW.Metadata_AC), -- null,   KNOT
            (select knot.PLV_ID from PLV_ProfessionalLevel knot where knot.PLV_ProfessionalLevel = :NEW.AC_PLV_PLV_ProfessionalLevel), -- number(3) null
            nvl(:NEW.Metadata_AC_PLV, :NEW.Metadata_AC) -- null,
        );
    end if;
END itAC_Actor;
/
CREATE OR REPLACE TRIGGER utAC_Actor
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utAC_Actor instead of UPDATE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF UPDATE
ON lAC_Actor
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now date := sysdate;
    l_changedate date := sysdate;
    l_metadata  integer;
    -- är kolumnen förändrad, OBS tar hänsyn till NULL
    function is_changed ( in_new varchar2, in_old varchar2) return boolean is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return false;
        else
            -- TRUE
            return true;
        end if;
    end is_changed;
    -- ger changedate, OBS tar hänsyn till NULL
    function get_changedate ( in_new date, in_old date) return date is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) OR (in_new is null) then
            -- FALSE
            return l_now;
        else
            -- TRUE
            return in_new;
        end if;
    end get_changedate;
    -- ger metadata, OBS tar hänsyn till NULL
    function get_metadata ( in_new integer, in_old integer) return integer is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return 0;
        else
            -- TRUE
            return in_new;
        end if;
    end get_metadata;
BEGIN
    if is_changed(:NEW.AC_NAM_Actor_Name, :OLD.AC_NAM_Actor_Name) then -- insert
        l_changedate := get_changedate(:NEW.AC_NAM_ChangedAt, :OLD.AC_NAM_ChangedAt);
        l_metadata := get_metadata(:NEW.Metadata_AC_NAM, :OLD.Metadata_AC_NAM);
        INSERT INTO AC_NAM_Actor_Name (
            AC_NAM_AC_ID, -- number(10) null,
            AC_NAM_ChangedAt, -- timestamp null,
            AC_NAM_Actor_Name, --  nvarchar2(42) null,   ELSE
            Metadata_AC_NAM -- number(10) null,
        ) VALUES (
            :NEW.AC_ID, -- number(10) null,
            l_changedate,
            :NEW.AC_NAM_Actor_Name, --  nvarchar2(42) null,   ELSE
            l_metadata -- number(10) null,
        );
    end if;
    if is_changed(:NEW.AC_GEN_GEN_Gender, :OLD.AC_GEN_GEN_Gender) then -- insert

        l_metadata := get_metadata(:NEW.Metadata_AC_GEN, :OLD.Metadata_AC_GEN);
        INSERT INTO AC_GEN_Actor_Gender (
            AC_GEN_AC_ID, -- number(10) null,

            -- AC_GEN_GEN_Gender, -- nvarchar2(42) null,   KNOT
            -- AC_GEN_Metadata_GEN, -- number(10) null,   KNOT
            AC_GEN_GEN_ID, --  number(3) null,   KNOT
            Metadata_AC_GEN -- number(10) null,
        ) VALUES (
            :NEW.AC_ID, -- number(10) null,

            -- :NEW.AC_GEN_GEN_Gender, -- nvarchar2(42) null,   KNOT
            -- nvl(:NEW.AC_GEN_Metadata_GEN, :NEW.Metadata_AC), -- null,   KNOT
            (select knot.GEN_ID from GEN_Gender knot where knot.GEN_Gender = :NEW.AC_GEN_GEN_Gender), -- number(3) null,    -- KNOT insert om AC_GEN_GEN_Gender på väg in i vyn finns i GEN_Gender
            l_metadata -- number(10) null,
        );
    end if;
    if is_changed(:NEW.AC_PLV_PLV_ProfessionalLevel, :OLD.AC_PLV_PLV_ProfessionalLevel) then -- insert
        l_changedate := get_changedate(:NEW.AC_PLV_ChangedAt, :OLD.AC_PLV_ChangedAt);
        l_metadata := get_metadata(:NEW.Metadata_AC_PLV, :OLD.Metadata_AC_PLV);
        INSERT INTO AC_PLV_Actor_ProfessionalLevel (
            AC_PLV_AC_ID, -- number(10) null,
            AC_PLV_ChangedAt, -- timestamp null,
            -- AC_PLV_PLV_ProfessionalLevel, -- nclob null,   KNOT
            -- AC_PLV_Metadata_PLV, -- number(10) null,   KNOT
            AC_PLV_PLV_ID, --  number(3) null
            Metadata_AC_PLV -- number(10) null,
        ) VALUES (
            :NEW.AC_ID, -- number(10) null,
            l_changedate,
            -- :NEW.AC_PLV_PLV_ProfessionalLevel, -- nclob null,   KNOT
            -- nvl(:NEW.AC_PLV_Metadata_PLV, :NEW.Metadata_AC), -- null,   KNOT
            (select knot.PLV_ID from PLV_ProfessionalLevel knot where knot.PLV_ProfessionalLevel = :NEW.AC_PLV_PLV_ProfessionalLevel), -- number(3) null
            l_metadata -- number(10) null,
        );
    end if;
END utAC_Actor;
/
CREATE OR REPLACE TRIGGER dtAC_Actor
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtAC_Actor instead of DELETE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lAC_Actor
FOR EACH ROW
DECLARE    l_now date := sysdate;
BEGIN
    -- ta bort attribut för givet ankare och tid
    delete AC_NAM_Actor_Name where 1=1
    and AC_NAM_AC_ID = :OLD.AC_ID
    and AC_NAM_ChangedAt = :OLD.AC_NAM_ChangedAt
    ;
    -- ta bort attribut för givet ankare
    delete AC_GEN_Actor_Gender where 1=1
    and AC_GEN_AC_ID = :OLD.AC_ID
    ;
    -- ta bort attribut för givet ankare och tid
    delete AC_PLV_Actor_ProfessionalLevel where 1=1
    and AC_PLV_AC_ID = :OLD.AC_ID
    and AC_PLV_ChangedAt = :OLD.AC_PLV_ChangedAt
    ;
    -- ta bort ankare om det inte längre har några attribut
    delete AC_Actor where AC_ID = :OLD.AC_ID

    and 0 = (select count(*) from AC_NAM_Actor_Name where AC_NAM_AC_ID = :OLD.AC_ID)

    and 0 = (select count(*) from AC_GEN_Actor_Gender where AC_GEN_AC_ID = :OLD.AC_ID)

    and 0 = (select count(*) from AC_PLV_Actor_ProfessionalLevel where AC_PLV_AC_ID = :OLD.AC_ID)
    ;
END dtAC_Actor;
/
CREATE OR REPLACE TRIGGER itPR_Program
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itPR_Program instead of INSERT trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lPR_Program
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN

    INSERT INTO PR_Program (
        PR_ID,
        Metadata_PR 
    ) VALUES (
        :NEW.PR_ID,
        :NEW.Metadata_PR 
    );

    if (:NEW.PR_NAM_Program_Name is not null) then -- insert
        INSERT INTO PR_NAM_Program_Name (
            PR_NAM_PR_ID, -- number(10) null,

            PR_NAM_Program_Name, --  nvarchar2(42) null,   ELSE
            Metadata_PR_NAM -- number(10) null,
        ) VALUES (
            :NEW.PR_ID, -- number(10) null,

            :NEW.PR_NAM_Program_Name, --  nvarchar2(42) null,   ELSE
            nvl(:NEW.Metadata_PR_NAM, :NEW.Metadata_PR) -- null,
        );
    end if;
    if (:NEW.PR_LEN_Program_Length is not null) then -- insert
        INSERT INTO PR_LEN_Program_Length (
            PR_LEN_PR_ID, -- number(10) null,
            PR_LEN_ChangedAt, -- date null,
            PR_LEN_Program_Length, --  timestamp null
            Metadata_PR_LEN -- number(10) null,
        ) VALUES (
            :NEW.PR_ID, -- number(10) null,
            nvl(:NEW.PR_LEN_ChangedAt, l_now), -- date null,
            :NEW.PR_LEN_Program_Length, --  timestamp null
            nvl(:NEW.Metadata_PR_LEN, :NEW.Metadata_PR) -- null,
        );
    end if;
END itPR_Program;
/
CREATE OR REPLACE TRIGGER utPR_Program
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utPR_Program instead of UPDATE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF UPDATE
ON lPR_Program
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now date := sysdate;
    l_changedate date := sysdate;
    l_metadata  integer;
    -- är kolumnen förändrad, OBS tar hänsyn till NULL
    function is_changed ( in_new varchar2, in_old varchar2) return boolean is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return false;
        else
            -- TRUE
            return true;
        end if;
    end is_changed;
    -- ger changedate, OBS tar hänsyn till NULL
    function get_changedate ( in_new date, in_old date) return date is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) OR (in_new is null) then
            -- FALSE
            return l_now;
        else
            -- TRUE
            return in_new;
        end if;
    end get_changedate;
    -- ger metadata, OBS tar hänsyn till NULL
    function get_metadata ( in_new integer, in_old integer) return integer is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return 0;
        else
            -- TRUE
            return in_new;
        end if;
    end get_metadata;
BEGIN
    if is_changed(:NEW.PR_NAM_Program_Name, :OLD.PR_NAM_Program_Name) then -- insert

        l_metadata := get_metadata(:NEW.Metadata_PR_NAM, :OLD.Metadata_PR_NAM);
        INSERT INTO PR_NAM_Program_Name (
            PR_NAM_PR_ID, -- number(10) null,

            PR_NAM_Program_Name, --  nvarchar2(42) null,   ELSE
            Metadata_PR_NAM -- number(10) null,
        ) VALUES (
            :NEW.PR_ID, -- number(10) null,

            :NEW.PR_NAM_Program_Name, --  nvarchar2(42) null,   ELSE
            l_metadata -- number(10) null,
        );
    end if;
    if is_changed(:NEW.PR_LEN_Program_Length, :OLD.PR_LEN_Program_Length) then -- insert
        l_changedate := get_changedate(:NEW.PR_LEN_ChangedAt, :OLD.PR_LEN_ChangedAt);
        l_metadata := get_metadata(:NEW.Metadata_PR_LEN, :OLD.Metadata_PR_LEN);
        INSERT INTO PR_LEN_Program_Length (
            PR_LEN_PR_ID, -- number(10) null,
            PR_LEN_ChangedAt, -- date null,
            PR_LEN_Program_Length, --  timestamp null
            Metadata_PR_LEN -- number(10) null,
        ) VALUES (
            :NEW.PR_ID, -- number(10) null,
            l_changedate,
            :NEW.PR_LEN_Program_Length, --  timestamp null
            l_metadata -- number(10) null,
        );
    end if;
END utPR_Program;
/
CREATE OR REPLACE TRIGGER dtPR_Program
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtPR_Program instead of DELETE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lPR_Program
FOR EACH ROW
DECLARE    l_now date := sysdate;
BEGIN
    -- ta bort attribut för givet ankare
    delete PR_NAM_Program_Name where 1=1
    and PR_NAM_PR_ID = :OLD.PR_ID
    ;
    -- ta bort attribut för givet ankare och tid
    delete PR_LEN_Program_Length where 1=1
    and PR_LEN_PR_ID = :OLD.PR_ID
    and PR_LEN_ChangedAt = :OLD.PR_LEN_ChangedAt
    ;
    -- ta bort ankare om det inte längre har några attribut
    delete PR_Program where PR_ID = :OLD.PR_ID

    and 0 = (select count(*) from PR_NAM_Program_Name where PR_NAM_PR_ID = :OLD.PR_ID)

    and 0 = (select count(*) from PR_LEN_Program_Length where PR_LEN_PR_ID = :OLD.PR_ID)
    ;
END dtPR_Program;
/
-- TIE PERSPECTIVES ---------------------------------------------------------------------------------------------------
--
-- Oracle latest (l) and now (n) perspectives.
--
CREATE OR REPLACE VIEW public.lAC_partner_AC_with_ONG_currently AS
SELECT
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    ONG_currently.Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    public.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    public.ONG_Ongoing ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE (
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            MAX(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            public.AC_partner_AC_with_ONG_currently sub
        WHERE
            (
                sub.AC_ID_partner = tie.AC_ID_partner
            OR
                sub.AC_ID_with = tie.AC_ID_with
            OR
                sub.ONG_ID_currently = tie.ONG_ID_currently
            )
    )
    OR tie.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW public.nAC_partner_AC_with_ONG_currently AS
SELECT
    *
FROM
    public.lAC_partner_AC_with_ONG_currently
;
CREATE OR REPLACE VIEW public.lAC_subset_PN_of AS
SELECT
    tie.Metadata_AC_subset_PN_of,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    public.AC_subset_PN_of tie
;

CREATE OR REPLACE VIEW public.nAC_subset_PN_of AS
SELECT
    *
FROM
    public.lAC_subset_PN_of
;
CREATE OR REPLACE VIEW public.lEV_in_AC_wasCast AS
SELECT
    tie.Metadata_EV_in_AC_wasCast,
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    public.EV_in_AC_wasCast tie
;

CREATE OR REPLACE VIEW public.nEV_in_AC_wasCast AS
SELECT
    *
FROM
    public.lEV_in_AC_wasCast
;
CREATE OR REPLACE VIEW public.lAC_part_PR_in_RAT_got AS
SELECT
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    public.AC_part_PR_in_RAT_got tie
LEFT JOIN
    public.RAT_Rating RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE (
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            MAX(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            public.AC_part_PR_in_RAT_got sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
    )
    OR tie.AC_part_PR_in_RAT_got_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW public.nAC_part_PR_in_RAT_got AS
SELECT
    *
FROM
    public.lAC_part_PR_in_RAT_got
;
CREATE OR REPLACE VIEW public.lST_at_PR_isPlaying AS
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    public.ST_at_PR_isPlaying tie
WHERE (
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            MAX(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            public.ST_at_PR_isPlaying sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
    )
    OR tie.ST_at_PR_isPlaying_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW public.nST_at_PR_isPlaying AS
SELECT
    *
FROM
    public.lST_at_PR_isPlaying
;
CREATE OR REPLACE VIEW public.lAC_parent_AC_child_PAT_having AS
SELECT
    tie.Metadata_AC_parent_AC_child_PAT_having,
    tie.AC_ID_parent,
    tie.AC_ID_child,
    PAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    PAT_having.Metadata_PAT AS having_Metadata_PAT,
    tie.PAT_ID_having
FROM
    public.AC_parent_AC_child_PAT_having tie
LEFT JOIN
    public.PAT_ParentalType PAT_having
ON
    PAT_having.PAT_ID = tie.PAT_ID_having
;

CREATE OR REPLACE VIEW public.nAC_parent_AC_child_PAT_having AS
SELECT
    *
FROM
    public.lAC_parent_AC_child_PAT_having
;
CREATE OR REPLACE VIEW public.lPR_content_ST_location_EV_of AS
SELECT
    tie.Metadata_PR_content_ST_location_EV_of,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    public.PR_content_ST_location_EV_of tie
;

CREATE OR REPLACE VIEW public.nPR_content_ST_location_EV_of AS
SELECT
    *
FROM
    public.lPR_content_ST_location_EV_of
;
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
CREATE OR REPLACE TRIGGER itAC_partner_AC_with_ONG_currently
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_partner_AC_with_ONG_currently instead of INSERT trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- HISTORIZED KNOTTED 
    INSERT INTO AC_partner_AC_with_ONG_currently (
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_current,
        Metadata_AC_partner_AC_with_ON
    ) VALUES (
        :NEW.AC_ID_partner,
        :NEW.AC_ID_with,
        (select a.ONG_ID from ONG_Ongoing a where a.ONG_Ongoing = :NEW.currently_ONG_Ongoing), -- Denna kolumn har också ett konstraint till en KNOT och måste därför särbehandlas
        NVL(:NEW.AC_partner_AC_with_ONG_current,l_now),
        :NEW.Metadata_AC_partner_AC_with_ON
    );
END itAC_partner_AC_with_ONG_currently;
/

CREATE OR REPLACE TRIGGER utAC_partner_AC_with_ONG_currently
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utAC_partner_AC_with_ONG_currently instead of UPDATE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF UPDATE
ON lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
    -- är kolumnen förändrad, OBS tar hänsyn till NULL
    function is_changed ( in_new varchar2, in_old varchar2) return boolean is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return false;
        else
            -- TRUE
            return true;
        end if;
    end is_changed;
BEGIN

 -- HISTORIZED KNOTTED 
    -- Relationskolumner får ej uppdateras
    if is_changed(:NEW.AC_ID_partner, :OLD.AC_ID_partner) then
        raise_application_error(-20001, 'Relationskolumnen AC_partner_AC_with_ONG_currently.AC_ID_partner får ej uppdateras');
    end if;
    -- Relationskolumner får ej uppdateras
    if is_changed(:NEW.AC_ID_with, :OLD.AC_ID_with) then
        raise_application_error(-20001, 'Relationskolumnen AC_partner_AC_with_ONG_currently.AC_ID_with får ej uppdateras');
    end if;
    INSERT INTO AC_partner_AC_with_ONG_currently (
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_current,
        Metadata_AC_partner_AC_with_ON
    ) VALUES (
        :NEW.AC_ID_partner,
        :NEW.AC_ID_with,
        (select a.ONG_ID from ONG_Ongoing a where a.ONG_Ongoing = :NEW.currently_ONG_Ongoing), -- Denna kolumn har också ett konstraint till en KNOT och måste därför särbehandlas
        NVL(:NEW.AC_partner_AC_with_ONG_current,l_now),
        :NEW.Metadata_AC_partner_AC_with_ON
    );
END utAC_partner_AC_with_ONG_currently;
/

CREATE OR REPLACE TRIGGER dtAC_partner_AC_with_ONG_currently
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtAC_partner_AC_with_ONG_currently instead of DELETE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE AC_partner_AC_with_ONG_currently WHERE 1=1
    AND AC_partner_AC_with_ONG_current = :NEW.AC_partner_AC_with_ONG_current
    AND (
            AC_ID_partner = :NEW.AC_ID_partner
        OR
            AC_ID_with = :NEW.AC_ID_with
        OR
            ONG_ID_currently = :NEW.ONG_ID_currently
    );
END dtAC_partner_AC_with_ONG_currently;
/
CREATE OR REPLACE TRIGGER itAC_subset_PN_of
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lAC_subset_PN_of
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- NOT HISTORIZED NOT KNOTTED 
    INSERT INTO AC_subset_PN_of (
        AC_ID_subset,
        PN_ID_of,

        Metadata_AC_subset_PN_of
    ) VALUES (
        :NEW.AC_ID_subset,
        :NEW.PN_ID_of,

        :NEW.Metadata_AC_subset_PN_of
    );
END itAC_subset_PN_of;
/

CREATE OR REPLACE TRIGGER dtAC_subset_PN_of
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lAC_subset_PN_of
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE AC_subset_PN_of WHERE 1=1
    AND (
            AC_ID_subset = :NEW.AC_ID_subset
        OR
            PN_ID_of = :NEW.PN_ID_of
    );
END dtAC_subset_PN_of;
/
CREATE OR REPLACE TRIGGER itEV_in_AC_wasCast
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itEV_in_AC_wasCast instead of INSERT trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lEV_in_AC_wasCast
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- NOT HISTORIZED NOT KNOTTED 
    INSERT INTO EV_in_AC_wasCast (
        EV_ID_in,
        AC_ID_wasCast,

        Metadata_EV_in_AC_wasCast
    ) VALUES (
        :NEW.EV_ID_in,
        :NEW.AC_ID_wasCast,

        :NEW.Metadata_EV_in_AC_wasCast
    );
END itEV_in_AC_wasCast;
/

CREATE OR REPLACE TRIGGER dtEV_in_AC_wasCast
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtEV_in_AC_wasCast instead of DELETE trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lEV_in_AC_wasCast
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE EV_in_AC_wasCast WHERE 1=1
    AND EV_ID_in = :NEW.EV_ID_in
    AND AC_ID_wasCast = :NEW.AC_ID_wasCast
    ;
END dtEV_in_AC_wasCast;
/
CREATE OR REPLACE TRIGGER itAC_part_PR_in_RAT_got
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_part_PR_in_RAT_got instead of INSERT trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- HISTORIZED KNOTTED 
    INSERT INTO AC_part_PR_in_RAT_got (
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got,
        AC_part_PR_in_RAT_got_ChangedA,
        Metadata_AC_part_PR_in_RAT_got
    ) VALUES (
        :NEW.AC_ID_part,
        :NEW.PR_ID_in,
        (select a.RAT_ID from RAT_Rating a where a.RAT_Rating = :NEW.got_RAT_Rating), -- Denna kolumn har också ett konstraint till en KNOT och måste därför särbehandlas
        NVL(:NEW.AC_part_PR_in_RAT_got_ChangedA,l_now),
        :NEW.Metadata_AC_part_PR_in_RAT_got
    );
END itAC_part_PR_in_RAT_got;
/

CREATE OR REPLACE TRIGGER utAC_part_PR_in_RAT_got
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utAC_part_PR_in_RAT_got instead of UPDATE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF UPDATE
ON lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
    -- är kolumnen förändrad, OBS tar hänsyn till NULL
    function is_changed ( in_new varchar2, in_old varchar2) return boolean is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return false;
        else
            -- TRUE
            return true;
        end if;
    end is_changed;
BEGIN

 -- HISTORIZED KNOTTED 
    -- Relationskolumner får ej uppdateras
    if is_changed(:NEW.AC_ID_part, :OLD.AC_ID_part) then
        raise_application_error(-20001, 'Relationskolumnen AC_part_PR_in_RAT_got.AC_ID_part får ej uppdateras');
    end if;
    -- Relationskolumner får ej uppdateras
    if is_changed(:NEW.PR_ID_in, :OLD.PR_ID_in) then
        raise_application_error(-20001, 'Relationskolumnen AC_part_PR_in_RAT_got.PR_ID_in får ej uppdateras');
    end if;
    INSERT INTO AC_part_PR_in_RAT_got (
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got,
        AC_part_PR_in_RAT_got_ChangedA,
        Metadata_AC_part_PR_in_RAT_got
    ) VALUES (
        :NEW.AC_ID_part,
        :NEW.PR_ID_in,
        (select a.RAT_ID from RAT_Rating a where a.RAT_Rating = :NEW.got_RAT_Rating), -- Denna kolumn har också ett konstraint till en KNOT och måste därför särbehandlas
        NVL(:NEW.AC_part_PR_in_RAT_got_ChangedA,l_now),
        :NEW.Metadata_AC_part_PR_in_RAT_got
    );
END utAC_part_PR_in_RAT_got;
/

CREATE OR REPLACE TRIGGER dtAC_part_PR_in_RAT_got
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtAC_part_PR_in_RAT_got instead of DELETE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE AC_part_PR_in_RAT_got WHERE 1=1
    AND AC_part_PR_in_RAT_got_ChangedA = :NEW.AC_part_PR_in_RAT_got_ChangedA
    AND AC_ID_part = :NEW.AC_ID_part
    AND PR_ID_in = :NEW.PR_ID_in
    ;
END dtAC_part_PR_in_RAT_got;
/
CREATE OR REPLACE TRIGGER itST_at_PR_isPlaying
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itST_at_PR_isPlaying instead of INSERT trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lST_at_PR_isPlaying
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- HISTORIZED NOT KNOTTED 
    INSERT INTO ST_at_PR_isPlaying (
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_ChangedAt,
        Metadata_ST_at_PR_isPlaying
    ) VALUES (
        :NEW.ST_ID_at,
        :NEW.PR_ID_isPlaying,
        NVL(:NEW.ST_at_PR_isPlaying_ChangedAt,l_now),
        :NEW.Metadata_ST_at_PR_isPlaying
    );
END itST_at_PR_isPlaying;
/

CREATE OR REPLACE TRIGGER dtST_at_PR_isPlaying
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtST_at_PR_isPlaying instead of DELETE trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lST_at_PR_isPlaying
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE ST_at_PR_isPlaying WHERE 1=1
    AND ST_at_PR_isPlaying_ChangedAt = :NEW.ST_at_PR_isPlaying_ChangedAt
    AND ST_ID_at = :NEW.ST_ID_at
    AND PR_ID_isPlaying = :NEW.PR_ID_isPlaying
    ;
END dtST_at_PR_isPlaying;
/
CREATE OR REPLACE TRIGGER itAC_parent_AC_child_PAT_having
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_parent_AC_child_PAT_having instead of INSERT trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lAC_parent_AC_child_PAT_having
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- NOT HISTORIZED KNOTTED 
    INSERT INTO AC_parent_AC_child_PAT_having (
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having,

        Metadata_AC_parent_AC_child_PA
    ) VALUES (
        :NEW.AC_ID_parent,
        :NEW.AC_ID_child,
        (select a.PAT_ID from PAT_ParentalType a where a.PAT_ParentalType = :NEW.having_PAT_ParentalType), -- Denna kolumn har också ett konstraint till en KNOT och måste därför särbehandlas

        :NEW.Metadata_AC_parent_AC_child_PA
    );
END itAC_parent_AC_child_PAT_having;
/

CREATE OR REPLACE TRIGGER dtAC_parent_AC_child_PAT_having
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtAC_parent_AC_child_PAT_having instead of DELETE trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lAC_parent_AC_child_PAT_having
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE AC_parent_AC_child_PAT_having WHERE 1=1
    AND AC_ID_parent = :NEW.AC_ID_parent
    AND AC_ID_child = :NEW.AC_ID_child
    AND PAT_ID_having = :NEW.PAT_ID_having
    ;
END dtAC_parent_AC_child_PAT_having;
/
CREATE OR REPLACE TRIGGER itPR_content_ST_location_EV_of
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itPR_content_ST_location_EV_of instead of INSERT trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lPR_content_ST_location_EV_of
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- NOT HISTORIZED NOT KNOTTED 
    INSERT INTO PR_content_ST_location_EV_of (
        PR_ID_content,
        ST_ID_location,
        EV_ID_of,

        Metadata_PR_content_ST_locatio
    ) VALUES (
        :NEW.PR_ID_content,
        :NEW.ST_ID_location,
        :NEW.EV_ID_of,

        :NEW.Metadata_PR_content_ST_locatio
    );
END itPR_content_ST_location_EV_of;
/

CREATE OR REPLACE TRIGGER dtPR_content_ST_location_EV_of
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtPR_content_ST_location_EV_of instead of DELETE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lPR_content_ST_location_EV_of
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE PR_content_ST_location_EV_of WHERE 1=1
    AND EV_ID_of = :NEW.EV_ID_of
    ;
END dtPR_content_ST_location_EV_of;
/
-- KNOT KNOT KNOT KNOT
-- KNOT KNOT KNOT KNOT
-- KNOT KNOT KNOT KNOT
-- KNOT KNOT KNOT KNOT
prompt Populate KNOT lPAT_ParentalType;
INSERT INTO PAT_ParentalType (
    PAT_ID,
    PAT_ParentalType,
    Metadata_PAT
) VALUES (
    100, -- PAT_ID, -- number(3) not null
    '0', -- PAT_ParentalType, -- nvarchar2(42) not null
    0 -- Metadata_PAT
);
prompt Populate KNOT lGEN_Gender;
INSERT INTO GEN_Gender (
    GEN_ID,
    GEN_Gender,
    Metadata_GEN
) VALUES (
    100, -- GEN_ID, -- number(3) not null
    '0', -- GEN_Gender, -- nvarchar2(42) not null
    0 -- Metadata_GEN
);
prompt Populate KNOT lPLV_ProfessionalLevel;
INSERT INTO PLV_ProfessionalLevel (
    PLV_ID,
    PLV_ProfessionalLevel,
    Metadata_PLV
) VALUES (
    100, -- PLV_ID, -- number(3) not null
    '0', -- PLV_ProfessionalLevel, -- nclob not null
    0 -- Metadata_PLV
);
prompt Populate KNOT lUTL_Utilization;
INSERT INTO UTL_Utilization (
    UTL_ID,
    UTL_Utilization,
    Metadata_UTL
) VALUES (
    100, -- UTL_ID, -- number(3) not null
    '0', -- UTL_Utilization, -- number(3) not null
    0 -- Metadata_UTL
);
prompt Populate KNOT lONG_Ongoing;
INSERT INTO ONG_Ongoing (
    ONG_ID,
    ONG_Ongoing,
    Metadata_ONG
) VALUES (
    100, -- ONG_ID, -- number(3) not null
    '0', -- ONG_Ongoing, -- nvarchar2(3) not null
    0 -- Metadata_ONG
);
prompt Populate KNOT lRAT_Rating;
INSERT INTO RAT_Rating (
    RAT_ID,
    RAT_Rating,
    Metadata_RAT
) VALUES (
    100, -- RAT_ID, -- number(3) not null
    '0', -- RAT_Rating, -- nvarchar2(42) not null
    0 -- Metadata_RAT
);
prompt Populate KNOT lETY_EventType;
INSERT INTO ETY_EventType (
    ETY_ID,
    ETY_EventType,
    Metadata_ETY
) VALUES (
    100, -- ETY_ID, -- number(3) not null
    '0', -- ETY_EventType, -- nvarchar2(42) not null
    0 -- Metadata_ETY
);


-- ANCHOR ANCHOR ANCHOR ANCHOR
-- ANCHOR ANCHOR ANCHOR ANCHOR
-- ANCHOR ANCHOR ANCHOR ANCHOR
-- ANCHOR ANCHOR ANCHOR ANCHOR
prompt Populate ANCHOR lPN_Person;
declare
    l_now   date := sysdate;
    l_count integer := 0;
begin
    for i in 10000000 .. 10000100 loop
        INSERT INTO lPN_Person ( -- 10000000
            PN_ID,
            Metadata_PN 
        ) VALUES ( -- 10000000
            i, -- PN_ID
            0 -- Metadata_PN, : PN_Dummy,
        );
        l_count := l_count + 1;
    end loop;
end;
/
prompt Populate ANCHOR lST_Stage;
declare
    l_now   date := sysdate;
    l_count integer := 0;
begin
    for i in 20000000 .. 20000100 loop
        INSERT INTO lST_Stage ( -- 20000000
            ST_ID,
            Metadata_ST ,
            ST_NAM_ST_ID,     -- ATTRIBUTE
            Metadata_ST_NAM,     -- ATTRIBUTE
            ST_NAM_ChangedAt,     -- ATTRIBUTE
            ST_NAM_Stage_Name,     -- ATTRIBUTE
            ST_LOC_ST_ID,     -- ATTRIBUTE
            Metadata_ST_LOC,     -- ATTRIBUTE

            ST_LOC_Stage_Location,     -- ATTRIBUTE
            ST_AVG_ST_ID,     -- ATTRIBUTE
            Metadata_ST_AVG,     -- ATTRIBUTE
            ST_AVG_ChangedAt,     -- ATTRIBUTE
            ST_AVG_UTL_Utilization,    -- KNOT
            ST_AVG_Metadata_UTL,    -- KNOT
            ST_AVG_UTL_ID,     -- ATTRIBUTE
            ST_MIN_ST_ID,     -- ATTRIBUTE
            Metadata_ST_MIN,     -- ATTRIBUTE

            ST_MIN_UTL_Utilization,    -- KNOT
            ST_MIN_Metadata_UTL,    -- KNOT
            ST_MIN_UTL_ID     -- ATTRIBUTE
        ) VALUES ( -- 20000000
            i, -- ST_ID
            0, -- Metadata_ST, : ST_Dummy,
            NULL, -- ST_NAM_ST_ID,     -- ATTRIBUTE
            NULL, -- Metadata_ST_NAM,     -- ATTRIBUTE
            l_now, -- ST_NAM_ChangedAt,     -- ATTRIBUTE
            substr(l_count,1,42), -- ST_NAM_Stage_Name nvarchar2(42) l_precision = 42)
            NULL, -- ST_LOC_ST_ID,     -- ATTRIBUTE
            NULL, -- Metadata_ST_LOC,     -- ATTRIBUTE

            substr(l_count,1,geography, -- ST_LOC_Stage_Location geography l_precision = geography
            NULL, -- ST_AVG_ST_ID,     -- ATTRIBUTE
            NULL, -- Metadata_ST_AVG,     -- ATTRIBUTE
            l_now, -- ST_AVG_ChangedAt,     -- ATTRIBUTE
            '0', -- ST_AVG_UTL_Utilization    -- KNOT
            NULL, -- ST_AVG_Metadata_UTL    -- KNOT
            l_count, -- ST_AVG_UTL_ID  l_precision = geography
            NULL, -- ST_MIN_ST_ID,     -- ATTRIBUTE
            NULL, -- Metadata_ST_MIN,     -- ATTRIBUTE

            '0', -- ST_MIN_UTL_Utilization    -- KNOT
            NULL, -- ST_MIN_Metadata_UTL    -- KNOT
            l_count -- ST_MIN_UTL_ID  l_precision = geography
        );
        l_count := l_count + 1;
    end loop;
end;
/
prompt Populate ANCHOR lAC_Actor;
declare
    l_now   date := sysdate;
    l_count integer := 0;
begin
    for i in 30000000 .. 30000100 loop
        INSERT INTO lAC_Actor ( -- 30000000
            AC_ID,
            Metadata_AC ,
            AC_NAM_AC_ID,     -- ATTRIBUTE
            Metadata_AC_NAM,     -- ATTRIBUTE
            AC_NAM_ChangedAt,     -- ATTRIBUTE
            AC_NAM_Actor_Name,     -- ATTRIBUTE
            AC_GEN_AC_ID,     -- ATTRIBUTE
            Metadata_AC_GEN,     -- ATTRIBUTE

            AC_GEN_GEN_Gender,    -- KNOT
            AC_GEN_Metadata_GEN,    -- KNOT
            AC_GEN_GEN_ID,     -- ATTRIBUTE
            AC_PLV_AC_ID,     -- ATTRIBUTE
            Metadata_AC_PLV,     -- ATTRIBUTE
            AC_PLV_ChangedAt,     -- ATTRIBUTE
            AC_PLV_PLV_ProfessionalLevel,    -- KNOT
            AC_PLV_Metadata_PLV,    -- KNOT
            AC_PLV_PLV_ID     -- ATTRIBUTE
        ) VALUES ( -- 30000000
            i, -- AC_ID
            0, -- Metadata_AC, : AC_Dummy,
            NULL, -- AC_NAM_AC_ID,     -- ATTRIBUTE
            NULL, -- Metadata_AC_NAM,     -- ATTRIBUTE
            l_now, -- AC_NAM_ChangedAt,     -- ATTRIBUTE
            substr(l_count,1,42), -- AC_NAM_Actor_Name nvarchar2(42) l_precision = 42)
            NULL, -- AC_GEN_AC_ID,     -- ATTRIBUTE
            NULL, -- Metadata_AC_GEN,     -- ATTRIBUTE

            '0', -- AC_GEN_GEN_Gender    -- KNOT
            NULL, -- AC_GEN_Metadata_GEN    -- KNOT
            l_count, -- AC_GEN_GEN_ID  l_precision = 42)
            NULL, -- AC_PLV_AC_ID,     -- ATTRIBUTE
            NULL, -- Metadata_AC_PLV,     -- ATTRIBUTE
            l_now, -- AC_PLV_ChangedAt,     -- ATTRIBUTE
            '0', -- AC_PLV_PLV_ProfessionalLevel    -- KNOT
            NULL, -- AC_PLV_Metadata_PLV    -- KNOT
            l_count -- AC_PLV_PLV_ID  l_precision = 42)
        );
        l_count := l_count + 1;
    end loop;
end;
/
prompt Populate ANCHOR lPR_Program;
declare
    l_now   date := sysdate;
    l_count integer := 0;
begin
    for i in 40000000 .. 40000100 loop
        INSERT INTO lPR_Program ( -- 40000000
            PR_ID,
            Metadata_PR ,
            PR_NAM_PR_ID,     -- ATTRIBUTE
            Metadata_PR_NAM,     -- ATTRIBUTE

            PR_NAM_Program_Name,     -- ATTRIBUTE
            PR_LEN_PR_ID,     -- ATTRIBUTE
            Metadata_PR_LEN,     -- ATTRIBUTE
            PR_LEN_ChangedAt,     -- ATTRIBUTE
            PR_LEN_Program_Length     -- ATTRIBUTE
        ) VALUES ( -- 40000000
            i, -- PR_ID
            0, -- Metadata_PR, : PR_Dummy,
            NULL, -- PR_NAM_PR_ID,     -- ATTRIBUTE
            NULL, -- Metadata_PR_NAM,     -- ATTRIBUTE

            substr(l_count,1,42), -- PR_NAM_Program_Name nvarchar2(42) l_precision = 42)
            NULL, -- PR_LEN_PR_ID,     -- ATTRIBUTE
            NULL, -- Metadata_PR_LEN,     -- ATTRIBUTE
            l_now, -- PR_LEN_ChangedAt,     -- ATTRIBUTE
            substr(l_count,1,timestamp -- PR_LEN_Program_Length timestamp l_precision = timestamp
        );
        l_count := l_count + 1;
    end loop;
end;
/

-- TIE TIE TIE TIE
-- TIE TIE TIE TIE
-- TIE TIE TIE TIE
-- TIE TIE TIE TIE
prompt Populate TIE lAC_partner_AC_with_ONG_currently;
-- Knotted historized tie table ---------------------------------------------------------------------------------------
    insert into lAC_partner_AC_with_ONG_currently (
        Metadata_AC_partner_AC_with_ON,
        AC_partner_AC_with_ONG_current,
        AC_ID_partner,
        AC_ID_with,
        currently_ONG_Ongoing,  -- KNOT
        currently_Metadata_ONG,  -- KNOT
        ONG_ID_currently
    ) SELECT
        '0' AS Metadata_AC_partner_AC_with_ON,
        NULL AS AC_partner_AC_with_ONG_current,
    AC_ID_partner.AC_ID,
    AC_ID_with.AC_ID,
        ONG_ID_currently.ONG_Ongoing AS currently_ONG_Ongoing,  -- KNOT
        '0' AS currently_Metadata_ONG,  -- KNOT
    ONG_ID_currently.ONG_ID AS ONG_ID_currently

    FROM
    AC_Actor AC_ID_partner,
    AC_Actor AC_ID_with,
    ONG_Ongoing ONG_ID_currently

    WHERE 1=1

    AND substr(AC_ID_partner.AC_ID,4) = substr(AC_ID_with.AC_ID,4)
    ;
prompt Populate TIE lAC_subset_PN_of;
-- Static tie table ---------------------------------------------------------------------------------------------------
    insert into lAC_subset_PN_of (
        Metadata_AC_subset_PN_of,

        AC_ID_subset,
        PN_ID_of
    ) SELECT
        '0' AS Metadata_AC_subset_PN_of,

    AC_ID_subset.AC_ID,
    PN_ID_of.PN_ID

    FROM
    AC_Actor AC_ID_subset,
    PN_Person PN_ID_of

    WHERE 1=1

    AND substr(AC_ID_subset.AC_ID,4) = substr(PN_ID_of.PN_ID,4)
    ;
prompt Populate TIE lEV_in_AC_wasCast;
-- Static tie table ---------------------------------------------------------------------------------------------------
    insert into lEV_in_AC_wasCast (
        Metadata_EV_in_AC_wasCast,

        EV_ID_in,
        AC_ID_wasCast
    ) SELECT
        '0' AS Metadata_EV_in_AC_wasCast,

    EV_ID_in.EV_ID,
    AC_ID_wasCast.AC_ID

    FROM
    EV_Event EV_ID_in,
    AC_Actor AC_ID_wasCast

    WHERE 1=1

    AND substr(EV_ID_in.EV_ID,4) = substr(AC_ID_wasCast.AC_ID,4)
    ;
prompt Populate TIE lAC_part_PR_in_RAT_got;
-- Knotted historized tie table ---------------------------------------------------------------------------------------
    insert into lAC_part_PR_in_RAT_got (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ChangedA,
        AC_ID_part,
        PR_ID_in,
        got_RAT_Rating,  -- KNOT
        got_Metadata_RAT,  -- KNOT
        RAT_ID_got
    ) SELECT
        '0' AS Metadata_AC_part_PR_in_RAT_got,
        NULL AS AC_part_PR_in_RAT_got_ChangedA,
    AC_ID_part.AC_ID,
    PR_ID_in.PR_ID,
        RAT_ID_got.RAT_Rating AS got_RAT_Rating,  -- KNOT
        '0' AS got_Metadata_RAT,  -- KNOT
    RAT_ID_got.RAT_ID AS RAT_ID_got

    FROM
    AC_Actor AC_ID_part,
    PR_Program PR_ID_in,
    RAT_Rating RAT_ID_got

    WHERE 1=1

    AND substr(AC_ID_part.AC_ID,4) = substr(PR_ID_in.PR_ID,4)
    ;
prompt Populate TIE lST_at_PR_isPlaying;
-- Historized tie table -----------------------------------------------------------------------------------------------
    insert into lST_at_PR_isPlaying (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying
    ) SELECT
        '0' AS Metadata_ST_at_PR_isPlaying,
        NULL AS ST_at_PR_isPlaying_ChangedAt,
    ST_ID_at.ST_ID,
    PR_ID_isPlaying.PR_ID

    FROM
    ST_Stage ST_ID_at,
    PR_Program PR_ID_isPlaying

    WHERE 1=1

    AND substr(ST_ID_at.ST_ID,4) = substr(PR_ID_isPlaying.PR_ID,4)
    ;
prompt Populate TIE lAC_parent_AC_child_PAT_having;
-- Knotted static tie table -------------------------------------------------------------------------------------------
    insert into lAC_parent_AC_child_PAT_having (
        Metadata_AC_parent_AC_child_PA,

        AC_ID_parent,
        AC_ID_child,
        having_PAT_ParentalType,  -- KNOT
        having_Metadata_PAT,  -- KNOT
        PAT_ID_having
    ) SELECT
        '0' AS Metadata_AC_parent_AC_child_PA,

    AC_ID_parent.AC_ID,
    AC_ID_child.AC_ID,
        PAT_ID_having.PAT_ParentalType AS having_PAT_ParentalType,  -- KNOT
        '0' AS having_Metadata_PAT,  -- KNOT
    PAT_ID_having.PAT_ID AS PAT_ID_having

    FROM
    AC_Actor AC_ID_parent,
    AC_Actor AC_ID_child,
    PAT_ParentalType PAT_ID_having

    WHERE 1=1

    AND substr(AC_ID_parent.AC_ID,4) = substr(AC_ID_child.AC_ID,4)
    ;
prompt Populate TIE lPR_content_ST_location_EV_of;
-- Static tie table ---------------------------------------------------------------------------------------------------
    insert into lPR_content_ST_location_EV_of (
        Metadata_PR_content_ST_locatio,

        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    ) SELECT
        '0' AS Metadata_PR_content_ST_locatio,

    PR_ID_content.PR_ID,
    ST_ID_location.ST_ID,
    EV_ID_of.EV_ID

    FROM
    PR_Program PR_ID_content,
    ST_Stage ST_ID_location,
    EV_Event EV_ID_of

    WHERE 1=1

    AND substr(PR_ID_content.PR_ID,4) = substr(ST_ID_location.ST_ID,4)

    AND substr(ST_ID_location.ST_ID,4) = substr(EV_ID_of.EV_ID,4)
    ;
COMMIT;
