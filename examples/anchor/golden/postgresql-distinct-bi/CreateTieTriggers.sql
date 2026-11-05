-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled and latest views make them behave like tables.
-- The assembled view has an 'instead of' trigger for insert, which keeps the posit and annex tables. The latest view has
-- three: insert, update, and delete. They propagate such operations to the assembled view in a consistent way. Default
-- values are used for some columns if not provided by the corresponding SQL statements: the changing and positing times
-- are now, the reliability is 1.
--
-- The rules are the ones of the attributes (see the attribute triggers). A tie that has identifiers and other roles, which
-- are its values, is decisive about the values of the identifiers (at a changing time): an assertion of other values retracts,
-- at its own positing time, the posit that is in effect, which is a correction.
--
-- For idempotent ties, only changes that represent values different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- PostgreSQL runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_partner_AC_with_ONG_currently tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_AC_partner_AC_with_ONG_currently"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."AC_partner_AC_with_ONG_currently_Reliability" = 1
            FROM
                ties."AC_partner_AC_with_ONG_currently_Annex" a
            WHERE
                a."AC_partner_AC_with_ONG_currently_ID" = _id
            AND
                a."AC_partner_AC_with_ONG_currently_PositedAt" <= _positing
            ORDER BY
                a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
            LIMIT 1
        ), false)
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
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_partner_AC_with_ONG_currently_Annex" a
        WHERE
            a."AC_partner_AC_with_ONG_currently_ID" = _posit
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
            _positing);
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
            a."AC_partner_AC_with_ONG_currently_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT ties."ie_AC_partner_AC_with_ONG_currently"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."AC_partner_AC_with_ONG_currently_Annex" (
            "Metadata_AC_partner_AC_with_ONG_currently",
            "AC_partner_AC_with_ONG_currently_ID",
            "AC_partner_AC_with_ONG_currently_PositedAt",
            "AC_partner_AC_with_ONG_currently_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_partner_AC_with_ONG_currently", 0),
            _posit,
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
        "AC_partner_AC_with_ONG_currently_PositedAt",
        "AC_partner_AC_with_ONG_currently_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_partner_AC_with_ONG_currently", 0),
        _posit,
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
                knots."ONG_Ongoing" k
            WHERE
                k."ONG_Ongoing" = NEW."currently_ONG_Ongoing"
            LIMIT 1
        )),
        coalesce(NEW."AC_partner_AC_with_ONG_currently_ChangedAt", _now),
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
    _ONG_currently smallint;
BEGIN
    _ONG_currently := NEW."ONG_ID_currently";
    IF NEW."currently_ONG_Ongoing" IS DISTINCT FROM OLD."currently_ONG_Ongoing" AND NEW."ONG_ID_currently" IS NOT DISTINCT FROM OLD."ONG_ID_currently" THEN
        _ONG_currently := NULL;
        IF NEW."currently_ONG_Ongoing" IS NOT NULL THEN
            SELECT
                k."ONG_ID"
            INTO
                _ONG_currently
            FROM
                knots."ONG_Ongoing" k
            WHERE
                k."ONG_Ongoing" = NEW."currently_ONG_Ongoing"
            LIMIT 1;
        END IF;
    END IF;
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
                "AC_partner_AC_with_ONG_currently_PositedAt",
                "AC_partner_AC_with_ONG_currently_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_partner_AC_with_ONG_currently",
                OLD."AC_ID_partner",
                OLD."AC_ID_with",
                OLD."ONG_ID_currently",
                OLD."AC_partner_AC_with_ONG_currently_ChangedAt",
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
    INSERT INTO ties."AC_partner_AC_with_ONG_currently_Annex" (
        "Metadata_AC_partner_AC_with_ONG_currently",
        "AC_partner_AC_with_ONG_currently_ID",
        "AC_partner_AC_with_ONG_currently_PositedAt",
        "AC_partner_AC_with_ONG_currently_Reliability"
    )
    SELECT
        OLD."Metadata_AC_partner_AC_with_ONG_currently",
        OLD."AC_partner_AC_with_ONG_currently_ID",
        _now,
        0
    WHERE
        OLD."AC_partner_AC_with_ONG_currently_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_partner_AC_with_ONG_currently" ON ties."lAC_partner_AC_with_ONG_currently";
CREATE TRIGGER "dt_lAC_partner_AC_with_ONG_currently"
INSTEAD OF DELETE ON ties."lAC_partner_AC_with_ONG_currently"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_partner_AC_with_ONG_currently"();
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_subset_PN_of tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_AC_subset_PN_of"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."AC_subset_PN_of_Reliability" = 1
            FROM
                ties."AC_subset_PN_of_Annex" a
            WHERE
                a."AC_subset_PN_of_ID" = _id
            AND
                a."AC_subset_PN_of_PositedAt" <= _positing
            ORDER BY
                a."AC_subset_PN_of_PositedAt" DESC
            LIMIT 1
        ), false)
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
    _positing timestamp;
    _reliability decimal(5,2);
    _posit integer;
    _other integer;
    _following integer;
