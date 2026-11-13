-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
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
-- it_lEV_Event instead of INSERT trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lEV_Event
INSTEAD OF INSERT ON lEV_Event
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
    v_ETY_of number(3);
BEGIN
    v_id := :NEW.EV_ID;
    IF v_id IS NULL THEN
        -- the identity of the knot value of the role, given as it is or looked up from the value
        v_ETY_of := :NEW.ETY_ID_of;
        IF v_ETY_of IS NULL AND :NEW.ETY_EventType IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.ETY_ID
                FROM
                    ETY_EventType k
                WHERE
                    k.ETY_EventType = :NEW.ETY_EventType
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_ETY_of := kv.ETY_ID;
            END LOOP;
        END IF;
        INSERT INTO EV_Event (
            ST_ID_wasHeldAt,
            PR_ID_wasPlayed,
            ETY_ID_of,
            EV_Dummy
        )
        VALUES (
            :NEW.ST_ID_wasHeldAt,
            :NEW.PR_ID_wasPlayed,
            v_ETY_of,
            NULL
        )
        RETURNING EV_ID INTO v_id;
    END IF;
    IF :NEW.EV_DAT_Event_Date IS NOT NULL THEN
        ip_EV_DAT_Event_Date(
            p_owner => COALESCE(:NEW.EV_ID, v_id),
            p_value => :NEW.EV_DAT_Event_Date
        );
    END IF;
    IF :NEW.EV_AUD_Event_Audience IS NOT NULL THEN
        ip_EV_AUD_Event_Audience(
            p_owner => COALESCE(:NEW.EV_ID, v_id),
            p_value => :NEW.EV_AUD_Event_Audience
        );
    END IF;
    IF :NEW.EV_REV_Event_Revenue IS NOT NULL THEN
        ip_EV_REV_Event_Revenue(
            p_owner => COALESCE(:NEW.EV_ID, v_id),
            p_value => :NEW.EV_REV_Event_Revenue
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
    IF (:NEW.ETY_EventType <> :OLD.ETY_EventType
        OR (:NEW.ETY_EventType IS NULL AND :OLD.ETY_EventType IS NOT NULL)
        OR (:NEW.ETY_EventType IS NOT NULL AND :OLD.ETY_EventType IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column ETY_EventType is not updatable.');
    END IF;
    IF (:NEW.EV_DAT_Event_Date <> :OLD.EV_DAT_Event_Date
        OR (:NEW.EV_DAT_Event_Date IS NULL AND :OLD.EV_DAT_Event_Date IS NOT NULL)
        OR (:NEW.EV_DAT_Event_Date IS NOT NULL AND :OLD.EV_DAT_Event_Date IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_DAT_Event_Date IS NOT NULL THEN
            ip_EV_DAT_Event_Date(
                p_owner => COALESCE(:NEW.EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_DAT_Event_Date
            );
        END IF;
    END IF;
    IF (:NEW.EV_AUD_Event_Audience <> :OLD.EV_AUD_Event_Audience
        OR (:NEW.EV_AUD_Event_Audience IS NULL AND :OLD.EV_AUD_Event_Audience IS NOT NULL)
        OR (:NEW.EV_AUD_Event_Audience IS NOT NULL AND :OLD.EV_AUD_Event_Audience IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_AUD_Event_Audience IS NOT NULL THEN
            ip_EV_AUD_Event_Audience(
                p_owner => COALESCE(:NEW.EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_AUD_Event_Audience
            );
        END IF;
    END IF;
    IF (:NEW.EV_REV_Event_Revenue <> :OLD.EV_REV_Event_Revenue
        OR (:NEW.EV_REV_Event_Revenue IS NULL AND :OLD.EV_REV_Event_Revenue IS NOT NULL)
        OR (:NEW.EV_REV_Event_Revenue IS NOT NULL AND :OLD.EV_REV_Event_Revenue IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_REV_Event_Revenue IS NOT NULL THEN
            ip_EV_REV_Event_Revenue(
                p_owner => COALESCE(:NEW.EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_REV_Event_Revenue
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
BEGIN
    DELETE FROM
        EV_DAT_Event_Date x
    WHERE
        x.EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        EV_AUD_Event_Audience x
    WHERE
        x.EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        EV_REV_Event_Revenue x
    WHERE
        x.EV_ID = :OLD.EV_ID
    ;
    -- a nexus that has no attribute rows left is removed
    DELETE FROM
        EV_Event a
    WHERE
        a.EV_ID = :OLD.EV_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            EV_DAT_Event_Date x
        WHERE
            x.EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            EV_AUD_Event_Audience x
        WHERE
            x.EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            EV_REV_Event_Revenue x
        WHERE
            x.EV_ID = a.EV_ID
    )
    ;
END dt_lEV_Event;
/
