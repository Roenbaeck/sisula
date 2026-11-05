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
-- it_SU_holder_OB_item_GRD_grade before INSERT trigger on SU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_SU_holder_OB_item_GRD_grade" := coalesce(NEW."Metadata_SU_holder_OB_item_GRD_grade", 0);
    NEW."SU_holder_OB_item_GRD_grade_ChangedAt" := coalesce(NEW."SU_holder_OB_item_GRD_grade_ChangedAt", _now);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_holder_OB_item_GRD_grade" x
        WHERE
            x."SU_ID_holder" = NEW."SU_ID_holder"
        AND
            x."OB_ID_item" = NEW."OB_ID_item"
        AND
            x."GRD_ID_grade" = NEW."GRD_ID_grade"
        AND
            x."SU_holder_OB_item_GRD_grade_ChangedAt" = NEW."SU_holder_OB_item_GRD_grade_ChangedAt"
    ) THEN
        RETURN NULL;
    END IF;
    -- other values for identifiers that already have values (at that time) are a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_holder_OB_item_GRD_grade" x
        WHERE
            x."SU_ID_holder" = NEW."SU_ID_holder"
        AND
            x."OB_ID_item" = NEW."OB_ID_item"
        AND
            x."SU_holder_OB_item_GRD_grade_ChangedAt" = NEW."SU_holder_OB_item_GRD_grade_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_holder_OB_item_GRD_grade for: %', concat_ws(', ',
            NEW."SU_ID_holder",
            NEW."OB_ID_item",
            NEW."SU_holder_OB_item_GRD_grade_ChangedAt"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_holder_OB_item_GRD_grade" ON public."SU_holder_OB_item_GRD_grade";
CREATE TRIGGER "it_SU_holder_OB_item_GRD_grade"
BEFORE INSERT ON public."SU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_holder_OB_item_GRD_grade"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_holder_OB_item_GRD_grade instead of INSERT trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lSU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO public."SU_holder_OB_item_GRD_grade" (
        "Metadata_SU_holder_OB_item_GRD_grade",
        "SU_holder_OB_item_GRD_grade_ChangedAt",
        "SU_ID_holder",
        "OB_ID_item",
        "GRD_ID_grade"
    )
    SELECT
        NEW."Metadata_SU_holder_OB_item_GRD_grade",
        NEW."SU_holder_OB_item_GRD_grade_ChangedAt",
        NEW."SU_ID_holder",
        NEW."OB_ID_item",
        coalesce(NEW."GRD_ID_grade", (
            SELECT
                k."GRD_ID"
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."grade_GRD_Grade"
            LIMIT 1
        ))
    ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lSU_holder_OB_item_GRD_grade" ON public."lSU_holder_OB_item_GRD_grade";
