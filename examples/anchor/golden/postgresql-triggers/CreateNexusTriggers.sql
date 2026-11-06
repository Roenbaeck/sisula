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
            "SU_ID_for",
            "Metadata_EV"
        )
        VALUES (
            NEW."SU_ID_for",
            NEW."Metadata_EV"
        )
        RETURNING "EV_ID" INTO _id;
    END IF;
    IF NEW."EV_QTY_Event_Quantity" IS NOT NULL THEN
        INSERT INTO public."EV_QTY_Event_Quantity" (
            "Metadata_EV_QTY",
            "EV_QTY_EV_ID",
            "EV_QTY_Event_Quantity"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_QTY", NEW."Metadata_EV"),
            coalesce(NEW."EV_QTY_EV_ID", _id),
            NEW."EV_QTY_Event_Quantity"
        );
    END IF;
    IF NEW."EV_PLC_Event_Place" IS NOT NULL THEN
        INSERT INTO public."EV_PLC_Event_Place" (
            "Metadata_EV_PLC",
            "EV_PLC_EV_ID",
            "EV_PLC_ChangedAt",
            "EV_PLC_Event_Place"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_PLC", NEW."Metadata_EV"),
            coalesce(NEW."EV_PLC_EV_ID", _id),
            coalesce(NEW."EV_PLC_ChangedAt", _now),
            NEW."EV_PLC_Event_Place"
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
    IF NEW."SU_ID_for" IS DISTINCT FROM OLD."SU_ID_for" THEN
        RAISE EXCEPTION 'The role column SU_ID_for is not updatable.';
    END IF;
    IF NEW."EV_QTY_EV_ID" IS DISTINCT FROM OLD."EV_QTY_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_QTY_EV_ID is not updatable.';
    END IF;
    IF NEW."EV_QTY_Event_Quantity" IS DISTINCT FROM OLD."EV_QTY_Event_Quantity"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."EV_QTY_Event_Quantity" IS NOT NULL AND (
            OLD."EV_QTY_Event_Quantity" IS NULL OR
            OLD."EV_QTY_Event_Quantity" <> NEW."EV_QTY_Event_Quantity"
        ) THEN
            INSERT INTO public."EV_QTY_Event_Quantity" (
                "Metadata_EV_QTY",
                "EV_QTY_EV_ID",
                "EV_QTY_Event_Quantity"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_QTY" IS NOT DISTINCT FROM OLD."Metadata_EV_QTY"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_QTY"
                    END, NEW."Metadata_EV"),
                coalesce(NEW."EV_QTY_EV_ID", NEW."EV_ID"),
                NEW."EV_QTY_Event_Quantity"
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF NEW."Deletable_EV_QTY" IS TRUE
    AND OLD."EV_QTY_Event_Quantity" IS NOT NULL
    AND NEW."EV_QTY_Event_Quantity" IS NULL
    THEN
        IF to_regclass('public."EV_QTY_Event_Quantity_Deleted"') IS NULL THEN
            CREATE TABLE public."EV_QTY_Event_Quantity_Deleted" (
                LIKE public."EV_QTY_Event_Quantity",
                "EV_QTY_Deleted" timestamp
            );
        END IF;
        WITH d AS (
            DELETE FROM public."EV_QTY_Event_Quantity"
            WHERE "EV_QTY_EV_ID" = OLD."EV_ID"
            RETURNING *
        )
        INSERT INTO public."EV_QTY_Event_Quantity_Deleted"
        SELECT
            d.*,
            _now
        FROM
            d;
    END IF;
    IF NEW."EV_PLC_EV_ID" IS DISTINCT FROM OLD."EV_PLC_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_PLC_EV_ID is not updatable.';
    END IF;
    IF NEW."EV_PLC_Event_Place" IS DISTINCT FROM OLD."EV_PLC_Event_Place"
    OR NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."EV_PLC_Event_Place" IS NOT NULL AND (
            NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt" OR
            OLD."EV_PLC_Event_Place" IS NULL OR
            OLD."EV_PLC_Event_Place" <> NEW."EV_PLC_Event_Place"
        ) THEN
            INSERT INTO public."EV_PLC_Event_Place" (
                "Metadata_EV_PLC",
                "EV_PLC_EV_ID",
                "EV_PLC_ChangedAt",
                "EV_PLC_Event_Place"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_PLC" IS NOT DISTINCT FROM OLD."Metadata_EV_PLC"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_PLC"
                    END, NEW."Metadata_EV"),
                coalesce(NEW."EV_PLC_EV_ID", NEW."EV_ID"),
                CASE
                    WHEN NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt" THEN NEW."EV_PLC_ChangedAt"
                    ELSE _now
                END,
                NEW."EV_PLC_Event_Place"
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF NEW."Deletable_EV_PLC" IS TRUE
    AND OLD."EV_PLC_Event_Place" IS NOT NULL
    AND NEW."EV_PLC_Event_Place" IS NULL
    THEN
        IF to_regclass('public."EV_PLC_Event_Place_Deleted"') IS NULL THEN
            CREATE TABLE public."EV_PLC_Event_Place_Deleted" (
                LIKE public."EV_PLC_Event_Place",
                "EV_PLC_Deleted" timestamp
            );
        END IF;
        WITH d AS (
            DELETE FROM public."EV_PLC_Event_Place"
            WHERE "EV_PLC_EV_ID" = OLD."EV_ID"
            RETURNING *
        )
        INSERT INTO public."EV_PLC_Event_Place_Deleted"
        SELECT
            d.*,
            (CASE WHEN NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt" THEN NEW."EV_PLC_ChangedAt" ELSE _now END)::timestamp
        FROM
            d;
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
        public."EV_QTY_Event_Quantity" x
    WHERE
        x."EV_QTY_EV_ID" = OLD."EV_ID"
    ;
    DELETE FROM
        public."EV_PLC_Event_Place" x
    WHERE
        x."EV_PLC_EV_ID" = OLD."EV_ID"
    AND
        x."EV_PLC_ChangedAt" = OLD."EV_PLC_ChangedAt"
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
            public."EV_QTY_Event_Quantity" x
        WHERE
            x."EV_QTY_EV_ID" = a."EV_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."EV_PLC_Event_Place" x
        WHERE
            x."EV_PLC_EV_ID" = a."EV_ID"
    )
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lEV_Event" ON public."lEV_Event";
CREATE TRIGGER "dt_lEV_Event"
INSTEAD OF DELETE ON public."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION public."dt_lEV_Event"();
