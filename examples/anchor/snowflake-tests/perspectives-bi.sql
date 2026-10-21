-- Perspective tests, bitemporal: what the time-traveling, latest, point-in-time and difference perspectives show.
--
-- Runs against the output for models/distinct-bi.xml (golden/distinct-bi/_full.sql) in an empty database;
-- tools/snowflake-tests.ps1 does both, and makes public.test_result. Snowflake has no triggers, so the posits and their
-- assertions go straight into the posit and annex tables, with identities from 100 up so as not to meet the ones a
-- sequence hands out. A reliability of 1 asserts a posit and 0 retracts it. Each check adds a row to
-- public.test_result: what a perspective shows, written out as a string, and whether it is what was expected. The
-- groups are separated by GO and sent one at a time; a group that ends with an error counts as a failure.

-- setup: the knot values that the groups use
INSERT INTO knots."UTL_Utilization" ("UTL_ID", "UTL_Utilization", "Metadata_UTL") VALUES (1, 10, 0), (2, 20, 0), (3, 30, 0);
INSERT INTO knots."ONG_Ongoing" ("ONG_ID", "ONG_Ongoing", "Metadata_ONG") VALUES (1, 'yes', 0);
INSERT INTO knots."RAT_Rating" ("RAT_ID", "RAT_Rating", "Metadata_RAT") VALUES (1, 'good', 0), (2, 'bad', 0);
INSERT INTO knots."ETY_EventType" ("ETY_ID", "ETY_EventType", "Metadata_ETY") VALUES (1, 'premiere', 0);
GO

-- b01 the latest view shows the latest asserted posit at the latest changing time: a correction at the same changing
--     time replaces a value, a retraction brings back the one before, and a static attribute shows its latest posit
INSERT INTO anchors."ST_Stage" ("ST_ID", "Metadata_ST") VALUES (301, 0);
INSERT INTO attributes."ST_NAM_Stage_Name_Posit" ("ST_NAM_ID", "ST_NAM_ST_ID", "ST_NAM_Stage_Name", "ST_NAM_ChangedAt") VALUES
    (101, 301, 'Hall', '2020-01-01'), (102, 301, 'Hal', '2021-01-01'), (103, 301, 'Hall B', '2021-01-01');
INSERT INTO attributes."ST_NAM_Stage_Name_Annex" ("ST_NAM_ID", "ST_NAM_PositedAt", "ST_NAM_Reliability", "Metadata_ST_NAM") VALUES
    (101, '2020-01-01', 1, 0), (102, '2021-01-02', 1, 0), (103, '2021-02-01', 1, 0);
INSERT INTO attributes."ST_AVG_Stage_Average_Posit" ("ST_AVG_ID", "ST_AVG_ST_ID", "ST_AVG_UTL_ID", "ST_AVG_ChangedAt") VALUES
    (101, 301, 1, '2020-01-01'), (102, 301, 2, '2021-06-01');
INSERT INTO attributes."ST_AVG_Stage_Average_Annex" ("ST_AVG_ID", "ST_AVG_PositedAt", "ST_AVG_Reliability", "Metadata_ST_AVG") VALUES
    (101, '2020-01-01', 1, 0), (102, '2021-06-01', 1, 0), (102, '2021-07-01', 0, 0);
INSERT INTO attributes."ST_MIN_Stage_Minimum_Posit" ("ST_MIN_ID", "ST_MIN_ST_ID", "ST_MIN_UTL_ID") VALUES (101, 301, 1), (102, 301, 3);
INSERT INTO attributes."ST_MIN_Stage_Minimum_Annex" ("ST_MIN_ID", "ST_MIN_PositedAt", "ST_MIN_Reliability", "Metadata_ST_MIN") VALUES
    (101, '2020-01-01', 1, 0), (102, '2022-01-01', 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'b01 the latest view shows corrections, retractions and the latest static posit', shown = '301 Hall B 10 30', shown
FROM (
    SELECT coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-') || ' ' || coalesce("ST_AVG_UTL_Utilization"::varchar, '-')
        || ' ' || coalesce("ST_MIN_UTL_Utilization"::varchar, '-'), ', '), '') AS shown
    FROM anchors."lST_Stage" WHERE "ST_ID" = 301
);
GO

-- b02 the time-traveling perspective shows what was known at an earlier positing time
INSERT INTO public.test_result (test, passed, detail)
SELECT 'b02 the time-traveling perspective as known at ' || at, shown = expected, shown
FROM (
    SELECT '2021-01-15' AS at, '301 Hal 10 10' AS expected, coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-') || ' '
        || coalesce("ST_AVG_UTL_Utilization"::varchar, '-') || ' ' || coalesce("ST_MIN_UTL_Utilization"::varchar, '-'), ', '), '') AS shown
    FROM TABLE(anchors."tST_Stage"('9999-12-31'::timestamp_ntz(9), '2021-01-15'::datetime)) WHERE "ST_ID" = 301
    UNION ALL
    SELECT '2021-06-15', '301 Hall B 20 10', coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-') || ' '
        || coalesce("ST_AVG_UTL_Utilization"::varchar, '-') || ' ' || coalesce("ST_MIN_UTL_Utilization"::varchar, '-'), ', '), '')
    FROM TABLE(anchors."tST_Stage"('9999-12-31'::timestamp_ntz(9), '2021-06-15'::datetime)) WHERE "ST_ID" = 301
);
GO