CREATE TRIGGER "it_lSU_holder_OB_item_GRD_grade"
INSTEAD OF INSERT ON public."lSU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."it_lSU_holder_OB_item_GRD_grade"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_holder_OB_item_GRD_grade instead of UPDATE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lSU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _GRD_grade smallint;
BEGIN
    IF NEW."SU_ID_holder" IS DISTINCT FROM OLD."SU_ID_holder" THEN
        RAISE EXCEPTION 'The identity column SU_ID_holder is not updatable.';
    END IF;
    IF NEW."OB_ID_item" IS DISTINCT FROM OLD."OB_ID_item" THEN
        RAISE EXCEPTION 'The identity column OB_ID_item is not updatable.';
    END IF;
    _GRD_grade := NEW."GRD_ID_grade";
    IF NEW."grade_GRD_Grade" IS DISTINCT FROM OLD."grade_GRD_Grade" THEN
        SELECT
            k."GRD_ID"
        INTO
            _GRD_grade
        FROM
            public."GRD_Grade" k
        WHERE
            k."GRD_Grade" = NEW."grade_GRD_Grade"
        LIMIT 1;
    END IF;
    -- values that are left as they are state nothing
    IF
        _GRD_grade IS NOT NULL
    AND
        (
            NEW."SU_holder_OB_item_GRD_grade_ChangedAt" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_ChangedAt" OR
            NEW."SU_ID_holder" IS DISTINCT FROM OLD."SU_ID_holder"
        OR
            NEW."OB_ID_item" IS DISTINCT FROM OLD."OB_ID_item"
        OR
            _GRD_grade IS DISTINCT FROM OLD."GRD_ID_grade"
        )
    THEN
        INSERT INTO public."SU_holder_OB_item_GRD_grade" (
            "Metadata_SU_holder_OB_item_GRD_grade",
            "SU_holder_OB_item_GRD_grade_ChangedAt",
            "SU_ID_holder",
            "OB_ID_item",
            "GRD_ID_grade"
        )
        VALUES (
            NEW."Metadata_SU_holder_OB_item_GRD_grade",
            CASE
                WHEN NEW."SU_holder_OB_item_GRD_grade_ChangedAt" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_ChangedAt" THEN NEW."SU_holder_OB_item_GRD_grade_ChangedAt"
                ELSE _now
            END,
            NEW."SU_ID_holder",
            NEW."OB_ID_item",
            _GRD_grade
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lSU_holder_OB_item_GRD_grade" ON public."lSU_holder_OB_item_GRD_grade";
CREATE TRIGGER "ut_lSU_holder_OB_item_GRD_grade"
INSTEAD OF UPDATE ON public."lSU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."ut_lSU_holder_OB_item_GRD_grade"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_holder_OB_item_GRD_grade instead of DELETE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lSU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        public."SU_holder_OB_item_GRD_grade" x
    WHERE
        x."SU_holder_OB_item_GRD_grade_ChangedAt" = OLD."SU_holder_OB_item_GRD_grade_ChangedAt"
    AND
        x."SU_ID_holder" = OLD."SU_ID_holder"
    AND
        x."OB_ID_item" = OLD."OB_ID_item"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lSU_holder_OB_item_GRD_grade" ON public."lSU_holder_OB_item_GRD_grade";
CREATE TRIGGER "dt_lSU_holder_OB_item_GRD_grade"
INSTEAD OF DELETE ON public."lSU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."dt_lSU_holder_OB_item_GRD_grade"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_keeper_OB_thing_GRD_rank before INSERT trigger on SU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_SU_keeper_OB_thing_GRD_rank" := coalesce(NEW."Metadata_SU_keeper_OB_thing_GRD_rank", 0);
    NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt" := coalesce(NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt", _now);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_keeper_OB_thing_GRD_rank" x
        WHERE
            x."SU_ID_keeper" = NEW."SU_ID_keeper"
        AND
            x."OB_ID_thing" = NEW."OB_ID_thing"
        AND
            x."GRD_ID_rank" = NEW."GRD_ID_rank"
        AND
            x."SU_keeper_OB_thing_GRD_rank_ChangedAt" = NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
    ) THEN
        RETURN NULL;
    END IF;
    -- other values for identifiers that already have values (at that time) are a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_keeper_OB_thing_GRD_rank" x
        WHERE
            x."SU_ID_keeper" = NEW."SU_ID_keeper"
        AND
            x."OB_ID_thing" = NEW."OB_ID_thing"
        AND
            x."SU_keeper_OB_thing_GRD_rank_ChangedAt" = NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_keeper_OB_thing_GRD_rank for: %', concat_ws(', ',
            NEW."SU_ID_keeper",
            NEW."OB_ID_thing",
            NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
        );
    END IF;
    -- what has the same values as the row before it, or as the row after it, is a restatement
    -- (an idempotent tie does not store it, and removes the row after it that the new row makes a restatement of)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_ID_keeper",
                p."OB_ID_thing",
                p."GRD_ID_rank"
            FROM
                public."SU_keeper_OB_thing_GRD_rank" p
            WHERE
                p."SU_ID_keeper" = NEW."SU_ID_keeper"
            AND
                p."OB_ID_thing" = NEW."OB_ID_thing"
            AND
                p."SU_keeper_OB_thing_GRD_rank_ChangedAt" < NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
            ORDER BY
                p."SU_keeper_OB_thing_GRD_rank_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."SU_ID_keeper" = NEW."SU_ID_keeper"
        AND
            pre."OB_ID_thing" = NEW."OB_ID_thing"
        AND
            pre."GRD_ID_rank" = NEW."GRD_ID_rank"
    ) THEN
        RETURN NULL;
    END IF;
    DELETE FROM
        public."SU_keeper_OB_thing_GRD_rank" x
    WHERE
        x."SU_ID_keeper" = NEW."SU_ID_keeper"
    AND
        x."OB_ID_thing" = NEW."OB_ID_thing"
    AND
        x."SU_keeper_OB_thing_GRD_rank_ChangedAt" = (
            SELECT
                min(f."SU_keeper_OB_thing_GRD_rank_ChangedAt")
            FROM
                public."SU_keeper_OB_thing_GRD_rank" f
            WHERE
                f."SU_ID_keeper" = NEW."SU_ID_keeper"
            AND
                f."OB_ID_thing" = NEW."OB_ID_thing"
            AND
                f."SU_keeper_OB_thing_GRD_rank_ChangedAt" > NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
        )
    AND
        x."SU_ID_keeper" = NEW."SU_ID_keeper"
    AND
        x."OB_ID_thing" = NEW."OB_ID_thing"
    AND
        x."GRD_ID_rank" = NEW."GRD_ID_rank"
    ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_keeper_OB_thing_GRD_rank" ON public."SU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "it_SU_keeper_OB_thing_GRD_rank"
