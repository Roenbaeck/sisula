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
-- eq_EV_DAT_Händelse_Datum tells whether two values of EV_DAT_Händelse_Datum are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_DAT_Händelse_Datum"(
    l timestamp,
    r timestamp
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_DAT_Händelse_Datum is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_EV_DAT_Händelse_Datum"(
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
        attributes."EV_DAT_Händelse_Datum_Annex" a
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
-- it_EV_DAT_Händelse_Datum instead of INSERT trigger on EV_DAT_Händelse_Datum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_DAT_Händelse_Datum"()
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
        attributes."EV_DAT_Händelse_Datum_Posit" p
    WHERE
        p."EV_DAT_EV_ID" = NEW."EV_DAT_EV_ID"
    AND
        attributes."eq_EV_DAT_Händelse_Datum"(p."EV_DAT_Händelse_Datum", NEW."EV_DAT_Händelse_Datum")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_DAT_Händelse_Datum_Annex" a
        WHERE
            a."EV_DAT_ID" = _posit
        AND
            a."EV_DAT_Positor" = _positor
        AND
            a."EV_DAT_PositedAt" = _positing
        AND
            a."EV_DAT_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_DAT_Händelse_Datum for: %', concat_ws(', ', NEW."EV_DAT_EV_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_DAT_Händelse_Datum_Posit" p
        JOIN
            attributes."EV_DAT_Händelse_Datum_Annex" a
        ON
            a."EV_DAT_ID" = p."EV_DAT_ID"
        WHERE
            p."EV_DAT_EV_ID" = NEW."EV_DAT_EV_ID"
        AND
            NOT attributes."eq_EV_DAT_Händelse_Datum"(p."EV_DAT_Händelse_Datum", NEW."EV_DAT_Händelse_Datum")
        AND
            a."EV_DAT_Positor" = _positor
        AND
            a."EV_DAT_PositedAt" = _positing
        AND
            a."EV_DAT_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_DAT_Händelse_Datum for: %', concat_ws(', ', NEW."EV_DAT_EV_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_DAT_Händelse_Datum_Annex" a
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
        _held := attributes."he_EV_DAT_Händelse_Datum"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_DAT_Händelse_Datum_Annex" (
            "Metadata_EV_DAT",
            "EV_DAT_ID",
            "EV_DAT_Positor",
            "EV_DAT_PositedAt",
            "EV_DAT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_DAT", 0),
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
            attributes."EV_DAT_Händelse_Datum_Posit" p
        WHERE
            p."EV_DAT_EV_ID" = NEW."EV_DAT_EV_ID"
        AND
            NOT attributes."eq_EV_DAT_Händelse_Datum"(p."EV_DAT_Händelse_Datum", NEW."EV_DAT_Händelse_Datum")
        AND
            coalesce(attributes."he_EV_DAT_Händelse_Datum"(p."EV_DAT_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO attributes."EV_DAT_Händelse_Datum_Annex" (
            "Metadata_EV_DAT",
            "EV_DAT_ID",
            "EV_DAT_Positor",
            "EV_DAT_PositedAt",
            "EV_DAT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_DAT", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_DAT_Händelse_Datum_Posit" (
            "EV_DAT_EV_ID",
            "EV_DAT_Händelse_Datum"
        )
        VALUES (
            NEW."EV_DAT_EV_ID",
            NEW."EV_DAT_Händelse_Datum"
        )
        RETURNING "EV_DAT_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_DAT_Händelse_Datum_Annex" (
        "Metadata_EV_DAT",
        "EV_DAT_ID",
        "EV_DAT_Positor",
        "EV_DAT_PositedAt",
        "EV_DAT_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_DAT", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_DAT_Händelse_Datum" ON attributes."EV_DAT_Händelse_Datum";
CREATE TRIGGER "it_EV_DAT_Händelse_Datum"
INSTEAD OF INSERT ON attributes."EV_DAT_Händelse_Datum"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_DAT_Händelse_Datum"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_AUD_Händelse_Publik tells whether two values of EV_AUD_Händelse_Publik are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_AUD_Händelse_Publik"(
    l integer,
    r integer
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_AUD_Händelse_Publik is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_EV_AUD_Händelse_Publik"(
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
        attributes."EV_AUD_Händelse_Publik_Annex" a
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
-- it_EV_AUD_Händelse_Publik instead of INSERT trigger on EV_AUD_Händelse_Publik
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_AUD_Händelse_Publik"()
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
        attributes."EV_AUD_Händelse_Publik_Posit" p
    WHERE
        p."EV_AUD_EV_ID" = NEW."EV_AUD_EV_ID"
    AND
        attributes."eq_EV_AUD_Händelse_Publik"(p."EV_AUD_Händelse_Publik", NEW."EV_AUD_Händelse_Publik")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_AUD_Händelse_Publik_Annex" a
        WHERE
            a."EV_AUD_ID" = _posit
        AND
            a."EV_AUD_Positor" = _positor
        AND
            a."EV_AUD_PositedAt" = _positing
        AND
            a."EV_AUD_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_AUD_Händelse_Publik for: %', concat_ws(', ', NEW."EV_AUD_EV_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_AUD_Händelse_Publik_Posit" p
        JOIN
            attributes."EV_AUD_Händelse_Publik_Annex" a
        ON
            a."EV_AUD_ID" = p."EV_AUD_ID"
        WHERE
            p."EV_AUD_EV_ID" = NEW."EV_AUD_EV_ID"
        AND
            NOT attributes."eq_EV_AUD_Händelse_Publik"(p."EV_AUD_Händelse_Publik", NEW."EV_AUD_Händelse_Publik")
        AND
            a."EV_AUD_Positor" = _positor
        AND
            a."EV_AUD_PositedAt" = _positing
        AND
            a."EV_AUD_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_AUD_Händelse_Publik for: %', concat_ws(', ', NEW."EV_AUD_EV_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_AUD_Händelse_Publik_Annex" a
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
        _held := attributes."he_EV_AUD_Händelse_Publik"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_AUD_Händelse_Publik_Annex" (
            "Metadata_EV_AUD",
            "EV_AUD_ID",
            "EV_AUD_Positor",
            "EV_AUD_PositedAt",
            "EV_AUD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_AUD", 0),
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
            attributes."EV_AUD_Händelse_Publik_Posit" p
        WHERE
            p."EV_AUD_EV_ID" = NEW."EV_AUD_EV_ID"
        AND
            NOT attributes."eq_EV_AUD_Händelse_Publik"(p."EV_AUD_Händelse_Publik", NEW."EV_AUD_Händelse_Publik")
        AND
            coalesce(attributes."he_EV_AUD_Händelse_Publik"(p."EV_AUD_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO attributes."EV_AUD_Händelse_Publik_Annex" (
            "Metadata_EV_AUD",
            "EV_AUD_ID",
            "EV_AUD_Positor",
            "EV_AUD_PositedAt",
            "EV_AUD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_AUD", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_AUD_Händelse_Publik_Posit" (
            "EV_AUD_EV_ID",
            "EV_AUD_Händelse_Publik"
        )
        VALUES (
            NEW."EV_AUD_EV_ID",
            NEW."EV_AUD_Händelse_Publik"
        )
        RETURNING "EV_AUD_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_AUD_Händelse_Publik_Annex" (
        "Metadata_EV_AUD",
        "EV_AUD_ID",
        "EV_AUD_Positor",
        "EV_AUD_PositedAt",
        "EV_AUD_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_AUD", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_AUD_Händelse_Publik" ON attributes."EV_AUD_Händelse_Publik";
CREATE TRIGGER "it_EV_AUD_Händelse_Publik"
INSTEAD OF INSERT ON attributes."EV_AUD_Händelse_Publik"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_AUD_Händelse_Publik"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_REV_Händelse_Intäkt tells whether two values of EV_REV_Händelse_Intäkt are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_REV_Händelse_Intäkt"(
    l decimal(19,4),
    r decimal(19,4)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_REV_Händelse_Intäkt is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_EV_REV_Händelse_Intäkt"(
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
        attributes."EV_REV_Händelse_Intäkt_Annex" a
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
-- it_EV_REV_Händelse_Intäkt instead of INSERT trigger on EV_REV_Händelse_Intäkt
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_REV_Händelse_Intäkt"()
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
        attributes."EV_REV_Händelse_Intäkt_Posit" p
    WHERE
        p."EV_REV_EV_ID" = NEW."EV_REV_EV_ID"
    AND
        attributes."eq_EV_REV_Händelse_Intäkt"(p."EV_REV_Händelse_Intäkt", NEW."EV_REV_Händelse_Intäkt")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_REV_Händelse_Intäkt_Annex" a
        WHERE
            a."EV_REV_ID" = _posit
        AND
            a."EV_REV_Positor" = _positor
        AND
            a."EV_REV_PositedAt" = _positing
        AND
            a."EV_REV_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_REV_Händelse_Intäkt for: %', concat_ws(', ', NEW."EV_REV_EV_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_REV_Händelse_Intäkt_Posit" p
        JOIN
            attributes."EV_REV_Händelse_Intäkt_Annex" a
        ON
            a."EV_REV_ID" = p."EV_REV_ID"
        WHERE
            p."EV_REV_EV_ID" = NEW."EV_REV_EV_ID"
        AND
            NOT attributes."eq_EV_REV_Händelse_Intäkt"(p."EV_REV_Händelse_Intäkt", NEW."EV_REV_Händelse_Intäkt")
        AND
            a."EV_REV_Positor" = _positor
        AND
            a."EV_REV_PositedAt" = _positing
        AND
            a."EV_REV_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_REV_Händelse_Intäkt for: %', concat_ws(', ', NEW."EV_REV_EV_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_REV_Händelse_Intäkt_Annex" a
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
        _held := attributes."he_EV_REV_Händelse_Intäkt"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_REV_Händelse_Intäkt_Annex" (
            "Metadata_EV_REV",
            "EV_REV_ID",
            "EV_REV_Positor",
            "EV_REV_PositedAt",
            "EV_REV_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_REV", 0),
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
            attributes."EV_REV_Händelse_Intäkt_Posit" p
        WHERE
            p."EV_REV_EV_ID" = NEW."EV_REV_EV_ID"
        AND
            NOT attributes."eq_EV_REV_Händelse_Intäkt"(p."EV_REV_Händelse_Intäkt", NEW."EV_REV_Händelse_Intäkt")
        AND
            coalesce(attributes."he_EV_REV_Händelse_Intäkt"(p."EV_REV_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO attributes."EV_REV_Händelse_Intäkt_Annex" (
            "Metadata_EV_REV",
            "EV_REV_ID",
            "EV_REV_Positor",
            "EV_REV_PositedAt",
            "EV_REV_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_REV", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_REV_Händelse_Intäkt_Posit" (
            "EV_REV_EV_ID",
            "EV_REV_Händelse_Intäkt"
        )
        VALUES (
            NEW."EV_REV_EV_ID",
            NEW."EV_REV_Händelse_Intäkt"
        )
        RETURNING "EV_REV_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_REV_Händelse_Intäkt_Annex" (
        "Metadata_EV_REV",
        "EV_REV_ID",
        "EV_REV_Positor",
        "EV_REV_PositedAt",
        "EV_REV_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_REV", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_REV_Händelse_Intäkt" ON attributes."EV_REV_Händelse_Intäkt";
CREATE TRIGGER "it_EV_REV_Händelse_Intäkt"
INSTEAD OF INSERT ON attributes."EV_REV_Händelse_Intäkt"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_REV_Händelse_Intäkt"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_STA_Händelse_Status tells whether two values of EV_STA_Händelse_Status are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_STA_Händelse_Status"(
    l varchar(20),
    r varchar(20)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_STA_Händelse_Status is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_EV_STA_Händelse_Status"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."EV_STA_Reliability"
    FROM
        attributes."EV_STA_Händelse_Status_Annex" a
    WHERE
        a."EV_STA_ID" = _id
    AND
        a."EV_STA_Positor" = _positor
    AND
        a."EV_STA_PositedAt" <= _positing
    ORDER BY
        a."EV_STA_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_STA_Händelse_Status instead of INSERT trigger on EV_STA_Händelse_Status
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_STA_Händelse_Status"()
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
    _positor := coalesce(NEW."EV_STA_Positor", 0);
    _positing := coalesce(NEW."EV_STA_PositedAt", _now);
    _reliability := coalesce(NEW."EV_STA_Reliability", 1);
    _changing := coalesce(NEW."EV_STA_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."EV_STA_ID"
    INTO
        _posit
    FROM
        attributes."EV_STA_Händelse_Status_Posit" p
    WHERE
        p."EV_STA_EV_ID" = NEW."EV_STA_EV_ID"
    AND
        p."EV_STA_ChangedAt" = _changing
    AND
        attributes."eq_EV_STA_Händelse_Status"(p."EV_STA_Händelse_Status", NEW."EV_STA_Händelse_Status")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_STA_Händelse_Status_Annex" a
        WHERE
            a."EV_STA_ID" = _posit
        AND
            a."EV_STA_Positor" = _positor
        AND
            a."EV_STA_PositedAt" = _positing
        AND
            a."EV_STA_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_STA_Händelse_Status for: %', concat_ws(', ', NEW."EV_STA_EV_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_STA_Händelse_Status_Posit" p
        JOIN
            attributes."EV_STA_Händelse_Status_Annex" a
        ON
            a."EV_STA_ID" = p."EV_STA_ID"
        WHERE
            p."EV_STA_EV_ID" = NEW."EV_STA_EV_ID"
        AND
            p."EV_STA_ChangedAt" = _changing
        AND
            NOT attributes."eq_EV_STA_Händelse_Status"(p."EV_STA_Händelse_Status", NEW."EV_STA_Händelse_Status")
        AND
            a."EV_STA_Positor" = _positor
        AND
            a."EV_STA_PositedAt" = _positing
        AND
            a."EV_STA_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_STA_Händelse_Status for: %', concat_ws(', ', NEW."EV_STA_EV_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_STA_Händelse_Status_Annex" a
        WHERE
            a."EV_STA_ID" = _posit
        AND
            a."EV_STA_Positor" = _positor
        AND
            a."EV_STA_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_EV_STA_Händelse_Status"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_STA_Händelse_Status_Annex" (
            "Metadata_EV_STA",
            "EV_STA_ID",
            "EV_STA_Positor",
            "EV_STA_PositedAt",
            "EV_STA_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_STA", 0),
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
            p."EV_STA_ID"
        FROM
            attributes."EV_STA_Händelse_Status_Posit" p
        WHERE
            p."EV_STA_EV_ID" = NEW."EV_STA_EV_ID"
        AND
            p."EV_STA_ChangedAt" = _changing
        AND
            NOT attributes."eq_EV_STA_Händelse_Status"(p."EV_STA_Händelse_Status", NEW."EV_STA_Händelse_Status")
        AND
            coalesce(attributes."he_EV_STA_Händelse_Status"(p."EV_STA_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO attributes."EV_STA_Händelse_Status_Annex" (
            "Metadata_EV_STA",
            "EV_STA_ID",
            "EV_STA_Positor",
            "EV_STA_PositedAt",
            "EV_STA_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_STA", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_STA_Händelse_Status_Posit" (
            "EV_STA_EV_ID",
            "EV_STA_ChangedAt",
            "EV_STA_Händelse_Status"
        )
        VALUES (
            NEW."EV_STA_EV_ID",
            _changing,
            NEW."EV_STA_Händelse_Status"
        )
        RETURNING "EV_STA_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_STA_Händelse_Status_Annex" (
        "Metadata_EV_STA",
        "EV_STA_ID",
        "EV_STA_Positor",
        "EV_STA_PositedAt",
        "EV_STA_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_STA", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_STA_Händelse_Status" ON attributes."EV_STA_Händelse_Status";
CREATE TRIGGER "it_EV_STA_Händelse_Status"
INSTEAD OF INSERT ON attributes."EV_STA_Händelse_Status"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_STA_Händelse_Status"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_UTL_Händelse_Utnyttjande tells whether two values of EV_UTL_Händelse_Utnyttjande are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_UTL_Händelse_Utnyttjande"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_UTL_Händelse_Utnyttjande is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_EV_UTL_Händelse_Utnyttjande"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."EV_UTL_Reliability"
    FROM
        attributes."EV_UTL_Händelse_Utnyttjande_Annex" a
    WHERE
        a."EV_UTL_ID" = _id
    AND
        a."EV_UTL_Positor" = _positor
    AND
        a."EV_UTL_PositedAt" <= _positing
    ORDER BY
        a."EV_UTL_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_UTL_Händelse_Utnyttjande instead of INSERT trigger on EV_UTL_Händelse_Utnyttjande
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_UTL_Händelse_Utnyttjande"()
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
    _positor := coalesce(NEW."EV_UTL_Positor", 0);
    _positing := coalesce(NEW."EV_UTL_PositedAt", _now);
    _reliability := coalesce(NEW."EV_UTL_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."EV_UTL_ID"
    INTO
        _posit
    FROM
        attributes."EV_UTL_Händelse_Utnyttjande_Posit" p
    WHERE
        p."EV_UTL_EV_ID" = NEW."EV_UTL_EV_ID"
    AND
        attributes."eq_EV_UTL_Händelse_Utnyttjande"(p."EV_UTL_UTL_ID", NEW."EV_UTL_UTL_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_UTL_Händelse_Utnyttjande_Annex" a
        WHERE
            a."EV_UTL_ID" = _posit
        AND
            a."EV_UTL_Positor" = _positor
        AND
            a."EV_UTL_PositedAt" = _positing
        AND
            a."EV_UTL_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_UTL_Händelse_Utnyttjande for: %', concat_ws(', ', NEW."EV_UTL_EV_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_UTL_Händelse_Utnyttjande_Posit" p
        JOIN
            attributes."EV_UTL_Händelse_Utnyttjande_Annex" a
        ON
            a."EV_UTL_ID" = p."EV_UTL_ID"
        WHERE
            p."EV_UTL_EV_ID" = NEW."EV_UTL_EV_ID"
        AND
            NOT attributes."eq_EV_UTL_Händelse_Utnyttjande"(p."EV_UTL_UTL_ID", NEW."EV_UTL_UTL_ID")
        AND
            a."EV_UTL_Positor" = _positor
        AND
            a."EV_UTL_PositedAt" = _positing
        AND
            a."EV_UTL_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_UTL_Händelse_Utnyttjande for: %', concat_ws(', ', NEW."EV_UTL_EV_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_UTL_Händelse_Utnyttjande_Annex" a
        WHERE
            a."EV_UTL_ID" = _posit
        AND
            a."EV_UTL_Positor" = _positor
        AND
            a."EV_UTL_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_EV_UTL_Händelse_Utnyttjande"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_UTL_Händelse_Utnyttjande_Annex" (
            "Metadata_EV_UTL",
            "EV_UTL_ID",
            "EV_UTL_Positor",
            "EV_UTL_PositedAt",
            "EV_UTL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_UTL", 0),
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
            p."EV_UTL_ID"
        FROM
            attributes."EV_UTL_Händelse_Utnyttjande_Posit" p
        WHERE
            p."EV_UTL_EV_ID" = NEW."EV_UTL_EV_ID"
        AND
            NOT attributes."eq_EV_UTL_Händelse_Utnyttjande"(p."EV_UTL_UTL_ID", NEW."EV_UTL_UTL_ID")
        AND
            coalesce(attributes."he_EV_UTL_Händelse_Utnyttjande"(p."EV_UTL_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO attributes."EV_UTL_Händelse_Utnyttjande_Annex" (
            "Metadata_EV_UTL",
            "EV_UTL_ID",
            "EV_UTL_Positor",
            "EV_UTL_PositedAt",
            "EV_UTL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_UTL", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_UTL_Händelse_Utnyttjande_Posit" (
            "EV_UTL_EV_ID",
            "EV_UTL_UTL_ID"
        )
        VALUES (
            NEW."EV_UTL_EV_ID",
            NEW."EV_UTL_UTL_ID"
        )
        RETURNING "EV_UTL_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_UTL_Händelse_Utnyttjande_Annex" (
        "Metadata_EV_UTL",
        "EV_UTL_ID",
        "EV_UTL_Positor",
        "EV_UTL_PositedAt",
        "EV_UTL_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_UTL", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_UTL_Händelse_Utnyttjande" ON attributes."EV_UTL_Händelse_Utnyttjande";
CREATE TRIGGER "it_EV_UTL_Händelse_Utnyttjande"
INSTEAD OF INSERT ON attributes."EV_UTL_Händelse_Utnyttjande"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_UTL_Händelse_Utnyttjande"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_LVL_Händelse_Level tells whether two values of EV_LVL_Händelse_Level are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_LVL_Händelse_Level"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_LVL_Händelse_Level is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_EV_LVL_Händelse_Level"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."EV_LVL_Reliability"
    FROM
        attributes."EV_LVL_Händelse_Level_Annex" a
    WHERE
        a."EV_LVL_ID" = _id
    AND
        a."EV_LVL_Positor" = _positor
    AND
        a."EV_LVL_PositedAt" <= _positing
    ORDER BY
        a."EV_LVL_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_LVL_Händelse_Level instead of INSERT trigger on EV_LVL_Händelse_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_LVL_Händelse_Level"()
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
    _positor := coalesce(NEW."EV_LVL_Positor", 0);
    _positing := coalesce(NEW."EV_LVL_PositedAt", _now);
    _reliability := coalesce(NEW."EV_LVL_Reliability", 1);
    _changing := coalesce(NEW."EV_LVL_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."EV_LVL_ID"
    INTO
        _posit
    FROM
        attributes."EV_LVL_Händelse_Level_Posit" p
    WHERE
        p."EV_LVL_EV_ID" = NEW."EV_LVL_EV_ID"
    AND
        p."EV_LVL_ChangedAt" = _changing
    AND
        attributes."eq_EV_LVL_Händelse_Level"(p."EV_LVL_PLV_ID", NEW."EV_LVL_PLV_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_LVL_Händelse_Level_Annex" a
        WHERE
            a."EV_LVL_ID" = _posit
        AND
            a."EV_LVL_Positor" = _positor
        AND
            a."EV_LVL_PositedAt" = _positing
        AND
            a."EV_LVL_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_LVL_Händelse_Level for: %', concat_ws(', ', NEW."EV_LVL_EV_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_LVL_Händelse_Level_Posit" p
        JOIN
            attributes."EV_LVL_Händelse_Level_Annex" a
        ON
            a."EV_LVL_ID" = p."EV_LVL_ID"
        WHERE
            p."EV_LVL_EV_ID" = NEW."EV_LVL_EV_ID"
        AND
            p."EV_LVL_ChangedAt" = _changing
        AND
            NOT attributes."eq_EV_LVL_Händelse_Level"(p."EV_LVL_PLV_ID", NEW."EV_LVL_PLV_ID")
        AND
            a."EV_LVL_Positor" = _positor
        AND
            a."EV_LVL_PositedAt" = _positing
        AND
            a."EV_LVL_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_LVL_Händelse_Level for: %', concat_ws(', ', NEW."EV_LVL_EV_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_LVL_Händelse_Level_Annex" a
        WHERE
            a."EV_LVL_ID" = _posit
        AND
            a."EV_LVL_Positor" = _positor
        AND
            a."EV_LVL_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_EV_LVL_Händelse_Level"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_LVL_Händelse_Level_Annex" (
            "Metadata_EV_LVL",
            "EV_LVL_ID",
            "EV_LVL_Positor",
            "EV_LVL_PositedAt",
            "EV_LVL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_LVL", 0),
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
            p."EV_LVL_ID"
        FROM
            attributes."EV_LVL_Händelse_Level_Posit" p
        WHERE
            p."EV_LVL_EV_ID" = NEW."EV_LVL_EV_ID"
        AND
            p."EV_LVL_ChangedAt" = _changing
        AND
            NOT attributes."eq_EV_LVL_Händelse_Level"(p."EV_LVL_PLV_ID", NEW."EV_LVL_PLV_ID")
        AND
            coalesce(attributes."he_EV_LVL_Händelse_Level"(p."EV_LVL_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO attributes."EV_LVL_Händelse_Level_Annex" (
            "Metadata_EV_LVL",
            "EV_LVL_ID",
            "EV_LVL_Positor",
            "EV_LVL_PositedAt",
            "EV_LVL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_LVL", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_LVL_Händelse_Level_Posit" (
            "EV_LVL_EV_ID",
            "EV_LVL_ChangedAt",
            "EV_LVL_PLV_ID"
        )
        VALUES (
            NEW."EV_LVL_EV_ID",
            _changing,
            NEW."EV_LVL_PLV_ID"
        )
        RETURNING "EV_LVL_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_LVL_Händelse_Level_Annex" (
        "Metadata_EV_LVL",
        "EV_LVL_ID",
        "EV_LVL_Positor",
        "EV_LVL_PositedAt",
        "EV_LVL_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_LVL", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_LVL_Händelse_Level" ON attributes."EV_LVL_Händelse_Level";
CREATE TRIGGER "it_EV_LVL_Händelse_Level"
INSTEAD OF INSERT ON attributes."EV_LVL_Händelse_Level"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_LVL_Händelse_Level"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_NAM_Scen_Namn tells whether two values of ST_NAM_Scen_Namn are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_ST_NAM_Scen_Namn"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_NAM_Scen_Namn is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_ST_NAM_Scen_Namn"(
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
        attributes."ST_NAM_Scen_Namn_Annex" a
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
-- it_ST_NAM_Scen_Namn instead of INSERT trigger on ST_NAM_Scen_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_NAM_Scen_Namn"()
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
        attributes."ST_NAM_Scen_Namn_Posit" p
    WHERE
        p."ST_NAM_ST_ID" = NEW."ST_NAM_ST_ID"
    AND
        p."ST_NAM_ChangedAt" = _changing
    AND
        attributes."eq_ST_NAM_Scen_Namn"(p."ST_NAM_Scen_Namn", NEW."ST_NAM_Scen_Namn")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_NAM_Scen_Namn_Annex" a
        WHERE
            a."ST_NAM_ID" = _posit
        AND
            a."ST_NAM_Positor" = _positor
        AND
            a."ST_NAM_PositedAt" = _positing
        AND
            a."ST_NAM_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_NAM_Scen_Namn for: %', concat_ws(', ', NEW."ST_NAM_ST_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_NAM_Scen_Namn_Posit" p
        JOIN
            attributes."ST_NAM_Scen_Namn_Annex" a
        ON
            a."ST_NAM_ID" = p."ST_NAM_ID"
        WHERE
            p."ST_NAM_ST_ID" = NEW."ST_NAM_ST_ID"
        AND
            p."ST_NAM_ChangedAt" = _changing
        AND
            NOT attributes."eq_ST_NAM_Scen_Namn"(p."ST_NAM_Scen_Namn", NEW."ST_NAM_Scen_Namn")
        AND
            a."ST_NAM_Positor" = _positor
        AND
            a."ST_NAM_PositedAt" = _positing
        AND
            a."ST_NAM_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_NAM_Scen_Namn for: %', concat_ws(', ', NEW."ST_NAM_ST_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_NAM_Scen_Namn_Annex" a
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
        _held := attributes."he_ST_NAM_Scen_Namn"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."ST_NAM_Scen_Namn_Annex" (
            "Metadata_ST_NAM",
            "ST_NAM_ID",
            "ST_NAM_Positor",
            "ST_NAM_PositedAt",
            "ST_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_NAM", 0),
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
            attributes."ST_NAM_Scen_Namn_Posit" p
        WHERE
            p."ST_NAM_ST_ID" = NEW."ST_NAM_ST_ID"
        AND
            p."ST_NAM_ChangedAt" = _changing
        AND
            NOT attributes."eq_ST_NAM_Scen_Namn"(p."ST_NAM_Scen_Namn", NEW."ST_NAM_Scen_Namn")
        AND
            coalesce(attributes."he_ST_NAM_Scen_Namn"(p."ST_NAM_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO attributes."ST_NAM_Scen_Namn_Annex" (
            "Metadata_ST_NAM",
            "ST_NAM_ID",
            "ST_NAM_Positor",
            "ST_NAM_PositedAt",
            "ST_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_NAM", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."ST_NAM_Scen_Namn_Posit" (
            "ST_NAM_ST_ID",
            "ST_NAM_ChangedAt",
            "ST_NAM_Scen_Namn"
        )
        VALUES (
            NEW."ST_NAM_ST_ID",
            _changing,
            NEW."ST_NAM_Scen_Namn"
        )
        RETURNING "ST_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."ST_NAM_Scen_Namn_Annex" (
        "Metadata_ST_NAM",
        "ST_NAM_ID",
        "ST_NAM_Positor",
        "ST_NAM_PositedAt",
        "ST_NAM_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_ST_NAM", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_NAM_Scen_Namn" ON attributes."ST_NAM_Scen_Namn";
CREATE TRIGGER "it_ST_NAM_Scen_Namn"
INSTEAD OF INSERT ON attributes."ST_NAM_Scen_Namn"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_NAM_Scen_Namn"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_LOC_Scen_Plats tells whether two values of ST_LOC_Scen_Plats are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_ST_LOC_Scen_Plats"(
    l text,
    r text
)
RETURNS boolean
AS
$$
    SELECT md5(l::text) = md5(r::text)
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_LOC_Scen_Plats is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_ST_LOC_Scen_Plats"(
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
        attributes."ST_LOC_Scen_Plats_Annex" a
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
-- it_ST_LOC_Scen_Plats instead of INSERT trigger on ST_LOC_Scen_Plats
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_LOC_Scen_Plats"()
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
        attributes."ST_LOC_Scen_Plats_Posit" p
    WHERE
        p."ST_LOC_ST_ID" = NEW."ST_LOC_ST_ID"
    AND
        attributes."eq_ST_LOC_Scen_Plats"(p."ST_LOC_Scen_Plats", NEW."ST_LOC_Scen_Plats")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_LOC_Scen_Plats_Annex" a
        WHERE
            a."ST_LOC_ID" = _posit
        AND
            a."ST_LOC_Positor" = _positor
        AND
            a."ST_LOC_PositedAt" = _positing
        AND
            a."ST_LOC_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_LOC_Scen_Plats for: %', concat_ws(', ', NEW."ST_LOC_ST_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_LOC_Scen_Plats_Posit" p
        JOIN
            attributes."ST_LOC_Scen_Plats_Annex" a
        ON
            a."ST_LOC_ID" = p."ST_LOC_ID"
        WHERE
            p."ST_LOC_ST_ID" = NEW."ST_LOC_ST_ID"
        AND
            NOT attributes."eq_ST_LOC_Scen_Plats"(p."ST_LOC_Scen_Plats", NEW."ST_LOC_Scen_Plats")
        AND
            a."ST_LOC_Positor" = _positor
        AND
            a."ST_LOC_PositedAt" = _positing
        AND
            a."ST_LOC_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_LOC_Scen_Plats for: %', concat_ws(', ', NEW."ST_LOC_ST_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_LOC_Scen_Plats_Annex" a
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
        _held := attributes."he_ST_LOC_Scen_Plats"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."ST_LOC_Scen_Plats_Annex" (
            "Metadata_ST_LOC",
            "ST_LOC_ID",
            "ST_LOC_Positor",
            "ST_LOC_PositedAt",
            "ST_LOC_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_LOC", 0),
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
            attributes."ST_LOC_Scen_Plats_Posit" p
        WHERE
            p."ST_LOC_ST_ID" = NEW."ST_LOC_ST_ID"
        AND
            NOT attributes."eq_ST_LOC_Scen_Plats"(p."ST_LOC_Scen_Plats", NEW."ST_LOC_Scen_Plats")
        AND
            coalesce(attributes."he_ST_LOC_Scen_Plats"(p."ST_LOC_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO attributes."ST_LOC_Scen_Plats_Annex" (
            "Metadata_ST_LOC",
            "ST_LOC_ID",
            "ST_LOC_Positor",
            "ST_LOC_PositedAt",
            "ST_LOC_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_LOC", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."ST_LOC_Scen_Plats_Posit" (
            "ST_LOC_ST_ID",
            "ST_LOC_Scen_Plats"
        )
        VALUES (
            NEW."ST_LOC_ST_ID",
            NEW."ST_LOC_Scen_Plats"
        )
        RETURNING "ST_LOC_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."ST_LOC_Scen_Plats_Annex" (
        "Metadata_ST_LOC",
        "ST_LOC_ID",
        "ST_LOC_Positor",
        "ST_LOC_PositedAt",
        "ST_LOC_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_ST_LOC", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_LOC_Scen_Plats" ON attributes."ST_LOC_Scen_Plats";
CREATE TRIGGER "it_ST_LOC_Scen_Plats"
INSTEAD OF INSERT ON attributes."ST_LOC_Scen_Plats"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_LOC_Scen_Plats"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_AVG_Scen_Medel tells whether two values of ST_AVG_Scen_Medel are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_ST_AVG_Scen_Medel"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_AVG_Scen_Medel is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_ST_AVG_Scen_Medel"(
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
        attributes."ST_AVG_Scen_Medel_Annex" a
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
-- it_ST_AVG_Scen_Medel instead of INSERT trigger on ST_AVG_Scen_Medel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_AVG_Scen_Medel"()
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
        attributes."ST_AVG_Scen_Medel_Posit" p
    WHERE
        p."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
    AND
        p."ST_AVG_ChangedAt" = _changing
    AND
        attributes."eq_ST_AVG_Scen_Medel"(p."ST_AVG_UTL_ID", NEW."ST_AVG_UTL_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_AVG_Scen_Medel_Annex" a
        WHERE
            a."ST_AVG_ID" = _posit
        AND
            a."ST_AVG_Positor" = _positor
        AND
            a."ST_AVG_PositedAt" = _positing
        AND
            a."ST_AVG_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_AVG_Scen_Medel for: %', concat_ws(', ', NEW."ST_AVG_ST_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_AVG_Scen_Medel_Posit" p
        JOIN
            attributes."ST_AVG_Scen_Medel_Annex" a
        ON
            a."ST_AVG_ID" = p."ST_AVG_ID"
        WHERE
            p."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
        AND
            p."ST_AVG_ChangedAt" = _changing
        AND
            NOT attributes."eq_ST_AVG_Scen_Medel"(p."ST_AVG_UTL_ID", NEW."ST_AVG_UTL_ID")
        AND
            a."ST_AVG_Positor" = _positor
        AND
            a."ST_AVG_PositedAt" = _positing
        AND
            a."ST_AVG_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_AVG_Scen_Medel for: %', concat_ws(', ', NEW."ST_AVG_ST_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_AVG_Scen_Medel_Annex" a
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
        _held := attributes."he_ST_AVG_Scen_Medel"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."ST_AVG_Scen_Medel_Annex" (
            "Metadata_ST_AVG",
            "ST_AVG_ID",
            "ST_AVG_Positor",
            "ST_AVG_PositedAt",
            "ST_AVG_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_AVG", 0),
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
            attributes."ST_AVG_Scen_Medel_Posit" p
        WHERE
            p."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
        AND
            p."ST_AVG_ChangedAt" = _changing
        AND
            NOT attributes."eq_ST_AVG_Scen_Medel"(p."ST_AVG_UTL_ID", NEW."ST_AVG_UTL_ID")
        AND
            coalesce(attributes."he_ST_AVG_Scen_Medel"(p."ST_AVG_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO attributes."ST_AVG_Scen_Medel_Annex" (
            "Metadata_ST_AVG",
            "ST_AVG_ID",
            "ST_AVG_Positor",
            "ST_AVG_PositedAt",
            "ST_AVG_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_AVG", 0),
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
                p."ST_AVG_UTL_ID"
            FROM
                attributes."ST_AVG_Scen_Medel_Posit" p
            WHERE
                p."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
            AND
                p."ST_AVG_ChangedAt" < _changing
            AND
                coalesce(attributes."he_ST_AVG_Scen_Medel"(p."ST_AVG_ID", _positor, _positing), 0) <> 0
            AND
                (attributes."he_ST_AVG_Scen_Medel"(p."ST_AVG_ID", _positor, _positing) > 0) = (_reliability > 0)
            ORDER BY
                p."ST_AVG_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            attributes."eq_ST_AVG_Scen_Medel"(pre."ST_AVG_UTL_ID", NEW."ST_AVG_UTL_ID")
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
        attributes."ST_AVG_Scen_Medel_Posit" f
    WHERE
        f."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
    AND
        f."ST_AVG_ChangedAt" > _changing
    AND
        coalesce(attributes."he_ST_AVG_Scen_Medel"(f."ST_AVG_ID", _positor, _positing), 0) <> 0
    AND
        (attributes."he_ST_AVG_Scen_Medel"(f."ST_AVG_ID", _positor, _positing) > 0) = (_reliability > 0)
    ORDER BY
        f."ST_AVG_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND attributes."eq_ST_AVG_Scen_Medel"((
        SELECT x."ST_AVG_UTL_ID" FROM attributes."ST_AVG_Scen_Medel_Posit" x WHERE x."ST_AVG_ID" = _following
    ), NEW."ST_AVG_UTL_ID") THEN
        -- (an idempotent attribute retracts it)
        INSERT INTO attributes."ST_AVG_Scen_Medel_Annex" (
            "Metadata_ST_AVG",
            "ST_AVG_ID",
            "ST_AVG_Positor",
            "ST_AVG_PositedAt",
            "ST_AVG_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_AVG", 0),
            _following,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."ST_AVG_Scen_Medel_Posit" (
            "ST_AVG_ST_ID",
            "ST_AVG_ChangedAt",
            "ST_AVG_UTL_ID"
        )
        VALUES (
            NEW."ST_AVG_ST_ID",
            _changing,
            NEW."ST_AVG_UTL_ID"
        )
        RETURNING "ST_AVG_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."ST_AVG_Scen_Medel_Annex" (
        "Metadata_ST_AVG",
        "ST_AVG_ID",
        "ST_AVG_Positor",
        "ST_AVG_PositedAt",
        "ST_AVG_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_ST_AVG", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_AVG_Scen_Medel" ON attributes."ST_AVG_Scen_Medel";
CREATE TRIGGER "it_ST_AVG_Scen_Medel"
INSTEAD OF INSERT ON attributes."ST_AVG_Scen_Medel"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_AVG_Scen_Medel"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_MIN_Scen_Minimum tells whether two values of ST_MIN_Scen_Minimum are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_ST_MIN_Scen_Minimum"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_MIN_Scen_Minimum is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_ST_MIN_Scen_Minimum"(
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
        attributes."ST_MIN_Scen_Minimum_Annex" a
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
-- it_ST_MIN_Scen_Minimum instead of INSERT trigger on ST_MIN_Scen_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_MIN_Scen_Minimum"()
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
        attributes."ST_MIN_Scen_Minimum_Posit" p
    WHERE
        p."ST_MIN_ST_ID" = NEW."ST_MIN_ST_ID"
    AND
        attributes."eq_ST_MIN_Scen_Minimum"(p."ST_MIN_UTL_ID", NEW."ST_MIN_UTL_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_MIN_Scen_Minimum_Annex" a
        WHERE
            a."ST_MIN_ID" = _posit
        AND
            a."ST_MIN_Positor" = _positor
        AND
            a."ST_MIN_PositedAt" = _positing
        AND
            a."ST_MIN_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_MIN_Scen_Minimum for: %', concat_ws(', ', NEW."ST_MIN_ST_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_MIN_Scen_Minimum_Posit" p
        JOIN
            attributes."ST_MIN_Scen_Minimum_Annex" a
        ON
            a."ST_MIN_ID" = p."ST_MIN_ID"
        WHERE
            p."ST_MIN_ST_ID" = NEW."ST_MIN_ST_ID"
        AND
            NOT attributes."eq_ST_MIN_Scen_Minimum"(p."ST_MIN_UTL_ID", NEW."ST_MIN_UTL_ID")
        AND
            a."ST_MIN_Positor" = _positor
        AND
            a."ST_MIN_PositedAt" = _positing
        AND
            a."ST_MIN_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_MIN_Scen_Minimum for: %', concat_ws(', ', NEW."ST_MIN_ST_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_MIN_Scen_Minimum_Annex" a
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
        _held := attributes."he_ST_MIN_Scen_Minimum"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."ST_MIN_Scen_Minimum_Annex" (
            "Metadata_ST_MIN",
            "ST_MIN_ID",
            "ST_MIN_Positor",
            "ST_MIN_PositedAt",
            "ST_MIN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_MIN", 0),
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
            attributes."ST_MIN_Scen_Minimum_Posit" p
        WHERE
            p."ST_MIN_ST_ID" = NEW."ST_MIN_ST_ID"
        AND
            NOT attributes."eq_ST_MIN_Scen_Minimum"(p."ST_MIN_UTL_ID", NEW."ST_MIN_UTL_ID")
        AND
            coalesce(attributes."he_ST_MIN_Scen_Minimum"(p."ST_MIN_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO attributes."ST_MIN_Scen_Minimum_Annex" (
            "Metadata_ST_MIN",
            "ST_MIN_ID",
            "ST_MIN_Positor",
            "ST_MIN_PositedAt",
            "ST_MIN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_MIN", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."ST_MIN_Scen_Minimum_Posit" (
            "ST_MIN_ST_ID",
            "ST_MIN_UTL_ID"
        )
        VALUES (
            NEW."ST_MIN_ST_ID",
            NEW."ST_MIN_UTL_ID"
        )
        RETURNING "ST_MIN_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."ST_MIN_Scen_Minimum_Annex" (
        "Metadata_ST_MIN",
        "ST_MIN_ID",
        "ST_MIN_Positor",
        "ST_MIN_PositedAt",
        "ST_MIN_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_ST_MIN", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_MIN_Scen_Minimum" ON attributes."ST_MIN_Scen_Minimum";
CREATE TRIGGER "it_ST_MIN_Scen_Minimum"
INSTEAD OF INSERT ON attributes."ST_MIN_Scen_Minimum"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_MIN_Scen_Minimum"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_NAM_Skådespelare_Namn tells whether two values of AC_NAM_Skådespelare_Namn are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_AC_NAM_Skådespelare_Namn"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_NAM_Skådespelare_Namn is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_AC_NAM_Skådespelare_Namn"(
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
        attributes."AC_NAM_Skådespelare_Namn_Annex" a
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
-- it_AC_NAM_Skådespelare_Namn instead of INSERT trigger on AC_NAM_Skådespelare_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_AC_NAM_Skådespelare_Namn"()
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
        attributes."AC_NAM_Skådespelare_Namn_Posit" p
    WHERE
        p."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
    AND
        p."AC_NAM_ChangedAt" = _changing
    AND
        attributes."eq_AC_NAM_Skådespelare_Namn"(p."AC_NAM_Skådespelare_Namn", NEW."AC_NAM_Skådespelare_Namn")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_NAM_Skådespelare_Namn_Annex" a
        WHERE
            a."AC_NAM_ID" = _posit
        AND
            a."AC_NAM_Positor" = _positor
        AND
            a."AC_NAM_PositedAt" = _positing
        AND
            a."AC_NAM_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_NAM_Skådespelare_Namn for: %', concat_ws(', ', NEW."AC_NAM_AC_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_NAM_Skådespelare_Namn_Posit" p
        JOIN
            attributes."AC_NAM_Skådespelare_Namn_Annex" a
        ON
            a."AC_NAM_ID" = p."AC_NAM_ID"
        WHERE
            p."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
        AND
            p."AC_NAM_ChangedAt" = _changing
        AND
            NOT attributes."eq_AC_NAM_Skådespelare_Namn"(p."AC_NAM_Skådespelare_Namn", NEW."AC_NAM_Skådespelare_Namn")
        AND
            a."AC_NAM_Positor" = _positor
        AND
            a."AC_NAM_PositedAt" = _positing
        AND
            a."AC_NAM_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_NAM_Skådespelare_Namn for: %', concat_ws(', ', NEW."AC_NAM_AC_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_NAM_Skådespelare_Namn_Annex" a
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
        _held := attributes."he_AC_NAM_Skådespelare_Namn"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."AC_NAM_Skådespelare_Namn_Annex" (
            "Metadata_AC_NAM",
            "AC_NAM_ID",
            "AC_NAM_Positor",
            "AC_NAM_PositedAt",
            "AC_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_NAM", 0),
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
            attributes."AC_NAM_Skådespelare_Namn_Posit" p
        WHERE
            p."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
        AND
            p."AC_NAM_ChangedAt" = _changing
        AND
            NOT attributes."eq_AC_NAM_Skådespelare_Namn"(p."AC_NAM_Skådespelare_Namn", NEW."AC_NAM_Skådespelare_Namn")
        AND
            coalesce(attributes."he_AC_NAM_Skådespelare_Namn"(p."AC_NAM_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO attributes."AC_NAM_Skådespelare_Namn_Annex" (
            "Metadata_AC_NAM",
            "AC_NAM_ID",
            "AC_NAM_Positor",
            "AC_NAM_PositedAt",
            "AC_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_NAM", 0),
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
                p."AC_NAM_Skådespelare_Namn"
            FROM
                attributes."AC_NAM_Skådespelare_Namn_Posit" p
            WHERE
                p."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
            AND
                p."AC_NAM_ChangedAt" < _changing
            AND
                coalesce(attributes."he_AC_NAM_Skådespelare_Namn"(p."AC_NAM_ID", _positor, _positing), 0) <> 0
            AND
                (attributes."he_AC_NAM_Skådespelare_Namn"(p."AC_NAM_ID", _positor, _positing) > 0) = (_reliability > 0)
            ORDER BY
                p."AC_NAM_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            attributes."eq_AC_NAM_Skådespelare_Namn"(pre."AC_NAM_Skådespelare_Namn", NEW."AC_NAM_Skådespelare_Namn")
    ) THEN
        RAISE EXCEPTION 'Restatement in AC_NAM_Skådespelare_Namn for: %', concat_ws(', ', NEW."AC_NAM_AC_ID", _changing, _positor, _positing);
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."AC_NAM_ID"
    INTO
        _following
    FROM
        attributes."AC_NAM_Skådespelare_Namn_Posit" f
    WHERE
        f."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
    AND
        f."AC_NAM_ChangedAt" > _changing
    AND
        coalesce(attributes."he_AC_NAM_Skådespelare_Namn"(f."AC_NAM_ID", _positor, _positing), 0) <> 0
    AND
        (attributes."he_AC_NAM_Skådespelare_Namn"(f."AC_NAM_ID", _positor, _positing) > 0) = (_reliability > 0)
    ORDER BY
        f."AC_NAM_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND attributes."eq_AC_NAM_Skådespelare_Namn"((
        SELECT x."AC_NAM_Skådespelare_Namn" FROM attributes."AC_NAM_Skådespelare_Namn_Posit" x WHERE x."AC_NAM_ID" = _following
    ), NEW."AC_NAM_Skådespelare_Namn") THEN
        RAISE EXCEPTION 'Restatement in AC_NAM_Skådespelare_Namn for: %', concat_ws(', ', NEW."AC_NAM_AC_ID", _changing, _positor, _positing);
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."AC_NAM_Skådespelare_Namn_Posit" (
            "AC_NAM_AC_ID",
            "AC_NAM_ChangedAt",
            "AC_NAM_Skådespelare_Namn"
        )
        VALUES (
            NEW."AC_NAM_AC_ID",
            _changing,
            NEW."AC_NAM_Skådespelare_Namn"
        )
        RETURNING "AC_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."AC_NAM_Skådespelare_Namn_Annex" (
        "Metadata_AC_NAM",
        "AC_NAM_ID",
        "AC_NAM_Positor",
        "AC_NAM_PositedAt",
        "AC_NAM_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_NAM", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_NAM_Skådespelare_Namn" ON attributes."AC_NAM_Skådespelare_Namn";
CREATE TRIGGER "it_AC_NAM_Skådespelare_Namn"
INSTEAD OF INSERT ON attributes."AC_NAM_Skådespelare_Namn"
FOR EACH ROW EXECUTE FUNCTION attributes."it_AC_NAM_Skådespelare_Namn"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_GEN_Skådespelare_Kön tells whether two values of AC_GEN_Skådespelare_Kön are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_AC_GEN_Skådespelare_Kön"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_GEN_Skådespelare_Kön is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_AC_GEN_Skådespelare_Kön"(
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
        attributes."AC_GEN_Skådespelare_Kön_Annex" a
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
-- it_AC_GEN_Skådespelare_Kön instead of INSERT trigger on AC_GEN_Skådespelare_Kön
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_AC_GEN_Skådespelare_Kön"()
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
        attributes."AC_GEN_Skådespelare_Kön_Posit" p
    WHERE
        p."AC_GEN_AC_ID" = NEW."AC_GEN_AC_ID"
    AND
        attributes."eq_AC_GEN_Skådespelare_Kön"(p."AC_GEN_GEN_ID", NEW."AC_GEN_GEN_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_GEN_Skådespelare_Kön_Annex" a
        WHERE
            a."AC_GEN_ID" = _posit
        AND
            a."AC_GEN_Positor" = _positor
        AND
            a."AC_GEN_PositedAt" = _positing
        AND
            a."AC_GEN_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_GEN_Skådespelare_Kön for: %', concat_ws(', ', NEW."AC_GEN_AC_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_GEN_Skådespelare_Kön_Posit" p
        JOIN
            attributes."AC_GEN_Skådespelare_Kön_Annex" a
        ON
            a."AC_GEN_ID" = p."AC_GEN_ID"
        WHERE
            p."AC_GEN_AC_ID" = NEW."AC_GEN_AC_ID"
        AND
            NOT attributes."eq_AC_GEN_Skådespelare_Kön"(p."AC_GEN_GEN_ID", NEW."AC_GEN_GEN_ID")
        AND
            a."AC_GEN_Positor" = _positor
        AND
            a."AC_GEN_PositedAt" = _positing
        AND
            a."AC_GEN_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_GEN_Skådespelare_Kön for: %', concat_ws(', ', NEW."AC_GEN_AC_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_GEN_Skådespelare_Kön_Annex" a
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
        _held := attributes."he_AC_GEN_Skådespelare_Kön"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."AC_GEN_Skådespelare_Kön_Annex" (
            "Metadata_AC_GEN",
            "AC_GEN_ID",
            "AC_GEN_Positor",
            "AC_GEN_PositedAt",
            "AC_GEN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_GEN", 0),
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
            attributes."AC_GEN_Skådespelare_Kön_Posit" p
        WHERE
            p."AC_GEN_AC_ID" = NEW."AC_GEN_AC_ID"
        AND
            NOT attributes."eq_AC_GEN_Skådespelare_Kön"(p."AC_GEN_GEN_ID", NEW."AC_GEN_GEN_ID")
        AND
            coalesce(attributes."he_AC_GEN_Skådespelare_Kön"(p."AC_GEN_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO attributes."AC_GEN_Skådespelare_Kön_Annex" (
            "Metadata_AC_GEN",
            "AC_GEN_ID",
            "AC_GEN_Positor",
            "AC_GEN_PositedAt",
            "AC_GEN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_GEN", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."AC_GEN_Skådespelare_Kön_Posit" (
            "AC_GEN_AC_ID",
            "AC_GEN_GEN_ID"
        )
        VALUES (
            NEW."AC_GEN_AC_ID",
            NEW."AC_GEN_GEN_ID"
        )
        RETURNING "AC_GEN_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."AC_GEN_Skådespelare_Kön_Annex" (
        "Metadata_AC_GEN",
        "AC_GEN_ID",
        "AC_GEN_Positor",
        "AC_GEN_PositedAt",
        "AC_GEN_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_GEN", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_GEN_Skådespelare_Kön" ON attributes."AC_GEN_Skådespelare_Kön";
CREATE TRIGGER "it_AC_GEN_Skådespelare_Kön"
INSTEAD OF INSERT ON attributes."AC_GEN_Skådespelare_Kön"
FOR EACH ROW EXECUTE FUNCTION attributes."it_AC_GEN_Skådespelare_Kön"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_PLV_Skådespelare_Yrkesnivå tells whether two values of AC_PLV_Skådespelare_Yrkesnivå are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_AC_PLV_Skådespelare_Yrkesnivå"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_PLV_Skådespelare_Yrkesnivå is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_AC_PLV_Skådespelare_Yrkesnivå"(
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
        attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" a
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
-- it_AC_PLV_Skådespelare_Yrkesnivå instead of INSERT trigger on AC_PLV_Skådespelare_Yrkesnivå
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_AC_PLV_Skådespelare_Yrkesnivå"()
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
        attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" p
    WHERE
        p."AC_PLV_AC_ID" = NEW."AC_PLV_AC_ID"
    AND
        p."AC_PLV_ChangedAt" = _changing
    AND
        attributes."eq_AC_PLV_Skådespelare_Yrkesnivå"(p."AC_PLV_PLV_ID", NEW."AC_PLV_PLV_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" a
        WHERE
            a."AC_PLV_ID" = _posit
        AND
            a."AC_PLV_Positor" = _positor
        AND
            a."AC_PLV_PositedAt" = _positing
        AND
            a."AC_PLV_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_PLV_Skådespelare_Yrkesnivå for: %', concat_ws(', ', NEW."AC_PLV_AC_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" p
        JOIN
            attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" a
        ON
            a."AC_PLV_ID" = p."AC_PLV_ID"
        WHERE
            p."AC_PLV_AC_ID" = NEW."AC_PLV_AC_ID"
        AND
            p."AC_PLV_ChangedAt" = _changing
        AND
            NOT attributes."eq_AC_PLV_Skådespelare_Yrkesnivå"(p."AC_PLV_PLV_ID", NEW."AC_PLV_PLV_ID")
        AND
            a."AC_PLV_Positor" = _positor
        AND
            a."AC_PLV_PositedAt" = _positing
        AND
            a."AC_PLV_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_PLV_Skådespelare_Yrkesnivå for: %', concat_ws(', ', NEW."AC_PLV_AC_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" a
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
        _held := attributes."he_AC_PLV_Skådespelare_Yrkesnivå"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" (
            "Metadata_AC_PLV",
            "AC_PLV_ID",
            "AC_PLV_Positor",
            "AC_PLV_PositedAt",
            "AC_PLV_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_PLV", 0),
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
            attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" p
        WHERE
            p."AC_PLV_AC_ID" = NEW."AC_PLV_AC_ID"
        AND
            p."AC_PLV_ChangedAt" = _changing
        AND
            NOT attributes."eq_AC_PLV_Skådespelare_Yrkesnivå"(p."AC_PLV_PLV_ID", NEW."AC_PLV_PLV_ID")
        AND
            coalesce(attributes."he_AC_PLV_Skådespelare_Yrkesnivå"(p."AC_PLV_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" (
            "Metadata_AC_PLV",
            "AC_PLV_ID",
            "AC_PLV_Positor",
            "AC_PLV_PositedAt",
            "AC_PLV_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_PLV", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" (
            "AC_PLV_AC_ID",
            "AC_PLV_ChangedAt",
            "AC_PLV_PLV_ID"
        )
        VALUES (
            NEW."AC_PLV_AC_ID",
            _changing,
            NEW."AC_PLV_PLV_ID"
        )
        RETURNING "AC_PLV_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" (
        "Metadata_AC_PLV",
        "AC_PLV_ID",
        "AC_PLV_Positor",
        "AC_PLV_PositedAt",
        "AC_PLV_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_PLV", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_PLV_Skådespelare_Yrkesnivå" ON attributes."AC_PLV_Skådespelare_Yrkesnivå";
CREATE TRIGGER "it_AC_PLV_Skådespelare_Yrkesnivå"
INSTEAD OF INSERT ON attributes."AC_PLV_Skådespelare_Yrkesnivå"
FOR EACH ROW EXECUTE FUNCTION attributes."it_AC_PLV_Skådespelare_Yrkesnivå"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_NAM_Föreställning_Namn tells whether two values of PR_NAM_Föreställning_Namn are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_PR_NAM_Föreställning_Namn"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_NAM_Föreställning_Namn is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_PR_NAM_Föreställning_Namn"(
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
        attributes."PR_NAM_Föreställning_Namn_Annex" a
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
-- it_PR_NAM_Föreställning_Namn instead of INSERT trigger on PR_NAM_Föreställning_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_PR_NAM_Föreställning_Namn"()
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
        attributes."PR_NAM_Föreställning_Namn_Posit" p
    WHERE
        p."PR_NAM_PR_ID" = NEW."PR_NAM_PR_ID"
    AND
        attributes."eq_PR_NAM_Föreställning_Namn"(p."PR_NAM_Föreställning_Namn", NEW."PR_NAM_Föreställning_Namn")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_NAM_Föreställning_Namn_Annex" a
        WHERE
            a."PR_NAM_ID" = _posit
        AND
            a."PR_NAM_Positor" = _positor
        AND
            a."PR_NAM_PositedAt" = _positing
        AND
            a."PR_NAM_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_NAM_Föreställning_Namn for: %', concat_ws(', ', NEW."PR_NAM_PR_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_NAM_Föreställning_Namn_Posit" p
        JOIN
            attributes."PR_NAM_Föreställning_Namn_Annex" a
        ON
            a."PR_NAM_ID" = p."PR_NAM_ID"
        WHERE
            p."PR_NAM_PR_ID" = NEW."PR_NAM_PR_ID"
        AND
            NOT attributes."eq_PR_NAM_Föreställning_Namn"(p."PR_NAM_Föreställning_Namn", NEW."PR_NAM_Föreställning_Namn")
        AND
            a."PR_NAM_Positor" = _positor
        AND
            a."PR_NAM_PositedAt" = _positing
        AND
            a."PR_NAM_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_NAM_Föreställning_Namn for: %', concat_ws(', ', NEW."PR_NAM_PR_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_NAM_Föreställning_Namn_Annex" a
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
        _held := attributes."he_PR_NAM_Föreställning_Namn"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."PR_NAM_Föreställning_Namn_Annex" (
            "Metadata_PR_NAM",
            "PR_NAM_ID",
            "PR_NAM_Positor",
            "PR_NAM_PositedAt",
            "PR_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_NAM", 0),
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
            attributes."PR_NAM_Föreställning_Namn_Posit" p
        WHERE
            p."PR_NAM_PR_ID" = NEW."PR_NAM_PR_ID"
        AND
            NOT attributes."eq_PR_NAM_Föreställning_Namn"(p."PR_NAM_Föreställning_Namn", NEW."PR_NAM_Föreställning_Namn")
        AND
            coalesce(attributes."he_PR_NAM_Föreställning_Namn"(p."PR_NAM_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO attributes."PR_NAM_Föreställning_Namn_Annex" (
            "Metadata_PR_NAM",
            "PR_NAM_ID",
            "PR_NAM_Positor",
            "PR_NAM_PositedAt",
            "PR_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_NAM", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."PR_NAM_Föreställning_Namn_Posit" (
            "PR_NAM_PR_ID",
            "PR_NAM_Föreställning_Namn"
        )
        VALUES (
            NEW."PR_NAM_PR_ID",
            NEW."PR_NAM_Föreställning_Namn"
        )
        RETURNING "PR_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."PR_NAM_Föreställning_Namn_Annex" (
        "Metadata_PR_NAM",
        "PR_NAM_ID",
        "PR_NAM_Positor",
        "PR_NAM_PositedAt",
        "PR_NAM_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_PR_NAM", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_PR_NAM_Föreställning_Namn" ON attributes."PR_NAM_Föreställning_Namn";
CREATE TRIGGER "it_PR_NAM_Föreställning_Namn"
INSTEAD OF INSERT ON attributes."PR_NAM_Föreställning_Namn"
FOR EACH ROW EXECUTE FUNCTION attributes."it_PR_NAM_Föreställning_Namn"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_LEN_Föreställning_Längd tells whether two values of PR_LEN_Föreställning_Längd are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_PR_LEN_Föreställning_Längd"(
    l time,
    r time
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_LEN_Föreställning_Längd is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_PR_LEN_Föreställning_Längd"(
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
        attributes."PR_LEN_Föreställning_Längd_Annex" a
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
-- it_PR_LEN_Föreställning_Längd instead of INSERT trigger on PR_LEN_Föreställning_Längd
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_PR_LEN_Föreställning_Längd"()
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
        attributes."PR_LEN_Föreställning_Längd_Posit" p
    WHERE
        p."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
    AND
        p."PR_LEN_ChangedAt" = _changing
    AND
        attributes."eq_PR_LEN_Föreställning_Längd"(p."PR_LEN_Föreställning_Längd", NEW."PR_LEN_Föreställning_Längd")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_LEN_Föreställning_Längd_Annex" a
        WHERE
            a."PR_LEN_ID" = _posit
        AND
            a."PR_LEN_Positor" = _positor
        AND
            a."PR_LEN_PositedAt" = _positing
        AND
            a."PR_LEN_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_LEN_Föreställning_Längd for: %', concat_ws(', ', NEW."PR_LEN_PR_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_LEN_Föreställning_Längd_Posit" p
        JOIN
            attributes."PR_LEN_Föreställning_Längd_Annex" a
        ON
            a."PR_LEN_ID" = p."PR_LEN_ID"
        WHERE
            p."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
        AND
            p."PR_LEN_ChangedAt" = _changing
        AND
            NOT attributes."eq_PR_LEN_Föreställning_Längd"(p."PR_LEN_Föreställning_Längd", NEW."PR_LEN_Föreställning_Längd")
        AND
            a."PR_LEN_Positor" = _positor
        AND
            a."PR_LEN_PositedAt" = _positing
        AND
            a."PR_LEN_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_LEN_Föreställning_Längd for: %', concat_ws(', ', NEW."PR_LEN_PR_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_LEN_Föreställning_Längd_Annex" a
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
        _held := attributes."he_PR_LEN_Föreställning_Längd"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."PR_LEN_Föreställning_Längd_Annex" (
            "Metadata_PR_LEN",
            "PR_LEN_ID",
            "PR_LEN_Positor",
            "PR_LEN_PositedAt",
            "PR_LEN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_LEN", 0),
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
            attributes."PR_LEN_Föreställning_Längd_Posit" p
        WHERE
            p."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
        AND
            p."PR_LEN_ChangedAt" = _changing
        AND
            NOT attributes."eq_PR_LEN_Föreställning_Längd"(p."PR_LEN_Föreställning_Längd", NEW."PR_LEN_Föreställning_Längd")
        AND
            coalesce(attributes."he_PR_LEN_Föreställning_Längd"(p."PR_LEN_ID", _positor, _positing), 0) <> 0
    LOOP
        INSERT INTO attributes."PR_LEN_Föreställning_Längd_Annex" (
            "Metadata_PR_LEN",
            "PR_LEN_ID",
            "PR_LEN_Positor",
            "PR_LEN_PositedAt",
            "PR_LEN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_LEN", 0),
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
                p."PR_LEN_Föreställning_Längd"
            FROM
                attributes."PR_LEN_Föreställning_Längd_Posit" p
            WHERE
                p."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
            AND
                p."PR_LEN_ChangedAt" < _changing
            AND
                coalesce(attributes."he_PR_LEN_Föreställning_Längd"(p."PR_LEN_ID", _positor, _positing), 0) <> 0
            AND
                (attributes."he_PR_LEN_Föreställning_Längd"(p."PR_LEN_ID", _positor, _positing) > 0) = (_reliability > 0)
            ORDER BY
                p."PR_LEN_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            attributes."eq_PR_LEN_Föreställning_Längd"(pre."PR_LEN_Föreställning_Längd", NEW."PR_LEN_Föreställning_Längd")
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
        attributes."PR_LEN_Föreställning_Längd_Posit" f
    WHERE
        f."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
    AND
        f."PR_LEN_ChangedAt" > _changing
    AND
        coalesce(attributes."he_PR_LEN_Föreställning_Längd"(f."PR_LEN_ID", _positor, _positing), 0) <> 0
    AND
        (attributes."he_PR_LEN_Föreställning_Längd"(f."PR_LEN_ID", _positor, _positing) > 0) = (_reliability > 0)
    ORDER BY
        f."PR_LEN_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND attributes."eq_PR_LEN_Föreställning_Längd"((
        SELECT x."PR_LEN_Föreställning_Längd" FROM attributes."PR_LEN_Föreställning_Längd_Posit" x WHERE x."PR_LEN_ID" = _following
    ), NEW."PR_LEN_Föreställning_Längd") THEN
        -- (an idempotent attribute retracts it)
        INSERT INTO attributes."PR_LEN_Föreställning_Längd_Annex" (
            "Metadata_PR_LEN",
            "PR_LEN_ID",
            "PR_LEN_Positor",
            "PR_LEN_PositedAt",
            "PR_LEN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_LEN", 0),
            _following,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."PR_LEN_Föreställning_Längd_Posit" (
            "PR_LEN_PR_ID",
            "PR_LEN_ChangedAt",
            "PR_LEN_Föreställning_Längd"
        )
        VALUES (
            NEW."PR_LEN_PR_ID",
            _changing,
            NEW."PR_LEN_Föreställning_Längd"
        )
        RETURNING "PR_LEN_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."PR_LEN_Föreställning_Längd_Annex" (
        "Metadata_PR_LEN",
        "PR_LEN_ID",
        "PR_LEN_Positor",
        "PR_LEN_PositedAt",
        "PR_LEN_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_PR_LEN", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_PR_LEN_Föreställning_Längd" ON attributes."PR_LEN_Föreställning_Längd";
CREATE TRIGGER "it_PR_LEN_Föreställning_Längd"
INSTEAD OF INSERT ON attributes."PR_LEN_Föreställning_Längd"
FOR EACH ROW EXECUTE FUNCTION attributes."it_PR_LEN_Föreställning_Längd"();