-- b03 the point-in-time perspective shows what is known now about a changing time
INSERT INTO public.test_result (test, passed, detail)
SELECT 'b03 the point-in-time perspective', shown = '301 Hall 10 30', shown
FROM (
    SELECT coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-') || ' ' || coalesce("ST_AVG_UTL_Utilization"::varchar, '-')
        || ' ' || coalesce("ST_MIN_UTL_Utilization"::varchar, '-'), ', '), '') AS shown
    FROM TABLE(anchors."pST_Stage"('2020-06-01'::timestamp_ntz(9))) WHERE "ST_ID" = 301
);
GO

-- b04 the difference perspective shows each changing time in the interval with what is known now about it, a
--     retracted posit's changing time included (this used to fail: it called the time-traveling perspective for every
--     change, and Snowflake cannot call a function with an outer join on its argument for each row of another table)
INSERT INTO public.test_result (test, passed, detail)
SELECT 'b04 the difference perspective of an anchor', shown = '301 2020-01-01 Hall 10, 301 2021-01-01 Hall B 10, 301 2021-06-01 Hall B 10', shown
FROM (
    SELECT coalesce(listagg(DISTINCT "ST_ID" || ' ' || to_char(inspectedTimepoint, 'YYYY-MM-DD') || ' ' || coalesce("ST_NAM_Stage_Name", '-') || ' '
        || coalesce("ST_AVG_UTL_Utilization"::varchar, '-'), ', ') WITHIN GROUP (ORDER BY "ST_ID" || ' ' || to_char(inspectedTimepoint, 'YYYY-MM-DD')
        || ' ' || coalesce("ST_NAM_Stage_Name", '-') || ' ' || coalesce("ST_AVG_UTL_Utilization"::varchar, '-')), '') AS shown
    FROM TABLE(anchors."dST_Stage"('2020-01-01'::timestamp_ntz(9), '2021-12-31'::timestamp_ntz(9), null::string)) WHERE "ST_ID" = 301
);
GO

-- b05 the perspectives of a nexus with a historized attribute
INSERT INTO anchors."ST_Stage" ("ST_ID", "Metadata_ST") VALUES (305, 0);
INSERT INTO anchors."PR_Program" ("PR_ID", "Metadata_PR") VALUES (305, 0);
INSERT INTO nexuses."EV_Event" ("EV_ID", "ST_ID_wasHeldAt", "PR_ID_wasPlayed", "ETY_ID_of", "Metadata_EV") VALUES (305, 305, 305, 1, 0);
INSERT INTO attributes."EV_STA_Event_Status_Posit" ("EV_STA_ID", "EV_STA_EV_ID", "EV_STA_Event_Status", "EV_STA_ChangedAt") VALUES
    (105, 305, 'planned', '2020-01-01'), (106, 305, 'sold out', '2020-06-01');
