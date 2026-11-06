-- Trigger tests, uni-temporal: what inserts, updates and deletes through the views and the tables store.
--
-- Runs against the output for models/postgresql-triggers.xml (golden/postgresql-triggers/_full.sql) in an empty database;
-- tools/postgres-tests.ps1 does both, and makes public.test_result. A check that expects an error catches it with
-- public.try, which runs a statement and returns the message of the error it gave, or null. Every group uses rows of its
-- own, and gives its times explicitly where the rule does not depend on now. The rules are in Anchor's docs/ANCHOR.md,
-- "Loading through the latest views". PostgreSQL runs a trigger of this kind for each row, and tells that a column is set in
-- an update from its having another value than before, so a column set to what it was is not set (an update that sets a
-- value and its changing time states it again on purpose, as it does in SQL Server).

CREATE OR REPLACE FUNCTION public.try(statement text) RETURNS text
LANGUAGE plpgsql
AS $$
BEGIN
    EXECUTE statement;
    RETURN NULL;
EXCEPTION WHEN OTHERS THEN
    RETURN SQLERRM;
END;
$$;
INSERT INTO public."GRD_Grade" ("GRD_ID", "GRD_Grade", "Metadata_GRD") VALUES (1, 'A', 0), (2, 'B', 0), (3, 'C', 0);
GO

