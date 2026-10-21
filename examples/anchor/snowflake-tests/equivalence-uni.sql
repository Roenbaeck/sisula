-- Equivalence tests, uni-temporal: what the latest, point-in-time and difference perspectives of an equivalent show.
--
-- Runs against the output for models/distinct-equivalence.xml (golden/distinct-equivalence/_full.sql) in an empty
-- database; tools/snowflake-tests.ps1 does both, and makes public.test_result. Snowflake has no triggers, so the rows go
-- straight into the tables. Each check adds a row to public.test_result: what a perspective shows, written out as a
-- string, and whether it is what was expected. The groups are separated by GO and sent one at a time; a group that ends
-- with an error counts as a failure. Equivalent 0 holds the values in one language and equivalent 1 in another; an
-- attribute or a knot that is not equivalent has one value for both.

-- setup: the equivalents and the knot values that the groups use
INSERT INTO dw."_EQ" ("EQ") VALUES (0), (1);
INSERT INTO knots."UTL_Utilization" ("UTL_ID", "UTL_Utilization", "Metadata_UTL") VALUES (1, 10, 0), (2, 20, 0);
INSERT INTO knots."PLV_ProfessionalLevel_ID" ("PLV_ID", "Metadata_PLV") VALUES (1, 0), (2, 0);
INSERT INTO knots."PLV_ProfessionalLevel_EQ" ("PLV_ID", "PLV_EQ", "PLV_ProfessionalLevel", "Metadata_PLV") VALUES
    (1, 0, 'junior', 0), (2, 0, 'senior', 0), (1, 1, 'débutant', 0), (2, 1, 'confirmé', 0);
INSERT INTO knots."ETY_EventType_ID" ("ETY_ID", "Metadata_ETY") VALUES (1, 0);
INSERT INTO knots."ETY_EventType_EQ" ("ETY_ID", "ETY_EQ", "ETY_EventType", "Metadata_ETY") VALUES (1, 0, 'premiere', 0), (1, 1, 'première', 0);
INSERT INTO knots."ONG_Ongoing_ID" ("ONG_ID", "Metadata_ONG") VALUES (1, 0);
INSERT INTO knots."ONG_Ongoing_EQ" ("ONG_ID", "ONG_EQ", "ONG_Ongoing", "Metadata_ONG") VALUES (1, 0, 'yes', 0), (1, 1, 'oui', 0);
GO

-- q01 the latest perspective of an equivalent shows its own values of the equivalent attributes, and the values of the
--     others
INSERT INTO anchors."ST_Stage" ("ST_ID", "Metadata_ST") VALUES (201, 0);
INSERT INTO attributes."ST_NAM_Stage_Name" ("ST_NAM_ST_ID", "ST_NAM_EQ", "ST_NAM_Stage_Name", "ST_NAM_ChangedAt", "Metadata_ST_NAM") VALUES
    (201, 0, 'Hall', '2020-01-01', 0), (201, 0, 'New Hall', '2022-01-01', 0), (201, 1, 'Salle', '2020-01-01', 0);
INSERT INTO attributes."ST_AVG_Stage_Average" ("ST_AVG_ST_ID", "ST_AVG_UTL_ID", "ST_AVG_ChangedAt", "Metadata_ST_AVG") VALUES
    (201, 1, '2020-01-01', 0), (201, 2, '2021-01-01', 0);
INSERT INTO attributes."ST_LOC_Stage_Location" ("ST_LOC_ST_ID", "ST_LOC_EQ", "ST_LOC_Stage_Location", "Metadata_ST_LOC")
SELECT 201, 0, to_geography('POINT(18.07 59.33)'), 0;
INSERT INTO public.test_result (test, passed, detail)
SELECT 'q01 the latest perspective of equivalent ' || eq, shown = expected, shown
FROM (
    SELECT 0 AS eq, '201 New Hall 20 located' AS expected, coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-') || ' '
        || coalesce("ST_AVG_UTL_Utilization"::varchar, '-') || ' ' || iff("ST_LOC_Stage_Location" IS NULL, '-', 'located'), ', '), '') AS shown
    FROM TABLE(anchors."elST_Stage"(0)) WHERE "ST_ID" = 201
    UNION ALL
    SELECT 1, '201 Salle 20 -', coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-') || ' '
        || coalesce("ST_AVG_UTL_Utilization"::varchar, '-') || ' ' || iff("ST_LOC_Stage_Location" IS NULL, '-', 'located'), ', '), '')
    FROM TABLE(anchors."elST_Stage"(1)) WHERE "ST_ID" = 201
);
GO