INSERT INTO attributes."EV_STA_Event_Status_Annex" ("EV_STA_ID", "EV_STA_PositedAt", "EV_STA_Reliability", "Metadata_EV_STA") VALUES
    (105, '2020-01-01', 1, 0), (106, '2020-06-01', 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'b05 a nexus, ' || perspective, shown = expected, shown
FROM (
    SELECT 'latest' AS perspective, '305 premiere sold out' AS expected,
        coalesce(listagg("EV_ID" || ' ' || coalesce("of_ETY_EventType", '-') || ' ' || coalesce("EV_STA_Event_Status", '-'), ', '), '') AS shown
    FROM nexuses."lEV_Event" WHERE "EV_ID" = 305
    UNION ALL
    SELECT 'difference', '305 2020-01-01 premiere planned, 305 2020-06-01 premiere sold out',
        coalesce(listagg("EV_ID" || ' ' || to_char(inspectedTimepoint, 'YYYY-MM-DD') || ' ' || coalesce("of_ETY_EventType", '-') || ' '
        || coalesce("EV_STA_Event_Status", '-'), ', ') WITHIN GROUP (ORDER BY inspectedTimepoint), '')
    FROM TABLE(nexuses."dEV_Event"('2020-01-01'::timestamp_ntz(9), '2020-12-31'::timestamp_ntz(9), null::string)) WHERE "EV_ID" = 305
);
GO

-- b06 a historized tie without identifiers is one to one, and a retraction brings back the posit before it
INSERT INTO anchors."AC_Actor" ("AC_ID", "Metadata_AC") VALUES (301, 0), (302, 0), (303, 0);
INSERT INTO ties."AC_partner_AC_with_ONG_currently_Posit" ("AC_partner_AC_with_ONG_currently_ID", "AC_ID_partner", "AC_ID_with", "ONG_ID_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt") VALUES (101, 301, 302, 1, '2020-01-01'), (102, 301, 303, 1, '2021-01-01');
INSERT INTO ties."AC_partner_AC_with_ONG_currently_Annex" ("AC_partner_AC_with_ONG_currently_ID", "AC_partner_AC_with_ONG_currently_PositedAt",
    "AC_partner_AC_with_ONG_currently_Reliability", "Metadata_AC_partner_AC_with_ONG_currently") VALUES
    (101, '2020-01-01', 1, 0), (102, '2021-01-01', 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'b06 a tie without identifiers, ' || perspective, shown = expected, shown
FROM (
    SELECT 'latest' AS perspective, '301 303' AS expected, coalesce(listagg("AC_ID_partner" || ' ' || "AC_ID_with", ', '), '') AS shown
    FROM ties."lAC_partner_AC_with_ONG_currently" WHERE "AC_ID_partner" = 301
    UNION ALL
    SELECT 'at 2020-06-01', '301 302', coalesce(listagg("AC_ID_partner" || ' ' || "AC_ID_with", ', '), '')
    FROM TABLE(ties."pAC_partner_AC_with_ONG_currently"('2020-06-01'::timestamp_ntz(9))) WHERE "AC_ID_partner" = 301
    UNION ALL
    SELECT 'as known before the second posit', '301 302', coalesce(listagg("AC_ID_partner" || ' ' || "AC_ID_with", ', '), '')
    FROM TABLE(ties."tAC_partner_AC_with_ONG_currently"('9999-12-31'::timestamp_ntz(9), '2020-12-31'::datetime)) WHERE "AC_ID_partner" = 301
);
INSERT INTO ties."AC_partner_AC_with_ONG_currently_Annex" ("AC_partner_AC_with_ONG_currently_ID", "AC_partner_AC_with_ONG_currently_PositedAt",
    "AC_partner_AC_with_ONG_currently_Reliability", "Metadata_AC_partner_AC_with_ONG_currently") VALUES (102, '2021-02-01', 0, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'b06 a tie without identifiers, latest after a retraction', shown = '301 302', shown
FROM (
    SELECT coalesce(listagg("AC_ID_partner" || ' ' || "AC_ID_with", ', '), '') AS shown
    FROM ties."lAC_partner_AC_with_ONG_currently" WHERE "AC_ID_partner" = 301
);
GO

-- b07 a historized tie with identifiers, and its difference perspective
INSERT INTO anchors."PR_Program" ("PR_ID", "Metadata_PR") VALUES (307, 0);
INSERT INTO ties."AC_part_PR_in_RAT_got_Posit" ("AC_part_PR_in_RAT_got_ID", "AC_ID_part", "PR_ID_in", "RAT_ID_got", "AC_part_PR_in_RAT_got_ChangedAt") VALUES
    (107, 301, 307, 1, '2020-01-01'), (108, 301, 307, 2, '2021-01-01');
INSERT INTO ties."AC_part_PR_in_RAT_got_Annex" ("AC_part_PR_in_RAT_got_ID", "AC_part_PR_in_RAT_got_PositedAt", "AC_part_PR_in_RAT_got_Reliability",
    "Metadata_AC_part_PR_in_RAT_got") VALUES (107, '2020-01-01', 1, 0), (108, '2021-01-01', 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'b07 a tie with identifiers, ' || perspective, shown = expected, shown
FROM (
    SELECT 'latest' AS perspective, '301 307 bad' AS expected, coalesce(listagg("AC_ID_part" || ' ' || "PR_ID_in" || ' ' || "got_RAT_Rating", ', '), '') AS shown
    FROM ties."lAC_part_PR_in_RAT_got" WHERE "PR_ID_in" = 307
    UNION ALL
    SELECT 'at 2020-06-01', '301 307 good', coalesce(listagg("AC_ID_part" || ' ' || "PR_ID_in" || ' ' || "got_RAT_Rating", ', '), '')
    FROM TABLE(ties."pAC_part_PR_in_RAT_got"('2020-06-01'::timestamp_ntz(9))) WHERE "PR_ID_in" = 307
    UNION ALL
    SELECT 'difference in 2021', '301 307 bad', coalesce(listagg("AC_ID_part" || ' ' || "PR_ID_in" || ' ' || "got_RAT_Rating", ', '), '')
    FROM TABLE(ties."dAC_part_PR_in_RAT_got"('2021-01-01'::timestamp_ntz(9), '2021-12-31'::timestamp_ntz(9))) WHERE "PR_ID_in" = 307
);
GO
