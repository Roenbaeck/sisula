-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
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
            "EV_DAT_Event_Date",
            "EV_DAT_Positor",
            "EV_DAT_PositedAt",
            "EV_DAT_Reliability"
        )
        VALUES (
            _id,
            NEW."EV_DAT_Event_Date",
            coalesce(NEW."EV_DAT_Positor", NEW."Positor", 0),
            coalesce(NEW."EV_DAT_PositedAt", _now),
            coalesce(NEW."EV_DAT_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."EV_AUD_Event_Audience" IS NOT NULL THEN
        INSERT INTO public."EV_AUD_Event_Audience" (
            "EV_ID",
            "EV_AUD_Event_Audience",
            "EV_AUD_Positor",
            "EV_AUD_PositedAt",
            "EV_AUD_Reliability"
        )
        VALUES (
            _id,
            NEW."EV_AUD_Event_Audience",
            coalesce(NEW."EV_AUD_Positor", NEW."Positor", 0),
            coalesce(NEW."EV_AUD_PositedAt", _now),
            coalesce(NEW."EV_AUD_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."EV_REV_Event_Revenue" IS NOT NULL THEN
        INSERT INTO public."EV_REV_Event_Revenue" (
            "EV_ID",
            "EV_REV_Event_Revenue",
            "EV_REV_Positor",
            "EV_REV_PositedAt",
            "EV_REV_Reliability"
        )
        VALUES (
            _id,
            NEW."EV_REV_Event_Revenue",
            coalesce(NEW."EV_REV_Positor", NEW."Positor", 0),
            coalesce(NEW."EV_REV_PositedAt", _now),
            coalesce(NEW."EV_REV_Reliability", NEW."Reliability", 1)
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
    _positor smallint;
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
    IF NEW."EV_DAT_ID" IS DISTINCT FROM OLD."EV_DAT_ID" THEN
        RAISE EXCEPTION 'The identity column EV_DAT_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_DAT_Event_Date, and when it posits
    _reliability := CASE
        WHEN NEW."EV_DAT_Reliability" IS DISTINCT FROM OLD."EV_DAT_Reliability" THEN NEW."EV_DAT_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."EV_DAT_Reliability"
    END;
    _positor := coalesce(CASE
        WHEN NEW."EV_DAT_Positor" IS DISTINCT FROM OLD."EV_DAT_Positor" THEN NEW."EV_DAT_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."EV_DAT_PositedAt" IS DISTINCT FROM OLD."EV_DAT_PositedAt" THEN NEW."EV_DAT_PositedAt"
        ELSE _now
    END;
    IF NEW."EV_DAT_Event_Date" IS DISTINCT FROM OLD."EV_DAT_Event_Date"
    OR NEW."EV_DAT_PositedAt" IS DISTINCT FROM OLD."EV_DAT_PositedAt"
    OR NEW."EV_DAT_Reliability" IS DISTINCT FROM OLD."EV_DAT_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."EV_DAT_Event_Date" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_DAT_Event_Date" IS NULL
            OR NEW."EV_DAT_PositedAt" IS DISTINCT FROM OLD."EV_DAT_PositedAt"
            OR OLD."EV_DAT_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_DAT_Positor" IS DISTINCT FROM _positor
            OR OLD."EV_DAT_Event_Date" <> NEW."EV_DAT_Event_Date"
            THEN
                INSERT INTO public."EV_DAT_Event_Date" (
                    "EV_ID",
                    "EV_DAT_Event_Date",
                    "EV_DAT_Positor",
                    "EV_DAT_PositedAt",
                    "EV_DAT_Reliability"
                )
                VALUES (
                    NEW."EV_ID",
                    NEW."EV_DAT_Event_Date",
                    _positor,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."EV_DAT_Event_Date" IS NULL AND OLD."EV_DAT_Event_Date" IS NOT NULL THEN
            INSERT INTO public."EV_DAT_Event_Date" (
                "EV_ID",
                "EV_DAT_Event_Date",
                "EV_DAT_Positor",
                "EV_DAT_PositedAt",
                "EV_DAT_Reliability"
            )
            SELECT
                p."EV_ID",
                p."EV_DAT_Event_Date",
                _positor,
                _positing,
                0
            FROM
                public."EV_DAT_Event_Date_Posit" p
            WHERE
                p."EV_DAT_ID" = OLD."EV_DAT_ID";
        END IF;
    END IF;
    IF NEW."EV_AUD_ID" IS DISTINCT FROM OLD."EV_AUD_ID" THEN
        RAISE EXCEPTION 'The identity column EV_AUD_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_AUD_Event_Audience, and when it posits
    _reliability := CASE
        WHEN NEW."EV_AUD_Reliability" IS DISTINCT FROM OLD."EV_AUD_Reliability" THEN NEW."EV_AUD_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."EV_AUD_Reliability"
    END;
    _positor := coalesce(CASE
        WHEN NEW."EV_AUD_Positor" IS DISTINCT FROM OLD."EV_AUD_Positor" THEN NEW."EV_AUD_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."EV_AUD_PositedAt" IS DISTINCT FROM OLD."EV_AUD_PositedAt" THEN NEW."EV_AUD_PositedAt"
        ELSE _now
    END;
    IF NEW."EV_AUD_Event_Audience" IS DISTINCT FROM OLD."EV_AUD_Event_Audience"
    OR NEW."EV_AUD_PositedAt" IS DISTINCT FROM OLD."EV_AUD_PositedAt"
    OR NEW."EV_AUD_Reliability" IS DISTINCT FROM OLD."EV_AUD_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."EV_AUD_Event_Audience" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_AUD_Event_Audience" IS NULL
            OR NEW."EV_AUD_PositedAt" IS DISTINCT FROM OLD."EV_AUD_PositedAt"
            OR OLD."EV_AUD_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_AUD_Positor" IS DISTINCT FROM _positor
            OR OLD."EV_AUD_Event_Audience" <> NEW."EV_AUD_Event_Audience"
            THEN
                INSERT INTO public."EV_AUD_Event_Audience" (
                    "EV_ID",
                    "EV_AUD_Event_Audience",
                    "EV_AUD_Positor",
                    "EV_AUD_PositedAt",
                    "EV_AUD_Reliability"
                )
                VALUES (
                    NEW."EV_ID",
                    NEW."EV_AUD_Event_Audience",
                    _positor,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."EV_AUD_Event_Audience" IS NULL AND OLD."EV_AUD_Event_Audience" IS NOT NULL THEN
            INSERT INTO public."EV_AUD_Event_Audience" (
                "EV_ID",
                "EV_AUD_Event_Audience",
                "EV_AUD_Positor",
                "EV_AUD_PositedAt",
                "EV_AUD_Reliability"
            )
            SELECT
                p."EV_ID",
                p."EV_AUD_Event_Audience",
                _positor,
                _positing,
                0
            FROM
                public."EV_AUD_Event_Audience_Posit" p
            WHERE
                p."EV_AUD_ID" = OLD."EV_AUD_ID";
        END IF;
    END IF;
    IF NEW."EV_REV_ID" IS DISTINCT FROM OLD."EV_REV_ID" THEN
        RAISE EXCEPTION 'The identity column EV_REV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_REV_Event_Revenue, and when it posits
    _reliability := CASE
        WHEN NEW."EV_REV_Reliability" IS DISTINCT FROM OLD."EV_REV_Reliability" THEN NEW."EV_REV_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."EV_REV_Reliability"
    END;
    _positor := coalesce(CASE
        WHEN NEW."EV_REV_Positor" IS DISTINCT FROM OLD."EV_REV_Positor" THEN NEW."EV_REV_Positor"
        ELSE NEW."Positor"
    END, 0);
    _positing := CASE
        WHEN NEW."EV_REV_PositedAt" IS DISTINCT FROM OLD."EV_REV_PositedAt" THEN NEW."EV_REV_PositedAt"
        ELSE _now
    END;
    IF NEW."EV_REV_Event_Revenue" IS DISTINCT FROM OLD."EV_REV_Event_Revenue"
    OR NEW."EV_REV_PositedAt" IS DISTINCT FROM OLD."EV_REV_PositedAt"
    OR NEW."EV_REV_Reliability" IS DISTINCT FROM OLD."EV_REV_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."EV_REV_Event_Revenue" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_REV_Event_Revenue" IS NULL
            OR NEW."EV_REV_PositedAt" IS DISTINCT FROM OLD."EV_REV_PositedAt"
            OR OLD."EV_REV_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_REV_Positor" IS DISTINCT FROM _positor
            OR OLD."EV_REV_Event_Revenue" <> NEW."EV_REV_Event_Revenue"
            THEN
                INSERT INTO public."EV_REV_Event_Revenue" (
                    "EV_ID",
                    "EV_REV_Event_Revenue",
                    "EV_REV_Positor",
                    "EV_REV_PositedAt",
                    "EV_REV_Reliability"
                )
                VALUES (
                    NEW."EV_ID",
                    NEW."EV_REV_Event_Revenue",
                    _positor,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."EV_REV_Event_Revenue" IS NULL AND OLD."EV_REV_Event_Revenue" IS NOT NULL THEN
            INSERT INTO public."EV_REV_Event_Revenue" (
                "EV_ID",
                "EV_REV_Event_Revenue",
                "EV_REV_Positor",
                "EV_REV_PositedAt",
                "EV_REV_Reliability"
            )
            SELECT
                p."EV_ID",
                p."EV_REV_Event_Revenue",
                _positor,
                _positing,
                0
            FROM
                public."EV_REV_Event_Revenue_Posit" p
            WHERE
                p."EV_REV_ID" = OLD."EV_REV_ID";
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
    -- what is shown of EV_DAT_Event_Date is retracted
    INSERT INTO public."EV_DAT_Event_Date_Annex" (
        "EV_DAT_ID",
        "EV_DAT_Positor",
        "EV_DAT_PositedAt",
        "EV_DAT_Reliability"
    )
    SELECT
        OLD."EV_DAT_ID",
        coalesce(OLD."EV_DAT_Positor", OLD."Positor", 0),
        _now,
        0
    WHERE
        OLD."EV_DAT_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of EV_AUD_Event_Audience is retracted
    INSERT INTO public."EV_AUD_Event_Audience_Annex" (
        "EV_AUD_ID",
        "EV_AUD_Positor",
        "EV_AUD_PositedAt",
        "EV_AUD_Reliability"
    )
    SELECT
        OLD."EV_AUD_ID",
        coalesce(OLD."EV_AUD_Positor", OLD."Positor", 0),
        _now,
        0
    WHERE
        OLD."EV_AUD_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of EV_REV_Event_Revenue is retracted
    INSERT INTO public."EV_REV_Event_Revenue_Annex" (
        "EV_REV_ID",
        "EV_REV_Positor",
        "EV_REV_PositedAt",
        "EV_REV_Reliability"
    )
    SELECT
        OLD."EV_REV_ID",
        coalesce(OLD."EV_REV_Positor", OLD."Positor", 0),
        _now,
        0
    WHERE
        OLD."EV_REV_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lEV_Event" ON public."lEV_Event";
CREATE TRIGGER "dt_lEV_Event"
INSTEAD OF DELETE ON public."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION public."dt_lEV_Event"();
