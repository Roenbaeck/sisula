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
CREATE OR REPLACE TRIGGER it_lEV_Event
INSTEAD OF INSERT ON lEV_Event
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
BEGIN
    v_id := :NEW.EV_ID;
    IF v_id IS NULL THEN
        INSERT INTO EV_Event (
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
        ip_EV_DAT_Event_Date(
            p_owner => COALESCE(:NEW.EV_DAT_EV_ID, v_id),
            p_value => :NEW.EV_DAT_Event_Date,
            p_positor => COALESCE(:NEW.EV_DAT_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.EV_DAT_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_DAT_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_DAT, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_AUD_Event_Audience IS NOT NULL THEN
        ip_EV_AUD_Event_Audience(
            p_owner => COALESCE(:NEW.EV_AUD_EV_ID, v_id),
            p_value => :NEW.EV_AUD_Event_Audience,
            p_positor => COALESCE(:NEW.EV_AUD_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.EV_AUD_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_AUD_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_AUD, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_REV_Event_Revenue IS NOT NULL THEN
        ip_EV_REV_Event_Revenue(
            p_owner => COALESCE(:NEW.EV_REV_EV_ID, v_id),
            p_value => :NEW.EV_REV_Event_Revenue,
            p_positor => COALESCE(:NEW.EV_REV_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.EV_REV_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_REV_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_REV, :NEW.Metadata_EV)
        );
    END IF;
END it_lEV_Event;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lEV_Event instead of UPDATE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lEV_Event
INSTEAD OF UPDATE ON lEV_Event
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(10);
    v_nexus_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
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
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
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
    v_reliability_diff := CASE WHEN (:NEW.EV_DAT_Reliability <> :OLD.EV_DAT_Reliability
        OR (:NEW.EV_DAT_Reliability IS NULL AND :OLD.EV_DAT_Reliability IS NOT NULL)
        OR (:NEW.EV_DAT_Reliability IS NOT NULL AND :OLD.EV_DAT_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_DAT_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_DAT_Reliability;
    END IF;
    IF (:NEW.EV_DAT_Positor <> :OLD.EV_DAT_Positor
        OR (:NEW.EV_DAT_Positor IS NULL AND :OLD.EV_DAT_Positor IS NOT NULL)
        OR (:NEW.EV_DAT_Positor IS NOT NULL AND :OLD.EV_DAT_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_DAT_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
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
            OR :OLD.EV_DAT_Reliability IS NULL
            OR :OLD.EV_DAT_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.EV_DAT_Positor IS NULL
            OR :OLD.EV_DAT_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_EV_DAT_Event_Date(
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
            ip_EV_DAT_Event_Date(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_DAT_Event_Date,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
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
    v_reliability_diff := CASE WHEN (:NEW.EV_AUD_Reliability <> :OLD.EV_AUD_Reliability
        OR (:NEW.EV_AUD_Reliability IS NULL AND :OLD.EV_AUD_Reliability IS NOT NULL)
        OR (:NEW.EV_AUD_Reliability IS NOT NULL AND :OLD.EV_AUD_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_AUD_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_AUD_Reliability;
    END IF;
    IF (:NEW.EV_AUD_Positor <> :OLD.EV_AUD_Positor
        OR (:NEW.EV_AUD_Positor IS NULL AND :OLD.EV_AUD_Positor IS NOT NULL)
        OR (:NEW.EV_AUD_Positor IS NOT NULL AND :OLD.EV_AUD_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_AUD_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
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
            OR :OLD.EV_AUD_Reliability IS NULL
            OR :OLD.EV_AUD_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.EV_AUD_Positor IS NULL
            OR :OLD.EV_AUD_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_EV_AUD_Event_Audience(
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
            ip_EV_AUD_Event_Audience(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_AUD_Event_Audience,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
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
    v_reliability_diff := CASE WHEN (:NEW.EV_REV_Reliability <> :OLD.EV_REV_Reliability
        OR (:NEW.EV_REV_Reliability IS NULL AND :OLD.EV_REV_Reliability IS NOT NULL)
        OR (:NEW.EV_REV_Reliability IS NOT NULL AND :OLD.EV_REV_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_REV_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_REV_Reliability;
    END IF;
    IF (:NEW.EV_REV_Positor <> :OLD.EV_REV_Positor
        OR (:NEW.EV_REV_Positor IS NULL AND :OLD.EV_REV_Positor IS NOT NULL)
        OR (:NEW.EV_REV_Positor IS NOT NULL AND :OLD.EV_REV_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_REV_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
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
            OR :OLD.EV_REV_Reliability IS NULL
            OR :OLD.EV_REV_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.EV_REV_Positor IS NULL
            OR :OLD.EV_REV_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_EV_REV_Event_Revenue(
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
            ip_EV_REV_Event_Revenue(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_REV_Event_Revenue,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
END ut_lEV_Event;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_Event instead of DELETE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lEV_Event
INSTEAD OF DELETE ON lEV_Event
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of EV_DAT_Event_Date is retracted
    INSERT INTO EV_DAT_Event_Date_Annex (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_Positor,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    SELECT
        :OLD.Metadata_EV_DAT,
        :OLD.EV_DAT_ID,
        COALESCE(:OLD.EV_DAT_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_DAT_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                EV_DAT_Event_Date_Annex x
            WHERE
                x.EV_DAT_ID = :OLD.EV_DAT_ID
            AND
                x.EV_DAT_Positor = COALESCE(:OLD.EV_DAT_Positor, :OLD.Positor, 0)
            AND
                x.EV_DAT_PositedAt = v_now
        );
    -- what is shown of EV_AUD_Event_Audience is retracted
    INSERT INTO EV_AUD_Event_Audience_Annex (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_Positor,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    SELECT
        :OLD.Metadata_EV_AUD,
        :OLD.EV_AUD_ID,
        COALESCE(:OLD.EV_AUD_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_AUD_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                EV_AUD_Event_Audience_Annex x
            WHERE
                x.EV_AUD_ID = :OLD.EV_AUD_ID
            AND
                x.EV_AUD_Positor = COALESCE(:OLD.EV_AUD_Positor, :OLD.Positor, 0)
            AND
                x.EV_AUD_PositedAt = v_now
        );
    -- what is shown of EV_REV_Event_Revenue is retracted
    INSERT INTO EV_REV_Event_Revenue_Annex (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_Positor,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    SELECT
        :OLD.Metadata_EV_REV,
        :OLD.EV_REV_ID,
        COALESCE(:OLD.EV_REV_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_REV_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                EV_REV_Event_Revenue_Annex x
            WHERE
                x.EV_REV_ID = :OLD.EV_REV_ID
            AND
                x.EV_REV_Positor = COALESCE(:OLD.EV_REV_Positor, :OLD.Positor, 0)
            AND
                x.EV_REV_PositedAt = v_now
        );
END dt_lEV_Event;
/
