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
CREATE OR REPLACE FUNCTION nexuses."it_lEV_Event"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id numeric(12,0);
    _UTL smallint;
    _LVL smallint;
BEGIN
    _id := NEW."EV_ID";
    IF _id IS NULL THEN
        INSERT INTO nexuses."EV_Event" (
            "ST_ID_wasHeldAt",
            "PR_ID_wasPlayed",
            "ETY_ID_of",
            "Metadata_EV"
        )
        VALUES (
            NEW."ST_ID_wasHeldAt",
            NEW."PR_ID_wasPlayed",
            NEW."ETY_ID_of",
            NEW."Metadata_EV"
        )
        RETURNING "EV_ID" INTO _id;
    END IF;
    IF NEW."EV_DAT_Event_Date" IS NOT NULL THEN
        INSERT INTO attributes."EV_DAT_Event_Date" (
            "Metadata_EV_DAT",
            "EV_DAT_EV_ID",
            "EV_DAT_Event_Date"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_DAT", NEW."Metadata_EV"),
            coalesce(NEW."EV_DAT_EV_ID", _id),
            NEW."EV_DAT_Event_Date"
        );
    END IF;
    IF NEW."EV_AUD_Event_Audience" IS NOT NULL THEN
        INSERT INTO attributes."EV_AUD_Event_Audience" (
            "Metadata_EV_AUD",
            "EV_AUD_EV_ID",
            "EV_AUD_Event_Audience"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_AUD", NEW."Metadata_EV"),
            coalesce(NEW."EV_AUD_EV_ID", _id),
            NEW."EV_AUD_Event_Audience"
        );
    END IF;
    IF NEW."EV_REV_Event_Revenue" IS NOT NULL THEN
        INSERT INTO attributes."EV_REV_Event_Revenue" (
            "Metadata_EV_REV",
            "EV_REV_EV_ID",
            "EV_REV_Event_Revenue"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_REV", NEW."Metadata_EV"),
            coalesce(NEW."EV_REV_EV_ID", _id),
            NEW."EV_REV_Event_Revenue"
        );
    END IF;
    IF NEW."EV_STA_Event_Status" IS NOT NULL THEN
        INSERT INTO attributes."EV_STA_Event_Status" (
            "Metadata_EV_STA",
            "EV_STA_EV_ID",
            "EV_STA_ChangedAt",
            "EV_STA_Event_Status"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_STA", NEW."Metadata_EV"),
            coalesce(NEW."EV_STA_EV_ID", _id),
            coalesce(NEW."EV_STA_ChangedAt", _now),
            NEW."EV_STA_Event_Status"
        );
    END IF;
    _UTL := NEW."EV_UTL_UTL_ID";
    IF _UTL IS NULL AND NEW."EV_UTL_UTL_Utilization" IS NOT NULL THEN
        SELECT
            k."UTL_ID"
        INTO
            _UTL
        FROM
            knots."UTL_Utilization" k
        WHERE
            k."UTL_Utilization" = NEW."EV_UTL_UTL_Utilization"
        LIMIT 1;
    END IF;
    IF _UTL IS NOT NULL THEN
        INSERT INTO attributes."EV_UTL_Event_Utilization" (
            "Metadata_EV_UTL",
            "EV_UTL_EV_ID",
            "EV_UTL_UTL_ID"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_UTL", NEW."Metadata_EV"),
            coalesce(NEW."EV_UTL_EV_ID", _id),
            _UTL
        );
    END IF;
    _LVL := NEW."EV_LVL_PLV_ID";
    IF _LVL IS NULL AND NEW."EV_LVL_PLV_ProfessionalLevel" IS NOT NULL THEN
        SELECT
            k."PLV_ID"
        INTO
            _LVL
        FROM
            knots."PLV_ProfessionalLevel" k
        WHERE
            k."PLV_Checksum" = decode(md5(NEW."EV_LVL_PLV_ProfessionalLevel"::text), 'hex')
        LIMIT 1;
    END IF;
    IF _LVL IS NOT NULL THEN
        INSERT INTO attributes."EV_LVL_Event_Level" (
            "Metadata_EV_LVL",
            "EV_LVL_EV_ID",
            "EV_LVL_ChangedAt",
            "EV_LVL_PLV_ID"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_LVL", NEW."Metadata_EV"),
            coalesce(NEW."EV_LVL_EV_ID", _id),
            coalesce(NEW."EV_LVL_ChangedAt", _now),
            _LVL
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lEV_Event" ON nexuses."lEV_Event";
CREATE TRIGGER "it_lEV_Event"
INSTEAD OF INSERT ON nexuses."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION nexuses."it_lEV_Event"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lEV_Event instead of UPDATE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."ut_lEV_Event"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _UTL smallint;
    _LVL smallint;
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
    IF NEW."of_ETY_EventType" IS DISTINCT FROM OLD."of_ETY_EventType" THEN
        RAISE EXCEPTION 'The role column of_ETY_EventType is not updatable.';
    END IF;
    IF NEW."EV_DAT_EV_ID" IS DISTINCT FROM OLD."EV_DAT_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_DAT_EV_ID is not updatable.';
    END IF;
    IF NEW."EV_DAT_Event_Date" IS DISTINCT FROM OLD."EV_DAT_Event_Date"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."EV_DAT_Event_Date" IS NOT NULL AND (
            OLD."EV_DAT_Event_Date" IS NULL OR
            OLD."EV_DAT_Event_Date" <> NEW."EV_DAT_Event_Date"
        ) THEN
            INSERT INTO attributes."EV_DAT_Event_Date" (
                "Metadata_EV_DAT",
                "EV_DAT_EV_ID",
                "EV_DAT_Event_Date"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_DAT" IS NOT DISTINCT FROM OLD."Metadata_EV_DAT"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_DAT"
                    END, NEW."Metadata_EV"),
                coalesce(NEW."EV_DAT_EV_ID", NEW."EV_ID"),
                NEW."EV_DAT_Event_Date"
            );
        END IF;
    END IF;
    IF NEW."EV_AUD_EV_ID" IS DISTINCT FROM OLD."EV_AUD_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_AUD_EV_ID is not updatable.';
    END IF;
    IF NEW."EV_AUD_Event_Audience" IS DISTINCT FROM OLD."EV_AUD_Event_Audience"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."EV_AUD_Event_Audience" IS NOT NULL AND (
            OLD."EV_AUD_Event_Audience" IS NULL OR
            OLD."EV_AUD_Event_Audience" <> NEW."EV_AUD_Event_Audience"
        ) THEN
            INSERT INTO attributes."EV_AUD_Event_Audience" (
                "Metadata_EV_AUD",
                "EV_AUD_EV_ID",
                "EV_AUD_Event_Audience"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_AUD" IS NOT DISTINCT FROM OLD."Metadata_EV_AUD"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_AUD"
                    END, NEW."Metadata_EV"),
                coalesce(NEW."EV_AUD_EV_ID", NEW."EV_ID"),
                NEW."EV_AUD_Event_Audience"
            );
        END IF;
    END IF;
    IF NEW."EV_REV_EV_ID" IS DISTINCT FROM OLD."EV_REV_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_REV_EV_ID is not updatable.';
    END IF;
    IF NEW."EV_REV_Event_Revenue" IS DISTINCT FROM OLD."EV_REV_Event_Revenue"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."EV_REV_Event_Revenue" IS NOT NULL AND (
            OLD."EV_REV_Event_Revenue" IS NULL OR
            OLD."EV_REV_Event_Revenue" <> NEW."EV_REV_Event_Revenue"
        ) THEN
            INSERT INTO attributes."EV_REV_Event_Revenue" (
                "Metadata_EV_REV",
                "EV_REV_EV_ID",
                "EV_REV_Event_Revenue"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_REV" IS NOT DISTINCT FROM OLD."Metadata_EV_REV"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_REV"
                    END, NEW."Metadata_EV"),
                coalesce(NEW."EV_REV_EV_ID", NEW."EV_ID"),
                NEW."EV_REV_Event_Revenue"
            );
        END IF;
    END IF;
    IF NEW."EV_STA_EV_ID" IS DISTINCT FROM OLD."EV_STA_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_STA_EV_ID is not updatable.';
    END IF;
    IF NEW."EV_STA_Event_Status" IS DISTINCT FROM OLD."EV_STA_Event_Status"
    OR NEW."EV_STA_ChangedAt" IS DISTINCT FROM OLD."EV_STA_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."EV_STA_Event_Status" IS NOT NULL AND (
            NEW."EV_STA_ChangedAt" IS DISTINCT FROM OLD."EV_STA_ChangedAt" OR
            OLD."EV_STA_Event_Status" IS NULL OR
            OLD."EV_STA_Event_Status" <> NEW."EV_STA_Event_Status"
        ) THEN
            INSERT INTO attributes."EV_STA_Event_Status" (
                "Metadata_EV_STA",
                "EV_STA_EV_ID",
                "EV_STA_ChangedAt",
                "EV_STA_Event_Status"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_STA" IS NOT DISTINCT FROM OLD."Metadata_EV_STA"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_STA"
                    END, NEW."Metadata_EV"),
                coalesce(NEW."EV_STA_EV_ID", NEW."EV_ID"),
                CASE
                    WHEN NEW."EV_STA_ChangedAt" IS DISTINCT FROM OLD."EV_STA_ChangedAt" THEN NEW."EV_STA_ChangedAt"
                    ELSE _now
                END,
                NEW."EV_STA_Event_Status"
            );
        END IF;
    END IF;
    IF NEW."EV_UTL_EV_ID" IS DISTINCT FROM OLD."EV_UTL_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_UTL_EV_ID is not updatable.';
    END IF;
    IF NEW."EV_UTL_UTL_ID" IS DISTINCT FROM OLD."EV_UTL_UTL_ID"
    OR NEW."EV_UTL_UTL_Utilization" IS DISTINCT FROM OLD."EV_UTL_UTL_Utilization"
    THEN
        _UTL := NEW."EV_UTL_UTL_ID";
        IF _UTL IS NOT DISTINCT FROM OLD."EV_UTL_UTL_ID" AND NEW."EV_UTL_UTL_Utilization" IS NOT NULL THEN
            SELECT
                k."UTL_ID"
            INTO
                _UTL
            FROM
                knots."UTL_Utilization" k
            WHERE
                k."UTL_Utilization" = NEW."EV_UTL_UTL_Utilization"
            LIMIT 1;
        END IF;
        -- a value that is left as it is states nothing
        IF _UTL IS NOT NULL AND (
            OLD."EV_UTL_UTL_ID" IS NULL OR
            OLD."EV_UTL_UTL_ID" <> _UTL
        ) THEN
            INSERT INTO attributes."EV_UTL_Event_Utilization" (
                "Metadata_EV_UTL",
                "EV_UTL_EV_ID",
                "EV_UTL_UTL_ID"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_UTL" IS NOT DISTINCT FROM OLD."Metadata_EV_UTL"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_UTL"
                    END, NEW."Metadata_EV"),
                coalesce(NEW."EV_UTL_EV_ID", NEW."EV_ID"),
                _UTL
            );
        END IF;
    END IF;
    IF NEW."EV_LVL_EV_ID" IS DISTINCT FROM OLD."EV_LVL_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_LVL_EV_ID is not updatable.';
    END IF;
    IF NEW."EV_LVL_PLV_ID" IS DISTINCT FROM OLD."EV_LVL_PLV_ID"
    OR NEW."EV_LVL_PLV_ProfessionalLevel" IS DISTINCT FROM OLD."EV_LVL_PLV_ProfessionalLevel"
    OR NEW."EV_LVL_ChangedAt" IS DISTINCT FROM OLD."EV_LVL_ChangedAt"
    THEN
        _LVL := NEW."EV_LVL_PLV_ID";
        IF _LVL IS NOT DISTINCT FROM OLD."EV_LVL_PLV_ID" AND NEW."EV_LVL_PLV_ProfessionalLevel" IS NOT NULL THEN
            SELECT
                k."PLV_ID"
            INTO
                _LVL
            FROM
                knots."PLV_ProfessionalLevel" k
            WHERE
                k."PLV_Checksum" = decode(md5(NEW."EV_LVL_PLV_ProfessionalLevel"::text), 'hex')
            LIMIT 1;
        END IF;
        -- a value that is left as it is states nothing
        IF _LVL IS NOT NULL AND (
            NEW."EV_LVL_ChangedAt" IS DISTINCT FROM OLD."EV_LVL_ChangedAt" OR
            OLD."EV_LVL_PLV_ID" IS NULL OR
            OLD."EV_LVL_PLV_ID" <> _LVL
        ) THEN
            INSERT INTO attributes."EV_LVL_Event_Level" (
                "Metadata_EV_LVL",
                "EV_LVL_EV_ID",
                "EV_LVL_ChangedAt",
                "EV_LVL_PLV_ID"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_LVL" IS NOT DISTINCT FROM OLD."Metadata_EV_LVL"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_LVL"
                    END, NEW."Metadata_EV"),
                coalesce(NEW."EV_LVL_EV_ID", NEW."EV_ID"),
                CASE
                    WHEN NEW."EV_LVL_ChangedAt" IS DISTINCT FROM OLD."EV_LVL_ChangedAt" THEN NEW."EV_LVL_ChangedAt"
                    ELSE _now
                END,
                _LVL
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lEV_Event" ON nexuses."lEV_Event";
CREATE TRIGGER "ut_lEV_Event"
INSTEAD OF UPDATE ON nexuses."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION nexuses."ut_lEV_Event"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_Event instead of DELETE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."dt_lEV_Event"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        attributes."EV_DAT_Event_Date" x
    WHERE
        x."EV_DAT_EV_ID" = OLD."EV_ID"
    ;
    DELETE FROM
        attributes."EV_AUD_Event_Audience" x
    WHERE
        x."EV_AUD_EV_ID" = OLD."EV_ID"
    ;
    DELETE FROM
        attributes."EV_REV_Event_Revenue" x
    WHERE
        x."EV_REV_EV_ID" = OLD."EV_ID"
    ;
    DELETE FROM
        attributes."EV_STA_Event_Status" x
    WHERE
        x."EV_STA_EV_ID" = OLD."EV_ID"
    AND
        x."EV_STA_ChangedAt" = OLD."EV_STA_ChangedAt"
    ;
    DELETE FROM
        attributes."EV_UTL_Event_Utilization" x
    WHERE
        x."EV_UTL_EV_ID" = OLD."EV_ID"
    ;
    DELETE FROM
        attributes."EV_LVL_Event_Level" x
    WHERE
        x."EV_LVL_EV_ID" = OLD."EV_ID"
    AND
        x."EV_LVL_ChangedAt" = OLD."EV_LVL_ChangedAt"
    ;
    -- a nexus that has no attribute rows left is removed
    DELETE FROM
        nexuses."EV_Event" a
    WHERE
        a."EV_ID" = OLD."EV_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."EV_DAT_Event_Date" x
        WHERE
            x."EV_DAT_EV_ID" = a."EV_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."EV_AUD_Event_Audience" x
        WHERE
            x."EV_AUD_EV_ID" = a."EV_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."EV_REV_Event_Revenue" x
        WHERE
            x."EV_REV_EV_ID" = a."EV_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."EV_STA_Event_Status" x
        WHERE
            x."EV_STA_EV_ID" = a."EV_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."EV_UTL_Event_Utilization" x
        WHERE
            x."EV_UTL_EV_ID" = a."EV_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes."EV_LVL_Event_Level" x
        WHERE
            x."EV_LVL_EV_ID" = a."EV_ID"
    )
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lEV_Event" ON nexuses."lEV_Event";
CREATE TRIGGER "dt_lEV_Event"
INSTEAD OF DELETE ON nexuses."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION nexuses."dt_lEV_Event"();
