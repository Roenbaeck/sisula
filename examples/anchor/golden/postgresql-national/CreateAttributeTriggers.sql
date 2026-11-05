-- ATTRIBUTE TRIGGERS ------------------------------------------------------------------------------------------------
--
-- The following triggers on the attribute tables make them behave as the model says: a row that is already there is
-- not stored again, another value at a time that has a value is a contradiction, and a value that is the same as the
-- one before it (a restatement) is skipped by an idempotent attribute and refused by one that may not be restated.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are
-- stored. Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_DAT_Händelse_Datum before INSERT trigger on EV_DAT_Händelse_Datum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_DAT_Händelse_Datum"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_DAT_Händelse_Datum" x
        WHERE
            x."EV_DAT_EV_ID" = NEW."EV_DAT_EV_ID"
        AND
            x."EV_DAT_Händelse_Datum" = NEW."EV_DAT_Händelse_Datum"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_DAT_Händelse_Datum" x
        WHERE
            x."EV_DAT_EV_ID" = NEW."EV_DAT_EV_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_DAT_Händelse_Datum for: %', NEW."EV_DAT_EV_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_DAT_Händelse_Datum" ON attributes."EV_DAT_Händelse_Datum";
CREATE TRIGGER "it_EV_DAT_Händelse_Datum"
BEFORE INSERT ON attributes."EV_DAT_Händelse_Datum"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_DAT_Händelse_Datum"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_AUD_Händelse_Publik before INSERT trigger on EV_AUD_Händelse_Publik
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_AUD_Händelse_Publik"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_AUD_Händelse_Publik" x
        WHERE
            x."EV_AUD_EQ" = NEW."EV_AUD_EQ"
        AND
            x."EV_AUD_EV_ID" = NEW."EV_AUD_EV_ID"
        AND
            x."EV_AUD_Händelse_Publik" = NEW."EV_AUD_Händelse_Publik"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_AUD_Händelse_Publik" x
        WHERE
            x."EV_AUD_EQ" = NEW."EV_AUD_EQ"
        AND
            x."EV_AUD_EV_ID" = NEW."EV_AUD_EV_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_AUD_Händelse_Publik for: %', NEW."EV_AUD_EV_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_AUD_Händelse_Publik" ON attributes."EV_AUD_Händelse_Publik";
CREATE TRIGGER "it_EV_AUD_Händelse_Publik"
BEFORE INSERT ON attributes."EV_AUD_Händelse_Publik"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_AUD_Händelse_Publik"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_REV_Händelse_Intäkt before INSERT trigger on EV_REV_Händelse_Intäkt
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_REV_Händelse_Intäkt"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_REV_Händelse_Intäkt" x
        WHERE
            x."EV_REV_EQ" = NEW."EV_REV_EQ"
        AND
            x."EV_REV_EV_ID" = NEW."EV_REV_EV_ID"
        AND
            x."EV_REV_Händelse_Intäkt" = NEW."EV_REV_Händelse_Intäkt"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_REV_Händelse_Intäkt" x
        WHERE
            x."EV_REV_EQ" = NEW."EV_REV_EQ"
        AND
            x."EV_REV_EV_ID" = NEW."EV_REV_EV_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_REV_Händelse_Intäkt for: %', NEW."EV_REV_EV_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_REV_Händelse_Intäkt" ON attributes."EV_REV_Händelse_Intäkt";
CREATE TRIGGER "it_EV_REV_Händelse_Intäkt"
BEFORE INSERT ON attributes."EV_REV_Händelse_Intäkt"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_REV_Händelse_Intäkt"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_STA_Händelse_Status before INSERT trigger on EV_STA_Händelse_Status
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_STA_Händelse_Status"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_STA_Händelse_Status" x
        WHERE
            x."EV_STA_EQ" = NEW."EV_STA_EQ"
        AND
            x."EV_STA_ChangedAt" = NEW."EV_STA_ChangedAt"
        AND
            x."EV_STA_EV_ID" = NEW."EV_STA_EV_ID"
        AND
            x."EV_STA_Händelse_Status" = NEW."EV_STA_Händelse_Status"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_STA_Händelse_Status" x
        WHERE
            x."EV_STA_EQ" = NEW."EV_STA_EQ"
        AND
            x."EV_STA_EV_ID" = NEW."EV_STA_EV_ID"
        AND
            x."EV_STA_ChangedAt" = NEW."EV_STA_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_STA_Händelse_Status for: %', concat_ws(', ', NEW."EV_STA_EV_ID", NEW."EV_STA_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_STA_Händelse_Status" ON attributes."EV_STA_Händelse_Status";
