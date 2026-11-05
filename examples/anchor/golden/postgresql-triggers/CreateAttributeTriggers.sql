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
-- it_EV_QTY_Event_Quantity before INSERT trigger on EV_QTY_Event_Quantity
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_EV_QTY_Event_Quantity"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."EV_QTY_Event_Quantity" x
        WHERE
            x."EV_QTY_EV_ID" = NEW."EV_QTY_EV_ID"
        AND
            x."EV_QTY_Event_Quantity" = NEW."EV_QTY_Event_Quantity"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."EV_QTY_Event_Quantity" x
        WHERE
            x."EV_QTY_EV_ID" = NEW."EV_QTY_EV_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_QTY_Event_Quantity for: %', NEW."EV_QTY_EV_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_QTY_Event_Quantity" ON public."EV_QTY_Event_Quantity";
CREATE TRIGGER "it_EV_QTY_Event_Quantity"
BEFORE INSERT ON public."EV_QTY_Event_Quantity"
FOR EACH ROW EXECUTE FUNCTION public."it_EV_QTY_Event_Quantity"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_PLC_Event_Place before INSERT trigger on EV_PLC_Event_Place
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_EV_PLC_Event_Place"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."EV_PLC_Event_Place" x
        WHERE
            x."EV_PLC_ChangedAt" = NEW."EV_PLC_ChangedAt"
        AND
            x."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
        AND
            x."EV_PLC_Event_Place" = NEW."EV_PLC_Event_Place"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."EV_PLC_Event_Place" x
        WHERE
            x."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
        AND
            x."EV_PLC_ChangedAt" = NEW."EV_PLC_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_PLC_Event_Place for: %', concat_ws(', ', NEW."EV_PLC_EV_ID", NEW."EV_PLC_ChangedAt");
    END IF;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an attribute that may not be restated refuses it)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."EV_PLC_Event_Place"
            FROM
                public."EV_PLC_Event_Place" p
            WHERE
                p."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
            AND
                p."EV_PLC_ChangedAt" < NEW."EV_PLC_ChangedAt"
            ORDER BY
                p."EV_PLC_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."EV_PLC_Event_Place" = NEW."EV_PLC_Event_Place"
    ) THEN
        RAISE EXCEPTION 'Restatement in EV_PLC_Event_Place for: %', concat_ws(', ', NEW."EV_PLC_EV_ID", NEW."EV_PLC_ChangedAt");
    END IF;
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                f."EV_PLC_Event_Place"
            FROM
                public."EV_PLC_Event_Place" f
            WHERE
                f."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
            AND
                f."EV_PLC_ChangedAt" > NEW."EV_PLC_ChangedAt"
            ORDER BY
                f."EV_PLC_ChangedAt" ASC
            LIMIT 1
        ) fol
        WHERE
            fol."EV_PLC_Event_Place" = NEW."EV_PLC_Event_Place"
    ) THEN
        RAISE EXCEPTION 'Restatement in EV_PLC_Event_Place for: %', concat_ws(', ', NEW."EV_PLC_EV_ID", NEW."EV_PLC_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_PLC_Event_Place" ON public."EV_PLC_Event_Place";
CREATE TRIGGER "it_EV_PLC_Event_Place"
BEFORE INSERT ON public."EV_PLC_Event_Place"
FOR EACH ROW EXECUTE FUNCTION public."it_EV_PLC_Event_Place"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NAM_Subject_Name before INSERT trigger on SU_NAM_Subject_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_NAM_Subject_Name"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_NAM_Subject_Name" x
        WHERE
            x."SU_NAM_SU_ID" = NEW."SU_NAM_SU_ID"
        AND
            x."SU_NAM_Subject_Name" = NEW."SU_NAM_Subject_Name"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_NAM_Subject_Name" x
        WHERE
            x."SU_NAM_SU_ID" = NEW."SU_NAM_SU_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_NAM_Subject_Name for: %', NEW."SU_NAM_SU_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_NAM_Subject_Name" ON public."SU_NAM_Subject_Name";
CREATE TRIGGER "it_SU_NAM_Subject_Name"
BEFORE INSERT ON public."SU_NAM_Subject_Name"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_NAM_Subject_Name"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_COD_Subject_Code before INSERT trigger on SU_COD_Subject_Code
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_COD_Subject_Code"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_COD_Subject_Code" x
        WHERE
            x."SU_COD_SU_ID" = NEW."SU_COD_SU_ID"
        AND
            x."SU_COD_Subject_Code" = NEW."SU_COD_Subject_Code"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_COD_Subject_Code" x
        WHERE
            x."SU_COD_SU_ID" = NEW."SU_COD_SU_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_COD_Subject_Code for: %', NEW."SU_COD_SU_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_COD_Subject_Code" ON public."SU_COD_Subject_Code";
CREATE TRIGGER "it_SU_COD_Subject_Code"
BEFORE INSERT ON public."SU_COD_Subject_Code"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_COD_Subject_Code"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_GRD_Subject_Grade before INSERT trigger on SU_GRD_Subject_Grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_GRD_Subject_Grade"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_GRD_Subject_Grade" x
        WHERE
            x."SU_GRD_SU_ID" = NEW."SU_GRD_SU_ID"
        AND
            x."SU_GRD_GRD_ID" = NEW."SU_GRD_GRD_ID"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_GRD_Subject_Grade" x
        WHERE
            x."SU_GRD_SU_ID" = NEW."SU_GRD_SU_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_GRD_Subject_Grade for: %', NEW."SU_GRD_SU_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_GRD_Subject_Grade" ON public."SU_GRD_Subject_Grade";
CREATE TRIGGER "it_SU_GRD_Subject_Grade"
BEFORE INSERT ON public."SU_GRD_Subject_Grade"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_GRD_Subject_Grade"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NOT_Subject_Note before INSERT trigger on SU_NOT_Subject_Note
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_NOT_Subject_Note"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_NOT_Subject_Note" x
        WHERE
            x."SU_NOT_SU_ID" = NEW."SU_NOT_SU_ID"
        AND
            md5(x."SU_NOT_Subject_Note"::text) = md5(NEW."SU_NOT_Subject_Note"::text)
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_NOT_Subject_Note" x
        WHERE
            x."SU_NOT_SU_ID" = NEW."SU_NOT_SU_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_NOT_Subject_Note for: %', NEW."SU_NOT_SU_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_NOT_Subject_Note" ON public."SU_NOT_Subject_Note";
CREATE TRIGGER "it_SU_NOT_Subject_Note"
BEFORE INSERT ON public."SU_NOT_Subject_Note"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_NOT_Subject_Note"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TTL_Subject_Title before INSERT trigger on SU_TTL_Subject_Title
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_TTL_Subject_Title"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_TTL_Subject_Title" x
        WHERE
            x."SU_TTL_ChangedAt" = NEW."SU_TTL_ChangedAt"
        AND
            x."SU_TTL_SU_ID" = NEW."SU_TTL_SU_ID"
        AND
            x."SU_TTL_Subject_Title" = NEW."SU_TTL_Subject_Title"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_TTL_Subject_Title" x
        WHERE
            x."SU_TTL_SU_ID" = NEW."SU_TTL_SU_ID"
        AND
            x."SU_TTL_ChangedAt" = NEW."SU_TTL_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TTL_Subject_Title for: %', concat_ws(', ', NEW."SU_TTL_SU_ID", NEW."SU_TTL_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_TTL_Subject_Title" ON public."SU_TTL_Subject_Title";
CREATE TRIGGER "it_SU_TTL_Subject_Title"
BEFORE INSERT ON public."SU_TTL_Subject_Title"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_TTL_Subject_Title"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_STA_Subject_State before INSERT trigger on SU_STA_Subject_State
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_STA_Subject_State"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_STA_Subject_State" x
        WHERE
            x."SU_STA_ChangedAt" = NEW."SU_STA_ChangedAt"
        AND
            x."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
        AND
            x."SU_STA_Subject_State" = NEW."SU_STA_Subject_State"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_STA_Subject_State" x
        WHERE
            x."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
        AND
            x."SU_STA_ChangedAt" = NEW."SU_STA_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_STA_Subject_State for: %', concat_ws(', ', NEW."SU_STA_SU_ID", NEW."SU_STA_ChangedAt");
    END IF;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an attribute that may not be restated refuses it)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_STA_Subject_State"
            FROM
                public."SU_STA_Subject_State" p
            WHERE
                p."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
            AND
                p."SU_STA_ChangedAt" < NEW."SU_STA_ChangedAt"
            ORDER BY
                p."SU_STA_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."SU_STA_Subject_State" = NEW."SU_STA_Subject_State"
    ) THEN
        RAISE EXCEPTION 'Restatement in SU_STA_Subject_State for: %', concat_ws(', ', NEW."SU_STA_SU_ID", NEW."SU_STA_ChangedAt");
    END IF;
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                f."SU_STA_Subject_State"
            FROM
                public."SU_STA_Subject_State" f
            WHERE
                f."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
            AND
                f."SU_STA_ChangedAt" > NEW."SU_STA_ChangedAt"
            ORDER BY
                f."SU_STA_ChangedAt" ASC
            LIMIT 1
        ) fol
        WHERE
            fol."SU_STA_Subject_State" = NEW."SU_STA_Subject_State"
    ) THEN
        RAISE EXCEPTION 'Restatement in SU_STA_Subject_State for: %', concat_ws(', ', NEW."SU_STA_SU_ID", NEW."SU_STA_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_STA_Subject_State" ON public."SU_STA_Subject_State";
CREATE TRIGGER "it_SU_STA_Subject_State"
BEFORE INSERT ON public."SU_STA_Subject_State"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_STA_Subject_State"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LBL_Subject_Label before INSERT trigger on SU_LBL_Subject_Label
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_LBL_Subject_Label"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_LBL_Subject_Label" x
        WHERE
            x."SU_LBL_ChangedAt" = NEW."SU_LBL_ChangedAt"
        AND
            x."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
        AND
            x."SU_LBL_Subject_Label" = NEW."SU_LBL_Subject_Label"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_LBL_Subject_Label" x
        WHERE
            x."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
        AND
            x."SU_LBL_ChangedAt" = NEW."SU_LBL_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_LBL_Subject_Label for: %', concat_ws(', ', NEW."SU_LBL_SU_ID", NEW."SU_LBL_ChangedAt");
    END IF;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_LBL_Subject_Label"
            FROM
                public."SU_LBL_Subject_Label" p
            WHERE
                p."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
            AND
                p."SU_LBL_ChangedAt" < NEW."SU_LBL_ChangedAt"
            ORDER BY
                p."SU_LBL_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."SU_LBL_Subject_Label" = NEW."SU_LBL_Subject_Label"
    ) THEN
        RETURN NULL;
    END IF;
    DELETE FROM
        public."SU_LBL_Subject_Label" x
    WHERE
        x."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
    AND
        x."SU_LBL_ChangedAt" = (
            SELECT
                min(f."SU_LBL_ChangedAt")
            FROM
                public."SU_LBL_Subject_Label" f
            WHERE
                f."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
            AND
                f."SU_LBL_ChangedAt" > NEW."SU_LBL_ChangedAt"
        )
    AND
        x."SU_LBL_Subject_Label" = NEW."SU_LBL_Subject_Label";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_LBL_Subject_Label" ON public."SU_LBL_Subject_Label";
