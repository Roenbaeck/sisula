-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers make a tie and its latest view behave like a table that is loaded with plain statements.
-- The tie table has a trigger for insert, which stores a row only when it is not there already, refuses a contradiction
-- and, for an idempotent tie, leaves out what only states again what the row before it says. The latest view has
-- three 'instead of' triggers: insert, update, and delete. They propagate such operations to the tie table in a consistent
-- way. Default values are used for some columns if not provided by the corresponding SQL statements.
--
-- For idempotent ties, only changes that represent values different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- PostgreSQL runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_partner_AC_with_ONG_currently before INSERT trigger on AC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_partner_AC_with_ONG_currently"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_AC_partner_AC_with_ONG_currently" := coalesce(NEW."Metadata_AC_partner_AC_with_ONG_currently", 0);
    NEW."AC_partner_AC_with_ONG_currently_ChangedAt" := coalesce(NEW."AC_partner_AC_with_ONG_currently_ChangedAt", _now);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            ties."AC_partner_AC_with_ONG_currently" x
        WHERE
            x."AC_ID_partner" = NEW."AC_ID_partner"
        AND
            x."AC_ID_with" = NEW."AC_ID_with"
        AND
            x."ONG_ID_currently" = NEW."ONG_ID_currently"
        AND
            x."AC_partner_AC_with_ONG_currently_ChangedAt" = NEW."AC_partner_AC_with_ONG_currently_ChangedAt"
    ) THEN
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_partner_AC_with_ONG_currently" ON ties."AC_partner_AC_with_ONG_currently";
CREATE TRIGGER "it_AC_partner_AC_with_ONG_currently"
BEFORE INSERT ON ties."AC_partner_AC_with_ONG_currently"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_partner_AC_with_ONG_currently"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_partner_AC_with_ONG_currently instead of INSERT trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_partner_AC_with_ONG_currently"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO ties."AC_partner_AC_with_ONG_currently" (
        "Metadata_AC_partner_AC_with_ONG_currently",
        "AC_partner_AC_with_ONG_currently_ChangedAt",
        "AC_ID_partner",
        "AC_ID_with",
        "ONG_ID_currently"
    )
    SELECT
        NEW."Metadata_AC_partner_AC_with_ONG_currently",
        NEW."AC_partner_AC_with_ONG_currently_ChangedAt",
        NEW."AC_ID_partner",
        NEW."AC_ID_with",
        coalesce(NEW."ONG_ID_currently", (
            SELECT
                k."ONG_ID"
            FROM
                knots."ONG_Pågående_EQ" k
            WHERE
                k."ONG_Pågående" = NEW."currently_ONG_Pågående"
            AND
                k."ONG_EQ" = coalesce(NEW."currently_ONG_EQ", 0)
            LIMIT 1
        ))
    ;
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
    _ONG_currently smallint;
BEGIN
    _ONG_currently := NEW."ONG_ID_currently";
    IF NEW."currently_ONG_Pågående" IS DISTINCT FROM OLD."currently_ONG_Pågående" THEN
        SELECT
            k."ONG_ID"
        INTO
            _ONG_currently
        FROM
            knots."ONG_Pågående_EQ" k
        WHERE
            k."ONG_Pågående" = NEW."currently_ONG_Pågående"
        AND
            k."ONG_EQ" = coalesce(NEW."currently_ONG_EQ", 0)
        LIMIT 1;
    END IF;
    -- values that are left as they are state nothing
    IF
        NEW."AC_ID_partner" IS NOT NULL
    AND
        NEW."AC_ID_with" IS NOT NULL
    AND
        _ONG_currently IS NOT NULL
    AND
        (
            NEW."AC_partner_AC_with_ONG_currently_ChangedAt" IS DISTINCT FROM OLD."AC_partner_AC_with_ONG_currently_ChangedAt" OR
            NEW."AC_ID_partner" IS DISTINCT FROM OLD."AC_ID_partner"
        OR
            NEW."AC_ID_with" IS DISTINCT FROM OLD."AC_ID_with"
        OR
            _ONG_currently IS DISTINCT FROM OLD."ONG_ID_currently"
        )
    THEN
        INSERT INTO ties."AC_partner_AC_with_ONG_currently" (
            "Metadata_AC_partner_AC_with_ONG_currently",
            "AC_partner_AC_with_ONG_currently_ChangedAt",
            "AC_ID_partner",
            "AC_ID_with",
            "ONG_ID_currently"
        )
        VALUES (
            NEW."Metadata_AC_partner_AC_with_ONG_currently",
            CASE
                WHEN NEW."AC_partner_AC_with_ONG_currently_ChangedAt" IS DISTINCT FROM OLD."AC_partner_AC_with_ONG_currently_ChangedAt" THEN NEW."AC_partner_AC_with_ONG_currently_ChangedAt"
                ELSE _now
            END,
            NEW."AC_ID_partner",
            NEW."AC_ID_with",
            _ONG_currently
        );
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
BEGIN
    DELETE FROM
        ties."AC_partner_AC_with_ONG_currently" x
    WHERE
        x."AC_partner_AC_with_ONG_currently_ChangedAt" = OLD."AC_partner_AC_with_ONG_currently_ChangedAt"
    AND
        x."AC_ID_partner" = OLD."AC_ID_partner"
    AND
        x."AC_ID_with" = OLD."AC_ID_with"
    AND
        x."ONG_ID_currently" = OLD."ONG_ID_currently"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_partner_AC_with_ONG_currently" ON ties."lAC_partner_AC_with_ONG_currently";
