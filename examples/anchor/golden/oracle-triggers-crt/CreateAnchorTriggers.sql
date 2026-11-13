-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the posit and annex tables of the attributes in a consistent way,
-- through the insert procedures of the attributes (ip_<attribute>, see the attribute triggers, which keep the posit and
-- annex tables). Default values are used for some columns if not provided by the corresponding SQL statements: the positor
-- is 0, the changing and positing times are now, the reliability is 1.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates (the insert procedures of the attributes see to that).
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
            p_positor => COALESCE(:NEW.SU_NAM_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.SU_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_NAM_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_NAM, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_COD_Subject_Code IS NOT NULL THEN
        ip_SU_COD_Subject_Code(
            p_owner => COALESCE(:NEW.SU_COD_SU_ID, v_id),
            p_value => :NEW.SU_COD_Subject_Code,
            p_positor => COALESCE(:NEW.SU_COD_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.SU_COD_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_COD_Reliability, :NEW.Reliability, 1),
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
            p_positor => COALESCE(:NEW.SU_GRD_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.SU_GRD_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_GRD_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_GRD, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_NOT_Subject_Note IS NOT NULL THEN
        ip_SU_NOT_Subject_Note(
            p_owner => COALESCE(:NEW.SU_NOT_SU_ID, v_id),
            p_value => :NEW.SU_NOT_Subject_Note,
            p_positor => COALESCE(:NEW.SU_NOT_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.SU_NOT_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_NOT_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_NOT, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_TTL_Subject_Title IS NOT NULL THEN
        ip_SU_TTL_Subject_Title(
            p_owner => COALESCE(:NEW.SU_TTL_SU_ID, v_id),
            p_value => :NEW.SU_TTL_Subject_Title,
            p_changing => COALESCE(:NEW.SU_TTL_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.SU_TTL_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.SU_TTL_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_TTL_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_TTL, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_STA_Subject_State IS NOT NULL THEN
        ip_SU_STA_Subject_State(
            p_owner => COALESCE(:NEW.SU_STA_SU_ID, v_id),
            p_value => :NEW.SU_STA_Subject_State,
            p_changing => COALESCE(:NEW.SU_STA_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.SU_STA_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.SU_STA_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_STA_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_STA, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_LBL_Subject_Label IS NOT NULL THEN
        ip_SU_LBL_Subject_Label(
            p_owner => COALESCE(:NEW.SU_LBL_SU_ID, v_id),
            p_value => :NEW.SU_LBL_Subject_Label,
            p_changing => COALESCE(:NEW.SU_LBL_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.SU_LBL_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.SU_LBL_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_LBL_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_LBL, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_TAG_Subject_Tag IS NOT NULL THEN
        ip_SU_TAG_Subject_Tag(
            p_owner => COALESCE(:NEW.SU_TAG_SU_ID, v_id),
            p_value => :NEW.SU_TAG_Subject_Tag,
            p_changing => COALESCE(:NEW.SU_TAG_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.SU_TAG_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.SU_TAG_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_TAG_Reliability, :NEW.Reliability, 1),
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
            p_value => v_LVL,
            p_changing => COALESCE(:NEW.SU_LVL_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.SU_LVL_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.SU_LVL_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_LVL_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_LVL, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_TXT_Subject_Text IS NOT NULL THEN
        ip_SU_TXT_Subject_Text(
            p_owner => COALESCE(:NEW.SU_TXT_SU_ID, v_id),
            p_value => :NEW.SU_TXT_Subject_Text,
            p_changing => COALESCE(:NEW.SU_TXT_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.SU_TXT_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.SU_TXT_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_TXT_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_TXT, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_ASR_Subject_Assessment IS NOT NULL THEN
        ip_SU_ASR_Subject_Assessment(
            p_owner => COALESCE(:NEW.SU_ASR_SU_ID, v_id),
            p_value => :NEW.SU_ASR_Subject_Assessment,
            p_changing => COALESCE(:NEW.SU_ASR_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.SU_ASR_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.SU_ASR_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_ASR_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_SU_ASR, :NEW.Metadata_SU)
        );
    END IF;
    IF :NEW.SU_ERS_Subject_Erasable IS NOT NULL THEN
        ip_SU_ERS_Subject_Erasable(
            p_owner => COALESCE(:NEW.SU_ERS_SU_ID, v_id),
            p_value => :NEW.SU_ERS_Subject_Erasable,
            p_changing => COALESCE(:NEW.SU_ERS_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.SU_ERS_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.SU_ERS_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.SU_ERS_Reliability, :NEW.Reliability, 1),
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
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(10);
    v_anchor_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_GRD number(5);
    v_TTL_changing timestamp;
    v_STA_changing timestamp;
    v_LBL_changing timestamp;
    v_TAG_changing timestamp;
    v_LVL number(5);
    v_LVL_changing timestamp;
    v_TXT_changing timestamp;
    v_ASR_changing timestamp;
    v_ERS_changing timestamp;
BEGIN
    IF (:NEW.SU_ID <> :OLD.SU_ID
        OR (:NEW.SU_ID IS NULL AND :OLD.SU_ID IS NOT NULL)
        OR (:NEW.SU_ID IS NOT NULL AND :OLD.SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    v_anchor_meta_diff := CASE WHEN (:NEW.Metadata_SU <> :OLD.Metadata_SU
        OR (:NEW.Metadata_SU IS NULL AND :OLD.Metadata_SU IS NOT NULL)
        OR (:NEW.Metadata_SU IS NOT NULL AND :OLD.Metadata_SU IS NULL)) THEN TRUE ELSE FALSE END;
    -- SU_NAM_Subject_Name
    IF (:NEW.SU_NAM_ID <> :OLD.SU_NAM_ID
        OR (:NEW.SU_NAM_ID IS NULL AND :OLD.SU_NAM_ID IS NOT NULL)
        OR (:NEW.SU_NAM_ID IS NOT NULL AND :OLD.SU_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_NAM_ID is not updatable.');
    END IF;
    IF (:NEW.SU_NAM_SU_ID <> :OLD.SU_NAM_SU_ID
        OR (:NEW.SU_NAM_SU_ID IS NULL AND :OLD.SU_NAM_SU_ID IS NOT NULL)
        OR (:NEW.SU_NAM_SU_ID IS NOT NULL AND :OLD.SU_NAM_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_NAM_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_NAM_Subject_Name, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_NAM_Reliability <> :OLD.SU_NAM_Reliability
        OR (:NEW.SU_NAM_Reliability IS NULL AND :OLD.SU_NAM_Reliability IS NOT NULL)
        OR (:NEW.SU_NAM_Reliability IS NOT NULL AND :OLD.SU_NAM_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_NAM_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_NAM_Reliability;
    END IF;
    IF (:NEW.SU_NAM_Positor <> :OLD.SU_NAM_Positor
        OR (:NEW.SU_NAM_Positor IS NULL AND :OLD.SU_NAM_Positor IS NOT NULL)
        OR (:NEW.SU_NAM_Positor IS NOT NULL AND :OLD.SU_NAM_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.SU_NAM_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_NAM_PositedAt <> :OLD.SU_NAM_PositedAt
        OR (:NEW.SU_NAM_PositedAt IS NULL AND :OLD.SU_NAM_PositedAt IS NOT NULL)
        OR (:NEW.SU_NAM_PositedAt IS NOT NULL AND :OLD.SU_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_NAM_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_NAM_Subject_Name <> :OLD.SU_NAM_Subject_Name
        OR (:NEW.SU_NAM_Subject_Name IS NULL AND :OLD.SU_NAM_Subject_Name IS NOT NULL)
        OR (:NEW.SU_NAM_Subject_Name IS NOT NULL AND :OLD.SU_NAM_Subject_Name IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_NAM <> :OLD.Metadata_SU_NAM
        OR (:NEW.Metadata_SU_NAM IS NULL AND :OLD.Metadata_SU_NAM IS NOT NULL)
        OR (:NEW.Metadata_SU_NAM IS NOT NULL AND :OLD.Metadata_SU_NAM IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_NAM
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.SU_NAM_Subject_Name IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_NAM_Subject_Name IS NULL
            OR v_positing_diff
            OR :OLD.SU_NAM_Reliability IS NULL
            OR :OLD.SU_NAM_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.SU_NAM_Positor IS NULL
            OR :OLD.SU_NAM_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_SU_NAM_Subject_Name(
                    p_owner => COALESCE(:NEW.SU_NAM_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_NAM_Subject_Name,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_NAM_Subject_Name IS NULL AND :OLD.SU_NAM_Subject_Name IS NOT NULL THEN
            ip_SU_NAM_Subject_Name(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_NAM_Subject_Name,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_COD_Subject_Code
    IF (:NEW.SU_COD_ID <> :OLD.SU_COD_ID
        OR (:NEW.SU_COD_ID IS NULL AND :OLD.SU_COD_ID IS NOT NULL)
        OR (:NEW.SU_COD_ID IS NOT NULL AND :OLD.SU_COD_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_COD_ID is not updatable.');
    END IF;
    IF (:NEW.SU_COD_SU_ID <> :OLD.SU_COD_SU_ID
        OR (:NEW.SU_COD_SU_ID IS NULL AND :OLD.SU_COD_SU_ID IS NOT NULL)
        OR (:NEW.SU_COD_SU_ID IS NOT NULL AND :OLD.SU_COD_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_COD_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_COD_Subject_Code, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_COD_Reliability <> :OLD.SU_COD_Reliability
        OR (:NEW.SU_COD_Reliability IS NULL AND :OLD.SU_COD_Reliability IS NOT NULL)
        OR (:NEW.SU_COD_Reliability IS NOT NULL AND :OLD.SU_COD_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_COD_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_COD_Reliability;
    END IF;
    IF (:NEW.SU_COD_Positor <> :OLD.SU_COD_Positor
        OR (:NEW.SU_COD_Positor IS NULL AND :OLD.SU_COD_Positor IS NOT NULL)
        OR (:NEW.SU_COD_Positor IS NOT NULL AND :OLD.SU_COD_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.SU_COD_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_COD_PositedAt <> :OLD.SU_COD_PositedAt
        OR (:NEW.SU_COD_PositedAt IS NULL AND :OLD.SU_COD_PositedAt IS NOT NULL)
        OR (:NEW.SU_COD_PositedAt IS NOT NULL AND :OLD.SU_COD_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_COD_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_COD_Subject_Code <> :OLD.SU_COD_Subject_Code
        OR (:NEW.SU_COD_Subject_Code IS NULL AND :OLD.SU_COD_Subject_Code IS NOT NULL)
        OR (:NEW.SU_COD_Subject_Code IS NOT NULL AND :OLD.SU_COD_Subject_Code IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_COD <> :OLD.Metadata_SU_COD
        OR (:NEW.Metadata_SU_COD IS NULL AND :OLD.Metadata_SU_COD IS NOT NULL)
        OR (:NEW.Metadata_SU_COD IS NOT NULL AND :OLD.Metadata_SU_COD IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_COD
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.SU_COD_Subject_Code IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_COD_Subject_Code IS NULL
            OR v_positing_diff
            OR :OLD.SU_COD_Reliability IS NULL
            OR :OLD.SU_COD_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.SU_COD_Positor IS NULL
            OR :OLD.SU_COD_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_SU_COD_Subject_Code(
                    p_owner => COALESCE(:NEW.SU_COD_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_COD_Subject_Code,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_COD_Subject_Code IS NULL AND :OLD.SU_COD_Subject_Code IS NOT NULL THEN
            ip_SU_COD_Subject_Code(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_COD_Subject_Code,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_GRD_Subject_Grade
    IF (:NEW.SU_GRD_ID <> :OLD.SU_GRD_ID
        OR (:NEW.SU_GRD_ID IS NULL AND :OLD.SU_GRD_ID IS NOT NULL)
        OR (:NEW.SU_GRD_ID IS NOT NULL AND :OLD.SU_GRD_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_GRD_ID is not updatable.');
    END IF;
    IF (:NEW.SU_GRD_SU_ID <> :OLD.SU_GRD_SU_ID
        OR (:NEW.SU_GRD_SU_ID IS NULL AND :OLD.SU_GRD_SU_ID IS NOT NULL)
        OR (:NEW.SU_GRD_SU_ID IS NOT NULL AND :OLD.SU_GRD_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_GRD_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_GRD_Subject_Grade, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_GRD_Reliability <> :OLD.SU_GRD_Reliability
        OR (:NEW.SU_GRD_Reliability IS NULL AND :OLD.SU_GRD_Reliability IS NOT NULL)
        OR (:NEW.SU_GRD_Reliability IS NOT NULL AND :OLD.SU_GRD_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_GRD_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_GRD_Reliability;
    END IF;
    IF (:NEW.SU_GRD_Positor <> :OLD.SU_GRD_Positor
        OR (:NEW.SU_GRD_Positor IS NULL AND :OLD.SU_GRD_Positor IS NOT NULL)
        OR (:NEW.SU_GRD_Positor IS NOT NULL AND :OLD.SU_GRD_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.SU_GRD_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_GRD_PositedAt <> :OLD.SU_GRD_PositedAt
        OR (:NEW.SU_GRD_PositedAt IS NULL AND :OLD.SU_GRD_PositedAt IS NOT NULL)
        OR (:NEW.SU_GRD_PositedAt IS NOT NULL AND :OLD.SU_GRD_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_GRD_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_GRD_GRD_ID <> :OLD.SU_GRD_GRD_ID
        OR (:NEW.SU_GRD_GRD_ID IS NULL AND :OLD.SU_GRD_GRD_ID IS NOT NULL)
        OR (:NEW.SU_GRD_GRD_ID IS NOT NULL AND :OLD.SU_GRD_GRD_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_GRD <> :OLD.Metadata_SU_GRD
        OR (:NEW.Metadata_SU_GRD IS NULL AND :OLD.Metadata_SU_GRD IS NOT NULL)
        OR (:NEW.Metadata_SU_GRD IS NOT NULL AND :OLD.Metadata_SU_GRD IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_GRD
        END, :NEW.Metadata_SU);
    v_knot_diff := CASE WHEN (:NEW.SU_GRD_GRD_Grade <> :OLD.SU_GRD_GRD_Grade
        OR (:NEW.SU_GRD_GRD_Grade IS NULL AND :OLD.SU_GRD_GRD_Grade IS NOT NULL)
        OR (:NEW.SU_GRD_GRD_Grade IS NOT NULL AND :OLD.SU_GRD_GRD_Grade IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_GRD := :NEW.SU_GRD_GRD_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_GRD := NULL;
        IF :NEW.SU_GRD_GRD_Grade IS NOT NULL THEN
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
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF v_GRD IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_GRD_GRD_ID IS NULL
            OR v_positing_diff
            OR :OLD.SU_GRD_Reliability IS NULL
            OR :OLD.SU_GRD_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.SU_GRD_Positor IS NULL
            OR :OLD.SU_GRD_Positor <> v_positor
            OR :OLD.SU_GRD_GRD_ID <> v_GRD
            THEN
                ip_SU_GRD_Subject_Grade(
                    p_owner => COALESCE(:NEW.SU_GRD_SU_ID, :NEW.SU_ID),
                    p_value => v_GRD,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.SU_GRD_GRD_ID IS NOT NULL AND (
            :NEW.SU_GRD_GRD_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.SU_GRD_GRD_Grade IS NULL AND :OLD.SU_GRD_GRD_Grade IS NOT NULL
            )
        ) THEN
            ip_SU_GRD_Subject_Grade(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_GRD_GRD_ID,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_NOT_Subject_Note
    IF (:NEW.SU_NOT_ID <> :OLD.SU_NOT_ID
        OR (:NEW.SU_NOT_ID IS NULL AND :OLD.SU_NOT_ID IS NOT NULL)
        OR (:NEW.SU_NOT_ID IS NOT NULL AND :OLD.SU_NOT_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_NOT_ID is not updatable.');
    END IF;
    IF (:NEW.SU_NOT_SU_ID <> :OLD.SU_NOT_SU_ID
        OR (:NEW.SU_NOT_SU_ID IS NULL AND :OLD.SU_NOT_SU_ID IS NOT NULL)
        OR (:NEW.SU_NOT_SU_ID IS NOT NULL AND :OLD.SU_NOT_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_NOT_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_NOT_Subject_Note, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_NOT_Reliability <> :OLD.SU_NOT_Reliability
        OR (:NEW.SU_NOT_Reliability IS NULL AND :OLD.SU_NOT_Reliability IS NOT NULL)
        OR (:NEW.SU_NOT_Reliability IS NOT NULL AND :OLD.SU_NOT_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_NOT_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_NOT_Reliability;
    END IF;
    IF (:NEW.SU_NOT_Positor <> :OLD.SU_NOT_Positor
        OR (:NEW.SU_NOT_Positor IS NULL AND :OLD.SU_NOT_Positor IS NOT NULL)
        OR (:NEW.SU_NOT_Positor IS NOT NULL AND :OLD.SU_NOT_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.SU_NOT_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_NOT_PositedAt <> :OLD.SU_NOT_PositedAt
        OR (:NEW.SU_NOT_PositedAt IS NULL AND :OLD.SU_NOT_PositedAt IS NOT NULL)
        OR (:NEW.SU_NOT_PositedAt IS NOT NULL AND :OLD.SU_NOT_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_NOT_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN ((:NEW.SU_NOT_Subject_Note IS NULL AND :OLD.SU_NOT_Subject_Note IS NOT NULL)
        OR (:NEW.SU_NOT_Subject_Note IS NOT NULL AND :OLD.SU_NOT_Subject_Note IS NULL)
        OR (:NEW.SU_NOT_Subject_Note IS NOT NULL AND :OLD.SU_NOT_Subject_Note IS NOT NULL
            AND DBMS_LOB.COMPARE(:NEW.SU_NOT_Subject_Note, :OLD.SU_NOT_Subject_Note) <> 0)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_NOT <> :OLD.Metadata_SU_NOT
        OR (:NEW.Metadata_SU_NOT IS NULL AND :OLD.Metadata_SU_NOT IS NOT NULL)
        OR (:NEW.Metadata_SU_NOT IS NOT NULL AND :OLD.Metadata_SU_NOT IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_NOT
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.SU_NOT_Subject_Note IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_NOT_Subject_Note IS NULL
            OR v_positing_diff
            OR :OLD.SU_NOT_Reliability IS NULL
            OR :OLD.SU_NOT_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.SU_NOT_Positor IS NULL
            OR :OLD.SU_NOT_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_SU_NOT_Subject_Note(
                    p_owner => COALESCE(:NEW.SU_NOT_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_NOT_Subject_Note,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_NOT_Subject_Note IS NULL AND :OLD.SU_NOT_Subject_Note IS NOT NULL THEN
            ip_SU_NOT_Subject_Note(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_NOT_Subject_Note,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_TTL_Subject_Title
    IF (:NEW.SU_TTL_ID <> :OLD.SU_TTL_ID
        OR (:NEW.SU_TTL_ID IS NULL AND :OLD.SU_TTL_ID IS NOT NULL)
        OR (:NEW.SU_TTL_ID IS NOT NULL AND :OLD.SU_TTL_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_TTL_ID is not updatable.');
    END IF;
    IF (:NEW.SU_TTL_SU_ID <> :OLD.SU_TTL_SU_ID
        OR (:NEW.SU_TTL_SU_ID IS NULL AND :OLD.SU_TTL_SU_ID IS NOT NULL)
        OR (:NEW.SU_TTL_SU_ID IS NOT NULL AND :OLD.SU_TTL_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_TTL_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_TTL_Subject_Title, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_TTL_Reliability <> :OLD.SU_TTL_Reliability
        OR (:NEW.SU_TTL_Reliability IS NULL AND :OLD.SU_TTL_Reliability IS NOT NULL)
        OR (:NEW.SU_TTL_Reliability IS NOT NULL AND :OLD.SU_TTL_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_TTL_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_TTL_Reliability;
    END IF;
    IF (:NEW.SU_TTL_Positor <> :OLD.SU_TTL_Positor
        OR (:NEW.SU_TTL_Positor IS NULL AND :OLD.SU_TTL_Positor IS NOT NULL)
        OR (:NEW.SU_TTL_Positor IS NOT NULL AND :OLD.SU_TTL_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.SU_TTL_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_TTL_PositedAt <> :OLD.SU_TTL_PositedAt
        OR (:NEW.SU_TTL_PositedAt IS NULL AND :OLD.SU_TTL_PositedAt IS NOT NULL)
        OR (:NEW.SU_TTL_PositedAt IS NOT NULL AND :OLD.SU_TTL_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_TTL_ChangedAt <> :OLD.SU_TTL_ChangedAt
        OR (:NEW.SU_TTL_ChangedAt IS NULL AND :OLD.SU_TTL_ChangedAt IS NOT NULL)
        OR (:NEW.SU_TTL_ChangedAt IS NOT NULL AND :OLD.SU_TTL_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_TTL_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_TTL_Subject_Title IS NULL THEN
        v_positing := :NEW.SU_TTL_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_TTL_Subject_Title <> :OLD.SU_TTL_Subject_Title
        OR (:NEW.SU_TTL_Subject_Title IS NULL AND :OLD.SU_TTL_Subject_Title IS NOT NULL)
        OR (:NEW.SU_TTL_Subject_Title IS NOT NULL AND :OLD.SU_TTL_Subject_Title IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_TTL <> :OLD.Metadata_SU_TTL
        OR (:NEW.Metadata_SU_TTL IS NULL AND :OLD.Metadata_SU_TTL IS NOT NULL)
        OR (:NEW.Metadata_SU_TTL IS NOT NULL AND :OLD.Metadata_SU_TTL IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_TTL
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_TTL_changing := :NEW.SU_TTL_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_TTL_changing := :NEW.SU_TTL_ChangedAt;
        ELSE
            v_TTL_changing := v_now;
        END IF;
        IF :NEW.SU_TTL_Subject_Title IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_TTL_Subject_Title IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_TTL_Reliability IS NULL
            OR :OLD.SU_TTL_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.SU_TTL_Positor IS NULL
            OR :OLD.SU_TTL_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_SU_TTL_Subject_Title(
                    p_owner => COALESCE(:NEW.SU_TTL_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_TTL_Subject_Title,
                    p_changing => v_TTL_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_TTL_Subject_Title IS NULL AND :OLD.SU_TTL_Subject_Title IS NOT NULL THEN
            ip_SU_TTL_Subject_Title(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_TTL_Subject_Title,
                p_changing => :OLD.SU_TTL_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_STA_Subject_State
    IF (:NEW.SU_STA_ID <> :OLD.SU_STA_ID
        OR (:NEW.SU_STA_ID IS NULL AND :OLD.SU_STA_ID IS NOT NULL)
        OR (:NEW.SU_STA_ID IS NOT NULL AND :OLD.SU_STA_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_STA_ID is not updatable.');
    END IF;
    IF (:NEW.SU_STA_SU_ID <> :OLD.SU_STA_SU_ID
        OR (:NEW.SU_STA_SU_ID IS NULL AND :OLD.SU_STA_SU_ID IS NOT NULL)
        OR (:NEW.SU_STA_SU_ID IS NOT NULL AND :OLD.SU_STA_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_STA_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_STA_Subject_State, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_STA_Reliability <> :OLD.SU_STA_Reliability
        OR (:NEW.SU_STA_Reliability IS NULL AND :OLD.SU_STA_Reliability IS NOT NULL)
        OR (:NEW.SU_STA_Reliability IS NOT NULL AND :OLD.SU_STA_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_STA_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_STA_Reliability;
    END IF;
    IF (:NEW.SU_STA_Positor <> :OLD.SU_STA_Positor
        OR (:NEW.SU_STA_Positor IS NULL AND :OLD.SU_STA_Positor IS NOT NULL)
        OR (:NEW.SU_STA_Positor IS NOT NULL AND :OLD.SU_STA_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.SU_STA_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_STA_PositedAt <> :OLD.SU_STA_PositedAt
        OR (:NEW.SU_STA_PositedAt IS NULL AND :OLD.SU_STA_PositedAt IS NOT NULL)
        OR (:NEW.SU_STA_PositedAt IS NOT NULL AND :OLD.SU_STA_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_STA_ChangedAt <> :OLD.SU_STA_ChangedAt
        OR (:NEW.SU_STA_ChangedAt IS NULL AND :OLD.SU_STA_ChangedAt IS NOT NULL)
        OR (:NEW.SU_STA_ChangedAt IS NOT NULL AND :OLD.SU_STA_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_STA_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_STA_Subject_State IS NULL THEN
        v_positing := :NEW.SU_STA_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_STA_Subject_State <> :OLD.SU_STA_Subject_State
        OR (:NEW.SU_STA_Subject_State IS NULL AND :OLD.SU_STA_Subject_State IS NOT NULL)
        OR (:NEW.SU_STA_Subject_State IS NOT NULL AND :OLD.SU_STA_Subject_State IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_STA <> :OLD.Metadata_SU_STA
        OR (:NEW.Metadata_SU_STA IS NULL AND :OLD.Metadata_SU_STA IS NOT NULL)
        OR (:NEW.Metadata_SU_STA IS NOT NULL AND :OLD.Metadata_SU_STA IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_STA
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_STA_changing := :NEW.SU_STA_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_STA_changing := :NEW.SU_STA_ChangedAt;
        ELSE
            v_STA_changing := v_now;
        END IF;
        IF :NEW.SU_STA_Subject_State IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_STA_Subject_State IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_STA_Reliability IS NULL
            OR :OLD.SU_STA_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.SU_STA_Positor IS NULL
            OR :OLD.SU_STA_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_SU_STA_Subject_State(
                    p_owner => COALESCE(:NEW.SU_STA_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_STA_Subject_State,
                    p_changing => v_STA_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_STA_Subject_State IS NULL AND :OLD.SU_STA_Subject_State IS NOT NULL THEN
            ip_SU_STA_Subject_State(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_STA_Subject_State,
                p_changing => :OLD.SU_STA_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_LBL_Subject_Label
    IF (:NEW.SU_LBL_ID <> :OLD.SU_LBL_ID
        OR (:NEW.SU_LBL_ID IS NULL AND :OLD.SU_LBL_ID IS NOT NULL)
        OR (:NEW.SU_LBL_ID IS NOT NULL AND :OLD.SU_LBL_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_LBL_ID is not updatable.');
    END IF;
    IF (:NEW.SU_LBL_SU_ID <> :OLD.SU_LBL_SU_ID
        OR (:NEW.SU_LBL_SU_ID IS NULL AND :OLD.SU_LBL_SU_ID IS NOT NULL)
        OR (:NEW.SU_LBL_SU_ID IS NOT NULL AND :OLD.SU_LBL_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_LBL_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_LBL_Subject_Label, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_LBL_Reliability <> :OLD.SU_LBL_Reliability
        OR (:NEW.SU_LBL_Reliability IS NULL AND :OLD.SU_LBL_Reliability IS NOT NULL)
        OR (:NEW.SU_LBL_Reliability IS NOT NULL AND :OLD.SU_LBL_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_LBL_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_LBL_Reliability;
    END IF;
    IF (:NEW.SU_LBL_Positor <> :OLD.SU_LBL_Positor
        OR (:NEW.SU_LBL_Positor IS NULL AND :OLD.SU_LBL_Positor IS NOT NULL)
        OR (:NEW.SU_LBL_Positor IS NOT NULL AND :OLD.SU_LBL_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.SU_LBL_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_LBL_PositedAt <> :OLD.SU_LBL_PositedAt
        OR (:NEW.SU_LBL_PositedAt IS NULL AND :OLD.SU_LBL_PositedAt IS NOT NULL)
        OR (:NEW.SU_LBL_PositedAt IS NOT NULL AND :OLD.SU_LBL_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_LBL_ChangedAt <> :OLD.SU_LBL_ChangedAt
        OR (:NEW.SU_LBL_ChangedAt IS NULL AND :OLD.SU_LBL_ChangedAt IS NOT NULL)
        OR (:NEW.SU_LBL_ChangedAt IS NOT NULL AND :OLD.SU_LBL_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_LBL_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_LBL_Subject_Label IS NULL THEN
        v_positing := :NEW.SU_LBL_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_LBL_Subject_Label <> :OLD.SU_LBL_Subject_Label
        OR (:NEW.SU_LBL_Subject_Label IS NULL AND :OLD.SU_LBL_Subject_Label IS NOT NULL)
        OR (:NEW.SU_LBL_Subject_Label IS NOT NULL AND :OLD.SU_LBL_Subject_Label IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_LBL <> :OLD.Metadata_SU_LBL
        OR (:NEW.Metadata_SU_LBL IS NULL AND :OLD.Metadata_SU_LBL IS NOT NULL)
        OR (:NEW.Metadata_SU_LBL IS NOT NULL AND :OLD.Metadata_SU_LBL IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_LBL
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_LBL_changing := :NEW.SU_LBL_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_LBL_changing := :NEW.SU_LBL_ChangedAt;
        ELSE
            v_LBL_changing := v_now;
        END IF;
        IF :NEW.SU_LBL_Subject_Label IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_LBL_Subject_Label IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_LBL_Reliability IS NULL
            OR :OLD.SU_LBL_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.SU_LBL_Positor IS NULL
            OR :OLD.SU_LBL_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_SU_LBL_Subject_Label(
                    p_owner => COALESCE(:NEW.SU_LBL_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_LBL_Subject_Label,
                    p_changing => v_LBL_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_LBL_Subject_Label IS NULL AND :OLD.SU_LBL_Subject_Label IS NOT NULL THEN
            ip_SU_LBL_Subject_Label(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_LBL_Subject_Label,
                p_changing => :OLD.SU_LBL_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_TAG_Subject_Tag
    IF (:NEW.SU_TAG_ID <> :OLD.SU_TAG_ID
        OR (:NEW.SU_TAG_ID IS NULL AND :OLD.SU_TAG_ID IS NOT NULL)
        OR (:NEW.SU_TAG_ID IS NOT NULL AND :OLD.SU_TAG_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_TAG_ID is not updatable.');
    END IF;
    IF (:NEW.SU_TAG_SU_ID <> :OLD.SU_TAG_SU_ID
        OR (:NEW.SU_TAG_SU_ID IS NULL AND :OLD.SU_TAG_SU_ID IS NOT NULL)
        OR (:NEW.SU_TAG_SU_ID IS NOT NULL AND :OLD.SU_TAG_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_TAG_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_TAG_Subject_Tag, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_TAG_Reliability <> :OLD.SU_TAG_Reliability
        OR (:NEW.SU_TAG_Reliability IS NULL AND :OLD.SU_TAG_Reliability IS NOT NULL)
        OR (:NEW.SU_TAG_Reliability IS NOT NULL AND :OLD.SU_TAG_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_TAG_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_TAG_Reliability;
    END IF;
    IF (:NEW.SU_TAG_Positor <> :OLD.SU_TAG_Positor
        OR (:NEW.SU_TAG_Positor IS NULL AND :OLD.SU_TAG_Positor IS NOT NULL)
        OR (:NEW.SU_TAG_Positor IS NOT NULL AND :OLD.SU_TAG_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.SU_TAG_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_TAG_PositedAt <> :OLD.SU_TAG_PositedAt
        OR (:NEW.SU_TAG_PositedAt IS NULL AND :OLD.SU_TAG_PositedAt IS NOT NULL)
        OR (:NEW.SU_TAG_PositedAt IS NOT NULL AND :OLD.SU_TAG_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_TAG_ChangedAt <> :OLD.SU_TAG_ChangedAt
        OR (:NEW.SU_TAG_ChangedAt IS NULL AND :OLD.SU_TAG_ChangedAt IS NOT NULL)
        OR (:NEW.SU_TAG_ChangedAt IS NOT NULL AND :OLD.SU_TAG_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_TAG_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_TAG_Subject_Tag IS NULL THEN
        v_positing := :NEW.SU_TAG_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_TAG_Subject_Tag <> :OLD.SU_TAG_Subject_Tag
        OR (:NEW.SU_TAG_Subject_Tag IS NULL AND :OLD.SU_TAG_Subject_Tag IS NOT NULL)
        OR (:NEW.SU_TAG_Subject_Tag IS NOT NULL AND :OLD.SU_TAG_Subject_Tag IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_TAG <> :OLD.Metadata_SU_TAG
        OR (:NEW.Metadata_SU_TAG IS NULL AND :OLD.Metadata_SU_TAG IS NOT NULL)
        OR (:NEW.Metadata_SU_TAG IS NOT NULL AND :OLD.Metadata_SU_TAG IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_TAG
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_TAG_changing := :NEW.SU_TAG_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_TAG_changing := :NEW.SU_TAG_ChangedAt;
        ELSE
            v_TAG_changing := v_now;
        END IF;
        IF :NEW.SU_TAG_Subject_Tag IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_TAG_Subject_Tag IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_TAG_Reliability IS NULL
            OR :OLD.SU_TAG_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.SU_TAG_Positor IS NULL
            OR :OLD.SU_TAG_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_SU_TAG_Subject_Tag(
                    p_owner => COALESCE(:NEW.SU_TAG_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_TAG_Subject_Tag,
                    p_changing => v_TAG_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_TAG_Subject_Tag IS NULL AND :OLD.SU_TAG_Subject_Tag IS NOT NULL THEN
            ip_SU_TAG_Subject_Tag(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_TAG_Subject_Tag,
                p_changing => :OLD.SU_TAG_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_LVL_Subject_Level
    IF (:NEW.SU_LVL_ID <> :OLD.SU_LVL_ID
        OR (:NEW.SU_LVL_ID IS NULL AND :OLD.SU_LVL_ID IS NOT NULL)
        OR (:NEW.SU_LVL_ID IS NOT NULL AND :OLD.SU_LVL_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_LVL_ID is not updatable.');
    END IF;
    IF (:NEW.SU_LVL_SU_ID <> :OLD.SU_LVL_SU_ID
        OR (:NEW.SU_LVL_SU_ID IS NULL AND :OLD.SU_LVL_SU_ID IS NOT NULL)
        OR (:NEW.SU_LVL_SU_ID IS NOT NULL AND :OLD.SU_LVL_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_LVL_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_LVL_Subject_Level, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_LVL_Reliability <> :OLD.SU_LVL_Reliability
        OR (:NEW.SU_LVL_Reliability IS NULL AND :OLD.SU_LVL_Reliability IS NOT NULL)
        OR (:NEW.SU_LVL_Reliability IS NOT NULL AND :OLD.SU_LVL_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_LVL_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_LVL_Reliability;
    END IF;
    IF (:NEW.SU_LVL_Positor <> :OLD.SU_LVL_Positor
        OR (:NEW.SU_LVL_Positor IS NULL AND :OLD.SU_LVL_Positor IS NOT NULL)
        OR (:NEW.SU_LVL_Positor IS NOT NULL AND :OLD.SU_LVL_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.SU_LVL_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_LVL_PositedAt <> :OLD.SU_LVL_PositedAt
        OR (:NEW.SU_LVL_PositedAt IS NULL AND :OLD.SU_LVL_PositedAt IS NOT NULL)
        OR (:NEW.SU_LVL_PositedAt IS NOT NULL AND :OLD.SU_LVL_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_LVL_ChangedAt <> :OLD.SU_LVL_ChangedAt
        OR (:NEW.SU_LVL_ChangedAt IS NULL AND :OLD.SU_LVL_ChangedAt IS NOT NULL)
        OR (:NEW.SU_LVL_ChangedAt IS NOT NULL AND :OLD.SU_LVL_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_LVL_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_LVL_GRD_ID IS NULL THEN
        v_positing := :NEW.SU_LVL_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_LVL_GRD_ID <> :OLD.SU_LVL_GRD_ID
        OR (:NEW.SU_LVL_GRD_ID IS NULL AND :OLD.SU_LVL_GRD_ID IS NOT NULL)
        OR (:NEW.SU_LVL_GRD_ID IS NOT NULL AND :OLD.SU_LVL_GRD_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_LVL <> :OLD.Metadata_SU_LVL
        OR (:NEW.Metadata_SU_LVL IS NULL AND :OLD.Metadata_SU_LVL IS NOT NULL)
        OR (:NEW.Metadata_SU_LVL IS NOT NULL AND :OLD.Metadata_SU_LVL IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_LVL
        END, :NEW.Metadata_SU);
    v_knot_diff := CASE WHEN (:NEW.SU_LVL_GRD_Grade <> :OLD.SU_LVL_GRD_Grade
        OR (:NEW.SU_LVL_GRD_Grade IS NULL AND :OLD.SU_LVL_GRD_Grade IS NOT NULL)
        OR (:NEW.SU_LVL_GRD_Grade IS NOT NULL AND :OLD.SU_LVL_GRD_Grade IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_LVL := :NEW.SU_LVL_GRD_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_LVL := NULL;
        IF :NEW.SU_LVL_GRD_Grade IS NOT NULL THEN
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
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_LVL_changing := :NEW.SU_LVL_ChangedAt;
        ELSIF :OLD.SU_LVL_GRD_ID = v_LVL THEN
            v_LVL_changing := :NEW.SU_LVL_ChangedAt;
        ELSE
            v_LVL_changing := v_now;
        END IF;
        IF v_LVL IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_LVL_GRD_ID IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_LVL_Reliability IS NULL
            OR :OLD.SU_LVL_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.SU_LVL_Positor IS NULL
            OR :OLD.SU_LVL_Positor <> v_positor
            OR :OLD.SU_LVL_GRD_ID <> v_LVL
            THEN
                ip_SU_LVL_Subject_Level(
                    p_owner => COALESCE(:NEW.SU_LVL_SU_ID, :NEW.SU_ID),
                    p_value => v_LVL,
                    p_changing => v_LVL_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.SU_LVL_GRD_ID IS NOT NULL AND (
            :NEW.SU_LVL_GRD_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.SU_LVL_GRD_Grade IS NULL AND :OLD.SU_LVL_GRD_Grade IS NOT NULL
            )
        ) THEN
            ip_SU_LVL_Subject_Level(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_LVL_GRD_ID,
                p_changing => :OLD.SU_LVL_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_TXT_Subject_Text
    IF (:NEW.SU_TXT_ID <> :OLD.SU_TXT_ID
        OR (:NEW.SU_TXT_ID IS NULL AND :OLD.SU_TXT_ID IS NOT NULL)
        OR (:NEW.SU_TXT_ID IS NOT NULL AND :OLD.SU_TXT_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_TXT_ID is not updatable.');
    END IF;
    IF (:NEW.SU_TXT_SU_ID <> :OLD.SU_TXT_SU_ID
        OR (:NEW.SU_TXT_SU_ID IS NULL AND :OLD.SU_TXT_SU_ID IS NOT NULL)
        OR (:NEW.SU_TXT_SU_ID IS NOT NULL AND :OLD.SU_TXT_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_TXT_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_TXT_Subject_Text, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_TXT_Reliability <> :OLD.SU_TXT_Reliability
        OR (:NEW.SU_TXT_Reliability IS NULL AND :OLD.SU_TXT_Reliability IS NOT NULL)
        OR (:NEW.SU_TXT_Reliability IS NOT NULL AND :OLD.SU_TXT_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_TXT_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_TXT_Reliability;
    END IF;
    IF (:NEW.SU_TXT_Positor <> :OLD.SU_TXT_Positor
        OR (:NEW.SU_TXT_Positor IS NULL AND :OLD.SU_TXT_Positor IS NOT NULL)
        OR (:NEW.SU_TXT_Positor IS NOT NULL AND :OLD.SU_TXT_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.SU_TXT_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_TXT_PositedAt <> :OLD.SU_TXT_PositedAt
        OR (:NEW.SU_TXT_PositedAt IS NULL AND :OLD.SU_TXT_PositedAt IS NOT NULL)
        OR (:NEW.SU_TXT_PositedAt IS NOT NULL AND :OLD.SU_TXT_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_TXT_ChangedAt <> :OLD.SU_TXT_ChangedAt
        OR (:NEW.SU_TXT_ChangedAt IS NULL AND :OLD.SU_TXT_ChangedAt IS NOT NULL)
        OR (:NEW.SU_TXT_ChangedAt IS NOT NULL AND :OLD.SU_TXT_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_TXT_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_TXT_Subject_Text IS NULL THEN
        v_positing := :NEW.SU_TXT_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN ((:NEW.SU_TXT_Subject_Text IS NULL AND :OLD.SU_TXT_Subject_Text IS NOT NULL)
        OR (:NEW.SU_TXT_Subject_Text IS NOT NULL AND :OLD.SU_TXT_Subject_Text IS NULL)
        OR (:NEW.SU_TXT_Subject_Text IS NOT NULL AND :OLD.SU_TXT_Subject_Text IS NOT NULL
            AND DBMS_LOB.COMPARE(:NEW.SU_TXT_Subject_Text, :OLD.SU_TXT_Subject_Text) <> 0)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_TXT <> :OLD.Metadata_SU_TXT
        OR (:NEW.Metadata_SU_TXT IS NULL AND :OLD.Metadata_SU_TXT IS NOT NULL)
        OR (:NEW.Metadata_SU_TXT IS NOT NULL AND :OLD.Metadata_SU_TXT IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_TXT
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_TXT_changing := :NEW.SU_TXT_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_TXT_changing := :NEW.SU_TXT_ChangedAt;
        ELSE
            v_TXT_changing := v_now;
        END IF;
        IF :NEW.SU_TXT_Subject_Text IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_TXT_Subject_Text IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_TXT_Reliability IS NULL
            OR :OLD.SU_TXT_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.SU_TXT_Positor IS NULL
            OR :OLD.SU_TXT_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_SU_TXT_Subject_Text(
                    p_owner => COALESCE(:NEW.SU_TXT_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_TXT_Subject_Text,
                    p_changing => v_TXT_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_TXT_Subject_Text IS NULL AND :OLD.SU_TXT_Subject_Text IS NOT NULL THEN
            ip_SU_TXT_Subject_Text(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_TXT_Subject_Text,
                p_changing => :OLD.SU_TXT_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_ASR_Subject_Assessment
    IF (:NEW.SU_ASR_ID <> :OLD.SU_ASR_ID
        OR (:NEW.SU_ASR_ID IS NULL AND :OLD.SU_ASR_ID IS NOT NULL)
        OR (:NEW.SU_ASR_ID IS NOT NULL AND :OLD.SU_ASR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_ASR_ID is not updatable.');
    END IF;
    IF (:NEW.SU_ASR_SU_ID <> :OLD.SU_ASR_SU_ID
        OR (:NEW.SU_ASR_SU_ID IS NULL AND :OLD.SU_ASR_SU_ID IS NOT NULL)
        OR (:NEW.SU_ASR_SU_ID IS NOT NULL AND :OLD.SU_ASR_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_ASR_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_ASR_Subject_Assessment, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_ASR_Reliability <> :OLD.SU_ASR_Reliability
        OR (:NEW.SU_ASR_Reliability IS NULL AND :OLD.SU_ASR_Reliability IS NOT NULL)
        OR (:NEW.SU_ASR_Reliability IS NOT NULL AND :OLD.SU_ASR_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_ASR_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_ASR_Reliability;
    END IF;
    IF (:NEW.SU_ASR_Positor <> :OLD.SU_ASR_Positor
        OR (:NEW.SU_ASR_Positor IS NULL AND :OLD.SU_ASR_Positor IS NOT NULL)
        OR (:NEW.SU_ASR_Positor IS NOT NULL AND :OLD.SU_ASR_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.SU_ASR_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_ASR_PositedAt <> :OLD.SU_ASR_PositedAt
        OR (:NEW.SU_ASR_PositedAt IS NULL AND :OLD.SU_ASR_PositedAt IS NOT NULL)
        OR (:NEW.SU_ASR_PositedAt IS NOT NULL AND :OLD.SU_ASR_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_ASR_ChangedAt <> :OLD.SU_ASR_ChangedAt
        OR (:NEW.SU_ASR_ChangedAt IS NULL AND :OLD.SU_ASR_ChangedAt IS NOT NULL)
        OR (:NEW.SU_ASR_ChangedAt IS NOT NULL AND :OLD.SU_ASR_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_ASR_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_ASR_Subject_Assessment IS NULL THEN
        v_positing := :NEW.SU_ASR_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_ASR_Subject_Assessment <> :OLD.SU_ASR_Subject_Assessment
        OR (:NEW.SU_ASR_Subject_Assessment IS NULL AND :OLD.SU_ASR_Subject_Assessment IS NOT NULL)
        OR (:NEW.SU_ASR_Subject_Assessment IS NOT NULL AND :OLD.SU_ASR_Subject_Assessment IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_ASR <> :OLD.Metadata_SU_ASR
        OR (:NEW.Metadata_SU_ASR IS NULL AND :OLD.Metadata_SU_ASR IS NOT NULL)
        OR (:NEW.Metadata_SU_ASR IS NOT NULL AND :OLD.Metadata_SU_ASR IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_ASR
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_ASR_changing := :NEW.SU_ASR_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_ASR_changing := :NEW.SU_ASR_ChangedAt;
        ELSE
            v_ASR_changing := v_now;
        END IF;
        IF :NEW.SU_ASR_Subject_Assessment IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_ASR_Subject_Assessment IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_ASR_Reliability IS NULL
            OR :OLD.SU_ASR_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.SU_ASR_Positor IS NULL
            OR :OLD.SU_ASR_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_SU_ASR_Subject_Assessment(
                    p_owner => COALESCE(:NEW.SU_ASR_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_ASR_Subject_Assessment,
                    p_changing => v_ASR_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_ASR_Subject_Assessment IS NULL AND :OLD.SU_ASR_Subject_Assessment IS NOT NULL THEN
            ip_SU_ASR_Subject_Assessment(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_ASR_Subject_Assessment,
                p_changing => :OLD.SU_ASR_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- SU_ERS_Subject_Erasable
    IF (:NEW.SU_ERS_ID <> :OLD.SU_ERS_ID
        OR (:NEW.SU_ERS_ID IS NULL AND :OLD.SU_ERS_ID IS NOT NULL)
        OR (:NEW.SU_ERS_ID IS NOT NULL AND :OLD.SU_ERS_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_ERS_ID is not updatable.');
    END IF;
    IF (:NEW.SU_ERS_SU_ID <> :OLD.SU_ERS_SU_ID
        OR (:NEW.SU_ERS_SU_ID IS NULL AND :OLD.SU_ERS_SU_ID IS NOT NULL)
        OR (:NEW.SU_ERS_SU_ID IS NOT NULL AND :OLD.SU_ERS_SU_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column SU_ERS_SU_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of SU_ERS_Subject_Erasable, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.SU_ERS_Reliability <> :OLD.SU_ERS_Reliability
        OR (:NEW.SU_ERS_Reliability IS NULL AND :OLD.SU_ERS_Reliability IS NOT NULL)
        OR (:NEW.SU_ERS_Reliability IS NOT NULL AND :OLD.SU_ERS_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.SU_ERS_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.SU_ERS_Reliability;
    END IF;
    IF (:NEW.SU_ERS_Positor <> :OLD.SU_ERS_Positor
        OR (:NEW.SU_ERS_Positor IS NULL AND :OLD.SU_ERS_Positor IS NOT NULL)
        OR (:NEW.SU_ERS_Positor IS NOT NULL AND :OLD.SU_ERS_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.SU_ERS_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.SU_ERS_PositedAt <> :OLD.SU_ERS_PositedAt
        OR (:NEW.SU_ERS_PositedAt IS NULL AND :OLD.SU_ERS_PositedAt IS NOT NULL)
        OR (:NEW.SU_ERS_PositedAt IS NOT NULL AND :OLD.SU_ERS_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.SU_ERS_ChangedAt <> :OLD.SU_ERS_ChangedAt
        OR (:NEW.SU_ERS_ChangedAt IS NULL AND :OLD.SU_ERS_ChangedAt IS NOT NULL)
        OR (:NEW.SU_ERS_ChangedAt IS NOT NULL AND :OLD.SU_ERS_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.SU_ERS_PositedAt;
    ELSIF v_changing_diff AND :NEW.SU_ERS_Subject_Erasable IS NULL THEN
        v_positing := :NEW.SU_ERS_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.SU_ERS_Subject_Erasable <> :OLD.SU_ERS_Subject_Erasable
        OR (:NEW.SU_ERS_Subject_Erasable IS NULL AND :OLD.SU_ERS_Subject_Erasable IS NOT NULL)
        OR (:NEW.SU_ERS_Subject_Erasable IS NOT NULL AND :OLD.SU_ERS_Subject_Erasable IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_SU_ERS <> :OLD.Metadata_SU_ERS
        OR (:NEW.Metadata_SU_ERS IS NULL AND :OLD.Metadata_SU_ERS IS NOT NULL)
        OR (:NEW.Metadata_SU_ERS IS NOT NULL AND :OLD.Metadata_SU_ERS IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_SU
            ELSE :NEW.Metadata_SU_ERS
        END, :NEW.Metadata_SU);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_ERS_changing := :NEW.SU_ERS_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_ERS_changing := :NEW.SU_ERS_ChangedAt;
        ELSE
            v_ERS_changing := v_now;
        END IF;
        IF :NEW.SU_ERS_Subject_Erasable IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.SU_ERS_Subject_Erasable IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.SU_ERS_Reliability IS NULL
            OR :OLD.SU_ERS_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.SU_ERS_Positor IS NULL
            OR :OLD.SU_ERS_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_SU_ERS_Subject_Erasable(
                    p_owner => COALESCE(:NEW.SU_ERS_SU_ID, :NEW.SU_ID),
                    p_value => :NEW.SU_ERS_Subject_Erasable,
                    p_changing => v_ERS_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.SU_ERS_Subject_Erasable IS NULL AND :OLD.SU_ERS_Subject_Erasable IS NOT NULL THEN
            ip_SU_ERS_Subject_Erasable(
                p_owner => :OLD.SU_ID,
                p_value => :OLD.SU_ERS_Subject_Erasable,
                p_changing => :OLD.SU_ERS_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
END ut_lSU_Subject;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_Subject instead of DELETE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_Subject
INSTEAD OF DELETE ON lSU_Subject
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown of SU_NAM_Subject_Name is retracted
    INSERT INTO SU_NAM_Subject_Name_Annex (
        Metadata_SU_NAM,
        SU_NAM_ID,
        SU_NAM_Positor,
        SU_NAM_PositedAt,
        SU_NAM_Reliability
    )
    SELECT
        :OLD.Metadata_SU_NAM,
        :OLD.SU_NAM_ID,
        COALESCE(:OLD.SU_NAM_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_NAM_Subject_Name_Annex x
            WHERE
                x.SU_NAM_ID = :OLD.SU_NAM_ID
            AND
                x.SU_NAM_Positor = COALESCE(:OLD.SU_NAM_Positor, :OLD.Positor, 0)
            AND
                x.SU_NAM_PositedAt = v_now
        );
    -- what is shown of SU_COD_Subject_Code is retracted
    INSERT INTO SU_COD_Subject_Code_Annex (
        Metadata_SU_COD,
        SU_COD_ID,
        SU_COD_Positor,
        SU_COD_PositedAt,
        SU_COD_Reliability
    )
    SELECT
        :OLD.Metadata_SU_COD,
        :OLD.SU_COD_ID,
        COALESCE(:OLD.SU_COD_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_COD_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_COD_Subject_Code_Annex x
            WHERE
                x.SU_COD_ID = :OLD.SU_COD_ID
            AND
                x.SU_COD_Positor = COALESCE(:OLD.SU_COD_Positor, :OLD.Positor, 0)
            AND
                x.SU_COD_PositedAt = v_now
        );
    -- what is shown of SU_GRD_Subject_Grade is retracted
    INSERT INTO SU_GRD_Subject_Grade_Annex (
        Metadata_SU_GRD,
        SU_GRD_ID,
        SU_GRD_Positor,
        SU_GRD_PositedAt,
        SU_GRD_Reliability
    )
    SELECT
        :OLD.Metadata_SU_GRD,
        :OLD.SU_GRD_ID,
        COALESCE(:OLD.SU_GRD_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_GRD_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_GRD_Subject_Grade_Annex x
            WHERE
                x.SU_GRD_ID = :OLD.SU_GRD_ID
            AND
                x.SU_GRD_Positor = COALESCE(:OLD.SU_GRD_Positor, :OLD.Positor, 0)
            AND
                x.SU_GRD_PositedAt = v_now
        );
    -- what is shown of SU_NOT_Subject_Note is retracted
    INSERT INTO SU_NOT_Subject_Note_Annex (
        Metadata_SU_NOT,
        SU_NOT_ID,
        SU_NOT_Positor,
        SU_NOT_PositedAt,
        SU_NOT_Reliability
    )
    SELECT
        :OLD.Metadata_SU_NOT,
        :OLD.SU_NOT_ID,
        COALESCE(:OLD.SU_NOT_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_NOT_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_NOT_Subject_Note_Annex x
            WHERE
                x.SU_NOT_ID = :OLD.SU_NOT_ID
            AND
                x.SU_NOT_Positor = COALESCE(:OLD.SU_NOT_Positor, :OLD.Positor, 0)
            AND
                x.SU_NOT_PositedAt = v_now
        );
    -- what is shown of SU_TTL_Subject_Title is retracted
    INSERT INTO SU_TTL_Subject_Title_Annex (
        Metadata_SU_TTL,
        SU_TTL_ID,
        SU_TTL_Positor,
        SU_TTL_PositedAt,
        SU_TTL_Reliability
    )
    SELECT
        :OLD.Metadata_SU_TTL,
        :OLD.SU_TTL_ID,
        COALESCE(:OLD.SU_TTL_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_TTL_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_TTL_Subject_Title_Annex x
            WHERE
                x.SU_TTL_ID = :OLD.SU_TTL_ID
            AND
                x.SU_TTL_Positor = COALESCE(:OLD.SU_TTL_Positor, :OLD.Positor, 0)
            AND
                x.SU_TTL_PositedAt = v_now
        );
    -- what is shown of SU_STA_Subject_State is retracted
    INSERT INTO SU_STA_Subject_State_Annex (
        Metadata_SU_STA,
        SU_STA_ID,
        SU_STA_Positor,
        SU_STA_PositedAt,
        SU_STA_Reliability
    )
    SELECT
        :OLD.Metadata_SU_STA,
        :OLD.SU_STA_ID,
        COALESCE(:OLD.SU_STA_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_STA_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_STA_Subject_State_Annex x
            WHERE
                x.SU_STA_ID = :OLD.SU_STA_ID
            AND
                x.SU_STA_Positor = COALESCE(:OLD.SU_STA_Positor, :OLD.Positor, 0)
            AND
                x.SU_STA_PositedAt = v_now
        );
    -- what is shown of SU_LBL_Subject_Label is retracted
    INSERT INTO SU_LBL_Subject_Label_Annex (
        Metadata_SU_LBL,
        SU_LBL_ID,
        SU_LBL_Positor,
        SU_LBL_PositedAt,
        SU_LBL_Reliability
    )
    SELECT
        :OLD.Metadata_SU_LBL,
        :OLD.SU_LBL_ID,
        COALESCE(:OLD.SU_LBL_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_LBL_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_LBL_Subject_Label_Annex x
            WHERE
                x.SU_LBL_ID = :OLD.SU_LBL_ID
            AND
                x.SU_LBL_Positor = COALESCE(:OLD.SU_LBL_Positor, :OLD.Positor, 0)
            AND
                x.SU_LBL_PositedAt = v_now
        );
    -- what is shown of SU_TAG_Subject_Tag is retracted
    INSERT INTO SU_TAG_Subject_Tag_Annex (
        Metadata_SU_TAG,
        SU_TAG_ID,
        SU_TAG_Positor,
        SU_TAG_PositedAt,
        SU_TAG_Reliability
    )
    SELECT
        :OLD.Metadata_SU_TAG,
        :OLD.SU_TAG_ID,
        COALESCE(:OLD.SU_TAG_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_TAG_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_TAG_Subject_Tag_Annex x
            WHERE
                x.SU_TAG_ID = :OLD.SU_TAG_ID
            AND
                x.SU_TAG_Positor = COALESCE(:OLD.SU_TAG_Positor, :OLD.Positor, 0)
            AND
                x.SU_TAG_PositedAt = v_now
        );
    -- what is shown of SU_LVL_Subject_Level is retracted
    INSERT INTO SU_LVL_Subject_Level_Annex (
        Metadata_SU_LVL,
        SU_LVL_ID,
        SU_LVL_Positor,
        SU_LVL_PositedAt,
        SU_LVL_Reliability
    )
    SELECT
        :OLD.Metadata_SU_LVL,
        :OLD.SU_LVL_ID,
        COALESCE(:OLD.SU_LVL_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_LVL_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_LVL_Subject_Level_Annex x
            WHERE
                x.SU_LVL_ID = :OLD.SU_LVL_ID
            AND
                x.SU_LVL_Positor = COALESCE(:OLD.SU_LVL_Positor, :OLD.Positor, 0)
            AND
                x.SU_LVL_PositedAt = v_now
        );
    -- what is shown of SU_TXT_Subject_Text is retracted
    INSERT INTO SU_TXT_Subject_Text_Annex (
        Metadata_SU_TXT,
        SU_TXT_ID,
        SU_TXT_Positor,
        SU_TXT_PositedAt,
        SU_TXT_Reliability
    )
    SELECT
        :OLD.Metadata_SU_TXT,
        :OLD.SU_TXT_ID,
        COALESCE(:OLD.SU_TXT_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_TXT_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_TXT_Subject_Text_Annex x
            WHERE
                x.SU_TXT_ID = :OLD.SU_TXT_ID
            AND
                x.SU_TXT_Positor = COALESCE(:OLD.SU_TXT_Positor, :OLD.Positor, 0)
            AND
                x.SU_TXT_PositedAt = v_now
        );
    -- what is shown of SU_ASR_Subject_Assessment is retracted
    INSERT INTO SU_ASR_Subject_Assessment_Annex (
        Metadata_SU_ASR,
        SU_ASR_ID,
        SU_ASR_Positor,
        SU_ASR_PositedAt,
        SU_ASR_Reliability
    )
    SELECT
        :OLD.Metadata_SU_ASR,
        :OLD.SU_ASR_ID,
        COALESCE(:OLD.SU_ASR_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_ASR_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_ASR_Subject_Assessment_Annex x
            WHERE
                x.SU_ASR_ID = :OLD.SU_ASR_ID
            AND
                x.SU_ASR_Positor = COALESCE(:OLD.SU_ASR_Positor, :OLD.Positor, 0)
            AND
                x.SU_ASR_PositedAt = v_now
        );
    -- what is shown of SU_ERS_Subject_Erasable is retracted
    INSERT INTO SU_ERS_Subject_Erasable_Annex (
        Metadata_SU_ERS,
        SU_ERS_ID,
        SU_ERS_Positor,
        SU_ERS_PositedAt,
        SU_ERS_Reliability
    )
    SELECT
        :OLD.Metadata_SU_ERS,
        :OLD.SU_ERS_ID,
        COALESCE(:OLD.SU_ERS_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.SU_ERS_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                SU_ERS_Subject_Erasable_Annex x
            WHERE
                x.SU_ERS_ID = :OLD.SU_ERS_ID
            AND
                x.SU_ERS_Positor = COALESCE(:OLD.SU_ERS_Positor, :OLD.Positor, 0)
            AND
                x.SU_ERS_PositedAt = v_now
        );
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
            p_positor => COALESCE(:NEW.OB_NAM_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.OB_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.OB_NAM_Reliability, :NEW.Reliability, 1),
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
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(10);
    v_anchor_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
BEGIN
    IF (:NEW.OB_ID <> :OLD.OB_ID
        OR (:NEW.OB_ID IS NULL AND :OLD.OB_ID IS NOT NULL)
        OR (:NEW.OB_ID IS NOT NULL AND :OLD.OB_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column OB_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    v_anchor_meta_diff := CASE WHEN (:NEW.Metadata_OB <> :OLD.Metadata_OB
        OR (:NEW.Metadata_OB IS NULL AND :OLD.Metadata_OB IS NOT NULL)
        OR (:NEW.Metadata_OB IS NOT NULL AND :OLD.Metadata_OB IS NULL)) THEN TRUE ELSE FALSE END;
    -- OB_NAM_Object_Name
    IF (:NEW.OB_NAM_ID <> :OLD.OB_NAM_ID
        OR (:NEW.OB_NAM_ID IS NULL AND :OLD.OB_NAM_ID IS NOT NULL)
        OR (:NEW.OB_NAM_ID IS NOT NULL AND :OLD.OB_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column OB_NAM_ID is not updatable.');
    END IF;
    IF (:NEW.OB_NAM_OB_ID <> :OLD.OB_NAM_OB_ID
        OR (:NEW.OB_NAM_OB_ID IS NULL AND :OLD.OB_NAM_OB_ID IS NOT NULL)
        OR (:NEW.OB_NAM_OB_ID IS NOT NULL AND :OLD.OB_NAM_OB_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column OB_NAM_OB_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of OB_NAM_Object_Name, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.OB_NAM_Reliability <> :OLD.OB_NAM_Reliability
        OR (:NEW.OB_NAM_Reliability IS NULL AND :OLD.OB_NAM_Reliability IS NOT NULL)
        OR (:NEW.OB_NAM_Reliability IS NOT NULL AND :OLD.OB_NAM_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.OB_NAM_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.OB_NAM_Reliability;
    END IF;
    IF (:NEW.OB_NAM_Positor <> :OLD.OB_NAM_Positor
        OR (:NEW.OB_NAM_Positor IS NULL AND :OLD.OB_NAM_Positor IS NOT NULL)
        OR (:NEW.OB_NAM_Positor IS NOT NULL AND :OLD.OB_NAM_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.OB_NAM_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.OB_NAM_PositedAt <> :OLD.OB_NAM_PositedAt
        OR (:NEW.OB_NAM_PositedAt IS NULL AND :OLD.OB_NAM_PositedAt IS NOT NULL)
        OR (:NEW.OB_NAM_PositedAt IS NOT NULL AND :OLD.OB_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.OB_NAM_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.OB_NAM_Object_Name <> :OLD.OB_NAM_Object_Name
        OR (:NEW.OB_NAM_Object_Name IS NULL AND :OLD.OB_NAM_Object_Name IS NOT NULL)
        OR (:NEW.OB_NAM_Object_Name IS NOT NULL AND :OLD.OB_NAM_Object_Name IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_OB_NAM <> :OLD.Metadata_OB_NAM
        OR (:NEW.Metadata_OB_NAM IS NULL AND :OLD.Metadata_OB_NAM IS NOT NULL)
        OR (:NEW.Metadata_OB_NAM IS NOT NULL AND :OLD.Metadata_OB_NAM IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_OB
            ELSE :NEW.Metadata_OB_NAM
        END, :NEW.Metadata_OB);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.OB_NAM_Object_Name IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.OB_NAM_Object_Name IS NULL
            OR v_positing_diff
            OR :OLD.OB_NAM_Reliability IS NULL
            OR :OLD.OB_NAM_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.OB_NAM_Positor IS NULL
            OR :OLD.OB_NAM_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_OB_NAM_Object_Name(
                    p_owner => COALESCE(:NEW.OB_NAM_OB_ID, :NEW.OB_ID),
                    p_value => :NEW.OB_NAM_Object_Name,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.OB_NAM_Object_Name IS NULL AND :OLD.OB_NAM_Object_Name IS NOT NULL THEN
            ip_OB_NAM_Object_Name(
                p_owner => :OLD.OB_ID,
                p_value => :OLD.OB_NAM_Object_Name,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
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
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown of OB_NAM_Object_Name is retracted
    INSERT INTO OB_NAM_Object_Name_Annex (
        Metadata_OB_NAM,
        OB_NAM_ID,
        OB_NAM_Positor,
        OB_NAM_PositedAt,
        OB_NAM_Reliability
    )
    SELECT
        :OLD.Metadata_OB_NAM,
        :OLD.OB_NAM_ID,
        COALESCE(:OLD.OB_NAM_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.OB_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                OB_NAM_Object_Name_Annex x
            WHERE
                x.OB_NAM_ID = :OLD.OB_NAM_ID
            AND
                x.OB_NAM_Positor = COALESCE(:OLD.OB_NAM_Positor, :OLD.Positor, 0)
            AND
                x.OB_NAM_PositedAt = v_now
        );
END dt_lOB_Object;
/
