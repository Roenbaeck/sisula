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
CREATE OR REPLACE FUNCTION attributes."eq_EV_DAT_Event_Date"(
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
CREATE OR REPLACE FUNCTION attributes."he_EV_DAT_Event_Date"(
    _id bigint,
    _positor smallint,
    _positing timestamp(3)
)
RETURNS decimal(7,3)
AS
$$
    SELECT
        a."EV_DAT_Confidence"
    FROM
        attributes."EV_DAT_Event_Date_Meta" a
    WHERE
        a."EV_DAT_ID" = _id
    AND
        a."EV_DAT_Who" = _positor
    AND
        a."EV_DAT_PositedAt" <= _positing
    ORDER BY
        a."EV_DAT_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_DAT_Event_Date instead of INSERT trigger on EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_DAT_Event_Date"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp(3);
    _reliability decimal(7,3);
    _held decimal(7,3);
    _posit bigint;
    _other bigint;
    _following bigint;
    _total decimal(7,3);
BEGIN
    _positor := coalesce(NEW."EV_DAT_Who", 0);
    _positing := coalesce(NEW."EV_DAT_PositedAt", _now);
    _reliability := coalesce(NEW."EV_DAT_Confidence", 1);
    -- the posit, if there is one
    SELECT
        p."EV_DAT_ID"
    INTO
        _posit
    FROM
        attributes."EV_DAT_Event_Date_Fact" p
    WHERE
        p."EV_DAT_EV_ID" = NEW."EV_DAT_EV_ID"
    AND
        attributes."eq_EV_DAT_Event_Date"(p."EV_DAT_Event_Date", NEW."EV_DAT_Event_Date")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_DAT_Event_Date_Meta" a
        WHERE
            a."EV_DAT_ID" = _posit
        AND
            a."EV_DAT_Who" = _positor
        AND
            a."EV_DAT_PositedAt" = _positing
        AND
            a."EV_DAT_Confidence" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_DAT_Event_Date for: %', concat_ws(', ', NEW."EV_DAT_EV_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0.25 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_DAT_Event_Date_Fact" p
        JOIN
            attributes."EV_DAT_Event_Date_Meta" a
        ON
            a."EV_DAT_ID" = p."EV_DAT_ID"
        WHERE
            p."EV_DAT_EV_ID" = NEW."EV_DAT_EV_ID"
        AND
            NOT attributes."eq_EV_DAT_Event_Date"(p."EV_DAT_Event_Date", NEW."EV_DAT_Event_Date")
        AND
            a."EV_DAT_Who" = _positor
        AND
            a."EV_DAT_PositedAt" = _positing
        AND
            a."EV_DAT_Confidence" <> 0.25
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_DAT_Event_Date for: %', concat_ws(', ', NEW."EV_DAT_EV_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_DAT_Event_Date_Meta" a
        WHERE
            a."EV_DAT_ID" = _posit
        AND
            a."EV_DAT_Who" = _positor
        AND
            a."EV_DAT_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_EV_DAT_Event_Date"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0.25) = 0.25 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_DAT_Event_Date_Meta" (
            "Metadata_EV_DAT",
            "EV_DAT_ID",
            "EV_DAT_Who",
            "EV_DAT_PositedAt",
            "EV_DAT_Confidence"
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
            attributes."EV_DAT_Event_Date_Fact" p
        WHERE
            p."EV_DAT_EV_ID" = NEW."EV_DAT_EV_ID"
        AND
            NOT attributes."eq_EV_DAT_Event_Date"(p."EV_DAT_Event_Date", NEW."EV_DAT_Event_Date")
        AND
            coalesce(attributes."he_EV_DAT_Event_Date"(p."EV_DAT_ID", _positor, _positing), 0.25) <> 0.25
    LOOP
        INSERT INTO attributes."EV_DAT_Event_Date_Meta" (
            "Metadata_EV_DAT",
            "EV_DAT_ID",
            "EV_DAT_Who",
            "EV_DAT_PositedAt",
            "EV_DAT_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_DAT", 0),
            _other,
            _positor,
            _positing,
            0.25
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_DAT_Event_Date_Fact" (
            "EV_DAT_EV_ID",
            "EV_DAT_Event_Date"
        )
        VALUES (
            NEW."EV_DAT_EV_ID",
            NEW."EV_DAT_Event_Date"
        )
        RETURNING "EV_DAT_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_DAT_Event_Date_Meta" (
        "Metadata_EV_DAT",
        "EV_DAT_ID",
        "EV_DAT_Who",
        "EV_DAT_PositedAt",
        "EV_DAT_Confidence"
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
DROP TRIGGER IF EXISTS "it_EV_DAT_Event_Date" ON attributes."EV_DAT_Event_Date";
CREATE TRIGGER "it_EV_DAT_Event_Date"
INSTEAD OF INSERT ON attributes."EV_DAT_Event_Date"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_DAT_Event_Date"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_AUD_Event_Audience tells whether two values of EV_AUD_Event_Audience are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_AUD_Event_Audience"(
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
CREATE OR REPLACE FUNCTION attributes."he_EV_AUD_Event_Audience"(
    _id bigint,
    _positor smallint,
    _positing timestamp(3)
)
RETURNS decimal(7,3)
AS
$$
    SELECT
        a."EV_AUD_Confidence"
    FROM
        attributes."EV_AUD_Event_Audience_Meta" a
    WHERE
        a."EV_AUD_ID" = _id
    AND
        a."EV_AUD_Who" = _positor
    AND
        a."EV_AUD_PositedAt" <= _positing
    ORDER BY
        a."EV_AUD_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_AUD_Event_Audience instead of INSERT trigger on EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_AUD_Event_Audience"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp(3);
    _reliability decimal(7,3);
    _held decimal(7,3);
    _posit bigint;
    _other bigint;
    _following bigint;
    _total decimal(7,3);
BEGIN
    _positor := coalesce(NEW."EV_AUD_Who", 0);
    _positing := coalesce(NEW."EV_AUD_PositedAt", _now);
    _reliability := coalesce(NEW."EV_AUD_Confidence", 1);
    -- the posit, if there is one
    SELECT
        p."EV_AUD_ID"
    INTO
        _posit
    FROM
        attributes."EV_AUD_Event_Audience_Fact" p
    WHERE
        p."EV_AUD_EV_ID" = NEW."EV_AUD_EV_ID"
    AND
        attributes."eq_EV_AUD_Event_Audience"(p."EV_AUD_Event_Audience", NEW."EV_AUD_Event_Audience")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_AUD_Event_Audience_Meta" a
        WHERE
            a."EV_AUD_ID" = _posit
        AND
            a."EV_AUD_Who" = _positor
        AND
            a."EV_AUD_PositedAt" = _positing
        AND
            a."EV_AUD_Confidence" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_AUD_Event_Audience for: %', concat_ws(', ', NEW."EV_AUD_EV_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0.25 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_AUD_Event_Audience_Fact" p
        JOIN
            attributes."EV_AUD_Event_Audience_Meta" a
        ON
            a."EV_AUD_ID" = p."EV_AUD_ID"
        WHERE
            p."EV_AUD_EV_ID" = NEW."EV_AUD_EV_ID"
        AND
            NOT attributes."eq_EV_AUD_Event_Audience"(p."EV_AUD_Event_Audience", NEW."EV_AUD_Event_Audience")
        AND
            a."EV_AUD_Who" = _positor
        AND
            a."EV_AUD_PositedAt" = _positing
        AND
            a."EV_AUD_Confidence" <> 0.25
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_AUD_Event_Audience for: %', concat_ws(', ', NEW."EV_AUD_EV_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_AUD_Event_Audience_Meta" a
        WHERE
            a."EV_AUD_ID" = _posit
        AND
            a."EV_AUD_Who" = _positor
        AND
            a."EV_AUD_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_EV_AUD_Event_Audience"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0.25) = 0.25 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_AUD_Event_Audience_Meta" (
            "Metadata_EV_AUD",
            "EV_AUD_ID",
            "EV_AUD_Who",
            "EV_AUD_PositedAt",
            "EV_AUD_Confidence"
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
            attributes."EV_AUD_Event_Audience_Fact" p
        WHERE
            p."EV_AUD_EV_ID" = NEW."EV_AUD_EV_ID"
        AND
            NOT attributes."eq_EV_AUD_Event_Audience"(p."EV_AUD_Event_Audience", NEW."EV_AUD_Event_Audience")
        AND
            coalesce(attributes."he_EV_AUD_Event_Audience"(p."EV_AUD_ID", _positor, _positing), 0.25) <> 0.25
    LOOP
        INSERT INTO attributes."EV_AUD_Event_Audience_Meta" (
            "Metadata_EV_AUD",
            "EV_AUD_ID",
            "EV_AUD_Who",
            "EV_AUD_PositedAt",
            "EV_AUD_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_AUD", 0),
            _other,
            _positor,
            _positing,
            0.25
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_AUD_Event_Audience_Fact" (
            "EV_AUD_EV_ID",
            "EV_AUD_Event_Audience"
        )
        VALUES (
            NEW."EV_AUD_EV_ID",
            NEW."EV_AUD_Event_Audience"
        )
        RETURNING "EV_AUD_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_AUD_Event_Audience_Meta" (
        "Metadata_EV_AUD",
        "EV_AUD_ID",
        "EV_AUD_Who",
        "EV_AUD_PositedAt",
        "EV_AUD_Confidence"
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
DROP TRIGGER IF EXISTS "it_EV_AUD_Event_Audience" ON attributes."EV_AUD_Event_Audience";
CREATE TRIGGER "it_EV_AUD_Event_Audience"
INSTEAD OF INSERT ON attributes."EV_AUD_Event_Audience"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_AUD_Event_Audience"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_REV_Event_Revenue tells whether two values of EV_REV_Event_Revenue are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_REV_Event_Revenue"(
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
CREATE OR REPLACE FUNCTION attributes."he_EV_REV_Event_Revenue"(
    _id bigint,
    _positor smallint,
    _positing timestamp(3)
)
RETURNS decimal(7,3)
AS
$$
    SELECT
        a."EV_REV_Confidence"
    FROM
        attributes."EV_REV_Event_Revenue_Meta" a
    WHERE
        a."EV_REV_ID" = _id
    AND
        a."EV_REV_Who" = _positor
    AND
        a."EV_REV_PositedAt" <= _positing
    ORDER BY
        a."EV_REV_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_REV_Event_Revenue instead of INSERT trigger on EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_REV_Event_Revenue"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp(3);
    _reliability decimal(7,3);
    _held decimal(7,3);
    _posit bigint;
    _other bigint;
    _following bigint;
    _total decimal(7,3);
BEGIN
    _positor := coalesce(NEW."EV_REV_Who", 0);
    _positing := coalesce(NEW."EV_REV_PositedAt", _now);
    _reliability := coalesce(NEW."EV_REV_Confidence", 1);
    -- the posit, if there is one
    SELECT
        p."EV_REV_ID"
    INTO
        _posit
    FROM
        attributes."EV_REV_Event_Revenue_Fact" p
    WHERE
        p."EV_REV_EV_ID" = NEW."EV_REV_EV_ID"
    AND
        attributes."eq_EV_REV_Event_Revenue"(p."EV_REV_Event_Revenue", NEW."EV_REV_Event_Revenue")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_REV_Event_Revenue_Meta" a
        WHERE
            a."EV_REV_ID" = _posit
        AND
            a."EV_REV_Who" = _positor
        AND
            a."EV_REV_PositedAt" = _positing
        AND
            a."EV_REV_Confidence" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_REV_Event_Revenue for: %', concat_ws(', ', NEW."EV_REV_EV_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0.25 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_REV_Event_Revenue_Fact" p
        JOIN
            attributes."EV_REV_Event_Revenue_Meta" a
        ON
            a."EV_REV_ID" = p."EV_REV_ID"
        WHERE
            p."EV_REV_EV_ID" = NEW."EV_REV_EV_ID"
        AND
            NOT attributes."eq_EV_REV_Event_Revenue"(p."EV_REV_Event_Revenue", NEW."EV_REV_Event_Revenue")
        AND
            a."EV_REV_Who" = _positor
        AND
            a."EV_REV_PositedAt" = _positing
        AND
            a."EV_REV_Confidence" <> 0.25
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_REV_Event_Revenue for: %', concat_ws(', ', NEW."EV_REV_EV_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_REV_Event_Revenue_Meta" a
        WHERE
            a."EV_REV_ID" = _posit
        AND
            a."EV_REV_Who" = _positor
        AND
            a."EV_REV_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_EV_REV_Event_Revenue"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0.25) = 0.25 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_REV_Event_Revenue_Meta" (
            "Metadata_EV_REV",
            "EV_REV_ID",
            "EV_REV_Who",
            "EV_REV_PositedAt",
            "EV_REV_Confidence"
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
            attributes."EV_REV_Event_Revenue_Fact" p
        WHERE
            p."EV_REV_EV_ID" = NEW."EV_REV_EV_ID"
        AND
            NOT attributes."eq_EV_REV_Event_Revenue"(p."EV_REV_Event_Revenue", NEW."EV_REV_Event_Revenue")
        AND
            coalesce(attributes."he_EV_REV_Event_Revenue"(p."EV_REV_ID", _positor, _positing), 0.25) <> 0.25
    LOOP
        INSERT INTO attributes."EV_REV_Event_Revenue_Meta" (
            "Metadata_EV_REV",
            "EV_REV_ID",
            "EV_REV_Who",
            "EV_REV_PositedAt",
            "EV_REV_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_REV", 0),
            _other,
            _positor,
            _positing,
            0.25
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_REV_Event_Revenue_Fact" (
            "EV_REV_EV_ID",
            "EV_REV_Event_Revenue"
        )
        VALUES (
            NEW."EV_REV_EV_ID",
            NEW."EV_REV_Event_Revenue"
        )
        RETURNING "EV_REV_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_REV_Event_Revenue_Meta" (
        "Metadata_EV_REV",
        "EV_REV_ID",
        "EV_REV_Who",
        "EV_REV_PositedAt",
        "EV_REV_Confidence"
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
DROP TRIGGER IF EXISTS "it_EV_REV_Event_Revenue" ON attributes."EV_REV_Event_Revenue";
CREATE TRIGGER "it_EV_REV_Event_Revenue"
INSTEAD OF INSERT ON attributes."EV_REV_Event_Revenue"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_REV_Event_Revenue"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_STA_Event_Status tells whether two values of EV_STA_Event_Status are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_STA_Event_Status"(
    l varchar(20),
    r varchar(20)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_STA_Event_Status is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_EV_STA_Event_Status"(
    _id bigint,
    _positor smallint,
    _positing timestamp(3)
)
RETURNS decimal(7,3)
AS
$$
    SELECT
        a."EV_STA_Confidence"
    FROM
        attributes."EV_STA_Event_Status_Meta" a
    WHERE
        a."EV_STA_ID" = _id
    AND
        a."EV_STA_Who" = _positor
    AND
        a."EV_STA_PositedAt" <= _positing
    ORDER BY
        a."EV_STA_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_STA_Event_Status instead of INSERT trigger on EV_STA_Event_Status
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_STA_Event_Status"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp(3);
    _reliability decimal(7,3);
    _held decimal(7,3);
    _changing timestamp;
    _posit bigint;
    _other bigint;
    _following bigint;
    _total decimal(7,3);
BEGIN
    _positor := coalesce(NEW."EV_STA_Who", 0);
    _positing := coalesce(NEW."EV_STA_PositedAt", _now);
    _reliability := coalesce(NEW."EV_STA_Confidence", 1);
    _changing := coalesce(NEW."EV_STA_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."EV_STA_ID"
    INTO
        _posit
    FROM
        attributes."EV_STA_Event_Status_Fact" p
    WHERE
        p."EV_STA_EV_ID" = NEW."EV_STA_EV_ID"
    AND
        p."EV_STA_ChangedAt" = _changing
    AND
        attributes."eq_EV_STA_Event_Status"(p."EV_STA_Event_Status", NEW."EV_STA_Event_Status")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_STA_Event_Status_Meta" a
        WHERE
            a."EV_STA_ID" = _posit
        AND
            a."EV_STA_Who" = _positor
        AND
            a."EV_STA_PositedAt" = _positing
        AND
            a."EV_STA_Confidence" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_STA_Event_Status for: %', concat_ws(', ', NEW."EV_STA_EV_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0.25 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_STA_Event_Status_Fact" p
        JOIN
            attributes."EV_STA_Event_Status_Meta" a
        ON
            a."EV_STA_ID" = p."EV_STA_ID"
        WHERE
            p."EV_STA_EV_ID" = NEW."EV_STA_EV_ID"
        AND
            p."EV_STA_ChangedAt" = _changing
        AND
            NOT attributes."eq_EV_STA_Event_Status"(p."EV_STA_Event_Status", NEW."EV_STA_Event_Status")
        AND
            a."EV_STA_Who" = _positor
        AND
            a."EV_STA_PositedAt" = _positing
        AND
            a."EV_STA_Confidence" <> 0.25
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_STA_Event_Status for: %', concat_ws(', ', NEW."EV_STA_EV_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_STA_Event_Status_Meta" a
        WHERE
            a."EV_STA_ID" = _posit
        AND
            a."EV_STA_Who" = _positor
        AND
            a."EV_STA_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_EV_STA_Event_Status"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0.25) = 0.25 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_STA_Event_Status_Meta" (
            "Metadata_EV_STA",
            "EV_STA_ID",
            "EV_STA_Who",
            "EV_STA_PositedAt",
            "EV_STA_Confidence"
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
            attributes."EV_STA_Event_Status_Fact" p
        WHERE
            p."EV_STA_EV_ID" = NEW."EV_STA_EV_ID"
        AND
            p."EV_STA_ChangedAt" = _changing
        AND
            NOT attributes."eq_EV_STA_Event_Status"(p."EV_STA_Event_Status", NEW."EV_STA_Event_Status")
        AND
            coalesce(attributes."he_EV_STA_Event_Status"(p."EV_STA_ID", _positor, _positing), 0.25) <> 0.25
    LOOP
        INSERT INTO attributes."EV_STA_Event_Status_Meta" (
            "Metadata_EV_STA",
            "EV_STA_ID",
            "EV_STA_Who",
            "EV_STA_PositedAt",
            "EV_STA_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_STA", 0),
            _other,
            _positor,
            _positing,
            0.25
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_STA_Event_Status_Fact" (
            "EV_STA_EV_ID",
            "EV_STA_ChangedAt",
            "EV_STA_Event_Status"
        )
        VALUES (
            NEW."EV_STA_EV_ID",
            _changing,
            NEW."EV_STA_Event_Status"
        )
        RETURNING "EV_STA_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_STA_Event_Status_Meta" (
        "Metadata_EV_STA",
        "EV_STA_ID",
        "EV_STA_Who",
        "EV_STA_PositedAt",
        "EV_STA_Confidence"
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
DROP TRIGGER IF EXISTS "it_EV_STA_Event_Status" ON attributes."EV_STA_Event_Status";
CREATE TRIGGER "it_EV_STA_Event_Status"
INSTEAD OF INSERT ON attributes."EV_STA_Event_Status"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_STA_Event_Status"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_UTL_Event_Utilization tells whether two values of EV_UTL_Event_Utilization are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_UTL_Event_Utilization"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_UTL_Event_Utilization is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_EV_UTL_Event_Utilization"(
    _id bigint,
    _positor smallint,
    _positing timestamp(3)
)
RETURNS decimal(7,3)
AS
$$
    SELECT
        a."EV_UTL_Confidence"
    FROM
        attributes."EV_UTL_Event_Utilization_Meta" a
    WHERE
        a."EV_UTL_ID" = _id
    AND
        a."EV_UTL_Who" = _positor
    AND
        a."EV_UTL_PositedAt" <= _positing
    ORDER BY
        a."EV_UTL_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_UTL_Event_Utilization instead of INSERT trigger on EV_UTL_Event_Utilization
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_UTL_Event_Utilization"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp(3);
    _reliability decimal(7,3);
    _held decimal(7,3);
    _posit bigint;
    _other bigint;
    _following bigint;
    _total decimal(7,3);