CREATE TRIGGER "it_SU_LBL_Subject_Label"
BEFORE INSERT ON public."SU_LBL_Subject_Label"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_LBL_Subject_Label"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TAG_Subject_Tag before INSERT trigger on SU_TAG_Subject_Tag
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_TAG_Subject_Tag"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_TAG_Subject_Tag" x
        WHERE
            x."SU_TAG_ChangedAt" = NEW."SU_TAG_ChangedAt"
        AND
            x."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
        AND
            x."SU_TAG_Subject_Tag" = NEW."SU_TAG_Subject_Tag"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_TAG_Subject_Tag" x
        WHERE
            x."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
        AND
            x."SU_TAG_ChangedAt" = NEW."SU_TAG_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TAG_Subject_Tag for: %', concat_ws(', ', NEW."SU_TAG_SU_ID", NEW."SU_TAG_ChangedAt");
    END IF;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_TAG_Subject_Tag"
            FROM
                public."SU_TAG_Subject_Tag" p
            WHERE
                p."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
            AND
                p."SU_TAG_ChangedAt" < NEW."SU_TAG_ChangedAt"
            ORDER BY
                p."SU_TAG_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."SU_TAG_Subject_Tag" = NEW."SU_TAG_Subject_Tag"
    ) THEN
        RETURN NULL;
    END IF;
    DELETE FROM
        public."SU_TAG_Subject_Tag" x
    WHERE
        x."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
    AND
        x."SU_TAG_ChangedAt" = (
            SELECT
                min(f."SU_TAG_ChangedAt")
            FROM
                public."SU_TAG_Subject_Tag" f
            WHERE
                f."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
            AND
                f."SU_TAG_ChangedAt" > NEW."SU_TAG_ChangedAt"
        )
    AND
        x."SU_TAG_Subject_Tag" = NEW."SU_TAG_Subject_Tag";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_TAG_Subject_Tag" ON public."SU_TAG_Subject_Tag";
