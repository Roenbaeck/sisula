-- Perspective tests, concurrent-reliance-temporal: what the time-traveling, latest, point-in-time and difference
-- perspectives show, for more than one positor.
--
-- Runs against the output for models/distinct-crt.xml (golden/distinct-crt/_full.sql) in an empty database;
-- tools/snowflake-tests.ps1 does both, and makes public.test_result. Snowflake has no triggers, so the posits and their
-- assertions go straight into the posit and annex tables, with identities from 200 up so as not to meet the ones a
-- sequence hands out; the annex works out the assertion from the reliability. Each check adds a row to
-- public.test_result: what a perspective shows, written out as a string, and whether it is what was expected. The
-- groups are separated by GO and sent one at a time; a group that ends with an error counts as a failure. The rules
-- are in Anchor's docs/ANCHOR.md, "What the crt views show".

-- setup: a second positor (positor 0 is there from the start), and the knot values that the groups use
INSERT INTO dw."_Positor" ("Positor") VALUES (1);
INSERT INTO knots."ONG_Ongoing" ("ONG_ID", "ONG_Ongoing", "Metadata_ONG") VALUES (1, 'yes', 0);
INSERT INTO knots."RAT_Rating" ("RAT_ID", "RAT_Rating", "Metadata_RAT") VALUES (1, 'good', 0), (2, 'bad', 0);
INSERT INTO knots."ETY_EventType" ("ETY_ID", "ETY_EventType", "Metadata_ETY") VALUES (1, 'premiere', 0);
GO

-- c01 each positor has a view of its own (this used to fail as soon as two positors had stated something: the latest
--     view calls the time-traveling perspective for each positor, and Snowflake could not do that with the positor
--     used before a window, or with a knot joined after an outer join on the positor)
INSERT INTO anchors."ST_Stage" ("ST_ID", "Metadata_ST") VALUES (501, 0);
INSERT INTO attributes."ST_NAM_Stage_Name_Posit" ("ST_NAM_ID", "ST_NAM_ST_ID", "ST_NAM_Stage_Name", "ST_NAM_ChangedAt") VALUES
    (206, 501, 'Hall', '2020-01-01'), (207, 501, 'Salle', '2020-01-01');
