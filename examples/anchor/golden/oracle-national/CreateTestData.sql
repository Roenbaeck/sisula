-- KNOT KNOT KNOT KNOT
-- KNOT KNOT KNOT KNOT
-- KNOT KNOT KNOT KNOT
-- KNOT KNOT KNOT KNOT
prompt Populate KNOT lPAT_Föräldratyp;
INSERT INTO PAT_Föräldratyp (
    PAT_ID,
    PAT_Föräldratyp,
    Metadata_PAT
) VALUES (
    100, -- PAT_ID, -- number(3) not null
    '0', -- PAT_Föräldratyp, -- nvarchar2(42) not null
    0 -- Metadata_PAT
);
prompt Populate KNOT lGEN_Kön;
INSERT INTO GEN_Kön (
    GEN_ID,
    GEN_Kön,
    Metadata_GEN
) VALUES (
    100, -- GEN_ID, -- number(3) not null
    '0', -- GEN_Kön, -- nvarchar2(42) not null
    0 -- Metadata_GEN
);
prompt Populate KNOT lPLV_Yrkesnivå;
INSERT INTO PLV_Yrkesnivå (
    PLV_ID,
    PLV_Yrkesnivå,
    Metadata_PLV
) VALUES (
    100, -- PLV_ID, -- number(3) not null
    '0', -- PLV_Yrkesnivå, -- nclob not null
    0 -- Metadata_PLV
);
prompt Populate KNOT lUTL_Utnyttjande;
INSERT INTO UTL_Utnyttjande (
    UTL_ID,
    UTL_Utnyttjande,
    Metadata_UTL
) VALUES (
    100, -- UTL_ID, -- number(3) not null
    '0', -- UTL_Utnyttjande, -- number(3) not null
    0 -- Metadata_UTL
);
prompt Populate KNOT lONG_Pågående;
INSERT INTO ONG_Pågående (
    ONG_ID,
    ONG_Pågående,
    Metadata_ONG
) VALUES (
    100, -- ONG_ID, -- number(3) not null
    '0', -- ONG_Pågående, -- nvarchar2(3) not null
    0 -- Metadata_ONG
);
prompt Populate KNOT lRAT_Betyg;
INSERT INTO RAT_Betyg (
    RAT_ID,
    RAT_Betyg,
    Metadata_RAT
) VALUES (
    100, -- RAT_ID, -- number(3) not null
    '0', -- RAT_Betyg, -- nvarchar2(42) not null
    0 -- Metadata_RAT
);
prompt Populate KNOT lETY_Händelsetyp;
INSERT INTO ETY_Händelsetyp (
    ETY_ID,
    ETY_Händelsetyp,
    Metadata_ETY
) VALUES (
    100, -- ETY_ID, -- number(3) not null
    '0', -- ETY_Händelsetyp, -- nvarchar2(42) not null
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
prompt Populate ANCHOR lST_Scen;
declare
    l_now   date := sysdate;
    l_count integer := 0;
begin
    for i in 20000000 .. 20000100 loop
        INSERT INTO lST_Scen ( -- 20000000
            ST_ID,
            Metadata_ST ,
            ST_NAM_ST_ID,     -- ATTRIBUTE
            Metadata_ST_NAM,     -- ATTRIBUTE
            ST_NAM_ChangedAt,     -- ATTRIBUTE
            ST_NAM_Scen_Namn,     -- ATTRIBUTE
            ST_LOC_ST_ID,     -- ATTRIBUTE
            Metadata_ST_LOC,     -- ATTRIBUTE

            ST_LOC_Scen_Plats,     -- ATTRIBUTE
            ST_AVG_ST_ID,     -- ATTRIBUTE
            Metadata_ST_AVG,     -- ATTRIBUTE
            ST_AVG_ChangedAt,     -- ATTRIBUTE
            ST_AVG_UTL_Utnyttjande,    -- KNOT
            ST_AVG_Metadata_UTL,    -- KNOT
            ST_AVG_UTL_ID,     -- ATTRIBUTE
            ST_MIN_ST_ID,     -- ATTRIBUTE
            Metadata_ST_MIN,     -- ATTRIBUTE

            ST_MIN_UTL_Utnyttjande,    -- KNOT
            ST_MIN_Metadata_UTL,    -- KNOT
            ST_MIN_UTL_ID     -- ATTRIBUTE
        ) VALUES ( -- 20000000
            i, -- ST_ID
            0, -- Metadata_ST, : ST_Dummy,
            NULL, -- ST_NAM_ST_ID,     -- ATTRIBUTE
            NULL, -- Metadata_ST_NAM,     -- ATTRIBUTE
            l_now, -- ST_NAM_ChangedAt,     -- ATTRIBUTE
            substr(l_count,1,42), -- ST_NAM_Scen_Namn nvarchar2(42) l_precision = 42)
            NULL, -- ST_LOC_ST_ID,     -- ATTRIBUTE
            NULL, -- Metadata_ST_LOC,     -- ATTRIBUTE

            substr(l_count,1,geography, -- ST_LOC_Scen_Plats geography l_precision = geography
            NULL, -- ST_AVG_ST_ID,     -- ATTRIBUTE
            NULL, -- Metadata_ST_AVG,     -- ATTRIBUTE
            l_now, -- ST_AVG_ChangedAt,     -- ATTRIBUTE
            '0', -- ST_AVG_UTL_Utnyttjande    -- KNOT
            NULL, -- ST_AVG_Metadata_UTL    -- KNOT
            l_count, -- ST_AVG_UTL_ID  l_precision = geography
            NULL, -- ST_MIN_ST_ID,     -- ATTRIBUTE
            NULL, -- Metadata_ST_MIN,     -- ATTRIBUTE

            '0', -- ST_MIN_UTL_Utnyttjande    -- KNOT
            NULL, -- ST_MIN_Metadata_UTL    -- KNOT
            l_count -- ST_MIN_UTL_ID  l_precision = geography
        );
        l_count := l_count + 1;
    end loop;
end;
/
prompt Populate ANCHOR lAC_Skådespelare;
declare
    l_now   date := sysdate;
    l_count integer := 0;
begin
    for i in 30000000 .. 30000100 loop
        INSERT INTO lAC_Skådespelare ( -- 30000000
            AC_ID,
            Metadata_AC ,
            AC_NAM_AC_ID,     -- ATTRIBUTE
            Metadata_AC_NAM,     -- ATTRIBUTE
            AC_NAM_ChangedAt,     -- ATTRIBUTE
            AC_NAM_Skådespelare_Namn,     -- ATTRIBUTE
            AC_GEN_AC_ID,     -- ATTRIBUTE
            Metadata_AC_GEN,     -- ATTRIBUTE

            AC_GEN_GEN_Kön,    -- KNOT
            AC_GEN_Metadata_GEN,    -- KNOT
            AC_GEN_GEN_ID,     -- ATTRIBUTE
            AC_PLV_AC_ID,     -- ATTRIBUTE
            Metadata_AC_PLV,     -- ATTRIBUTE
            AC_PLV_ChangedAt,     -- ATTRIBUTE
            AC_PLV_PLV_Yrkesnivå,    -- KNOT
            AC_PLV_Metadata_PLV,    -- KNOT
            AC_PLV_PLV_ID     -- ATTRIBUTE
        ) VALUES ( -- 30000000
            i, -- AC_ID
            0, -- Metadata_AC, : AC_Dummy,
            NULL, -- AC_NAM_AC_ID,     -- ATTRIBUTE
            NULL, -- Metadata_AC_NAM,     -- ATTRIBUTE
            l_now, -- AC_NAM_ChangedAt,     -- ATTRIBUTE
            substr(l_count,1,42), -- AC_NAM_Skådespelare_Namn nvarchar2(42) l_precision = 42)
            NULL, -- AC_GEN_AC_ID,     -- ATTRIBUTE
            NULL, -- Metadata_AC_GEN,     -- ATTRIBUTE

            '0', -- AC_GEN_GEN_Kön    -- KNOT
            NULL, -- AC_GEN_Metadata_GEN    -- KNOT
            l_count, -- AC_GEN_GEN_ID  l_precision = 42)
            NULL, -- AC_PLV_AC_ID,     -- ATTRIBUTE
            NULL, -- Metadata_AC_PLV,     -- ATTRIBUTE
            l_now, -- AC_PLV_ChangedAt,     -- ATTRIBUTE
            '0', -- AC_PLV_PLV_Yrkesnivå    -- KNOT
            NULL, -- AC_PLV_Metadata_PLV    -- KNOT
            l_count -- AC_PLV_PLV_ID  l_precision = 42)
        );
        l_count := l_count + 1;
    end loop;
