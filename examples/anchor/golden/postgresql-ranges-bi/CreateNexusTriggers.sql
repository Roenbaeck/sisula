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
            "EV_DAT_Event_Date",
            "EV_DAT_PositedAt",
            "EV_DAT_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_DAT", NEW."Metadata_EV"),
            coalesce(NEW."EV_DAT_EV_ID", _id),
            NEW."EV_DAT_Event_Date",
            coalesce(NEW."EV_DAT_PositedAt", _now),
            coalesce(NEW."EV_DAT_Confidence", NEW."Confidence", 1)
        );
    END IF;
    IF NEW."EV_AUD_Event_Audience" IS NOT NULL THEN
        INSERT INTO attributes."EV_AUD_Event_Audience" (
            "Metadata_EV_AUD",
            "EV_AUD_EV_ID",
            "EV_AUD_Event_Audience",
            "EV_AUD_PositedAt",
            "EV_AUD_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_AUD", NEW."Metadata_EV"),
            coalesce(NEW."EV_AUD_EV_ID", _id),
            NEW."EV_AUD_Event_Audience",
            coalesce(NEW."EV_AUD_PositedAt", _now),
            coalesce(NEW."EV_AUD_Confidence", NEW."Confidence", 1)
        );
    END IF;
    IF NEW."EV_REV_Event_Revenue" IS NOT NULL THEN
        INSERT INTO attributes."EV_REV_Event_Revenue" (
            "Metadata_EV_REV",
            "EV_REV_EV_ID",
            "EV_REV_Event_Revenue",
            "EV_REV_PositedAt",
            "EV_REV_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_REV", NEW."Metadata_EV"),
            coalesce(NEW."EV_REV_EV_ID", _id),
            NEW."EV_REV_Event_Revenue",
            coalesce(NEW."EV_REV_PositedAt", _now),
            coalesce(NEW."EV_REV_Confidence", NEW."Confidence", 1)
        );
    END IF;
    IF NEW."EV_STA_Event_Status" IS NOT NULL THEN
        INSERT INTO attributes."EV_STA_Event_Status" (
            "Metadata_EV_STA",
            "EV_STA_EV_ID",
            "EV_STA_Event_Status",
            "EV_STA_ChangedAt",
            "EV_STA_PositedAt",
            "EV_STA_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_STA", NEW."Metadata_EV"),
            coalesce(NEW."EV_STA_EV_ID", _id),
            NEW."EV_STA_Event_Status",
            coalesce(NEW."EV_STA_ChangedAt", _now),
            coalesce(NEW."EV_STA_PositedAt", _now),
            coalesce(NEW."EV_STA_Confidence", NEW."Confidence", 1)
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
            "EV_UTL_UTL_ID",
            "EV_UTL_PositedAt",
            "EV_UTL_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_UTL", NEW."Metadata_EV"),
            coalesce(NEW."EV_UTL_EV_ID", _id),
            _UTL,
            coalesce(NEW."EV_UTL_PositedAt", _now),
            coalesce(NEW."EV_UTL_Confidence", NEW."Confidence", 1)
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
            "EV_LVL_PLV_ID",
            "EV_LVL_ChangedAt",
            "EV_LVL_PositedAt",
            "EV_LVL_Confidence"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_LVL", NEW."Metadata_EV"),
            coalesce(NEW."EV_LVL_EV_ID", _id),
            _LVL,
            coalesce(NEW."EV_LVL_ChangedAt", _now),
            coalesce(NEW."EV_LVL_PositedAt", _now),
            coalesce(NEW."EV_LVL_Confidence", NEW."Confidence", 1)
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
    _reliability decimal(7,3);
    _positing timestamp(3);
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
    IF NEW."EV_DAT_ID" IS DISTINCT FROM OLD."EV_DAT_ID" THEN
        RAISE EXCEPTION 'The identity column EV_DAT_ID is not updatable.';
    END IF;
    IF NEW."EV_DAT_EV_ID" IS DISTINCT FROM OLD."EV_DAT_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_DAT_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_DAT_Event_Date, and when it posits
    _reliability := CASE
        WHEN NEW."EV_DAT_Confidence" IS DISTINCT FROM OLD."EV_DAT_Confidence" THEN NEW."EV_DAT_Confidence"
        WHEN NEW."Confidence" IS DISTINCT FROM OLD."Confidence" THEN NEW."Confidence"
        ELSE NEW."EV_DAT_Confidence"
    END;
    _positing := CASE
        WHEN NEW."EV_DAT_PositedAt" IS DISTINCT FROM OLD."EV_DAT_PositedAt" THEN NEW."EV_DAT_PositedAt"
        ELSE _now
    END;
    IF NEW."EV_DAT_Event_Date" IS DISTINCT FROM OLD."EV_DAT_Event_Date"
    OR NEW."EV_DAT_PositedAt" IS DISTINCT FROM OLD."EV_DAT_PositedAt"
    OR NEW."EV_DAT_Confidence" IS DISTINCT FROM OLD."EV_DAT_Confidence"
    OR NEW."Confidence" IS DISTINCT FROM OLD."Confidence"
    THEN
        IF NEW."EV_DAT_Event_Date" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_DAT_Event_Date" IS NULL
            OR NEW."EV_DAT_PositedAt" IS DISTINCT FROM OLD."EV_DAT_PositedAt"
            OR OLD."EV_DAT_Confidence" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_DAT_Event_Date" <> NEW."EV_DAT_Event_Date"
            THEN
                INSERT INTO attributes."EV_DAT_Event_Date" (
                    "Metadata_EV_DAT",
                    "EV_DAT_EV_ID",
                    "EV_DAT_Event_Date",
                    "EV_DAT_PositedAt",
                    "EV_DAT_Confidence"
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
                    NEW."EV_DAT_Event_Date",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."EV_DAT_Event_Date" IS NULL AND OLD."EV_DAT_Event_Date" IS NOT NULL THEN
            INSERT INTO attributes."EV_DAT_Event_Date" (
                "Metadata_EV_DAT",
                "EV_DAT_EV_ID",
                "EV_DAT_Event_Date",
                "EV_DAT_PositedAt",
                "EV_DAT_Confidence"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_DAT" IS NOT DISTINCT FROM OLD."Metadata_EV_DAT"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_DAT"
                    END, NEW."Metadata_EV"),
                p."EV_DAT_EV_ID",
                p."EV_DAT_Event_Date",
                _positing,
                0
            FROM
                attributes."EV_DAT_Event_Date_Fact" p
            WHERE
                p."EV_DAT_ID" = OLD."EV_DAT_ID";
        END IF;
    END IF;
    IF NEW."EV_AUD_ID" IS DISTINCT FROM OLD."EV_AUD_ID" THEN
        RAISE EXCEPTION 'The identity column EV_AUD_ID is not updatable.';
    END IF;
    IF NEW."EV_AUD_EV_ID" IS DISTINCT FROM OLD."EV_AUD_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_AUD_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_AUD_Event_Audience, and when it posits
    _reliability := CASE
        WHEN NEW."EV_AUD_Confidence" IS DISTINCT FROM OLD."EV_AUD_Confidence" THEN NEW."EV_AUD_Confidence"
        WHEN NEW."Confidence" IS DISTINCT FROM OLD."Confidence" THEN NEW."Confidence"
        ELSE NEW."EV_AUD_Confidence"
    END;
    _positing := CASE
        WHEN NEW."EV_AUD_PositedAt" IS DISTINCT FROM OLD."EV_AUD_PositedAt" THEN NEW."EV_AUD_PositedAt"
        ELSE _now
    END;
    IF NEW."EV_AUD_Event_Audience" IS DISTINCT FROM OLD."EV_AUD_Event_Audience"
    OR NEW."EV_AUD_PositedAt" IS DISTINCT FROM OLD."EV_AUD_PositedAt"
    OR NEW."EV_AUD_Confidence" IS DISTINCT FROM OLD."EV_AUD_Confidence"
    OR NEW."Confidence" IS DISTINCT FROM OLD."Confidence"
    THEN
        IF NEW."EV_AUD_Event_Audience" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_AUD_Event_Audience" IS NULL
            OR NEW."EV_AUD_PositedAt" IS DISTINCT FROM OLD."EV_AUD_PositedAt"
            OR OLD."EV_AUD_Confidence" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_AUD_Event_Audience" <> NEW."EV_AUD_Event_Audience"
            THEN
                INSERT INTO attributes."EV_AUD_Event_Audience" (
                    "Metadata_EV_AUD",
                    "EV_AUD_EV_ID",
                    "EV_AUD_Event_Audience",
                    "EV_AUD_PositedAt",
                    "EV_AUD_Confidence"
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
                    NEW."EV_AUD_Event_Audience",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."EV_AUD_Event_Audience" IS NULL AND OLD."EV_AUD_Event_Audience" IS NOT NULL THEN
            INSERT INTO attributes."EV_AUD_Event_Audience" (
                "Metadata_EV_AUD",
                "EV_AUD_EV_ID",
                "EV_AUD_Event_Audience",
                "EV_AUD_PositedAt",
                "EV_AUD_Confidence"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_AUD" IS NOT DISTINCT FROM OLD."Metadata_EV_AUD"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_AUD"
                    END, NEW."Metadata_EV"),
                p."EV_AUD_EV_ID",
                p."EV_AUD_Event_Audience",
                _positing,
                0
            FROM
                attributes."EV_AUD_Event_Audience_Fact" p
            WHERE
                p."EV_AUD_ID" = OLD."EV_AUD_ID";
        END IF;
    END IF;
    IF NEW."EV_REV_ID" IS DISTINCT FROM OLD."EV_REV_ID" THEN
        RAISE EXCEPTION 'The identity column EV_REV_ID is not updatable.';
    END IF;
    IF NEW."EV_REV_EV_ID" IS DISTINCT FROM OLD."EV_REV_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_REV_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_REV_Event_Revenue, and when it posits
    _reliability := CASE
        WHEN NEW."EV_REV_Confidence" IS DISTINCT FROM OLD."EV_REV_Confidence" THEN NEW."EV_REV_Confidence"
        WHEN NEW."Confidence" IS DISTINCT FROM OLD."Confidence" THEN NEW."Confidence"
        ELSE NEW."EV_REV_Confidence"
    END;
    _positing := CASE
        WHEN NEW."EV_REV_PositedAt" IS DISTINCT FROM OLD."EV_REV_PositedAt" THEN NEW."EV_REV_PositedAt"
        ELSE _now
    END;
    IF NEW."EV_REV_Event_Revenue" IS DISTINCT FROM OLD."EV_REV_Event_Revenue"
    OR NEW."EV_REV_PositedAt" IS DISTINCT FROM OLD."EV_REV_PositedAt"
    OR NEW."EV_REV_Confidence" IS DISTINCT FROM OLD."EV_REV_Confidence"
    OR NEW."Confidence" IS DISTINCT FROM OLD."Confidence"
    THEN
        IF NEW."EV_REV_Event_Revenue" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_REV_Event_Revenue" IS NULL
            OR NEW."EV_REV_PositedAt" IS DISTINCT FROM OLD."EV_REV_PositedAt"
            OR OLD."EV_REV_Confidence" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_REV_Event_Revenue" <> NEW."EV_REV_Event_Revenue"
            THEN
                INSERT INTO attributes."EV_REV_Event_Revenue" (
                    "Metadata_EV_REV",
                    "EV_REV_EV_ID",
                    "EV_REV_Event_Revenue",
                    "EV_REV_PositedAt",
                    "EV_REV_Confidence"
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
                    NEW."EV_REV_Event_Revenue",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."EV_REV_Event_Revenue" IS NULL AND OLD."EV_REV_Event_Revenue" IS NOT NULL THEN
            INSERT INTO attributes."EV_REV_Event_Revenue" (
                "Metadata_EV_REV",
                "EV_REV_EV_ID",
                "EV_REV_Event_Revenue",
                "EV_REV_PositedAt",
                "EV_REV_Confidence"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_REV" IS NOT DISTINCT FROM OLD."Metadata_EV_REV"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_REV"
                    END, NEW."Metadata_EV"),
                p."EV_REV_EV_ID",
                p."EV_REV_Event_Revenue",
                _positing,
                0
            FROM
                attributes."EV_REV_Event_Revenue_Fact" p
            WHERE
                p."EV_REV_ID" = OLD."EV_REV_ID";
        END IF;
    END IF;
    IF NEW."EV_STA_ID" IS DISTINCT FROM OLD."EV_STA_ID" THEN
        RAISE EXCEPTION 'The identity column EV_STA_ID is not updatable.';
    END IF;
    IF NEW."EV_STA_EV_ID" IS DISTINCT FROM OLD."EV_STA_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_STA_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_STA_Event_Status, and when it posits
    _reliability := CASE
        WHEN NEW."EV_STA_Confidence" IS DISTINCT FROM OLD."EV_STA_Confidence" THEN NEW."EV_STA_Confidence"
        WHEN NEW."Confidence" IS DISTINCT FROM OLD."Confidence" THEN NEW."Confidence"
        ELSE NEW."EV_STA_Confidence"
    END;
    _positing := CASE
        WHEN NEW."EV_STA_PositedAt" IS DISTINCT FROM OLD."EV_STA_PositedAt" THEN NEW."EV_STA_PositedAt"
        WHEN NEW."EV_STA_ChangedAt" IS DISTINCT FROM OLD."EV_STA_ChangedAt" AND NEW."EV_STA_Event_Status" IS NULL THEN NEW."EV_STA_ChangedAt"
        ELSE _now
    END;
    IF NEW."EV_STA_Event_Status" IS DISTINCT FROM OLD."EV_STA_Event_Status"
    OR NEW."EV_STA_ChangedAt" IS DISTINCT FROM OLD."EV_STA_ChangedAt"
    OR NEW."EV_STA_PositedAt" IS DISTINCT FROM OLD."EV_STA_PositedAt"
    OR NEW."EV_STA_Confidence" IS DISTINCT FROM OLD."EV_STA_Confidence"
    OR NEW."Confidence" IS DISTINCT FROM OLD."Confidence"
    THEN
        IF NEW."EV_STA_Event_Status" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_STA_Event_Status" IS NULL
            OR NEW."EV_STA_ChangedAt" IS DISTINCT FROM OLD."EV_STA_ChangedAt"
            OR NEW."EV_STA_PositedAt" IS DISTINCT FROM OLD."EV_STA_PositedAt"
            OR OLD."EV_STA_Confidence" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_STA_Event_Status" <> NEW."EV_STA_Event_Status"
            THEN
                INSERT INTO attributes."EV_STA_Event_Status" (
                    "Metadata_EV_STA",
                    "EV_STA_EV_ID",
                    "EV_STA_Event_Status",
                    "EV_STA_ChangedAt",
                    "EV_STA_PositedAt",
                    "EV_STA_Confidence"
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
                    NEW."EV_STA_Event_Status",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."EV_STA_ChangedAt" IS DISTINCT FROM OLD."EV_STA_ChangedAt" THEN NEW."EV_STA_ChangedAt"
                        WHEN OLD."EV_STA_Event_Status" = NEW."EV_STA_Event_Status" THEN NEW."EV_STA_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."EV_STA_Event_Status" IS NULL AND OLD."EV_STA_Event_Status" IS NOT NULL THEN
            INSERT INTO attributes."EV_STA_Event_Status" (
                "Metadata_EV_STA",
                "EV_STA_EV_ID",
                "EV_STA_Event_Status",
                "EV_STA_ChangedAt",
                "EV_STA_PositedAt",
                "EV_STA_Confidence"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_STA" IS NOT DISTINCT FROM OLD."Metadata_EV_STA"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_STA"
                    END, NEW."Metadata_EV"),
                p."EV_STA_EV_ID",
                p."EV_STA_Event_Status",
                p."EV_STA_ChangedAt",
                _positing,
                0
            FROM
                attributes."EV_STA_Event_Status_Fact" p
            WHERE
                p."EV_STA_ID" = OLD."EV_STA_ID";
        END IF;
    END IF;
    IF NEW."EV_UTL_ID" IS DISTINCT FROM OLD."EV_UTL_ID" THEN
        RAISE EXCEPTION 'The identity column EV_UTL_ID is not updatable.';
    END IF;
    IF NEW."EV_UTL_EV_ID" IS DISTINCT FROM OLD."EV_UTL_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_UTL_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_UTL_Event_Utilization, and when it posits
    _reliability := CASE
        WHEN NEW."EV_UTL_Confidence" IS DISTINCT FROM OLD."EV_UTL_Confidence" THEN NEW."EV_UTL_Confidence"
        WHEN NEW."Confidence" IS DISTINCT FROM OLD."Confidence" THEN NEW."Confidence"
        ELSE NEW."EV_UTL_Confidence"
    END;
    _positing := CASE
        WHEN NEW."EV_UTL_PositedAt" IS DISTINCT FROM OLD."EV_UTL_PositedAt" THEN NEW."EV_UTL_PositedAt"
        ELSE _now
    END;
    _UTL := NEW."EV_UTL_UTL_ID";
    IF _UTL IS NOT DISTINCT FROM OLD."EV_UTL_UTL_ID" AND NEW."EV_UTL_UTL_Utilization" IS DISTINCT FROM OLD."EV_UTL_UTL_Utilization" THEN
        _UTL := NULL;
        IF NEW."EV_UTL_UTL_Utilization" IS NOT NULL THEN
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
    END IF;
    IF NEW."EV_UTL_UTL_ID" IS DISTINCT FROM OLD."EV_UTL_UTL_ID"
    OR NEW."EV_UTL_UTL_Utilization" IS DISTINCT FROM OLD."EV_UTL_UTL_Utilization"
    OR NEW."EV_UTL_PositedAt" IS DISTINCT FROM OLD."EV_UTL_PositedAt"
    OR NEW."EV_UTL_Confidence" IS DISTINCT FROM OLD."EV_UTL_Confidence"
    OR NEW."Confidence" IS DISTINCT FROM OLD."Confidence"
    THEN
        IF _UTL IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_UTL_UTL_ID" IS NULL
            OR NEW."EV_UTL_PositedAt" IS DISTINCT FROM OLD."EV_UTL_PositedAt"
            OR OLD."EV_UTL_Confidence" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_UTL_UTL_ID" <> _UTL
            THEN
                INSERT INTO attributes."EV_UTL_Event_Utilization" (
                    "Metadata_EV_UTL",
                    "EV_UTL_EV_ID",
                    "EV_UTL_UTL_ID",
                    "EV_UTL_PositedAt",
                    "EV_UTL_Confidence"
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
                    _UTL,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."EV_UTL_UTL_ID" IS NOT NULL AND (
            NEW."EV_UTL_UTL_ID" IS NULL OR (
                NEW."EV_UTL_UTL_ID" = OLD."EV_UTL_UTL_ID"
                AND NEW."EV_UTL_UTL_Utilization" IS NULL AND OLD."EV_UTL_UTL_Utilization" IS NOT NULL
            )
        ) THEN
            INSERT INTO attributes."EV_UTL_Event_Utilization" (
                "Metadata_EV_UTL",
                "EV_UTL_EV_ID",
                "EV_UTL_UTL_ID",
                "EV_UTL_PositedAt",
                "EV_UTL_Confidence"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_UTL" IS NOT DISTINCT FROM OLD."Metadata_EV_UTL"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_UTL"
                    END, NEW."Metadata_EV"),
                p."EV_UTL_EV_ID",
                p."EV_UTL_UTL_ID",
                _positing,
                0
            FROM
                attributes."EV_UTL_Event_Utilization_Fact" p
            WHERE
                p."EV_UTL_ID" = OLD."EV_UTL_ID";
        END IF;
    END IF;
    IF NEW."EV_LVL_ID" IS DISTINCT FROM OLD."EV_LVL_ID" THEN
        RAISE EXCEPTION 'The identity column EV_LVL_ID is not updatable.';
    END IF;
    IF NEW."EV_LVL_EV_ID" IS DISTINCT FROM OLD."EV_LVL_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_LVL_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_LVL_Event_Level, and when it posits
    _reliability := CASE
        WHEN NEW."EV_LVL_Confidence" IS DISTINCT FROM OLD."EV_LVL_Confidence" THEN NEW."EV_LVL_Confidence"
        WHEN NEW."Confidence" IS DISTINCT FROM OLD."Confidence" THEN NEW."Confidence"
        ELSE NEW."EV_LVL_Confidence"
    END;
    _positing := CASE
        WHEN NEW."EV_LVL_PositedAt" IS DISTINCT FROM OLD."EV_LVL_PositedAt" THEN NEW."EV_LVL_PositedAt"
        WHEN NEW."EV_LVL_ChangedAt" IS DISTINCT FROM OLD."EV_LVL_ChangedAt" AND NEW."EV_LVL_PLV_ID" IS NULL THEN NEW."EV_LVL_ChangedAt"
        ELSE _now
    END;
    _LVL := NEW."EV_LVL_PLV_ID";
    IF _LVL IS NOT DISTINCT FROM OLD."EV_LVL_PLV_ID" AND NEW."EV_LVL_PLV_ProfessionalLevel" IS DISTINCT FROM OLD."EV_LVL_PLV_ProfessionalLevel" THEN
        _LVL := NULL;
        IF NEW."EV_LVL_PLV_ProfessionalLevel" IS NOT NULL THEN
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
    END IF;
    IF NEW."EV_LVL_PLV_ID" IS DISTINCT FROM OLD."EV_LVL_PLV_ID"
    OR NEW."EV_LVL_PLV_ProfessionalLevel" IS DISTINCT FROM OLD."EV_LVL_PLV_ProfessionalLevel"
    OR NEW."EV_LVL_ChangedAt" IS DISTINCT FROM OLD."EV_LVL_ChangedAt"
    OR NEW."EV_LVL_PositedAt" IS DISTINCT FROM OLD."EV_LVL_PositedAt"
    OR NEW."EV_LVL_Confidence" IS DISTINCT FROM OLD."EV_LVL_Confidence"
    OR NEW."Confidence" IS DISTINCT FROM OLD."Confidence"
    THEN
        IF _LVL IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_LVL_PLV_ID" IS NULL
            OR NEW."EV_LVL_ChangedAt" IS DISTINCT FROM OLD."EV_LVL_ChangedAt"
            OR NEW."EV_LVL_PositedAt" IS DISTINCT FROM OLD."EV_LVL_PositedAt"
            OR OLD."EV_LVL_Confidence" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_LVL_PLV_ID" <> _LVL
            THEN
                INSERT INTO attributes."EV_LVL_Event_Level" (
                    "Metadata_EV_LVL",
                    "EV_LVL_EV_ID",
                    "EV_LVL_PLV_ID",
                    "EV_LVL_ChangedAt",
                    "EV_LVL_PositedAt",
                    "EV_LVL_Confidence"
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
                    _LVL,
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."EV_LVL_ChangedAt" IS DISTINCT FROM OLD."EV_LVL_ChangedAt" THEN NEW."EV_LVL_ChangedAt"
                        WHEN OLD."EV_LVL_PLV_ID" = _LVL THEN NEW."EV_LVL_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."EV_LVL_PLV_ID" IS NOT NULL AND (
            NEW."EV_LVL_PLV_ID" IS NULL OR (
                NEW."EV_LVL_PLV_ID" = OLD."EV_LVL_PLV_ID"
                AND NEW."EV_LVL_PLV_ProfessionalLevel" IS NULL AND OLD."EV_LVL_PLV_ProfessionalLevel" IS NOT NULL
            )
        ) THEN
            INSERT INTO attributes."EV_LVL_Event_Level" (
                "Metadata_EV_LVL",
                "EV_LVL_EV_ID",
                "EV_LVL_PLV_ID",
                "EV_LVL_ChangedAt",
                "EV_LVL_PositedAt",
                "EV_LVL_Confidence"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_LVL" IS NOT DISTINCT FROM OLD."Metadata_EV_LVL"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_LVL"
                    END, NEW."Metadata_EV"),
                p."EV_LVL_EV_ID",
                p."EV_LVL_PLV_ID",
                p."EV_LVL_ChangedAt",
                _positing,
                0
            FROM
                attributes."EV_LVL_Event_Level_Fact" p
            WHERE
                p."EV_LVL_ID" = OLD."EV_LVL_ID";
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
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown of EV_DAT_Event_Date is retracted
    INSERT INTO attributes."EV_DAT_Event_Date_Meta" (
        "Metadata_EV_DAT",
        "EV_DAT_ID",
        "EV_DAT_PositedAt",
        "EV_DAT_Confidence"
    )
    SELECT
        OLD."Metadata_EV_DAT",
        OLD."EV_DAT_ID",
        _now,
        0
    WHERE
        OLD."EV_DAT_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of EV_AUD_Event_Audience is retracted
    INSERT INTO attributes."EV_AUD_Event_Audience_Meta" (
        "Metadata_EV_AUD",
        "EV_AUD_ID",
        "EV_AUD_PositedAt",
        "EV_AUD_Confidence"
    )
    SELECT
        OLD."Metadata_EV_AUD",
        OLD."EV_AUD_ID",
        _now,
        0
    WHERE
        OLD."EV_AUD_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of EV_REV_Event_Revenue is retracted
    INSERT INTO attributes."EV_REV_Event_Revenue_Meta" (
        "Metadata_EV_REV",
        "EV_REV_ID",
        "EV_REV_PositedAt",
        "EV_REV_Confidence"
    )
    SELECT
        OLD."Metadata_EV_REV",
        OLD."EV_REV_ID",
        _now,
        0
    WHERE
        OLD."EV_REV_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of EV_STA_Event_Status is retracted
    INSERT INTO attributes."EV_STA_Event_Status_Meta" (
        "Metadata_EV_STA",
        "EV_STA_ID",
        "EV_STA_PositedAt",
        "EV_STA_Confidence"
    )
    SELECT
        OLD."Metadata_EV_STA",
        OLD."EV_STA_ID",
        _now,
        0
    WHERE
        OLD."EV_STA_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of EV_UTL_Event_Utilization is retracted
    INSERT INTO attributes."EV_UTL_Event_Utilization_Meta" (
        "Metadata_EV_UTL",
        "EV_UTL_ID",
        "EV_UTL_PositedAt",
        "EV_UTL_Confidence"
    )
    SELECT
        OLD."Metadata_EV_UTL",
        OLD."EV_UTL_ID",
        _now,
        0
    WHERE
        OLD."EV_UTL_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of EV_LVL_Event_Level is retracted
    INSERT INTO attributes."EV_LVL_Event_Level_Meta" (
        "Metadata_EV_LVL",
        "EV_LVL_ID",
        "EV_LVL_PositedAt",
        "EV_LVL_Confidence"
    )
    SELECT
        OLD."Metadata_EV_LVL",
        OLD."EV_LVL_ID",
        _now,
        0
    WHERE
        OLD."EV_LVL_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lEV_Event" ON nexuses."lEV_Event";
CREATE TRIGGER "dt_lEV_Event"
INSTEAD OF DELETE ON nexuses."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION nexuses."dt_lEV_Event"();