CREATE TRIGGER "it_EV_STA_Händelse_Status"
BEFORE INSERT ON attributes."EV_STA_Händelse_Status"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_STA_Händelse_Status"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_UTL_Händelse_Utnyttjande before INSERT trigger on EV_UTL_Händelse_Utnyttjande
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_UTL_Händelse_Utnyttjande"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_UTL_Händelse_Utnyttjande" x
        WHERE
            x."EV_UTL_EV_ID" = NEW."EV_UTL_EV_ID"
        AND
            x."EV_UTL_UTL_ID" = NEW."EV_UTL_UTL_ID"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_UTL_Händelse_Utnyttjande" x
        WHERE
            x."EV_UTL_EV_ID" = NEW."EV_UTL_EV_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_UTL_Händelse_Utnyttjande for: %', NEW."EV_UTL_EV_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_UTL_Händelse_Utnyttjande" ON attributes."EV_UTL_Händelse_Utnyttjande";
CREATE TRIGGER "it_EV_UTL_Händelse_Utnyttjande"
BEFORE INSERT ON attributes."EV_UTL_Händelse_Utnyttjande"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_UTL_Händelse_Utnyttjande"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_LVL_Händelse_Level before INSERT trigger on EV_LVL_Händelse_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_LVL_Händelse_Level"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_LVL_Händelse_Level" x
        WHERE
            x."EV_LVL_ChangedAt" = NEW."EV_LVL_ChangedAt"
        AND
            x."EV_LVL_EV_ID" = NEW."EV_LVL_EV_ID"
        AND
            x."EV_LVL_PLV_ID" = NEW."EV_LVL_PLV_ID"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_LVL_Händelse_Level" x
        WHERE
            x."EV_LVL_EV_ID" = NEW."EV_LVL_EV_ID"
        AND
            x."EV_LVL_ChangedAt" = NEW."EV_LVL_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_LVL_Händelse_Level for: %', concat_ws(', ', NEW."EV_LVL_EV_ID", NEW."EV_LVL_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_LVL_Händelse_Level" ON attributes."EV_LVL_Händelse_Level";
CREATE TRIGGER "it_EV_LVL_Händelse_Level"
BEFORE INSERT ON attributes."EV_LVL_Händelse_Level"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_LVL_Händelse_Level"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_NAM_Scen_Namn before INSERT trigger on ST_NAM_Scen_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_NAM_Scen_Namn"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."ST_NAM_Scen_Namn" x
        WHERE
            x."ST_NAM_EQ" = NEW."ST_NAM_EQ"
        AND
            x."ST_NAM_ChangedAt" = NEW."ST_NAM_ChangedAt"
        AND
            x."ST_NAM_ST_ID" = NEW."ST_NAM_ST_ID"
        AND
            x."ST_NAM_Scen_Namn" = NEW."ST_NAM_Scen_Namn"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."ST_NAM_Scen_Namn" x
        WHERE
            x."ST_NAM_EQ" = NEW."ST_NAM_EQ"
        AND
            x."ST_NAM_ST_ID" = NEW."ST_NAM_ST_ID"
        AND
            x."ST_NAM_ChangedAt" = NEW."ST_NAM_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_NAM_Scen_Namn for: %', concat_ws(', ', NEW."ST_NAM_ST_ID", NEW."ST_NAM_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_NAM_Scen_Namn" ON attributes."ST_NAM_Scen_Namn";