BEGIN
    _positor := coalesce(NEW."EV_UTL_Who", 0);
    _positing := coalesce(NEW."EV_UTL_PositedAt", _now);
    _reliability := coalesce(NEW."EV_UTL_Confidence", 1);
    -- the posit, if there is one
    SELECT
        p."EV_UTL_ID"
    INTO
        _posit
    FROM
        attributes."EV_UTL_Event_Utilization_Fact" p
    WHERE
        p."EV_UTL_EV_ID" = NEW."EV_UTL_EV_ID"
    AND
        attributes."eq_EV_UTL_Event_Utilization"(p."EV_UTL_UTL_ID", NEW."EV_UTL_UTL_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_UTL_Event_Utilization_Meta" a
        WHERE
            a."EV_UTL_ID" = _posit
        AND
            a."EV_UTL_Who" = _positor
        AND
            a."EV_UTL_PositedAt" = _positing
        AND
            a."EV_UTL_Confidence" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_UTL_Event_Utilization for: %', concat_ws(', ', NEW."EV_UTL_EV_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0.25 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_UTL_Event_Utilization_Fact" p
        JOIN
            attributes."EV_UTL_Event_Utilization_Meta" a
        ON
            a."EV_UTL_ID" = p."EV_UTL_ID"
        WHERE
            p."EV_UTL_EV_ID" = NEW."EV_UTL_EV_ID"
        AND
            NOT attributes."eq_EV_UTL_Event_Utilization"(p."EV_UTL_UTL_ID", NEW."EV_UTL_UTL_ID")
        AND
            a."EV_UTL_Who" = _positor
        AND
            a."EV_UTL_PositedAt" = _positing
        AND
            a."EV_UTL_Confidence" <> 0.25
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_UTL_Event_Utilization for: %', concat_ws(', ', NEW."EV_UTL_EV_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_UTL_Event_Utilization_Meta" a
        WHERE
            a."EV_UTL_ID" = _posit
        AND
            a."EV_UTL_Who" = _positor
        AND
            a."EV_UTL_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_EV_UTL_Event_Utilization"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0.25) = 0.25 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_UTL_Event_Utilization_Meta" (
            "Metadata_EV_UTL",
            "EV_UTL_ID",
            "EV_UTL_Who",
            "EV_UTL_PositedAt",
            "EV_UTL_Confidence"
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
            attributes."EV_UTL_Event_Utilization_Fact" p
        WHERE
            p."EV_UTL_EV_ID" = NEW."EV_UTL_EV_ID"
        AND
            NOT attributes."eq_EV_UTL_Event_Utilization"(p."EV_UTL_UTL_ID", NEW."EV_UTL_UTL_ID")
        AND
            coalesce(attributes."he_EV_UTL_Event_Utilization"(p."EV_UTL_ID", _positor, _positing), 0.25) <> 0.25
    LOOP
        INSERT INTO attributes."EV_UTL_Event_Utilization_Meta" (
            "Metadata_EV_UTL",
            "EV_UTL_ID",
            "EV_UTL_Who",
            "EV_UTL_PositedAt",
            "EV_UTL_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_UTL", 0),
            _other,
            _positor,
            _positing,
            0.25
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_UTL_Event_Utilization_Fact" (
            "EV_UTL_EV_ID",
            "EV_UTL_UTL_ID"
        )
        VALUES (
            NEW."EV_UTL_EV_ID",
            NEW."EV_UTL_UTL_ID"
        )
        RETURNING "EV_UTL_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_UTL_Event_Utilization_Meta" (
        "Metadata_EV_UTL",
        "EV_UTL_ID",
        "EV_UTL_Who",
        "EV_UTL_PositedAt",
        "EV_UTL_Confidence"
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
DROP TRIGGER IF EXISTS "it_EV_UTL_Event_Utilization" ON attributes."EV_UTL_Event_Utilization";
CREATE TRIGGER "it_EV_UTL_Event_Utilization"
INSTEAD OF INSERT ON attributes."EV_UTL_Event_Utilization"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_UTL_Event_Utilization"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_LVL_Event_Level tells whether two values of EV_LVL_Event_Level are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_LVL_Event_Level"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_LVL_Event_Level is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."he_EV_LVL_Event_Level"(
    _id bigint,
    _positor smallint,
    _positing timestamp(3)
)
RETURNS decimal(7,3)
AS
$$
    SELECT
        a."EV_LVL_Confidence"
    FROM
        attributes."EV_LVL_Event_Level_Meta" a
    WHERE
        a."EV_LVL_ID" = _id
    AND
        a."EV_LVL_Who" = _positor
    AND
        a."EV_LVL_PositedAt" <= _positing
    ORDER BY
        a."EV_LVL_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_LVL_Event_Level instead of INSERT trigger on EV_LVL_Event_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_LVL_Event_Level"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp(3);
    _reliability decimal(7,3);
    _held decimal(7,3);
    _changing date;
    _posit bigint;
    _other bigint;
    _following bigint;
    _total decimal(7,3);
BEGIN
    _positor := coalesce(NEW."EV_LVL_Who", 0);
    _positing := coalesce(NEW."EV_LVL_PositedAt", _now);
    _reliability := coalesce(NEW."EV_LVL_Confidence", 1);
    _changing := coalesce(NEW."EV_LVL_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."EV_LVL_ID"
    INTO
        _posit
    FROM
        attributes."EV_LVL_Event_Level_Fact" p
    WHERE
        p."EV_LVL_EV_ID" = NEW."EV_LVL_EV_ID"
    AND
        p."EV_LVL_ChangedAt" = _changing
    AND
        attributes."eq_EV_LVL_Event_Level"(p."EV_LVL_PLV_ID", NEW."EV_LVL_PLV_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_LVL_Event_Level_Meta" a
        WHERE
            a."EV_LVL_ID" = _posit
        AND
            a."EV_LVL_Who" = _positor
        AND
            a."EV_LVL_PositedAt" = _positing
        AND
            a."EV_LVL_Confidence" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_LVL_Event_Level for: %', concat_ws(', ', NEW."EV_LVL_EV_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0.25 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_LVL_Event_Level_Fact" p
        JOIN
            attributes."EV_LVL_Event_Level_Meta" a
        ON
            a."EV_LVL_ID" = p."EV_LVL_ID"
        WHERE
            p."EV_LVL_EV_ID" = NEW."EV_LVL_EV_ID"
        AND
            p."EV_LVL_ChangedAt" = _changing
        AND
            NOT attributes."eq_EV_LVL_Event_Level"(p."EV_LVL_PLV_ID", NEW."EV_LVL_PLV_ID")
        AND
            a."EV_LVL_Who" = _positor
        AND
            a."EV_LVL_PositedAt" = _positing
        AND
            a."EV_LVL_Confidence" <> 0.25
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_LVL_Event_Level for: %', concat_ws(', ', NEW."EV_LVL_EV_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_LVL_Event_Level_Meta" a
        WHERE
            a."EV_LVL_ID" = _posit
        AND
            a."EV_LVL_Who" = _positor
        AND
            a."EV_LVL_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_EV_LVL_Event_Level"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0.25) = 0.25 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_LVL_Event_Level_Meta" (
            "Metadata_EV_LVL",
            "EV_LVL_ID",
            "EV_LVL_Who",
            "EV_LVL_PositedAt",
            "EV_LVL_Confidence"
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
            attributes."EV_LVL_Event_Level_Fact" p
        WHERE
            p."EV_LVL_EV_ID" = NEW."EV_LVL_EV_ID"
        AND
            p."EV_LVL_ChangedAt" = _changing
        AND
            NOT attributes."eq_EV_LVL_Event_Level"(p."EV_LVL_PLV_ID", NEW."EV_LVL_PLV_ID")
        AND
            coalesce(attributes."he_EV_LVL_Event_Level"(p."EV_LVL_ID", _positor, _positing), 0.25) <> 0.25
    LOOP
        INSERT INTO attributes."EV_LVL_Event_Level_Meta" (
            "Metadata_EV_LVL",
            "EV_LVL_ID",
            "EV_LVL_Who",
            "EV_LVL_PositedAt",
            "EV_LVL_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_LVL", 0),
            _other,
            _positor,
            _positing,
            0.25
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_LVL_Event_Level_Fact" (
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
    INSERT INTO attributes."EV_LVL_Event_Level_Meta" (
        "Metadata_EV_LVL",
        "EV_LVL_ID",
        "EV_LVL_Who",
        "EV_LVL_PositedAt",
        "EV_LVL_Confidence"
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
DROP TRIGGER IF EXISTS "it_EV_LVL_Event_Level" ON attributes."EV_LVL_Event_Level";
CREATE TRIGGER "it_EV_LVL_Event_Level"
INSTEAD OF INSERT ON attributes."EV_LVL_Event_Level"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_LVL_Event_Level"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_NAM_Stage_Name tells whether two values of ST_NAM_Stage_Name are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_ST_NAM_Stage_Name"(
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
CREATE OR REPLACE FUNCTION attributes."he_ST_NAM_Stage_Name"(
    _id bigint,
    _positor smallint,
    _positing timestamp(3)
)
RETURNS decimal(7,3)
AS
$$
    SELECT
        a."ST_NAM_Confidence"
    FROM
        attributes."ST_NAM_Stage_Name_Meta" a
    WHERE
        a."ST_NAM_ID" = _id
    AND
        a."ST_NAM_Who" = _positor
    AND
        a."ST_NAM_PositedAt" <= _positing
    ORDER BY
        a."ST_NAM_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_NAM_Stage_Name instead of INSERT trigger on ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_NAM_Stage_Name"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp(3);
    _reliability decimal(7,3);
    _held decimal(7,3);
    _changing timestamp;
    _posit bigint;
    _other bigint;
    _following bigint;
    _total decimal(7,3);
BEGIN
    _positor := coalesce(NEW."ST_NAM_Who", 0);
    _positing := coalesce(NEW."ST_NAM_PositedAt", _now);
    _reliability := coalesce(NEW."ST_NAM_Confidence", 1);
    _changing := coalesce(NEW."ST_NAM_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."ST_NAM_ID"
    INTO
        _posit
    FROM
        attributes."ST_NAM_Stage_Name_Fact" p
    WHERE
        p."ST_NAM_ST_ID" = NEW."ST_NAM_ST_ID"
    AND
        p."ST_NAM_ChangedAt" = _changing
    AND
        attributes."eq_ST_NAM_Stage_Name"(p."ST_NAM_Stage_Name", NEW."ST_NAM_Stage_Name")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_NAM_Stage_Name_Meta" a
        WHERE
            a."ST_NAM_ID" = _posit
        AND
            a."ST_NAM_Who" = _positor
        AND
            a."ST_NAM_PositedAt" = _positing
        AND
            a."ST_NAM_Confidence" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_NAM_Stage_Name for: %', concat_ws(', ', NEW."ST_NAM_ST_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0.25 AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_NAM_Stage_Name_Fact" p
        JOIN
            attributes."ST_NAM_Stage_Name_Meta" a
        ON
            a."ST_NAM_ID" = p."ST_NAM_ID"
        WHERE
            p."ST_NAM_ST_ID" = NEW."ST_NAM_ST_ID"
        AND
            p."ST_NAM_ChangedAt" = _changing
        AND
            NOT attributes."eq_ST_NAM_Stage_Name"(p."ST_NAM_Stage_Name", NEW."ST_NAM_Stage_Name")
        AND
            a."ST_NAM_Who" = _positor
        AND
            a."ST_NAM_PositedAt" = _positing
        AND
            a."ST_NAM_Confidence" <> 0.25
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_NAM_Stage_Name for: %', concat_ws(', ', NEW."ST_NAM_ST_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_NAM_Stage_Name_Meta" a
        WHERE
            a."ST_NAM_ID" = _posit
        AND
            a."ST_NAM_Who" = _positor
        AND
            a."ST_NAM_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_ST_NAM_Stage_Name"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0.25) = 0.25 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."ST_NAM_Stage_Name_Meta" (
            "Metadata_ST_NAM",
            "ST_NAM_ID",
            "ST_NAM_Who",
            "ST_NAM_PositedAt",
            "ST_NAM_Confidence"
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
            attributes."ST_NAM_Stage_Name_Fact" p
        WHERE
            p."ST_NAM_ST_ID" = NEW."ST_NAM_ST_ID"
        AND
            p."ST_NAM_ChangedAt" = _changing
        AND
            NOT attributes."eq_ST_NAM_Stage_Name"(p."ST_NAM_Stage_Name", NEW."ST_NAM_Stage_Name")
        AND
            coalesce(attributes."he_ST_NAM_Stage_Name"(p."ST_NAM_ID", _positor, _positing), 0.25) <> 0.25
    LOOP
        INSERT INTO attributes."ST_NAM_Stage_Name_Meta" (
            "Metadata_ST_NAM",
            "ST_NAM_ID",
            "ST_NAM_Who",
            "ST_NAM_PositedAt",
            "ST_NAM_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_NAM", 0),
            _other,
            _positor,
            _positing,
            0.25
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."ST_NAM_Stage_Name_Fact" (
            "ST_NAM_ST_ID",
            "ST_NAM_ChangedAt",
            "ST_NAM_Stage_Name"
        )
        VALUES (
            NEW."ST_NAM_ST_ID",
            _changing,
            NEW."ST_NAM_Stage_Name"
        )
        RETURNING "ST_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."ST_NAM_Stage_Name_Meta" (
        "Metadata_ST_NAM",
        "ST_NAM_ID",
        "ST_NAM_Who",
        "ST_NAM_PositedAt",
        "ST_NAM_Confidence"
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
DROP TRIGGER IF EXISTS "it_ST_NAM_Stage_Name" ON attributes."ST_NAM_Stage_Name";
CREATE TRIGGER "it_ST_NAM_Stage_Name"
INSTEAD OF INSERT ON attributes."ST_NAM_Stage_Name"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_NAM_Stage_Name"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_LOC_Stage_Location tells whether two values of ST_LOC_Stage_Location are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_ST_LOC_Stage_Location"(
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
CREATE OR REPLACE FUNCTION attributes."he_ST_LOC_Stage_Location"(
    _id bigint,
    _positor smallint,
    _positing timestamp(3)
)
RETURNS decimal(7,3)
AS
$$
    SELECT
        a."ST_LOC_Confidence"
    FROM
        attributes."ST_LOC_Stage_Location_Meta" a
    WHERE
        a."ST_LOC_ID" = _id
    AND
        a."ST_LOC_Who" = _positor
    AND
        a."ST_LOC_PositedAt" <= _positing
    ORDER BY
        a."ST_LOC_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_LOC_Stage_Location instead of INSERT trigger on ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_LOC_Stage_Location"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp(3);
    _reliability decimal(7,3);
    _held decimal(7,3);
    _posit bigint;
    _other bigint;
    _following bigint;
    _total decimal(7,3);
BEGIN
    _positor := coalesce(NEW."ST_LOC_Who", 0);
    _positing := coalesce(NEW."ST_LOC_PositedAt", _now);
    _reliability := coalesce(NEW."ST_LOC_Confidence", 1);
    -- the posit, if there is one
    SELECT
        p."ST_LOC_ID"
    INTO
        _posit
    FROM
        attributes."ST_LOC_Stage_Location_Fact" p
    WHERE
        p."ST_LOC_ST_ID" = NEW."ST_LOC_ST_ID"
    AND
        attributes."eq_ST_LOC_Stage_Location"(p."ST_LOC_Stage_Location", NEW."ST_LOC_Stage_Location")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_LOC_Stage_Location_Meta" a
        WHERE
            a."ST_LOC_ID" = _posit
        AND
            a."ST_LOC_Who" = _positor
        AND
            a."ST_LOC_PositedAt" = _positing
        AND
            a."ST_LOC_Confidence" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_LOC_Stage_Location for: %', concat_ws(', ', NEW."ST_LOC_ST_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0.25 AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_LOC_Stage_Location_Fact" p
        JOIN
            attributes."ST_LOC_Stage_Location_Meta" a
        ON
            a."ST_LOC_ID" = p."ST_LOC_ID"
        WHERE
            p."ST_LOC_ST_ID" = NEW."ST_LOC_ST_ID"
        AND
            NOT attributes."eq_ST_LOC_Stage_Location"(p."ST_LOC_Stage_Location", NEW."ST_LOC_Stage_Location")
        AND
            a."ST_LOC_Who" = _positor
        AND
            a."ST_LOC_PositedAt" = _positing
        AND
            a."ST_LOC_Confidence" <> 0.25
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_LOC_Stage_Location for: %', concat_ws(', ', NEW."ST_LOC_ST_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_LOC_Stage_Location_Meta" a
        WHERE
            a."ST_LOC_ID" = _posit
        AND
            a."ST_LOC_Who" = _positor
        AND
            a."ST_LOC_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_ST_LOC_Stage_Location"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0.25) = 0.25 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."ST_LOC_Stage_Location_Meta" (
            "Metadata_ST_LOC",
            "ST_LOC_ID",
            "ST_LOC_Who",
            "ST_LOC_PositedAt",
            "ST_LOC_Confidence"
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
            attributes."ST_LOC_Stage_Location_Fact" p
        WHERE
            p."ST_LOC_ST_ID" = NEW."ST_LOC_ST_ID"
        AND
            NOT attributes."eq_ST_LOC_Stage_Location"(p."ST_LOC_Stage_Location", NEW."ST_LOC_Stage_Location")
        AND
            coalesce(attributes."he_ST_LOC_Stage_Location"(p."ST_LOC_ID", _positor, _positing), 0.25) <> 0.25
    LOOP
        INSERT INTO attributes."ST_LOC_Stage_Location_Meta" (
            "Metadata_ST_LOC",
            "ST_LOC_ID",
            "ST_LOC_Who",
            "ST_LOC_PositedAt",
            "ST_LOC_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_LOC", 0),
            _other,
            _positor,
            _positing,
            0.25
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."ST_LOC_Stage_Location_Fact" (
            "ST_LOC_ST_ID",
            "ST_LOC_Stage_Location"
        )
        VALUES (
            NEW."ST_LOC_ST_ID",
            NEW."ST_LOC_Stage_Location"
        )
        RETURNING "ST_LOC_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."ST_LOC_Stage_Location_Meta" (
        "Metadata_ST_LOC",
        "ST_LOC_ID",
        "ST_LOC_Who",
        "ST_LOC_PositedAt",
        "ST_LOC_Confidence"
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
DROP TRIGGER IF EXISTS "it_ST_LOC_Stage_Location" ON attributes."ST_LOC_Stage_Location";
CREATE TRIGGER "it_ST_LOC_Stage_Location"
INSTEAD OF INSERT ON attributes."ST_LOC_Stage_Location"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_LOC_Stage_Location"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_AVG_Stage_Average tells whether two values of ST_AVG_Stage_Average are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_ST_AVG_Stage_Average"(
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
CREATE OR REPLACE FUNCTION attributes."he_ST_AVG_Stage_Average"(
    _id bigint,
    _positor smallint,
    _positing timestamp(3)
)
RETURNS decimal(7,3)
AS
$$
    SELECT
        a."ST_AVG_Confidence"
    FROM
        attributes."ST_AVG_Stage_Average_Meta" a
    WHERE
        a."ST_AVG_ID" = _id
    AND
        a."ST_AVG_Who" = _positor
    AND
        a."ST_AVG_PositedAt" <= _positing
    ORDER BY
        a."ST_AVG_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_AVG_Stage_Average instead of INSERT trigger on ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_AVG_Stage_Average"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp(3);
    _reliability decimal(7,3);
    _held decimal(7,3);
    _changing timestamp;
    _posit bigint;
    _other bigint;
    _following bigint;
    _total decimal(7,3);
BEGIN
    _positor := coalesce(NEW."ST_AVG_Who", 0);
    _positing := coalesce(NEW."ST_AVG_PositedAt", _now);
    _reliability := coalesce(NEW."ST_AVG_Confidence", 1);
    _changing := coalesce(NEW."ST_AVG_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."ST_AVG_ID"
    INTO
        _posit
    FROM
        attributes."ST_AVG_Stage_Average_Fact" p
    WHERE
        p."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
    AND
        p."ST_AVG_ChangedAt" = _changing
    AND
        attributes."eq_ST_AVG_Stage_Average"(p."ST_AVG_UTL_ID", NEW."ST_AVG_UTL_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_AVG_Stage_Average_Meta" a
        WHERE
            a."ST_AVG_ID" = _posit
        AND
            a."ST_AVG_Who" = _positor
        AND
            a."ST_AVG_PositedAt" = _positing
        AND
            a."ST_AVG_Confidence" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_AVG_Stage_Average for: %', concat_ws(', ', NEW."ST_AVG_ST_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0.25 AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_AVG_Stage_Average_Fact" p
        JOIN
            attributes."ST_AVG_Stage_Average_Meta" a
        ON
            a."ST_AVG_ID" = p."ST_AVG_ID"
        WHERE
            p."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
        AND
            p."ST_AVG_ChangedAt" = _changing
        AND
            NOT attributes."eq_ST_AVG_Stage_Average"(p."ST_AVG_UTL_ID", NEW."ST_AVG_UTL_ID")
        AND
            a."ST_AVG_Who" = _positor
        AND
            a."ST_AVG_PositedAt" = _positing
        AND
            a."ST_AVG_Confidence" <> 0.25
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_AVG_Stage_Average for: %', concat_ws(', ', NEW."ST_AVG_ST_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_AVG_Stage_Average_Meta" a
        WHERE
            a."ST_AVG_ID" = _posit
        AND
            a."ST_AVG_Who" = _positor
        AND
            a."ST_AVG_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_ST_AVG_Stage_Average"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0.25) = 0.25 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."ST_AVG_Stage_Average_Meta" (
            "Metadata_ST_AVG",
            "ST_AVG_ID",
            "ST_AVG_Who",
            "ST_AVG_PositedAt",
            "ST_AVG_Confidence"
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
            attributes."ST_AVG_Stage_Average_Fact" p
        WHERE
            p."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
        AND
            p."ST_AVG_ChangedAt" = _changing
        AND
            NOT attributes."eq_ST_AVG_Stage_Average"(p."ST_AVG_UTL_ID", NEW."ST_AVG_UTL_ID")
        AND
            coalesce(attributes."he_ST_AVG_Stage_Average"(p."ST_AVG_ID", _positor, _positing), 0.25) <> 0.25
    LOOP
        INSERT INTO attributes."ST_AVG_Stage_Average_Meta" (
            "Metadata_ST_AVG",
            "ST_AVG_ID",
            "ST_AVG_Who",
            "ST_AVG_PositedAt",
            "ST_AVG_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_AVG", 0),
            _other,
            _positor,
            _positing,
            0.25
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
                attributes."ST_AVG_Stage_Average_Fact" p
            WHERE
                p."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
            AND
                p."ST_AVG_ChangedAt" < _changing
            AND
                coalesce(attributes."he_ST_AVG_Stage_Average"(p."ST_AVG_ID", _positor, _positing), 0.25) <> 0.25
            AND
                (attributes."he_ST_AVG_Stage_Average"(p."ST_AVG_ID", _positor, _positing) > 0.25) = (_reliability > 0.25)
            ORDER BY
                p."ST_AVG_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            attributes."eq_ST_AVG_Stage_Average"(pre."ST_AVG_UTL_ID", NEW."ST_AVG_UTL_ID")
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
        attributes."ST_AVG_Stage_Average_Fact" f
    WHERE
        f."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
    AND
        f."ST_AVG_ChangedAt" > _changing
    AND
        coalesce(attributes."he_ST_AVG_Stage_Average"(f."ST_AVG_ID", _positor, _positing), 0.25) <> 0.25
    AND
        (attributes."he_ST_AVG_Stage_Average"(f."ST_AVG_ID", _positor, _positing) > 0.25) = (_reliability > 0.25)
    ORDER BY
        f."ST_AVG_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND attributes."eq_ST_AVG_Stage_Average"((
        SELECT x."ST_AVG_UTL_ID" FROM attributes."ST_AVG_Stage_Average_Fact" x WHERE x."ST_AVG_ID" = _following
    ), NEW."ST_AVG_UTL_ID") THEN
        -- (an idempotent attribute retracts it)
        INSERT INTO attributes."ST_AVG_Stage_Average_Meta" (
            "Metadata_ST_AVG",
            "ST_AVG_ID",
            "ST_AVG_Who",
            "ST_AVG_PositedAt",
            "ST_AVG_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_AVG", 0),
            _following,
            _positor,
            _positing,
            0.25
        )
        ON CONFLICT DO NOTHING;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."ST_AVG_Stage_Average_Fact" (
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
    INSERT INTO attributes."ST_AVG_Stage_Average_Meta" (
        "Metadata_ST_AVG",
        "ST_AVG_ID",
        "ST_AVG_Who",
        "ST_AVG_PositedAt",
        "ST_AVG_Confidence"
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
DROP TRIGGER IF EXISTS "it_ST_AVG_Stage_Average" ON attributes."ST_AVG_Stage_Average";
CREATE TRIGGER "it_ST_AVG_Stage_Average"
INSTEAD OF INSERT ON attributes."ST_AVG_Stage_Average"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_AVG_Stage_Average"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_MIN_Stage_Minimum tells whether two values of ST_MIN_Stage_Minimum are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_ST_MIN_Stage_Minimum"(
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
CREATE OR REPLACE FUNCTION attributes."he_ST_MIN_Stage_Minimum"(
    _id bigint,
    _positor smallint,
    _positing timestamp(3)
)
RETURNS decimal(7,3)
AS
$$
    SELECT
        a."ST_MIN_Confidence"
    FROM
        attributes."ST_MIN_Stage_Minimum_Meta" a
    WHERE
        a."ST_MIN_ID" = _id
    AND
        a."ST_MIN_Who" = _positor
    AND
        a."ST_MIN_PositedAt" <= _positing
    ORDER BY
        a."ST_MIN_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_MIN_Stage_Minimum instead of INSERT trigger on ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_MIN_Stage_Minimum"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp(3);
    _reliability decimal(7,3);
    _held decimal(7,3);
    _posit bigint;
    _other bigint;
    _following bigint;
    _total decimal(7,3);
BEGIN
    _positor := coalesce(NEW."ST_MIN_Who", 0);
    _positing := coalesce(NEW."ST_MIN_PositedAt", _now);
    _reliability := coalesce(NEW."ST_MIN_Confidence", 1);
    -- the posit, if there is one
    SELECT
        p."ST_MIN_ID"
    INTO
        _posit
    FROM
        attributes."ST_MIN_Stage_Minimum_Fact" p
    WHERE
        p."ST_MIN_ST_ID" = NEW."ST_MIN_ST_ID"
    AND
        attributes."eq_ST_MIN_Stage_Minimum"(p."ST_MIN_UTL_ID", NEW."ST_MIN_UTL_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_MIN_Stage_Minimum_Meta" a
        WHERE
            a."ST_MIN_ID" = _posit
        AND
            a."ST_MIN_Who" = _positor
        AND
            a."ST_MIN_PositedAt" = _positing
        AND
            a."ST_MIN_Confidence" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_MIN_Stage_Minimum for: %', concat_ws(', ', NEW."ST_MIN_ST_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0.25 AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_MIN_Stage_Minimum_Fact" p
        JOIN
            attributes."ST_MIN_Stage_Minimum_Meta" a
        ON
            a."ST_MIN_ID" = p."ST_MIN_ID"
        WHERE
            p."ST_MIN_ST_ID" = NEW."ST_MIN_ST_ID"
        AND
            NOT attributes."eq_ST_MIN_Stage_Minimum"(p."ST_MIN_UTL_ID", NEW."ST_MIN_UTL_ID")
        AND
            a."ST_MIN_Who" = _positor
        AND
            a."ST_MIN_PositedAt" = _positing
        AND
            a."ST_MIN_Confidence" <> 0.25
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_MIN_Stage_Minimum for: %', concat_ws(', ', NEW."ST_MIN_ST_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_MIN_Stage_Minimum_Meta" a
        WHERE
            a."ST_MIN_ID" = _posit
        AND
            a."ST_MIN_Who" = _positor
        AND
            a."ST_MIN_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_ST_MIN_Stage_Minimum"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0.25) = 0.25 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."ST_MIN_Stage_Minimum_Meta" (
            "Metadata_ST_MIN",
            "ST_MIN_ID",
            "ST_MIN_Who",
            "ST_MIN_PositedAt",
            "ST_MIN_Confidence"
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
            attributes."ST_MIN_Stage_Minimum_Fact" p
        WHERE
            p."ST_MIN_ST_ID" = NEW."ST_MIN_ST_ID"
        AND
            NOT attributes."eq_ST_MIN_Stage_Minimum"(p."ST_MIN_UTL_ID", NEW."ST_MIN_UTL_ID")
        AND
            coalesce(attributes."he_ST_MIN_Stage_Minimum"(p."ST_MIN_ID", _positor, _positing), 0.25) <> 0.25
    LOOP
        INSERT INTO attributes."ST_MIN_Stage_Minimum_Meta" (
            "Metadata_ST_MIN",
            "ST_MIN_ID",
            "ST_MIN_Who",
            "ST_MIN_PositedAt",
            "ST_MIN_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_MIN", 0),
            _other,
            _positor,
            _positing,
            0.25
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."ST_MIN_Stage_Minimum_Fact" (
            "ST_MIN_ST_ID",
            "ST_MIN_UTL_ID"
        )
        VALUES (
            NEW."ST_MIN_ST_ID",
            NEW."ST_MIN_UTL_ID"
        )
        RETURNING "ST_MIN_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."ST_MIN_Stage_Minimum_Meta" (
        "Metadata_ST_MIN",
        "ST_MIN_ID",
        "ST_MIN_Who",
        "ST_MIN_PositedAt",
        "ST_MIN_Confidence"
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
DROP TRIGGER IF EXISTS "it_ST_MIN_Stage_Minimum" ON attributes."ST_MIN_Stage_Minimum";
CREATE TRIGGER "it_ST_MIN_Stage_Minimum"
INSTEAD OF INSERT ON attributes."ST_MIN_Stage_Minimum"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_MIN_Stage_Minimum"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_NAM_Actor_Name tells whether two values of AC_NAM_Actor_Name are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_AC_NAM_Actor_Name"(
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
CREATE OR REPLACE FUNCTION attributes."he_AC_NAM_Actor_Name"(
    _id bigint,
    _positor smallint,
    _positing timestamp(3)
)
RETURNS decimal(7,3)
AS
$$
    SELECT
        a."AC_NAM_Confidence"
    FROM
        attributes."AC_NAM_Actor_Name_Meta" a
    WHERE
        a."AC_NAM_ID" = _id
    AND
        a."AC_NAM_Who" = _positor
    AND
        a."AC_NAM_PositedAt" <= _positing
    ORDER BY
        a."AC_NAM_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_NAM_Actor_Name instead of INSERT trigger on AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_AC_NAM_Actor_Name"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp(3);
    _reliability decimal(7,3);
    _held decimal(7,3);
    _changing timestamp;
    _posit bigint;
    _other bigint;
    _following bigint;
    _total decimal(7,3);
BEGIN
    _positor := coalesce(NEW."AC_NAM_Who", 0);
    _positing := coalesce(NEW."AC_NAM_PositedAt", _now);
    _reliability := coalesce(NEW."AC_NAM_Confidence", 1);
    _changing := coalesce(NEW."AC_NAM_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."AC_NAM_ID"
    INTO
        _posit
    FROM
        attributes."AC_NAM_Actor_Name_Fact" p
    WHERE
        p."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
    AND
        p."AC_NAM_ChangedAt" = _changing
    AND
        attributes."eq_AC_NAM_Actor_Name"(p."AC_NAM_Actor_Name", NEW."AC_NAM_Actor_Name")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_NAM_Actor_Name_Meta" a
        WHERE
            a."AC_NAM_ID" = _posit
        AND
            a."AC_NAM_Who" = _positor
        AND
            a."AC_NAM_PositedAt" = _positing
        AND
            a."AC_NAM_Confidence" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_NAM_Actor_Name for: %', concat_ws(', ', NEW."AC_NAM_AC_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0.25 AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_NAM_Actor_Name_Fact" p
        JOIN
            attributes."AC_NAM_Actor_Name_Meta" a
        ON
            a."AC_NAM_ID" = p."AC_NAM_ID"
        WHERE
            p."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
        AND
            p."AC_NAM_ChangedAt" = _changing
        AND
            NOT attributes."eq_AC_NAM_Actor_Name"(p."AC_NAM_Actor_Name", NEW."AC_NAM_Actor_Name")
        AND
            a."AC_NAM_Who" = _positor
        AND
            a."AC_NAM_PositedAt" = _positing
        AND
            a."AC_NAM_Confidence" <> 0.25
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_NAM_Actor_Name for: %', concat_ws(', ', NEW."AC_NAM_AC_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_NAM_Actor_Name_Meta" a
        WHERE
            a."AC_NAM_ID" = _posit
        AND
            a."AC_NAM_Who" = _positor
        AND
            a."AC_NAM_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_AC_NAM_Actor_Name"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0.25) = 0.25 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."AC_NAM_Actor_Name_Meta" (
            "Metadata_AC_NAM",
            "AC_NAM_ID",
            "AC_NAM_Who",
            "AC_NAM_PositedAt",
            "AC_NAM_Confidence"
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
            attributes."AC_NAM_Actor_Name_Fact" p
        WHERE
            p."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
        AND
            p."AC_NAM_ChangedAt" = _changing
        AND
            NOT attributes."eq_AC_NAM_Actor_Name"(p."AC_NAM_Actor_Name", NEW."AC_NAM_Actor_Name")
        AND
            coalesce(attributes."he_AC_NAM_Actor_Name"(p."AC_NAM_ID", _positor, _positing), 0.25) <> 0.25
    LOOP
        INSERT INTO attributes."AC_NAM_Actor_Name_Meta" (
            "Metadata_AC_NAM",
            "AC_NAM_ID",
            "AC_NAM_Who",
            "AC_NAM_PositedAt",
            "AC_NAM_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_NAM", 0),
            _other,
            _positor,
            _positing,
            0.25
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
                attributes."AC_NAM_Actor_Name_Fact" p
            WHERE
                p."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
            AND
                p."AC_NAM_ChangedAt" < _changing
            AND
                coalesce(attributes."he_AC_NAM_Actor_Name"(p."AC_NAM_ID", _positor, _positing), 0.25) <> 0.25
            AND
                (attributes."he_AC_NAM_Actor_Name"(p."AC_NAM_ID", _positor, _positing) > 0.25) = (_reliability > 0.25)
            ORDER BY
                p."AC_NAM_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            attributes."eq_AC_NAM_Actor_Name"(pre."AC_NAM_Actor_Name", NEW."AC_NAM_Actor_Name")
    ) THEN
        RAISE EXCEPTION 'Restatement in AC_NAM_Actor_Name for: %', concat_ws(', ', NEW."AC_NAM_AC_ID", _changing, _positor, _positing);
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."AC_NAM_ID"
    INTO
        _following
    FROM
        attributes."AC_NAM_Actor_Name_Fact" f
    WHERE
        f."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
    AND
        f."AC_NAM_ChangedAt" > _changing
    AND
        coalesce(attributes."he_AC_NAM_Actor_Name"(f."AC_NAM_ID", _positor, _positing), 0.25) <> 0.25
    AND
        (attributes."he_AC_NAM_Actor_Name"(f."AC_NAM_ID", _positor, _positing) > 0.25) = (_reliability > 0.25)
    ORDER BY
        f."AC_NAM_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND attributes."eq_AC_NAM_Actor_Name"((
        SELECT x."AC_NAM_Actor_Name" FROM attributes."AC_NAM_Actor_Name_Fact" x WHERE x."AC_NAM_ID" = _following
    ), NEW."AC_NAM_Actor_Name") THEN
        RAISE EXCEPTION 'Restatement in AC_NAM_Actor_Name for: %', concat_ws(', ', NEW."AC_NAM_AC_ID", _changing, _positor, _positing);
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."AC_NAM_Actor_Name_Fact" (
            "AC_NAM_AC_ID",
            "AC_NAM_ChangedAt",
            "AC_NAM_Actor_Name"
        )
        VALUES (
            NEW."AC_NAM_AC_ID",
            _changing,
            NEW."AC_NAM_Actor_Name"
        )
        RETURNING "AC_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."AC_NAM_Actor_Name_Meta" (
        "Metadata_AC_NAM",
        "AC_NAM_ID",
        "AC_NAM_Who",
        "AC_NAM_PositedAt",
        "AC_NAM_Confidence"
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
DROP TRIGGER IF EXISTS "it_AC_NAM_Actor_Name" ON attributes."AC_NAM_Actor_Name";
CREATE TRIGGER "it_AC_NAM_Actor_Name"
INSTEAD OF INSERT ON attributes."AC_NAM_Actor_Name"
FOR EACH ROW EXECUTE FUNCTION attributes."it_AC_NAM_Actor_Name"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_GEN_Actor_Gender tells whether two values of AC_GEN_Actor_Gender are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_AC_GEN_Actor_Gender"(
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
CREATE OR REPLACE FUNCTION attributes."he_AC_GEN_Actor_Gender"(
    _id bigint,
    _positor smallint,
    _positing timestamp(3)
)
RETURNS decimal(7,3)
AS
$$
    SELECT
        a."AC_GEN_Confidence"
    FROM
        attributes."AC_GEN_Actor_Gender_Meta" a
    WHERE
        a."AC_GEN_ID" = _id
    AND
        a."AC_GEN_Who" = _positor
    AND
        a."AC_GEN_PositedAt" <= _positing
    ORDER BY
        a."AC_GEN_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_GEN_Actor_Gender instead of INSERT trigger on AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_AC_GEN_Actor_Gender"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp(3);
    _reliability decimal(7,3);
    _held decimal(7,3);
    _posit bigint;
    _other bigint;
    _following bigint;
    _total decimal(7,3);
BEGIN
    _positor := coalesce(NEW."AC_GEN_Who", 0);
    _positing := coalesce(NEW."AC_GEN_PositedAt", _now);
    _reliability := coalesce(NEW."AC_GEN_Confidence", 1);
    -- the posit, if there is one
    SELECT
        p."AC_GEN_ID"
    INTO
        _posit
    FROM
        attributes."AC_GEN_Actor_Gender_Fact" p
    WHERE
        p."AC_GEN_AC_ID" = NEW."AC_GEN_AC_ID"
    AND
        attributes."eq_AC_GEN_Actor_Gender"(p."AC_GEN_GEN_ID", NEW."AC_GEN_GEN_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_GEN_Actor_Gender_Meta" a
        WHERE
            a."AC_GEN_ID" = _posit
        AND
            a."AC_GEN_Who" = _positor
        AND
            a."AC_GEN_PositedAt" = _positing
        AND
            a."AC_GEN_Confidence" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_GEN_Actor_Gender for: %', concat_ws(', ', NEW."AC_GEN_AC_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0.25 AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_GEN_Actor_Gender_Fact" p
        JOIN
            attributes."AC_GEN_Actor_Gender_Meta" a
        ON
            a."AC_GEN_ID" = p."AC_GEN_ID"
        WHERE
            p."AC_GEN_AC_ID" = NEW."AC_GEN_AC_ID"
        AND
            NOT attributes."eq_AC_GEN_Actor_Gender"(p."AC_GEN_GEN_ID", NEW."AC_GEN_GEN_ID")
        AND
            a."AC_GEN_Who" = _positor
        AND
            a."AC_GEN_PositedAt" = _positing
        AND
            a."AC_GEN_Confidence" <> 0.25
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_GEN_Actor_Gender for: %', concat_ws(', ', NEW."AC_GEN_AC_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_GEN_Actor_Gender_Meta" a
        WHERE
            a."AC_GEN_ID" = _posit
        AND
            a."AC_GEN_Who" = _positor
        AND
            a."AC_GEN_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_AC_GEN_Actor_Gender"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0.25) = 0.25 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."AC_GEN_Actor_Gender_Meta" (
            "Metadata_AC_GEN",
            "AC_GEN_ID",
            "AC_GEN_Who",
            "AC_GEN_PositedAt",
            "AC_GEN_Confidence"
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
            attributes."AC_GEN_Actor_Gender_Fact" p
        WHERE
            p."AC_GEN_AC_ID" = NEW."AC_GEN_AC_ID"
        AND
            NOT attributes."eq_AC_GEN_Actor_Gender"(p."AC_GEN_GEN_ID", NEW."AC_GEN_GEN_ID")
        AND
            coalesce(attributes."he_AC_GEN_Actor_Gender"(p."AC_GEN_ID", _positor, _positing), 0.25) <> 0.25
    LOOP
        INSERT INTO attributes."AC_GEN_Actor_Gender_Meta" (
            "Metadata_AC_GEN",
            "AC_GEN_ID",
            "AC_GEN_Who",
            "AC_GEN_PositedAt",
            "AC_GEN_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_GEN", 0),
            _other,
            _positor,
            _positing,
            0.25
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."AC_GEN_Actor_Gender_Fact" (
            "AC_GEN_AC_ID",
            "AC_GEN_GEN_ID"
        )
        VALUES (
            NEW."AC_GEN_AC_ID",
            NEW."AC_GEN_GEN_ID"
        )
        RETURNING "AC_GEN_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."AC_GEN_Actor_Gender_Meta" (
        "Metadata_AC_GEN",
        "AC_GEN_ID",
        "AC_GEN_Who",
        "AC_GEN_PositedAt",
        "AC_GEN_Confidence"
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
DROP TRIGGER IF EXISTS "it_AC_GEN_Actor_Gender" ON attributes."AC_GEN_Actor_Gender";
CREATE TRIGGER "it_AC_GEN_Actor_Gender"
INSTEAD OF INSERT ON attributes."AC_GEN_Actor_Gender"
FOR EACH ROW EXECUTE FUNCTION attributes."it_AC_GEN_Actor_Gender"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_PLV_Actor_ProfessionalLevel tells whether two values of AC_PLV_Actor_ProfessionalLevel are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_AC_PLV_Actor_ProfessionalLevel"(
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
CREATE OR REPLACE FUNCTION attributes."he_AC_PLV_Actor_ProfessionalLevel"(
    _id bigint,
    _positor smallint,
    _positing timestamp(3)
)
RETURNS decimal(7,3)
AS
$$
    SELECT
        a."AC_PLV_Confidence"
    FROM
        attributes."AC_PLV_Actor_ProfessionalLevel_Meta" a
    WHERE
        a."AC_PLV_ID" = _id
    AND
        a."AC_PLV_Who" = _positor
    AND
        a."AC_PLV_PositedAt" <= _positing
    ORDER BY
        a."AC_PLV_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_PLV_Actor_ProfessionalLevel instead of INSERT trigger on AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_AC_PLV_Actor_ProfessionalLevel"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp(3);
    _reliability decimal(7,3);
    _held decimal(7,3);
    _changing timestamp;
    _posit bigint;
    _other bigint;
    _following bigint;
    _total decimal(7,3);
BEGIN
    _positor := coalesce(NEW."AC_PLV_Who", 0);
    _positing := coalesce(NEW."AC_PLV_PositedAt", _now);
    _reliability := coalesce(NEW."AC_PLV_Confidence", 1);
    _changing := coalesce(NEW."AC_PLV_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."AC_PLV_ID"
    INTO
        _posit
    FROM
        attributes."AC_PLV_Actor_ProfessionalLevel_Fact" p
    WHERE
        p."AC_PLV_AC_ID" = NEW."AC_PLV_AC_ID"
    AND
        p."AC_PLV_ChangedAt" = _changing
    AND
        attributes."eq_AC_PLV_Actor_ProfessionalLevel"(p."AC_PLV_PLV_ID", NEW."AC_PLV_PLV_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_PLV_Actor_ProfessionalLevel_Meta" a
        WHERE
            a."AC_PLV_ID" = _posit
        AND
            a."AC_PLV_Who" = _positor
        AND
            a."AC_PLV_PositedAt" = _positing
        AND
            a."AC_PLV_Confidence" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: %', concat_ws(', ', NEW."AC_PLV_AC_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0.25 AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_PLV_Actor_ProfessionalLevel_Fact" p
        JOIN
            attributes."AC_PLV_Actor_ProfessionalLevel_Meta" a
        ON
            a."AC_PLV_ID" = p."AC_PLV_ID"
        WHERE
            p."AC_PLV_AC_ID" = NEW."AC_PLV_AC_ID"
        AND
            p."AC_PLV_ChangedAt" = _changing
        AND
            NOT attributes."eq_AC_PLV_Actor_ProfessionalLevel"(p."AC_PLV_PLV_ID", NEW."AC_PLV_PLV_ID")
        AND
            a."AC_PLV_Who" = _positor
        AND
            a."AC_PLV_PositedAt" = _positing
        AND
            a."AC_PLV_Confidence" <> 0.25
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: %', concat_ws(', ', NEW."AC_PLV_AC_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_PLV_Actor_ProfessionalLevel_Meta" a
        WHERE
            a."AC_PLV_ID" = _posit
        AND
            a."AC_PLV_Who" = _positor
        AND
            a."AC_PLV_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_AC_PLV_Actor_ProfessionalLevel"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0.25) = 0.25 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."AC_PLV_Actor_ProfessionalLevel_Meta" (
            "Metadata_AC_PLV",
            "AC_PLV_ID",
            "AC_PLV_Who",
            "AC_PLV_PositedAt",
            "AC_PLV_Confidence"
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
            attributes."AC_PLV_Actor_ProfessionalLevel_Fact" p
        WHERE
            p."AC_PLV_AC_ID" = NEW."AC_PLV_AC_ID"
        AND
            p."AC_PLV_ChangedAt" = _changing
        AND
            NOT attributes."eq_AC_PLV_Actor_ProfessionalLevel"(p."AC_PLV_PLV_ID", NEW."AC_PLV_PLV_ID")
        AND
            coalesce(attributes."he_AC_PLV_Actor_ProfessionalLevel"(p."AC_PLV_ID", _positor, _positing), 0.25) <> 0.25
    LOOP
        INSERT INTO attributes."AC_PLV_Actor_ProfessionalLevel_Meta" (
            "Metadata_AC_PLV",
            "AC_PLV_ID",
            "AC_PLV_Who",
            "AC_PLV_PositedAt",
            "AC_PLV_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_PLV", 0),
            _other,
            _positor,
            _positing,
            0.25
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."AC_PLV_Actor_ProfessionalLevel_Fact" (
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
    INSERT INTO attributes."AC_PLV_Actor_ProfessionalLevel_Meta" (
        "Metadata_AC_PLV",
        "AC_PLV_ID",
        "AC_PLV_Who",
        "AC_PLV_PositedAt",
        "AC_PLV_Confidence"
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
DROP TRIGGER IF EXISTS "it_AC_PLV_Actor_ProfessionalLevel" ON attributes."AC_PLV_Actor_ProfessionalLevel";
CREATE TRIGGER "it_AC_PLV_Actor_ProfessionalLevel"
INSTEAD OF INSERT ON attributes."AC_PLV_Actor_ProfessionalLevel"
FOR EACH ROW EXECUTE FUNCTION attributes."it_AC_PLV_Actor_ProfessionalLevel"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_NAM_Program_Name tells whether two values of PR_NAM_Program_Name are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_PR_NAM_Program_Name"(
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
CREATE OR REPLACE FUNCTION attributes."he_PR_NAM_Program_Name"(
    _id bigint,
    _positor smallint,
    _positing timestamp(3)
)
RETURNS decimal(7,3)
AS
$$
    SELECT
        a."PR_NAM_Confidence"
    FROM
        attributes."PR_NAM_Program_Name_Meta" a
    WHERE
        a."PR_NAM_ID" = _id
    AND
        a."PR_NAM_Who" = _positor
    AND
        a."PR_NAM_PositedAt" <= _positing
    ORDER BY
        a."PR_NAM_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_NAM_Program_Name instead of INSERT trigger on PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_PR_NAM_Program_Name"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp(3);
    _reliability decimal(7,3);
    _held decimal(7,3);
    _posit bigint;
    _other bigint;
    _following bigint;
    _total decimal(7,3);
BEGIN
    _positor := coalesce(NEW."PR_NAM_Who", 0);
    _positing := coalesce(NEW."PR_NAM_PositedAt", _now);
    _reliability := coalesce(NEW."PR_NAM_Confidence", 1);
    -- the posit, if there is one
    SELECT
        p."PR_NAM_ID"
    INTO
        _posit
    FROM
        attributes."PR_NAM_Program_Name_Fact" p
    WHERE
        p."PR_NAM_PR_ID" = NEW."PR_NAM_PR_ID"
    AND
        attributes."eq_PR_NAM_Program_Name"(p."PR_NAM_Program_Name", NEW."PR_NAM_Program_Name")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_NAM_Program_Name_Meta" a
        WHERE
            a."PR_NAM_ID" = _posit
        AND
            a."PR_NAM_Who" = _positor
        AND
            a."PR_NAM_PositedAt" = _positing
        AND
            a."PR_NAM_Confidence" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_NAM_Program_Name for: %', concat_ws(', ', NEW."PR_NAM_PR_ID",
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0.25 AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_NAM_Program_Name_Fact" p
        JOIN
            attributes."PR_NAM_Program_Name_Meta" a
        ON
            a."PR_NAM_ID" = p."PR_NAM_ID"
        WHERE
            p."PR_NAM_PR_ID" = NEW."PR_NAM_PR_ID"
        AND
            NOT attributes."eq_PR_NAM_Program_Name"(p."PR_NAM_Program_Name", NEW."PR_NAM_Program_Name")
        AND
            a."PR_NAM_Who" = _positor
        AND
            a."PR_NAM_PositedAt" = _positing
        AND
            a."PR_NAM_Confidence" <> 0.25
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_NAM_Program_Name for: %', concat_ws(', ', NEW."PR_NAM_PR_ID",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_NAM_Program_Name_Meta" a
        WHERE
            a."PR_NAM_ID" = _posit
        AND
            a."PR_NAM_Who" = _positor
        AND
            a."PR_NAM_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_PR_NAM_Program_Name"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0.25) = 0.25 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."PR_NAM_Program_Name_Meta" (
            "Metadata_PR_NAM",
            "PR_NAM_ID",
            "PR_NAM_Who",
            "PR_NAM_PositedAt",
            "PR_NAM_Confidence"
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
            attributes."PR_NAM_Program_Name_Fact" p
        WHERE
            p."PR_NAM_PR_ID" = NEW."PR_NAM_PR_ID"
        AND
            NOT attributes."eq_PR_NAM_Program_Name"(p."PR_NAM_Program_Name", NEW."PR_NAM_Program_Name")
        AND
            coalesce(attributes."he_PR_NAM_Program_Name"(p."PR_NAM_ID", _positor, _positing), 0.25) <> 0.25
    LOOP
        INSERT INTO attributes."PR_NAM_Program_Name_Meta" (
            "Metadata_PR_NAM",
            "PR_NAM_ID",
            "PR_NAM_Who",
            "PR_NAM_PositedAt",
            "PR_NAM_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_NAM", 0),
            _other,
            _positor,
            _positing,
            0.25
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."PR_NAM_Program_Name_Fact" (
            "PR_NAM_PR_ID",
            "PR_NAM_Program_Name"
        )
        VALUES (
            NEW."PR_NAM_PR_ID",
            NEW."PR_NAM_Program_Name"
        )
        RETURNING "PR_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."PR_NAM_Program_Name_Meta" (
        "Metadata_PR_NAM",
        "PR_NAM_ID",
        "PR_NAM_Who",
        "PR_NAM_PositedAt",
        "PR_NAM_Confidence"
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
DROP TRIGGER IF EXISTS "it_PR_NAM_Program_Name" ON attributes."PR_NAM_Program_Name";
CREATE TRIGGER "it_PR_NAM_Program_Name"
INSTEAD OF INSERT ON attributes."PR_NAM_Program_Name"
FOR EACH ROW EXECUTE FUNCTION attributes."it_PR_NAM_Program_Name"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_LEN_Program_Length tells whether two values of PR_LEN_Program_Length are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_PR_LEN_Program_Length"(
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
CREATE OR REPLACE FUNCTION attributes."he_PR_LEN_Program_Length"(
    _id bigint,
    _positor smallint,
    _positing timestamp(3)
)
RETURNS decimal(7,3)
AS
$$
    SELECT
        a."PR_LEN_Confidence"
    FROM
        attributes."PR_LEN_Program_Length_Meta" a
    WHERE
        a."PR_LEN_ID" = _id
    AND
        a."PR_LEN_Who" = _positor
    AND
        a."PR_LEN_PositedAt" <= _positing
    ORDER BY
        a."PR_LEN_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_LEN_Program_Length instead of INSERT trigger on PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_PR_LEN_Program_Length"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positor smallint;
    _positing timestamp(3);
    _reliability decimal(7,3);
    _held decimal(7,3);
    _changing date;
    _posit bigint;
    _other bigint;
    _following bigint;
    _total decimal(7,3);
BEGIN
    _positor := coalesce(NEW."PR_LEN_Who", 0);
    _positing := coalesce(NEW."PR_LEN_PositedAt", _now);
    _reliability := coalesce(NEW."PR_LEN_Confidence", 1);
    _changing := coalesce(NEW."PR_LEN_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."PR_LEN_ID"
    INTO
        _posit
    FROM
        attributes."PR_LEN_Program_Length_Fact" p
    WHERE
        p."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
    AND
        p."PR_LEN_ChangedAt" = _changing
    AND
        attributes."eq_PR_LEN_Program_Length"(p."PR_LEN_Program_Length", NEW."PR_LEN_Program_Length")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_LEN_Program_Length_Meta" a
        WHERE
            a."PR_LEN_ID" = _posit
        AND
            a."PR_LEN_Who" = _positor
        AND
            a."PR_LEN_PositedAt" = _positing
        AND
            a."PR_LEN_Confidence" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_LEN_Program_Length for: %', concat_ws(', ', NEW."PR_LEN_PR_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF _reliability <> 0.25 AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_LEN_Program_Length_Fact" p
        JOIN
            attributes."PR_LEN_Program_Length_Meta" a
        ON
            a."PR_LEN_ID" = p."PR_LEN_ID"
        WHERE
            p."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
        AND
            p."PR_LEN_ChangedAt" = _changing
        AND
            NOT attributes."eq_PR_LEN_Program_Length"(p."PR_LEN_Program_Length", NEW."PR_LEN_Program_Length")
        AND
            a."PR_LEN_Who" = _positor
        AND
            a."PR_LEN_PositedAt" = _positing
        AND
            a."PR_LEN_Confidence" <> 0.25
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_LEN_Program_Length for: %', concat_ws(', ', NEW."PR_LEN_PR_ID",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_LEN_Program_Length_Meta" a
        WHERE
            a."PR_LEN_ID" = _posit
        AND
            a."PR_LEN_Who" = _positor
        AND
            a."PR_LEN_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := attributes."he_PR_LEN_Program_Length"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0.25) = 0.25 THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."PR_LEN_Program_Length_Meta" (
            "Metadata_PR_LEN",
            "PR_LEN_ID",
            "PR_LEN_Who",
            "PR_LEN_PositedAt",
            "PR_LEN_Confidence"
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
            attributes."PR_LEN_Program_Length_Fact" p
        WHERE
            p."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
        AND
            p."PR_LEN_ChangedAt" = _changing
        AND
            NOT attributes."eq_PR_LEN_Program_Length"(p."PR_LEN_Program_Length", NEW."PR_LEN_Program_Length")
        AND
            coalesce(attributes."he_PR_LEN_Program_Length"(p."PR_LEN_ID", _positor, _positing), 0.25) <> 0.25
    LOOP
        INSERT INTO attributes."PR_LEN_Program_Length_Meta" (
            "Metadata_PR_LEN",
            "PR_LEN_ID",
            "PR_LEN_Who",
            "PR_LEN_PositedAt",
            "PR_LEN_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_LEN", 0),
            _other,
            _positor,
            _positing,
            0.25
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
                attributes."PR_LEN_Program_Length_Fact" p
            WHERE
                p."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
            AND
                p."PR_LEN_ChangedAt" < _changing
            AND
                coalesce(attributes."he_PR_LEN_Program_Length"(p."PR_LEN_ID", _positor, _positing), 0.25) <> 0.25
            AND
                (attributes."he_PR_LEN_Program_Length"(p."PR_LEN_ID", _positor, _positing) > 0.25) = (_reliability > 0.25)
            ORDER BY
                p."PR_LEN_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            attributes."eq_PR_LEN_Program_Length"(pre."PR_LEN_Program_Length", NEW."PR_LEN_Program_Length")
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
        attributes."PR_LEN_Program_Length_Fact" f
    WHERE
        f."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
    AND
        f."PR_LEN_ChangedAt" > _changing
    AND
        coalesce(attributes."he_PR_LEN_Program_Length"(f."PR_LEN_ID", _positor, _positing), 0.25) <> 0.25
    AND
        (attributes."he_PR_LEN_Program_Length"(f."PR_LEN_ID", _positor, _positing) > 0.25) = (_reliability > 0.25)
    ORDER BY
        f."PR_LEN_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND attributes."eq_PR_LEN_Program_Length"((
        SELECT x."PR_LEN_Program_Length" FROM attributes."PR_LEN_Program_Length_Fact" x WHERE x."PR_LEN_ID" = _following
    ), NEW."PR_LEN_Program_Length") THEN
        -- (an idempotent attribute retracts it)
        INSERT INTO attributes."PR_LEN_Program_Length_Meta" (
            "Metadata_PR_LEN",
            "PR_LEN_ID",
            "PR_LEN_Who",
            "PR_LEN_PositedAt",
            "PR_LEN_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_LEN", 0),
            _following,
            _positor,
            _positing,
            0.25
        )
        ON CONFLICT DO NOTHING;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."PR_LEN_Program_Length_Fact" (
            "PR_LEN_PR_ID",
            "PR_LEN_ChangedAt",
            "PR_LEN_Program_Length"
        )
        VALUES (
            NEW."PR_LEN_PR_ID",
            _changing,
            NEW."PR_LEN_Program_Length"
        )
        RETURNING "PR_LEN_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."PR_LEN_Program_Length_Meta" (
        "Metadata_PR_LEN",
        "PR_LEN_ID",
        "PR_LEN_Who",
        "PR_LEN_PositedAt",
        "PR_LEN_Confidence"
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
DROP TRIGGER IF EXISTS "it_PR_LEN_Program_Length" ON attributes."PR_LEN_Program_Length";
CREATE TRIGGER "it_PR_LEN_Program_Length"
INSTEAD OF INSERT ON attributes."PR_LEN_Program_Length"
FOR EACH ROW EXECUTE FUNCTION attributes."it_PR_LEN_Program_Length"();
