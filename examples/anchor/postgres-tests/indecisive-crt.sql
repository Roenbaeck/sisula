-- Trigger tests, concurrent-reliance-temporal without decisiveness: corrections and alternatives.
--
-- Runs against the output for models/postgresql-indecisive-crt.xml (golden/postgresql-indecisive-crt/_full.sql), which is
-- models/postgresql-triggers-crt.xml with decisiveness off, in an empty database; tools/postgres-tests.ps1 does both, and
-- makes public.test_result. Without decisiveness a positor may hold several values at once, so an insert of another value
-- adds an alternative and retracts nothing, while an update of the shown value of a static attribute or tie is a correction,
-- which also retracts the shown posit. (PostgreSQL tells that a column is set in an update from its having another value than
-- before, so an update of a historized attribute that states the changing time it has is not told from one that does not
-- state it, and is a new version from now; the first check of i03 is about that.) The checks are written as in
-- triggers-crt.sql, and two statements about the same posit get positing times of their own. Everything is stated by
-- positor 0.
-- The rules are in Anchor's docs/ANCHOR.md, "Loading through the latest views".

INSERT INTO public."GRD_Grade" ("GRD_ID", "GRD_Grade", "Metadata_GRD") VALUES (1, 'A', 0), (2, 'B', 0), (3, 'C', 0);
GO

-- i01 an insert of another static value adds an alternative, which retracts nothing
DO $$
DECLARE
    s integer;
    n integer;
    held integer;
    shown text;
    error text;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    BEGIN
        INSERT INTO public."SU_NAM_Subject_Name" ("Metadata_SU_NAM", "SU_NAM_SU_ID", "SU_NAM_Subject_Name", "SU_NAM_PositedAt", "SU_NAM_Positor", "SU_NAM_Reliability")
        VALUES (0, s, 'n1', '2024-01-01', 0, 0.6), (0, s, 'n2', '2024-02-01', 0, 0.4);
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    n := (SELECT count(*) FROM public."SU_NAM_Subject_Name_Annex" a JOIN public."SU_NAM_Subject_Name_Posit" p ON p."SU_NAM_ID" = a."SU_NAM_ID"
        WHERE p."SU_NAM_SU_ID" = s AND a."SU_NAM_Reliability" = 0);
    held := (SELECT count(*) FROM public."SU_NAM_Subject_Name_Annex" a JOIN public."SU_NAM_Subject_Name_Posit" p ON p."SU_NAM_ID" = a."SU_NAM_ID"
        WHERE p."SU_NAM_SU_ID" = s AND a."SU_NAM_Reliability" > 0);
    shown := (SELECT "SU_NAM_Subject_Name" FROM public."lSU_Subject" WHERE "SU_ID" = s AND "Positor" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i01 another value inserted is an alternative, and the latest one is shown', error IS NULL AND n = 0 AND held = 2 AND shown = 'n2',
        n || ' retractions, ' || held || ' assertions; shown ' || coalesce(shown, 'nothing') || coalesce(' ' || error, ''));
END;
$$;
GO