end;
/
prompt Populate ANCHOR lPR_Föreställning;
declare
    l_now   date := sysdate;
    l_count integer := 0;
begin
    for i in 40000000 .. 40000100 loop
        INSERT INTO lPR_Föreställning ( -- 40000000
            PR_ID,
            Metadata_PR ,
            PR_NAM_PR_ID,     -- ATTRIBUTE
            Metadata_PR_NAM,     -- ATTRIBUTE

            PR_NAM_Föreställning_Namn,     -- ATTRIBUTE
            PR_LEN_PR_ID,     -- ATTRIBUTE
            Metadata_PR_LEN,     -- ATTRIBUTE
            PR_LEN_ChangedAt,     -- ATTRIBUTE
            PR_LEN_Föreställning_Längd     -- ATTRIBUTE
        ) VALUES ( -- 40000000
            i, -- PR_ID
            0, -- Metadata_PR, : PR_Dummy,
            NULL, -- PR_NAM_PR_ID,     -- ATTRIBUTE
            NULL, -- Metadata_PR_NAM,     -- ATTRIBUTE

            substr(l_count,1,42), -- PR_NAM_Föreställning_Namn nvarchar2(42) l_precision = 42)
            NULL, -- PR_LEN_PR_ID,     -- ATTRIBUTE
            NULL, -- Metadata_PR_LEN,     -- ATTRIBUTE
            l_now, -- PR_LEN_ChangedAt,     -- ATTRIBUTE
            substr(l_count,1,timestamp -- PR_LEN_Föreställning_Längd timestamp l_precision = timestamp
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
        currently_ONG_Pågående,  -- KNOT
        currently_Metadata_ONG,  -- KNOT
        ONG_ID_currently
    ) SELECT
        '0' AS Metadata_AC_partner_AC_with_ON,
        NULL AS AC_partner_AC_with_ONG_current,
    AC_ID_partner.AC_ID,
    AC_ID_with.AC_ID,
        ONG_ID_currently.ONG_Pågående AS currently_ONG_Pågående,  -- KNOT
        '0' AS currently_Metadata_ONG,  -- KNOT
    ONG_ID_currently.ONG_ID AS ONG_ID_currently

    FROM
    AC_Skådespelare AC_ID_partner,
    AC_Skådespelare AC_ID_with,
    ONG_Pågående ONG_ID_currently

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
    AC_Skådespelare AC_ID_subset,
    PN_Person PN_ID_of

    WHERE 1=1

    AND substr(AC_ID_subset.AC_ID,4) = substr(PN_ID_of.PN_ID,4)
    ;
