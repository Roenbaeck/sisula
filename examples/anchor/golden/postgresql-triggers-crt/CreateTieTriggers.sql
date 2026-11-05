-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled and latest views make them behave like tables.
-- The assembled view has an 'instead of' trigger for insert, which keeps the posit and annex tables. The latest view has
-- three: insert, update, and delete. They propagate such operations to the assembled view in a consistent way. Default
-- values are used for some columns if not provided by the corresponding SQL statements: the positor is 0, the changing and
-- positing times are now, the reliability is 1.
--
-- The rules are the ones of the attributes (see the attribute triggers). A tie that has identifiers and other roles, which
-- are its values, is about the values of the identifiers (at a changing time):
-- a decisive positor holds one assertion at a time for them, so an assertion of other values retracts, at its own positing
-- time, the posit that the positor holds, which is a correction.
--
-- For idempotent ties, only changes that represent values different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- PostgreSQL runs a trigger of this kind for each row, so the rows of an insert are taken in the order they have. Whether a
-- column is set in an UPDATE is told from whether it has another value than the row had.
--
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_holder_OB_item_GRD_grade is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_SU_holder_OB_item_GRD_grade"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."SU_holder_OB_item_GRD_grade_Reliability"
    FROM
        public."SU_holder_OB_item_GRD_grade_Annex" a
    WHERE
        a."SU_holder_OB_item_GRD_grade_ID" = _id
    AND
        a."SU_holder_OB_item_GRD_grade_Positor" = _positor
    AND
        a."SU_holder_OB_item_GRD_grade_PositedAt" <= _positing
    ORDER BY
        a."SU_holder_OB_item_GRD_grade_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_SU_holder_OB_item_GRD_grade tells whether a posit is in effect for a positor at a positing time: it holds an assertion of it, positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ie_SU_holder_OB_item_GRD_grade"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT coalesce(public."he_SU_holder_OB_item_GRD_grade"(_id, _positor, _positing), 0) <> 0
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_holder_OB_item_GRD_grade instead of INSERT trigger on SU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp;
    _reliability decimal(5,2);
    _held decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
    _total decimal(5,2);
