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
                knots."ONG_Ongoing_EQ" k
            WHERE
                k."ONG_Ongoing" = NEW."currently_ONG_Ongoing"
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
    IF NEW."currently_ONG_Ongoing" IS DISTINCT FROM OLD."currently_ONG_Ongoing" THEN
        SELECT
            k."ONG_ID"
        INTO
            _ONG_currently
        FROM
            knots."ONG_Ongoing_EQ" k
        WHERE
            k."ONG_Ongoing" = NEW."currently_ONG_Ongoing"
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
-- it_EV_in_AC_wasCast before INSERT trigger on EV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_EV_in_AC_wasCast"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_EV_in_AC_wasCast" := coalesce(NEW."Metadata_EV_in_AC_wasCast", 0);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            ties."EV_in_AC_wasCast" x
        WHERE
            x."EV_ID_in" = NEW."EV_ID_in"
        AND
            x."AC_ID_wasCast" = NEW."AC_ID_wasCast"
        AND
            true
    ) THEN
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_in_AC_wasCast" ON ties."EV_in_AC_wasCast";
CREATE TRIGGER "it_EV_in_AC_wasCast"
BEFORE INSERT ON ties."EV_in_AC_wasCast"
FOR EACH ROW EXECUTE FUNCTION ties."it_EV_in_AC_wasCast"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_wasCast instead of INSERT trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lEV_in_AC_wasCast"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO ties."EV_in_AC_wasCast" (
        "Metadata_EV_in_AC_wasCast",
        "EV_ID_in",
        "AC_ID_wasCast"
    )
    SELECT
        NEW."Metadata_EV_in_AC_wasCast",
        NEW."EV_ID_in",
        NEW."AC_ID_wasCast"
    ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lEV_in_AC_wasCast" ON ties."lEV_in_AC_wasCast";
CREATE TRIGGER "it_lEV_in_AC_wasCast"
INSTEAD OF INSERT ON ties."lEV_in_AC_wasCast"
FOR EACH ROW EXECUTE FUNCTION ties."it_lEV_in_AC_wasCast"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_in_AC_wasCast instead of DELETE trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lEV_in_AC_wasCast"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        ties."EV_in_AC_wasCast" x
    WHERE
        x."EV_ID_in" = OLD."EV_ID_in"
    AND
        x."AC_ID_wasCast" = OLD."AC_ID_wasCast"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lEV_in_AC_wasCast" ON ties."lEV_in_AC_wasCast";