CREATE TRIGGER "it_SU_TAG_Subject_Tag"
BEFORE INSERT ON public."SU_TAG_Subject_Tag"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_TAG_Subject_Tag"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LVL_Subject_Level before INSERT trigger on SU_LVL_Subject_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_LVL_Subject_Level"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_LVL_Subject_Level" x
        WHERE
            x."SU_LVL_ChangedAt" = NEW."SU_LVL_ChangedAt"
        AND
            x."SU_LVL_SU_ID" = NEW."SU_LVL_SU_ID"
        AND
            x."SU_LVL_GRD_ID" = NEW."SU_LVL_GRD_ID"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_LVL_Subject_Level" x
        WHERE
            x."SU_LVL_SU_ID" = NEW."SU_LVL_SU_ID"
        AND
            x."SU_LVL_ChangedAt" = NEW."SU_LVL_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_LVL_Subject_Level for: %', concat_ws(', ', NEW."SU_LVL_SU_ID", NEW."SU_LVL_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_LVL_Subject_Level" ON public."SU_LVL_Subject_Level";
CREATE TRIGGER "it_SU_LVL_Subject_Level"
BEFORE INSERT ON public."SU_LVL_Subject_Level"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_LVL_Subject_Level"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TXT_Subject_Text before INSERT trigger on SU_TXT_Subject_Text
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_TXT_Subject_Text"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_TXT_Subject_Text" x
        WHERE
            x."SU_TXT_ChangedAt" = NEW."SU_TXT_ChangedAt"
        AND
            x."SU_TXT_SU_ID" = NEW."SU_TXT_SU_ID"
        AND
            md5(x."SU_TXT_Subject_Text"::text) = md5(NEW."SU_TXT_Subject_Text"::text)
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_TXT_Subject_Text" x
        WHERE
            x."SU_TXT_SU_ID" = NEW."SU_TXT_SU_ID"
        AND
            x."SU_TXT_ChangedAt" = NEW."SU_TXT_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TXT_Subject_Text for: %', concat_ws(', ', NEW."SU_TXT_SU_ID", NEW."SU_TXT_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_TXT_Subject_Text" ON public."SU_TXT_Subject_Text";
