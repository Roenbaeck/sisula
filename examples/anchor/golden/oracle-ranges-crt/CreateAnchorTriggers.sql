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
-- it_lST_Stage instead of INSERT trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.it_lST_Stage
INSTEAD OF INSERT ON anchors.lST_Stage
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
    v_AVG number(3);
    v_MIN number(3);
BEGIN
    v_id := :NEW.ST_ID;
    IF v_id IS NULL THEN
        INSERT INTO anchors.ST_Stage (
            Metadata_ST
        )
        VALUES (
            :NEW.Metadata_ST
        )
        RETURNING ST_ID INTO v_id;
    END IF;
    IF :NEW.ST_NAM_Stage_Name IS NOT NULL THEN
        attributes.ip_ST_NAM_Stage_Name(
            p_owner => COALESCE(:NEW.ST_NAM_ST_ID, v_id),
            p_value => :NEW.ST_NAM_Stage_Name,
            p_changing => COALESCE(:NEW.ST_NAM_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.ST_NAM_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.ST_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_NAM_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_ST_NAM, :NEW.Metadata_ST)
        );
    END IF;
    IF :NEW.ST_LOC_Stage_Location IS NOT NULL THEN
        attributes.ip_ST_LOC_Stage_Location(
            p_owner => COALESCE(:NEW.ST_LOC_ST_ID, v_id),
            p_value => :NEW.ST_LOC_Stage_Location,
            p_positor => COALESCE(:NEW.ST_LOC_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.ST_LOC_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_LOC_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_ST_LOC, :NEW.Metadata_ST)
        );
    END IF;
    v_AVG := :NEW.ST_AVG_UTL_ID;
    IF v_AVG IS NULL AND :NEW.ST_AVG_UTL_Utilization IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                knots.UTL_Utilization k
            WHERE
                k.UTL_Utilization = :NEW.ST_AVG_UTL_Utilization
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_AVG := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_AVG IS NOT NULL THEN
        attributes.ip_ST_AVG_Stage_Average(
            p_owner => COALESCE(:NEW.ST_AVG_ST_ID, v_id),
            p_value => v_AVG,
            p_changing => COALESCE(:NEW.ST_AVG_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.ST_AVG_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.ST_AVG_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_AVG_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_ST_AVG, :NEW.Metadata_ST)
        );
    END IF;
    v_MIN := :NEW.ST_MIN_UTL_ID;
    IF v_MIN IS NULL AND :NEW.ST_MIN_UTL_Utilization IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                knots.UTL_Utilization k
            WHERE
                k.UTL_Utilization = :NEW.ST_MIN_UTL_Utilization
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_MIN := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_MIN IS NOT NULL THEN
        attributes.ip_ST_MIN_Stage_Minimum(
            p_owner => COALESCE(:NEW.ST_MIN_ST_ID, v_id),
            p_value => v_MIN,
            p_positor => COALESCE(:NEW.ST_MIN_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.ST_MIN_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_MIN_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_ST_MIN, :NEW.Metadata_ST)
        );
    END IF;
END it_lST_Stage;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Stage instead of UPDATE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.ut_lST_Stage
INSTEAD OF UPDATE ON anchors.lST_Stage
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(19);
    v_anchor_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_NAM_changing timestamp;
    v_AVG number(3);
    v_AVG_changing timestamp;
    v_MIN number(3);
