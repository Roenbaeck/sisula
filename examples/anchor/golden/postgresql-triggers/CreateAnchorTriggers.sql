-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
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
            "SU_NAM_Subject_Name"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NAM", NEW."Metadata_SU"),
            coalesce(NEW."SU_NAM_SU_ID", _id),
            NEW."SU_NAM_Subject_Name"
        );
    END IF;
    IF NEW."SU_COD_Subject_Code" IS NOT NULL THEN
        INSERT INTO public."SU_COD_Subject_Code" (
            "Metadata_SU_COD",
            "SU_COD_SU_ID",
            "SU_COD_Subject_Code"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_COD", NEW."Metadata_SU"),
            coalesce(NEW."SU_COD_SU_ID", _id),
            NEW."SU_COD_Subject_Code"
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
            "SU_GRD_GRD_ID"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_GRD", NEW."Metadata_SU"),
            coalesce(NEW."SU_GRD_SU_ID", _id),
            _GRD
        );
    END IF;
    IF NEW."SU_NOT_Subject_Note" IS NOT NULL THEN
        INSERT INTO public."SU_NOT_Subject_Note" (
            "Metadata_SU_NOT",
            "SU_NOT_SU_ID",
            "SU_NOT_Subject_Note"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NOT", NEW."Metadata_SU"),
            coalesce(NEW."SU_NOT_SU_ID", _id),
            NEW."SU_NOT_Subject_Note"
        );
    END IF;
    IF NEW."SU_TTL_Subject_Title" IS NOT NULL THEN
        INSERT INTO public."SU_TTL_Subject_Title" (
            "Metadata_SU_TTL",
            "SU_TTL_SU_ID",
            "SU_TTL_ChangedAt",
            "SU_TTL_Subject_Title"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TTL", NEW."Metadata_SU"),
            coalesce(NEW."SU_TTL_SU_ID", _id),
            coalesce(NEW."SU_TTL_ChangedAt", _now),
            NEW."SU_TTL_Subject_Title"
        );
    END IF;
    IF NEW."SU_STA_Subject_State" IS NOT NULL THEN
        INSERT INTO public."SU_STA_Subject_State" (
            "Metadata_SU_STA",
            "SU_STA_SU_ID",
            "SU_STA_ChangedAt",
            "SU_STA_Subject_State"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_STA", NEW."Metadata_SU"),
            coalesce(NEW."SU_STA_SU_ID", _id),
            coalesce(NEW."SU_STA_ChangedAt", _now),
            NEW."SU_STA_Subject_State"
        );
    END IF;
    IF NEW."SU_LBL_Subject_Label" IS NOT NULL THEN
        INSERT INTO public."SU_LBL_Subject_Label" (
            "Metadata_SU_LBL",
            "SU_LBL_SU_ID",
            "SU_LBL_ChangedAt",
            "SU_LBL_Subject_Label"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LBL", NEW."Metadata_SU"),
            coalesce(NEW."SU_LBL_SU_ID", _id),
            coalesce(NEW."SU_LBL_ChangedAt", _now),
            NEW."SU_LBL_Subject_Label"
        );
    END IF;
    IF NEW."SU_TAG_Subject_Tag" IS NOT NULL THEN
        INSERT INTO public."SU_TAG_Subject_Tag" (
            "Metadata_SU_TAG",
            "SU_TAG_SU_ID",
            "SU_TAG_ChangedAt",
            "SU_TAG_Subject_Tag"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TAG", NEW."Metadata_SU"),
            coalesce(NEW."SU_TAG_SU_ID", _id),
            coalesce(NEW."SU_TAG_ChangedAt", _now),
            NEW."SU_TAG_Subject_Tag"
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
            "SU_LVL_ChangedAt",
            "SU_LVL_GRD_ID"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LVL", NEW."Metadata_SU"),
            coalesce(NEW."SU_LVL_SU_ID", _id),
            coalesce(NEW."SU_LVL_ChangedAt", _now),
            _LVL
        );
    END IF;
    IF NEW."SU_TXT_Subject_Text" IS NOT NULL THEN
        INSERT INTO public."SU_TXT_Subject_Text" (
            "Metadata_SU_TXT",
            "SU_TXT_SU_ID",
            "SU_TXT_ChangedAt",
            "SU_TXT_Subject_Text"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TXT", NEW."Metadata_SU"),
            coalesce(NEW."SU_TXT_SU_ID", _id),
            coalesce(NEW."SU_TXT_ChangedAt", _now),
            NEW."SU_TXT_Subject_Text"
        );
    END IF;
    IF NEW."SU_ASR_Subject_Assessment" IS NOT NULL THEN
        INSERT INTO public."SU_ASR_Subject_Assessment" (
            "Metadata_SU_ASR",
            "SU_ASR_SU_ID",
            "SU_ASR_ChangedAt",
            "SU_ASR_Subject_Assessment"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ASR", NEW."Metadata_SU"),
            coalesce(NEW."SU_ASR_SU_ID", _id),
            coalesce(NEW."SU_ASR_ChangedAt", _now),
            NEW."SU_ASR_Subject_Assessment"
        );
    END IF;
    IF NEW."SU_ERS_Subject_Erasable" IS NOT NULL THEN
        INSERT INTO public."SU_ERS_Subject_Erasable" (
            "Metadata_SU_ERS",
            "SU_ERS_SU_ID",
            "SU_ERS_ChangedAt",
            "SU_ERS_Subject_Erasable"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ERS", NEW."Metadata_SU"),
            coalesce(NEW."SU_ERS_SU_ID", _id),
            coalesce(NEW."SU_ERS_ChangedAt", _now),
            NEW."SU_ERS_Subject_Erasable"
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
    _GRD smallint;
    _LVL smallint;
BEGIN
    IF NEW."SU_ID" IS DISTINCT FROM OLD."SU_ID" THEN
        RAISE EXCEPTION 'The identity column SU_ID is not updatable.';
    END IF;
    IF NEW."SU_NAM_SU_ID" IS DISTINCT FROM OLD."SU_NAM_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_NAM_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_NAM_Subject_Name" IS DISTINCT FROM OLD."SU_NAM_Subject_Name"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_NAM_Subject_Name" IS NOT NULL AND (
            OLD."SU_NAM_Subject_Name" IS NULL OR
            OLD."SU_NAM_Subject_Name" <> NEW."SU_NAM_Subject_Name"
        ) THEN
            INSERT INTO public."SU_NAM_Subject_Name" (
                "Metadata_SU_NAM",
                "SU_NAM_SU_ID",
                "SU_NAM_Subject_Name"
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
                NEW."SU_NAM_Subject_Name"
            );
        END IF;
    END IF;
    IF NEW."SU_COD_SU_ID" IS DISTINCT FROM OLD."SU_COD_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_COD_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_COD_Subject_Code" IS DISTINCT FROM OLD."SU_COD_Subject_Code"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_COD_Subject_Code" IS NOT NULL AND (
            OLD."SU_COD_Subject_Code" IS NULL OR
            OLD."SU_COD_Subject_Code" <> NEW."SU_COD_Subject_Code"
        ) THEN
            INSERT INTO public."SU_COD_Subject_Code" (
                "Metadata_SU_COD",
                "SU_COD_SU_ID",
                "SU_COD_Subject_Code"
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
                NEW."SU_COD_Subject_Code"
            );
        END IF;
    END IF;
    IF NEW."SU_GRD_SU_ID" IS DISTINCT FROM OLD."SU_GRD_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_GRD_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_GRD_GRD_ID" IS DISTINCT FROM OLD."SU_GRD_GRD_ID"
    OR NEW."SU_GRD_GRD_Grade" IS DISTINCT FROM OLD."SU_GRD_GRD_Grade"
    THEN
        _GRD := NEW."SU_GRD_GRD_ID";
        IF _GRD IS NOT DISTINCT FROM OLD."SU_GRD_GRD_ID" AND NEW."SU_GRD_GRD_Grade" IS NOT NULL THEN
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
        -- a value that is left as it is states nothing
        IF _GRD IS NOT NULL AND (
            OLD."SU_GRD_GRD_ID" IS NULL OR
            OLD."SU_GRD_GRD_ID" <> _GRD
        ) THEN
            INSERT INTO public."SU_GRD_Subject_Grade" (
                "Metadata_SU_GRD",
                "SU_GRD_SU_ID",
                "SU_GRD_GRD_ID"
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
                _GRD
            );
        END IF;
    END IF;
    IF NEW."SU_NOT_SU_ID" IS DISTINCT FROM OLD."SU_NOT_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_NOT_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_NOT_Subject_Note" IS DISTINCT FROM OLD."SU_NOT_Subject_Note"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_NOT_Subject_Note" IS NOT NULL AND (
            OLD."SU_NOT_Subject_Note" IS NULL OR
            md5(OLD."SU_NOT_Subject_Note"::text) <> md5(NEW."SU_NOT_Subject_Note"::text)
        ) THEN
            INSERT INTO public."SU_NOT_Subject_Note" (
                "Metadata_SU_NOT",
                "SU_NOT_SU_ID",
                "SU_NOT_Subject_Note"
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
                NEW."SU_NOT_Subject_Note"
            );
        END IF;
    END IF;
    IF NEW."SU_TTL_SU_ID" IS DISTINCT FROM OLD."SU_TTL_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_TTL_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_TTL_Subject_Title" IS DISTINCT FROM OLD."SU_TTL_Subject_Title"
    OR NEW."SU_TTL_ChangedAt" IS DISTINCT FROM OLD."SU_TTL_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_TTL_Subject_Title" IS NOT NULL AND (
            NEW."SU_TTL_ChangedAt" IS DISTINCT FROM OLD."SU_TTL_ChangedAt" OR
            OLD."SU_TTL_Subject_Title" IS NULL OR
            OLD."SU_TTL_Subject_Title" <> NEW."SU_TTL_Subject_Title"
        ) THEN
            INSERT INTO public."SU_TTL_Subject_Title" (
                "Metadata_SU_TTL",
                "SU_TTL_SU_ID",
                "SU_TTL_ChangedAt",
                "SU_TTL_Subject_Title"
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
                CASE
                    WHEN NEW."SU_TTL_ChangedAt" IS DISTINCT FROM OLD."SU_TTL_ChangedAt" THEN NEW."SU_TTL_ChangedAt"
                    ELSE _now
                END,
                NEW."SU_TTL_Subject_Title"
            );
        END IF;
    END IF;
    IF NEW."SU_STA_SU_ID" IS DISTINCT FROM OLD."SU_STA_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_STA_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_STA_Subject_State" IS DISTINCT FROM OLD."SU_STA_Subject_State"
    OR NEW."SU_STA_ChangedAt" IS DISTINCT FROM OLD."SU_STA_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_STA_Subject_State" IS NOT NULL AND (
            NEW."SU_STA_ChangedAt" IS DISTINCT FROM OLD."SU_STA_ChangedAt" OR
            OLD."SU_STA_Subject_State" IS NULL OR
            OLD."SU_STA_Subject_State" <> NEW."SU_STA_Subject_State"
        ) THEN
            INSERT INTO public."SU_STA_Subject_State" (
                "Metadata_SU_STA",
                "SU_STA_SU_ID",
                "SU_STA_ChangedAt",
                "SU_STA_Subject_State"
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
                CASE
                    WHEN NEW."SU_STA_ChangedAt" IS DISTINCT FROM OLD."SU_STA_ChangedAt" THEN NEW."SU_STA_ChangedAt"
                    ELSE _now
                END,
                NEW."SU_STA_Subject_State"
            );
        END IF;
    END IF;
    IF NEW."SU_LBL_SU_ID" IS DISTINCT FROM OLD."SU_LBL_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_LBL_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_LBL_Subject_Label" IS DISTINCT FROM OLD."SU_LBL_Subject_Label"
    OR NEW."SU_LBL_ChangedAt" IS DISTINCT FROM OLD."SU_LBL_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_LBL_Subject_Label" IS NOT NULL AND (
            NEW."SU_LBL_ChangedAt" IS DISTINCT FROM OLD."SU_LBL_ChangedAt" OR
            OLD."SU_LBL_Subject_Label" IS NULL OR
            OLD."SU_LBL_Subject_Label" <> NEW."SU_LBL_Subject_Label"
        ) THEN
            INSERT INTO public."SU_LBL_Subject_Label" (
                "Metadata_SU_LBL",
                "SU_LBL_SU_ID",
                "SU_LBL_ChangedAt",
                "SU_LBL_Subject_Label"
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
                CASE
                    WHEN NEW."SU_LBL_ChangedAt" IS DISTINCT FROM OLD."SU_LBL_ChangedAt" THEN NEW."SU_LBL_ChangedAt"
                    ELSE _now
                END,
                NEW."SU_LBL_Subject_Label"
            );
        END IF;
    END IF;
    IF NEW."SU_TAG_SU_ID" IS DISTINCT FROM OLD."SU_TAG_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_TAG_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_TAG_Subject_Tag" IS DISTINCT FROM OLD."SU_TAG_Subject_Tag"
    OR NEW."SU_TAG_ChangedAt" IS DISTINCT FROM OLD."SU_TAG_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_TAG_Subject_Tag" IS NOT NULL AND (
            NEW."SU_TAG_ChangedAt" IS DISTINCT FROM OLD."SU_TAG_ChangedAt" OR
            OLD."SU_TAG_Subject_Tag" IS NULL OR
            OLD."SU_TAG_Subject_Tag" <> NEW."SU_TAG_Subject_Tag"
        ) THEN
            INSERT INTO public."SU_TAG_Subject_Tag" (
                "Metadata_SU_TAG",
                "SU_TAG_SU_ID",
                "SU_TAG_ChangedAt",
                "SU_TAG_Subject_Tag"
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
                CASE
                    WHEN NEW."SU_TAG_ChangedAt" IS DISTINCT FROM OLD."SU_TAG_ChangedAt" THEN NEW."SU_TAG_ChangedAt"
                    ELSE _now
                END,
                NEW."SU_TAG_Subject_Tag"
            );
        END IF;
    END IF;
    IF NEW."SU_LVL_SU_ID" IS DISTINCT FROM OLD."SU_LVL_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_LVL_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_LVL_GRD_ID" IS DISTINCT FROM OLD."SU_LVL_GRD_ID"
    OR NEW."SU_LVL_GRD_Grade" IS DISTINCT FROM OLD."SU_LVL_GRD_Grade"
    OR NEW."SU_LVL_ChangedAt" IS DISTINCT FROM OLD."SU_LVL_ChangedAt"
    THEN
        _LVL := NEW."SU_LVL_GRD_ID";
        IF _LVL IS NOT DISTINCT FROM OLD."SU_LVL_GRD_ID" AND NEW."SU_LVL_GRD_Grade" IS NOT NULL THEN
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
        -- a value that is left as it is states nothing
        IF _LVL IS NOT NULL AND (
            NEW."SU_LVL_ChangedAt" IS DISTINCT FROM OLD."SU_LVL_ChangedAt" OR
            OLD."SU_LVL_GRD_ID" IS NULL OR
            OLD."SU_LVL_GRD_ID" <> _LVL
        ) THEN
            INSERT INTO public."SU_LVL_Subject_Level" (
                "Metadata_SU_LVL",
                "SU_LVL_SU_ID",
                "SU_LVL_ChangedAt",
                "SU_LVL_GRD_ID"
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
                CASE
                    WHEN NEW."SU_LVL_ChangedAt" IS DISTINCT FROM OLD."SU_LVL_ChangedAt" THEN NEW."SU_LVL_ChangedAt"
                    ELSE _now
                END,
                _LVL
            );
        END IF;
    END IF;
    IF NEW."SU_TXT_SU_ID" IS DISTINCT FROM OLD."SU_TXT_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_TXT_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_TXT_Subject_Text" IS DISTINCT FROM OLD."SU_TXT_Subject_Text"
    OR NEW."SU_TXT_ChangedAt" IS DISTINCT FROM OLD."SU_TXT_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_TXT_Subject_Text" IS NOT NULL AND (
            NEW."SU_TXT_ChangedAt" IS DISTINCT FROM OLD."SU_TXT_ChangedAt" OR
            OLD."SU_TXT_Subject_Text" IS NULL OR
            md5(OLD."SU_TXT_Subject_Text"::text) <> md5(NEW."SU_TXT_Subject_Text"::text)
        ) THEN
            INSERT INTO public."SU_TXT_Subject_Text" (
                "Metadata_SU_TXT",
                "SU_TXT_SU_ID",
                "SU_TXT_ChangedAt",
                "SU_TXT_Subject_Text"
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
                CASE
                    WHEN NEW."SU_TXT_ChangedAt" IS DISTINCT FROM OLD."SU_TXT_ChangedAt" THEN NEW."SU_TXT_ChangedAt"
                    ELSE _now
                END,
                NEW."SU_TXT_Subject_Text"
            );
        END IF;
    END IF;
    IF NEW."SU_ASR_SU_ID" IS DISTINCT FROM OLD."SU_ASR_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_ASR_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_ASR_Subject_Assessment" IS DISTINCT FROM OLD."SU_ASR_Subject_Assessment"
    OR NEW."SU_ASR_ChangedAt" IS DISTINCT FROM OLD."SU_ASR_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_ASR_Subject_Assessment" IS NOT NULL AND (
            NEW."SU_ASR_ChangedAt" IS DISTINCT FROM OLD."SU_ASR_ChangedAt" OR
            OLD."SU_ASR_Subject_Assessment" IS NULL OR
            OLD."SU_ASR_Subject_Assessment" <> NEW."SU_ASR_Subject_Assessment"
        ) THEN
            INSERT INTO public."SU_ASR_Subject_Assessment" (
                "Metadata_SU_ASR",
                "SU_ASR_SU_ID",
                "SU_ASR_ChangedAt",
                "SU_ASR_Subject_Assessment"
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
                CASE
                    WHEN NEW."SU_ASR_ChangedAt" IS DISTINCT FROM OLD."SU_ASR_ChangedAt" THEN NEW."SU_ASR_ChangedAt"
                    ELSE _now
                END,
                NEW."SU_ASR_Subject_Assessment"
            );
        END IF;
    END IF;
    IF NEW."SU_ERS_SU_ID" IS DISTINCT FROM OLD."SU_ERS_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_ERS_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_ERS_Subject_Erasable" IS DISTINCT FROM OLD."SU_ERS_Subject_Erasable"
    OR NEW."SU_ERS_ChangedAt" IS DISTINCT FROM OLD."SU_ERS_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_ERS_Subject_Erasable" IS NOT NULL AND (
            NEW."SU_ERS_ChangedAt" IS DISTINCT FROM OLD."SU_ERS_ChangedAt" OR
            OLD."SU_ERS_Subject_Erasable" IS NULL OR
            OLD."SU_ERS_Subject_Erasable" <> NEW."SU_ERS_Subject_Erasable"
        ) THEN
            INSERT INTO public."SU_ERS_Subject_Erasable" (
                "Metadata_SU_ERS",
                "SU_ERS_SU_ID",
                "SU_ERS_ChangedAt",
                "SU_ERS_Subject_Erasable"
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
                CASE
                    WHEN NEW."SU_ERS_ChangedAt" IS DISTINCT FROM OLD."SU_ERS_ChangedAt" THEN NEW."SU_ERS_ChangedAt"
                    ELSE _now
                END,
                NEW."SU_ERS_Subject_Erasable"
            );
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
BEGIN
    DELETE FROM
        public."SU_NAM_Subject_Name" x
    WHERE
        x."SU_NAM_SU_ID" = OLD."SU_ID"
    ;
    DELETE FROM
        public."SU_COD_Subject_Code" x
    WHERE
        x."SU_COD_SU_ID" = OLD."SU_ID"
    ;
    DELETE FROM
        public."SU_GRD_Subject_Grade" x
    WHERE
        x."SU_GRD_SU_ID" = OLD."SU_ID"
    ;
    DELETE FROM
        public."SU_NOT_Subject_Note" x
    WHERE
        x."SU_NOT_SU_ID" = OLD."SU_ID"
    ;
    DELETE FROM
        public."SU_TTL_Subject_Title" x
    WHERE
        x."SU_TTL_SU_ID" = OLD."SU_ID"
    AND
        x."SU_TTL_ChangedAt" = OLD."SU_TTL_ChangedAt"
    ;
    DELETE FROM
        public."SU_STA_Subject_State" x
    WHERE
        x."SU_STA_SU_ID" = OLD."SU_ID"
    AND
        x."SU_STA_ChangedAt" = OLD."SU_STA_ChangedAt"
    ;
    DELETE FROM
        public."SU_LBL_Subject_Label" x
    WHERE
        x."SU_LBL_SU_ID" = OLD."SU_ID"
    AND
        x."SU_LBL_ChangedAt" = OLD."SU_LBL_ChangedAt"
    ;
    DELETE FROM
        public."SU_TAG_Subject_Tag" x
    WHERE
        x."SU_TAG_SU_ID" = OLD."SU_ID"
    AND
        x."SU_TAG_ChangedAt" = OLD."SU_TAG_ChangedAt"
    ;
    DELETE FROM
        public."SU_LVL_Subject_Level" x
    WHERE
        x."SU_LVL_SU_ID" = OLD."SU_ID"
    AND
        x."SU_LVL_ChangedAt" = OLD."SU_LVL_ChangedAt"
    ;
    DELETE FROM
        public."SU_TXT_Subject_Text" x
    WHERE
        x."SU_TXT_SU_ID" = OLD."SU_ID"
    AND
        x."SU_TXT_ChangedAt" = OLD."SU_TXT_ChangedAt"
    ;
    DELETE FROM
        public."SU_ASR_Subject_Assessment" x
    WHERE
        x."SU_ASR_SU_ID" = OLD."SU_ID"
    AND
        x."SU_ASR_ChangedAt" = OLD."SU_ASR_ChangedAt"
    ;
    DELETE FROM
        public."SU_ERS_Subject_Erasable" x
    WHERE
        x."SU_ERS_SU_ID" = OLD."SU_ID"
    AND
        x."SU_ERS_ChangedAt" = OLD."SU_ERS_ChangedAt"
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        public."SU_Subject" a
    WHERE
        a."SU_ID" = OLD."SU_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_NAM_Subject_Name" x
        WHERE
            x."SU_NAM_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_COD_Subject_Code" x
        WHERE
            x."SU_COD_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_GRD_Subject_Grade" x
        WHERE
            x."SU_GRD_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_NOT_Subject_Note" x
        WHERE
            x."SU_NOT_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_TTL_Subject_Title" x
        WHERE
            x."SU_TTL_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_STA_Subject_State" x
        WHERE
            x."SU_STA_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_LBL_Subject_Label" x
        WHERE
            x."SU_LBL_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_TAG_Subject_Tag" x
        WHERE
            x."SU_TAG_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_LVL_Subject_Level" x
        WHERE
            x."SU_LVL_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_TXT_Subject_Text" x
        WHERE
            x."SU_TXT_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_ASR_Subject_Assessment" x
        WHERE
            x."SU_ASR_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_ERS_Subject_Erasable" x
        WHERE
            x."SU_ERS_SU_ID" = a."SU_ID"
    )
    ;
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
            "OB_NAM_Object_Name"
        )
        VALUES (
            coalesce(NEW."Metadata_OB_NAM", NEW."Metadata_OB"),
            coalesce(NEW."OB_NAM_OB_ID", _id),
            NEW."OB_NAM_Object_Name"
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
BEGIN
    IF NEW."OB_ID" IS DISTINCT FROM OLD."OB_ID" THEN
        RAISE EXCEPTION 'The identity column OB_ID is not updatable.';
    END IF;
    IF NEW."OB_NAM_OB_ID" IS DISTINCT FROM OLD."OB_NAM_OB_ID" THEN
        RAISE EXCEPTION 'The foreign key column OB_NAM_OB_ID is not updatable.';
    END IF;
    IF NEW."OB_NAM_Object_Name" IS DISTINCT FROM OLD."OB_NAM_Object_Name"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."OB_NAM_Object_Name" IS NOT NULL AND (
            OLD."OB_NAM_Object_Name" IS NULL OR
            OLD."OB_NAM_Object_Name" <> NEW."OB_NAM_Object_Name"
        ) THEN
            INSERT INTO public."OB_NAM_Object_Name" (
                "Metadata_OB_NAM",
                "OB_NAM_OB_ID",
                "OB_NAM_Object_Name"
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
                NEW."OB_NAM_Object_Name"
            );
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
BEGIN
    DELETE FROM
        public."OB_NAM_Object_Name" x
    WHERE
        x."OB_NAM_OB_ID" = OLD."OB_ID"
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        public."OB_Object" a
    WHERE
        a."OB_ID" = OLD."OB_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."OB_NAM_Object_Name" x
        WHERE
            x."OB_NAM_OB_ID" = a."OB_ID"
    )
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lOB_Object" ON public."lOB_Object";
CREATE TRIGGER "dt_lOB_Object"
INSTEAD OF DELETE ON public."lOB_Object"
FOR EACH ROW EXECUTE FUNCTION public."dt_lOB_Object"();