CREATE TRIGGER "it_SU_TXT_Subject_Text"
BEFORE INSERT ON public."SU_TXT_Subject_Text"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_TXT_Subject_Text"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ASR_Subject_Assessment before INSERT trigger on SU_ASR_Subject_Assessment
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_ASR_Subject_Assessment"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_ASR_Subject_Assessment" x
        WHERE
            x."SU_ASR_ChangedAt" = NEW."SU_ASR_ChangedAt"
        AND
            x."SU_ASR_SU_ID" = NEW."SU_ASR_SU_ID"
        AND
            x."SU_ASR_Subject_Assessment" = NEW."SU_ASR_Subject_Assessment"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_ASR_Subject_Assessment" x
        WHERE
            x."SU_ASR_SU_ID" = NEW."SU_ASR_SU_ID"
        AND
            x."SU_ASR_ChangedAt" = NEW."SU_ASR_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_ASR_Subject_Assessment for: %', concat_ws(', ', NEW."SU_ASR_SU_ID", NEW."SU_ASR_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_ASR_Subject_Assessment" ON public."SU_ASR_Subject_Assessment";
CREATE TRIGGER "it_SU_ASR_Subject_Assessment"
BEFORE INSERT ON public."SU_ASR_Subject_Assessment"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_ASR_Subject_Assessment"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ERS_Subject_Erasable before INSERT trigger on SU_ERS_Subject_Erasable
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_ERS_Subject_Erasable"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_ERS_Subject_Erasable" x
        WHERE
            x."SU_ERS_ChangedAt" = NEW."SU_ERS_ChangedAt"
        AND
            x."SU_ERS_SU_ID" = NEW."SU_ERS_SU_ID"
        AND
            x."SU_ERS_Subject_Erasable" = NEW."SU_ERS_Subject_Erasable"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_ERS_Subject_Erasable" x
        WHERE
            x."SU_ERS_SU_ID" = NEW."SU_ERS_SU_ID"
        AND
            x."SU_ERS_ChangedAt" = NEW."SU_ERS_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_ERS_Subject_Erasable for: %', concat_ws(', ', NEW."SU_ERS_SU_ID", NEW."SU_ERS_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_ERS_Subject_Erasable" ON public."SU_ERS_Subject_Erasable";
CREATE TRIGGER "it_SU_ERS_Subject_Erasable"
BEFORE INSERT ON public."SU_ERS_Subject_Erasable"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_ERS_Subject_Erasable"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OB_NAM_Object_Name before INSERT trigger on OB_NAM_Object_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_OB_NAM_Object_Name"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."OB_NAM_Object_Name" x
        WHERE
            x."OB_NAM_OB_ID" = NEW."OB_NAM_OB_ID"
        AND
            x."OB_NAM_Object_Name" = NEW."OB_NAM_Object_Name"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."OB_NAM_Object_Name" x
        WHERE
            x."OB_NAM_OB_ID" = NEW."OB_NAM_OB_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in OB_NAM_Object_Name for: %', NEW."OB_NAM_OB_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_OB_NAM_Object_Name" ON public."OB_NAM_Object_Name";
CREATE TRIGGER "it_OB_NAM_Object_Name"
BEFORE INSERT ON public."OB_NAM_Object_Name"
FOR EACH ROW EXECUTE FUNCTION public."it_OB_NAM_Object_Name"();
