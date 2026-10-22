-- Natural key tests, concurrent-reliance-temporal: what the key views, the point-in-time keys and their checks give.
--
-- Runs against the output for models/keys-crt.xml (golden/keys-crt/_full.sql) in an empty database;
-- tools/snowflake-tests.ps1 does both, and makes public.test_result. They are the tests of keys-uni.sql, with each
-- value a posit and its assertion by positor 0 in the annex (a reliability of 1), at positing times of their own, and a key per positor. Snowflake has no
-- triggers, so the rows go straight into the tables, with identities from 100 up so as not to meet the ones a sequence
-- hands out. Each check adds a row to public.test_result; the groups are separated by GO and sent one at a time, and a
-- group that ends with an error counts as a failure.

-- setup: the knot values that the groups use
INSERT INTO public."UTL_Utilization" ("UTL_ID", "UTL_Utilization", "Metadata_UTL") VALUES (1, 50, 0), (2, 80, 0);
INSERT INTO public."ETY_EventType" ("ETY_ID", "ETY_EventType", "Metadata_ETY") VALUES (1, 'premiere', 0), (2, 'regular', 0);
INSERT INTO public."RAT_Rating" ("RAT_ID", "RAT_Rating", "Metadata_RAT") VALUES (1, 'good', 0), (2, 'bad', 0);
GO