BEGIN
    _positor := coalesce(NEW."SU_holder_OB_item_GRD_grade_Positor", 0);
    _positing := coalesce(NEW."SU_holder_OB_item_GRD_grade_PositedAt", _now);
    _reliability := coalesce(NEW."SU_holder_OB_item_GRD_grade_Reliability", 1);
    _changing := coalesce(NEW."SU_holder_OB_item_GRD_grade_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_holder_OB_item_GRD_grade_ID"
    INTO
        _posit
    FROM
        public."SU_holder_OB_item_GRD_grade_Posit" p
    WHERE
        p."SU_ID_holder" = NEW."SU_ID_holder"
    AND
        p."OB_ID_item" = NEW."OB_ID_item"
    AND
        p."GRD_ID_grade" = NEW."GRD_ID_grade"
    AND
        p."SU_holder_OB_item_GRD_grade_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_holder_OB_item_GRD_grade_Annex" a
        WHERE
            a."SU_holder_OB_item_GRD_grade_ID" = _posit
        AND
            a."SU_holder_OB_item_GRD_grade_Positor" = _positor
        AND
            a."SU_holder_OB_item_GRD_grade_PositedAt" = _positing
        AND
            a."SU_holder_OB_item_GRD_grade_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_holder_OB_item_GRD_grade for: %', concat_ws(', ',
            NEW."SU_ID_holder",
            NEW."OB_ID_item",
            NEW."GRD_ID_grade",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, are other values for identifiers that already have
    -- values (at that time), asserted by the positor at the positing time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_holder_OB_item_GRD_grade_Posit" p
        JOIN
            public."SU_holder_OB_item_GRD_grade_Annex" a
        ON
            a."SU_holder_OB_item_GRD_grade_ID" = p."SU_holder_OB_item_GRD_grade_ID"
        WHERE
            p."SU_ID_holder" = NEW."SU_ID_holder"
        AND
            p."OB_ID_item" = NEW."OB_ID_item"
        AND
            p."SU_holder_OB_item_GRD_grade_ChangedAt" = _changing
        AND
            NOT (
                p."GRD_ID_grade" = NEW."GRD_ID_grade"
            )
        AND
            a."SU_holder_OB_item_GRD_grade_Positor" = _positor
        AND
            a."SU_holder_OB_item_GRD_grade_PositedAt" = _positing
        AND
            a."SU_holder_OB_item_GRD_grade_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_holder_OB_item_GRD_grade for: %', concat_ws(', ',
            NEW."SU_ID_holder",
            NEW."OB_ID_item",
            NEW."GRD_ID_grade",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_holder_OB_item_GRD_grade_Annex" a
        WHERE
            a."SU_holder_OB_item_GRD_grade_ID" = _posit
        AND
            a."SU_holder_OB_item_GRD_grade_Positor" = _positor
        AND
            a."SU_holder_OB_item_GRD_grade_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_SU_holder_OB_item_GRD_grade"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_holder_OB_item_GRD_grade_Annex" (
            "Metadata_SU_holder_OB_item_GRD_grade",
            "SU_holder_OB_item_GRD_grade_ID",
            "SU_holder_OB_item_GRD_grade_Positor",
            "SU_holder_OB_item_GRD_grade_PositedAt",
            "SU_holder_OB_item_GRD_grade_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_holder_OB_item_GRD_grade", 0),
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what the positor holds for the same identifiers (and changing time), when that has other values: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR _other IN
        SELECT
            p."SU_holder_OB_item_GRD_grade_ID"
        FROM
            public."SU_holder_OB_item_GRD_grade_Posit" p
        WHERE
            p."SU_ID_holder" = NEW."SU_ID_holder"
        AND
            p."OB_ID_item" = NEW."OB_ID_item"
        AND
            p."SU_holder_OB_item_GRD_grade_ChangedAt" = _changing
        AND
            NOT (
                p."GRD_ID_grade" = NEW."GRD_ID_grade"
            )
        AND
            public."ie_SU_holder_OB_item_GRD_grade"(p."SU_holder_OB_item_GRD_grade_ID", _positor, _positing)
    LOOP
        INSERT INTO public."SU_holder_OB_item_GRD_grade_Annex" (
            "Metadata_SU_holder_OB_item_GRD_grade",
            "SU_holder_OB_item_GRD_grade_ID",
            "SU_holder_OB_item_GRD_grade_Positor",
            "SU_holder_OB_item_GRD_grade_PositedAt",
            "SU_holder_OB_item_GRD_grade_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_holder_OB_item_GRD_grade", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_holder_OB_item_GRD_grade_Posit" (
            "SU_ID_holder",
            "OB_ID_item",
            "GRD_ID_grade",
            "SU_holder_OB_item_GRD_grade_ChangedAt"
        )
        VALUES (
            NEW."SU_ID_holder",
            NEW."OB_ID_item",
            NEW."GRD_ID_grade",
            _changing
        )
        RETURNING "SU_holder_OB_item_GRD_grade_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_holder_OB_item_GRD_grade_Annex" (
        "Metadata_SU_holder_OB_item_GRD_grade",
        "SU_holder_OB_item_GRD_grade_ID",
        "SU_holder_OB_item_GRD_grade_Positor",
        "SU_holder_OB_item_GRD_grade_PositedAt",
        "SU_holder_OB_item_GRD_grade_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_holder_OB_item_GRD_grade", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_holder_OB_item_GRD_grade" ON public."SU_holder_OB_item_GRD_grade";
CREATE TRIGGER "it_SU_holder_OB_item_GRD_grade"
INSTEAD OF INSERT ON public."SU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_holder_OB_item_GRD_grade"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_holder_OB_item_GRD_grade instead of INSERT trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lSU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO public."SU_holder_OB_item_GRD_grade" (
        "Metadata_SU_holder_OB_item_GRD_grade",
        "SU_ID_holder",
        "OB_ID_item",
        "GRD_ID_grade",
        "SU_holder_OB_item_GRD_grade_ChangedAt",
        "SU_holder_OB_item_GRD_grade_Positor",
        "SU_holder_OB_item_GRD_grade_PositedAt",
        "SU_holder_OB_item_GRD_grade_Reliability"
    )
    VALUES (
        NEW."Metadata_SU_holder_OB_item_GRD_grade",
        NEW."SU_ID_holder",
        NEW."OB_ID_item",
        coalesce(NEW."GRD_ID_grade", (
            SELECT
                k."GRD_ID"
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."grade_GRD_Grade"
            LIMIT 1
        )),
        coalesce(NEW."SU_holder_OB_item_GRD_grade_ChangedAt", _now),
        coalesce(NEW."SU_holder_OB_item_GRD_grade_Positor", NEW."Positor", 0),
        coalesce(NEW."SU_holder_OB_item_GRD_grade_PositedAt", _now),
        coalesce(NEW."SU_holder_OB_item_GRD_grade_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lSU_holder_OB_item_GRD_grade" ON public."lSU_holder_OB_item_GRD_grade";
CREATE TRIGGER "it_lSU_holder_OB_item_GRD_grade"
INSTEAD OF INSERT ON public."lSU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."it_lSU_holder_OB_item_GRD_grade"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_holder_OB_item_GRD_grade instead of UPDATE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lSU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _positor smallint;
    _GRD_grade smallint;
BEGIN
    IF NEW."SU_ID_holder" IS DISTINCT FROM OLD."SU_ID_holder" THEN
        RAISE EXCEPTION 'The identity column SU_ID_holder is not updatable.';
    END IF;
    IF NEW."OB_ID_item" IS DISTINCT FROM OLD."OB_ID_item" THEN
        RAISE EXCEPTION 'The identity column OB_ID_item is not updatable.';
    END IF;
    _GRD_grade := NEW."GRD_ID_grade";
    IF NEW."grade_GRD_Grade" IS DISTINCT FROM OLD."grade_GRD_Grade" AND NEW."GRD_ID_grade" IS NOT DISTINCT FROM OLD."GRD_ID_grade" THEN
        _GRD_grade := NULL;
        IF NEW."grade_GRD_Grade" IS NOT NULL THEN
            SELECT
                k."GRD_ID"
            INTO
                _GRD_grade
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."grade_GRD_Grade"
            LIMIT 1;
        END IF;
    END IF;
    _positor := coalesce(CASE
        WHEN NEW."SU_holder_OB_item_GRD_grade_Positor" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_Positor" THEN NEW."SU_holder_OB_item_GRD_grade_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."SU_holder_OB_item_GRD_grade_PositedAt" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_PositedAt" THEN NEW."SU_holder_OB_item_GRD_grade_PositedAt"
        ELSE _now
    END;
    IF
        NEW."SU_ID_holder" IS DISTINCT FROM OLD."SU_ID_holder" OR
        NEW."OB_ID_item" IS DISTINCT FROM OLD."OB_ID_item" OR
        _GRD_grade IS DISTINCT FROM OLD."GRD_ID_grade" OR
        NEW."SU_holder_OB_item_GRD_grade_ChangedAt" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_ChangedAt" OR
        NEW."SU_holder_OB_item_GRD_grade_PositedAt" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_PositedAt" OR
        NEW."SU_holder_OB_item_GRD_grade_Reliability" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_Reliability"
    THEN
        IF
            NEW."SU_ID_holder" IS NOT NULL
        AND
            NEW."OB_ID_item" IS NOT NULL
        AND
            _GRD_grade IS NOT NULL
        THEN
            INSERT INTO public."SU_holder_OB_item_GRD_grade" (
                "Metadata_SU_holder_OB_item_GRD_grade",
                "SU_ID_holder",
                "OB_ID_item",
                "GRD_ID_grade",
                "SU_holder_OB_item_GRD_grade_ChangedAt",
                "SU_holder_OB_item_GRD_grade_Positor",
                "SU_holder_OB_item_GRD_grade_PositedAt",
                "SU_holder_OB_item_GRD_grade_Reliability"
            )
            VALUES (
                NEW."Metadata_SU_holder_OB_item_GRD_grade",
                NEW."SU_ID_holder",
                NEW."OB_ID_item",
                _GRD_grade,
                -- the shown version asserted again keeps its changing time, as does one that is given
                CASE
                    WHEN NEW."SU_holder_OB_item_GRD_grade_ChangedAt" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_ChangedAt" THEN NEW."SU_holder_OB_item_GRD_grade_ChangedAt"
                    WHEN
                        NEW."SU_ID_holder" = OLD."SU_ID_holder"
                    AND
                        NEW."OB_ID_item" = OLD."OB_ID_item"
                    AND
                        _GRD_grade = OLD."GRD_ID_grade"
                    THEN NEW."SU_holder_OB_item_GRD_grade_ChangedAt"
                    ELSE _now
                END,
                _positor,
                _positing,
                coalesce(NEW."SU_holder_OB_item_GRD_grade_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO public."SU_holder_OB_item_GRD_grade" (
                "Metadata_SU_holder_OB_item_GRD_grade",
                "SU_ID_holder",
                "OB_ID_item",
                "GRD_ID_grade",
                "SU_holder_OB_item_GRD_grade_ChangedAt",
                "SU_holder_OB_item_GRD_grade_Positor",
                "SU_holder_OB_item_GRD_grade_PositedAt",
                "SU_holder_OB_item_GRD_grade_Reliability"
            )
            VALUES (
                NEW."Metadata_SU_holder_OB_item_GRD_grade",
                OLD."SU_ID_holder",
                OLD."OB_ID_item",
                OLD."GRD_ID_grade",
                OLD."SU_holder_OB_item_GRD_grade_ChangedAt",
                _positor,
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lSU_holder_OB_item_GRD_grade" ON public."lSU_holder_OB_item_GRD_grade";
CREATE TRIGGER "ut_lSU_holder_OB_item_GRD_grade"
INSTEAD OF UPDATE ON public."lSU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."ut_lSU_holder_OB_item_GRD_grade"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_holder_OB_item_GRD_grade instead of DELETE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lSU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO public."SU_holder_OB_item_GRD_grade" (
        "Metadata_SU_holder_OB_item_GRD_grade",
        "SU_ID_holder",
        "OB_ID_item",
        "GRD_ID_grade",
        "SU_holder_OB_item_GRD_grade_ChangedAt",
        "SU_holder_OB_item_GRD_grade_Positor",
        "SU_holder_OB_item_GRD_grade_PositedAt",
        "SU_holder_OB_item_GRD_grade_Reliability"
    )
    VALUES (
        OLD."Metadata_SU_holder_OB_item_GRD_grade",
        OLD."SU_ID_holder",
        OLD."OB_ID_item",
        OLD."GRD_ID_grade",
        OLD."SU_holder_OB_item_GRD_grade_ChangedAt",
        coalesce(OLD."SU_holder_OB_item_GRD_grade_Positor", OLD."Positor", 0),
        _now,
        0
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lSU_holder_OB_item_GRD_grade" ON public."lSU_holder_OB_item_GRD_grade";
CREATE TRIGGER "dt_lSU_holder_OB_item_GRD_grade"
INSTEAD OF DELETE ON public."lSU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."dt_lSU_holder_OB_item_GRD_grade"();
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_keeper_OB_thing_GRD_rank is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_SU_keeper_OB_thing_GRD_rank"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."SU_keeper_OB_thing_GRD_rank_Reliability"
    FROM
        public."SU_keeper_OB_thing_GRD_rank_Annex" a
    WHERE
        a."SU_keeper_OB_thing_GRD_rank_ID" = _id
    AND
        a."SU_keeper_OB_thing_GRD_rank_Positor" = _positor
    AND
        a."SU_keeper_OB_thing_GRD_rank_PositedAt" <= _positing
    ORDER BY
        a."SU_keeper_OB_thing_GRD_rank_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_SU_keeper_OB_thing_GRD_rank tells whether a posit is in effect for a positor at a positing time: it holds an assertion of it, positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ie_SU_keeper_OB_thing_GRD_rank"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT coalesce(public."he_SU_keeper_OB_thing_GRD_rank"(_id, _positor, _positing), 0) <> 0
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_keeper_OB_thing_GRD_rank instead of INSERT trigger on SU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp;
    _reliability decimal(5,2);
    _held decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
    _total decimal(5,2);
BEGIN
    _positor := coalesce(NEW."SU_keeper_OB_thing_GRD_rank_Positor", 0);
    _positing := coalesce(NEW."SU_keeper_OB_thing_GRD_rank_PositedAt", _now);
    _reliability := coalesce(NEW."SU_keeper_OB_thing_GRD_rank_Reliability", 1);
    _changing := coalesce(NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_keeper_OB_thing_GRD_rank_ID"
    INTO
        _posit
    FROM
        public."SU_keeper_OB_thing_GRD_rank_Posit" p
    WHERE
        p."SU_ID_keeper" = NEW."SU_ID_keeper"
    AND
        p."OB_ID_thing" = NEW."OB_ID_thing"
    AND
        p."GRD_ID_rank" = NEW."GRD_ID_rank"
    AND
        p."SU_keeper_OB_thing_GRD_rank_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_keeper_OB_thing_GRD_rank_Annex" a
        WHERE
            a."SU_keeper_OB_thing_GRD_rank_ID" = _posit
        AND
            a."SU_keeper_OB_thing_GRD_rank_Positor" = _positor
        AND
            a."SU_keeper_OB_thing_GRD_rank_PositedAt" = _positing
        AND
            a."SU_keeper_OB_thing_GRD_rank_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_keeper_OB_thing_GRD_rank for: %', concat_ws(', ',
            NEW."SU_ID_keeper",
            NEW."OB_ID_thing",
            NEW."GRD_ID_rank",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, are other values for identifiers that already have
    -- values (at that time), asserted by the positor at the positing time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_keeper_OB_thing_GRD_rank_Posit" p
        JOIN
            public."SU_keeper_OB_thing_GRD_rank_Annex" a
        ON
            a."SU_keeper_OB_thing_GRD_rank_ID" = p."SU_keeper_OB_thing_GRD_rank_ID"
        WHERE
            p."SU_ID_keeper" = NEW."SU_ID_keeper"
        AND
            p."OB_ID_thing" = NEW."OB_ID_thing"
        AND
            p."SU_keeper_OB_thing_GRD_rank_ChangedAt" = _changing
        AND
            NOT (
                p."GRD_ID_rank" = NEW."GRD_ID_rank"
            )
        AND
            a."SU_keeper_OB_thing_GRD_rank_Positor" = _positor
        AND
            a."SU_keeper_OB_thing_GRD_rank_PositedAt" = _positing
        AND
            a."SU_keeper_OB_thing_GRD_rank_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_keeper_OB_thing_GRD_rank for: %', concat_ws(', ',
            NEW."SU_ID_keeper",
            NEW."OB_ID_thing",
            NEW."GRD_ID_rank",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_keeper_OB_thing_GRD_rank_Annex" a
        WHERE
            a."SU_keeper_OB_thing_GRD_rank_ID" = _posit
        AND
            a."SU_keeper_OB_thing_GRD_rank_Positor" = _positor
        AND
            a."SU_keeper_OB_thing_GRD_rank_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_SU_keeper_OB_thing_GRD_rank"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_keeper_OB_thing_GRD_rank_Annex" (
            "Metadata_SU_keeper_OB_thing_GRD_rank",
            "SU_keeper_OB_thing_GRD_rank_ID",
            "SU_keeper_OB_thing_GRD_rank_Positor",
            "SU_keeper_OB_thing_GRD_rank_PositedAt",
            "SU_keeper_OB_thing_GRD_rank_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_keeper_OB_thing_GRD_rank", 0),
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the same assertion that the positor holds is not stated again unless the tie is assertive
    IF _held IS NOT NULL AND _held = _reliability THEN
        RETURN NULL;
    END IF;
    -- an assertion corrects what the positor holds for the same identifiers (and changing time), when that has other values: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR _other IN
        SELECT
            p."SU_keeper_OB_thing_GRD_rank_ID"
        FROM
            public."SU_keeper_OB_thing_GRD_rank_Posit" p
        WHERE
            p."SU_ID_keeper" = NEW."SU_ID_keeper"
        AND
            p."OB_ID_thing" = NEW."OB_ID_thing"
        AND
            p."SU_keeper_OB_thing_GRD_rank_ChangedAt" = _changing
        AND
            NOT (
                p."GRD_ID_rank" = NEW."GRD_ID_rank"
            )
        AND
            public."ie_SU_keeper_OB_thing_GRD_rank"(p."SU_keeper_OB_thing_GRD_rank_ID", _positor, _positing)
    LOOP
        INSERT INTO public."SU_keeper_OB_thing_GRD_rank_Annex" (
            "Metadata_SU_keeper_OB_thing_GRD_rank",
            "SU_keeper_OB_thing_GRD_rank_ID",
            "SU_keeper_OB_thing_GRD_rank_Positor",
            "SU_keeper_OB_thing_GRD_rank_PositedAt",
            "SU_keeper_OB_thing_GRD_rank_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_keeper_OB_thing_GRD_rank", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the same values as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_ID_keeper",
                p."OB_ID_thing",
                p."GRD_ID_rank"
            FROM
                public."SU_keeper_OB_thing_GRD_rank_Posit" p
            WHERE
                p."SU_ID_keeper" = NEW."SU_ID_keeper"
            AND
                p."OB_ID_thing" = NEW."OB_ID_thing"
            AND
                p."SU_keeper_OB_thing_GRD_rank_ChangedAt" < _changing
            AND
                public."ie_SU_keeper_OB_thing_GRD_rank"(p."SU_keeper_OB_thing_GRD_rank_ID", _positor, _positing)
            AND
                (public."he_SU_keeper_OB_thing_GRD_rank"(p."SU_keeper_OB_thing_GRD_rank_ID", _positor, _positing) > 0) = (_reliability > 0)
            ORDER BY
                p."SU_keeper_OB_thing_GRD_rank_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."SU_ID_keeper" = NEW."SU_ID_keeper"
        AND
            pre."OB_ID_thing" = NEW."OB_ID_thing"
        AND
            pre."GRD_ID_rank" = NEW."GRD_ID_rank"
    ) THEN
        -- (an idempotent tie does not store it)
        RETURN NULL;
    END IF;
    -- the same values as the version after it make that version a restatement
    SELECT
        f."SU_keeper_OB_thing_GRD_rank_ID"
    INTO
        _following
    FROM
        public."SU_keeper_OB_thing_GRD_rank_Posit" f
    WHERE
        f."SU_ID_keeper" = NEW."SU_ID_keeper"
    AND
        f."OB_ID_thing" = NEW."OB_ID_thing"
    AND
        f."SU_keeper_OB_thing_GRD_rank_ChangedAt" > _changing
    AND
        public."ie_SU_keeper_OB_thing_GRD_rank"(f."SU_keeper_OB_thing_GRD_rank_ID", _positor, _positing)
    AND
        (public."he_SU_keeper_OB_thing_GRD_rank"(f."SU_keeper_OB_thing_GRD_rank_ID", _positor, _positing) > 0) = (_reliability > 0)
    ORDER BY
        f."SU_keeper_OB_thing_GRD_rank_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_keeper_OB_thing_GRD_rank_Posit" x
        WHERE
            x."SU_keeper_OB_thing_GRD_rank_ID" = _following
        AND
            x."SU_ID_keeper" = NEW."SU_ID_keeper"
        AND
            x."OB_ID_thing" = NEW."OB_ID_thing"
        AND
            x."GRD_ID_rank" = NEW."GRD_ID_rank"
    ) THEN
        -- (an idempotent tie retracts it)
        INSERT INTO public."SU_keeper_OB_thing_GRD_rank_Annex" (
            "Metadata_SU_keeper_OB_thing_GRD_rank",
            "SU_keeper_OB_thing_GRD_rank_ID",
            "SU_keeper_OB_thing_GRD_rank_Positor",
            "SU_keeper_OB_thing_GRD_rank_PositedAt",
            "SU_keeper_OB_thing_GRD_rank_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_keeper_OB_thing_GRD_rank", 0),
            _following,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_keeper_OB_thing_GRD_rank_Posit" (
            "SU_ID_keeper",
            "OB_ID_thing",
            "GRD_ID_rank",
            "SU_keeper_OB_thing_GRD_rank_ChangedAt"
        )
        VALUES (
            NEW."SU_ID_keeper",
            NEW."OB_ID_thing",
            NEW."GRD_ID_rank",
            _changing
        )
        RETURNING "SU_keeper_OB_thing_GRD_rank_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_keeper_OB_thing_GRD_rank_Annex" (
        "Metadata_SU_keeper_OB_thing_GRD_rank",
        "SU_keeper_OB_thing_GRD_rank_ID",
        "SU_keeper_OB_thing_GRD_rank_Positor",
        "SU_keeper_OB_thing_GRD_rank_PositedAt",
        "SU_keeper_OB_thing_GRD_rank_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_keeper_OB_thing_GRD_rank", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_keeper_OB_thing_GRD_rank" ON public."SU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "it_SU_keeper_OB_thing_GRD_rank"
INSTEAD OF INSERT ON public."SU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_keeper_OB_thing_GRD_rank"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_keeper_OB_thing_GRD_rank instead of INSERT trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lSU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO public."SU_keeper_OB_thing_GRD_rank" (
        "Metadata_SU_keeper_OB_thing_GRD_rank",
        "SU_ID_keeper",
        "OB_ID_thing",
        "GRD_ID_rank",
        "SU_keeper_OB_thing_GRD_rank_ChangedAt",
        "SU_keeper_OB_thing_GRD_rank_Positor",
        "SU_keeper_OB_thing_GRD_rank_PositedAt",
        "SU_keeper_OB_thing_GRD_rank_Reliability"
    )
    VALUES (
        NEW."Metadata_SU_keeper_OB_thing_GRD_rank",
        NEW."SU_ID_keeper",
        NEW."OB_ID_thing",
        coalesce(NEW."GRD_ID_rank", (
            SELECT
                k."GRD_ID"
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."rank_GRD_Grade"
            LIMIT 1
        )),
        coalesce(NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt", _now),
        coalesce(NEW."SU_keeper_OB_thing_GRD_rank_Positor", NEW."Positor", 0),
        coalesce(NEW."SU_keeper_OB_thing_GRD_rank_PositedAt", _now),
        coalesce(NEW."SU_keeper_OB_thing_GRD_rank_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lSU_keeper_OB_thing_GRD_rank" ON public."lSU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "it_lSU_keeper_OB_thing_GRD_rank"
INSTEAD OF INSERT ON public."lSU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."it_lSU_keeper_OB_thing_GRD_rank"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_keeper_OB_thing_GRD_rank instead of UPDATE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lSU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _positor smallint;
    _GRD_rank smallint;
BEGIN
    IF NEW."SU_ID_keeper" IS DISTINCT FROM OLD."SU_ID_keeper" THEN
        RAISE EXCEPTION 'The identity column SU_ID_keeper is not updatable.';
    END IF;
    IF NEW."OB_ID_thing" IS DISTINCT FROM OLD."OB_ID_thing" THEN
        RAISE EXCEPTION 'The identity column OB_ID_thing is not updatable.';
    END IF;
    _GRD_rank := NEW."GRD_ID_rank";
    IF NEW."rank_GRD_Grade" IS DISTINCT FROM OLD."rank_GRD_Grade" AND NEW."GRD_ID_rank" IS NOT DISTINCT FROM OLD."GRD_ID_rank" THEN
        _GRD_rank := NULL;
        IF NEW."rank_GRD_Grade" IS NOT NULL THEN
            SELECT
                k."GRD_ID"
            INTO
                _GRD_rank
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."rank_GRD_Grade"
            LIMIT 1;
        END IF;
    END IF;
    _positor := coalesce(CASE
        WHEN NEW."SU_keeper_OB_thing_GRD_rank_Positor" IS DISTINCT FROM OLD."SU_keeper_OB_thing_GRD_rank_Positor" THEN NEW."SU_keeper_OB_thing_GRD_rank_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."SU_keeper_OB_thing_GRD_rank_PositedAt" IS DISTINCT FROM OLD."SU_keeper_OB_thing_GRD_rank_PositedAt" THEN NEW."SU_keeper_OB_thing_GRD_rank_PositedAt"
        ELSE _now
    END;
    IF
        NEW."SU_ID_keeper" IS DISTINCT FROM OLD."SU_ID_keeper" OR
        NEW."OB_ID_thing" IS DISTINCT FROM OLD."OB_ID_thing" OR
        _GRD_rank IS DISTINCT FROM OLD."GRD_ID_rank" OR
        NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt" IS DISTINCT FROM OLD."SU_keeper_OB_thing_GRD_rank_ChangedAt" OR
        NEW."SU_keeper_OB_thing_GRD_rank_PositedAt" IS DISTINCT FROM OLD."SU_keeper_OB_thing_GRD_rank_PositedAt" OR
        NEW."SU_keeper_OB_thing_GRD_rank_Reliability" IS DISTINCT FROM OLD."SU_keeper_OB_thing_GRD_rank_Reliability"
    THEN
        IF
            NEW."SU_ID_keeper" IS NOT NULL
        AND
            NEW."OB_ID_thing" IS NOT NULL
        AND
            _GRD_rank IS NOT NULL
        THEN
            INSERT INTO public."SU_keeper_OB_thing_GRD_rank" (
                "Metadata_SU_keeper_OB_thing_GRD_rank",
                "SU_ID_keeper",
                "OB_ID_thing",
                "GRD_ID_rank",
                "SU_keeper_OB_thing_GRD_rank_ChangedAt",
                "SU_keeper_OB_thing_GRD_rank_Positor",
                "SU_keeper_OB_thing_GRD_rank_PositedAt",
                "SU_keeper_OB_thing_GRD_rank_Reliability"
            )
            VALUES (
                NEW."Metadata_SU_keeper_OB_thing_GRD_rank",
                NEW."SU_ID_keeper",
                NEW."OB_ID_thing",
                _GRD_rank,
                -- the shown version asserted again keeps its changing time, as does one that is given
                CASE
                    WHEN NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt" IS DISTINCT FROM OLD."SU_keeper_OB_thing_GRD_rank_ChangedAt" THEN NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
                    WHEN
                        NEW."SU_ID_keeper" = OLD."SU_ID_keeper"
                    AND
                        NEW."OB_ID_thing" = OLD."OB_ID_thing"
                    AND
                        _GRD_rank = OLD."GRD_ID_rank"
                    THEN NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
                    ELSE _now
                END,
                _positor,
                _positing,
                coalesce(NEW."SU_keeper_OB_thing_GRD_rank_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO public."SU_keeper_OB_thing_GRD_rank" (
                "Metadata_SU_keeper_OB_thing_GRD_rank",
                "SU_ID_keeper",
                "OB_ID_thing",
                "GRD_ID_rank",
                "SU_keeper_OB_thing_GRD_rank_ChangedAt",
                "SU_keeper_OB_thing_GRD_rank_Positor",
                "SU_keeper_OB_thing_GRD_rank_PositedAt",
                "SU_keeper_OB_thing_GRD_rank_Reliability"
            )
            VALUES (
                NEW."Metadata_SU_keeper_OB_thing_GRD_rank",
                OLD."SU_ID_keeper",
                OLD."OB_ID_thing",
                OLD."GRD_ID_rank",
                OLD."SU_keeper_OB_thing_GRD_rank_ChangedAt",
                _positor,
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lSU_keeper_OB_thing_GRD_rank" ON public."lSU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "ut_lSU_keeper_OB_thing_GRD_rank"
INSTEAD OF UPDATE ON public."lSU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."ut_lSU_keeper_OB_thing_GRD_rank"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_keeper_OB_thing_GRD_rank instead of DELETE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lSU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO public."SU_keeper_OB_thing_GRD_rank" (
        "Metadata_SU_keeper_OB_thing_GRD_rank",
        "SU_ID_keeper",
        "OB_ID_thing",
        "GRD_ID_rank",
        "SU_keeper_OB_thing_GRD_rank_ChangedAt",
        "SU_keeper_OB_thing_GRD_rank_Positor",
        "SU_keeper_OB_thing_GRD_rank_PositedAt",
        "SU_keeper_OB_thing_GRD_rank_Reliability"
    )
    VALUES (
        OLD."Metadata_SU_keeper_OB_thing_GRD_rank",
        OLD."SU_ID_keeper",
        OLD."OB_ID_thing",
        OLD."GRD_ID_rank",
        OLD."SU_keeper_OB_thing_GRD_rank_ChangedAt",
        coalesce(OLD."SU_keeper_OB_thing_GRD_rank_Positor", OLD."Positor", 0),
        _now,
        0
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lSU_keeper_OB_thing_GRD_rank" ON public."lSU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "dt_lSU_keeper_OB_thing_GRD_rank"
INSTEAD OF DELETE ON public."lSU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."dt_lSU_keeper_OB_thing_GRD_rank"();
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_OB_part_SU_owner is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_OB_part_SU_owner"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."OB_part_SU_owner_Reliability"
    FROM
        public."OB_part_SU_owner_Annex" a
    WHERE
        a."OB_part_SU_owner_ID" = _id
    AND
        a."OB_part_SU_owner_Positor" = _positor
    AND
        a."OB_part_SU_owner_PositedAt" <= _positing
    ORDER BY
        a."OB_part_SU_owner_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_OB_part_SU_owner tells whether a posit is in effect for a positor at a positing time: it holds an assertion of it, positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ie_OB_part_SU_owner"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT coalesce(public."he_OB_part_SU_owner"(_id, _positor, _positing), 0) <> 0
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OB_part_SU_owner instead of INSERT trigger on OB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_OB_part_SU_owner"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp;
    _reliability decimal(5,2);
    _held decimal(5,2);
    _posit integer;
    _other integer;
    _following integer;
    _total decimal(5,2);
BEGIN
    _positor := coalesce(NEW."OB_part_SU_owner_Positor", 0);
    _positing := coalesce(NEW."OB_part_SU_owner_PositedAt", _now);
    _reliability := coalesce(NEW."OB_part_SU_owner_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."OB_part_SU_owner_ID"
    INTO
        _posit
    FROM
        public."OB_part_SU_owner_Posit" p
    WHERE
        p."OB_ID_part" = NEW."OB_ID_part"
    AND
        p."SU_ID_owner" = NEW."SU_ID_owner"
    AND
        true
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."OB_part_SU_owner_Annex" a
        WHERE
            a."OB_part_SU_owner_ID" = _posit
        AND
            a."OB_part_SU_owner_Positor" = _positor
        AND
            a."OB_part_SU_owner_PositedAt" = _positing
        AND
            a."OB_part_SU_owner_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in OB_part_SU_owner for: %', concat_ws(', ',
            NEW."OB_ID_part",
            NEW."SU_ID_owner",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, are other values for identifiers that already have
    -- values (at that time), asserted by the positor at the positing time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            public."OB_part_SU_owner_Posit" p
        JOIN
            public."OB_part_SU_owner_Annex" a
        ON
            a."OB_part_SU_owner_ID" = p."OB_part_SU_owner_ID"
        WHERE
            p."OB_ID_part" = NEW."OB_ID_part"
        AND
            NOT (
                p."SU_ID_owner" = NEW."SU_ID_owner"
            )
        AND
            a."OB_part_SU_owner_Positor" = _positor
        AND
            a."OB_part_SU_owner_PositedAt" = _positing
        AND
            a."OB_part_SU_owner_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in OB_part_SU_owner for: %', concat_ws(', ',
            NEW."OB_ID_part",
            NEW."SU_ID_owner",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."OB_part_SU_owner_Annex" a
        WHERE
            a."OB_part_SU_owner_ID" = _posit
        AND
            a."OB_part_SU_owner_Positor" = _positor
        AND
            a."OB_part_SU_owner_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_OB_part_SU_owner"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."OB_part_SU_owner_Annex" (
            "Metadata_OB_part_SU_owner",
            "OB_part_SU_owner_ID",
            "OB_part_SU_owner_Positor",
            "OB_part_SU_owner_PositedAt",
            "OB_part_SU_owner_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_OB_part_SU_owner", 0),
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what the positor holds for the same identifiers (and changing time), when that has other values: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR _other IN
        SELECT
            p."OB_part_SU_owner_ID"
        FROM
            public."OB_part_SU_owner_Posit" p
        WHERE
            p."OB_ID_part" = NEW."OB_ID_part"
        AND
            NOT (
                p."SU_ID_owner" = NEW."SU_ID_owner"
            )
        AND
            public."ie_OB_part_SU_owner"(p."OB_part_SU_owner_ID", _positor, _positing)
    LOOP
        INSERT INTO public."OB_part_SU_owner_Annex" (
            "Metadata_OB_part_SU_owner",
            "OB_part_SU_owner_ID",
            "OB_part_SU_owner_Positor",
            "OB_part_SU_owner_PositedAt",
            "OB_part_SU_owner_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_OB_part_SU_owner", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."OB_part_SU_owner_Posit" (
            "OB_ID_part",
            "SU_ID_owner",
            "OB_part_SU_owner_ID"
        )
        VALUES (
            NEW."OB_ID_part",
            NEW."SU_ID_owner",
            DEFAULT
        )
        RETURNING "OB_part_SU_owner_ID" INTO _posit;
    END IF;
    INSERT INTO public."OB_part_SU_owner_Annex" (
        "Metadata_OB_part_SU_owner",
        "OB_part_SU_owner_ID",
        "OB_part_SU_owner_Positor",
        "OB_part_SU_owner_PositedAt",
        "OB_part_SU_owner_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_OB_part_SU_owner", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_OB_part_SU_owner" ON public."OB_part_SU_owner";
CREATE TRIGGER "it_OB_part_SU_owner"
INSTEAD OF INSERT ON public."OB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."it_OB_part_SU_owner"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_part_SU_owner instead of INSERT trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lOB_part_SU_owner"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO public."OB_part_SU_owner" (
        "Metadata_OB_part_SU_owner",
        "OB_ID_part",
        "SU_ID_owner",
        "OB_part_SU_owner_Positor",
        "OB_part_SU_owner_PositedAt",
        "OB_part_SU_owner_Reliability"
    )
    VALUES (
        NEW."Metadata_OB_part_SU_owner",
        NEW."OB_ID_part",
        NEW."SU_ID_owner",
        coalesce(NEW."OB_part_SU_owner_Positor", NEW."Positor", 0),
        coalesce(NEW."OB_part_SU_owner_PositedAt", _now),
        coalesce(NEW."OB_part_SU_owner_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lOB_part_SU_owner" ON public."lOB_part_SU_owner";
CREATE TRIGGER "it_lOB_part_SU_owner"
INSTEAD OF INSERT ON public."lOB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."it_lOB_part_SU_owner"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOB_part_SU_owner instead of UPDATE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lOB_part_SU_owner"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _positor smallint;
BEGIN
    IF NEW."OB_ID_part" IS DISTINCT FROM OLD."OB_ID_part" THEN
        RAISE EXCEPTION 'The identity column OB_ID_part is not updatable.';
    END IF;
    _positor := coalesce(CASE
        WHEN NEW."OB_part_SU_owner_Positor" IS DISTINCT FROM OLD."OB_part_SU_owner_Positor" THEN NEW."OB_part_SU_owner_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."OB_part_SU_owner_PositedAt" IS DISTINCT FROM OLD."OB_part_SU_owner_PositedAt" THEN NEW."OB_part_SU_owner_PositedAt"
        ELSE _now
    END;
    IF
        NEW."OB_ID_part" IS DISTINCT FROM OLD."OB_ID_part" OR
        NEW."SU_ID_owner" IS DISTINCT FROM OLD."SU_ID_owner" OR
        NEW."OB_part_SU_owner_PositedAt" IS DISTINCT FROM OLD."OB_part_SU_owner_PositedAt" OR
        NEW."OB_part_SU_owner_Reliability" IS DISTINCT FROM OLD."OB_part_SU_owner_Reliability"
    THEN
        IF
            NEW."OB_ID_part" IS NOT NULL
        AND
            NEW."SU_ID_owner" IS NOT NULL
        THEN
            INSERT INTO public."OB_part_SU_owner" (
                "Metadata_OB_part_SU_owner",
                "OB_ID_part",
                "SU_ID_owner",
                "OB_part_SU_owner_Positor",
                "OB_part_SU_owner_PositedAt",
                "OB_part_SU_owner_Reliability"
            )
            VALUES (
                NEW."Metadata_OB_part_SU_owner",
                NEW."OB_ID_part",
                NEW."SU_ID_owner",
                _positor,
                _positing,
                coalesce(NEW."OB_part_SU_owner_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO public."OB_part_SU_owner" (
                "Metadata_OB_part_SU_owner",
                "OB_ID_part",
                "SU_ID_owner",
                "OB_part_SU_owner_Positor",
                "OB_part_SU_owner_PositedAt",
                "OB_part_SU_owner_Reliability"
            )
            VALUES (
                NEW."Metadata_OB_part_SU_owner",
                OLD."OB_ID_part",
                OLD."SU_ID_owner",
                _positor,
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lOB_part_SU_owner" ON public."lOB_part_SU_owner";
CREATE TRIGGER "ut_lOB_part_SU_owner"
INSTEAD OF UPDATE ON public."lOB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."ut_lOB_part_SU_owner"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_part_SU_owner instead of DELETE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lOB_part_SU_owner"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO public."OB_part_SU_owner" (
        "Metadata_OB_part_SU_owner",
        "OB_ID_part",
        "SU_ID_owner",
        "OB_part_SU_owner_Positor",
        "OB_part_SU_owner_PositedAt",
        "OB_part_SU_owner_Reliability"
    )
    VALUES (
        OLD."Metadata_OB_part_SU_owner",
        OLD."OB_ID_part",
        OLD."SU_ID_owner",
        coalesce(OLD."OB_part_SU_owner_Positor", OLD."Positor", 0),
        _now,
        0
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lOB_part_SU_owner" ON public."lOB_part_SU_owner";
CREATE TRIGGER "dt_lOB_part_SU_owner"
INSTEAD OF DELETE ON public."lOB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."dt_lOB_part_SU_owner"();
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_partner_SU_with is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_SU_partner_SU_with"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."SU_partner_SU_with_Reliability"
    FROM
        public."SU_partner_SU_with_Annex" a
    WHERE
        a."SU_partner_SU_with_ID" = _id
    AND
        a."SU_partner_SU_with_Positor" = _positor
    AND
        a."SU_partner_SU_with_PositedAt" <= _positing
    ORDER BY
        a."SU_partner_SU_with_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_SU_partner_SU_with tells whether a posit is in effect for a positor at a positing time: it holds an assertion of it, positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ie_SU_partner_SU_with"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT coalesce(public."he_SU_partner_SU_with"(_id, _positor, _positing), 0) <> 0
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_partner_SU_with instead of INSERT trigger on SU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_partner_SU_with"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp;
    _reliability decimal(5,2);
    _held decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
    _total decimal(5,2);
BEGIN
    _positor := coalesce(NEW."SU_partner_SU_with_Positor", 0);
    _positing := coalesce(NEW."SU_partner_SU_with_PositedAt", _now);
    _reliability := coalesce(NEW."SU_partner_SU_with_Reliability", 1);
    _changing := coalesce(NEW."SU_partner_SU_with_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_partner_SU_with_ID"
    INTO
        _posit
    FROM
        public."SU_partner_SU_with_Posit" p
    WHERE
        p."SU_ID_partner" = NEW."SU_ID_partner"
    AND
        p."SU_ID_with" = NEW."SU_ID_with"
    AND
        p."SU_partner_SU_with_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_partner_SU_with_Annex" a
        WHERE
            a."SU_partner_SU_with_ID" = _posit
        AND
            a."SU_partner_SU_with_Positor" = _positor
        AND
            a."SU_partner_SU_with_PositedAt" = _positing
        AND
            a."SU_partner_SU_with_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_partner_SU_with for: %', concat_ws(', ',
            NEW."SU_ID_partner",
            NEW."SU_ID_with",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_partner_SU_with_Annex" a
        WHERE
            a."SU_partner_SU_with_ID" = _posit
        AND
            a."SU_partner_SU_with_Positor" = _positor
        AND
            a."SU_partner_SU_with_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_SU_partner_SU_with"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_partner_SU_with_Annex" (
            "Metadata_SU_partner_SU_with",
            "SU_partner_SU_with_ID",
            "SU_partner_SU_with_Positor",
            "SU_partner_SU_with_PositedAt",
            "SU_partner_SU_with_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_partner_SU_with", 0),
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_partner_SU_with_Posit" (
            "SU_ID_partner",
            "SU_ID_with",
            "SU_partner_SU_with_ChangedAt"
        )
        VALUES (
            NEW."SU_ID_partner",
            NEW."SU_ID_with",
            _changing
        )
        RETURNING "SU_partner_SU_with_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_partner_SU_with_Annex" (
        "Metadata_SU_partner_SU_with",
        "SU_partner_SU_with_ID",
        "SU_partner_SU_with_Positor",
        "SU_partner_SU_with_PositedAt",
        "SU_partner_SU_with_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_partner_SU_with", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_partner_SU_with" ON public."SU_partner_SU_with";
CREATE TRIGGER "it_SU_partner_SU_with"
INSTEAD OF INSERT ON public."SU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_partner_SU_with"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_partner_SU_with instead of INSERT trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lSU_partner_SU_with"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO public."SU_partner_SU_with" (
        "Metadata_SU_partner_SU_with",
        "SU_ID_partner",
        "SU_ID_with",
        "SU_partner_SU_with_ChangedAt",
        "SU_partner_SU_with_Positor",
        "SU_partner_SU_with_PositedAt",
        "SU_partner_SU_with_Reliability"
    )
    VALUES (
        NEW."Metadata_SU_partner_SU_with",
        NEW."SU_ID_partner",
        NEW."SU_ID_with",
        coalesce(NEW."SU_partner_SU_with_ChangedAt", _now),
        coalesce(NEW."SU_partner_SU_with_Positor", NEW."Positor", 0),
        coalesce(NEW."SU_partner_SU_with_PositedAt", _now),
        coalesce(NEW."SU_partner_SU_with_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lSU_partner_SU_with" ON public."lSU_partner_SU_with";
CREATE TRIGGER "it_lSU_partner_SU_with"
INSTEAD OF INSERT ON public."lSU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."it_lSU_partner_SU_with"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_partner_SU_with instead of UPDATE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lSU_partner_SU_with"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _positor smallint;
BEGIN
    _positor := coalesce(CASE
        WHEN NEW."SU_partner_SU_with_Positor" IS DISTINCT FROM OLD."SU_partner_SU_with_Positor" THEN NEW."SU_partner_SU_with_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."SU_partner_SU_with_PositedAt" IS DISTINCT FROM OLD."SU_partner_SU_with_PositedAt" THEN NEW."SU_partner_SU_with_PositedAt"
        ELSE _now
    END;
    IF
        NEW."SU_ID_partner" IS DISTINCT FROM OLD."SU_ID_partner" OR
        NEW."SU_ID_with" IS DISTINCT FROM OLD."SU_ID_with" OR
        NEW."SU_partner_SU_with_ChangedAt" IS DISTINCT FROM OLD."SU_partner_SU_with_ChangedAt" OR
        NEW."SU_partner_SU_with_PositedAt" IS DISTINCT FROM OLD."SU_partner_SU_with_PositedAt" OR
        NEW."SU_partner_SU_with_Reliability" IS DISTINCT FROM OLD."SU_partner_SU_with_Reliability"
    THEN
        IF
            NEW."SU_ID_partner" IS NOT NULL
        AND
            NEW."SU_ID_with" IS NOT NULL
        THEN
            INSERT INTO public."SU_partner_SU_with" (
                "Metadata_SU_partner_SU_with",
                "SU_ID_partner",
                "SU_ID_with",
                "SU_partner_SU_with_ChangedAt",
                "SU_partner_SU_with_Positor",
                "SU_partner_SU_with_PositedAt",
                "SU_partner_SU_with_Reliability"
            )
            VALUES (
                NEW."Metadata_SU_partner_SU_with",
                NEW."SU_ID_partner",
                NEW."SU_ID_with",
                -- the shown version asserted again keeps its changing time, as does one that is given
                CASE
                    WHEN NEW."SU_partner_SU_with_ChangedAt" IS DISTINCT FROM OLD."SU_partner_SU_with_ChangedAt" THEN NEW."SU_partner_SU_with_ChangedAt"
                    WHEN
                        NEW."SU_ID_partner" = OLD."SU_ID_partner"
                    AND
                        NEW."SU_ID_with" = OLD."SU_ID_with"
                    THEN NEW."SU_partner_SU_with_ChangedAt"
                    ELSE _now
                END,
                _positor,
                _positing,
                coalesce(NEW."SU_partner_SU_with_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO public."SU_partner_SU_with" (
                "Metadata_SU_partner_SU_with",
                "SU_ID_partner",
                "SU_ID_with",
                "SU_partner_SU_with_ChangedAt",
                "SU_partner_SU_with_Positor",
                "SU_partner_SU_with_PositedAt",
                "SU_partner_SU_with_Reliability"
            )
            VALUES (
                NEW."Metadata_SU_partner_SU_with",
                OLD."SU_ID_partner",
                OLD."SU_ID_with",
                OLD."SU_partner_SU_with_ChangedAt",
                _positor,
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lSU_partner_SU_with" ON public."lSU_partner_SU_with";
CREATE TRIGGER "ut_lSU_partner_SU_with"
INSTEAD OF UPDATE ON public."lSU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."ut_lSU_partner_SU_with"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_partner_SU_with instead of DELETE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lSU_partner_SU_with"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO public."SU_partner_SU_with" (
        "Metadata_SU_partner_SU_with",
        "SU_ID_partner",
        "SU_ID_with",
        "SU_partner_SU_with_ChangedAt",
        "SU_partner_SU_with_Positor",
        "SU_partner_SU_with_PositedAt",
        "SU_partner_SU_with_Reliability"
    )
    VALUES (
        OLD."Metadata_SU_partner_SU_with",
        OLD."SU_ID_partner",
        OLD."SU_ID_with",
        OLD."SU_partner_SU_with_ChangedAt",
        coalesce(OLD."SU_partner_SU_with_Positor", OLD."Positor", 0),
        _now,
        0
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lSU_partner_SU_with" ON public."lSU_partner_SU_with";
CREATE TRIGGER "dt_lSU_partner_SU_with"
INSTEAD OF DELETE ON public."lSU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."dt_lSU_partner_SU_with"();
