-- Perspective tests, uni-temporal: what the latest, point-in-time, now and difference perspectives show.
--
-- Runs against the output for models/distinct.xml (golden/distinct/_full.sql) in an empty database;
-- tools/snowflake-tests.ps1 does both, and makes public.test_result. Snowflake has no triggers, so the rows go straight
-- into the tables. Each check adds a row to public.test_result: what a perspective shows, written out as a string, and
-- whether it is what was expected. The groups are separated by GO and sent one at a time; a group that ends with an
-- error counts as a failure. Every group uses rows of its own, with identities from 100 up so as not to meet the ones
-- a sequence hands out.

-- setup: the knot values that the groups use
INSERT INTO knots."UTL_Utilization" ("UTL_ID", "UTL_Utilization", "Metadata_UTL") VALUES (1, 10, 0), (2, 20, 0), (3, 30, 0);
INSERT INTO knots."PLV_ProfessionalLevel" ("PLV_ID", "PLV_ProfessionalLevel", "Metadata_PLV") VALUES (1, 'junior', 0), (2, 'senior', 0);
INSERT INTO knots."ONG_Ongoing" ("ONG_ID", "ONG_Ongoing", "Metadata_ONG") VALUES (1, 'yes', 0), (2, 'no', 0);
INSERT INTO knots."RAT_Rating" ("RAT_ID", "RAT_Rating", "Metadata_RAT") VALUES (1, 'good', 0), (2, 'bad', 0);
INSERT INTO knots."ETY_EventType" ("ETY_ID", "ETY_EventType", "Metadata_ETY") VALUES (1, 'premiere', 0), (2, 'regular', 0);
GO

-- u01 the latest view of an anchor shows the latest value of each historized attribute, and the static ones
INSERT INTO anchors."ST_Stage" ("ST_ID", "Metadata_ST") VALUES (101, 0), (102, 0), (103, 0);
INSERT INTO attributes."ST_NAM_Stage_Name" ("ST_NAM_ST_ID", "ST_NAM_Stage_Name", "ST_NAM_ChangedAt", "Metadata_ST_NAM") VALUES
    (101, 'Old Hall', '2020-01-01', 0), (101, 'New Hall', '2022-01-01', 0), (102, 'Studio', '2021-01-01', 0);
INSERT INTO attributes."ST_AVG_Stage_Average" ("ST_AVG_ST_ID", "ST_AVG_UTL_ID", "ST_AVG_ChangedAt", "Metadata_ST_AVG") VALUES
    (101, 1, '2020-01-01', 0), (101, 2, '2021-06-01', 0), (102, 3, '2021-01-01', 0);
INSERT INTO attributes."ST_MIN_Stage_Minimum" ("ST_MIN_ST_ID", "ST_MIN_UTL_ID", "Metadata_ST_MIN") VALUES (101, 1, 0);
INSERT INTO attributes."ST_LOC_Stage_Location" ("ST_LOC_ST_ID", "ST_LOC_Stage_Location", "Metadata_ST_LOC")
SELECT 101, to_geography('POINT(18.07 59.33)'), 0;
INSERT INTO public.test_result (test, passed, detail)
SELECT 'u01 the latest view shows the latest value of each attribute', shown = '101 New Hall 20 10 located, 102 Studio 30 - -, 103 - - - -', shown
FROM (
    SELECT coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-') || ' ' || coalesce("ST_AVG_UTL_Utilization"::varchar, '-')
        || ' ' || coalesce("ST_MIN_UTL_Utilization"::varchar, '-') || ' ' || iff("ST_LOC_Stage_Location" IS NULL, '-', 'located'), ', ')
        WITHIN GROUP (ORDER BY "ST_ID"), '') AS shown
    FROM anchors."lST_Stage"
    WHERE "ST_ID" BETWEEN 101 AND 103
);
GO

