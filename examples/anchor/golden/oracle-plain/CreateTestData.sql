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
            PN_Dummy 
        ) VALUES ( -- 10000000
            i, -- PN_ID
            -- Metadata_PN, : PN_Dummy,
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
            ST_Dummy ,


            ST_NAM_ChangedAt,     -- ATTRIBUTE
            ST_NAM_Stage_Name,     -- ATTRIBUTE



            ST_LOC_Stage_Location,     -- ATTRIBUTE


            ST_AVG_ChangedAt,     -- ATTRIBUTE
            UTL_Utilization,    -- KNOT

            UTL_ID,     -- ATTRIBUTE



            UTL_Utilization,    -- KNOT

            UTL_ID     -- ATTRIBUTE
        ) VALUES ( -- 20000000
            i, -- ST_ID
            , -- Metadata_ST, : ST_Dummy,


            l_now, -- ST_NAM_ChangedAt,     -- ATTRIBUTE
            substr(l_count,1,42), -- ST_NAM_Stage_Name nvarchar2(42) l_precision = 42)



            substr(l_count,1,geography, -- ST_LOC_Stage_Location geography l_precision = geography


            l_now, -- ST_AVG_ChangedAt,     -- ATTRIBUTE
            '0', -- UTL_Utilization    -- KNOT

            l_count, -- UTL_ID  l_precision = geography



            '0', -- UTL_Utilization    -- KNOT

            l_count -- UTL_ID  l_precision = geography
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
            AC_Dummy ,


            AC_NAM_ChangedAt,     -- ATTRIBUTE
            AC_NAM_Actor_Name,     -- ATTRIBUTE



            GEN_Gender,    -- KNOT

            GEN_ID,     -- ATTRIBUTE


            AC_PLV_ChangedAt,     -- ATTRIBUTE
            PLV_ProfessionalLevel,    -- KNOT

            PLV_ID     -- ATTRIBUTE
        ) VALUES ( -- 30000000
            i, -- AC_ID
            , -- Metadata_AC, : AC_Dummy,


            l_now, -- AC_NAM_ChangedAt,     -- ATTRIBUTE
            substr(l_count,1,42), -- AC_NAM_Actor_Name nvarchar2(42) l_precision = 42)



            '0', -- GEN_Gender    -- KNOT

            l_count, -- GEN_ID  l_precision = 42)


            l_now, -- AC_PLV_ChangedAt,     -- ATTRIBUTE
            '0', -- PLV_ProfessionalLevel    -- KNOT

            l_count -- PLV_ID  l_precision = 42)
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
            PR_Dummy ,



            PR_NAM_Program_Name,     -- ATTRIBUTE


            PR_LEN_ChangedAt,     -- ATTRIBUTE
            PR_LEN_Program_Length     -- ATTRIBUTE
        ) VALUES ( -- 40000000
            i, -- PR_ID
            , -- Metadata_PR, : PR_Dummy,



            substr(l_count,1,42), -- PR_NAM_Program_Name nvarchar2(42) l_precision = 42)


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

        AC_partner_AC_with_ONG_current,
        AC_ID_partner,
        AC_ID_with,
        ONG_Ongoing,  -- KNOT

        ONG_ID_currently
    ) SELECT
        ,
        NULL AS AC_partner_AC_with_ONG_current,
    AC_ID_partner.AC_ID,
    AC_ID_with.AC_ID,
        ONG_ID_currently.ONG_Ongoing AS ONG_Ongoing,  -- KNOT

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


        AC_ID_subset,
        PN_ID_of
    ) SELECT
        ,

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


        EV_ID_in,
        AC_ID_wasCast
    ) SELECT
        ,

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

        AC_part_PR_in_RAT_got_ChangedA,
        AC_ID_part,
        PR_ID_in,
        RAT_Rating,  -- KNOT

        RAT_ID_got
    ) SELECT
        ,
        NULL AS AC_part_PR_in_RAT_got_ChangedA,
    AC_ID_part.AC_ID,
    PR_ID_in.PR_ID,
        RAT_ID_got.RAT_Rating AS RAT_Rating,  -- KNOT

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

        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying
    ) SELECT
        ,
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


        AC_ID_parent,
        AC_ID_child,
        PAT_ParentalType,  -- KNOT

        PAT_ID_having
    ) SELECT
        ,

    AC_ID_parent.AC_ID,
    AC_ID_child.AC_ID,
        PAT_ID_having.PAT_ParentalType AS PAT_ParentalType,  -- KNOT

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


        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    ) SELECT
        ,

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
