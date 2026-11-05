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
-- it_EV_DAT_Event_Date before INSERT trigger on EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_DAT_Event_Date"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_DAT_Event_Date" x
        WHERE
            x."EV_DAT_EV_ID" = NEW."EV_DAT_EV_ID"
        AND
            x."EV_DAT_Event_Date" = NEW."EV_DAT_Event_Date"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_DAT_Event_Date" x
        WHERE
            x."EV_DAT_EV_ID" = NEW."EV_DAT_EV_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_DAT_Event_Date for: %', NEW."EV_DAT_EV_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_DAT_Event_Date" ON attributes."EV_DAT_Event_Date";
CREATE TRIGGER "it_EV_DAT_Event_Date"
BEFORE INSERT ON attributes."EV_DAT_Event_Date"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_DAT_Event_Date"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_AUD_Event_Audience before INSERT trigger on EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_AUD_Event_Audience"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_AUD_Event_Audience" x
        WHERE
            x."EV_AUD_EV_ID" = NEW."EV_AUD_EV_ID"
        AND
            x."EV_AUD_Event_Audience" = NEW."EV_AUD_Event_Audience"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_AUD_Event_Audience" x
        WHERE
            x."EV_AUD_EV_ID" = NEW."EV_AUD_EV_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_AUD_Event_Audience for: %', NEW."EV_AUD_EV_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_AUD_Event_Audience" ON attributes."EV_AUD_Event_Audience";
CREATE TRIGGER "it_EV_AUD_Event_Audience"
BEFORE INSERT ON attributes."EV_AUD_Event_Audience"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_AUD_Event_Audience"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_REV_Event_Revenue before INSERT trigger on EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_REV_Event_Revenue"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_REV_Event_Revenue" x
        WHERE
            x."EV_REV_EV_ID" = NEW."EV_REV_EV_ID"
        AND
            x."EV_REV_Event_Revenue" = NEW."EV_REV_Event_Revenue"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_REV_Event_Revenue" x
        WHERE
            x."EV_REV_EV_ID" = NEW."EV_REV_EV_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_REV_Event_Revenue for: %', NEW."EV_REV_EV_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_REV_Event_Revenue" ON attributes."EV_REV_Event_Revenue";
CREATE TRIGGER "it_EV_REV_Event_Revenue"
BEFORE INSERT ON attributes."EV_REV_Event_Revenue"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_REV_Event_Revenue"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_STA_Event_Status before INSERT trigger on EV_STA_Event_Status
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_STA_Event_Status"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_STA_Event_Status" x
        WHERE
            x."EV_STA_ChangedAt" = NEW."EV_STA_ChangedAt"
        AND
            x."EV_STA_EV_ID" = NEW."EV_STA_EV_ID"
        AND
            x."EV_STA_Event_Status" = NEW."EV_STA_Event_Status"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_STA_Event_Status" x
        WHERE
            x."EV_STA_EV_ID" = NEW."EV_STA_EV_ID"
        AND
            x."EV_STA_ChangedAt" = NEW."EV_STA_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_STA_Event_Status for: %', concat_ws(', ', NEW."EV_STA_EV_ID", NEW."EV_STA_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_STA_Event_Status" ON attributes."EV_STA_Event_Status";
CREATE TRIGGER "it_EV_STA_Event_Status"
BEFORE INSERT ON attributes."EV_STA_Event_Status"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_STA_Event_Status"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_UTL_Event_Utilization before INSERT trigger on EV_UTL_Event_Utilization
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_UTL_Event_Utilization"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_UTL_Event_Utilization" x
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
            attributes."EV_UTL_Event_Utilization" x
        WHERE
            x."EV_UTL_EV_ID" = NEW."EV_UTL_EV_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_UTL_Event_Utilization for: %', NEW."EV_UTL_EV_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_UTL_Event_Utilization" ON attributes."EV_UTL_Event_Utilization";
CREATE TRIGGER "it_EV_UTL_Event_Utilization"
BEFORE INSERT ON attributes."EV_UTL_Event_Utilization"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_UTL_Event_Utilization"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_LVL_Event_Level before INSERT trigger on EV_LVL_Event_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_LVL_Event_Level"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."EV_LVL_Event_Level" x
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
            attributes."EV_LVL_Event_Level" x
        WHERE
            x."EV_LVL_EV_ID" = NEW."EV_LVL_EV_ID"
        AND
            x."EV_LVL_ChangedAt" = NEW."EV_LVL_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_LVL_Event_Level for: %', concat_ws(', ', NEW."EV_LVL_EV_ID", NEW."EV_LVL_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_LVL_Event_Level" ON attributes."EV_LVL_Event_Level";