-- q02 the point-in-time perspective of an equivalent
INSERT INTO public.test_result (test, passed, detail)
SELECT 'q02 the point-in-time perspective of equivalent ' || eq || ' at ' || at, shown = expected, shown
FROM (
    SELECT 1 AS eq, '2020-06-01' AS at, '201 Salle 10' AS expected, coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-') || ' '
        || coalesce("ST_AVG_UTL_Utilization"::varchar, '-'), ', '), '') AS shown
    FROM TABLE(anchors."epST_Stage"(1, '2020-06-01'::timestamp_ntz(9))) WHERE "ST_ID" = 201
    UNION ALL
    SELECT 0, '2021-06-01', '201 Hall 20', coalesce(listagg("ST_ID" || ' ' || coalesce("ST_NAM_Stage_Name", '-') || ' '
        || coalesce("ST_AVG_UTL_Utilization"::varchar, '-'), ', '), '')
    FROM TABLE(anchors."epST_Stage"(0, '2021-06-01'::timestamp_ntz(9))) WHERE "ST_ID" = 201
);
GO

-- q03 the difference perspective of an equivalent shows the changes of its own values and of the values of the others
--     (this used to fail: it called the point-in-time perspective for every change, and Snowflake cannot call a function
--     with an outer join on its argument for each row of another table)
INSERT INTO public.test_result (test, passed, detail)
SELECT 'q03 the difference perspective of equivalent ' || eq, shown = expected, shown
FROM (
    SELECT 0 AS eq, '201 2020-01-01 AVG Hall 10, 201 2020-01-01 NAM Hall 10, 201 2021-01-01 AVG Hall 20, 201 2022-01-01 NAM New Hall 20' AS expected,
        coalesce(listagg("ST_ID" || ' ' || to_char(inspectedTimepoint, 'YYYY-MM-DD') || ' ' || mnemonic || ' ' || coalesce("ST_NAM_Stage_Name", '-')
        || ' ' || coalesce("ST_AVG_UTL_Utilization"::varchar, '-'), ', ') WITHIN GROUP (ORDER BY inspectedTimepoint, mnemonic), '') AS shown
    FROM TABLE(anchors."edST_Stage"(0, '2020-01-01'::timestamp_ntz(9), '2022-12-31'::timestamp_ntz(9), null::string)) WHERE "ST_ID" = 201
    UNION ALL
    SELECT 1, '201 2020-01-01 AVG Salle 10, 201 2020-01-01 NAM Salle 10, 201 2021-01-01 AVG Salle 20',
        coalesce(listagg("ST_ID" || ' ' || to_char(inspectedTimepoint, 'YYYY-MM-DD') || ' ' || mnemonic || ' ' || coalesce("ST_NAM_Stage_Name", '-')
        || ' ' || coalesce("ST_AVG_UTL_Utilization"::varchar, '-'), ', ') WITHIN GROUP (ORDER BY inspectedTimepoint, mnemonic), '')
    FROM TABLE(anchors."edST_Stage"(1, '2020-01-01'::timestamp_ntz(9), '2022-12-31'::timestamp_ntz(9), null::string)) WHERE "ST_ID" = 201
);
GO

-- q04 the perspectives of a nexus with an equivalent knot role, an equivalent historized attribute and an attribute
--     knotted to an equivalent knot
INSERT INTO anchors."ST_Stage" ("ST_ID", "Metadata_ST") VALUES (202, 0);
INSERT INTO anchors."PR_Program" ("PR_ID", "Metadata_PR") VALUES (202, 0);
INSERT INTO nexuses."EV_Event" ("EV_ID", "ST_ID_wasHeldAt", "PR_ID_wasPlayed", "ETY_ID_of", "Metadata_EV") VALUES (202, 202, 202, 1, 0);
INSERT INTO attributes."EV_STA_Event_Status" ("EV_STA_EV_ID", "EV_STA_EQ", "EV_STA_Event_Status", "EV_STA_ChangedAt", "Metadata_EV_STA") VALUES
    (202, 0, 'planned', '2020-01-01', 0), (202, 0, 'sold out', '2020-06-01', 0), (202, 1, 'prévu', '2020-01-01', 0);
