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
-- it_lST_Stage instead of INSERT trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."it_lST_Stage"()
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
        INSERT INTO anchors."ST_Stage" (
            "Metadata_ST"
        )
        VALUES (
            NEW."Metadata_ST"
        )
        RETURNING "ST_ID" INTO _id;
    END IF;
    IF NEW."ST_NAM_Stage_Name" IS NOT NULL THEN
        INSERT INTO attributes."ST_NAM_Stage_Name" (
            "Metadata_ST_NAM",
            "ST_NAM_ST_ID",
            "ST_NAM_EQ",
            "ST_NAM_ChangedAt",
            "ST_NAM_Stage_Name"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_NAM", NEW."Metadata_ST"),
            coalesce(NEW."ST_NAM_ST_ID", _id),
            coalesce(NEW."ST_NAM_EQ", 0),
            coalesce(NEW."ST_NAM_ChangedAt", _now),
            NEW."ST_NAM_Stage_Name"
        );
    END IF;
    IF NEW."ST_LOC_Stage_Location" IS NOT NULL THEN
        INSERT INTO attributes."ST_LOC_Stage_Location" (
            "Metadata_ST_LOC",
            "ST_LOC_ST_ID",
            "ST_LOC_EQ",
            "ST_LOC_Stage_Location"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_LOC", NEW."Metadata_ST"),
            coalesce(NEW."ST_LOC_ST_ID", _id),
            coalesce(NEW."ST_LOC_EQ", 0),
            NEW."ST_LOC_Stage_Location"
        );
    END IF;
    _AVG := NEW."ST_AVG_UTL_ID";
    IF _AVG IS NULL AND NEW."ST_AVG_UTL_Utilization" IS NOT NULL THEN
        SELECT
            k."UTL_ID"
        INTO
            _AVG
        FROM
            knots."UTL_Utilization" k
        WHERE
            k."UTL_Utilization" = NEW."ST_AVG_UTL_Utilization"
        LIMIT 1;
    END IF;
    IF _AVG IS NOT NULL THEN
        INSERT INTO attributes."ST_AVG_Stage_Average" (
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
    IF _MIN IS NULL AND NEW."ST_MIN_UTL_Utilization" IS NOT NULL THEN
        SELECT
            k."UTL_ID"
        INTO
            _MIN
        FROM
            knots."UTL_Utilization" k
        WHERE
            k."UTL_Utilization" = NEW."ST_MIN_UTL_Utilization"
        LIMIT 1;
    END IF;
    IF _MIN IS NOT NULL THEN
        INSERT INTO attributes."ST_MIN_Stage_Minimum" (
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
DROP TRIGGER IF EXISTS "it_lST_Stage" ON anchors."lST_Stage";
CREATE TRIGGER "it_lST_Stage"
INSTEAD OF INSERT ON anchors."lST_Stage"
FOR EACH ROW EXECUTE FUNCTION anchors."it_lST_Stage"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Stage instead of UPDATE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."ut_lST_Stage"()
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
    IF NEW."ST_NAM_Stage_Name" IS DISTINCT FROM OLD."ST_NAM_Stage_Name"
    OR NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt"
    OR NEW."ST_NAM_EQ" IS DISTINCT FROM OLD."ST_NAM_EQ"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."ST_NAM_Stage_Name" IS NOT NULL AND (
            NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt" OR
            NEW."ST_NAM_EQ" IS DISTINCT FROM OLD."ST_NAM_EQ" OR
            OLD."ST_NAM_Stage_Name" IS NULL OR
            OLD."ST_NAM_Stage_Name" <> NEW."ST_NAM_Stage_Name"
        ) THEN
            INSERT INTO attributes."ST_NAM_Stage_Name" (
                "Metadata_ST_NAM",
                "ST_NAM_ST_ID",
                "ST_NAM_EQ",
                "ST_NAM_ChangedAt",
                "ST_NAM_Stage_Name"
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
                NEW."ST_NAM_Stage_Name"
            );
        END IF;
    END IF;
    IF NEW."ST_LOC_ST_ID" IS DISTINCT FROM OLD."ST_LOC_ST_ID" THEN
        RAISE EXCEPTION 'The foreign key column ST_LOC_ST_ID is not updatable.';
    END IF;
    IF NEW."ST_LOC_Stage_Location" IS DISTINCT FROM OLD."ST_LOC_Stage_Location"
    OR NEW."ST_LOC_EQ" IS DISTINCT FROM OLD."ST_LOC_EQ"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."ST_LOC_Stage_Location" IS NOT NULL AND (
            NEW."ST_LOC_EQ" IS DISTINCT FROM OLD."ST_LOC_EQ" OR
            OLD."ST_LOC_Stage_Location" IS NULL OR
            md5(OLD."ST_LOC_Stage_Location"::text) <> md5(NEW."ST_LOC_Stage_Location"::text)
        ) THEN
            INSERT INTO attributes."ST_LOC_Stage_Location" (
                "Metadata_ST_LOC",
                "ST_LOC_ST_ID",
                "ST_LOC_EQ",
                "ST_LOC_Stage_Location"
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
                NEW."ST_LOC_Stage_Location"
            );
        END IF;
    END IF;
    IF NEW."ST_AVG_ST_ID" IS DISTINCT FROM OLD."ST_AVG_ST_ID" THEN
        RAISE EXCEPTION 'The foreign key column ST_AVG_ST_ID is not updatable.';
    END IF;
    IF NEW."ST_AVG_UTL_ID" IS DISTINCT FROM OLD."ST_AVG_UTL_ID"
    OR NEW."ST_AVG_UTL_Utilization" IS DISTINCT FROM OLD."ST_AVG_UTL_Utilization"
    OR NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt"
    THEN
        _AVG := NEW."ST_AVG_UTL_ID";
        IF _AVG IS NOT DISTINCT FROM OLD."ST_AVG_UTL_ID" AND NEW."ST_AVG_UTL_Utilization" IS NOT NULL THEN
            SELECT
                k."UTL_ID"
            INTO
                _AVG
            FROM
                knots."UTL_Utilization" k
            WHERE
                k."UTL_Utilization" = NEW."ST_AVG_UTL_Utilization"
            LIMIT 1;
        END IF;
        -- a value that is left as it is states nothing
        IF _AVG IS NOT NULL AND (
            NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt" OR
            OLD."ST_AVG_UTL_ID" IS NULL OR
            OLD."ST_AVG_UTL_ID" <> _AVG
        ) THEN
            INSERT INTO attributes."ST_AVG_Stage_Average" (
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
    OR NEW."ST_MIN_UTL_Utilization" IS DISTINCT FROM OLD."ST_MIN_UTL_Utilization"
    THEN
        _MIN := NEW."ST_MIN_UTL_ID";
        IF _MIN IS NOT DISTINCT FROM OLD."ST_MIN_UTL_ID" AND NEW."ST_MIN_UTL_Utilization" IS NOT NULL THEN
            SELECT
                k."UTL_ID"
            INTO
                _MIN
            FROM
                knots."UTL_Utilization" k
            WHERE
                k."UTL_Utilization" = NEW."ST_MIN_UTL_Utilization"
            LIMIT 1;
        END IF;
        -- a value that is left as it is states nothing
        IF _MIN IS NOT NULL AND (
            OLD."ST_MIN_UTL_ID" IS NULL OR
            OLD."ST_MIN_UTL_ID" <> _MIN
        ) THEN
            INSERT INTO attributes."ST_MIN_Stage_Minimum" (
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
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF NEW."Deletable_ST_MIN" IS TRUE
    AND OLD."ST_MIN_UTL_ID" IS NOT NULL
    AND (NEW."ST_MIN_UTL_ID" IS NULL OR NEW."ST_MIN_UTL_Utilization" IS NULL)
    THEN
        IF to_regclass('attributes."ST_MIN_Stage_Minimum_Deleted"') IS NULL THEN
            CREATE TABLE attributes."ST_MIN_Stage_Minimum_Deleted" (
                LIKE attributes."ST_MIN_Stage_Minimum",
                "ST_MIN_Deleted" timestamp
            );
        END IF;
        WITH d AS (
            DELETE FROM attributes."ST_MIN_Stage_Minimum"
            WHERE "ST_MIN_ST_ID" = OLD."ST_ID"
            RETURNING *
        )
        INSERT INTO attributes."ST_MIN_Stage_Minimum_Deleted"
        SELECT
            d.*,
            _now
        FROM
            d;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lST_Stage" ON anchors."lST_Stage";
CREATE TRIGGER "ut_lST_Stage"
INSTEAD OF UPDATE ON anchors."lST_Stage"
FOR EACH ROW EXECUTE FUNCTION anchors."ut_lST_Stage"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Stage instead of DELETE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dt_lST_Stage"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        attributes."ST_NAM_Stage_Name" x
    WHERE
        x."ST_NAM_ST_ID" = OLD."ST_ID"
    AND
        x."ST_NAM_EQ" = OLD."ST_NAM_EQ"
    AND
        x."ST_NAM_ChangedAt" = OLD."ST_NAM_ChangedAt"
    ;
    DELETE FROM
        attributes."ST_LOC_Stage_Location" x
    WHERE
        x."ST_LOC_ST_ID" = OLD."ST_ID"
    AND
        x."ST_LOC_EQ" = OLD."ST_LOC_EQ"
    ;
    DELETE FROM
        attributes."ST_AVG_Stage_Average" x
    WHERE
        x."ST_AVG_ST_ID" = OLD."ST_ID"
    AND
        x."ST_AVG_ChangedAt" = OLD."ST_AVG_ChangedAt"
    ;
    DELETE FROM
        attributes."ST_MIN_Stage_Minimum" x
    WHERE
        x."ST_MIN_ST_ID" = OLD."ST_ID"
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        anchors."ST_Stage" a
    WHERE
        a."ST_ID" = OLD."ST_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."ST_NAM_Stage_Name" x
        WHERE
            x."ST_NAM_ST_ID" = a."ST_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."ST_LOC_Stage_Location" x
        WHERE
            x."ST_LOC_ST_ID" = a."ST_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."ST_AVG_Stage_Average" x
        WHERE
            x."ST_AVG_ST_ID" = a."ST_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."ST_MIN_Stage_Minimum" x
        WHERE
            x."ST_MIN_ST_ID" = a."ST_ID"
    )
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lST_Stage" ON anchors."lST_Stage";
CREATE TRIGGER "dt_lST_Stage"
INSTEAD OF DELETE ON anchors."lST_Stage"
FOR EACH ROW EXECUTE FUNCTION anchors."dt_lST_Stage"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Actor instead of INSERT trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."it_lAC_Actor"()
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
        INSERT INTO anchors."AC_Actor" (
            "Metadata_AC"
        )
        VALUES (
            NEW."Metadata_AC"
        )
        RETURNING "AC_ID" INTO _id;
    END IF;
    IF NEW."AC_NAM_Actor_Name" IS NOT NULL THEN
        INSERT INTO attributes."AC_NAM_Actor_Name" (
            "Metadata_AC_NAM",
            "AC_NAM_AC_ID",
            "AC_NAM_ChangedAt",
            "AC_NAM_Actor_Name"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_NAM", NEW."Metadata_AC"),
            coalesce(NEW."AC_NAM_AC_ID", _id),
            coalesce(NEW."AC_NAM_ChangedAt", _now),
            NEW."AC_NAM_Actor_Name"
        );
    END IF;
    _GEN := NEW."AC_GEN_GEN_ID";
    IF _GEN IS NULL AND NEW."AC_GEN_GEN_Gender" IS NOT NULL THEN
        SELECT
            k."GEN_ID"
        INTO
            _GEN
        FROM
            knots."GEN_Gender" k
        WHERE
            k."GEN_Checksum" = decode(md5(NEW."AC_GEN_GEN_Gender"::text), 'hex')
        LIMIT 1;
    END IF;
    IF _GEN IS NOT NULL THEN
        INSERT INTO attributes."AC_GEN_Actor_Gender" (
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
    IF _PLV IS NULL AND NEW."AC_PLV_PLV_ProfessionalLevel" IS NOT NULL THEN
        SELECT
            k."PLV_ID"
        INTO
            _PLV
        FROM
            knots."PLV_ProfessionalLevel_EQ" k
        WHERE
            k."PLV_Checksum" = decode(md5(NEW."AC_PLV_PLV_ProfessionalLevel"::text), 'hex')
        AND
            k."PLV_EQ" = coalesce(NEW."AC_PLV_PLV_EQ", 0)
        LIMIT 1;
    END IF;
    IF _PLV IS NOT NULL THEN
        INSERT INTO attributes."AC_PLV_Actor_ProfessionalLevel" (
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
DROP TRIGGER IF EXISTS "it_lAC_Actor" ON anchors."lAC_Actor";
CREATE TRIGGER "it_lAC_Actor"
INSTEAD OF INSERT ON anchors."lAC_Actor"
FOR EACH ROW EXECUTE FUNCTION anchors."it_lAC_Actor"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_Actor instead of UPDATE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."ut_lAC_Actor"()
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
    IF NEW."AC_NAM_Actor_Name" IS DISTINCT FROM OLD."AC_NAM_Actor_Name"
    OR NEW."AC_NAM_ChangedAt" IS DISTINCT FROM OLD."AC_NAM_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."AC_NAM_Actor_Name" IS NOT NULL AND (
            NEW."AC_NAM_ChangedAt" IS DISTINCT FROM OLD."AC_NAM_ChangedAt" OR
            OLD."AC_NAM_Actor_Name" IS NULL OR
            OLD."AC_NAM_Actor_Name" <> NEW."AC_NAM_Actor_Name"
        ) THEN
            INSERT INTO attributes."AC_NAM_Actor_Name" (
                "Metadata_AC_NAM",
                "AC_NAM_AC_ID",
                "AC_NAM_ChangedAt",
                "AC_NAM_Actor_Name"
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
                NEW."AC_NAM_Actor_Name"
            );
        END IF;
    END IF;
    IF NEW."AC_GEN_AC_ID" IS DISTINCT FROM OLD."AC_GEN_AC_ID" THEN
        RAISE EXCEPTION 'The foreign key column AC_GEN_AC_ID is not updatable.';
    END IF;
    IF NEW."AC_GEN_GEN_ID" IS DISTINCT FROM OLD."AC_GEN_GEN_ID"
    OR NEW."AC_GEN_GEN_Gender" IS DISTINCT FROM OLD."AC_GEN_GEN_Gender"
    THEN
        _GEN := NEW."AC_GEN_GEN_ID";
        IF _GEN IS NOT DISTINCT FROM OLD."AC_GEN_GEN_ID" AND NEW."AC_GEN_GEN_Gender" IS NOT NULL THEN
            SELECT
                k."GEN_ID"
            INTO
                _GEN
            FROM
                knots."GEN_Gender" k
            WHERE
                k."GEN_Checksum" = decode(md5(NEW."AC_GEN_GEN_Gender"::text), 'hex')
            LIMIT 1;
        END IF;
        -- a value that is left as it is states nothing
        IF _GEN IS NOT NULL AND (
            OLD."AC_GEN_GEN_ID" IS NULL OR
            OLD."AC_GEN_GEN_ID" <> _GEN
        ) THEN
            INSERT INTO attributes."AC_GEN_Actor_Gender" (
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
    OR NEW."AC_PLV_PLV_ProfessionalLevel" IS DISTINCT FROM OLD."AC_PLV_PLV_ProfessionalLevel"
    OR NEW."AC_PLV_ChangedAt" IS DISTINCT FROM OLD."AC_PLV_ChangedAt"
    THEN
        _PLV := NEW."AC_PLV_PLV_ID";
        IF _PLV IS NOT DISTINCT FROM OLD."AC_PLV_PLV_ID" AND NEW."AC_PLV_PLV_ProfessionalLevel" IS NOT NULL THEN
            SELECT
                k."PLV_ID"
            INTO
                _PLV
            FROM
                knots."PLV_ProfessionalLevel_EQ" k
            WHERE
                k."PLV_Checksum" = decode(md5(NEW."AC_PLV_PLV_ProfessionalLevel"::text), 'hex')
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
            INSERT INTO attributes."AC_PLV_Actor_ProfessionalLevel" (
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
DROP TRIGGER IF EXISTS "ut_lAC_Actor" ON anchors."lAC_Actor";
CREATE TRIGGER "ut_lAC_Actor"
INSTEAD OF UPDATE ON anchors."lAC_Actor"
FOR EACH ROW EXECUTE FUNCTION anchors."ut_lAC_Actor"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_Actor instead of DELETE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dt_lAC_Actor"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        attributes."AC_NAM_Actor_Name" x
    WHERE
        x."AC_NAM_AC_ID" = OLD."AC_ID"
    AND
        x."AC_NAM_ChangedAt" = OLD."AC_NAM_ChangedAt"
    ;
    DELETE FROM
        attributes."AC_GEN_Actor_Gender" x
    WHERE
        x."AC_GEN_AC_ID" = OLD."AC_ID"
    ;
    DELETE FROM
        attributes."AC_PLV_Actor_ProfessionalLevel" x
    WHERE
        x."AC_PLV_AC_ID" = OLD."AC_ID"
    AND
        x."AC_PLV_ChangedAt" = OLD."AC_PLV_ChangedAt"
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        anchors."AC_Actor" a
    WHERE
        a."AC_ID" = OLD."AC_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."AC_NAM_Actor_Name" x
        WHERE
            x."AC_NAM_AC_ID" = a."AC_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."AC_GEN_Actor_Gender" x
        WHERE
            x."AC_GEN_AC_ID" = a."AC_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."AC_PLV_Actor_ProfessionalLevel" x
        WHERE
            x."AC_PLV_AC_ID" = a."AC_ID"
    )
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_Actor" ON anchors."lAC_Actor";
CREATE TRIGGER "dt_lAC_Actor"
INSTEAD OF DELETE ON anchors."lAC_Actor"
FOR EACH ROW EXECUTE FUNCTION anchors."dt_lAC_Actor"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Program instead of INSERT trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."it_lPR_Program"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id bigint;
BEGIN
    _id := NEW."PR_ID";
    IF _id IS NULL THEN
        INSERT INTO anchors."PR_Program" (
            "Metadata_PR"
        )
        VALUES (
            NEW."Metadata_PR"
        )
        RETURNING "PR_ID" INTO _id;
    END IF;
    IF NEW."PR_NAM_Program_Name" IS NOT NULL THEN
        INSERT INTO attributes."PR_NAM_Program_Name" (
            "Metadata_PR_NAM",
            "PR_NAM_PR_ID",
            "PR_NAM_Program_Name"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_NAM", NEW."Metadata_PR"),
            coalesce(NEW."PR_NAM_PR_ID", _id),
            NEW."PR_NAM_Program_Name"
        );
    END IF;
    IF NEW."PR_LEN_Program_Length" IS NOT NULL THEN
        INSERT INTO attributes."PR_LEN_Program_Length" (
            "Metadata_PR_LEN",
            "PR_LEN_PR_ID",
            "PR_LEN_EQ",
            "PR_LEN_ChangedAt",
            "PR_LEN_Program_Length"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_LEN", NEW."Metadata_PR"),
            coalesce(NEW."PR_LEN_PR_ID", _id),
            coalesce(NEW."PR_LEN_EQ", 0),
            coalesce(NEW."PR_LEN_ChangedAt", _now),
            NEW."PR_LEN_Program_Length"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lPR_Program" ON anchors."lPR_Program";
CREATE TRIGGER "it_lPR_Program"
INSTEAD OF INSERT ON anchors."lPR_Program"
FOR EACH ROW EXECUTE FUNCTION anchors."it_lPR_Program"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_Program instead of UPDATE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."ut_lPR_Program"()
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
    IF NEW."PR_NAM_Program_Name" IS DISTINCT FROM OLD."PR_NAM_Program_Name"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."PR_NAM_Program_Name" IS NOT NULL AND (
            OLD."PR_NAM_Program_Name" IS NULL OR
            OLD."PR_NAM_Program_Name" <> NEW."PR_NAM_Program_Name"
        ) THEN
            INSERT INTO attributes."PR_NAM_Program_Name" (
                "Metadata_PR_NAM",
                "PR_NAM_PR_ID",
                "PR_NAM_Program_Name"
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
                NEW."PR_NAM_Program_Name"
            );
        END IF;
    END IF;
    IF NEW."PR_LEN_PR_ID" IS DISTINCT FROM OLD."PR_LEN_PR_ID" THEN
        RAISE EXCEPTION 'The foreign key column PR_LEN_PR_ID is not updatable.';
    END IF;
    IF NEW."PR_LEN_Program_Length" IS DISTINCT FROM OLD."PR_LEN_Program_Length"
    OR NEW."PR_LEN_ChangedAt" IS DISTINCT FROM OLD."PR_LEN_ChangedAt"
    OR NEW."PR_LEN_EQ" IS DISTINCT FROM OLD."PR_LEN_EQ"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."PR_LEN_Program_Length" IS NOT NULL AND (
            NEW."PR_LEN_ChangedAt" IS DISTINCT FROM OLD."PR_LEN_ChangedAt" OR
            NEW."PR_LEN_EQ" IS DISTINCT FROM OLD."PR_LEN_EQ" OR
            OLD."PR_LEN_Program_Length" IS NULL OR
            OLD."PR_LEN_Program_Length" <> NEW."PR_LEN_Program_Length"
        ) THEN
            INSERT INTO attributes."PR_LEN_Program_Length" (
                "Metadata_PR_LEN",
                "PR_LEN_PR_ID",
                "PR_LEN_EQ",
                "PR_LEN_ChangedAt",
                "PR_LEN_Program_Length"
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
                NEW."PR_LEN_Program_Length"
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lPR_Program" ON anchors."lPR_Program";
CREATE TRIGGER "ut_lPR_Program"
INSTEAD OF UPDATE ON anchors."lPR_Program"
FOR EACH ROW EXECUTE FUNCTION anchors."ut_lPR_Program"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_Program instead of DELETE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dt_lPR_Program"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        attributes."PR_NAM_Program_Name" x
    WHERE
        x."PR_NAM_PR_ID" = OLD."PR_ID"
    ;
    DELETE FROM
        attributes."PR_LEN_Program_Length" x
    WHERE
        x."PR_LEN_PR_ID" = OLD."PR_ID"
    AND
        x."PR_LEN_EQ" = OLD."PR_LEN_EQ"
    AND
        x."PR_LEN_ChangedAt" = OLD."PR_LEN_ChangedAt"
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        anchors."PR_Program" a
    WHERE
        a."PR_ID" = OLD."PR_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."PR_NAM_Program_Name" x
        WHERE
            x."PR_NAM_PR_ID" = a."PR_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."PR_LEN_Program_Length" x
        WHERE
            x."PR_LEN_PR_ID" = a."PR_ID"
    )
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lPR_Program" ON anchors."lPR_Program";
CREATE TRIGGER "dt_lPR_Program"
INSTEAD OF DELETE ON anchors."lPR_Program"
FOR EACH ROW EXECUTE FUNCTION anchors."dt_lPR_Program"();
