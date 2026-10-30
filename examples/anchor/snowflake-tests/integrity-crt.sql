-- Integrity tests, concurrent reliance temporal, not decisive: what the checks of attributes and ties say about what the posit
-- and the annex say together.
--
-- Runs against the output for models/flags-crt.xml (golden/flags-crt/_full.sql) in an empty database, where an actor's name
-- (AC_NAM) and the rating that an actor gave a program (AC_part_PR_in_RAT_got) may not be restated, and tools/snowflake-tests.ps1
-- does both, and makes public.test_result. Snowflake has no triggers, so the posits and their annex rows go straight into the
-- tables, with identities from 100 up so as not to meet the ones a sequence hands out, and each group uses actors of its own.
-- The checks are the views ic_<attribute> and ic_<tie>. A positor may hold more than one assertion at a time, as long as the
-- weights of them add up to at most one: a positive reliability is its own weight, a negative one adds one to it, so that
-- not-A with a reliability of -0.40 weighs 0.60. Each check adds a row to public.test_result; the groups are separated by GO
-- and sent one at a time.

-- setup: the knot values that the groups use
INSERT INTO knots."RAT_Rating" ("RAT_ID", "RAT_Rating", "Metadata_RAT") VALUES (1, 'good', 0), (2, 'bad', 0);
GO