CREATE TRIGGER "it_ST_NAM_Scen_Namn"
BEFORE INSERT ON attributes."ST_NAM_Scen_Namn"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_NAM_Scen_Namn"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_LOC_Scen_Plats before INSERT trigger on ST_LOC_Scen_Plats
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_LOC_Scen_Plats"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."ST_LOC_Scen_Plats" x
        WHERE
            x."ST_LOC_EQ" = NEW."ST_LOC_EQ"
        AND
            x."ST_LOC_ST_ID" = NEW."ST_LOC_ST_ID"
        AND
            md5(x."ST_LOC_Scen_Plats"::text) = md5(NEW."ST_LOC_Scen_Plats"::text)
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."ST_LOC_Scen_Plats" x
        WHERE
            x."ST_LOC_EQ" = NEW."ST_LOC_EQ"
        AND
            x."ST_LOC_ST_ID" = NEW."ST_LOC_ST_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_LOC_Scen_Plats for: %', NEW."ST_LOC_ST_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_LOC_Scen_Plats" ON attributes."ST_LOC_Scen_Plats";
CREATE TRIGGER "it_ST_LOC_Scen_Plats"
BEFORE INSERT ON attributes."ST_LOC_Scen_Plats"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_LOC_Scen_Plats"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_AVG_Scen_Medel before INSERT trigger on ST_AVG_Scen_Medel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_AVG_Scen_Medel"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."ST_AVG_Scen_Medel" x
        WHERE
            x."ST_AVG_ChangedAt" = NEW."ST_AVG_ChangedAt"
        AND
            x."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
        AND
            x."ST_AVG_UTL_ID" = NEW."ST_AVG_UTL_ID"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."ST_AVG_Scen_Medel" x
        WHERE
            x."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
        AND
            x."ST_AVG_ChangedAt" = NEW."ST_AVG_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_AVG_Scen_Medel for: %', concat_ws(', ', NEW."ST_AVG_ST_ID", NEW."ST_AVG_ChangedAt");
    END IF;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."ST_AVG_UTL_ID"
            FROM
                attributes."ST_AVG_Scen_Medel" p
            WHERE
                p."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
            AND
                p."ST_AVG_ChangedAt" < NEW."ST_AVG_ChangedAt"
            ORDER BY
                p."ST_AVG_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."ST_AVG_UTL_ID" = NEW."ST_AVG_UTL_ID"
    ) THEN
        RETURN NULL;
    END IF;
    DELETE FROM
        attributes."ST_AVG_Scen_Medel" x
    WHERE
        x."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
    AND
        x."ST_AVG_ChangedAt" = (
            SELECT
                min(f."ST_AVG_ChangedAt")
            FROM
                attributes."ST_AVG_Scen_Medel" f
            WHERE
                f."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
            AND
                f."ST_AVG_ChangedAt" > NEW."ST_AVG_ChangedAt"
        )
    AND
        x."ST_AVG_UTL_ID" = NEW."ST_AVG_UTL_ID";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_AVG_Scen_Medel" ON attributes."ST_AVG_Scen_Medel";
CREATE TRIGGER "it_ST_AVG_Scen_Medel"
BEFORE INSERT ON attributes."ST_AVG_Scen_Medel"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_AVG_Scen_Medel"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_MIN_Scen_Minimum before INSERT trigger on ST_MIN_Scen_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_MIN_Scen_Minimum"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."ST_MIN_Scen_Minimum" x
        WHERE
            x."ST_MIN_ST_ID" = NEW."ST_MIN_ST_ID"
        AND
            x."ST_MIN_UTL_ID" = NEW."ST_MIN_UTL_ID"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."ST_MIN_Scen_Minimum" x
        WHERE
            x."ST_MIN_ST_ID" = NEW."ST_MIN_ST_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_MIN_Scen_Minimum for: %', NEW."ST_MIN_ST_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_MIN_Scen_Minimum" ON attributes."ST_MIN_Scen_Minimum";
