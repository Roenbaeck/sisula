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
-- he_AC_partner_AC_with_ONG_currently is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."he_AC_partner_AC_with_ONG_currently"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."AC_partner_AC_with_ONG_currently_Reliability"
    FROM
        ties."AC_partner_AC_with_ONG_currently_Annex" a
    WHERE
        a."AC_partner_AC_with_ONG_currently_ID" = _id
    AND
        a."AC_partner_AC_with_ONG_currently_Positor" = _positor
    AND
        a."AC_partner_AC_with_ONG_currently_PositedAt" <= _positing
    ORDER BY
        a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_partner_AC_with_ONG_currently tells whether a posit is in effect for a positor at a positing time: it holds an assertion of it, positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_AC_partner_AC_with_ONG_currently"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT coalesce(ties."he_AC_partner_AC_with_ONG_currently"(_id, _positor, _positing), 0) <> 0
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_partner_AC_with_ONG_currently instead of INSERT trigger on AC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_partner_AC_with_ONG_currently"()
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
    _positor := coalesce(NEW."AC_partner_AC_with_ONG_currently_Positor", 0);
    _positing := coalesce(NEW."AC_partner_AC_with_ONG_currently_PositedAt", _now);
    _reliability := coalesce(NEW."AC_partner_AC_with_ONG_currently_Reliability", 1);
    _changing := coalesce(NEW."AC_partner_AC_with_ONG_currently_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."AC_partner_AC_with_ONG_currently_ID"
    INTO
        _posit
    FROM
        ties."AC_partner_AC_with_ONG_currently_Posit" p
    WHERE
        p."AC_ID_partner" = NEW."AC_ID_partner"
    AND
        p."AC_ID_with" = NEW."AC_ID_with"
    AND
        p."ONG_ID_currently" = NEW."ONG_ID_currently"
    AND
        p."AC_partner_AC_with_ONG_currently_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_partner_AC_with_ONG_currently_Annex" a
        WHERE
            a."AC_partner_AC_with_ONG_currently_ID" = _posit
        AND
            a."AC_partner_AC_with_ONG_currently_Positor" = _positor
        AND
            a."AC_partner_AC_with_ONG_currently_PositedAt" = _positing
        AND
            a."AC_partner_AC_with_ONG_currently_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_partner_AC_with_ONG_currently for: %', concat_ws(', ',
            NEW."AC_ID_partner",
            NEW."AC_ID_with",
            NEW."ONG_ID_currently",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_partner_AC_with_ONG_currently_Annex" a
        WHERE
            a."AC_partner_AC_with_ONG_currently_ID" = _posit
        AND
            a."AC_partner_AC_with_ONG_currently_Positor" = _positor
        AND
            a."AC_partner_AC_with_ONG_currently_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := ties."he_AC_partner_AC_with_ONG_currently"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."AC_partner_AC_with_ONG_currently_Annex" (
            "Metadata_AC_partner_AC_with_ONG_currently",
            "AC_partner_AC_with_ONG_currently_ID",
            "AC_partner_AC_with_ONG_currently_Positor",
            "AC_partner_AC_with_ONG_currently_PositedAt",
            "AC_partner_AC_with_ONG_currently_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_partner_AC_with_ONG_currently", 0),
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."AC_partner_AC_with_ONG_currently_Posit" (
            "AC_ID_partner",
            "AC_ID_with",
            "ONG_ID_currently",
            "AC_partner_AC_with_ONG_currently_ChangedAt"
        )
        VALUES (
            NEW."AC_ID_partner",
            NEW."AC_ID_with",
            NEW."ONG_ID_currently",
            _changing
        )
        RETURNING "AC_partner_AC_with_ONG_currently_ID" INTO _posit;
    END IF;
    INSERT INTO ties."AC_partner_AC_with_ONG_currently_Annex" (
        "Metadata_AC_partner_AC_with_ONG_currently",
        "AC_partner_AC_with_ONG_currently_ID",
        "AC_partner_AC_with_ONG_currently_Positor",
        "AC_partner_AC_with_ONG_currently_PositedAt",
        "AC_partner_AC_with_ONG_currently_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_partner_AC_with_ONG_currently", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_partner_AC_with_ONG_currently" ON ties."AC_partner_AC_with_ONG_currently";
CREATE TRIGGER "it_AC_partner_AC_with_ONG_currently"
INSTEAD OF INSERT ON ties."AC_partner_AC_with_ONG_currently"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_partner_AC_with_ONG_currently"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_partner_AC_with_ONG_currently instead of INSERT trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_partner_AC_with_ONG_currently"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."AC_partner_AC_with_ONG_currently" (
        "Metadata_AC_partner_AC_with_ONG_currently",
        "AC_ID_partner",
        "AC_ID_with",
        "ONG_ID_currently",
        "AC_partner_AC_with_ONG_currently_ChangedAt",
        "AC_partner_AC_with_ONG_currently_Positor",
        "AC_partner_AC_with_ONG_currently_PositedAt",
        "AC_partner_AC_with_ONG_currently_Reliability"
    )
    VALUES (
        NEW."Metadata_AC_partner_AC_with_ONG_currently",
        NEW."AC_ID_partner",
        NEW."AC_ID_with",
        coalesce(NEW."ONG_ID_currently", (
            SELECT
                k."ONG_ID"
            FROM
                knots."ONG_Pågående" k
            WHERE
                k."ONG_Pågående" = NEW."currently_ONG_Pågående"
            LIMIT 1
        )),
        coalesce(NEW."AC_partner_AC_with_ONG_currently_ChangedAt", _now),
        coalesce(NEW."AC_partner_AC_with_ONG_currently_Positor", NEW."Positor", 0),
        coalesce(NEW."AC_partner_AC_with_ONG_currently_PositedAt", _now),
        coalesce(NEW."AC_partner_AC_with_ONG_currently_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lAC_partner_AC_with_ONG_currently" ON ties."lAC_partner_AC_with_ONG_currently";
CREATE TRIGGER "it_lAC_partner_AC_with_ONG_currently"
INSTEAD OF INSERT ON ties."lAC_partner_AC_with_ONG_currently"
FOR EACH ROW EXECUTE FUNCTION ties."it_lAC_partner_AC_with_ONG_currently"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_partner_AC_with_ONG_currently instead of UPDATE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ut_lAC_partner_AC_with_ONG_currently"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _positor smallint;
    _ONG_currently smallint;
BEGIN
    _ONG_currently := NEW."ONG_ID_currently";
    IF NEW."currently_ONG_Pågående" IS DISTINCT FROM OLD."currently_ONG_Pågående" AND NEW."ONG_ID_currently" IS NOT DISTINCT FROM OLD."ONG_ID_currently" THEN
        _ONG_currently := NULL;
        IF NEW."currently_ONG_Pågående" IS NOT NULL THEN
            SELECT
                k."ONG_ID"
            INTO
                _ONG_currently
            FROM
                knots."ONG_Pågående" k
            WHERE
                k."ONG_Pågående" = NEW."currently_ONG_Pågående"
            LIMIT 1;
        END IF;
    END IF;
    _positor := coalesce(CASE
        WHEN NEW."AC_partner_AC_with_ONG_currently_Positor" IS DISTINCT FROM OLD."AC_partner_AC_with_ONG_currently_Positor" THEN NEW."AC_partner_AC_with_ONG_currently_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."AC_partner_AC_with_ONG_currently_PositedAt" IS DISTINCT FROM OLD."AC_partner_AC_with_ONG_currently_PositedAt" THEN NEW."AC_partner_AC_with_ONG_currently_PositedAt"
        ELSE _now
    END;
    IF
        NEW."AC_ID_partner" IS DISTINCT FROM OLD."AC_ID_partner" OR
        NEW."AC_ID_with" IS DISTINCT FROM OLD."AC_ID_with" OR
        _ONG_currently IS DISTINCT FROM OLD."ONG_ID_currently" OR
        NEW."AC_partner_AC_with_ONG_currently_ChangedAt" IS DISTINCT FROM OLD."AC_partner_AC_with_ONG_currently_ChangedAt" OR
        NEW."AC_partner_AC_with_ONG_currently_PositedAt" IS DISTINCT FROM OLD."AC_partner_AC_with_ONG_currently_PositedAt" OR
        NEW."AC_partner_AC_with_ONG_currently_Reliability" IS DISTINCT FROM OLD."AC_partner_AC_with_ONG_currently_Reliability"
    THEN
        IF
            NEW."AC_ID_partner" IS NOT NULL
        AND
            NEW."AC_ID_with" IS NOT NULL
        AND
            _ONG_currently IS NOT NULL
        THEN
            INSERT INTO ties."AC_partner_AC_with_ONG_currently" (
                "Metadata_AC_partner_AC_with_ONG_currently",
                "AC_ID_partner",
                "AC_ID_with",
                "ONG_ID_currently",
                "AC_partner_AC_with_ONG_currently_ChangedAt",
                "AC_partner_AC_with_ONG_currently_Positor",
                "AC_partner_AC_with_ONG_currently_PositedAt",
                "AC_partner_AC_with_ONG_currently_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_partner_AC_with_ONG_currently",
                NEW."AC_ID_partner",
                NEW."AC_ID_with",
                _ONG_currently,
                -- the shown version asserted again keeps its changing time, as does one that is given
                CASE
                    WHEN NEW."AC_partner_AC_with_ONG_currently_ChangedAt" IS DISTINCT FROM OLD."AC_partner_AC_with_ONG_currently_ChangedAt" THEN NEW."AC_partner_AC_with_ONG_currently_ChangedAt"
                    WHEN
                        NEW."AC_ID_partner" = OLD."AC_ID_partner"
                    AND
                        NEW."AC_ID_with" = OLD."AC_ID_with"
                    AND
                        _ONG_currently = OLD."ONG_ID_currently"
                    THEN NEW."AC_partner_AC_with_ONG_currently_ChangedAt"
                    ELSE _now
                END,
                _positor,
                _positing,
                coalesce(NEW."AC_partner_AC_with_ONG_currently_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO ties."AC_partner_AC_with_ONG_currently" (
                "Metadata_AC_partner_AC_with_ONG_currently",
                "AC_ID_partner",
                "AC_ID_with",
                "ONG_ID_currently",
                "AC_partner_AC_with_ONG_currently_ChangedAt",
                "AC_partner_AC_with_ONG_currently_Positor",
                "AC_partner_AC_with_ONG_currently_PositedAt",
                "AC_partner_AC_with_ONG_currently_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_partner_AC_with_ONG_currently",
                OLD."AC_ID_partner",
                OLD."AC_ID_with",
                OLD."ONG_ID_currently",
                OLD."AC_partner_AC_with_ONG_currently_ChangedAt",
                _positor,
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lAC_partner_AC_with_ONG_currently" ON ties."lAC_partner_AC_with_ONG_currently";
CREATE TRIGGER "ut_lAC_partner_AC_with_ONG_currently"
INSTEAD OF UPDATE ON ties."lAC_partner_AC_with_ONG_currently"
FOR EACH ROW EXECUTE FUNCTION ties."ut_lAC_partner_AC_with_ONG_currently"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_partner_AC_with_ONG_currently instead of DELETE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lAC_partner_AC_with_ONG_currently"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."AC_partner_AC_with_ONG_currently" (
        "Metadata_AC_partner_AC_with_ONG_currently",
        "AC_ID_partner",
        "AC_ID_with",
        "ONG_ID_currently",
        "AC_partner_AC_with_ONG_currently_ChangedAt",
        "AC_partner_AC_with_ONG_currently_Positor",
        "AC_partner_AC_with_ONG_currently_PositedAt",
        "AC_partner_AC_with_ONG_currently_Reliability"
    )
    VALUES (
        OLD."Metadata_AC_partner_AC_with_ONG_currently",
        OLD."AC_ID_partner",
        OLD."AC_ID_with",
        OLD."ONG_ID_currently",
        OLD."AC_partner_AC_with_ONG_currently_ChangedAt",
        coalesce(OLD."AC_partner_AC_with_ONG_currently_Positor", OLD."Positor", 0),
        _now,
        0
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_partner_AC_with_ONG_currently" ON ties."lAC_partner_AC_with_ONG_currently";
CREATE TRIGGER "dt_lAC_partner_AC_with_ONG_currently"
INSTEAD OF DELETE ON ties."lAC_partner_AC_with_ONG_currently"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_partner_AC_with_ONG_currently"();
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_subset_PN_of is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."he_AC_subset_PN_of"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."AC_subset_PN_of_Reliability"
    FROM
        ties."AC_subset_PN_of_Annex" a
    WHERE
        a."AC_subset_PN_of_ID" = _id
    AND
        a."AC_subset_PN_of_Positor" = _positor
    AND
        a."AC_subset_PN_of_PositedAt" <= _positing
    ORDER BY
        a."AC_subset_PN_of_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_subset_PN_of tells whether a posit is in effect for a positor at a positing time: it holds an assertion of it, positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_AC_subset_PN_of"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT coalesce(ties."he_AC_subset_PN_of"(_id, _positor, _positing), 0) <> 0
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_subset_PN_of instead of INSERT trigger on AC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_subset_PN_of"()
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
    _positor := coalesce(NEW."AC_subset_PN_of_Positor", 0);
    _positing := coalesce(NEW."AC_subset_PN_of_PositedAt", _now);
    _reliability := coalesce(NEW."AC_subset_PN_of_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."AC_subset_PN_of_ID"
    INTO
        _posit
    FROM
        ties."AC_subset_PN_of_Posit" p
    WHERE
        p."AC_ID_subset" = NEW."AC_ID_subset"
    AND
        p."PN_ID_of" = NEW."PN_ID_of"
    AND
        true
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_subset_PN_of_Annex" a
        WHERE
            a."AC_subset_PN_of_ID" = _posit
        AND
            a."AC_subset_PN_of_Positor" = _positor
        AND
            a."AC_subset_PN_of_PositedAt" = _positing
        AND
            a."AC_subset_PN_of_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_subset_PN_of for: %', concat_ws(', ',
            NEW."AC_ID_subset",
            NEW."PN_ID_of",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_subset_PN_of_Annex" a
        WHERE
            a."AC_subset_PN_of_ID" = _posit
        AND
            a."AC_subset_PN_of_Positor" = _positor
        AND
            a."AC_subset_PN_of_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := ties."he_AC_subset_PN_of"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."AC_subset_PN_of_Annex" (
            "Metadata_AC_subset_PN_of",
            "AC_subset_PN_of_ID",
            "AC_subset_PN_of_Positor",
            "AC_subset_PN_of_PositedAt",
            "AC_subset_PN_of_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_subset_PN_of", 0),
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."AC_subset_PN_of_Posit" (
            "AC_ID_subset",
            "PN_ID_of",
            "AC_subset_PN_of_ID"
        )
        VALUES (
            NEW."AC_ID_subset",
            NEW."PN_ID_of",
            DEFAULT
        )
        RETURNING "AC_subset_PN_of_ID" INTO _posit;
    END IF;
    INSERT INTO ties."AC_subset_PN_of_Annex" (
        "Metadata_AC_subset_PN_of",
        "AC_subset_PN_of_ID",
        "AC_subset_PN_of_Positor",
        "AC_subset_PN_of_PositedAt",
        "AC_subset_PN_of_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_subset_PN_of", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_subset_PN_of" ON ties."AC_subset_PN_of";
CREATE TRIGGER "it_AC_subset_PN_of"
INSTEAD OF INSERT ON ties."AC_subset_PN_of"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_subset_PN_of"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_subset_PN_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."AC_subset_PN_of" (
        "Metadata_AC_subset_PN_of",
        "AC_ID_subset",
        "PN_ID_of",
        "AC_subset_PN_of_Positor",
        "AC_subset_PN_of_PositedAt",
        "AC_subset_PN_of_Reliability"
    )
    VALUES (
        NEW."Metadata_AC_subset_PN_of",
        NEW."AC_ID_subset",
        NEW."PN_ID_of",
        coalesce(NEW."AC_subset_PN_of_Positor", NEW."Positor", 0),
        coalesce(NEW."AC_subset_PN_of_PositedAt", _now),
        coalesce(NEW."AC_subset_PN_of_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lAC_subset_PN_of" ON ties."lAC_subset_PN_of";
CREATE TRIGGER "it_lAC_subset_PN_of"
INSTEAD OF INSERT ON ties."lAC_subset_PN_of"
FOR EACH ROW EXECUTE FUNCTION ties."it_lAC_subset_PN_of"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_subset_PN_of instead of UPDATE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ut_lAC_subset_PN_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _positor smallint;
BEGIN
    _positor := coalesce(CASE
        WHEN NEW."AC_subset_PN_of_Positor" IS DISTINCT FROM OLD."AC_subset_PN_of_Positor" THEN NEW."AC_subset_PN_of_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."AC_subset_PN_of_PositedAt" IS DISTINCT FROM OLD."AC_subset_PN_of_PositedAt" THEN NEW."AC_subset_PN_of_PositedAt"
        ELSE _now
    END;
    IF
        NEW."AC_ID_subset" IS DISTINCT FROM OLD."AC_ID_subset" OR
        NEW."PN_ID_of" IS DISTINCT FROM OLD."PN_ID_of" OR
        NEW."AC_subset_PN_of_PositedAt" IS DISTINCT FROM OLD."AC_subset_PN_of_PositedAt" OR
        NEW."AC_subset_PN_of_Reliability" IS DISTINCT FROM OLD."AC_subset_PN_of_Reliability"
    THEN
        IF
            NEW."AC_ID_subset" IS NOT NULL
        AND
            NEW."PN_ID_of" IS NOT NULL
        THEN
            INSERT INTO ties."AC_subset_PN_of" (
                "Metadata_AC_subset_PN_of",
                "AC_ID_subset",
                "PN_ID_of",
                "AC_subset_PN_of_Positor",
                "AC_subset_PN_of_PositedAt",
                "AC_subset_PN_of_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_subset_PN_of",
                NEW."AC_ID_subset",
                NEW."PN_ID_of",
                _positor,
                _positing,
                coalesce(NEW."AC_subset_PN_of_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO ties."AC_subset_PN_of" (
                "Metadata_AC_subset_PN_of",
                "AC_ID_subset",
                "PN_ID_of",
                "AC_subset_PN_of_Positor",
                "AC_subset_PN_of_PositedAt",
                "AC_subset_PN_of_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_subset_PN_of",
                OLD."AC_ID_subset",
                OLD."PN_ID_of",
                _positor,
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lAC_subset_PN_of" ON ties."lAC_subset_PN_of";
CREATE TRIGGER "ut_lAC_subset_PN_of"
INSTEAD OF UPDATE ON ties."lAC_subset_PN_of"
FOR EACH ROW EXECUTE FUNCTION ties."ut_lAC_subset_PN_of"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lAC_subset_PN_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."AC_subset_PN_of" (
        "Metadata_AC_subset_PN_of",
        "AC_ID_subset",
        "PN_ID_of",
        "AC_subset_PN_of_Positor",
        "AC_subset_PN_of_PositedAt",
        "AC_subset_PN_of_Reliability"
    )
    VALUES (
        OLD."Metadata_AC_subset_PN_of",
        OLD."AC_ID_subset",
        OLD."PN_ID_of",
        coalesce(OLD."AC_subset_PN_of_Positor", OLD."Positor", 0),
        _now,
        0
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_subset_PN_of" ON ties."lAC_subset_PN_of";
CREATE TRIGGER "dt_lAC_subset_PN_of"
INSTEAD OF DELETE ON ties."lAC_subset_PN_of"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_subset_PN_of"();
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_in_AC_rollsattes is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."he_EV_in_AC_rollsattes"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."EV_in_AC_rollsattes_Reliability"
    FROM
        ties."EV_in_AC_rollsattes_Annex" a
    WHERE
        a."EV_in_AC_rollsattes_ID" = _id
    AND
        a."EV_in_AC_rollsattes_Positor" = _positor
    AND
        a."EV_in_AC_rollsattes_PositedAt" <= _positing
    ORDER BY
        a."EV_in_AC_rollsattes_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_EV_in_AC_rollsattes tells whether a posit is in effect for a positor at a positing time: it holds an assertion of it, positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_EV_in_AC_rollsattes"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT coalesce(ties."he_EV_in_AC_rollsattes"(_id, _positor, _positing), 0) <> 0
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_in_AC_rollsattes instead of INSERT trigger on EV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_EV_in_AC_rollsattes"()
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
    _positor := coalesce(NEW."EV_in_AC_rollsattes_Positor", 0);
    _positing := coalesce(NEW."EV_in_AC_rollsattes_PositedAt", _now);
    _reliability := coalesce(NEW."EV_in_AC_rollsattes_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."EV_in_AC_rollsattes_ID"
    INTO
        _posit
    FROM
        ties."EV_in_AC_rollsattes_Posit" p
    WHERE
        p."EV_ID_in" = NEW."EV_ID_in"
    AND
        p."AC_ID_rollsattes" = NEW."AC_ID_rollsattes"
    AND
        true
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."EV_in_AC_rollsattes_Annex" a
        WHERE
            a."EV_in_AC_rollsattes_ID" = _posit
        AND
            a."EV_in_AC_rollsattes_Positor" = _positor
        AND
            a."EV_in_AC_rollsattes_PositedAt" = _positing
        AND
            a."EV_in_AC_rollsattes_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_in_AC_rollsattes for: %', concat_ws(', ',
            NEW."EV_ID_in",
            NEW."AC_ID_rollsattes",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."EV_in_AC_rollsattes_Annex" a
        WHERE
            a."EV_in_AC_rollsattes_ID" = _posit
        AND
            a."EV_in_AC_rollsattes_Positor" = _positor
        AND
            a."EV_in_AC_rollsattes_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := ties."he_EV_in_AC_rollsattes"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."EV_in_AC_rollsattes_Annex" (
            "Metadata_EV_in_AC_rollsattes",
            "EV_in_AC_rollsattes_ID",
            "EV_in_AC_rollsattes_Positor",
            "EV_in_AC_rollsattes_PositedAt",
            "EV_in_AC_rollsattes_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_in_AC_rollsattes", 0),
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."EV_in_AC_rollsattes_Posit" (
            "EV_ID_in",
            "AC_ID_rollsattes",
            "EV_in_AC_rollsattes_ID"
        )
        VALUES (
            NEW."EV_ID_in",
            NEW."AC_ID_rollsattes",
            DEFAULT
        )
        RETURNING "EV_in_AC_rollsattes_ID" INTO _posit;
    END IF;
    INSERT INTO ties."EV_in_AC_rollsattes_Annex" (
        "Metadata_EV_in_AC_rollsattes",
        "EV_in_AC_rollsattes_ID",
        "EV_in_AC_rollsattes_Positor",
        "EV_in_AC_rollsattes_PositedAt",
        "EV_in_AC_rollsattes_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_in_AC_rollsattes", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_in_AC_rollsattes" ON ties."EV_in_AC_rollsattes";
CREATE TRIGGER "it_EV_in_AC_rollsattes"
INSTEAD OF INSERT ON ties."EV_in_AC_rollsattes"
FOR EACH ROW EXECUTE FUNCTION ties."it_EV_in_AC_rollsattes"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_rollsattes instead of INSERT trigger on lEV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lEV_in_AC_rollsattes"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."EV_in_AC_rollsattes" (
        "Metadata_EV_in_AC_rollsattes",
        "EV_ID_in",
        "AC_ID_rollsattes",
        "EV_in_AC_rollsattes_Positor",
        "EV_in_AC_rollsattes_PositedAt",
        "EV_in_AC_rollsattes_Reliability"
    )
    VALUES (
        NEW."Metadata_EV_in_AC_rollsattes",
        NEW."EV_ID_in",
        NEW."AC_ID_rollsattes",
        coalesce(NEW."EV_in_AC_rollsattes_Positor", NEW."Positor", 0),
        coalesce(NEW."EV_in_AC_rollsattes_PositedAt", _now),
        coalesce(NEW."EV_in_AC_rollsattes_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lEV_in_AC_rollsattes" ON ties."lEV_in_AC_rollsattes";
CREATE TRIGGER "it_lEV_in_AC_rollsattes"
INSTEAD OF INSERT ON ties."lEV_in_AC_rollsattes"
FOR EACH ROW EXECUTE FUNCTION ties."it_lEV_in_AC_rollsattes"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_in_AC_rollsattes instead of DELETE trigger on lEV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lEV_in_AC_rollsattes"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."EV_in_AC_rollsattes" (
        "Metadata_EV_in_AC_rollsattes",
        "EV_ID_in",
        "AC_ID_rollsattes",
        "EV_in_AC_rollsattes_Positor",
        "EV_in_AC_rollsattes_PositedAt",
        "EV_in_AC_rollsattes_Reliability"
    )
    VALUES (
        OLD."Metadata_EV_in_AC_rollsattes",
        OLD."EV_ID_in",
        OLD."AC_ID_rollsattes",
        coalesce(OLD."EV_in_AC_rollsattes_Positor", OLD."Positor", 0),
        _now,
        0
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lEV_in_AC_rollsattes" ON ties."lEV_in_AC_rollsattes";
CREATE TRIGGER "dt_lEV_in_AC_rollsattes"
INSTEAD OF DELETE ON ties."lEV_in_AC_rollsattes"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lEV_in_AC_rollsattes"();
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_deltar_PR_in_RAT_fick is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."he_AC_deltar_PR_in_RAT_fick"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."AC_deltar_PR_in_RAT_fick_Reliability"
    FROM
        ties."AC_deltar_PR_in_RAT_fick_Annex" a
    WHERE
        a."AC_deltar_PR_in_RAT_fick_ID" = _id
    AND
        a."AC_deltar_PR_in_RAT_fick_Positor" = _positor
    AND
        a."AC_deltar_PR_in_RAT_fick_PositedAt" <= _positing
    ORDER BY
        a."AC_deltar_PR_in_RAT_fick_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_deltar_PR_in_RAT_fick tells whether a posit is in effect for a positor at a positing time: it holds an assertion of it, positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_AC_deltar_PR_in_RAT_fick"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT coalesce(ties."he_AC_deltar_PR_in_RAT_fick"(_id, _positor, _positing), 0) <> 0
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_deltar_PR_in_RAT_fick instead of INSERT trigger on AC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_deltar_PR_in_RAT_fick"()
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
    _positor := coalesce(NEW."AC_deltar_PR_in_RAT_fick_Positor", 0);
    _positing := coalesce(NEW."AC_deltar_PR_in_RAT_fick_PositedAt", _now);
    _reliability := coalesce(NEW."AC_deltar_PR_in_RAT_fick_Reliability", 1);
    _changing := coalesce(NEW."AC_deltar_PR_in_RAT_fick_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."AC_deltar_PR_in_RAT_fick_ID"
    INTO
        _posit
    FROM
        ties."AC_deltar_PR_in_RAT_fick_Posit" p
    WHERE
        p."AC_ID_deltar" = NEW."AC_ID_deltar"
    AND
        p."PR_ID_in" = NEW."PR_ID_in"
    AND
        p."RAT_ID_fick" = NEW."RAT_ID_fick"
    AND
        p."AC_deltar_PR_in_RAT_fick_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_deltar_PR_in_RAT_fick_Annex" a
        WHERE
            a."AC_deltar_PR_in_RAT_fick_ID" = _posit
        AND
            a."AC_deltar_PR_in_RAT_fick_Positor" = _positor
        AND
            a."AC_deltar_PR_in_RAT_fick_PositedAt" = _positing
        AND
            a."AC_deltar_PR_in_RAT_fick_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_deltar_PR_in_RAT_fick for: %', concat_ws(', ',
            NEW."AC_ID_deltar",
            NEW."PR_ID_in",
            NEW."RAT_ID_fick",
            _changing,
            _positor, _positing);
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, are other values for identifiers that already have
    -- values (at that time), asserted by the positor at the positing time
    IF _reliability <> 0 AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_deltar_PR_in_RAT_fick_Posit" p
        JOIN
            ties."AC_deltar_PR_in_RAT_fick_Annex" a
        ON
            a."AC_deltar_PR_in_RAT_fick_ID" = p."AC_deltar_PR_in_RAT_fick_ID"
        WHERE
            p."AC_ID_deltar" = NEW."AC_ID_deltar"
        AND
            p."PR_ID_in" = NEW."PR_ID_in"
        AND
            p."AC_deltar_PR_in_RAT_fick_ChangedAt" = _changing
        AND
            NOT (
                p."RAT_ID_fick" = NEW."RAT_ID_fick"
            )
        AND
            a."AC_deltar_PR_in_RAT_fick_Positor" = _positor
        AND
            a."AC_deltar_PR_in_RAT_fick_PositedAt" = _positing
        AND
            a."AC_deltar_PR_in_RAT_fick_Reliability" <> 0
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_deltar_PR_in_RAT_fick for: %', concat_ws(', ',
            NEW."AC_ID_deltar",
            NEW."PR_ID_in",
            NEW."RAT_ID_fick",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_deltar_PR_in_RAT_fick_Annex" a
        WHERE
            a."AC_deltar_PR_in_RAT_fick_ID" = _posit
        AND
            a."AC_deltar_PR_in_RAT_fick_Positor" = _positor
        AND
            a."AC_deltar_PR_in_RAT_fick_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := ties."he_AC_deltar_PR_in_RAT_fick"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."AC_deltar_PR_in_RAT_fick_Annex" (
            "Metadata_AC_deltar_PR_in_RAT_fick",
            "AC_deltar_PR_in_RAT_fick_ID",
            "AC_deltar_PR_in_RAT_fick_Positor",
            "AC_deltar_PR_in_RAT_fick_PositedAt",
            "AC_deltar_PR_in_RAT_fick_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_deltar_PR_in_RAT_fick", 0),
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
            p."AC_deltar_PR_in_RAT_fick_ID"
        FROM
            ties."AC_deltar_PR_in_RAT_fick_Posit" p
        WHERE
            p."AC_ID_deltar" = NEW."AC_ID_deltar"
        AND
            p."PR_ID_in" = NEW."PR_ID_in"
        AND
            p."AC_deltar_PR_in_RAT_fick_ChangedAt" = _changing
        AND
            NOT (
                p."RAT_ID_fick" = NEW."RAT_ID_fick"
            )
        AND
            ties."ie_AC_deltar_PR_in_RAT_fick"(p."AC_deltar_PR_in_RAT_fick_ID", _positor, _positing)
    LOOP
        INSERT INTO ties."AC_deltar_PR_in_RAT_fick_Annex" (
            "Metadata_AC_deltar_PR_in_RAT_fick",
            "AC_deltar_PR_in_RAT_fick_ID",
            "AC_deltar_PR_in_RAT_fick_Positor",
            "AC_deltar_PR_in_RAT_fick_PositedAt",
            "AC_deltar_PR_in_RAT_fick_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_deltar_PR_in_RAT_fick", 0),
            _other,
            _positor,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."AC_deltar_PR_in_RAT_fick_Posit" (
            "AC_ID_deltar",
            "PR_ID_in",
            "RAT_ID_fick",
            "AC_deltar_PR_in_RAT_fick_ChangedAt"
        )
        VALUES (
            NEW."AC_ID_deltar",
            NEW."PR_ID_in",
            NEW."RAT_ID_fick",
            _changing
        )
        RETURNING "AC_deltar_PR_in_RAT_fick_ID" INTO _posit;
    END IF;
    INSERT INTO ties."AC_deltar_PR_in_RAT_fick_Annex" (
        "Metadata_AC_deltar_PR_in_RAT_fick",
        "AC_deltar_PR_in_RAT_fick_ID",
        "AC_deltar_PR_in_RAT_fick_Positor",
        "AC_deltar_PR_in_RAT_fick_PositedAt",
        "AC_deltar_PR_in_RAT_fick_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_deltar_PR_in_RAT_fick", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_deltar_PR_in_RAT_fick" ON ties."AC_deltar_PR_in_RAT_fick";
CREATE TRIGGER "it_AC_deltar_PR_in_RAT_fick"
INSTEAD OF INSERT ON ties."AC_deltar_PR_in_RAT_fick"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_deltar_PR_in_RAT_fick"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_deltar_PR_in_RAT_fick instead of INSERT trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_deltar_PR_in_RAT_fick"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."AC_deltar_PR_in_RAT_fick" (
        "Metadata_AC_deltar_PR_in_RAT_fick",
        "AC_ID_deltar",
        "PR_ID_in",
        "RAT_ID_fick",
        "AC_deltar_PR_in_RAT_fick_ChangedAt",
        "AC_deltar_PR_in_RAT_fick_Positor",
        "AC_deltar_PR_in_RAT_fick_PositedAt",
        "AC_deltar_PR_in_RAT_fick_Reliability"
    )
    VALUES (
        NEW."Metadata_AC_deltar_PR_in_RAT_fick",
        NEW."AC_ID_deltar",
        NEW."PR_ID_in",
        coalesce(NEW."RAT_ID_fick", (
            SELECT
                k."RAT_ID"
            FROM
                knots."RAT_Betyg" k
            WHERE
                k."RAT_Betyg" = NEW."fick_RAT_Betyg"
            LIMIT 1
        )),
        coalesce(NEW."AC_deltar_PR_in_RAT_fick_ChangedAt", _now),
        coalesce(NEW."AC_deltar_PR_in_RAT_fick_Positor", NEW."Positor", 0),
        coalesce(NEW."AC_deltar_PR_in_RAT_fick_PositedAt", _now),
        coalesce(NEW."AC_deltar_PR_in_RAT_fick_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lAC_deltar_PR_in_RAT_fick" ON ties."lAC_deltar_PR_in_RAT_fick";
CREATE TRIGGER "it_lAC_deltar_PR_in_RAT_fick"
INSTEAD OF INSERT ON ties."lAC_deltar_PR_in_RAT_fick"
FOR EACH ROW EXECUTE FUNCTION ties."it_lAC_deltar_PR_in_RAT_fick"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_deltar_PR_in_RAT_fick instead of UPDATE trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ut_lAC_deltar_PR_in_RAT_fick"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _positor smallint;
    _RAT_fick smallint;
BEGIN
    IF NEW."AC_ID_deltar" IS DISTINCT FROM OLD."AC_ID_deltar" THEN
        RAISE EXCEPTION 'The identity column AC_ID_deltar is not updatable.';
    END IF;
    IF NEW."PR_ID_in" IS DISTINCT FROM OLD."PR_ID_in" THEN
        RAISE EXCEPTION 'The identity column PR_ID_in is not updatable.';
    END IF;
    _RAT_fick := NEW."RAT_ID_fick";
    IF NEW."fick_RAT_Betyg" IS DISTINCT FROM OLD."fick_RAT_Betyg" AND NEW."RAT_ID_fick" IS NOT DISTINCT FROM OLD."RAT_ID_fick" THEN
        _RAT_fick := NULL;
        IF NEW."fick_RAT_Betyg" IS NOT NULL THEN
            SELECT
                k."RAT_ID"
            INTO
                _RAT_fick
            FROM
                knots."RAT_Betyg" k
            WHERE
                k."RAT_Betyg" = NEW."fick_RAT_Betyg"
            LIMIT 1;
        END IF;
    END IF;
    _positor := coalesce(CASE
        WHEN NEW."AC_deltar_PR_in_RAT_fick_Positor" IS DISTINCT FROM OLD."AC_deltar_PR_in_RAT_fick_Positor" THEN NEW."AC_deltar_PR_in_RAT_fick_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."AC_deltar_PR_in_RAT_fick_PositedAt" IS DISTINCT FROM OLD."AC_deltar_PR_in_RAT_fick_PositedAt" THEN NEW."AC_deltar_PR_in_RAT_fick_PositedAt"
        ELSE _now
    END;
    IF
        NEW."AC_ID_deltar" IS DISTINCT FROM OLD."AC_ID_deltar" OR
        NEW."PR_ID_in" IS DISTINCT FROM OLD."PR_ID_in" OR
        _RAT_fick IS DISTINCT FROM OLD."RAT_ID_fick" OR
        NEW."AC_deltar_PR_in_RAT_fick_ChangedAt" IS DISTINCT FROM OLD."AC_deltar_PR_in_RAT_fick_ChangedAt" OR
        NEW."AC_deltar_PR_in_RAT_fick_PositedAt" IS DISTINCT FROM OLD."AC_deltar_PR_in_RAT_fick_PositedAt" OR
        NEW."AC_deltar_PR_in_RAT_fick_Reliability" IS DISTINCT FROM OLD."AC_deltar_PR_in_RAT_fick_Reliability"
    THEN
        IF
            NEW."AC_ID_deltar" IS NOT NULL
        AND
            NEW."PR_ID_in" IS NOT NULL
        AND
            _RAT_fick IS NOT NULL
        THEN
            INSERT INTO ties."AC_deltar_PR_in_RAT_fick" (
                "Metadata_AC_deltar_PR_in_RAT_fick",
                "AC_ID_deltar",
                "PR_ID_in",
                "RAT_ID_fick",
                "AC_deltar_PR_in_RAT_fick_ChangedAt",
                "AC_deltar_PR_in_RAT_fick_Positor",
                "AC_deltar_PR_in_RAT_fick_PositedAt",
                "AC_deltar_PR_in_RAT_fick_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_deltar_PR_in_RAT_fick",
                NEW."AC_ID_deltar",
                NEW."PR_ID_in",
                _RAT_fick,
                -- the shown version asserted again keeps its changing time, as does one that is given
                CASE
                    WHEN NEW."AC_deltar_PR_in_RAT_fick_ChangedAt" IS DISTINCT FROM OLD."AC_deltar_PR_in_RAT_fick_ChangedAt" THEN NEW."AC_deltar_PR_in_RAT_fick_ChangedAt"
                    WHEN
                        NEW."AC_ID_deltar" = OLD."AC_ID_deltar"
                    AND
                        NEW."PR_ID_in" = OLD."PR_ID_in"
                    AND
                        _RAT_fick = OLD."RAT_ID_fick"
                    THEN NEW."AC_deltar_PR_in_RAT_fick_ChangedAt"
                    ELSE _now
                END,
                _positor,
                _positing,
                coalesce(NEW."AC_deltar_PR_in_RAT_fick_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO ties."AC_deltar_PR_in_RAT_fick" (
                "Metadata_AC_deltar_PR_in_RAT_fick",
                "AC_ID_deltar",
                "PR_ID_in",
                "RAT_ID_fick",
                "AC_deltar_PR_in_RAT_fick_ChangedAt",
                "AC_deltar_PR_in_RAT_fick_Positor",
                "AC_deltar_PR_in_RAT_fick_PositedAt",
                "AC_deltar_PR_in_RAT_fick_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_deltar_PR_in_RAT_fick",
                OLD."AC_ID_deltar",
                OLD."PR_ID_in",
                OLD."RAT_ID_fick",
                OLD."AC_deltar_PR_in_RAT_fick_ChangedAt",
                _positor,
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lAC_deltar_PR_in_RAT_fick" ON ties."lAC_deltar_PR_in_RAT_fick";
CREATE TRIGGER "ut_lAC_deltar_PR_in_RAT_fick"
INSTEAD OF UPDATE ON ties."lAC_deltar_PR_in_RAT_fick"
FOR EACH ROW EXECUTE FUNCTION ties."ut_lAC_deltar_PR_in_RAT_fick"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_deltar_PR_in_RAT_fick instead of DELETE trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lAC_deltar_PR_in_RAT_fick"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."AC_deltar_PR_in_RAT_fick" (
        "Metadata_AC_deltar_PR_in_RAT_fick",
        "AC_ID_deltar",
        "PR_ID_in",
        "RAT_ID_fick",
        "AC_deltar_PR_in_RAT_fick_ChangedAt",
        "AC_deltar_PR_in_RAT_fick_Positor",
        "AC_deltar_PR_in_RAT_fick_PositedAt",
        "AC_deltar_PR_in_RAT_fick_Reliability"
    )
    VALUES (
        OLD."Metadata_AC_deltar_PR_in_RAT_fick",
        OLD."AC_ID_deltar",
        OLD."PR_ID_in",
        OLD."RAT_ID_fick",
        OLD."AC_deltar_PR_in_RAT_fick_ChangedAt",
        coalesce(OLD."AC_deltar_PR_in_RAT_fick_Positor", OLD."Positor", 0),
        _now,
        0
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_deltar_PR_in_RAT_fick" ON ties."lAC_deltar_PR_in_RAT_fick";
CREATE TRIGGER "dt_lAC_deltar_PR_in_RAT_fick"
INSTEAD OF DELETE ON ties."lAC_deltar_PR_in_RAT_fick"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_deltar_PR_in_RAT_fick"();
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_at_PR_spelas is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."he_ST_at_PR_spelas"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."ST_at_PR_spelas_Reliability"
    FROM
        ties."ST_at_PR_spelas_Annex" a
    WHERE
        a."ST_at_PR_spelas_ID" = _id
    AND
        a."ST_at_PR_spelas_Positor" = _positor
    AND
        a."ST_at_PR_spelas_PositedAt" <= _positing
    ORDER BY
        a."ST_at_PR_spelas_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_ST_at_PR_spelas tells whether a posit is in effect for a positor at a positing time: it holds an assertion of it, positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_ST_at_PR_spelas"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT coalesce(ties."he_ST_at_PR_spelas"(_id, _positor, _positing), 0) <> 0
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_at_PR_spelas instead of INSERT trigger on ST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_ST_at_PR_spelas"()
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
    _positor := coalesce(NEW."ST_at_PR_spelas_Positor", 0);
    _positing := coalesce(NEW."ST_at_PR_spelas_PositedAt", _now);
    _reliability := coalesce(NEW."ST_at_PR_spelas_Reliability", 1);
    _changing := coalesce(NEW."ST_at_PR_spelas_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."ST_at_PR_spelas_ID"
    INTO
        _posit
    FROM
        ties."ST_at_PR_spelas_Posit" p
    WHERE
        p."ST_ID_at" = NEW."ST_ID_at"
    AND
        p."PR_ID_spelas" = NEW."PR_ID_spelas"
    AND
        p."ST_at_PR_spelas_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."ST_at_PR_spelas_Annex" a
        WHERE
            a."ST_at_PR_spelas_ID" = _posit
        AND
            a."ST_at_PR_spelas_Positor" = _positor
        AND
            a."ST_at_PR_spelas_PositedAt" = _positing
        AND
            a."ST_at_PR_spelas_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_at_PR_spelas for: %', concat_ws(', ',
            NEW."ST_ID_at",
            NEW."PR_ID_spelas",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."ST_at_PR_spelas_Annex" a
        WHERE
            a."ST_at_PR_spelas_ID" = _posit
        AND
            a."ST_at_PR_spelas_Positor" = _positor
        AND
            a."ST_at_PR_spelas_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := ties."he_ST_at_PR_spelas"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."ST_at_PR_spelas_Annex" (
            "Metadata_ST_at_PR_spelas",
            "ST_at_PR_spelas_ID",
            "ST_at_PR_spelas_Positor",
            "ST_at_PR_spelas_PositedAt",
            "ST_at_PR_spelas_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_at_PR_spelas", 0),
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."ST_at_PR_spelas_Posit" (
            "ST_ID_at",
            "PR_ID_spelas",
            "ST_at_PR_spelas_ChangedAt"
        )
        VALUES (
            NEW."ST_ID_at",
            NEW."PR_ID_spelas",
            _changing
        )
        RETURNING "ST_at_PR_spelas_ID" INTO _posit;
    END IF;
    INSERT INTO ties."ST_at_PR_spelas_Annex" (
        "Metadata_ST_at_PR_spelas",
        "ST_at_PR_spelas_ID",
        "ST_at_PR_spelas_Positor",
        "ST_at_PR_spelas_PositedAt",
        "ST_at_PR_spelas_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_ST_at_PR_spelas", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_at_PR_spelas" ON ties."ST_at_PR_spelas";
CREATE TRIGGER "it_ST_at_PR_spelas"
INSTEAD OF INSERT ON ties."ST_at_PR_spelas"
FOR EACH ROW EXECUTE FUNCTION ties."it_ST_at_PR_spelas"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_spelas instead of INSERT trigger on lST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lST_at_PR_spelas"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."ST_at_PR_spelas" (
        "Metadata_ST_at_PR_spelas",
        "ST_ID_at",
        "PR_ID_spelas",
        "ST_at_PR_spelas_ChangedAt",
        "ST_at_PR_spelas_Positor",
        "ST_at_PR_spelas_PositedAt",
        "ST_at_PR_spelas_Reliability"
    )
    VALUES (
        NEW."Metadata_ST_at_PR_spelas",
        NEW."ST_ID_at",
        NEW."PR_ID_spelas",
        coalesce(NEW."ST_at_PR_spelas_ChangedAt", _now),
        coalesce(NEW."ST_at_PR_spelas_Positor", NEW."Positor", 0),
        coalesce(NEW."ST_at_PR_spelas_PositedAt", _now),
        coalesce(NEW."ST_at_PR_spelas_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lST_at_PR_spelas" ON ties."lST_at_PR_spelas";
CREATE TRIGGER "it_lST_at_PR_spelas"
INSTEAD OF INSERT ON ties."lST_at_PR_spelas"
FOR EACH ROW EXECUTE FUNCTION ties."it_lST_at_PR_spelas"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_at_PR_spelas instead of DELETE trigger on lST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lST_at_PR_spelas"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."ST_at_PR_spelas" (
        "Metadata_ST_at_PR_spelas",
        "ST_ID_at",
        "PR_ID_spelas",
        "ST_at_PR_spelas_ChangedAt",
        "ST_at_PR_spelas_Positor",
        "ST_at_PR_spelas_PositedAt",
        "ST_at_PR_spelas_Reliability"
    )
    VALUES (
        OLD."Metadata_ST_at_PR_spelas",
        OLD."ST_ID_at",
        OLD."PR_ID_spelas",
        OLD."ST_at_PR_spelas_ChangedAt",
        coalesce(OLD."ST_at_PR_spelas_Positor", OLD."Positor", 0),
        _now,
        0
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lST_at_PR_spelas" ON ties."lST_at_PR_spelas";
CREATE TRIGGER "dt_lST_at_PR_spelas"
INSTEAD OF DELETE ON ties."lST_at_PR_spelas"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lST_at_PR_spelas"();
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_förälder_AC_barn_PAT_har is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."he_AC_förälder_AC_barn_PAT_har"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."AC_förälder_AC_barn_PAT_har_Reliability"
    FROM
        ties."AC_förälder_AC_barn_PAT_har_Annex" a
    WHERE
        a."AC_förälder_AC_barn_PAT_har_ID" = _id
    AND
        a."AC_förälder_AC_barn_PAT_har_Positor" = _positor
    AND
        a."AC_förälder_AC_barn_PAT_har_PositedAt" <= _positing
    ORDER BY
        a."AC_förälder_AC_barn_PAT_har_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_förälder_AC_barn_PAT_har tells whether a posit is in effect for a positor at a positing time: it holds an assertion of it, positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_AC_förälder_AC_barn_PAT_har"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT coalesce(ties."he_AC_förälder_AC_barn_PAT_har"(_id, _positor, _positing), 0) <> 0
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_förälder_AC_barn_PAT_har instead of INSERT trigger on AC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_förälder_AC_barn_PAT_har"()
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
    _positor := coalesce(NEW."AC_förälder_AC_barn_PAT_har_Positor", 0);
    _positing := coalesce(NEW."AC_förälder_AC_barn_PAT_har_PositedAt", _now);
    _reliability := coalesce(NEW."AC_förälder_AC_barn_PAT_har_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."AC_förälder_AC_barn_PAT_har_ID"
    INTO
        _posit
    FROM
        ties."AC_förälder_AC_barn_PAT_har_Posit" p
    WHERE
        p."AC_ID_förälder" = NEW."AC_ID_förälder"
    AND
        p."AC_ID_barn" = NEW."AC_ID_barn"
    AND
        p."PAT_ID_har" = NEW."PAT_ID_har"
    AND
        true
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_förälder_AC_barn_PAT_har_Annex" a
        WHERE
            a."AC_förälder_AC_barn_PAT_har_ID" = _posit
        AND
            a."AC_förälder_AC_barn_PAT_har_Positor" = _positor
        AND
            a."AC_förälder_AC_barn_PAT_har_PositedAt" = _positing
        AND
            a."AC_förälder_AC_barn_PAT_har_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_förälder_AC_barn_PAT_har for: %', concat_ws(', ',
            NEW."AC_ID_förälder",
            NEW."AC_ID_barn",
            NEW."PAT_ID_har",
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_förälder_AC_barn_PAT_har_Annex" a
        WHERE
            a."AC_förälder_AC_barn_PAT_har_ID" = _posit
        AND
            a."AC_förälder_AC_barn_PAT_har_Positor" = _positor
        AND
            a."AC_förälder_AC_barn_PAT_har_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := ties."he_AC_förälder_AC_barn_PAT_har"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."AC_förälder_AC_barn_PAT_har_Annex" (
            "Metadata_AC_förälder_AC_barn_PAT_har",
            "AC_förälder_AC_barn_PAT_har_ID",
            "AC_förälder_AC_barn_PAT_har_Positor",
            "AC_förälder_AC_barn_PAT_har_PositedAt",
            "AC_förälder_AC_barn_PAT_har_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_förälder_AC_barn_PAT_har", 0),
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."AC_förälder_AC_barn_PAT_har_Posit" (
            "AC_ID_förälder",
            "AC_ID_barn",
            "PAT_ID_har",
            "AC_förälder_AC_barn_PAT_har_ID"
        )
        VALUES (
            NEW."AC_ID_förälder",
            NEW."AC_ID_barn",
            NEW."PAT_ID_har",
            DEFAULT
        )
        RETURNING "AC_förälder_AC_barn_PAT_har_ID" INTO _posit;
    END IF;
    INSERT INTO ties."AC_förälder_AC_barn_PAT_har_Annex" (
        "Metadata_AC_förälder_AC_barn_PAT_har",
        "AC_förälder_AC_barn_PAT_har_ID",
        "AC_förälder_AC_barn_PAT_har_Positor",
        "AC_förälder_AC_barn_PAT_har_PositedAt",
        "AC_förälder_AC_barn_PAT_har_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_förälder_AC_barn_PAT_har", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_förälder_AC_barn_PAT_har" ON ties."AC_förälder_AC_barn_PAT_har";
CREATE TRIGGER "it_AC_förälder_AC_barn_PAT_har"
INSTEAD OF INSERT ON ties."AC_förälder_AC_barn_PAT_har"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_förälder_AC_barn_PAT_har"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_förälder_AC_barn_PAT_har instead of INSERT trigger on lAC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_förälder_AC_barn_PAT_har"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."AC_förälder_AC_barn_PAT_har" (
        "Metadata_AC_förälder_AC_barn_PAT_har",
        "AC_ID_förälder",
        "AC_ID_barn",
        "PAT_ID_har",
        "AC_förälder_AC_barn_PAT_har_Positor",
        "AC_förälder_AC_barn_PAT_har_PositedAt",
        "AC_förälder_AC_barn_PAT_har_Reliability"
    )
    VALUES (
        NEW."Metadata_AC_förälder_AC_barn_PAT_har",
        NEW."AC_ID_förälder",
        NEW."AC_ID_barn",
        coalesce(NEW."PAT_ID_har", (
            SELECT
                k."PAT_ID"
            FROM
                knots."PAT_Föräldratyp" k
            WHERE
                k."PAT_Föräldratyp" = NEW."har_PAT_Föräldratyp"
            LIMIT 1
        )),
        coalesce(NEW."AC_förälder_AC_barn_PAT_har_Positor", NEW."Positor", 0),
        coalesce(NEW."AC_förälder_AC_barn_PAT_har_PositedAt", _now),
        coalesce(NEW."AC_förälder_AC_barn_PAT_har_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lAC_förälder_AC_barn_PAT_har" ON ties."lAC_förälder_AC_barn_PAT_har";
CREATE TRIGGER "it_lAC_förälder_AC_barn_PAT_har"
INSTEAD OF INSERT ON ties."lAC_förälder_AC_barn_PAT_har"
FOR EACH ROW EXECUTE FUNCTION ties."it_lAC_förälder_AC_barn_PAT_har"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_förälder_AC_barn_PAT_har instead of DELETE trigger on lAC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lAC_förälder_AC_barn_PAT_har"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."AC_förälder_AC_barn_PAT_har" (
        "Metadata_AC_förälder_AC_barn_PAT_har",
        "AC_ID_förälder",
        "AC_ID_barn",
        "PAT_ID_har",
        "AC_förälder_AC_barn_PAT_har_Positor",
        "AC_förälder_AC_barn_PAT_har_PositedAt",
        "AC_förälder_AC_barn_PAT_har_Reliability"
    )
    VALUES (
        OLD."Metadata_AC_förälder_AC_barn_PAT_har",
        OLD."AC_ID_förälder",
        OLD."AC_ID_barn",
        OLD."PAT_ID_har",
        coalesce(OLD."AC_förälder_AC_barn_PAT_har_Positor", OLD."Positor", 0),
        _now,
        0
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_förälder_AC_barn_PAT_har" ON ties."lAC_förälder_AC_barn_PAT_har";
CREATE TRIGGER "dt_lAC_förälder_AC_barn_PAT_har"
INSTEAD OF DELETE ON ties."lAC_förälder_AC_barn_PAT_har"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_förälder_AC_barn_PAT_har"();
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_innehåll_ST_plats_EV_of is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."he_PR_innehåll_ST_plats_EV_of"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS decimal(5,2)
AS
$$
    SELECT
        a."PR_innehåll_ST_plats_EV_of_Reliability"
    FROM
        ties."PR_innehåll_ST_plats_EV_of_Annex" a
    WHERE
        a."PR_innehåll_ST_plats_EV_of_ID" = _id
    AND
        a."PR_innehåll_ST_plats_EV_of_Positor" = _positor
    AND
        a."PR_innehåll_ST_plats_EV_of_PositedAt" <= _positing
    ORDER BY
        a."PR_innehåll_ST_plats_EV_of_PositedAt" DESC
    LIMIT 1
$$ LANGUAGE sql STABLE;
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_PR_innehåll_ST_plats_EV_of tells whether a posit is in effect for a positor at a positing time: it holds an assertion of it, positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_PR_innehåll_ST_plats_EV_of"(
    _id integer,
    _positor smallint,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT coalesce(ties."he_PR_innehåll_ST_plats_EV_of"(_id, _positor, _positing), 0) <> 0
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_innehåll_ST_plats_EV_of instead of INSERT trigger on PR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_PR_innehåll_ST_plats_EV_of"()
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
    _positor := coalesce(NEW."PR_innehåll_ST_plats_EV_of_Positor", 0);
    _positing := coalesce(NEW."PR_innehåll_ST_plats_EV_of_PositedAt", _now);
    _reliability := coalesce(NEW."PR_innehåll_ST_plats_EV_of_Reliability", 1);
    _changing := coalesce(NEW."PR_innehåll_ST_plats_EV_of_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."PR_innehåll_ST_plats_EV_of_ID"
    INTO
        _posit
    FROM
        ties."PR_innehåll_ST_plats_EV_of_Posit" p
    WHERE
        p."PR_ID_innehåll" = NEW."PR_ID_innehåll"
    AND
        p."ST_ID_plats" = NEW."ST_ID_plats"
    AND
        p."EV_ID_of" = NEW."EV_ID_of"
    AND
        p."PR_innehåll_ST_plats_EV_of_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."PR_innehåll_ST_plats_EV_of_Annex" a
        WHERE
            a."PR_innehåll_ST_plats_EV_of_ID" = _posit
        AND
            a."PR_innehåll_ST_plats_EV_of_Positor" = _positor
        AND
            a."PR_innehåll_ST_plats_EV_of_PositedAt" = _positing
        AND
            a."PR_innehåll_ST_plats_EV_of_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_innehåll_ST_plats_EV_of for: %', concat_ws(', ',
            NEW."PR_ID_innehåll",
            NEW."ST_ID_plats",
            NEW."EV_ID_of",
            _changing,
            _positor, _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."PR_innehåll_ST_plats_EV_of_Annex" a
        WHERE
            a."PR_innehåll_ST_plats_EV_of_ID" = _posit
        AND
            a."PR_innehåll_ST_plats_EV_of_Positor" = _positor
        AND
            a."PR_innehåll_ST_plats_EV_of_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- what the positor holds of the posit
    IF _posit IS NOT NULL THEN
        _held := ties."he_PR_innehåll_ST_plats_EV_of"(_posit, _positor, _positing);
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF coalesce(_held, 0) = 0 THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."PR_innehåll_ST_plats_EV_of_Annex" (
            "Metadata_PR_innehåll_ST_plats_EV_of",
            "PR_innehåll_ST_plats_EV_of_ID",
            "PR_innehåll_ST_plats_EV_of_Positor",
            "PR_innehåll_ST_plats_EV_of_PositedAt",
            "PR_innehåll_ST_plats_EV_of_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_innehåll_ST_plats_EV_of", 0),
            _posit,
            _positor,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."PR_innehåll_ST_plats_EV_of_Posit" (
            "PR_ID_innehåll",
            "ST_ID_plats",
            "EV_ID_of",
            "PR_innehåll_ST_plats_EV_of_ChangedAt"
        )
        VALUES (
            NEW."PR_ID_innehåll",
            NEW."ST_ID_plats",
            NEW."EV_ID_of",
            _changing
        )
        RETURNING "PR_innehåll_ST_plats_EV_of_ID" INTO _posit;
    END IF;
    INSERT INTO ties."PR_innehåll_ST_plats_EV_of_Annex" (
        "Metadata_PR_innehåll_ST_plats_EV_of",
        "PR_innehåll_ST_plats_EV_of_ID",
        "PR_innehåll_ST_plats_EV_of_Positor",
        "PR_innehåll_ST_plats_EV_of_PositedAt",
        "PR_innehåll_ST_plats_EV_of_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_PR_innehåll_ST_plats_EV_of", 0),
        _posit,
        _positor,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_PR_innehåll_ST_plats_EV_of" ON ties."PR_innehåll_ST_plats_EV_of";
CREATE TRIGGER "it_PR_innehåll_ST_plats_EV_of"
INSTEAD OF INSERT ON ties."PR_innehåll_ST_plats_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."it_PR_innehåll_ST_plats_EV_of"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_innehåll_ST_plats_EV_of instead of INSERT trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lPR_innehåll_ST_plats_EV_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."PR_innehåll_ST_plats_EV_of" (
        "Metadata_PR_innehåll_ST_plats_EV_of",
        "PR_ID_innehåll",
        "ST_ID_plats",
        "EV_ID_of",
        "PR_innehåll_ST_plats_EV_of_ChangedAt",
        "PR_innehåll_ST_plats_EV_of_Positor",
        "PR_innehåll_ST_plats_EV_of_PositedAt",
        "PR_innehåll_ST_plats_EV_of_Reliability"
    )
    VALUES (
        NEW."Metadata_PR_innehåll_ST_plats_EV_of",
        NEW."PR_ID_innehåll",
        NEW."ST_ID_plats",
        NEW."EV_ID_of",
        coalesce(NEW."PR_innehåll_ST_plats_EV_of_ChangedAt", _now),
        coalesce(NEW."PR_innehåll_ST_plats_EV_of_Positor", NEW."Positor", 0),
        coalesce(NEW."PR_innehåll_ST_plats_EV_of_PositedAt", _now),
        coalesce(NEW."PR_innehåll_ST_plats_EV_of_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lPR_innehåll_ST_plats_EV_of" ON ties."lPR_innehåll_ST_plats_EV_of";
CREATE TRIGGER "it_lPR_innehåll_ST_plats_EV_of"
INSTEAD OF INSERT ON ties."lPR_innehåll_ST_plats_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."it_lPR_innehåll_ST_plats_EV_of"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_innehåll_ST_plats_EV_of instead of UPDATE trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ut_lPR_innehåll_ST_plats_EV_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _positor smallint;
BEGIN
    _positor := coalesce(CASE
        WHEN NEW."PR_innehåll_ST_plats_EV_of_Positor" IS DISTINCT FROM OLD."PR_innehåll_ST_plats_EV_of_Positor" THEN NEW."PR_innehåll_ST_plats_EV_of_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."PR_innehåll_ST_plats_EV_of_PositedAt" IS DISTINCT FROM OLD."PR_innehåll_ST_plats_EV_of_PositedAt" THEN NEW."PR_innehåll_ST_plats_EV_of_PositedAt"
        ELSE _now
    END;
    IF
        NEW."PR_ID_innehåll" IS DISTINCT FROM OLD."PR_ID_innehåll" OR
        NEW."ST_ID_plats" IS DISTINCT FROM OLD."ST_ID_plats" OR
        NEW."EV_ID_of" IS DISTINCT FROM OLD."EV_ID_of" OR
        NEW."PR_innehåll_ST_plats_EV_of_ChangedAt" IS DISTINCT FROM OLD."PR_innehåll_ST_plats_EV_of_ChangedAt" OR
        NEW."PR_innehåll_ST_plats_EV_of_PositedAt" IS DISTINCT FROM OLD."PR_innehåll_ST_plats_EV_of_PositedAt" OR
        NEW."PR_innehåll_ST_plats_EV_of_Reliability" IS DISTINCT FROM OLD."PR_innehåll_ST_plats_EV_of_Reliability"
    THEN
        IF
            NEW."PR_ID_innehåll" IS NOT NULL
        AND
            NEW."ST_ID_plats" IS NOT NULL
        AND
            NEW."EV_ID_of" IS NOT NULL
        THEN
            INSERT INTO ties."PR_innehåll_ST_plats_EV_of" (
                "Metadata_PR_innehåll_ST_plats_EV_of",
                "PR_ID_innehåll",
                "ST_ID_plats",
                "EV_ID_of",
                "PR_innehåll_ST_plats_EV_of_ChangedAt",
                "PR_innehåll_ST_plats_EV_of_Positor",
                "PR_innehåll_ST_plats_EV_of_PositedAt",
                "PR_innehåll_ST_plats_EV_of_Reliability"
            )
            VALUES (
                NEW."Metadata_PR_innehåll_ST_plats_EV_of",
                NEW."PR_ID_innehåll",
                NEW."ST_ID_plats",
                NEW."EV_ID_of",
                -- the shown version asserted again keeps its changing time, as does one that is given
                CASE
                    WHEN NEW."PR_innehåll_ST_plats_EV_of_ChangedAt" IS DISTINCT FROM OLD."PR_innehåll_ST_plats_EV_of_ChangedAt" THEN NEW."PR_innehåll_ST_plats_EV_of_ChangedAt"
                    WHEN
                        NEW."PR_ID_innehåll" = OLD."PR_ID_innehåll"
                    AND
                        NEW."ST_ID_plats" = OLD."ST_ID_plats"
                    AND
                        NEW."EV_ID_of" = OLD."EV_ID_of"
                    THEN NEW."PR_innehåll_ST_plats_EV_of_ChangedAt"
                    ELSE _now
                END,
                _positor,
                _positing,
                coalesce(NEW."PR_innehåll_ST_plats_EV_of_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO ties."PR_innehåll_ST_plats_EV_of" (
                "Metadata_PR_innehåll_ST_plats_EV_of",
                "PR_ID_innehåll",
                "ST_ID_plats",
                "EV_ID_of",
                "PR_innehåll_ST_plats_EV_of_ChangedAt",
                "PR_innehåll_ST_plats_EV_of_Positor",
                "PR_innehåll_ST_plats_EV_of_PositedAt",
                "PR_innehåll_ST_plats_EV_of_Reliability"
            )
            VALUES (
                NEW."Metadata_PR_innehåll_ST_plats_EV_of",
                OLD."PR_ID_innehåll",
                OLD."ST_ID_plats",
                OLD."EV_ID_of",
                OLD."PR_innehåll_ST_plats_EV_of_ChangedAt",
                _positor,
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lPR_innehåll_ST_plats_EV_of" ON ties."lPR_innehåll_ST_plats_EV_of";
CREATE TRIGGER "ut_lPR_innehåll_ST_plats_EV_of"
INSTEAD OF UPDATE ON ties."lPR_innehåll_ST_plats_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."ut_lPR_innehåll_ST_plats_EV_of"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_innehåll_ST_plats_EV_of instead of DELETE trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lPR_innehåll_ST_plats_EV_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."PR_innehåll_ST_plats_EV_of" (
        "Metadata_PR_innehåll_ST_plats_EV_of",
        "PR_ID_innehåll",
        "ST_ID_plats",
        "EV_ID_of",
        "PR_innehåll_ST_plats_EV_of_ChangedAt",
        "PR_innehåll_ST_plats_EV_of_Positor",
        "PR_innehåll_ST_plats_EV_of_PositedAt",
        "PR_innehåll_ST_plats_EV_of_Reliability"
    )
    VALUES (
        OLD."Metadata_PR_innehåll_ST_plats_EV_of",
        OLD."PR_ID_innehåll",
        OLD."ST_ID_plats",
        OLD."EV_ID_of",
        OLD."PR_innehåll_ST_plats_EV_of_ChangedAt",
        coalesce(OLD."PR_innehåll_ST_plats_EV_of_Positor", OLD."Positor", 0),
        _now,
        0
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lPR_innehåll_ST_plats_EV_of" ON ties."lPR_innehåll_ST_plats_EV_of";
CREATE TRIGGER "dt_lPR_innehåll_ST_plats_EV_of"
INSTEAD OF DELETE ON ties."lPR_innehåll_ST_plats_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lPR_innehåll_ST_plats_EV_of"();