CREATE TRIGGER "it_EV_LVL_Event_Level"
BEFORE INSERT ON attributes."EV_LVL_Event_Level"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_LVL_Event_Level"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_NAM_Stage_Name before INSERT trigger on ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_NAM_Stage_Name"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."ST_NAM_Stage_Name" x
        WHERE
            x."ST_NAM_ChangedAt" = NEW."ST_NAM_ChangedAt"
        AND
            x."ST_NAM_ST_ID" = NEW."ST_NAM_ST_ID"
        AND
            x."ST_NAM_Stage_Name" = NEW."ST_NAM_Stage_Name"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."ST_NAM_Stage_Name" x
        WHERE
            x."ST_NAM_ST_ID" = NEW."ST_NAM_ST_ID"
        AND
            x."ST_NAM_ChangedAt" = NEW."ST_NAM_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_NAM_Stage_Name for: %', concat_ws(', ', NEW."ST_NAM_ST_ID", NEW."ST_NAM_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_NAM_Stage_Name" ON attributes."ST_NAM_Stage_Name";
CREATE TRIGGER "it_ST_NAM_Stage_Name"
BEFORE INSERT ON attributes."ST_NAM_Stage_Name"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_NAM_Stage_Name"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_LOC_Stage_Location before INSERT trigger on ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_LOC_Stage_Location"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."ST_LOC_Stage_Location" x
        WHERE
            x."ST_LOC_ST_ID" = NEW."ST_LOC_ST_ID"
        AND
            md5(x."ST_LOC_Stage_Location"::text) = md5(NEW."ST_LOC_Stage_Location"::text)
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."ST_LOC_Stage_Location" x
        WHERE
            x."ST_LOC_ST_ID" = NEW."ST_LOC_ST_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_LOC_Stage_Location for: %', NEW."ST_LOC_ST_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_LOC_Stage_Location" ON attributes."ST_LOC_Stage_Location";