CREATE TRIGGER "dt_lAC_partner_AC_with_ONG_currently"
INSTEAD OF DELETE ON ties."lAC_partner_AC_with_ONG_currently"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_partner_AC_with_ONG_currently"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_subset_PN_of before INSERT trigger on AC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_subset_PN_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_AC_subset_PN_of" := coalesce(NEW."Metadata_AC_subset_PN_of", 0);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            ties."AC_subset_PN_of" x
        WHERE
            x."AC_ID_subset" = NEW."AC_ID_subset"
        AND
            x."PN_ID_of" = NEW."PN_ID_of"
        AND
            true
    ) THEN
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_subset_PN_of" ON ties."AC_subset_PN_of";
CREATE TRIGGER "it_AC_subset_PN_of"
BEFORE INSERT ON ties."AC_subset_PN_of"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_subset_PN_of"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_subset_PN_of"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO ties."AC_subset_PN_of" (
        "Metadata_AC_subset_PN_of",
        "AC_ID_subset",
        "PN_ID_of"
    )
    SELECT
        NEW."Metadata_AC_subset_PN_of",
        NEW."AC_ID_subset",
        NEW."PN_ID_of"
    ;
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
BEGIN
    -- values that are left as they are state nothing
    IF
        NEW."AC_ID_subset" IS NOT NULL
    AND
        NEW."PN_ID_of" IS NOT NULL
    AND
        (
            NEW."AC_ID_subset" IS DISTINCT FROM OLD."AC_ID_subset"
        OR
            NEW."PN_ID_of" IS DISTINCT FROM OLD."PN_ID_of"
        )
    THEN
        INSERT INTO ties."AC_subset_PN_of" (
            "Metadata_AC_subset_PN_of",
            "AC_ID_subset",
            "PN_ID_of"
        )
        VALUES (
            NEW."Metadata_AC_subset_PN_of",
            NEW."AC_ID_subset",
            NEW."PN_ID_of"
        );
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
BEGIN
    DELETE FROM
        ties."AC_subset_PN_of" x
    WHERE
        x."AC_ID_subset" = OLD."AC_ID_subset"
    AND
        x."PN_ID_of" = OLD."PN_ID_of"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_subset_PN_of" ON ties."lAC_subset_PN_of";