-- u01 an insert through the latest view stores each value given
DO $$
DECLARE
    s integer;
    n integer;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_NAM_Subject_Name", "SU_COD_Subject_Code", "SU_GRD_GRD_ID", "SU_NOT_Subject_Note",
        "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_STA_Subject_State", "SU_STA_ChangedAt", "SU_LBL_Subject_Label", "SU_LBL_ChangedAt",
        "SU_TAG_Subject_Tag", "SU_TAG_ChangedAt", "SU_LVL_GRD_ID", "SU_LVL_ChangedAt", "SU_TXT_Subject_Text", "SU_TXT_ChangedAt",
        "SU_ASR_Subject_Assessment", "SU_ASR_ChangedAt", "SU_ERS_Subject_Erasable", "SU_ERS_ChangedAt")
    VALUES (0, 'name', 'code', 1, 'note', 'title', '2020-01-01', 'state', '2020-01-01', 'label', '2020-01-01',
        'tag', '2020-01-01', 1, '2020-01-01', 'text', '2020-01-01', 'assessment', '2020-01-01', 'erasable', '2020-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    n := (SELECT count(*) FROM public."SU_NAM_Subject_Name" WHERE "SU_NAM_SU_ID" = s) + (SELECT count(*) FROM public."SU_COD_Subject_Code" WHERE "SU_COD_SU_ID" = s)
       + (SELECT count(*) FROM public."SU_GRD_Subject_Grade" WHERE "SU_GRD_SU_ID" = s) + (SELECT count(*) FROM public."SU_NOT_Subject_Note" WHERE "SU_NOT_SU_ID" = s)
       + (SELECT count(*) FROM public."SU_TTL_Subject_Title" WHERE "SU_TTL_SU_ID" = s) + (SELECT count(*) FROM public."SU_STA_Subject_State" WHERE "SU_STA_SU_ID" = s)
       + (SELECT count(*) FROM public."SU_LBL_Subject_Label" WHERE "SU_LBL_SU_ID" = s) + (SELECT count(*) FROM public."SU_TAG_Subject_Tag" WHERE "SU_TAG_SU_ID" = s)
       + (SELECT count(*) FROM public."SU_LVL_Subject_Level" WHERE "SU_LVL_SU_ID" = s) + (SELECT count(*) FROM public."SU_TXT_Subject_Text" WHERE "SU_TXT_SU_ID" = s)
       + (SELECT count(*) FROM public."SU_ASR_Subject_Assessment" WHERE "SU_ASR_SU_ID" = s) + (SELECT count(*) FROM public."SU_ERS_Subject_Erasable" WHERE "SU_ERS_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u01 an insert through the latest view stores each value', n = 12, n || ' rows, expected 12');
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_GRD_GRD_Grade") VALUES (0, 'B');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    n := (SELECT "SU_GRD_GRD_ID" FROM public."SU_GRD_Subject_Grade" WHERE "SU_GRD_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u01 an insert by knot value stores the knot', n = 2, 'knot ' || coalesce(n::text, 'none') || ', expected 2');
END;
$$;
GO

-- u02 an update that leaves every value as it is states nothing (State is not restatable and Name is static)
DO $$
DECLARE
    s integer;
    before integer;
    after integer;
    error text;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_NAM_Subject_Name", "SU_COD_Subject_Code", "SU_GRD_GRD_ID", "SU_NOT_Subject_Note",
        "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_STA_Subject_State", "SU_STA_ChangedAt", "SU_LBL_Subject_Label", "SU_LBL_ChangedAt",
        "SU_TAG_Subject_Tag", "SU_TAG_ChangedAt", "SU_LVL_GRD_ID", "SU_LVL_ChangedAt", "SU_TXT_Subject_Text", "SU_TXT_ChangedAt",
        "SU_ASR_Subject_Assessment", "SU_ASR_ChangedAt", "SU_ERS_Subject_Erasable", "SU_ERS_ChangedAt")
    VALUES (0, 'name', 'code', 1, 'note', 'title', '2020-01-01', 'state', '2020-01-01', 'label', '2020-01-01',
        'tag', '2020-01-01', 1, '2020-01-01', 'text', '2020-01-01', 'assessment', '2020-01-01', 'erasable', '2020-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    before := (SELECT count(*) FROM public."SU_NAM_Subject_Name") + (SELECT count(*) FROM public."SU_COD_Subject_Code") + (SELECT count(*) FROM public."SU_GRD_Subject_Grade")
       + (SELECT count(*) FROM public."SU_NOT_Subject_Note") + (SELECT count(*) FROM public."SU_TTL_Subject_Title") + (SELECT count(*) FROM public."SU_STA_Subject_State")
       + (SELECT count(*) FROM public."SU_LBL_Subject_Label") + (SELECT count(*) FROM public."SU_TAG_Subject_Tag") + (SELECT count(*) FROM public."SU_LVL_Subject_Level")
       + (SELECT count(*) FROM public."SU_TXT_Subject_Text") + (SELECT count(*) FROM public."SU_ASR_Subject_Assessment") + (SELECT count(*) FROM public."SU_ERS_Subject_Erasable");
    error := public.try(format('UPDATE public."lSU_Subject" SET "SU_NAM_Subject_Name" = "SU_NAM_Subject_Name", "SU_COD_Subject_Code" = "SU_COD_Subject_Code",
        "SU_GRD_GRD_ID" = "SU_GRD_GRD_ID", "SU_NOT_Subject_Note" = "SU_NOT_Subject_Note", "SU_TTL_Subject_Title" = "SU_TTL_Subject_Title",
        "SU_STA_Subject_State" = "SU_STA_Subject_State", "SU_LBL_Subject_Label" = "SU_LBL_Subject_Label", "SU_TAG_Subject_Tag" = "SU_TAG_Subject_Tag",
        "SU_LVL_GRD_ID" = "SU_LVL_GRD_ID", "SU_TXT_Subject_Text" = "SU_TXT_Subject_Text", "SU_ASR_Subject_Assessment" = "SU_ASR_Subject_Assessment",
        "SU_ERS_Subject_Erasable" = "SU_ERS_Subject_Erasable" WHERE "SU_ID" = %s', s));
    after := (SELECT count(*) FROM public."SU_NAM_Subject_Name") + (SELECT count(*) FROM public."SU_COD_Subject_Code") + (SELECT count(*) FROM public."SU_GRD_Subject_Grade")
       + (SELECT count(*) FROM public."SU_NOT_Subject_Note") + (SELECT count(*) FROM public."SU_TTL_Subject_Title") + (SELECT count(*) FROM public."SU_STA_Subject_State")
       + (SELECT count(*) FROM public."SU_LBL_Subject_Label") + (SELECT count(*) FROM public."SU_TAG_Subject_Tag") + (SELECT count(*) FROM public."SU_LVL_Subject_Level")
       + (SELECT count(*) FROM public."SU_TXT_Subject_Text") + (SELECT count(*) FROM public."SU_ASR_Subject_Assessment") + (SELECT count(*) FROM public."SU_ERS_Subject_Erasable");
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u02 an update that leaves every value as it is states nothing', error IS NULL AND after = before,
        (after - before) || ' new rows ' || coalesce(error, ''));
END;
$$;
GO

-- u03 a new value of a historized attribute is a new version from now
DO $$
DECLARE
    s integer;
    n integer;
    shown text;
    changed timestamp;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt") VALUES (0, 'first', '2020-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    UPDATE public."lSU_Subject" SET "SU_TTL_Subject_Title" = 'second' WHERE "SU_ID" = s;
    SELECT "SU_TTL_Subject_Title", "SU_TTL_ChangedAt" INTO shown, changed FROM public."lSU_Subject" WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_TTL_Subject_Title" WHERE "SU_TTL_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u03 a new value is a new version from now', n = 2 AND shown = 'second' AND changed > '2025-01-01', n || ' versions, shown ' || shown || ' from ' || changed);
    UPDATE public."lSU_Subject" SET "SU_TTL_Subject_Title" = 'third', "SU_TTL_ChangedAt" = '2022-01-01' WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_TTL_Subject_Title" WHERE "SU_TTL_SU_ID" = s AND "SU_TTL_ChangedAt" = '2022-01-01' AND "SU_TTL_Subject_Title" = 'third');
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u03 a new value with a changing time is a version from that time', n = 1, n || ' versions at 2022, expected 1');
END;
$$;
GO

-- u04 the same value with a changing time of its own is a restatement, and the settings decide
DO $$
DECLARE
    s integer;
    n integer;
    error text;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_STA_Subject_State", "SU_STA_ChangedAt",
        "SU_LBL_Subject_Label", "SU_LBL_ChangedAt", "SU_TAG_Subject_Tag", "SU_TAG_ChangedAt", "SU_LVL_GRD_ID", "SU_LVL_ChangedAt", "SU_TXT_Subject_Text", "SU_TXT_ChangedAt")
    VALUES (0, 'x', '2020-01-01', 'x', '2020-01-01', 'x', '2020-01-01', 'x', '2020-01-01', 1, '2020-01-01', 'x', '2020-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    UPDATE public."lSU_Subject" SET "SU_TTL_Subject_Title" = 'x', "SU_TTL_ChangedAt" = '2021-01-01' WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_TTL_Subject_Title" WHERE "SU_TTL_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u04 restatable: a restatement is stored', n = 2, n || ' versions, expected 2');
    error := public.try(format('UPDATE public."lSU_Subject" SET "SU_STA_Subject_State" = ''x'', "SU_STA_ChangedAt" = ''2021-01-01'' WHERE "SU_ID" = %s', s));
    n := (SELECT count(*) FROM public."SU_STA_Subject_State" WHERE "SU_STA_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u04 not restatable: a restatement is an error', error LIKE 'Restatement in SU_STA_Subject_State%' AND n = 1, n || ' versions; ' || coalesce(error, 'no error'));
    error := public.try(format('UPDATE public."lSU_Subject" SET "SU_LBL_Subject_Label" = ''x'', "SU_LBL_ChangedAt" = ''2021-01-01'' WHERE "SU_ID" = %s', s));
    n := (SELECT count(*) FROM public."SU_LBL_Subject_Label" WHERE "SU_LBL_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u04 not restatable, idempotent: a restatement is skipped', error IS NULL AND n = 1, n || ' versions ' || coalesce(error, ''));
    UPDATE public."lSU_Subject" SET "SU_TAG_Subject_Tag" = 'x', "SU_TAG_ChangedAt" = '2021-01-01' WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_TAG_Subject_Tag" WHERE "SU_TAG_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u04 restatable, idempotent: a restatement is skipped', n = 1, n || ' versions, expected 1');
    UPDATE public."lSU_Subject" SET "SU_LVL_GRD_ID" = 1, "SU_LVL_ChangedAt" = '2021-01-01' WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_LVL_Subject_Level" WHERE "SU_LVL_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u04 knotted, restatable: a restatement is stored', n = 2, n || ' versions, expected 2');
    UPDATE public."lSU_Subject" SET "SU_TXT_Subject_Text" = 'x', "SU_TXT_ChangedAt" = '2021-01-01' WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_TXT_Subject_Text" WHERE "SU_TXT_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u04 with a checksum, restatable: a restatement is stored', n = 2, n || ' versions, expected 2');
END;
$$;
GO

-- u05 a static value: a missing one is filled, the same one states nothing, another one is a contradiction
DO $$
DECLARE
    s integer;
    n integer;
    v text;
    error text;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    UPDATE public."lSU_Subject" SET "SU_NAM_Subject_Name" = 'n1', "SU_COD_Subject_Code" = 'c1', "SU_GRD_GRD_Grade" = 'A', "SU_NOT_Subject_Note" = 'note one' WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_NAM_Subject_Name" WHERE "SU_NAM_SU_ID" = s) + (SELECT count(*) FROM public."SU_COD_Subject_Code" WHERE "SU_COD_SU_ID" = s)
       + (SELECT count(*) FROM public."SU_GRD_Subject_Grade" WHERE "SU_GRD_SU_ID" = s AND "SU_GRD_GRD_ID" = 1) + (SELECT count(*) FROM public."SU_NOT_Subject_Note" WHERE "SU_NOT_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u05 a missing static value is filled by an update', n = 4, n || ' values, expected 4');
    error := public.try(format('UPDATE public."lSU_Subject" SET "SU_NAM_Subject_Name" = ''n1'', "SU_COD_Subject_Code" = ''c1'', "SU_GRD_GRD_ID" = 1, "SU_NOT_Subject_Note" = ''note one'' WHERE "SU_ID" = %s', s));
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u05 the same static value states nothing', error IS NULL, error);
    error := public.try(format('UPDATE public."lSU_Subject" SET "SU_NAM_Subject_Name" = ''n2'' WHERE "SU_ID" = %s', s));
    v := (SELECT "SU_NAM_Subject_Name" FROM public."SU_NAM_Subject_Name" WHERE "SU_NAM_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u05 another static value is a contradiction', error LIKE 'Contradiction in SU_NAM_Subject_Name%' AND v = 'n1', v || '; ' || coalesce(error, 'no error'));
    error := public.try(format('UPDATE public."lSU_Subject" SET "SU_COD_Subject_Code" = ''c2'' WHERE "SU_ID" = %s', s));
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u05 idempotent: another static value is still a contradiction', error LIKE 'Contradiction in SU_COD_Subject_Code%', coalesce(error, 'no error'));
    error := public.try(format('UPDATE public."lSU_Subject" SET "SU_GRD_GRD_Grade" = ''B'' WHERE "SU_ID" = %s', s));
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u05 knotted: another knot value is a contradiction', error LIKE 'Contradiction in SU_GRD_Subject_Grade%', coalesce(error, 'no error'));
    error := public.try(format('UPDATE public."lSU_Subject" SET "SU_NOT_Subject_Note" = ''note two'' WHERE "SU_ID" = %s', s));
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u05 with a checksum: another value is a contradiction', error LIKE 'Contradiction in SU_NOT_Subject_Note%', coalesce(error, 'no error'));
END;
$$;
GO

-- u06 inserts straight into the attribute tables: the identical is ignored, another value for the same slot is a
--     contradiction, and a restatement of an attribute that is not restatable is an error
DO $$
DECLARE
    s integer;
    n integer;
    error text;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_NAM_Subject_Name", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_STA_Subject_State", "SU_STA_ChangedAt")
    VALUES (0, 'n', 't', '2020-01-01', 's', '2020-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    error := public.try(format('INSERT INTO public."SU_NAM_Subject_Name" ("SU_NAM_SU_ID", "SU_NAM_Subject_Name", "Metadata_SU_NAM") VALUES (%s, ''n'', 0)', s));
    error := coalesce(error, public.try(format('INSERT INTO public."SU_TTL_Subject_Title" ("SU_TTL_SU_ID", "SU_TTL_ChangedAt", "SU_TTL_Subject_Title", "Metadata_SU_TTL") VALUES (%s, ''2020-01-01'', ''t'', 0)', s)));
    n := (SELECT count(*) FROM public."SU_NAM_Subject_Name" WHERE "SU_NAM_SU_ID" = s) + (SELECT count(*) FROM public."SU_TTL_Subject_Title" WHERE "SU_TTL_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u06 the identical inserted again is ignored', error IS NULL AND n = 2, n || ' rows ' || coalesce(error, ''));
    error := public.try(format('INSERT INTO public."SU_TTL_Subject_Title" ("SU_TTL_SU_ID", "SU_TTL_ChangedAt", "SU_TTL_Subject_Title", "Metadata_SU_TTL") VALUES (%s, ''2020-01-01'', ''other'', 0)', s));
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u06 another value at a changing time that has one is a contradiction', error LIKE 'Contradiction in SU_TTL_Subject_Title%', coalesce(error, 'no error'));
    error := public.try(format('INSERT INTO public."SU_STA_Subject_State" ("SU_STA_SU_ID", "SU_STA_ChangedAt", "SU_STA_Subject_State", "Metadata_SU_STA") VALUES (%s, ''2021-01-01'', ''s'', 0)', s));
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u06 not restatable: an inserted restatement is an error', error LIKE 'Restatement in SU_STA_Subject_State%', coalesce(error, 'no error'));
END;
$$;
GO

-- u07 idempotent, out of order: an earlier version with the same value as the next one keeps the earlier start
DO $$
DECLARE
    s integer;
    n integer;
    changed timestamp;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    INSERT INTO public."SU_LBL_Subject_Label" ("SU_LBL_SU_ID", "SU_LBL_ChangedAt", "SU_LBL_Subject_Label", "Metadata_SU_LBL") VALUES (s, '2021-01-01', 'x', 0);
    INSERT INTO public."SU_LBL_Subject_Label" ("SU_LBL_SU_ID", "SU_LBL_ChangedAt", "SU_LBL_Subject_Label", "Metadata_SU_LBL") VALUES (s, '2020-01-01', 'x', 0);
    SELECT count(*), min("SU_LBL_ChangedAt") INTO n, changed FROM public."SU_LBL_Subject_Label" WHERE "SU_LBL_SU_ID" = s;
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u07 idempotent: the value counts from the earlier time', n = 1 AND changed = '2020-01-01', n || ' versions from ' || changed);
END;
$$;
GO

-- u08 null on a deletable attribute: nothing for an attribute that is not deletable, nothing without the deletable column,
--     and the history moved to the deletion table with it (historized, static, knotted, and a nexus attribute)
DO $$
DECLARE
    s integer; other integer;
    n integer;
    deleted integer;
    shown text;
    stamped timestamp;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_ERS_Subject_Erasable", "SU_ERS_ChangedAt") VALUES (0, 't', '2020-01-01', 'e', '2020-01-01');
    s := (SELECT max("SU_ID") FROM public."SU_Subject");
    UPDATE public."lSU_Subject" SET "SU_ERS_Subject_Erasable" = 'f', "SU_ERS_ChangedAt" = '2021-01-01' WHERE "SU_ID" = s;
    UPDATE public."lSU_Subject" SET "SU_TTL_Subject_Title" = NULL WHERE "SU_ID" = s;
    shown := (SELECT "SU_TTL_Subject_Title" FROM public."lSU_Subject" WHERE "SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 null changes nothing when not deletable', shown = 't', 'shown ' || coalesce(shown, 'nothing'));
    UPDATE public."lSU_Subject" SET "SU_ERS_Subject_Erasable" = NULL WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_ERS_Subject_Erasable" WHERE "SU_ERS_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 null without the deletable column changes nothing', n = 2, n || ' versions, expected 2');
    UPDATE public."lSU_Subject" SET "SU_ERS_Subject_Erasable" = NULL, "Deletable_SU_ERS" = true, "SU_ERS_ChangedAt" = '2022-02-02' WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_ERS_Subject_Erasable" WHERE "SU_ERS_SU_ID" = s);
    deleted := (SELECT count(*) FROM public."SU_ERS_Subject_Erasable_Deleted" WHERE "SU_ERS_SU_ID" = s);
    stamped := (SELECT min("SU_ERS_Deleted") FROM public."SU_ERS_Subject_Erasable_Deleted" WHERE "SU_ERS_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 null with the deletable column moves the history to the deletion table', n = 0 AND deleted = 2, n || ' left, ' || deleted || ' moved');
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 a historized deletion is stamped with the changing time given', stamped = '2022-02-02', 'stamped ' || coalesce(stamped::text, 'nothing'));
    shown := (SELECT "SU_TTL_Subject_Title" FROM public."lSU_Subject" WHERE "SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 the other attributes of the entity are left alone', shown = 't', 'shown ' || coalesce(shown, 'nothing'));
    -- an entity without a value does not move anything, and another entity's history stays where it is
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_ERS_Subject_Erasable", "SU_ERS_ChangedAt") VALUES (0, 'other', '2020-01-01');
    other := (SELECT max("SU_ID") FROM public."SU_Subject");
    UPDATE public."lSU_Subject" SET "SU_ERS_Subject_Erasable" = NULL, "Deletable_SU_ERS" = true WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_ERS_Subject_Erasable" WHERE "SU_ERS_SU_ID" = other);
    deleted := (SELECT count(*) FROM public."SU_ERS_Subject_Erasable_Deleted" WHERE "SU_ERS_SU_ID" = s) + (SELECT count(*) FROM public."SU_ERS_Subject_Erasable_Deleted" WHERE "SU_ERS_SU_ID" = other);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 a null for an entity without a value moves nothing, and nothing of another entity', n = 1 AND deleted = 2, n || ' left, ' || deleted || ' deleted');
    -- a value can be given again after a deletion
    UPDATE public."lSU_Subject" SET "SU_ERS_Subject_Erasable" = 'again', "SU_ERS_ChangedAt" = '2023-01-01' WHERE "SU_ID" = s;
    shown := (SELECT "SU_ERS_Subject_Erasable" FROM public."lSU_Subject" WHERE "SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 a value given after a deletion is shown', shown = 'again', 'shown ' || coalesce(shown, 'nothing'));

    -- static
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_NAM_Subject_Name", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt") VALUES (0, 'name', 'title', '2020-01-01');
    s := (SELECT max("SU_ID") FROM public."SU_Subject");
    UPDATE public."lSU_Subject" SET "SU_NAM_Subject_Name" = NULL, "Deletable_SU_NAM" = true WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_NAM_Subject_Name" WHERE "SU_NAM_SU_ID" = s);
    deleted := (SELECT count(*) FROM public."SU_NAM_Subject_Name_Deleted" WHERE "SU_NAM_SU_ID" = s);
    stamped := (SELECT "SU_NAM_Deleted" FROM public."SU_NAM_Subject_Name_Deleted" WHERE "SU_NAM_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 a static attribute is moved to its deletion table, stamped with now', n = 0 AND deleted = 1 AND stamped > '2025-01-01', n || ' left, ' || deleted || ' moved, stamped ' || coalesce(stamped::text, 'nothing'));

    -- knotted, historized: a null knot value deletes too
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_LVL_GRD_Grade", "SU_LVL_ChangedAt") VALUES (0, 'A', '2020-01-01');
    s := (SELECT max("SU_ID") FROM public."SU_Subject");
    UPDATE public."lSU_Subject" SET "SU_LVL_GRD_Grade" = 'B', "SU_LVL_ChangedAt" = '2021-01-01' WHERE "SU_ID" = s;
    UPDATE public."lSU_Subject" SET "SU_LVL_GRD_Grade" = NULL WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_LVL_Subject_Level" WHERE "SU_LVL_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 a null knot value without the deletable column changes nothing', n = 2, n || ' versions, expected 2');
    UPDATE public."lSU_Subject" SET "SU_LVL_GRD_Grade" = NULL, "Deletable_SU_LVL" = true WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_LVL_Subject_Level" WHERE "SU_LVL_SU_ID" = s);
    deleted := (SELECT count(*) FROM public."SU_LVL_Subject_Level_Deleted" WHERE "SU_LVL_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 a null knot value with the deletable column moves the history', n = 0 AND deleted = 2, n || ' left, ' || deleted || ' moved');
END;
$$;
GO

-- u08 nexus attributes (static and historized) and ties (historized and static) that are deletable
DO $$
DECLARE
    s integer; o integer; e integer;
    n integer;
    deleted integer;
    shown text;
    stamped timestamp;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    INSERT INTO public."OB_Object" ("Metadata_OB") VALUES (0) RETURNING "OB_ID" INTO o;
    INSERT INTO public."lEV_Event" ("Metadata_EV", "SU_ID_for", "EV_QTY_Event_Quantity", "EV_PLC_Event_Place", "EV_PLC_ChangedAt") VALUES (0, s, 5, 'here', '2020-01-01');
    e := (SELECT max("EV_ID") FROM public."EV_Event" WHERE "SU_ID_for" = s);
    UPDATE public."lEV_Event" SET "EV_QTY_Event_Quantity" = NULL, "EV_PLC_Event_Place" = NULL WHERE "EV_ID" = e;
    n := (SELECT count(*) FROM public."EV_QTY_Event_Quantity" WHERE "EV_QTY_EV_ID" = e) + (SELECT count(*) FROM public."EV_PLC_Event_Place" WHERE "EV_PLC_EV_ID" = e);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 a nexus: null without the deletable column changes nothing', n = 2, n || ' rows, expected 2');
    UPDATE public."lEV_Event" SET "EV_QTY_Event_Quantity" = NULL, "Deletable_EV_QTY" = true WHERE "EV_ID" = e;
    n := (SELECT count(*) FROM public."EV_QTY_Event_Quantity" WHERE "EV_QTY_EV_ID" = e);
    deleted := (SELECT count(*) FROM public."EV_QTY_Event_Quantity_Deleted" WHERE "EV_QTY_EV_ID" = e);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 a nexus: a static attribute is moved to its deletion table', n = 0 AND deleted = 1, n || ' left, ' || deleted || ' moved');
    shown := (SELECT "EV_PLC_Event_Place" FROM public."lEV_Event" WHERE "EV_ID" = e);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 a nexus: the other attribute is left alone', shown = 'here', 'shown ' || coalesce(shown, 'nothing'));
    UPDATE public."lEV_Event" SET "EV_PLC_Event_Place" = NULL, "Deletable_EV_PLC" = true, "EV_PLC_ChangedAt" = '2021-03-03' WHERE "EV_ID" = e;
    n := (SELECT count(*) FROM public."EV_PLC_Event_Place" WHERE "EV_PLC_EV_ID" = e);
    deleted := (SELECT count(*) FROM public."EV_PLC_Event_Place_Deleted" WHERE "EV_PLC_EV_ID" = e);
    stamped := (SELECT "EV_PLC_Deleted" FROM public."EV_PLC_Event_Place_Deleted" WHERE "EV_PLC_EV_ID" = e);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 a nexus: a historized attribute is moved, stamped with the changing time', n = 0 AND deleted = 1 AND stamped = '2021-03-03', n || ' left, ' || deleted || ' moved, stamped ' || coalesce(stamped::text, 'nothing'));

    -- a historized tie with identifiers and a value
    INSERT INTO public."lSU_holder_OB_item_GRD_grade" ("Metadata_SU_holder_OB_item_GRD_grade", "SU_holder_OB_item_GRD_grade_ChangedAt", "SU_ID_holder", "OB_ID_item", "GRD_ID_grade") VALUES (0, '2020-01-01', s, o, 1);
    UPDATE public."lSU_holder_OB_item_GRD_grade" SET "grade_GRD_Grade" = 'B', "SU_holder_OB_item_GRD_grade_ChangedAt" = '2021-01-01' WHERE "SU_ID_holder" = s AND "OB_ID_item" = o;
    UPDATE public."lSU_holder_OB_item_GRD_grade" SET "grade_GRD_Grade" = NULL WHERE "SU_ID_holder" = s AND "OB_ID_item" = o;
    n := (SELECT count(*) FROM public."SU_holder_OB_item_GRD_grade" WHERE "SU_ID_holder" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 a tie: null without the deletable column changes nothing', n = 2, n || ' versions, expected 2');
    UPDATE public."lSU_holder_OB_item_GRD_grade" SET "grade_GRD_Grade" = NULL, "Deletable_SU_holder_OB_item_GRD_grade" = true WHERE "SU_ID_holder" = s AND "OB_ID_item" = o;
    n := (SELECT count(*) FROM public."SU_holder_OB_item_GRD_grade" WHERE "SU_ID_holder" = s);
    deleted := (SELECT count(*) FROM public."SU_holder_OB_item_GRD_grade_Deleted" WHERE "SU_ID_holder" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 a tie: null with the deletable column moves its versions to the deletion table', n = 0 AND deleted = 2, n || ' left, ' || deleted || ' moved');

    -- a static tie with an identifier and a value
    INSERT INTO public."lOB_part_SU_owner" ("Metadata_OB_part_SU_owner", "OB_ID_part", "SU_ID_owner") VALUES (0, o, s);
    UPDATE public."lOB_part_SU_owner" SET "SU_ID_owner" = NULL WHERE "OB_ID_part" = o;
    n := (SELECT count(*) FROM public."OB_part_SU_owner" WHERE "OB_ID_part" = o);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 a static tie: null without the deletable column changes nothing', n = 1, n || ' rows, expected 1');
    UPDATE public."lOB_part_SU_owner" SET "SU_ID_owner" = NULL, "Deletable_OB_part_SU_owner" = true WHERE "OB_ID_part" = o;
    n := (SELECT count(*) FROM public."OB_part_SU_owner" WHERE "OB_ID_part" = o);
    deleted := (SELECT count(*) FROM public."OB_part_SU_owner_Deleted" WHERE "OB_ID_part" = o);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u08 a static tie: null with the deletable column moves its row to the deletion table', n = 0 AND deleted = 1, n || ' left, ' || deleted || ' moved');
END;
$$;
GO

-- u09 a delete through the latest view removes the shown versions
DO $$
DECLARE
    s integer;
    n integer;
    shown text;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_NAM_Subject_Name", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt") VALUES (0, 'n', 'one', '2020-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    UPDATE public."lSU_Subject" SET "SU_TTL_Subject_Title" = 'two', "SU_TTL_ChangedAt" = '2021-01-01' WHERE "SU_ID" = s;
    DELETE FROM public."lSU_Subject" WHERE "SU_ID" = s;
    shown := (SELECT "SU_TTL_Subject_Title" FROM public."lSU_Subject" WHERE "SU_ID" = s);
    n := (SELECT count(*) FROM public."SU_NAM_Subject_Name" WHERE "SU_NAM_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u09 a delete removes the shown versions', shown = 'one' AND n = 0, 'shown ' || coalesce(shown, 'nothing') || ', ' || n || ' names left');
END;
$$;
GO

-- u10 ties
DO $$
DECLARE
    s1 integer; s2 integer; s3 integer; o integer;
    n integer;
    shown text;
    error text;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s1;
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s2;
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s3;
    INSERT INTO public."OB_Object" ("Metadata_OB") VALUES (0) RETURNING "OB_ID" INTO o;
    -- historized, with identifiers and a value
    INSERT INTO public."lSU_holder_OB_item_GRD_grade" ("Metadata_SU_holder_OB_item_GRD_grade", "SU_holder_OB_item_GRD_grade_ChangedAt", "SU_ID_holder", "OB_ID_item", "GRD_ID_grade") VALUES (0, '2020-01-01', s1, o, 1);
    UPDATE public."lSU_holder_OB_item_GRD_grade" SET "GRD_ID_grade" = 1 WHERE "SU_ID_holder" = s1 AND "OB_ID_item" = o;
    n := (SELECT count(*) FROM public."SU_holder_OB_item_GRD_grade" WHERE "SU_ID_holder" = s1);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u10 a tie: unchanged values state nothing', n = 1, n || ' versions, expected 1');
    UPDATE public."lSU_holder_OB_item_GRD_grade" SET "grade_GRD_Grade" = 'B', "SU_holder_OB_item_GRD_grade_ChangedAt" = '2021-01-01' WHERE "SU_ID_holder" = s1 AND "OB_ID_item" = o;
    shown := (SELECT "grade_GRD_Grade" FROM public."lSU_holder_OB_item_GRD_grade" WHERE "SU_ID_holder" = s1 AND "OB_ID_item" = o);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u10 a tie: a new value by knot value is a new version', shown = 'B', 'shown ' || coalesce(shown, 'nothing'));
    UPDATE public."lSU_holder_OB_item_GRD_grade" SET "GRD_ID_grade" = 2, "SU_holder_OB_item_GRD_grade_ChangedAt" = '2022-01-01' WHERE "SU_ID_holder" = s1 AND "OB_ID_item" = o;
    n := (SELECT count(*) FROM public."SU_holder_OB_item_GRD_grade" WHERE "SU_ID_holder" = s1);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u10 a restatable tie: a restatement is stored', n = 3, n || ' versions, expected 3');
    -- historized, idempotent and not restatable
    INSERT INTO public."lSU_keeper_OB_thing_GRD_rank" ("Metadata_SU_keeper_OB_thing_GRD_rank", "SU_keeper_OB_thing_GRD_rank_ChangedAt", "SU_ID_keeper", "OB_ID_thing", "GRD_ID_rank") VALUES (0, '2020-01-01', s1, o, 1);
    UPDATE public."lSU_keeper_OB_thing_GRD_rank" SET "GRD_ID_rank" = 1, "SU_keeper_OB_thing_GRD_rank_ChangedAt" = '2021-01-01' WHERE "SU_ID_keeper" = s1 AND "OB_ID_thing" = o;
    n := (SELECT count(*) FROM public."SU_keeper_OB_thing_GRD_rank" WHERE "SU_ID_keeper" = s1);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u10 an idempotent tie: a restatement is skipped', n = 1, n || ' versions, expected 1');
    -- static, with an identifier and a value
    INSERT INTO public."lOB_part_SU_owner" ("Metadata_OB_part_SU_owner", "OB_ID_part", "SU_ID_owner") VALUES (0, o, s1);
    error := public.try(format('UPDATE public."lOB_part_SU_owner" SET "SU_ID_owner" = %s WHERE "OB_ID_part" = %s', s1, o));
    error := coalesce(error, public.try(format('INSERT INTO public."lOB_part_SU_owner" ("Metadata_OB_part_SU_owner", "OB_ID_part", "SU_ID_owner") VALUES (0, %s, %s)', o, s1)));
    n := (SELECT count(*) FROM public."OB_part_SU_owner" WHERE "OB_ID_part" = o);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u10 a static tie: the same values state nothing and are not inserted twice', error IS NULL AND n = 1, n || ' rows ' || coalesce(error, ''));
    error := public.try(format('UPDATE public."lOB_part_SU_owner" SET "SU_ID_owner" = %s WHERE "OB_ID_part" = %s', s2, o));
    n := (SELECT "SU_ID_owner" FROM public."OB_part_SU_owner" WHERE "OB_ID_part" = o);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u10 a static tie: another value is a contradiction', error LIKE 'Contradiction in OB_part_SU_owner%' AND n = s1, coalesce(error, 'no error'));
    -- historized, without identifiers
    INSERT INTO public."lSU_partner_SU_with" ("Metadata_SU_partner_SU_with", "SU_partner_SU_with_ChangedAt", "SU_ID_partner", "SU_ID_with") VALUES (0, '2020-01-01', s1, s2);
    UPDATE public."lSU_partner_SU_with" SET "SU_ID_with" = s2 WHERE "SU_ID_partner" = s1;
    n := (SELECT count(*) FROM public."SU_partner_SU_with" WHERE "SU_ID_partner" = s1);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u10 a tie without identifiers: unchanged values state nothing', n = 1, n || ' rows, expected 1');
    INSERT INTO public."SU_partner_SU_with" ("Metadata_SU_partner_SU_with", "SU_partner_SU_with_ChangedAt", "SU_ID_partner", "SU_ID_with") VALUES (0, '2021-01-01', s1, s3);
    n := (SELECT count(*) FROM public."SU_partner_SU_with" WHERE "SU_ID_partner" = s1);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u10 a tie without identifiers: other values are a row of their own', n = 2, n || ' rows, expected 2');
END;
$$;
GO

-- u11 a nexus: an insert through its latest view, and its static attribute
DO $$
DECLARE
    s integer; a integer; b integer;
    e integer;
    n integer;
    made integer;
    matched integer;
    error text;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    error := public.try(format('INSERT INTO public."lEV_Event" ("Metadata_EV", "SU_ID_for", "EV_QTY_Event_Quantity") VALUES (0, %s, 5)', s));
    e := (SELECT max("EV_ID") FROM public."EV_Event" WHERE "SU_ID_for" = s);
    n := (SELECT count(*) FROM public."EV_QTY_Event_Quantity" WHERE "EV_QTY_EV_ID" = e);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u11 a nexus with an attribute through its latest view', error IS NULL AND n = 1, n || ' values ' || coalesce(error, ''));
    error := public.try(format('UPDATE public."lEV_Event" SET "EV_QTY_Event_Quantity" = 5 WHERE "EV_ID" = %s', e));
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u11 a nexus: the same value states nothing', e IS NOT NULL AND error IS NULL, error);
    error := public.try(format('UPDATE public."lEV_Event" SET "EV_QTY_Event_Quantity" = 6 WHERE "EV_ID" = %s', e));
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u11 a nexus: another value is a contradiction', error LIKE 'Contradiction in EV_QTY_Event_Quantity%', coalesce(error, 'no error'));
    -- several new nexus rows in one insert: each keeps its own roles and values
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO a;
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO b;
    error := public.try(format('INSERT INTO public."lEV_Event" ("Metadata_EV", "SU_ID_for", "EV_QTY_Event_Quantity") VALUES (0, %s, 7), (0, %s, 8), (0, %s, 9)', a, b, a));
    made := (SELECT count(*) FROM public."EV_Event" WHERE "SU_ID_for" IN (a, b));
    matched := (SELECT count(*) FROM public."EV_Event" e JOIN public."EV_QTY_Event_Quantity" q ON q."EV_QTY_EV_ID" = e."EV_ID"
        WHERE (e."SU_ID_for" = a AND q."EV_QTY_Event_Quantity" IN (7, 9)) OR (e."SU_ID_for" = b AND q."EV_QTY_Event_Quantity" = 8));
    INSERT INTO public.test_result (test, passed, detail) VALUES ('u11 several new nexus rows in one insert keep their own values', error IS NULL AND made = 3 AND matched = 3, made || ' rows, ' || matched || ' with their own values ' || coalesce(error, ''));
END;
$$;
GO
