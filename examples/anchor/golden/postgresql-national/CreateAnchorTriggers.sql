-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates (the triggers of the attribute tables see to that).
--
-- PostgreSQL runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_Scen instead of INSERT trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."it_lST_Scen"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id integer;
    _AVG smallint;
    _MIN smallint;
BEGIN
    _id := NEW."ST_ID";
    IF _id IS NULL THEN
        INSERT INTO anchors."ST_Scen" (
            "Metadata_ST"
        )
        VALUES (
            NEW."Metadata_ST"
        )
        RETURNING "ST_ID" INTO _id;
    END IF;
    IF NEW."ST_NAM_Scen_Namn" IS NOT NULL THEN
        INSERT INTO attributes."ST_NAM_Scen_Namn" (
            "Metadata_ST_NAM",
            "ST_NAM_ST_ID",
            "ST_NAM_EQ",
            "ST_NAM_ChangedAt",
            "ST_NAM_Scen_Namn"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_NAM", NEW."Metadata_ST"),
            coalesce(NEW."ST_NAM_ST_ID", _id),
            coalesce(NEW."ST_NAM_EQ", 0),
            coalesce(NEW."ST_NAM_ChangedAt", _now),
            NEW."ST_NAM_Scen_Namn"
        );
    END IF;
    IF NEW."ST_LOC_Scen_Plats" IS NOT NULL THEN
        INSERT INTO attributes."ST_LOC_Scen_Plats" (
            "Metadata_ST_LOC",
            "ST_LOC_ST_ID",
            "ST_LOC_EQ",
            "ST_LOC_Scen_Plats"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_LOC", NEW."Metadata_ST"),
            coalesce(NEW."ST_LOC_ST_ID", _id),
            coalesce(NEW."ST_LOC_EQ", 0),
            NEW."ST_LOC_Scen_Plats"
        );
    END IF;
    _AVG := NEW."ST_AVG_UTL_ID";
    IF _AVG IS NULL AND NEW."ST_AVG_UTL_Utnyttjande" IS NOT NULL THEN
        SELECT
            k."UTL_ID"
        INTO
            _AVG
        FROM
            knots."UTL_Utnyttjande" k
        WHERE
            k."UTL_Utnyttjande" = NEW."ST_AVG_UTL_Utnyttjande"
        LIMIT 1;
    END IF;
    IF _AVG IS NOT NULL THEN
        INSERT INTO attributes."ST_AVG_Scen_Medel" (
            "Metadata_ST_AVG",
            "ST_AVG_ST_ID",
            "ST_AVG_ChangedAt",
            "ST_AVG_UTL_ID"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_AVG", NEW."Metadata_ST"),
            coalesce(NEW."ST_AVG_ST_ID", _id),
            coalesce(NEW."ST_AVG_ChangedAt", _now),
            _AVG
        );
    END IF;
    _MIN := NEW."ST_MIN_UTL_ID";
    IF _MIN IS NULL AND NEW."ST_MIN_UTL_Utnyttjande" IS NOT NULL THEN
        SELECT
            k."UTL_ID"
        INTO
            _MIN
        FROM
            knots."UTL_Utnyttjande" k
        WHERE
            k."UTL_Utnyttjande" = NEW."ST_MIN_UTL_Utnyttjande"
        LIMIT 1;
    END IF;
    IF _MIN IS NOT NULL THEN
        INSERT INTO attributes."ST_MIN_Scen_Minimum" (
            "Metadata_ST_MIN",
            "ST_MIN_ST_ID",
            "ST_MIN_UTL_ID"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_MIN", NEW."Metadata_ST"),
            coalesce(NEW."ST_MIN_ST_ID", _id),
            _MIN
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lST_Scen" ON anchors."lST_Scen";
CREATE TRIGGER "it_lST_Scen"
INSTEAD OF INSERT ON anchors."lST_Scen"
FOR EACH ROW EXECUTE FUNCTION anchors."it_lST_Scen"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Scen instead of UPDATE trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."ut_lST_Scen"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _AVG smallint;
    _MIN smallint;
BEGIN
    IF NEW."ST_ID" IS DISTINCT FROM OLD."ST_ID" THEN
        RAISE EXCEPTION 'The identity column ST_ID is not updatable.';
    END IF;
    IF NEW."ST_NAM_ST_ID" IS DISTINCT FROM OLD."ST_NAM_ST_ID" THEN
        RAISE EXCEPTION 'The foreign key column ST_NAM_ST_ID is not updatable.';
    END IF;
    IF NEW."ST_NAM_Scen_Namn" IS DISTINCT FROM OLD."ST_NAM_Scen_Namn"
    OR NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt"
    OR NEW."ST_NAM_EQ" IS DISTINCT FROM OLD."ST_NAM_EQ"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."ST_NAM_Scen_Namn" IS NOT NULL AND (
            NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt" OR
            NEW."ST_NAM_EQ" IS DISTINCT FROM OLD."ST_NAM_EQ" OR
            OLD."ST_NAM_Scen_Namn" IS NULL OR
            OLD."ST_NAM_Scen_Namn" <> NEW."ST_NAM_Scen_Namn"
        ) THEN
            INSERT INTO attributes."ST_NAM_Scen_Namn" (
                "Metadata_ST_NAM",
                "ST_NAM_ST_ID",
                "ST_NAM_EQ",
                "ST_NAM_ChangedAt",
                "ST_NAM_Scen_Namn"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_ST" IS DISTINCT FROM OLD."Metadata_ST"
                         AND NEW."Metadata_ST_NAM" IS NOT DISTINCT FROM OLD."Metadata_ST_NAM"
                        THEN NEW."Metadata_ST"
                        ELSE NEW."Metadata_ST_NAM"
                    END, NEW."Metadata_ST"),
                coalesce(NEW."ST_NAM_ST_ID", NEW."ST_ID"),
                coalesce(NEW."ST_NAM_EQ", 0),
                CASE
                    WHEN NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt" THEN NEW."ST_NAM_ChangedAt"
                    ELSE _now
                END,
                NEW."ST_NAM_Scen_Namn"
            );
        END IF;
    END IF;
    IF NEW."ST_LOC_ST_ID" IS DISTINCT FROM OLD."ST_LOC_ST_ID" THEN
        RAISE EXCEPTION 'The foreign key column ST_LOC_ST_ID is not updatable.';
    END IF;
    IF NEW."ST_LOC_Scen_Plats" IS DISTINCT FROM OLD."ST_LOC_Scen_Plats"
    OR NEW."ST_LOC_EQ" IS DISTINCT FROM OLD."ST_LOC_EQ"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."ST_LOC_Scen_Plats" IS NOT NULL AND (
            NEW."ST_LOC_EQ" IS DISTINCT FROM OLD."ST_LOC_EQ" OR
            OLD."ST_LOC_Scen_Plats" IS NULL OR
            md5(OLD."ST_LOC_Scen_Plats"::text) <> md5(NEW."ST_LOC_Scen_Plats"::text)
        ) THEN
            INSERT INTO attributes."ST_LOC_Scen_Plats" (
                "Metadata_ST_LOC",
                "ST_LOC_ST_ID",
                "ST_LOC_EQ",
                "ST_LOC_Scen_Plats"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_ST" IS DISTINCT FROM OLD."Metadata_ST"
                         AND NEW."Metadata_ST_LOC" IS NOT DISTINCT FROM OLD."Metadata_ST_LOC"
                        THEN NEW."Metadata_ST"
                        ELSE NEW."Metadata_ST_LOC"
                    END, NEW."Metadata_ST"),
                coalesce(NEW."ST_LOC_ST_ID", NEW."ST_ID"),
                coalesce(NEW."ST_LOC_EQ", 0),
                NEW."ST_LOC_Scen_Plats"
            );
        END IF;
    END IF;
    IF NEW."ST_AVG_ST_ID" IS DISTINCT FROM OLD."ST_AVG_ST_ID" THEN
        RAISE EXCEPTION 'The foreign key column ST_AVG_ST_ID is not updatable.';
    END IF;
    IF NEW."ST_AVG_UTL_ID" IS DISTINCT FROM OLD."ST_AVG_UTL_ID"
    OR NEW."ST_AVG_UTL_Utnyttjande" IS DISTINCT FROM OLD."ST_AVG_UTL_Utnyttjande"
    OR NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt"
    THEN
        _AVG := NEW."ST_AVG_UTL_ID";
        IF _AVG IS NOT DISTINCT FROM OLD."ST_AVG_UTL_ID" AND NEW."ST_AVG_UTL_Utnyttjande" IS NOT NULL THEN
            SELECT
                k."UTL_ID"
            INTO
                _AVG
            FROM
                knots."UTL_Utnyttjande" k
            WHERE
                k."UTL_Utnyttjande" = NEW."ST_AVG_UTL_Utnyttjande"
            LIMIT 1;
        END IF;
        -- a value that is left as it is states nothing
        IF _AVG IS NOT NULL AND (
            NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt" OR
            OLD."ST_AVG_UTL_ID" IS NULL OR
            OLD."ST_AVG_UTL_ID" <> _AVG
        ) THEN
            INSERT INTO attributes."ST_AVG_Scen_Medel" (
                "Metadata_ST_AVG",
                "ST_AVG_ST_ID",
                "ST_AVG_ChangedAt",
                "ST_AVG_UTL_ID"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_ST" IS DISTINCT FROM OLD."Metadata_ST"
                         AND NEW."Metadata_ST_AVG" IS NOT DISTINCT FROM OLD."Metadata_ST_AVG"
                        THEN NEW."Metadata_ST"
                        ELSE NEW."Metadata_ST_AVG"
                    END, NEW."Metadata_ST"),
                coalesce(NEW."ST_AVG_ST_ID", NEW."ST_ID"),
                CASE
                    WHEN NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt" THEN NEW."ST_AVG_ChangedAt"
                    ELSE _now
                END,
                _AVG
            );
        END IF;
    END IF;
    IF NEW."ST_MIN_ST_ID" IS DISTINCT FROM OLD."ST_MIN_ST_ID" THEN
        RAISE EXCEPTION 'The foreign key column ST_MIN_ST_ID is not updatable.';
    END IF;
    IF NEW."ST_MIN_UTL_ID" IS DISTINCT FROM OLD."ST_MIN_UTL_ID"
    OR NEW."ST_MIN_UTL_Utnyttjande" IS DISTINCT FROM OLD."ST_MIN_UTL_Utnyttjande"
    THEN
        _MIN := NEW."ST_MIN_UTL_ID";
        IF _MIN IS NOT DISTINCT FROM OLD."ST_MIN_UTL_ID" AND NEW."ST_MIN_UTL_Utnyttjande" IS NOT NULL THEN
            SELECT
                k."UTL_ID"
            INTO
                _MIN
            FROM
                knots."UTL_Utnyttjande" k
            WHERE
                k."UTL_Utnyttjande" = NEW."ST_MIN_UTL_Utnyttjande"
            LIMIT 1;
        END IF;
        -- a value that is left as it is states nothing
        IF _MIN IS NOT NULL AND (
            OLD."ST_MIN_UTL_ID" IS NULL OR
            OLD."ST_MIN_UTL_ID" <> _MIN
        ) THEN
            INSERT INTO attributes."ST_MIN_Scen_Minimum" (
                "Metadata_ST_MIN",
                "ST_MIN_ST_ID",
                "ST_MIN_UTL_ID"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_ST" IS DISTINCT FROM OLD."Metadata_ST"
                         AND NEW."Metadata_ST_MIN" IS NOT DISTINCT FROM OLD."Metadata_ST_MIN"
                        THEN NEW."Metadata_ST"
                        ELSE NEW."Metadata_ST_MIN"
                    END, NEW."Metadata_ST"),
                coalesce(NEW."ST_MIN_ST_ID", NEW."ST_ID"),
                _MIN
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lST_Scen" ON anchors."lST_Scen";
CREATE TRIGGER "ut_lST_Scen"
INSTEAD OF UPDATE ON anchors."lST_Scen"
FOR EACH ROW EXECUTE FUNCTION anchors."ut_lST_Scen"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Scen instead of DELETE trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dt_lST_Scen"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        attributes."ST_NAM_Scen_Namn" x
    WHERE
        x."ST_NAM_ST_ID" = OLD."ST_ID"
    AND
        x."ST_NAM_EQ" = OLD."ST_NAM_EQ"
    AND
        x."ST_NAM_ChangedAt" = OLD."ST_NAM_ChangedAt"
    ;
    DELETE FROM
        attributes."ST_LOC_Scen_Plats" x
    WHERE
        x."ST_LOC_ST_ID" = OLD."ST_ID"
    AND
        x."ST_LOC_EQ" = OLD."ST_LOC_EQ"
    ;
    DELETE FROM
        attributes."ST_AVG_Scen_Medel" x
    WHERE
        x."ST_AVG_ST_ID" = OLD."ST_ID"
    AND
        x."ST_AVG_ChangedAt" = OLD."ST_AVG_ChangedAt"
    ;
    DELETE FROM
        attributes."ST_MIN_Scen_Minimum" x
    WHERE
        x."ST_MIN_ST_ID" = OLD."ST_ID"
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        anchors."ST_Scen" a
    WHERE
        a."ST_ID" = OLD."ST_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."ST_NAM_Scen_Namn" x
        WHERE
            x."ST_NAM_ST_ID" = a."ST_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."ST_LOC_Scen_Plats" x
        WHERE
            x."ST_LOC_ST_ID" = a."ST_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."ST_AVG_Scen_Medel" x
        WHERE
            x."ST_AVG_ST_ID" = a."ST_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."ST_MIN_Scen_Minimum" x
        WHERE
            x."ST_MIN_ST_ID" = a."ST_ID"
    )
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lST_Scen" ON anchors."lST_Scen";
CREATE TRIGGER "dt_lST_Scen"
INSTEAD OF DELETE ON anchors."lST_Scen"
FOR EACH ROW EXECUTE FUNCTION anchors."dt_lST_Scen"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Skådespelare instead of INSERT trigger on lAC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."it_lAC_Skådespelare"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id smallint;
    _GEN smallint;
    _PLV smallint;