BEGIN
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
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_subset_PN_of_Annex" a
        WHERE
            a."AC_subset_PN_of_ID" = _posit
        AND
            a."AC_subset_PN_of_PositedAt" = _positing
        AND
            a."AC_subset_PN_of_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_subset_PN_of for: %', concat_ws(', ',
            NEW."AC_ID_subset",
            NEW."PN_ID_of",
            _positing);
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
            a."AC_subset_PN_of_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT ties."ie_AC_subset_PN_of"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."AC_subset_PN_of_Annex" (
            "Metadata_AC_subset_PN_of",
            "AC_subset_PN_of_ID",
            "AC_subset_PN_of_PositedAt",
            "AC_subset_PN_of_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_subset_PN_of", 0),
            _posit,
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
        "AC_subset_PN_of_PositedAt",
        "AC_subset_PN_of_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_subset_PN_of", 0),
        _posit,
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
        "AC_subset_PN_of_PositedAt",
        "AC_subset_PN_of_Reliability"
    )
    VALUES (
        NEW."Metadata_AC_subset_PN_of",
        NEW."AC_ID_subset",
        NEW."PN_ID_of",
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
BEGIN
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
                "AC_subset_PN_of_PositedAt",
                "AC_subset_PN_of_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_subset_PN_of",
                NEW."AC_ID_subset",
                NEW."PN_ID_of",
                _positing,
                coalesce(NEW."AC_subset_PN_of_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO ties."AC_subset_PN_of" (
                "Metadata_AC_subset_PN_of",
                "AC_ID_subset",
                "PN_ID_of",
                "AC_subset_PN_of_PositedAt",
                "AC_subset_PN_of_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_subset_PN_of",
                OLD."AC_ID_subset",
                OLD."PN_ID_of",
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
    INSERT INTO ties."AC_subset_PN_of_Annex" (
        "Metadata_AC_subset_PN_of",
        "AC_subset_PN_of_ID",
        "AC_subset_PN_of_PositedAt",
        "AC_subset_PN_of_Reliability"
    )
    SELECT
        OLD."Metadata_AC_subset_PN_of",
        OLD."AC_subset_PN_of_ID",
        _now,
        0
    WHERE
        OLD."AC_subset_PN_of_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_subset_PN_of" ON ties."lAC_subset_PN_of";
CREATE TRIGGER "dt_lAC_subset_PN_of"
INSTEAD OF DELETE ON ties."lAC_subset_PN_of"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_subset_PN_of"();
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_EV_in_AC_wasCast tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_EV_in_AC_wasCast"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."EV_in_AC_wasCast_Reliability" = 1
            FROM
                ties."EV_in_AC_wasCast_Annex" a
            WHERE
                a."EV_in_AC_wasCast_ID" = _id
            AND
                a."EV_in_AC_wasCast_PositedAt" <= _positing
            ORDER BY
                a."EV_in_AC_wasCast_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_in_AC_wasCast instead of INSERT trigger on EV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_EV_in_AC_wasCast"()
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
    _positing := coalesce(NEW."EV_in_AC_wasCast_PositedAt", _now);
    _reliability := coalesce(NEW."EV_in_AC_wasCast_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."EV_in_AC_wasCast_ID"
    INTO
        _posit
    FROM
        ties."EV_in_AC_wasCast_Posit" p
    WHERE
        p."EV_ID_in" = NEW."EV_ID_in"
    AND
        p."AC_ID_wasCast" = NEW."AC_ID_wasCast"
    AND
        true
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."EV_in_AC_wasCast_Annex" a
        WHERE
            a."EV_in_AC_wasCast_ID" = _posit
        AND
            a."EV_in_AC_wasCast_PositedAt" = _positing
        AND
            a."EV_in_AC_wasCast_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_in_AC_wasCast for: %', concat_ws(', ',
            NEW."EV_ID_in",
            NEW."AC_ID_wasCast",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."EV_in_AC_wasCast_Annex" a
        WHERE
            a."EV_in_AC_wasCast_ID" = _posit
        AND
            a."EV_in_AC_wasCast_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT ties."ie_EV_in_AC_wasCast"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."EV_in_AC_wasCast_Annex" (
            "Metadata_EV_in_AC_wasCast",
            "EV_in_AC_wasCast_ID",
            "EV_in_AC_wasCast_PositedAt",
            "EV_in_AC_wasCast_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_in_AC_wasCast", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."EV_in_AC_wasCast_Posit" (
            "EV_ID_in",
            "AC_ID_wasCast",
            "EV_in_AC_wasCast_ID"
        )
        VALUES (
            NEW."EV_ID_in",
            NEW."AC_ID_wasCast",
            DEFAULT
        )
        RETURNING "EV_in_AC_wasCast_ID" INTO _posit;
    END IF;
    INSERT INTO ties."EV_in_AC_wasCast_Annex" (
        "Metadata_EV_in_AC_wasCast",
        "EV_in_AC_wasCast_ID",
        "EV_in_AC_wasCast_PositedAt",
        "EV_in_AC_wasCast_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_in_AC_wasCast", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_in_AC_wasCast" ON ties."EV_in_AC_wasCast";
CREATE TRIGGER "it_EV_in_AC_wasCast"
INSTEAD OF INSERT ON ties."EV_in_AC_wasCast"
FOR EACH ROW EXECUTE FUNCTION ties."it_EV_in_AC_wasCast"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_wasCast instead of INSERT trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lEV_in_AC_wasCast"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."EV_in_AC_wasCast" (
        "Metadata_EV_in_AC_wasCast",
        "EV_ID_in",
        "AC_ID_wasCast",
        "EV_in_AC_wasCast_PositedAt",
        "EV_in_AC_wasCast_Reliability"
    )
    VALUES (
        NEW."Metadata_EV_in_AC_wasCast",
        NEW."EV_ID_in",
        NEW."AC_ID_wasCast",
        coalesce(NEW."EV_in_AC_wasCast_PositedAt", _now),
        coalesce(NEW."EV_in_AC_wasCast_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lEV_in_AC_wasCast" ON ties."lEV_in_AC_wasCast";
CREATE TRIGGER "it_lEV_in_AC_wasCast"
INSTEAD OF INSERT ON ties."lEV_in_AC_wasCast"
FOR EACH ROW EXECUTE FUNCTION ties."it_lEV_in_AC_wasCast"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_in_AC_wasCast instead of DELETE trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lEV_in_AC_wasCast"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."EV_in_AC_wasCast_Annex" (
        "Metadata_EV_in_AC_wasCast",
        "EV_in_AC_wasCast_ID",
        "EV_in_AC_wasCast_PositedAt",
        "EV_in_AC_wasCast_Reliability"
    )
    SELECT
        OLD."Metadata_EV_in_AC_wasCast",
        OLD."EV_in_AC_wasCast_ID",
        _now,
        0
    WHERE
        OLD."EV_in_AC_wasCast_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lEV_in_AC_wasCast" ON ties."lEV_in_AC_wasCast";
CREATE TRIGGER "dt_lEV_in_AC_wasCast"
INSTEAD OF DELETE ON ties."lEV_in_AC_wasCast"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lEV_in_AC_wasCast"();
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_part_PR_in_RAT_got tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_AC_part_PR_in_RAT_got"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."AC_part_PR_in_RAT_got_Reliability" = 1
            FROM
                ties."AC_part_PR_in_RAT_got_Annex" a
            WHERE
                a."AC_part_PR_in_RAT_got_ID" = _id
            AND
                a."AC_part_PR_in_RAT_got_PositedAt" <= _positing
            ORDER BY
                a."AC_part_PR_in_RAT_got_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_part_PR_in_RAT_got instead of INSERT trigger on AC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_part_PR_in_RAT_got"()
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
    _positing := coalesce(NEW."AC_part_PR_in_RAT_got_PositedAt", _now);
    _reliability := coalesce(NEW."AC_part_PR_in_RAT_got_Reliability", 1);
    _changing := coalesce(NEW."AC_part_PR_in_RAT_got_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."AC_part_PR_in_RAT_got_ID"
    INTO
        _posit
    FROM
        ties."AC_part_PR_in_RAT_got_Posit" p
    WHERE
        p."AC_ID_part" = NEW."AC_ID_part"
    AND
        p."PR_ID_in" = NEW."PR_ID_in"
    AND
        p."RAT_ID_got" = NEW."RAT_ID_got"
    AND
        p."AC_part_PR_in_RAT_got_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_part_PR_in_RAT_got_Annex" a
        WHERE
            a."AC_part_PR_in_RAT_got_ID" = _posit
        AND
            a."AC_part_PR_in_RAT_got_PositedAt" = _positing
        AND
            a."AC_part_PR_in_RAT_got_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_part_PR_in_RAT_got for: %', concat_ws(', ',
            NEW."AC_ID_part",
            NEW."PR_ID_in",
            NEW."RAT_ID_got",
            _changing,
            _positing);
    END IF;
    -- other values for identifiers that already have values at that time, asserted at the positing time, are a contradiction
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_part_PR_in_RAT_got_Posit" p
        JOIN
            ties."AC_part_PR_in_RAT_got_Annex" a
        ON
            a."AC_part_PR_in_RAT_got_ID" = p."AC_part_PR_in_RAT_got_ID"
        WHERE
            p."AC_ID_part" = NEW."AC_ID_part"
        AND
            p."PR_ID_in" = NEW."PR_ID_in"
        AND
            p."AC_part_PR_in_RAT_got_ChangedAt" = _changing
        AND
            NOT (
                p."RAT_ID_got" = NEW."RAT_ID_got"
            )
        AND
            a."AC_part_PR_in_RAT_got_PositedAt" = _positing
        AND
            a."AC_part_PR_in_RAT_got_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_part_PR_in_RAT_got for: %', concat_ws(', ',
            NEW."AC_ID_part",
            NEW."PR_ID_in",
            NEW."RAT_ID_got",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_part_PR_in_RAT_got_Annex" a
        WHERE
            a."AC_part_PR_in_RAT_got_ID" = _posit
        AND
            a."AC_part_PR_in_RAT_got_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT ties."ie_AC_part_PR_in_RAT_got"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."AC_part_PR_in_RAT_got_Annex" (
            "Metadata_AC_part_PR_in_RAT_got",
            "AC_part_PR_in_RAT_got_ID",
            "AC_part_PR_in_RAT_got_PositedAt",
            "AC_part_PR_in_RAT_got_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_part_PR_in_RAT_got", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same identifiers (and changing time), when that has
    -- other values: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."AC_part_PR_in_RAT_got_ID"
        FROM
            ties."AC_part_PR_in_RAT_got_Posit" p
        WHERE
            p."AC_ID_part" = NEW."AC_ID_part"
        AND
            p."PR_ID_in" = NEW."PR_ID_in"
        AND
            p."AC_part_PR_in_RAT_got_ChangedAt" = _changing
        AND
            NOT (
                p."RAT_ID_got" = NEW."RAT_ID_got"
            )
        AND
            ties."ie_AC_part_PR_in_RAT_got"(p."AC_part_PR_in_RAT_got_ID", _positing)
    LOOP
        INSERT INTO ties."AC_part_PR_in_RAT_got_Annex" (
            "Metadata_AC_part_PR_in_RAT_got",
            "AC_part_PR_in_RAT_got_ID",
            "AC_part_PR_in_RAT_got_PositedAt",
            "AC_part_PR_in_RAT_got_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_part_PR_in_RAT_got", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."AC_part_PR_in_RAT_got_Posit" (
            "AC_ID_part",
            "PR_ID_in",
            "RAT_ID_got",
            "AC_part_PR_in_RAT_got_ChangedAt"
        )
        VALUES (
            NEW."AC_ID_part",
            NEW."PR_ID_in",
            NEW."RAT_ID_got",
            _changing
        )
        RETURNING "AC_part_PR_in_RAT_got_ID" INTO _posit;
    END IF;
    INSERT INTO ties."AC_part_PR_in_RAT_got_Annex" (
        "Metadata_AC_part_PR_in_RAT_got",
        "AC_part_PR_in_RAT_got_ID",
        "AC_part_PR_in_RAT_got_PositedAt",
        "AC_part_PR_in_RAT_got_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_part_PR_in_RAT_got", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_part_PR_in_RAT_got" ON ties."AC_part_PR_in_RAT_got";
CREATE TRIGGER "it_AC_part_PR_in_RAT_got"
INSTEAD OF INSERT ON ties."AC_part_PR_in_RAT_got"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_part_PR_in_RAT_got"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_part_PR_in_RAT_got instead of INSERT trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_part_PR_in_RAT_got"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."AC_part_PR_in_RAT_got" (
        "Metadata_AC_part_PR_in_RAT_got",
        "AC_ID_part",
        "PR_ID_in",
        "RAT_ID_got",
        "AC_part_PR_in_RAT_got_ChangedAt",
        "AC_part_PR_in_RAT_got_PositedAt",
        "AC_part_PR_in_RAT_got_Reliability"
    )
    VALUES (
        NEW."Metadata_AC_part_PR_in_RAT_got",
        NEW."AC_ID_part",
        NEW."PR_ID_in",
        coalesce(NEW."RAT_ID_got", (
            SELECT
                k."RAT_ID"
            FROM
                knots."RAT_Rating" k
            WHERE
                k."RAT_Rating" = NEW."got_RAT_Rating"
            LIMIT 1
        )),
        coalesce(NEW."AC_part_PR_in_RAT_got_ChangedAt", _now),
        coalesce(NEW."AC_part_PR_in_RAT_got_PositedAt", _now),
        coalesce(NEW."AC_part_PR_in_RAT_got_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lAC_part_PR_in_RAT_got" ON ties."lAC_part_PR_in_RAT_got";
CREATE TRIGGER "it_lAC_part_PR_in_RAT_got"
INSTEAD OF INSERT ON ties."lAC_part_PR_in_RAT_got"
FOR EACH ROW EXECUTE FUNCTION ties."it_lAC_part_PR_in_RAT_got"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_part_PR_in_RAT_got instead of UPDATE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ut_lAC_part_PR_in_RAT_got"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _RAT_got smallint;
BEGIN
    IF NEW."AC_ID_part" IS DISTINCT FROM OLD."AC_ID_part" THEN
        RAISE EXCEPTION 'The identity column AC_ID_part is not updatable.';
    END IF;
    IF NEW."PR_ID_in" IS DISTINCT FROM OLD."PR_ID_in" THEN
        RAISE EXCEPTION 'The identity column PR_ID_in is not updatable.';
    END IF;
    _RAT_got := NEW."RAT_ID_got";
    IF NEW."got_RAT_Rating" IS DISTINCT FROM OLD."got_RAT_Rating" AND NEW."RAT_ID_got" IS NOT DISTINCT FROM OLD."RAT_ID_got" THEN
        _RAT_got := NULL;
        IF NEW."got_RAT_Rating" IS NOT NULL THEN
            SELECT
                k."RAT_ID"
            INTO
                _RAT_got
            FROM
                knots."RAT_Rating" k
            WHERE
                k."RAT_Rating" = NEW."got_RAT_Rating"
            LIMIT 1;
        END IF;
    END IF;
    _positing := CASE
        WHEN NEW."AC_part_PR_in_RAT_got_PositedAt" IS DISTINCT FROM OLD."AC_part_PR_in_RAT_got_PositedAt" THEN NEW."AC_part_PR_in_RAT_got_PositedAt"
        ELSE _now
    END;
    IF
        NEW."AC_ID_part" IS DISTINCT FROM OLD."AC_ID_part" OR
        NEW."PR_ID_in" IS DISTINCT FROM OLD."PR_ID_in" OR
        _RAT_got IS DISTINCT FROM OLD."RAT_ID_got" OR
        NEW."AC_part_PR_in_RAT_got_ChangedAt" IS DISTINCT FROM OLD."AC_part_PR_in_RAT_got_ChangedAt" OR
        NEW."AC_part_PR_in_RAT_got_PositedAt" IS DISTINCT FROM OLD."AC_part_PR_in_RAT_got_PositedAt" OR
        NEW."AC_part_PR_in_RAT_got_Reliability" IS DISTINCT FROM OLD."AC_part_PR_in_RAT_got_Reliability"
    THEN
        IF
            NEW."AC_ID_part" IS NOT NULL
        AND
            NEW."PR_ID_in" IS NOT NULL
        AND
            _RAT_got IS NOT NULL
        THEN
            INSERT INTO ties."AC_part_PR_in_RAT_got" (
                "Metadata_AC_part_PR_in_RAT_got",
                "AC_ID_part",
                "PR_ID_in",
                "RAT_ID_got",
                "AC_part_PR_in_RAT_got_ChangedAt",
                "AC_part_PR_in_RAT_got_PositedAt",
                "AC_part_PR_in_RAT_got_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_part_PR_in_RAT_got",
                NEW."AC_ID_part",
                NEW."PR_ID_in",
                _RAT_got,
                -- the shown version asserted again keeps its changing time, as does one that is given
                CASE
                    WHEN NEW."AC_part_PR_in_RAT_got_ChangedAt" IS DISTINCT FROM OLD."AC_part_PR_in_RAT_got_ChangedAt" THEN NEW."AC_part_PR_in_RAT_got_ChangedAt"
                    WHEN
                        NEW."AC_ID_part" = OLD."AC_ID_part"
                    AND
                        NEW."PR_ID_in" = OLD."PR_ID_in"
                    AND
                        _RAT_got = OLD."RAT_ID_got"
                    THEN NEW."AC_part_PR_in_RAT_got_ChangedAt"
                    ELSE _now
                END,
                _positing,
                coalesce(NEW."AC_part_PR_in_RAT_got_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO ties."AC_part_PR_in_RAT_got" (
                "Metadata_AC_part_PR_in_RAT_got",
                "AC_ID_part",
                "PR_ID_in",
                "RAT_ID_got",
                "AC_part_PR_in_RAT_got_ChangedAt",
                "AC_part_PR_in_RAT_got_PositedAt",
                "AC_part_PR_in_RAT_got_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_part_PR_in_RAT_got",
                OLD."AC_ID_part",
                OLD."PR_ID_in",
                OLD."RAT_ID_got",
                OLD."AC_part_PR_in_RAT_got_ChangedAt",
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lAC_part_PR_in_RAT_got" ON ties."lAC_part_PR_in_RAT_got";
CREATE TRIGGER "ut_lAC_part_PR_in_RAT_got"
INSTEAD OF UPDATE ON ties."lAC_part_PR_in_RAT_got"
FOR EACH ROW EXECUTE FUNCTION ties."ut_lAC_part_PR_in_RAT_got"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_part_PR_in_RAT_got instead of DELETE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lAC_part_PR_in_RAT_got"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."AC_part_PR_in_RAT_got_Annex" (
        "Metadata_AC_part_PR_in_RAT_got",
        "AC_part_PR_in_RAT_got_ID",
        "AC_part_PR_in_RAT_got_PositedAt",
        "AC_part_PR_in_RAT_got_Reliability"
    )
    SELECT
        OLD."Metadata_AC_part_PR_in_RAT_got",
        OLD."AC_part_PR_in_RAT_got_ID",
        _now,
        0
    WHERE
        OLD."AC_part_PR_in_RAT_got_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_part_PR_in_RAT_got" ON ties."lAC_part_PR_in_RAT_got";
CREATE TRIGGER "dt_lAC_part_PR_in_RAT_got"
INSTEAD OF DELETE ON ties."lAC_part_PR_in_RAT_got"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_part_PR_in_RAT_got"();
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_ST_at_PR_isPlaying tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_ST_at_PR_isPlaying"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."ST_at_PR_isPlaying_Reliability" = 1
            FROM
                ties."ST_at_PR_isPlaying_Annex" a
            WHERE
                a."ST_at_PR_isPlaying_ID" = _id
            AND
                a."ST_at_PR_isPlaying_PositedAt" <= _positing
            ORDER BY
                a."ST_at_PR_isPlaying_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_at_PR_isPlaying instead of INSERT trigger on ST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_ST_at_PR_isPlaying"()
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
    _positing := coalesce(NEW."ST_at_PR_isPlaying_PositedAt", _now);
    _reliability := coalesce(NEW."ST_at_PR_isPlaying_Reliability", 1);
    _changing := coalesce(NEW."ST_at_PR_isPlaying_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."ST_at_PR_isPlaying_ID"
    INTO
        _posit
    FROM
        ties."ST_at_PR_isPlaying_Posit" p
    WHERE
        p."ST_ID_at" = NEW."ST_ID_at"
    AND
        p."PR_ID_isPlaying" = NEW."PR_ID_isPlaying"
    AND
        p."ST_at_PR_isPlaying_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."ST_at_PR_isPlaying_Annex" a
        WHERE
            a."ST_at_PR_isPlaying_ID" = _posit
        AND
            a."ST_at_PR_isPlaying_PositedAt" = _positing
        AND
            a."ST_at_PR_isPlaying_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_at_PR_isPlaying for: %', concat_ws(', ',
            NEW."ST_ID_at",
            NEW."PR_ID_isPlaying",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."ST_at_PR_isPlaying_Annex" a
        WHERE
            a."ST_at_PR_isPlaying_ID" = _posit
        AND
            a."ST_at_PR_isPlaying_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT ties."ie_ST_at_PR_isPlaying"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."ST_at_PR_isPlaying_Annex" (
            "Metadata_ST_at_PR_isPlaying",
            "ST_at_PR_isPlaying_ID",
            "ST_at_PR_isPlaying_PositedAt",
            "ST_at_PR_isPlaying_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_at_PR_isPlaying", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."ST_at_PR_isPlaying_Posit" (
            "ST_ID_at",
            "PR_ID_isPlaying",
            "ST_at_PR_isPlaying_ChangedAt"
        )
        VALUES (
            NEW."ST_ID_at",
            NEW."PR_ID_isPlaying",
            _changing
        )
        RETURNING "ST_at_PR_isPlaying_ID" INTO _posit;
    END IF;
    INSERT INTO ties."ST_at_PR_isPlaying_Annex" (
        "Metadata_ST_at_PR_isPlaying",
        "ST_at_PR_isPlaying_ID",
        "ST_at_PR_isPlaying_PositedAt",
        "ST_at_PR_isPlaying_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_ST_at_PR_isPlaying", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_at_PR_isPlaying" ON ties."ST_at_PR_isPlaying";
CREATE TRIGGER "it_ST_at_PR_isPlaying"
INSTEAD OF INSERT ON ties."ST_at_PR_isPlaying"
FOR EACH ROW EXECUTE FUNCTION ties."it_ST_at_PR_isPlaying"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_isPlaying instead of INSERT trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lST_at_PR_isPlaying"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."ST_at_PR_isPlaying" (
        "Metadata_ST_at_PR_isPlaying",
        "ST_ID_at",
        "PR_ID_isPlaying",
        "ST_at_PR_isPlaying_ChangedAt",
        "ST_at_PR_isPlaying_PositedAt",
        "ST_at_PR_isPlaying_Reliability"
    )
    VALUES (
        NEW."Metadata_ST_at_PR_isPlaying",
        NEW."ST_ID_at",
        NEW."PR_ID_isPlaying",
        coalesce(NEW."ST_at_PR_isPlaying_ChangedAt", _now),
        coalesce(NEW."ST_at_PR_isPlaying_PositedAt", _now),
        coalesce(NEW."ST_at_PR_isPlaying_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lST_at_PR_isPlaying" ON ties."lST_at_PR_isPlaying";
CREATE TRIGGER "it_lST_at_PR_isPlaying"
INSTEAD OF INSERT ON ties."lST_at_PR_isPlaying"
FOR EACH ROW EXECUTE FUNCTION ties."it_lST_at_PR_isPlaying"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_at_PR_isPlaying instead of DELETE trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lST_at_PR_isPlaying"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."ST_at_PR_isPlaying_Annex" (
        "Metadata_ST_at_PR_isPlaying",
        "ST_at_PR_isPlaying_ID",
        "ST_at_PR_isPlaying_PositedAt",
        "ST_at_PR_isPlaying_Reliability"
    )
    SELECT
        OLD."Metadata_ST_at_PR_isPlaying",
        OLD."ST_at_PR_isPlaying_ID",
        _now,
        0
    WHERE
        OLD."ST_at_PR_isPlaying_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lST_at_PR_isPlaying" ON ties."lST_at_PR_isPlaying";
CREATE TRIGGER "dt_lST_at_PR_isPlaying"
INSTEAD OF DELETE ON ties."lST_at_PR_isPlaying"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lST_at_PR_isPlaying"();
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_parent_AC_child_PAT_having tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_AC_parent_AC_child_PAT_having"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."AC_parent_AC_child_PAT_having_Reliability" = 1
            FROM
                ties."AC_parent_AC_child_PAT_having_Annex" a
            WHERE
                a."AC_parent_AC_child_PAT_having_ID" = _id
            AND
                a."AC_parent_AC_child_PAT_having_PositedAt" <= _positing
            ORDER BY
                a."AC_parent_AC_child_PAT_having_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_parent_AC_child_PAT_having instead of INSERT trigger on AC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_parent_AC_child_PAT_having"()
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
    _positing := coalesce(NEW."AC_parent_AC_child_PAT_having_PositedAt", _now);
    _reliability := coalesce(NEW."AC_parent_AC_child_PAT_having_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."AC_parent_AC_child_PAT_having_ID"
    INTO
        _posit
    FROM
        ties."AC_parent_AC_child_PAT_having_Posit" p
    WHERE
        p."AC_ID_parent" = NEW."AC_ID_parent"
    AND
        p."AC_ID_child" = NEW."AC_ID_child"
    AND
        p."PAT_ID_having" = NEW."PAT_ID_having"
    AND
        true
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_parent_AC_child_PAT_having_Annex" a
        WHERE
            a."AC_parent_AC_child_PAT_having_ID" = _posit
        AND
            a."AC_parent_AC_child_PAT_having_PositedAt" = _positing
        AND
            a."AC_parent_AC_child_PAT_having_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_parent_AC_child_PAT_having for: %', concat_ws(', ',
            NEW."AC_ID_parent",
            NEW."AC_ID_child",
            NEW."PAT_ID_having",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_parent_AC_child_PAT_having_Annex" a
        WHERE
            a."AC_parent_AC_child_PAT_having_ID" = _posit
        AND
            a."AC_parent_AC_child_PAT_having_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT ties."ie_AC_parent_AC_child_PAT_having"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."AC_parent_AC_child_PAT_having_Annex" (
            "Metadata_AC_parent_AC_child_PAT_having",
            "AC_parent_AC_child_PAT_having_ID",
            "AC_parent_AC_child_PAT_having_PositedAt",
            "AC_parent_AC_child_PAT_having_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_parent_AC_child_PAT_having", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."AC_parent_AC_child_PAT_having_Posit" (
            "AC_ID_parent",
            "AC_ID_child",
            "PAT_ID_having",
            "AC_parent_AC_child_PAT_having_ID"
        )
        VALUES (
            NEW."AC_ID_parent",
            NEW."AC_ID_child",
            NEW."PAT_ID_having",
            DEFAULT
        )
        RETURNING "AC_parent_AC_child_PAT_having_ID" INTO _posit;
    END IF;
    INSERT INTO ties."AC_parent_AC_child_PAT_having_Annex" (
        "Metadata_AC_parent_AC_child_PAT_having",
        "AC_parent_AC_child_PAT_having_ID",
        "AC_parent_AC_child_PAT_having_PositedAt",
        "AC_parent_AC_child_PAT_having_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_parent_AC_child_PAT_having", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_parent_AC_child_PAT_having" ON ties."AC_parent_AC_child_PAT_having";
CREATE TRIGGER "it_AC_parent_AC_child_PAT_having"
INSTEAD OF INSERT ON ties."AC_parent_AC_child_PAT_having"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_parent_AC_child_PAT_having"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_parent_AC_child_PAT_having instead of INSERT trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_parent_AC_child_PAT_having"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."AC_parent_AC_child_PAT_having" (
        "Metadata_AC_parent_AC_child_PAT_having",
        "AC_ID_parent",
        "AC_ID_child",
        "PAT_ID_having",
        "AC_parent_AC_child_PAT_having_PositedAt",
        "AC_parent_AC_child_PAT_having_Reliability"
    )
    VALUES (
        NEW."Metadata_AC_parent_AC_child_PAT_having",
        NEW."AC_ID_parent",
        NEW."AC_ID_child",
        coalesce(NEW."PAT_ID_having", (
            SELECT
                k."PAT_ID"
            FROM
                knots."PAT_ParentalType" k
            WHERE
                k."PAT_ParentalType" = NEW."having_PAT_ParentalType"
            LIMIT 1
        )),
        coalesce(NEW."AC_parent_AC_child_PAT_having_PositedAt", _now),
        coalesce(NEW."AC_parent_AC_child_PAT_having_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lAC_parent_AC_child_PAT_having" ON ties."lAC_parent_AC_child_PAT_having";
CREATE TRIGGER "it_lAC_parent_AC_child_PAT_having"
INSTEAD OF INSERT ON ties."lAC_parent_AC_child_PAT_having"
FOR EACH ROW EXECUTE FUNCTION ties."it_lAC_parent_AC_child_PAT_having"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_parent_AC_child_PAT_having instead of DELETE trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lAC_parent_AC_child_PAT_having"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."AC_parent_AC_child_PAT_having_Annex" (
        "Metadata_AC_parent_AC_child_PAT_having",
        "AC_parent_AC_child_PAT_having_ID",
        "AC_parent_AC_child_PAT_having_PositedAt",
        "AC_parent_AC_child_PAT_having_Reliability"
    )
    SELECT
        OLD."Metadata_AC_parent_AC_child_PAT_having",
        OLD."AC_parent_AC_child_PAT_having_ID",
        _now,
        0
    WHERE
        OLD."AC_parent_AC_child_PAT_having_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_parent_AC_child_PAT_having" ON ties."lAC_parent_AC_child_PAT_having";
CREATE TRIGGER "dt_lAC_parent_AC_child_PAT_having"
INSTEAD OF DELETE ON ties."lAC_parent_AC_child_PAT_having"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_parent_AC_child_PAT_having"();
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_PR_content_ST_location_EV_of tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_PR_content_ST_location_EV_of"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."PR_content_ST_location_EV_of_Reliability" = 1
            FROM
                ties."PR_content_ST_location_EV_of_Annex" a
            WHERE
                a."PR_content_ST_location_EV_of_ID" = _id
            AND
                a."PR_content_ST_location_EV_of_PositedAt" <= _positing
            ORDER BY
                a."PR_content_ST_location_EV_of_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_content_ST_location_EV_of instead of INSERT trigger on PR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_PR_content_ST_location_EV_of"()
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
    _positing := coalesce(NEW."PR_content_ST_location_EV_of_PositedAt", _now);
    _reliability := coalesce(NEW."PR_content_ST_location_EV_of_Reliability", 1);
    _changing := coalesce(NEW."PR_content_ST_location_EV_of_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."PR_content_ST_location_EV_of_ID"
    INTO
        _posit
    FROM
        ties."PR_content_ST_location_EV_of_Posit" p
    WHERE
        p."PR_ID_content" = NEW."PR_ID_content"
    AND
        p."ST_ID_location" = NEW."ST_ID_location"
    AND
        p."EV_ID_of" = NEW."EV_ID_of"
    AND
        p."PR_content_ST_location_EV_of_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."PR_content_ST_location_EV_of_Annex" a
        WHERE
            a."PR_content_ST_location_EV_of_ID" = _posit
        AND
            a."PR_content_ST_location_EV_of_PositedAt" = _positing
        AND
            a."PR_content_ST_location_EV_of_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_content_ST_location_EV_of for: %', concat_ws(', ',
            NEW."PR_ID_content",
            NEW."ST_ID_location",
            NEW."EV_ID_of",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."PR_content_ST_location_EV_of_Annex" a
        WHERE
            a."PR_content_ST_location_EV_of_ID" = _posit
        AND
            a."PR_content_ST_location_EV_of_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT ties."ie_PR_content_ST_location_EV_of"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."PR_content_ST_location_EV_of_Annex" (
            "Metadata_PR_content_ST_location_EV_of",
            "PR_content_ST_location_EV_of_ID",
            "PR_content_ST_location_EV_of_PositedAt",
            "PR_content_ST_location_EV_of_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_content_ST_location_EV_of", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."PR_content_ST_location_EV_of_Posit" (
            "PR_ID_content",
            "ST_ID_location",
            "EV_ID_of",
            "PR_content_ST_location_EV_of_ChangedAt"
        )
        VALUES (
            NEW."PR_ID_content",
            NEW."ST_ID_location",
            NEW."EV_ID_of",
            _changing
        )
        RETURNING "PR_content_ST_location_EV_of_ID" INTO _posit;
    END IF;
    INSERT INTO ties."PR_content_ST_location_EV_of_Annex" (
        "Metadata_PR_content_ST_location_EV_of",
        "PR_content_ST_location_EV_of_ID",
        "PR_content_ST_location_EV_of_PositedAt",
        "PR_content_ST_location_EV_of_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_PR_content_ST_location_EV_of", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_PR_content_ST_location_EV_of" ON ties."PR_content_ST_location_EV_of";
CREATE TRIGGER "it_PR_content_ST_location_EV_of"
INSTEAD OF INSERT ON ties."PR_content_ST_location_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."it_PR_content_ST_location_EV_of"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_content_ST_location_EV_of instead of INSERT trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lPR_content_ST_location_EV_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."PR_content_ST_location_EV_of" (
        "Metadata_PR_content_ST_location_EV_of",
        "PR_ID_content",
        "ST_ID_location",
        "EV_ID_of",
        "PR_content_ST_location_EV_of_ChangedAt",
        "PR_content_ST_location_EV_of_PositedAt",
        "PR_content_ST_location_EV_of_Reliability"
    )
    VALUES (
        NEW."Metadata_PR_content_ST_location_EV_of",
        NEW."PR_ID_content",
        NEW."ST_ID_location",
        NEW."EV_ID_of",
        coalesce(NEW."PR_content_ST_location_EV_of_ChangedAt", _now),
        coalesce(NEW."PR_content_ST_location_EV_of_PositedAt", _now),
        coalesce(NEW."PR_content_ST_location_EV_of_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lPR_content_ST_location_EV_of" ON ties."lPR_content_ST_location_EV_of";
CREATE TRIGGER "it_lPR_content_ST_location_EV_of"
INSTEAD OF INSERT ON ties."lPR_content_ST_location_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."it_lPR_content_ST_location_EV_of"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_content_ST_location_EV_of instead of UPDATE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ut_lPR_content_ST_location_EV_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
BEGIN
    _positing := CASE
        WHEN NEW."PR_content_ST_location_EV_of_PositedAt" IS DISTINCT FROM OLD."PR_content_ST_location_EV_of_PositedAt" THEN NEW."PR_content_ST_location_EV_of_PositedAt"
        ELSE _now
    END;
    IF
        NEW."PR_ID_content" IS DISTINCT FROM OLD."PR_ID_content" OR
        NEW."ST_ID_location" IS DISTINCT FROM OLD."ST_ID_location" OR
        NEW."EV_ID_of" IS DISTINCT FROM OLD."EV_ID_of" OR
        NEW."PR_content_ST_location_EV_of_ChangedAt" IS DISTINCT FROM OLD."PR_content_ST_location_EV_of_ChangedAt" OR
        NEW."PR_content_ST_location_EV_of_PositedAt" IS DISTINCT FROM OLD."PR_content_ST_location_EV_of_PositedAt" OR
        NEW."PR_content_ST_location_EV_of_Reliability" IS DISTINCT FROM OLD."PR_content_ST_location_EV_of_Reliability"
    THEN
        IF
            NEW."PR_ID_content" IS NOT NULL
        AND
            NEW."ST_ID_location" IS NOT NULL
        AND
            NEW."EV_ID_of" IS NOT NULL
        THEN
            INSERT INTO ties."PR_content_ST_location_EV_of" (
                "Metadata_PR_content_ST_location_EV_of",
                "PR_ID_content",
                "ST_ID_location",
                "EV_ID_of",
                "PR_content_ST_location_EV_of_ChangedAt",
                "PR_content_ST_location_EV_of_PositedAt",
                "PR_content_ST_location_EV_of_Reliability"
            )
            VALUES (
                NEW."Metadata_PR_content_ST_location_EV_of",
                NEW."PR_ID_content",
                NEW."ST_ID_location",
                NEW."EV_ID_of",
                -- the shown version asserted again keeps its changing time, as does one that is given
                CASE
                    WHEN NEW."PR_content_ST_location_EV_of_ChangedAt" IS DISTINCT FROM OLD."PR_content_ST_location_EV_of_ChangedAt" THEN NEW."PR_content_ST_location_EV_of_ChangedAt"
                    WHEN
                        NEW."PR_ID_content" = OLD."PR_ID_content"
                    AND
                        NEW."ST_ID_location" = OLD."ST_ID_location"
                    AND
                        NEW."EV_ID_of" = OLD."EV_ID_of"
                    THEN NEW."PR_content_ST_location_EV_of_ChangedAt"
                    ELSE _now
                END,
                _positing,
                coalesce(NEW."PR_content_ST_location_EV_of_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO ties."PR_content_ST_location_EV_of" (
                "Metadata_PR_content_ST_location_EV_of",
                "PR_ID_content",
                "ST_ID_location",
                "EV_ID_of",
                "PR_content_ST_location_EV_of_ChangedAt",
                "PR_content_ST_location_EV_of_PositedAt",
                "PR_content_ST_location_EV_of_Reliability"
            )
            VALUES (
                NEW."Metadata_PR_content_ST_location_EV_of",
                OLD."PR_ID_content",
                OLD."ST_ID_location",
                OLD."EV_ID_of",
                OLD."PR_content_ST_location_EV_of_ChangedAt",
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lPR_content_ST_location_EV_of" ON ties."lPR_content_ST_location_EV_of";
CREATE TRIGGER "ut_lPR_content_ST_location_EV_of"
INSTEAD OF UPDATE ON ties."lPR_content_ST_location_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."ut_lPR_content_ST_location_EV_of"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_content_ST_location_EV_of instead of DELETE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lPR_content_ST_location_EV_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."PR_content_ST_location_EV_of_Annex" (
        "Metadata_PR_content_ST_location_EV_of",
        "PR_content_ST_location_EV_of_ID",
        "PR_content_ST_location_EV_of_PositedAt",
        "PR_content_ST_location_EV_of_Reliability"
    )
    SELECT
        OLD."Metadata_PR_content_ST_location_EV_of",
        OLD."PR_content_ST_location_EV_of_ID",
        _now,
        0
    WHERE
        OLD."PR_content_ST_location_EV_of_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lPR_content_ST_location_EV_of" ON ties."lPR_content_ST_location_EV_of";
CREATE TRIGGER "dt_lPR_content_ST_location_EV_of"
INSTEAD OF DELETE ON ties."lPR_content_ST_location_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lPR_content_ST_location_EV_of"();
