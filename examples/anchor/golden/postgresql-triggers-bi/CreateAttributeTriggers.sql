-- ATTRIBUTE TRIGGERS ------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled views make them behave like tables.
-- There is one 'instead of' trigger for: insert.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- The rules are the ones in Anchor's docs/ANCHOR.md, "Loading through the latest views". Bitemporal modeling is decisive:
-- one posit at a time is asserted for an entity (and a changing time). An assertion of another value therefore retracts, at
-- its own positing time, the posit that is in effect, which is a correction; a posit is in effect at a positing time when its
-- latest annex row up to then asserts it. The positing time is now (the clock, which moves between two statements) unless it is
-- given.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates, although what they correct is retracted.
--
-- PostgreSQL runs a trigger of this kind for each row.
--
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_QTY_Event_Quantity tells whether two values of EV_QTY_Event_Quantity are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_EV_QTY_Event_Quantity"(
    l integer,
    r integer
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_QTY_Event_Quantity instead of INSERT trigger on EV_QTY_Event_Quantity
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_EV_QTY_Event_Quantity"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."EV_QTY_PositedAt", _now);
    _reliability := coalesce(NEW."EV_QTY_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."EV_QTY_ID"
    INTO
        _posit
    FROM
        public."EV_QTY_Event_Quantity_Posit" p
    WHERE
        p."EV_QTY_EV_ID" = NEW."EV_QTY_EV_ID"
    AND
        public."eq_EV_QTY_Event_Quantity"(p."EV_QTY_Event_Quantity", NEW."EV_QTY_Event_Quantity")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."EV_QTY_Event_Quantity_Annex" a
        WHERE
            a."EV_QTY_ID" = _posit
        AND
            a."EV_QTY_PositedAt" = _positing
        AND
            a."EV_QTY_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_QTY_Event_Quantity for: %', concat_ws(', ', NEW."EV_QTY_EV_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."EV_QTY_Event_Quantity_Posit" p
        JOIN
            public."EV_QTY_Event_Quantity_Annex" a
        ON
            a."EV_QTY_ID" = p."EV_QTY_ID"
        WHERE
            p."EV_QTY_EV_ID" = NEW."EV_QTY_EV_ID"
        AND
            NOT public."eq_EV_QTY_Event_Quantity"(p."EV_QTY_Event_Quantity", NEW."EV_QTY_Event_Quantity")
        AND
            a."EV_QTY_PositedAt" = _positing
        AND
            a."EV_QTY_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_QTY_Event_Quantity for: %', concat_ws(', ', NEW."EV_QTY_EV_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."EV_QTY_Event_Quantity_Annex" a
        WHERE
            a."EV_QTY_ID" = _posit
        AND
            a."EV_QTY_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."EV_QTY_Reliability" = 1
            FROM
                public."EV_QTY_Event_Quantity_Annex" a
            WHERE
                a."EV_QTY_ID" = _posit
            AND
                a."EV_QTY_PositedAt" <= _positing
            ORDER BY
                a."EV_QTY_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."EV_QTY_Event_Quantity_Annex" (
            "Metadata_EV_QTY",
            "EV_QTY_ID",
            "EV_QTY_PositedAt",
            "EV_QTY_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_QTY", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."EV_QTY_ID"
        FROM
            public."EV_QTY_Event_Quantity_Posit" p
        WHERE
            p."EV_QTY_EV_ID" = NEW."EV_QTY_EV_ID"
        AND
            NOT public."eq_EV_QTY_Event_Quantity"(p."EV_QTY_Event_Quantity", NEW."EV_QTY_Event_Quantity")
        AND
            coalesce((
                SELECT
                    a."EV_QTY_Reliability" = 1
                FROM
                    public."EV_QTY_Event_Quantity_Annex" a
                WHERE
                    a."EV_QTY_ID" = p."EV_QTY_ID"
                AND
                    a."EV_QTY_PositedAt" <= _positing
                ORDER BY
                    a."EV_QTY_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."EV_QTY_Event_Quantity_Annex" (
            "Metadata_EV_QTY",
            "EV_QTY_ID",
            "EV_QTY_PositedAt",
            "EV_QTY_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_QTY", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."EV_QTY_Event_Quantity_Posit" (
            "EV_QTY_EV_ID",
            "EV_QTY_Event_Quantity"
        )
        VALUES (
            NEW."EV_QTY_EV_ID",
            NEW."EV_QTY_Event_Quantity"
        )
        RETURNING "EV_QTY_ID" INTO _posit;
    END IF;
    INSERT INTO public."EV_QTY_Event_Quantity_Annex" (
        "Metadata_EV_QTY",
        "EV_QTY_ID",
        "EV_QTY_PositedAt",
        "EV_QTY_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_QTY", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_QTY_Event_Quantity" ON public."EV_QTY_Event_Quantity";
CREATE TRIGGER "it_EV_QTY_Event_Quantity"
INSTEAD OF INSERT ON public."EV_QTY_Event_Quantity"
FOR EACH ROW EXECUTE FUNCTION public."it_EV_QTY_Event_Quantity"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_PLC_Event_Place tells whether two values of EV_PLC_Event_Place are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_EV_PLC_Event_Place"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_PLC_Event_Place instead of INSERT trigger on EV_PLC_Event_Place
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_EV_PLC_Event_Place"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."EV_PLC_PositedAt", _now);
    _reliability := coalesce(NEW."EV_PLC_Reliability", 1);
    _changing := coalesce(NEW."EV_PLC_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."EV_PLC_ID"
    INTO
        _posit
    FROM
        public."EV_PLC_Event_Place_Posit" p
    WHERE
        p."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
    AND
        p."EV_PLC_ChangedAt" = _changing
    AND
        public."eq_EV_PLC_Event_Place"(p."EV_PLC_Event_Place", NEW."EV_PLC_Event_Place")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."EV_PLC_Event_Place_Annex" a
        WHERE
            a."EV_PLC_ID" = _posit
        AND
            a."EV_PLC_PositedAt" = _positing
        AND
            a."EV_PLC_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_PLC_Event_Place for: %', concat_ws(', ', NEW."EV_PLC_EV_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."EV_PLC_Event_Place_Posit" p
        JOIN
            public."EV_PLC_Event_Place_Annex" a
        ON
            a."EV_PLC_ID" = p."EV_PLC_ID"
        WHERE
            p."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
        AND
            p."EV_PLC_ChangedAt" = _changing
        AND
            NOT public."eq_EV_PLC_Event_Place"(p."EV_PLC_Event_Place", NEW."EV_PLC_Event_Place")
        AND
            a."EV_PLC_PositedAt" = _positing
        AND
            a."EV_PLC_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_PLC_Event_Place for: %', concat_ws(', ', NEW."EV_PLC_EV_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."EV_PLC_Event_Place_Annex" a
        WHERE
            a."EV_PLC_ID" = _posit
        AND
            a."EV_PLC_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."EV_PLC_Reliability" = 1
            FROM
                public."EV_PLC_Event_Place_Annex" a
            WHERE
                a."EV_PLC_ID" = _posit
            AND
                a."EV_PLC_PositedAt" <= _positing
            ORDER BY
                a."EV_PLC_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."EV_PLC_Event_Place_Annex" (
            "Metadata_EV_PLC",
            "EV_PLC_ID",
            "EV_PLC_PositedAt",
            "EV_PLC_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_PLC", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."EV_PLC_ID"
        FROM
            public."EV_PLC_Event_Place_Posit" p
        WHERE
            p."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
        AND
            p."EV_PLC_ChangedAt" = _changing
        AND
            NOT public."eq_EV_PLC_Event_Place"(p."EV_PLC_Event_Place", NEW."EV_PLC_Event_Place")
        AND
            coalesce((
                SELECT
                    a."EV_PLC_Reliability" = 1
                FROM
                    public."EV_PLC_Event_Place_Annex" a
                WHERE
                    a."EV_PLC_ID" = p."EV_PLC_ID"
                AND
                    a."EV_PLC_PositedAt" <= _positing
                ORDER BY
                    a."EV_PLC_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."EV_PLC_Event_Place_Annex" (
            "Metadata_EV_PLC",
            "EV_PLC_ID",
            "EV_PLC_PositedAt",
            "EV_PLC_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_PLC", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."EV_PLC_Event_Place"
            FROM
                public."EV_PLC_Event_Place_Posit" p
            WHERE
                p."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
            AND
                p."EV_PLC_ChangedAt" < _changing
            AND
                coalesce((
                    SELECT
                        a."EV_PLC_Reliability" = 1
                    FROM
                        public."EV_PLC_Event_Place_Annex" a
                    WHERE
                        a."EV_PLC_ID" = p."EV_PLC_ID"
                    AND
                        a."EV_PLC_PositedAt" <= _positing
                    ORDER BY
                        a."EV_PLC_PositedAt" DESC
                    LIMIT 1
                ), false)
            ORDER BY
                p."EV_PLC_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            public."eq_EV_PLC_Event_Place"(pre."EV_PLC_Event_Place", NEW."EV_PLC_Event_Place")
    ) THEN
        RAISE EXCEPTION 'Restatement in EV_PLC_Event_Place for: %', concat_ws(', ', NEW."EV_PLC_EV_ID", _changing, _positing);
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."EV_PLC_ID"
    INTO
        _following
    FROM
        public."EV_PLC_Event_Place_Posit" f
    WHERE
        f."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
    AND
        f."EV_PLC_ChangedAt" > _changing
    AND
        coalesce((
            SELECT
                a."EV_PLC_Reliability" = 1
            FROM
                public."EV_PLC_Event_Place_Annex" a
            WHERE
                a."EV_PLC_ID" = f."EV_PLC_ID"
            AND
                a."EV_PLC_PositedAt" <= _positing
            ORDER BY
                a."EV_PLC_PositedAt" DESC
            LIMIT 1
        ), false)
    ORDER BY
        f."EV_PLC_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND public."eq_EV_PLC_Event_Place"((
        SELECT x."EV_PLC_Event_Place" FROM public."EV_PLC_Event_Place_Posit" x WHERE x."EV_PLC_ID" = _following
    ), NEW."EV_PLC_Event_Place") THEN
        RAISE EXCEPTION 'Restatement in EV_PLC_Event_Place for: %', concat_ws(', ', NEW."EV_PLC_EV_ID", _changing, _positing);
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."EV_PLC_Event_Place_Posit" (
            "EV_PLC_EV_ID",
            "EV_PLC_ChangedAt",
            "EV_PLC_Event_Place"
        )
        VALUES (
            NEW."EV_PLC_EV_ID",
            _changing,
            NEW."EV_PLC_Event_Place"
        )
        RETURNING "EV_PLC_ID" INTO _posit;
    END IF;
    INSERT INTO public."EV_PLC_Event_Place_Annex" (
        "Metadata_EV_PLC",
        "EV_PLC_ID",
        "EV_PLC_PositedAt",
        "EV_PLC_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_PLC", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_PLC_Event_Place" ON public."EV_PLC_Event_Place";
CREATE TRIGGER "it_EV_PLC_Event_Place"
INSTEAD OF INSERT ON public."EV_PLC_Event_Place"
FOR EACH ROW EXECUTE FUNCTION public."it_EV_PLC_Event_Place"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_NAM_Subject_Name tells whether two values of SU_NAM_Subject_Name are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_NAM_Subject_Name"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NAM_Subject_Name instead of INSERT trigger on SU_NAM_Subject_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_NAM_Subject_Name"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_NAM_PositedAt", _now);
    _reliability := coalesce(NEW."SU_NAM_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."SU_NAM_ID"
    INTO
        _posit
    FROM
        public."SU_NAM_Subject_Name_Posit" p
    WHERE
        p."SU_NAM_SU_ID" = NEW."SU_NAM_SU_ID"
    AND
        public."eq_SU_NAM_Subject_Name"(p."SU_NAM_Subject_Name", NEW."SU_NAM_Subject_Name")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_NAM_Subject_Name_Annex" a
        WHERE
            a."SU_NAM_ID" = _posit
        AND
            a."SU_NAM_PositedAt" = _positing
        AND
            a."SU_NAM_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_NAM_Subject_Name for: %', concat_ws(', ', NEW."SU_NAM_SU_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_NAM_Subject_Name_Posit" p
        JOIN
            public."SU_NAM_Subject_Name_Annex" a
        ON
            a."SU_NAM_ID" = p."SU_NAM_ID"
        WHERE
            p."SU_NAM_SU_ID" = NEW."SU_NAM_SU_ID"
        AND
            NOT public."eq_SU_NAM_Subject_Name"(p."SU_NAM_Subject_Name", NEW."SU_NAM_Subject_Name")
        AND
            a."SU_NAM_PositedAt" = _positing
        AND
            a."SU_NAM_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_NAM_Subject_Name for: %', concat_ws(', ', NEW."SU_NAM_SU_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_NAM_Subject_Name_Annex" a
        WHERE
            a."SU_NAM_ID" = _posit
        AND
            a."SU_NAM_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_NAM_Reliability" = 1
            FROM
                public."SU_NAM_Subject_Name_Annex" a
            WHERE
                a."SU_NAM_ID" = _posit
            AND
                a."SU_NAM_PositedAt" <= _positing
            ORDER BY
                a."SU_NAM_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_NAM_Subject_Name_Annex" (
            "Metadata_SU_NAM",
            "SU_NAM_ID",
            "SU_NAM_PositedAt",
            "SU_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NAM", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_NAM_ID"
        FROM
            public."SU_NAM_Subject_Name_Posit" p
        WHERE
            p."SU_NAM_SU_ID" = NEW."SU_NAM_SU_ID"
        AND
            NOT public."eq_SU_NAM_Subject_Name"(p."SU_NAM_Subject_Name", NEW."SU_NAM_Subject_Name")
        AND
            coalesce((
                SELECT
                    a."SU_NAM_Reliability" = 1
                FROM
                    public."SU_NAM_Subject_Name_Annex" a
                WHERE
                    a."SU_NAM_ID" = p."SU_NAM_ID"
                AND
                    a."SU_NAM_PositedAt" <= _positing
                ORDER BY
                    a."SU_NAM_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_NAM_Subject_Name_Annex" (
            "Metadata_SU_NAM",
            "SU_NAM_ID",
            "SU_NAM_PositedAt",
            "SU_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NAM", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_NAM_Subject_Name_Posit" (
            "SU_NAM_SU_ID",
            "SU_NAM_Subject_Name"
        )
        VALUES (
            NEW."SU_NAM_SU_ID",
            NEW."SU_NAM_Subject_Name"
        )
        RETURNING "SU_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_NAM_Subject_Name_Annex" (
        "Metadata_SU_NAM",
        "SU_NAM_ID",
        "SU_NAM_PositedAt",
        "SU_NAM_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_NAM", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_NAM_Subject_Name" ON public."SU_NAM_Subject_Name";
CREATE TRIGGER "it_SU_NAM_Subject_Name"
INSTEAD OF INSERT ON public."SU_NAM_Subject_Name"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_NAM_Subject_Name"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_COD_Subject_Code tells whether two values of SU_COD_Subject_Code are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_COD_Subject_Code"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_COD_Subject_Code instead of INSERT trigger on SU_COD_Subject_Code
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_COD_Subject_Code"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_COD_PositedAt", _now);
    _reliability := coalesce(NEW."SU_COD_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."SU_COD_ID"
    INTO
        _posit
    FROM
        public."SU_COD_Subject_Code_Posit" p
    WHERE
        p."SU_COD_SU_ID" = NEW."SU_COD_SU_ID"
    AND
        public."eq_SU_COD_Subject_Code"(p."SU_COD_Subject_Code", NEW."SU_COD_Subject_Code")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_COD_Subject_Code_Annex" a
        WHERE
            a."SU_COD_ID" = _posit
        AND
            a."SU_COD_PositedAt" = _positing
        AND
            a."SU_COD_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_COD_Subject_Code for: %', concat_ws(', ', NEW."SU_COD_SU_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_COD_Subject_Code_Posit" p
        JOIN
            public."SU_COD_Subject_Code_Annex" a
        ON
            a."SU_COD_ID" = p."SU_COD_ID"
        WHERE
            p."SU_COD_SU_ID" = NEW."SU_COD_SU_ID"
        AND
            NOT public."eq_SU_COD_Subject_Code"(p."SU_COD_Subject_Code", NEW."SU_COD_Subject_Code")
        AND
            a."SU_COD_PositedAt" = _positing
        AND
            a."SU_COD_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_COD_Subject_Code for: %', concat_ws(', ', NEW."SU_COD_SU_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_COD_Subject_Code_Annex" a
        WHERE
            a."SU_COD_ID" = _posit
        AND
            a."SU_COD_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_COD_Reliability" = 1
            FROM
                public."SU_COD_Subject_Code_Annex" a
            WHERE
                a."SU_COD_ID" = _posit
            AND
                a."SU_COD_PositedAt" <= _positing
            ORDER BY
                a."SU_COD_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_COD_Subject_Code_Annex" (
            "Metadata_SU_COD",
            "SU_COD_ID",
            "SU_COD_PositedAt",
            "SU_COD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_COD", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_COD_ID"
        FROM
            public."SU_COD_Subject_Code_Posit" p
        WHERE
            p."SU_COD_SU_ID" = NEW."SU_COD_SU_ID"
        AND
            NOT public."eq_SU_COD_Subject_Code"(p."SU_COD_Subject_Code", NEW."SU_COD_Subject_Code")
        AND
            coalesce((
                SELECT
                    a."SU_COD_Reliability" = 1
                FROM
                    public."SU_COD_Subject_Code_Annex" a
                WHERE
                    a."SU_COD_ID" = p."SU_COD_ID"
                AND
                    a."SU_COD_PositedAt" <= _positing
                ORDER BY
                    a."SU_COD_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_COD_Subject_Code_Annex" (
            "Metadata_SU_COD",
            "SU_COD_ID",
            "SU_COD_PositedAt",
            "SU_COD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_COD", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_COD_Subject_Code_Posit" (
            "SU_COD_SU_ID",
            "SU_COD_Subject_Code"
        )
        VALUES (
            NEW."SU_COD_SU_ID",
            NEW."SU_COD_Subject_Code"
        )
        RETURNING "SU_COD_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_COD_Subject_Code_Annex" (
        "Metadata_SU_COD",
        "SU_COD_ID",
        "SU_COD_PositedAt",
        "SU_COD_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_COD", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_COD_Subject_Code" ON public."SU_COD_Subject_Code";
CREATE TRIGGER "it_SU_COD_Subject_Code"
INSTEAD OF INSERT ON public."SU_COD_Subject_Code"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_COD_Subject_Code"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_GRD_Subject_Grade tells whether two values of SU_GRD_Subject_Grade are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_GRD_Subject_Grade"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_GRD_Subject_Grade instead of INSERT trigger on SU_GRD_Subject_Grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_GRD_Subject_Grade"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_GRD_PositedAt", _now);
    _reliability := coalesce(NEW."SU_GRD_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."SU_GRD_ID"
    INTO
        _posit
    FROM
        public."SU_GRD_Subject_Grade_Posit" p
    WHERE
        p."SU_GRD_SU_ID" = NEW."SU_GRD_SU_ID"
    AND
        public."eq_SU_GRD_Subject_Grade"(p."SU_GRD_GRD_ID", NEW."SU_GRD_GRD_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_GRD_Subject_Grade_Annex" a
        WHERE
            a."SU_GRD_ID" = _posit
        AND
            a."SU_GRD_PositedAt" = _positing
        AND
            a."SU_GRD_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_GRD_Subject_Grade for: %', concat_ws(', ', NEW."SU_GRD_SU_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_GRD_Subject_Grade_Posit" p
        JOIN
            public."SU_GRD_Subject_Grade_Annex" a
        ON
            a."SU_GRD_ID" = p."SU_GRD_ID"
        WHERE
            p."SU_GRD_SU_ID" = NEW."SU_GRD_SU_ID"
        AND
            NOT public."eq_SU_GRD_Subject_Grade"(p."SU_GRD_GRD_ID", NEW."SU_GRD_GRD_ID")
        AND
            a."SU_GRD_PositedAt" = _positing
        AND
            a."SU_GRD_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_GRD_Subject_Grade for: %', concat_ws(', ', NEW."SU_GRD_SU_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_GRD_Subject_Grade_Annex" a
        WHERE
            a."SU_GRD_ID" = _posit
        AND
            a."SU_GRD_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_GRD_Reliability" = 1
            FROM
                public."SU_GRD_Subject_Grade_Annex" a
            WHERE
                a."SU_GRD_ID" = _posit
            AND
                a."SU_GRD_PositedAt" <= _positing
            ORDER BY
                a."SU_GRD_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_GRD_Subject_Grade_Annex" (
            "Metadata_SU_GRD",
            "SU_GRD_ID",
            "SU_GRD_PositedAt",
            "SU_GRD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_GRD", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_GRD_ID"
        FROM
            public."SU_GRD_Subject_Grade_Posit" p
        WHERE
            p."SU_GRD_SU_ID" = NEW."SU_GRD_SU_ID"
        AND
            NOT public."eq_SU_GRD_Subject_Grade"(p."SU_GRD_GRD_ID", NEW."SU_GRD_GRD_ID")
        AND
            coalesce((
                SELECT
                    a."SU_GRD_Reliability" = 1
                FROM
                    public."SU_GRD_Subject_Grade_Annex" a
                WHERE
                    a."SU_GRD_ID" = p."SU_GRD_ID"
                AND
                    a."SU_GRD_PositedAt" <= _positing
                ORDER BY
                    a."SU_GRD_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_GRD_Subject_Grade_Annex" (
            "Metadata_SU_GRD",
            "SU_GRD_ID",
            "SU_GRD_PositedAt",
            "SU_GRD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_GRD", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_GRD_Subject_Grade_Posit" (
            "SU_GRD_SU_ID",
            "SU_GRD_GRD_ID"
        )
        VALUES (
            NEW."SU_GRD_SU_ID",
            NEW."SU_GRD_GRD_ID"
        )
        RETURNING "SU_GRD_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_GRD_Subject_Grade_Annex" (
        "Metadata_SU_GRD",
        "SU_GRD_ID",
        "SU_GRD_PositedAt",
        "SU_GRD_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_GRD", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_GRD_Subject_Grade" ON public."SU_GRD_Subject_Grade";
CREATE TRIGGER "it_SU_GRD_Subject_Grade"
INSTEAD OF INSERT ON public."SU_GRD_Subject_Grade"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_GRD_Subject_Grade"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_NOT_Subject_Note tells whether two values of SU_NOT_Subject_Note are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_NOT_Subject_Note"(
    l text,
    r text
)
RETURNS boolean
AS
$$
    SELECT md5(l::text) = md5(r::text)
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NOT_Subject_Note instead of INSERT trigger on SU_NOT_Subject_Note
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_NOT_Subject_Note"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_NOT_PositedAt", _now);
    _reliability := coalesce(NEW."SU_NOT_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."SU_NOT_ID"
    INTO
        _posit
    FROM
        public."SU_NOT_Subject_Note_Posit" p
    WHERE
        p."SU_NOT_SU_ID" = NEW."SU_NOT_SU_ID"
    AND
        public."eq_SU_NOT_Subject_Note"(p."SU_NOT_Subject_Note", NEW."SU_NOT_Subject_Note")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_NOT_Subject_Note_Annex" a
        WHERE
            a."SU_NOT_ID" = _posit
        AND
            a."SU_NOT_PositedAt" = _positing
        AND
            a."SU_NOT_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_NOT_Subject_Note for: %', concat_ws(', ', NEW."SU_NOT_SU_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_NOT_Subject_Note_Posit" p
        JOIN
            public."SU_NOT_Subject_Note_Annex" a
        ON
            a."SU_NOT_ID" = p."SU_NOT_ID"
        WHERE
            p."SU_NOT_SU_ID" = NEW."SU_NOT_SU_ID"
        AND
            NOT public."eq_SU_NOT_Subject_Note"(p."SU_NOT_Subject_Note", NEW."SU_NOT_Subject_Note")
        AND
            a."SU_NOT_PositedAt" = _positing
        AND
            a."SU_NOT_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_NOT_Subject_Note for: %', concat_ws(', ', NEW."SU_NOT_SU_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_NOT_Subject_Note_Annex" a
        WHERE
            a."SU_NOT_ID" = _posit
        AND
            a."SU_NOT_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_NOT_Reliability" = 1
            FROM
                public."SU_NOT_Subject_Note_Annex" a
            WHERE
                a."SU_NOT_ID" = _posit
            AND
                a."SU_NOT_PositedAt" <= _positing
            ORDER BY
                a."SU_NOT_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_NOT_Subject_Note_Annex" (
            "Metadata_SU_NOT",
            "SU_NOT_ID",
            "SU_NOT_PositedAt",
            "SU_NOT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NOT", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_NOT_ID"
        FROM
            public."SU_NOT_Subject_Note_Posit" p
        WHERE
            p."SU_NOT_SU_ID" = NEW."SU_NOT_SU_ID"
        AND
            NOT public."eq_SU_NOT_Subject_Note"(p."SU_NOT_Subject_Note", NEW."SU_NOT_Subject_Note")
        AND
            coalesce((
                SELECT
                    a."SU_NOT_Reliability" = 1
                FROM
                    public."SU_NOT_Subject_Note_Annex" a
                WHERE
                    a."SU_NOT_ID" = p."SU_NOT_ID"
                AND
                    a."SU_NOT_PositedAt" <= _positing
                ORDER BY
                    a."SU_NOT_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_NOT_Subject_Note_Annex" (
            "Metadata_SU_NOT",
            "SU_NOT_ID",
            "SU_NOT_PositedAt",
            "SU_NOT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NOT", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_NOT_Subject_Note_Posit" (
            "SU_NOT_SU_ID",
            "SU_NOT_Subject_Note"
        )
        VALUES (
            NEW."SU_NOT_SU_ID",
            NEW."SU_NOT_Subject_Note"
        )
        RETURNING "SU_NOT_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_NOT_Subject_Note_Annex" (
        "Metadata_SU_NOT",
        "SU_NOT_ID",
        "SU_NOT_PositedAt",
        "SU_NOT_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_NOT", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_NOT_Subject_Note" ON public."SU_NOT_Subject_Note";
CREATE TRIGGER "it_SU_NOT_Subject_Note"
INSTEAD OF INSERT ON public."SU_NOT_Subject_Note"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_NOT_Subject_Note"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_TTL_Subject_Title tells whether two values of SU_TTL_Subject_Title are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_TTL_Subject_Title"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TTL_Subject_Title instead of INSERT trigger on SU_TTL_Subject_Title
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_TTL_Subject_Title"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_TTL_PositedAt", _now);
    _reliability := coalesce(NEW."SU_TTL_Reliability", 1);
    _changing := coalesce(NEW."SU_TTL_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_TTL_ID"
    INTO
        _posit
    FROM
        public."SU_TTL_Subject_Title_Posit" p
    WHERE
        p."SU_TTL_SU_ID" = NEW."SU_TTL_SU_ID"
    AND
        p."SU_TTL_ChangedAt" = _changing
    AND
        public."eq_SU_TTL_Subject_Title"(p."SU_TTL_Subject_Title", NEW."SU_TTL_Subject_Title")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TTL_Subject_Title_Annex" a
        WHERE
            a."SU_TTL_ID" = _posit
        AND
            a."SU_TTL_PositedAt" = _positing
        AND
            a."SU_TTL_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TTL_Subject_Title for: %', concat_ws(', ', NEW."SU_TTL_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TTL_Subject_Title_Posit" p
        JOIN
            public."SU_TTL_Subject_Title_Annex" a
        ON
            a."SU_TTL_ID" = p."SU_TTL_ID"
        WHERE
            p."SU_TTL_SU_ID" = NEW."SU_TTL_SU_ID"
        AND
            p."SU_TTL_ChangedAt" = _changing
        AND
            NOT public."eq_SU_TTL_Subject_Title"(p."SU_TTL_Subject_Title", NEW."SU_TTL_Subject_Title")
        AND
            a."SU_TTL_PositedAt" = _positing
        AND
            a."SU_TTL_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TTL_Subject_Title for: %', concat_ws(', ', NEW."SU_TTL_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TTL_Subject_Title_Annex" a
        WHERE
            a."SU_TTL_ID" = _posit
        AND
            a."SU_TTL_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_TTL_Reliability" = 1
            FROM
                public."SU_TTL_Subject_Title_Annex" a
            WHERE
                a."SU_TTL_ID" = _posit
            AND
                a."SU_TTL_PositedAt" <= _positing
            ORDER BY
                a."SU_TTL_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_TTL_Subject_Title_Annex" (
            "Metadata_SU_TTL",
            "SU_TTL_ID",
            "SU_TTL_PositedAt",
            "SU_TTL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TTL", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_TTL_ID"
        FROM
            public."SU_TTL_Subject_Title_Posit" p
        WHERE
            p."SU_TTL_SU_ID" = NEW."SU_TTL_SU_ID"
        AND
            p."SU_TTL_ChangedAt" = _changing
        AND
            NOT public."eq_SU_TTL_Subject_Title"(p."SU_TTL_Subject_Title", NEW."SU_TTL_Subject_Title")
        AND
            coalesce((
                SELECT
                    a."SU_TTL_Reliability" = 1
                FROM
                    public."SU_TTL_Subject_Title_Annex" a
                WHERE
                    a."SU_TTL_ID" = p."SU_TTL_ID"
                AND
                    a."SU_TTL_PositedAt" <= _positing
                ORDER BY
                    a."SU_TTL_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_TTL_Subject_Title_Annex" (
            "Metadata_SU_TTL",
            "SU_TTL_ID",
            "SU_TTL_PositedAt",
            "SU_TTL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TTL", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_TTL_Subject_Title_Posit" (
            "SU_TTL_SU_ID",
            "SU_TTL_ChangedAt",
            "SU_TTL_Subject_Title"
        )
        VALUES (
            NEW."SU_TTL_SU_ID",
            _changing,
            NEW."SU_TTL_Subject_Title"
        )
        RETURNING "SU_TTL_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_TTL_Subject_Title_Annex" (
        "Metadata_SU_TTL",
        "SU_TTL_ID",
        "SU_TTL_PositedAt",
        "SU_TTL_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_TTL", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_TTL_Subject_Title" ON public."SU_TTL_Subject_Title";
CREATE TRIGGER "it_SU_TTL_Subject_Title"
INSTEAD OF INSERT ON public."SU_TTL_Subject_Title"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_TTL_Subject_Title"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_STA_Subject_State tells whether two values of SU_STA_Subject_State are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_STA_Subject_State"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_STA_Subject_State instead of INSERT trigger on SU_STA_Subject_State
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_STA_Subject_State"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_STA_PositedAt", _now);
    _reliability := coalesce(NEW."SU_STA_Reliability", 1);
    _changing := coalesce(NEW."SU_STA_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_STA_ID"
    INTO
        _posit
    FROM
        public."SU_STA_Subject_State_Posit" p
    WHERE
        p."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
    AND
        p."SU_STA_ChangedAt" = _changing
    AND
        public."eq_SU_STA_Subject_State"(p."SU_STA_Subject_State", NEW."SU_STA_Subject_State")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_STA_Subject_State_Annex" a
        WHERE
            a."SU_STA_ID" = _posit
        AND
            a."SU_STA_PositedAt" = _positing
        AND
            a."SU_STA_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_STA_Subject_State for: %', concat_ws(', ', NEW."SU_STA_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_STA_Subject_State_Posit" p
        JOIN
            public."SU_STA_Subject_State_Annex" a
        ON
            a."SU_STA_ID" = p."SU_STA_ID"
        WHERE
            p."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
        AND
            p."SU_STA_ChangedAt" = _changing
        AND
            NOT public."eq_SU_STA_Subject_State"(p."SU_STA_Subject_State", NEW."SU_STA_Subject_State")
        AND
            a."SU_STA_PositedAt" = _positing
        AND
            a."SU_STA_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_STA_Subject_State for: %', concat_ws(', ', NEW."SU_STA_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_STA_Subject_State_Annex" a
        WHERE
            a."SU_STA_ID" = _posit
        AND
            a."SU_STA_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_STA_Reliability" = 1
            FROM
                public."SU_STA_Subject_State_Annex" a
            WHERE
                a."SU_STA_ID" = _posit
            AND
                a."SU_STA_PositedAt" <= _positing
            ORDER BY
                a."SU_STA_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_STA_Subject_State_Annex" (
            "Metadata_SU_STA",
            "SU_STA_ID",
            "SU_STA_PositedAt",
            "SU_STA_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_STA", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_STA_ID"
        FROM
            public."SU_STA_Subject_State_Posit" p
        WHERE
            p."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
        AND
            p."SU_STA_ChangedAt" = _changing
        AND
            NOT public."eq_SU_STA_Subject_State"(p."SU_STA_Subject_State", NEW."SU_STA_Subject_State")
        AND
            coalesce((
                SELECT
                    a."SU_STA_Reliability" = 1
                FROM
                    public."SU_STA_Subject_State_Annex" a
                WHERE
                    a."SU_STA_ID" = p."SU_STA_ID"
                AND
                    a."SU_STA_PositedAt" <= _positing
                ORDER BY
                    a."SU_STA_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_STA_Subject_State_Annex" (
            "Metadata_SU_STA",
            "SU_STA_ID",
            "SU_STA_PositedAt",
            "SU_STA_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_STA", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_STA_Subject_State"
            FROM
                public."SU_STA_Subject_State_Posit" p
            WHERE
                p."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
            AND
                p."SU_STA_ChangedAt" < _changing
            AND
                coalesce((
                    SELECT
                        a."SU_STA_Reliability" = 1
                    FROM
                        public."SU_STA_Subject_State_Annex" a
                    WHERE
                        a."SU_STA_ID" = p."SU_STA_ID"
                    AND
                        a."SU_STA_PositedAt" <= _positing
                    ORDER BY
                        a."SU_STA_PositedAt" DESC
                    LIMIT 1
                ), false)
            ORDER BY
                p."SU_STA_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            public."eq_SU_STA_Subject_State"(pre."SU_STA_Subject_State", NEW."SU_STA_Subject_State")
    ) THEN
        RAISE EXCEPTION 'Restatement in SU_STA_Subject_State for: %', concat_ws(', ', NEW."SU_STA_SU_ID", _changing, _positing);
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."SU_STA_ID"
    INTO
        _following
    FROM
        public."SU_STA_Subject_State_Posit" f
    WHERE
        f."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
    AND
        f."SU_STA_ChangedAt" > _changing
    AND
        coalesce((
            SELECT
                a."SU_STA_Reliability" = 1
            FROM
                public."SU_STA_Subject_State_Annex" a
            WHERE
                a."SU_STA_ID" = f."SU_STA_ID"
            AND
                a."SU_STA_PositedAt" <= _positing
            ORDER BY
                a."SU_STA_PositedAt" DESC
            LIMIT 1
        ), false)
    ORDER BY
        f."SU_STA_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND public."eq_SU_STA_Subject_State"((
        SELECT x."SU_STA_Subject_State" FROM public."SU_STA_Subject_State_Posit" x WHERE x."SU_STA_ID" = _following
    ), NEW."SU_STA_Subject_State") THEN
        RAISE EXCEPTION 'Restatement in SU_STA_Subject_State for: %', concat_ws(', ', NEW."SU_STA_SU_ID", _changing, _positing);
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_STA_Subject_State_Posit" (
            "SU_STA_SU_ID",
            "SU_STA_ChangedAt",
            "SU_STA_Subject_State"
        )
        VALUES (
            NEW."SU_STA_SU_ID",
            _changing,
            NEW."SU_STA_Subject_State"
        )
        RETURNING "SU_STA_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_STA_Subject_State_Annex" (
        "Metadata_SU_STA",
        "SU_STA_ID",
        "SU_STA_PositedAt",
        "SU_STA_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_STA", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_STA_Subject_State" ON public."SU_STA_Subject_State";
CREATE TRIGGER "it_SU_STA_Subject_State"
INSTEAD OF INSERT ON public."SU_STA_Subject_State"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_STA_Subject_State"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_LBL_Subject_Label tells whether two values of SU_LBL_Subject_Label are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_LBL_Subject_Label"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LBL_Subject_Label instead of INSERT trigger on SU_LBL_Subject_Label
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_LBL_Subject_Label"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_LBL_PositedAt", _now);
    _reliability := coalesce(NEW."SU_LBL_Reliability", 1);
    _changing := coalesce(NEW."SU_LBL_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_LBL_ID"
    INTO
        _posit
    FROM
        public."SU_LBL_Subject_Label_Posit" p
    WHERE
        p."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
    AND
        p."SU_LBL_ChangedAt" = _changing
    AND
        public."eq_SU_LBL_Subject_Label"(p."SU_LBL_Subject_Label", NEW."SU_LBL_Subject_Label")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_LBL_Subject_Label_Annex" a
        WHERE
            a."SU_LBL_ID" = _posit
        AND
            a."SU_LBL_PositedAt" = _positing
        AND
            a."SU_LBL_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_LBL_Subject_Label for: %', concat_ws(', ', NEW."SU_LBL_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_LBL_Subject_Label_Posit" p
        JOIN
            public."SU_LBL_Subject_Label_Annex" a
        ON
            a."SU_LBL_ID" = p."SU_LBL_ID"
        WHERE
            p."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
        AND
            p."SU_LBL_ChangedAt" = _changing
        AND
            NOT public."eq_SU_LBL_Subject_Label"(p."SU_LBL_Subject_Label", NEW."SU_LBL_Subject_Label")
        AND
            a."SU_LBL_PositedAt" = _positing
        AND
            a."SU_LBL_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_LBL_Subject_Label for: %', concat_ws(', ', NEW."SU_LBL_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_LBL_Subject_Label_Annex" a
        WHERE
            a."SU_LBL_ID" = _posit
        AND
            a."SU_LBL_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_LBL_Reliability" = 1
            FROM
                public."SU_LBL_Subject_Label_Annex" a
            WHERE
                a."SU_LBL_ID" = _posit
            AND
                a."SU_LBL_PositedAt" <= _positing
            ORDER BY
                a."SU_LBL_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_LBL_Subject_Label_Annex" (
            "Metadata_SU_LBL",
            "SU_LBL_ID",
            "SU_LBL_PositedAt",
            "SU_LBL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LBL", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_LBL_ID"
        FROM
            public."SU_LBL_Subject_Label_Posit" p
        WHERE
            p."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
        AND
            p."SU_LBL_ChangedAt" = _changing
        AND
            NOT public."eq_SU_LBL_Subject_Label"(p."SU_LBL_Subject_Label", NEW."SU_LBL_Subject_Label")
        AND
            coalesce((
                SELECT
                    a."SU_LBL_Reliability" = 1
                FROM
                    public."SU_LBL_Subject_Label_Annex" a
                WHERE
                    a."SU_LBL_ID" = p."SU_LBL_ID"
                AND
                    a."SU_LBL_PositedAt" <= _positing
                ORDER BY
                    a."SU_LBL_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_LBL_Subject_Label_Annex" (
            "Metadata_SU_LBL",
            "SU_LBL_ID",
            "SU_LBL_PositedAt",
            "SU_LBL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LBL", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_LBL_Subject_Label"
            FROM
                public."SU_LBL_Subject_Label_Posit" p
            WHERE
                p."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
            AND
                p."SU_LBL_ChangedAt" < _changing
            AND
                coalesce((
                    SELECT
                        a."SU_LBL_Reliability" = 1
                    FROM
                        public."SU_LBL_Subject_Label_Annex" a
                    WHERE
                        a."SU_LBL_ID" = p."SU_LBL_ID"
                    AND
                        a."SU_LBL_PositedAt" <= _positing
                    ORDER BY
                        a."SU_LBL_PositedAt" DESC
                    LIMIT 1
                ), false)
            ORDER BY
                p."SU_LBL_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            public."eq_SU_LBL_Subject_Label"(pre."SU_LBL_Subject_Label", NEW."SU_LBL_Subject_Label")
    ) THEN
        -- (an idempotent attribute does not store it)
        RETURN NULL;
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."SU_LBL_ID"
    INTO
        _following
    FROM
        public."SU_LBL_Subject_Label_Posit" f
    WHERE
        f."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
    AND
        f."SU_LBL_ChangedAt" > _changing
    AND
        coalesce((
            SELECT
                a."SU_LBL_Reliability" = 1
            FROM
                public."SU_LBL_Subject_Label_Annex" a
            WHERE
                a."SU_LBL_ID" = f."SU_LBL_ID"
            AND
                a."SU_LBL_PositedAt" <= _positing
            ORDER BY
                a."SU_LBL_PositedAt" DESC
            LIMIT 1
        ), false)
    ORDER BY
        f."SU_LBL_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND public."eq_SU_LBL_Subject_Label"((
        SELECT x."SU_LBL_Subject_Label" FROM public."SU_LBL_Subject_Label_Posit" x WHERE x."SU_LBL_ID" = _following
    ), NEW."SU_LBL_Subject_Label") THEN
        -- (an idempotent attribute retracts it)
        INSERT INTO public."SU_LBL_Subject_Label_Annex" (
            "Metadata_SU_LBL",
            "SU_LBL_ID",
            "SU_LBL_PositedAt",
            "SU_LBL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LBL", 0),
            _following,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_LBL_Subject_Label_Posit" (
            "SU_LBL_SU_ID",
            "SU_LBL_ChangedAt",
            "SU_LBL_Subject_Label"
        )
        VALUES (
            NEW."SU_LBL_SU_ID",
            _changing,
            NEW."SU_LBL_Subject_Label"
        )
        RETURNING "SU_LBL_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_LBL_Subject_Label_Annex" (
        "Metadata_SU_LBL",
        "SU_LBL_ID",
        "SU_LBL_PositedAt",
        "SU_LBL_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_LBL", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_LBL_Subject_Label" ON public."SU_LBL_Subject_Label";
CREATE TRIGGER "it_SU_LBL_Subject_Label"
INSTEAD OF INSERT ON public."SU_LBL_Subject_Label"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_LBL_Subject_Label"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_TAG_Subject_Tag tells whether two values of SU_TAG_Subject_Tag are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_TAG_Subject_Tag"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TAG_Subject_Tag instead of INSERT trigger on SU_TAG_Subject_Tag
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_TAG_Subject_Tag"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_TAG_PositedAt", _now);
    _reliability := coalesce(NEW."SU_TAG_Reliability", 1);
    _changing := coalesce(NEW."SU_TAG_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_TAG_ID"
    INTO
        _posit
    FROM
        public."SU_TAG_Subject_Tag_Posit" p
    WHERE
        p."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
    AND
        p."SU_TAG_ChangedAt" = _changing
    AND
        public."eq_SU_TAG_Subject_Tag"(p."SU_TAG_Subject_Tag", NEW."SU_TAG_Subject_Tag")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TAG_Subject_Tag_Annex" a
        WHERE
            a."SU_TAG_ID" = _posit
        AND
            a."SU_TAG_PositedAt" = _positing
        AND
            a."SU_TAG_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TAG_Subject_Tag for: %', concat_ws(', ', NEW."SU_TAG_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TAG_Subject_Tag_Posit" p
        JOIN
            public."SU_TAG_Subject_Tag_Annex" a
        ON
            a."SU_TAG_ID" = p."SU_TAG_ID"
        WHERE
            p."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
        AND
            p."SU_TAG_ChangedAt" = _changing
        AND
            NOT public."eq_SU_TAG_Subject_Tag"(p."SU_TAG_Subject_Tag", NEW."SU_TAG_Subject_Tag")
        AND
            a."SU_TAG_PositedAt" = _positing
        AND
            a."SU_TAG_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TAG_Subject_Tag for: %', concat_ws(', ', NEW."SU_TAG_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TAG_Subject_Tag_Annex" a
        WHERE
            a."SU_TAG_ID" = _posit
        AND
            a."SU_TAG_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_TAG_Reliability" = 1
            FROM
                public."SU_TAG_Subject_Tag_Annex" a
            WHERE
                a."SU_TAG_ID" = _posit
            AND
                a."SU_TAG_PositedAt" <= _positing
            ORDER BY
                a."SU_TAG_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_TAG_Subject_Tag_Annex" (
            "Metadata_SU_TAG",
            "SU_TAG_ID",
            "SU_TAG_PositedAt",
            "SU_TAG_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TAG", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_TAG_ID"
        FROM
            public."SU_TAG_Subject_Tag_Posit" p
        WHERE
            p."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
        AND
            p."SU_TAG_ChangedAt" = _changing
        AND
            NOT public."eq_SU_TAG_Subject_Tag"(p."SU_TAG_Subject_Tag", NEW."SU_TAG_Subject_Tag")
        AND
            coalesce((
                SELECT
                    a."SU_TAG_Reliability" = 1
                FROM
                    public."SU_TAG_Subject_Tag_Annex" a
                WHERE
                    a."SU_TAG_ID" = p."SU_TAG_ID"
                AND
                    a."SU_TAG_PositedAt" <= _positing
                ORDER BY
                    a."SU_TAG_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_TAG_Subject_Tag_Annex" (
            "Metadata_SU_TAG",
            "SU_TAG_ID",
            "SU_TAG_PositedAt",
            "SU_TAG_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TAG", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_TAG_Subject_Tag"
            FROM
                public."SU_TAG_Subject_Tag_Posit" p
            WHERE
                p."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
            AND
                p."SU_TAG_ChangedAt" < _changing
            AND
                coalesce((
                    SELECT
                        a."SU_TAG_Reliability" = 1
                    FROM
                        public."SU_TAG_Subject_Tag_Annex" a
                    WHERE
                        a."SU_TAG_ID" = p."SU_TAG_ID"
                    AND
                        a."SU_TAG_PositedAt" <= _positing
                    ORDER BY
                        a."SU_TAG_PositedAt" DESC
                    LIMIT 1
                ), false)
            ORDER BY
                p."SU_TAG_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            public."eq_SU_TAG_Subject_Tag"(pre."SU_TAG_Subject_Tag", NEW."SU_TAG_Subject_Tag")
    ) THEN
        -- (an idempotent attribute does not store it)
        RETURN NULL;
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."SU_TAG_ID"
    INTO
        _following
    FROM
        public."SU_TAG_Subject_Tag_Posit" f
    WHERE
        f."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
    AND
        f."SU_TAG_ChangedAt" > _changing
    AND
        coalesce((
            SELECT
                a."SU_TAG_Reliability" = 1
            FROM
                public."SU_TAG_Subject_Tag_Annex" a
            WHERE
                a."SU_TAG_ID" = f."SU_TAG_ID"
            AND
                a."SU_TAG_PositedAt" <= _positing
            ORDER BY
                a."SU_TAG_PositedAt" DESC
            LIMIT 1
        ), false)
    ORDER BY
        f."SU_TAG_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND public."eq_SU_TAG_Subject_Tag"((
        SELECT x."SU_TAG_Subject_Tag" FROM public."SU_TAG_Subject_Tag_Posit" x WHERE x."SU_TAG_ID" = _following
    ), NEW."SU_TAG_Subject_Tag") THEN
        -- (an idempotent attribute retracts it)
        INSERT INTO public."SU_TAG_Subject_Tag_Annex" (
            "Metadata_SU_TAG",
            "SU_TAG_ID",
            "SU_TAG_PositedAt",
            "SU_TAG_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TAG", 0),
            _following,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_TAG_Subject_Tag_Posit" (
            "SU_TAG_SU_ID",
            "SU_TAG_ChangedAt",
            "SU_TAG_Subject_Tag"
        )
        VALUES (
            NEW."SU_TAG_SU_ID",
            _changing,
            NEW."SU_TAG_Subject_Tag"
        )
        RETURNING "SU_TAG_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_TAG_Subject_Tag_Annex" (
        "Metadata_SU_TAG",
        "SU_TAG_ID",
        "SU_TAG_PositedAt",
        "SU_TAG_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_TAG", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_TAG_Subject_Tag" ON public."SU_TAG_Subject_Tag";
CREATE TRIGGER "it_SU_TAG_Subject_Tag"
INSTEAD OF INSERT ON public."SU_TAG_Subject_Tag"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_TAG_Subject_Tag"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_LVL_Subject_Level tells whether two values of SU_LVL_Subject_Level are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_LVL_Subject_Level"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LVL_Subject_Level instead of INSERT trigger on SU_LVL_Subject_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_LVL_Subject_Level"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_LVL_PositedAt", _now);
    _reliability := coalesce(NEW."SU_LVL_Reliability", 1);
    _changing := coalesce(NEW."SU_LVL_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_LVL_ID"
    INTO
        _posit
    FROM
        public."SU_LVL_Subject_Level_Posit" p
    WHERE
        p."SU_LVL_SU_ID" = NEW."SU_LVL_SU_ID"
    AND
        p."SU_LVL_ChangedAt" = _changing
    AND
        public."eq_SU_LVL_Subject_Level"(p."SU_LVL_GRD_ID", NEW."SU_LVL_GRD_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_LVL_Subject_Level_Annex" a
        WHERE
            a."SU_LVL_ID" = _posit
        AND
            a."SU_LVL_PositedAt" = _positing
        AND
            a."SU_LVL_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_LVL_Subject_Level for: %', concat_ws(', ', NEW."SU_LVL_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_LVL_Subject_Level_Posit" p
        JOIN
            public."SU_LVL_Subject_Level_Annex" a
        ON
            a."SU_LVL_ID" = p."SU_LVL_ID"
        WHERE
            p."SU_LVL_SU_ID" = NEW."SU_LVL_SU_ID"
        AND
            p."SU_LVL_ChangedAt" = _changing
        AND
            NOT public."eq_SU_LVL_Subject_Level"(p."SU_LVL_GRD_ID", NEW."SU_LVL_GRD_ID")
        AND
            a."SU_LVL_PositedAt" = _positing
        AND
            a."SU_LVL_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_LVL_Subject_Level for: %', concat_ws(', ', NEW."SU_LVL_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_LVL_Subject_Level_Annex" a
        WHERE
            a."SU_LVL_ID" = _posit
        AND
            a."SU_LVL_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_LVL_Reliability" = 1
            FROM
                public."SU_LVL_Subject_Level_Annex" a
            WHERE
                a."SU_LVL_ID" = _posit
            AND
                a."SU_LVL_PositedAt" <= _positing
            ORDER BY
                a."SU_LVL_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_LVL_Subject_Level_Annex" (
            "Metadata_SU_LVL",
            "SU_LVL_ID",
            "SU_LVL_PositedAt",
            "SU_LVL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LVL", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_LVL_ID"
        FROM
            public."SU_LVL_Subject_Level_Posit" p
        WHERE
            p."SU_LVL_SU_ID" = NEW."SU_LVL_SU_ID"
        AND
            p."SU_LVL_ChangedAt" = _changing
        AND
            NOT public."eq_SU_LVL_Subject_Level"(p."SU_LVL_GRD_ID", NEW."SU_LVL_GRD_ID")
        AND
            coalesce((
                SELECT
                    a."SU_LVL_Reliability" = 1
                FROM
                    public."SU_LVL_Subject_Level_Annex" a
                WHERE
                    a."SU_LVL_ID" = p."SU_LVL_ID"
                AND
                    a."SU_LVL_PositedAt" <= _positing
                ORDER BY
                    a."SU_LVL_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_LVL_Subject_Level_Annex" (
            "Metadata_SU_LVL",
            "SU_LVL_ID",
            "SU_LVL_PositedAt",
            "SU_LVL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LVL", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_LVL_Subject_Level_Posit" (
            "SU_LVL_SU_ID",
            "SU_LVL_ChangedAt",
            "SU_LVL_GRD_ID"
        )
        VALUES (
            NEW."SU_LVL_SU_ID",
            _changing,
            NEW."SU_LVL_GRD_ID"
        )
        RETURNING "SU_LVL_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_LVL_Subject_Level_Annex" (
        "Metadata_SU_LVL",
        "SU_LVL_ID",
        "SU_LVL_PositedAt",
        "SU_LVL_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_LVL", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_LVL_Subject_Level" ON public."SU_LVL_Subject_Level";
CREATE TRIGGER "it_SU_LVL_Subject_Level"
INSTEAD OF INSERT ON public."SU_LVL_Subject_Level"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_LVL_Subject_Level"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_TXT_Subject_Text tells whether two values of SU_TXT_Subject_Text are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_TXT_Subject_Text"(
    l text,
    r text
)
RETURNS boolean
AS
$$
    SELECT md5(l::text) = md5(r::text)
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TXT_Subject_Text instead of INSERT trigger on SU_TXT_Subject_Text
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_TXT_Subject_Text"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_TXT_PositedAt", _now);
    _reliability := coalesce(NEW."SU_TXT_Reliability", 1);
    _changing := coalesce(NEW."SU_TXT_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_TXT_ID"
    INTO
        _posit
    FROM
        public."SU_TXT_Subject_Text_Posit" p
    WHERE
        p."SU_TXT_SU_ID" = NEW."SU_TXT_SU_ID"
    AND
        p."SU_TXT_ChangedAt" = _changing
    AND
        public."eq_SU_TXT_Subject_Text"(p."SU_TXT_Subject_Text", NEW."SU_TXT_Subject_Text")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TXT_Subject_Text_Annex" a
        WHERE
            a."SU_TXT_ID" = _posit
        AND
            a."SU_TXT_PositedAt" = _positing
        AND
            a."SU_TXT_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TXT_Subject_Text for: %', concat_ws(', ', NEW."SU_TXT_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TXT_Subject_Text_Posit" p
        JOIN
            public."SU_TXT_Subject_Text_Annex" a
        ON
            a."SU_TXT_ID" = p."SU_TXT_ID"
        WHERE
            p."SU_TXT_SU_ID" = NEW."SU_TXT_SU_ID"
        AND
            p."SU_TXT_ChangedAt" = _changing
        AND
            NOT public."eq_SU_TXT_Subject_Text"(p."SU_TXT_Subject_Text", NEW."SU_TXT_Subject_Text")
        AND
            a."SU_TXT_PositedAt" = _positing
        AND
            a."SU_TXT_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TXT_Subject_Text for: %', concat_ws(', ', NEW."SU_TXT_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TXT_Subject_Text_Annex" a
        WHERE
            a."SU_TXT_ID" = _posit
        AND
            a."SU_TXT_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_TXT_Reliability" = 1
            FROM
                public."SU_TXT_Subject_Text_Annex" a
            WHERE
                a."SU_TXT_ID" = _posit
            AND
                a."SU_TXT_PositedAt" <= _positing
            ORDER BY
                a."SU_TXT_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_TXT_Subject_Text_Annex" (
            "Metadata_SU_TXT",
            "SU_TXT_ID",
            "SU_TXT_PositedAt",
            "SU_TXT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TXT", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_TXT_ID"
        FROM
            public."SU_TXT_Subject_Text_Posit" p
        WHERE
            p."SU_TXT_SU_ID" = NEW."SU_TXT_SU_ID"
        AND
            p."SU_TXT_ChangedAt" = _changing
        AND
            NOT public."eq_SU_TXT_Subject_Text"(p."SU_TXT_Subject_Text", NEW."SU_TXT_Subject_Text")
        AND
            coalesce((
                SELECT
                    a."SU_TXT_Reliability" = 1
                FROM
                    public."SU_TXT_Subject_Text_Annex" a
                WHERE
                    a."SU_TXT_ID" = p."SU_TXT_ID"
                AND
                    a."SU_TXT_PositedAt" <= _positing
                ORDER BY
                    a."SU_TXT_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_TXT_Subject_Text_Annex" (
            "Metadata_SU_TXT",
            "SU_TXT_ID",
            "SU_TXT_PositedAt",
            "SU_TXT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TXT", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_TXT_Subject_Text_Posit" (
            "SU_TXT_SU_ID",
            "SU_TXT_ChangedAt",
            "SU_TXT_Subject_Text"
        )
        VALUES (
            NEW."SU_TXT_SU_ID",
            _changing,
            NEW."SU_TXT_Subject_Text"
        )
        RETURNING "SU_TXT_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_TXT_Subject_Text_Annex" (
        "Metadata_SU_TXT",
        "SU_TXT_ID",
        "SU_TXT_PositedAt",
        "SU_TXT_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_TXT", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_TXT_Subject_Text" ON public."SU_TXT_Subject_Text";
CREATE TRIGGER "it_SU_TXT_Subject_Text"
INSTEAD OF INSERT ON public."SU_TXT_Subject_Text"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_TXT_Subject_Text"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_ASR_Subject_Assessment tells whether two values of SU_ASR_Subject_Assessment are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_ASR_Subject_Assessment"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ASR_Subject_Assessment instead of INSERT trigger on SU_ASR_Subject_Assessment
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_ASR_Subject_Assessment"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_ASR_PositedAt", _now);
    _reliability := coalesce(NEW."SU_ASR_Reliability", 1);
    _changing := coalesce(NEW."SU_ASR_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_ASR_ID"
    INTO
        _posit
    FROM
        public."SU_ASR_Subject_Assessment_Posit" p
    WHERE
        p."SU_ASR_SU_ID" = NEW."SU_ASR_SU_ID"
    AND
        p."SU_ASR_ChangedAt" = _changing
    AND
        public."eq_SU_ASR_Subject_Assessment"(p."SU_ASR_Subject_Assessment", NEW."SU_ASR_Subject_Assessment")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_ASR_Subject_Assessment_Annex" a
        WHERE
            a."SU_ASR_ID" = _posit
        AND
            a."SU_ASR_PositedAt" = _positing
        AND
            a."SU_ASR_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_ASR_Subject_Assessment for: %', concat_ws(', ', NEW."SU_ASR_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_ASR_Subject_Assessment_Posit" p
        JOIN
            public."SU_ASR_Subject_Assessment_Annex" a
        ON
            a."SU_ASR_ID" = p."SU_ASR_ID"
        WHERE
            p."SU_ASR_SU_ID" = NEW."SU_ASR_SU_ID"
        AND
            p."SU_ASR_ChangedAt" = _changing
        AND
            NOT public."eq_SU_ASR_Subject_Assessment"(p."SU_ASR_Subject_Assessment", NEW."SU_ASR_Subject_Assessment")
        AND
            a."SU_ASR_PositedAt" = _positing
        AND
            a."SU_ASR_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_ASR_Subject_Assessment for: %', concat_ws(', ', NEW."SU_ASR_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_ASR_Subject_Assessment_Annex" a
        WHERE
            a."SU_ASR_ID" = _posit
        AND
            a."SU_ASR_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_ASR_Reliability" = 1
            FROM
                public."SU_ASR_Subject_Assessment_Annex" a
            WHERE
                a."SU_ASR_ID" = _posit
            AND
                a."SU_ASR_PositedAt" <= _positing
            ORDER BY
                a."SU_ASR_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_ASR_Subject_Assessment_Annex" (
            "Metadata_SU_ASR",
            "SU_ASR_ID",
            "SU_ASR_PositedAt",
            "SU_ASR_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ASR", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    IF _posit IS NOT NULL AND coalesce((
        SELECT
            a."SU_ASR_Reliability" = 1
        FROM
            public."SU_ASR_Subject_Assessment_Annex" a
        WHERE
            a."SU_ASR_ID" = _posit
        AND
            a."SU_ASR_PositedAt" <= _positing
        ORDER BY
            a."SU_ASR_PositedAt" DESC
        LIMIT 1
    ), false) THEN
        RETURN NULL;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_ASR_ID"
        FROM
            public."SU_ASR_Subject_Assessment_Posit" p
        WHERE
            p."SU_ASR_SU_ID" = NEW."SU_ASR_SU_ID"
        AND
            p."SU_ASR_ChangedAt" = _changing
        AND
            NOT public."eq_SU_ASR_Subject_Assessment"(p."SU_ASR_Subject_Assessment", NEW."SU_ASR_Subject_Assessment")
        AND
            coalesce((
                SELECT
                    a."SU_ASR_Reliability" = 1
                FROM
                    public."SU_ASR_Subject_Assessment_Annex" a
                WHERE
                    a."SU_ASR_ID" = p."SU_ASR_ID"
                AND
                    a."SU_ASR_PositedAt" <= _positing
                ORDER BY
                    a."SU_ASR_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_ASR_Subject_Assessment_Annex" (
            "Metadata_SU_ASR",
            "SU_ASR_ID",
            "SU_ASR_PositedAt",
            "SU_ASR_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ASR", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_ASR_Subject_Assessment_Posit" (
            "SU_ASR_SU_ID",
            "SU_ASR_ChangedAt",
            "SU_ASR_Subject_Assessment"
        )
        VALUES (
            NEW."SU_ASR_SU_ID",
            _changing,
            NEW."SU_ASR_Subject_Assessment"
        )
        RETURNING "SU_ASR_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_ASR_Subject_Assessment_Annex" (
        "Metadata_SU_ASR",
        "SU_ASR_ID",
        "SU_ASR_PositedAt",
        "SU_ASR_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_ASR", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_ASR_Subject_Assessment" ON public."SU_ASR_Subject_Assessment";
CREATE TRIGGER "it_SU_ASR_Subject_Assessment"
INSTEAD OF INSERT ON public."SU_ASR_Subject_Assessment"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_ASR_Subject_Assessment"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_ERS_Subject_Erasable tells whether two values of SU_ERS_Subject_Erasable are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_ERS_Subject_Erasable"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ERS_Subject_Erasable instead of INSERT trigger on SU_ERS_Subject_Erasable
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_ERS_Subject_Erasable"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_ERS_PositedAt", _now);
    _reliability := coalesce(NEW."SU_ERS_Reliability", 1);
    _changing := coalesce(NEW."SU_ERS_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_ERS_ID"
    INTO
        _posit
    FROM
        public."SU_ERS_Subject_Erasable_Posit" p
    WHERE
        p."SU_ERS_SU_ID" = NEW."SU_ERS_SU_ID"
    AND
        p."SU_ERS_ChangedAt" = _changing
    AND
        public."eq_SU_ERS_Subject_Erasable"(p."SU_ERS_Subject_Erasable", NEW."SU_ERS_Subject_Erasable")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_ERS_Subject_Erasable_Annex" a
        WHERE
            a."SU_ERS_ID" = _posit
        AND
            a."SU_ERS_PositedAt" = _positing
        AND
            a."SU_ERS_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_ERS_Subject_Erasable for: %', concat_ws(', ', NEW."SU_ERS_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_ERS_Subject_Erasable_Posit" p
        JOIN
            public."SU_ERS_Subject_Erasable_Annex" a
        ON
            a."SU_ERS_ID" = p."SU_ERS_ID"
        WHERE
            p."SU_ERS_SU_ID" = NEW."SU_ERS_SU_ID"
        AND
            p."SU_ERS_ChangedAt" = _changing
        AND
            NOT public."eq_SU_ERS_Subject_Erasable"(p."SU_ERS_Subject_Erasable", NEW."SU_ERS_Subject_Erasable")
        AND
            a."SU_ERS_PositedAt" = _positing
        AND
            a."SU_ERS_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_ERS_Subject_Erasable for: %', concat_ws(', ', NEW."SU_ERS_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_ERS_Subject_Erasable_Annex" a
        WHERE
            a."SU_ERS_ID" = _posit
        AND
            a."SU_ERS_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_ERS_Reliability" = 1
            FROM
                public."SU_ERS_Subject_Erasable_Annex" a
            WHERE
                a."SU_ERS_ID" = _posit
            AND
                a."SU_ERS_PositedAt" <= _positing
            ORDER BY
                a."SU_ERS_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_ERS_Subject_Erasable_Annex" (
            "Metadata_SU_ERS",
            "SU_ERS_ID",
            "SU_ERS_PositedAt",
            "SU_ERS_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ERS", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_ERS_ID"
        FROM
            public."SU_ERS_Subject_Erasable_Posit" p
        WHERE
            p."SU_ERS_SU_ID" = NEW."SU_ERS_SU_ID"
        AND
            p."SU_ERS_ChangedAt" = _changing
        AND
            NOT public."eq_SU_ERS_Subject_Erasable"(p."SU_ERS_Subject_Erasable", NEW."SU_ERS_Subject_Erasable")
        AND
            coalesce((
                SELECT
                    a."SU_ERS_Reliability" = 1
                FROM
                    public."SU_ERS_Subject_Erasable_Annex" a
                WHERE
                    a."SU_ERS_ID" = p."SU_ERS_ID"
                AND
                    a."SU_ERS_PositedAt" <= _positing
                ORDER BY
                    a."SU_ERS_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_ERS_Subject_Erasable_Annex" (
            "Metadata_SU_ERS",
            "SU_ERS_ID",
            "SU_ERS_PositedAt",
            "SU_ERS_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ERS", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_ERS_Subject_Erasable_Posit" (
            "SU_ERS_SU_ID",
            "SU_ERS_ChangedAt",
            "SU_ERS_Subject_Erasable"
        )
        VALUES (
            NEW."SU_ERS_SU_ID",
            _changing,
            NEW."SU_ERS_Subject_Erasable"
        )
        RETURNING "SU_ERS_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_ERS_Subject_Erasable_Annex" (
        "Metadata_SU_ERS",
        "SU_ERS_ID",
        "SU_ERS_PositedAt",
        "SU_ERS_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_ERS", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_ERS_Subject_Erasable" ON public."SU_ERS_Subject_Erasable";
CREATE TRIGGER "it_SU_ERS_Subject_Erasable"
INSTEAD OF INSERT ON public."SU_ERS_Subject_Erasable"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_ERS_Subject_Erasable"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_OB_NAM_Object_Name tells whether two values of OB_NAM_Object_Name are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_OB_NAM_Object_Name"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OB_NAM_Object_Name instead of INSERT trigger on OB_NAM_Object_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_OB_NAM_Object_Name"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."OB_NAM_PositedAt", _now);
    _reliability := coalesce(NEW."OB_NAM_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."OB_NAM_ID"
    INTO
        _posit
    FROM
        public."OB_NAM_Object_Name_Posit" p
    WHERE
        p."OB_NAM_OB_ID" = NEW."OB_NAM_OB_ID"
    AND
        public."eq_OB_NAM_Object_Name"(p."OB_NAM_Object_Name", NEW."OB_NAM_Object_Name")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."OB_NAM_Object_Name_Annex" a
        WHERE
            a."OB_NAM_ID" = _posit
        AND
            a."OB_NAM_PositedAt" = _positing
        AND
            a."OB_NAM_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in OB_NAM_Object_Name for: %', concat_ws(', ', NEW."OB_NAM_OB_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."OB_NAM_Object_Name_Posit" p
        JOIN
            public."OB_NAM_Object_Name_Annex" a
        ON
            a."OB_NAM_ID" = p."OB_NAM_ID"
        WHERE
            p."OB_NAM_OB_ID" = NEW."OB_NAM_OB_ID"
        AND
            NOT public."eq_OB_NAM_Object_Name"(p."OB_NAM_Object_Name", NEW."OB_NAM_Object_Name")
        AND
            a."OB_NAM_PositedAt" = _positing
        AND
            a."OB_NAM_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in OB_NAM_Object_Name for: %', concat_ws(', ', NEW."OB_NAM_OB_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."OB_NAM_Object_Name_Annex" a
        WHERE
            a."OB_NAM_ID" = _posit
        AND
            a."OB_NAM_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."OB_NAM_Reliability" = 1
            FROM
                public."OB_NAM_Object_Name_Annex" a
            WHERE
                a."OB_NAM_ID" = _posit
            AND
                a."OB_NAM_PositedAt" <= _positing
            ORDER BY
                a."OB_NAM_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."OB_NAM_Object_Name_Annex" (
            "Metadata_OB_NAM",
            "OB_NAM_ID",
            "OB_NAM_PositedAt",
            "OB_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_OB_NAM", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."OB_NAM_ID"
        FROM
            public."OB_NAM_Object_Name_Posit" p
        WHERE
            p."OB_NAM_OB_ID" = NEW."OB_NAM_OB_ID"
        AND
            NOT public."eq_OB_NAM_Object_Name"(p."OB_NAM_Object_Name", NEW."OB_NAM_Object_Name")
        AND
            coalesce((
                SELECT
                    a."OB_NAM_Reliability" = 1
                FROM
                    public."OB_NAM_Object_Name_Annex" a
                WHERE
                    a."OB_NAM_ID" = p."OB_NAM_ID"
                AND
                    a."OB_NAM_PositedAt" <= _positing
                ORDER BY
                    a."OB_NAM_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."OB_NAM_Object_Name_Annex" (
            "Metadata_OB_NAM",
            "OB_NAM_ID",
            "OB_NAM_PositedAt",
            "OB_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_OB_NAM", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."OB_NAM_Object_Name_Posit" (
            "OB_NAM_OB_ID",
            "OB_NAM_Object_Name"
        )
        VALUES (
            NEW."OB_NAM_OB_ID",
            NEW."OB_NAM_Object_Name"
        )
        RETURNING "OB_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO public."OB_NAM_Object_Name_Annex" (
        "Metadata_OB_NAM",
        "OB_NAM_ID",
        "OB_NAM_PositedAt",
        "OB_NAM_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_OB_NAM", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_OB_NAM_Object_Name" ON public."OB_NAM_Object_Name";
CREATE TRIGGER "it_OB_NAM_Object_Name"
INSTEAD OF INSERT ON public."OB_NAM_Object_Name"
FOR EACH ROW EXECUTE FUNCTION public."it_OB_NAM_Object_Name"();
