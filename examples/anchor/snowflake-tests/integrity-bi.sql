-- Integrity tests, bitemporal: what the checks of attributes and ties say about what the posit and the annex say together.
--
-- Runs against the output for models/flags-bi.xml (golden/flags-bi/_full.sql) in an empty database, where an actor's name
-- (AC_NAM) and the rating that an actor gave a program (AC_part_PR_in_RAT_got) may not be restated, and tools/snowflake-tests.ps1
-- does both, and makes public.test_result. Snowflake has no triggers, so the posits and their annex rows go straight into the
-- tables, with identities from 100 up so as not to meet the ones a sequence hands out, and each group uses actors of its own.
-- The checks are the views ic_<attribute> and ic_<tie>; a reliability of 1 asserts a posit and 0 retracts it. Each check adds a
-- row to public.test_result; the groups are separated by GO and sent one at a time.

-- setup: the knot values that the groups use
INSERT INTO knots."RAT_Rating" ("RAT_ID", "RAT_Rating", "Metadata_RAT") VALUES (1, 'good', 0), (2, 'bad', 0);
GO

-- i01 nothing is wrong with a history of values, nor with a correction that retracts what it corrects at its own positing time
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (101, 701, 'A', '2020-01-01'), (102, 701, 'B', '2021-01-01'), (103, 701, 'B2', '2021-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (101, '2020-01-01', 1, 0), (102, '2021-01-01', 1, 0), (102, '2022-01-01', 0, 0), (103, '2022-01-01', 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'i01 a history and a correction break nothing', n = 0, n || ' violations, expected none'
FROM (SELECT count(*) AS n FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 701);
GO

-- i02 two posits asserted at once for the same entity and changing time, until one of them is retracted: the violation is at
--     the positing time where it begins, and only there
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (104, 702, 'X', '2020-01-01'), (105, 702, 'Y', '2020-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (104, '2020-01-01', 1, 0), (105, '2020-02-01', 1, 0), (104, '2020-03-01', 0, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'i02 two posits asserted at once are reported where they begin', n = 1 AND occurrences = 2 AND at = '2020-02-01', n || ' violations of ' || coalesce(occurrences::varchar, 'none') || ' at ' || coalesce(at, 'never') || ', expected one of 2 at 2020-02-01'
FROM (
    SELECT count(*) AS n, max(Occurrences) AS occurrences, max(left(ViolationKey['AC_NAM_PositedAt']::varchar, 10)) AS at
    FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 702 AND Violation = 'more than one posit asserted at a time'
);
GO

-- i03 two annex rows with the same entity, changing time, positing time and reliability are a temporal duplicate, which the
--     assembled view of SQL Server has a unique key against
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (106, 703, 'P', '2020-01-01'), (107, 703, 'Q', '2020-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (106, '2020-01-01', 1, 0), (107, '2020-01-01', 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'i03 a temporal duplicate is reported', n = 1 AND occurrences = 2, n || ' violations of ' || coalesce(occurrences::varchar, 'none') || ', expected one of 2'
FROM (SELECT count(*) AS n, max(Occurrences) AS occurrences FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 703 AND Violation = 'temporal duplicate');
INSERT INTO public.test_result (test, passed, detail)
SELECT 'i03 and they are asserted at once', n = 1, n || ' violations, expected 1'
FROM (SELECT count(*) AS n FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 703 AND Violation = 'more than one posit asserted at a time');
GO

-- i04 a value that is asserted again at a later changing time is a restatement, in an attribute that may not have them, and it
--     is gone when that posit is retracted: only what is in effect counts
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (108, 704, 'S', '2020-01-01'), (109, 704, 'S', '2021-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (108, '2020-01-01', 1, 0), (109, '2021-06-01', 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'i04 a restatement is reported', n = 1, n || ' violations, expected 1'
FROM (SELECT count(*) AS n FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 704 AND Violation = 'restatement');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES (109, '2021-07-01', 0, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'i04 a retracted restatement is not one', n = 0, n || ' violations, expected none'
FROM (SELECT count(*) AS n FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 704 AND Violation = 'restatement');
GO

-- i05 a knotted attribute that may not be restated is checked on the value of its knot
INSERT INTO knots."UTL_Utilization" ("UTL_ID", "UTL_Utilization", "Metadata_UTL") VALUES (1, 50, 0), (2, 80, 0);
INSERT INTO attributes."ST_AVG_Stage_Average_Posit" ("ST_AVG_ID", "ST_AVG_ST_ID", "ST_AVG_UTL_ID", "ST_AVG_ChangedAt") VALUES
    (101, 751, 1, '2020-01-01'), (102, 751, 1, '2021-01-01'), (103, 752, 1, '2020-01-01'), (104, 752, 2, '2021-01-01');
INSERT INTO attributes."ST_AVG_Stage_Average_Annex" ("ST_AVG_ID", "ST_AVG_PositedAt", "ST_AVG_Reliability", "Metadata_ST_AVG") VALUES
    (101, '2020-01-01', 1, 0), (102, '2021-01-01', 1, 0), (103, '2020-01-01', 1, 0), (104, '2021-01-01', 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'i05 a knotted restatement is reported, and another value is not', one = 1 AND other = 0, one || ' for the repeated value, ' || other || ' for the changed one, expected 1 and 0'
FROM (
    SELECT count_if(ViolationKey['ST_AVG_ST_ID']::int = 751) AS one, count_if(ViolationKey['ST_AVG_ST_ID']::int = 752) AS other
    FROM attributes."ic_ST_AVG_Stage_Average" WHERE Violation = 'restatement'
);
GO

-- i06 a tie with identifiers and a value that may not be restated: the same value for the same identifiers at a later changing time
INSERT INTO ties."AC_part_PR_in_RAT_got_Posit" ("AC_part_PR_in_RAT_got_ID", "AC_ID_part", "PR_ID_in", "RAT_ID_got", "AC_part_PR_in_RAT_got_ChangedAt") VALUES
    (101, 705, 705, 1, '2020-01-01'), (102, 705, 705, 1, '2021-01-01'), (103, 706, 706, 1, '2020-01-01'), (104, 706, 706, 2, '2021-01-01');
INSERT INTO ties."AC_part_PR_in_RAT_got_Annex" ("AC_part_PR_in_RAT_got_ID", "AC_part_PR_in_RAT_got_PositedAt", "AC_part_PR_in_RAT_got_Reliability",
    "Metadata_AC_part_PR_in_RAT_got") VALUES (101, '2020-01-01', 1, 0), (102, '2021-01-01', 1, 0), (103, '2020-01-01', 1, 0), (104, '2021-01-01', 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'i06 a tie restatement is reported, and another value is not', one = 1 AND other = 0, one || ' for the repeated rating, ' || other || ' for the changed one, expected 1 and 0'
FROM (
    SELECT count_if(ViolationKey['AC_ID_part']::int = 705) AS one, count_if(ViolationKey['AC_ID_part']::int = 706) AS other
    FROM ties."ic_AC_part_PR_in_RAT_got" WHERE Violation = 'restatement'
);
GO

-- i07 two posits of a tie asserted at once for the same identifiers and changing time
INSERT INTO ties."AC_part_PR_in_RAT_got_Posit" ("AC_part_PR_in_RAT_got_ID", "AC_ID_part", "PR_ID_in", "RAT_ID_got", "AC_part_PR_in_RAT_got_ChangedAt") VALUES
    (105, 707, 707, 1, '2020-01-01'), (106, 707, 707, 2, '2020-01-01');
INSERT INTO ties."AC_part_PR_in_RAT_got_Annex" ("AC_part_PR_in_RAT_got_ID", "AC_part_PR_in_RAT_got_PositedAt", "AC_part_PR_in_RAT_got_Reliability",
    "Metadata_AC_part_PR_in_RAT_got") VALUES (105, '2020-01-01', 1, 0), (106, '2020-02-01', 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'i07 two posits of a tie asserted at once are reported', n = 1 AND occurrences = 2, n || ' violations of ' || coalesce(occurrences::varchar, 'none') || ', expected one of 2'
FROM (SELECT count(*) AS n, max(Occurrences) AS occurrences FROM ties."ic_AC_part_PR_in_RAT_got" WHERE ViolationKey['AC_ID_part']::int = 707 AND Violation = 'more than one posit asserted at a time');
GO

-- i08 the checks are in IntegrityViolations: the violation of the attribute that was retracted in i04 is not
INSERT INTO public.test_result (test, passed, detail)
SELECT 'i08 IntegrityViolations has them', n = 3, n || ' of the violations of the attribute and the tie, expected 3'
FROM (
    SELECT count(*) AS n FROM dw.IntegrityViolations
    WHERE (Construct = 'AC_NAM_Actor_Name' AND ViolationKey['AC_NAM_AC_ID']::int IN (702, 704) AND Violation IN ('more than one posit asserted at a time', 'restatement'))
       OR (Construct = 'AC_part_PR_in_RAT_got' AND ViolationKey['AC_ID_part']::int IN (705, 707) AND Violation IN ('more than one posit asserted at a time', 'restatement'))
);
GO
