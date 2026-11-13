-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are
-- stored. Others are silently ignored in order to avoid unnecessary temporal duplicates (the insert procedures of the
-- attributes, ip_<attribute>, see to that).
--
-- Oracle runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Two values are different when one is not null and the other is, or when they are not equal; PL/SQL has no IS DISTINCT FROM.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_Subject instead of INSERT trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lSU_Subject
INSTEAD OF INSERT ON lSU_Subject
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_id number(10);
    v_GRD number(5);
    v_LVL number(5);
BEGIN
    v_id := :NEW.SU_ID;
    IF v_id IS NULL THEN
        INSERT INTO SU_Subject (
            Metadata_SU
        )
        VALUES (
            :NEW.Metadata_SU
        )
        RETURNING SU_ID INTO v_id;
    END IF;
    IF :NEW.SU_NAM_Subject_Name IS NOT NULL THEN
        ip_SU_NAM_Subject_Name(
            p_owner => COALESCE(:NEW.SU_NAM_SU_ID, v_id),
            p_value => :NEW.SU_NAM_Subject_Name,
            p_metadata => COALESCE(:NEW.Metadata_SU_NAM, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_COD_Subject_Code IS NOT NULL THEN
        ip_SU_COD_Subject_Code(
            p_owner => COALESCE(:NEW.SU_COD_SU_ID, v_id),
            p_value => :NEW.SU_COD_Subject_Code,
            p_metadata => COALESCE(:NEW.Metadata_SU_COD, :NEW.Metadata_SU)
        );
    END IF;
    v_GRD := :NEW.SU_GRD_GRD_ID;
    IF v_GRD IS NULL AND :NEW.SU_GRD_GRD_Grade IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GRD_ID
            FROM
                GRD_Grade k
            WHERE
                k.GRD_Grade = :NEW.SU_GRD_GRD_Grade
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_GRD := kv.GRD_ID;
        END LOOP;
    END IF;
    IF v_GRD IS NOT NULL THEN
        ip_SU_GRD_Subject_Grade(
            p_owner => COALESCE(:NEW.SU_GRD_SU_ID, v_id),
            p_value => v_GRD,
            p_metadata => COALESCE(:NEW.Metadata_SU_GRD, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_NOT_Subject_Note IS NOT NULL THEN
        ip_SU_NOT_Subject_Note(
            p_owner => COALESCE(:NEW.SU_NOT_SU_ID, v_id),
            p_value => :NEW.SU_NOT_Subject_Note,
            p_metadata => COALESCE(:NEW.Metadata_SU_NOT, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_TTL_Subject_Title IS NOT NULL THEN
        ip_SU_TTL_Subject_Title(
            p_owner => COALESCE(:NEW.SU_TTL_SU_ID, v_id),
            p_changing => COALESCE(:NEW.SU_TTL_ChangedAt, v_now),
            p_value => :NEW.SU_TTL_Subject_Title,
            p_metadata => COALESCE(:NEW.Metadata_SU_TTL, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_STA_Subject_State IS NOT NULL THEN
        ip_SU_STA_Subject_State(
            p_owner => COALESCE(:NEW.SU_STA_SU_ID, v_id),
            p_changing => COALESCE(:NEW.SU_STA_ChangedAt, v_now),
            p_value => :NEW.SU_STA_Subject_State,
            p_metadata => COALESCE(:NEW.Metadata_SU_STA, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_LBL_Subject_Label IS NOT NULL THEN
        ip_SU_LBL_Subject_Label(
            p_owner => COALESCE(:NEW.SU_LBL_SU_ID, v_id),
            p_changing => COALESCE(:NEW.SU_LBL_ChangedAt, v_now),
            p_value => :NEW.SU_LBL_Subject_Label,
            p_metadata => COALESCE(:NEW.Metadata_SU_LBL, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_TAG_Subject_Tag IS NOT NULL THEN
        ip_SU_TAG_Subject_Tag(
            p_owner => COALESCE(:NEW.SU_TAG_SU_ID, v_id),
            p_changing => COALESCE(:NEW.SU_TAG_ChangedAt, v_now),
            p_value => :NEW.SU_TAG_Subject_Tag,
            p_metadata => COALESCE(:NEW.Metadata_SU_TAG, :NEW.Metadata_SU)
        );
    END IF;
    v_LVL := :NEW.SU_LVL_GRD_ID;
    IF v_LVL IS NULL AND :NEW.SU_LVL_GRD_Grade IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GRD_ID
            FROM
                GRD_Grade k
            WHERE
                k.GRD_Grade = :NEW.SU_LVL_GRD_Grade
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_LVL := kv.GRD_ID;
        END LOOP;
    END IF;
    IF v_LVL IS NOT NULL THEN
        ip_SU_LVL_Subject_Level(
            p_owner => COALESCE(:NEW.SU_LVL_SU_ID, v_id),
            p_changing => COALESCE(:NEW.SU_LVL_ChangedAt, v_now),
            p_value => v_LVL,
            p_metadata => COALESCE(:NEW.Metadata_SU_LVL, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_TXT_Subject_Text IS NOT NULL THEN
        ip_SU_TXT_Subject_Text(
            p_owner => COALESCE(:NEW.SU_TXT_SU_ID, v_id),
            p_changing => COALESCE(:NEW.SU_TXT_ChangedAt, v_now),
            p_value => :NEW.SU_TXT_Subject_Text,
            p_metadata => COALESCE(:NEW.Metadata_SU_TXT, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_ASR_Subject_Assessment IS NOT NULL THEN
        ip_SU_ASR_Subject_Assessment(
            p_owner => COALESCE(:NEW.SU_ASR_SU_ID, v_id),
            p_changing => COALESCE(:NEW.SU_ASR_ChangedAt, v_now),
            p_value => :NEW.SU_ASR_Subject_Assessment,
            p_metadata => COALESCE(:NEW.Metadata_SU_ASR, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_ERS_Subject_Erasable IS NOT NULL THEN
        ip_SU_ERS_Subject_Erasable(
            p_owner => COALESCE(:NEW.SU_ERS_SU_ID, v_id),
            p_changing => COALESCE(:NEW.SU_ERS_ChangedAt, v_now),
            p_value => :NEW.SU_ERS_Subject_Erasable,
            p_metadata => COALESCE(:NEW.Metadata_SU_ERS, :NEW.Metadata_SU)
        );
    END IF;
END it_lSU_Subject;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_Subject instead of UPDATE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lSU_Subject
INSTEAD OF UPDATE ON lSU_Subject
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_GRD number(5);
    v_LVL number(5);
BEGIN
    IF (:NEW.SU_ID <> :OLD.SU_ID
        OR (:NEW.SU_ID IS NULL AND :OLD.SU_ID IS NOT NULL)
        OR (:NEW.SU_ID IS NOT NULL AND :OLD.SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_NAM_SU_ID <> :OLD.SU_NAM_SU_ID
        OR (:NEW.SU_NAM_SU_ID IS NULL AND :OLD.SU_NAM_SU_ID IS NOT NULL)
        OR (:NEW.SU_NAM_SU_ID IS NOT NULL AND :OLD.SU_NAM_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_NAM_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_NAM_Subject_Name <> :OLD.SU_NAM_Subject_Name
        OR (:NEW.SU_NAM_Subject_Name IS NULL AND :OLD.SU_NAM_Subject_Name IS NOT NULL)
        OR (:NEW.SU_NAM_Subject_Name IS NOT NULL AND :OLD.SU_NAM_Subject_Name IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_NAM_Subject_Name IS NOT NULL THEN
            ip_SU_NAM_Subject_Name(
                p_owner => COALESCE(:NEW.SU_NAM_SU_ID, :NEW.SU_ID),
                p_value => :NEW.SU_NAM_Subject_Name,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_NAM = :OLD.Metadata_SU_NAM
                            OR (:NEW.Metadata_SU_NAM IS NULL AND :OLD.Metadata_SU_NAM IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_NAM
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF :NEW.Deletable_SU_NAM = 1
    AND :OLD.SU_NAM_Subject_Name IS NOT NULL
    AND :NEW.SU_NAM_Subject_Name IS NULL
    THEN
        INSERT INTO SU_NAM_Subject_Name_Deleted (
            SU_NAM_SU_ID,
            SU_NAM_Subject_Name,
            Metadata_SU_NAM,
            SU_NAM_Deleted
        )
        SELECT
            x.SU_NAM_SU_ID,
            x.SU_NAM_Subject_Name,
            x.Metadata_SU_NAM,
            v_now
        FROM
            SU_NAM_Subject_Name x
        WHERE
            x.SU_NAM_SU_ID = :OLD.SU_ID;
        DELETE FROM
            SU_NAM_Subject_Name
        WHERE
            SU_NAM_SU_ID = :OLD.SU_ID;
    END IF;
    IF (:NEW.SU_COD_SU_ID <> :OLD.SU_COD_SU_ID
        OR (:NEW.SU_COD_SU_ID IS NULL AND :OLD.SU_COD_SU_ID IS NOT NULL)
        OR (:NEW.SU_COD_SU_ID IS NOT NULL AND :OLD.SU_COD_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_COD_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_COD_Subject_Code <> :OLD.SU_COD_Subject_Code
        OR (:NEW.SU_COD_Subject_Code IS NULL AND :OLD.SU_COD_Subject_Code IS NOT NULL)
        OR (:NEW.SU_COD_Subject_Code IS NOT NULL AND :OLD.SU_COD_Subject_Code IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_COD_Subject_Code IS NOT NULL THEN
            ip_SU_COD_Subject_Code(
                p_owner => COALESCE(:NEW.SU_COD_SU_ID, :NEW.SU_ID),
                p_value => :NEW.SU_COD_Subject_Code,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_COD = :OLD.Metadata_SU_COD
                            OR (:NEW.Metadata_SU_COD IS NULL AND :OLD.Metadata_SU_COD IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_COD
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_GRD_SU_ID <> :OLD.SU_GRD_SU_ID
        OR (:NEW.SU_GRD_SU_ID IS NULL AND :OLD.SU_GRD_SU_ID IS NOT NULL)
        OR (:NEW.SU_GRD_SU_ID IS NOT NULL AND :OLD.SU_GRD_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_GRD_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_GRD_GRD_ID <> :OLD.SU_GRD_GRD_ID
        OR (:NEW.SU_GRD_GRD_ID IS NULL AND :OLD.SU_GRD_GRD_ID IS NOT NULL)
        OR (:NEW.SU_GRD_GRD_ID IS NOT NULL AND :OLD.SU_GRD_GRD_ID IS NULL))
    OR (:NEW.SU_GRD_GRD_Grade <> :OLD.SU_GRD_GRD_Grade
        OR (:NEW.SU_GRD_GRD_Grade IS NULL AND :OLD.SU_GRD_GRD_Grade IS NOT NULL)
        OR (:NEW.SU_GRD_GRD_Grade IS NOT NULL AND :OLD.SU_GRD_GRD_Grade IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_GRD := :NEW.SU_GRD_GRD_ID;
        IF (v_GRD = :OLD.SU_GRD_GRD_ID OR (v_GRD IS NULL AND :OLD.SU_GRD_GRD_ID IS NULL))
        AND :NEW.SU_GRD_GRD_Grade IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.GRD_ID
                FROM
                    GRD_Grade k
                WHERE
                    k.GRD_Grade = :NEW.SU_GRD_GRD_Grade
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_GRD := kv.GRD_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_GRD IS NOT NULL AND (
            :OLD.SU_GRD_GRD_ID IS NULL OR
            :OLD.SU_GRD_GRD_ID <> v_GRD
        ) THEN
            ip_SU_GRD_Subject_Grade(
                p_owner => COALESCE(:NEW.SU_GRD_SU_ID, :NEW.SU_ID),
                p_value => v_GRD,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_GRD = :OLD.Metadata_SU_GRD
                            OR (:NEW.Metadata_SU_GRD IS NULL AND :OLD.Metadata_SU_GRD IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_GRD
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_NOT_SU_ID <> :OLD.SU_NOT_SU_ID
        OR (:NEW.SU_NOT_SU_ID IS NULL AND :OLD.SU_NOT_SU_ID IS NOT NULL)
        OR (:NEW.SU_NOT_SU_ID IS NOT NULL AND :OLD.SU_NOT_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_NOT_SU_ID is not updatable.');
    END IF;
    IF (DBMS_LOB.COMPARE(:NEW.SU_NOT_Subject_Note, :OLD.SU_NOT_Subject_Note) <> 0
        OR (:NEW.SU_NOT_Subject_Note IS NULL AND :OLD.SU_NOT_Subject_Note IS NOT NULL)
        OR (:NEW.SU_NOT_Subject_Note IS NOT NULL AND :OLD.SU_NOT_Subject_Note IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_NOT_Subject_Note IS NOT NULL THEN
            ip_SU_NOT_Subject_Note(
                p_owner => COALESCE(:NEW.SU_NOT_SU_ID, :NEW.SU_ID),
                p_value => :NEW.SU_NOT_Subject_Note,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_NOT = :OLD.Metadata_SU_NOT
                            OR (:NEW.Metadata_SU_NOT IS NULL AND :OLD.Metadata_SU_NOT IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_NOT
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_TTL_SU_ID <> :OLD.SU_TTL_SU_ID
        OR (:NEW.SU_TTL_SU_ID IS NULL AND :OLD.SU_TTL_SU_ID IS NOT NULL)
        OR (:NEW.SU_TTL_SU_ID IS NOT NULL AND :OLD.SU_TTL_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_TTL_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_TTL_Subject_Title <> :OLD.SU_TTL_Subject_Title
        OR (:NEW.SU_TTL_Subject_Title IS NULL AND :OLD.SU_TTL_Subject_Title IS NOT NULL)
        OR (:NEW.SU_TTL_Subject_Title IS NOT NULL AND :OLD.SU_TTL_Subject_Title IS NULL))
    OR (:NEW.SU_TTL_ChangedAt <> :OLD.SU_TTL_ChangedAt
        OR (:NEW.SU_TTL_ChangedAt IS NULL AND :OLD.SU_TTL_ChangedAt IS NOT NULL)
        OR (:NEW.SU_TTL_ChangedAt IS NOT NULL AND :OLD.SU_TTL_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_TTL_Subject_Title IS NOT NULL THEN
            ip_SU_TTL_Subject_Title(
                p_owner => COALESCE(:NEW.SU_TTL_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_TTL_ChangedAt <> :OLD.SU_TTL_ChangedAt
                        OR (:NEW.SU_TTL_ChangedAt IS NULL AND :OLD.SU_TTL_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_TTL_ChangedAt IS NOT NULL AND :OLD.SU_TTL_ChangedAt IS NULL))
                    THEN :NEW.SU_TTL_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.SU_TTL_Subject_Title,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_TTL = :OLD.Metadata_SU_TTL
                            OR (:NEW.Metadata_SU_TTL IS NULL AND :OLD.Metadata_SU_TTL IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_TTL
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_STA_SU_ID <> :OLD.SU_STA_SU_ID
        OR (:NEW.SU_STA_SU_ID IS NULL AND :OLD.SU_STA_SU_ID IS NOT NULL)
        OR (:NEW.SU_STA_SU_ID IS NOT NULL AND :OLD.SU_STA_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_STA_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_STA_Subject_State <> :OLD.SU_STA_Subject_State
        OR (:NEW.SU_STA_Subject_State IS NULL AND :OLD.SU_STA_Subject_State IS NOT NULL)
        OR (:NEW.SU_STA_Subject_State IS NOT NULL AND :OLD.SU_STA_Subject_State IS NULL))
    OR (:NEW.SU_STA_ChangedAt <> :OLD.SU_STA_ChangedAt
        OR (:NEW.SU_STA_ChangedAt IS NULL AND :OLD.SU_STA_ChangedAt IS NOT NULL)
        OR (:NEW.SU_STA_ChangedAt IS NOT NULL AND :OLD.SU_STA_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_STA_Subject_State IS NOT NULL THEN
            ip_SU_STA_Subject_State(
                p_owner => COALESCE(:NEW.SU_STA_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_STA_ChangedAt <> :OLD.SU_STA_ChangedAt
                        OR (:NEW.SU_STA_ChangedAt IS NULL AND :OLD.SU_STA_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_STA_ChangedAt IS NOT NULL AND :OLD.SU_STA_ChangedAt IS NULL))
                    THEN :NEW.SU_STA_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.SU_STA_Subject_State,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_STA = :OLD.Metadata_SU_STA
                            OR (:NEW.Metadata_SU_STA IS NULL AND :OLD.Metadata_SU_STA IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_STA
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_LBL_SU_ID <> :OLD.SU_LBL_SU_ID
        OR (:NEW.SU_LBL_SU_ID IS NULL AND :OLD.SU_LBL_SU_ID IS NOT NULL)
        OR (:NEW.SU_LBL_SU_ID IS NOT NULL AND :OLD.SU_LBL_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_LBL_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_LBL_Subject_Label <> :OLD.SU_LBL_Subject_Label
        OR (:NEW.SU_LBL_Subject_Label IS NULL AND :OLD.SU_LBL_Subject_Label IS NOT NULL)
        OR (:NEW.SU_LBL_Subject_Label IS NOT NULL AND :OLD.SU_LBL_Subject_Label IS NULL))
    OR (:NEW.SU_LBL_ChangedAt <> :OLD.SU_LBL_ChangedAt
        OR (:NEW.SU_LBL_ChangedAt IS NULL AND :OLD.SU_LBL_ChangedAt IS NOT NULL)
        OR (:NEW.SU_LBL_ChangedAt IS NOT NULL AND :OLD.SU_LBL_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_LBL_Subject_Label IS NOT NULL THEN
            ip_SU_LBL_Subject_Label(
                p_owner => COALESCE(:NEW.SU_LBL_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_LBL_ChangedAt <> :OLD.SU_LBL_ChangedAt
                        OR (:NEW.SU_LBL_ChangedAt IS NULL AND :OLD.SU_LBL_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_LBL_ChangedAt IS NOT NULL AND :OLD.SU_LBL_ChangedAt IS NULL))
                    THEN :NEW.SU_LBL_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.SU_LBL_Subject_Label,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_LBL = :OLD.Metadata_SU_LBL
                            OR (:NEW.Metadata_SU_LBL IS NULL AND :OLD.Metadata_SU_LBL IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_LBL
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_TAG_SU_ID <> :OLD.SU_TAG_SU_ID
        OR (:NEW.SU_TAG_SU_ID IS NULL AND :OLD.SU_TAG_SU_ID IS NOT NULL)
        OR (:NEW.SU_TAG_SU_ID IS NOT NULL AND :OLD.SU_TAG_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_TAG_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_TAG_Subject_Tag <> :OLD.SU_TAG_Subject_Tag
        OR (:NEW.SU_TAG_Subject_Tag IS NULL AND :OLD.SU_TAG_Subject_Tag IS NOT NULL)
        OR (:NEW.SU_TAG_Subject_Tag IS NOT NULL AND :OLD.SU_TAG_Subject_Tag IS NULL))
    OR (:NEW.SU_TAG_ChangedAt <> :OLD.SU_TAG_ChangedAt
        OR (:NEW.SU_TAG_ChangedAt IS NULL AND :OLD.SU_TAG_ChangedAt IS NOT NULL)
        OR (:NEW.SU_TAG_ChangedAt IS NOT NULL AND :OLD.SU_TAG_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_TAG_Subject_Tag IS NOT NULL THEN
            ip_SU_TAG_Subject_Tag(
                p_owner => COALESCE(:NEW.SU_TAG_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_TAG_ChangedAt <> :OLD.SU_TAG_ChangedAt
                        OR (:NEW.SU_TAG_ChangedAt IS NULL AND :OLD.SU_TAG_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_TAG_ChangedAt IS NOT NULL AND :OLD.SU_TAG_ChangedAt IS NULL))
                    THEN :NEW.SU_TAG_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.SU_TAG_Subject_Tag,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_TAG = :OLD.Metadata_SU_TAG
                            OR (:NEW.Metadata_SU_TAG IS NULL AND :OLD.Metadata_SU_TAG IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_TAG
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_LVL_SU_ID <> :OLD.SU_LVL_SU_ID
        OR (:NEW.SU_LVL_SU_ID IS NULL AND :OLD.SU_LVL_SU_ID IS NOT NULL)
        OR (:NEW.SU_LVL_SU_ID IS NOT NULL AND :OLD.SU_LVL_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_LVL_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_LVL_GRD_ID <> :OLD.SU_LVL_GRD_ID
        OR (:NEW.SU_LVL_GRD_ID IS NULL AND :OLD.SU_LVL_GRD_ID IS NOT NULL)
        OR (:NEW.SU_LVL_GRD_ID IS NOT NULL AND :OLD.SU_LVL_GRD_ID IS NULL))
    OR (:NEW.SU_LVL_GRD_Grade <> :OLD.SU_LVL_GRD_Grade
        OR (:NEW.SU_LVL_GRD_Grade IS NULL AND :OLD.SU_LVL_GRD_Grade IS NOT NULL)
        OR (:NEW.SU_LVL_GRD_Grade IS NOT NULL AND :OLD.SU_LVL_GRD_Grade IS NULL))
    OR (:NEW.SU_LVL_ChangedAt <> :OLD.SU_LVL_ChangedAt
        OR (:NEW.SU_LVL_ChangedAt IS NULL AND :OLD.SU_LVL_ChangedAt IS NOT NULL)
        OR (:NEW.SU_LVL_ChangedAt IS NOT NULL AND :OLD.SU_LVL_ChangedAt IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_LVL := :NEW.SU_LVL_GRD_ID;
        IF (v_LVL = :OLD.SU_LVL_GRD_ID OR (v_LVL IS NULL AND :OLD.SU_LVL_GRD_ID IS NULL))
        AND :NEW.SU_LVL_GRD_Grade IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.GRD_ID
                FROM
                    GRD_Grade k
                WHERE
                    k.GRD_Grade = :NEW.SU_LVL_GRD_Grade
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_LVL := kv.GRD_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_LVL IS NOT NULL AND (
            (:NEW.SU_LVL_ChangedAt <> :OLD.SU_LVL_ChangedAt
                OR (:NEW.SU_LVL_ChangedAt IS NULL AND :OLD.SU_LVL_ChangedAt IS NOT NULL)
                OR (:NEW.SU_LVL_ChangedAt IS NOT NULL AND :OLD.SU_LVL_ChangedAt IS NULL)) OR
            :OLD.SU_LVL_GRD_ID IS NULL OR
            :OLD.SU_LVL_GRD_ID <> v_LVL
        ) THEN
            ip_SU_LVL_Subject_Level(
                p_owner => COALESCE(:NEW.SU_LVL_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_LVL_ChangedAt <> :OLD.SU_LVL_ChangedAt
                        OR (:NEW.SU_LVL_ChangedAt IS NULL AND :OLD.SU_LVL_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_LVL_ChangedAt IS NOT NULL AND :OLD.SU_LVL_ChangedAt IS NULL))
                    THEN :NEW.SU_LVL_ChangedAt
                    ELSE v_now
                END,
                p_value => v_LVL,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_LVL = :OLD.Metadata_SU_LVL
                            OR (:NEW.Metadata_SU_LVL IS NULL AND :OLD.Metadata_SU_LVL IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_LVL
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF :NEW.Deletable_SU_LVL = 1
    AND :OLD.SU_LVL_GRD_ID IS NOT NULL
    AND (:NEW.SU_LVL_GRD_ID IS NULL OR :NEW.SU_LVL_GRD_Grade IS NULL)
    THEN
        INSERT INTO SU_LVL_Subject_Level_Deleted (
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt,
            Metadata_SU_LVL,
            SU_LVL_Deleted
        )
        SELECT
            x.SU_LVL_SU_ID,
            x.SU_LVL_GRD_ID,
            x.SU_LVL_ChangedAt,
            x.Metadata_SU_LVL,
            CAST(CASE WHEN :NEW.SU_LVL_ChangedAt <> :OLD.SU_LVL_ChangedAt
                    OR (:NEW.SU_LVL_ChangedAt IS NULL AND :OLD.SU_LVL_ChangedAt IS NOT NULL)
                    OR (:NEW.SU_LVL_ChangedAt IS NOT NULL AND :OLD.SU_LVL_ChangedAt IS NULL)
                THEN :NEW.SU_LVL_ChangedAt ELSE v_now END AS timestamp)
        FROM
            SU_LVL_Subject_Level x
        WHERE
            x.SU_LVL_SU_ID = :OLD.SU_ID;
        DELETE FROM
            SU_LVL_Subject_Level
        WHERE
            SU_LVL_SU_ID = :OLD.SU_ID;
    END IF;
    IF (:NEW.SU_TXT_SU_ID <> :OLD.SU_TXT_SU_ID
        OR (:NEW.SU_TXT_SU_ID IS NULL AND :OLD.SU_TXT_SU_ID IS NOT NULL)
        OR (:NEW.SU_TXT_SU_ID IS NOT NULL AND :OLD.SU_TXT_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_TXT_SU_ID is not updatable.');
    END IF;
    IF (DBMS_LOB.COMPARE(:NEW.SU_TXT_Subject_Text, :OLD.SU_TXT_Subject_Text) <> 0
        OR (:NEW.SU_TXT_Subject_Text IS NULL AND :OLD.SU_TXT_Subject_Text IS NOT NULL)
        OR (:NEW.SU_TXT_Subject_Text IS NOT NULL AND :OLD.SU_TXT_Subject_Text IS NULL))
    OR (:NEW.SU_TXT_ChangedAt <> :OLD.SU_TXT_ChangedAt
        OR (:NEW.SU_TXT_ChangedAt IS NULL AND :OLD.SU_TXT_ChangedAt IS NOT NULL)
        OR (:NEW.SU_TXT_ChangedAt IS NOT NULL AND :OLD.SU_TXT_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_TXT_Subject_Text IS NOT NULL THEN
            ip_SU_TXT_Subject_Text(
                p_owner => COALESCE(:NEW.SU_TXT_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_TXT_ChangedAt <> :OLD.SU_TXT_ChangedAt
                        OR (:NEW.SU_TXT_ChangedAt IS NULL AND :OLD.SU_TXT_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_TXT_ChangedAt IS NOT NULL AND :OLD.SU_TXT_ChangedAt IS NULL))
                    THEN :NEW.SU_TXT_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.SU_TXT_Subject_Text,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_TXT = :OLD.Metadata_SU_TXT
                            OR (:NEW.Metadata_SU_TXT IS NULL AND :OLD.Metadata_SU_TXT IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_TXT
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_ASR_SU_ID <> :OLD.SU_ASR_SU_ID
        OR (:NEW.SU_ASR_SU_ID IS NULL AND :OLD.SU_ASR_SU_ID IS NOT NULL)
        OR (:NEW.SU_ASR_SU_ID IS NOT NULL AND :OLD.SU_ASR_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_ASR_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_ASR_Subject_Assessment <> :OLD.SU_ASR_Subject_Assessment
        OR (:NEW.SU_ASR_Subject_Assessment IS NULL AND :OLD.SU_ASR_Subject_Assessment IS NOT NULL)
        OR (:NEW.SU_ASR_Subject_Assessment IS NOT NULL AND :OLD.SU_ASR_Subject_Assessment IS NULL))
    OR (:NEW.SU_ASR_ChangedAt <> :OLD.SU_ASR_ChangedAt
        OR (:NEW.SU_ASR_ChangedAt IS NULL AND :OLD.SU_ASR_ChangedAt IS NOT NULL)
        OR (:NEW.SU_ASR_ChangedAt IS NOT NULL AND :OLD.SU_ASR_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_ASR_Subject_Assessment IS NOT NULL THEN
            ip_SU_ASR_Subject_Assessment(
                p_owner => COALESCE(:NEW.SU_ASR_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_ASR_ChangedAt <> :OLD.SU_ASR_ChangedAt
                        OR (:NEW.SU_ASR_ChangedAt IS NULL AND :OLD.SU_ASR_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_ASR_ChangedAt IS NOT NULL AND :OLD.SU_ASR_ChangedAt IS NULL))
                    THEN :NEW.SU_ASR_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.SU_ASR_Subject_Assessment,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_ASR = :OLD.Metadata_SU_ASR
                            OR (:NEW.Metadata_SU_ASR IS NULL AND :OLD.Metadata_SU_ASR IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_ASR
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    IF (:NEW.SU_ERS_SU_ID <> :OLD.SU_ERS_SU_ID
        OR (:NEW.SU_ERS_SU_ID IS NULL AND :OLD.SU_ERS_SU_ID IS NOT NULL)
        OR (:NEW.SU_ERS_SU_ID IS NOT NULL AND :OLD.SU_ERS_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_ERS_SU_ID is not updatable.');
    END IF;
    IF (:NEW.SU_ERS_Subject_Erasable <> :OLD.SU_ERS_Subject_Erasable
        OR (:NEW.SU_ERS_Subject_Erasable IS NULL AND :OLD.SU_ERS_Subject_Erasable IS NOT NULL)
        OR (:NEW.SU_ERS_Subject_Erasable IS NOT NULL AND :OLD.SU_ERS_Subject_Erasable IS NULL))
    OR (:NEW.SU_ERS_ChangedAt <> :OLD.SU_ERS_ChangedAt
        OR (:NEW.SU_ERS_ChangedAt IS NULL AND :OLD.SU_ERS_ChangedAt IS NOT NULL)
        OR (:NEW.SU_ERS_ChangedAt IS NOT NULL AND :OLD.SU_ERS_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.SU_ERS_Subject_Erasable IS NOT NULL THEN
            ip_SU_ERS_Subject_Erasable(
                p_owner => COALESCE(:NEW.SU_ERS_SU_ID, :NEW.SU_ID),
                p_changing => CASE
                    WHEN (:NEW.SU_ERS_ChangedAt <> :OLD.SU_ERS_ChangedAt
                        OR (:NEW.SU_ERS_ChangedAt IS NULL AND :OLD.SU_ERS_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_ERS_ChangedAt IS NOT NULL AND :OLD.SU_ERS_ChangedAt IS NULL))
                    THEN :NEW.SU_ERS_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.SU_ERS_Subject_Erasable,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
                            OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
                            OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL))
                        AND (:NEW.Metadata_SU_ERS = :OLD.Metadata_SU_ERS
                            OR (:NEW.Metadata_SU_ERS IS NULL AND :OLD.Metadata_SU_ERS IS NULL))
                        THEN :NEW.Metadata_SU
                        ELSE :NEW.Metadata_SU_ERS
                    END, :NEW.Metadata_SU)
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF :NEW.Deletable_SU_ERS = 1
    AND :OLD.SU_ERS_Subject_Erasable IS NOT NULL
    AND :NEW.SU_ERS_Subject_Erasable IS NULL
    THEN
        INSERT INTO SU_ERS_Subject_Erasable_Deleted (
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt,
            Metadata_SU_ERS,
            SU_ERS_Deleted
        )
        SELECT
            x.SU_ERS_SU_ID,
            x.SU_ERS_Subject_Erasable,
            x.SU_ERS_ChangedAt,
            x.Metadata_SU_ERS,
            CAST(CASE WHEN :NEW.SU_ERS_ChangedAt <> :OLD.SU_ERS_ChangedAt
                    OR (:NEW.SU_ERS_ChangedAt IS NULL AND :OLD.SU_ERS_ChangedAt IS NOT NULL)
                    OR (:NEW.SU_ERS_ChangedAt IS NOT NULL AND :OLD.SU_ERS_ChangedAt IS NULL)
                THEN :NEW.SU_ERS_ChangedAt ELSE v_now END AS timestamp)
        FROM
            SU_ERS_Subject_Erasable x
        WHERE
            x.SU_ERS_SU_ID = :OLD.SU_ID;
        DELETE FROM
            SU_ERS_Subject_Erasable
        WHERE
            SU_ERS_SU_ID = :OLD.SU_ID;
    END IF;
END ut_lSU_Subject;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_Subject instead of DELETE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_Subject
INSTEAD OF DELETE ON lSU_Subject
FOR EACH ROW
BEGIN
    DELETE FROM
        SU_NAM_Subject_Name x
    WHERE
        x.SU_NAM_SU_ID = :OLD.SU_ID
    ;
    DELETE FROM
        SU_COD_Subject_Code x
    WHERE
        x.SU_COD_SU_ID = :OLD.SU_ID
    ;
    DELETE FROM
        SU_GRD_Subject_Grade x
    WHERE
        x.SU_GRD_SU_ID = :OLD.SU_ID
    ;
    DELETE FROM
        SU_NOT_Subject_Note x
    WHERE
        x.SU_NOT_SU_ID = :OLD.SU_ID
    ;
    DELETE FROM
        SU_TTL_Subject_Title x
    WHERE
        x.SU_TTL_SU_ID = :OLD.SU_ID
    AND
        x.SU_TTL_ChangedAt = :OLD.SU_TTL_ChangedAt
    ;
    DELETE FROM
        SU_STA_Subject_State x
    WHERE
        x.SU_STA_SU_ID = :OLD.SU_ID
    AND
        x.SU_STA_ChangedAt = :OLD.SU_STA_ChangedAt
    ;
    DELETE FROM
        SU_LBL_Subject_Label x
    WHERE
        x.SU_LBL_SU_ID = :OLD.SU_ID
    AND
        x.SU_LBL_ChangedAt = :OLD.SU_LBL_ChangedAt
    ;
    DELETE FROM
        SU_TAG_Subject_Tag x
    WHERE
        x.SU_TAG_SU_ID = :OLD.SU_ID
    AND
        x.SU_TAG_ChangedAt = :OLD.SU_TAG_ChangedAt
    ;
    DELETE FROM
        SU_LVL_Subject_Level x
    WHERE
        x.SU_LVL_SU_ID = :OLD.SU_ID
    AND
        x.SU_LVL_ChangedAt = :OLD.SU_LVL_ChangedAt
    ;
    DELETE FROM
        SU_TXT_Subject_Text x
    WHERE
        x.SU_TXT_SU_ID = :OLD.SU_ID
    AND
        x.SU_TXT_ChangedAt = :OLD.SU_TXT_ChangedAt
    ;
    DELETE FROM
        SU_ASR_Subject_Assessment x
    WHERE
        x.SU_ASR_SU_ID = :OLD.SU_ID
    AND
        x.SU_ASR_ChangedAt = :OLD.SU_ASR_ChangedAt
    ;
    DELETE FROM
        SU_ERS_Subject_Erasable x
    WHERE
        x.SU_ERS_SU_ID = :OLD.SU_ID
    AND
        x.SU_ERS_ChangedAt = :OLD.SU_ERS_ChangedAt
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        SU_Subject a
    WHERE
        a.SU_ID = :OLD.SU_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_NAM_Subject_Name x
        WHERE
            x.SU_NAM_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_COD_Subject_Code x
        WHERE
            x.SU_COD_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_GRD_Subject_Grade x
        WHERE
            x.SU_GRD_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_NOT_Subject_Note x
        WHERE
            x.SU_NOT_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_TTL_Subject_Title x
        WHERE
            x.SU_TTL_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_STA_Subject_State x
        WHERE
            x.SU_STA_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_LBL_Subject_Label x
        WHERE
            x.SU_LBL_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_TAG_Subject_Tag x
        WHERE
            x.SU_TAG_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_LVL_Subject_Level x
        WHERE
            x.SU_LVL_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_TXT_Subject_Text x
        WHERE
            x.SU_TXT_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_ASR_Subject_Assessment x
        WHERE
            x.SU_ASR_SU_ID = a.SU_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            SU_ERS_Subject_Erasable x
        WHERE
            x.SU_ERS_SU_ID = a.SU_ID
    )
    ;
END dt_lSU_Subject;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_Object instead of INSERT trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lOB_Object
INSTEAD OF INSERT ON lOB_Object
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_id number(10);
BEGIN
    v_id := :NEW.OB_ID;
    IF v_id IS NULL THEN
        INSERT INTO OB_Object (
            Metadata_OB
        )
        VALUES (
            :NEW.Metadata_OB
        )
        RETURNING OB_ID INTO v_id;
    END IF;
    IF :NEW.OB_NAM_Object_Name IS NOT NULL THEN
        ip_OB_NAM_Object_Name(
            p_owner => COALESCE(:NEW.OB_NAM_OB_ID, v_id),
            p_value => :NEW.OB_NAM_Object_Name,
            p_metadata => COALESCE(:NEW.Metadata_OB_NAM, :NEW.Metadata_OB)
        );
    END IF;
END it_lOB_Object;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOB_Object instead of UPDATE trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lOB_Object
INSTEAD OF UPDATE ON lOB_Object
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    IF (:NEW.OB_ID <> :OLD.OB_ID
        OR (:NEW.OB_ID IS NULL AND :OLD.OB_ID IS NOT NULL)
        OR (:NEW.OB_ID IS NOT NULL AND :OLD.OB_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column OB_ID is not updatable.');
    END IF;
    IF (:NEW.OB_NAM_OB_ID <> :OLD.OB_NAM_OB_ID
        OR (:NEW.OB_NAM_OB_ID IS NULL AND :OLD.OB_NAM_OB_ID IS NOT NULL)
        OR (:NEW.OB_NAM_OB_ID IS NOT NULL AND :OLD.OB_NAM_OB_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column OB_NAM_OB_ID is not updatable.');
    END IF;
    IF (:NEW.OB_NAM_Object_Name <> :OLD.OB_NAM_Object_Name
        OR (:NEW.OB_NAM_Object_Name IS NULL AND :OLD.OB_NAM_Object_Name IS NOT NULL)
        OR (:NEW.OB_NAM_Object_Name IS NOT NULL AND :OLD.OB_NAM_Object_Name IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.OB_NAM_Object_Name IS NOT NULL THEN
            ip_OB_NAM_Object_Name(
                p_owner => COALESCE(:NEW.OB_NAM_OB_ID, :NEW.OB_ID),
                p_value => :NEW.OB_NAM_Object_Name,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_OB <> :OLD.Metadata_OB
                            OR (:NEW.Metadata_OB IS NULL AND :OLD.Metadata_OB IS NOT NULL)
                            OR (:NEW.Metadata_OB IS NOT NULL AND :OLD.Metadata_OB IS NULL))
                        AND (:NEW.Metadata_OB_NAM = :OLD.Metadata_OB_NAM
                            OR (:NEW.Metadata_OB_NAM IS NULL AND :OLD.Metadata_OB_NAM IS NULL))
                        THEN :NEW.Metadata_OB
                        ELSE :NEW.Metadata_OB_NAM
                    END, :NEW.Metadata_OB)
            );
        END IF;
    END IF;
END ut_lOB_Object;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_Object instead of DELETE trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lOB_Object
INSTEAD OF DELETE ON lOB_Object
FOR EACH ROW
BEGIN
    DELETE FROM
        OB_NAM_Object_Name x
    WHERE
        x.OB_NAM_OB_ID = :OLD.OB_ID
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        OB_Object a
    WHERE
        a.OB_ID = :OLD.OB_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            OB_NAM_Object_Name x
        WHERE
            x.OB_NAM_OB_ID = a.OB_ID
    )
    ;
END dt_lOB_Object;
/
