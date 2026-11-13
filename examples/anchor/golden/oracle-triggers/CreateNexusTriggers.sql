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
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_id number(10);
BEGIN
    v_id := :NEW.EV_ID;
    IF v_id IS NULL THEN
        INSERT INTO EV_Event (
            SU_ID_for,
            Metadata_EV
        )
        VALUES (
            :NEW.SU_ID_for,
            :NEW.Metadata_EV
        )
        RETURNING EV_ID INTO v_id;
    END IF;
    IF :NEW.EV_QTY_Event_Quantity IS NOT NULL THEN
        ip_EV_QTY_Event_Quantity(
            p_owner => COALESCE(:NEW.EV_QTY_EV_ID, v_id),
            p_value => :NEW.EV_QTY_Event_Quantity,
            p_metadata => COALESCE(:NEW.Metadata_EV_QTY, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_PLC_Event_Place IS NOT NULL THEN
        ip_EV_PLC_Event_Place(
            p_owner => COALESCE(:NEW.EV_PLC_EV_ID, v_id),
            p_changing => COALESCE(:NEW.EV_PLC_ChangedAt, v_now),
            p_value => :NEW.EV_PLC_Event_Place,
            p_metadata => COALESCE(:NEW.Metadata_EV_PLC, :NEW.Metadata_EV)
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
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    IF (:NEW.EV_ID <> :OLD.EV_ID
        OR (:NEW.EV_ID IS NULL AND :OLD.EV_ID IS NOT NULL)
        OR (:NEW.EV_ID IS NOT NULL AND :OLD.EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_ID is not updatable.');
    END IF;
    IF (:NEW.SU_ID_for <> :OLD.SU_ID_for
        OR (:NEW.SU_ID_for IS NULL AND :OLD.SU_ID_for IS NOT NULL)
        OR (:NEW.SU_ID_for IS NOT NULL AND :OLD.SU_ID_for IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column SU_ID_for is not updatable.');
    END IF;
    IF (:NEW.EV_QTY_EV_ID <> :OLD.EV_QTY_EV_ID
        OR (:NEW.EV_QTY_EV_ID IS NULL AND :OLD.EV_QTY_EV_ID IS NOT NULL)
        OR (:NEW.EV_QTY_EV_ID IS NOT NULL AND :OLD.EV_QTY_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_QTY_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_QTY_Event_Quantity <> :OLD.EV_QTY_Event_Quantity
        OR (:NEW.EV_QTY_Event_Quantity IS NULL AND :OLD.EV_QTY_Event_Quantity IS NOT NULL)
        OR (:NEW.EV_QTY_Event_Quantity IS NOT NULL AND :OLD.EV_QTY_Event_Quantity IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_QTY_Event_Quantity IS NOT NULL THEN
            ip_EV_QTY_Event_Quantity(
                p_owner => COALESCE(:NEW.EV_QTY_EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_QTY_Event_Quantity,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_QTY = :OLD.Metadata_EV_QTY
                            OR (:NEW.Metadata_EV_QTY IS NULL AND :OLD.Metadata_EV_QTY IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_QTY
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF :NEW.Deletable_EV_QTY = 1
    AND :OLD.EV_QTY_Event_Quantity IS NOT NULL
    AND :NEW.EV_QTY_Event_Quantity IS NULL
    THEN
        INSERT INTO EV_QTY_Event_Quantity_Deleted (
            EV_QTY_EV_ID,
            EV_QTY_Event_Quantity,
            Metadata_EV_QTY,
            EV_QTY_Deleted
        )
        SELECT
            x.EV_QTY_EV_ID,
            x.EV_QTY_Event_Quantity,
            x.Metadata_EV_QTY,
            v_now
        FROM
            EV_QTY_Event_Quantity x
        WHERE
            x.EV_QTY_EV_ID = :OLD.EV_ID;
        DELETE FROM
            EV_QTY_Event_Quantity
        WHERE
            EV_QTY_EV_ID = :OLD.EV_ID;
    END IF;
    IF (:NEW.EV_PLC_EV_ID <> :OLD.EV_PLC_EV_ID
        OR (:NEW.EV_PLC_EV_ID IS NULL AND :OLD.EV_PLC_EV_ID IS NOT NULL)
        OR (:NEW.EV_PLC_EV_ID IS NOT NULL AND :OLD.EV_PLC_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_PLC_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_PLC_Event_Place <> :OLD.EV_PLC_Event_Place
        OR (:NEW.EV_PLC_Event_Place IS NULL AND :OLD.EV_PLC_Event_Place IS NOT NULL)
        OR (:NEW.EV_PLC_Event_Place IS NOT NULL AND :OLD.EV_PLC_Event_Place IS NULL))
    OR (:NEW.EV_PLC_ChangedAt <> :OLD.EV_PLC_ChangedAt
        OR (:NEW.EV_PLC_ChangedAt IS NULL AND :OLD.EV_PLC_ChangedAt IS NOT NULL)
        OR (:NEW.EV_PLC_ChangedAt IS NOT NULL AND :OLD.EV_PLC_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_PLC_Event_Place IS NOT NULL THEN
            ip_EV_PLC_Event_Place(
                p_owner => COALESCE(:NEW.EV_PLC_EV_ID, :NEW.EV_ID),
                p_changing => CASE
                    WHEN (:NEW.EV_PLC_ChangedAt <> :OLD.EV_PLC_ChangedAt
                        OR (:NEW.EV_PLC_ChangedAt IS NULL AND :OLD.EV_PLC_ChangedAt IS NOT NULL)
                        OR (:NEW.EV_PLC_ChangedAt IS NOT NULL AND :OLD.EV_PLC_ChangedAt IS NULL))
                    THEN :NEW.EV_PLC_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.EV_PLC_Event_Place,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_PLC = :OLD.Metadata_EV_PLC
                            OR (:NEW.Metadata_EV_PLC IS NULL AND :OLD.Metadata_EV_PLC IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_PLC
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF :NEW.Deletable_EV_PLC = 1
    AND :OLD.EV_PLC_Event_Place IS NOT NULL
    AND :NEW.EV_PLC_Event_Place IS NULL
    THEN
        INSERT INTO EV_PLC_Event_Place_Deleted (
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt,
            Metadata_EV_PLC,
            EV_PLC_Deleted
        )
        SELECT
            x.EV_PLC_EV_ID,
            x.EV_PLC_Event_Place,
            x.EV_PLC_ChangedAt,
            x.Metadata_EV_PLC,
            CAST(CASE WHEN :NEW.EV_PLC_ChangedAt <> :OLD.EV_PLC_ChangedAt
                    OR (:NEW.EV_PLC_ChangedAt IS NULL AND :OLD.EV_PLC_ChangedAt IS NOT NULL)
                    OR (:NEW.EV_PLC_ChangedAt IS NOT NULL AND :OLD.EV_PLC_ChangedAt IS NULL)
                THEN :NEW.EV_PLC_ChangedAt ELSE v_now END AS timestamp)
        FROM
            EV_PLC_Event_Place x
        WHERE
            x.EV_PLC_EV_ID = :OLD.EV_ID;
        DELETE FROM
            EV_PLC_Event_Place
        WHERE
            EV_PLC_EV_ID = :OLD.EV_ID;
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
        EV_QTY_Event_Quantity x
    WHERE
        x.EV_QTY_EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        EV_PLC_Event_Place x
    WHERE
        x.EV_PLC_EV_ID = :OLD.EV_ID
    AND
        x.EV_PLC_ChangedAt = :OLD.EV_PLC_ChangedAt
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
            EV_QTY_Event_Quantity x
        WHERE
            x.EV_QTY_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            EV_PLC_Event_Place x
        WHERE
            x.EV_PLC_EV_ID = a.EV_ID
    )
    ;
END dt_lEV_Event;
/