CREATE TRIGGER "dt_lAC_subset_PN_of"
INSTEAD OF DELETE ON ties."lAC_subset_PN_of"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_subset_PN_of"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_in_AC_rollsattes before INSERT trigger on EV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_EV_in_AC_rollsattes"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_EV_in_AC_rollsattes" := coalesce(NEW."Metadata_EV_in_AC_rollsattes", 0);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            ties."EV_in_AC_rollsattes" x
        WHERE
            x."EV_ID_in" = NEW."EV_ID_in"
        AND
            x."AC_ID_rollsattes" = NEW."AC_ID_rollsattes"
        AND
            true
    ) THEN
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_in_AC_rollsattes" ON ties."EV_in_AC_rollsattes";
CREATE TRIGGER "it_EV_in_AC_rollsattes"
BEFORE INSERT ON ties."EV_in_AC_rollsattes"
FOR EACH ROW EXECUTE FUNCTION ties."it_EV_in_AC_rollsattes"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_rollsattes instead of INSERT trigger on lEV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lEV_in_AC_rollsattes"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO ties."EV_in_AC_rollsattes" (
        "Metadata_EV_in_AC_rollsattes",
        "EV_ID_in",
        "AC_ID_rollsattes"
    )
    SELECT
        NEW."Metadata_EV_in_AC_rollsattes",
        NEW."EV_ID_in",
        NEW."AC_ID_rollsattes"
    ;
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
BEGIN
    DELETE FROM
        ties."EV_in_AC_rollsattes" x
    WHERE
        x."EV_ID_in" = OLD."EV_ID_in"
    AND
        x."AC_ID_rollsattes" = OLD."AC_ID_rollsattes"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lEV_in_AC_rollsattes" ON ties."lEV_in_AC_rollsattes";
CREATE TRIGGER "dt_lEV_in_AC_rollsattes"
INSTEAD OF DELETE ON ties."lEV_in_AC_rollsattes"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lEV_in_AC_rollsattes"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_deltar_PR_in_RAT_fick before INSERT trigger on AC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_deltar_PR_in_RAT_fick"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_AC_deltar_PR_in_RAT_fick" := coalesce(NEW."Metadata_AC_deltar_PR_in_RAT_fick", 0);
    NEW."AC_deltar_PR_in_RAT_fick_ChangedAt" := coalesce(NEW."AC_deltar_PR_in_RAT_fick_ChangedAt", _now);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            ties."AC_deltar_PR_in_RAT_fick" x
        WHERE
            x."AC_ID_deltar" = NEW."AC_ID_deltar"
        AND
            x."PR_ID_in" = NEW."PR_ID_in"
        AND
            x."RAT_ID_fick" = NEW."RAT_ID_fick"
        AND
            x."AC_deltar_PR_in_RAT_fick_ChangedAt" = NEW."AC_deltar_PR_in_RAT_fick_ChangedAt"
    ) THEN
        RETURN NULL;
    END IF;
    -- other values for identifiers that already have values (at that time) are a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            ties."AC_deltar_PR_in_RAT_fick" x
        WHERE
            x."AC_ID_deltar" = NEW."AC_ID_deltar"
        AND
            x."PR_ID_in" = NEW."PR_ID_in"
        AND
            x."AC_deltar_PR_in_RAT_fick_ChangedAt" = NEW."AC_deltar_PR_in_RAT_fick_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_deltar_PR_in_RAT_fick for: %', concat_ws(', ',
            NEW."AC_ID_deltar",
            NEW."PR_ID_in",
            NEW."AC_deltar_PR_in_RAT_fick_ChangedAt"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_deltar_PR_in_RAT_fick" ON ties."AC_deltar_PR_in_RAT_fick";
CREATE TRIGGER "it_AC_deltar_PR_in_RAT_fick"
BEFORE INSERT ON ties."AC_deltar_PR_in_RAT_fick"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_deltar_PR_in_RAT_fick"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_deltar_PR_in_RAT_fick instead of INSERT trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_deltar_PR_in_RAT_fick"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO ties."AC_deltar_PR_in_RAT_fick" (
        "Metadata_AC_deltar_PR_in_RAT_fick",
        "AC_deltar_PR_in_RAT_fick_ChangedAt",
        "AC_ID_deltar",
        "PR_ID_in",
        "RAT_ID_fick"
    )
    SELECT
        NEW."Metadata_AC_deltar_PR_in_RAT_fick",
        NEW."AC_deltar_PR_in_RAT_fick_ChangedAt",
        NEW."AC_ID_deltar",
        NEW."PR_ID_in",
        coalesce(NEW."RAT_ID_fick", (
            SELECT
                k."RAT_ID"
            FROM
                knots."RAT_Betyg_EQ" k
            WHERE
                k."RAT_Betyg" = NEW."fick_RAT_Betyg"
            AND
                k."RAT_EQ" = coalesce(NEW."fick_RAT_EQ", 0)
            LIMIT 1
        ))
    ;
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
    _RAT_fick smallint;