-- k01 the key of an anchor's own attribute: the value and its checksum, which a lookup matches on (hashing the value
--     as the type of the attribute)
INSERT INTO public."ST_Stage" ("ST_ID", "Metadata_ST") VALUES (101, 0);
INSERT INTO public."ST_NAM_Stage_Name_Posit" ("ST_NAM_ID", "ST_NAM_ST_ID", "ST_NAM_Stage_Name", "ST_NAM_ChangedAt") VALUES (101, 101, 'Globen', '2020-01-01');
INSERT INTO public."ST_NAM_Stage_Name_Annex" ("ST_NAM_ID", "ST_NAM_PositedAt", "ST_NAM_Positor", "ST_NAM_Reliability", "Metadata_ST_NAM") VALUES (101, '2020-01-01', 0, 1, 0);
INSERT INTO public."ST_LOC_Stage_Location_Posit" ("ST_LOC_ID", "ST_LOC_ST_ID", "ST_LOC_Stage_Location") SELECT 101, 101, to_geography('POINT(18.0831 59.2936)');
INSERT INTO public."ST_LOC_Stage_Location_Annex" ("ST_LOC_ID", "ST_LOC_PositedAt", "ST_LOC_Positor", "ST_LOC_Reliability", "Metadata_ST_LOC") VALUES (101, '2020-01-01', 0, 1, 0);
INSERT INTO public."ST_MIN_Stage_Minimum_Posit" ("ST_MIN_ID", "ST_MIN_ST_ID", "ST_MIN_UTL_ID") VALUES (101, 101, 1);
INSERT INTO public."ST_MIN_Stage_Minimum_Annex" ("ST_MIN_ID", "ST_MIN_PositedAt", "ST_MIN_Positor", "ST_MIN_Reliability", "Metadata_ST_MIN") VALUES (101, '2020-01-01', 0, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k01 the key view has the value and its checksum', n = 1, n || ' rows, expected 1'
FROM (
    SELECT count(*) AS n FROM public."key_ST_Stage_1st"
    WHERE "Positor" = 0 AND "ST_ID" = 101 AND "ST_LOC_Checksum" = (SELECT "ST_LOC_Checksum" FROM public."ST_LOC_Stage_Location_Posit" WHERE "ST_LOC_ST_ID" = 101)
    AND st_distance("ST_LOC_Stage_Location", to_geography('POINT(18.0831 59.2936)')) = 0
);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k01 a lookup by the checksum of the value finds the one stage', n = 1, n || ' rows, expected 1'
FROM (SELECT count(*) AS n FROM public."key_ST_Stage_1st" WHERE "Positor" = 0 AND "ST_LOC_Checksum" = hash(to_geography('POINT(18.0831 59.2936)')));
GO

-- k02 a key through the roles of a nexus (the event by its date, the location of its stage and the name of its
--     program), and one with the knot of a nexus role (its type)
INSERT INTO public."PR_Program" ("PR_ID", "Metadata_PR") VALUES (101, 0);
INSERT INTO public."PR_NAM_Program_Name_Posit" ("PR_NAM_ID", "PR_NAM_PR_ID", "PR_NAM_Program_Name") VALUES (101, 101, 'Hamlet');
INSERT INTO public."PR_NAM_Program_Name_Annex" ("PR_NAM_ID", "PR_NAM_PositedAt", "PR_NAM_Positor", "PR_NAM_Reliability", "Metadata_PR_NAM") VALUES (101, '2020-01-01', 0, 1, 0);
INSERT INTO public."EV_Event" ("EV_ID", "ST_ID_wasHeldAt", "PR_ID_wasPlayed", "ETY_ID_of", "Metadata_EV") VALUES (101, 101, 101, 1, 0);
INSERT INTO public."EV_DAT_Event_Date_Posit" ("EV_DAT_ID", "EV_DAT_EV_ID", "EV_DAT_Event_Date") VALUES (101, 101, '2024-05-01 19:00');
INSERT INTO public."EV_DAT_Event_Date_Annex" ("EV_DAT_ID", "EV_DAT_PositedAt", "EV_DAT_Positor", "EV_DAT_Reliability", "Metadata_EV_DAT") VALUES (101, '2024-01-01', 0, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k02 a lookup by a key through nexus roles finds the event', n = 1 AND found = 101, n || ' rows, event ' || coalesce(found::varchar, 'none') || ', expected 101'
FROM (
    SELECT count(*) AS n, max("EV_ID") AS found FROM public."key_EV_Event_1st"
    WHERE "Positor" = 0 AND "EV_DAT_Event_Date" = '2024-05-01 19:00' AND "wasPlayed_PR_NAM_Program_Name" = 'Hamlet'
    AND "wasHeldAt_ST_LOC_Checksum" = hash(to_geography('POINT(18.0831 59.2936)'))
);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k02 a key with the knot of a nexus role has its value', coalesce(type = 'premiere', false), 'type ' || coalesce(type, 'nothing') || ', expected premiere'
FROM (SELECT (SELECT "of_ETY_EventType" FROM public."key_EV_Event_2nd" WHERE "Positor" = 0 AND "EV_ID" = 101) AS type);
GO

-- k03 a key that changes: the key view has the latest value, the point-in-time key the value at a time
INSERT INTO public."ST_NAM_Stage_Name_Posit" ("ST_NAM_ID", "ST_NAM_ST_ID", "ST_NAM_Stage_Name", "ST_NAM_ChangedAt") VALUES (102, 101, 'Avicii Arena', '2021-05-19');
INSERT INTO public."ST_NAM_Stage_Name_Annex" ("ST_NAM_ID", "ST_NAM_PositedAt", "ST_NAM_Positor", "ST_NAM_Reliability", "Metadata_ST_NAM") VALUES (102, '2021-05-19', 0, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k03 the key view has the latest value', coalesce(name = 'Avicii Arena', false), 'name ' || coalesce(name, 'nothing') || ', expected Avicii Arena'
FROM (SELECT (SELECT "ST_NAM_Stage_Name" FROM public."key_ST_Stage_2nd" WHERE "Positor" = 0 AND "ST_ID" = 101) AS name);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k03 the point-in-time key has the value at the time', coalesce(name = 'Globen', false), 'name ' || coalesce(name, 'nothing') || ', expected Globen'
FROM (SELECT (SELECT "ST_NAM_Stage_Name" FROM TABLE(public."pkey_ST_Stage_2nd"('2020-06-01'::timestamp_ntz(9))) WHERE "Positor" = 0 AND "ST_ID" = 101) AS name);
GO

-- k04 a key through a tie (the event, by the name of the program its content is), and a knotted attribute with a
--     historized one (the stage by its minimum utilization and name)
INSERT INTO public."PR_content_ST_location_EV_of_Posit" ("PR_content_ST_location_EV_of_ID", "PR_ID_content", "ST_ID_location", "EV_ID_of") VALUES (101, 101, 101, 101);
INSERT INTO public."PR_content_ST_location_EV_of_Annex" ("PR_content_ST_location_EV_of_ID", "PR_content_ST_location_EV_of_PositedAt", "PR_content_ST_location_EV_of_Positor", "PR_content_ST_location_EV_of_Reliability",
    "Metadata_PR_content_ST_location_EV_of") VALUES (101, '2024-01-01', 0, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k04 a key through a tie has the value at its end', coalesce(name = 'Hamlet', false), 'name ' || coalesce(name, 'nothing') || ', expected Hamlet'
FROM (SELECT (SELECT "content_PR_NAM_Program_Name" FROM public."key_EV_Event_3rd" WHERE "Positor" = 0 AND "EV_ID" = 101) AS name);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k04 a knotted attribute gives the value of its knot', coalesce(minimum = 50 AND stage = 'Avicii Arena', false),
    coalesce(minimum::varchar, 'nothing') || ' and ' || coalesce(stage, 'nothing') || ', expected 50 and Avicii Arena'
FROM (SELECT max("ST_MIN_UTL_Utilization") AS minimum, max("ST_NAM_Stage_Name") AS stage FROM public."key_ST_Stage_3rd" WHERE "Positor" = 0 AND "ST_ID" = 101);
GO

-- k05 the key of an anchor without attributes, which has no perspectives (a person, by the name of the actor it is a
--     subset of)
INSERT INTO public."PN_Person" ("PN_ID", "Metadata_PN") VALUES (101, 0);
INSERT INTO public."AC_Actor" ("AC_ID", "Metadata_AC") VALUES (101, 0);
INSERT INTO public."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES (101, 101, 'Stellan', '2020-01-01');
INSERT INTO public."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES (101, '2020-01-01', 0, 1, 0);
INSERT INTO public."AC_subset_PN_of_Posit" ("AC_subset_PN_of_ID", "AC_ID_subset", "PN_ID_of") VALUES (101, 101, 101);
INSERT INTO public."AC_subset_PN_of_Annex" ("AC_subset_PN_of_ID", "AC_subset_PN_of_PositedAt", "AC_subset_PN_of_Positor", "AC_subset_PN_of_Reliability", "Metadata_AC_subset_PN_of") VALUES (101, '2020-01-01', 0, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k05 an anchor without attributes has its key', coalesce(name = 'Stellan', false), 'name ' || coalesce(name, 'nothing') || ', expected Stellan'
FROM (SELECT (SELECT "subset_AC_NAM_Actor_Name" FROM public."key_PN_Person_1st" WHERE "Positor" = 0 AND "PN_ID" = 101) AS name);
GO

-- k06 nothing is wrong with keys that only one identity has
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k06 the checks of unique keys are empty', n = 0, n || ' violations, expected none'
FROM (SELECT (SELECT count(*) FROM public."ic_key_ST_Stage_1st") + (SELECT count(*) FROM public."ic_key_EV_Event_1st")
    + (SELECT count(*) FROM public."ic_key_PR_Program_1st") AS n);
GO

-- k07 a key that two identities have: the check reports it (the SQL Server tests also refresh a key table here, which
--     Snowflake does not have)
INSERT INTO public."PR_Program" ("PR_ID", "Metadata_PR") VALUES (102, 0);
INSERT INTO public."PR_NAM_Program_Name_Posit" ("PR_NAM_ID", "PR_NAM_PR_ID", "PR_NAM_Program_Name") VALUES (102, 102, 'Hamlet');
INSERT INTO public."PR_NAM_Program_Name_Annex" ("PR_NAM_ID", "PR_NAM_PositedAt", "PR_NAM_Positor", "PR_NAM_Reliability", "Metadata_PR_NAM") VALUES (102, '2020-01-01', 0, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k07 the check reports a key of two identities', n = 1 AND occurrences = 2, n || ' violations of ' || coalesce(occurrences::varchar, 'none') || ', expected one of 2'
FROM (SELECT count(*) AS n, max(Occurrences) AS occurrences FROM public."ic_key_PR_Program_1st" WHERE Violation = 'duplicate natural key');
GO

-- k08 a route that is not functional (a program by the rating got for a part in it): two parts give the program two
--     keys, which the check reports
INSERT INTO public."AC_Actor" ("AC_ID", "Metadata_AC") VALUES (102, 0);
INSERT INTO public."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES (102, 102, 'Alicia', '2020-01-01');
INSERT INTO public."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES (102, '2020-01-01', 0, 1, 0);
INSERT INTO public."AC_part_PR_in_RAT_got_Posit" ("AC_part_PR_in_RAT_got_ID", "AC_ID_part", "PR_ID_in", "RAT_ID_got", "AC_part_PR_in_RAT_got_ChangedAt") VALUES
    (101, 101, 101, 1, '2024-01-01'), (102, 102, 101, 2, '2024-01-01');
INSERT INTO public."AC_part_PR_in_RAT_got_Annex" ("AC_part_PR_in_RAT_got_ID", "AC_part_PR_in_RAT_got_PositedAt", "AC_part_PR_in_RAT_got_Positor", "AC_part_PR_in_RAT_got_Reliability",
    "Metadata_AC_part_PR_in_RAT_got") VALUES (101, '2024-01-01', 0, 1, 0), (102, '2024-01-01', 0, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k08 a route that is not functional can give an identity more than one key', keys = 2, keys || ' keys, expected 2'
FROM (SELECT count(*) AS keys FROM public."key_PR_Program_2nd" WHERE "Positor" = 0 AND "PR_ID" = 101);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k08 the check reports it', n = 1 AND occurrences = 2, n || ' violations of ' || coalesce(occurrences::varchar, 'none') || ', expected one of 2'
FROM (SELECT count(*) AS n, max(Occurrences) AS occurrences FROM public."ic_key_PR_Program_2nd" WHERE Violation = 'more than one natural key');
GO

-- k09 the routes that break a rule are not generated, and those that do not are
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k09 the routes that break a rule are not generated', made = 0, made || ' of 5 there, expected none'
FROM (
    SELECT count(*) AS made FROM (
        SELECT table_name AS name FROM information_schema.views WHERE table_schema = 'PUBLIC'
        UNION ALL SELECT function_name FROM information_schema.functions WHERE function_schema = 'PUBLIC'
    ) WHERE name IN ('key_EV_Event_4th', 'key_EV_Event_5th', 'key_ST_Stage_5th', 'key_AC_Actor_4th', 'key_PR_Program_3rd')
);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k09 and the others are', made = 5, made || ' of 5 there'
FROM (
    SELECT count(*) AS made FROM (
        SELECT table_name AS name FROM information_schema.views WHERE table_schema = 'PUBLIC'
        UNION ALL SELECT function_name FROM information_schema.functions WHERE function_schema = 'PUBLIC'
    ) WHERE name IN ('key_AC_Actor_2nd', 'pkey_AC_Actor_2nd', 'key_AC_Actor_3rd', 'key_ST_Stage_4th', 'ic_key_EV_Event_3rd')
);
GO

-- k10 a key is per positor: a second positor that names the stage otherwise has a key of its own, and the first
--     positor's is as it was
INSERT INTO public."_Positor" ("Positor") SELECT 1 WHERE NOT EXISTS (SELECT 1 FROM public."_Positor" WHERE "Positor" = 1);
INSERT INTO public."ST_NAM_Stage_Name_Posit" ("ST_NAM_ID", "ST_NAM_ST_ID", "ST_NAM_Stage_Name", "ST_NAM_ChangedAt") VALUES (103, 101, 'Ericsson Globe', '2022-01-01');
INSERT INTO public."ST_NAM_Stage_Name_Annex" ("ST_NAM_ID", "ST_NAM_PositedAt", "ST_NAM_Positor", "ST_NAM_Reliability", "Metadata_ST_NAM") VALUES (103, '2024-01-01', 1, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k10 the second positor has a key of its own', coalesce(name = 'Ericsson Globe', false), 'name ' || coalesce(name, 'nothing') || ', expected Ericsson Globe'
FROM (SELECT (SELECT "ST_NAM_Stage_Name" FROM public."key_ST_Stage_2nd" WHERE "Positor" = 1 AND "ST_ID" = 101) AS name);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'k10 the first positor''s key is as it was', coalesce(name = 'Avicii Arena', false), 'name ' || coalesce(name, 'nothing') || ', expected Avicii Arena'
FROM (SELECT (SELECT "ST_NAM_Stage_Name" FROM public."key_ST_Stage_2nd" WHERE "Positor" = 0 AND "ST_ID" = 101) AS name);
GO