INSERT INTO attributes."EV_LVL_Event_Level" ("EV_LVL_EV_ID", "EV_LVL_PLV_ID", "EV_LVL_ChangedAt", "Metadata_EV_LVL") VALUES
    (202, 1, '2020-01-01', 0), (202, 2, '2020-02-01', 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'q04 a nexus, ' || perspective, shown = expected, shown
FROM (
    SELECT 'latest of equivalent 0' AS perspective, '202 premiere sold out senior' AS expected, coalesce(listagg("EV_ID" || ' ' || coalesce("of_ETY_EventType", '-')
        || ' ' || coalesce("EV_STA_Event_Status", '-') || ' ' || coalesce("EV_LVL_PLV_ProfessionalLevel", '-'), ', '), '') AS shown
    FROM TABLE(nexuses."elEV_Event"(0)) WHERE "EV_ID" = 202
    UNION ALL
    SELECT 'latest of equivalent 1', '202 première prévu confirmé', coalesce(listagg("EV_ID" || ' ' || coalesce("of_ETY_EventType", '-')
        || ' ' || coalesce("EV_STA_Event_Status", '-') || ' ' || coalesce("EV_LVL_PLV_ProfessionalLevel", '-'), ', '), '')
    FROM TABLE(nexuses."elEV_Event"(1)) WHERE "EV_ID" = 202
    UNION ALL
    SELECT 'point in time of equivalent 1', '202 première prévu débutant', coalesce(listagg("EV_ID" || ' ' || coalesce("of_ETY_EventType", '-')
        || ' ' || coalesce("EV_STA_Event_Status", '-') || ' ' || coalesce("EV_LVL_PLV_ProfessionalLevel", '-'), ', '), '')
    FROM TABLE(nexuses."epEV_Event"(1, '2020-01-15'::timestamp_ntz(9))) WHERE "EV_ID" = 202
    UNION ALL
    SELECT 'difference of equivalent 1', '202 2020-01-01 LVL prévu débutant, 202 2020-01-01 STA prévu débutant, 202 2020-02-01 LVL prévu confirmé',
        coalesce(listagg("EV_ID" || ' ' || to_char(inspectedTimepoint, 'YYYY-MM-DD') || ' ' || mnemonic || ' ' || coalesce("EV_STA_Event_Status", '-')
        || ' ' || coalesce("EV_LVL_PLV_ProfessionalLevel", '-'), ', ') WITHIN GROUP (ORDER BY inspectedTimepoint, mnemonic), '')
    FROM TABLE(nexuses."edEV_Event"(1, '2020-01-01'::timestamp_ntz(9), '2020-12-31'::timestamp_ntz(9), null::string)) WHERE "EV_ID" = 202
);
GO

-- q05 a tie with an equivalent knot role shows the knot value of the equivalent
INSERT INTO anchors."AC_Actor" ("AC_ID", "Metadata_AC") VALUES (201, 0), (202, 0);
INSERT INTO ties."AC_partner_AC_with_ONG_currently" ("AC_ID_partner", "AC_ID_with", "ONG_ID_currently", "AC_partner_AC_with_ONG_currently_ChangedAt",
    "Metadata_AC_partner_AC_with_ONG_currently") VALUES (201, 202, 1, '2020-01-01', 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'q05 a tie with an equivalent knot role, latest of equivalent ' || eq, shown = expected, shown
FROM (
    SELECT 0 AS eq, '201 202 yes' AS expected, coalesce(listagg("AC_ID_partner" || ' ' || "AC_ID_with" || ' ' || coalesce("currently_ONG_Ongoing", '-'), ', '), '') AS shown
    FROM TABLE(ties."elAC_partner_AC_with_ONG_currently"(0)) WHERE "AC_ID_partner" = 201
    UNION ALL
    SELECT 1, '201 202 oui', coalesce(listagg("AC_ID_partner" || ' ' || "AC_ID_with" || ' ' || coalesce("currently_ONG_Ongoing", '-'), ', '), '')
    FROM TABLE(ties."elAC_partner_AC_with_ONG_currently"(1)) WHERE "AC_ID_partner" = 201
);
GO