BEGIN
    IF NEW."AC_ID_deltar" IS DISTINCT FROM OLD."AC_ID_deltar" THEN
        RAISE EXCEPTION 'The identity column AC_ID_deltar is not updatable.';
    END IF;
    IF NEW."PR_ID_in" IS DISTINCT FROM OLD."PR_ID_in" THEN
        RAISE EXCEPTION 'The identity column PR_ID_in is not updatable.';
    END IF;
    _RAT_fick := NEW."RAT_ID_fick";
    IF NEW."fick_RAT_Betyg" IS DISTINCT FROM OLD."fick_RAT_Betyg" THEN
        SELECT
            k."RAT_ID"
        INTO
            _RAT_fick
        FROM
            knots."RAT_Betyg_EQ" k
        WHERE
            k."RAT_Betyg" = NEW."fick_RAT_Betyg"
        AND
            k."RAT_EQ" = coalesce(NEW."fick_RAT_EQ", 0)
        LIMIT 1;
    END IF;
    -- values that are left as they are state nothing
    IF
        _RAT_fick IS NOT NULL
    AND
        (
            NEW."AC_deltar_PR_in_RAT_fick_ChangedAt" IS DISTINCT FROM OLD."AC_deltar_PR_in_RAT_fick_ChangedAt" OR
            NEW."AC_ID_deltar" IS DISTINCT FROM OLD."AC_ID_deltar"
        OR
            NEW."PR_ID_in" IS DISTINCT FROM OLD."PR_ID_in"
        OR
            _RAT_fick IS DISTINCT FROM OLD."RAT_ID_fick"
        )
    THEN
        INSERT INTO ties."AC_deltar_PR_in_RAT_fick" (
            "Metadata_AC_deltar_PR_in_RAT_fick",
            "AC_deltar_PR_in_RAT_fick_ChangedAt",
            "AC_ID_deltar",
            "PR_ID_in",
            "RAT_ID_fick"
        )
        VALUES (
            NEW."Metadata_AC_deltar_PR_in_RAT_fick",
            CASE
                WHEN NEW."AC_deltar_PR_in_RAT_fick_ChangedAt" IS DISTINCT FROM OLD."AC_deltar_PR_in_RAT_fick_ChangedAt" THEN NEW."AC_deltar_PR_in_RAT_fick_ChangedAt"
                ELSE _now
            END,
            NEW."AC_ID_deltar",
            NEW."PR_ID_in",
            _RAT_fick
        );
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
BEGIN
    DELETE FROM
        ties."AC_deltar_PR_in_RAT_fick" x
    WHERE
        x."AC_deltar_PR_in_RAT_fick_ChangedAt" = OLD."AC_deltar_PR_in_RAT_fick_ChangedAt"
    AND
        x."AC_ID_deltar" = OLD."AC_ID_deltar"
    AND
        x."PR_ID_in" = OLD."PR_ID_in"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_deltar_PR_in_RAT_fick" ON ties."lAC_deltar_PR_in_RAT_fick";
