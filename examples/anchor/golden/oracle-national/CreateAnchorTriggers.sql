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
-- it_lST_Scen instead of INSERT trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.it_lST_Scen
INSTEAD OF INSERT ON anchors.lST_Scen
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
    v_AVG number(3);
    v_MIN number(3);
BEGIN
    v_id := :NEW.ST_ID;
    IF v_id IS NULL THEN
        INSERT INTO anchors.ST_Scen (
            Metadata_ST
        )
        VALUES (
            :NEW.Metadata_ST
        )
        RETURNING ST_ID INTO v_id;
    END IF;
    IF :NEW.ST_NAM_Scen_Namn IS NOT NULL THEN
        attributes.ip_ST_NAM_Scen_Namn(
            p_owner => COALESCE(:NEW.ST_NAM_ST_ID, v_id),
            p_changing => COALESCE(:NEW.ST_NAM_ChangedAt, v_now),
            p_value => :NEW.ST_NAM_Scen_Namn,
            p_metadata => COALESCE(:NEW.Metadata_ST_NAM, :NEW.Metadata_ST)
        );
    END IF;
    IF :NEW.ST_LOC_Scen_Plats IS NOT NULL THEN
        attributes.ip_ST_LOC_Scen_Plats(
            p_owner => COALESCE(:NEW.ST_LOC_ST_ID, v_id),
            p_value => :NEW.ST_LOC_Scen_Plats,
            p_metadata => COALESCE(:NEW.Metadata_ST_LOC, :NEW.Metadata_ST)
        );
    END IF;
    v_AVG := :NEW.ST_AVG_UTL_ID;
    IF v_AVG IS NULL AND :NEW.ST_AVG_UTL_Utnyttjande IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                knots.UTL_Utnyttjande k
            WHERE
                k.UTL_Utnyttjande = :NEW.ST_AVG_UTL_Utnyttjande
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_AVG := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_AVG IS NOT NULL THEN
        attributes.ip_ST_AVG_Scen_Medel(
            p_owner => COALESCE(:NEW.ST_AVG_ST_ID, v_id),
            p_changing => COALESCE(:NEW.ST_AVG_ChangedAt, v_now),
            p_value => v_AVG,
            p_metadata => COALESCE(:NEW.Metadata_ST_AVG, :NEW.Metadata_ST)
        );
    END IF;
    v_MIN := :NEW.ST_MIN_UTL_ID;
    IF v_MIN IS NULL AND :NEW.ST_MIN_UTL_Utnyttjande IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                knots.UTL_Utnyttjande k
            WHERE
                k.UTL_Utnyttjande = :NEW.ST_MIN_UTL_Utnyttjande
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_MIN := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_MIN IS NOT NULL THEN
        attributes.ip_ST_MIN_Scen_Minimum(
            p_owner => COALESCE(:NEW.ST_MIN_ST_ID, v_id),
            p_value => v_MIN,
            p_metadata => COALESCE(:NEW.Metadata_ST_MIN, :NEW.Metadata_ST)
        );
    END IF;
END it_lST_Scen;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Scen instead of UPDATE trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.ut_lST_Scen
INSTEAD OF UPDATE ON anchors.lST_Scen
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_AVG number(3);
    v_MIN number(3);
