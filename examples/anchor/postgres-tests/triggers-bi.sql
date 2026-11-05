-- Trigger tests, bitemporal: what inserts, updates and deletes through the views store.
--
-- Runs against the output for models/postgresql-triggers-bi.xml (golden/postgresql-triggers-bi/_full.sql) in an empty
-- database; tools/postgres-tests.ps1 does both, and makes public.test_result. A check that expects an error catches it in a
-- block of its own. Every group uses rows of its own, and gives its times explicitly where the rule does not depend on now;
-- in particular two statements about the same posit get positing times of their own, since the statements of a DO block get
-- the same now. The rules are in Anchor's docs/ANCHOR.md, "Loading through the latest views".
-- PostgreSQL runs a trigger of this kind for each row, and tells that a column is set in an update from its having another
-- value than before, so a column set to what it was is not set. What SQL Server's tests state by an update that sets a
-- changing time or a positing time to what it was is stated here by an insert into the assembled view (or into the latest
-- view, with the identity). The groups are numbered as SQL Server's (b01 and so on); b19 (the keys of the assembled views,
-- which are indexes there) is not run, since the annex tables have a key of their own.
-- Not run: the deletable attributes, which PostgreSQL's generator does not have yet.

INSERT INTO public."GRD_Grade" ("GRD_ID", "GRD_Grade", "Metadata_GRD") VALUES (1, 'A', 0), (2, 'B', 0), (3, 'C', 0);
GO

-- b01 an insert through the latest view: a posit and an assertion for each value
DO $$
DECLARE
    s integer;
    posits integer;
    assertions integer;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_NAM_Subject_Name", "SU_COD_Subject_Code", "SU_GRD_GRD_ID", "SU_NOT_Subject_Note",
        "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_STA_Subject_State", "SU_STA_ChangedAt", "SU_LBL_Subject_Label", "SU_LBL_ChangedAt",
        "SU_TAG_Subject_Tag", "SU_TAG_ChangedAt", "SU_LVL_GRD_ID", "SU_LVL_ChangedAt", "SU_TXT_Subject_Text", "SU_TXT_ChangedAt",
        "SU_ASR_Subject_Assessment", "SU_ASR_ChangedAt", "SU_ERS_Subject_Erasable", "SU_ERS_ChangedAt")
    VALUES (0, 'name', 'code', 1, 'note', 'title', '2020-01-01', 'state', '2020-01-01', 'label', '2020-01-01',
        'tag', '2020-01-01', 1, '2020-01-01', 'text', '2020-01-01', 'assessment', '2020-01-01', 'erasable', '2020-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    posits := (SELECT count(*) FROM public."SU_NAM_Subject_Name_Posit" WHERE "SU_NAM_SU_ID" = s) + (SELECT count(*) FROM public."SU_COD_Subject_Code_Posit" WHERE "SU_COD_SU_ID" = s)
       + (SELECT count(*) FROM public."SU_GRD_Subject_Grade_Posit" WHERE "SU_GRD_SU_ID" = s) + (SELECT count(*) FROM public."SU_NOT_Subject_Note_Posit" WHERE "SU_NOT_SU_ID" = s)
       + (SELECT count(*) FROM public."SU_TTL_Subject_Title_Posit" WHERE "SU_TTL_SU_ID" = s) + (SELECT count(*) FROM public."SU_STA_Subject_State_Posit" WHERE "SU_STA_SU_ID" = s)
       + (SELECT count(*) FROM public."SU_LBL_Subject_Label_Posit" WHERE "SU_LBL_SU_ID" = s) + (SELECT count(*) FROM public."SU_TAG_Subject_Tag_Posit" WHERE "SU_TAG_SU_ID" = s)
       + (SELECT count(*) FROM public."SU_LVL_Subject_Level_Posit" WHERE "SU_LVL_SU_ID" = s) + (SELECT count(*) FROM public."SU_TXT_Subject_Text_Posit" WHERE "SU_TXT_SU_ID" = s)
       + (SELECT count(*) FROM public."SU_ASR_Subject_Assessment_Posit" WHERE "SU_ASR_SU_ID" = s) + (SELECT count(*) FROM public."SU_ERS_Subject_Erasable_Posit" WHERE "SU_ERS_SU_ID" = s);
    assertions := (SELECT count(*) FROM public."SU_TTL_Subject_Title_Annex" a JOIN public."SU_TTL_Subject_Title_Posit" p ON p."SU_TTL_ID" = a."SU_TTL_ID" WHERE p."SU_TTL_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b01 an insert through the latest view stores a posit for each value', posits = 12 AND assertions = 1,
        posits || ' posits, expected 12; ' || assertions || ' assertions of the title');
END;
$$;
GO

-- b02 an update that leaves every value and reliability as it is states nothing (State is not restatable)
DO $$
DECLARE
    s integer;
    before integer;
    after integer;
    error text;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_NAM_Subject_Name", "SU_GRD_GRD_ID", "SU_NOT_Subject_Note", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt",
        "SU_STA_Subject_State", "SU_STA_ChangedAt", "SU_LVL_GRD_ID", "SU_LVL_ChangedAt", "SU_TXT_Subject_Text", "SU_TXT_ChangedAt")
    VALUES (0, 'name', 1, 'note', 'title', '2020-01-01', 'state', '2020-01-01', 1, '2020-01-01', 'text', '2020-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    before := (SELECT count(*) FROM public."SU_NAM_Subject_Name_Annex") + (SELECT count(*) FROM public."SU_GRD_Subject_Grade_Annex") + (SELECT count(*) FROM public."SU_NOT_Subject_Note_Annex")
       + (SELECT count(*) FROM public."SU_TTL_Subject_Title_Annex") + (SELECT count(*) FROM public."SU_STA_Subject_State_Annex") + (SELECT count(*) FROM public."SU_LVL_Subject_Level_Annex")
       + (SELECT count(*) FROM public."SU_TXT_Subject_Text_Annex");
    BEGIN
        UPDATE public."lSU_Subject" SET "SU_NAM_Subject_Name" = "SU_NAM_Subject_Name", "SU_GRD_GRD_ID" = "SU_GRD_GRD_ID", "SU_NOT_Subject_Note" = "SU_NOT_Subject_Note",
            "SU_TTL_Subject_Title" = "SU_TTL_Subject_Title", "SU_STA_Subject_State" = "SU_STA_Subject_State", "SU_LVL_GRD_ID" = "SU_LVL_GRD_ID",
            "SU_TXT_Subject_Text" = "SU_TXT_Subject_Text", "SU_TTL_Reliability" = "SU_TTL_Reliability"
        WHERE "SU_ID" = s;
        UPDATE public."lSU_Subject" SET "SU_GRD_GRD_Grade" = "SU_GRD_GRD_Grade", "Reliability" = 1 WHERE "SU_ID" = s;
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    after := (SELECT count(*) FROM public."SU_NAM_Subject_Name_Annex") + (SELECT count(*) FROM public."SU_GRD_Subject_Grade_Annex") + (SELECT count(*) FROM public."SU_NOT_Subject_Note_Annex")
       + (SELECT count(*) FROM public."SU_TTL_Subject_Title_Annex") + (SELECT count(*) FROM public."SU_STA_Subject_State_Annex") + (SELECT count(*) FROM public."SU_LVL_Subject_Level_Annex")
       + (SELECT count(*) FROM public."SU_TXT_Subject_Text_Annex");
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b02 an update that leaves everything as it is states nothing', error IS NULL AND after = before,
        (after - before) || ' new assertions' || coalesce(' ' || error, ''));