INSERT INTO attributes."ST_NAM_Stage_Name_Annex" ("ST_NAM_ID", "ST_NAM_PositedAt", "ST_NAM_Positor", "ST_NAM_Reliability", "Metadata_ST_NAM") VALUES
    (206, '2020-01-01', 0, 1, 0), (207, '2020-01-02', 1, 0.75, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c01 each positor has a view of its own', shown = '0 501 Hall 1.00, 1 501 Salle 0.75', shown
FROM (
    SELECT coalesce(listagg("Positor" || ' ' || "ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-') || ' ' || coalesce("ST_NAM_Reliability"::varchar, '-'), ', ')
        WITHIN GROUP (ORDER BY "Positor"), '') AS shown
    FROM anchors."lST_Stage" WHERE "ST_ID" = 501
);
GO

-- c02 an assertion supersedes those at earlier changing times whatever its sign: Green from 2001, first asserted and
--     then denied, leaves nothing to show from 2001 on, and Red has to be asserted from 2001 to be shown again
INSERT INTO anchors."ST_Stage" ("ST_ID", "Metadata_ST") VALUES (502, 0);
INSERT INTO attributes."ST_NAM_Stage_Name_Posit" ("ST_NAM_ID", "ST_NAM_ST_ID", "ST_NAM_Stage_Name", "ST_NAM_ChangedAt") VALUES
    (201, 502, 'Red', '2000-01-01'), (202, 502, 'Green', '2001-01-01');
INSERT INTO attributes."ST_NAM_Stage_Name_Annex" ("ST_NAM_ID", "ST_NAM_PositedAt", "ST_NAM_Positor", "ST_NAM_Reliability", "Metadata_ST_NAM") VALUES
    (201, '2012-12-11', 0, 1, 0), (202, '2012-12-12', 0, 1, 0), (202, '2012-12-13', 0, -1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c02 ' || perspective, shown = expected, shown
FROM (
    SELECT 'the latest view shows nothing after the denial' AS perspective, '502 -' AS expected,
        coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-'), ', '), '') AS shown
    FROM anchors."lST_Stage" WHERE "ST_ID" = 502 AND "Positor" = 0
    UNION ALL
    SELECT 'the point-in-time perspective shows Red before 2001', '502 Red', coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-'), ', '), '')
    FROM TABLE(anchors."pST_Stage"('2000-06-01'::timestamp_ntz(9))) WHERE "ST_ID" = 502 AND "Positor" = 0
    UNION ALL
    SELECT 'the time-traveling perspective shows the denial when asked for negative assertions', '502 Green -1.00 -',
        coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-') || ' ' || coalesce("ST_NAM_Reliability"::varchar, '-') || ' '
        || coalesce("ST_NAM_Assertion", '-'), ', '), '')
    FROM TABLE(anchors."tST_Stage"(0, '9999-12-31'::timestamp_ntz(9), '9999-12-31'::datetime, '-')) WHERE "ST_ID" = 502
    UNION ALL
    SELECT 'the time-traveling perspective shows Green as known before the denial', '502 Green',
        coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-'), ', '), '')
    FROM TABLE(anchors."tST_Stage"(0, '9999-12-31'::timestamp_ntz(9), '2012-12-12 12:00'::datetime, '+')) WHERE "ST_ID" = 502
);
INSERT INTO attributes."ST_NAM_Stage_Name_Posit" ("ST_NAM_ID", "ST_NAM_ST_ID", "ST_NAM_Stage_Name", "ST_NAM_ChangedAt") VALUES (203, 502, 'Red', '2001-01-01');
INSERT INTO attributes."ST_NAM_Stage_Name_Annex" ("ST_NAM_ID", "ST_NAM_PositedAt", "ST_NAM_Positor", "ST_NAM_Reliability", "Metadata_ST_NAM") VALUES
    (203, '2012-12-14', 0, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c02 the latest view shows Red when it is asserted from 2001', shown = '502 Red', shown
FROM (
    SELECT coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-'), ', '), '') AS shown
    FROM anchors."lST_Stage" WHERE "ST_ID" = 502 AND "Positor" = 0
);
GO

-- c03 a retraction supersedes nothing: with Green from 2001 retracted, Red from 2000 is shown
INSERT INTO anchors."ST_Stage" ("ST_ID", "Metadata_ST") VALUES (503, 0);
INSERT INTO attributes."ST_NAM_Stage_Name_Posit" ("ST_NAM_ID", "ST_NAM_ST_ID", "ST_NAM_Stage_Name", "ST_NAM_ChangedAt") VALUES
    (204, 503, 'Red', '2000-01-01'), (205, 503, 'Green', '2001-01-01');
INSERT INTO attributes."ST_NAM_Stage_Name_Annex" ("ST_NAM_ID", "ST_NAM_PositedAt", "ST_NAM_Positor", "ST_NAM_Reliability", "Metadata_ST_NAM") VALUES
    (204, '2012-12-11', 0, 1, 0), (205, '2012-12-12', 0, 1, 0), (205, '2012-12-13', 0, 0, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c03 a retraction supersedes nothing', shown = '503 Red', shown
FROM (
    SELECT coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-'), ', '), '') AS shown
    FROM anchors."lST_Stage" WHERE "ST_ID" = 503 AND "Positor" = 0
);
GO

-- c04 the difference perspective shows each changing time in the interval for each positor, with what is known now
--     about it (this used to fail: it called the time-traveling perspective for every change, and Snowflake cannot
--     call a function with an outer join on its argument for each row of another table)
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c04 the difference perspective of an anchor', shown = '0 501 2020-01-01 Hall, 0 502 2000-01-01 Red, 0 502 2001-01-01 Red, '
    || '0 503 2000-01-01 Red, 0 503 2001-01-01 Red, 1 501 2020-01-01 Salle', shown
FROM (
    SELECT coalesce(listagg(DISTINCT "Positor" || ' ' || "ST_ID" || ' ' || to_char(inspectedTimepoint, 'YYYY-MM-DD') || ' ' || coalesce("ST_NAM_Stage_Name", '-'), ', ')
        WITHIN GROUP (ORDER BY "Positor" || ' ' || "ST_ID" || ' ' || to_char(inspectedTimepoint, 'YYYY-MM-DD') || ' ' || coalesce("ST_NAM_Stage_Name", '-')), '') AS shown
    FROM TABLE(anchors."dST_Stage"('1999-01-01'::timestamp_ntz(9), '2021-12-31'::timestamp_ntz(9), null::string)) WHERE "ST_ID" BETWEEN 501 AND 503
);
GO

-- c05 a historized tie without identifiers is one to one, in the view of each positor
INSERT INTO anchors."AC_Actor" ("AC_ID", "Metadata_AC") VALUES (601, 0), (602, 0), (603, 0);
INSERT INTO ties."AC_partner_AC_with_ONG_currently_Posit" ("AC_partner_AC_with_ONG_currently_ID", "AC_ID_partner", "AC_ID_with", "ONG_ID_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt") VALUES (201, 601, 602, 1, '2020-01-01'), (202, 601, 603, 1, '2021-01-01');
INSERT INTO ties."AC_partner_AC_with_ONG_currently_Annex" ("AC_partner_AC_with_ONG_currently_ID", "AC_partner_AC_with_ONG_currently_PositedAt",
    "AC_partner_AC_with_ONG_currently_Positor", "AC_partner_AC_with_ONG_currently_Reliability", "Metadata_AC_partner_AC_with_ONG_currently") VALUES
    (201, '2020-01-01', 0, 1, 0), (202, '2021-01-01', 0, 1, 0), (201, '2020-01-02', 1, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c05 a tie without identifiers, ' || perspective, shown = expected, shown
FROM (
    SELECT 'latest' AS perspective, '0 601 603, 1 601 602' AS expected,
        coalesce(listagg("Positor" || ' ' || "AC_ID_partner" || ' ' || "AC_ID_with", ', ') WITHIN GROUP (ORDER BY "Positor"), '') AS shown
    FROM ties."lAC_partner_AC_with_ONG_currently" WHERE "AC_ID_partner" = 601
    UNION ALL
    SELECT 'at 2020-06-01', '0 601 602, 1 601 602',
        coalesce(listagg("Positor" || ' ' || "AC_ID_partner" || ' ' || "AC_ID_with", ', ') WITHIN GROUP (ORDER BY "Positor"), '')
    FROM TABLE(ties."pAC_partner_AC_with_ONG_currently"('2020-06-01'::timestamp_ntz(9))) WHERE "AC_ID_partner" = 601
    UNION ALL
    SELECT 'difference', '0 2020-01-01 601 602, 0 2021-01-01 601 603, 1 2020-01-01 601 602',
        coalesce(listagg("Positor" || ' ' || to_char(inspectedTimepoint, 'YYYY-MM-DD') || ' ' || "AC_ID_partner" || ' ' || "AC_ID_with", ', ')
        WITHIN GROUP (ORDER BY "Positor", inspectedTimepoint), '')
    FROM TABLE(ties."dAC_partner_AC_with_ONG_currently"('2020-01-01'::timestamp_ntz(9), '2021-12-31'::timestamp_ntz(9))) WHERE "AC_ID_partner" = 601
);
GO

-- c06 a historized tie with identifiers: a denial supersedes the earlier posit, in every perspective
INSERT INTO anchors."PR_Program" ("PR_ID", "Metadata_PR") VALUES (607, 0);
INSERT INTO ties."AC_part_PR_in_RAT_got_Posit" ("AC_part_PR_in_RAT_got_ID", "AC_ID_part", "PR_ID_in", "RAT_ID_got", "AC_part_PR_in_RAT_got_ChangedAt") VALUES
    (203, 601, 607, 1, '2020-01-01'), (204, 601, 607, 2, '2021-01-01');
INSERT INTO ties."AC_part_PR_in_RAT_got_Annex" ("AC_part_PR_in_RAT_got_ID", "AC_part_PR_in_RAT_got_PositedAt", "AC_part_PR_in_RAT_got_Positor",
    "AC_part_PR_in_RAT_got_Reliability", "Metadata_AC_part_PR_in_RAT_got") VALUES
    (203, '2020-01-01', 0, 1, 0), (204, '2021-01-01', 0, 1, 0), (204, '2021-02-01', 0, -1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c06 a tie with identifiers, ' || perspective, shown = expected, shown
FROM (
    SELECT 'latest' AS perspective, '' AS expected, coalesce(listagg("AC_ID_part" || ' ' || "PR_ID_in" || ' ' || "got_RAT_Rating", ', '), '') AS shown
    FROM ties."lAC_part_PR_in_RAT_got" WHERE "PR_ID_in" = 607 AND "Positor" = 0
    UNION ALL
    SELECT 'at 2020-06-01', '601 607 good', coalesce(listagg("AC_ID_part" || ' ' || "PR_ID_in" || ' ' || "got_RAT_Rating", ', '), '')
    FROM TABLE(ties."pAC_part_PR_in_RAT_got"('2020-06-01'::timestamp_ntz(9))) WHERE "PR_ID_in" = 607 AND "Positor" = 0
    UNION ALL
    SELECT 'difference', '2020-01-01 601 607 good',
        coalesce(listagg(to_char(inspectedTimepoint, 'YYYY-MM-DD') || ' ' || "AC_ID_part" || ' ' || "PR_ID_in" || ' ' || "got_RAT_Rating", ', ')
        WITHIN GROUP (ORDER BY inspectedTimepoint), '')
    FROM TABLE(ties."dAC_part_PR_in_RAT_got"('2020-01-01'::timestamp_ntz(9), '2021-12-31'::timestamp_ntz(9))) WHERE "PR_ID_in" = 607 AND "Positor" = 0
);
GO

-- c07 the perspectives of a nexus with a historized attribute
INSERT INTO anchors."ST_Stage" ("ST_ID", "Metadata_ST") VALUES (507, 0);
INSERT INTO anchors."PR_Program" ("PR_ID", "Metadata_PR") VALUES (507, 0);
INSERT INTO nexuses."EV_Event" ("EV_ID", "ST_ID_wasHeldAt", "PR_ID_wasPlayed", "ETY_ID_of", "Metadata_EV") VALUES (507, 507, 507, 1, 0);
INSERT INTO attributes."EV_STA_Event_Status_Posit" ("EV_STA_ID", "EV_STA_EV_ID", "EV_STA_Event_Status", "EV_STA_ChangedAt") VALUES
    (207, 507, 'planned', '2020-01-01'), (208, 507, 'sold out', '2020-06-01');
INSERT INTO attributes."EV_STA_Event_Status_Annex" ("EV_STA_ID", "EV_STA_PositedAt", "EV_STA_Positor", "EV_STA_Reliability", "Metadata_EV_STA") VALUES
    (207, '2020-01-01', 0, 1, 0), (208, '2020-06-01', 0, 1, 0), (207, '2020-01-02', 1, 0.5, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c07 a nexus, ' || perspective, shown = expected, shown
FROM (
    SELECT 'latest' AS perspective, '0 507 premiere sold out, 1 507 premiere planned' AS expected,
        coalesce(listagg("Positor" || ' ' || "EV_ID" || ' ' || coalesce("of_ETY_EventType", '-') || ' ' || coalesce("EV_STA_Event_Status", '-'), ', ')
        WITHIN GROUP (ORDER BY "Positor"), '') AS shown
    FROM nexuses."lEV_Event" WHERE "EV_ID" = 507
    UNION ALL
    SELECT 'difference', '0 2020-01-01 premiere planned, 0 2020-06-01 premiere sold out, 1 2020-01-01 premiere planned',
        coalesce(listagg("Positor" || ' ' || to_char(inspectedTimepoint, 'YYYY-MM-DD') || ' ' || coalesce("of_ETY_EventType", '-') || ' '
        || coalesce("EV_STA_Event_Status", '-'), ', ') WITHIN GROUP (ORDER BY "Positor", inspectedTimepoint), '')
    FROM TABLE(nexuses."dEV_Event"('2020-01-01'::timestamp_ntz(9), '2020-12-31'::timestamp_ntz(9), null::string)) WHERE "EV_ID" = 507
);
GO