BEGIN
    IF (:NEW.ST_ID <> :OLD.ST_ID
        OR (:NEW.ST_ID IS NULL AND :OLD.ST_ID IS NOT NULL)
        OR (:NEW.ST_ID IS NOT NULL AND :OLD.ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Confidence <> :OLD.Confidence
        OR (:NEW.Confidence IS NULL AND :OLD.Confidence IS NOT NULL)
        OR (:NEW.Confidence IS NOT NULL AND :OLD.Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    v_anchor_meta_diff := CASE WHEN (:NEW.Metadata_ST <> :OLD.Metadata_ST
        OR (:NEW.Metadata_ST IS NULL AND :OLD.Metadata_ST IS NOT NULL)
        OR (:NEW.Metadata_ST IS NOT NULL AND :OLD.Metadata_ST IS NULL)) THEN TRUE ELSE FALSE END;
    -- ST_NAM_Stage_Name
    IF (:NEW.ST_NAM_ID <> :OLD.ST_NAM_ID
        OR (:NEW.ST_NAM_ID IS NULL AND :OLD.ST_NAM_ID IS NOT NULL)
        OR (:NEW.ST_NAM_ID IS NOT NULL AND :OLD.ST_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_NAM_ID is not updatable.');
    END IF;
    IF (:NEW.ST_NAM_ST_ID <> :OLD.ST_NAM_ST_ID
        OR (:NEW.ST_NAM_ST_ID IS NULL AND :OLD.ST_NAM_ST_ID IS NOT NULL)
        OR (:NEW.ST_NAM_ST_ID IS NOT NULL AND :OLD.ST_NAM_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_NAM_ST_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_NAM_Stage_Name, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_NAM_Confidence <> :OLD.ST_NAM_Confidence
        OR (:NEW.ST_NAM_Confidence IS NULL AND :OLD.ST_NAM_Confidence IS NOT NULL)
        OR (:NEW.ST_NAM_Confidence IS NOT NULL AND :OLD.ST_NAM_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_NAM_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.ST_NAM_Confidence;
    END IF;
    IF (:NEW.ST_NAM_Who <> :OLD.ST_NAM_Who
        OR (:NEW.ST_NAM_Who IS NULL AND :OLD.ST_NAM_Who IS NOT NULL)
        OR (:NEW.ST_NAM_Who IS NOT NULL AND :OLD.ST_NAM_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_NAM_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_NAM_PositedAt <> :OLD.ST_NAM_PositedAt
        OR (:NEW.ST_NAM_PositedAt IS NULL AND :OLD.ST_NAM_PositedAt IS NOT NULL)
        OR (:NEW.ST_NAM_PositedAt IS NOT NULL AND :OLD.ST_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.ST_NAM_ChangedAt <> :OLD.ST_NAM_ChangedAt
        OR (:NEW.ST_NAM_ChangedAt IS NULL AND :OLD.ST_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.ST_NAM_ChangedAt IS NOT NULL AND :OLD.ST_NAM_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_NAM_PositedAt;
    ELSIF v_changing_diff AND :NEW.ST_NAM_Stage_Name IS NULL THEN
        v_positing := :NEW.ST_NAM_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.ST_NAM_Stage_Name <> :OLD.ST_NAM_Stage_Name
        OR (:NEW.ST_NAM_Stage_Name IS NULL AND :OLD.ST_NAM_Stage_Name IS NOT NULL)
        OR (:NEW.ST_NAM_Stage_Name IS NOT NULL AND :OLD.ST_NAM_Stage_Name IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_ST_NAM <> :OLD.Metadata_ST_NAM
        OR (:NEW.Metadata_ST_NAM IS NULL AND :OLD.Metadata_ST_NAM IS NOT NULL)
        OR (:NEW.Metadata_ST_NAM IS NOT NULL AND :OLD.Metadata_ST_NAM IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_ST
            ELSE :NEW.Metadata_ST_NAM
        END, :NEW.Metadata_ST);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_NAM_changing := :NEW.ST_NAM_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_NAM_changing := :NEW.ST_NAM_ChangedAt;
        ELSE
            v_NAM_changing := v_now;
        END IF;
        IF :NEW.ST_NAM_Stage_Name IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.ST_NAM_Stage_Name IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.ST_NAM_Confidence IS NULL
            OR :OLD.ST_NAM_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.ST_NAM_Who IS NULL
            OR :OLD.ST_NAM_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_ST_NAM_Stage_Name(
                    p_owner => COALESCE(:NEW.ST_NAM_ST_ID, :NEW.ST_ID),
                    p_value => :NEW.ST_NAM_Stage_Name,
                    p_changing => v_NAM_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.ST_NAM_Stage_Name IS NULL AND :OLD.ST_NAM_Stage_Name IS NOT NULL THEN
            attributes.ip_ST_NAM_Stage_Name(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_NAM_Stage_Name,
                p_changing => :OLD.ST_NAM_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- ST_LOC_Stage_Location
    IF (:NEW.ST_LOC_ID <> :OLD.ST_LOC_ID
        OR (:NEW.ST_LOC_ID IS NULL AND :OLD.ST_LOC_ID IS NOT NULL)
        OR (:NEW.ST_LOC_ID IS NOT NULL AND :OLD.ST_LOC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_LOC_ID is not updatable.');
    END IF;
    IF (:NEW.ST_LOC_ST_ID <> :OLD.ST_LOC_ST_ID
        OR (:NEW.ST_LOC_ST_ID IS NULL AND :OLD.ST_LOC_ST_ID IS NOT NULL)
        OR (:NEW.ST_LOC_ST_ID IS NOT NULL AND :OLD.ST_LOC_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_LOC_ST_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_LOC_Stage_Location, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_LOC_Confidence <> :OLD.ST_LOC_Confidence
        OR (:NEW.ST_LOC_Confidence IS NULL AND :OLD.ST_LOC_Confidence IS NOT NULL)
        OR (:NEW.ST_LOC_Confidence IS NOT NULL AND :OLD.ST_LOC_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_LOC_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.ST_LOC_Confidence;
    END IF;
    IF (:NEW.ST_LOC_Who <> :OLD.ST_LOC_Who
        OR (:NEW.ST_LOC_Who IS NULL AND :OLD.ST_LOC_Who IS NOT NULL)
        OR (:NEW.ST_LOC_Who IS NOT NULL AND :OLD.ST_LOC_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_LOC_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_LOC_PositedAt <> :OLD.ST_LOC_PositedAt
        OR (:NEW.ST_LOC_PositedAt IS NULL AND :OLD.ST_LOC_PositedAt IS NOT NULL)
        OR (:NEW.ST_LOC_PositedAt IS NOT NULL AND :OLD.ST_LOC_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_LOC_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.ST_LOC_Stage_Location <> :OLD.ST_LOC_Stage_Location
        OR (:NEW.ST_LOC_Stage_Location IS NULL AND :OLD.ST_LOC_Stage_Location IS NOT NULL)
        OR (:NEW.ST_LOC_Stage_Location IS NOT NULL AND :OLD.ST_LOC_Stage_Location IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_ST_LOC <> :OLD.Metadata_ST_LOC
        OR (:NEW.Metadata_ST_LOC IS NULL AND :OLD.Metadata_ST_LOC IS NOT NULL)
        OR (:NEW.Metadata_ST_LOC IS NOT NULL AND :OLD.Metadata_ST_LOC IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_ST
            ELSE :NEW.Metadata_ST_LOC
        END, :NEW.Metadata_ST);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.ST_LOC_Stage_Location IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.ST_LOC_Stage_Location IS NULL
            OR v_positing_diff
            OR :OLD.ST_LOC_Confidence IS NULL
            OR :OLD.ST_LOC_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.ST_LOC_Who IS NULL
            OR :OLD.ST_LOC_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_ST_LOC_Stage_Location(
                    p_owner => COALESCE(:NEW.ST_LOC_ST_ID, :NEW.ST_ID),
                    p_value => :NEW.ST_LOC_Stage_Location,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.ST_LOC_Stage_Location IS NULL AND :OLD.ST_LOC_Stage_Location IS NOT NULL THEN
            attributes.ip_ST_LOC_Stage_Location(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_LOC_Stage_Location,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- ST_AVG_Stage_Average
    IF (:NEW.ST_AVG_ID <> :OLD.ST_AVG_ID
        OR (:NEW.ST_AVG_ID IS NULL AND :OLD.ST_AVG_ID IS NOT NULL)
        OR (:NEW.ST_AVG_ID IS NOT NULL AND :OLD.ST_AVG_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_AVG_ID is not updatable.');
    END IF;
    IF (:NEW.ST_AVG_ST_ID <> :OLD.ST_AVG_ST_ID
        OR (:NEW.ST_AVG_ST_ID IS NULL AND :OLD.ST_AVG_ST_ID IS NOT NULL)
        OR (:NEW.ST_AVG_ST_ID IS NOT NULL AND :OLD.ST_AVG_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_AVG_ST_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_AVG_Stage_Average, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_AVG_Confidence <> :OLD.ST_AVG_Confidence
        OR (:NEW.ST_AVG_Confidence IS NULL AND :OLD.ST_AVG_Confidence IS NOT NULL)
        OR (:NEW.ST_AVG_Confidence IS NOT NULL AND :OLD.ST_AVG_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_AVG_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.ST_AVG_Confidence;
    END IF;
    IF (:NEW.ST_AVG_Who <> :OLD.ST_AVG_Who
        OR (:NEW.ST_AVG_Who IS NULL AND :OLD.ST_AVG_Who IS NOT NULL)
        OR (:NEW.ST_AVG_Who IS NOT NULL AND :OLD.ST_AVG_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_AVG_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_AVG_PositedAt <> :OLD.ST_AVG_PositedAt
        OR (:NEW.ST_AVG_PositedAt IS NULL AND :OLD.ST_AVG_PositedAt IS NOT NULL)
        OR (:NEW.ST_AVG_PositedAt IS NOT NULL AND :OLD.ST_AVG_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
        OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
        OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_AVG_PositedAt;
    ELSIF v_changing_diff AND :NEW.ST_AVG_UTL_ID IS NULL THEN
        v_positing := :NEW.ST_AVG_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.ST_AVG_UTL_ID <> :OLD.ST_AVG_UTL_ID
        OR (:NEW.ST_AVG_UTL_ID IS NULL AND :OLD.ST_AVG_UTL_ID IS NOT NULL)
        OR (:NEW.ST_AVG_UTL_ID IS NOT NULL AND :OLD.ST_AVG_UTL_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_ST_AVG <> :OLD.Metadata_ST_AVG
        OR (:NEW.Metadata_ST_AVG IS NULL AND :OLD.Metadata_ST_AVG IS NOT NULL)
        OR (:NEW.Metadata_ST_AVG IS NOT NULL AND :OLD.Metadata_ST_AVG IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_ST
            ELSE :NEW.Metadata_ST_AVG
        END, :NEW.Metadata_ST);
    v_knot_diff := CASE WHEN (:NEW.ST_AVG_UTL_Utilization <> :OLD.ST_AVG_UTL_Utilization
        OR (:NEW.ST_AVG_UTL_Utilization IS NULL AND :OLD.ST_AVG_UTL_Utilization IS NOT NULL)
        OR (:NEW.ST_AVG_UTL_Utilization IS NOT NULL AND :OLD.ST_AVG_UTL_Utilization IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_AVG := :NEW.ST_AVG_UTL_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_AVG := NULL;
        IF :NEW.ST_AVG_UTL_Utilization IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    knots.UTL_Utilization k
                WHERE
                    k.UTL_Utilization = :NEW.ST_AVG_UTL_Utilization
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_AVG := kv.UTL_ID;
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
            v_AVG_changing := :NEW.ST_AVG_ChangedAt;
        ELSIF :OLD.ST_AVG_UTL_ID = v_AVG THEN
            v_AVG_changing := :NEW.ST_AVG_ChangedAt;
        ELSE
            v_AVG_changing := v_now;
        END IF;
        IF v_AVG IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.ST_AVG_UTL_ID IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.ST_AVG_Confidence IS NULL
            OR :OLD.ST_AVG_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.ST_AVG_Who IS NULL
            OR :OLD.ST_AVG_Who <> v_positor
            OR :OLD.ST_AVG_UTL_ID <> v_AVG
            THEN
                attributes.ip_ST_AVG_Stage_Average(
                    p_owner => COALESCE(:NEW.ST_AVG_ST_ID, :NEW.ST_ID),
                    p_value => v_AVG,
                    p_changing => v_AVG_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.ST_AVG_UTL_ID IS NOT NULL AND (
            :NEW.ST_AVG_UTL_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.ST_AVG_UTL_Utilization IS NULL AND :OLD.ST_AVG_UTL_Utilization IS NOT NULL
            )
        ) THEN
            attributes.ip_ST_AVG_Stage_Average(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_AVG_UTL_ID,
                p_changing => :OLD.ST_AVG_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- ST_MIN_Stage_Minimum
    IF (:NEW.ST_MIN_ID <> :OLD.ST_MIN_ID
        OR (:NEW.ST_MIN_ID IS NULL AND :OLD.ST_MIN_ID IS NOT NULL)
        OR (:NEW.ST_MIN_ID IS NOT NULL AND :OLD.ST_MIN_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_MIN_ID is not updatable.');
    END IF;
    IF (:NEW.ST_MIN_ST_ID <> :OLD.ST_MIN_ST_ID
        OR (:NEW.ST_MIN_ST_ID IS NULL AND :OLD.ST_MIN_ST_ID IS NOT NULL)
        OR (:NEW.ST_MIN_ST_ID IS NOT NULL AND :OLD.ST_MIN_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_MIN_ST_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_MIN_Stage_Minimum, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_MIN_Confidence <> :OLD.ST_MIN_Confidence
        OR (:NEW.ST_MIN_Confidence IS NULL AND :OLD.ST_MIN_Confidence IS NOT NULL)
        OR (:NEW.ST_MIN_Confidence IS NOT NULL AND :OLD.ST_MIN_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_MIN_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.ST_MIN_Confidence;
    END IF;
    IF (:NEW.ST_MIN_Who <> :OLD.ST_MIN_Who
        OR (:NEW.ST_MIN_Who IS NULL AND :OLD.ST_MIN_Who IS NOT NULL)
        OR (:NEW.ST_MIN_Who IS NOT NULL AND :OLD.ST_MIN_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_MIN_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_MIN_PositedAt <> :OLD.ST_MIN_PositedAt
        OR (:NEW.ST_MIN_PositedAt IS NULL AND :OLD.ST_MIN_PositedAt IS NOT NULL)
        OR (:NEW.ST_MIN_PositedAt IS NOT NULL AND :OLD.ST_MIN_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_MIN_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.ST_MIN_UTL_ID <> :OLD.ST_MIN_UTL_ID
        OR (:NEW.ST_MIN_UTL_ID IS NULL AND :OLD.ST_MIN_UTL_ID IS NOT NULL)
        OR (:NEW.ST_MIN_UTL_ID IS NOT NULL AND :OLD.ST_MIN_UTL_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_ST_MIN <> :OLD.Metadata_ST_MIN
        OR (:NEW.Metadata_ST_MIN IS NULL AND :OLD.Metadata_ST_MIN IS NOT NULL)
        OR (:NEW.Metadata_ST_MIN IS NOT NULL AND :OLD.Metadata_ST_MIN IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_ST
            ELSE :NEW.Metadata_ST_MIN
        END, :NEW.Metadata_ST);
    v_knot_diff := CASE WHEN (:NEW.ST_MIN_UTL_Utilization <> :OLD.ST_MIN_UTL_Utilization
        OR (:NEW.ST_MIN_UTL_Utilization IS NULL AND :OLD.ST_MIN_UTL_Utilization IS NOT NULL)
        OR (:NEW.ST_MIN_UTL_Utilization IS NOT NULL AND :OLD.ST_MIN_UTL_Utilization IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_MIN := :NEW.ST_MIN_UTL_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_MIN := NULL;
        IF :NEW.ST_MIN_UTL_Utilization IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    knots.UTL_Utilization k
                WHERE
                    k.UTL_Utilization = :NEW.ST_MIN_UTL_Utilization
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_MIN := kv.UTL_ID;
            END LOOP;
        END IF;
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF v_MIN IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.ST_MIN_UTL_ID IS NULL
            OR v_positing_diff
            OR :OLD.ST_MIN_Confidence IS NULL
            OR :OLD.ST_MIN_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.ST_MIN_Who IS NULL
            OR :OLD.ST_MIN_Who <> v_positor
            OR :OLD.ST_MIN_UTL_ID <> v_MIN
            THEN
                attributes.ip_ST_MIN_Stage_Minimum(
                    p_owner => COALESCE(:NEW.ST_MIN_ST_ID, :NEW.ST_ID),
                    p_value => v_MIN,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.ST_MIN_UTL_ID IS NOT NULL AND (
            :NEW.ST_MIN_UTL_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.ST_MIN_UTL_Utilization IS NULL AND :OLD.ST_MIN_UTL_Utilization IS NOT NULL
            )
        ) THEN
            attributes.ip_ST_MIN_Stage_Minimum(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_MIN_UTL_ID,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
END ut_lST_Stage;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Stage instead of DELETE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.dt_lST_Stage
INSTEAD OF DELETE ON anchors.lST_Stage
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of ST_NAM_Stage_Name is retracted
    INSERT INTO attributes.ST_NAM_Stage_Name_Meta (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_Who,
        ST_NAM_PositedAt,
        ST_NAM_Confidence
    )
    SELECT
        :OLD.Metadata_ST_NAM,
        :OLD.ST_NAM_ID,
        COALESCE(:OLD.ST_NAM_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.ST_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.ST_NAM_Stage_Name_Meta x
            WHERE
                x.ST_NAM_ID = :OLD.ST_NAM_ID
            AND
                x.ST_NAM_Who = COALESCE(:OLD.ST_NAM_Who, :OLD.Who, 0)
            AND
                x.ST_NAM_PositedAt = v_now
        );
    -- what is shown of ST_LOC_Stage_Location is retracted
    INSERT INTO attributes.ST_LOC_Stage_Location_Meta (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_Who,
        ST_LOC_PositedAt,
        ST_LOC_Confidence
    )
    SELECT
        :OLD.Metadata_ST_LOC,
        :OLD.ST_LOC_ID,
        COALESCE(:OLD.ST_LOC_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.ST_LOC_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.ST_LOC_Stage_Location_Meta x
            WHERE
                x.ST_LOC_ID = :OLD.ST_LOC_ID
            AND
                x.ST_LOC_Who = COALESCE(:OLD.ST_LOC_Who, :OLD.Who, 0)
            AND
                x.ST_LOC_PositedAt = v_now
        );
    -- what is shown of ST_AVG_Stage_Average is retracted
    INSERT INTO attributes.ST_AVG_Stage_Average_Meta (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_Who,
        ST_AVG_PositedAt,
        ST_AVG_Confidence
    )
    SELECT
        :OLD.Metadata_ST_AVG,
        :OLD.ST_AVG_ID,
        COALESCE(:OLD.ST_AVG_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.ST_AVG_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.ST_AVG_Stage_Average_Meta x
            WHERE
                x.ST_AVG_ID = :OLD.ST_AVG_ID
            AND
                x.ST_AVG_Who = COALESCE(:OLD.ST_AVG_Who, :OLD.Who, 0)
            AND
                x.ST_AVG_PositedAt = v_now
        );
    -- what is shown of ST_MIN_Stage_Minimum is retracted
    INSERT INTO attributes.ST_MIN_Stage_Minimum_Meta (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_Who,
        ST_MIN_PositedAt,
        ST_MIN_Confidence
    )
    SELECT
        :OLD.Metadata_ST_MIN,
        :OLD.ST_MIN_ID,
        COALESCE(:OLD.ST_MIN_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.ST_MIN_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.ST_MIN_Stage_Minimum_Meta x
            WHERE
                x.ST_MIN_ID = :OLD.ST_MIN_ID
            AND
                x.ST_MIN_Who = COALESCE(:OLD.ST_MIN_Who, :OLD.Who, 0)
            AND
                x.ST_MIN_PositedAt = v_now
        );
END dt_lST_Stage;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Actor instead of INSERT trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.it_lAC_Actor
INSTEAD OF INSERT ON anchors.lAC_Actor
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(5);
    v_GEN number(3);
    v_PLV number(3);
BEGIN
    v_id := :NEW.AC_ID;
    IF v_id IS NULL THEN
        INSERT INTO anchors.AC_Actor (
            Metadata_AC
        )
        VALUES (
            :NEW.Metadata_AC
        )
        RETURNING AC_ID INTO v_id;
    END IF;
    IF :NEW.AC_NAM_Actor_Name IS NOT NULL THEN
        attributes.ip_AC_NAM_Actor_Name(
            p_owner => COALESCE(:NEW.AC_NAM_AC_ID, v_id),
            p_value => :NEW.AC_NAM_Actor_Name,
            p_changing => COALESCE(:NEW.AC_NAM_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.AC_NAM_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.AC_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.AC_NAM_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_AC_NAM, :NEW.Metadata_AC)
        );
    END IF;
    v_GEN := :NEW.AC_GEN_GEN_ID;
    IF v_GEN IS NULL AND :NEW.AC_GEN_GEN_Gender IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GEN_ID
            FROM
                knots.GEN_Gender k
            WHERE
                k.GEN_Checksum = STANDARD_HASH(:NEW.AC_GEN_GEN_Gender, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_GEN := kv.GEN_ID;
        END LOOP;
    END IF;
    IF v_GEN IS NOT NULL THEN
        attributes.ip_AC_GEN_Actor_Gender(
            p_owner => COALESCE(:NEW.AC_GEN_AC_ID, v_id),
            p_value => v_GEN,
            p_positor => COALESCE(:NEW.AC_GEN_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.AC_GEN_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.AC_GEN_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_AC_GEN, :NEW.Metadata_AC)
        );
    END IF;
    v_PLV := :NEW.AC_PLV_PLV_ID;
    IF v_PLV IS NULL AND :NEW.AC_PLV_PLV_ProfessionalLevel IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PLV_ID
            FROM
                knots.PLV_ProfessionalLevel k
            WHERE
                k.PLV_Checksum = STANDARD_HASH(:NEW.AC_PLV_PLV_ProfessionalLevel, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_PLV := kv.PLV_ID;
        END LOOP;
    END IF;
    IF v_PLV IS NOT NULL THEN
        attributes.ip_AC_PLV_Actor_ProfessionalLevel(
            p_owner => COALESCE(:NEW.AC_PLV_AC_ID, v_id),
            p_value => v_PLV,
            p_changing => COALESCE(:NEW.AC_PLV_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.AC_PLV_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.AC_PLV_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.AC_PLV_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_AC_PLV, :NEW.Metadata_AC)
        );
    END IF;
END it_lAC_Actor;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_Actor instead of UPDATE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.ut_lAC_Actor
INSTEAD OF UPDATE ON anchors.lAC_Actor
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(19);
    v_anchor_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_NAM_changing timestamp;
    v_GEN number(3);
    v_PLV number(3);
    v_PLV_changing timestamp;
BEGIN
    IF (:NEW.AC_ID <> :OLD.AC_ID
        OR (:NEW.AC_ID IS NULL AND :OLD.AC_ID IS NOT NULL)
        OR (:NEW.AC_ID IS NOT NULL AND :OLD.AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Confidence <> :OLD.Confidence
        OR (:NEW.Confidence IS NULL AND :OLD.Confidence IS NOT NULL)
        OR (:NEW.Confidence IS NOT NULL AND :OLD.Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    v_anchor_meta_diff := CASE WHEN (:NEW.Metadata_AC <> :OLD.Metadata_AC
        OR (:NEW.Metadata_AC IS NULL AND :OLD.Metadata_AC IS NOT NULL)
        OR (:NEW.Metadata_AC IS NOT NULL AND :OLD.Metadata_AC IS NULL)) THEN TRUE ELSE FALSE END;
    -- AC_NAM_Actor_Name
    IF (:NEW.AC_NAM_ID <> :OLD.AC_NAM_ID
        OR (:NEW.AC_NAM_ID IS NULL AND :OLD.AC_NAM_ID IS NOT NULL)
        OR (:NEW.AC_NAM_ID IS NOT NULL AND :OLD.AC_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_NAM_ID is not updatable.');
    END IF;
    IF (:NEW.AC_NAM_AC_ID <> :OLD.AC_NAM_AC_ID
        OR (:NEW.AC_NAM_AC_ID IS NULL AND :OLD.AC_NAM_AC_ID IS NOT NULL)
        OR (:NEW.AC_NAM_AC_ID IS NOT NULL AND :OLD.AC_NAM_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_NAM_AC_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of AC_NAM_Actor_Name, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.AC_NAM_Confidence <> :OLD.AC_NAM_Confidence
        OR (:NEW.AC_NAM_Confidence IS NULL AND :OLD.AC_NAM_Confidence IS NOT NULL)
        OR (:NEW.AC_NAM_Confidence IS NOT NULL AND :OLD.AC_NAM_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.AC_NAM_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.AC_NAM_Confidence;
    END IF;
    IF (:NEW.AC_NAM_Who <> :OLD.AC_NAM_Who
        OR (:NEW.AC_NAM_Who IS NULL AND :OLD.AC_NAM_Who IS NOT NULL)
        OR (:NEW.AC_NAM_Who IS NOT NULL AND :OLD.AC_NAM_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.AC_NAM_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.AC_NAM_PositedAt <> :OLD.AC_NAM_PositedAt
        OR (:NEW.AC_NAM_PositedAt IS NULL AND :OLD.AC_NAM_PositedAt IS NOT NULL)
        OR (:NEW.AC_NAM_PositedAt IS NOT NULL AND :OLD.AC_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.AC_NAM_ChangedAt <> :OLD.AC_NAM_ChangedAt
        OR (:NEW.AC_NAM_ChangedAt IS NULL AND :OLD.AC_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.AC_NAM_ChangedAt IS NOT NULL AND :OLD.AC_NAM_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.AC_NAM_PositedAt;
    ELSIF v_changing_diff AND :NEW.AC_NAM_Actor_Name IS NULL THEN
        v_positing := :NEW.AC_NAM_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.AC_NAM_Actor_Name <> :OLD.AC_NAM_Actor_Name
        OR (:NEW.AC_NAM_Actor_Name IS NULL AND :OLD.AC_NAM_Actor_Name IS NOT NULL)
        OR (:NEW.AC_NAM_Actor_Name IS NOT NULL AND :OLD.AC_NAM_Actor_Name IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_AC_NAM <> :OLD.Metadata_AC_NAM
        OR (:NEW.Metadata_AC_NAM IS NULL AND :OLD.Metadata_AC_NAM IS NOT NULL)
        OR (:NEW.Metadata_AC_NAM IS NOT NULL AND :OLD.Metadata_AC_NAM IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_AC
            ELSE :NEW.Metadata_AC_NAM
        END, :NEW.Metadata_AC);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_NAM_changing := :NEW.AC_NAM_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_NAM_changing := :NEW.AC_NAM_ChangedAt;
        ELSE
            v_NAM_changing := v_now;
        END IF;
        IF :NEW.AC_NAM_Actor_Name IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.AC_NAM_Actor_Name IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.AC_NAM_Confidence IS NULL
            OR :OLD.AC_NAM_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.AC_NAM_Who IS NULL
            OR :OLD.AC_NAM_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_AC_NAM_Actor_Name(
                    p_owner => COALESCE(:NEW.AC_NAM_AC_ID, :NEW.AC_ID),
                    p_value => :NEW.AC_NAM_Actor_Name,
                    p_changing => v_NAM_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.AC_NAM_Actor_Name IS NULL AND :OLD.AC_NAM_Actor_Name IS NOT NULL THEN
            attributes.ip_AC_NAM_Actor_Name(
                p_owner => :OLD.AC_ID,
                p_value => :OLD.AC_NAM_Actor_Name,
                p_changing => :OLD.AC_NAM_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- AC_GEN_Actor_Gender
    IF (:NEW.AC_GEN_ID <> :OLD.AC_GEN_ID
        OR (:NEW.AC_GEN_ID IS NULL AND :OLD.AC_GEN_ID IS NOT NULL)
        OR (:NEW.AC_GEN_ID IS NOT NULL AND :OLD.AC_GEN_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_GEN_ID is not updatable.');
    END IF;
    IF (:NEW.AC_GEN_AC_ID <> :OLD.AC_GEN_AC_ID
        OR (:NEW.AC_GEN_AC_ID IS NULL AND :OLD.AC_GEN_AC_ID IS NOT NULL)
        OR (:NEW.AC_GEN_AC_ID IS NOT NULL AND :OLD.AC_GEN_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_GEN_AC_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of AC_GEN_Actor_Gender, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.AC_GEN_Confidence <> :OLD.AC_GEN_Confidence
        OR (:NEW.AC_GEN_Confidence IS NULL AND :OLD.AC_GEN_Confidence IS NOT NULL)
        OR (:NEW.AC_GEN_Confidence IS NOT NULL AND :OLD.AC_GEN_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.AC_GEN_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.AC_GEN_Confidence;
    END IF;
    IF (:NEW.AC_GEN_Who <> :OLD.AC_GEN_Who
        OR (:NEW.AC_GEN_Who IS NULL AND :OLD.AC_GEN_Who IS NOT NULL)
        OR (:NEW.AC_GEN_Who IS NOT NULL AND :OLD.AC_GEN_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.AC_GEN_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.AC_GEN_PositedAt <> :OLD.AC_GEN_PositedAt
        OR (:NEW.AC_GEN_PositedAt IS NULL AND :OLD.AC_GEN_PositedAt IS NOT NULL)
        OR (:NEW.AC_GEN_PositedAt IS NOT NULL AND :OLD.AC_GEN_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.AC_GEN_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.AC_GEN_GEN_ID <> :OLD.AC_GEN_GEN_ID
        OR (:NEW.AC_GEN_GEN_ID IS NULL AND :OLD.AC_GEN_GEN_ID IS NOT NULL)
        OR (:NEW.AC_GEN_GEN_ID IS NOT NULL AND :OLD.AC_GEN_GEN_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_AC_GEN <> :OLD.Metadata_AC_GEN
        OR (:NEW.Metadata_AC_GEN IS NULL AND :OLD.Metadata_AC_GEN IS NOT NULL)
        OR (:NEW.Metadata_AC_GEN IS NOT NULL AND :OLD.Metadata_AC_GEN IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_AC
            ELSE :NEW.Metadata_AC_GEN
        END, :NEW.Metadata_AC);
    v_knot_diff := CASE WHEN (:NEW.AC_GEN_GEN_Gender <> :OLD.AC_GEN_GEN_Gender
        OR (:NEW.AC_GEN_GEN_Gender IS NULL AND :OLD.AC_GEN_GEN_Gender IS NOT NULL)
        OR (:NEW.AC_GEN_GEN_Gender IS NOT NULL AND :OLD.AC_GEN_GEN_Gender IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_GEN := :NEW.AC_GEN_GEN_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_GEN := NULL;
        IF :NEW.AC_GEN_GEN_Gender IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.GEN_ID
                FROM
                    knots.GEN_Gender k
                WHERE
                    k.GEN_Checksum = STANDARD_HASH(:NEW.AC_GEN_GEN_Gender, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_GEN := kv.GEN_ID;
            END LOOP;
        END IF;
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF v_GEN IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.AC_GEN_GEN_ID IS NULL
            OR v_positing_diff
            OR :OLD.AC_GEN_Confidence IS NULL
            OR :OLD.AC_GEN_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.AC_GEN_Who IS NULL
            OR :OLD.AC_GEN_Who <> v_positor
            OR :OLD.AC_GEN_GEN_ID <> v_GEN
            THEN
                attributes.ip_AC_GEN_Actor_Gender(
                    p_owner => COALESCE(:NEW.AC_GEN_AC_ID, :NEW.AC_ID),
                    p_value => v_GEN,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.AC_GEN_GEN_ID IS NOT NULL AND (
            :NEW.AC_GEN_GEN_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.AC_GEN_GEN_Gender IS NULL AND :OLD.AC_GEN_GEN_Gender IS NOT NULL
            )
        ) THEN
            attributes.ip_AC_GEN_Actor_Gender(
                p_owner => :OLD.AC_ID,
                p_value => :OLD.AC_GEN_GEN_ID,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- AC_PLV_Actor_ProfessionalLevel
    IF (:NEW.AC_PLV_ID <> :OLD.AC_PLV_ID
        OR (:NEW.AC_PLV_ID IS NULL AND :OLD.AC_PLV_ID IS NOT NULL)
        OR (:NEW.AC_PLV_ID IS NOT NULL AND :OLD.AC_PLV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_PLV_ID is not updatable.');
    END IF;
    IF (:NEW.AC_PLV_AC_ID <> :OLD.AC_PLV_AC_ID
        OR (:NEW.AC_PLV_AC_ID IS NULL AND :OLD.AC_PLV_AC_ID IS NOT NULL)
        OR (:NEW.AC_PLV_AC_ID IS NOT NULL AND :OLD.AC_PLV_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_PLV_AC_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of AC_PLV_Actor_ProfessionalLevel, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.AC_PLV_Confidence <> :OLD.AC_PLV_Confidence
        OR (:NEW.AC_PLV_Confidence IS NULL AND :OLD.AC_PLV_Confidence IS NOT NULL)
        OR (:NEW.AC_PLV_Confidence IS NOT NULL AND :OLD.AC_PLV_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.AC_PLV_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.AC_PLV_Confidence;
    END IF;
    IF (:NEW.AC_PLV_Who <> :OLD.AC_PLV_Who
        OR (:NEW.AC_PLV_Who IS NULL AND :OLD.AC_PLV_Who IS NOT NULL)
        OR (:NEW.AC_PLV_Who IS NOT NULL AND :OLD.AC_PLV_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.AC_PLV_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.AC_PLV_PositedAt <> :OLD.AC_PLV_PositedAt
        OR (:NEW.AC_PLV_PositedAt IS NULL AND :OLD.AC_PLV_PositedAt IS NOT NULL)
        OR (:NEW.AC_PLV_PositedAt IS NOT NULL AND :OLD.AC_PLV_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
        OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
        OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.AC_PLV_PositedAt;
    ELSIF v_changing_diff AND :NEW.AC_PLV_PLV_ID IS NULL THEN
        v_positing := :NEW.AC_PLV_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.AC_PLV_PLV_ID <> :OLD.AC_PLV_PLV_ID
        OR (:NEW.AC_PLV_PLV_ID IS NULL AND :OLD.AC_PLV_PLV_ID IS NOT NULL)
        OR (:NEW.AC_PLV_PLV_ID IS NOT NULL AND :OLD.AC_PLV_PLV_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_AC_PLV <> :OLD.Metadata_AC_PLV
        OR (:NEW.Metadata_AC_PLV IS NULL AND :OLD.Metadata_AC_PLV IS NOT NULL)
        OR (:NEW.Metadata_AC_PLV IS NOT NULL AND :OLD.Metadata_AC_PLV IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_AC
            ELSE :NEW.Metadata_AC_PLV
        END, :NEW.Metadata_AC);
    v_knot_diff := CASE WHEN (:NEW.AC_PLV_PLV_ProfessionalLevel <> :OLD.AC_PLV_PLV_ProfessionalLevel
        OR (:NEW.AC_PLV_PLV_ProfessionalLevel IS NULL AND :OLD.AC_PLV_PLV_ProfessionalLevel IS NOT NULL)
        OR (:NEW.AC_PLV_PLV_ProfessionalLevel IS NOT NULL AND :OLD.AC_PLV_PLV_ProfessionalLevel IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_PLV := :NEW.AC_PLV_PLV_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_PLV := NULL;
        IF :NEW.AC_PLV_PLV_ProfessionalLevel IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.PLV_ID
                FROM
                    knots.PLV_ProfessionalLevel k
                WHERE
                    k.PLV_Checksum = STANDARD_HASH(:NEW.AC_PLV_PLV_ProfessionalLevel, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_PLV := kv.PLV_ID;
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
            v_PLV_changing := :NEW.AC_PLV_ChangedAt;
        ELSIF :OLD.AC_PLV_PLV_ID = v_PLV THEN
            v_PLV_changing := :NEW.AC_PLV_ChangedAt;
        ELSE
            v_PLV_changing := v_now;
        END IF;
        IF v_PLV IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.AC_PLV_PLV_ID IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.AC_PLV_Confidence IS NULL
            OR :OLD.AC_PLV_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.AC_PLV_Who IS NULL
            OR :OLD.AC_PLV_Who <> v_positor
            OR :OLD.AC_PLV_PLV_ID <> v_PLV
            THEN
                attributes.ip_AC_PLV_Actor_ProfessionalLevel(
                    p_owner => COALESCE(:NEW.AC_PLV_AC_ID, :NEW.AC_ID),
                    p_value => v_PLV,
                    p_changing => v_PLV_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.AC_PLV_PLV_ID IS NOT NULL AND (
            :NEW.AC_PLV_PLV_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.AC_PLV_PLV_ProfessionalLevel IS NULL AND :OLD.AC_PLV_PLV_ProfessionalLevel IS NOT NULL
            )
        ) THEN
            attributes.ip_AC_PLV_Actor_ProfessionalLevel(
                p_owner => :OLD.AC_ID,
                p_value => :OLD.AC_PLV_PLV_ID,
                p_changing => :OLD.AC_PLV_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
END ut_lAC_Actor;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_Actor instead of DELETE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.dt_lAC_Actor
INSTEAD OF DELETE ON anchors.lAC_Actor
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of AC_NAM_Actor_Name is retracted
    INSERT INTO attributes.AC_NAM_Actor_Name_Meta (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_Who,
        AC_NAM_PositedAt,
        AC_NAM_Confidence
    )
    SELECT
        :OLD.Metadata_AC_NAM,
        :OLD.AC_NAM_ID,
        COALESCE(:OLD.AC_NAM_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.AC_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.AC_NAM_Actor_Name_Meta x
            WHERE
                x.AC_NAM_ID = :OLD.AC_NAM_ID
            AND
                x.AC_NAM_Who = COALESCE(:OLD.AC_NAM_Who, :OLD.Who, 0)
            AND
                x.AC_NAM_PositedAt = v_now
        );
    -- what is shown of AC_GEN_Actor_Gender is retracted
    INSERT INTO attributes.AC_GEN_Actor_Gender_Meta (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_Who,
        AC_GEN_PositedAt,
        AC_GEN_Confidence
    )
    SELECT
        :OLD.Metadata_AC_GEN,
        :OLD.AC_GEN_ID,
        COALESCE(:OLD.AC_GEN_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.AC_GEN_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.AC_GEN_Actor_Gender_Meta x
            WHERE
                x.AC_GEN_ID = :OLD.AC_GEN_ID
            AND
                x.AC_GEN_Who = COALESCE(:OLD.AC_GEN_Who, :OLD.Who, 0)
            AND
                x.AC_GEN_PositedAt = v_now
        );
    -- what is shown of AC_PLV_Actor_ProfessionalLevel is retracted
    INSERT INTO attributes.AC_PLV_Actor_ProfessionalLevel_Meta (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_Who,
        AC_PLV_PositedAt,
        AC_PLV_Confidence
    )
    SELECT
        :OLD.Metadata_AC_PLV,
        :OLD.AC_PLV_ID,
        COALESCE(:OLD.AC_PLV_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.AC_PLV_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.AC_PLV_Actor_ProfessionalLevel_Meta x
            WHERE
                x.AC_PLV_ID = :OLD.AC_PLV_ID
            AND
                x.AC_PLV_Who = COALESCE(:OLD.AC_PLV_Who, :OLD.Who, 0)
            AND
                x.AC_PLV_PositedAt = v_now
        );
END dt_lAC_Actor;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Program instead of INSERT trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.it_lPR_Program
INSTEAD OF INSERT ON anchors.lPR_Program
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(19);
BEGIN
    v_id := :NEW.PR_ID;
    IF v_id IS NULL THEN
        INSERT INTO anchors.PR_Program (
            Metadata_PR
        )
        VALUES (
            :NEW.Metadata_PR
        )
        RETURNING PR_ID INTO v_id;
    END IF;
    IF :NEW.PR_NAM_Program_Name IS NOT NULL THEN
        attributes.ip_PR_NAM_Program_Name(
            p_owner => COALESCE(:NEW.PR_NAM_PR_ID, v_id),
            p_value => :NEW.PR_NAM_Program_Name,
            p_positor => COALESCE(:NEW.PR_NAM_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.PR_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.PR_NAM_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_PR_NAM, :NEW.Metadata_PR)
        );
    END IF;
    IF :NEW.PR_LEN_Program_Length IS NOT NULL THEN
        attributes.ip_PR_LEN_Program_Length(
            p_owner => COALESCE(:NEW.PR_LEN_PR_ID, v_id),
            p_value => :NEW.PR_LEN_Program_Length,
            p_changing => COALESCE(:NEW.PR_LEN_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.PR_LEN_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.PR_LEN_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.PR_LEN_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_PR_LEN, :NEW.Metadata_PR)
        );
    END IF;
END it_lPR_Program;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_Program instead of UPDATE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.ut_lPR_Program
INSTEAD OF UPDATE ON anchors.lPR_Program
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(19);
    v_anchor_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_LEN_changing date;
BEGIN
    IF (:NEW.PR_ID <> :OLD.PR_ID
        OR (:NEW.PR_ID IS NULL AND :OLD.PR_ID IS NOT NULL)
        OR (:NEW.PR_ID IS NOT NULL AND :OLD.PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Confidence <> :OLD.Confidence
        OR (:NEW.Confidence IS NULL AND :OLD.Confidence IS NOT NULL)
        OR (:NEW.Confidence IS NOT NULL AND :OLD.Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    v_anchor_meta_diff := CASE WHEN (:NEW.Metadata_PR <> :OLD.Metadata_PR
        OR (:NEW.Metadata_PR IS NULL AND :OLD.Metadata_PR IS NOT NULL)
        OR (:NEW.Metadata_PR IS NOT NULL AND :OLD.Metadata_PR IS NULL)) THEN TRUE ELSE FALSE END;
    -- PR_NAM_Program_Name
    IF (:NEW.PR_NAM_ID <> :OLD.PR_NAM_ID
        OR (:NEW.PR_NAM_ID IS NULL AND :OLD.PR_NAM_ID IS NOT NULL)
        OR (:NEW.PR_NAM_ID IS NOT NULL AND :OLD.PR_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_NAM_ID is not updatable.');
    END IF;
    IF (:NEW.PR_NAM_PR_ID <> :OLD.PR_NAM_PR_ID
        OR (:NEW.PR_NAM_PR_ID IS NULL AND :OLD.PR_NAM_PR_ID IS NOT NULL)
        OR (:NEW.PR_NAM_PR_ID IS NOT NULL AND :OLD.PR_NAM_PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column PR_NAM_PR_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of PR_NAM_Program_Name, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.PR_NAM_Confidence <> :OLD.PR_NAM_Confidence
        OR (:NEW.PR_NAM_Confidence IS NULL AND :OLD.PR_NAM_Confidence IS NOT NULL)
        OR (:NEW.PR_NAM_Confidence IS NOT NULL AND :OLD.PR_NAM_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.PR_NAM_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.PR_NAM_Confidence;
    END IF;
    IF (:NEW.PR_NAM_Who <> :OLD.PR_NAM_Who
        OR (:NEW.PR_NAM_Who IS NULL AND :OLD.PR_NAM_Who IS NOT NULL)
        OR (:NEW.PR_NAM_Who IS NOT NULL AND :OLD.PR_NAM_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.PR_NAM_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.PR_NAM_PositedAt <> :OLD.PR_NAM_PositedAt
        OR (:NEW.PR_NAM_PositedAt IS NULL AND :OLD.PR_NAM_PositedAt IS NOT NULL)
        OR (:NEW.PR_NAM_PositedAt IS NOT NULL AND :OLD.PR_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.PR_NAM_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.PR_NAM_Program_Name <> :OLD.PR_NAM_Program_Name
        OR (:NEW.PR_NAM_Program_Name IS NULL AND :OLD.PR_NAM_Program_Name IS NOT NULL)
        OR (:NEW.PR_NAM_Program_Name IS NOT NULL AND :OLD.PR_NAM_Program_Name IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_PR_NAM <> :OLD.Metadata_PR_NAM
        OR (:NEW.Metadata_PR_NAM IS NULL AND :OLD.Metadata_PR_NAM IS NOT NULL)
        OR (:NEW.Metadata_PR_NAM IS NOT NULL AND :OLD.Metadata_PR_NAM IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_PR
            ELSE :NEW.Metadata_PR_NAM
        END, :NEW.Metadata_PR);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.PR_NAM_Program_Name IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.PR_NAM_Program_Name IS NULL
            OR v_positing_diff
            OR :OLD.PR_NAM_Confidence IS NULL
            OR :OLD.PR_NAM_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.PR_NAM_Who IS NULL
            OR :OLD.PR_NAM_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_PR_NAM_Program_Name(
                    p_owner => COALESCE(:NEW.PR_NAM_PR_ID, :NEW.PR_ID),
                    p_value => :NEW.PR_NAM_Program_Name,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.PR_NAM_Program_Name IS NULL AND :OLD.PR_NAM_Program_Name IS NOT NULL THEN
            attributes.ip_PR_NAM_Program_Name(
                p_owner => :OLD.PR_ID,
                p_value => :OLD.PR_NAM_Program_Name,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- PR_LEN_Program_Length
    IF (:NEW.PR_LEN_ID <> :OLD.PR_LEN_ID
        OR (:NEW.PR_LEN_ID IS NULL AND :OLD.PR_LEN_ID IS NOT NULL)
        OR (:NEW.PR_LEN_ID IS NOT NULL AND :OLD.PR_LEN_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_LEN_ID is not updatable.');
    END IF;
    IF (:NEW.PR_LEN_PR_ID <> :OLD.PR_LEN_PR_ID
        OR (:NEW.PR_LEN_PR_ID IS NULL AND :OLD.PR_LEN_PR_ID IS NOT NULL)
        OR (:NEW.PR_LEN_PR_ID IS NOT NULL AND :OLD.PR_LEN_PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column PR_LEN_PR_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of PR_LEN_Program_Length, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.PR_LEN_Confidence <> :OLD.PR_LEN_Confidence
        OR (:NEW.PR_LEN_Confidence IS NULL AND :OLD.PR_LEN_Confidence IS NOT NULL)
        OR (:NEW.PR_LEN_Confidence IS NOT NULL AND :OLD.PR_LEN_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.PR_LEN_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.PR_LEN_Confidence;
    END IF;
    IF (:NEW.PR_LEN_Who <> :OLD.PR_LEN_Who
        OR (:NEW.PR_LEN_Who IS NULL AND :OLD.PR_LEN_Who IS NOT NULL)
        OR (:NEW.PR_LEN_Who IS NOT NULL AND :OLD.PR_LEN_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.PR_LEN_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.PR_LEN_PositedAt <> :OLD.PR_LEN_PositedAt
        OR (:NEW.PR_LEN_PositedAt IS NULL AND :OLD.PR_LEN_PositedAt IS NOT NULL)
        OR (:NEW.PR_LEN_PositedAt IS NOT NULL AND :OLD.PR_LEN_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.PR_LEN_ChangedAt <> :OLD.PR_LEN_ChangedAt
        OR (:NEW.PR_LEN_ChangedAt IS NULL AND :OLD.PR_LEN_ChangedAt IS NOT NULL)
        OR (:NEW.PR_LEN_ChangedAt IS NOT NULL AND :OLD.PR_LEN_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.PR_LEN_PositedAt;
    ELSIF v_changing_diff AND :NEW.PR_LEN_Program_Length IS NULL THEN
        v_positing := :NEW.PR_LEN_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.PR_LEN_Program_Length <> :OLD.PR_LEN_Program_Length
        OR (:NEW.PR_LEN_Program_Length IS NULL AND :OLD.PR_LEN_Program_Length IS NOT NULL)
        OR (:NEW.PR_LEN_Program_Length IS NOT NULL AND :OLD.PR_LEN_Program_Length IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_PR_LEN <> :OLD.Metadata_PR_LEN
        OR (:NEW.Metadata_PR_LEN IS NULL AND :OLD.Metadata_PR_LEN IS NOT NULL)
        OR (:NEW.Metadata_PR_LEN IS NOT NULL AND :OLD.Metadata_PR_LEN IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_PR
            ELSE :NEW.Metadata_PR_LEN
        END, :NEW.Metadata_PR);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_LEN_changing := :NEW.PR_LEN_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_LEN_changing := :NEW.PR_LEN_ChangedAt;
        ELSE
            v_LEN_changing := v_now;
        END IF;
        IF :NEW.PR_LEN_Program_Length IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.PR_LEN_Program_Length IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.PR_LEN_Confidence IS NULL
            OR :OLD.PR_LEN_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.PR_LEN_Who IS NULL
            OR :OLD.PR_LEN_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_PR_LEN_Program_Length(
                    p_owner => COALESCE(:NEW.PR_LEN_PR_ID, :NEW.PR_ID),
                    p_value => :NEW.PR_LEN_Program_Length,
                    p_changing => v_LEN_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.PR_LEN_Program_Length IS NULL AND :OLD.PR_LEN_Program_Length IS NOT NULL THEN
            attributes.ip_PR_LEN_Program_Length(
                p_owner => :OLD.PR_ID,
                p_value => :OLD.PR_LEN_Program_Length,
                p_changing => :OLD.PR_LEN_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
END ut_lPR_Program;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_Program instead of DELETE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.dt_lPR_Program
INSTEAD OF DELETE ON anchors.lPR_Program
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of PR_NAM_Program_Name is retracted
    INSERT INTO attributes.PR_NAM_Program_Name_Meta (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_Who,
        PR_NAM_PositedAt,
        PR_NAM_Confidence
    )
    SELECT
        :OLD.Metadata_PR_NAM,
        :OLD.PR_NAM_ID,
        COALESCE(:OLD.PR_NAM_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.PR_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.PR_NAM_Program_Name_Meta x
            WHERE
                x.PR_NAM_ID = :OLD.PR_NAM_ID
            AND
                x.PR_NAM_Who = COALESCE(:OLD.PR_NAM_Who, :OLD.Who, 0)
            AND
                x.PR_NAM_PositedAt = v_now
        );
    -- what is shown of PR_LEN_Program_Length is retracted
    INSERT INTO attributes.PR_LEN_Program_Length_Meta (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_Who,
        PR_LEN_PositedAt,
        PR_LEN_Confidence
    )
    SELECT
        :OLD.Metadata_PR_LEN,
        :OLD.PR_LEN_ID,
        COALESCE(:OLD.PR_LEN_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.PR_LEN_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.PR_LEN_Program_Length_Meta x
            WHERE
                x.PR_LEN_ID = :OLD.PR_LEN_ID
            AND
                x.PR_LEN_Who = COALESCE(:OLD.PR_LEN_Who, :OLD.Who, 0)
            AND
                x.PR_LEN_PositedAt = v_now
        );
END dt_lPR_Program;
/