END;
$$;
GO

-- b03 a new value of a historized attribute is a new version from now
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
    n := (SELECT count(*) FROM public."SU_TTL_Subject_Title_Posit" WHERE "SU_TTL_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b03 a new value is a new version from now', n = 2 AND shown = 'second' AND changed > '2025-01-01',
        n || ' posits, shown ' || coalesce(shown, 'nothing') || ' from ' || coalesce(changed::text, 'nothing'));
END;
$$;
GO

-- b04 the same value with a changing time of its own is a restatement, and the settings decide
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
    n := (SELECT count(*) FROM public."SU_TTL_Subject_Title_Posit" WHERE "SU_TTL_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b04 restatable: a restatement is stored', n = 2, n || ' posits, expected 2');
    BEGIN
        UPDATE public."lSU_Subject" SET "SU_STA_Subject_State" = 'x', "SU_STA_ChangedAt" = '2021-01-01' WHERE "SU_ID" = s;
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    n := (SELECT count(*) FROM public."SU_STA_Subject_State_Posit" WHERE "SU_STA_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b04 not restatable: a restatement is an error', error LIKE 'Restatement in SU_STA_Subject_State%' AND n = 1,
        n || ' posits; ' || coalesce(error, 'no error'));
    UPDATE public."lSU_Subject" SET "SU_LBL_Subject_Label" = 'x', "SU_LBL_ChangedAt" = '2021-01-01' WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_LBL_Subject_Label_Posit" WHERE "SU_LBL_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b04 not restatable, idempotent: a restatement is skipped', n = 1, n || ' posits, expected 1');
    UPDATE public."lSU_Subject" SET "SU_TAG_Subject_Tag" = 'x', "SU_TAG_ChangedAt" = '2021-01-01' WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_TAG_Subject_Tag_Posit" WHERE "SU_TAG_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b04 restatable, idempotent: a restatement is skipped', n = 1, n || ' posits, expected 1');
    UPDATE public."lSU_Subject" SET "SU_LVL_GRD_ID" = 1, "SU_LVL_ChangedAt" = '2021-01-01' WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_LVL_Subject_Level_Posit" WHERE "SU_LVL_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b04 knotted, restatable: a restatement is stored', n = 2, n || ' posits, expected 2');
    UPDATE public."lSU_Subject" SET "SU_TXT_Subject_Text" = 'x', "SU_TXT_ChangedAt" = '2021-01-01' WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_TXT_Subject_Text_Posit" WHERE "SU_TXT_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b04 with a checksum, restatable: a restatement is stored', n = 2, n || ' posits, expected 2');
END;
$$;
GO

-- b05 another static value is a correction; the same states nothing
DO $$
DECLARE
    s integer;
    before integer;
    after integer;
    name text;
    code text;
    grade smallint;
    note text;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_NAM_Subject_Name", "SU_NAM_PositedAt", "SU_COD_Subject_Code", "SU_COD_PositedAt", "SU_GRD_GRD_ID", "SU_GRD_PositedAt", "SU_NOT_Subject_Note", "SU_NOT_PositedAt")
    VALUES (0, 'n1', '2024-01-01', 'c1', '2024-01-01', 1, '2024-01-01', 'note one', '2024-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    before := (SELECT count(*) FROM public."SU_NAM_Subject_Name_Annex") + (SELECT count(*) FROM public."SU_COD_Subject_Code_Annex") + (SELECT count(*) FROM public."SU_GRD_Subject_Grade_Annex") + (SELECT count(*) FROM public."SU_NOT_Subject_Note_Annex");
    UPDATE public."lSU_Subject" SET "SU_NAM_Subject_Name" = 'n1', "SU_COD_Subject_Code" = 'c1', "SU_GRD_GRD_Grade" = 'A', "SU_NOT_Subject_Note" = 'note one' WHERE "SU_ID" = s;
    after := (SELECT count(*) FROM public."SU_NAM_Subject_Name_Annex") + (SELECT count(*) FROM public."SU_COD_Subject_Code_Annex") + (SELECT count(*) FROM public."SU_GRD_Subject_Grade_Annex") + (SELECT count(*) FROM public."SU_NOT_Subject_Note_Annex");
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b05 the same static value states nothing', after = before, (after - before) || ' new assertions');
    UPDATE public."lSU_Subject" SET "SU_NAM_Subject_Name" = 'n2', "SU_COD_Subject_Code" = 'c2', "SU_GRD_GRD_Grade" = 'B', "SU_NOT_Subject_Note" = 'note two',
        "SU_NAM_PositedAt" = '2024-02-01', "SU_COD_PositedAt" = '2024-02-01', "SU_GRD_PositedAt" = '2024-02-01', "SU_NOT_PositedAt" = '2024-02-01' WHERE "SU_ID" = s;
    SELECT "SU_NAM_Subject_Name", "SU_COD_Subject_Code", "SU_GRD_GRD_ID", "SU_NOT_Subject_Note" INTO name, code, grade, note FROM public."lSU_Subject" WHERE "SU_ID" = s;
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b05 another static value is a correction', name = 'n2' AND code = 'c2' AND grade = 2 AND note = 'note two',
        'shown ' || coalesce(name, 'nothing') || ', ' || coalesce(code, 'nothing') || ', ' || coalesce(grade::text, 'nothing') || ', ' || coalesce(note, 'nothing'));
END;
$$;
GO

-- b06 the shown value asserted again at a positing time of its own: stored when assertive, skipped when not
DO $$
DECLARE
    s integer;
    title integer;
    assessment integer;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt", "SU_ASR_Subject_Assessment", "SU_ASR_ChangedAt", "SU_ASR_PositedAt")
    VALUES (0, 't', '2020-01-01', '2024-01-01', 'a', '2020-01-01', '2024-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    UPDATE public."lSU_Subject" SET "SU_TTL_Subject_Title" = 't', "SU_TTL_PositedAt" = '2024-06-01', "SU_ASR_Subject_Assessment" = 'a', "SU_ASR_PositedAt" = '2024-06-01' WHERE "SU_ID" = s;
    title := (SELECT count(*) FROM public."SU_TTL_Subject_Title_Annex" a JOIN public."SU_TTL_Subject_Title_Posit" p ON p."SU_TTL_ID" = a."SU_TTL_ID" WHERE p."SU_TTL_SU_ID" = s);
    assessment := (SELECT count(*) FROM public."SU_ASR_Subject_Assessment_Annex" a JOIN public."SU_ASR_Subject_Assessment_Posit" p ON p."SU_ASR_ID" = a."SU_ASR_ID" WHERE p."SU_ASR_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b06 assertive: a re-assertion is stored', title = 2, title || ' assertions, expected 2');
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b06 not assertive: a re-assertion is skipped', assessment = 1, assessment || ' assertions, expected 1');
END;
$$;
GO

-- b07 not assertive: A, then B, then A again at the same changing time shows A (the last A used to be lost)
DO $$
DECLARE
    s integer;
    shown text;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_ASR_Subject_Assessment", "SU_ASR_ChangedAt", "SU_ASR_PositedAt") VALUES (0, 'A', '2020-01-01', '2024-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    INSERT INTO public."SU_ASR_Subject_Assessment" ("Metadata_SU_ASR", "SU_ASR_SU_ID", "SU_ASR_Subject_Assessment", "SU_ASR_ChangedAt", "SU_ASR_PositedAt", "SU_ASR_Reliability")
    VALUES (0, s, 'B', '2020-01-01', '2024-02-01', 1);
    shown := (SELECT "SU_ASR_Subject_Assessment" FROM public."lSU_Subject" WHERE "SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b07 a value at the same changing time corrects the shown one', shown = 'B', 'shown ' || coalesce(shown, 'nothing'));
    INSERT INTO public."SU_ASR_Subject_Assessment" ("Metadata_SU_ASR", "SU_ASR_SU_ID", "SU_ASR_Subject_Assessment", "SU_ASR_ChangedAt", "SU_ASR_PositedAt", "SU_ASR_Reliability")
    VALUES (0, s, 'A', '2020-01-01', '2024-03-01', 1);
    shown := (SELECT "SU_ASR_Subject_Assessment" FROM public."lSU_Subject" WHERE "SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b07 not assertive: switching back to an earlier value is stored', shown = 'A', 'shown ' || coalesce(shown, 'nothing') || ', expected A');
END;
$$;
GO

-- b08 a reliability of 0 retracts the shown version, through the attribute's own column and through the Reliability
--     column; an unchanged reliability states nothing
DO $$
DECLARE
    s integer;
    t integer;
    shown text;
    before integer;
    after integer;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt") VALUES (0, 'x', '2020-01-01', '2024-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    UPDATE public."lSU_Subject" SET "SU_TTL_Subject_Title" = 'y', "SU_TTL_ChangedAt" = '2021-01-01', "SU_TTL_PositedAt" = '2024-02-01' WHERE "SU_ID" = s;
    before := (SELECT count(*) FROM public."SU_TTL_Subject_Title_Annex");
    UPDATE public."lSU_Subject" SET "Reliability" = 1 WHERE "SU_ID" = s;
    after := (SELECT count(*) FROM public."SU_TTL_Subject_Title_Annex");
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b08 an unchanged reliability states nothing', after = before, (after - before) || ' new assertions');
    UPDATE public."lSU_Subject" SET "SU_TTL_Reliability" = 0, "SU_TTL_PositedAt" = '2024-03-01' WHERE "SU_ID" = s;
    shown := (SELECT "SU_TTL_Subject_Title" FROM public."lSU_Subject" WHERE "SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b08 reliability 0 in the attribute''s own column retracts the shown version', shown = 'x', 'shown ' || coalesce(shown, 'nothing') || ', expected x');
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_STA_Subject_State", "SU_STA_ChangedAt", "SU_STA_PositedAt") VALUES (0, 's', '2020-01-01', '2024-01-01');
    SELECT max("SU_ID") INTO t FROM public."SU_Subject";
    UPDATE public."lSU_Subject" SET "Reliability" = 0, "SU_STA_PositedAt" = '2024-02-01' WHERE "SU_ID" = t;
    shown := (SELECT "SU_STA_Subject_State" FROM public."lSU_Subject" WHERE "SU_ID" = t);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b08 reliability 0 in the Reliability column retracts the shown version', shown IS NULL, 'shown ' || coalesce(shown, 'nothing'));
END;
$$;
GO

-- b09 null retracts the shown version; a value after that is a new version
DO $$
DECLARE
    s integer;
    shown text;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt") VALUES (0, 'x', '2020-01-01', '2024-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    UPDATE public."lSU_Subject" SET "SU_TTL_Subject_Title" = NULL, "SU_TTL_PositedAt" = '2024-02-01' WHERE "SU_ID" = s;
    shown := (SELECT "SU_TTL_Subject_Title" FROM public."lSU_Subject" WHERE "SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b09 null retracts the shown version', shown IS NULL, 'shown ' || coalesce(shown, 'nothing'));
    UPDATE public."lSU_Subject" SET "SU_TTL_Subject_Title" = 'y' WHERE "SU_ID" = s;
    shown := (SELECT "SU_TTL_Subject_Title" FROM public."lSU_Subject" WHERE "SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b09 a value after a retraction is stated', shown = 'y', 'shown ' || coalesce(shown, 'nothing'));
END;
$$;
GO

-- b10 a delete retracts each shown posit once, also one asserted twice (that used to collide on the annex key)
DO $$
DECLARE
    s integer;
    title text;
    name text;
    error text;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_NAM_Subject_Name", "SU_NAM_PositedAt", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt") VALUES (0, 'n', '2024-01-01', 't', '2020-01-01', '2024-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    UPDATE public."lSU_Subject" SET "SU_TTL_Subject_Title" = 't', "SU_TTL_PositedAt" = '2024-06-01' WHERE "SU_ID" = s;
    BEGIN
        DELETE FROM public."lSU_Subject" WHERE "SU_ID" = s;
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    SELECT "SU_TTL_Subject_Title", "SU_NAM_Subject_Name" INTO title, name FROM public."lSU_Subject" WHERE "SU_ID" = s;
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b10 a delete retracts the shown posits', error IS NULL AND title IS NULL AND name IS NULL,
        'shown ' || coalesce(title, 'nothing') || ' and ' || coalesce(name, 'nothing') || coalesce(' ' || error, ''));
END;
$$;
GO

-- b11 inserts straight into the assembled views: the identical is ignored
DO $$
DECLARE
    s integer;
    n integer;
    error text;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    BEGIN
        INSERT INTO public."SU_TTL_Subject_Title" ("Metadata_SU_TTL", "SU_TTL_SU_ID", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt", "SU_TTL_Reliability") VALUES (0, s, 't', '2020-01-01', '2024-01-01', 1);
        INSERT INTO public."SU_TTL_Subject_Title" ("Metadata_SU_TTL", "SU_TTL_SU_ID", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt", "SU_TTL_Reliability") VALUES (0, s, 't', '2020-01-01', '2024-01-01', 1);
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    n := (SELECT count(*) FROM public."SU_TTL_Subject_Title_Annex" a JOIN public."SU_TTL_Subject_Title_Posit" p ON p."SU_TTL_ID" = a."SU_TTL_ID" WHERE p."SU_TTL_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b11 the identical inserted again is ignored', error IS NULL AND n = 1, n || ' assertions' || coalesce(' ' || error, ''));
END;
$$;
GO

-- b12 idempotent, out of order: an earlier version with the same value as the next one keeps the earlier start
DO $$
DECLARE
    s integer;
    changed timestamp;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    INSERT INTO public."SU_LBL_Subject_Label" ("Metadata_SU_LBL", "SU_LBL_SU_ID", "SU_LBL_Subject_Label", "SU_LBL_ChangedAt", "SU_LBL_PositedAt", "SU_LBL_Reliability") VALUES (0, s, 'x', '2021-01-01', '2024-01-01', 1);
    INSERT INTO public."SU_LBL_Subject_Label" ("Metadata_SU_LBL", "SU_LBL_SU_ID", "SU_LBL_Subject_Label", "SU_LBL_ChangedAt", "SU_LBL_PositedAt", "SU_LBL_Reliability") VALUES (0, s, 'x', '2020-01-01', '2024-02-01', 1);
    changed := (SELECT "SU_LBL_ChangedAt" FROM public."lSU_Subject" WHERE "SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b12 idempotent: the value counts from the earlier time', changed = '2020-01-01', 'shown from ' || coalesce(changed::text, 'nothing'));
END;
$$;
GO

-- b13 ties
DO $$
DECLARE
    s1 integer;
    s2 integer;
    o integer;
    n integer;
    shown text;
    owner integer;
    error text;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s1;
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s2;
    INSERT INTO public."OB_Object" ("Metadata_OB") VALUES (0) RETURNING "OB_ID" INTO o;
    -- historized, with identifiers and a value
    INSERT INTO public."lSU_holder_OB_item_GRD_grade" ("Metadata_SU_holder_OB_item_GRD_grade", "SU_holder_OB_item_GRD_grade_ChangedAt", "SU_holder_OB_item_GRD_grade_PositedAt", "SU_ID_holder", "OB_ID_item", "GRD_ID_grade")
    VALUES (0, '2020-01-01', '2024-01-01', s1, o, 1);
    UPDATE public."lSU_holder_OB_item_GRD_grade" SET "GRD_ID_grade" = 1 WHERE "SU_ID_holder" = s1 AND "OB_ID_item" = o;
    n := (SELECT count(*) FROM public."SU_holder_OB_item_GRD_grade_Annex" a JOIN public."SU_holder_OB_item_GRD_grade_Posit" p ON p."SU_holder_OB_item_GRD_grade_ID" = a."SU_holder_OB_item_GRD_grade_ID" WHERE p."SU_ID_holder" = s1 AND p."OB_ID_item" = o);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b13 a tie: unchanged values state nothing', n = 1, n || ' assertions, expected 1');
    UPDATE public."lSU_holder_OB_item_GRD_grade" SET "grade_GRD_Grade" = 'B', "SU_holder_OB_item_GRD_grade_ChangedAt" = '2021-01-01', "SU_holder_OB_item_GRD_grade_PositedAt" = '2024-02-01' WHERE "SU_ID_holder" = s1 AND "OB_ID_item" = o;
    shown := (SELECT "grade_GRD_Grade" FROM public."lSU_holder_OB_item_GRD_grade" WHERE "SU_ID_holder" = s1 AND "OB_ID_item" = o);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b13 a tie: a new value by knot value is a new version', shown = 'B', 'shown ' || coalesce(shown, 'nothing'));
    BEGIN
        UPDATE public."lSU_holder_OB_item_GRD_grade" SET "GRD_ID_grade" = NULL, "SU_holder_OB_item_GRD_grade_PositedAt" = '2024-03-01' WHERE "SU_ID_holder" = s1 AND "OB_ID_item" = o;
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    shown := (SELECT "grade_GRD_Grade" FROM public."lSU_holder_OB_item_GRD_grade" WHERE "SU_ID_holder" = s1 AND "OB_ID_item" = o);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b13 a tie: null retracts the shown version', error IS NULL AND shown = 'A', 'shown ' || coalesce(shown, 'nothing') || ', expected A' || coalesce(' ' || error, ''));
    UPDATE public."lSU_holder_OB_item_GRD_grade" SET "SU_holder_OB_item_GRD_grade_Reliability" = 0 WHERE "SU_ID_holder" = s1 AND "OB_ID_item" = o;
    n := (SELECT count(*) FROM public."lSU_holder_OB_item_GRD_grade" WHERE "SU_ID_holder" = s1 AND "OB_ID_item" = o);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b13 a tie: reliability 0 retracts the shown version', n = 0, n || ' shown, expected 0');
    -- historized, not assertive
    INSERT INTO public."lSU_keeper_OB_thing_GRD_rank" ("Metadata_SU_keeper_OB_thing_GRD_rank", "SU_keeper_OB_thing_GRD_rank_ChangedAt", "SU_keeper_OB_thing_GRD_rank_PositedAt", "SU_ID_keeper", "OB_ID_thing", "GRD_ID_rank")
    VALUES (0, '2020-01-01', '2024-01-01', s1, o, 1);
    UPDATE public."lSU_keeper_OB_thing_GRD_rank" SET "GRD_ID_rank" = 1, "SU_keeper_OB_thing_GRD_rank_PositedAt" = '2024-06-01' WHERE "SU_ID_keeper" = s1 AND "OB_ID_thing" = o;
    n := (SELECT count(*) FROM public."SU_keeper_OB_thing_GRD_rank_Annex" a JOIN public."SU_keeper_OB_thing_GRD_rank_Posit" p ON p."SU_keeper_OB_thing_GRD_rank_ID" = a."SU_keeper_OB_thing_GRD_rank_ID" WHERE p."SU_ID_keeper" = s1 AND p."OB_ID_thing" = o);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b13 a tie that is not assertive: a re-assertion is skipped', n = 1, n || ' assertions, expected 1');
    -- static, with an identifier and a value
    INSERT INTO public."lOB_part_SU_owner" ("Metadata_OB_part_SU_owner", "OB_part_SU_owner_PositedAt", "OB_ID_part", "SU_ID_owner") VALUES (0, '2024-01-01', o, s1);
    UPDATE public."lOB_part_SU_owner" SET "SU_ID_owner" = s2 WHERE "OB_ID_part" = o;
    owner := (SELECT "SU_ID_owner" FROM public."lOB_part_SU_owner" WHERE "OB_ID_part" = o);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b13 a static tie: another value is a correction', owner = s2, 'shown owner ' || coalesce(owner::text, 'nothing'));
    -- historized, without identifiers
    INSERT INTO public."lSU_partner_SU_with" ("Metadata_SU_partner_SU_with", "SU_partner_SU_with_ChangedAt", "SU_ID_partner", "SU_ID_with") VALUES (0, '2020-01-01', s1, s2);
    UPDATE public."lSU_partner_SU_with" SET "SU_ID_with" = s2 WHERE "SU_ID_partner" = s1;
    n := (SELECT count(*) FROM public."SU_partner_SU_with_Annex" a JOIN public."SU_partner_SU_with_Posit" p ON p."SU_partner_SU_with_ID" = a."SU_partner_SU_with_ID" WHERE p."SU_ID_partner" = s1);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b13 a tie without identifiers: unchanged values state nothing', n = 1, n || ' assertions, expected 1');
END;
$$;
GO

-- b14 a nexus with an attribute, through its latest view
DO $$
DECLARE
    s integer;
    e integer;
    n integer;
    a integer;
    b integer;
    made integer;
    matched integer;
    error text;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    BEGIN
        INSERT INTO public."lEV_Event" ("Metadata_EV", "SU_ID_for", "EV_QTY_Event_Quantity") VALUES (0, s, 5);
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    e := (SELECT max("EV_ID") FROM public."EV_Event" WHERE "SU_ID_for" = s);
    n := (SELECT count(*) FROM public."EV_QTY_Event_Quantity_Posit" WHERE "EV_QTY_EV_ID" = e);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b14 a nexus with an attribute through its latest view', error IS NULL AND n = 1, n || ' values' || coalesce(' ' || error, ''));
    -- several new nexus rows in one insert: each keeps its own roles and values
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO a;
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO b;
    error := NULL;
    BEGIN
        INSERT INTO public."lEV_Event" ("Metadata_EV", "SU_ID_for", "EV_QTY_Event_Quantity") VALUES (0, a, 7), (0, b, 8), (0, a, 9);
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    made := (SELECT count(*) FROM public."EV_Event" WHERE "SU_ID_for" IN (a, b));
    matched := (SELECT count(*) FROM public."EV_Event" e JOIN public."EV_QTY_Event_Quantity_Posit" q ON q."EV_QTY_EV_ID" = e."EV_ID"
        WHERE (e."SU_ID_for" = a AND q."EV_QTY_Event_Quantity" IN (7, 9)) OR (e."SU_ID_for" = b AND q."EV_QTY_Event_Quantity" = 8));
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b14 several new nexus rows in one insert keep their own values', error IS NULL AND made = 3 AND matched = 3,
        made || ' rows, ' || matched || ' with their own values' || coalesce(' ' || error, ''));
END;
$$;
GO

-- b15 a posit asserted again at a positing time that already has an assertion of it: the same reliability states
--     nothing, another one is a contradiction
DO $$
DECLARE
    s integer;
    o integer;
    n integer;
    shown text;
    error text;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt") VALUES (0, 'x', '2020-01-01', '2024-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    BEGIN
        INSERT INTO public."SU_TTL_Subject_Title" ("Metadata_SU_TTL", "SU_TTL_SU_ID", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt", "SU_TTL_Reliability") VALUES (0, s, 'x', '2020-01-01', '2024-01-01', 1);
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    n := (SELECT count(*) FROM public."SU_TTL_Subject_Title_Annex" a JOIN public."SU_TTL_Subject_Title_Posit" p ON p."SU_TTL_ID" = a."SU_TTL_ID" WHERE p."SU_TTL_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b15 the same reliability at a positing time that is taken states nothing', error IS NULL AND n = 1, n || ' assertions' || coalesce(' ' || error, ''));
    error := NULL;
    BEGIN
        INSERT INTO public."SU_TTL_Subject_Title" ("Metadata_SU_TTL", "SU_TTL_SU_ID", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt", "SU_TTL_Reliability") VALUES (0, s, 'x', '2020-01-01', '2024-01-01', 0);
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    shown := (SELECT "SU_TTL_Subject_Title" FROM public."lSU_Subject" WHERE "SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b15 another reliability at a positing time that is taken is a contradiction', error LIKE 'Contradiction in SU_TTL_Subject_Title%' AND shown = 'x',
        'shown ' || coalesce(shown, 'nothing') || '; ' || coalesce(error, 'no error'));
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    INSERT INTO public."OB_Object" ("Metadata_OB") VALUES (0) RETURNING "OB_ID" INTO o;
    INSERT INTO public."lSU_holder_OB_item_GRD_grade" ("Metadata_SU_holder_OB_item_GRD_grade", "SU_holder_OB_item_GRD_grade_ChangedAt", "SU_holder_OB_item_GRD_grade_PositedAt", "SU_ID_holder", "OB_ID_item", "GRD_ID_grade")
    VALUES (0, '2020-01-01', '2024-01-01', s, o, 1);
    error := NULL;
    BEGIN
        INSERT INTO public."SU_holder_OB_item_GRD_grade" ("Metadata_SU_holder_OB_item_GRD_grade", "SU_ID_holder", "OB_ID_item", "GRD_ID_grade", "SU_holder_OB_item_GRD_grade_ChangedAt", "SU_holder_OB_item_GRD_grade_PositedAt", "SU_holder_OB_item_GRD_grade_Reliability")
        VALUES (0, s, o, 1, '2020-01-01', '2024-01-01', 0);
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    n := (SELECT count(*) FROM public."lSU_holder_OB_item_GRD_grade" WHERE "SU_ID_holder" = s AND "OB_ID_item" = o);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b15 a tie: another reliability at a positing time that is taken is a contradiction', error LIKE 'Contradiction in SU_holder_OB_item_GRD_grade%' AND n = 1,
        n || ' shown; ' || coalesce(error, 'no error'));
END;
$$;
GO

-- b16 another value at the same changing time is a correction, which retracts what it corrects at its own positing
--     time, so retracting the correction leaves nothing of the corrected value in effect (it used to come back)
DO $$
DECLARE
    s integer;
    n integer;
    shown text;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_NAM_Subject_Name", "SU_NAM_PositedAt") VALUES (0, 'n1', '2024-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    UPDATE public."lSU_Subject" SET "SU_NAM_Subject_Name" = 'n2', "SU_NAM_PositedAt" = '2024-02-01' WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_NAM_Subject_Name_Annex" a JOIN public."SU_NAM_Subject_Name_Posit" p ON p."SU_NAM_ID" = a."SU_NAM_ID"
        WHERE p."SU_NAM_SU_ID" = s AND p."SU_NAM_Subject_Name" = 'n1' AND a."SU_NAM_PositedAt" = '2024-02-01' AND a."SU_NAM_Reliability" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b16 a static correction retracts the corrected posit at its positing time', n = 1, n || ' retractions of n1, expected 1');
    UPDATE public."lSU_Subject" SET "SU_NAM_Reliability" = 0, "SU_NAM_PositedAt" = '2024-03-01' WHERE "SU_ID" = s;
    shown := (SELECT "SU_NAM_Subject_Name" FROM public."lSU_Subject" WHERE "SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b16 retracting a static correction leaves nothing in effect', shown IS NULL, 'shown ' || coalesce(shown, 'nothing'));
    -- historized: a value at the changing time of the shown version corrects it, and only it
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt") VALUES (0, 'early', '2019-01-01', '2024-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    UPDATE public."lSU_Subject" SET "SU_TTL_Subject_Title" = 't1', "SU_TTL_ChangedAt" = '2020-01-01', "SU_TTL_PositedAt" = '2024-02-01' WHERE "SU_ID" = s;
    INSERT INTO public."SU_TTL_Subject_Title" ("Metadata_SU_TTL", "SU_TTL_SU_ID", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt", "SU_TTL_Reliability") VALUES (0, s, 't2', '2020-01-01', '2024-03-01', 1);
    n := (SELECT count(*) FROM public."SU_TTL_Subject_Title_Annex" a JOIN public."SU_TTL_Subject_Title_Posit" p ON p."SU_TTL_ID" = a."SU_TTL_ID"
        WHERE p."SU_TTL_SU_ID" = s AND a."SU_TTL_Reliability" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b16 a historized correction retracts the version it corrects and no other', n = 1, n || ' retractions, expected 1');
    UPDATE public."lSU_Subject" SET "SU_TTL_Reliability" = 0, "SU_TTL_PositedAt" = '2024-04-01' WHERE "SU_ID" = s;
    shown := (SELECT "SU_TTL_Subject_Title" FROM public."lSU_Subject" WHERE "SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b16 retracting a historized correction shows the version before it', shown = 'early', 'shown ' || coalesce(shown, 'nothing') || ', expected early');
    -- knotted, by the value of the knot, and with a checksum
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_GRD_GRD_ID", "SU_GRD_PositedAt", "SU_NOT_Subject_Note", "SU_NOT_PositedAt") VALUES (0, 1, '2024-01-01', 'note one', '2024-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    UPDATE public."lSU_Subject" SET "SU_GRD_GRD_Grade" = 'B', "SU_GRD_PositedAt" = '2024-02-01', "SU_NOT_Subject_Note" = 'note two', "SU_NOT_PositedAt" = '2024-02-01' WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_GRD_Subject_Grade_Annex" a JOIN public."SU_GRD_Subject_Grade_Posit" p ON p."SU_GRD_ID" = a."SU_GRD_ID"
            WHERE p."SU_GRD_SU_ID" = s AND p."SU_GRD_GRD_ID" = 1 AND a."SU_GRD_PositedAt" = '2024-02-01' AND a."SU_GRD_Reliability" = 0)
        + (SELECT count(*) FROM public."SU_NOT_Subject_Note_Annex" a JOIN public."SU_NOT_Subject_Note_Posit" p ON p."SU_NOT_ID" = a."SU_NOT_ID"
            WHERE p."SU_NOT_SU_ID" = s AND p."SU_NOT_Subject_Note" = 'note one' AND a."SU_NOT_PositedAt" = '2024-02-01' AND a."SU_NOT_Reliability" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b16 a correction of a knotted attribute and of one with a checksum retracts the corrected posits', n = 2, n || ' retractions, expected 2');
END;
$$;
GO

-- b17 a static tie: other values are a correction, which retracts what it corrects
DO $$
DECLARE
    s1 integer;
    s2 integer;
    o integer;
    n integer;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s1;
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s2;
    INSERT INTO public."OB_Object" ("Metadata_OB") VALUES (0) RETURNING "OB_ID" INTO o;
    INSERT INTO public."lOB_part_SU_owner" ("Metadata_OB_part_SU_owner", "OB_part_SU_owner_PositedAt", "OB_ID_part", "SU_ID_owner") VALUES (0, '2024-01-01', o, s1);
    UPDATE public."lOB_part_SU_owner" SET "SU_ID_owner" = s2, "OB_part_SU_owner_PositedAt" = '2024-02-01' WHERE "OB_ID_part" = o;
    n := (SELECT count(*) FROM public."OB_part_SU_owner_Annex" a JOIN public."OB_part_SU_owner_Posit" p ON p."OB_part_SU_owner_ID" = a."OB_part_SU_owner_ID"
        WHERE p."OB_ID_part" = o AND p."SU_ID_owner" = s1 AND a."OB_part_SU_owner_PositedAt" = '2024-02-01' AND a."OB_part_SU_owner_Reliability" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b17 a static tie correction retracts the corrected posit at its positing time', n = 1, n || ' retractions, expected 1');
    UPDATE public."lOB_part_SU_owner" SET "OB_part_SU_owner_Reliability" = 0, "OB_part_SU_owner_PositedAt" = '2024-03-01' WHERE "OB_ID_part" = o;
    n := (SELECT count(*) FROM public."lOB_part_SU_owner" WHERE "OB_ID_part" = o);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b17 retracting a static tie correction leaves nothing in effect', n = 0, n || ' shown, expected 0');
END;
$$;
GO

-- b18 a nexus is updated and deleted through its latest view, as an anchor is, and its roles are not updatable
DO $$
DECLARE
    s integer;
    s2 integer;
    e integer;
    n integer;
    quantity integer;
    for_ integer;
    error text;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s2;
    INSERT INTO public."lEV_Event" ("Metadata_EV", "SU_ID_for", "EV_QTY_Event_Quantity", "EV_QTY_PositedAt") VALUES (0, s, 5, '2024-01-01');
    e := (SELECT max("EV_ID") FROM public."EV_Event" WHERE "SU_ID_for" = s);
    BEGIN
        UPDATE public."lEV_Event" SET "EV_QTY_Event_Quantity" = 6, "EV_QTY_PositedAt" = '2024-02-01' WHERE "EV_ID" = e;
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    quantity := (SELECT "EV_QTY_Event_Quantity" FROM public."lEV_Event" WHERE "EV_ID" = e);
    n := (SELECT count(*) FROM public."EV_QTY_Event_Quantity_Annex" a JOIN public."EV_QTY_Event_Quantity_Posit" p ON p."EV_QTY_ID" = a."EV_QTY_ID"
        WHERE p."EV_QTY_EV_ID" = e AND p."EV_QTY_Event_Quantity" = 5 AND a."EV_QTY_PositedAt" = '2024-02-01' AND a."EV_QTY_Reliability" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b18 an update of a nexus attribute through the latest view is a correction', error IS NULL AND quantity = 6 AND n = 1,
        'shown ' || coalesce(quantity::text, 'nothing') || ', ' || n || ' retractions of 5' || coalesce(' ' || error, ''));
    error := NULL;
    BEGIN
        UPDATE public."lEV_Event" SET "SU_ID_for" = s2 WHERE "EV_ID" = e;
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    for_ := (SELECT "SU_ID_for" FROM public."EV_Event" WHERE "EV_ID" = e);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b18 a role of a nexus is not updatable', error LIKE 'The role column SU_ID_for is not updatable%' AND for_ = s,
        'for ' || coalesce(for_::text, 'nothing') || '; ' || coalesce(error, 'no error'));
    error := NULL;
    BEGIN
        DELETE FROM public."lEV_Event" WHERE "EV_ID" = e;
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    quantity := (SELECT "EV_QTY_Event_Quantity" FROM public."lEV_Event" WHERE "EV_ID" = e);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b18 a delete through the latest view of a nexus retracts its shown values', error IS NULL AND quantity IS NULL,
        'shown ' || coalesce(quantity::text, 'nothing') || coalesce(' ' || error, ''));
END;
$$;
GO

-- b20 a historized attribute of a nexus: a new value is a new version, which the difference perspective shows, and a
--     restatement is an error when the attribute is not restatable
DO $$
DECLARE
    s integer;
    e integer;
    n integer;
    place text;
    error text;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    INSERT INTO public."lEV_Event" ("Metadata_EV", "SU_ID_for", "EV_PLC_Event_Place", "EV_PLC_ChangedAt", "EV_PLC_PositedAt") VALUES (0, s, 'p1', '2020-01-01', '2024-01-01');
    e := (SELECT max("EV_ID") FROM public."EV_Event" WHERE "SU_ID_for" = s);
    UPDATE public."lEV_Event" SET "EV_PLC_Event_Place" = 'p2', "EV_PLC_ChangedAt" = '2021-01-01', "EV_PLC_PositedAt" = '2024-02-01' WHERE "EV_ID" = e;
    place := (SELECT "EV_PLC_Event_Place" FROM public."lEV_Event" WHERE "EV_ID" = e);
    n := (SELECT count(*) FROM public."dEV_Event"('2019-01-01'::timestamp, '2022-01-01'::timestamp, NULL::text) WHERE "EV_ID" = e);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b20 a new value of a historized nexus attribute is a new version, which the difference perspective shows', place = 'p2' AND n = 2,
        'shown ' || coalesce(place, 'nothing') || ', ' || n || ' differences, expected 2');
    BEGIN
        UPDATE public."lEV_Event" SET "EV_PLC_Event_Place" = 'p2', "EV_PLC_ChangedAt" = '2022-01-01', "EV_PLC_PositedAt" = '2024-03-01' WHERE "EV_ID" = e;
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    n := (SELECT count(*) FROM public."EV_PLC_Event_Place_Posit" WHERE "EV_PLC_EV_ID" = e);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b20 a restatement of a nexus attribute that is not restatable is an error', error LIKE 'Restatement in EV_PLC_Event_Place%' AND n = 2,
        n || ' posits; ' || coalesce(error, 'no error'));
END;
$$;
GO

-- b21 another value at a positing time that already has one is a contradiction; a correction to the value of the version
--     before retracts what it corrects, although an idempotent attribute skips the restatement; and a retraction followed
--     by an assertion at the same positing time is a correction written in two statements
DO $$
DECLARE
    s integer;
    n integer;
    shown text;
    changed timestamp;
    error text;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_NAM_Subject_Name", "SU_NAM_PositedAt") VALUES (0, 'n1', '2024-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    BEGIN
        INSERT INTO public."SU_NAM_Subject_Name" ("Metadata_SU_NAM", "SU_NAM_SU_ID", "SU_NAM_Subject_Name", "SU_NAM_PositedAt", "SU_NAM_Reliability") VALUES (0, s, 'n2', '2024-01-01', 1);
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    n := (SELECT count(*) FROM public."SU_NAM_Subject_Name_Posit" WHERE "SU_NAM_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b21 another value at a positing time that has one is a contradiction', error LIKE 'Contradiction in SU_NAM_Subject_Name%' AND n = 1,
        n || ' posits; ' || coalesce(error, 'no error'));
    -- idempotent: A, then B at a changing time of its own, then A at that time
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_TAG_Subject_Tag", "SU_TAG_ChangedAt", "SU_TAG_PositedAt") VALUES (0, 'A', '2020-01-01', '2024-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    UPDATE public."lSU_Subject" SET "SU_TAG_Subject_Tag" = 'B', "SU_TAG_ChangedAt" = '2021-01-01', "SU_TAG_PositedAt" = '2024-02-01' WHERE "SU_ID" = s;
    INSERT INTO public."SU_TAG_Subject_Tag" ("Metadata_SU_TAG", "SU_TAG_SU_ID", "SU_TAG_Subject_Tag", "SU_TAG_ChangedAt", "SU_TAG_PositedAt", "SU_TAG_Reliability") VALUES (0, s, 'A', '2021-01-01', '2024-03-01', 1);
    SELECT "SU_TAG_Subject_Tag", "SU_TAG_ChangedAt" INTO shown, changed FROM public."lSU_Subject" WHERE "SU_ID" = s;
    n := (SELECT count(*) FROM public."SU_TAG_Subject_Tag_Posit" WHERE "SU_TAG_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b21 idempotent: a correction to the value of the version before retracts the corrected version', shown = 'A' AND changed = '2020-01-01' AND n = 2,
        'shown ' || coalesce(shown, 'nothing') || ' from ' || coalesce(changed::text, 'nothing') || ', ' || n || ' posits, expected A from 2020-01-01 and 2 posits');
    -- a retraction and then an assertion at the same positing time
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_NAM_Subject_Name", "SU_NAM_PositedAt") VALUES (0, 'm1', '2024-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    error := NULL;
    BEGIN
        INSERT INTO public."SU_NAM_Subject_Name" ("Metadata_SU_NAM", "SU_NAM_SU_ID", "SU_NAM_Subject_Name", "SU_NAM_PositedAt", "SU_NAM_Reliability") VALUES (0, s, 'm1', '2024-02-01', 0);
        INSERT INTO public."SU_NAM_Subject_Name" ("Metadata_SU_NAM", "SU_NAM_SU_ID", "SU_NAM_Subject_Name", "SU_NAM_PositedAt", "SU_NAM_Reliability") VALUES (0, s, 'm2', '2024-02-01', 1);
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    shown := (SELECT "SU_NAM_Subject_Name" FROM public."lSU_Subject" WHERE "SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('b21 a retraction and an assertion at one positing time make a correction', error IS NULL AND shown = 'm2',
        'shown ' || coalesce(shown, 'nothing') || coalesce(' ' || error, ''));
END;
$$;
GO
