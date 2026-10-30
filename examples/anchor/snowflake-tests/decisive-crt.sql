-- Integrity tests, concurrent reliance temporal, decisive: what the checks of attributes say when a positor holds a single
-- assertion at a time, positive or negative, and the model has entity integrity.
--
-- Runs against the output for models/distinct-crt.xml (golden/distinct-crt/_full.sql) in an empty database, where an actor's
-- name (AC_NAM) and a stage's average (ST_AVG) may not be restated, and tools/snowflake-tests.ps1 does both, and makes
-- public.test_result. Snowflake has no triggers, so the posits and their annex rows go straight into the tables, with
-- identities from 100 up so as not to meet the ones a sequence hands out, and each group uses actors of its own. What counts
-- is the number of assertions that a positor has at a time, whatever their reliabilities are: a reliability above zero asserts,
-- one below denies, and zero is neither. The checks are the views ic_<attribute>. Each check adds a row to public.test_result;
-- the groups are separated by GO and sent one at a time.

-- d01 nothing is wrong with a history of values, nor with a correction that withdraws what it corrects at its own positing time
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (101, 901, 'A', '2020-01-01'), (102, 901, 'B', '2021-01-01'), (103, 901, 'B2', '2021-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (101, '2020-01-01', 1, 1, 0), (102, '2021-01-01', 1, 1, 0), (102, '2022-01-01', 1, 0, 0), (103, '2022-01-01', 1, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'd01 a history and a correction break nothing', n = 0, n || ' violations, expected none'
FROM (SELECT count(*) AS n FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 901);
GO

-- d02 two assertions of one positor for the same actor and time are too many when it is decisive, whatever their weights:
--     the violation is where the second begins, and it counts them
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (104, 902, 'X', '2020-01-01'), (105, 902, 'Y', '2020-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (104, '2020-01-01', 1, 0.10, 0), (105, '2020-02-01', 1, 0.10, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'd02 two assertions are too many, even of 0.10', n = 1 AND occurrences = 2 AND at = '2020-02-01',
    n || ' violations of ' || coalesce(occurrences::varchar, 'none') || ' at ' || coalesce(at, 'never') || ', expected one of 2 at 2020-02-01'
FROM (
    SELECT count(*) AS n, max(Occurrences) AS occurrences, max(left(ViolationKey['AC_NAM_PositedAt']::varchar, 10)) AS at
    FROM attributes."ic_AC_NAM_Actor_Name"
    WHERE ViolationKey['AC_NAM_AC_ID']::int = 902 AND Violation = 'more than one assertion at a time'
);
GO

-- d03 a denial is an assertion as well, and a reliability of zero is none
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (106, 903, 'P', '2020-01-01'), (107, 903, 'Q', '2020-01-01'),
    (108, 904, 'R', '2020-01-01'), (109, 904, 'S', '2020-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (106, '2020-01-01', 1, 1, 0), (107, '2020-01-01', 1, -0.50, 0),
    (108, '2020-01-01', 1, 1, 0), (109, '2020-01-01', 1, 0, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'd03 an assertion and a denial are two, an assertion and a zero are one', denial = 1 AND zero = 0, denial || ' for the denial, ' || zero || ' for the zero, expected 1 and 0'
FROM (
    SELECT count_if(ViolationKey['AC_NAM_AC_ID']::int = 903) AS denial, count_if(ViolationKey['AC_NAM_AC_ID']::int = 904) AS zero
    FROM attributes."ic_AC_NAM_Actor_Name" WHERE Violation = 'more than one assertion at a time'
);
GO

-- d04 two positors do not count against each other
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (110, 905, 'M', '2020-01-01'), (111, 905, 'N', '2020-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (110, '2020-01-01', 1, 1, 0), (111, '2020-01-01', 2, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'd04 two positors may disagree', n = 0, n || ' violations, expected none'
FROM (SELECT count(*) AS n FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 905);
GO

-- d05 entity integrity: two posits of the same actor, changing time, positing time, positor and assertion are a temporal
--     duplicate, which the assembled view of SQL Server has a unique key against
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (112, 906, 'T', '2020-01-01'), (113, 906, 'U', '2020-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (112, '2020-01-01', 1, 1, 0), (113, '2020-01-01', 1, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'd05 a temporal duplicate is reported', n = 1 AND occurrences = 2, n || ' violations of ' || coalesce(occurrences::varchar, 'none') || ', expected one of 2'
FROM (SELECT count(*) AS n, max(Occurrences) AS occurrences FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 906 AND Violation = 'temporal duplicate');
INSERT INTO public.test_result (test, passed, detail)
SELECT 'd05 and they are two assertions at once', n = 1, n || ' violations, expected 1'
FROM (SELECT count(*) AS n FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 906 AND Violation = 'more than one assertion at a time');
GO

-- d06 a value that a positor asserts again at a later changing time is a restatement, and it is gone when that assertion is
--     withdrawn
INSERT INTO attributes."AC_NAM_Actor_Name_Posit" ("AC_NAM_ID", "AC_NAM_AC_ID", "AC_NAM_Actor_Name", "AC_NAM_ChangedAt") VALUES
    (114, 907, 'V', '2020-01-01'), (115, 907, 'V', '2021-01-01');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES
    (114, '2020-01-01', 1, 1, 0), (115, '2021-06-01', 1, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'd06 a restatement is reported', n = 1, n || ' violations, expected 1'
FROM (SELECT count(*) AS n FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 907 AND Violation = 'restatement');
INSERT INTO attributes."AC_NAM_Actor_Name_Annex" ("AC_NAM_ID", "AC_NAM_PositedAt", "AC_NAM_Positor", "AC_NAM_Reliability", "Metadata_AC_NAM") VALUES (115, '2021-07-01', 1, 0, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'd06 a withdrawn restatement is not one', n = 0, n || ' violations, expected none'
FROM (SELECT count(*) AS n FROM attributes."ic_AC_NAM_Actor_Name" WHERE ViolationKey['AC_NAM_AC_ID']::int = 907 AND Violation = 'restatement');
GO

-- d07 a knotted attribute that may not be restated is checked on the value of its knot
INSERT INTO knots."UTL_Utilization" ("UTL_ID", "UTL_Utilization", "Metadata_UTL") VALUES (1, 50, 0), (2, 80, 0);
INSERT INTO attributes."ST_AVG_Stage_Average_Posit" ("ST_AVG_ID", "ST_AVG_ST_ID", "ST_AVG_UTL_ID", "ST_AVG_ChangedAt") VALUES
    (101, 951, 1, '2020-01-01'), (102, 951, 1, '2021-01-01'), (103, 952, 1, '2020-01-01'), (104, 952, 2, '2021-01-01');
INSERT INTO attributes."ST_AVG_Stage_Average_Annex" ("ST_AVG_ID", "ST_AVG_PositedAt", "ST_AVG_Positor", "ST_AVG_Reliability", "Metadata_ST_AVG") VALUES
    (101, '2020-01-01', 1, 1, 0), (102, '2021-01-01', 1, 1, 0), (103, '2020-01-01', 1, 1, 0), (104, '2021-01-01', 1, 1, 0);
INSERT INTO public.test_result (test, passed, detail)
SELECT 'd07 a knotted restatement is reported, and another value is not', one = 1 AND other = 0, one || ' for the repeated value, ' || other || ' for the changed one, expected 1 and 0'
FROM (
    SELECT count_if(ViolationKey['ST_AVG_ST_ID']::int = 951) AS one, count_if(ViolationKey['ST_AVG_ST_ID']::int = 952) AS other
    FROM attributes."ic_ST_AVG_Stage_Average" WHERE Violation = 'restatement'
);
GO

-- d08 the checks are in IntegrityViolations
INSERT INTO public.test_result (test, passed, detail)
SELECT 'd08 IntegrityViolations has them', n = 4, n || ' of the violations above, expected 4'
FROM (
    SELECT count(*) AS n FROM dw.IntegrityViolations
    WHERE Construct = 'AC_NAM_Actor_Name' AND ViolationKey['AC_NAM_AC_ID']::int IN (902, 903, 906)
      AND Violation IN ('more than one assertion at a time', 'temporal duplicate')
);
GO