BEGIN
    IF (:NEW.ST_ID <> :OLD.ST_ID
        OR (:NEW.ST_ID IS NULL AND :OLD.ST_ID IS NOT NULL)
        OR (:NEW.ST_ID IS NOT NULL AND :OLD.ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_NAM_ST_ID <> :OLD.ST_NAM_ST_ID
        OR (:NEW.ST_NAM_ST_ID IS NULL AND :OLD.ST_NAM_ST_ID IS NOT NULL)
        OR (:NEW.ST_NAM_ST_ID IS NOT NULL AND :OLD.ST_NAM_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_NAM_ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_NAM_Scen_Namn <> :OLD.ST_NAM_Scen_Namn
        OR (:NEW.ST_NAM_Scen_Namn IS NULL AND :OLD.ST_NAM_Scen_Namn IS NOT NULL)
        OR (:NEW.ST_NAM_Scen_Namn IS NOT NULL AND :OLD.ST_NAM_Scen_Namn IS NULL))
    OR (:NEW.ST_NAM_ChangedAt <> :OLD.ST_NAM_ChangedAt
        OR (:NEW.ST_NAM_ChangedAt IS NULL AND :OLD.ST_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.ST_NAM_ChangedAt IS NOT NULL AND :OLD.ST_NAM_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.ST_NAM_Scen_Namn IS NOT NULL THEN
            attributes.ip_ST_NAM_Scen_Namn(
                p_owner => COALESCE(:NEW.ST_NAM_ST_ID, :NEW.ST_ID),
                p_changing => CASE
                    WHEN (:NEW.ST_NAM_ChangedAt <> :OLD.ST_NAM_ChangedAt
                        OR (:NEW.ST_NAM_ChangedAt IS NULL AND :OLD.ST_NAM_ChangedAt IS NOT NULL)
                        OR (:NEW.ST_NAM_ChangedAt IS NOT NULL AND :OLD.ST_NAM_ChangedAt IS NULL))
                    THEN :NEW.ST_NAM_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.ST_NAM_Scen_Namn,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_ST <> :OLD.Metadata_ST
                            OR (:NEW.Metadata_ST IS NULL AND :OLD.Metadata_ST IS NOT NULL)
                            OR (:NEW.Metadata_ST IS NOT NULL AND :OLD.Metadata_ST IS NULL))
                        AND (:NEW.Metadata_ST_NAM = :OLD.Metadata_ST_NAM
                            OR (:NEW.Metadata_ST_NAM IS NULL AND :OLD.Metadata_ST_NAM IS NULL))
                        THEN :NEW.Metadata_ST
                        ELSE :NEW.Metadata_ST_NAM
                    END, :NEW.Metadata_ST)
            );
        END IF;
    END IF;
    IF (:NEW.ST_LOC_ST_ID <> :OLD.ST_LOC_ST_ID
        OR (:NEW.ST_LOC_ST_ID IS NULL AND :OLD.ST_LOC_ST_ID IS NOT NULL)
        OR (:NEW.ST_LOC_ST_ID IS NOT NULL AND :OLD.ST_LOC_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_LOC_ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_LOC_Scen_Plats <> :OLD.ST_LOC_Scen_Plats
        OR (:NEW.ST_LOC_Scen_Plats IS NULL AND :OLD.ST_LOC_Scen_Plats IS NOT NULL)
        OR (:NEW.ST_LOC_Scen_Plats IS NOT NULL AND :OLD.ST_LOC_Scen_Plats IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.ST_LOC_Scen_Plats IS NOT NULL THEN
            attributes.ip_ST_LOC_Scen_Plats(
                p_owner => COALESCE(:NEW.ST_LOC_ST_ID, :NEW.ST_ID),
                p_value => :NEW.ST_LOC_Scen_Plats,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_ST <> :OLD.Metadata_ST
                            OR (:NEW.Metadata_ST IS NULL AND :OLD.Metadata_ST IS NOT NULL)
                            OR (:NEW.Metadata_ST IS NOT NULL AND :OLD.Metadata_ST IS NULL))
                        AND (:NEW.Metadata_ST_LOC = :OLD.Metadata_ST_LOC
                            OR (:NEW.Metadata_ST_LOC IS NULL AND :OLD.Metadata_ST_LOC IS NULL))
                        THEN :NEW.Metadata_ST
                        ELSE :NEW.Metadata_ST_LOC
                    END, :NEW.Metadata_ST)
            );
        END IF;
    END IF;
    IF (:NEW.ST_AVG_ST_ID <> :OLD.ST_AVG_ST_ID
        OR (:NEW.ST_AVG_ST_ID IS NULL AND :OLD.ST_AVG_ST_ID IS NOT NULL)
        OR (:NEW.ST_AVG_ST_ID IS NOT NULL AND :OLD.ST_AVG_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_AVG_ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_AVG_UTL_ID <> :OLD.ST_AVG_UTL_ID
        OR (:NEW.ST_AVG_UTL_ID IS NULL AND :OLD.ST_AVG_UTL_ID IS NOT NULL)
        OR (:NEW.ST_AVG_UTL_ID IS NOT NULL AND :OLD.ST_AVG_UTL_ID IS NULL))
    OR (:NEW.ST_AVG_UTL_Utnyttjande <> :OLD.ST_AVG_UTL_Utnyttjande
        OR (:NEW.ST_AVG_UTL_Utnyttjande IS NULL AND :OLD.ST_AVG_UTL_Utnyttjande IS NOT NULL)
        OR (:NEW.ST_AVG_UTL_Utnyttjande IS NOT NULL AND :OLD.ST_AVG_UTL_Utnyttjande IS NULL))
    OR (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
        OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
        OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_AVG := :NEW.ST_AVG_UTL_ID;
        IF (v_AVG = :OLD.ST_AVG_UTL_ID OR (v_AVG IS NULL AND :OLD.ST_AVG_UTL_ID IS NULL))
        AND :NEW.ST_AVG_UTL_Utnyttjande IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    knots.UTL_Utnyttjande k
                WHERE
                    k.UTL_Utnyttjande = :NEW.ST_AVG_UTL_Utnyttjande
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_AVG := kv.UTL_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_AVG IS NOT NULL AND (
            (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
                OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
                OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL)) OR
            :OLD.ST_AVG_UTL_ID IS NULL OR
            :OLD.ST_AVG_UTL_ID <> v_AVG
        ) THEN
            attributes.ip_ST_AVG_Scen_Medel(
                p_owner => COALESCE(:NEW.ST_AVG_ST_ID, :NEW.ST_ID),
                p_changing => CASE
                    WHEN (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
                        OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
                        OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL))
                    THEN :NEW.ST_AVG_ChangedAt
                    ELSE v_now
                END,
                p_value => v_AVG,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_ST <> :OLD.Metadata_ST
                            OR (:NEW.Metadata_ST IS NULL AND :OLD.Metadata_ST IS NOT NULL)
                            OR (:NEW.Metadata_ST IS NOT NULL AND :OLD.Metadata_ST IS NULL))
                        AND (:NEW.Metadata_ST_AVG = :OLD.Metadata_ST_AVG
                            OR (:NEW.Metadata_ST_AVG IS NULL AND :OLD.Metadata_ST_AVG IS NULL))
                        THEN :NEW.Metadata_ST
                        ELSE :NEW.Metadata_ST_AVG
                    END, :NEW.Metadata_ST)
            );
        END IF;
    END IF;
    IF (:NEW.ST_MIN_ST_ID <> :OLD.ST_MIN_ST_ID
        OR (:NEW.ST_MIN_ST_ID IS NULL AND :OLD.ST_MIN_ST_ID IS NOT NULL)
        OR (:NEW.ST_MIN_ST_ID IS NOT NULL AND :OLD.ST_MIN_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_MIN_ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_MIN_UTL_ID <> :OLD.ST_MIN_UTL_ID
        OR (:NEW.ST_MIN_UTL_ID IS NULL AND :OLD.ST_MIN_UTL_ID IS NOT NULL)
        OR (:NEW.ST_MIN_UTL_ID IS NOT NULL AND :OLD.ST_MIN_UTL_ID IS NULL))
    OR (:NEW.ST_MIN_UTL_Utnyttjande <> :OLD.ST_MIN_UTL_Utnyttjande
        OR (:NEW.ST_MIN_UTL_Utnyttjande IS NULL AND :OLD.ST_MIN_UTL_Utnyttjande IS NOT NULL)
        OR (:NEW.ST_MIN_UTL_Utnyttjande IS NOT NULL AND :OLD.ST_MIN_UTL_Utnyttjande IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_MIN := :NEW.ST_MIN_UTL_ID;
        IF (v_MIN = :OLD.ST_MIN_UTL_ID OR (v_MIN IS NULL AND :OLD.ST_MIN_UTL_ID IS NULL))
        AND :NEW.ST_MIN_UTL_Utnyttjande IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    knots.UTL_Utnyttjande k
                WHERE
                    k.UTL_Utnyttjande = :NEW.ST_MIN_UTL_Utnyttjande
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_MIN := kv.UTL_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_MIN IS NOT NULL AND (
            :OLD.ST_MIN_UTL_ID IS NULL OR
            :OLD.ST_MIN_UTL_ID <> v_MIN
        ) THEN
            attributes.ip_ST_MIN_Scen_Minimum(
                p_owner => COALESCE(:NEW.ST_MIN_ST_ID, :NEW.ST_ID),
                p_value => v_MIN,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_ST <> :OLD.Metadata_ST
                            OR (:NEW.Metadata_ST IS NULL AND :OLD.Metadata_ST IS NOT NULL)
                            OR (:NEW.Metadata_ST IS NOT NULL AND :OLD.Metadata_ST IS NULL))
                        AND (:NEW.Metadata_ST_MIN = :OLD.Metadata_ST_MIN
                            OR (:NEW.Metadata_ST_MIN IS NULL AND :OLD.Metadata_ST_MIN IS NULL))
                        THEN :NEW.Metadata_ST
                        ELSE :NEW.Metadata_ST_MIN
                    END, :NEW.Metadata_ST)
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF :NEW.Deletable_ST_MIN = 1
    AND :OLD.ST_MIN_UTL_ID IS NOT NULL
    AND (:NEW.ST_MIN_UTL_ID IS NULL OR :NEW.ST_MIN_UTL_Utnyttjande IS NULL)
    THEN
        INSERT INTO attributes.ST_MIN_Scen_Minimum_Deleted (
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID,
            Metadata_ST_MIN,
            ST_MIN_Deleted
        )
        SELECT
            x.ST_MIN_ST_ID,
            x.ST_MIN_UTL_ID,
            x.Metadata_ST_MIN,
            v_now
        FROM
            attributes.ST_MIN_Scen_Minimum x
        WHERE
            x.ST_MIN_ST_ID = :OLD.ST_ID;
        DELETE FROM
            attributes.ST_MIN_Scen_Minimum
        WHERE
            ST_MIN_ST_ID = :OLD.ST_ID;
    END IF;
END ut_lST_Scen;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Scen instead of DELETE trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.dt_lST_Scen
INSTEAD OF DELETE ON anchors.lST_Scen
FOR EACH ROW
BEGIN
    DELETE FROM
        attributes.ST_NAM_Scen_Namn x
    WHERE
        x.ST_NAM_ST_ID = :OLD.ST_ID
    AND
        x.ST_NAM_ChangedAt = :OLD.ST_NAM_ChangedAt
    ;
    DELETE FROM
        attributes.ST_LOC_Scen_Plats x
    WHERE
        x.ST_LOC_ST_ID = :OLD.ST_ID
    ;
    DELETE FROM
        attributes.ST_AVG_Scen_Medel x
    WHERE
        x.ST_AVG_ST_ID = :OLD.ST_ID
    AND
        x.ST_AVG_ChangedAt = :OLD.ST_AVG_ChangedAt
    ;
    DELETE FROM
        attributes.ST_MIN_Scen_Minimum x
    WHERE
        x.ST_MIN_ST_ID = :OLD.ST_ID
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        anchors.ST_Scen a
    WHERE
        a.ST_ID = :OLD.ST_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.ST_NAM_Scen_Namn x
        WHERE
            x.ST_NAM_ST_ID = a.ST_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.ST_LOC_Scen_Plats x
        WHERE
            x.ST_LOC_ST_ID = a.ST_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.ST_AVG_Scen_Medel x
        WHERE
            x.ST_AVG_ST_ID = a.ST_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.ST_MIN_Scen_Minimum x
        WHERE
            x.ST_MIN_ST_ID = a.ST_ID
    )
    ;
END dt_lST_Scen;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Skådespelare instead of INSERT trigger on lAC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.it_lAC_Skådespelare
INSTEAD OF INSERT ON anchors.lAC_Skådespelare
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(5);
    v_GEN number(3);
    v_PLV number(3);
BEGIN
    v_id := :NEW.AC_ID;
    IF v_id IS NULL THEN
        INSERT INTO anchors.AC_Skådespelare (
            Metadata_AC
        )
        VALUES (
            :NEW.Metadata_AC
        )
        RETURNING AC_ID INTO v_id;
    END IF;
    IF :NEW.AC_NAM_Skådespelare_Namn IS NOT NULL THEN
        attributes.ip_AC_NAM_Skådespelare_Namn(
            p_owner => COALESCE(:NEW.AC_NAM_AC_ID, v_id),
            p_changing => COALESCE(:NEW.AC_NAM_ChangedAt, v_now),
            p_value => :NEW.AC_NAM_Skådespelare_Namn,
            p_metadata => COALESCE(:NEW.Metadata_AC_NAM, :NEW.Metadata_AC)
        );
    END IF;
    v_GEN := :NEW.AC_GEN_GEN_ID;
    IF v_GEN IS NULL AND :NEW.AC_GEN_GEN_Kön IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GEN_ID
            FROM
                knots.GEN_Kön k
            WHERE
                k.GEN_Checksum = STANDARD_HASH(:NEW.AC_GEN_GEN_Kön, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_GEN := kv.GEN_ID;
        END LOOP;
    END IF;
    IF v_GEN IS NOT NULL THEN
        attributes.ip_AC_GEN_Skådespelare_Kön(
            p_owner => COALESCE(:NEW.AC_GEN_AC_ID, v_id),
            p_value => v_GEN,
            p_metadata => COALESCE(:NEW.Metadata_AC_GEN, :NEW.Metadata_AC)
        );
    END IF;
    v_PLV := :NEW.AC_PLV_PLV_ID;
    IF v_PLV IS NULL AND :NEW.AC_PLV_PLV_Yrkesnivå IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PLV_ID
            FROM
                knots.PLV_Yrkesnivå k
            WHERE
                k.PLV_Checksum = STANDARD_HASH(:NEW.AC_PLV_PLV_Yrkesnivå, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_PLV := kv.PLV_ID;
        END LOOP;
    END IF;
    IF v_PLV IS NOT NULL THEN
        attributes.ip_AC_PLV_Skådespelare_Yrkesnivå(
            p_owner => COALESCE(:NEW.AC_PLV_AC_ID, v_id),
            p_changing => COALESCE(:NEW.AC_PLV_ChangedAt, v_now),
            p_value => v_PLV,
            p_metadata => COALESCE(:NEW.Metadata_AC_PLV, :NEW.Metadata_AC)
        );
    END IF;
END it_lAC_Skådespelare;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_Skådespelare instead of UPDATE trigger on lAC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.ut_lAC_Skådespelare
INSTEAD OF UPDATE ON anchors.lAC_Skådespelare
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_GEN number(3);
    v_PLV number(3);
BEGIN
    IF (:NEW.AC_ID <> :OLD.AC_ID
        OR (:NEW.AC_ID IS NULL AND :OLD.AC_ID IS NOT NULL)
        OR (:NEW.AC_ID IS NOT NULL AND :OLD.AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_ID is not updatable.');
    END IF;
    IF (:NEW.AC_NAM_AC_ID <> :OLD.AC_NAM_AC_ID
        OR (:NEW.AC_NAM_AC_ID IS NULL AND :OLD.AC_NAM_AC_ID IS NOT NULL)
        OR (:NEW.AC_NAM_AC_ID IS NOT NULL AND :OLD.AC_NAM_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_NAM_AC_ID is not updatable.');
    END IF;
    IF (:NEW.AC_NAM_Skådespelare_Namn <> :OLD.AC_NAM_Skådespelare_Namn
        OR (:NEW.AC_NAM_Skådespelare_Namn IS NULL AND :OLD.AC_NAM_Skådespelare_Namn IS NOT NULL)
        OR (:NEW.AC_NAM_Skådespelare_Namn IS NOT NULL AND :OLD.AC_NAM_Skådespelare_Namn IS NULL))
    OR (:NEW.AC_NAM_ChangedAt <> :OLD.AC_NAM_ChangedAt
        OR (:NEW.AC_NAM_ChangedAt IS NULL AND :OLD.AC_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.AC_NAM_ChangedAt IS NOT NULL AND :OLD.AC_NAM_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.AC_NAM_Skådespelare_Namn IS NOT NULL THEN
            attributes.ip_AC_NAM_Skådespelare_Namn(
                p_owner => COALESCE(:NEW.AC_NAM_AC_ID, :NEW.AC_ID),
                p_changing => CASE
                    WHEN (:NEW.AC_NAM_ChangedAt <> :OLD.AC_NAM_ChangedAt
                        OR (:NEW.AC_NAM_ChangedAt IS NULL AND :OLD.AC_NAM_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_NAM_ChangedAt IS NOT NULL AND :OLD.AC_NAM_ChangedAt IS NULL))
                    THEN :NEW.AC_NAM_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.AC_NAM_Skådespelare_Namn,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_AC <> :OLD.Metadata_AC
                            OR (:NEW.Metadata_AC IS NULL AND :OLD.Metadata_AC IS NOT NULL)
                            OR (:NEW.Metadata_AC IS NOT NULL AND :OLD.Metadata_AC IS NULL))
                        AND (:NEW.Metadata_AC_NAM = :OLD.Metadata_AC_NAM
                            OR (:NEW.Metadata_AC_NAM IS NULL AND :OLD.Metadata_AC_NAM IS NULL))
                        THEN :NEW.Metadata_AC
                        ELSE :NEW.Metadata_AC_NAM
                    END, :NEW.Metadata_AC)
            );
        END IF;
    END IF;
    IF (:NEW.AC_GEN_AC_ID <> :OLD.AC_GEN_AC_ID
        OR (:NEW.AC_GEN_AC_ID IS NULL AND :OLD.AC_GEN_AC_ID IS NOT NULL)
        OR (:NEW.AC_GEN_AC_ID IS NOT NULL AND :OLD.AC_GEN_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_GEN_AC_ID is not updatable.');
    END IF;
    IF (:NEW.AC_GEN_GEN_ID <> :OLD.AC_GEN_GEN_ID
        OR (:NEW.AC_GEN_GEN_ID IS NULL AND :OLD.AC_GEN_GEN_ID IS NOT NULL)
        OR (:NEW.AC_GEN_GEN_ID IS NOT NULL AND :OLD.AC_GEN_GEN_ID IS NULL))
    OR (:NEW.AC_GEN_GEN_Kön <> :OLD.AC_GEN_GEN_Kön
        OR (:NEW.AC_GEN_GEN_Kön IS NULL AND :OLD.AC_GEN_GEN_Kön IS NOT NULL)
        OR (:NEW.AC_GEN_GEN_Kön IS NOT NULL AND :OLD.AC_GEN_GEN_Kön IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_GEN := :NEW.AC_GEN_GEN_ID;
        IF (v_GEN = :OLD.AC_GEN_GEN_ID OR (v_GEN IS NULL AND :OLD.AC_GEN_GEN_ID IS NULL))
        AND :NEW.AC_GEN_GEN_Kön IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.GEN_ID
                FROM
                    knots.GEN_Kön k
                WHERE
                    k.GEN_Checksum = STANDARD_HASH(:NEW.AC_GEN_GEN_Kön, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_GEN := kv.GEN_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_GEN IS NOT NULL AND (
            :OLD.AC_GEN_GEN_ID IS NULL OR
            :OLD.AC_GEN_GEN_ID <> v_GEN
        ) THEN
            attributes.ip_AC_GEN_Skådespelare_Kön(
                p_owner => COALESCE(:NEW.AC_GEN_AC_ID, :NEW.AC_ID),
                p_value => v_GEN,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_AC <> :OLD.Metadata_AC
                            OR (:NEW.Metadata_AC IS NULL AND :OLD.Metadata_AC IS NOT NULL)
                            OR (:NEW.Metadata_AC IS NOT NULL AND :OLD.Metadata_AC IS NULL))
                        AND (:NEW.Metadata_AC_GEN = :OLD.Metadata_AC_GEN
                            OR (:NEW.Metadata_AC_GEN IS NULL AND :OLD.Metadata_AC_GEN IS NULL))
                        THEN :NEW.Metadata_AC
                        ELSE :NEW.Metadata_AC_GEN
                    END, :NEW.Metadata_AC)
            );
        END IF;
    END IF;
    IF (:NEW.AC_PLV_AC_ID <> :OLD.AC_PLV_AC_ID
        OR (:NEW.AC_PLV_AC_ID IS NULL AND :OLD.AC_PLV_AC_ID IS NOT NULL)
        OR (:NEW.AC_PLV_AC_ID IS NOT NULL AND :OLD.AC_PLV_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_PLV_AC_ID is not updatable.');
    END IF;
    IF (:NEW.AC_PLV_PLV_ID <> :OLD.AC_PLV_PLV_ID
        OR (:NEW.AC_PLV_PLV_ID IS NULL AND :OLD.AC_PLV_PLV_ID IS NOT NULL)
        OR (:NEW.AC_PLV_PLV_ID IS NOT NULL AND :OLD.AC_PLV_PLV_ID IS NULL))
    OR (:NEW.AC_PLV_PLV_Yrkesnivå <> :OLD.AC_PLV_PLV_Yrkesnivå
        OR (:NEW.AC_PLV_PLV_Yrkesnivå IS NULL AND :OLD.AC_PLV_PLV_Yrkesnivå IS NOT NULL)
        OR (:NEW.AC_PLV_PLV_Yrkesnivå IS NOT NULL AND :OLD.AC_PLV_PLV_Yrkesnivå IS NULL))
    OR (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
        OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
        OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_PLV := :NEW.AC_PLV_PLV_ID;
        IF (v_PLV = :OLD.AC_PLV_PLV_ID OR (v_PLV IS NULL AND :OLD.AC_PLV_PLV_ID IS NULL))
        AND :NEW.AC_PLV_PLV_Yrkesnivå IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.PLV_ID
                FROM
                    knots.PLV_Yrkesnivå k
                WHERE
                    k.PLV_Checksum = STANDARD_HASH(:NEW.AC_PLV_PLV_Yrkesnivå, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_PLV := kv.PLV_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_PLV IS NOT NULL AND (
            (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
                OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
                OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL)) OR
            :OLD.AC_PLV_PLV_ID IS NULL OR
            :OLD.AC_PLV_PLV_ID <> v_PLV
        ) THEN
            attributes.ip_AC_PLV_Skådespelare_Yrkesnivå(
                p_owner => COALESCE(:NEW.AC_PLV_AC_ID, :NEW.AC_ID),
                p_changing => CASE
                    WHEN (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
                        OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL))
                    THEN :NEW.AC_PLV_ChangedAt
                    ELSE v_now
                END,
                p_value => v_PLV,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_AC <> :OLD.Metadata_AC
                            OR (:NEW.Metadata_AC IS NULL AND :OLD.Metadata_AC IS NOT NULL)
                            OR (:NEW.Metadata_AC IS NOT NULL AND :OLD.Metadata_AC IS NULL))
                        AND (:NEW.Metadata_AC_PLV = :OLD.Metadata_AC_PLV
                            OR (:NEW.Metadata_AC_PLV IS NULL AND :OLD.Metadata_AC_PLV IS NULL))
                        THEN :NEW.Metadata_AC
                        ELSE :NEW.Metadata_AC_PLV
                    END, :NEW.Metadata_AC)
            );
        END IF;
    END IF;
END ut_lAC_Skådespelare;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_Skådespelare instead of DELETE trigger on lAC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.dt_lAC_Skådespelare
INSTEAD OF DELETE ON anchors.lAC_Skådespelare
FOR EACH ROW
BEGIN
    DELETE FROM
        attributes.AC_NAM_Skådespelare_Namn x
    WHERE
        x.AC_NAM_AC_ID = :OLD.AC_ID
    AND
        x.AC_NAM_ChangedAt = :OLD.AC_NAM_ChangedAt
    ;
    DELETE FROM
        attributes.AC_GEN_Skådespelare_Kön x
    WHERE
        x.AC_GEN_AC_ID = :OLD.AC_ID
    ;
    DELETE FROM
        attributes.AC_PLV_Skådespelare_Yrkesnivå x
    WHERE
        x.AC_PLV_AC_ID = :OLD.AC_ID
    AND
        x.AC_PLV_ChangedAt = :OLD.AC_PLV_ChangedAt
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        anchors.AC_Skådespelare a
    WHERE
        a.AC_ID = :OLD.AC_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.AC_NAM_Skådespelare_Namn x
        WHERE
            x.AC_NAM_AC_ID = a.AC_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.AC_GEN_Skådespelare_Kön x
        WHERE
            x.AC_GEN_AC_ID = a.AC_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå x
        WHERE
            x.AC_PLV_AC_ID = a.AC_ID
    )
    ;
END dt_lAC_Skådespelare;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Föreställning instead of INSERT trigger on lPR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.it_lPR_Föreställning
INSTEAD OF INSERT ON anchors.lPR_Föreställning
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(19);
BEGIN
    v_id := :NEW.PR_ID;
    IF v_id IS NULL THEN
        INSERT INTO anchors.PR_Föreställning (
            Metadata_PR
        )
        VALUES (
            :NEW.Metadata_PR
        )
        RETURNING PR_ID INTO v_id;
    END IF;
    IF :NEW.PR_NAM_Föreställning_Namn IS NOT NULL THEN
        attributes.ip_PR_NAM_Föreställning_Namn(
            p_owner => COALESCE(:NEW.PR_NAM_PR_ID, v_id),
            p_value => :NEW.PR_NAM_Föreställning_Namn,
            p_metadata => COALESCE(:NEW.Metadata_PR_NAM, :NEW.Metadata_PR)
        );
    END IF;
    IF :NEW.PR_LEN_Föreställning_Längd IS NOT NULL THEN
        attributes.ip_PR_LEN_Föreställning_Längd(
            p_owner => COALESCE(:NEW.PR_LEN_PR_ID, v_id),
            p_changing => COALESCE(:NEW.PR_LEN_ChangedAt, v_now),
            p_value => :NEW.PR_LEN_Föreställning_Längd,
            p_metadata => COALESCE(:NEW.Metadata_PR_LEN, :NEW.Metadata_PR)
        );
    END IF;
END it_lPR_Föreställning;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_Föreställning instead of UPDATE trigger on lPR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.ut_lPR_Föreställning
INSTEAD OF UPDATE ON anchors.lPR_Föreställning
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    IF (:NEW.PR_ID <> :OLD.PR_ID
        OR (:NEW.PR_ID IS NULL AND :OLD.PR_ID IS NOT NULL)
        OR (:NEW.PR_ID IS NOT NULL AND :OLD.PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_ID is not updatable.');
    END IF;
    IF (:NEW.PR_NAM_PR_ID <> :OLD.PR_NAM_PR_ID
        OR (:NEW.PR_NAM_PR_ID IS NULL AND :OLD.PR_NAM_PR_ID IS NOT NULL)
        OR (:NEW.PR_NAM_PR_ID IS NOT NULL AND :OLD.PR_NAM_PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column PR_NAM_PR_ID is not updatable.');
    END IF;
    IF (:NEW.PR_NAM_Föreställning_Namn <> :OLD.PR_NAM_Föreställning_Namn
        OR (:NEW.PR_NAM_Föreställning_Namn IS NULL AND :OLD.PR_NAM_Föreställning_Namn IS NOT NULL)
        OR (:NEW.PR_NAM_Föreställning_Namn IS NOT NULL AND :OLD.PR_NAM_Föreställning_Namn IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.PR_NAM_Föreställning_Namn IS NOT NULL THEN
            attributes.ip_PR_NAM_Föreställning_Namn(
                p_owner => COALESCE(:NEW.PR_NAM_PR_ID, :NEW.PR_ID),
                p_value => :NEW.PR_NAM_Föreställning_Namn,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_PR <> :OLD.Metadata_PR
                            OR (:NEW.Metadata_PR IS NULL AND :OLD.Metadata_PR IS NOT NULL)
                            OR (:NEW.Metadata_PR IS NOT NULL AND :OLD.Metadata_PR IS NULL))
                        AND (:NEW.Metadata_PR_NAM = :OLD.Metadata_PR_NAM
                            OR (:NEW.Metadata_PR_NAM IS NULL AND :OLD.Metadata_PR_NAM IS NULL))
                        THEN :NEW.Metadata_PR
                        ELSE :NEW.Metadata_PR_NAM
                    END, :NEW.Metadata_PR)
            );
        END IF;
    END IF;
    IF (:NEW.PR_LEN_PR_ID <> :OLD.PR_LEN_PR_ID
        OR (:NEW.PR_LEN_PR_ID IS NULL AND :OLD.PR_LEN_PR_ID IS NOT NULL)
        OR (:NEW.PR_LEN_PR_ID IS NOT NULL AND :OLD.PR_LEN_PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column PR_LEN_PR_ID is not updatable.');
    END IF;
    IF (:NEW.PR_LEN_Föreställning_Längd <> :OLD.PR_LEN_Föreställning_Längd
        OR (:NEW.PR_LEN_Föreställning_Längd IS NULL AND :OLD.PR_LEN_Föreställning_Längd IS NOT NULL)
        OR (:NEW.PR_LEN_Föreställning_Längd IS NOT NULL AND :OLD.PR_LEN_Föreställning_Längd IS NULL))
    OR (:NEW.PR_LEN_ChangedAt <> :OLD.PR_LEN_ChangedAt
        OR (:NEW.PR_LEN_ChangedAt IS NULL AND :OLD.PR_LEN_ChangedAt IS NOT NULL)
        OR (:NEW.PR_LEN_ChangedAt IS NOT NULL AND :OLD.PR_LEN_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.PR_LEN_Föreställning_Längd IS NOT NULL THEN
            attributes.ip_PR_LEN_Föreställning_Längd(
                p_owner => COALESCE(:NEW.PR_LEN_PR_ID, :NEW.PR_ID),
                p_changing => CASE
                    WHEN (:NEW.PR_LEN_ChangedAt <> :OLD.PR_LEN_ChangedAt
                        OR (:NEW.PR_LEN_ChangedAt IS NULL AND :OLD.PR_LEN_ChangedAt IS NOT NULL)
                        OR (:NEW.PR_LEN_ChangedAt IS NOT NULL AND :OLD.PR_LEN_ChangedAt IS NULL))
                    THEN :NEW.PR_LEN_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.PR_LEN_Föreställning_Längd,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_PR <> :OLD.Metadata_PR
                            OR (:NEW.Metadata_PR IS NULL AND :OLD.Metadata_PR IS NOT NULL)
                            OR (:NEW.Metadata_PR IS NOT NULL AND :OLD.Metadata_PR IS NULL))
                        AND (:NEW.Metadata_PR_LEN = :OLD.Metadata_PR_LEN
                            OR (:NEW.Metadata_PR_LEN IS NULL AND :OLD.Metadata_PR_LEN IS NULL))
                        THEN :NEW.Metadata_PR
                        ELSE :NEW.Metadata_PR_LEN
                    END, :NEW.Metadata_PR)
            );
        END IF;
    END IF;
END ut_lPR_Föreställning;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_Föreställning instead of DELETE trigger on lPR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.dt_lPR_Föreställning
INSTEAD OF DELETE ON anchors.lPR_Föreställning
FOR EACH ROW
BEGIN
    DELETE FROM
        attributes.PR_NAM_Föreställning_Namn x
    WHERE
        x.PR_NAM_PR_ID = :OLD.PR_ID
    ;
    DELETE FROM
        attributes.PR_LEN_Föreställning_Längd x
    WHERE
        x.PR_LEN_PR_ID = :OLD.PR_ID
    AND
        x.PR_LEN_ChangedAt = :OLD.PR_LEN_ChangedAt
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        anchors.PR_Föreställning a
    WHERE
        a.PR_ID = :OLD.PR_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.PR_NAM_Föreställning_Namn x
        WHERE
            x.PR_NAM_PR_ID = a.PR_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.PR_LEN_Föreställning_Längd x
        WHERE
            x.PR_LEN_PR_ID = a.PR_ID
    )
    ;
END dt_lPR_Föreställning;
/