BEFORE INSERT ON public."SU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_keeper_OB_thing_GRD_rank"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_keeper_OB_thing_GRD_rank instead of INSERT trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lSU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO public."SU_keeper_OB_thing_GRD_rank" (
        "Metadata_SU_keeper_OB_thing_GRD_rank",
        "SU_keeper_OB_thing_GRD_rank_ChangedAt",
        "SU_ID_keeper",
        "OB_ID_thing",
        "GRD_ID_rank"
    )
    SELECT
        NEW."Metadata_SU_keeper_OB_thing_GRD_rank",
        NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt",
        NEW."SU_ID_keeper",
        NEW."OB_ID_thing",
        coalesce(NEW."GRD_ID_rank", (
            SELECT
                k."GRD_ID"
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."rank_GRD_Grade"
            LIMIT 1
        ))
    ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lSU_keeper_OB_thing_GRD_rank" ON public."lSU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "it_lSU_keeper_OB_thing_GRD_rank"
INSTEAD OF INSERT ON public."lSU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."it_lSU_keeper_OB_thing_GRD_rank"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_keeper_OB_thing_GRD_rank instead of UPDATE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lSU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _GRD_rank smallint;
BEGIN
    IF NEW."SU_ID_keeper" IS DISTINCT FROM OLD."SU_ID_keeper" THEN
        RAISE EXCEPTION 'The identity column SU_ID_keeper is not updatable.';
    END IF;
    IF NEW."OB_ID_thing" IS DISTINCT FROM OLD."OB_ID_thing" THEN
        RAISE EXCEPTION 'The identity column OB_ID_thing is not updatable.';
    END IF;
    _GRD_rank := NEW."GRD_ID_rank";
    IF NEW."rank_GRD_Grade" IS DISTINCT FROM OLD."rank_GRD_Grade" THEN
        SELECT
            k."GRD_ID"
        INTO
            _GRD_rank
        FROM
            public."GRD_Grade" k
        WHERE
            k."GRD_Grade" = NEW."rank_GRD_Grade"
        LIMIT 1;
    END IF;
    -- values that are left as they are state nothing
    IF
        _GRD_rank IS NOT NULL
    AND
        (
            NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt" IS DISTINCT FROM OLD."SU_keeper_OB_thing_GRD_rank_ChangedAt" OR
            NEW."SU_ID_keeper" IS DISTINCT FROM OLD."SU_ID_keeper"
        OR
            NEW."OB_ID_thing" IS DISTINCT FROM OLD."OB_ID_thing"
        OR
            _GRD_rank IS DISTINCT FROM OLD."GRD_ID_rank"
        )
    THEN
        INSERT INTO public."SU_keeper_OB_thing_GRD_rank" (
            "Metadata_SU_keeper_OB_thing_GRD_rank",
            "SU_keeper_OB_thing_GRD_rank_ChangedAt",
            "SU_ID_keeper",
            "OB_ID_thing",
            "GRD_ID_rank"
        )
        VALUES (
            NEW."Metadata_SU_keeper_OB_thing_GRD_rank",
            CASE
                WHEN NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt" IS DISTINCT FROM OLD."SU_keeper_OB_thing_GRD_rank_ChangedAt" THEN NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
                ELSE _now
            END,
            NEW."SU_ID_keeper",
            NEW."OB_ID_thing",
            _GRD_rank
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lSU_keeper_OB_thing_GRD_rank" ON public."lSU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "ut_lSU_keeper_OB_thing_GRD_rank"
INSTEAD OF UPDATE ON public."lSU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."ut_lSU_keeper_OB_thing_GRD_rank"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_keeper_OB_thing_GRD_rank instead of DELETE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lSU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        public."SU_keeper_OB_thing_GRD_rank" x
    WHERE
        x."SU_keeper_OB_thing_GRD_rank_ChangedAt" = OLD."SU_keeper_OB_thing_GRD_rank_ChangedAt"
    AND
        x."SU_ID_keeper" = OLD."SU_ID_keeper"
    AND
        x."OB_ID_thing" = OLD."OB_ID_thing"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lSU_keeper_OB_thing_GRD_rank" ON public."lSU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "dt_lSU_keeper_OB_thing_GRD_rank"
INSTEAD OF DELETE ON public."lSU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."dt_lSU_keeper_OB_thing_GRD_rank"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OB_part_SU_owner before INSERT trigger on OB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_OB_part_SU_owner"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_OB_part_SU_owner" := coalesce(NEW."Metadata_OB_part_SU_owner", 0);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."OB_part_SU_owner" x
        WHERE
            x."OB_ID_part" = NEW."OB_ID_part"
        AND
            x."SU_ID_owner" = NEW."SU_ID_owner"
        AND
            true
    ) THEN
        RETURN NULL;
    END IF;
    -- other values for identifiers that already have values (at that time) are a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."OB_part_SU_owner" x
        WHERE
            x."OB_ID_part" = NEW."OB_ID_part"
        AND
            true
    ) THEN
        RAISE EXCEPTION 'Contradiction in OB_part_SU_owner for: %', concat_ws(', ',
            NEW."OB_ID_part",
            ''
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_OB_part_SU_owner" ON public."OB_part_SU_owner";
CREATE TRIGGER "it_OB_part_SU_owner"
BEFORE INSERT ON public."OB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."it_OB_part_SU_owner"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_part_SU_owner instead of INSERT trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lOB_part_SU_owner"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO public."OB_part_SU_owner" (
        "Metadata_OB_part_SU_owner",
        "OB_ID_part",
        "SU_ID_owner"
    )
    SELECT
        NEW."Metadata_OB_part_SU_owner",
        NEW."OB_ID_part",
        NEW."SU_ID_owner"
    ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lOB_part_SU_owner" ON public."lOB_part_SU_owner";
CREATE TRIGGER "it_lOB_part_SU_owner"
INSTEAD OF INSERT ON public."lOB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."it_lOB_part_SU_owner"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOB_part_SU_owner instead of UPDATE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lOB_part_SU_owner"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    IF NEW."OB_ID_part" IS DISTINCT FROM OLD."OB_ID_part" THEN
        RAISE EXCEPTION 'The identity column OB_ID_part is not updatable.';
    END IF;
    -- values that are left as they are state nothing
    IF
        NEW."SU_ID_owner" IS NOT NULL
    AND
        (
            NEW."OB_ID_part" IS DISTINCT FROM OLD."OB_ID_part"
        OR
            NEW."SU_ID_owner" IS DISTINCT FROM OLD."SU_ID_owner"
        )
    THEN
        INSERT INTO public."OB_part_SU_owner" (
            "Metadata_OB_part_SU_owner",
            "OB_ID_part",
            "SU_ID_owner"
        )
        VALUES (
            NEW."Metadata_OB_part_SU_owner",
            NEW."OB_ID_part",
            NEW."SU_ID_owner"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lOB_part_SU_owner" ON public."lOB_part_SU_owner";
CREATE TRIGGER "ut_lOB_part_SU_owner"
INSTEAD OF UPDATE ON public."lOB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."ut_lOB_part_SU_owner"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_part_SU_owner instead of DELETE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lOB_part_SU_owner"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        public."OB_part_SU_owner" x
    WHERE
        x."OB_ID_part" = OLD."OB_ID_part"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lOB_part_SU_owner" ON public."lOB_part_SU_owner";
CREATE TRIGGER "dt_lOB_part_SU_owner"
INSTEAD OF DELETE ON public."lOB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."dt_lOB_part_SU_owner"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_partner_SU_with before INSERT trigger on SU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_partner_SU_with"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_SU_partner_SU_with" := coalesce(NEW."Metadata_SU_partner_SU_with", 0);
    NEW."SU_partner_SU_with_ChangedAt" := coalesce(NEW."SU_partner_SU_with_ChangedAt", _now);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_partner_SU_with" x
        WHERE
            x."SU_ID_partner" = NEW."SU_ID_partner"
        AND
            x."SU_ID_with" = NEW."SU_ID_with"
        AND
            x."SU_partner_SU_with_ChangedAt" = NEW."SU_partner_SU_with_ChangedAt"
    ) THEN
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_partner_SU_with" ON public."SU_partner_SU_with";
CREATE TRIGGER "it_SU_partner_SU_with"
BEFORE INSERT ON public."SU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_partner_SU_with"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_partner_SU_with instead of INSERT trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lSU_partner_SU_with"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO public."SU_partner_SU_with" (
        "Metadata_SU_partner_SU_with",
        "SU_partner_SU_with_ChangedAt",
        "SU_ID_partner",
        "SU_ID_with"
    )
    SELECT
        NEW."Metadata_SU_partner_SU_with",
        NEW."SU_partner_SU_with_ChangedAt",
        NEW."SU_ID_partner",
        NEW."SU_ID_with"
    ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lSU_partner_SU_with" ON public."lSU_partner_SU_with";