-- u02 the point-in-time perspective of an anchor shows the values in effect at the time, a change at the time included
--     (each time is a call of its own: Snowflake cannot call the perspective for each row of another table, see u04)
INSERT INTO public.test_result (test, passed, detail)
SELECT 'u02 the point-in-time perspective shows the values in effect at ' || at, shown = expected, shown
FROM (
    SELECT at, expected, coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-') || ' ' || coalesce("ST_AVG_UTL_Utilization"::varchar, '-'), ', ')
        WITHIN GROUP (ORDER BY "ST_ID"), '') AS shown
    FROM (
        SELECT '2019-01-01' AS at, '101 - -, 102 - -, 103 - -' AS expected, p.* FROM TABLE(anchors."pST_Stage"('2019-01-01'::timestamp_ntz(9))) p
        UNION ALL
        SELECT '2021-01-01', '101 Old Hall 10, 102 Studio 30, 103 - -', p.* FROM TABLE(anchors."pST_Stage"('2021-01-01'::timestamp_ntz(9))) p
        UNION ALL
        SELECT '2021-07-01', '101 Old Hall 20, 102 Studio 30, 103 - -', p.* FROM TABLE(anchors."pST_Stage"('2021-07-01'::timestamp_ntz(9))) p
        UNION ALL
        SELECT '2022-01-01', '101 New Hall 20, 102 Studio 30, 103 - -', p.* FROM TABLE(anchors."pST_Stage"('2022-01-01'::timestamp_ntz(9))) p
    )
    WHERE "ST_ID" BETWEEN 101 AND 103
    GROUP BY at, expected
);
GO

