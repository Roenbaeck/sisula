-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
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
-- it_lEV_Event instead of INSERT trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER nexuses.it_lEV_Event
INSTEAD OF INSERT ON nexuses.lEV_Event
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(12,0);
    v_UTL number(3);
    v_LVL number(3);
BEGIN
    v_id := :NEW.EV_ID;
    IF v_id IS NULL THEN
        INSERT INTO nexuses.EV_Event (
            ST_ID_wasHeldAt,
            PR_ID_wasPlayed,
            ETY_ID_of,
            Metadata_EV
        )
        VALUES (
            :NEW.ST_ID_wasHeldAt,
            :NEW.PR_ID_wasPlayed,
            :NEW.ETY_ID_of,
            :NEW.Metadata_EV
        )
        RETURNING EV_ID INTO v_id;
    END IF;
    IF :NEW.EV_DAT_Event_Date IS NOT NULL THEN
        attributes.ip_EV_DAT_Event_Date(
            p_owner => COALESCE(:NEW.EV_DAT_EV_ID, v_id),
            p_value => :NEW.EV_DAT_Event_Date,
            p_positor => COALESCE(:NEW.EV_DAT_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.EV_DAT_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_DAT_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_DAT, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_AUD_Event_Audience IS NOT NULL THEN
        attributes.ip_EV_AUD_Event_Audience(
            p_owner => COALESCE(:NEW.EV_AUD_EV_ID, v_id),
            p_value => :NEW.EV_AUD_Event_Audience,
            p_positor => COALESCE(:NEW.EV_AUD_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.EV_AUD_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_AUD_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_AUD, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_REV_Event_Revenue IS NOT NULL THEN
        attributes.ip_EV_REV_Event_Revenue(
            p_owner => COALESCE(:NEW.EV_REV_EV_ID, v_id),
            p_value => :NEW.EV_REV_Event_Revenue,
            p_positor => COALESCE(:NEW.EV_REV_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.EV_REV_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_REV_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_REV, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_STA_Event_Status IS NOT NULL THEN
        attributes.ip_EV_STA_Event_Status(
            p_owner => COALESCE(:NEW.EV_STA_EV_ID, v_id),
            p_value => :NEW.EV_STA_Event_Status,
            p_changing => COALESCE(:NEW.EV_STA_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.EV_STA_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.EV_STA_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_STA_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_STA, :NEW.Metadata_EV)
        );
    END IF;
    v_UTL := :NEW.EV_UTL_UTL_ID;
    IF v_UTL IS NULL AND :NEW.EV_UTL_UTL_Utilization IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                knots.UTL_Utilization k
            WHERE
                k.UTL_Utilization = :NEW.EV_UTL_UTL_Utilization
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_UTL := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_UTL IS NOT NULL THEN
        attributes.ip_EV_UTL_Event_Utilization(
            p_owner => COALESCE(:NEW.EV_UTL_EV_ID, v_id),
            p_value => v_UTL,
            p_positor => COALESCE(:NEW.EV_UTL_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.EV_UTL_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_UTL_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_UTL, :NEW.Metadata_EV)
        );
    END IF;
    v_LVL := :NEW.EV_LVL_PLV_ID;
    IF v_LVL IS NULL AND :NEW.EV_LVL_PLV_ProfessionalLevel IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PLV_ID
            FROM
                knots.PLV_ProfessionalLevel k
            WHERE
                k.PLV_Checksum = STANDARD_HASH(:NEW.EV_LVL_PLV_ProfessionalLevel, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_LVL := kv.PLV_ID;
        END LOOP;
    END IF;
    IF v_LVL IS NOT NULL THEN
        attributes.ip_EV_LVL_Event_Level(
            p_owner => COALESCE(:NEW.EV_LVL_EV_ID, v_id),
            p_value => v_LVL,
            p_changing => COALESCE(:NEW.EV_LVL_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.EV_LVL_Who, :NEW.Who, 0),
            p_positing => COALESCE(:NEW.EV_LVL_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_LVL_Confidence, :NEW.Confidence, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_LVL, :NEW.Metadata_EV)
        );
    END IF;
END it_lEV_Event;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lEV_Event instead of UPDATE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER nexuses.ut_lEV_Event
INSTEAD OF UPDATE ON nexuses.lEV_Event
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
    v_nexus_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_STA_changing timestamp;
    v_UTL number(3);
    v_LVL number(3);
    v_LVL_changing date;
BEGIN
    IF (:NEW.EV_ID <> :OLD.EV_ID
        OR (:NEW.EV_ID IS NULL AND :OLD.EV_ID IS NOT NULL)
        OR (:NEW.EV_ID IS NOT NULL AND :OLD.EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_ID is not updatable.');
    END IF;
    IF (:NEW.ST_ID_wasHeldAt <> :OLD.ST_ID_wasHeldAt
        OR (:NEW.ST_ID_wasHeldAt IS NULL AND :OLD.ST_ID_wasHeldAt IS NOT NULL)
        OR (:NEW.ST_ID_wasHeldAt IS NOT NULL AND :OLD.ST_ID_wasHeldAt IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column ST_ID_wasHeldAt is not updatable.');
    END IF;
    IF (:NEW.PR_ID_wasPlayed <> :OLD.PR_ID_wasPlayed
        OR (:NEW.PR_ID_wasPlayed IS NULL AND :OLD.PR_ID_wasPlayed IS NOT NULL)
        OR (:NEW.PR_ID_wasPlayed IS NOT NULL AND :OLD.PR_ID_wasPlayed IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column PR_ID_wasPlayed is not updatable.');
    END IF;
    IF (:NEW.ETY_ID_of <> :OLD.ETY_ID_of
        OR (:NEW.ETY_ID_of IS NULL AND :OLD.ETY_ID_of IS NOT NULL)
        OR (:NEW.ETY_ID_of IS NOT NULL AND :OLD.ETY_ID_of IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column ETY_ID_of is not updatable.');
    END IF;
    IF (:NEW.of_ETY_EventType <> :OLD.of_ETY_EventType
        OR (:NEW.of_ETY_EventType IS NULL AND :OLD.of_ETY_EventType IS NOT NULL)
        OR (:NEW.of_ETY_EventType IS NOT NULL AND :OLD.of_ETY_EventType IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column of_ETY_EventType is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Confidence <> :OLD.Confidence
        OR (:NEW.Confidence IS NULL AND :OLD.Confidence IS NOT NULL)
        OR (:NEW.Confidence IS NOT NULL AND :OLD.Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    v_nexus_meta_diff := CASE WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
        OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
        OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL)) THEN TRUE ELSE FALSE END;
    -- EV_DAT_Event_Date
    IF (:NEW.EV_DAT_ID <> :OLD.EV_DAT_ID
        OR (:NEW.EV_DAT_ID IS NULL AND :OLD.EV_DAT_ID IS NOT NULL)
        OR (:NEW.EV_DAT_ID IS NOT NULL AND :OLD.EV_DAT_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_DAT_ID is not updatable.');
    END IF;
    IF (:NEW.EV_DAT_EV_ID <> :OLD.EV_DAT_EV_ID
        OR (:NEW.EV_DAT_EV_ID IS NULL AND :OLD.EV_DAT_EV_ID IS NOT NULL)
        OR (:NEW.EV_DAT_EV_ID IS NOT NULL AND :OLD.EV_DAT_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_DAT_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_DAT_Event_Date, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_DAT_Confidence <> :OLD.EV_DAT_Confidence
        OR (:NEW.EV_DAT_Confidence IS NULL AND :OLD.EV_DAT_Confidence IS NOT NULL)
        OR (:NEW.EV_DAT_Confidence IS NOT NULL AND :OLD.EV_DAT_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_DAT_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.EV_DAT_Confidence;
    END IF;
    IF (:NEW.EV_DAT_Who <> :OLD.EV_DAT_Who
        OR (:NEW.EV_DAT_Who IS NULL AND :OLD.EV_DAT_Who IS NOT NULL)
        OR (:NEW.EV_DAT_Who IS NOT NULL AND :OLD.EV_DAT_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_DAT_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_DAT_PositedAt <> :OLD.EV_DAT_PositedAt
        OR (:NEW.EV_DAT_PositedAt IS NULL AND :OLD.EV_DAT_PositedAt IS NOT NULL)
        OR (:NEW.EV_DAT_PositedAt IS NOT NULL AND :OLD.EV_DAT_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_DAT_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_DAT_Event_Date <> :OLD.EV_DAT_Event_Date
        OR (:NEW.EV_DAT_Event_Date IS NULL AND :OLD.EV_DAT_Event_Date IS NOT NULL)
        OR (:NEW.EV_DAT_Event_Date IS NOT NULL AND :OLD.EV_DAT_Event_Date IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_DAT <> :OLD.Metadata_EV_DAT
        OR (:NEW.Metadata_EV_DAT IS NULL AND :OLD.Metadata_EV_DAT IS NOT NULL)
        OR (:NEW.Metadata_EV_DAT IS NOT NULL AND :OLD.Metadata_EV_DAT IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_DAT
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.EV_DAT_Event_Date IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_DAT_Event_Date IS NULL
            OR v_positing_diff
            OR :OLD.EV_DAT_Confidence IS NULL
            OR :OLD.EV_DAT_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.EV_DAT_Who IS NULL
            OR :OLD.EV_DAT_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_EV_DAT_Event_Date(
                    p_owner => COALESCE(:NEW.EV_DAT_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_DAT_Event_Date,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.EV_DAT_Event_Date IS NULL AND :OLD.EV_DAT_Event_Date IS NOT NULL THEN
            attributes.ip_EV_DAT_Event_Date(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_DAT_Event_Date,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_AUD_Event_Audience
    IF (:NEW.EV_AUD_ID <> :OLD.EV_AUD_ID
        OR (:NEW.EV_AUD_ID IS NULL AND :OLD.EV_AUD_ID IS NOT NULL)
        OR (:NEW.EV_AUD_ID IS NOT NULL AND :OLD.EV_AUD_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_AUD_ID is not updatable.');
    END IF;
    IF (:NEW.EV_AUD_EV_ID <> :OLD.EV_AUD_EV_ID
        OR (:NEW.EV_AUD_EV_ID IS NULL AND :OLD.EV_AUD_EV_ID IS NOT NULL)
        OR (:NEW.EV_AUD_EV_ID IS NOT NULL AND :OLD.EV_AUD_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_AUD_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_AUD_Event_Audience, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_AUD_Confidence <> :OLD.EV_AUD_Confidence
        OR (:NEW.EV_AUD_Confidence IS NULL AND :OLD.EV_AUD_Confidence IS NOT NULL)
        OR (:NEW.EV_AUD_Confidence IS NOT NULL AND :OLD.EV_AUD_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_AUD_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.EV_AUD_Confidence;
    END IF;
    IF (:NEW.EV_AUD_Who <> :OLD.EV_AUD_Who
        OR (:NEW.EV_AUD_Who IS NULL AND :OLD.EV_AUD_Who IS NOT NULL)
        OR (:NEW.EV_AUD_Who IS NOT NULL AND :OLD.EV_AUD_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_AUD_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_AUD_PositedAt <> :OLD.EV_AUD_PositedAt
        OR (:NEW.EV_AUD_PositedAt IS NULL AND :OLD.EV_AUD_PositedAt IS NOT NULL)
        OR (:NEW.EV_AUD_PositedAt IS NOT NULL AND :OLD.EV_AUD_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_AUD_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_AUD_Event_Audience <> :OLD.EV_AUD_Event_Audience
        OR (:NEW.EV_AUD_Event_Audience IS NULL AND :OLD.EV_AUD_Event_Audience IS NOT NULL)
        OR (:NEW.EV_AUD_Event_Audience IS NOT NULL AND :OLD.EV_AUD_Event_Audience IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_AUD <> :OLD.Metadata_EV_AUD
        OR (:NEW.Metadata_EV_AUD IS NULL AND :OLD.Metadata_EV_AUD IS NOT NULL)
        OR (:NEW.Metadata_EV_AUD IS NOT NULL AND :OLD.Metadata_EV_AUD IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_AUD
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.EV_AUD_Event_Audience IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_AUD_Event_Audience IS NULL
            OR v_positing_diff
            OR :OLD.EV_AUD_Confidence IS NULL
            OR :OLD.EV_AUD_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.EV_AUD_Who IS NULL
            OR :OLD.EV_AUD_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_EV_AUD_Event_Audience(
                    p_owner => COALESCE(:NEW.EV_AUD_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_AUD_Event_Audience,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.EV_AUD_Event_Audience IS NULL AND :OLD.EV_AUD_Event_Audience IS NOT NULL THEN
            attributes.ip_EV_AUD_Event_Audience(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_AUD_Event_Audience,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_REV_Event_Revenue
    IF (:NEW.EV_REV_ID <> :OLD.EV_REV_ID
        OR (:NEW.EV_REV_ID IS NULL AND :OLD.EV_REV_ID IS NOT NULL)
        OR (:NEW.EV_REV_ID IS NOT NULL AND :OLD.EV_REV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_REV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_REV_EV_ID <> :OLD.EV_REV_EV_ID
        OR (:NEW.EV_REV_EV_ID IS NULL AND :OLD.EV_REV_EV_ID IS NOT NULL)
        OR (:NEW.EV_REV_EV_ID IS NOT NULL AND :OLD.EV_REV_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_REV_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_REV_Event_Revenue, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_REV_Confidence <> :OLD.EV_REV_Confidence
        OR (:NEW.EV_REV_Confidence IS NULL AND :OLD.EV_REV_Confidence IS NOT NULL)
        OR (:NEW.EV_REV_Confidence IS NOT NULL AND :OLD.EV_REV_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_REV_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.EV_REV_Confidence;
    END IF;
    IF (:NEW.EV_REV_Who <> :OLD.EV_REV_Who
        OR (:NEW.EV_REV_Who IS NULL AND :OLD.EV_REV_Who IS NOT NULL)
        OR (:NEW.EV_REV_Who IS NOT NULL AND :OLD.EV_REV_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_REV_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_REV_PositedAt <> :OLD.EV_REV_PositedAt
        OR (:NEW.EV_REV_PositedAt IS NULL AND :OLD.EV_REV_PositedAt IS NOT NULL)
        OR (:NEW.EV_REV_PositedAt IS NOT NULL AND :OLD.EV_REV_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_REV_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_REV_Event_Revenue <> :OLD.EV_REV_Event_Revenue
        OR (:NEW.EV_REV_Event_Revenue IS NULL AND :OLD.EV_REV_Event_Revenue IS NOT NULL)
        OR (:NEW.EV_REV_Event_Revenue IS NOT NULL AND :OLD.EV_REV_Event_Revenue IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_REV <> :OLD.Metadata_EV_REV
        OR (:NEW.Metadata_EV_REV IS NULL AND :OLD.Metadata_EV_REV IS NOT NULL)
        OR (:NEW.Metadata_EV_REV IS NOT NULL AND :OLD.Metadata_EV_REV IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_REV
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.EV_REV_Event_Revenue IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_REV_Event_Revenue IS NULL
            OR v_positing_diff
            OR :OLD.EV_REV_Confidence IS NULL
            OR :OLD.EV_REV_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.EV_REV_Who IS NULL
            OR :OLD.EV_REV_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_EV_REV_Event_Revenue(
                    p_owner => COALESCE(:NEW.EV_REV_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_REV_Event_Revenue,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.EV_REV_Event_Revenue IS NULL AND :OLD.EV_REV_Event_Revenue IS NOT NULL THEN
            attributes.ip_EV_REV_Event_Revenue(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_REV_Event_Revenue,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_STA_Event_Status
    IF (:NEW.EV_STA_ID <> :OLD.EV_STA_ID
        OR (:NEW.EV_STA_ID IS NULL AND :OLD.EV_STA_ID IS NOT NULL)
        OR (:NEW.EV_STA_ID IS NOT NULL AND :OLD.EV_STA_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_STA_ID is not updatable.');
    END IF;
    IF (:NEW.EV_STA_EV_ID <> :OLD.EV_STA_EV_ID
        OR (:NEW.EV_STA_EV_ID IS NULL AND :OLD.EV_STA_EV_ID IS NOT NULL)
        OR (:NEW.EV_STA_EV_ID IS NOT NULL AND :OLD.EV_STA_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_STA_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_STA_Event_Status, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_STA_Confidence <> :OLD.EV_STA_Confidence
        OR (:NEW.EV_STA_Confidence IS NULL AND :OLD.EV_STA_Confidence IS NOT NULL)
        OR (:NEW.EV_STA_Confidence IS NOT NULL AND :OLD.EV_STA_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_STA_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.EV_STA_Confidence;
    END IF;
    IF (:NEW.EV_STA_Who <> :OLD.EV_STA_Who
        OR (:NEW.EV_STA_Who IS NULL AND :OLD.EV_STA_Who IS NOT NULL)
        OR (:NEW.EV_STA_Who IS NOT NULL AND :OLD.EV_STA_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_STA_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_STA_PositedAt <> :OLD.EV_STA_PositedAt
        OR (:NEW.EV_STA_PositedAt IS NULL AND :OLD.EV_STA_PositedAt IS NOT NULL)
        OR (:NEW.EV_STA_PositedAt IS NOT NULL AND :OLD.EV_STA_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.EV_STA_ChangedAt <> :OLD.EV_STA_ChangedAt
        OR (:NEW.EV_STA_ChangedAt IS NULL AND :OLD.EV_STA_ChangedAt IS NOT NULL)
        OR (:NEW.EV_STA_ChangedAt IS NOT NULL AND :OLD.EV_STA_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_STA_PositedAt;
    ELSIF v_changing_diff AND :NEW.EV_STA_Event_Status IS NULL THEN
        v_positing := :NEW.EV_STA_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_STA_Event_Status <> :OLD.EV_STA_Event_Status
        OR (:NEW.EV_STA_Event_Status IS NULL AND :OLD.EV_STA_Event_Status IS NOT NULL)
        OR (:NEW.EV_STA_Event_Status IS NOT NULL AND :OLD.EV_STA_Event_Status IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_STA <> :OLD.Metadata_EV_STA
        OR (:NEW.Metadata_EV_STA IS NULL AND :OLD.Metadata_EV_STA IS NOT NULL)
        OR (:NEW.Metadata_EV_STA IS NOT NULL AND :OLD.Metadata_EV_STA IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_STA
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_STA_changing := :NEW.EV_STA_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_STA_changing := :NEW.EV_STA_ChangedAt;
        ELSE
            v_STA_changing := v_now;
        END IF;
        IF :NEW.EV_STA_Event_Status IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_STA_Event_Status IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.EV_STA_Confidence IS NULL
            OR :OLD.EV_STA_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.EV_STA_Who IS NULL
            OR :OLD.EV_STA_Who <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_EV_STA_Event_Status(
                    p_owner => COALESCE(:NEW.EV_STA_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_STA_Event_Status,
                    p_changing => v_STA_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.EV_STA_Event_Status IS NULL AND :OLD.EV_STA_Event_Status IS NOT NULL THEN
            attributes.ip_EV_STA_Event_Status(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_STA_Event_Status,
                p_changing => :OLD.EV_STA_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_UTL_Event_Utilization
    IF (:NEW.EV_UTL_ID <> :OLD.EV_UTL_ID
        OR (:NEW.EV_UTL_ID IS NULL AND :OLD.EV_UTL_ID IS NOT NULL)
        OR (:NEW.EV_UTL_ID IS NOT NULL AND :OLD.EV_UTL_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_UTL_ID is not updatable.');
    END IF;
    IF (:NEW.EV_UTL_EV_ID <> :OLD.EV_UTL_EV_ID
        OR (:NEW.EV_UTL_EV_ID IS NULL AND :OLD.EV_UTL_EV_ID IS NOT NULL)
        OR (:NEW.EV_UTL_EV_ID IS NOT NULL AND :OLD.EV_UTL_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_UTL_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_UTL_Event_Utilization, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_UTL_Confidence <> :OLD.EV_UTL_Confidence
        OR (:NEW.EV_UTL_Confidence IS NULL AND :OLD.EV_UTL_Confidence IS NOT NULL)
        OR (:NEW.EV_UTL_Confidence IS NOT NULL AND :OLD.EV_UTL_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_UTL_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.EV_UTL_Confidence;
    END IF;
    IF (:NEW.EV_UTL_Who <> :OLD.EV_UTL_Who
        OR (:NEW.EV_UTL_Who IS NULL AND :OLD.EV_UTL_Who IS NOT NULL)
        OR (:NEW.EV_UTL_Who IS NOT NULL AND :OLD.EV_UTL_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_UTL_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_UTL_PositedAt <> :OLD.EV_UTL_PositedAt
        OR (:NEW.EV_UTL_PositedAt IS NULL AND :OLD.EV_UTL_PositedAt IS NOT NULL)
        OR (:NEW.EV_UTL_PositedAt IS NOT NULL AND :OLD.EV_UTL_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_UTL_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_UTL_UTL_ID <> :OLD.EV_UTL_UTL_ID
        OR (:NEW.EV_UTL_UTL_ID IS NULL AND :OLD.EV_UTL_UTL_ID IS NOT NULL)
        OR (:NEW.EV_UTL_UTL_ID IS NOT NULL AND :OLD.EV_UTL_UTL_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_UTL <> :OLD.Metadata_EV_UTL
        OR (:NEW.Metadata_EV_UTL IS NULL AND :OLD.Metadata_EV_UTL IS NOT NULL)
        OR (:NEW.Metadata_EV_UTL IS NOT NULL AND :OLD.Metadata_EV_UTL IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_UTL
        END, :NEW.Metadata_EV);
    v_knot_diff := CASE WHEN (:NEW.EV_UTL_UTL_Utilization <> :OLD.EV_UTL_UTL_Utilization
        OR (:NEW.EV_UTL_UTL_Utilization IS NULL AND :OLD.EV_UTL_UTL_Utilization IS NOT NULL)
        OR (:NEW.EV_UTL_UTL_Utilization IS NOT NULL AND :OLD.EV_UTL_UTL_Utilization IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_UTL := :NEW.EV_UTL_UTL_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_UTL := NULL;
        IF :NEW.EV_UTL_UTL_Utilization IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    knots.UTL_Utilization k
                WHERE
                    k.UTL_Utilization = :NEW.EV_UTL_UTL_Utilization
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_UTL := kv.UTL_ID;
            END LOOP;
        END IF;
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF v_UTL IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_UTL_UTL_ID IS NULL
            OR v_positing_diff
            OR :OLD.EV_UTL_Confidence IS NULL
            OR :OLD.EV_UTL_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.EV_UTL_Who IS NULL
            OR :OLD.EV_UTL_Who <> v_positor
            OR :OLD.EV_UTL_UTL_ID <> v_UTL
            THEN
                attributes.ip_EV_UTL_Event_Utilization(
                    p_owner => COALESCE(:NEW.EV_UTL_EV_ID, :NEW.EV_ID),
                    p_value => v_UTL,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.EV_UTL_UTL_ID IS NOT NULL AND (
            :NEW.EV_UTL_UTL_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.EV_UTL_UTL_Utilization IS NULL AND :OLD.EV_UTL_UTL_Utilization IS NOT NULL
            )
        ) THEN
            attributes.ip_EV_UTL_Event_Utilization(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_UTL_UTL_ID,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_LVL_Event_Level
    IF (:NEW.EV_LVL_ID <> :OLD.EV_LVL_ID
        OR (:NEW.EV_LVL_ID IS NULL AND :OLD.EV_LVL_ID IS NOT NULL)
        OR (:NEW.EV_LVL_ID IS NOT NULL AND :OLD.EV_LVL_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_LVL_ID is not updatable.');
    END IF;
    IF (:NEW.EV_LVL_EV_ID <> :OLD.EV_LVL_EV_ID
        OR (:NEW.EV_LVL_EV_ID IS NULL AND :OLD.EV_LVL_EV_ID IS NOT NULL)
        OR (:NEW.EV_LVL_EV_ID IS NOT NULL AND :OLD.EV_LVL_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_LVL_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_LVL_Event_Level, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_LVL_Confidence <> :OLD.EV_LVL_Confidence
        OR (:NEW.EV_LVL_Confidence IS NULL AND :OLD.EV_LVL_Confidence IS NOT NULL)
        OR (:NEW.EV_LVL_Confidence IS NOT NULL AND :OLD.EV_LVL_Confidence IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_LVL_Confidence;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Confidence;
    ELSE
        v_reliability := :NEW.EV_LVL_Confidence;
    END IF;
    IF (:NEW.EV_LVL_Who <> :OLD.EV_LVL_Who
        OR (:NEW.EV_LVL_Who IS NULL AND :OLD.EV_LVL_Who IS NOT NULL)
        OR (:NEW.EV_LVL_Who IS NOT NULL AND :OLD.EV_LVL_Who IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_LVL_Who, 0);
    ELSE
        v_positor := COALESCE(:NEW.Who, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_LVL_PositedAt <> :OLD.EV_LVL_PositedAt
        OR (:NEW.EV_LVL_PositedAt IS NULL AND :OLD.EV_LVL_PositedAt IS NOT NULL)
        OR (:NEW.EV_LVL_PositedAt IS NOT NULL AND :OLD.EV_LVL_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.EV_LVL_ChangedAt <> :OLD.EV_LVL_ChangedAt
        OR (:NEW.EV_LVL_ChangedAt IS NULL AND :OLD.EV_LVL_ChangedAt IS NOT NULL)
        OR (:NEW.EV_LVL_ChangedAt IS NOT NULL AND :OLD.EV_LVL_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_LVL_PositedAt;
    ELSIF v_changing_diff AND :NEW.EV_LVL_PLV_ID IS NULL THEN
        v_positing := :NEW.EV_LVL_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_LVL_PLV_ID <> :OLD.EV_LVL_PLV_ID
        OR (:NEW.EV_LVL_PLV_ID IS NULL AND :OLD.EV_LVL_PLV_ID IS NOT NULL)
        OR (:NEW.EV_LVL_PLV_ID IS NOT NULL AND :OLD.EV_LVL_PLV_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_LVL <> :OLD.Metadata_EV_LVL
        OR (:NEW.Metadata_EV_LVL IS NULL AND :OLD.Metadata_EV_LVL IS NOT NULL)
        OR (:NEW.Metadata_EV_LVL IS NOT NULL AND :OLD.Metadata_EV_LVL IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_LVL
        END, :NEW.Metadata_EV);
    v_knot_diff := CASE WHEN (:NEW.EV_LVL_PLV_ProfessionalLevel <> :OLD.EV_LVL_PLV_ProfessionalLevel
        OR (:NEW.EV_LVL_PLV_ProfessionalLevel IS NULL AND :OLD.EV_LVL_PLV_ProfessionalLevel IS NOT NULL)
        OR (:NEW.EV_LVL_PLV_ProfessionalLevel IS NOT NULL AND :OLD.EV_LVL_PLV_ProfessionalLevel IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_LVL := :NEW.EV_LVL_PLV_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_LVL := NULL;
        IF :NEW.EV_LVL_PLV_ProfessionalLevel IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.PLV_ID
                FROM
                    knots.PLV_ProfessionalLevel k
                WHERE
                    k.PLV_Checksum = STANDARD_HASH(:NEW.EV_LVL_PLV_ProfessionalLevel, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_LVL := kv.PLV_ID;
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
            v_LVL_changing := :NEW.EV_LVL_ChangedAt;
        ELSIF :OLD.EV_LVL_PLV_ID = v_LVL THEN
            v_LVL_changing := :NEW.EV_LVL_ChangedAt;
        ELSE
            v_LVL_changing := v_now;
        END IF;
        IF v_LVL IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_LVL_PLV_ID IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.EV_LVL_Confidence IS NULL
            OR :OLD.EV_LVL_Confidence <> COALESCE(v_reliability, 1)
            OR :OLD.EV_LVL_Who IS NULL
            OR :OLD.EV_LVL_Who <> v_positor
            OR :OLD.EV_LVL_PLV_ID <> v_LVL
            THEN
                attributes.ip_EV_LVL_Event_Level(
                    p_owner => COALESCE(:NEW.EV_LVL_EV_ID, :NEW.EV_ID),
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
        IF :OLD.EV_LVL_PLV_ID IS NOT NULL AND (
            :NEW.EV_LVL_PLV_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.EV_LVL_PLV_ProfessionalLevel IS NULL AND :OLD.EV_LVL_PLV_ProfessionalLevel IS NOT NULL
            )
        ) THEN
            attributes.ip_EV_LVL_Event_Level(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_LVL_PLV_ID,
                p_changing => :OLD.EV_LVL_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0.25,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
END ut_lEV_Event;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_Event instead of DELETE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER nexuses.dt_lEV_Event
INSTEAD OF DELETE ON nexuses.lEV_Event
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of EV_DAT_Event_Date is retracted
    INSERT INTO attributes.EV_DAT_Event_Date_Meta (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_Who,
        EV_DAT_PositedAt,
        EV_DAT_Confidence
    )
    SELECT
        :OLD.Metadata_EV_DAT,
        :OLD.EV_DAT_ID,
        COALESCE(:OLD.EV_DAT_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.EV_DAT_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_DAT_Event_Date_Meta x
            WHERE
                x.EV_DAT_ID = :OLD.EV_DAT_ID
            AND
                x.EV_DAT_Who = COALESCE(:OLD.EV_DAT_Who, :OLD.Who, 0)
            AND
                x.EV_DAT_PositedAt = v_now
        );
    -- what is shown of EV_AUD_Event_Audience is retracted
    INSERT INTO attributes.EV_AUD_Event_Audience_Meta (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_Who,
        EV_AUD_PositedAt,
        EV_AUD_Confidence
    )
    SELECT
        :OLD.Metadata_EV_AUD,
        :OLD.EV_AUD_ID,
        COALESCE(:OLD.EV_AUD_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.EV_AUD_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_AUD_Event_Audience_Meta x
            WHERE
                x.EV_AUD_ID = :OLD.EV_AUD_ID
            AND
                x.EV_AUD_Who = COALESCE(:OLD.EV_AUD_Who, :OLD.Who, 0)
            AND
                x.EV_AUD_PositedAt = v_now
        );
    -- what is shown of EV_REV_Event_Revenue is retracted
    INSERT INTO attributes.EV_REV_Event_Revenue_Meta (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_Who,
        EV_REV_PositedAt,
        EV_REV_Confidence
    )
    SELECT
        :OLD.Metadata_EV_REV,
        :OLD.EV_REV_ID,
        COALESCE(:OLD.EV_REV_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.EV_REV_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_REV_Event_Revenue_Meta x
            WHERE
                x.EV_REV_ID = :OLD.EV_REV_ID
            AND
                x.EV_REV_Who = COALESCE(:OLD.EV_REV_Who, :OLD.Who, 0)
            AND
                x.EV_REV_PositedAt = v_now
        );
    -- what is shown of EV_STA_Event_Status is retracted
    INSERT INTO attributes.EV_STA_Event_Status_Meta (
        Metadata_EV_STA,
        EV_STA_ID,
        EV_STA_Who,
        EV_STA_PositedAt,
        EV_STA_Confidence
    )
    SELECT
        :OLD.Metadata_EV_STA,
        :OLD.EV_STA_ID,
        COALESCE(:OLD.EV_STA_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.EV_STA_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_STA_Event_Status_Meta x
            WHERE
                x.EV_STA_ID = :OLD.EV_STA_ID
            AND
                x.EV_STA_Who = COALESCE(:OLD.EV_STA_Who, :OLD.Who, 0)
            AND
                x.EV_STA_PositedAt = v_now
        );
    -- what is shown of EV_UTL_Event_Utilization is retracted
    INSERT INTO attributes.EV_UTL_Event_Utilization_Meta (
        Metadata_EV_UTL,
        EV_UTL_ID,
        EV_UTL_Who,
        EV_UTL_PositedAt,
        EV_UTL_Confidence
    )
    SELECT
        :OLD.Metadata_EV_UTL,
        :OLD.EV_UTL_ID,
        COALESCE(:OLD.EV_UTL_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.EV_UTL_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_UTL_Event_Utilization_Meta x
            WHERE
                x.EV_UTL_ID = :OLD.EV_UTL_ID
            AND
                x.EV_UTL_Who = COALESCE(:OLD.EV_UTL_Who, :OLD.Who, 0)
            AND
                x.EV_UTL_PositedAt = v_now
        );
    -- what is shown of EV_LVL_Event_Level is retracted
    INSERT INTO attributes.EV_LVL_Event_Level_Meta (
        Metadata_EV_LVL,
        EV_LVL_ID,
        EV_LVL_Who,
        EV_LVL_PositedAt,
        EV_LVL_Confidence
    )
    SELECT
        :OLD.Metadata_EV_LVL,
        :OLD.EV_LVL_ID,
        COALESCE(:OLD.EV_LVL_Who, :OLD.Who, 0),
        v_now,
        0.25
    FROM
        dual
    WHERE
        :OLD.EV_LVL_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_LVL_Event_Level_Meta x
            WHERE
                x.EV_LVL_ID = :OLD.EV_LVL_ID
            AND
                x.EV_LVL_Who = COALESCE(:OLD.EV_LVL_Who, :OLD.Who, 0)
            AND
                x.EV_LVL_PositedAt = v_now
        );
END dt_lEV_Event;
/