CREATE TRIGGER "it_lSU_partner_SU_with"
INSTEAD OF INSERT ON public."lSU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."it_lSU_partner_SU_with"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_partner_SU_with instead of UPDATE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lSU_partner_SU_with"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- values that are left as they are state nothing
    IF
        NEW."SU_ID_partner" IS NOT NULL
    AND
        NEW."SU_ID_with" IS NOT NULL
    AND
        (
            NEW."SU_partner_SU_with_ChangedAt" IS DISTINCT FROM OLD."SU_partner_SU_with_ChangedAt" OR
            NEW."SU_ID_partner" IS DISTINCT FROM OLD."SU_ID_partner"
        OR
            NEW."SU_ID_with" IS DISTINCT FROM OLD."SU_ID_with"
        )
    THEN
        INSERT INTO public."SU_partner_SU_with" (
            "Metadata_SU_partner_SU_with",
            "SU_partner_SU_with_ChangedAt",
            "SU_ID_partner",
            "SU_ID_with"
        )
        VALUES (
            NEW."Metadata_SU_partner_SU_with",
            CASE
                WHEN NEW."SU_partner_SU_with_ChangedAt" IS DISTINCT FROM OLD."SU_partner_SU_with_ChangedAt" THEN NEW."SU_partner_SU_with_ChangedAt"
                ELSE _now
            END,
            NEW."SU_ID_partner",
            NEW."SU_ID_with"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lSU_partner_SU_with" ON public."lSU_partner_SU_with";
CREATE TRIGGER "ut_lSU_partner_SU_with"
INSTEAD OF UPDATE ON public."lSU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."ut_lSU_partner_SU_with"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_partner_SU_with instead of DELETE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lSU_partner_SU_with"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        public."SU_partner_SU_with" x
    WHERE
        x."SU_partner_SU_with_ChangedAt" = OLD."SU_partner_SU_with_ChangedAt"
    AND
        x."SU_ID_partner" = OLD."SU_ID_partner"
    AND
        x."SU_ID_with" = OLD."SU_ID_with"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lSU_partner_SU_with" ON public."lSU_partner_SU_with";
CREATE TRIGGER "dt_lSU_partner_SU_with"
INSTEAD OF DELETE ON public."lSU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."dt_lSU_partner_SU_with"();
