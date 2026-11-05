-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
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
-- it_lSU_Subject instead of INSERT trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lSU_Subject"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id integer;
    _GRD smallint;
    _LVL smallint;
BEGIN
    _id := NEW."SU_ID";
    IF _id IS NULL THEN
        INSERT INTO public."SU_Subject" (
            "Metadata_SU"
        )
        VALUES (
            NEW."Metadata_SU"
        )
        RETURNING "SU_ID" INTO _id;
    END IF;
    IF NEW."SU_NAM_Subject_Name" IS NOT NULL THEN
        INSERT INTO public."SU_NAM_Subject_Name" (
            "Metadata_SU_NAM",
            "SU_NAM_SU_ID",
            "SU_NAM_Subject_Name",
            "SU_NAM_PositedAt",
            "SU_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NAM", NEW."Metadata_SU"),
            coalesce(NEW."SU_NAM_SU_ID", _id),
            NEW."SU_NAM_Subject_Name",
            coalesce(NEW."SU_NAM_PositedAt", _now),
            coalesce(NEW."SU_NAM_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_COD_Subject_Code" IS NOT NULL THEN
        INSERT INTO public."SU_COD_Subject_Code" (
            "Metadata_SU_COD",
            "SU_COD_SU_ID",
            "SU_COD_Subject_Code",
            "SU_COD_PositedAt",
            "SU_COD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_COD", NEW."Metadata_SU"),
            coalesce(NEW."SU_COD_SU_ID", _id),
            NEW."SU_COD_Subject_Code",
            coalesce(NEW."SU_COD_PositedAt", _now),
            coalesce(NEW."SU_COD_Reliability", NEW."Reliability", 1)
        );
    END IF;
    _GRD := NEW."SU_GRD_GRD_ID";
    IF _GRD IS NULL AND NEW."SU_GRD_GRD_Grade" IS NOT NULL THEN
        SELECT
            k."GRD_ID"
        INTO
            _GRD
        FROM
            public."GRD_Grade" k
        WHERE
            k."GRD_Grade" = NEW."SU_GRD_GRD_Grade"
        LIMIT 1;
    END IF;
    IF _GRD IS NOT NULL THEN
        INSERT INTO public."SU_GRD_Subject_Grade" (
            "Metadata_SU_GRD",
            "SU_GRD_SU_ID",
            "SU_GRD_GRD_ID",
            "SU_GRD_PositedAt",
            "SU_GRD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_GRD", NEW."Metadata_SU"),
            coalesce(NEW."SU_GRD_SU_ID", _id),
            _GRD,
            coalesce(NEW."SU_GRD_PositedAt", _now),
            coalesce(NEW."SU_GRD_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_NOT_Subject_Note" IS NOT NULL THEN
        INSERT INTO public."SU_NOT_Subject_Note" (
            "Metadata_SU_NOT",
            "SU_NOT_SU_ID",
            "SU_NOT_Subject_Note",
            "SU_NOT_PositedAt",
            "SU_NOT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NOT", NEW."Metadata_SU"),
            coalesce(NEW."SU_NOT_SU_ID", _id),
            NEW."SU_NOT_Subject_Note",
            coalesce(NEW."SU_NOT_PositedAt", _now),
            coalesce(NEW."SU_NOT_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_TTL_Subject_Title" IS NOT NULL THEN
        INSERT INTO public."SU_TTL_Subject_Title" (
            "Metadata_SU_TTL",
            "SU_TTL_SU_ID",
            "SU_TTL_Subject_Title",
            "SU_TTL_ChangedAt",
            "SU_TTL_PositedAt",
            "SU_TTL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TTL", NEW."Metadata_SU"),
            coalesce(NEW."SU_TTL_SU_ID", _id),
            NEW."SU_TTL_Subject_Title",
            coalesce(NEW."SU_TTL_ChangedAt", _now),
            coalesce(NEW."SU_TTL_PositedAt", _now),
            coalesce(NEW."SU_TTL_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_STA_Subject_State" IS NOT NULL THEN
        INSERT INTO public."SU_STA_Subject_State" (
            "Metadata_SU_STA",
            "SU_STA_SU_ID",
            "SU_STA_Subject_State",
            "SU_STA_ChangedAt",
            "SU_STA_PositedAt",
            "SU_STA_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_STA", NEW."Metadata_SU"),
            coalesce(NEW."SU_STA_SU_ID", _id),
            NEW."SU_STA_Subject_State",
            coalesce(NEW."SU_STA_ChangedAt", _now),
            coalesce(NEW."SU_STA_PositedAt", _now),
            coalesce(NEW."SU_STA_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_LBL_Subject_Label" IS NOT NULL THEN
        INSERT INTO public."SU_LBL_Subject_Label" (
            "Metadata_SU_LBL",
            "SU_LBL_SU_ID",
            "SU_LBL_Subject_Label",
            "SU_LBL_ChangedAt",
            "SU_LBL_PositedAt",
            "SU_LBL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LBL", NEW."Metadata_SU"),
            coalesce(NEW."SU_LBL_SU_ID", _id),
            NEW."SU_LBL_Subject_Label",
            coalesce(NEW."SU_LBL_ChangedAt", _now),
            coalesce(NEW."SU_LBL_PositedAt", _now),
            coalesce(NEW."SU_LBL_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_TAG_Subject_Tag" IS NOT NULL THEN
        INSERT INTO public."SU_TAG_Subject_Tag" (
            "Metadata_SU_TAG",
            "SU_TAG_SU_ID",
            "SU_TAG_Subject_Tag",
            "SU_TAG_ChangedAt",
            "SU_TAG_PositedAt",
            "SU_TAG_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TAG", NEW."Metadata_SU"),
            coalesce(NEW."SU_TAG_SU_ID", _id),
            NEW."SU_TAG_Subject_Tag",
            coalesce(NEW."SU_TAG_ChangedAt", _now),
            coalesce(NEW."SU_TAG_PositedAt", _now),
            coalesce(NEW."SU_TAG_Reliability", NEW."Reliability", 1)
        );
    END IF;
    _LVL := NEW."SU_LVL_GRD_ID";
    IF _LVL IS NULL AND NEW."SU_LVL_GRD_Grade" IS NOT NULL THEN
        SELECT
            k."GRD_ID"
        INTO
            _LVL
        FROM
            public."GRD_Grade" k
        WHERE
            k."GRD_Grade" = NEW."SU_LVL_GRD_Grade"
        LIMIT 1;
    END IF;
    IF _LVL IS NOT NULL THEN
        INSERT INTO public."SU_LVL_Subject_Level" (
            "Metadata_SU_LVL",
            "SU_LVL_SU_ID",
            "SU_LVL_GRD_ID",
            "SU_LVL_ChangedAt",
            "SU_LVL_PositedAt",
            "SU_LVL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LVL", NEW."Metadata_SU"),
            coalesce(NEW."SU_LVL_SU_ID", _id),
            _LVL,
            coalesce(NEW."SU_LVL_ChangedAt", _now),
            coalesce(NEW."SU_LVL_PositedAt", _now),
            coalesce(NEW."SU_LVL_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_TXT_Subject_Text" IS NOT NULL THEN
        INSERT INTO public."SU_TXT_Subject_Text" (
            "Metadata_SU_TXT",
            "SU_TXT_SU_ID",
            "SU_TXT_Subject_Text",
            "SU_TXT_ChangedAt",
            "SU_TXT_PositedAt",
            "SU_TXT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TXT", NEW."Metadata_SU"),
            coalesce(NEW."SU_TXT_SU_ID", _id),
            NEW."SU_TXT_Subject_Text",
            coalesce(NEW."SU_TXT_ChangedAt", _now),
            coalesce(NEW."SU_TXT_PositedAt", _now),
            coalesce(NEW."SU_TXT_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_ASR_Subject_Assessment" IS NOT NULL THEN
        INSERT INTO public."SU_ASR_Subject_Assessment" (
            "Metadata_SU_ASR",
            "SU_ASR_SU_ID",
            "SU_ASR_Subject_Assessment",
            "SU_ASR_ChangedAt",
            "SU_ASR_PositedAt",
            "SU_ASR_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ASR", NEW."Metadata_SU"),
            coalesce(NEW."SU_ASR_SU_ID", _id),
            NEW."SU_ASR_Subject_Assessment",
            coalesce(NEW."SU_ASR_ChangedAt", _now),
            coalesce(NEW."SU_ASR_PositedAt", _now),
            coalesce(NEW."SU_ASR_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_ERS_Subject_Erasable" IS NOT NULL THEN
        INSERT INTO public."SU_ERS_Subject_Erasable" (
            "Metadata_SU_ERS",
            "SU_ERS_SU_ID",
            "SU_ERS_Subject_Erasable",
            "SU_ERS_ChangedAt",
            "SU_ERS_PositedAt",
            "SU_ERS_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ERS", NEW."Metadata_SU"),
            coalesce(NEW."SU_ERS_SU_ID", _id),
            NEW."SU_ERS_Subject_Erasable",
            coalesce(NEW."SU_ERS_ChangedAt", _now),
            coalesce(NEW."SU_ERS_PositedAt", _now),
            coalesce(NEW."SU_ERS_Reliability", NEW."Reliability", 1)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lSU_Subject" ON public."lSU_Subject";
CREATE TRIGGER "it_lSU_Subject"
INSTEAD OF INSERT ON public."lSU_Subject"
FOR EACH ROW EXECUTE FUNCTION public."it_lSU_Subject"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_Subject instead of UPDATE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lSU_Subject"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _reliability decimal(5,2);
    _positing timestamp;
    _GRD smallint;
    _LVL smallint;
BEGIN
    IF NEW."SU_ID" IS DISTINCT FROM OLD."SU_ID" THEN
        RAISE EXCEPTION 'The identity column SU_ID is not updatable.';
    END IF;
    IF NEW."SU_NAM_ID" IS DISTINCT FROM OLD."SU_NAM_ID" THEN
        RAISE EXCEPTION 'The identity column SU_NAM_ID is not updatable.';
    END IF;
    IF NEW."SU_NAM_SU_ID" IS DISTINCT FROM OLD."SU_NAM_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_NAM_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_NAM_Subject_Name, and when it posits
    _reliability := CASE
        WHEN NEW."SU_NAM_Reliability" IS DISTINCT FROM OLD."SU_NAM_Reliability" THEN NEW."SU_NAM_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_NAM_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_NAM_PositedAt" IS DISTINCT FROM OLD."SU_NAM_PositedAt" THEN NEW."SU_NAM_PositedAt"
        ELSE _now
    END;
    IF NEW."SU_NAM_Subject_Name" IS DISTINCT FROM OLD."SU_NAM_Subject_Name"
    OR NEW."SU_NAM_PositedAt" IS DISTINCT FROM OLD."SU_NAM_PositedAt"
    OR NEW."SU_NAM_Reliability" IS DISTINCT FROM OLD."SU_NAM_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_NAM_Subject_Name" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_NAM_Subject_Name" IS NULL
            OR NEW."SU_NAM_PositedAt" IS DISTINCT FROM OLD."SU_NAM_PositedAt"
            OR OLD."SU_NAM_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_NAM_Subject_Name" <> NEW."SU_NAM_Subject_Name"
            THEN
                INSERT INTO public."SU_NAM_Subject_Name" (
                    "Metadata_SU_NAM",
                    "SU_NAM_SU_ID",
                    "SU_NAM_Subject_Name",
                    "SU_NAM_PositedAt",
                    "SU_NAM_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_NAM" IS NOT DISTINCT FROM OLD."Metadata_SU_NAM"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_NAM"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_NAM_SU_ID", NEW."SU_ID"),
                    NEW."SU_NAM_Subject_Name",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_NAM_Subject_Name" IS NULL AND OLD."SU_NAM_Subject_Name" IS NOT NULL THEN
            INSERT INTO public."SU_NAM_Subject_Name" (
                "Metadata_SU_NAM",
                "SU_NAM_SU_ID",
                "SU_NAM_Subject_Name",
                "SU_NAM_PositedAt",
                "SU_NAM_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_NAM" IS NOT DISTINCT FROM OLD."Metadata_SU_NAM"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_NAM"
                    END, NEW."Metadata_SU"),
                p."SU_NAM_SU_ID",
                p."SU_NAM_Subject_Name",
                _positing,
                0
            FROM
                public."SU_NAM_Subject_Name_Posit" p
            WHERE
                p."SU_NAM_ID" = OLD."SU_NAM_ID";
        END IF;
    END IF;
    IF NEW."SU_COD_ID" IS DISTINCT FROM OLD."SU_COD_ID" THEN
        RAISE EXCEPTION 'The identity column SU_COD_ID is not updatable.';
    END IF;
    IF NEW."SU_COD_SU_ID" IS DISTINCT FROM OLD."SU_COD_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_COD_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_COD_Subject_Code, and when it posits
    _reliability := CASE
        WHEN NEW."SU_COD_Reliability" IS DISTINCT FROM OLD."SU_COD_Reliability" THEN NEW."SU_COD_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_COD_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_COD_PositedAt" IS DISTINCT FROM OLD."SU_COD_PositedAt" THEN NEW."SU_COD_PositedAt"
        ELSE _now
    END;
    IF NEW."SU_COD_Subject_Code" IS DISTINCT FROM OLD."SU_COD_Subject_Code"
    OR NEW."SU_COD_PositedAt" IS DISTINCT FROM OLD."SU_COD_PositedAt"
    OR NEW."SU_COD_Reliability" IS DISTINCT FROM OLD."SU_COD_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_COD_Subject_Code" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_COD_Subject_Code" IS NULL
            OR NEW."SU_COD_PositedAt" IS DISTINCT FROM OLD."SU_COD_PositedAt"
            OR OLD."SU_COD_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_COD_Subject_Code" <> NEW."SU_COD_Subject_Code"
            THEN
                INSERT INTO public."SU_COD_Subject_Code" (
                    "Metadata_SU_COD",
                    "SU_COD_SU_ID",
                    "SU_COD_Subject_Code",
                    "SU_COD_PositedAt",
                    "SU_COD_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_COD" IS NOT DISTINCT FROM OLD."Metadata_SU_COD"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_COD"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_COD_SU_ID", NEW."SU_ID"),
                    NEW."SU_COD_Subject_Code",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_COD_Subject_Code" IS NULL AND OLD."SU_COD_Subject_Code" IS NOT NULL THEN
            INSERT INTO public."SU_COD_Subject_Code" (
                "Metadata_SU_COD",
                "SU_COD_SU_ID",
                "SU_COD_Subject_Code",
                "SU_COD_PositedAt",
                "SU_COD_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_COD" IS NOT DISTINCT FROM OLD."Metadata_SU_COD"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_COD"
                    END, NEW."Metadata_SU"),
                p."SU_COD_SU_ID",
                p."SU_COD_Subject_Code",
                _positing,
                0
            FROM
                public."SU_COD_Subject_Code_Posit" p
            WHERE
                p."SU_COD_ID" = OLD."SU_COD_ID";
        END IF;
    END IF;
    IF NEW."SU_GRD_ID" IS DISTINCT FROM OLD."SU_GRD_ID" THEN
        RAISE EXCEPTION 'The identity column SU_GRD_ID is not updatable.';
    END IF;
    IF NEW."SU_GRD_SU_ID" IS DISTINCT FROM OLD."SU_GRD_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_GRD_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_GRD_Subject_Grade, and when it posits
    _reliability := CASE
        WHEN NEW."SU_GRD_Reliability" IS DISTINCT FROM OLD."SU_GRD_Reliability" THEN NEW."SU_GRD_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_GRD_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_GRD_PositedAt" IS DISTINCT FROM OLD."SU_GRD_PositedAt" THEN NEW."SU_GRD_PositedAt"
        ELSE _now
    END;
    _GRD := NEW."SU_GRD_GRD_ID";
    IF _GRD IS NOT DISTINCT FROM OLD."SU_GRD_GRD_ID" AND NEW."SU_GRD_GRD_Grade" IS DISTINCT FROM OLD."SU_GRD_GRD_Grade" THEN
        _GRD := NULL;
        IF NEW."SU_GRD_GRD_Grade" IS NOT NULL THEN
            SELECT
                k."GRD_ID"
            INTO
                _GRD
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."SU_GRD_GRD_Grade"
            LIMIT 1;
        END IF;
    END IF;
    IF NEW."SU_GRD_GRD_ID" IS DISTINCT FROM OLD."SU_GRD_GRD_ID"
    OR NEW."SU_GRD_GRD_Grade" IS DISTINCT FROM OLD."SU_GRD_GRD_Grade"
    OR NEW."SU_GRD_PositedAt" IS DISTINCT FROM OLD."SU_GRD_PositedAt"
    OR NEW."SU_GRD_Reliability" IS DISTINCT FROM OLD."SU_GRD_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF _GRD IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_GRD_GRD_ID" IS NULL
            OR NEW."SU_GRD_PositedAt" IS DISTINCT FROM OLD."SU_GRD_PositedAt"
            OR OLD."SU_GRD_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_GRD_GRD_ID" <> _GRD
            THEN
                INSERT INTO public."SU_GRD_Subject_Grade" (
                    "Metadata_SU_GRD",
                    "SU_GRD_SU_ID",
                    "SU_GRD_GRD_ID",
                    "SU_GRD_PositedAt",
                    "SU_GRD_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_GRD" IS NOT DISTINCT FROM OLD."Metadata_SU_GRD"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_GRD"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_GRD_SU_ID", NEW."SU_ID"),
                    _GRD,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."SU_GRD_GRD_ID" IS NOT NULL AND (
            NEW."SU_GRD_GRD_ID" IS NULL OR (
                NEW."SU_GRD_GRD_ID" = OLD."SU_GRD_GRD_ID"
                AND NEW."SU_GRD_GRD_Grade" IS NULL AND OLD."SU_GRD_GRD_Grade" IS NOT NULL
            )
        ) THEN
            INSERT INTO public."SU_GRD_Subject_Grade" (
                "Metadata_SU_GRD",
                "SU_GRD_SU_ID",
                "SU_GRD_GRD_ID",
                "SU_GRD_PositedAt",
                "SU_GRD_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_GRD" IS NOT DISTINCT FROM OLD."Metadata_SU_GRD"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_GRD"
                    END, NEW."Metadata_SU"),
                p."SU_GRD_SU_ID",
                p."SU_GRD_GRD_ID",
                _positing,
                0
            FROM
                public."SU_GRD_Subject_Grade_Posit" p
            WHERE
                p."SU_GRD_ID" = OLD."SU_GRD_ID";
        END IF;
    END IF;
    IF NEW."SU_NOT_ID" IS DISTINCT FROM OLD."SU_NOT_ID" THEN
        RAISE EXCEPTION 'The identity column SU_NOT_ID is not updatable.';
    END IF;
    IF NEW."SU_NOT_SU_ID" IS DISTINCT FROM OLD."SU_NOT_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_NOT_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_NOT_Subject_Note, and when it posits
    _reliability := CASE
        WHEN NEW."SU_NOT_Reliability" IS DISTINCT FROM OLD."SU_NOT_Reliability" THEN NEW."SU_NOT_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_NOT_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_NOT_PositedAt" IS DISTINCT FROM OLD."SU_NOT_PositedAt" THEN NEW."SU_NOT_PositedAt"
        ELSE _now
    END;
    IF NEW."SU_NOT_Subject_Note" IS DISTINCT FROM OLD."SU_NOT_Subject_Note"
    OR NEW."SU_NOT_PositedAt" IS DISTINCT FROM OLD."SU_NOT_PositedAt"
    OR NEW."SU_NOT_Reliability" IS DISTINCT FROM OLD."SU_NOT_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_NOT_Subject_Note" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_NOT_Subject_Note" IS NULL
            OR NEW."SU_NOT_PositedAt" IS DISTINCT FROM OLD."SU_NOT_PositedAt"
            OR OLD."SU_NOT_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR md5(OLD."SU_NOT_Subject_Note"::text) <> md5(NEW."SU_NOT_Subject_Note"::text)
            THEN
                INSERT INTO public."SU_NOT_Subject_Note" (
                    "Metadata_SU_NOT",
                    "SU_NOT_SU_ID",
                    "SU_NOT_Subject_Note",
                    "SU_NOT_PositedAt",
                    "SU_NOT_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_NOT" IS NOT DISTINCT FROM OLD."Metadata_SU_NOT"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_NOT"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_NOT_SU_ID", NEW."SU_ID"),
                    NEW."SU_NOT_Subject_Note",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_NOT_Subject_Note" IS NULL AND OLD."SU_NOT_Subject_Note" IS NOT NULL THEN
            INSERT INTO public."SU_NOT_Subject_Note" (
                "Metadata_SU_NOT",
                "SU_NOT_SU_ID",
                "SU_NOT_Subject_Note",
                "SU_NOT_PositedAt",
                "SU_NOT_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_NOT" IS NOT DISTINCT FROM OLD."Metadata_SU_NOT"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_NOT"
                    END, NEW."Metadata_SU"),
                p."SU_NOT_SU_ID",
                p."SU_NOT_Subject_Note",
                _positing,
                0
            FROM
                public."SU_NOT_Subject_Note_Posit" p
            WHERE
                p."SU_NOT_ID" = OLD."SU_NOT_ID";
        END IF;
    END IF;
    IF NEW."SU_TTL_ID" IS DISTINCT FROM OLD."SU_TTL_ID" THEN
        RAISE EXCEPTION 'The identity column SU_TTL_ID is not updatable.';
    END IF;
    IF NEW."SU_TTL_SU_ID" IS DISTINCT FROM OLD."SU_TTL_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_TTL_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_TTL_Subject_Title, and when it posits
    _reliability := CASE
        WHEN NEW."SU_TTL_Reliability" IS DISTINCT FROM OLD."SU_TTL_Reliability" THEN NEW."SU_TTL_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_TTL_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_TTL_PositedAt" IS DISTINCT FROM OLD."SU_TTL_PositedAt" THEN NEW."SU_TTL_PositedAt"
        WHEN NEW."SU_TTL_ChangedAt" IS DISTINCT FROM OLD."SU_TTL_ChangedAt" AND NEW."SU_TTL_Subject_Title" IS NULL THEN NEW."SU_TTL_ChangedAt"
        ELSE _now
    END;
    IF NEW."SU_TTL_Subject_Title" IS DISTINCT FROM OLD."SU_TTL_Subject_Title"
    OR NEW."SU_TTL_ChangedAt" IS DISTINCT FROM OLD."SU_TTL_ChangedAt"
    OR NEW."SU_TTL_PositedAt" IS DISTINCT FROM OLD."SU_TTL_PositedAt"
    OR NEW."SU_TTL_Reliability" IS DISTINCT FROM OLD."SU_TTL_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_TTL_Subject_Title" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_TTL_Subject_Title" IS NULL
            OR NEW."SU_TTL_ChangedAt" IS DISTINCT FROM OLD."SU_TTL_ChangedAt"
            OR NEW."SU_TTL_PositedAt" IS DISTINCT FROM OLD."SU_TTL_PositedAt"
            OR OLD."SU_TTL_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_TTL_Subject_Title" <> NEW."SU_TTL_Subject_Title"
            THEN
                INSERT INTO public."SU_TTL_Subject_Title" (
                    "Metadata_SU_TTL",
                    "SU_TTL_SU_ID",
                    "SU_TTL_Subject_Title",
                    "SU_TTL_ChangedAt",
                    "SU_TTL_PositedAt",
                    "SU_TTL_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_TTL" IS NOT DISTINCT FROM OLD."Metadata_SU_TTL"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_TTL"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_TTL_SU_ID", NEW."SU_ID"),
                    NEW."SU_TTL_Subject_Title",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_TTL_ChangedAt" IS DISTINCT FROM OLD."SU_TTL_ChangedAt" THEN NEW."SU_TTL_ChangedAt"
                        WHEN OLD."SU_TTL_Subject_Title" = NEW."SU_TTL_Subject_Title" THEN NEW."SU_TTL_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_TTL_Subject_Title" IS NULL AND OLD."SU_TTL_Subject_Title" IS NOT NULL THEN
            INSERT INTO public."SU_TTL_Subject_Title" (
                "Metadata_SU_TTL",
                "SU_TTL_SU_ID",
                "SU_TTL_Subject_Title",
                "SU_TTL_ChangedAt",
                "SU_TTL_PositedAt",
                "SU_TTL_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_TTL" IS NOT DISTINCT FROM OLD."Metadata_SU_TTL"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_TTL"
                    END, NEW."Metadata_SU"),
                p."SU_TTL_SU_ID",
                p."SU_TTL_Subject_Title",
                p."SU_TTL_ChangedAt",
                _positing,
                0
            FROM
                public."SU_TTL_Subject_Title_Posit" p
            WHERE
                p."SU_TTL_ID" = OLD."SU_TTL_ID";
        END IF;
    END IF;
    IF NEW."SU_STA_ID" IS DISTINCT FROM OLD."SU_STA_ID" THEN
        RAISE EXCEPTION 'The identity column SU_STA_ID is not updatable.';
    END IF;
    IF NEW."SU_STA_SU_ID" IS DISTINCT FROM OLD."SU_STA_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_STA_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_STA_Subject_State, and when it posits
    _reliability := CASE
        WHEN NEW."SU_STA_Reliability" IS DISTINCT FROM OLD."SU_STA_Reliability" THEN NEW."SU_STA_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_STA_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_STA_PositedAt" IS DISTINCT FROM OLD."SU_STA_PositedAt" THEN NEW."SU_STA_PositedAt"
        WHEN NEW."SU_STA_ChangedAt" IS DISTINCT FROM OLD."SU_STA_ChangedAt" AND NEW."SU_STA_Subject_State" IS NULL THEN NEW."SU_STA_ChangedAt"
        ELSE _now
    END;
    IF NEW."SU_STA_Subject_State" IS DISTINCT FROM OLD."SU_STA_Subject_State"
    OR NEW."SU_STA_ChangedAt" IS DISTINCT FROM OLD."SU_STA_ChangedAt"
    OR NEW."SU_STA_PositedAt" IS DISTINCT FROM OLD."SU_STA_PositedAt"
    OR NEW."SU_STA_Reliability" IS DISTINCT FROM OLD."SU_STA_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_STA_Subject_State" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_STA_Subject_State" IS NULL
            OR NEW."SU_STA_ChangedAt" IS DISTINCT FROM OLD."SU_STA_ChangedAt"
            OR NEW."SU_STA_PositedAt" IS DISTINCT FROM OLD."SU_STA_PositedAt"
            OR OLD."SU_STA_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_STA_Subject_State" <> NEW."SU_STA_Subject_State"
            THEN
                INSERT INTO public."SU_STA_Subject_State" (
                    "Metadata_SU_STA",
                    "SU_STA_SU_ID",
                    "SU_STA_Subject_State",
                    "SU_STA_ChangedAt",
                    "SU_STA_PositedAt",
                    "SU_STA_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_STA" IS NOT DISTINCT FROM OLD."Metadata_SU_STA"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_STA"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_STA_SU_ID", NEW."SU_ID"),
                    NEW."SU_STA_Subject_State",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_STA_ChangedAt" IS DISTINCT FROM OLD."SU_STA_ChangedAt" THEN NEW."SU_STA_ChangedAt"
                        WHEN OLD."SU_STA_Subject_State" = NEW."SU_STA_Subject_State" THEN NEW."SU_STA_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_STA_Subject_State" IS NULL AND OLD."SU_STA_Subject_State" IS NOT NULL THEN
            INSERT INTO public."SU_STA_Subject_State" (
                "Metadata_SU_STA",
                "SU_STA_SU_ID",
                "SU_STA_Subject_State",
                "SU_STA_ChangedAt",
                "SU_STA_PositedAt",
                "SU_STA_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_STA" IS NOT DISTINCT FROM OLD."Metadata_SU_STA"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_STA"
                    END, NEW."Metadata_SU"),
                p."SU_STA_SU_ID",
                p."SU_STA_Subject_State",
                p."SU_STA_ChangedAt",
                _positing,
                0
            FROM
                public."SU_STA_Subject_State_Posit" p
            WHERE
                p."SU_STA_ID" = OLD."SU_STA_ID";
        END IF;
    END IF;
    IF NEW."SU_LBL_ID" IS DISTINCT FROM OLD."SU_LBL_ID" THEN
        RAISE EXCEPTION 'The identity column SU_LBL_ID is not updatable.';
    END IF;
    IF NEW."SU_LBL_SU_ID" IS DISTINCT FROM OLD."SU_LBL_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_LBL_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_LBL_Subject_Label, and when it posits
    _reliability := CASE
        WHEN NEW."SU_LBL_Reliability" IS DISTINCT FROM OLD."SU_LBL_Reliability" THEN NEW."SU_LBL_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_LBL_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_LBL_PositedAt" IS DISTINCT FROM OLD."SU_LBL_PositedAt" THEN NEW."SU_LBL_PositedAt"
        WHEN NEW."SU_LBL_ChangedAt" IS DISTINCT FROM OLD."SU_LBL_ChangedAt" AND NEW."SU_LBL_Subject_Label" IS NULL THEN NEW."SU_LBL_ChangedAt"
        ELSE _now
    END;
    IF NEW."SU_LBL_Subject_Label" IS DISTINCT FROM OLD."SU_LBL_Subject_Label"
    OR NEW."SU_LBL_ChangedAt" IS DISTINCT FROM OLD."SU_LBL_ChangedAt"
    OR NEW."SU_LBL_PositedAt" IS DISTINCT FROM OLD."SU_LBL_PositedAt"
    OR NEW."SU_LBL_Reliability" IS DISTINCT FROM OLD."SU_LBL_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_LBL_Subject_Label" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_LBL_Subject_Label" IS NULL
            OR NEW."SU_LBL_ChangedAt" IS DISTINCT FROM OLD."SU_LBL_ChangedAt"
            OR NEW."SU_LBL_PositedAt" IS DISTINCT FROM OLD."SU_LBL_PositedAt"
            OR OLD."SU_LBL_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_LBL_Subject_Label" <> NEW."SU_LBL_Subject_Label"
            THEN
                INSERT INTO public."SU_LBL_Subject_Label" (
                    "Metadata_SU_LBL",
                    "SU_LBL_SU_ID",
                    "SU_LBL_Subject_Label",
                    "SU_LBL_ChangedAt",
                    "SU_LBL_PositedAt",
                    "SU_LBL_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_LBL" IS NOT DISTINCT FROM OLD."Metadata_SU_LBL"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_LBL"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_LBL_SU_ID", NEW."SU_ID"),
                    NEW."SU_LBL_Subject_Label",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_LBL_ChangedAt" IS DISTINCT FROM OLD."SU_LBL_ChangedAt" THEN NEW."SU_LBL_ChangedAt"
                        WHEN OLD."SU_LBL_Subject_Label" = NEW."SU_LBL_Subject_Label" THEN NEW."SU_LBL_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_LBL_Subject_Label" IS NULL AND OLD."SU_LBL_Subject_Label" IS NOT NULL THEN
            INSERT INTO public."SU_LBL_Subject_Label" (
                "Metadata_SU_LBL",
                "SU_LBL_SU_ID",
                "SU_LBL_Subject_Label",
                "SU_LBL_ChangedAt",
                "SU_LBL_PositedAt",
                "SU_LBL_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_LBL" IS NOT DISTINCT FROM OLD."Metadata_SU_LBL"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_LBL"
                    END, NEW."Metadata_SU"),
                p."SU_LBL_SU_ID",
                p."SU_LBL_Subject_Label",
                p."SU_LBL_ChangedAt",
                _positing,
                0
            FROM
                public."SU_LBL_Subject_Label_Posit" p
            WHERE
                p."SU_LBL_ID" = OLD."SU_LBL_ID";
        END IF;
    END IF;
    IF NEW."SU_TAG_ID" IS DISTINCT FROM OLD."SU_TAG_ID" THEN
        RAISE EXCEPTION 'The identity column SU_TAG_ID is not updatable.';
    END IF;
    IF NEW."SU_TAG_SU_ID" IS DISTINCT FROM OLD."SU_TAG_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_TAG_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_TAG_Subject_Tag, and when it posits
    _reliability := CASE
        WHEN NEW."SU_TAG_Reliability" IS DISTINCT FROM OLD."SU_TAG_Reliability" THEN NEW."SU_TAG_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_TAG_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_TAG_PositedAt" IS DISTINCT FROM OLD."SU_TAG_PositedAt" THEN NEW."SU_TAG_PositedAt"
        WHEN NEW."SU_TAG_ChangedAt" IS DISTINCT FROM OLD."SU_TAG_ChangedAt" AND NEW."SU_TAG_Subject_Tag" IS NULL THEN NEW."SU_TAG_ChangedAt"
        ELSE _now
    END;
    IF NEW."SU_TAG_Subject_Tag" IS DISTINCT FROM OLD."SU_TAG_Subject_Tag"
    OR NEW."SU_TAG_ChangedAt" IS DISTINCT FROM OLD."SU_TAG_ChangedAt"
    OR NEW."SU_TAG_PositedAt" IS DISTINCT FROM OLD."SU_TAG_PositedAt"
    OR NEW."SU_TAG_Reliability" IS DISTINCT FROM OLD."SU_TAG_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_TAG_Subject_Tag" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_TAG_Subject_Tag" IS NULL
            OR NEW."SU_TAG_ChangedAt" IS DISTINCT FROM OLD."SU_TAG_ChangedAt"
            OR NEW."SU_TAG_PositedAt" IS DISTINCT FROM OLD."SU_TAG_PositedAt"
            OR OLD."SU_TAG_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_TAG_Subject_Tag" <> NEW."SU_TAG_Subject_Tag"
            THEN
                INSERT INTO public."SU_TAG_Subject_Tag" (
                    "Metadata_SU_TAG",
                    "SU_TAG_SU_ID",
                    "SU_TAG_Subject_Tag",
                    "SU_TAG_ChangedAt",
                    "SU_TAG_PositedAt",
                    "SU_TAG_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_TAG" IS NOT DISTINCT FROM OLD."Metadata_SU_TAG"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_TAG"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_TAG_SU_ID", NEW."SU_ID"),
                    NEW."SU_TAG_Subject_Tag",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_TAG_ChangedAt" IS DISTINCT FROM OLD."SU_TAG_ChangedAt" THEN NEW."SU_TAG_ChangedAt"
                        WHEN OLD."SU_TAG_Subject_Tag" = NEW."SU_TAG_Subject_Tag" THEN NEW."SU_TAG_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_TAG_Subject_Tag" IS NULL AND OLD."SU_TAG_Subject_Tag" IS NOT NULL THEN
            INSERT INTO public."SU_TAG_Subject_Tag" (
                "Metadata_SU_TAG",
                "SU_TAG_SU_ID",
                "SU_TAG_Subject_Tag",
                "SU_TAG_ChangedAt",
                "SU_TAG_PositedAt",
                "SU_TAG_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_TAG" IS NOT DISTINCT FROM OLD."Metadata_SU_TAG"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_TAG"
                    END, NEW."Metadata_SU"),
                p."SU_TAG_SU_ID",
                p."SU_TAG_Subject_Tag",
                p."SU_TAG_ChangedAt",
                _positing,
                0
            FROM
                public."SU_TAG_Subject_Tag_Posit" p
            WHERE
                p."SU_TAG_ID" = OLD."SU_TAG_ID";
        END IF;
    END IF;
    IF NEW."SU_LVL_ID" IS DISTINCT FROM OLD."SU_LVL_ID" THEN
        RAISE EXCEPTION 'The identity column SU_LVL_ID is not updatable.';
    END IF;
    IF NEW."SU_LVL_SU_ID" IS DISTINCT FROM OLD."SU_LVL_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_LVL_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_LVL_Subject_Level, and when it posits
    _reliability := CASE
        WHEN NEW."SU_LVL_Reliability" IS DISTINCT FROM OLD."SU_LVL_Reliability" THEN NEW."SU_LVL_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_LVL_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_LVL_PositedAt" IS DISTINCT FROM OLD."SU_LVL_PositedAt" THEN NEW."SU_LVL_PositedAt"
        WHEN NEW."SU_LVL_ChangedAt" IS DISTINCT FROM OLD."SU_LVL_ChangedAt" AND NEW."SU_LVL_GRD_ID" IS NULL THEN NEW."SU_LVL_ChangedAt"
        ELSE _now
    END;
    _LVL := NEW."SU_LVL_GRD_ID";
    IF _LVL IS NOT DISTINCT FROM OLD."SU_LVL_GRD_ID" AND NEW."SU_LVL_GRD_Grade" IS DISTINCT FROM OLD."SU_LVL_GRD_Grade" THEN
        _LVL := NULL;
        IF NEW."SU_LVL_GRD_Grade" IS NOT NULL THEN
            SELECT
                k."GRD_ID"
            INTO
                _LVL
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."SU_LVL_GRD_Grade"
            LIMIT 1;
        END IF;
    END IF;
    IF NEW."SU_LVL_GRD_ID" IS DISTINCT FROM OLD."SU_LVL_GRD_ID"
    OR NEW."SU_LVL_GRD_Grade" IS DISTINCT FROM OLD."SU_LVL_GRD_Grade"
    OR NEW."SU_LVL_ChangedAt" IS DISTINCT FROM OLD."SU_LVL_ChangedAt"
    OR NEW."SU_LVL_PositedAt" IS DISTINCT FROM OLD."SU_LVL_PositedAt"
    OR NEW."SU_LVL_Reliability" IS DISTINCT FROM OLD."SU_LVL_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF _LVL IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_LVL_GRD_ID" IS NULL
            OR NEW."SU_LVL_ChangedAt" IS DISTINCT FROM OLD."SU_LVL_ChangedAt"
            OR NEW."SU_LVL_PositedAt" IS DISTINCT FROM OLD."SU_LVL_PositedAt"
            OR OLD."SU_LVL_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_LVL_GRD_ID" <> _LVL
            THEN
                INSERT INTO public."SU_LVL_Subject_Level" (
                    "Metadata_SU_LVL",
                    "SU_LVL_SU_ID",
                    "SU_LVL_GRD_ID",
                    "SU_LVL_ChangedAt",
                    "SU_LVL_PositedAt",
                    "SU_LVL_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_LVL" IS NOT DISTINCT FROM OLD."Metadata_SU_LVL"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_LVL"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_LVL_SU_ID", NEW."SU_ID"),
                    _LVL,
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_LVL_ChangedAt" IS DISTINCT FROM OLD."SU_LVL_ChangedAt" THEN NEW."SU_LVL_ChangedAt"
                        WHEN OLD."SU_LVL_GRD_ID" = _LVL THEN NEW."SU_LVL_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."SU_LVL_GRD_ID" IS NOT NULL AND (
            NEW."SU_LVL_GRD_ID" IS NULL OR (
                NEW."SU_LVL_GRD_ID" = OLD."SU_LVL_GRD_ID"
                AND NEW."SU_LVL_GRD_Grade" IS NULL AND OLD."SU_LVL_GRD_Grade" IS NOT NULL
            )
        ) THEN
            INSERT INTO public."SU_LVL_Subject_Level" (
                "Metadata_SU_LVL",
                "SU_LVL_SU_ID",
                "SU_LVL_GRD_ID",
                "SU_LVL_ChangedAt",
                "SU_LVL_PositedAt",
                "SU_LVL_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_LVL" IS NOT DISTINCT FROM OLD."Metadata_SU_LVL"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_LVL"
                    END, NEW."Metadata_SU"),
                p."SU_LVL_SU_ID",
                p."SU_LVL_GRD_ID",
                p."SU_LVL_ChangedAt",
                _positing,
                0
            FROM
                public."SU_LVL_Subject_Level_Posit" p
            WHERE
                p."SU_LVL_ID" = OLD."SU_LVL_ID";
        END IF;
    END IF;
    IF NEW."SU_TXT_ID" IS DISTINCT FROM OLD."SU_TXT_ID" THEN
        RAISE EXCEPTION 'The identity column SU_TXT_ID is not updatable.';
    END IF;
    IF NEW."SU_TXT_SU_ID" IS DISTINCT FROM OLD."SU_TXT_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_TXT_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_TXT_Subject_Text, and when it posits
    _reliability := CASE
        WHEN NEW."SU_TXT_Reliability" IS DISTINCT FROM OLD."SU_TXT_Reliability" THEN NEW."SU_TXT_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_TXT_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_TXT_PositedAt" IS DISTINCT FROM OLD."SU_TXT_PositedAt" THEN NEW."SU_TXT_PositedAt"
        WHEN NEW."SU_TXT_ChangedAt" IS DISTINCT FROM OLD."SU_TXT_ChangedAt" AND NEW."SU_TXT_Subject_Text" IS NULL THEN NEW."SU_TXT_ChangedAt"
        ELSE _now
    END;
    IF NEW."SU_TXT_Subject_Text" IS DISTINCT FROM OLD."SU_TXT_Subject_Text"
    OR NEW."SU_TXT_ChangedAt" IS DISTINCT FROM OLD."SU_TXT_ChangedAt"
    OR NEW."SU_TXT_PositedAt" IS DISTINCT FROM OLD."SU_TXT_PositedAt"
    OR NEW."SU_TXT_Reliability" IS DISTINCT FROM OLD."SU_TXT_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_TXT_Subject_Text" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_TXT_Subject_Text" IS NULL
            OR NEW."SU_TXT_ChangedAt" IS DISTINCT FROM OLD."SU_TXT_ChangedAt"
            OR NEW."SU_TXT_PositedAt" IS DISTINCT FROM OLD."SU_TXT_PositedAt"
            OR OLD."SU_TXT_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR md5(OLD."SU_TXT_Subject_Text"::text) <> md5(NEW."SU_TXT_Subject_Text"::text)
            THEN
                INSERT INTO public."SU_TXT_Subject_Text" (
                    "Metadata_SU_TXT",
                    "SU_TXT_SU_ID",
                    "SU_TXT_Subject_Text",
                    "SU_TXT_ChangedAt",
                    "SU_TXT_PositedAt",
                    "SU_TXT_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_TXT" IS NOT DISTINCT FROM OLD."Metadata_SU_TXT"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_TXT"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_TXT_SU_ID", NEW."SU_ID"),
                    NEW."SU_TXT_Subject_Text",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_TXT_ChangedAt" IS DISTINCT FROM OLD."SU_TXT_ChangedAt" THEN NEW."SU_TXT_ChangedAt"
                        WHEN md5(OLD."SU_TXT_Subject_Text"::text) = md5(NEW."SU_TXT_Subject_Text"::text) THEN NEW."SU_TXT_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_TXT_Subject_Text" IS NULL AND OLD."SU_TXT_Subject_Text" IS NOT NULL THEN
            INSERT INTO public."SU_TXT_Subject_Text" (
                "Metadata_SU_TXT",
                "SU_TXT_SU_ID",
                "SU_TXT_Subject_Text",
                "SU_TXT_ChangedAt",
                "SU_TXT_PositedAt",
                "SU_TXT_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_TXT" IS NOT DISTINCT FROM OLD."Metadata_SU_TXT"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_TXT"
                    END, NEW."Metadata_SU"),
                p."SU_TXT_SU_ID",
                p."SU_TXT_Subject_Text",
                p."SU_TXT_ChangedAt",
                _positing,
                0
            FROM
                public."SU_TXT_Subject_Text_Posit" p
            WHERE
                p."SU_TXT_ID" = OLD."SU_TXT_ID";
        END IF;
    END IF;
    IF NEW."SU_ASR_ID" IS DISTINCT FROM OLD."SU_ASR_ID" THEN
        RAISE EXCEPTION 'The identity column SU_ASR_ID is not updatable.';
    END IF;
    IF NEW."SU_ASR_SU_ID" IS DISTINCT FROM OLD."SU_ASR_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_ASR_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_ASR_Subject_Assessment, and when it posits
    _reliability := CASE
        WHEN NEW."SU_ASR_Reliability" IS DISTINCT FROM OLD."SU_ASR_Reliability" THEN NEW."SU_ASR_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_ASR_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_ASR_PositedAt" IS DISTINCT FROM OLD."SU_ASR_PositedAt" THEN NEW."SU_ASR_PositedAt"
        WHEN NEW."SU_ASR_ChangedAt" IS DISTINCT FROM OLD."SU_ASR_ChangedAt" AND NEW."SU_ASR_Subject_Assessment" IS NULL THEN NEW."SU_ASR_ChangedAt"
        ELSE _now
    END;
    IF NEW."SU_ASR_Subject_Assessment" IS DISTINCT FROM OLD."SU_ASR_Subject_Assessment"
    OR NEW."SU_ASR_ChangedAt" IS DISTINCT FROM OLD."SU_ASR_ChangedAt"
    OR NEW."SU_ASR_PositedAt" IS DISTINCT FROM OLD."SU_ASR_PositedAt"
    OR NEW."SU_ASR_Reliability" IS DISTINCT FROM OLD."SU_ASR_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_ASR_Subject_Assessment" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_ASR_Subject_Assessment" IS NULL
            OR NEW."SU_ASR_ChangedAt" IS DISTINCT FROM OLD."SU_ASR_ChangedAt"
            OR NEW."SU_ASR_PositedAt" IS DISTINCT FROM OLD."SU_ASR_PositedAt"
            OR OLD."SU_ASR_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_ASR_Subject_Assessment" <> NEW."SU_ASR_Subject_Assessment"
            THEN
                INSERT INTO public."SU_ASR_Subject_Assessment" (
                    "Metadata_SU_ASR",
                    "SU_ASR_SU_ID",
                    "SU_ASR_Subject_Assessment",
                    "SU_ASR_ChangedAt",
                    "SU_ASR_PositedAt",
                    "SU_ASR_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_ASR" IS NOT DISTINCT FROM OLD."Metadata_SU_ASR"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_ASR"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_ASR_SU_ID", NEW."SU_ID"),
                    NEW."SU_ASR_Subject_Assessment",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_ASR_ChangedAt" IS DISTINCT FROM OLD."SU_ASR_ChangedAt" THEN NEW."SU_ASR_ChangedAt"
                        WHEN OLD."SU_ASR_Subject_Assessment" = NEW."SU_ASR_Subject_Assessment" THEN NEW."SU_ASR_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_ASR_Subject_Assessment" IS NULL AND OLD."SU_ASR_Subject_Assessment" IS NOT NULL THEN
            INSERT INTO public."SU_ASR_Subject_Assessment" (
                "Metadata_SU_ASR",
                "SU_ASR_SU_ID",
                "SU_ASR_Subject_Assessment",
                "SU_ASR_ChangedAt",
                "SU_ASR_PositedAt",
                "SU_ASR_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_ASR" IS NOT DISTINCT FROM OLD."Metadata_SU_ASR"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_ASR"
                    END, NEW."Metadata_SU"),
                p."SU_ASR_SU_ID",
                p."SU_ASR_Subject_Assessment",
                p."SU_ASR_ChangedAt",
                _positing,
                0
            FROM
                public."SU_ASR_Subject_Assessment_Posit" p
            WHERE
                p."SU_ASR_ID" = OLD."SU_ASR_ID";
        END IF;
    END IF;
    IF NEW."SU_ERS_ID" IS DISTINCT FROM OLD."SU_ERS_ID" THEN
        RAISE EXCEPTION 'The identity column SU_ERS_ID is not updatable.';
    END IF;
    IF NEW."SU_ERS_SU_ID" IS DISTINCT FROM OLD."SU_ERS_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_ERS_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_ERS_Subject_Erasable, and when it posits
    _reliability := CASE
        WHEN NEW."SU_ERS_Reliability" IS DISTINCT FROM OLD."SU_ERS_Reliability" THEN NEW."SU_ERS_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_ERS_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_ERS_PositedAt" IS DISTINCT FROM OLD."SU_ERS_PositedAt" THEN NEW."SU_ERS_PositedAt"
        WHEN NEW."SU_ERS_ChangedAt" IS DISTINCT FROM OLD."SU_ERS_ChangedAt" AND NEW."SU_ERS_Subject_Erasable" IS NULL THEN NEW."SU_ERS_ChangedAt"
        ELSE _now
    END;
    IF NEW."SU_ERS_Subject_Erasable" IS DISTINCT FROM OLD."SU_ERS_Subject_Erasable"
    OR NEW."SU_ERS_ChangedAt" IS DISTINCT FROM OLD."SU_ERS_ChangedAt"
    OR NEW."SU_ERS_PositedAt" IS DISTINCT FROM OLD."SU_ERS_PositedAt"
    OR NEW."SU_ERS_Reliability" IS DISTINCT FROM OLD."SU_ERS_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_ERS_Subject_Erasable" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_ERS_Subject_Erasable" IS NULL
            OR NEW."SU_ERS_ChangedAt" IS DISTINCT FROM OLD."SU_ERS_ChangedAt"
            OR NEW."SU_ERS_PositedAt" IS DISTINCT FROM OLD."SU_ERS_PositedAt"
            OR OLD."SU_ERS_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_ERS_Subject_Erasable" <> NEW."SU_ERS_Subject_Erasable"
            THEN
                INSERT INTO public."SU_ERS_Subject_Erasable" (
                    "Metadata_SU_ERS",
                    "SU_ERS_SU_ID",
                    "SU_ERS_Subject_Erasable",
                    "SU_ERS_ChangedAt",
                    "SU_ERS_PositedAt",
                    "SU_ERS_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_ERS" IS NOT DISTINCT FROM OLD."Metadata_SU_ERS"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_ERS"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_ERS_SU_ID", NEW."SU_ID"),
                    NEW."SU_ERS_Subject_Erasable",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_ERS_ChangedAt" IS DISTINCT FROM OLD."SU_ERS_ChangedAt" THEN NEW."SU_ERS_ChangedAt"
                        WHEN OLD."SU_ERS_Subject_Erasable" = NEW."SU_ERS_Subject_Erasable" THEN NEW."SU_ERS_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_ERS_Subject_Erasable" IS NULL AND OLD."SU_ERS_Subject_Erasable" IS NOT NULL THEN
            INSERT INTO public."SU_ERS_Subject_Erasable" (
                "Metadata_SU_ERS",
                "SU_ERS_SU_ID",
                "SU_ERS_Subject_Erasable",
                "SU_ERS_ChangedAt",
                "SU_ERS_PositedAt",
                "SU_ERS_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_ERS" IS NOT DISTINCT FROM OLD."Metadata_SU_ERS"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_ERS"
                    END, NEW."Metadata_SU"),
                p."SU_ERS_SU_ID",
                p."SU_ERS_Subject_Erasable",
                p."SU_ERS_ChangedAt",
                _positing,
                0
            FROM
                public."SU_ERS_Subject_Erasable_Posit" p
            WHERE
                p."SU_ERS_ID" = OLD."SU_ERS_ID";
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lSU_Subject" ON public."lSU_Subject";
CREATE TRIGGER "ut_lSU_Subject"
INSTEAD OF UPDATE ON public."lSU_Subject"
FOR EACH ROW EXECUTE FUNCTION public."ut_lSU_Subject"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_Subject instead of DELETE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lSU_Subject"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown of SU_NAM_Subject_Name is retracted
    INSERT INTO public."SU_NAM_Subject_Name_Annex" (
        "Metadata_SU_NAM",
        "SU_NAM_ID",
        "SU_NAM_PositedAt",
        "SU_NAM_Reliability"
    )
    SELECT
        OLD."Metadata_SU_NAM",
        OLD."SU_NAM_ID",
        _now,
        0
    WHERE
        OLD."SU_NAM_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_COD_Subject_Code is retracted
    INSERT INTO public."SU_COD_Subject_Code_Annex" (
        "Metadata_SU_COD",
        "SU_COD_ID",
        "SU_COD_PositedAt",
        "SU_COD_Reliability"
    )
    SELECT
        OLD."Metadata_SU_COD",
        OLD."SU_COD_ID",
        _now,
        0
    WHERE
        OLD."SU_COD_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_GRD_Subject_Grade is retracted
    INSERT INTO public."SU_GRD_Subject_Grade_Annex" (
        "Metadata_SU_GRD",
        "SU_GRD_ID",
        "SU_GRD_PositedAt",
        "SU_GRD_Reliability"
    )
    SELECT
        OLD."Metadata_SU_GRD",
        OLD."SU_GRD_ID",
        _now,
        0
    WHERE
        OLD."SU_GRD_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_NOT_Subject_Note is retracted
    INSERT INTO public."SU_NOT_Subject_Note_Annex" (
        "Metadata_SU_NOT",
        "SU_NOT_ID",
        "SU_NOT_PositedAt",
        "SU_NOT_Reliability"
    )
    SELECT
        OLD."Metadata_SU_NOT",
        OLD."SU_NOT_ID",
        _now,
        0
    WHERE
        OLD."SU_NOT_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_TTL_Subject_Title is retracted
    INSERT INTO public."SU_TTL_Subject_Title_Annex" (
        "Metadata_SU_TTL",
        "SU_TTL_ID",
        "SU_TTL_PositedAt",
        "SU_TTL_Reliability"
    )
    SELECT
        OLD."Metadata_SU_TTL",
        OLD."SU_TTL_ID",
        _now,
        0
    WHERE
        OLD."SU_TTL_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_STA_Subject_State is retracted
    INSERT INTO public."SU_STA_Subject_State_Annex" (
        "Metadata_SU_STA",
        "SU_STA_ID",
        "SU_STA_PositedAt",
        "SU_STA_Reliability"
    )
    SELECT
        OLD."Metadata_SU_STA",
        OLD."SU_STA_ID",
        _now,
        0
    WHERE
        OLD."SU_STA_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_LBL_Subject_Label is retracted
    INSERT INTO public."SU_LBL_Subject_Label_Annex" (
        "Metadata_SU_LBL",
        "SU_LBL_ID",
        "SU_LBL_PositedAt",
        "SU_LBL_Reliability"
    )
    SELECT
        OLD."Metadata_SU_LBL",
        OLD."SU_LBL_ID",
        _now,
        0
    WHERE
        OLD."SU_LBL_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_TAG_Subject_Tag is retracted
    INSERT INTO public."SU_TAG_Subject_Tag_Annex" (
        "Metadata_SU_TAG",
        "SU_TAG_ID",
        "SU_TAG_PositedAt",
        "SU_TAG_Reliability"
    )
    SELECT
        OLD."Metadata_SU_TAG",
        OLD."SU_TAG_ID",
        _now,
        0
    WHERE
        OLD."SU_TAG_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_LVL_Subject_Level is retracted
    INSERT INTO public."SU_LVL_Subject_Level_Annex" (
        "Metadata_SU_LVL",
        "SU_LVL_ID",
        "SU_LVL_PositedAt",
        "SU_LVL_Reliability"
    )
    SELECT
        OLD."Metadata_SU_LVL",
        OLD."SU_LVL_ID",
        _now,
        0
    WHERE
        OLD."SU_LVL_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_TXT_Subject_Text is retracted
    INSERT INTO public."SU_TXT_Subject_Text_Annex" (
        "Metadata_SU_TXT",
        "SU_TXT_ID",
        "SU_TXT_PositedAt",
        "SU_TXT_Reliability"
    )
    SELECT
        OLD."Metadata_SU_TXT",
        OLD."SU_TXT_ID",
        _now,
        0
    WHERE
        OLD."SU_TXT_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_ASR_Subject_Assessment is retracted
    INSERT INTO public."SU_ASR_Subject_Assessment_Annex" (
        "Metadata_SU_ASR",
        "SU_ASR_ID",
        "SU_ASR_PositedAt",
        "SU_ASR_Reliability"
    )
    SELECT
        OLD."Metadata_SU_ASR",
        OLD."SU_ASR_ID",
        _now,
        0
    WHERE
        OLD."SU_ASR_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_ERS_Subject_Erasable is retracted
    INSERT INTO public."SU_ERS_Subject_Erasable_Annex" (
        "Metadata_SU_ERS",
        "SU_ERS_ID",
        "SU_ERS_PositedAt",
        "SU_ERS_Reliability"
    )
    SELECT
        OLD."Metadata_SU_ERS",
        OLD."SU_ERS_ID",
        _now,
        0
    WHERE
        OLD."SU_ERS_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lSU_Subject" ON public."lSU_Subject";
CREATE TRIGGER "dt_lSU_Subject"
INSTEAD OF DELETE ON public."lSU_Subject"
FOR EACH ROW EXECUTE FUNCTION public."dt_lSU_Subject"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_Object instead of INSERT trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lOB_Object"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id integer;
BEGIN
    _id := NEW."OB_ID";
    IF _id IS NULL THEN
        INSERT INTO public."OB_Object" (
            "Metadata_OB"
        )
        VALUES (
            NEW."Metadata_OB"
        )
        RETURNING "OB_ID" INTO _id;
    END IF;
    IF NEW."OB_NAM_Object_Name" IS NOT NULL THEN
        INSERT INTO public."OB_NAM_Object_Name" (
            "Metadata_OB_NAM",
            "OB_NAM_OB_ID",
            "OB_NAM_Object_Name",
            "OB_NAM_PositedAt",
            "OB_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_OB_NAM", NEW."Metadata_OB"),
            coalesce(NEW."OB_NAM_OB_ID", _id),
            NEW."OB_NAM_Object_Name",
            coalesce(NEW."OB_NAM_PositedAt", _now),
            coalesce(NEW."OB_NAM_Reliability", NEW."Reliability", 1)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lOB_Object" ON public."lOB_Object";
CREATE TRIGGER "it_lOB_Object"
INSTEAD OF INSERT ON public."lOB_Object"
FOR EACH ROW EXECUTE FUNCTION public."it_lOB_Object"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOB_Object instead of UPDATE trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lOB_Object"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _reliability decimal(5,2);
    _positing timestamp;
BEGIN
    IF NEW."OB_ID" IS DISTINCT FROM OLD."OB_ID" THEN
        RAISE EXCEPTION 'The identity column OB_ID is not updatable.';
    END IF;
    IF NEW."OB_NAM_ID" IS DISTINCT FROM OLD."OB_NAM_ID" THEN
        RAISE EXCEPTION 'The identity column OB_NAM_ID is not updatable.';
    END IF;
    IF NEW."OB_NAM_OB_ID" IS DISTINCT FROM OLD."OB_NAM_OB_ID" THEN
        RAISE EXCEPTION 'The foreign key column OB_NAM_OB_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of OB_NAM_Object_Name, and when it posits
    _reliability := CASE
        WHEN NEW."OB_NAM_Reliability" IS DISTINCT FROM OLD."OB_NAM_Reliability" THEN NEW."OB_NAM_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."OB_NAM_Reliability"
    END;
    _positing := CASE
        WHEN NEW."OB_NAM_PositedAt" IS DISTINCT FROM OLD."OB_NAM_PositedAt" THEN NEW."OB_NAM_PositedAt"
        ELSE _now
    END;
    IF NEW."OB_NAM_Object_Name" IS DISTINCT FROM OLD."OB_NAM_Object_Name"
    OR NEW."OB_NAM_PositedAt" IS DISTINCT FROM OLD."OB_NAM_PositedAt"
    OR NEW."OB_NAM_Reliability" IS DISTINCT FROM OLD."OB_NAM_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."OB_NAM_Object_Name" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."OB_NAM_Object_Name" IS NULL
            OR NEW."OB_NAM_PositedAt" IS DISTINCT FROM OLD."OB_NAM_PositedAt"
            OR OLD."OB_NAM_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."OB_NAM_Object_Name" <> NEW."OB_NAM_Object_Name"
            THEN
                INSERT INTO public."OB_NAM_Object_Name" (
                    "Metadata_OB_NAM",
                    "OB_NAM_OB_ID",
                    "OB_NAM_Object_Name",
                    "OB_NAM_PositedAt",
                    "OB_NAM_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_OB" IS DISTINCT FROM OLD."Metadata_OB"
                             AND NEW."Metadata_OB_NAM" IS NOT DISTINCT FROM OLD."Metadata_OB_NAM"
                            THEN NEW."Metadata_OB"
                            ELSE NEW."Metadata_OB_NAM"
                        END, NEW."Metadata_OB"),
                    coalesce(NEW."OB_NAM_OB_ID", NEW."OB_ID"),
                    NEW."OB_NAM_Object_Name",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."OB_NAM_Object_Name" IS NULL AND OLD."OB_NAM_Object_Name" IS NOT NULL THEN
            INSERT INTO public."OB_NAM_Object_Name" (
                "Metadata_OB_NAM",
                "OB_NAM_OB_ID",
                "OB_NAM_Object_Name",
                "OB_NAM_PositedAt",
                "OB_NAM_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_OB" IS DISTINCT FROM OLD."Metadata_OB"
                         AND NEW."Metadata_OB_NAM" IS NOT DISTINCT FROM OLD."Metadata_OB_NAM"
                        THEN NEW."Metadata_OB"
                        ELSE NEW."Metadata_OB_NAM"
                    END, NEW."Metadata_OB"),
                p."OB_NAM_OB_ID",
                p."OB_NAM_Object_Name",
                _positing,
                0
            FROM
                public."OB_NAM_Object_Name_Posit" p
            WHERE
                p."OB_NAM_ID" = OLD."OB_NAM_ID";
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lOB_Object" ON public."lOB_Object";
CREATE TRIGGER "ut_lOB_Object"
INSTEAD OF UPDATE ON public."lOB_Object"
FOR EACH ROW EXECUTE FUNCTION public."ut_lOB_Object"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_Object instead of DELETE trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lOB_Object"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown of OB_NAM_Object_Name is retracted
    INSERT INTO public."OB_NAM_Object_Name_Annex" (
        "Metadata_OB_NAM",
        "OB_NAM_ID",
        "OB_NAM_PositedAt",
        "OB_NAM_Reliability"
    )
    SELECT
        OLD."Metadata_OB_NAM",
        OLD."OB_NAM_ID",
        _now,
        0
    WHERE
        OLD."OB_NAM_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lOB_Object" ON public."lOB_Object";
CREATE TRIGGER "dt_lOB_Object"
INSTEAD OF DELETE ON public."lOB_Object"
FOR EACH ROW EXECUTE FUNCTION public."dt_lOB_Object"();