-- c01 nothing is wrong with a history of values, nor with a correction that withdraws what it corrects at its own positing time
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (101, 801, 'A', '2020-01-01'), (102, 801, 'B', '2021-01-01'), (103, 801, 'B2', '2021-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (101, '2020-01-01', 1, 1, 0), (102, '2021-01-01', 1, 1, 0), (102, '2022-01-01', 1, 0, 0), (103, '2022-01-01', 1, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c01 a history and a correction break nothing', n = 0, n || ' violations, expected none'
FROM (SELECT count(*) AS n FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 801);
GO

-- c02 a positor that is sure of two different names for the same actor and time contradicts itself: 0.60 and 0.60 weigh 1.20,
--     and the violation is where the second begins, with its weight
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (104, 802, 'X', '2020-01-01'), (105, 802, 'Y', '2020-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (104, '2020-01-01', 1, 0.60, 0), (105, '2020-02-01', 1, 0.60, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c02 two assertions that weigh more than one are reported where they begin',
    n = 1 AND weight = 1.2 AND at = '2020-02-01',
    n || ' violations of weight ' || coalesce(weight::varchar, 'none') || ' at ' || coalesce(at, 'never') || ', expected one of 1.2 at 2020-02-01'
FROM (
    SELECT count(*) AS n, max(ViolationKey['Weight']::number(5, 2)) AS weight, max(left(ViolationKey['AC_NAM_PositedAt']::varchar, 10)) AS at
    FROM attributes."ic_AC_NAM_Actor_Name"
    WHERE ViolationKey['AC_NAM_AC_ID']::int = 802 AND Violation = 'assertions that contradict at a time'
);
GO

-- c03 0.60 and 0.40 weigh exactly one, which is fine, and a positor that is only 60% sure of a name and 60% sure that another
--     one is wrong (-0.40) weighs 1.20
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (106, 803, 'P', '2020-01-01'), (107, 803, 'Q', '2020-01-01'),
    (108, 804, 'R', '2020-01-01'), (109, 804, 'S', '2020-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (106, '2020-01-01', 1, 0.60, 0), (107, '2020-01-01', 1, 0.40, 0),
    (108, '2020-01-01', 1, -0.40, 0), (109, '2020-01-01', 1, -0.40, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c03 weights that add up to one are fine, and two denials of 0.60 are not', fine = 0 AND denials = 1, fine || ' violations for 0.60 and 0.40, ' || denials || ' for -0.40 and -0.40, expected 0 and 1'
FROM (
    SELECT count_if(ViolationKey['AC_NAM_AC_ID']::int = 803) AS fine, count_if(ViolationKey['AC_NAM_AC_ID']::int = 804) AS denials
    FROM attributes."ic_AC_NAM_Actor_Name" WHERE Violation = 'assertions that contradict at a time'
);
GO

-- c04 two positors do not contradict each other, each is checked on its own
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (110, 805, 'M', '2020-01-01'), (111, 805, 'N', '2020-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (110, '2020-01-01', 1, 1, 0), (111, '2020-01-01', 2, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c04 two positors may disagree', n = 0, n || ' violations, expected none'
FROM (SELECT count(*) AS n FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 805);
GO

-- c05 an annex row that withdraws an assertion (a reliability of 0) ends its weight: two assertions of a positor that follow
--     each other do not add up
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (112, 806, 'T', '2020-01-01'), (113, 806, 'U', '2020-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (112, '2020-01-01', 1, 0.90, 0), (112, '2020-02-01', 1, 0, 0), (113, '2020-02-01', 1, 0.90, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c05 a withdrawn assertion weighs nothing', n = 0, n || ' violations, expected none'
FROM (SELECT count(*) AS n FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 806);
GO

-- c06 a value that a positor asserts again at a later changing time is a restatement, and it is gone when that assertion is
--     withdrawn; what another positor asserts is a different matter
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (114, 807, 'V', '2020-01-01'), (115, 807, 'V', '2021-01-01'),
    (116, 808, 'W', '2020-01-01'), (117, 808, 'W', '2021-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (114, '2020-01-01', 1, 1, 0), (115, '2021-06-01', 1, 1, 0),
    (116, '2020-01-01', 1, 1, 0), (117, '2021-06-01', 2, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c06 a restatement is reported, but not when another positor asserts it', one = 1 AND other = 0, one || ' for the same positor, ' || other || ' for another, expected 1 and 0'
FROM (
    SELECT count_if(ViolationKey['AC_NAM_AC_ID']::int = 807) AS one, count_if(ViolationKey['AC_NAM_AC_ID']::int = 808) AS other
    FROM attributes."ic_AC_NAM_Actor_Name" WHERE Violation = 'restatement'
);
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES (115, '2021-07-01', 1, 0, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c06 a withdrawn restatement is not one', n = 0, n || ' violations, expected none'
FROM (SELECT count(*) AS n FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 807 AND Violation = 'restatement');
GO

-- c07 a knotted attribute that may not be restated is checked on the value of its knot
INSERT INTO knots."UTL_Utilization" ("UTL_ID", "UTL_Utilization", "Metadata_UTL") VALUES (1, 50, 0), (2, 80, 0);
INSERT INTO attributes."ST_AVG_Stage_Average_Posit" ("ST_AVG_ID", "ST_AVG_ST_ID", "ST_AVG_UTL_ID", "ST_AVG_ChangedAt") VALUES
    (101, 851, 1, '2020-01-01'), (102, 851, 1, '2021-01-01'), (103, 852, 1, '2020-01-01'), (104, 852, 2, '2021-01-01');
INSERT INTO attributes."ST_AVG_Stage_Average_Annex" ("ST_AVG_ID", "ST_AVG_PositedAt", "ST_AVG_Positor", "ST_AVG_Reliability", "Metadata_ST_AVG") VALUES
    (101, '2020-01-01', 1, 1, 0), (102, '2021-01-01', 1, 1, 0), (103, '2020-01-01', 1, 1, 0), (104, '2021-01-01', 1, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c07 a knotted restatement is reported, and another value is not', one = 1 AND other = 0, one || ' for the repeated value, ' || other || ' for the changed one, expected 1 and 0'
FROM (
    SELECT count_if(ViolationKey['ST_AVG_ST_ID']::int = 851) AS one, count_if(ViolationKey['ST_AVG_ST_ID']::int = 852) AS other
    FROM attributes."ic_ST_AVG_Stage_Average" WHERE Violation = 'restatement'
);
GO

-- c08 a tie with identifiers and a value that may not be restated: the same value for the same identifiers at a later changing time
INSERT INTO ties."AC_part_PR_in_RAT_got_Posit" ("AC_part_PR_in_RAT_got_ID", "AC_ID_part", "PR_ID_in", "RAT_ID_got", "AC_part_PR_in_RAT_got_ChangedAt") VALUES
    (101, 855, 855, 1, '2020-01-01'), (102, 855, 855, 1, '2021-01-01'), (103, 856, 856, 1, '2020-01-01'), (104, 856, 856, 2, '2021-01-01');
INSERT INTO ties."AC_part_PR_in_RAT_got_Annex" ("AC_part_PR_in_RAT_got_ID", "AC_part_PR_in_RAT_got_PositedAt", "AC_part_PR_in_RAT_got_Positor",
    "AC_part_PR_in_RAT_got_Reliability", "Metadata_AC_part_PR_in_RAT_got") VALUES
    (101, '2020-01-01', 1, 1, 0), (102, '2021-01-01', 1, 1, 0), (103, '2020-01-01', 1, 1, 0), (104, '2021-01-01', 1, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c08 a tie restatement is reported, and another value is not', one = 1 AND other = 0, one || ' for the repeated rating, ' || other || ' for the changed one, expected 1 and 0'
FROM (
    SELECT count_if(ViolationKey['AC_ID_part']::int = 855) AS one, count_if(ViolationKey['AC_ID_part']::int = 856) AS other
    FROM ties."ic_AC_part_PR_in_RAT_got" WHERE Violation = 'restatement'
);
GO

-- c09 a positor that is sure of two ratings for the same identifiers and time contradicts itself, and a tie checks
--     its positors on their own as well
INSERT INTO ties."AC_part_PR_in_RAT_got_Posit" ("AC_part_PR_in_RAT_got_ID", "AC_ID_part", "PR_ID_in", "RAT_ID_got", "AC_part_PR_in_RAT_got_ChangedAt") VALUES
    (105, 857, 857, 1, '2020-01-01'), (106, 857, 857, 2, '2020-01-01'),
    (107, 858, 858, 1, '2020-01-01'), (108, 858, 858, 2, '2020-01-01');
INSERT INTO ties."AC_part_PR_in_RAT_got_Annex" ("AC_part_PR_in_RAT_got_ID", "AC_part_PR_in_RAT_got_PositedAt", "AC_part_PR_in_RAT_got_Positor",
    "AC_part_PR_in_RAT_got_Reliability", "Metadata_AC_part_PR_in_RAT_got") VALUES
    (105, '2020-01-01', 1, 0.80, 0), (106, '2020-02-01', 1, 0.80, 0),
    (107, '2020-01-01', 1, 0.80, 0), (108, '2020-01-01', 2, 0.80, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c09 tie assertions that weigh more than one are reported, and those of two positors are not', one = 1 AND other = 0, one || ' for one positor, ' || other || ' for two, expected 1 and 0'
FROM (
    SELECT count_if(ViolationKey['AC_ID_part']::int = 857) AS one, count_if(ViolationKey['AC_ID_part']::int = 858) AS other
    FROM ties."ic_AC_part_PR_in_RAT_got" WHERE Violation = 'assertions that contradict at a time'
);
GO

-- c10 there is no temporal duplicate check when the model is not decisive, since the key of the annex is all there is
INSERT INTO public.test_result (test, passed, detail)
SELECT 'c10 the checks are in IntegrityViolations, and a duplicate is not one of them', found = 3 AND duplicates = 0, found || ' violations of the ones above, ' || duplicates || ' temporal duplicates, expected 3 and 0'
FROM (
    SELECT
        count_if(Violation IN ('assertions that contradict at a time', 'restatement')
            AND (ViolationKey['AC_NAM_AC_ID']::int = 802 OR ViolationKey['AC_ID_part']::int IN (855, 857))) AS found,
        count_if(Violation = 'temporal duplicate') AS duplicates
    FROM dw.IntegrityViolations
);
GO
