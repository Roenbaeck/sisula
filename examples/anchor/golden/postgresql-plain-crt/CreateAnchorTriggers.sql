-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the assembled views of the attributes (whose triggers keep the
-- posit and annex tables) in a consistent way. Default values are used for some columns if not provided by the
-- corresponding SQL statements: the positor is 0, the changing and positing times are now, the reliability is 1.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates (the triggers of the attributes see to that).
--
-- PostgreSQL runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_Stage instead of INSERT trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lST_Stage"()
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
        INSERT INTO public."ST_Stage" (
            "ST_Dummy"
        )
        VALUES (
            null
        )
        RETURNING "ST_ID" INTO _id;
    END IF;
    IF NEW."ST_NAM_Stage_Name" IS NOT NULL THEN
        INSERT INTO public."ST_NAM_Stage_Name" (
            "ST_ID",
            "ST_NAM_Stage_Name",
            "ST_NAM_ChangedAt",
            "ST_NAM_Positor",
            "ST_NAM_PositedAt",
            "ST_NAM_Reliability"
        )
        VALUES (
            _id,
            NEW."ST_NAM_Stage_Name",
            coalesce(NEW."ST_NAM_ChangedAt", _now),
            coalesce(NEW."ST_NAM_Positor", NEW."Positor", 0),
            coalesce(NEW."ST_NAM_PositedAt", _now),
            coalesce(NEW."ST_NAM_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."ST_LOC_Stage_Location" IS NOT NULL THEN
        INSERT INTO public."ST_LOC_Stage_Location" (
            "ST_ID",
            "ST_LOC_Stage_Location",
            "ST_LOC_Positor",
            "ST_LOC_PositedAt",
            "ST_LOC_Reliability"
        )
        VALUES (
            _id,
            NEW."ST_LOC_Stage_Location",
            coalesce(NEW."ST_LOC_Positor", NEW."Positor", 0),
            coalesce(NEW."ST_LOC_PositedAt", _now),
            coalesce(NEW."ST_LOC_Reliability", NEW."Reliability", 1)
        );
    END IF;
    _AVG := NEW."UTL_ID";
    IF _AVG IS NULL AND NEW."UTL_Utilization" IS NOT NULL THEN
        SELECT
            k."UTL_ID"
        INTO
            _AVG
        FROM
            public."UTL_Utilization" k
        WHERE
            k."UTL_Utilization" = NEW."UTL_Utilization"
        LIMIT 1;
    END IF;
    IF _AVG IS NOT NULL THEN
        INSERT INTO public."ST_AVG_Stage_Average" (
            "ST_ID",
            "UTL_ID",
            "ST_AVG_ChangedAt",
            "ST_AVG_Positor",
            "ST_AVG_PositedAt",
            "ST_AVG_Reliability"
        )
        VALUES (
            _id,
            _AVG,
            coalesce(NEW."ST_AVG_ChangedAt", _now),
            coalesce(NEW."ST_AVG_Positor", NEW."Positor", 0),
            coalesce(NEW."ST_AVG_PositedAt", _now),
            coalesce(NEW."ST_AVG_Reliability", NEW."Reliability", 1)
        );
    END IF;
    _MIN := NEW."UTL_ID";
    IF _MIN IS NULL AND NEW."UTL_Utilization" IS NOT NULL THEN
        SELECT
            k."UTL_ID"
        INTO
            _MIN
        FROM
            public."UTL_Utilization" k
        WHERE
            k."UTL_Utilization" = NEW."UTL_Utilization"
        LIMIT 1;
    END IF;
    IF _MIN IS NOT NULL THEN
        INSERT INTO public."ST_MIN_Stage_Minimum" (
            "ST_ID",
            "UTL_ID",
            "ST_MIN_Positor",
            "ST_MIN_PositedAt",
            "ST_MIN_Reliability"
        )
        VALUES (
            _id,
            _MIN,
            coalesce(NEW."ST_MIN_Positor", NEW."Positor", 0),
            coalesce(NEW."ST_MIN_PositedAt", _now),
            coalesce(NEW."ST_MIN_Reliability", NEW."Reliability", 1)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lST_Stage" ON public."lST_Stage";
CREATE TRIGGER "it_lST_Stage"
INSTEAD OF INSERT ON public."lST_Stage"
FOR EACH ROW EXECUTE FUNCTION public."it_lST_Stage"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Stage instead of UPDATE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lST_Stage"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _reliability decimal(5,2);
    _positing timestamp;
    _positor smallint;
    _AVG smallint;
    _MIN smallint;
BEGIN
    IF NEW."ST_ID" IS DISTINCT FROM OLD."ST_ID" THEN
        RAISE EXCEPTION 'The identity column ST_ID is not updatable.';
    END IF;
    IF NEW."ST_NAM_ID" IS DISTINCT FROM OLD."ST_NAM_ID" THEN
        RAISE EXCEPTION 'The identity column ST_NAM_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of ST_NAM_Stage_Name, and when it posits
    _reliability := CASE
        WHEN NEW."ST_NAM_Reliability" IS DISTINCT FROM OLD."ST_NAM_Reliability" THEN NEW."ST_NAM_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."ST_NAM_Reliability"
    END;
    _positor := coalesce(CASE
        WHEN NEW."ST_NAM_Positor" IS DISTINCT FROM OLD."ST_NAM_Positor" THEN NEW."ST_NAM_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."ST_NAM_PositedAt" IS DISTINCT FROM OLD."ST_NAM_PositedAt" THEN NEW."ST_NAM_PositedAt"
        WHEN NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt" AND NEW."ST_NAM_Stage_Name" IS NULL THEN NEW."ST_NAM_ChangedAt"
        ELSE _now
    END;
    IF NEW."ST_NAM_Stage_Name" IS DISTINCT FROM OLD."ST_NAM_Stage_Name"
    OR NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt"
    OR NEW."ST_NAM_PositedAt" IS DISTINCT FROM OLD."ST_NAM_PositedAt"
    OR NEW."ST_NAM_Reliability" IS DISTINCT FROM OLD."ST_NAM_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."ST_NAM_Stage_Name" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."ST_NAM_Stage_Name" IS NULL
            OR NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt"
            OR NEW."ST_NAM_PositedAt" IS DISTINCT FROM OLD."ST_NAM_PositedAt"
            OR OLD."ST_NAM_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."ST_NAM_Positor" IS DISTINCT FROM _positor
            OR OLD."ST_NAM_Stage_Name" <> NEW."ST_NAM_Stage_Name"
            THEN
                INSERT INTO public."ST_NAM_Stage_Name" (
                    "ST_ID",
                    "ST_NAM_Stage_Name",
                    "ST_NAM_ChangedAt",
                    "ST_NAM_Positor",
                    "ST_NAM_PositedAt",
                    "ST_NAM_Reliability"
                )
                VALUES (
                    NEW."ST_ID",
                    NEW."ST_NAM_Stage_Name",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt" THEN NEW."ST_NAM_ChangedAt"
                        WHEN OLD."ST_NAM_Stage_Name" = NEW."ST_NAM_Stage_Name" THEN NEW."ST_NAM_ChangedAt"
                        ELSE _now
                    END,
                    _positor,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."ST_NAM_Stage_Name" IS NULL AND OLD."ST_NAM_Stage_Name" IS NOT NULL THEN
            INSERT INTO public."ST_NAM_Stage_Name" (
                "ST_ID",
                "ST_NAM_Stage_Name",
                "ST_NAM_ChangedAt",
                "ST_NAM_Positor",
                "ST_NAM_PositedAt",
                "ST_NAM_Reliability"
            )
            SELECT
                p."ST_ID",
                p."ST_NAM_Stage_Name",
                p."ST_NAM_ChangedAt",
                _positor,
                _positing,
                0
            FROM
                public."ST_NAM_Stage_Name_Posit" p
            WHERE
                p."ST_NAM_ID" = OLD."ST_NAM_ID";
        END IF;
    END IF;
    IF NEW."ST_LOC_ID" IS DISTINCT FROM OLD."ST_LOC_ID" THEN
        RAISE EXCEPTION 'The identity column ST_LOC_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of ST_LOC_Stage_Location, and when it posits
    _reliability := CASE
        WHEN NEW."ST_LOC_Reliability" IS DISTINCT FROM OLD."ST_LOC_Reliability" THEN NEW."ST_LOC_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."ST_LOC_Reliability"
    END;
    _positor := coalesce(CASE
        WHEN NEW."ST_LOC_Positor" IS DISTINCT FROM OLD."ST_LOC_Positor" THEN NEW."ST_LOC_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."ST_LOC_PositedAt" IS DISTINCT FROM OLD."ST_LOC_PositedAt" THEN NEW."ST_LOC_PositedAt"
        ELSE _now
    END;
    IF NEW."ST_LOC_Stage_Location" IS DISTINCT FROM OLD."ST_LOC_Stage_Location"
    OR NEW."ST_LOC_PositedAt" IS DISTINCT FROM OLD."ST_LOC_PositedAt"
    OR NEW."ST_LOC_Reliability" IS DISTINCT FROM OLD."ST_LOC_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."ST_LOC_Stage_Location" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."ST_LOC_Stage_Location" IS NULL
            OR NEW."ST_LOC_PositedAt" IS DISTINCT FROM OLD."ST_LOC_PositedAt"
            OR OLD."ST_LOC_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."ST_LOC_Positor" IS DISTINCT FROM _positor
            OR md5(OLD."ST_LOC_Stage_Location"::text) <> md5(NEW."ST_LOC_Stage_Location"::text)
            THEN
                INSERT INTO public."ST_LOC_Stage_Location" (
                    "ST_ID",
                    "ST_LOC_Stage_Location",
                    "ST_LOC_Positor",
                    "ST_LOC_PositedAt",
                    "ST_LOC_Reliability"
                )
                VALUES (
                    NEW."ST_ID",
                    NEW."ST_LOC_Stage_Location",
                    _positor,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."ST_LOC_Stage_Location" IS NULL AND OLD."ST_LOC_Stage_Location" IS NOT NULL THEN
            INSERT INTO public."ST_LOC_Stage_Location" (
                "ST_ID",
                "ST_LOC_Stage_Location",
                "ST_LOC_Positor",
                "ST_LOC_PositedAt",
                "ST_LOC_Reliability"
            )
            SELECT
                p."ST_ID",
                p."ST_LOC_Stage_Location",
                _positor,
                _positing,
                0
            FROM
                public."ST_LOC_Stage_Location_Posit" p
            WHERE
                p."ST_LOC_ID" = OLD."ST_LOC_ID";
        END IF;
    END IF;
    IF NEW."ST_AVG_ID" IS DISTINCT FROM OLD."ST_AVG_ID" THEN
        RAISE EXCEPTION 'The identity column ST_AVG_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of ST_AVG_Stage_Average, and when it posits
    _reliability := CASE
        WHEN NEW."ST_AVG_Reliability" IS DISTINCT FROM OLD."ST_AVG_Reliability" THEN NEW."ST_AVG_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."ST_AVG_Reliability"
    END;
    _positor := coalesce(CASE
        WHEN NEW."ST_AVG_Positor" IS DISTINCT FROM OLD."ST_AVG_Positor" THEN NEW."ST_AVG_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."ST_AVG_PositedAt" IS DISTINCT FROM OLD."ST_AVG_PositedAt" THEN NEW."ST_AVG_PositedAt"
        WHEN NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt" AND NEW."UTL_ID" IS NULL THEN NEW."ST_AVG_ChangedAt"
        ELSE _now
    END;
    _AVG := NEW."UTL_ID";
    IF _AVG IS NOT DISTINCT FROM OLD."UTL_ID" AND NEW."UTL_Utilization" IS DISTINCT FROM OLD."UTL_Utilization" THEN
        _AVG := NULL;
        IF NEW."UTL_Utilization" IS NOT NULL THEN
            SELECT
                k."UTL_ID"
            INTO
                _AVG
            FROM
                public."UTL_Utilization" k
            WHERE
                k."UTL_Utilization" = NEW."UTL_Utilization"
            LIMIT 1;
        END IF;
    END IF;
    IF NEW."UTL_ID" IS DISTINCT FROM OLD."UTL_ID"
    OR NEW."UTL_Utilization" IS DISTINCT FROM OLD."UTL_Utilization"
    OR NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt"
    OR NEW."ST_AVG_PositedAt" IS DISTINCT FROM OLD."ST_AVG_PositedAt"
    OR NEW."ST_AVG_Reliability" IS DISTINCT FROM OLD."ST_AVG_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF _AVG IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."UTL_ID" IS NULL
            OR NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt"
            OR NEW."ST_AVG_PositedAt" IS DISTINCT FROM OLD."ST_AVG_PositedAt"
            OR OLD."ST_AVG_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."ST_AVG_Positor" IS DISTINCT FROM _positor
            OR OLD."UTL_ID" <> _AVG
            THEN
                INSERT INTO public."ST_AVG_Stage_Average" (
                    "ST_ID",
                    "UTL_ID",
                    "ST_AVG_ChangedAt",
                    "ST_AVG_Positor",
                    "ST_AVG_PositedAt",
                    "ST_AVG_Reliability"
                )
                VALUES (
                    NEW."ST_ID",
                    _AVG,
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt" THEN NEW."ST_AVG_ChangedAt"
                        WHEN OLD."UTL_ID" = _AVG THEN NEW."ST_AVG_ChangedAt"
                        ELSE _now
                    END,
                    _positor,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."UTL_ID" IS NOT NULL AND (
            NEW."UTL_ID" IS NULL OR (
                NEW."UTL_ID" = OLD."UTL_ID"
                AND NEW."UTL_Utilization" IS NULL AND OLD."UTL_Utilization" IS NOT NULL
            )
        ) THEN
            INSERT INTO public."ST_AVG_Stage_Average" (
                "ST_ID",
                "UTL_ID",
                "ST_AVG_ChangedAt",
                "ST_AVG_Positor",
                "ST_AVG_PositedAt",
                "ST_AVG_Reliability"
            )
            SELECT
                p."ST_ID",
                p."UTL_ID",
                p."ST_AVG_ChangedAt",
                _positor,
                _positing,
                0
            FROM
                public."ST_AVG_Stage_Average_Posit" p
            WHERE
                p."ST_AVG_ID" = OLD."ST_AVG_ID";
        END IF;
    END IF;
    IF NEW."ST_MIN_ID" IS DISTINCT FROM OLD."ST_MIN_ID" THEN
        RAISE EXCEPTION 'The identity column ST_MIN_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of ST_MIN_Stage_Minimum, and when it posits
    _reliability := CASE
        WHEN NEW."ST_MIN_Reliability" IS DISTINCT FROM OLD."ST_MIN_Reliability" THEN NEW."ST_MIN_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."ST_MIN_Reliability"
    END;
    _positor := coalesce(CASE
        WHEN NEW."ST_MIN_Positor" IS DISTINCT FROM OLD."ST_MIN_Positor" THEN NEW."ST_MIN_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."ST_MIN_PositedAt" IS DISTINCT FROM OLD."ST_MIN_PositedAt" THEN NEW."ST_MIN_PositedAt"
        ELSE _now
    END;
    _MIN := NEW."UTL_ID";
    IF _MIN IS NOT DISTINCT FROM OLD."UTL_ID" AND NEW."UTL_Utilization" IS DISTINCT FROM OLD."UTL_Utilization" THEN
        _MIN := NULL;
        IF NEW."UTL_Utilization" IS NOT NULL THEN
            SELECT
                k."UTL_ID"
            INTO
                _MIN
            FROM
                public."UTL_Utilization" k
            WHERE
                k."UTL_Utilization" = NEW."UTL_Utilization"
            LIMIT 1;
        END IF;
    END IF;
    IF NEW."UTL_ID" IS DISTINCT FROM OLD."UTL_ID"
    OR NEW."UTL_Utilization" IS DISTINCT FROM OLD."UTL_Utilization"
    OR NEW."ST_MIN_PositedAt" IS DISTINCT FROM OLD."ST_MIN_PositedAt"
    OR NEW."ST_MIN_Reliability" IS DISTINCT FROM OLD."ST_MIN_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF _MIN IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."UTL_ID" IS NULL
            OR NEW."ST_MIN_PositedAt" IS DISTINCT FROM OLD."ST_MIN_PositedAt"
            OR OLD."ST_MIN_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."ST_MIN_Positor" IS DISTINCT FROM _positor
            OR OLD."UTL_ID" <> _MIN
            THEN
                INSERT INTO public."ST_MIN_Stage_Minimum" (
                    "ST_ID",
                    "UTL_ID",
                    "ST_MIN_Positor",
                    "ST_MIN_PositedAt",
                    "ST_MIN_Reliability"
                )
                VALUES (
                    NEW."ST_ID",
                    _MIN,
                    _positor,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."UTL_ID" IS NOT NULL AND (
            NEW."UTL_ID" IS NULL OR (
                NEW."UTL_ID" = OLD."UTL_ID"
                AND NEW."UTL_Utilization" IS NULL AND OLD."UTL_Utilization" IS NOT NULL
            )
        ) THEN
            INSERT INTO public."ST_MIN_Stage_Minimum" (
                "ST_ID",
                "UTL_ID",
                "ST_MIN_Positor",
                "ST_MIN_PositedAt",
                "ST_MIN_Reliability"
            )
            SELECT
                p."ST_ID",
                p."UTL_ID",
                _positor,
                _positing,
                0
            FROM
                public."ST_MIN_Stage_Minimum_Posit" p
            WHERE
                p."ST_MIN_ID" = OLD."ST_MIN_ID";
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lST_Stage" ON public."lST_Stage";
CREATE TRIGGER "ut_lST_Stage"
INSTEAD OF UPDATE ON public."lST_Stage"
FOR EACH ROW EXECUTE FUNCTION public."ut_lST_Stage"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Stage instead of DELETE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lST_Stage"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown of ST_NAM_Stage_Name is retracted
    INSERT INTO public."ST_NAM_Stage_Name_Annex" (
        "ST_NAM_ID",
        "ST_NAM_Positor",
        "ST_NAM_PositedAt",
        "ST_NAM_Reliability"
    )
    SELECT
        OLD."ST_NAM_ID",
        coalesce(OLD."ST_NAM_Positor", OLD."Positor", 0),
        _now,
        0
    WHERE
        OLD."ST_NAM_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of ST_LOC_Stage_Location is retracted
    INSERT INTO public."ST_LOC_Stage_Location_Annex" (
        "ST_LOC_ID",
        "ST_LOC_Positor",
        "ST_LOC_PositedAt",
        "ST_LOC_Reliability"
    )
    SELECT
        OLD."ST_LOC_ID",
        coalesce(OLD."ST_LOC_Positor", OLD."Positor", 0),
        _now,
        0
    WHERE
        OLD."ST_LOC_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of ST_AVG_Stage_Average is retracted
    INSERT INTO public."ST_AVG_Stage_Average_Annex" (
        "ST_AVG_ID",
        "ST_AVG_Positor",
        "ST_AVG_PositedAt",
        "ST_AVG_Reliability"
    )
    SELECT
        OLD."ST_AVG_ID",
        coalesce(OLD."ST_AVG_Positor", OLD."Positor", 0),
        _now,
        0
    WHERE
        OLD."ST_AVG_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of ST_MIN_Stage_Minimum is retracted
    INSERT INTO public."ST_MIN_Stage_Minimum_Annex" (
        "ST_MIN_ID",
        "ST_MIN_Positor",
        "ST_MIN_PositedAt",
        "ST_MIN_Reliability"
    )
    SELECT
        OLD."ST_MIN_ID",
        coalesce(OLD."ST_MIN_Positor", OLD."Positor", 0),
        _now,
        0
    WHERE
        OLD."ST_MIN_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lST_Stage" ON public."lST_Stage";
CREATE TRIGGER "dt_lST_Stage"
INSTEAD OF DELETE ON public."lST_Stage"
FOR EACH ROW EXECUTE FUNCTION public."dt_lST_Stage"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Actor instead of INSERT trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lAC_Actor"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id integer;
    _GEN smallint;
    _PLV smallint;
BEGIN
    _id := NEW."AC_ID";
    IF _id IS NULL THEN
        INSERT INTO public."AC_Actor" (
            "AC_Dummy"
        )
        VALUES (
            null
        )
        RETURNING "AC_ID" INTO _id;
    END IF;
    IF NEW."AC_NAM_Actor_Name" IS NOT NULL THEN
        INSERT INTO public."AC_NAM_Actor_Name" (
            "AC_ID",
            "AC_NAM_Actor_Name",
            "AC_NAM_ChangedAt",
            "AC_NAM_Positor",
            "AC_NAM_PositedAt",
            "AC_NAM_Reliability"
        )
        VALUES (
            _id,
            NEW."AC_NAM_Actor_Name",
            coalesce(NEW."AC_NAM_ChangedAt", _now),
            coalesce(NEW."AC_NAM_Positor", NEW."Positor", 0),
            coalesce(NEW."AC_NAM_PositedAt", _now),
            coalesce(NEW."AC_NAM_Reliability", NEW."Reliability", 1)
        );
    END IF;
    _GEN := NEW."GEN_ID";
    IF _GEN IS NULL AND NEW."GEN_Gender" IS NOT NULL THEN
        SELECT
            k."GEN_ID"
        INTO
            _GEN
        FROM
            public."GEN_Gender" k
        WHERE
            k."GEN_Gender" = NEW."GEN_Gender"
        LIMIT 1;
    END IF;
    IF _GEN IS NOT NULL THEN
        INSERT INTO public."AC_GEN_Actor_Gender" (
            "AC_ID",
            "GEN_ID",
            "AC_GEN_Positor",
            "AC_GEN_PositedAt",
            "AC_GEN_Reliability"
        )
        VALUES (
            _id,
            _GEN,
            coalesce(NEW."AC_GEN_Positor", NEW."Positor", 0),
            coalesce(NEW."AC_GEN_PositedAt", _now),
            coalesce(NEW."AC_GEN_Reliability", NEW."Reliability", 1)
        );
    END IF;
    _PLV := NEW."PLV_ID";
    IF _PLV IS NULL AND NEW."PLV_ProfessionalLevel" IS NOT NULL THEN
        SELECT
            k."PLV_ID"
        INTO
            _PLV
        FROM
            public."PLV_ProfessionalLevel" k
        WHERE
            k."PLV_Checksum" = decode(md5(NEW."PLV_ProfessionalLevel"::text), 'hex')
        LIMIT 1;
    END IF;
    IF _PLV IS NOT NULL THEN
        INSERT INTO public."AC_PLV_Actor_ProfessionalLevel" (
            "AC_ID",
            "PLV_ID",
            "AC_PLV_ChangedAt",
            "AC_PLV_Positor",
            "AC_PLV_PositedAt",
            "AC_PLV_Reliability"
        )
        VALUES (
            _id,
            _PLV,
            coalesce(NEW."AC_PLV_ChangedAt", _now),
            coalesce(NEW."AC_PLV_Positor", NEW."Positor", 0),
            coalesce(NEW."AC_PLV_PositedAt", _now),
            coalesce(NEW."AC_PLV_Reliability", NEW."Reliability", 1)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lAC_Actor" ON public."lAC_Actor";
CREATE TRIGGER "it_lAC_Actor"
INSTEAD OF INSERT ON public."lAC_Actor"
FOR EACH ROW EXECUTE FUNCTION public."it_lAC_Actor"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_Actor instead of UPDATE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lAC_Actor"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _reliability decimal(5,2);
    _positing timestamp;
    _positor smallint;
    _GEN smallint;
    _PLV smallint;
BEGIN
    IF NEW."AC_ID" IS DISTINCT FROM OLD."AC_ID" THEN
        RAISE EXCEPTION 'The identity column AC_ID is not updatable.';
    END IF;
    IF NEW."AC_NAM_ID" IS DISTINCT FROM OLD."AC_NAM_ID" THEN
        RAISE EXCEPTION 'The identity column AC_NAM_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of AC_NAM_Actor_Name, and when it posits
    _reliability := CASE
        WHEN NEW."AC_NAM_Reliability" IS DISTINCT FROM OLD."AC_NAM_Reliability" THEN NEW."AC_NAM_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."AC_NAM_Reliability"
    END;
    _positor := coalesce(CASE
        WHEN NEW."AC_NAM_Positor" IS DISTINCT FROM OLD."AC_NAM_Positor" THEN NEW."AC_NAM_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."AC_NAM_PositedAt" IS DISTINCT FROM OLD."AC_NAM_PositedAt" THEN NEW."AC_NAM_PositedAt"
        WHEN NEW."AC_NAM_ChangedAt" IS DISTINCT FROM OLD."AC_NAM_ChangedAt" AND NEW."AC_NAM_Actor_Name" IS NULL THEN NEW."AC_NAM_ChangedAt"
        ELSE _now
    END;
    IF NEW."AC_NAM_Actor_Name" IS DISTINCT FROM OLD."AC_NAM_Actor_Name"
    OR NEW."AC_NAM_ChangedAt" IS DISTINCT FROM OLD."AC_NAM_ChangedAt"
    OR NEW."AC_NAM_PositedAt" IS DISTINCT FROM OLD."AC_NAM_PositedAt"
    OR NEW."AC_NAM_Reliability" IS DISTINCT FROM OLD."AC_NAM_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."AC_NAM_Actor_Name" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."AC_NAM_Actor_Name" IS NULL
            OR NEW."AC_NAM_ChangedAt" IS DISTINCT FROM OLD."AC_NAM_ChangedAt"
            OR NEW."AC_NAM_PositedAt" IS DISTINCT FROM OLD."AC_NAM_PositedAt"
            OR OLD."AC_NAM_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."AC_NAM_Positor" IS DISTINCT FROM _positor
            OR OLD."AC_NAM_Actor_Name" <> NEW."AC_NAM_Actor_Name"
            THEN
                INSERT INTO public."AC_NAM_Actor_Name" (
                    "AC_ID",
                    "AC_NAM_Actor_Name",
                    "AC_NAM_ChangedAt",
                    "AC_NAM_Positor",
                    "AC_NAM_PositedAt",
                    "AC_NAM_Reliability"
                )
                VALUES (
                    NEW."AC_ID",
                    NEW."AC_NAM_Actor_Name",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."AC_NAM_ChangedAt" IS DISTINCT FROM OLD."AC_NAM_ChangedAt" THEN NEW."AC_NAM_ChangedAt"
                        WHEN OLD."AC_NAM_Actor_Name" = NEW."AC_NAM_Actor_Name" THEN NEW."AC_NAM_ChangedAt"
                        ELSE _now
                    END,
                    _positor,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."AC_NAM_Actor_Name" IS NULL AND OLD."AC_NAM_Actor_Name" IS NOT NULL THEN
            INSERT INTO public."AC_NAM_Actor_Name" (
                "AC_ID",
                "AC_NAM_Actor_Name",
                "AC_NAM_ChangedAt",
                "AC_NAM_Positor",
                "AC_NAM_PositedAt",
                "AC_NAM_Reliability"
            )
            SELECT
                p."AC_ID",
                p."AC_NAM_Actor_Name",
                p."AC_NAM_ChangedAt",
                _positor,
                _positing,
                0
            FROM
                public."AC_NAM_Actor_Name_Posit" p
            WHERE
                p."AC_NAM_ID" = OLD."AC_NAM_ID";
        END IF;
    END IF;
    IF NEW."AC_GEN_ID" IS DISTINCT FROM OLD."AC_GEN_ID" THEN
        RAISE EXCEPTION 'The identity column AC_GEN_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of AC_GEN_Actor_Gender, and when it posits
    _reliability := CASE
        WHEN NEW."AC_GEN_Reliability" IS DISTINCT FROM OLD."AC_GEN_Reliability" THEN NEW."AC_GEN_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."AC_GEN_Reliability"
    END;
    _positor := coalesce(CASE
        WHEN NEW."AC_GEN_Positor" IS DISTINCT FROM OLD."AC_GEN_Positor" THEN NEW."AC_GEN_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."AC_GEN_PositedAt" IS DISTINCT FROM OLD."AC_GEN_PositedAt" THEN NEW."AC_GEN_PositedAt"
        ELSE _now
    END;
    _GEN := NEW."GEN_ID";
    IF _GEN IS NOT DISTINCT FROM OLD."GEN_ID" AND NEW."GEN_Gender" IS DISTINCT FROM OLD."GEN_Gender" THEN
        _GEN := NULL;
        IF NEW."GEN_Gender" IS NOT NULL THEN
            SELECT
                k."GEN_ID"
            INTO
                _GEN
            FROM
                public."GEN_Gender" k
            WHERE
                k."GEN_Gender" = NEW."GEN_Gender"
            LIMIT 1;
        END IF;
    END IF;
    IF NEW."GEN_ID" IS DISTINCT FROM OLD."GEN_ID"
    OR NEW."GEN_Gender" IS DISTINCT FROM OLD."GEN_Gender"
    OR NEW."AC_GEN_PositedAt" IS DISTINCT FROM OLD."AC_GEN_PositedAt"
    OR NEW."AC_GEN_Reliability" IS DISTINCT FROM OLD."AC_GEN_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF _GEN IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."GEN_ID" IS NULL
            OR NEW."AC_GEN_PositedAt" IS DISTINCT FROM OLD."AC_GEN_PositedAt"
            OR OLD."AC_GEN_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."AC_GEN_Positor" IS DISTINCT FROM _positor
            OR OLD."GEN_ID" <> _GEN
            THEN
                INSERT INTO public."AC_GEN_Actor_Gender" (
                    "AC_ID",
                    "GEN_ID",
                    "AC_GEN_Positor",
                    "AC_GEN_PositedAt",
                    "AC_GEN_Reliability"
                )
                VALUES (
                    NEW."AC_ID",
                    _GEN,
                    _positor,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."GEN_ID" IS NOT NULL AND (
            NEW."GEN_ID" IS NULL OR (
                NEW."GEN_ID" = OLD."GEN_ID"
                AND NEW."GEN_Gender" IS NULL AND OLD."GEN_Gender" IS NOT NULL
            )
        ) THEN
            INSERT INTO public."AC_GEN_Actor_Gender" (
                "AC_ID",
                "GEN_ID",
                "AC_GEN_Positor",
                "AC_GEN_PositedAt",
                "AC_GEN_Reliability"
            )
            SELECT
                p."AC_ID",
                p."GEN_ID",
                _positor,
                _positing,
                0
            FROM
                public."AC_GEN_Actor_Gender_Posit" p
            WHERE
                p."AC_GEN_ID" = OLD."AC_GEN_ID";
        END IF;
    END IF;
    IF NEW."AC_PLV_ID" IS DISTINCT FROM OLD."AC_PLV_ID" THEN
        RAISE EXCEPTION 'The identity column AC_PLV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of AC_PLV_Actor_ProfessionalLevel, and when it posits
    _reliability := CASE
        WHEN NEW."AC_PLV_Reliability" IS DISTINCT FROM OLD."AC_PLV_Reliability" THEN NEW."AC_PLV_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."AC_PLV_Reliability"
    END;
    _positor := coalesce(CASE
        WHEN NEW."AC_PLV_Positor" IS DISTINCT FROM OLD."AC_PLV_Positor" THEN NEW."AC_PLV_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."AC_PLV_PositedAt" IS DISTINCT FROM OLD."AC_PLV_PositedAt" THEN NEW."AC_PLV_PositedAt"
        WHEN NEW."AC_PLV_ChangedAt" IS DISTINCT FROM OLD."AC_PLV_ChangedAt" AND NEW."PLV_ID" IS NULL THEN NEW."AC_PLV_ChangedAt"
        ELSE _now
    END;
    _PLV := NEW."PLV_ID";
    IF _PLV IS NOT DISTINCT FROM OLD."PLV_ID" AND NEW."PLV_ProfessionalLevel" IS DISTINCT FROM OLD."PLV_ProfessionalLevel" THEN
        _PLV := NULL;
        IF NEW."PLV_ProfessionalLevel" IS NOT NULL THEN
            SELECT
                k."PLV_ID"
            INTO
                _PLV
            FROM
                public."PLV_ProfessionalLevel" k
            WHERE
                k."PLV_Checksum" = decode(md5(NEW."PLV_ProfessionalLevel"::text), 'hex')
            LIMIT 1;
        END IF;
    END IF;
    IF NEW."PLV_ID" IS DISTINCT FROM OLD."PLV_ID"
    OR NEW."PLV_ProfessionalLevel" IS DISTINCT FROM OLD."PLV_ProfessionalLevel"
    OR NEW."AC_PLV_ChangedAt" IS DISTINCT FROM OLD."AC_PLV_ChangedAt"
    OR NEW."AC_PLV_PositedAt" IS DISTINCT FROM OLD."AC_PLV_PositedAt"
    OR NEW."AC_PLV_Reliability" IS DISTINCT FROM OLD."AC_PLV_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF _PLV IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."PLV_ID" IS NULL
            OR NEW."AC_PLV_ChangedAt" IS DISTINCT FROM OLD."AC_PLV_ChangedAt"
            OR NEW."AC_PLV_PositedAt" IS DISTINCT FROM OLD."AC_PLV_PositedAt"
            OR OLD."AC_PLV_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."AC_PLV_Positor" IS DISTINCT FROM _positor
            OR OLD."PLV_ID" <> _PLV
            THEN
                INSERT INTO public."AC_PLV_Actor_ProfessionalLevel" (
                    "AC_ID",
                    "PLV_ID",
                    "AC_PLV_ChangedAt",
                    "AC_PLV_Positor",
                    "AC_PLV_PositedAt",
                    "AC_PLV_Reliability"
                )
                VALUES (
                    NEW."AC_ID",
                    _PLV,
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."AC_PLV_ChangedAt" IS DISTINCT FROM OLD."AC_PLV_ChangedAt" THEN NEW."AC_PLV_ChangedAt"
                        WHEN OLD."PLV_ID" = _PLV THEN NEW."AC_PLV_ChangedAt"
                        ELSE _now
                    END,
                    _positor,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."PLV_ID" IS NOT NULL AND (
            NEW."PLV_ID" IS NULL OR (
                NEW."PLV_ID" = OLD."PLV_ID"
                AND NEW."PLV_ProfessionalLevel" IS NULL AND OLD."PLV_ProfessionalLevel" IS NOT NULL
            )
        ) THEN
            INSERT INTO public."AC_PLV_Actor_ProfessionalLevel" (
                "AC_ID",
                "PLV_ID",
                "AC_PLV_ChangedAt",
                "AC_PLV_Positor",
                "AC_PLV_PositedAt",
                "AC_PLV_Reliability"
            )
            SELECT
                p."AC_ID",
                p."PLV_ID",
                p."AC_PLV_ChangedAt",
                _positor,
                _positing,
                0
            FROM
                public."AC_PLV_Actor_ProfessionalLevel_Posit" p
            WHERE
                p."AC_PLV_ID" = OLD."AC_PLV_ID";
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lAC_Actor" ON public."lAC_Actor";
CREATE TRIGGER "ut_lAC_Actor"
INSTEAD OF UPDATE ON public."lAC_Actor"
FOR EACH ROW EXECUTE FUNCTION public."ut_lAC_Actor"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_Actor instead of DELETE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lAC_Actor"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown of AC_NAM_Actor_Name is retracted
    INSERT INTO public."AC_NAM_Actor_Name_Annex" (
        "AC_NAM_ID",
        "AC_NAM_Positor",
        "AC_NAM_PositedAt",
        "AC_NAM_Reliability"
    )
    SELECT
        OLD."AC_NAM_ID",
        coalesce(OLD."AC_NAM_Positor", OLD."Positor", 0),
        _now,
        0
    WHERE
        OLD."AC_NAM_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of AC_GEN_Actor_Gender is retracted
    INSERT INTO public."AC_GEN_Actor_Gender_Annex" (
        "AC_GEN_ID",
        "AC_GEN_Positor",
        "AC_GEN_PositedAt",
        "AC_GEN_Reliability"
    )
    SELECT
        OLD."AC_GEN_ID",
        coalesce(OLD."AC_GEN_Positor", OLD."Positor", 0),
        _now,
        0
    WHERE
        OLD."AC_GEN_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of AC_PLV_Actor_ProfessionalLevel is retracted
    INSERT INTO public."AC_PLV_Actor_ProfessionalLevel_Annex" (
        "AC_PLV_ID",
        "AC_PLV_Positor",
        "AC_PLV_PositedAt",
        "AC_PLV_Reliability"
    )
    SELECT
        OLD."AC_PLV_ID",
        coalesce(OLD."AC_PLV_Positor", OLD."Positor", 0),
        _now,
        0
    WHERE
        OLD."AC_PLV_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_Actor" ON public."lAC_Actor";
CREATE TRIGGER "dt_lAC_Actor"
INSTEAD OF DELETE ON public."lAC_Actor"
FOR EACH ROW EXECUTE FUNCTION public."dt_lAC_Actor"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Program instead of INSERT trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lPR_Program"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id integer;
BEGIN
    _id := NEW."PR_ID";
    IF _id IS NULL THEN
        INSERT INTO public."PR_Program" (
            "PR_Dummy"
        )
        VALUES (
            null
        )
        RETURNING "PR_ID" INTO _id;
    END IF;
    IF NEW."PR_NAM_Program_Name" IS NOT NULL THEN
        INSERT INTO public."PR_NAM_Program_Name" (
            "PR_ID",
            "PR_NAM_Program_Name",
            "PR_NAM_Positor",
            "PR_NAM_PositedAt",
            "PR_NAM_Reliability"
        )
        VALUES (
            _id,
            NEW."PR_NAM_Program_Name",
            coalesce(NEW."PR_NAM_Positor", NEW."Positor", 0),
            coalesce(NEW."PR_NAM_PositedAt", _now),
            coalesce(NEW."PR_NAM_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."PR_LEN_Program_Length" IS NOT NULL THEN
        INSERT INTO public."PR_LEN_Program_Length" (
            "PR_ID",
            "PR_LEN_Program_Length",
            "PR_LEN_ChangedAt",
            "PR_LEN_Positor",
            "PR_LEN_PositedAt",
            "PR_LEN_Reliability"
        )
        VALUES (
            _id,
            NEW."PR_LEN_Program_Length",
            coalesce(NEW."PR_LEN_ChangedAt", _now),
            coalesce(NEW."PR_LEN_Positor", NEW."Positor", 0),
            coalesce(NEW."PR_LEN_PositedAt", _now),
            coalesce(NEW."PR_LEN_Reliability", NEW."Reliability", 1)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lPR_Program" ON public."lPR_Program";
CREATE TRIGGER "it_lPR_Program"
INSTEAD OF INSERT ON public."lPR_Program"
FOR EACH ROW EXECUTE FUNCTION public."it_lPR_Program"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_Program instead of UPDATE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lPR_Program"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _reliability decimal(5,2);
    _positing timestamp;
    _positor smallint;
BEGIN
    IF NEW."PR_ID" IS DISTINCT FROM OLD."PR_ID" THEN
        RAISE EXCEPTION 'The identity column PR_ID is not updatable.';
    END IF;
    IF NEW."PR_NAM_ID" IS DISTINCT FROM OLD."PR_NAM_ID" THEN
        RAISE EXCEPTION 'The identity column PR_NAM_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of PR_NAM_Program_Name, and when it posits
    _reliability := CASE
        WHEN NEW."PR_NAM_Reliability" IS DISTINCT FROM OLD."PR_NAM_Reliability" THEN NEW."PR_NAM_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."PR_NAM_Reliability"
    END;
    _positor := coalesce(CASE
        WHEN NEW."PR_NAM_Positor" IS DISTINCT FROM OLD."PR_NAM_Positor" THEN NEW."PR_NAM_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."PR_NAM_PositedAt" IS DISTINCT FROM OLD."PR_NAM_PositedAt" THEN NEW."PR_NAM_PositedAt"
        ELSE _now
    END;
    IF NEW."PR_NAM_Program_Name" IS DISTINCT FROM OLD."PR_NAM_Program_Name"
    OR NEW."PR_NAM_PositedAt" IS DISTINCT FROM OLD."PR_NAM_PositedAt"
    OR NEW."PR_NAM_Reliability" IS DISTINCT FROM OLD."PR_NAM_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."PR_NAM_Program_Name" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."PR_NAM_Program_Name" IS NULL
            OR NEW."PR_NAM_PositedAt" IS DISTINCT FROM OLD."PR_NAM_PositedAt"
            OR OLD."PR_NAM_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."PR_NAM_Positor" IS DISTINCT FROM _positor
            OR OLD."PR_NAM_Program_Name" <> NEW."PR_NAM_Program_Name"
            THEN
                INSERT INTO public."PR_NAM_Program_Name" (
                    "PR_ID",
                    "PR_NAM_Program_Name",
                    "PR_NAM_Positor",
                    "PR_NAM_PositedAt",
                    "PR_NAM_Reliability"
                )
                VALUES (
                    NEW."PR_ID",
                    NEW."PR_NAM_Program_Name",
                    _positor,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."PR_NAM_Program_Name" IS NULL AND OLD."PR_NAM_Program_Name" IS NOT NULL THEN
            INSERT INTO public."PR_NAM_Program_Name" (
                "PR_ID",
                "PR_NAM_Program_Name",
                "PR_NAM_Positor",
                "PR_NAM_PositedAt",
                "PR_NAM_Reliability"
            )
            SELECT
                p."PR_ID",
                p."PR_NAM_Program_Name",
                _positor,
                _positing,
                0
            FROM
                public."PR_NAM_Program_Name_Posit" p
            WHERE
                p."PR_NAM_ID" = OLD."PR_NAM_ID";
        END IF;
    END IF;
    IF NEW."PR_LEN_ID" IS DISTINCT FROM OLD."PR_LEN_ID" THEN
        RAISE EXCEPTION 'The identity column PR_LEN_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of PR_LEN_Program_Length, and when it posits
    _reliability := CASE
        WHEN NEW."PR_LEN_Reliability" IS DISTINCT FROM OLD."PR_LEN_Reliability" THEN NEW."PR_LEN_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."PR_LEN_Reliability"
    END;
    _positor := coalesce(CASE
        WHEN NEW."PR_LEN_Positor" IS DISTINCT FROM OLD."PR_LEN_Positor" THEN NEW."PR_LEN_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."PR_LEN_PositedAt" IS DISTINCT FROM OLD."PR_LEN_PositedAt" THEN NEW."PR_LEN_PositedAt"
        WHEN NEW."PR_LEN_ChangedAt" IS DISTINCT FROM OLD."PR_LEN_ChangedAt" AND NEW."PR_LEN_Program_Length" IS NULL THEN NEW."PR_LEN_ChangedAt"
        ELSE _now
    END;
    IF NEW."PR_LEN_Program_Length" IS DISTINCT FROM OLD."PR_LEN_Program_Length"
    OR NEW."PR_LEN_ChangedAt" IS DISTINCT FROM OLD."PR_LEN_ChangedAt"
    OR NEW."PR_LEN_PositedAt" IS DISTINCT FROM OLD."PR_LEN_PositedAt"
    OR NEW."PR_LEN_Reliability" IS DISTINCT FROM OLD."PR_LEN_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."PR_LEN_Program_Length" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."PR_LEN_Program_Length" IS NULL
            OR NEW."PR_LEN_ChangedAt" IS DISTINCT FROM OLD."PR_LEN_ChangedAt"
            OR NEW."PR_LEN_PositedAt" IS DISTINCT FROM OLD."PR_LEN_PositedAt"
            OR OLD."PR_LEN_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."PR_LEN_Positor" IS DISTINCT FROM _positor
            OR OLD."PR_LEN_Program_Length" <> NEW."PR_LEN_Program_Length"
            THEN
                INSERT INTO public."PR_LEN_Program_Length" (
                    "PR_ID",
                    "PR_LEN_Program_Length",
                    "PR_LEN_ChangedAt",
                    "PR_LEN_Positor",
                    "PR_LEN_PositedAt",
                    "PR_LEN_Reliability"
                )
                VALUES (
                    NEW."PR_ID",
                    NEW."PR_LEN_Program_Length",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."PR_LEN_ChangedAt" IS DISTINCT FROM OLD."PR_LEN_ChangedAt" THEN NEW."PR_LEN_ChangedAt"
                        WHEN OLD."PR_LEN_Program_Length" = NEW."PR_LEN_Program_Length" THEN NEW."PR_LEN_ChangedAt"
                        ELSE _now
                    END,
                    _positor,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."PR_LEN_Program_Length" IS NULL AND OLD."PR_LEN_Program_Length" IS NOT NULL THEN
            INSERT INTO public."PR_LEN_Program_Length" (
                "PR_ID",
                "PR_LEN_Program_Length",
                "PR_LEN_ChangedAt",
                "PR_LEN_Positor",
                "PR_LEN_PositedAt",
                "PR_LEN_Reliability"
            )
            SELECT
                p."PR_ID",
                p."PR_LEN_Program_Length",
                p."PR_LEN_ChangedAt",
                _positor,
                _positing,
                0
            FROM
                public."PR_LEN_Program_Length_Posit" p
            WHERE
                p."PR_LEN_ID" = OLD."PR_LEN_ID";
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lPR_Program" ON public."lPR_Program";
CREATE TRIGGER "ut_lPR_Program"
INSTEAD OF UPDATE ON public."lPR_Program"
FOR EACH ROW EXECUTE FUNCTION public."ut_lPR_Program"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_Program instead of DELETE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lPR_Program"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown of PR_NAM_Program_Name is retracted
    INSERT INTO public."PR_NAM_Program_Name_Annex" (
        "PR_NAM_ID",
        "PR_NAM_Positor",
        "PR_NAM_PositedAt",
        "PR_NAM_Reliability"
    )
    SELECT
        OLD."PR_NAM_ID",
        coalesce(OLD."PR_NAM_Positor", OLD."Positor", 0),
        _now,
        0
    WHERE
        OLD."PR_NAM_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of PR_LEN_Program_Length is retracted
    INSERT INTO public."PR_LEN_Program_Length_Annex" (
        "PR_LEN_ID",
        "PR_LEN_Positor",
        "PR_LEN_PositedAt",
        "PR_LEN_Reliability"
    )
    SELECT
        OLD."PR_LEN_ID",
        coalesce(OLD."PR_LEN_Positor", OLD."Positor", 0),
        _now,
        0
    WHERE
        OLD."PR_LEN_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lPR_Program" ON public."lPR_Program";
CREATE TRIGGER "dt_lPR_Program"
INSTEAD OF DELETE ON public."lPR_Program"
FOR EACH ROW EXECUTE FUNCTION public."dt_lPR_Program"();