CREATE TRIGGER "it_ST_MIN_Scen_Minimum"
BEFORE INSERT ON attributes."ST_MIN_Scen_Minimum"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_MIN_Scen_Minimum"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_NAM_Skådespelare_Namn before INSERT trigger on AC_NAM_Skådespelare_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_AC_NAM_Skådespelare_Namn"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."AC_NAM_Skådespelare_Namn" x
        WHERE
            x."AC_NAM_ChangedAt" = NEW."AC_NAM_ChangedAt"
        AND
            x."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
        AND
            x."AC_NAM_Skådespelare_Namn" = NEW."AC_NAM_Skådespelare_Namn"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."AC_NAM_Skådespelare_Namn" x
        WHERE
            x."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
        AND
            x."AC_NAM_ChangedAt" = NEW."AC_NAM_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_NAM_Skådespelare_Namn for: %', concat_ws(', ', NEW."AC_NAM_AC_ID", NEW."AC_NAM_ChangedAt");
    END IF;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an attribute that may not be restated refuses it)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."AC_NAM_Skådespelare_Namn"
            FROM
                attributes."AC_NAM_Skådespelare_Namn" p
            WHERE
                p."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
            AND
                p."AC_NAM_ChangedAt" < NEW."AC_NAM_ChangedAt"
            ORDER BY
                p."AC_NAM_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."AC_NAM_Skådespelare_Namn" = NEW."AC_NAM_Skådespelare_Namn"
    ) THEN
        RAISE EXCEPTION 'Restatement in AC_NAM_Skådespelare_Namn for: %', concat_ws(', ', NEW."AC_NAM_AC_ID", NEW."AC_NAM_ChangedAt");
    END IF;
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                f."AC_NAM_Skådespelare_Namn"
            FROM
                attributes."AC_NAM_Skådespelare_Namn" f
            WHERE
                f."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
            AND
                f."AC_NAM_ChangedAt" > NEW."AC_NAM_ChangedAt"
            ORDER BY
                f."AC_NAM_ChangedAt" ASC
            LIMIT 1
        ) fol
        WHERE
            fol."AC_NAM_Skådespelare_Namn" = NEW."AC_NAM_Skådespelare_Namn"
    ) THEN
        RAISE EXCEPTION 'Restatement in AC_NAM_Skådespelare_Namn for: %', concat_ws(', ', NEW."AC_NAM_AC_ID", NEW."AC_NAM_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_NAM_Skådespelare_Namn" ON attributes."AC_NAM_Skådespelare_Namn";
CREATE TRIGGER "it_AC_NAM_Skådespelare_Namn"
BEFORE INSERT ON attributes."AC_NAM_Skådespelare_Namn"
FOR EACH ROW EXECUTE FUNCTION attributes."it_AC_NAM_Skådespelare_Namn"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_GEN_Skådespelare_Kön before INSERT trigger on AC_GEN_Skådespelare_Kön
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_AC_GEN_Skådespelare_Kön"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."AC_GEN_Skådespelare_Kön" x
        WHERE
            x."AC_GEN_AC_ID" = NEW."AC_GEN_AC_ID"
        AND
            x."AC_GEN_GEN_ID" = NEW."AC_GEN_GEN_ID"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."AC_GEN_Skådespelare_Kön" x
        WHERE
            x."AC_GEN_AC_ID" = NEW."AC_GEN_AC_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_GEN_Skådespelare_Kön for: %', NEW."AC_GEN_AC_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_GEN_Skådespelare_Kön" ON attributes."AC_GEN_Skådespelare_Kön";
CREATE TRIGGER "it_AC_GEN_Skådespelare_Kön"
BEFORE INSERT ON attributes."AC_GEN_Skådespelare_Kön"
FOR EACH ROW EXECUTE FUNCTION attributes."it_AC_GEN_Skådespelare_Kön"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_PLV_Skådespelare_Yrkesnivå before INSERT trigger on AC_PLV_Skådespelare_Yrkesnivå
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_AC_PLV_Skådespelare_Yrkesnivå"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."AC_PLV_Skådespelare_Yrkesnivå" x
        WHERE
            x."AC_PLV_ChangedAt" = NEW."AC_PLV_ChangedAt"
        AND
            x."AC_PLV_AC_ID" = NEW."AC_PLV_AC_ID"
        AND
            x."AC_PLV_PLV_ID" = NEW."AC_PLV_PLV_ID"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."AC_PLV_Skådespelare_Yrkesnivå" x
        WHERE
            x."AC_PLV_AC_ID" = NEW."AC_PLV_AC_ID"
        AND
            x."AC_PLV_ChangedAt" = NEW."AC_PLV_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_PLV_Skådespelare_Yrkesnivå for: %', concat_ws(', ', NEW."AC_PLV_AC_ID", NEW."AC_PLV_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_PLV_Skådespelare_Yrkesnivå" ON attributes."AC_PLV_Skådespelare_Yrkesnivå";
CREATE TRIGGER "it_AC_PLV_Skådespelare_Yrkesnivå"
BEFORE INSERT ON attributes."AC_PLV_Skådespelare_Yrkesnivå"
FOR EACH ROW EXECUTE FUNCTION attributes."it_AC_PLV_Skådespelare_Yrkesnivå"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_NAM_Föreställning_Namn before INSERT trigger on PR_NAM_Föreställning_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_PR_NAM_Föreställning_Namn"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."PR_NAM_Föreställning_Namn" x
        WHERE
            x."PR_NAM_PR_ID" = NEW."PR_NAM_PR_ID"
        AND
            x."PR_NAM_Föreställning_Namn" = NEW."PR_NAM_Föreställning_Namn"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."PR_NAM_Föreställning_Namn" x
        WHERE
            x."PR_NAM_PR_ID" = NEW."PR_NAM_PR_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_NAM_Föreställning_Namn for: %', NEW."PR_NAM_PR_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_PR_NAM_Föreställning_Namn" ON attributes."PR_NAM_Föreställning_Namn";
CREATE TRIGGER "it_PR_NAM_Föreställning_Namn"
BEFORE INSERT ON attributes."PR_NAM_Föreställning_Namn"
FOR EACH ROW EXECUTE FUNCTION attributes."it_PR_NAM_Föreställning_Namn"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_LEN_Föreställning_Längd before INSERT trigger on PR_LEN_Föreställning_Längd
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_PR_LEN_Föreställning_Längd"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."PR_LEN_Föreställning_Längd" x
        WHERE
            x."PR_LEN_EQ" = NEW."PR_LEN_EQ"
        AND
            x."PR_LEN_ChangedAt" = NEW."PR_LEN_ChangedAt"
        AND
            x."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
        AND
            x."PR_LEN_Föreställning_Längd" = NEW."PR_LEN_Föreställning_Längd"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."PR_LEN_Föreställning_Längd" x
        WHERE
            x."PR_LEN_EQ" = NEW."PR_LEN_EQ"
        AND
            x."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
        AND
            x."PR_LEN_ChangedAt" = NEW."PR_LEN_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_LEN_Föreställning_Längd for: %', concat_ws(', ', NEW."PR_LEN_PR_ID", NEW."PR_LEN_ChangedAt");
    END IF;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."PR_LEN_Föreställning_Längd"
            FROM
                attributes."PR_LEN_Föreställning_Längd" p
            WHERE
                p."PR_LEN_EQ" = NEW."PR_LEN_EQ"
            AND
                p."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
            AND
                p."PR_LEN_ChangedAt" < NEW."PR_LEN_ChangedAt"
            ORDER BY
                p."PR_LEN_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."PR_LEN_Föreställning_Längd" = NEW."PR_LEN_Föreställning_Längd"
    ) THEN
        RETURN NULL;
    END IF;
    DELETE FROM
        attributes."PR_LEN_Föreställning_Längd" x
    WHERE
        x."PR_LEN_EQ" = NEW."PR_LEN_EQ"
    AND
        x."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
    AND
        x."PR_LEN_ChangedAt" = (
            SELECT
                min(f."PR_LEN_ChangedAt")
            FROM
                attributes."PR_LEN_Föreställning_Längd" f
            WHERE
                f."PR_LEN_EQ" = NEW."PR_LEN_EQ"
            AND
                f."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
            AND
                f."PR_LEN_ChangedAt" > NEW."PR_LEN_ChangedAt"
        )
    AND
        x."PR_LEN_Föreställning_Längd" = NEW."PR_LEN_Föreställning_Längd";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_PR_LEN_Föreställning_Längd" ON attributes."PR_LEN_Föreställning_Längd";
CREATE TRIGGER "it_PR_LEN_Föreställning_Längd"
BEFORE INSERT ON attributes."PR_LEN_Föreställning_Längd"
FOR EACH ROW EXECUTE FUNCTION attributes."it_PR_LEN_Föreställning_Längd"();