CREATE TRIGGER "dt_lEV_in_AC_wasCast"
INSTEAD OF DELETE ON ties."lEV_in_AC_wasCast"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lEV_in_AC_wasCast"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_part_PR_in_RAT_got before INSERT trigger on AC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_part_PR_in_RAT_got"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_AC_part_PR_in_RAT_got" := coalesce(NEW."Metadata_AC_part_PR_in_RAT_got", 0);
    NEW."AC_part_PR_in_RAT_got_ChangedAt" := coalesce(NEW."AC_part_PR_in_RAT_got_ChangedAt", _now);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            ties."AC_part_PR_in_RAT_got" x
        WHERE
            x."AC_ID_part" = NEW."AC_ID_part"
        AND
            x."PR_ID_in" = NEW."PR_ID_in"
        AND
            x."RAT_ID_got" = NEW."RAT_ID_got"
        AND
            x."AC_part_PR_in_RAT_got_ChangedAt" = NEW."AC_part_PR_in_RAT_got_ChangedAt"
    ) THEN
        RETURN NULL;
    END IF;
    -- other values for identifiers that already have values (at that time) are a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            ties."AC_part_PR_in_RAT_got" x
        WHERE
            x."AC_ID_part" = NEW."AC_ID_part"
        AND
            x."PR_ID_in" = NEW."PR_ID_in"
        AND
            x."AC_part_PR_in_RAT_got_ChangedAt" = NEW."AC_part_PR_in_RAT_got_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_part_PR_in_RAT_got for: %', concat_ws(', ',
            NEW."AC_ID_part",
            NEW."PR_ID_in",
            NEW."AC_part_PR_in_RAT_got_ChangedAt"
        );
    END IF;
    -- what has the same values as the row before it, or as the row after it, is a restatement
    -- (a tie that may not be restated refuses it)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."AC_ID_part",
                p."PR_ID_in",
                p."RAT_ID_got"
            FROM
                ties."AC_part_PR_in_RAT_got" p
            WHERE
                p."AC_ID_part" = NEW."AC_ID_part"
            AND
                p."PR_ID_in" = NEW."PR_ID_in"
            AND
                p."AC_part_PR_in_RAT_got_ChangedAt" < NEW."AC_part_PR_in_RAT_got_ChangedAt"
            ORDER BY
                p."AC_part_PR_in_RAT_got_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."AC_ID_part" = NEW."AC_ID_part"
        AND
            pre."PR_ID_in" = NEW."PR_ID_in"
        AND
            pre."RAT_ID_got" = NEW."RAT_ID_got"
    ) THEN
        RAISE EXCEPTION 'Restatement in AC_part_PR_in_RAT_got for: %', concat_ws(', ',
            NEW."AC_ID_part",
            NEW."PR_ID_in",
            NEW."RAT_ID_got",
            NEW."AC_part_PR_in_RAT_got_ChangedAt"
        );
    END IF;
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                f."AC_ID_part",
                f."PR_ID_in",
                f."RAT_ID_got"
            FROM
                ties."AC_part_PR_in_RAT_got" f
            WHERE
                f."AC_ID_part" = NEW."AC_ID_part"
            AND
                f."PR_ID_in" = NEW."PR_ID_in"
            AND
                f."AC_part_PR_in_RAT_got_ChangedAt" > NEW."AC_part_PR_in_RAT_got_ChangedAt"
            ORDER BY
                f."AC_part_PR_in_RAT_got_ChangedAt" ASC
            LIMIT 1
        ) fol
        WHERE
            fol."AC_ID_part" = NEW."AC_ID_part"
        AND
            fol."PR_ID_in" = NEW."PR_ID_in"
        AND
            fol."RAT_ID_got" = NEW."RAT_ID_got"
    ) THEN
        RAISE EXCEPTION 'Restatement in AC_part_PR_in_RAT_got for: %', concat_ws(', ',
            NEW."AC_ID_part",
            NEW."PR_ID_in",
            NEW."RAT_ID_got",
            NEW."AC_part_PR_in_RAT_got_ChangedAt"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_part_PR_in_RAT_got" ON ties."AC_part_PR_in_RAT_got";
CREATE TRIGGER "it_AC_part_PR_in_RAT_got"
BEFORE INSERT ON ties."AC_part_PR_in_RAT_got"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_part_PR_in_RAT_got"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_part_PR_in_RAT_got instead of INSERT trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_part_PR_in_RAT_got"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO ties."AC_part_PR_in_RAT_got" (
        "Metadata_AC_part_PR_in_RAT_got",
        "AC_part_PR_in_RAT_got_ChangedAt",
        "AC_ID_part",
        "PR_ID_in",
        "RAT_ID_got"
    )
    SELECT
        NEW."Metadata_AC_part_PR_in_RAT_got",
        NEW."AC_part_PR_in_RAT_got_ChangedAt",
        NEW."AC_ID_part",
        NEW."PR_ID_in",
        coalesce(NEW."RAT_ID_got", (
            SELECT
                k."RAT_ID"
            FROM
                knots."RAT_Rating_EQ" k
            WHERE
                k."RAT_Rating" = NEW."got_RAT_Rating"
            AND
                k."RAT_EQ" = coalesce(NEW."got_RAT_EQ", 0)
            LIMIT 1
        ))
    ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lAC_part_PR_in_RAT_got" ON ties."lAC_part_PR_in_RAT_got";
CREATE TRIGGER "it_lAC_part_PR_in_RAT_got"
INSTEAD OF INSERT ON ties."lAC_part_PR_in_RAT_got"
FOR EACH ROW EXECUTE FUNCTION ties."it_lAC_part_PR_in_RAT_got"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_part_PR_in_RAT_got instead of UPDATE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ut_lAC_part_PR_in_RAT_got"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _RAT_got smallint;
BEGIN
    IF NEW."AC_ID_part" IS DISTINCT FROM OLD."AC_ID_part" THEN
        RAISE EXCEPTION 'The identity column AC_ID_part is not updatable.';
    END IF;
    IF NEW."PR_ID_in" IS DISTINCT FROM OLD."PR_ID_in" THEN
        RAISE EXCEPTION 'The identity column PR_ID_in is not updatable.';
    END IF;
    _RAT_got := NEW."RAT_ID_got";
    IF NEW."got_RAT_Rating" IS DISTINCT FROM OLD."got_RAT_Rating" THEN
        SELECT
            k."RAT_ID"
        INTO
            _RAT_got
        FROM
            knots."RAT_Rating_EQ" k
        WHERE
            k."RAT_Rating" = NEW."got_RAT_Rating"
        AND
            k."RAT_EQ" = coalesce(NEW."got_RAT_EQ", 0)
        LIMIT 1;
    END IF;
    -- values that are left as they are state nothing
    IF
        _RAT_got IS NOT NULL
    AND
        (
            NEW."AC_part_PR_in_RAT_got_ChangedAt" IS DISTINCT FROM OLD."AC_part_PR_in_RAT_got_ChangedAt" OR
            NEW."AC_ID_part" IS DISTINCT FROM OLD."AC_ID_part"
        OR
            NEW."PR_ID_in" IS DISTINCT FROM OLD."PR_ID_in"
        OR
            _RAT_got IS DISTINCT FROM OLD."RAT_ID_got"
        )
    THEN
        INSERT INTO ties."AC_part_PR_in_RAT_got" (
            "Metadata_AC_part_PR_in_RAT_got",
            "AC_part_PR_in_RAT_got_ChangedAt",
            "AC_ID_part",
            "PR_ID_in",
            "RAT_ID_got"
        )
        VALUES (
            NEW."Metadata_AC_part_PR_in_RAT_got",
            CASE
                WHEN NEW."AC_part_PR_in_RAT_got_ChangedAt" IS DISTINCT FROM OLD."AC_part_PR_in_RAT_got_ChangedAt" THEN NEW."AC_part_PR_in_RAT_got_ChangedAt"
                ELSE _now
            END,
            NEW."AC_ID_part",
            NEW."PR_ID_in",
            _RAT_got
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lAC_part_PR_in_RAT_got" ON ties."lAC_part_PR_in_RAT_got";
CREATE TRIGGER "ut_lAC_part_PR_in_RAT_got"
INSTEAD OF UPDATE ON ties."lAC_part_PR_in_RAT_got"
FOR EACH ROW EXECUTE FUNCTION ties."ut_lAC_part_PR_in_RAT_got"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_part_PR_in_RAT_got instead of DELETE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lAC_part_PR_in_RAT_got"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        ties."AC_part_PR_in_RAT_got" x
    WHERE
        x."AC_part_PR_in_RAT_got_ChangedAt" = OLD."AC_part_PR_in_RAT_got_ChangedAt"
    AND
        x."AC_ID_part" = OLD."AC_ID_part"
    AND
        x."PR_ID_in" = OLD."PR_ID_in"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_part_PR_in_RAT_got" ON ties."lAC_part_PR_in_RAT_got";
CREATE TRIGGER "dt_lAC_part_PR_in_RAT_got"
INSTEAD OF DELETE ON ties."lAC_part_PR_in_RAT_got"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_part_PR_in_RAT_got"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_at_PR_isPlaying before INSERT trigger on ST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_ST_at_PR_isPlaying"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_ST_at_PR_isPlaying" := coalesce(NEW."Metadata_ST_at_PR_isPlaying", 0);
    NEW."ST_at_PR_isPlaying_ChangedAt" := coalesce(NEW."ST_at_PR_isPlaying_ChangedAt", _now);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            ties."ST_at_PR_isPlaying" x
        WHERE
            x."ST_ID_at" = NEW."ST_ID_at"
        AND
            x."PR_ID_isPlaying" = NEW."PR_ID_isPlaying"
        AND
            x."ST_at_PR_isPlaying_ChangedAt" = NEW."ST_at_PR_isPlaying_ChangedAt"
    ) THEN
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_at_PR_isPlaying" ON ties."ST_at_PR_isPlaying";
CREATE TRIGGER "it_ST_at_PR_isPlaying"
BEFORE INSERT ON ties."ST_at_PR_isPlaying"
FOR EACH ROW EXECUTE FUNCTION ties."it_ST_at_PR_isPlaying"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_isPlaying instead of INSERT trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lST_at_PR_isPlaying"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO ties."ST_at_PR_isPlaying" (
        "Metadata_ST_at_PR_isPlaying",
        "ST_at_PR_isPlaying_ChangedAt",
        "ST_ID_at",
        "PR_ID_isPlaying"
    )
    SELECT
        NEW."Metadata_ST_at_PR_isPlaying",
        NEW."ST_at_PR_isPlaying_ChangedAt",
        NEW."ST_ID_at",
        NEW."PR_ID_isPlaying"
    ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lST_at_PR_isPlaying" ON ties."lST_at_PR_isPlaying";