BEGIN
    _id := NEW."AC_ID";
    IF _id IS NULL THEN
        INSERT INTO anchors."AC_Skådespelare" (
            "Metadata_AC"
        )
        VALUES (
            NEW."Metadata_AC"
        )
        RETURNING "AC_ID" INTO _id;
    END IF;
    IF NEW."AC_NAM_Skådespelare_Namn" IS NOT NULL THEN
        INSERT INTO attributes."AC_NAM_Skådespelare_Namn" (
            "Metadata_AC_NAM",
            "AC_NAM_AC_ID",
            "AC_NAM_ChangedAt",
            "AC_NAM_Skådespelare_Namn"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_NAM", NEW."Metadata_AC"),
            coalesce(NEW."AC_NAM_AC_ID", _id),
            coalesce(NEW."AC_NAM_ChangedAt", _now),
            NEW."AC_NAM_Skådespelare_Namn"
        );
    END IF;
    _GEN := NEW."AC_GEN_GEN_ID";
    IF _GEN IS NULL AND NEW."AC_GEN_GEN_Kön" IS NOT NULL THEN
        SELECT
            k."GEN_ID"
        INTO
            _GEN
        FROM
            knots."GEN_Kön" k
        WHERE
            k."GEN_Checksum" = decode(md5(NEW."AC_GEN_GEN_Kön"::text), 'hex')
        LIMIT 1;
    END IF;
    IF _GEN IS NOT NULL THEN
        INSERT INTO attributes."AC_GEN_Skådespelare_Kön" (
            "Metadata_AC_GEN",
            "AC_GEN_AC_ID",
            "AC_GEN_GEN_ID"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_GEN", NEW."Metadata_AC"),
            coalesce(NEW."AC_GEN_AC_ID", _id),
            _GEN
        );
    END IF;
    _PLV := NEW."AC_PLV_PLV_ID";
    IF _PLV IS NULL AND NEW."AC_PLV_PLV_Yrkesnivå" IS NOT NULL THEN
        SELECT
            k."PLV_ID"
        INTO
            _PLV
        FROM
            knots."PLV_Yrkesnivå_EQ" k
        WHERE
            k."PLV_Checksum" = decode(md5(NEW."AC_PLV_PLV_Yrkesnivå"::text), 'hex')
        AND
            k."PLV_EQ" = coalesce(NEW."AC_PLV_PLV_EQ", 0)
        LIMIT 1;
    END IF;
    IF _PLV IS NOT NULL THEN
        INSERT INTO attributes."AC_PLV_Skådespelare_Yrkesnivå" (
            "Metadata_AC_PLV",
            "AC_PLV_AC_ID",
            "AC_PLV_ChangedAt",
            "AC_PLV_PLV_ID"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_PLV", NEW."Metadata_AC"),
            coalesce(NEW."AC_PLV_AC_ID", _id),
            coalesce(NEW."AC_PLV_ChangedAt", _now),
            _PLV
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lAC_Skådespelare" ON anchors."lAC_Skådespelare";
CREATE TRIGGER "it_lAC_Skådespelare"
INSTEAD OF INSERT ON anchors."lAC_Skådespelare"
FOR EACH ROW EXECUTE FUNCTION anchors."it_lAC_Skådespelare"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_Skådespelare instead of UPDATE trigger on lAC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."ut_lAC_Skådespelare"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _GEN smallint;
    _PLV smallint;
BEGIN
    IF NEW."AC_ID" IS DISTINCT FROM OLD."AC_ID" THEN
        RAISE EXCEPTION 'The identity column AC_ID is not updatable.';
    END IF;
    IF NEW."AC_NAM_AC_ID" IS DISTINCT FROM OLD."AC_NAM_AC_ID" THEN
        RAISE EXCEPTION 'The foreign key column AC_NAM_AC_ID is not updatable.';
    END IF;
    IF NEW."AC_NAM_Skådespelare_Namn" IS DISTINCT FROM OLD."AC_NAM_Skådespelare_Namn"
    OR NEW."AC_NAM_ChangedAt" IS DISTINCT FROM OLD."AC_NAM_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."AC_NAM_Skådespelare_Namn" IS NOT NULL AND (
            NEW."AC_NAM_ChangedAt" IS DISTINCT FROM OLD."AC_NAM_ChangedAt" OR
            OLD."AC_NAM_Skådespelare_Namn" IS NULL OR
            OLD."AC_NAM_Skådespelare_Namn" <> NEW."AC_NAM_Skådespelare_Namn"
        ) THEN
            INSERT INTO attributes."AC_NAM_Skådespelare_Namn" (
                "Metadata_AC_NAM",
                "AC_NAM_AC_ID",
                "AC_NAM_ChangedAt",
                "AC_NAM_Skådespelare_Namn"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_AC" IS DISTINCT FROM OLD."Metadata_AC"
                         AND NEW."Metadata_AC_NAM" IS NOT DISTINCT FROM OLD."Metadata_AC_NAM"
                        THEN NEW."Metadata_AC"
                        ELSE NEW."Metadata_AC_NAM"
                    END, NEW."Metadata_AC"),
                coalesce(NEW."AC_NAM_AC_ID", NEW."AC_ID"),
                CASE
                    WHEN NEW."AC_NAM_ChangedAt" IS DISTINCT FROM OLD."AC_NAM_ChangedAt" THEN NEW."AC_NAM_ChangedAt"
                    ELSE _now
                END,
                NEW."AC_NAM_Skådespelare_Namn"
            );
        END IF;
    END IF;
    IF NEW."AC_GEN_AC_ID" IS DISTINCT FROM OLD."AC_GEN_AC_ID" THEN
        RAISE EXCEPTION 'The foreign key column AC_GEN_AC_ID is not updatable.';
    END IF;
    IF NEW."AC_GEN_GEN_ID" IS DISTINCT FROM OLD."AC_GEN_GEN_ID"
    OR NEW."AC_GEN_GEN_Kön" IS DISTINCT FROM OLD."AC_GEN_GEN_Kön"
    THEN
        _GEN := NEW."AC_GEN_GEN_ID";
        IF _GEN IS NOT DISTINCT FROM OLD."AC_GEN_GEN_ID" AND NEW."AC_GEN_GEN_Kön" IS NOT NULL THEN
            SELECT
                k."GEN_ID"
            INTO
                _GEN
            FROM
                knots."GEN_Kön" k
            WHERE
                k."GEN_Checksum" = decode(md5(NEW."AC_GEN_GEN_Kön"::text), 'hex')
            LIMIT 1;
        END IF;
        -- a value that is left as it is states nothing
        IF _GEN IS NOT NULL AND (
            OLD."AC_GEN_GEN_ID" IS NULL OR
            OLD."AC_GEN_GEN_ID" <> _GEN
        ) THEN
            INSERT INTO attributes."AC_GEN_Skådespelare_Kön" (
                "Metadata_AC_GEN",
                "AC_GEN_AC_ID",
                "AC_GEN_GEN_ID"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_AC" IS DISTINCT FROM OLD."Metadata_AC"
                         AND NEW."Metadata_AC_GEN" IS NOT DISTINCT FROM OLD."Metadata_AC_GEN"
                        THEN NEW."Metadata_AC"
                        ELSE NEW."Metadata_AC_GEN"
                    END, NEW."Metadata_AC"),
                coalesce(NEW."AC_GEN_AC_ID", NEW."AC_ID"),
                _GEN
            );
        END IF;
    END IF;
    IF NEW."AC_PLV_AC_ID" IS DISTINCT FROM OLD."AC_PLV_AC_ID" THEN
        RAISE EXCEPTION 'The foreign key column AC_PLV_AC_ID is not updatable.';
    END IF;
    IF NEW."AC_PLV_PLV_ID" IS DISTINCT FROM OLD."AC_PLV_PLV_ID"
    OR NEW."AC_PLV_PLV_Yrkesnivå" IS DISTINCT FROM OLD."AC_PLV_PLV_Yrkesnivå"
    OR NEW."AC_PLV_ChangedAt" IS DISTINCT FROM OLD."AC_PLV_ChangedAt"
    THEN
        _PLV := NEW."AC_PLV_PLV_ID";
        IF _PLV IS NOT DISTINCT FROM OLD."AC_PLV_PLV_ID" AND NEW."AC_PLV_PLV_Yrkesnivå" IS NOT NULL THEN
            SELECT
                k."PLV_ID"
            INTO
                _PLV
            FROM
                knots."PLV_Yrkesnivå_EQ" k
            WHERE
                k."PLV_Checksum" = decode(md5(NEW."AC_PLV_PLV_Yrkesnivå"::text), 'hex')
            AND
                k."PLV_EQ" = coalesce(NEW."AC_PLV_PLV_EQ", 0)
            LIMIT 1;
        END IF;
        -- a value that is left as it is states nothing
        IF _PLV IS NOT NULL AND (
            NEW."AC_PLV_ChangedAt" IS DISTINCT FROM OLD."AC_PLV_ChangedAt" OR
            OLD."AC_PLV_PLV_ID" IS NULL OR
            OLD."AC_PLV_PLV_ID" <> _PLV
        ) THEN
            INSERT INTO attributes."AC_PLV_Skådespelare_Yrkesnivå" (
                "Metadata_AC_PLV",
                "AC_PLV_AC_ID",
                "AC_PLV_ChangedAt",
                "AC_PLV_PLV_ID"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_AC" IS DISTINCT FROM OLD."Metadata_AC"
                         AND NEW."Metadata_AC_PLV" IS NOT DISTINCT FROM OLD."Metadata_AC_PLV"
                        THEN NEW."Metadata_AC"
                        ELSE NEW."Metadata_AC_PLV"
                    END, NEW."Metadata_AC"),
                coalesce(NEW."AC_PLV_AC_ID", NEW."AC_ID"),
                CASE
                    WHEN NEW."AC_PLV_ChangedAt" IS DISTINCT FROM OLD."AC_PLV_ChangedAt" THEN NEW."AC_PLV_ChangedAt"
                    ELSE _now
                END,
                _PLV
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lAC_Skådespelare" ON anchors."lAC_Skådespelare";
CREATE TRIGGER "ut_lAC_Skådespelare"
INSTEAD OF UPDATE ON anchors."lAC_Skådespelare"
FOR EACH ROW EXECUTE FUNCTION anchors."ut_lAC_Skådespelare"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_Skådespelare instead of DELETE trigger on lAC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dt_lAC_Skådespelare"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        attributes."AC_NAM_Skådespelare_Namn" x
    WHERE
        x."AC_NAM_AC_ID" = OLD."AC_ID"
    AND
        x."AC_NAM_ChangedAt" = OLD."AC_NAM_ChangedAt"
    ;
    DELETE FROM
        attributes."AC_GEN_Skådespelare_Kön" x
    WHERE
        x."AC_GEN_AC_ID" = OLD."AC_ID"
    ;
    DELETE FROM
        attributes."AC_PLV_Skådespelare_Yrkesnivå" x
    WHERE
        x."AC_PLV_AC_ID" = OLD."AC_ID"
    AND
        x."AC_PLV_ChangedAt" = OLD."AC_PLV_ChangedAt"
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        anchors."AC_Skådespelare" a
    WHERE
        a."AC_ID" = OLD."AC_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."AC_NAM_Skådespelare_Namn" x
        WHERE
            x."AC_NAM_AC_ID" = a."AC_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."AC_GEN_Skådespelare_Kön" x
        WHERE
            x."AC_GEN_AC_ID" = a."AC_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."AC_PLV_Skådespelare_Yrkesnivå" x
        WHERE
            x."AC_PLV_AC_ID" = a."AC_ID"
    )
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_Skådespelare" ON anchors."lAC_Skådespelare";
CREATE TRIGGER "dt_lAC_Skådespelare"
INSTEAD OF DELETE ON anchors."lAC_Skådespelare"
FOR EACH ROW EXECUTE FUNCTION anchors."dt_lAC_Skådespelare"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Föreställning instead of INSERT trigger on lPR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."it_lPR_Föreställning"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id bigint;
BEGIN
    _id := NEW."PR_ID";
    IF _id IS NULL THEN
        INSERT INTO anchors."PR_Föreställning" (
            "Metadata_PR"
        )
        VALUES (
            NEW."Metadata_PR"
        )
        RETURNING "PR_ID" INTO _id;
    END IF;
    IF NEW."PR_NAM_Föreställning_Namn" IS NOT NULL THEN
        INSERT INTO attributes."PR_NAM_Föreställning_Namn" (
            "Metadata_PR_NAM",
            "PR_NAM_PR_ID",
            "PR_NAM_Föreställning_Namn"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_NAM", NEW."Metadata_PR"),
            coalesce(NEW."PR_NAM_PR_ID", _id),
            NEW."PR_NAM_Föreställning_Namn"
        );
    END IF;
    IF NEW."PR_LEN_Föreställning_Längd" IS NOT NULL THEN
        INSERT INTO attributes."PR_LEN_Föreställning_Längd" (
            "Metadata_PR_LEN",
            "PR_LEN_PR_ID",
            "PR_LEN_EQ",
            "PR_LEN_ChangedAt",
            "PR_LEN_Föreställning_Längd"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_LEN", NEW."Metadata_PR"),
            coalesce(NEW."PR_LEN_PR_ID", _id),
            coalesce(NEW."PR_LEN_EQ", 0),
            coalesce(NEW."PR_LEN_ChangedAt", _now),
            NEW."PR_LEN_Föreställning_Längd"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lPR_Föreställning" ON anchors."lPR_Föreställning";
CREATE TRIGGER "it_lPR_Föreställning"
INSTEAD OF INSERT ON anchors."lPR_Föreställning"
FOR EACH ROW EXECUTE FUNCTION anchors."it_lPR_Föreställning"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_Föreställning instead of UPDATE trigger on lPR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."ut_lPR_Föreställning"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    IF NEW."PR_ID" IS DISTINCT FROM OLD."PR_ID" THEN
        RAISE EXCEPTION 'The identity column PR_ID is not updatable.';
    END IF;
    IF NEW."PR_NAM_PR_ID" IS DISTINCT FROM OLD."PR_NAM_PR_ID" THEN
        RAISE EXCEPTION 'The foreign key column PR_NAM_PR_ID is not updatable.';
    END IF;
    IF NEW."PR_NAM_Föreställning_Namn" IS DISTINCT FROM OLD."PR_NAM_Föreställning_Namn"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."PR_NAM_Föreställning_Namn" IS NOT NULL AND (
            OLD."PR_NAM_Föreställning_Namn" IS NULL OR
            OLD."PR_NAM_Föreställning_Namn" <> NEW."PR_NAM_Föreställning_Namn"
        ) THEN
            INSERT INTO attributes."PR_NAM_Föreställning_Namn" (
                "Metadata_PR_NAM",
                "PR_NAM_PR_ID",
                "PR_NAM_Föreställning_Namn"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_PR" IS DISTINCT FROM OLD."Metadata_PR"
                         AND NEW."Metadata_PR_NAM" IS NOT DISTINCT FROM OLD."Metadata_PR_NAM"
                        THEN NEW."Metadata_PR"
                        ELSE NEW."Metadata_PR_NAM"
                    END, NEW."Metadata_PR"),
                coalesce(NEW."PR_NAM_PR_ID", NEW."PR_ID"),
                NEW."PR_NAM_Föreställning_Namn"
            );
        END IF;
    END IF;
    IF NEW."PR_LEN_PR_ID" IS DISTINCT FROM OLD."PR_LEN_PR_ID" THEN
        RAISE EXCEPTION 'The foreign key column PR_LEN_PR_ID is not updatable.';
    END IF;
    IF NEW."PR_LEN_Föreställning_Längd" IS DISTINCT FROM OLD."PR_LEN_Föreställning_Längd"
    OR NEW."PR_LEN_ChangedAt" IS DISTINCT FROM OLD."PR_LEN_ChangedAt"
    OR NEW."PR_LEN_EQ" IS DISTINCT FROM OLD."PR_LEN_EQ"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."PR_LEN_Föreställning_Längd" IS NOT NULL AND (
            NEW."PR_LEN_ChangedAt" IS DISTINCT FROM OLD."PR_LEN_ChangedAt" OR
            NEW."PR_LEN_EQ" IS DISTINCT FROM OLD."PR_LEN_EQ" OR
            OLD."PR_LEN_Föreställning_Längd" IS NULL OR
            OLD."PR_LEN_Föreställning_Längd" <> NEW."PR_LEN_Föreställning_Längd"
        ) THEN
            INSERT INTO attributes."PR_LEN_Föreställning_Längd" (
                "Metadata_PR_LEN",
                "PR_LEN_PR_ID",
                "PR_LEN_EQ",
                "PR_LEN_ChangedAt",
                "PR_LEN_Föreställning_Längd"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_PR" IS DISTINCT FROM OLD."Metadata_PR"
                         AND NEW."Metadata_PR_LEN" IS NOT DISTINCT FROM OLD."Metadata_PR_LEN"
                        THEN NEW."Metadata_PR"
                        ELSE NEW."Metadata_PR_LEN"
                    END, NEW."Metadata_PR"),
                coalesce(NEW."PR_LEN_PR_ID", NEW."PR_ID"),
                coalesce(NEW."PR_LEN_EQ", 0),
                CASE
                    WHEN NEW."PR_LEN_ChangedAt" IS DISTINCT FROM OLD."PR_LEN_ChangedAt" THEN NEW."PR_LEN_ChangedAt"
                    ELSE _now
                END,
                NEW."PR_LEN_Föreställning_Längd"
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lPR_Föreställning" ON anchors."lPR_Föreställning";
CREATE TRIGGER "ut_lPR_Föreställning"
INSTEAD OF UPDATE ON anchors."lPR_Föreställning"
FOR EACH ROW EXECUTE FUNCTION anchors."ut_lPR_Föreställning"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_Föreställning instead of DELETE trigger on lPR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dt_lPR_Föreställning"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        attributes."PR_NAM_Föreställning_Namn" x
    WHERE
        x."PR_NAM_PR_ID" = OLD."PR_ID"
    ;
    DELETE FROM
        attributes."PR_LEN_Föreställning_Längd" x
    WHERE
        x."PR_LEN_PR_ID" = OLD."PR_ID"
    AND
        x."PR_LEN_EQ" = OLD."PR_LEN_EQ"
    AND
        x."PR_LEN_ChangedAt" = OLD."PR_LEN_ChangedAt"
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        anchors."PR_Föreställning" a
    WHERE
        a."PR_ID" = OLD."PR_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."PR_NAM_Föreställning_Namn" x
        WHERE
            x."PR_NAM_PR_ID" = a."PR_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."PR_LEN_Föreställning_Längd" x
        WHERE
            x."PR_LEN_PR_ID" = a."PR_ID"
    )
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lPR_Föreställning" ON anchors."lPR_Föreställning";
CREATE TRIGGER "dt_lPR_Föreställning"
INSTEAD OF DELETE ON anchors."lPR_Föreställning"
FOR EACH ROW EXECUTE FUNCTION anchors."dt_lPR_Föreställning"();