CREATE TRIGGER "dt_lAC_deltar_PR_in_RAT_fick"
INSTEAD OF DELETE ON ties."lAC_deltar_PR_in_RAT_fick"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_deltar_PR_in_RAT_fick"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_at_PR_spelas before INSERT trigger on ST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_ST_at_PR_spelas"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_ST_at_PR_spelas" := coalesce(NEW."Metadata_ST_at_PR_spelas", 0);
    NEW."ST_at_PR_spelas_ChangedAt" := coalesce(NEW."ST_at_PR_spelas_ChangedAt", _now);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            ties."ST_at_PR_spelas" x
        WHERE
            x."ST_ID_at" = NEW."ST_ID_at"
        AND
            x."PR_ID_spelas" = NEW."PR_ID_spelas"
        AND
            x."ST_at_PR_spelas_ChangedAt" = NEW."ST_at_PR_spelas_ChangedAt"
    ) THEN
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_at_PR_spelas" ON ties."ST_at_PR_spelas";
CREATE TRIGGER "it_ST_at_PR_spelas"
BEFORE INSERT ON ties."ST_at_PR_spelas"
FOR EACH ROW EXECUTE FUNCTION ties."it_ST_at_PR_spelas"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_spelas instead of INSERT trigger on lST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lST_at_PR_spelas"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO ties."ST_at_PR_spelas" (
        "Metadata_ST_at_PR_spelas",
        "ST_at_PR_spelas_ChangedAt",
        "ST_ID_at",
        "PR_ID_spelas"
    )
    SELECT
        NEW."Metadata_ST_at_PR_spelas",
        NEW."ST_at_PR_spelas_ChangedAt",
        NEW."ST_ID_at",
        NEW."PR_ID_spelas"
    ;
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
BEGIN
    DELETE FROM
        ties."ST_at_PR_spelas" x
    WHERE
        x."ST_at_PR_spelas_ChangedAt" = OLD."ST_at_PR_spelas_ChangedAt"
    AND
        x."ST_ID_at" = OLD."ST_ID_at"
    AND
        x."PR_ID_spelas" = OLD."PR_ID_spelas"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lST_at_PR_spelas" ON ties."lST_at_PR_spelas";
CREATE TRIGGER "dt_lST_at_PR_spelas"
INSTEAD OF DELETE ON ties."lST_at_PR_spelas"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lST_at_PR_spelas"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_förälder_AC_barn_PAT_har before INSERT trigger on AC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_förälder_AC_barn_PAT_har"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_AC_förälder_AC_barn_PAT_har" := coalesce(NEW."Metadata_AC_förälder_AC_barn_PAT_har", 0);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            ties."AC_förälder_AC_barn_PAT_har" x
        WHERE
            x."AC_ID_förälder" = NEW."AC_ID_förälder"
        AND
            x."AC_ID_barn" = NEW."AC_ID_barn"
        AND
            x."PAT_ID_har" = NEW."PAT_ID_har"
        AND
            true
    ) THEN
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_förälder_AC_barn_PAT_har" ON ties."AC_förälder_AC_barn_PAT_har";
CREATE TRIGGER "it_AC_förälder_AC_barn_PAT_har"
BEFORE INSERT ON ties."AC_förälder_AC_barn_PAT_har"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_förälder_AC_barn_PAT_har"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_förälder_AC_barn_PAT_har instead of INSERT trigger on lAC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_förälder_AC_barn_PAT_har"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO ties."AC_förälder_AC_barn_PAT_har" (
        "Metadata_AC_förälder_AC_barn_PAT_har",
        "AC_ID_förälder",
        "AC_ID_barn",
        "PAT_ID_har"
    )
    SELECT
        NEW."Metadata_AC_förälder_AC_barn_PAT_har",
        NEW."AC_ID_förälder",
        NEW."AC_ID_barn",
        coalesce(NEW."PAT_ID_har", (
            SELECT
                k."PAT_ID"
            FROM
                knots."PAT_Föräldratyp_EQ" k
            WHERE
                k."PAT_Föräldratyp" = NEW."har_PAT_Föräldratyp"
            AND
                k."PAT_EQ" = coalesce(NEW."har_PAT_EQ", 0)
            LIMIT 1
        ))
    ;
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
BEGIN
    DELETE FROM
        ties."AC_förälder_AC_barn_PAT_har" x
    WHERE
        x."AC_ID_förälder" = OLD."AC_ID_förälder"
    AND
        x."AC_ID_barn" = OLD."AC_ID_barn"
    AND
        x."PAT_ID_har" = OLD."PAT_ID_har"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_förälder_AC_barn_PAT_har" ON ties."lAC_förälder_AC_barn_PAT_har";