CREATE TRIGGER "it_lST_at_PR_isPlaying"
INSTEAD OF INSERT ON ties."lST_at_PR_isPlaying"
FOR EACH ROW EXECUTE FUNCTION ties."it_lST_at_PR_isPlaying"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_at_PR_isPlaying instead of DELETE trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lST_at_PR_isPlaying"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        ties."ST_at_PR_isPlaying" x
    WHERE
        x."ST_at_PR_isPlaying_ChangedAt" = OLD."ST_at_PR_isPlaying_ChangedAt"
    AND
        x."ST_ID_at" = OLD."ST_ID_at"
    AND
        x."PR_ID_isPlaying" = OLD."PR_ID_isPlaying"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lST_at_PR_isPlaying" ON ties."lST_at_PR_isPlaying";
CREATE TRIGGER "dt_lST_at_PR_isPlaying"
INSTEAD OF DELETE ON ties."lST_at_PR_isPlaying"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lST_at_PR_isPlaying"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_parent_AC_child_PAT_having before INSERT trigger on AC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_parent_AC_child_PAT_having"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_AC_parent_AC_child_PAT_having" := coalesce(NEW."Metadata_AC_parent_AC_child_PAT_having", 0);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            ties."AC_parent_AC_child_PAT_having" x
        WHERE
            x."AC_ID_parent" = NEW."AC_ID_parent"
        AND
            x."AC_ID_child" = NEW."AC_ID_child"
        AND
            x."PAT_ID_having" = NEW."PAT_ID_having"
        AND
            true
    ) THEN
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_parent_AC_child_PAT_having" ON ties."AC_parent_AC_child_PAT_having";
CREATE TRIGGER "it_AC_parent_AC_child_PAT_having"
BEFORE INSERT ON ties."AC_parent_AC_child_PAT_having"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_parent_AC_child_PAT_having"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_parent_AC_child_PAT_having instead of INSERT trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_parent_AC_child_PAT_having"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO ties."AC_parent_AC_child_PAT_having" (
        "Metadata_AC_parent_AC_child_PAT_having",
        "AC_ID_parent",
        "AC_ID_child",
        "PAT_ID_having"
    )
    SELECT
        NEW."Metadata_AC_parent_AC_child_PAT_having",
        NEW."AC_ID_parent",
        NEW."AC_ID_child",
        coalesce(NEW."PAT_ID_having", (
            SELECT
                k."PAT_ID"
            FROM
                knots."PAT_ParentalType_EQ" k
            WHERE
                k."PAT_ParentalType" = NEW."having_PAT_ParentalType"
            AND
                k."PAT_EQ" = coalesce(NEW."having_PAT_EQ", 0)
            LIMIT 1
        ))
    ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lAC_parent_AC_child_PAT_having" ON ties."lAC_parent_AC_child_PAT_having";
