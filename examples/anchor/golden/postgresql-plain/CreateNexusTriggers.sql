-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
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
-- it_lEV_Event instead of INSERT trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lEV_Event"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id integer;
BEGIN
    _id := NEW."EV_ID";
    IF _id IS NULL THEN
        INSERT INTO public."EV_Event" (
            "ST_ID_wasHeldAt",
            "PR_ID_wasPlayed",
            "ETY_ID_of",
            "EV_Dummy"
        )
        VALUES (
            NEW."ST_ID_wasHeldAt",
            NEW."PR_ID_wasPlayed",
            NEW."ETY_ID_of",
            null
        )
        RETURNING "EV_ID" INTO _id;
    END IF;
    IF NEW."EV_DAT_Event_Date" IS NOT NULL THEN
        INSERT INTO public."EV_DAT_Event_Date" (
            "EV_ID",
            "EV_DAT_Event_Date"
        )
        VALUES (
            coalesce(NEW."EV_ID", _id),
            NEW."EV_DAT_Event_Date"
        );
    END IF;
    IF NEW."EV_AUD_Event_Audience" IS NOT NULL THEN
        INSERT INTO public."EV_AUD_Event_Audience" (
            "EV_ID",
            "EV_AUD_Event_Audience"
        )
        VALUES (
            coalesce(NEW."EV_ID", _id),
            NEW."EV_AUD_Event_Audience"
        );
    END IF;
    IF NEW."EV_REV_Event_Revenue" IS NOT NULL THEN
        INSERT INTO public."EV_REV_Event_Revenue" (
            "EV_ID",
            "EV_REV_Event_Revenue"
        )
        VALUES (
            coalesce(NEW."EV_ID", _id),
            NEW."EV_REV_Event_Revenue"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lEV_Event" ON public."lEV_Event";
CREATE TRIGGER "it_lEV_Event"
INSTEAD OF INSERT ON public."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION public."it_lEV_Event"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lEV_Event instead of UPDATE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lEV_Event"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    IF NEW."EV_ID" IS DISTINCT FROM OLD."EV_ID" THEN
        RAISE EXCEPTION 'The identity column EV_ID is not updatable.';
    END IF;
    IF NEW."ST_ID_wasHeldAt" IS DISTINCT FROM OLD."ST_ID_wasHeldAt" THEN
        RAISE EXCEPTION 'The role column ST_ID_wasHeldAt is not updatable.';
    END IF;
    IF NEW."PR_ID_wasPlayed" IS DISTINCT FROM OLD."PR_ID_wasPlayed" THEN
        RAISE EXCEPTION 'The role column PR_ID_wasPlayed is not updatable.';
    END IF;
    IF NEW."ETY_ID_of" IS DISTINCT FROM OLD."ETY_ID_of" THEN
        RAISE EXCEPTION 'The role column ETY_ID_of is not updatable.';
    END IF;
    IF NEW."ETY_EventType" IS DISTINCT FROM OLD."ETY_EventType" THEN
        RAISE EXCEPTION 'The role column ETY_EventType is not updatable.';
    END IF;
    IF NEW."EV_DAT_Event_Date" IS DISTINCT FROM OLD."EV_DAT_Event_Date"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."EV_DAT_Event_Date" IS NOT NULL AND (
            OLD."EV_DAT_Event_Date" IS NULL OR
            OLD."EV_DAT_Event_Date" <> NEW."EV_DAT_Event_Date"
        ) THEN
            INSERT INTO public."EV_DAT_Event_Date" (
                "EV_ID",
                "EV_DAT_Event_Date"
            )
            VALUES (
                coalesce(NEW."EV_ID", NEW."EV_ID"),
                NEW."EV_DAT_Event_Date"
            );
        END IF;
    END IF;
    IF NEW."EV_AUD_Event_Audience" IS DISTINCT FROM OLD."EV_AUD_Event_Audience"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."EV_AUD_Event_Audience" IS NOT NULL AND (
            OLD."EV_AUD_Event_Audience" IS NULL OR
            OLD."EV_AUD_Event_Audience" <> NEW."EV_AUD_Event_Audience"
        ) THEN
            INSERT INTO public."EV_AUD_Event_Audience" (
                "EV_ID",
                "EV_AUD_Event_Audience"
            )
            VALUES (
                coalesce(NEW."EV_ID", NEW."EV_ID"),
                NEW."EV_AUD_Event_Audience"
            );
        END IF;
    END IF;
    IF NEW."EV_REV_Event_Revenue" IS DISTINCT FROM OLD."EV_REV_Event_Revenue"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."EV_REV_Event_Revenue" IS NOT NULL AND (
            OLD."EV_REV_Event_Revenue" IS NULL OR
            OLD."EV_REV_Event_Revenue" <> NEW."EV_REV_Event_Revenue"
        ) THEN
            INSERT INTO public."EV_REV_Event_Revenue" (
                "EV_ID",
                "EV_REV_Event_Revenue"
            )
            VALUES (
                coalesce(NEW."EV_ID", NEW."EV_ID"),
                NEW."EV_REV_Event_Revenue"
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lEV_Event" ON public."lEV_Event";
CREATE TRIGGER "ut_lEV_Event"
INSTEAD OF UPDATE ON public."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION public."ut_lEV_Event"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_Event instead of DELETE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lEV_Event"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        public."EV_DAT_Event_Date" x
    WHERE
        x."EV_ID" = OLD."EV_ID"
    ;
    DELETE FROM
        public."EV_AUD_Event_Audience" x
    WHERE
        x."EV_ID" = OLD."EV_ID"
    ;
    DELETE FROM
        public."EV_REV_Event_Revenue" x
    WHERE
        x."EV_ID" = OLD."EV_ID"
    ;
    -- a nexus that has no attribute rows left is removed
    DELETE FROM
        public."EV_Event" a
    WHERE
        a."EV_ID" = OLD."EV_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."EV_DAT_Event_Date" x
        WHERE
            x."EV_ID" = a."EV_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."EV_AUD_Event_Audience" x
        WHERE
            x."EV_ID" = a."EV_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."EV_REV_Event_Revenue" x
        WHERE
            x."EV_ID" = a."EV_ID"
    )
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lEV_Event" ON public."lEV_Event";
CREATE TRIGGER "dt_lEV_Event"
INSTEAD OF DELETE ON public."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION public."dt_lEV_Event"();