-- u03 the now perspective leaves out a change that lies ahead, which the latest view shows
INSERT INTO anchors."ST_Stage" ("ST_ID", "Metadata_ST") VALUES (104, 0);
INSERT INTO attributes."ST_NAM_Stage_Name" ("ST_NAM_ST_ID", "ST_NAM_Stage_Name", "ST_NAM_ChangedAt", "Metadata_ST_NAM") VALUES
    (104, 'Now', '2020-01-01', 0), (104, 'Ahead', '2999-01-01', 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'u03 the now perspective leaves out a change ahead, the latest view shows it', shown = 'now Now, latest Ahead', shown
FROM (
    SELECT 'now ' || (SELECT "ST_NAM_Stage_Name" FROM anchors."nST_Stage" WHERE "ST_ID" = 104)
        || ', latest ' || (SELECT "ST_NAM_Stage_Name" FROM anchors."lST_Stage" WHERE "ST_ID" = 104) AS shown
);
GO

-- u04 the difference perspective of an anchor shows each change in the interval with the values in effect then, and
--     the selection limits it to the attributes named (this used to fail: it called the point-in-time perspective for
--     every change, and Snowflake cannot call a function with an outer join on its argument for each row of another
--     table)
INSERT INTO public.test_result (test, passed, detail)
SELECT 'u04 the difference perspective shows each change in the interval', shown = '101 2020-01-01 AVG Old Hall 10, 101 2020-01-01 NAM Old Hall 10, '
    || '101 2021-06-01 AVG Old Hall 20, 102 2021-01-01 AVG Studio 30, 102 2021-01-01 NAM Studio 30, 104 2020-01-01 NAM Now -', shown
FROM (
    SELECT coalesce(listagg("ST_ID" || ' ' || to_char(inspectedTimepoint, 'YYYY-MM-DD') || ' ' || mnemonic || ' ' || coalesce("ST_NAM_Stage_Name", '-')
        || ' ' || coalesce("ST_AVG_UTL_Utilization"::varchar, '-'), ', ') WITHIN GROUP (ORDER BY "ST_ID", inspectedTimepoint, mnemonic), '') AS shown
    FROM TABLE(anchors."dST_Stage"('2020-01-01'::timestamp_ntz(9), '2021-12-31'::timestamp_ntz(9), null::string))
    WHERE "ST_ID" BETWEEN 101 AND 104
);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'u04 the selection limits the difference perspective to the attributes named', shown = '101 2020-01-01 AVG, 101 2021-06-01 AVG, 102 2021-01-01 AVG', shown
FROM (
    SELECT coalesce(listagg("ST_ID" || ' ' || to_char(inspectedTimepoint, 'YYYY-MM-DD') || ' ' || mnemonic, ', ')
        WITHIN GROUP (ORDER BY "ST_ID", inspectedTimepoint, mnemonic), '') AS shown
    FROM TABLE(anchors."dST_Stage"('2020-01-01'::timestamp_ntz(9), '2021-12-31'::timestamp_ntz(9), 'AVG'))
    WHERE "ST_ID" BETWEEN 101 AND 104
);
GO

-- u05 the perspectives of a nexus: its roles, the knot of a knot role, and its historized, knotted and static attributes
INSERT INTO anchors."ST_Stage" ("ST_ID", "Metadata_ST") VALUES (105, 0), (106, 0);
INSERT INTO anchors."PR_Program" ("PR_ID", "Metadata_PR") VALUES (105, 0);
INSERT INTO nexuses."EV_Event" ("EV_ID", "ST_ID_wasHeldAt", "PR_ID_wasPlayed", "ETY_ID_of", "Metadata_EV") VALUES (105, 105, 105, 1, 0), (106, 106, 105, 2, 0);
INSERT INTO attributes."EV_STA_Event_Status" ("EV_STA_EV_ID", "EV_STA_Event_Status", "EV_STA_ChangedAt", "Metadata_EV_STA") VALUES
    (105, 'planned', '2020-01-01', 0), (105, 'sold out', '2020-06-01', 0), (106, 'planned', '2020-03-01', 0);
INSERT INTO attributes."EV_LVL_Event_Level" ("EV_LVL_EV_ID", "EV_LVL_PLV_ID", "EV_LVL_ChangedAt", "Metadata_EV_LVL") VALUES
    (105, 1, '2020-01-01', 0), (105, 2, '2020-02-01', 0);
INSERT INTO attributes."EV_UTL_Event_Utilization" ("EV_UTL_EV_ID", "EV_UTL_UTL_ID", "Metadata_EV_UTL") VALUES (105, 3, 0);
INSERT INTO attributes."EV_AUD_Event_Audience" ("EV_AUD_EV_ID", "EV_AUD_Event_Audience", "Metadata_EV_AUD") VALUES (105, 500, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'u05 the latest view of a nexus', shown = '105 105 105 premiere sold out senior 30 500, 106 106 105 regular planned - - -', shown
FROM (
    SELECT coalesce(listagg("EV_ID" || ' ' || "ST_ID_wasHeldAt" || ' ' || "PR_ID_wasPlayed" || ' ' || coalesce("of_ETY_EventType", '-') || ' '
        || coalesce("EV_STA_Event_Status", '-') || ' ' || coalesce("EV_LVL_PLV_ProfessionalLevel", '-') || ' '
        || coalesce("EV_UTL_UTL_Utilization"::varchar, '-') || ' ' || coalesce("EV_AUD_Event_Audience"::varchar, '-'), ', ')
        WITHIN GROUP (ORDER BY "EV_ID"), '') AS shown
    FROM nexuses."lEV_Event"
    WHERE "EV_ID" IN (105, 106)
);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'u05 the point-in-time perspective of a nexus', shown = '105 planned junior, 106 - -', shown
FROM (
    SELECT coalesce(listagg("EV_ID" || ' ' || coalesce("EV_STA_Event_Status", '-') || ' ' || coalesce("EV_LVL_PLV_ProfessionalLevel", '-'), ', ')
        WITHIN GROUP (ORDER BY "EV_ID"), '') AS shown
    FROM TABLE(nexuses."pEV_Event"('2020-01-15'::timestamp_ntz(9)))
    WHERE "EV_ID" IN (105, 106)
);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'u05 the difference perspective of a nexus', shown = '105 2020-01-01 LVL planned junior, 105 2020-01-01 STA planned junior, '
    || '105 2020-02-01 LVL planned senior, 105 2020-06-01 STA sold out senior, 106 2020-03-01 STA planned -', shown
FROM (
    SELECT coalesce(listagg("EV_ID" || ' ' || to_char(inspectedTimepoint, 'YYYY-MM-DD') || ' ' || mnemonic || ' ' || coalesce("EV_STA_Event_Status", '-')
        || ' ' || coalesce("EV_LVL_PLV_ProfessionalLevel", '-'), ', ') WITHIN GROUP (ORDER BY "EV_ID", inspectedTimepoint, mnemonic), '') AS shown
    FROM TABLE(nexuses."dEV_Event"('2020-01-01'::timestamp_ntz(9), '2020-12-31'::timestamp_ntz(9), null::string))
    WHERE "EV_ID" IN (105, 106)
);
GO

-- u06 a historized tie with identifiers: the latest value for each combination of identifiers
INSERT INTO anchors."AC_Actor" ("AC_ID", "Metadata_AC") VALUES (101, 0), (102, 0);
INSERT INTO anchors."PR_Program" ("PR_ID", "Metadata_PR") VALUES (106, 0);
INSERT INTO ties."AC_part_PR_in_RAT_got" ("AC_ID_part", "PR_ID_in", "RAT_ID_got", "AC_part_PR_in_RAT_got_ChangedAt", "Metadata_AC_part_PR_in_RAT_got") VALUES
    (101, 106, 1, '2020-01-01', 0), (101, 106, 2, '2021-01-01', 0), (102, 106, 1, '2020-06-01', 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'u06 a tie with identifiers, ' || perspective, shown = expected, shown
FROM (
    SELECT 'latest' AS perspective, '101 106 bad, 102 106 good' AS expected, coalesce(listagg("AC_ID_part" || ' ' || "PR_ID_in" || ' ' || "got_RAT_Rating", ', ')
        WITHIN GROUP (ORDER BY "AC_ID_part"), '') AS shown
    FROM ties."lAC_part_PR_in_RAT_got" WHERE "PR_ID_in" = 106
    UNION ALL
    SELECT 'at 2020-07-01', '101 106 good, 102 106 good', coalesce(listagg("AC_ID_part" || ' ' || "PR_ID_in" || ' ' || "got_RAT_Rating", ', ')
        WITHIN GROUP (ORDER BY "AC_ID_part"), '')
    FROM TABLE(ties."pAC_part_PR_in_RAT_got"('2020-07-01'::timestamp_ntz(9))) WHERE "PR_ID_in" = 106
    UNION ALL
    SELECT 'at 2020-03-01', '101 106 good', coalesce(listagg("AC_ID_part" || ' ' || "PR_ID_in" || ' ' || "got_RAT_Rating", ', ')
        WITHIN GROUP (ORDER BY "AC_ID_part"), '')
    FROM TABLE(ties."pAC_part_PR_in_RAT_got"('2020-03-01'::timestamp_ntz(9))) WHERE "PR_ID_in" = 106
    UNION ALL
    SELECT 'difference in 2020', '101 106 good 2020-01-01, 102 106 good 2020-06-01', coalesce(listagg("AC_ID_part" || ' ' || "PR_ID_in" || ' ' || "got_RAT_Rating"
        || ' ' || to_char("AC_part_PR_in_RAT_got_ChangedAt", 'YYYY-MM-DD'), ', ') WITHIN GROUP (ORDER BY "AC_ID_part"), '')
    FROM TABLE(ties."dAC_part_PR_in_RAT_got"('2020-01-01'::timestamp_ntz(9), '2020-12-31'::timestamp_ntz(9))) WHERE "PR_ID_in" = 106
);
GO

-- u07 a historized tie without identifiers is one to one: a later value for any of its anchors replaces an earlier one
--     (this used to show the rows replaced too: the perspectives compared with the latest changing time of the rows that
--     share either anchor, in a subquery that refers to the outer row with OR, and Snowflake kept rows it should not)
INSERT INTO anchors."AC_Actor" ("AC_ID", "Metadata_AC") VALUES (103, 0), (104, 0), (105, 0), (106, 0);
INSERT INTO ties."AC_partner_AC_with_ONG_currently" ("AC_ID_partner", "AC_ID_with", "ONG_ID_currently", "AC_partner_AC_with_ONG_currently_ChangedAt",
    "Metadata_AC_partner_AC_with_ONG_currently") VALUES
    (103, 104, 1, '2020-01-01', 0), (103, 105, 1, '2021-01-01', 0), (106, 104, 2, '2022-01-01', 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'u07 a tie without identifiers, ' || perspective, shown = expected, shown
FROM (
    SELECT 'latest' AS perspective, '103 105 yes, 106 104 no' AS expected, coalesce(listagg("AC_ID_partner" || ' ' || "AC_ID_with" || ' ' || "currently_ONG_Ongoing", ', ')
        WITHIN GROUP (ORDER BY "AC_ID_partner"), '') AS shown
    FROM ties."lAC_partner_AC_with_ONG_currently" WHERE "AC_ID_partner" BETWEEN 103 AND 106
    UNION ALL
    SELECT 'at 2020-06-01', '103 104 yes', coalesce(listagg("AC_ID_partner" || ' ' || "AC_ID_with" || ' ' || "currently_ONG_Ongoing", ', ')
        WITHIN GROUP (ORDER BY "AC_ID_partner"), '')
    FROM TABLE(ties."pAC_partner_AC_with_ONG_currently"('2020-06-01'::timestamp_ntz(9))) WHERE "AC_ID_partner" BETWEEN 103 AND 106
    UNION ALL
    SELECT 'at 2021-06-01', '103 105 yes', coalesce(listagg("AC_ID_partner" || ' ' || "AC_ID_with" || ' ' || "currently_ONG_Ongoing", ', ')
        WITHIN GROUP (ORDER BY "AC_ID_partner"), '')
    FROM TABLE(ties."pAC_partner_AC_with_ONG_currently"('2021-06-01'::timestamp_ntz(9))) WHERE "AC_ID_partner" BETWEEN 103 AND 106
);
GO

-- u08 a historized tie without identifiers that has a nexus role is one to one over all three of its roles
INSERT INTO anchors."ST_Stage" ("ST_ID", "Metadata_ST") VALUES (107, 0), (108, 0);
INSERT INTO anchors."PR_Program" ("PR_ID", "Metadata_PR") VALUES (107, 0);
INSERT INTO nexuses."EV_Event" ("EV_ID", "ST_ID_wasHeldAt", "PR_ID_wasPlayed", "ETY_ID_of", "Metadata_EV") VALUES (107, 107, 107, 1, 0), (108, 108, 107, 1, 0);
INSERT INTO ties."PR_content_ST_location_EV_of" ("PR_ID_content", "ST_ID_location", "EV_ID_of", "PR_content_ST_location_EV_of_ChangedAt",
    "Metadata_PR_content_ST_location_EV_of") VALUES
    (107, 107, 107, '2020-01-01', 0), (107, 108, 108, '2020-03-01', 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'u08 a tie with a nexus role and no identifiers, ' || perspective, shown = expected, shown
FROM (
    SELECT 'latest' AS perspective, '107 108 108' AS expected, coalesce(listagg("PR_ID_content" || ' ' || "ST_ID_location" || ' ' || "EV_ID_of", ', ')
        WITHIN GROUP (ORDER BY "ST_ID_location"), '') AS shown
    FROM ties."lPR_content_ST_location_EV_of" WHERE "PR_ID_content" = 107
    UNION ALL
    SELECT 'at 2020-02-01', '107 107 107', coalesce(listagg("PR_ID_content" || ' ' || "ST_ID_location" || ' ' || "EV_ID_of", ', ')
        WITHIN GROUP (ORDER BY "ST_ID_location"), '')
    FROM TABLE(ties."pPR_content_ST_location_EV_of"('2020-02-01'::timestamp_ntz(9))) WHERE "PR_ID_content" = 107
);
GO

-- u09 a static tie shows every row
INSERT INTO ties."EV_in_AC_wasCast" ("EV_ID_in", "AC_ID_wasCast", "Metadata_EV_in_AC_wasCast") VALUES (107, 101, 0), (107, 102, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'u09 a static tie shows every row', shown = '107 101, 107 102', shown
FROM (
    SELECT coalesce(listagg("EV_ID_in" || ' ' || "AC_ID_wasCast", ', ') WITHIN GROUP (ORDER BY "AC_ID_wasCast"), '') AS shown
    FROM ties."lEV_in_AC_wasCast" WHERE "EV_ID_in" = 107
);
GO