CREATE TRIGGER "it_lAC_parent_AC_child_PAT_having"
INSTEAD OF INSERT ON ties."lAC_parent_AC_child_PAT_having"
FOR EACH ROW EXECUTE FUNCTION ties."it_lAC_parent_AC_child_PAT_having"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_parent_AC_child_PAT_having instead of DELETE trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lAC_parent_AC_child_PAT_having"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        ties."AC_parent_AC_child_PAT_having" x
    WHERE
        x."AC_ID_parent" = OLD."AC_ID_parent"
    AND
        x."AC_ID_child" = OLD."AC_ID_child"
    AND
        x."PAT_ID_having" = OLD."PAT_ID_having"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_parent_AC_child_PAT_having" ON ties."lAC_parent_AC_child_PAT_having";
CREATE TRIGGER "dt_lAC_parent_AC_child_PAT_having"
INSTEAD OF DELETE ON ties."lAC_parent_AC_child_PAT_having"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_parent_AC_child_PAT_having"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_content_ST_location_EV_of before INSERT trigger on PR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_PR_content_ST_location_EV_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_PR_content_ST_location_EV_of" := coalesce(NEW."Metadata_PR_content_ST_location_EV_of", 0);
    NEW."PR_content_ST_location_EV_of_ChangedAt" := coalesce(NEW."PR_content_ST_location_EV_of_ChangedAt", _now);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            ties."PR_content_ST_location_EV_of" x
        WHERE
            x."PR_ID_content" = NEW."PR_ID_content"
        AND
            x."ST_ID_location" = NEW."ST_ID_location"
        AND
            x."EV_ID_of" = NEW."EV_ID_of"
        AND
            x."PR_content_ST_location_EV_of_ChangedAt" = NEW."PR_content_ST_location_EV_of_ChangedAt"
    ) THEN
        RETURN NULL;
    END IF;
    -- what has the same values as the row before it, or as the row after it, is a restatement
    -- (a tie that may not be restated refuses it)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."PR_ID_content",
                p."ST_ID_location",
                p."EV_ID_of"
            FROM
                ties."PR_content_ST_location_EV_of" p
            WHERE
                p."PR_ID_content" = NEW."PR_ID_content"
            AND
                p."ST_ID_location" = NEW."ST_ID_location"
            AND
                p."EV_ID_of" = NEW."EV_ID_of"
            AND
                p."PR_content_ST_location_EV_of_ChangedAt" < NEW."PR_content_ST_location_EV_of_ChangedAt"
            ORDER BY
                p."PR_content_ST_location_EV_of_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."PR_ID_content" = NEW."PR_ID_content"
        AND
            pre."ST_ID_location" = NEW."ST_ID_location"
        AND
            pre."EV_ID_of" = NEW."EV_ID_of"
    ) THEN
        RAISE EXCEPTION 'Restatement in PR_content_ST_location_EV_of for: %', concat_ws(', ',
            NEW."PR_ID_content",
            NEW."ST_ID_location",
            NEW."EV_ID_of",
            NEW."PR_content_ST_location_EV_of_ChangedAt"
        );
    END IF;
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                f."PR_ID_content",
                f."ST_ID_location",
                f."EV_ID_of"
            FROM
                ties."PR_content_ST_location_EV_of" f
            WHERE
                f."PR_ID_content" = NEW."PR_ID_content"
            AND
                f."ST_ID_location" = NEW."ST_ID_location"
            AND
                f."EV_ID_of" = NEW."EV_ID_of"
            AND
                f."PR_content_ST_location_EV_of_ChangedAt" > NEW."PR_content_ST_location_EV_of_ChangedAt"
            ORDER BY
                f."PR_content_ST_location_EV_of_ChangedAt" ASC
            LIMIT 1
        ) fol
        WHERE
            fol."PR_ID_content" = NEW."PR_ID_content"
        AND
            fol."ST_ID_location" = NEW."ST_ID_location"
        AND
            fol."EV_ID_of" = NEW."EV_ID_of"
    ) THEN
        RAISE EXCEPTION 'Restatement in PR_content_ST_location_EV_of for: %', concat_ws(', ',
            NEW."PR_ID_content",
            NEW."ST_ID_location",
            NEW."EV_ID_of",
            NEW."PR_content_ST_location_EV_of_ChangedAt"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_PR_content_ST_location_EV_of" ON ties."PR_content_ST_location_EV_of";
CREATE TRIGGER "it_PR_content_ST_location_EV_of"
BEFORE INSERT ON ties."PR_content_ST_location_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."it_PR_content_ST_location_EV_of"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_content_ST_location_EV_of instead of INSERT trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lPR_content_ST_location_EV_of"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO ties."PR_content_ST_location_EV_of" (
        "Metadata_PR_content_ST_location_EV_of",
        "PR_content_ST_location_EV_of_ChangedAt",
        "PR_ID_content",
        "ST_ID_location",
        "EV_ID_of"
    )
    SELECT
        NEW."Metadata_PR_content_ST_location_EV_of",
        NEW."PR_content_ST_location_EV_of_ChangedAt",
        NEW."PR_ID_content",
        NEW."ST_ID_location",
        NEW."EV_ID_of"
    ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lPR_content_ST_location_EV_of" ON ties."lPR_content_ST_location_EV_of";
CREATE TRIGGER "it_lPR_content_ST_location_EV_of"
INSTEAD OF INSERT ON ties."lPR_content_ST_location_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."it_lPR_content_ST_location_EV_of"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_content_ST_location_EV_of instead of UPDATE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ut_lPR_content_ST_location_EV_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- values that are left as they are state nothing
    IF
        NEW."PR_ID_content" IS NOT NULL
    AND
        NEW."ST_ID_location" IS NOT NULL
    AND
        NEW."EV_ID_of" IS NOT NULL
    AND
        (
            NEW."PR_content_ST_location_EV_of_ChangedAt" IS DISTINCT FROM OLD."PR_content_ST_location_EV_of_ChangedAt" OR
            NEW."PR_ID_content" IS DISTINCT FROM OLD."PR_ID_content"
        OR
            NEW."ST_ID_location" IS DISTINCT FROM OLD."ST_ID_location"
        OR
            NEW."EV_ID_of" IS DISTINCT FROM OLD."EV_ID_of"
        )
    THEN
        INSERT INTO ties."PR_content_ST_location_EV_of" (
            "Metadata_PR_content_ST_location_EV_of",
            "PR_content_ST_location_EV_of_ChangedAt",
            "PR_ID_content",
            "ST_ID_location",
            "EV_ID_of"
        )
        VALUES (
            NEW."Metadata_PR_content_ST_location_EV_of",
            CASE
                WHEN NEW."PR_content_ST_location_EV_of_ChangedAt" IS DISTINCT FROM OLD."PR_content_ST_location_EV_of_ChangedAt" THEN NEW."PR_content_ST_location_EV_of_ChangedAt"
                ELSE _now
            END,
            NEW."PR_ID_content",
            NEW."ST_ID_location",
            NEW."EV_ID_of"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lPR_content_ST_location_EV_of" ON ties."lPR_content_ST_location_EV_of";
CREATE TRIGGER "ut_lPR_content_ST_location_EV_of"
INSTEAD OF UPDATE ON ties."lPR_content_ST_location_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."ut_lPR_content_ST_location_EV_of"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_content_ST_location_EV_of instead of DELETE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lPR_content_ST_location_EV_of"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        ties."PR_content_ST_location_EV_of" x
    WHERE
        x."PR_content_ST_location_EV_of_ChangedAt" = OLD."PR_content_ST_location_EV_of_ChangedAt"
    AND
        x."PR_ID_content" = OLD."PR_ID_content"
    AND
        x."ST_ID_location" = OLD."ST_ID_location"
    AND
        x."EV_ID_of" = OLD."EV_ID_of"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lPR_content_ST_location_EV_of" ON ties."lPR_content_ST_location_EV_of";
CREATE TRIGGER "dt_lPR_content_ST_location_EV_of"
INSTEAD OF DELETE ON ties."lPR_content_ST_location_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lPR_content_ST_location_EV_of"();
