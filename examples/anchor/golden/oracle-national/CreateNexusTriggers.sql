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
-- it_lEV_Händelse instead of INSERT trigger on lEV_Händelse
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER nexuses.it_lEV_Händelse
INSTEAD OF INSERT ON nexuses.lEV_Händelse
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(12,0);
    v_ETY_of number(3);
    v_UTL number(3);
    v_LVL number(3);
BEGIN
    v_id := :NEW.EV_ID;
    IF v_id IS NULL THEN
        -- the identity of the knot value of the role, given as it is or looked up from the value
        v_ETY_of := :NEW.ETY_ID_of;
        IF v_ETY_of IS NULL AND :NEW.of_ETY_Händelsetyp IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.ETY_ID
                FROM
                    knots.ETY_Händelsetyp k
                WHERE
                    k.ETY_Checksum = STANDARD_HASH(:NEW.of_ETY_Händelsetyp, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_ETY_of := kv.ETY_ID;
            END LOOP;
        END IF;
        INSERT INTO nexuses.EV_Händelse (
            ST_ID_hölls,
            PR_ID_spelades,
            ETY_ID_of,
            Metadata_EV
        )
        VALUES (
            :NEW.ST_ID_hölls,
            :NEW.PR_ID_spelades,
            v_ETY_of,
            :NEW.Metadata_EV
        )
        RETURNING EV_ID INTO v_id;
    END IF;
    IF :NEW.EV_DAT_Händelse_Datum IS NOT NULL THEN
        attributes.ip_EV_DAT_Händelse_Datum(
            p_owner => COALESCE(:NEW.EV_DAT_EV_ID, v_id),
            p_value => :NEW.EV_DAT_Händelse_Datum,
            p_metadata => COALESCE(:NEW.Metadata_EV_DAT, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_AUD_Händelse_Publik IS NOT NULL THEN
        attributes.ip_EV_AUD_Händelse_Publik(
            p_owner => COALESCE(:NEW.EV_AUD_EV_ID, v_id),
            p_value => :NEW.EV_AUD_Händelse_Publik,
            p_metadata => COALESCE(:NEW.Metadata_EV_AUD, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_REV_Händelse_Intäkt IS NOT NULL THEN
        attributes.ip_EV_REV_Händelse_Intäkt(
            p_owner => COALESCE(:NEW.EV_REV_EV_ID, v_id),
            p_value => :NEW.EV_REV_Händelse_Intäkt,
            p_metadata => COALESCE(:NEW.Metadata_EV_REV, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_STA_Händelse_Status IS NOT NULL THEN
        attributes.ip_EV_STA_Händelse_Status(
            p_owner => COALESCE(:NEW.EV_STA_EV_ID, v_id),
            p_changing => COALESCE(:NEW.EV_STA_ChangedAt, v_now),
            p_value => :NEW.EV_STA_Händelse_Status,
            p_metadata => COALESCE(:NEW.Metadata_EV_STA, :NEW.Metadata_EV)
        );
    END IF;
    v_UTL := :NEW.EV_UTL_UTL_ID;
    IF v_UTL IS NULL AND :NEW.EV_UTL_UTL_Utnyttjande IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                knots.UTL_Utnyttjande k
            WHERE
                k.UTL_Utnyttjande = :NEW.EV_UTL_UTL_Utnyttjande
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_UTL := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_UTL IS NOT NULL THEN
        attributes.ip_EV_UTL_Händelse_Utnyttjande(
            p_owner => COALESCE(:NEW.EV_UTL_EV_ID, v_id),
            p_value => v_UTL,
            p_metadata => COALESCE(:NEW.Metadata_EV_UTL, :NEW.Metadata_EV)
        );
    END IF;
    v_LVL := :NEW.EV_LVL_PLV_ID;
    IF v_LVL IS NULL AND :NEW.EV_LVL_PLV_Yrkesnivå IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PLV_ID
            FROM
                knots.PLV_Yrkesnivå k
            WHERE
                k.PLV_Checksum = STANDARD_HASH(:NEW.EV_LVL_PLV_Yrkesnivå, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_LVL := kv.PLV_ID;
        END LOOP;
    END IF;
    IF v_LVL IS NOT NULL THEN
        attributes.ip_EV_LVL_Händelse_Level(
            p_owner => COALESCE(:NEW.EV_LVL_EV_ID, v_id),
            p_changing => COALESCE(:NEW.EV_LVL_ChangedAt, v_now),
            p_value => v_LVL,
            p_metadata => COALESCE(:NEW.Metadata_EV_LVL, :NEW.Metadata_EV)
        );
    END IF;
END it_lEV_Händelse;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lEV_Händelse instead of UPDATE trigger on lEV_Händelse
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER nexuses.ut_lEV_Händelse
INSTEAD OF UPDATE ON nexuses.lEV_Händelse
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_UTL number(3);
    v_LVL number(3);
BEGIN
    IF (:NEW.EV_ID <> :OLD.EV_ID
        OR (:NEW.EV_ID IS NULL AND :OLD.EV_ID IS NOT NULL)
        OR (:NEW.EV_ID IS NOT NULL AND :OLD.EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_ID is not updatable.');
    END IF;
    IF (:NEW.ST_ID_hölls <> :OLD.ST_ID_hölls
        OR (:NEW.ST_ID_hölls IS NULL AND :OLD.ST_ID_hölls IS NOT NULL)
        OR (:NEW.ST_ID_hölls IS NOT NULL AND :OLD.ST_ID_hölls IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column ST_ID_hölls is not updatable.');
    END IF;
    IF (:NEW.PR_ID_spelades <> :OLD.PR_ID_spelades
        OR (:NEW.PR_ID_spelades IS NULL AND :OLD.PR_ID_spelades IS NOT NULL)
        OR (:NEW.PR_ID_spelades IS NOT NULL AND :OLD.PR_ID_spelades IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column PR_ID_spelades is not updatable.');
    END IF;
    IF (:NEW.ETY_ID_of <> :OLD.ETY_ID_of
        OR (:NEW.ETY_ID_of IS NULL AND :OLD.ETY_ID_of IS NOT NULL)
        OR (:NEW.ETY_ID_of IS NOT NULL AND :OLD.ETY_ID_of IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column ETY_ID_of is not updatable.');
    END IF;
    IF (:NEW.of_ETY_Händelsetyp <> :OLD.of_ETY_Händelsetyp
        OR (:NEW.of_ETY_Händelsetyp IS NULL AND :OLD.of_ETY_Händelsetyp IS NOT NULL)
        OR (:NEW.of_ETY_Händelsetyp IS NOT NULL AND :OLD.of_ETY_Händelsetyp IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column of_ETY_Händelsetyp is not updatable.');
    END IF;
    IF (:NEW.EV_DAT_EV_ID <> :OLD.EV_DAT_EV_ID
        OR (:NEW.EV_DAT_EV_ID IS NULL AND :OLD.EV_DAT_EV_ID IS NOT NULL)
        OR (:NEW.EV_DAT_EV_ID IS NOT NULL AND :OLD.EV_DAT_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_DAT_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_DAT_Händelse_Datum <> :OLD.EV_DAT_Händelse_Datum
        OR (:NEW.EV_DAT_Händelse_Datum IS NULL AND :OLD.EV_DAT_Händelse_Datum IS NOT NULL)
        OR (:NEW.EV_DAT_Händelse_Datum IS NOT NULL AND :OLD.EV_DAT_Händelse_Datum IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_DAT_Händelse_Datum IS NOT NULL THEN
            attributes.ip_EV_DAT_Händelse_Datum(
                p_owner => COALESCE(:NEW.EV_DAT_EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_DAT_Händelse_Datum,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_DAT = :OLD.Metadata_EV_DAT
                            OR (:NEW.Metadata_EV_DAT IS NULL AND :OLD.Metadata_EV_DAT IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_DAT
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    IF (:NEW.EV_AUD_EV_ID <> :OLD.EV_AUD_EV_ID
        OR (:NEW.EV_AUD_EV_ID IS NULL AND :OLD.EV_AUD_EV_ID IS NOT NULL)
        OR (:NEW.EV_AUD_EV_ID IS NOT NULL AND :OLD.EV_AUD_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_AUD_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_AUD_Händelse_Publik <> :OLD.EV_AUD_Händelse_Publik
        OR (:NEW.EV_AUD_Händelse_Publik IS NULL AND :OLD.EV_AUD_Händelse_Publik IS NOT NULL)
        OR (:NEW.EV_AUD_Händelse_Publik IS NOT NULL AND :OLD.EV_AUD_Händelse_Publik IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_AUD_Händelse_Publik IS NOT NULL THEN
            attributes.ip_EV_AUD_Händelse_Publik(
                p_owner => COALESCE(:NEW.EV_AUD_EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_AUD_Händelse_Publik,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_AUD = :OLD.Metadata_EV_AUD
                            OR (:NEW.Metadata_EV_AUD IS NULL AND :OLD.Metadata_EV_AUD IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_AUD
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    IF (:NEW.EV_REV_EV_ID <> :OLD.EV_REV_EV_ID
        OR (:NEW.EV_REV_EV_ID IS NULL AND :OLD.EV_REV_EV_ID IS NOT NULL)
        OR (:NEW.EV_REV_EV_ID IS NOT NULL AND :OLD.EV_REV_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_REV_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_REV_Händelse_Intäkt <> :OLD.EV_REV_Händelse_Intäkt
        OR (:NEW.EV_REV_Händelse_Intäkt IS NULL AND :OLD.EV_REV_Händelse_Intäkt IS NOT NULL)
        OR (:NEW.EV_REV_Händelse_Intäkt IS NOT NULL AND :OLD.EV_REV_Händelse_Intäkt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_REV_Händelse_Intäkt IS NOT NULL THEN
            attributes.ip_EV_REV_Händelse_Intäkt(
                p_owner => COALESCE(:NEW.EV_REV_EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_REV_Händelse_Intäkt,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_REV = :OLD.Metadata_EV_REV
                            OR (:NEW.Metadata_EV_REV IS NULL AND :OLD.Metadata_EV_REV IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_REV
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    IF (:NEW.EV_STA_EV_ID <> :OLD.EV_STA_EV_ID
        OR (:NEW.EV_STA_EV_ID IS NULL AND :OLD.EV_STA_EV_ID IS NOT NULL)
        OR (:NEW.EV_STA_EV_ID IS NOT NULL AND :OLD.EV_STA_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_STA_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_STA_Händelse_Status <> :OLD.EV_STA_Händelse_Status
        OR (:NEW.EV_STA_Händelse_Status IS NULL AND :OLD.EV_STA_Händelse_Status IS NOT NULL)
        OR (:NEW.EV_STA_Händelse_Status IS NOT NULL AND :OLD.EV_STA_Händelse_Status IS NULL))
    OR (:NEW.EV_STA_ChangedAt <> :OLD.EV_STA_ChangedAt
        OR (:NEW.EV_STA_ChangedAt IS NULL AND :OLD.EV_STA_ChangedAt IS NOT NULL)
        OR (:NEW.EV_STA_ChangedAt IS NOT NULL AND :OLD.EV_STA_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_STA_Händelse_Status IS NOT NULL THEN
            attributes.ip_EV_STA_Händelse_Status(
                p_owner => COALESCE(:NEW.EV_STA_EV_ID, :NEW.EV_ID),
                p_changing => CASE
                    WHEN (:NEW.EV_STA_ChangedAt <> :OLD.EV_STA_ChangedAt
                        OR (:NEW.EV_STA_ChangedAt IS NULL AND :OLD.EV_STA_ChangedAt IS NOT NULL)
                        OR (:NEW.EV_STA_ChangedAt IS NOT NULL AND :OLD.EV_STA_ChangedAt IS NULL))
                    THEN :NEW.EV_STA_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.EV_STA_Händelse_Status,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_STA = :OLD.Metadata_EV_STA
                            OR (:NEW.Metadata_EV_STA IS NULL AND :OLD.Metadata_EV_STA IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_STA
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    IF (:NEW.EV_UTL_EV_ID <> :OLD.EV_UTL_EV_ID
        OR (:NEW.EV_UTL_EV_ID IS NULL AND :OLD.EV_UTL_EV_ID IS NOT NULL)
        OR (:NEW.EV_UTL_EV_ID IS NOT NULL AND :OLD.EV_UTL_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_UTL_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_UTL_UTL_ID <> :OLD.EV_UTL_UTL_ID
        OR (:NEW.EV_UTL_UTL_ID IS NULL AND :OLD.EV_UTL_UTL_ID IS NOT NULL)
        OR (:NEW.EV_UTL_UTL_ID IS NOT NULL AND :OLD.EV_UTL_UTL_ID IS NULL))
    OR (:NEW.EV_UTL_UTL_Utnyttjande <> :OLD.EV_UTL_UTL_Utnyttjande
        OR (:NEW.EV_UTL_UTL_Utnyttjande IS NULL AND :OLD.EV_UTL_UTL_Utnyttjande IS NOT NULL)
        OR (:NEW.EV_UTL_UTL_Utnyttjande IS NOT NULL AND :OLD.EV_UTL_UTL_Utnyttjande IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_UTL := :NEW.EV_UTL_UTL_ID;
        IF (v_UTL = :OLD.EV_UTL_UTL_ID OR (v_UTL IS NULL AND :OLD.EV_UTL_UTL_ID IS NULL))
        AND :NEW.EV_UTL_UTL_Utnyttjande IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    knots.UTL_Utnyttjande k
                WHERE
                    k.UTL_Utnyttjande = :NEW.EV_UTL_UTL_Utnyttjande
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_UTL := kv.UTL_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_UTL IS NOT NULL AND (
            :OLD.EV_UTL_UTL_ID IS NULL OR
            :OLD.EV_UTL_UTL_ID <> v_UTL
        ) THEN
            attributes.ip_EV_UTL_Händelse_Utnyttjande(
                p_owner => COALESCE(:NEW.EV_UTL_EV_ID, :NEW.EV_ID),
                p_value => v_UTL,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_UTL = :OLD.Metadata_EV_UTL
                            OR (:NEW.Metadata_EV_UTL IS NULL AND :OLD.Metadata_EV_UTL IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_UTL
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    IF (:NEW.EV_LVL_EV_ID <> :OLD.EV_LVL_EV_ID
        OR (:NEW.EV_LVL_EV_ID IS NULL AND :OLD.EV_LVL_EV_ID IS NOT NULL)
        OR (:NEW.EV_LVL_EV_ID IS NOT NULL AND :OLD.EV_LVL_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_LVL_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_LVL_PLV_ID <> :OLD.EV_LVL_PLV_ID
        OR (:NEW.EV_LVL_PLV_ID IS NULL AND :OLD.EV_LVL_PLV_ID IS NOT NULL)
        OR (:NEW.EV_LVL_PLV_ID IS NOT NULL AND :OLD.EV_LVL_PLV_ID IS NULL))
    OR (:NEW.EV_LVL_PLV_Yrkesnivå <> :OLD.EV_LVL_PLV_Yrkesnivå
        OR (:NEW.EV_LVL_PLV_Yrkesnivå IS NULL AND :OLD.EV_LVL_PLV_Yrkesnivå IS NOT NULL)
        OR (:NEW.EV_LVL_PLV_Yrkesnivå IS NOT NULL AND :OLD.EV_LVL_PLV_Yrkesnivå IS NULL))
    OR (:NEW.EV_LVL_ChangedAt <> :OLD.EV_LVL_ChangedAt
        OR (:NEW.EV_LVL_ChangedAt IS NULL AND :OLD.EV_LVL_ChangedAt IS NOT NULL)
        OR (:NEW.EV_LVL_ChangedAt IS NOT NULL AND :OLD.EV_LVL_ChangedAt IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_LVL := :NEW.EV_LVL_PLV_ID;
        IF (v_LVL = :OLD.EV_LVL_PLV_ID OR (v_LVL IS NULL AND :OLD.EV_LVL_PLV_ID IS NULL))
        AND :NEW.EV_LVL_PLV_Yrkesnivå IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.PLV_ID
                FROM
                    knots.PLV_Yrkesnivå k
                WHERE
                    k.PLV_Checksum = STANDARD_HASH(:NEW.EV_LVL_PLV_Yrkesnivå, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_LVL := kv.PLV_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_LVL IS NOT NULL AND (
            (:NEW.EV_LVL_ChangedAt <> :OLD.EV_LVL_ChangedAt
                OR (:NEW.EV_LVL_ChangedAt IS NULL AND :OLD.EV_LVL_ChangedAt IS NOT NULL)
                OR (:NEW.EV_LVL_ChangedAt IS NOT NULL AND :OLD.EV_LVL_ChangedAt IS NULL)) OR
            :OLD.EV_LVL_PLV_ID IS NULL OR
            :OLD.EV_LVL_PLV_ID <> v_LVL
        ) THEN
            attributes.ip_EV_LVL_Händelse_Level(
                p_owner => COALESCE(:NEW.EV_LVL_EV_ID, :NEW.EV_ID),
                p_changing => CASE
                    WHEN (:NEW.EV_LVL_ChangedAt <> :OLD.EV_LVL_ChangedAt
                        OR (:NEW.EV_LVL_ChangedAt IS NULL AND :OLD.EV_LVL_ChangedAt IS NOT NULL)
                        OR (:NEW.EV_LVL_ChangedAt IS NOT NULL AND :OLD.EV_LVL_ChangedAt IS NULL))
                    THEN :NEW.EV_LVL_ChangedAt
                    ELSE v_now
                END,
                p_value => v_LVL,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_LVL = :OLD.Metadata_EV_LVL
                            OR (:NEW.Metadata_EV_LVL IS NULL AND :OLD.Metadata_EV_LVL IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_LVL
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
END ut_lEV_Händelse;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_Händelse instead of DELETE trigger on lEV_Händelse
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER nexuses.dt_lEV_Händelse
INSTEAD OF DELETE ON nexuses.lEV_Händelse
FOR EACH ROW
BEGIN
    DELETE FROM
        attributes.EV_DAT_Händelse_Datum x
    WHERE
        x.EV_DAT_EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        attributes.EV_AUD_Händelse_Publik x
    WHERE
        x.EV_AUD_EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        attributes.EV_REV_Händelse_Intäkt x
    WHERE
        x.EV_REV_EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        attributes.EV_STA_Händelse_Status x
    WHERE
        x.EV_STA_EV_ID = :OLD.EV_ID
    AND
        x.EV_STA_ChangedAt = :OLD.EV_STA_ChangedAt
    ;
    DELETE FROM
        attributes.EV_UTL_Händelse_Utnyttjande x
    WHERE
        x.EV_UTL_EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        attributes.EV_LVL_Händelse_Level x
    WHERE
        x.EV_LVL_EV_ID = :OLD.EV_ID
    AND
        x.EV_LVL_ChangedAt = :OLD.EV_LVL_ChangedAt
    ;
    -- a nexus that has no attribute rows left is removed
    DELETE FROM
        nexuses.EV_Händelse a
    WHERE
        a.EV_ID = :OLD.EV_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_DAT_Händelse_Datum x
        WHERE
            x.EV_DAT_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_AUD_Händelse_Publik x
        WHERE
            x.EV_AUD_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_REV_Händelse_Intäkt x
        WHERE
            x.EV_REV_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_STA_Händelse_Status x
        WHERE
            x.EV_STA_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_UTL_Händelse_Utnyttjande x
        WHERE
            x.EV_UTL_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_LVL_Händelse_Level x
        WHERE
            x.EV_LVL_EV_ID = a.EV_ID
    )
    ;
END dt_lEV_Händelse;
/