CREATE TRIGGER "it_ST_LOC_Stage_Location"
BEFORE INSERT ON attributes."ST_LOC_Stage_Location"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_LOC_Stage_Location"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_AVG_Stage_Average before INSERT trigger on ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_AVG_Stage_Average"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."ST_AVG_Stage_Average" x
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
            attributes."ST_AVG_Stage_Average" x
        WHERE
            x."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
        AND
            x."ST_AVG_ChangedAt" = NEW."ST_AVG_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_AVG_Stage_Average for: %', concat_ws(', ', NEW."ST_AVG_ST_ID", NEW."ST_AVG_ChangedAt");
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
                attributes."ST_AVG_Stage_Average" p
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
        attributes."ST_AVG_Stage_Average" x
    WHERE
        x."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
    AND
        x."ST_AVG_ChangedAt" = (
            SELECT
                min(f."ST_AVG_ChangedAt")
            FROM
                attributes."ST_AVG_Stage_Average" f
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
DROP TRIGGER IF EXISTS "it_ST_AVG_Stage_Average" ON attributes."ST_AVG_Stage_Average";
CREATE TRIGGER "it_ST_AVG_Stage_Average"
BEFORE INSERT ON attributes."ST_AVG_Stage_Average"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_AVG_Stage_Average"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_MIN_Stage_Minimum before INSERT trigger on ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_MIN_Stage_Minimum"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."ST_MIN_Stage_Minimum" x
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
            attributes."ST_MIN_Stage_Minimum" x
        WHERE
            x."ST_MIN_ST_ID" = NEW."ST_MIN_ST_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_MIN_Stage_Minimum for: %', NEW."ST_MIN_ST_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_MIN_Stage_Minimum" ON attributes."ST_MIN_Stage_Minimum";
CREATE TRIGGER "it_ST_MIN_Stage_Minimum"
BEFORE INSERT ON attributes."ST_MIN_Stage_Minimum"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_MIN_Stage_Minimum"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_NAM_Actor_Name before INSERT trigger on AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_AC_NAM_Actor_Name"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."AC_NAM_Actor_Name" x
        WHERE
            x."AC_NAM_ChangedAt" = NEW."AC_NAM_ChangedAt"
        AND
            x."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
        AND
            x."AC_NAM_Actor_Name" = NEW."AC_NAM_Actor_Name"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."AC_NAM_Actor_Name" x
        WHERE
            x."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
        AND
            x."AC_NAM_ChangedAt" = NEW."AC_NAM_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_NAM_Actor_Name for: %', concat_ws(', ', NEW."AC_NAM_AC_ID", NEW."AC_NAM_ChangedAt");
    END IF;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an attribute that may not be restated refuses it)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."AC_NAM_Actor_Name"
            FROM
                attributes."AC_NAM_Actor_Name" p
            WHERE
                p."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
            AND
                p."AC_NAM_ChangedAt" < NEW."AC_NAM_ChangedAt"
            ORDER BY
                p."AC_NAM_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."AC_NAM_Actor_Name" = NEW."AC_NAM_Actor_Name"
    ) THEN
        RAISE EXCEPTION 'Restatement in AC_NAM_Actor_Name for: %', concat_ws(', ', NEW."AC_NAM_AC_ID", NEW."AC_NAM_ChangedAt");
    END IF;
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                f."AC_NAM_Actor_Name"
            FROM
                attributes."AC_NAM_Actor_Name" f
            WHERE
                f."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
            AND
                f."AC_NAM_ChangedAt" > NEW."AC_NAM_ChangedAt"
            ORDER BY
                f."AC_NAM_ChangedAt" ASC
            LIMIT 1
        ) fol
        WHERE
            fol."AC_NAM_Actor_Name" = NEW."AC_NAM_Actor_Name"
    ) THEN
        RAISE EXCEPTION 'Restatement in AC_NAM_Actor_Name for: %', concat_ws(', ', NEW."AC_NAM_AC_ID", NEW."AC_NAM_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_NAM_Actor_Name" ON attributes."AC_NAM_Actor_Name";
CREATE TRIGGER "it_AC_NAM_Actor_Name"
BEFORE INSERT ON attributes."AC_NAM_Actor_Name"
FOR EACH ROW EXECUTE FUNCTION attributes."it_AC_NAM_Actor_Name"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_GEN_Actor_Gender before INSERT trigger on AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_AC_GEN_Actor_Gender"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."AC_GEN_Actor_Gender" x
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
            attributes."AC_GEN_Actor_Gender" x
        WHERE
            x."AC_GEN_AC_ID" = NEW."AC_GEN_AC_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_GEN_Actor_Gender for: %', NEW."AC_GEN_AC_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_GEN_Actor_Gender" ON attributes."AC_GEN_Actor_Gender";
CREATE TRIGGER "it_AC_GEN_Actor_Gender"
BEFORE INSERT ON attributes."AC_GEN_Actor_Gender"
FOR EACH ROW EXECUTE FUNCTION attributes."it_AC_GEN_Actor_Gender"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_PLV_Actor_ProfessionalLevel before INSERT trigger on AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_AC_PLV_Actor_ProfessionalLevel"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."AC_PLV_Actor_ProfessionalLevel" x
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
            attributes."AC_PLV_Actor_ProfessionalLevel" x
        WHERE
            x."AC_PLV_AC_ID" = NEW."AC_PLV_AC_ID"
        AND
            x."AC_PLV_ChangedAt" = NEW."AC_PLV_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: %', concat_ws(', ', NEW."AC_PLV_AC_ID", NEW."AC_PLV_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_PLV_Actor_ProfessionalLevel" ON attributes."AC_PLV_Actor_ProfessionalLevel";
CREATE TRIGGER "it_AC_PLV_Actor_ProfessionalLevel"
BEFORE INSERT ON attributes."AC_PLV_Actor_ProfessionalLevel"
FOR EACH ROW EXECUTE FUNCTION attributes."it_AC_PLV_Actor_ProfessionalLevel"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_NAM_Program_Name before INSERT trigger on PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_PR_NAM_Program_Name"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."PR_NAM_Program_Name" x
        WHERE
            x."PR_NAM_PR_ID" = NEW."PR_NAM_PR_ID"
        AND
            x."PR_NAM_Program_Name" = NEW."PR_NAM_Program_Name"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."PR_NAM_Program_Name" x
        WHERE
            x."PR_NAM_PR_ID" = NEW."PR_NAM_PR_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_NAM_Program_Name for: %', NEW."PR_NAM_PR_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_PR_NAM_Program_Name" ON attributes."PR_NAM_Program_Name";
CREATE TRIGGER "it_PR_NAM_Program_Name"
BEFORE INSERT ON attributes."PR_NAM_Program_Name"
FOR EACH ROW EXECUTE FUNCTION attributes."it_PR_NAM_Program_Name"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_LEN_Program_Length before INSERT trigger on PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_PR_LEN_Program_Length"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."PR_LEN_Program_Length" x
        WHERE
            x."PR_LEN_ChangedAt" = NEW."PR_LEN_ChangedAt"
        AND
            x."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
        AND
            x."PR_LEN_Program_Length" = NEW."PR_LEN_Program_Length"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            attributes."PR_LEN_Program_Length" x
        WHERE
            x."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
        AND
            x."PR_LEN_ChangedAt" = NEW."PR_LEN_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_LEN_Program_Length for: %', concat_ws(', ', NEW."PR_LEN_PR_ID", NEW."PR_LEN_ChangedAt");
    END IF;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."PR_LEN_Program_Length"
            FROM
                attributes."PR_LEN_Program_Length" p
            WHERE
                p."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
            AND
                p."PR_LEN_ChangedAt" < NEW."PR_LEN_ChangedAt"
            ORDER BY
                p."PR_LEN_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."PR_LEN_Program_Length" = NEW."PR_LEN_Program_Length"
    ) THEN
        RETURN NULL;
    END IF;
    DELETE FROM
        attributes."PR_LEN_Program_Length" x
    WHERE
        x."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
    AND
        x."PR_LEN_ChangedAt" = (
            SELECT
                min(f."PR_LEN_ChangedAt")
            FROM
                attributes."PR_LEN_Program_Length" f
            WHERE
                f."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
            AND
                f."PR_LEN_ChangedAt" > NEW."PR_LEN_ChangedAt"
        )
    AND
        x."PR_LEN_Program_Length" = NEW."PR_LEN_Program_Length";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_PR_LEN_Program_Length" ON attributes."PR_LEN_Program_Length";
CREATE TRIGGER "it_PR_LEN_Program_Length"
BEFORE INSERT ON attributes."PR_LEN_Program_Length"
FOR EACH ROW EXECUTE FUNCTION attributes."it_PR_LEN_Program_Length"();