-- i02 an update of a static value is a correction, which retracts the shown posit and leaves the alternatives
DO $$
DECLARE
    s integer;
    n integer;
    shown text;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_NAM_Subject_Name", "SU_NAM_PositedAt") VALUES (0, 'n1', '2024-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    UPDATE public."lSU_Subject" SET "SU_NAM_Subject_Name" = 'n2', "SU_NAM_PositedAt" = '2024-02-01' WHERE "SU_ID" = s AND "Positor" = 0;
    n := (SELECT count(*) FROM public."SU_NAM_Subject_Name_Annex" a JOIN public."SU_NAM_Subject_Name_Posit" p ON p."SU_NAM_ID" = a."SU_NAM_ID"
        WHERE p."SU_NAM_SU_ID" = s AND p."SU_NAM_Subject_Name" = 'n1' AND a."SU_NAM_PositedAt" = '2024-02-01' AND a."SU_NAM_Reliability" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i02 an update of a static value retracts the shown posit at its positing time', n = 1, n || ' retractions of n1, expected 1');
    UPDATE public."lSU_Subject" SET "SU_NAM_Reliability" = 0, "SU_NAM_PositedAt" = '2024-03-01' WHERE "SU_ID" = s AND "Positor" = 0;
    shown := (SELECT "SU_NAM_Subject_Name" FROM public."lSU_Subject" WHERE "SU_ID" = s AND "Positor" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i02 retracting the correction leaves nothing in effect', shown IS NULL, 'shown ' || coalesce(shown, 'nothing'));
    -- with an alternative: the correction replaces the shown value only
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    INSERT INTO public."SU_NAM_Subject_Name" ("Metadata_SU_NAM", "SU_NAM_SU_ID", "SU_NAM_Subject_Name", "SU_NAM_PositedAt", "SU_NAM_Positor", "SU_NAM_Reliability")
    VALUES (0, s, 'n1', '2024-01-01', 0, 0.6), (0, s, 'n2', '2024-02-01', 0, 0.4);
    UPDATE public."lSU_Subject" SET "SU_NAM_Subject_Name" = 'n3', "SU_NAM_PositedAt" = '2024-03-01' WHERE "SU_ID" = s AND "Positor" = 0;
    n := (SELECT count(*) FROM public."SU_NAM_Subject_Name_Annex" a JOIN public."SU_NAM_Subject_Name_Posit" p ON p."SU_NAM_ID" = a."SU_NAM_ID"
        WHERE p."SU_NAM_SU_ID" = s AND a."SU_NAM_Reliability" = 0);
    shown := (SELECT "SU_NAM_Subject_Name" FROM public."lSU_Subject" WHERE "SU_ID" = s AND "Positor" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i02 a correction retracts the shown value and not the alternative', n = 1 AND shown = 'n3', n || ' retractions; shown ' || coalesce(shown, 'nothing'));
    UPDATE public."lSU_Subject" SET "SU_NAM_Reliability" = 0, "SU_NAM_PositedAt" = '2024-04-01' WHERE "SU_ID" = s AND "Positor" = 0;
    shown := (SELECT "SU_NAM_Subject_Name" FROM public."lSU_Subject" WHERE "SU_ID" = s AND "Positor" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i02 retracting the correction shows the alternative that is still held', shown = 'n1', 'shown ' || coalesce(shown, 'nothing') || ', expected n1');
END;
$$;
GO

-- i03 historized: an insert at the changing time of the shown version is an alternative, which retracts nothing; an update
--     from now is a new version, which retracts nothing either
DO $$
DECLARE
    s integer;
    n integer;
    shown text;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt", "SU_TTL_Reliability") VALUES (0, 't1', '2020-01-01', '2024-01-01', 0.5);
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    INSERT INTO public."SU_TTL_Subject_Title" ("Metadata_SU_TTL", "SU_TTL_SU_ID", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt", "SU_TTL_Positor", "SU_TTL_Reliability")
    VALUES (0, s, 't2', '2020-01-01', '2024-02-01', 0, 0.5);
    n := (SELECT count(*) FROM public."SU_TTL_Subject_Title_Annex" a JOIN public."SU_TTL_Subject_Title_Posit" p ON p."SU_TTL_ID" = a."SU_TTL_ID"
        WHERE p."SU_TTL_SU_ID" = s AND a."SU_TTL_Reliability" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i03 another value at the changing time of the shown version is an alternative', n = 0, n || ' retractions, expected 0');
    UPDATE public."lSU_Subject" SET "SU_TTL_Subject_Title" = 't3', "SU_TTL_PositedAt" = '2024-03-01' WHERE "SU_ID" = s AND "Positor" = 0;
    n := (SELECT count(*) FROM public."SU_TTL_Subject_Title_Annex" a JOIN public."SU_TTL_Subject_Title_Posit" p ON p."SU_TTL_ID" = a."SU_TTL_ID"
        WHERE p."SU_TTL_SU_ID" = s AND a."SU_TTL_Reliability" = 0);
    shown := (SELECT "SU_TTL_Subject_Title" FROM public."lSU_Subject" WHERE "SU_ID" = s AND "Positor" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i03 a new version from now retracts nothing', n = 0 AND shown = 't3', n || ' retractions; shown ' || coalesce(shown, 'nothing'));
END;
$$;
GO

-- i04 a correction of a knotted attribute, by the value of its knot, and of one with a checksum
DO $$
DECLARE
    s integer;
    n integer;
BEGIN
    INSERT INTO public."lSU_Subject" ("Metadata_SU", "SU_GRD_GRD_ID", "SU_GRD_PositedAt", "SU_NOT_Subject_Note", "SU_NOT_PositedAt") VALUES (0, 1, '2024-01-01', 'note one', '2024-01-01');
    SELECT max("SU_ID") INTO s FROM public."SU_Subject";
    UPDATE public."lSU_Subject" SET "SU_GRD_GRD_Grade" = 'B', "SU_GRD_PositedAt" = '2024-02-01', "SU_NOT_Subject_Note" = 'note two', "SU_NOT_PositedAt" = '2024-02-01' WHERE "SU_ID" = s AND "Positor" = 0;
    n := (SELECT count(*) FROM public."SU_GRD_Subject_Grade_Annex" a JOIN public."SU_GRD_Subject_Grade_Posit" p ON p."SU_GRD_ID" = a."SU_GRD_ID"
            WHERE p."SU_GRD_SU_ID" = s AND p."SU_GRD_GRD_ID" = 1 AND a."SU_GRD_PositedAt" = '2024-02-01' AND a."SU_GRD_Reliability" = 0)
        + (SELECT count(*) FROM public."SU_NOT_Subject_Note_Annex" a JOIN public."SU_NOT_Subject_Note_Posit" p ON p."SU_NOT_ID" = a."SU_NOT_ID"
            WHERE p."SU_NOT_SU_ID" = s AND p."SU_NOT_Subject_Note" = 'note one' AND a."SU_NOT_PositedAt" = '2024-02-01' AND a."SU_NOT_Reliability" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i04 a correction of a knotted attribute and of one with a checksum retracts the shown posits', n = 2, n || ' retractions, expected 2');
END;
$$;
GO

-- i05 a static tie: an update of its other values is a correction, which retracts the shown posit; an insert of other
--     values is an alternative, here at a reliability that leaves room for it
DO $$
DECLARE
    s1 integer;
    s2 integer;
    s3 integer;
    o integer;
    n integer;
    owner integer;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s1;
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s2;
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s3;
    INSERT INTO public."OB_Object" ("Metadata_OB") VALUES (0) RETURNING "OB_ID" INTO o;
    INSERT INTO public."lOB_part_SU_owner" ("Metadata_OB_part_SU_owner", "OB_part_SU_owner_PositedAt", "OB_part_SU_owner_Reliability", "OB_ID_part", "SU_ID_owner") VALUES (0, '2024-01-01', 0.5, o, s1);
    UPDATE public."lOB_part_SU_owner" SET "SU_ID_owner" = s2, "OB_part_SU_owner_PositedAt" = '2024-02-01' WHERE "OB_ID_part" = o AND "Positor" = 0;
    n := (SELECT count(*) FROM public."OB_part_SU_owner_Annex" a JOIN public."OB_part_SU_owner_Posit" p ON p."OB_part_SU_owner_ID" = a."OB_part_SU_owner_ID"
        WHERE p."OB_ID_part" = o AND p."SU_ID_owner" = s1 AND a."OB_part_SU_owner_PositedAt" = '2024-02-01' AND a."OB_part_SU_owner_Reliability" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i05 an update of a static tie retracts the shown posit', n = 1, n || ' retractions, expected 1');
    INSERT INTO public."OB_part_SU_owner" ("Metadata_OB_part_SU_owner", "OB_ID_part", "SU_ID_owner", "OB_part_SU_owner_PositedAt", "OB_part_SU_owner_Positor", "OB_part_SU_owner_Reliability")
    VALUES (0, o, s3, '2024-03-01', 0, 0.5);
    n := (SELECT count(*) FROM public."OB_part_SU_owner_Annex" a JOIN public."OB_part_SU_owner_Posit" p ON p."OB_part_SU_owner_ID" = a."OB_part_SU_owner_ID"
        WHERE p."OB_ID_part" = o AND a."OB_part_SU_owner_Reliability" = 0);
    owner := (SELECT "SU_ID_owner" FROM public."lOB_part_SU_owner" WHERE "OB_ID_part" = o AND "Positor" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i05 an insert of other values of a static tie is an alternative', n = 1 AND owner = s3, n || ' retractions; shown owner ' || coalesce(owner::text, 'nobody'));
END;
$$;
GO

-- i06 an update of a nexus attribute through the latest view is a correction, which retracts the shown posit
DO $$
DECLARE
    s integer;
    e integer;
    n integer;
    quantity integer;
    error text;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    INSERT INTO public."lEV_Event" ("Metadata_EV", "SU_ID_for", "EV_QTY_Event_Quantity", "EV_QTY_PositedAt") VALUES (0, s, 5, '2024-01-01');
    e := (SELECT max("EV_ID") FROM public."EV_Event" WHERE "SU_ID_for" = s);
    BEGIN
        UPDATE public."lEV_Event" SET "EV_QTY_Event_Quantity" = 6, "EV_QTY_PositedAt" = '2024-02-01' WHERE "EV_ID" = e AND "Positor" = 0;
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    quantity := (SELECT "EV_QTY_Event_Quantity" FROM public."lEV_Event" WHERE "EV_ID" = e AND "Positor" = 0);
    n := (SELECT count(*) FROM public."EV_QTY_Event_Quantity_Annex" a JOIN public."EV_QTY_Event_Quantity_Posit" p ON p."EV_QTY_ID" = a."EV_QTY_ID"
        WHERE p."EV_QTY_EV_ID" = e AND p."EV_QTY_Event_Quantity" = 5 AND a."EV_QTY_PositedAt" = '2024-02-01' AND a."EV_QTY_Reliability" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i06 an update of a nexus attribute is a correction', error IS NULL AND quantity = 6 AND n = 1,
        'shown ' || coalesce(quantity::text, 'nothing') || ', ' || n || ' retractions of 5' || coalesce(' ' || error, ''));
END;
$$;
GO

-- i07 what a positor holds may not contradict itself: positive reliabilities count as they are, negative ones as one plus
--     them, and they may not sum up to more than one (non-contradiction in transitional modeling)
DO $$
DECLARE
    s integer;
    n integer;
    error text;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    INSERT INTO public."SU_NAM_Subject_Name" ("Metadata_SU_NAM", "SU_NAM_SU_ID", "SU_NAM_Subject_Name", "SU_NAM_PositedAt", "SU_NAM_Positor", "SU_NAM_Reliability") VALUES (0, s, 'a', '2024-01-01', 0, 0.6);
    BEGIN
        INSERT INTO public."SU_NAM_Subject_Name" ("Metadata_SU_NAM", "SU_NAM_SU_ID", "SU_NAM_Subject_Name", "SU_NAM_PositedAt", "SU_NAM_Positor", "SU_NAM_Reliability") VALUES (0, s, 'b', '2024-02-01', 0, 0.6);
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    n := (SELECT count(*) FROM public."SU_NAM_Subject_Name_Posit" WHERE "SU_NAM_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i07 0.6 for a and 0.6 for b is a contradiction', error LIKE 'Contradiction in SU_NAM_Subject_Name%' AND n = 1, n || ' posits; ' || coalesce(error, 'no error'));
    -- 40 percent not a and 40 percent not b are 60 percent a and 60 percent b
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    INSERT INTO public."SU_NAM_Subject_Name" ("Metadata_SU_NAM", "SU_NAM_SU_ID", "SU_NAM_Subject_Name", "SU_NAM_PositedAt", "SU_NAM_Positor", "SU_NAM_Reliability") VALUES (0, s, 'a', '2024-01-01', 0, -0.4);
    error := NULL;
    BEGIN
        INSERT INTO public."SU_NAM_Subject_Name" ("Metadata_SU_NAM", "SU_NAM_SU_ID", "SU_NAM_Subject_Name", "SU_NAM_PositedAt", "SU_NAM_Positor", "SU_NAM_Reliability") VALUES (0, s, 'b', '2024-02-01', 0, -0.4);
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    n := (SELECT count(*) FROM public."SU_NAM_Subject_Name_Posit" WHERE "SU_NAM_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i07 -0.4 for a and -0.4 for b is a contradiction', error LIKE 'Contradiction in SU_NAM_Subject_Name%' AND n = 1, n || ' posits; ' || coalesce(error, 'no error'));
    -- 0.5 for a, certainly not b, and 0.5 for c sum up to one, and a positor may be certain that many values are not it
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    error := NULL;
    BEGIN
        INSERT INTO public."SU_NAM_Subject_Name" ("Metadata_SU_NAM", "SU_NAM_SU_ID", "SU_NAM_Subject_Name", "SU_NAM_PositedAt", "SU_NAM_Positor", "SU_NAM_Reliability")
        VALUES (0, s, 'a', '2024-01-01', 0, 0.5), (0, s, 'b', '2024-01-01', 0, -1), (0, s, 'c', '2024-01-01', 0, 0.5), (0, s, 'd', '2024-01-01', 0, -1);
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    n := (SELECT count(*) FROM public."SU_NAM_Subject_Name_Posit" WHERE "SU_NAM_SU_ID" = s);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i07 0.5 for a, -1 for b, 0.5 for c and -1 for d is no contradiction', error IS NULL AND n = 4, n || ' posits' || coalesce(' ' || error, ''));
    -- another positor's beliefs are its own
    INSERT INTO public."_Positor" ("Positor") VALUES (1) ON CONFLICT DO NOTHING;
    error := NULL;
    BEGIN
        INSERT INTO public."SU_NAM_Subject_Name" ("Metadata_SU_NAM", "SU_NAM_SU_ID", "SU_NAM_Subject_Name", "SU_NAM_PositedAt", "SU_NAM_Positor", "SU_NAM_Reliability") VALUES (0, s, 'e', '2024-01-01', 1, 1);
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i07 what another positor holds does not count', error IS NULL, coalesce(error, 'no error'));
END;
$$;
GO

-- i08 Red from 2000, then certainly not Green from 2001: nothing is shown from 2001, since the later changing time
--     supersedes the earlier one; Red asserted at 2001 as well is held concurrently with not Green and shown
DO $$
DECLARE
    s integer;
    n integer;
    shown text;
    error text;
BEGIN
    INSERT INTO public."SU_Subject" ("Metadata_SU") VALUES (0) RETURNING "SU_ID" INTO s;
    INSERT INTO public."SU_TTL_Subject_Title" ("Metadata_SU_TTL", "SU_TTL_SU_ID", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt", "SU_TTL_Positor", "SU_TTL_Reliability")
    VALUES (0, s, 'Red', '2000-01-01', '2012-12-12', 0, 1);
    INSERT INTO public."SU_TTL_Subject_Title" ("Metadata_SU_TTL", "SU_TTL_SU_ID", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt", "SU_TTL_Positor", "SU_TTL_Reliability")
    VALUES (0, s, 'Green', '2001-01-01', '2012-12-13', 0, -1);
    shown := (SELECT "SU_TTL_Subject_Title" FROM public."lSU_Subject" WHERE "SU_ID" = s AND "Positor" = 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i08 certainly not Green from 2001 supersedes Red from 2000', shown IS NULL, 'shown ' || coalesce(shown, 'nothing'));
    BEGIN
        INSERT INTO public."SU_TTL_Subject_Title" ("Metadata_SU_TTL", "SU_TTL_SU_ID", "SU_TTL_Subject_Title", "SU_TTL_ChangedAt", "SU_TTL_PositedAt", "SU_TTL_Positor", "SU_TTL_Reliability")
        VALUES (0, s, 'Red', '2001-01-01', '2012-12-14', 0, 1);
    EXCEPTION WHEN OTHERS THEN
        error := SQLERRM;
    END;
    shown := (SELECT "SU_TTL_Subject_Title" FROM public."lSU_Subject" WHERE "SU_ID" = s AND "Positor" = 0);
    n := (SELECT count(*) FROM public."SU_TTL_Subject_Title_Annex" a JOIN public."SU_TTL_Subject_Title_Posit" p ON p."SU_TTL_ID" = a."SU_TTL_ID"
        WHERE p."SU_TTL_SU_ID" = s AND p."SU_TTL_ChangedAt" = '2001-01-01' AND a."SU_TTL_Reliability" <> 0);
    INSERT INTO public.test_result (test, passed, detail) VALUES ('i08 Red asserted at 2001 is held with not Green, and shown', error IS NULL AND shown = 'Red' AND n = 2,
        'shown ' || coalesce(shown, 'nothing') || ', ' || n || ' assertions held at 2001' || coalesce(' ' || error, ''));
END;
$$;
GO