CREATE TRIGGER "dt_lAC_förälder_AC_barn_PAT_har"
INSTEAD OF DELETE ON ties."lAC_förälder_AC_barn_PAT_har"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_förälder_AC_barn_PAT_har"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_innehåll_ST_plats_EV_of before INSERT trigger on PR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_PR_innehåll_ST_plats_EV_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_PR_innehåll_ST_plats_EV_of" := coalesce(NEW."Metadata_PR_innehåll_ST_plats_EV_of", 0);
    NEW."PR_innehåll_ST_plats_EV_of_ChangedAt" := coalesce(NEW."PR_innehåll_ST_plats_EV_of_ChangedAt", _now);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            ties."PR_innehåll_ST_plats_EV_of" x
        WHERE
            x."PR_ID_innehåll" = NEW."PR_ID_innehåll"
        AND
            x."ST_ID_plats" = NEW."ST_ID_plats"
        AND
            x."EV_ID_of" = NEW."EV_ID_of"
        AND
            x."PR_innehåll_ST_plats_EV_of_ChangedAt" = NEW."PR_innehåll_ST_plats_EV_of_ChangedAt"
    ) THEN
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_PR_innehåll_ST_plats_EV_of" ON ties."PR_innehåll_ST_plats_EV_of";
CREATE TRIGGER "it_PR_innehåll_ST_plats_EV_of"
BEFORE INSERT ON ties."PR_innehåll_ST_plats_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."it_PR_innehåll_ST_plats_EV_of"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_innehåll_ST_plats_EV_of instead of INSERT trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lPR_innehåll_ST_plats_EV_of"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO ties."PR_innehåll_ST_plats_EV_of" (
        "Metadata_PR_innehåll_ST_plats_EV_of",
        "PR_innehåll_ST_plats_EV_of_ChangedAt",
        "PR_ID_innehåll",
        "ST_ID_plats",
        "EV_ID_of"
    )
    SELECT
        NEW."Metadata_PR_innehåll_ST_plats_EV_of",
        NEW."PR_innehåll_ST_plats_EV_of_ChangedAt",
        NEW."PR_ID_innehåll",
        NEW."ST_ID_plats",
        NEW."EV_ID_of"
    ;
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
BEGIN
    -- values that are left as they are state nothing
    IF
        NEW."PR_ID_innehåll" IS NOT NULL
    AND
        NEW."ST_ID_plats" IS NOT NULL
    AND
        NEW."EV_ID_of" IS NOT NULL
    AND
        (
            NEW."PR_innehåll_ST_plats_EV_of_ChangedAt" IS DISTINCT FROM OLD."PR_innehåll_ST_plats_EV_of_ChangedAt" OR
            NEW."PR_ID_innehåll" IS DISTINCT FROM OLD."PR_ID_innehåll"
        OR
            NEW."ST_ID_plats" IS DISTINCT FROM OLD."ST_ID_plats"
        OR
            NEW."EV_ID_of" IS DISTINCT FROM OLD."EV_ID_of"
        )
    THEN
        INSERT INTO ties."PR_innehåll_ST_plats_EV_of" (
            "Metadata_PR_innehåll_ST_plats_EV_of",
            "PR_innehåll_ST_plats_EV_of_ChangedAt",
            "PR_ID_innehåll",
            "ST_ID_plats",
            "EV_ID_of"
        )
        VALUES (
            NEW."Metadata_PR_innehåll_ST_plats_EV_of",
            CASE
                WHEN NEW."PR_innehåll_ST_plats_EV_of_ChangedAt" IS DISTINCT FROM OLD."PR_innehåll_ST_plats_EV_of_ChangedAt" THEN NEW."PR_innehåll_ST_plats_EV_of_ChangedAt"
                ELSE _now
            END,
            NEW."PR_ID_innehåll",
            NEW."ST_ID_plats",
            NEW."EV_ID_of"
        );
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
BEGIN
    DELETE FROM
        ties."PR_innehåll_ST_plats_EV_of" x
    WHERE
        x."PR_innehåll_ST_plats_EV_of_ChangedAt" = OLD."PR_innehåll_ST_plats_EV_of_ChangedAt"
    AND
        x."PR_ID_innehåll" = OLD."PR_ID_innehåll"
    AND
        x."ST_ID_plats" = OLD."ST_ID_plats"
    AND
        x."EV_ID_of" = OLD."EV_ID_of"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lPR_innehåll_ST_plats_EV_of" ON ties."lPR_innehåll_ST_plats_EV_of";
CREATE TRIGGER "dt_lPR_innehåll_ST_plats_EV_of"
INSTEAD OF DELETE ON ties."lPR_innehåll_ST_plats_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lPR_innehåll_ST_plats_EV_of"();
