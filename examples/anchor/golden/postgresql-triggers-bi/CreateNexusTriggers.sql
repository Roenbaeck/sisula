-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the assembled views of the attributes (whose triggers keep the
-- posit and annex tables) in a consistent way. Default values are used for some columns if not provided by the
-- corresponding SQL statements: the changing and positing times are now, the reliability is 1.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates (the triggers of the attributes see to that).
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
            "EV_QTY_Event_Quantity",
            "EV_QTY_PositedAt",
            "EV_QTY_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_QTY", NEW."Metadata_EV"),
            coalesce(NEW."EV_QTY_EV_ID", _id),
            NEW."EV_QTY_Event_Quantity",
            coalesce(NEW."EV_QTY_PositedAt", _now),
            coalesce(NEW."EV_QTY_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."EV_PLC_Event_Place" IS NOT NULL THEN
        INSERT INTO public."EV_PLC_Event_Place" (
            "Metadata_EV_PLC",
            "EV_PLC_EV_ID",
            "EV_PLC_Event_Place",
            "EV_PLC_ChangedAt",
            "EV_PLC_PositedAt",
            "EV_PLC_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_PLC", NEW."Metadata_EV"),
            coalesce(NEW."EV_PLC_EV_ID", _id),
            NEW."EV_PLC_Event_Place",
            coalesce(NEW."EV_PLC_ChangedAt", _now),
            coalesce(NEW."EV_PLC_PositedAt", _now),
            coalesce(NEW."EV_PLC_Reliability", NEW."Reliability", 1)
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
    _reliability decimal(5,2);
    _positing timestamp;
BEGIN
    IF NEW."EV_ID" IS DISTINCT FROM OLD."EV_ID" THEN
        RAISE EXCEPTION 'The identity column EV_ID is not updatable.';
    END IF;
    IF NEW."SU_ID_for" IS DISTINCT FROM OLD."SU_ID_for" THEN
        RAISE EXCEPTION 'The role column SU_ID_for is not updatable.';
    END IF;
    IF NEW."EV_QTY_ID" IS DISTINCT FROM OLD."EV_QTY_ID" THEN
        RAISE EXCEPTION 'The identity column EV_QTY_ID is not updatable.';
    END IF;
    IF NEW."EV_QTY_EV_ID" IS DISTINCT FROM OLD."EV_QTY_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_QTY_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_QTY_Event_Quantity, and when it posits
    _reliability := CASE
        WHEN NEW."EV_QTY_Reliability" IS DISTINCT FROM OLD."EV_QTY_Reliability" THEN NEW."EV_QTY_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."EV_QTY_Reliability"
    END;
    _positing := CASE
        WHEN NEW."EV_QTY_PositedAt" IS DISTINCT FROM OLD."EV_QTY_PositedAt" THEN NEW."EV_QTY_PositedAt"
        ELSE _now
    END;
    IF NEW."EV_QTY_Event_Quantity" IS DISTINCT FROM OLD."EV_QTY_Event_Quantity"
    OR NEW."EV_QTY_PositedAt" IS DISTINCT FROM OLD."EV_QTY_PositedAt"
    OR NEW."EV_QTY_Reliability" IS DISTINCT FROM OLD."EV_QTY_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."EV_QTY_Event_Quantity" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_QTY_Event_Quantity" IS NULL
            OR NEW."EV_QTY_PositedAt" IS DISTINCT FROM OLD."EV_QTY_PositedAt"
            OR OLD."EV_QTY_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_QTY_Event_Quantity" <> NEW."EV_QTY_Event_Quantity"
            THEN
                INSERT INTO public."EV_QTY_Event_Quantity" (
                    "Metadata_EV_QTY",
                    "EV_QTY_EV_ID",
                    "EV_QTY_Event_Quantity",
                    "EV_QTY_PositedAt",
                    "EV_QTY_Reliability"
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
                    NEW."EV_QTY_Event_Quantity",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."EV_QTY_Event_Quantity" IS NULL AND OLD."EV_QTY_Event_Quantity" IS NOT NULL THEN
            INSERT INTO public."EV_QTY_Event_Quantity" (
                "Metadata_EV_QTY",
                "EV_QTY_EV_ID",
                "EV_QTY_Event_Quantity",
                "EV_QTY_PositedAt",
                "EV_QTY_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_QTY" IS NOT DISTINCT FROM OLD."Metadata_EV_QTY"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_QTY"
                    END, NEW."Metadata_EV"),
                p."EV_QTY_EV_ID",
                p."EV_QTY_Event_Quantity",
                _positing,
                0
            FROM
                public."EV_QTY_Event_Quantity_Posit" p
            WHERE
                p."EV_QTY_ID" = OLD."EV_QTY_ID";
        END IF;
    END IF;
    IF NEW."EV_PLC_ID" IS DISTINCT FROM OLD."EV_PLC_ID" THEN
        RAISE EXCEPTION 'The identity column EV_PLC_ID is not updatable.';
    END IF;
    IF NEW."EV_PLC_EV_ID" IS DISTINCT FROM OLD."EV_PLC_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_PLC_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_PLC_Event_Place, and when it posits
    _reliability := CASE
        WHEN NEW."EV_PLC_Reliability" IS DISTINCT FROM OLD."EV_PLC_Reliability" THEN NEW."EV_PLC_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."EV_PLC_Reliability"
    END;
    _positing := CASE
        WHEN NEW."EV_PLC_PositedAt" IS DISTINCT FROM OLD."EV_PLC_PositedAt" THEN NEW."EV_PLC_PositedAt"
        WHEN NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt" AND NEW."EV_PLC_Event_Place" IS NULL THEN NEW."EV_PLC_ChangedAt"
        ELSE _now
    END;
    IF NEW."EV_PLC_Event_Place" IS DISTINCT FROM OLD."EV_PLC_Event_Place"
    OR NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt"
    OR NEW."EV_PLC_PositedAt" IS DISTINCT FROM OLD."EV_PLC_PositedAt"
    OR NEW."EV_PLC_Reliability" IS DISTINCT FROM OLD."EV_PLC_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."EV_PLC_Event_Place" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_PLC_Event_Place" IS NULL
            OR NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt"
            OR NEW."EV_PLC_PositedAt" IS DISTINCT FROM OLD."EV_PLC_PositedAt"
            OR OLD."EV_PLC_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_PLC_Event_Place" <> NEW."EV_PLC_Event_Place"
            THEN
                INSERT INTO public."EV_PLC_Event_Place" (
                    "Metadata_EV_PLC",
                    "EV_PLC_EV_ID",
                    "EV_PLC_Event_Place",
                    "EV_PLC_ChangedAt",
                    "EV_PLC_PositedAt",
                    "EV_PLC_Reliability"
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
                    NEW."EV_PLC_Event_Place",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt" THEN NEW."EV_PLC_ChangedAt"
                        WHEN OLD."EV_PLC_Event_Place" = NEW."EV_PLC_Event_Place" THEN NEW."EV_PLC_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."EV_PLC_Event_Place" IS NULL AND OLD."EV_PLC_Event_Place" IS NOT NULL THEN
            INSERT INTO public."EV_PLC_Event_Place" (
                "Metadata_EV_PLC",
                "EV_PLC_EV_ID",
                "EV_PLC_Event_Place",
                "EV_PLC_ChangedAt",
                "EV_PLC_PositedAt",
                "EV_PLC_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_PLC" IS NOT DISTINCT FROM OLD."Metadata_EV_PLC"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_PLC"
                    END, NEW."Metadata_EV"),
                p."EV_PLC_EV_ID",
                p."EV_PLC_Event_Place",
                p."EV_PLC_ChangedAt",
                _positing,
                0
            FROM
                public."EV_PLC_Event_Place_Posit" p
            WHERE
                p."EV_PLC_ID" = OLD."EV_PLC_ID";
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
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown of EV_QTY_Event_Quantity is retracted
    INSERT INTO public."EV_QTY_Event_Quantity_Annex" (
        "Metadata_EV_QTY",
        "EV_QTY_ID",
        "EV_QTY_PositedAt",
        "EV_QTY_Reliability"
    )
    SELECT
        OLD."Metadata_EV_QTY",
        OLD."EV_QTY_ID",
        _now,
        0
    WHERE
        OLD."EV_QTY_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of EV_PLC_Event_Place is retracted
    INSERT INTO public."EV_PLC_Event_Place_Annex" (
        "Metadata_EV_PLC",
        "EV_PLC_ID",
        "EV_PLC_PositedAt",
        "EV_PLC_Reliability"
    )
    SELECT
        OLD."Metadata_EV_PLC",
        OLD."EV_PLC_ID",
        _now,
        0
    WHERE
        OLD."EV_PLC_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lEV_Event" ON public."lEV_Event";
CREATE TRIGGER "dt_lEV_Event"
INSTEAD OF DELETE ON public."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION public."dt_lEV_Event"();
