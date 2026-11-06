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
            "ST_NAM_ChangedAt",
            "ST_NAM_Stage_Name"
        )
        VALUES (
            coalesce(NEW."ST_ID", _id),
            coalesce(NEW."ST_NAM_ChangedAt", _now),
            NEW."ST_NAM_Stage_Name"
        );
    END IF;
    IF NEW."ST_LOC_Stage_Location" IS NOT NULL THEN
        INSERT INTO public."ST_LOC_Stage_Location" (
            "ST_ID",
            "ST_LOC_Stage_Location"
        )
        VALUES (
            coalesce(NEW."ST_ID", _id),
            NEW."ST_LOC_Stage_Location"
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
            "ST_AVG_ChangedAt",
            "UTL_ID"
        )
        VALUES (
            coalesce(NEW."ST_ID", _id),
            coalesce(NEW."ST_AVG_ChangedAt", _now),
            _AVG
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
            "UTL_ID"
        )
        VALUES (
            coalesce(NEW."ST_ID", _id),
            _MIN
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
    _AVG smallint;
    _MIN smallint;
BEGIN
    IF NEW."ST_ID" IS DISTINCT FROM OLD."ST_ID" THEN
        RAISE EXCEPTION 'The identity column ST_ID is not updatable.';
    END IF;
    IF NEW."ST_NAM_Stage_Name" IS DISTINCT FROM OLD."ST_NAM_Stage_Name"
    OR NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."ST_NAM_Stage_Name" IS NOT NULL AND (
            NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt" OR
            OLD."ST_NAM_Stage_Name" IS NULL OR
            OLD."ST_NAM_Stage_Name" <> NEW."ST_NAM_Stage_Name"
        ) THEN
            INSERT INTO public."ST_NAM_Stage_Name" (
                "ST_ID",
                "ST_NAM_ChangedAt",
                "ST_NAM_Stage_Name"
            )
            VALUES (
                coalesce(NEW."ST_ID", NEW."ST_ID"),
                CASE
                    WHEN NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt" THEN NEW."ST_NAM_ChangedAt"
                    ELSE _now
                END,
                NEW."ST_NAM_Stage_Name"
            );
        END IF;
    END IF;
    IF NEW."ST_LOC_Stage_Location" IS DISTINCT FROM OLD."ST_LOC_Stage_Location"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."ST_LOC_Stage_Location" IS NOT NULL AND (
            OLD."ST_LOC_Stage_Location" IS NULL OR
            md5(OLD."ST_LOC_Stage_Location"::text) <> md5(NEW."ST_LOC_Stage_Location"::text)
        ) THEN
            INSERT INTO public."ST_LOC_Stage_Location" (
                "ST_ID",
                "ST_LOC_Stage_Location"
            )
            VALUES (
                coalesce(NEW."ST_ID", NEW."ST_ID"),
                NEW."ST_LOC_Stage_Location"
            );
        END IF;
    END IF;
    IF NEW."UTL_ID" IS DISTINCT FROM OLD."UTL_ID"
    OR NEW."UTL_Utilization" IS DISTINCT FROM OLD."UTL_Utilization"
    OR NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt"
    THEN
        _AVG := NEW."UTL_ID";
        IF _AVG IS NOT DISTINCT FROM OLD."UTL_ID" AND NEW."UTL_Utilization" IS NOT NULL THEN
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
        -- a value that is left as it is states nothing
        IF _AVG IS NOT NULL AND (
            NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt" OR
            OLD."UTL_ID" IS NULL OR
            OLD."UTL_ID" <> _AVG
        ) THEN
            INSERT INTO public."ST_AVG_Stage_Average" (
                "ST_ID",
                "ST_AVG_ChangedAt",
                "UTL_ID"
            )
            VALUES (
                coalesce(NEW."ST_ID", NEW."ST_ID"),
                CASE
                    WHEN NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt" THEN NEW."ST_AVG_ChangedAt"
                    ELSE _now
                END,
                _AVG
            );
        END IF;
    END IF;
    IF NEW."UTL_ID" IS DISTINCT FROM OLD."UTL_ID"
    OR NEW."UTL_Utilization" IS DISTINCT FROM OLD."UTL_Utilization"
    THEN
        _MIN := NEW."UTL_ID";
        IF _MIN IS NOT DISTINCT FROM OLD."UTL_ID" AND NEW."UTL_Utilization" IS NOT NULL THEN
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
        -- a value that is left as it is states nothing
        IF _MIN IS NOT NULL AND (
            OLD."UTL_ID" IS NULL OR
            OLD."UTL_ID" <> _MIN
        ) THEN
            INSERT INTO public."ST_MIN_Stage_Minimum" (
                "ST_ID",
                "UTL_ID"
            )
            VALUES (
                coalesce(NEW."ST_ID", NEW."ST_ID"),
                _MIN
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF NEW."Deletable_ST_MIN" IS TRUE
    AND OLD."UTL_ID" IS NOT NULL
    AND (NEW."UTL_ID" IS NULL OR NEW."UTL_Utilization" IS NULL)
    THEN
        IF to_regclass('public."ST_MIN_Stage_Minimum_Deleted"') IS NULL THEN
            CREATE TABLE public."ST_MIN_Stage_Minimum_Deleted" (
                LIKE public."ST_MIN_Stage_Minimum",
                "ST_MIN_Deleted" timestamp
            );
        END IF;
        WITH d AS (
            DELETE FROM public."ST_MIN_Stage_Minimum"
            WHERE "ST_ID" = OLD."ST_ID"
            RETURNING *
        )
        INSERT INTO public."ST_MIN_Stage_Minimum_Deleted"
        SELECT
            d.*,
            _now
        FROM
            d;
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
BEGIN
    DELETE FROM
        public."ST_NAM_Stage_Name" x
    WHERE
        x."ST_ID" = OLD."ST_ID"
    AND
        x."ST_NAM_ChangedAt" = OLD."ST_NAM_ChangedAt"
    ;
    DELETE FROM
        public."ST_LOC_Stage_Location" x
    WHERE
        x."ST_ID" = OLD."ST_ID"
    ;
    DELETE FROM
        public."ST_AVG_Stage_Average" x
    WHERE
        x."ST_ID" = OLD."ST_ID"
    AND
        x."ST_AVG_ChangedAt" = OLD."ST_AVG_ChangedAt"
    ;
    DELETE FROM
        public."ST_MIN_Stage_Minimum" x
    WHERE
        x."ST_ID" = OLD."ST_ID"
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        public."ST_Stage" a
    WHERE
        a."ST_ID" = OLD."ST_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."ST_NAM_Stage_Name" x
        WHERE
            x."ST_ID" = a."ST_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."ST_LOC_Stage_Location" x
        WHERE
            x."ST_ID" = a."ST_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."ST_AVG_Stage_Average" x
        WHERE
            x."ST_ID" = a."ST_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."ST_MIN_Stage_Minimum" x
        WHERE
            x."ST_ID" = a."ST_ID"
    )
    ;
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
            "AC_NAM_ChangedAt",
            "AC_NAM_Actor_Name"
        )
        VALUES (
            coalesce(NEW."AC_ID", _id),
            coalesce(NEW."AC_NAM_ChangedAt", _now),
            NEW."AC_NAM_Actor_Name"
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
            "GEN_ID"
        )
        VALUES (
            coalesce(NEW."AC_ID", _id),
            _GEN
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
            "AC_PLV_ChangedAt",
            "PLV_ID"
        )
        VALUES (
            coalesce(NEW."AC_ID", _id),
            coalesce(NEW."AC_PLV_ChangedAt", _now),
            _PLV
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
    _GEN smallint;
    _PLV smallint;
BEGIN
    IF NEW."AC_ID" IS DISTINCT FROM OLD."AC_ID" THEN
        RAISE EXCEPTION 'The identity column AC_ID is not updatable.';
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
            INSERT INTO public."AC_NAM_Actor_Name" (
                "AC_ID",
                "AC_NAM_ChangedAt",
                "AC_NAM_Actor_Name"
            )
            VALUES (
                coalesce(NEW."AC_ID", NEW."AC_ID"),
                CASE
                    WHEN NEW."AC_NAM_ChangedAt" IS DISTINCT FROM OLD."AC_NAM_ChangedAt" THEN NEW."AC_NAM_ChangedAt"
                    ELSE _now
                END,
                NEW."AC_NAM_Actor_Name"
            );
        END IF;
    END IF;
    IF NEW."GEN_ID" IS DISTINCT FROM OLD."GEN_ID"
    OR NEW."GEN_Gender" IS DISTINCT FROM OLD."GEN_Gender"
    THEN
        _GEN := NEW."GEN_ID";
        IF _GEN IS NOT DISTINCT FROM OLD."GEN_ID" AND NEW."GEN_Gender" IS NOT NULL THEN
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
        -- a value that is left as it is states nothing
        IF _GEN IS NOT NULL AND (
            OLD."GEN_ID" IS NULL OR
            OLD."GEN_ID" <> _GEN
        ) THEN
            INSERT INTO public."AC_GEN_Actor_Gender" (
                "AC_ID",
                "GEN_ID"
            )
            VALUES (
                coalesce(NEW."AC_ID", NEW."AC_ID"),
                _GEN
            );
        END IF;
    END IF;
    IF NEW."PLV_ID" IS DISTINCT FROM OLD."PLV_ID"
    OR NEW."PLV_ProfessionalLevel" IS DISTINCT FROM OLD."PLV_ProfessionalLevel"
    OR NEW."AC_PLV_ChangedAt" IS DISTINCT FROM OLD."AC_PLV_ChangedAt"
    THEN
        _PLV := NEW."PLV_ID";
        IF _PLV IS NOT DISTINCT FROM OLD."PLV_ID" AND NEW."PLV_ProfessionalLevel" IS NOT NULL THEN
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
        -- a value that is left as it is states nothing
        IF _PLV IS NOT NULL AND (
            NEW."AC_PLV_ChangedAt" IS DISTINCT FROM OLD."AC_PLV_ChangedAt" OR
            OLD."PLV_ID" IS NULL OR
            OLD."PLV_ID" <> _PLV
        ) THEN
            INSERT INTO public."AC_PLV_Actor_ProfessionalLevel" (
                "AC_ID",
                "AC_PLV_ChangedAt",
                "PLV_ID"
            )
            VALUES (
                coalesce(NEW."AC_ID", NEW."AC_ID"),
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
BEGIN
    DELETE FROM
        public."AC_NAM_Actor_Name" x
    WHERE
        x."AC_ID" = OLD."AC_ID"
    AND
        x."AC_NAM_ChangedAt" = OLD."AC_NAM_ChangedAt"
    ;
    DELETE FROM
        public."AC_GEN_Actor_Gender" x
    WHERE
        x."AC_ID" = OLD."AC_ID"
    ;
    DELETE FROM
        public."AC_PLV_Actor_ProfessionalLevel" x
    WHERE
        x."AC_ID" = OLD."AC_ID"
    AND
        x."AC_PLV_ChangedAt" = OLD."AC_PLV_ChangedAt"
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        public."AC_Actor" a
    WHERE
        a."AC_ID" = OLD."AC_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."AC_NAM_Actor_Name" x
        WHERE
            x."AC_ID" = a."AC_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."AC_GEN_Actor_Gender" x
        WHERE
            x."AC_ID" = a."AC_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."AC_PLV_Actor_ProfessionalLevel" x
        WHERE
            x."AC_ID" = a."AC_ID"
    )
    ;
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
            "PR_NAM_Program_Name"
        )
        VALUES (
            coalesce(NEW."PR_ID", _id),
            NEW."PR_NAM_Program_Name"
        );
    END IF;
    IF NEW."PR_LEN_Program_Length" IS NOT NULL THEN
        INSERT INTO public."PR_LEN_Program_Length" (
            "PR_ID",
            "PR_LEN_ChangedAt",
            "PR_LEN_Program_Length"
        )
        VALUES (
            coalesce(NEW."PR_ID", _id),
            coalesce(NEW."PR_LEN_ChangedAt", _now),
            NEW."PR_LEN_Program_Length"
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
BEGIN
    IF NEW."PR_ID" IS DISTINCT FROM OLD."PR_ID" THEN
        RAISE EXCEPTION 'The identity column PR_ID is not updatable.';
    END IF;
    IF NEW."PR_NAM_Program_Name" IS DISTINCT FROM OLD."PR_NAM_Program_Name"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."PR_NAM_Program_Name" IS NOT NULL AND (
            OLD."PR_NAM_Program_Name" IS NULL OR
            OLD."PR_NAM_Program_Name" <> NEW."PR_NAM_Program_Name"
        ) THEN
            INSERT INTO public."PR_NAM_Program_Name" (
                "PR_ID",
                "PR_NAM_Program_Name"
            )
            VALUES (
                coalesce(NEW."PR_ID", NEW."PR_ID"),
                NEW."PR_NAM_Program_Name"
            );
        END IF;
    END IF;
    IF NEW."PR_LEN_Program_Length" IS DISTINCT FROM OLD."PR_LEN_Program_Length"
    OR NEW."PR_LEN_ChangedAt" IS DISTINCT FROM OLD."PR_LEN_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."PR_LEN_Program_Length" IS NOT NULL AND (
            NEW."PR_LEN_ChangedAt" IS DISTINCT FROM OLD."PR_LEN_ChangedAt" OR
            OLD."PR_LEN_Program_Length" IS NULL OR
            OLD."PR_LEN_Program_Length" <> NEW."PR_LEN_Program_Length"
        ) THEN
            INSERT INTO public."PR_LEN_Program_Length" (
                "PR_ID",
                "PR_LEN_ChangedAt",
                "PR_LEN_Program_Length"
            )
            VALUES (
                coalesce(NEW."PR_ID", NEW."PR_ID"),
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
BEGIN
    DELETE FROM
        public."PR_NAM_Program_Name" x
    WHERE
        x."PR_ID" = OLD."PR_ID"
    ;
    DELETE FROM
        public."PR_LEN_Program_Length" x
    WHERE
        x."PR_ID" = OLD."PR_ID"
    AND
        x."PR_LEN_ChangedAt" = OLD."PR_LEN_ChangedAt"
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        public."PR_Program" a
    WHERE
        a."PR_ID" = OLD."PR_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."PR_NAM_Program_Name" x
        WHERE
            x."PR_ID" = a."PR_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."PR_LEN_Program_Length" x
        WHERE
            x."PR_ID" = a."PR_ID"
    )
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lPR_Program" ON public."lPR_Program";
CREATE TRIGGER "dt_lPR_Program"
INSTEAD OF DELETE ON public."lPR_Program"
FOR EACH ROW EXECUTE FUNCTION public."dt_lPR_Program"();