prompt Populate TIE lEV_in_AC_rollsattes;
-- Static tie table ---------------------------------------------------------------------------------------------------
    insert into lEV_in_AC_rollsattes (
        Metadata_EV_in_AC_rollsattes,

        EV_ID_in,
        AC_ID_rollsattes
    ) SELECT
        '0' AS Metadata_EV_in_AC_rollsattes,

    EV_ID_in.EV_ID,
    AC_ID_rollsattes.AC_ID

    FROM
    EV_Händelse EV_ID_in,
    AC_Skådespelare AC_ID_rollsattes

    WHERE 1=1

    AND substr(EV_ID_in.EV_ID,4) = substr(AC_ID_rollsattes.AC_ID,4)
    ;
prompt Populate TIE lAC_deltar_PR_in_RAT_fick;
-- Knotted historized tie table ---------------------------------------------------------------------------------------
    insert into lAC_deltar_PR_in_RAT_fick (
        Metadata_AC_deltar_PR_in_RAT_f,
        AC_deltar_PR_in_RAT_fick_Chang,
        AC_ID_deltar,
        PR_ID_in,
        fick_RAT_Betyg,  -- KNOT
        fick_Metadata_RAT,  -- KNOT
        RAT_ID_fick
    ) SELECT
        '0' AS Metadata_AC_deltar_PR_in_RAT_f,
        NULL AS AC_deltar_PR_in_RAT_fick_Chang,
    AC_ID_deltar.AC_ID,
    PR_ID_in.PR_ID,
        RAT_ID_fick.RAT_Betyg AS fick_RAT_Betyg,  -- KNOT
        '0' AS fick_Metadata_RAT,  -- KNOT
    RAT_ID_fick.RAT_ID AS RAT_ID_fick

    FROM
    AC_Skådespelare AC_ID_deltar,
    PR_Föreställning PR_ID_in,
    RAT_Betyg RAT_ID_fick

    WHERE 1=1

    AND substr(AC_ID_deltar.AC_ID,4) = substr(PR_ID_in.PR_ID,4)
    ;
