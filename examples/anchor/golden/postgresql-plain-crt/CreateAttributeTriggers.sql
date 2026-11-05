-- ATTRIBUTE TRIGGERS ------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled views make them behave like tables.
-- There is one 'instead of' trigger for: insert.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements: the positor is 0, the positing time is now and the reliability is 1.
--
-- The rules are the ones in Anchor's docs/ANCHOR.md, "Loading through the latest views". A positor holds, for a posit, what
-- its latest annex row up to a positing time says: a positive reliability asserts it, a negative one asserts that it is
-- not so, and 0 retracts the assertion (the posit is not in effect for the positor). A retraction of what the positor does
-- not hold states nothing.
-- Positors are decisive: a positor holds one assertion at a time for an entity (and a changing time), so an assertion that
-- is not a retraction, positive or negative, of another value retracts, at its own positing time, the posit that the
-- positor holds, which is a correction.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- PostgreSQL runs a trigger of this kind for each row, so the rows of an insert are taken in the order they have.
--
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_DAT_Event_Date tells whether two values of EV_DAT_Event_Date are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_EV_DAT_Event_Date"(
    l timestamp,
    r timestamp
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_DAT_Event_Date is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_EV_DAT_Event_Date"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."EV_DAT_Reliability"
    FROM
        public."EV_DAT_Event_Date_Annex" a
    WHERE
        a."EV_DAT_ID" = _id
    AND
        a."EV_DAT_Positor" = _positor
    AND
        a."EV_DAT_PositedAt" <= _positing
    ORDER BY
        a."EV_DAT_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_DAT_Event_Date instead of INSERT trigger on EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_EV_DAT_Event_Date"()
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
    _positor := coalesce(NEW."EV_DAT_Positor", 0);
    _positing := coalesce(NEW."EV_DAT_PositedAt", _now);
    _reliability := coalesce(NEW."EV_DAT_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."EV_DAT_ID"
    INTO
        _posit
    FROM
        public."EV_DAT_Event_Date_Posit" p
    WHERE
        p."EV_ID" = NEW."EV_ID"
    AND
        public."eq_EV_DAT_Event_Date"(p."EV_DAT_Event_Date", NEW."EV_DAT_Event_Date")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."EV_DAT_Event_Date_Annex" a
        WHERE
            a."EV_DAT_ID" = _posit
        AND
            a."EV_DAT_Positor" = _positor
        AND
            a."EV_DAT_PositedAt" = _positing
        AND
            a."EV_DAT_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_DAT_Event_Date for: %', concat_ws(', ', NEW."EV_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            public."EV_DAT_Event_Date_Posit" p
        JOIN
            public."EV_DAT_Event_Date_Annex" a
        ON
            a."EV_DAT_ID" = p."EV_DAT_ID"
        WHERE
            p."EV_ID" = NEW."EV_ID"
        AND
            NOT public."eq_EV_DAT_Event_Date"(p."EV_DAT_Event_Date", NEW."EV_DAT_Event_Date")
        AND
            a."EV_DAT_Positor" = _positor
        AND
            a."EV_DAT_PositedAt" = _positing
        AND
            a."EV_DAT_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_DAT_Event_Date for: %', concat_ws(', ', NEW."EV_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."EV_DAT_Event_Date_Annex" a
        WHERE
            a."EV_DAT_ID" = _posit
        AND
            a."EV_DAT_Positor" = _positor
        AND
            a."EV_DAT_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_EV_DAT_Event_Date"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."EV_DAT_Event_Date_Annex" (
            "EV_DAT_ID",
            "EV_DAT_Positor",
            "EV_DAT_PositedAt",
            "EV_DAT_Reliability"
        )
        VALUES (
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR _other IN
        SELECT
            p."EV_DAT_ID"
        FROM
            public."EV_DAT_Event_Date_Posit" p
        WHERE
            p."EV_ID" = NEW."EV_ID"
        AND
            NOT public."eq_EV_DAT_Event_Date"(p."EV_DAT_Event_Date", NEW."EV_DAT_Event_Date")
        AND
            coalesce(public."he_EV_DAT_Event_Date"(p."EV_DAT_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO public."EV_DAT_Event_Date_Annex" (
            "EV_DAT_ID",
            "EV_DAT_Positor",
            "EV_DAT_PositedAt",
            "EV_DAT_Reliability"
        )
        VALUES (
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."EV_DAT_Event_Date_Posit" (
            "EV_ID",
            "EV_DAT_Event_Date"
        )
        VALUES (
            NEW."EV_ID",
            NEW."EV_DAT_Event_Date"
        )
        RETURNING "EV_DAT_ID" INTO _posit;
    END IF;
    INSERT INTO public."EV_DAT_Event_Date_Annex" (
        "EV_DAT_ID",
        "EV_DAT_Positor",
        "EV_DAT_PositedAt",
        "EV_DAT_Reliability"
    )
    VALUES (
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_DAT_Event_Date" ON public."EV_DAT_Event_Date";
CREATE TRIGGER "it_EV_DAT_Event_Date"
INSTEAD OF INSERT ON public."EV_DAT_Event_Date"
FOR EACH ROW EXECUTE FUNCTION public."it_EV_DAT_Event_Date"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_AUD_Event_Audience tells whether two values of EV_AUD_Event_Audience are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_EV_AUD_Event_Audience"(
    l integer,
    r integer
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_AUD_Event_Audience is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_EV_AUD_Event_Audience"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."EV_AUD_Reliability"
    FROM
        public."EV_AUD_Event_Audience_Annex" a
    WHERE
        a."EV_AUD_ID" = _id
    AND
        a."EV_AUD_Positor" = _positor
    AND
        a."EV_AUD_PositedAt" <= _positing
    ORDER BY
        a."EV_AUD_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_AUD_Event_Audience instead of INSERT trigger on EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_EV_AUD_Event_Audience"()
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
    _positor := coalesce(NEW."EV_AUD_Positor", 0);
    _positing := coalesce(NEW."EV_AUD_PositedAt", _now);
    _reliability := coalesce(NEW."EV_AUD_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."EV_AUD_ID"
    INTO
        _posit
    FROM
        public."EV_AUD_Event_Audience_Posit" p
    WHERE
        p."EV_ID" = NEW."EV_ID"
    AND
        public."eq_EV_AUD_Event_Audience"(p."EV_AUD_Event_Audience", NEW."EV_AUD_Event_Audience")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."EV_AUD_Event_Audience_Annex" a
        WHERE
            a."EV_AUD_ID" = _posit
        AND
            a."EV_AUD_Positor" = _positor
        AND
            a."EV_AUD_PositedAt" = _positing
        AND
            a."EV_AUD_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_AUD_Event_Audience for: %', concat_ws(', ', NEW."EV_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            public."EV_AUD_Event_Audience_Posit" p
        JOIN
            public."EV_AUD_Event_Audience_Annex" a
        ON
            a."EV_AUD_ID" = p."EV_AUD_ID"
        WHERE
            p."EV_ID" = NEW."EV_ID"
        AND
            NOT public."eq_EV_AUD_Event_Audience"(p."EV_AUD_Event_Audience", NEW."EV_AUD_Event_Audience")
        AND
            a."EV_AUD_Positor" = _positor
        AND
            a."EV_AUD_PositedAt" = _positing
        AND
            a."EV_AUD_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_AUD_Event_Audience for: %', concat_ws(', ', NEW."EV_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."EV_AUD_Event_Audience_Annex" a
        WHERE
            a."EV_AUD_ID" = _posit
        AND
            a."EV_AUD_Positor" = _positor
        AND
            a."EV_AUD_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_EV_AUD_Event_Audience"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."EV_AUD_Event_Audience_Annex" (
            "EV_AUD_ID",
            "EV_AUD_Positor",
            "EV_AUD_PositedAt",
            "EV_AUD_Reliability"
        )
        VALUES (
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR _other IN
        SELECT
            p."EV_AUD_ID"
        FROM
            public."EV_AUD_Event_Audience_Posit" p
        WHERE
            p."EV_ID" = NEW."EV_ID"
        AND
            NOT public."eq_EV_AUD_Event_Audience"(p."EV_AUD_Event_Audience", NEW."EV_AUD_Event_Audience")
        AND
            coalesce(public."he_EV_AUD_Event_Audience"(p."EV_AUD_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO public."EV_AUD_Event_Audience_Annex" (
            "EV_AUD_ID",
            "EV_AUD_Positor",
            "EV_AUD_PositedAt",
            "EV_AUD_Reliability"
        )
        VALUES (
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."EV_AUD_Event_Audience_Posit" (
            "EV_ID",
            "EV_AUD_Event_Audience"
        )
        VALUES (
            NEW."EV_ID",
            NEW."EV_AUD_Event_Audience"
        )
        RETURNING "EV_AUD_ID" INTO _posit;
    END IF;
    INSERT INTO public."EV_AUD_Event_Audience_Annex" (
        "EV_AUD_ID",
        "EV_AUD_Positor",
        "EV_AUD_PositedAt",
        "EV_AUD_Reliability"
    )
    VALUES (
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_AUD_Event_Audience" ON public."EV_AUD_Event_Audience";
CREATE TRIGGER "it_EV_AUD_Event_Audience"
INSTEAD OF INSERT ON public."EV_AUD_Event_Audience"
FOR EACH ROW EXECUTE FUNCTION public."it_EV_AUD_Event_Audience"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_REV_Event_Revenue tells whether two values of EV_REV_Event_Revenue are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_EV_REV_Event_Revenue"(
    l decimal(19,4),
    r decimal(19,4)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_REV_Event_Revenue is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_EV_REV_Event_Revenue"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."EV_REV_Reliability"
    FROM
        public."EV_REV_Event_Revenue_Annex" a
    WHERE
        a."EV_REV_ID" = _id
    AND
        a."EV_REV_Positor" = _positor
    AND
        a."EV_REV_PositedAt" <= _positing
    ORDER BY
        a."EV_REV_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_REV_Event_Revenue instead of INSERT trigger on EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_EV_REV_Event_Revenue"()
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
    _positor := coalesce(NEW."EV_REV_Positor", 0);
    _positing := coalesce(NEW."EV_REV_PositedAt", _now);
    _reliability := coalesce(NEW."EV_REV_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."EV_REV_ID"
    INTO
        _posit
    FROM
        public."EV_REV_Event_Revenue_Posit" p
    WHERE
        p."EV_ID" = NEW."EV_ID"
    AND
        public."eq_EV_REV_Event_Revenue"(p."EV_REV_Event_Revenue", NEW."EV_REV_Event_Revenue")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."EV_REV_Event_Revenue_Annex" a
        WHERE
            a."EV_REV_ID" = _posit
        AND
            a."EV_REV_Positor" = _positor
        AND
            a."EV_REV_PositedAt" = _positing
        AND
            a."EV_REV_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_REV_Event_Revenue for: %', concat_ws(', ', NEW."EV_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            public."EV_REV_Event_Revenue_Posit" p
        JOIN
            public."EV_REV_Event_Revenue_Annex" a
        ON
            a."EV_REV_ID" = p."EV_REV_ID"
        WHERE
            p."EV_ID" = NEW."EV_ID"
        AND
            NOT public."eq_EV_REV_Event_Revenue"(p."EV_REV_Event_Revenue", NEW."EV_REV_Event_Revenue")
        AND
            a."EV_REV_Positor" = _positor
        AND
            a."EV_REV_PositedAt" = _positing
        AND
            a."EV_REV_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_REV_Event_Revenue for: %', concat_ws(', ', NEW."EV_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."EV_REV_Event_Revenue_Annex" a
        WHERE
            a."EV_REV_ID" = _posit
        AND
            a."EV_REV_Positor" = _positor
        AND
            a."EV_REV_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_EV_REV_Event_Revenue"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."EV_REV_Event_Revenue_Annex" (
            "EV_REV_ID",
            "EV_REV_Positor",
            "EV_REV_PositedAt",
            "EV_REV_Reliability"
        )
        VALUES (
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR _other IN
        SELECT
            p."EV_REV_ID"
        FROM
            public."EV_REV_Event_Revenue_Posit" p
        WHERE
            p."EV_ID" = NEW."EV_ID"
        AND
            NOT public."eq_EV_REV_Event_Revenue"(p."EV_REV_Event_Revenue", NEW."EV_REV_Event_Revenue")
        AND
            coalesce(public."he_EV_REV_Event_Revenue"(p."EV_REV_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO public."EV_REV_Event_Revenue_Annex" (
            "EV_REV_ID",
            "EV_REV_Positor",
            "EV_REV_PositedAt",
            "EV_REV_Reliability"
        )
        VALUES (
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."EV_REV_Event_Revenue_Posit" (
            "EV_ID",
            "EV_REV_Event_Revenue"
        )
        VALUES (
            NEW."EV_ID",
            NEW."EV_REV_Event_Revenue"
        )
        RETURNING "EV_REV_ID" INTO _posit;
    END IF;
    INSERT INTO public."EV_REV_Event_Revenue_Annex" (
        "EV_REV_ID",
        "EV_REV_Positor",
        "EV_REV_PositedAt",
        "EV_REV_Reliability"
    )
    VALUES (
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_REV_Event_Revenue" ON public."EV_REV_Event_Revenue";
CREATE TRIGGER "it_EV_REV_Event_Revenue"
INSTEAD OF INSERT ON public."EV_REV_Event_Revenue"
FOR EACH ROW EXECUTE FUNCTION public."it_EV_REV_Event_Revenue"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_NAM_Stage_Name tells whether two values of ST_NAM_Stage_Name are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_ST_NAM_Stage_Name"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_NAM_Stage_Name is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_ST_NAM_Stage_Name"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."ST_NAM_Reliability"
    FROM
        public."ST_NAM_Stage_Name_Annex" a
    WHERE
        a."ST_NAM_ID" = _id
    AND
        a."ST_NAM_Positor" = _positor
    AND
        a."ST_NAM_PositedAt" <= _positing
    ORDER BY
        a."ST_NAM_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_NAM_Stage_Name instead of INSERT trigger on ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_ST_NAM_Stage_Name"()
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
    _positor := coalesce(NEW."ST_NAM_Positor", 0);
    _positing := coalesce(NEW."ST_NAM_PositedAt", _now);
    _reliability := coalesce(NEW."ST_NAM_Reliability", 1);
    _changing := coalesce(NEW."ST_NAM_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."ST_NAM_ID"
    INTO
        _posit
    FROM
        public."ST_NAM_Stage_Name_Posit" p
    WHERE
        p."ST_ID" = NEW."ST_ID"
    AND
        p."ST_NAM_ChangedAt" = _changing
    AND
        public."eq_ST_NAM_Stage_Name"(p."ST_NAM_Stage_Name", NEW."ST_NAM_Stage_Name")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."ST_NAM_Stage_Name_Annex" a
        WHERE
            a."ST_NAM_ID" = _posit
        AND
            a."ST_NAM_Positor" = _positor
        AND
            a."ST_NAM_PositedAt" = _positing
        AND
            a."ST_NAM_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_NAM_Stage_Name for: %', concat_ws(', ', NEW."ST_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            public."ST_NAM_Stage_Name_Posit" p
        JOIN
            public."ST_NAM_Stage_Name_Annex" a
        ON
            a."ST_NAM_ID" = p."ST_NAM_ID"
        WHERE
            p."ST_ID" = NEW."ST_ID"
        AND
            p."ST_NAM_ChangedAt" = _changing
        AND
            NOT public."eq_ST_NAM_Stage_Name"(p."ST_NAM_Stage_Name", NEW."ST_NAM_Stage_Name")
        AND
            a."ST_NAM_Positor" = _positor
        AND
            a."ST_NAM_PositedAt" = _positing
        AND
            a."ST_NAM_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_NAM_Stage_Name for: %', concat_ws(', ', NEW."ST_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."ST_NAM_Stage_Name_Annex" a
        WHERE
            a."ST_NAM_ID" = _posit
        AND
            a."ST_NAM_Positor" = _positor
        AND
            a."ST_NAM_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_ST_NAM_Stage_Name"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."ST_NAM_Stage_Name_Annex" (
            "ST_NAM_ID",
            "ST_NAM_Positor",
            "ST_NAM_PositedAt",
            "ST_NAM_Reliability"
        )
        VALUES (
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR _other IN
        SELECT
            p."ST_NAM_ID"
        FROM
            public."ST_NAM_Stage_Name_Posit" p
        WHERE
            p."ST_ID" = NEW."ST_ID"
        AND
            p."ST_NAM_ChangedAt" = _changing
        AND
            NOT public."eq_ST_NAM_Stage_Name"(p."ST_NAM_Stage_Name", NEW."ST_NAM_Stage_Name")
        AND
            coalesce(public."he_ST_NAM_Stage_Name"(p."ST_NAM_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO public."ST_NAM_Stage_Name_Annex" (
            "ST_NAM_ID",
            "ST_NAM_Positor",
            "ST_NAM_PositedAt",
            "ST_NAM_Reliability"
        )
        VALUES (
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."ST_NAM_Stage_Name_Posit" (
            "ST_ID",
            "ST_NAM_ChangedAt",
            "ST_NAM_Stage_Name"
        )
        VALUES (
            NEW."ST_ID",
            _changing,
            NEW."ST_NAM_Stage_Name"
        )
        RETURNING "ST_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO public."ST_NAM_Stage_Name_Annex" (
        "ST_NAM_ID",
        "ST_NAM_Positor",
        "ST_NAM_PositedAt",
        "ST_NAM_Reliability"
    )
    VALUES (
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_NAM_Stage_Name" ON public."ST_NAM_Stage_Name";
CREATE TRIGGER "it_ST_NAM_Stage_Name"
INSTEAD OF INSERT ON public."ST_NAM_Stage_Name"
FOR EACH ROW EXECUTE FUNCTION public."it_ST_NAM_Stage_Name"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_LOC_Stage_Location tells whether two values of ST_LOC_Stage_Location are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_ST_LOC_Stage_Location"(
    l text,
    r text
)
RETURNS boolean
AS
$$
    SELECT md5(l::text) = md5(r::text)
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_LOC_Stage_Location is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_ST_LOC_Stage_Location"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."ST_LOC_Reliability"
    FROM
        public."ST_LOC_Stage_Location_Annex" a
    WHERE
        a."ST_LOC_ID" = _id
    AND
        a."ST_LOC_Positor" = _positor
    AND
        a."ST_LOC_PositedAt" <= _positing
    ORDER BY
        a."ST_LOC_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_LOC_Stage_Location instead of INSERT trigger on ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_ST_LOC_Stage_Location"()
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
    _positor := coalesce(NEW."ST_LOC_Positor", 0);
    _positing := coalesce(NEW."ST_LOC_PositedAt", _now);
    _reliability := coalesce(NEW."ST_LOC_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."ST_LOC_ID"
    INTO
        _posit
    FROM
        public."ST_LOC_Stage_Location_Posit" p
    WHERE
        p."ST_ID" = NEW."ST_ID"
    AND
        public."eq_ST_LOC_Stage_Location"(p."ST_LOC_Stage_Location", NEW."ST_LOC_Stage_Location")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."ST_LOC_Stage_Location_Annex" a
        WHERE
            a."ST_LOC_ID" = _posit
        AND
            a."ST_LOC_Positor" = _positor
        AND
            a."ST_LOC_PositedAt" = _positing
        AND
            a."ST_LOC_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_LOC_Stage_Location for: %', concat_ws(', ', NEW."ST_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            public."ST_LOC_Stage_Location_Posit" p
        JOIN
            public."ST_LOC_Stage_Location_Annex" a
        ON
            a."ST_LOC_ID" = p."ST_LOC_ID"
        WHERE
            p."ST_ID" = NEW."ST_ID"
        AND
            NOT public."eq_ST_LOC_Stage_Location"(p."ST_LOC_Stage_Location", NEW."ST_LOC_Stage_Location")
        AND
            a."ST_LOC_Positor" = _positor
        AND
            a."ST_LOC_PositedAt" = _positing
        AND
            a."ST_LOC_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_LOC_Stage_Location for: %', concat_ws(', ', NEW."ST_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."ST_LOC_Stage_Location_Annex" a
        WHERE
            a."ST_LOC_ID" = _posit
        AND
            a."ST_LOC_Positor" = _positor
        AND
            a."ST_LOC_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_ST_LOC_Stage_Location"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."ST_LOC_Stage_Location_Annex" (
            "ST_LOC_ID",
            "ST_LOC_Positor",
            "ST_LOC_PositedAt",
            "ST_LOC_Reliability"
        )
        VALUES (
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR _other IN
        SELECT
            p."ST_LOC_ID"
        FROM
            public."ST_LOC_Stage_Location_Posit" p
        WHERE
            p."ST_ID" = NEW."ST_ID"
        AND
            NOT public."eq_ST_LOC_Stage_Location"(p."ST_LOC_Stage_Location", NEW."ST_LOC_Stage_Location")
        AND
            coalesce(public."he_ST_LOC_Stage_Location"(p."ST_LOC_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO public."ST_LOC_Stage_Location_Annex" (
            "ST_LOC_ID",
            "ST_LOC_Positor",
            "ST_LOC_PositedAt",
            "ST_LOC_Reliability"
        )
        VALUES (
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."ST_LOC_Stage_Location_Posit" (
            "ST_ID",
            "ST_LOC_Stage_Location"
        )
        VALUES (
            NEW."ST_ID",
            NEW."ST_LOC_Stage_Location"
        )
        RETURNING "ST_LOC_ID" INTO _posit;
    END IF;
    INSERT INTO public."ST_LOC_Stage_Location_Annex" (
        "ST_LOC_ID",
        "ST_LOC_Positor",
        "ST_LOC_PositedAt",
        "ST_LOC_Reliability"
    )
    VALUES (
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_LOC_Stage_Location" ON public."ST_LOC_Stage_Location";
CREATE TRIGGER "it_ST_LOC_Stage_Location"
INSTEAD OF INSERT ON public."ST_LOC_Stage_Location"
FOR EACH ROW EXECUTE FUNCTION public."it_ST_LOC_Stage_Location"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_AVG_Stage_Average tells whether two values of ST_AVG_Stage_Average are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_ST_AVG_Stage_Average"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_AVG_Stage_Average is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_ST_AVG_Stage_Average"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."ST_AVG_Reliability"
    FROM
        public."ST_AVG_Stage_Average_Annex" a
    WHERE
        a."ST_AVG_ID" = _id
    AND
        a."ST_AVG_Positor" = _positor
    AND
        a."ST_AVG_PositedAt" <= _positing
    ORDER BY
        a."ST_AVG_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_AVG_Stage_Average instead of INSERT trigger on ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_ST_AVG_Stage_Average"()
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
    _positor := coalesce(NEW."ST_AVG_Positor", 0);
    _positing := coalesce(NEW."ST_AVG_PositedAt", _now);
    _reliability := coalesce(NEW."ST_AVG_Reliability", 1);
    _changing := coalesce(NEW."ST_AVG_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."ST_AVG_ID"
    INTO
        _posit
    FROM
        public."ST_AVG_Stage_Average_Posit" p
    WHERE
        p."ST_ID" = NEW."ST_ID"
    AND
        p."ST_AVG_ChangedAt" = _changing
    AND
        public."eq_ST_AVG_Stage_Average"(p."UTL_ID", NEW."UTL_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."ST_AVG_Stage_Average_Annex" a
        WHERE
            a."ST_AVG_ID" = _posit
        AND
            a."ST_AVG_Positor" = _positor
        AND
            a."ST_AVG_PositedAt" = _positing
        AND
            a."ST_AVG_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_AVG_Stage_Average for: %', concat_ws(', ', NEW."ST_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            public."ST_AVG_Stage_Average_Posit" p
        JOIN
            public."ST_AVG_Stage_Average_Annex" a
        ON
            a."ST_AVG_ID" = p."ST_AVG_ID"
        WHERE
            p."ST_ID" = NEW."ST_ID"
        AND
            p."ST_AVG_ChangedAt" = _changing
        AND
            NOT public."eq_ST_AVG_Stage_Average"(p."UTL_ID", NEW."UTL_ID")
        AND
            a."ST_AVG_Positor" = _positor
        AND
            a."ST_AVG_PositedAt" = _positing
        AND
            a."ST_AVG_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_AVG_Stage_Average for: %', concat_ws(', ', NEW."ST_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."ST_AVG_Stage_Average_Annex" a
        WHERE
            a."ST_AVG_ID" = _posit
        AND
            a."ST_AVG_Positor" = _positor
        AND
            a."ST_AVG_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_ST_AVG_Stage_Average"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."ST_AVG_Stage_Average_Annex" (
            "ST_AVG_ID",
            "ST_AVG_Positor",
            "ST_AVG_PositedAt",
            "ST_AVG_Reliability"
        )
        VALUES (
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR _other IN
        SELECT
            p."ST_AVG_ID"
        FROM
            public."ST_AVG_Stage_Average_Posit" p
        WHERE
            p."ST_ID" = NEW."ST_ID"
        AND
            p."ST_AVG_ChangedAt" = _changing
        AND
            NOT public."eq_ST_AVG_Stage_Average"(p."UTL_ID", NEW."UTL_ID")
        AND
            coalesce(public."he_ST_AVG_Stage_Average"(p."ST_AVG_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO public."ST_AVG_Stage_Average_Annex" (
            "ST_AVG_ID",
            "ST_AVG_Positor",
            "ST_AVG_PositedAt",
            "ST_AVG_Reliability"
        )
        VALUES (
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."UTL_ID"
            FROM
                public."ST_AVG_Stage_Average_Posit" p
            WHERE
                p."ST_ID" = NEW."ST_ID"
            AND
                p."ST_AVG_ChangedAt" < _changing
            AND
                coalesce(public."he_ST_AVG_Stage_Average"(p."ST_AVG_ID", _positor, _positing), 0) <> 0
            AND
                (public."he_ST_AVG_Stage_Average"(p."ST_AVG_ID", _positor, _positing) > 0) = (_reliability > 0)
            ORDER BY
                p."ST_AVG_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            public."eq_ST_AVG_Stage_Average"(pre."UTL_ID", NEW."UTL_ID")
    ) THEN
        -- (an idempotent attribute does not store it)
        RETURN NULL;
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."ST_AVG_ID"
    INTO
        _following
    FROM
        public."ST_AVG_Stage_Average_Posit" f
    WHERE
        f."ST_ID" = NEW."ST_ID"
    AND
        f."ST_AVG_ChangedAt" > _changing
    AND
        coalesce(public."he_ST_AVG_Stage_Average"(f."ST_AVG_ID", _positor, _positing), 0) <> 0
    AND
        (public."he_ST_AVG_Stage_Average"(f."ST_AVG_ID", _positor, _positing) > 0) = (_reliability > 0)
    ORDER BY
        f."ST_AVG_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND public."eq_ST_AVG_Stage_Average"((
        SELECT x."UTL_ID" FROM public."ST_AVG_Stage_Average_Posit" x WHERE x."ST_AVG_ID" = _following
    ), NEW."UTL_ID") THEN
        -- (an idempotent attribute retracts it)
        INSERT INTO public."ST_AVG_Stage_Average_Annex" (
            "ST_AVG_ID",
            "ST_AVG_Positor",
            "ST_AVG_PositedAt",
            "ST_AVG_Reliability"
        )
        VALUES (
            _following,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."ST_AVG_Stage_Average_Posit" (
            "ST_ID",
            "ST_AVG_ChangedAt",
            "UTL_ID"
        )
        VALUES (
            NEW."ST_ID",
            _changing,
            NEW."UTL_ID"
        )
        RETURNING "ST_AVG_ID" INTO _posit;
    END IF;
    INSERT INTO public."ST_AVG_Stage_Average_Annex" (
        "ST_AVG_ID",
        "ST_AVG_Positor",
        "ST_AVG_PositedAt",
        "ST_AVG_Reliability"
    )
    VALUES (
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_AVG_Stage_Average" ON public."ST_AVG_Stage_Average";
CREATE TRIGGER "it_ST_AVG_Stage_Average"
INSTEAD OF INSERT ON public."ST_AVG_Stage_Average"
FOR EACH ROW EXECUTE FUNCTION public."it_ST_AVG_Stage_Average"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_MIN_Stage_Minimum tells whether two values of ST_MIN_Stage_Minimum are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_ST_MIN_Stage_Minimum"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_MIN_Stage_Minimum is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_ST_MIN_Stage_Minimum"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."ST_MIN_Reliability"
    FROM
        public."ST_MIN_Stage_Minimum_Annex" a
    WHERE
        a."ST_MIN_ID" = _id
    AND
        a."ST_MIN_Positor" = _positor
    AND
        a."ST_MIN_PositedAt" <= _positing
    ORDER BY
        a."ST_MIN_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_MIN_Stage_Minimum instead of INSERT trigger on ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_ST_MIN_Stage_Minimum"()
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
    _positor := coalesce(NEW."ST_MIN_Positor", 0);
    _positing := coalesce(NEW."ST_MIN_PositedAt", _now);
    _reliability := coalesce(NEW."ST_MIN_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."ST_MIN_ID"
    INTO
        _posit
    FROM
        public."ST_MIN_Stage_Minimum_Posit" p
    WHERE
        p."ST_ID" = NEW."ST_ID"
    AND
        public."eq_ST_MIN_Stage_Minimum"(p."UTL_ID", NEW."UTL_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."ST_MIN_Stage_Minimum_Annex" a
        WHERE
            a."ST_MIN_ID" = _posit
        AND
            a."ST_MIN_Positor" = _positor
        AND
            a."ST_MIN_PositedAt" = _positing
        AND
            a."ST_MIN_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_MIN_Stage_Minimum for: %', concat_ws(', ', NEW."ST_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            public."ST_MIN_Stage_Minimum_Posit" p
        JOIN
            public."ST_MIN_Stage_Minimum_Annex" a
        ON
            a."ST_MIN_ID" = p."ST_MIN_ID"
        WHERE
            p."ST_ID" = NEW."ST_ID"
        AND
            NOT public."eq_ST_MIN_Stage_Minimum"(p."UTL_ID", NEW."UTL_ID")
        AND
            a."ST_MIN_Positor" = _positor
        AND
            a."ST_MIN_PositedAt" = _positing
        AND
            a."ST_MIN_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_MIN_Stage_Minimum for: %', concat_ws(', ', NEW."ST_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."ST_MIN_Stage_Minimum_Annex" a
        WHERE
            a."ST_MIN_ID" = _posit
        AND
            a."ST_MIN_Positor" = _positor
        AND
            a."ST_MIN_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_ST_MIN_Stage_Minimum"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."ST_MIN_Stage_Minimum_Annex" (
            "ST_MIN_ID",
            "ST_MIN_Positor",
            "ST_MIN_PositedAt",
            "ST_MIN_Reliability"
        )
        VALUES (
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR _other IN
        SELECT
            p."ST_MIN_ID"
        FROM
            public."ST_MIN_Stage_Minimum_Posit" p
        WHERE
            p."ST_ID" = NEW."ST_ID"
        AND
            NOT public."eq_ST_MIN_Stage_Minimum"(p."UTL_ID", NEW."UTL_ID")
        AND
            coalesce(public."he_ST_MIN_Stage_Minimum"(p."ST_MIN_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO public."ST_MIN_Stage_Minimum_Annex" (
            "ST_MIN_ID",
            "ST_MIN_Positor",
            "ST_MIN_PositedAt",
            "ST_MIN_Reliability"
        )
        VALUES (
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."ST_MIN_Stage_Minimum_Posit" (
            "ST_ID",
            "UTL_ID"
        )
        VALUES (
            NEW."ST_ID",
            NEW."UTL_ID"
        )
        RETURNING "ST_MIN_ID" INTO _posit;
    END IF;
    INSERT INTO public."ST_MIN_Stage_Minimum_Annex" (
        "ST_MIN_ID",
        "ST_MIN_Positor",
        "ST_MIN_PositedAt",
        "ST_MIN_Reliability"
    )
    VALUES (
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_MIN_Stage_Minimum" ON public."ST_MIN_Stage_Minimum";
CREATE TRIGGER "it_ST_MIN_Stage_Minimum"
INSTEAD OF INSERT ON public."ST_MIN_Stage_Minimum"
FOR EACH ROW EXECUTE FUNCTION public."it_ST_MIN_Stage_Minimum"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_NAM_Actor_Name tells whether two values of AC_NAM_Actor_Name are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_AC_NAM_Actor_Name"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_NAM_Actor_Name is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_AC_NAM_Actor_Name"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."AC_NAM_Reliability"
    FROM
        public."AC_NAM_Actor_Name_Annex" a
    WHERE
        a."AC_NAM_ID" = _id
    AND
        a."AC_NAM_Positor" = _positor
    AND
        a."AC_NAM_PositedAt" <= _positing
    ORDER BY
        a."AC_NAM_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_NAM_Actor_Name instead of INSERT trigger on AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_AC_NAM_Actor_Name"()
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
    _positor := coalesce(NEW."AC_NAM_Positor", 0);
    _positing := coalesce(NEW."AC_NAM_PositedAt", _now);
    _reliability := coalesce(NEW."AC_NAM_Reliability", 1);
    _changing := coalesce(NEW."AC_NAM_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."AC_NAM_ID"
    INTO
        _posit
    FROM
        public."AC_NAM_Actor_Name_Posit" p
    WHERE
        p."AC_ID" = NEW."AC_ID"
    AND
        p."AC_NAM_ChangedAt" = _changing
    AND
        public."eq_AC_NAM_Actor_Name"(p."AC_NAM_Actor_Name", NEW."AC_NAM_Actor_Name")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."AC_NAM_Actor_Name_Annex" a
        WHERE
            a."AC_NAM_ID" = _posit
        AND
            a."AC_NAM_Positor" = _positor
        AND
            a."AC_NAM_PositedAt" = _positing
        AND
            a."AC_NAM_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_NAM_Actor_Name for: %', concat_ws(', ', NEW."AC_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            public."AC_NAM_Actor_Name_Posit" p
        JOIN
            public."AC_NAM_Actor_Name_Annex" a
        ON
            a."AC_NAM_ID" = p."AC_NAM_ID"
        WHERE
            p."AC_ID" = NEW."AC_ID"
        AND
            p."AC_NAM_ChangedAt" = _changing
        AND
            NOT public."eq_AC_NAM_Actor_Name"(p."AC_NAM_Actor_Name", NEW."AC_NAM_Actor_Name")
        AND
            a."AC_NAM_Positor" = _positor
        AND
            a."AC_NAM_PositedAt" = _positing
        AND
            a."AC_NAM_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_NAM_Actor_Name for: %', concat_ws(', ', NEW."AC_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."AC_NAM_Actor_Name_Annex" a
        WHERE
            a."AC_NAM_ID" = _posit
        AND
            a."AC_NAM_Positor" = _positor
        AND
            a."AC_NAM_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_AC_NAM_Actor_Name"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."AC_NAM_Actor_Name_Annex" (
            "AC_NAM_ID",
            "AC_NAM_Positor",
            "AC_NAM_PositedAt",
            "AC_NAM_Reliability"
        )
        VALUES (
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR _other IN
        SELECT
            p."AC_NAM_ID"
        FROM
            public."AC_NAM_Actor_Name_Posit" p
        WHERE
            p."AC_ID" = NEW."AC_ID"
        AND
            p."AC_NAM_ChangedAt" = _changing
        AND
            NOT public."eq_AC_NAM_Actor_Name"(p."AC_NAM_Actor_Name", NEW."AC_NAM_Actor_Name")
        AND
            coalesce(public."he_AC_NAM_Actor_Name"(p."AC_NAM_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO public."AC_NAM_Actor_Name_Annex" (
            "AC_NAM_ID",
            "AC_NAM_Positor",
            "AC_NAM_PositedAt",
            "AC_NAM_Reliability"
        )
        VALUES (
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."AC_NAM_Actor_Name"
            FROM
                public."AC_NAM_Actor_Name_Posit" p
            WHERE
                p."AC_ID" = NEW."AC_ID"
            AND
                p."AC_NAM_ChangedAt" < _changing
            AND
                coalesce(public."he_AC_NAM_Actor_Name"(p."AC_NAM_ID", _positor, _positing), 0) <> 0
            AND
                (public."he_AC_NAM_Actor_Name"(p."AC_NAM_ID", _positor, _positing) > 0) = (_reliability > 0)
            ORDER BY
                p."AC_NAM_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            public."eq_AC_NAM_Actor_Name"(pre."AC_NAM_Actor_Name", NEW."AC_NAM_Actor_Name")
    ) THEN
        RAISE EXCEPTION 'Restatement in AC_NAM_Actor_Name for: %', concat_ws(', ', NEW."AC_ID", _changing, _positor, _positing);
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."AC_NAM_ID"
    INTO
        _following
    FROM
        public."AC_NAM_Actor_Name_Posit" f
    WHERE
        f."AC_ID" = NEW."AC_ID"
    AND
        f."AC_NAM_ChangedAt" > _changing
    AND
        coalesce(public."he_AC_NAM_Actor_Name"(f."AC_NAM_ID", _positor, _positing), 0) <> 0
    AND
        (public."he_AC_NAM_Actor_Name"(f."AC_NAM_ID", _positor, _positing) > 0) = (_reliability > 0)
    ORDER BY
        f."AC_NAM_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND public."eq_AC_NAM_Actor_Name"((
        SELECT x."AC_NAM_Actor_Name" FROM public."AC_NAM_Actor_Name_Posit" x WHERE x."AC_NAM_ID" = _following
    ), NEW."AC_NAM_Actor_Name") THEN
        RAISE EXCEPTION 'Restatement in AC_NAM_Actor_Name for: %', concat_ws(', ', NEW."AC_ID", _changing, _positor, _positing);
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."AC_NAM_Actor_Name_Posit" (
            "AC_ID",
            "AC_NAM_ChangedAt",
            "AC_NAM_Actor_Name"
        )
        VALUES (
            NEW."AC_ID",
            _changing,
            NEW."AC_NAM_Actor_Name"
        )
        RETURNING "AC_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO public."AC_NAM_Actor_Name_Annex" (
        "AC_NAM_ID",
        "AC_NAM_Positor",
        "AC_NAM_PositedAt",
        "AC_NAM_Reliability"
    )
    VALUES (
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_NAM_Actor_Name" ON public."AC_NAM_Actor_Name";
CREATE TRIGGER "it_AC_NAM_Actor_Name"
INSTEAD OF INSERT ON public."AC_NAM_Actor_Name"
FOR EACH ROW EXECUTE FUNCTION public."it_AC_NAM_Actor_Name"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_GEN_Actor_Gender tells whether two values of AC_GEN_Actor_Gender are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_AC_GEN_Actor_Gender"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_GEN_Actor_Gender is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_AC_GEN_Actor_Gender"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."AC_GEN_Reliability"
    FROM
        public."AC_GEN_Actor_Gender_Annex" a
    WHERE
        a."AC_GEN_ID" = _id
    AND
        a."AC_GEN_Positor" = _positor
    AND
        a."AC_GEN_PositedAt" <= _positing
    ORDER BY
        a."AC_GEN_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_GEN_Actor_Gender instead of INSERT trigger on AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_AC_GEN_Actor_Gender"()
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
    _positor := coalesce(NEW."AC_GEN_Positor", 0);
    _positing := coalesce(NEW."AC_GEN_PositedAt", _now);
    _reliability := coalesce(NEW."AC_GEN_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."AC_GEN_ID"
    INTO
        _posit
    FROM
        public."AC_GEN_Actor_Gender_Posit" p
    WHERE
        p."AC_ID" = NEW."AC_ID"
    AND
        public."eq_AC_GEN_Actor_Gender"(p."GEN_ID", NEW."GEN_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."AC_GEN_Actor_Gender_Annex" a
        WHERE
            a."AC_GEN_ID" = _posit
        AND
            a."AC_GEN_Positor" = _positor
        AND
            a."AC_GEN_PositedAt" = _positing
        AND
            a."AC_GEN_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_GEN_Actor_Gender for: %', concat_ws(', ', NEW."AC_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            public."AC_GEN_Actor_Gender_Posit" p
        JOIN
            public."AC_GEN_Actor_Gender_Annex" a
        ON
            a."AC_GEN_ID" = p."AC_GEN_ID"
        WHERE
            p."AC_ID" = NEW."AC_ID"
        AND
            NOT public."eq_AC_GEN_Actor_Gender"(p."GEN_ID", NEW."GEN_ID")
        AND
            a."AC_GEN_Positor" = _positor
        AND
            a."AC_GEN_PositedAt" = _positing
        AND
            a."AC_GEN_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_GEN_Actor_Gender for: %', concat_ws(', ', NEW."AC_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."AC_GEN_Actor_Gender_Annex" a
        WHERE
            a."AC_GEN_ID" = _posit
        AND
            a."AC_GEN_Positor" = _positor
        AND
            a."AC_GEN_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_AC_GEN_Actor_Gender"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."AC_GEN_Actor_Gender_Annex" (
            "AC_GEN_ID",
            "AC_GEN_Positor",
            "AC_GEN_PositedAt",
            "AC_GEN_Reliability"
        )
        VALUES (
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR _other IN
        SELECT
            p."AC_GEN_ID"
        FROM
            public."AC_GEN_Actor_Gender_Posit" p
        WHERE
            p."AC_ID" = NEW."AC_ID"
        AND
            NOT public."eq_AC_GEN_Actor_Gender"(p."GEN_ID", NEW."GEN_ID")
        AND
            coalesce(public."he_AC_GEN_Actor_Gender"(p."AC_GEN_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO public."AC_GEN_Actor_Gender_Annex" (
            "AC_GEN_ID",
            "AC_GEN_Positor",
            "AC_GEN_PositedAt",
            "AC_GEN_Reliability"
        )
        VALUES (
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."AC_GEN_Actor_Gender_Posit" (
            "AC_ID",
            "GEN_ID"
        )
        VALUES (
            NEW."AC_ID",
            NEW."GEN_ID"
        )
        RETURNING "AC_GEN_ID" INTO _posit;
    END IF;
    INSERT INTO public."AC_GEN_Actor_Gender_Annex" (
        "AC_GEN_ID",
        "AC_GEN_Positor",
        "AC_GEN_PositedAt",
        "AC_GEN_Reliability"
    )
    VALUES (
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_GEN_Actor_Gender" ON public."AC_GEN_Actor_Gender";
CREATE TRIGGER "it_AC_GEN_Actor_Gender"
INSTEAD OF INSERT ON public."AC_GEN_Actor_Gender"
FOR EACH ROW EXECUTE FUNCTION public."it_AC_GEN_Actor_Gender"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_PLV_Actor_ProfessionalLevel tells whether two values of AC_PLV_Actor_ProfessionalLevel are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_AC_PLV_Actor_ProfessionalLevel"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_PLV_Actor_ProfessionalLevel is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_AC_PLV_Actor_ProfessionalLevel"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."AC_PLV_Reliability"
    FROM
        public."AC_PLV_Actor_ProfessionalLevel_Annex" a
    WHERE
        a."AC_PLV_ID" = _id
    AND
        a."AC_PLV_Positor" = _positor
    AND
        a."AC_PLV_PositedAt" <= _positing
    ORDER BY
        a."AC_PLV_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_PLV_Actor_ProfessionalLevel instead of INSERT trigger on AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_AC_PLV_Actor_ProfessionalLevel"()
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
    _positor := coalesce(NEW."AC_PLV_Positor", 0);
    _positing := coalesce(NEW."AC_PLV_PositedAt", _now);
    _reliability := coalesce(NEW."AC_PLV_Reliability", 1);
    _changing := coalesce(NEW."AC_PLV_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."AC_PLV_ID"
    INTO
        _posit
    FROM
        public."AC_PLV_Actor_ProfessionalLevel_Posit" p
    WHERE
        p."AC_ID" = NEW."AC_ID"
    AND
        p."AC_PLV_ChangedAt" = _changing
    AND
        public."eq_AC_PLV_Actor_ProfessionalLevel"(p."PLV_ID", NEW."PLV_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."AC_PLV_Actor_ProfessionalLevel_Annex" a
        WHERE
            a."AC_PLV_ID" = _posit
        AND
            a."AC_PLV_Positor" = _positor
        AND
            a."AC_PLV_PositedAt" = _positing
        AND
            a."AC_PLV_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: %', concat_ws(', ', NEW."AC_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            public."AC_PLV_Actor_ProfessionalLevel_Posit" p
        JOIN
            public."AC_PLV_Actor_ProfessionalLevel_Annex" a
        ON
            a."AC_PLV_ID" = p."AC_PLV_ID"
        WHERE
            p."AC_ID" = NEW."AC_ID"
        AND
            p."AC_PLV_ChangedAt" = _changing
        AND
            NOT public."eq_AC_PLV_Actor_ProfessionalLevel"(p."PLV_ID", NEW."PLV_ID")
        AND
            a."AC_PLV_Positor" = _positor
        AND
            a."AC_PLV_PositedAt" = _positing
        AND
            a."AC_PLV_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: %', concat_ws(', ', NEW."AC_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."AC_PLV_Actor_ProfessionalLevel_Annex" a
        WHERE
            a."AC_PLV_ID" = _posit
        AND
            a."AC_PLV_Positor" = _positor
        AND
            a."AC_PLV_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_AC_PLV_Actor_ProfessionalLevel"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."AC_PLV_Actor_ProfessionalLevel_Annex" (
            "AC_PLV_ID",
            "AC_PLV_Positor",
            "AC_PLV_PositedAt",
            "AC_PLV_Reliability"
        )
        VALUES (
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR _other IN
        SELECT
            p."AC_PLV_ID"
        FROM
            public."AC_PLV_Actor_ProfessionalLevel_Posit" p
        WHERE
            p."AC_ID" = NEW."AC_ID"
        AND
            p."AC_PLV_ChangedAt" = _changing
        AND
            NOT public."eq_AC_PLV_Actor_ProfessionalLevel"(p."PLV_ID", NEW."PLV_ID")
        AND
            coalesce(public."he_AC_PLV_Actor_ProfessionalLevel"(p."AC_PLV_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO public."AC_PLV_Actor_ProfessionalLevel_Annex" (
            "AC_PLV_ID",
            "AC_PLV_Positor",
            "AC_PLV_PositedAt",
            "AC_PLV_Reliability"
        )
        VALUES (
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."AC_PLV_Actor_ProfessionalLevel_Posit" (
            "AC_ID",
            "AC_PLV_ChangedAt",
            "PLV_ID"
        )
        VALUES (
            NEW."AC_ID",
            _changing,
            NEW."PLV_ID"
        )
        RETURNING "AC_PLV_ID" INTO _posit;
    END IF;
    INSERT INTO public."AC_PLV_Actor_ProfessionalLevel_Annex" (
        "AC_PLV_ID",
        "AC_PLV_Positor",
        "AC_PLV_PositedAt",
        "AC_PLV_Reliability"
    )
    VALUES (
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_PLV_Actor_ProfessionalLevel" ON public."AC_PLV_Actor_ProfessionalLevel";
CREATE TRIGGER "it_AC_PLV_Actor_ProfessionalLevel"
INSTEAD OF INSERT ON public."AC_PLV_Actor_ProfessionalLevel"
FOR EACH ROW EXECUTE FUNCTION public."it_AC_PLV_Actor_ProfessionalLevel"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_NAM_Program_Name tells whether two values of PR_NAM_Program_Name are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_PR_NAM_Program_Name"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_NAM_Program_Name is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_PR_NAM_Program_Name"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."PR_NAM_Reliability"
    FROM
        public."PR_NAM_Program_Name_Annex" a
    WHERE
        a."PR_NAM_ID" = _id
    AND
        a."PR_NAM_Positor" = _positor
    AND
        a."PR_NAM_PositedAt" <= _positing
    ORDER BY
        a."PR_NAM_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_NAM_Program_Name instead of INSERT trigger on PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_PR_NAM_Program_Name"()
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
    _positor := coalesce(NEW."PR_NAM_Positor", 0);
    _positing := coalesce(NEW."PR_NAM_PositedAt", _now);
    _reliability := coalesce(NEW."PR_NAM_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."PR_NAM_ID"
    INTO
        _posit
    FROM
        public."PR_NAM_Program_Name_Posit" p
    WHERE
        p."PR_ID" = NEW."PR_ID"
    AND
        public."eq_PR_NAM_Program_Name"(p."PR_NAM_Program_Name", NEW."PR_NAM_Program_Name")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."PR_NAM_Program_Name_Annex" a
        WHERE
            a."PR_NAM_ID" = _posit
        AND
            a."PR_NAM_Positor" = _positor
        AND
            a."PR_NAM_PositedAt" = _positing
        AND
            a."PR_NAM_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_NAM_Program_Name for: %', concat_ws(', ', NEW."PR_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            public."PR_NAM_Program_Name_Posit" p
        JOIN
            public."PR_NAM_Program_Name_Annex" a
        ON
            a."PR_NAM_ID" = p."PR_NAM_ID"
        WHERE
            p."PR_ID" = NEW."PR_ID"
        AND
            NOT public."eq_PR_NAM_Program_Name"(p."PR_NAM_Program_Name", NEW."PR_NAM_Program_Name")
        AND
            a."PR_NAM_Positor" = _positor
        AND
            a."PR_NAM_PositedAt" = _positing
        AND
            a."PR_NAM_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_NAM_Program_Name for: %', concat_ws(', ', NEW."PR_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."PR_NAM_Program_Name_Annex" a
        WHERE
            a."PR_NAM_ID" = _posit
        AND
            a."PR_NAM_Positor" = _positor
        AND
            a."PR_NAM_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_PR_NAM_Program_Name"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."PR_NAM_Program_Name_Annex" (
            "PR_NAM_ID",
            "PR_NAM_Positor",
            "PR_NAM_PositedAt",
            "PR_NAM_Reliability"
        )
        VALUES (
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR _other IN
        SELECT
            p."PR_NAM_ID"
        FROM
            public."PR_NAM_Program_Name_Posit" p
        WHERE
            p."PR_ID" = NEW."PR_ID"
        AND
            NOT public."eq_PR_NAM_Program_Name"(p."PR_NAM_Program_Name", NEW."PR_NAM_Program_Name")
        AND
            coalesce(public."he_PR_NAM_Program_Name"(p."PR_NAM_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO public."PR_NAM_Program_Name_Annex" (
            "PR_NAM_ID",
            "PR_NAM_Positor",
            "PR_NAM_PositedAt",
            "PR_NAM_Reliability"
        )
        VALUES (
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."PR_NAM_Program_Name_Posit" (
            "PR_ID",
            "PR_NAM_Program_Name"
        )
        VALUES (
            NEW."PR_ID",
            NEW."PR_NAM_Program_Name"
        )
        RETURNING "PR_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO public."PR_NAM_Program_Name_Annex" (
        "PR_NAM_ID",
        "PR_NAM_Positor",
        "PR_NAM_PositedAt",
        "PR_NAM_Reliability"
    )
    VALUES (
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_PR_NAM_Program_Name" ON public."PR_NAM_Program_Name";
CREATE TRIGGER "it_PR_NAM_Program_Name"
INSTEAD OF INSERT ON public."PR_NAM_Program_Name"
FOR EACH ROW EXECUTE FUNCTION public."it_PR_NAM_Program_Name"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_LEN_Program_Length tells whether two values of PR_LEN_Program_Length are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_PR_LEN_Program_Length"(
    l time,
    r time
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_LEN_Program_Length is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."he_PR_LEN_Program_Length"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."PR_LEN_Reliability"
    FROM
        public."PR_LEN_Program_Length_Annex" a
    WHERE
        a."PR_LEN_ID" = _id
    AND
        a."PR_LEN_Positor" = _positor
    AND
        a."PR_LEN_PositedAt" <= _positing
    ORDER BY
        a."PR_LEN_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_LEN_Program_Length instead of INSERT trigger on PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_PR_LEN_Program_Length"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp;
    _reliability decimal(5,2);
    _held decimal(5,2);
    _changing date;
    _posit integer;
    _other integer;
    _following integer;
    _total decimal(5,2);
BEGIN
    _positor := coalesce(NEW."PR_LEN_Positor", 0);
    _positing := coalesce(NEW."PR_LEN_PositedAt", _now);
    _reliability := coalesce(NEW."PR_LEN_Reliability", 1);
    _changing := coalesce(NEW."PR_LEN_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."PR_LEN_ID"
    INTO
        _posit
    FROM
        public."PR_LEN_Program_Length_Posit" p
    WHERE
        p."PR_ID" = NEW."PR_ID"
    AND
        p."PR_LEN_ChangedAt" = _changing
    AND
        public."eq_PR_LEN_Program_Length"(p."PR_LEN_Program_Length", NEW."PR_LEN_Program_Length")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."PR_LEN_Program_Length_Annex" a
        WHERE
            a."PR_LEN_ID" = _posit
        AND
            a."PR_LEN_Positor" = _positor
        AND
            a."PR_LEN_PositedAt" = _positing
        AND
            a."PR_LEN_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_LEN_Program_Length for: %', concat_ws(', ', NEW."PR_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            public."PR_LEN_Program_Length_Posit" p
        JOIN
            public."PR_LEN_Program_Length_Annex" a
        ON
            a."PR_LEN_ID" = p."PR_LEN_ID"
        WHERE
            p."PR_ID" = NEW."PR_ID"
        AND
            p."PR_LEN_ChangedAt" = _changing
        AND
            NOT public."eq_PR_LEN_Program_Length"(p."PR_LEN_Program_Length", NEW."PR_LEN_Program_Length")
        AND
            a."PR_LEN_Positor" = _positor
        AND
            a."PR_LEN_PositedAt" = _positing
        AND
            a."PR_LEN_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_LEN_Program_Length for: %', concat_ws(', ', NEW."PR_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."PR_LEN_Program_Length_Annex" a
        WHERE
            a."PR_LEN_ID" = _posit
        AND
            a."PR_LEN_Positor" = _positor
        AND
            a."PR_LEN_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := public."he_PR_LEN_Program_Length"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."PR_LEN_Program_Length_Annex" (
            "PR_LEN_ID",
            "PR_LEN_Positor",
            "PR_LEN_PositedAt",
            "PR_LEN_Reliability"
        )
        VALUES (
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR _other IN
        SELECT
            p."PR_LEN_ID"
        FROM
            public."PR_LEN_Program_Length_Posit" p
        WHERE
            p."PR_ID" = NEW."PR_ID"
        AND
            p."PR_LEN_ChangedAt" = _changing
        AND
            NOT public."eq_PR_LEN_Program_Length"(p."PR_LEN_Program_Length", NEW."PR_LEN_Program_Length")
        AND
            coalesce(public."he_PR_LEN_Program_Length"(p."PR_LEN_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO public."PR_LEN_Program_Length_Annex" (
            "PR_LEN_ID",
            "PR_LEN_Positor",
            "PR_LEN_PositedAt",
            "PR_LEN_Reliability"
        )
        VALUES (
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."PR_LEN_Program_Length"
            FROM
                public."PR_LEN_Program_Length_Posit" p
            WHERE
                p."PR_ID" = NEW."PR_ID"
            AND
                p."PR_LEN_ChangedAt" < _changing
            AND
                coalesce(public."he_PR_LEN_Program_Length"(p."PR_LEN_ID", _positor, _positing), 0) <> 0
            AND
                (public."he_PR_LEN_Program_Length"(p."PR_LEN_ID", _positor, _positing) > 0) = (_reliability > 0)
            ORDER BY
                p."PR_LEN_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            public."eq_PR_LEN_Program_Length"(pre."PR_LEN_Program_Length", NEW."PR_LEN_Program_Length")
    ) THEN
        -- (an idempotent attribute does not store it)
        RETURN NULL;
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."PR_LEN_ID"
    INTO
        _following
    FROM
        public."PR_LEN_Program_Length_Posit" f
    WHERE
        f."PR_ID" = NEW."PR_ID"
    AND
        f."PR_LEN_ChangedAt" > _changing
    AND
        coalesce(public."he_PR_LEN_Program_Length"(f."PR_LEN_ID", _positor, _positing), 0) <> 0
    AND
        (public."he_PR_LEN_Program_Length"(f."PR_LEN_ID", _positor, _positing) > 0) = (_reliability > 0)
    ORDER BY
        f."PR_LEN_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND public."eq_PR_LEN_Program_Length"((
        SELECT x."PR_LEN_Program_Length" FROM public."PR_LEN_Program_Length_Posit" x WHERE x."PR_LEN_ID" = _following
    ), NEW."PR_LEN_Program_Length") THEN
        -- (an idempotent attribute retracts it)
        INSERT INTO public."PR_LEN_Program_Length_Annex" (
            "PR_LEN_ID",
            "PR_LEN_Positor",
            "PR_LEN_PositedAt",
            "PR_LEN_Reliability"
        )
        VALUES (
            _following,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."PR_LEN_Program_Length_Posit" (
            "PR_ID",
            "PR_LEN_ChangedAt",
            "PR_LEN_Program_Length"
        )
        VALUES (
            NEW."PR_ID",
            _changing,
            NEW."PR_LEN_Program_Length"
        )
        RETURNING "PR_LEN_ID" INTO _posit;
    END IF;
    INSERT INTO public."PR_LEN_Program_Length_Annex" (
        "PR_LEN_ID",
        "PR_LEN_Positor",
        "PR_LEN_PositedAt",
        "PR_LEN_Reliability"
    )
    VALUES (
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_PR_LEN_Program_Length" ON public."PR_LEN_Program_Length";
CREATE TRIGGER "it_PR_LEN_Program_Length"
INSTEAD OF INSERT ON public."PR_LEN_Program_Length"
FOR EACH ROW EXECUTE FUNCTION public."it_PR_LEN_Program_Length"();