prompt Populate TIE lST_at_PR_spelas;
-- Historized tie table -----------------------------------------------------------------------------------------------
    insert into lST_at_PR_spelas (
        Metadata_ST_at_PR_spelas,
        ST_at_PR_spelas_ChangedAt,
        ST_ID_at,
        PR_ID_spelas
    ) SELECT
        '0' AS Metadata_ST_at_PR_spelas,
        NULL AS ST_at_PR_spelas_ChangedAt,
    ST_ID_at.ST_ID,
    PR_ID_spelas.PR_ID

    FROM
    ST_Scen ST_ID_at,
    PR_Föreställning PR_ID_spelas

    WHERE 1=1

    AND substr(ST_ID_at.ST_ID,4) = substr(PR_ID_spelas.PR_ID,4)
    ;
prompt Populate TIE lAC_förälder_AC_barn_PAT_har;
-- Knotted static tie table -------------------------------------------------------------------------------------------
    insert into lAC_förälder_AC_barn_PAT_har (
        Metadata_AC_förälder_AC_barn_P,

        AC_ID_förälder,
        AC_ID_barn,
        har_PAT_Föräldratyp,  -- KNOT
        har_Metadata_PAT,  -- KNOT
        PAT_ID_har
    ) SELECT
        '0' AS Metadata_AC_förälder_AC_barn_P,

    AC_ID_förälder.AC_ID,
    AC_ID_barn.AC_ID,
        PAT_ID_har.PAT_Föräldratyp AS har_PAT_Föräldratyp,  -- KNOT
        '0' AS har_Metadata_PAT,  -- KNOT
    PAT_ID_har.PAT_ID AS PAT_ID_har

    FROM
    AC_Skådespelare AC_ID_förälder,
    AC_Skådespelare AC_ID_barn,
    PAT_Föräldratyp PAT_ID_har

    WHERE 1=1

    AND substr(AC_ID_förälder.AC_ID,4) = substr(AC_ID_barn.AC_ID,4)
    ;
prompt Populate TIE lPR_innehåll_ST_plats_EV_of;
-- Historized tie table -----------------------------------------------------------------------------------------------
    insert into lPR_innehåll_ST_plats_EV_of (
        Metadata_PR_innehåll_ST_plats_,
        PR_innehåll_ST_plats_EV_of_Cha,
        PR_ID_innehåll,
        ST_ID_plats,
        EV_ID_of
    ) SELECT
        '0' AS Metadata_PR_innehåll_ST_plats_,
        NULL AS PR_innehåll_ST_plats_EV_of_Cha,
    PR_ID_innehåll.PR_ID,
    ST_ID_plats.ST_ID,
    EV_ID_of.EV_ID

    FROM
    PR_Föreställning PR_ID_innehåll,
    ST_Scen ST_ID_plats,
    EV_Händelse EV_ID_of

    WHERE 1=1

    AND substr(PR_ID_innehåll.PR_ID,4) = substr(ST_ID_plats.ST_ID,4)

    AND substr(ST_ID_plats.ST_ID,4) = substr(EV_ID_of.EV_ID,4)
    ;
COMMIT;
