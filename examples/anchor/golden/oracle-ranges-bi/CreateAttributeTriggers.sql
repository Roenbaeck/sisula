-- ATTRIBUTE TRIGGERS -------------------------------------------------------------------------------------------------
--
-- The following procedures state one posit of an attribute and its assertion, in the way that the model says, and the
-- triggers on the assembled views make the views behave like tables, by calling them. There is one 'instead of' trigger
-- for: insert. The procedures are procedures and not triggers on the posit and annex tables, since Oracle does not let a
-- row trigger read the table it is on (ORA-04091), which these rules do. The INSTEAD OF triggers on the latest views of the
-- anchors, and those of the nexuses, call them too, and so can a load:
--
--     BEGIN ip_AC_NAM_Actor_Name(p_owner => 1, p_value => 'Ann', p_changing => SYSTIMESTAMP, p_reliability => 1, p_metadata => 1); END;
--
-- ip_<attribute.name> (one for every attribute of an anchor or a nexus, named as the attribute is in the model, written in
-- front of its schema if it has one). Its parameters are named, and all except the owner and the value may be left out (or
-- be null), when the default of the one left out is used:
--
--     p_owner        the entity that has the attribute, a column of the posit table: the entity reference of the attribute
--     p_value        the value that is posited, as it is in the posit table: for a knotted attribute the identity of the value in the
--                    knot, for an attribute with a checksum the value (the checksum is made by the table)
--     p_changing     only for a historized attribute: from when the value is valid. Default: now (current_timestamp)
--     p_positing     when the posit is asserted. Default: now
--     p_reliability  how reliable the assertion is: 1 asserts the posit and 0 retracts it. Default: 1
--     p_metadata     only when the model has metadata: the metadata of the annex row. Default: 0
--
-- The rules are the ones in Anchor's docs/ANCHOR.md, "Loading through the latest views". Bitemporal modeling is decisive:
-- one posit at a time is asserted for an entity (and a changing time). An assertion of another value therefore retracts, at
-- its own positing time, the posit that is in effect, which is a correction; a posit is in effect at a positing time when its
-- latest annex row up to then asserts it. The positing time is now (the clock, which moves between two statements) unless it is
-- given. A posit that is not there is created. A retraction of what is not asserted states nothing. An error is raised
-- (RAISE_APPLICATION_ERROR) for a contradiction (-20001: another reliability of the same posit at the same positing time, or
-- another value for the same entity and changing time at that positing time) and for a restatement (-20002: the value is the
-- same as that of the version before or after it, where the attribute may not be restated). A call that raises an error is
-- undone, as is the statement that made it.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates, although what they correct is retracted.
--
-- Two functions help the procedures and may be used in a query as well:
--
--     eq_<attribute.name>(p_left, p_right)      1 if two values of the attribute are the same, else 0
--     he_<attribute.name>(p_id, p_positing)     the reliability of the posit with the identity at the positing time (that of its
--                                               latest annex row up to then), null if it has none
--
-- Oracle runs a trigger of this kind for each row.
--
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_DAT_Event_Date tells whether two values of EV_DAT_Event_Date are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_DAT_Event_Date (
    p_left IN attributes.EV_DAT_Event_Date_Fact.EV_DAT_Event_Date%TYPE,
    p_right IN attributes.EV_DAT_Event_Date_Fact.EV_DAT_Event_Date%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_DAT_Event_Date;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_DAT_Event_Date is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_DAT_Event_Date (
    p_id IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_ID%TYPE,
    p_positing IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_PositedAt%TYPE
) RETURN attributes.EV_DAT_Event_Date_Meta.EV_DAT_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_DAT_Confidence
        FROM
            attributes.EV_DAT_Event_Date_Meta a
        WHERE
            a.EV_DAT_ID = p_id
        AND
            a.EV_DAT_PositedAt <= p_positing
        ORDER BY
            a.EV_DAT_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_DAT_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_DAT_Event_Date;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_DAT_Event_Date states a value of EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_DAT_Event_Date (
    p_owner IN attributes.EV_DAT_Event_Date_Fact.EV_DAT_EV_ID%TYPE,
    p_value IN attributes.EV_DAT_Event_Date_Fact.EV_DAT_Event_Date%TYPE,
    p_positing IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_DAT_Event_Date_Meta.Metadata_EV_DAT%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_posit attributes.EV_DAT_Event_Date_Fact.EV_DAT_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_DAT_Event_Date_Fact.EV_DAT_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_DAT_Event_Date_Meta (
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_PositedAt,
            EV_DAT_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_DAT_Event_Date_Meta x
                WHERE
                    x.EV_DAT_ID = p_id
                AND
                    x.EV_DAT_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_DAT_ID
        FROM
            attributes.EV_DAT_Event_Date_Fact p
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            attributes.eq_EV_DAT_Event_Date(p.EV_DAT_Event_Date, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_DAT_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_DAT_Event_Date_Meta a
        WHERE
            a.EV_DAT_ID = v_posit
        AND
            a.EV_DAT_PositedAt = v_positing
        AND
            a.EV_DAT_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Event_Date for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_DAT_Event_Date_Fact p
        JOIN
            attributes.EV_DAT_Event_Date_Meta a
        ON
            a.EV_DAT_ID = p.EV_DAT_ID
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            attributes.eq_EV_DAT_Event_Date(p.EV_DAT_Event_Date, p_value) = 0
        AND
            a.EV_DAT_PositedAt = v_positing
        AND
            a.EV_DAT_Confidence = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Event_Date for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_DAT_Event_Date_Meta a
        WHERE
            a.EV_DAT_ID = v_posit
        AND
            a.EV_DAT_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(attributes.he_EV_DAT_Event_Date(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_DAT_Event_Date_Meta (
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_PositedAt,
            EV_DAT_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.EV_DAT_ID
        FROM
            attributes.EV_DAT_Event_Date_Fact p
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            attributes.eq_EV_DAT_Event_Date(p.EV_DAT_Event_Date, p_value) = 0
        AND
            COALESCE(attributes.he_EV_DAT_Event_Date(p.EV_DAT_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.EV_DAT_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_DAT_Event_Date_Fact (
            EV_DAT_EV_ID,
            EV_DAT_Event_Date
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_DAT_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_DAT_Event_Date_Meta (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_PositedAt,
        EV_DAT_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_EV_DAT_Event_Date;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_DAT_Event_Date instead of INSERT trigger on EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER attributes.it_EV_DAT_Event_Date
INSTEAD OF INSERT ON attributes.EV_DAT_Event_Date
FOR EACH ROW
BEGIN
    attributes.ip_EV_DAT_Event_Date(
        p_owner => :NEW.EV_DAT_EV_ID,
        p_value => :NEW.EV_DAT_Event_Date,
        p_positing => :NEW.EV_DAT_PositedAt,
        p_reliability => :NEW.EV_DAT_Confidence,
        p_metadata => :NEW.Metadata_EV_DAT
    );
END it_EV_DAT_Event_Date;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_AUD_Event_Audience tells whether two values of EV_AUD_Event_Audience are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_AUD_Event_Audience (
    p_left IN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_Event_Audience%TYPE,
    p_right IN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_Event_Audience%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_AUD_Event_Audience;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_AUD_Event_Audience is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_AUD_Event_Audience (
    p_id IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_ID%TYPE,
    p_positing IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_PositedAt%TYPE
) RETURN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_AUD_Confidence
        FROM
            attributes.EV_AUD_Event_Audience_Meta a
        WHERE
            a.EV_AUD_ID = p_id
        AND
            a.EV_AUD_PositedAt <= p_positing
        ORDER BY
            a.EV_AUD_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_AUD_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_AUD_Event_Audience;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_AUD_Event_Audience states a value of EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_AUD_Event_Audience (
    p_owner IN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_EV_ID%TYPE,
    p_value IN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_Event_Audience%TYPE,
    p_positing IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_AUD_Event_Audience_Meta.Metadata_EV_AUD%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_posit attributes.EV_AUD_Event_Audience_Fact.EV_AUD_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_AUD_Event_Audience_Meta (
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_PositedAt,
            EV_AUD_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_AUD_Event_Audience_Meta x
                WHERE
                    x.EV_AUD_ID = p_id
                AND
                    x.EV_AUD_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_AUD_ID
        FROM
            attributes.EV_AUD_Event_Audience_Fact p
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            attributes.eq_EV_AUD_Event_Audience(p.EV_AUD_Event_Audience, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_AUD_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_AUD_Event_Audience_Meta a
        WHERE
            a.EV_AUD_ID = v_posit
        AND
            a.EV_AUD_PositedAt = v_positing
        AND
            a.EV_AUD_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Event_Audience for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_AUD_Event_Audience_Fact p
        JOIN
            attributes.EV_AUD_Event_Audience_Meta a
        ON
            a.EV_AUD_ID = p.EV_AUD_ID
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            attributes.eq_EV_AUD_Event_Audience(p.EV_AUD_Event_Audience, p_value) = 0
        AND
            a.EV_AUD_PositedAt = v_positing
        AND
            a.EV_AUD_Confidence = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Event_Audience for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_AUD_Event_Audience_Meta a
        WHERE
            a.EV_AUD_ID = v_posit
        AND
            a.EV_AUD_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(attributes.he_EV_AUD_Event_Audience(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_AUD_Event_Audience_Meta (
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_PositedAt,
            EV_AUD_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.EV_AUD_ID
        FROM
            attributes.EV_AUD_Event_Audience_Fact p
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            attributes.eq_EV_AUD_Event_Audience(p.EV_AUD_Event_Audience, p_value) = 0
        AND
            COALESCE(attributes.he_EV_AUD_Event_Audience(p.EV_AUD_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.EV_AUD_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_AUD_Event_Audience_Fact (
            EV_AUD_EV_ID,
            EV_AUD_Event_Audience
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_AUD_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_AUD_Event_Audience_Meta (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_PositedAt,
        EV_AUD_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_EV_AUD_Event_Audience;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_AUD_Event_Audience instead of INSERT trigger on EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER attributes.it_EV_AUD_Event_Audience
INSTEAD OF INSERT ON attributes.EV_AUD_Event_Audience
FOR EACH ROW
BEGIN
    attributes.ip_EV_AUD_Event_Audience(
        p_owner => :NEW.EV_AUD_EV_ID,
        p_value => :NEW.EV_AUD_Event_Audience,
        p_positing => :NEW.EV_AUD_PositedAt,
        p_reliability => :NEW.EV_AUD_Confidence,
        p_metadata => :NEW.Metadata_EV_AUD
    );
END it_EV_AUD_Event_Audience;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_REV_Event_Revenue tells whether two values of EV_REV_Event_Revenue are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_REV_Event_Revenue (
    p_left IN attributes.EV_REV_Event_Revenue_Fact.EV_REV_Event_Revenue%TYPE,
    p_right IN attributes.EV_REV_Event_Revenue_Fact.EV_REV_Event_Revenue%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_REV_Event_Revenue;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_REV_Event_Revenue is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_REV_Event_Revenue (
    p_id IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_ID%TYPE,
    p_positing IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_PositedAt%TYPE
) RETURN attributes.EV_REV_Event_Revenue_Meta.EV_REV_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_REV_Confidence
        FROM
            attributes.EV_REV_Event_Revenue_Meta a
        WHERE
            a.EV_REV_ID = p_id
        AND
            a.EV_REV_PositedAt <= p_positing
        ORDER BY
            a.EV_REV_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_REV_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_REV_Event_Revenue;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_REV_Event_Revenue states a value of EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_REV_Event_Revenue (
    p_owner IN attributes.EV_REV_Event_Revenue_Fact.EV_REV_EV_ID%TYPE,
    p_value IN attributes.EV_REV_Event_Revenue_Fact.EV_REV_Event_Revenue%TYPE,
    p_positing IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_REV_Event_Revenue_Meta.Metadata_EV_REV%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_posit attributes.EV_REV_Event_Revenue_Fact.EV_REV_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_REV_Event_Revenue_Fact.EV_REV_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_REV_Event_Revenue_Meta (
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_PositedAt,
            EV_REV_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_REV_Event_Revenue_Meta x
                WHERE
                    x.EV_REV_ID = p_id
                AND
                    x.EV_REV_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_REV_ID
        FROM
            attributes.EV_REV_Event_Revenue_Fact p
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            attributes.eq_EV_REV_Event_Revenue(p.EV_REV_Event_Revenue, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_REV_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_REV_Event_Revenue_Meta a
        WHERE
            a.EV_REV_ID = v_posit
        AND
            a.EV_REV_PositedAt = v_positing
        AND
            a.EV_REV_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Event_Revenue for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_REV_Event_Revenue_Fact p
        JOIN
            attributes.EV_REV_Event_Revenue_Meta a
        ON
            a.EV_REV_ID = p.EV_REV_ID
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            attributes.eq_EV_REV_Event_Revenue(p.EV_REV_Event_Revenue, p_value) = 0
        AND
            a.EV_REV_PositedAt = v_positing
        AND
            a.EV_REV_Confidence = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Event_Revenue for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_REV_Event_Revenue_Meta a
        WHERE
            a.EV_REV_ID = v_posit
        AND
            a.EV_REV_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(attributes.he_EV_REV_Event_Revenue(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_REV_Event_Revenue_Meta (
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_PositedAt,
            EV_REV_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.EV_REV_ID
        FROM
            attributes.EV_REV_Event_Revenue_Fact p
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            attributes.eq_EV_REV_Event_Revenue(p.EV_REV_Event_Revenue, p_value) = 0
        AND
            COALESCE(attributes.he_EV_REV_Event_Revenue(p.EV_REV_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.EV_REV_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_REV_Event_Revenue_Fact (
            EV_REV_EV_ID,
            EV_REV_Event_Revenue
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_REV_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_REV_Event_Revenue_Meta (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_PositedAt,
        EV_REV_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_EV_REV_Event_Revenue;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_REV_Event_Revenue instead of INSERT trigger on EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER attributes.it_EV_REV_Event_Revenue
INSTEAD OF INSERT ON attributes.EV_REV_Event_Revenue
FOR EACH ROW
BEGIN
    attributes.ip_EV_REV_Event_Revenue(
        p_owner => :NEW.EV_REV_EV_ID,
        p_value => :NEW.EV_REV_Event_Revenue,
        p_positing => :NEW.EV_REV_PositedAt,
        p_reliability => :NEW.EV_REV_Confidence,
        p_metadata => :NEW.Metadata_EV_REV
    );
END it_EV_REV_Event_Revenue;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_STA_Event_Status tells whether two values of EV_STA_Event_Status are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_STA_Event_Status (
    p_left IN attributes.EV_STA_Event_Status_Fact.EV_STA_Event_Status%TYPE,
    p_right IN attributes.EV_STA_Event_Status_Fact.EV_STA_Event_Status%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_STA_Event_Status;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_STA_Event_Status is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_STA_Event_Status (
    p_id IN attributes.EV_STA_Event_Status_Meta.EV_STA_ID%TYPE,
    p_positing IN attributes.EV_STA_Event_Status_Meta.EV_STA_PositedAt%TYPE
) RETURN attributes.EV_STA_Event_Status_Meta.EV_STA_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_STA_Confidence
        FROM
            attributes.EV_STA_Event_Status_Meta a
        WHERE
            a.EV_STA_ID = p_id
        AND
            a.EV_STA_PositedAt <= p_positing
        ORDER BY
            a.EV_STA_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_STA_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_STA_Event_Status;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_STA_Event_Status states a value of EV_STA_Event_Status
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_STA_Event_Status (
    p_owner IN attributes.EV_STA_Event_Status_Fact.EV_STA_EV_ID%TYPE,
    p_value IN attributes.EV_STA_Event_Status_Fact.EV_STA_Event_Status%TYPE,
    p_changing IN attributes.EV_STA_Event_Status_Fact.EV_STA_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_STA_Event_Status_Meta.EV_STA_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_STA_Event_Status_Meta.EV_STA_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_STA_Event_Status_Meta.Metadata_EV_STA%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_changing timestamp;
    v_posit attributes.EV_STA_Event_Status_Fact.EV_STA_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_STA_Event_Status_Fact.EV_STA_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_STA_Event_Status_Meta (
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_PositedAt,
            EV_STA_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_STA_Event_Status_Meta x
                WHERE
                    x.EV_STA_ID = p_id
                AND
                    x.EV_STA_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_STA_ID
        FROM
            attributes.EV_STA_Event_Status_Fact p
        WHERE
            p.EV_STA_EV_ID = p_owner
        AND
            p.EV_STA_ChangedAt = v_changing
        AND
            attributes.eq_EV_STA_Event_Status(p.EV_STA_Event_Status, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_STA_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_STA_Event_Status_Meta a
        WHERE
            a.EV_STA_ID = v_posit
        AND
            a.EV_STA_PositedAt = v_positing
        AND
            a.EV_STA_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_STA_Event_Status for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_STA_Event_Status_Fact p
        JOIN
            attributes.EV_STA_Event_Status_Meta a
        ON
            a.EV_STA_ID = p.EV_STA_ID
        WHERE
            p.EV_STA_EV_ID = p_owner
        AND
            p.EV_STA_ChangedAt = v_changing
        AND
            attributes.eq_EV_STA_Event_Status(p.EV_STA_Event_Status, p_value) = 0
        AND
            a.EV_STA_PositedAt = v_positing
        AND
            a.EV_STA_Confidence = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_STA_Event_Status for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_STA_Event_Status_Meta a
        WHERE
            a.EV_STA_ID = v_posit
        AND
            a.EV_STA_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(attributes.he_EV_STA_Event_Status(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_STA_Event_Status_Meta (
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_PositedAt,
            EV_STA_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.EV_STA_ID
        FROM
            attributes.EV_STA_Event_Status_Fact p
        WHERE
            p.EV_STA_EV_ID = p_owner
        AND
            p.EV_STA_ChangedAt = v_changing
        AND
            attributes.eq_EV_STA_Event_Status(p.EV_STA_Event_Status, p_value) = 0
        AND
            COALESCE(attributes.he_EV_STA_Event_Status(p.EV_STA_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.EV_STA_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_STA_Event_Status_Fact (
            EV_STA_EV_ID,
            EV_STA_ChangedAt,
            EV_STA_Event_Status
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING EV_STA_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_STA_Event_Status_Meta (
        Metadata_EV_STA,
        EV_STA_ID,
        EV_STA_PositedAt,
        EV_STA_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_EV_STA_Event_Status;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_STA_Event_Status instead of INSERT trigger on EV_STA_Event_Status
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER attributes.it_EV_STA_Event_Status
INSTEAD OF INSERT ON attributes.EV_STA_Event_Status
FOR EACH ROW
BEGIN
    attributes.ip_EV_STA_Event_Status(
        p_owner => :NEW.EV_STA_EV_ID,
        p_value => :NEW.EV_STA_Event_Status,
        p_changing => :NEW.EV_STA_ChangedAt,
        p_positing => :NEW.EV_STA_PositedAt,
        p_reliability => :NEW.EV_STA_Confidence,
        p_metadata => :NEW.Metadata_EV_STA
    );
END it_EV_STA_Event_Status;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_UTL_Event_Utilization tells whether two values of EV_UTL_Event_Utilization are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_UTL_Event_Utilization (
    p_left IN attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_UTL_ID%TYPE,
    p_right IN attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_UTL_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_UTL_Event_Utilization;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_UTL_Event_Utilization is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_UTL_Event_Utilization (
    p_id IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_ID%TYPE,
    p_positing IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_PositedAt%TYPE
) RETURN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_UTL_Confidence
        FROM
            attributes.EV_UTL_Event_Utilization_Meta a
        WHERE
            a.EV_UTL_ID = p_id
        AND
            a.EV_UTL_PositedAt <= p_positing
        ORDER BY
            a.EV_UTL_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_UTL_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_UTL_Event_Utilization;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_UTL_Event_Utilization states a value of EV_UTL_Event_Utilization
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_UTL_Event_Utilization (
    p_owner IN attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_EV_ID%TYPE,
    p_value IN attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_UTL_ID%TYPE,
    p_positing IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_UTL_Event_Utilization_Meta.Metadata_EV_UTL%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_posit attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_UTL_Event_Utilization_Meta (
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_PositedAt,
            EV_UTL_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_UTL_Event_Utilization_Meta x
                WHERE
                    x.EV_UTL_ID = p_id
                AND
                    x.EV_UTL_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_UTL_ID
        FROM
            attributes.EV_UTL_Event_Utilization_Fact p
        WHERE
            p.EV_UTL_EV_ID = p_owner
        AND
            attributes.eq_EV_UTL_Event_Utilization(p.EV_UTL_UTL_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_UTL_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_UTL_Event_Utilization_Meta a
        WHERE
            a.EV_UTL_ID = v_posit
        AND
            a.EV_UTL_PositedAt = v_positing
        AND
            a.EV_UTL_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_UTL_Event_Utilization for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_UTL_Event_Utilization_Fact p
        JOIN
            attributes.EV_UTL_Event_Utilization_Meta a
        ON
            a.EV_UTL_ID = p.EV_UTL_ID
        WHERE
            p.EV_UTL_EV_ID = p_owner
        AND
            attributes.eq_EV_UTL_Event_Utilization(p.EV_UTL_UTL_ID, p_value) = 0
        AND
            a.EV_UTL_PositedAt = v_positing
        AND
            a.EV_UTL_Confidence = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_UTL_Event_Utilization for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_UTL_Event_Utilization_Meta a
        WHERE
            a.EV_UTL_ID = v_posit
        AND
            a.EV_UTL_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(attributes.he_EV_UTL_Event_Utilization(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_UTL_Event_Utilization_Meta (
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_PositedAt,
            EV_UTL_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.EV_UTL_ID
        FROM
            attributes.EV_UTL_Event_Utilization_Fact p
        WHERE
            p.EV_UTL_EV_ID = p_owner
        AND
            attributes.eq_EV_UTL_Event_Utilization(p.EV_UTL_UTL_ID, p_value) = 0
        AND
            COALESCE(attributes.he_EV_UTL_Event_Utilization(p.EV_UTL_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.EV_UTL_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_UTL_Event_Utilization_Fact (
            EV_UTL_EV_ID,
            EV_UTL_UTL_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_UTL_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_UTL_Event_Utilization_Meta (
        Metadata_EV_UTL,
        EV_UTL_ID,
        EV_UTL_PositedAt,
        EV_UTL_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_EV_UTL_Event_Utilization;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_UTL_Event_Utilization instead of INSERT trigger on EV_UTL_Event_Utilization
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER attributes.it_EV_UTL_Event_Utilization
INSTEAD OF INSERT ON attributes.EV_UTL_Event_Utilization
FOR EACH ROW
BEGIN
    attributes.ip_EV_UTL_Event_Utilization(
        p_owner => :NEW.EV_UTL_EV_ID,
        p_value => :NEW.EV_UTL_UTL_ID,
        p_positing => :NEW.EV_UTL_PositedAt,
        p_reliability => :NEW.EV_UTL_Confidence,
        p_metadata => :NEW.Metadata_EV_UTL
    );
END it_EV_UTL_Event_Utilization;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_LVL_Event_Level tells whether two values of EV_LVL_Event_Level are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_LVL_Event_Level (
    p_left IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_PLV_ID%TYPE,
    p_right IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_PLV_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_LVL_Event_Level;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_LVL_Event_Level is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_LVL_Event_Level (
    p_id IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_ID%TYPE,
    p_positing IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_PositedAt%TYPE
) RETURN attributes.EV_LVL_Event_Level_Meta.EV_LVL_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_LVL_Confidence
        FROM
            attributes.EV_LVL_Event_Level_Meta a
        WHERE
            a.EV_LVL_ID = p_id
        AND
            a.EV_LVL_PositedAt <= p_positing
        ORDER BY
            a.EV_LVL_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_LVL_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_LVL_Event_Level;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_LVL_Event_Level states a value of EV_LVL_Event_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_LVL_Event_Level (
    p_owner IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_EV_ID%TYPE,
    p_value IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_PLV_ID%TYPE,
    p_changing IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_LVL_Event_Level_Meta.Metadata_EV_LVL%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_changing date;
    v_posit attributes.EV_LVL_Event_Level_Fact.EV_LVL_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_LVL_Event_Level_Meta (
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_PositedAt,
            EV_LVL_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_LVL_Event_Level_Meta x
                WHERE
                    x.EV_LVL_ID = p_id
                AND
                    x.EV_LVL_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_LVL_ID
        FROM
            attributes.EV_LVL_Event_Level_Fact p
        WHERE
            p.EV_LVL_EV_ID = p_owner
        AND
            p.EV_LVL_ChangedAt = v_changing
        AND
            attributes.eq_EV_LVL_Event_Level(p.EV_LVL_PLV_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_LVL_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_LVL_Event_Level_Meta a
        WHERE
            a.EV_LVL_ID = v_posit
        AND
            a.EV_LVL_PositedAt = v_positing
        AND
            a.EV_LVL_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_LVL_Event_Level for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_LVL_Event_Level_Fact p
        JOIN
            attributes.EV_LVL_Event_Level_Meta a
        ON
            a.EV_LVL_ID = p.EV_LVL_ID
        WHERE
            p.EV_LVL_EV_ID = p_owner
        AND
            p.EV_LVL_ChangedAt = v_changing
        AND
            attributes.eq_EV_LVL_Event_Level(p.EV_LVL_PLV_ID, p_value) = 0
        AND
            a.EV_LVL_PositedAt = v_positing
        AND
            a.EV_LVL_Confidence = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_LVL_Event_Level for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_LVL_Event_Level_Meta a
        WHERE
            a.EV_LVL_ID = v_posit
        AND
            a.EV_LVL_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(attributes.he_EV_LVL_Event_Level(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_LVL_Event_Level_Meta (
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_PositedAt,
            EV_LVL_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.EV_LVL_ID
        FROM
            attributes.EV_LVL_Event_Level_Fact p
        WHERE
            p.EV_LVL_EV_ID = p_owner
        AND
            p.EV_LVL_ChangedAt = v_changing
        AND
            attributes.eq_EV_LVL_Event_Level(p.EV_LVL_PLV_ID, p_value) = 0
        AND
            COALESCE(attributes.he_EV_LVL_Event_Level(p.EV_LVL_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.EV_LVL_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_LVL_Event_Level_Fact (
            EV_LVL_EV_ID,
            EV_LVL_ChangedAt,
            EV_LVL_PLV_ID
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING EV_LVL_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_LVL_Event_Level_Meta (
        Metadata_EV_LVL,
        EV_LVL_ID,
        EV_LVL_PositedAt,
        EV_LVL_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_EV_LVL_Event_Level;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_LVL_Event_Level instead of INSERT trigger on EV_LVL_Event_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER attributes.it_EV_LVL_Event_Level
INSTEAD OF INSERT ON attributes.EV_LVL_Event_Level
FOR EACH ROW
BEGIN
    attributes.ip_EV_LVL_Event_Level(
        p_owner => :NEW.EV_LVL_EV_ID,
        p_value => :NEW.EV_LVL_PLV_ID,
        p_changing => :NEW.EV_LVL_ChangedAt,
        p_positing => :NEW.EV_LVL_PositedAt,
        p_reliability => :NEW.EV_LVL_Confidence,
        p_metadata => :NEW.Metadata_EV_LVL
    );
END it_EV_LVL_Event_Level;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_NAM_Stage_Name tells whether two values of ST_NAM_Stage_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_ST_NAM_Stage_Name (
    p_left IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_Stage_Name%TYPE,
    p_right IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_Stage_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_ST_NAM_Stage_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_NAM_Stage_Name is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_ST_NAM_Stage_Name (
    p_id IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_ID%TYPE,
    p_positing IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_PositedAt%TYPE
) RETURN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_NAM_Confidence
        FROM
            attributes.ST_NAM_Stage_Name_Meta a
        WHERE
            a.ST_NAM_ID = p_id
        AND
            a.ST_NAM_PositedAt <= p_positing
        ORDER BY
            a.ST_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_NAM_Confidence;
    END LOOP;
    RETURN NULL;
END he_ST_NAM_Stage_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_NAM_Stage_Name states a value of ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_NAM_Stage_Name (
    p_owner IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_ST_ID%TYPE,
    p_value IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_Stage_Name%TYPE,
    p_changing IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_NAM_Stage_Name_Meta.Metadata_ST_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_changing timestamp;
    v_posit attributes.ST_NAM_Stage_Name_Fact.ST_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_NAM_Stage_Name_Meta (
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_NAM_Stage_Name_Meta x
                WHERE
                    x.ST_NAM_ID = p_id
                AND
                    x.ST_NAM_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_NAM_ID
        FROM
            attributes.ST_NAM_Stage_Name_Fact p
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            attributes.eq_ST_NAM_Stage_Name(p.ST_NAM_Stage_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_NAM_Stage_Name_Meta a
        WHERE
            a.ST_NAM_ID = v_posit
        AND
            a.ST_NAM_PositedAt = v_positing
        AND
            a.ST_NAM_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Stage_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_NAM_Stage_Name_Fact p
        JOIN
            attributes.ST_NAM_Stage_Name_Meta a
        ON
            a.ST_NAM_ID = p.ST_NAM_ID
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            attributes.eq_ST_NAM_Stage_Name(p.ST_NAM_Stage_Name, p_value) = 0
        AND
            a.ST_NAM_PositedAt = v_positing
        AND
            a.ST_NAM_Confidence = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Stage_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_NAM_Stage_Name_Meta a
        WHERE
            a.ST_NAM_ID = v_posit
        AND
            a.ST_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(attributes.he_ST_NAM_Stage_Name(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_NAM_Stage_Name_Meta (
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.ST_NAM_ID
        FROM
            attributes.ST_NAM_Stage_Name_Fact p
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            attributes.eq_ST_NAM_Stage_Name(p.ST_NAM_Stage_Name, p_value) = 0
        AND
            COALESCE(attributes.he_ST_NAM_Stage_Name(p.ST_NAM_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.ST_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_NAM_Stage_Name_Fact (
            ST_NAM_ST_ID,
            ST_NAM_ChangedAt,
            ST_NAM_Stage_Name
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING ST_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.ST_NAM_Stage_Name_Meta (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_PositedAt,
        ST_NAM_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_ST_NAM_Stage_Name;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_NAM_Stage_Name instead of INSERT trigger on ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER attributes.it_ST_NAM_Stage_Name
INSTEAD OF INSERT ON attributes.ST_NAM_Stage_Name
FOR EACH ROW
BEGIN
    attributes.ip_ST_NAM_Stage_Name(
        p_owner => :NEW.ST_NAM_ST_ID,
        p_value => :NEW.ST_NAM_Stage_Name,
        p_changing => :NEW.ST_NAM_ChangedAt,
        p_positing => :NEW.ST_NAM_PositedAt,
        p_reliability => :NEW.ST_NAM_Confidence,
        p_metadata => :NEW.Metadata_ST_NAM
    );
END it_ST_NAM_Stage_Name;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_LOC_Stage_Location tells whether two values of ST_LOC_Stage_Location are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_ST_LOC_Stage_Location (
    p_left IN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_Stage_Location%TYPE,
    p_right IN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_Stage_Location%TYPE
) RETURN NUMBER
IS
    v_same NUMBER;
BEGIN
    SELECT CASE WHEN STANDARD_HASH(p_left, 'MD5') = STANDARD_HASH(p_right, 'MD5') THEN 1 ELSE 0 END INTO v_same FROM dual;
    RETURN v_same;
END eq_ST_LOC_Stage_Location;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_LOC_Stage_Location is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_ST_LOC_Stage_Location (
    p_id IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_ID%TYPE,
    p_positing IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_PositedAt%TYPE
) RETURN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_LOC_Confidence
        FROM
            attributes.ST_LOC_Stage_Location_Meta a
        WHERE
            a.ST_LOC_ID = p_id
        AND
            a.ST_LOC_PositedAt <= p_positing
        ORDER BY
            a.ST_LOC_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_LOC_Confidence;
    END LOOP;
    RETURN NULL;
END he_ST_LOC_Stage_Location;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_LOC_Stage_Location states a value of ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_LOC_Stage_Location (
    p_owner IN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_ST_ID%TYPE,
    p_value IN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_Stage_Location%TYPE,
    p_positing IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_LOC_Stage_Location_Meta.Metadata_ST_LOC%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_posit attributes.ST_LOC_Stage_Location_Fact.ST_LOC_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_LOC_Stage_Location_Meta (
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_PositedAt,
            ST_LOC_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_LOC_Stage_Location_Meta x
                WHERE
                    x.ST_LOC_ID = p_id
                AND
                    x.ST_LOC_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_LOC_ID
        FROM
            attributes.ST_LOC_Stage_Location_Fact p
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            attributes.eq_ST_LOC_Stage_Location(p.ST_LOC_Stage_Location, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_LOC_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_LOC_Stage_Location_Meta a
        WHERE
            a.ST_LOC_ID = v_posit
        AND
            a.ST_LOC_PositedAt = v_positing
        AND
            a.ST_LOC_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Stage_Location for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_LOC_Stage_Location_Fact p
        JOIN
            attributes.ST_LOC_Stage_Location_Meta a
        ON
            a.ST_LOC_ID = p.ST_LOC_ID
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            attributes.eq_ST_LOC_Stage_Location(p.ST_LOC_Stage_Location, p_value) = 0
        AND
            a.ST_LOC_PositedAt = v_positing
        AND
            a.ST_LOC_Confidence = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Stage_Location for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_LOC_Stage_Location_Meta a
        WHERE
            a.ST_LOC_ID = v_posit
        AND
            a.ST_LOC_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(attributes.he_ST_LOC_Stage_Location(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_LOC_Stage_Location_Meta (
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_PositedAt,
            ST_LOC_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.ST_LOC_ID
        FROM
            attributes.ST_LOC_Stage_Location_Fact p
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            attributes.eq_ST_LOC_Stage_Location(p.ST_LOC_Stage_Location, p_value) = 0
        AND
            COALESCE(attributes.he_ST_LOC_Stage_Location(p.ST_LOC_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.ST_LOC_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_LOC_Stage_Location_Fact (
            ST_LOC_ST_ID,
            ST_LOC_Stage_Location
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING ST_LOC_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.ST_LOC_Stage_Location_Meta (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_PositedAt,
        ST_LOC_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_ST_LOC_Stage_Location;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_LOC_Stage_Location instead of INSERT trigger on ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER attributes.it_ST_LOC_Stage_Location
INSTEAD OF INSERT ON attributes.ST_LOC_Stage_Location
FOR EACH ROW
BEGIN
    attributes.ip_ST_LOC_Stage_Location(
        p_owner => :NEW.ST_LOC_ST_ID,
        p_value => :NEW.ST_LOC_Stage_Location,
        p_positing => :NEW.ST_LOC_PositedAt,
        p_reliability => :NEW.ST_LOC_Confidence,
        p_metadata => :NEW.Metadata_ST_LOC
    );
END it_ST_LOC_Stage_Location;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_AVG_Stage_Average tells whether two values of ST_AVG_Stage_Average are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_ST_AVG_Stage_Average (
    p_left IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_UTL_ID%TYPE,
    p_right IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_UTL_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_ST_AVG_Stage_Average;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_AVG_Stage_Average is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_ST_AVG_Stage_Average (
    p_id IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_ID%TYPE,
    p_positing IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_PositedAt%TYPE
) RETURN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_AVG_Confidence
        FROM
            attributes.ST_AVG_Stage_Average_Meta a
        WHERE
            a.ST_AVG_ID = p_id
        AND
            a.ST_AVG_PositedAt <= p_positing
        ORDER BY
            a.ST_AVG_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_AVG_Confidence;
    END LOOP;
    RETURN NULL;
END he_ST_AVG_Stage_Average;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_AVG_Stage_Average states a value of ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_AVG_Stage_Average (
    p_owner IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_ST_ID%TYPE,
    p_value IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_UTL_ID%TYPE,
    p_changing IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_AVG_Stage_Average_Meta.Metadata_ST_AVG%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_changing timestamp;
    v_posit attributes.ST_AVG_Stage_Average_Fact.ST_AVG_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_AVG_Stage_Average_Meta (
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_AVG_Stage_Average_Meta x
                WHERE
                    x.ST_AVG_ID = p_id
                AND
                    x.ST_AVG_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_AVG_ID
        FROM
            attributes.ST_AVG_Stage_Average_Fact p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            attributes.eq_ST_AVG_Stage_Average(p.ST_AVG_UTL_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_AVG_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_AVG_Stage_Average_Meta a
        WHERE
            a.ST_AVG_ID = v_posit
        AND
            a.ST_AVG_PositedAt = v_positing
        AND
            a.ST_AVG_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Stage_Average for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_AVG_Stage_Average_Fact p
        JOIN
            attributes.ST_AVG_Stage_Average_Meta a
        ON
            a.ST_AVG_ID = p.ST_AVG_ID
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            attributes.eq_ST_AVG_Stage_Average(p.ST_AVG_UTL_ID, p_value) = 0
        AND
            a.ST_AVG_PositedAt = v_positing
        AND
            a.ST_AVG_Confidence = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Stage_Average for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_AVG_Stage_Average_Meta a
        WHERE
            a.ST_AVG_ID = v_posit
        AND
            a.ST_AVG_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(attributes.he_ST_AVG_Stage_Average(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_AVG_Stage_Average_Meta (
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.ST_AVG_ID
        FROM
            attributes.ST_AVG_Stage_Average_Fact p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            attributes.eq_ST_AVG_Stage_Average(p.ST_AVG_UTL_ID, p_value) = 0
        AND
            COALESCE(attributes.he_ST_AVG_Stage_Average(p.ST_AVG_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.ST_AVG_ID);
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Stage_Average_Fact p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt < v_changing
        AND
            COALESCE(attributes.he_ST_AVG_Stage_Average(p.ST_AVG_ID, v_positing), 0) = 1
        ORDER BY
            p.ST_AVG_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_ST_AVG_Stage_Average(r.ST_AVG_UTL_ID, p_value) = 1 THEN
            -- (an idempotent attribute does not store it)
            RETURN;
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.ST_AVG_ID,
            f.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Stage_Average_Fact f
        WHERE
            f.ST_AVG_ST_ID = p_owner
        AND
            f.ST_AVG_ChangedAt > v_changing
        AND
            COALESCE(attributes.he_ST_AVG_Stage_Average(f.ST_AVG_ID, v_positing), 0) = 1
        ORDER BY
            f.ST_AVG_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_ST_AVG_Stage_Average(r.ST_AVG_UTL_ID, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.ST_AVG_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_AVG_Stage_Average_Fact (
            ST_AVG_ST_ID,
            ST_AVG_ChangedAt,
            ST_AVG_UTL_ID
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING ST_AVG_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.ST_AVG_Stage_Average_Meta (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_PositedAt,
        ST_AVG_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_ST_AVG_Stage_Average;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_AVG_Stage_Average instead of INSERT trigger on ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER attributes.it_ST_AVG_Stage_Average
INSTEAD OF INSERT ON attributes.ST_AVG_Stage_Average
FOR EACH ROW
BEGIN
    attributes.ip_ST_AVG_Stage_Average(
        p_owner => :NEW.ST_AVG_ST_ID,
        p_value => :NEW.ST_AVG_UTL_ID,
        p_changing => :NEW.ST_AVG_ChangedAt,
        p_positing => :NEW.ST_AVG_PositedAt,
        p_reliability => :NEW.ST_AVG_Confidence,
        p_metadata => :NEW.Metadata_ST_AVG
    );
END it_ST_AVG_Stage_Average;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_MIN_Stage_Minimum tells whether two values of ST_MIN_Stage_Minimum are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_ST_MIN_Stage_Minimum (
    p_left IN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_UTL_ID%TYPE,
    p_right IN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_UTL_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_ST_MIN_Stage_Minimum;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_MIN_Stage_Minimum is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_ST_MIN_Stage_Minimum (
    p_id IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_ID%TYPE,
    p_positing IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_PositedAt%TYPE
) RETURN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_MIN_Confidence
        FROM
            attributes.ST_MIN_Stage_Minimum_Meta a
        WHERE
            a.ST_MIN_ID = p_id
        AND
            a.ST_MIN_PositedAt <= p_positing
        ORDER BY
            a.ST_MIN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_MIN_Confidence;
    END LOOP;
    RETURN NULL;
END he_ST_MIN_Stage_Minimum;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_MIN_Stage_Minimum states a value of ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_MIN_Stage_Minimum (
    p_owner IN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_ST_ID%TYPE,
    p_value IN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_UTL_ID%TYPE,
    p_positing IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_MIN_Stage_Minimum_Meta.Metadata_ST_MIN%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_posit attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_MIN_Stage_Minimum_Meta (
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_PositedAt,
            ST_MIN_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_MIN_Stage_Minimum_Meta x
                WHERE
                    x.ST_MIN_ID = p_id
                AND
                    x.ST_MIN_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_MIN_ID
        FROM
            attributes.ST_MIN_Stage_Minimum_Fact p
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            attributes.eq_ST_MIN_Stage_Minimum(p.ST_MIN_UTL_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_MIN_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_MIN_Stage_Minimum_Meta a
        WHERE
            a.ST_MIN_ID = v_posit
        AND
            a.ST_MIN_PositedAt = v_positing
        AND
            a.ST_MIN_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Stage_Minimum for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_MIN_Stage_Minimum_Fact p
        JOIN
            attributes.ST_MIN_Stage_Minimum_Meta a
        ON
            a.ST_MIN_ID = p.ST_MIN_ID
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            attributes.eq_ST_MIN_Stage_Minimum(p.ST_MIN_UTL_ID, p_value) = 0
        AND
            a.ST_MIN_PositedAt = v_positing
        AND
            a.ST_MIN_Confidence = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Stage_Minimum for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_MIN_Stage_Minimum_Meta a
        WHERE
            a.ST_MIN_ID = v_posit
        AND
            a.ST_MIN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(attributes.he_ST_MIN_Stage_Minimum(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_MIN_Stage_Minimum_Meta (
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_PositedAt,
            ST_MIN_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.ST_MIN_ID
        FROM
            attributes.ST_MIN_Stage_Minimum_Fact p
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            attributes.eq_ST_MIN_Stage_Minimum(p.ST_MIN_UTL_ID, p_value) = 0
        AND
            COALESCE(attributes.he_ST_MIN_Stage_Minimum(p.ST_MIN_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.ST_MIN_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_MIN_Stage_Minimum_Fact (
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING ST_MIN_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.ST_MIN_Stage_Minimum_Meta (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_PositedAt,
        ST_MIN_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_ST_MIN_Stage_Minimum;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_MIN_Stage_Minimum instead of INSERT trigger on ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER attributes.it_ST_MIN_Stage_Minimum
INSTEAD OF INSERT ON attributes.ST_MIN_Stage_Minimum
FOR EACH ROW
BEGIN
    attributes.ip_ST_MIN_Stage_Minimum(
        p_owner => :NEW.ST_MIN_ST_ID,
        p_value => :NEW.ST_MIN_UTL_ID,
        p_positing => :NEW.ST_MIN_PositedAt,
        p_reliability => :NEW.ST_MIN_Confidence,
        p_metadata => :NEW.Metadata_ST_MIN
    );
END it_ST_MIN_Stage_Minimum;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_NAM_Actor_Name tells whether two values of AC_NAM_Actor_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_AC_NAM_Actor_Name (
    p_left IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_Actor_Name%TYPE,
    p_right IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_Actor_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_AC_NAM_Actor_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_NAM_Actor_Name is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_AC_NAM_Actor_Name (
    p_id IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_ID%TYPE,
    p_positing IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_PositedAt%TYPE
) RETURN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_NAM_Confidence
        FROM
            attributes.AC_NAM_Actor_Name_Meta a
        WHERE
            a.AC_NAM_ID = p_id
        AND
            a.AC_NAM_PositedAt <= p_positing
        ORDER BY
            a.AC_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_NAM_Confidence;
    END LOOP;
    RETURN NULL;
END he_AC_NAM_Actor_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_NAM_Actor_Name states a value of AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_NAM_Actor_Name (
    p_owner IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_AC_ID%TYPE,
    p_value IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_Actor_Name%TYPE,
    p_changing IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.AC_NAM_Actor_Name_Meta.Metadata_AC_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_changing timestamp;
    v_posit attributes.AC_NAM_Actor_Name_Fact.AC_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.AC_NAM_Actor_Name_Meta (
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.AC_NAM_Actor_Name_Meta x
                WHERE
                    x.AC_NAM_ID = p_id
                AND
                    x.AC_NAM_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.AC_NAM_ID
        FROM
            attributes.AC_NAM_Actor_Name_Fact p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            attributes.eq_AC_NAM_Actor_Name(p.AC_NAM_Actor_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_NAM_Actor_Name_Meta a
        WHERE
            a.AC_NAM_ID = v_posit
        AND
            a.AC_NAM_PositedAt = v_positing
        AND
            a.AC_NAM_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_NAM_Actor_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_NAM_Actor_Name_Fact p
        JOIN
            attributes.AC_NAM_Actor_Name_Meta a
        ON
            a.AC_NAM_ID = p.AC_NAM_ID
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            attributes.eq_AC_NAM_Actor_Name(p.AC_NAM_Actor_Name, p_value) = 0
        AND
            a.AC_NAM_PositedAt = v_positing
        AND
            a.AC_NAM_Confidence = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_NAM_Actor_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_NAM_Actor_Name_Meta a
        WHERE
            a.AC_NAM_ID = v_posit
        AND
            a.AC_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(attributes.he_AC_NAM_Actor_Name(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.AC_NAM_Actor_Name_Meta (
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.AC_NAM_ID
        FROM
            attributes.AC_NAM_Actor_Name_Fact p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            attributes.eq_AC_NAM_Actor_Name(p.AC_NAM_Actor_Name, p_value) = 0
        AND
            COALESCE(attributes.he_AC_NAM_Actor_Name(p.AC_NAM_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.AC_NAM_ID);
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.AC_NAM_Actor_Name
        FROM
            attributes.AC_NAM_Actor_Name_Fact p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt < v_changing
        AND
            COALESCE(attributes.he_AC_NAM_Actor_Name(p.AC_NAM_ID, v_positing), 0) = 1
        ORDER BY
            p.AC_NAM_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_AC_NAM_Actor_Name(r.AC_NAM_Actor_Name, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Actor_Name for: ' || p_owner || ', ' || v_changing || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.AC_NAM_ID,
            f.AC_NAM_Actor_Name
        FROM
            attributes.AC_NAM_Actor_Name_Fact f
        WHERE
            f.AC_NAM_AC_ID = p_owner
        AND
            f.AC_NAM_ChangedAt > v_changing
        AND
            COALESCE(attributes.he_AC_NAM_Actor_Name(f.AC_NAM_ID, v_positing), 0) = 1
        ORDER BY
            f.AC_NAM_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_AC_NAM_Actor_Name(r.AC_NAM_Actor_Name, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Actor_Name for: ' || p_owner || ', ' || v_changing || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.AC_NAM_Actor_Name_Fact (
            AC_NAM_AC_ID,
            AC_NAM_ChangedAt,
            AC_NAM_Actor_Name
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING AC_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.AC_NAM_Actor_Name_Meta (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_PositedAt,
        AC_NAM_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_AC_NAM_Actor_Name;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_NAM_Actor_Name instead of INSERT trigger on AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER attributes.it_AC_NAM_Actor_Name
INSTEAD OF INSERT ON attributes.AC_NAM_Actor_Name
FOR EACH ROW
BEGIN
    attributes.ip_AC_NAM_Actor_Name(
        p_owner => :NEW.AC_NAM_AC_ID,
        p_value => :NEW.AC_NAM_Actor_Name,
        p_changing => :NEW.AC_NAM_ChangedAt,
        p_positing => :NEW.AC_NAM_PositedAt,
        p_reliability => :NEW.AC_NAM_Confidence,
        p_metadata => :NEW.Metadata_AC_NAM
    );
END it_AC_NAM_Actor_Name;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_GEN_Actor_Gender tells whether two values of AC_GEN_Actor_Gender are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_AC_GEN_Actor_Gender (
    p_left IN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_GEN_ID%TYPE,
    p_right IN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_GEN_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_AC_GEN_Actor_Gender;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_GEN_Actor_Gender is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_AC_GEN_Actor_Gender (
    p_id IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_ID%TYPE,
    p_positing IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_PositedAt%TYPE
) RETURN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_GEN_Confidence
        FROM
            attributes.AC_GEN_Actor_Gender_Meta a
        WHERE
            a.AC_GEN_ID = p_id
        AND
            a.AC_GEN_PositedAt <= p_positing
        ORDER BY
            a.AC_GEN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_GEN_Confidence;
    END LOOP;
    RETURN NULL;
END he_AC_GEN_Actor_Gender;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_GEN_Actor_Gender states a value of AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_GEN_Actor_Gender (
    p_owner IN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_AC_ID%TYPE,
    p_value IN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_GEN_ID%TYPE,
    p_positing IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.AC_GEN_Actor_Gender_Meta.Metadata_AC_GEN%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_posit attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.AC_GEN_Actor_Gender_Meta (
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.AC_GEN_Actor_Gender_Meta x
                WHERE
                    x.AC_GEN_ID = p_id
                AND
                    x.AC_GEN_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.AC_GEN_ID
        FROM
            attributes.AC_GEN_Actor_Gender_Fact p
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            attributes.eq_AC_GEN_Actor_Gender(p.AC_GEN_GEN_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_GEN_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_GEN_Actor_Gender_Meta a
        WHERE
            a.AC_GEN_ID = v_posit
        AND
            a.AC_GEN_PositedAt = v_positing
        AND
            a.AC_GEN_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Actor_Gender for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_GEN_Actor_Gender_Fact p
        JOIN
            attributes.AC_GEN_Actor_Gender_Meta a
        ON
            a.AC_GEN_ID = p.AC_GEN_ID
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            attributes.eq_AC_GEN_Actor_Gender(p.AC_GEN_GEN_ID, p_value) = 0
        AND
            a.AC_GEN_PositedAt = v_positing
        AND
            a.AC_GEN_Confidence = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Actor_Gender for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_GEN_Actor_Gender_Meta a
        WHERE
            a.AC_GEN_ID = v_posit
        AND
            a.AC_GEN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(attributes.he_AC_GEN_Actor_Gender(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.AC_GEN_Actor_Gender_Meta (
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.AC_GEN_ID
        FROM
            attributes.AC_GEN_Actor_Gender_Fact p
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            attributes.eq_AC_GEN_Actor_Gender(p.AC_GEN_GEN_ID, p_value) = 0
        AND
            COALESCE(attributes.he_AC_GEN_Actor_Gender(p.AC_GEN_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.AC_GEN_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.AC_GEN_Actor_Gender_Fact (
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING AC_GEN_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.AC_GEN_Actor_Gender_Meta (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_AC_GEN_Actor_Gender;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_GEN_Actor_Gender instead of INSERT trigger on AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER attributes.it_AC_GEN_Actor_Gender
INSTEAD OF INSERT ON attributes.AC_GEN_Actor_Gender
FOR EACH ROW
BEGIN
    attributes.ip_AC_GEN_Actor_Gender(
        p_owner => :NEW.AC_GEN_AC_ID,
        p_value => :NEW.AC_GEN_GEN_ID,
        p_positing => :NEW.AC_GEN_PositedAt,
        p_reliability => :NEW.AC_GEN_Confidence,
        p_metadata => :NEW.Metadata_AC_GEN
    );
END it_AC_GEN_Actor_Gender;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_PLV_Actor_ProfessionalLevel tells whether two values of AC_PLV_Actor_ProfessionalLevel are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_AC_PLV_Actor_ProfessionalLevel (
    p_left IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_PLV_ID%TYPE,
    p_right IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_PLV_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_AC_PLV_Actor_ProfessionalLevel;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_PLV_Actor_ProfessionalLevel is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_AC_PLV_Actor_ProfessionalLevel (
    p_id IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_ID%TYPE,
    p_positing IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_PositedAt%TYPE
) RETURN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_PLV_Confidence
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
        WHERE
            a.AC_PLV_ID = p_id
        AND
            a.AC_PLV_PositedAt <= p_positing
        ORDER BY
            a.AC_PLV_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_PLV_Confidence;
    END LOOP;
    RETURN NULL;
END he_AC_PLV_Actor_ProfessionalLevel;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_PLV_Actor_ProfessionalLevel states a value of AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_PLV_Actor_ProfessionalLevel (
    p_owner IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_AC_ID%TYPE,
    p_value IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_PLV_ID%TYPE,
    p_changing IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.Metadata_AC_PLV%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_changing timestamp;
    v_posit attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.AC_PLV_Actor_ProfessionalLevel_Meta (
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.AC_PLV_Actor_ProfessionalLevel_Meta x
                WHERE
                    x.AC_PLV_ID = p_id
                AND
                    x.AC_PLV_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.AC_PLV_ID
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            attributes.eq_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_PLV_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_PLV_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
        WHERE
            a.AC_PLV_ID = v_posit
        AND
            a.AC_PLV_PositedAt = v_positing
        AND
            a.AC_PLV_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
        JOIN
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
        ON
            a.AC_PLV_ID = p.AC_PLV_ID
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            attributes.eq_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_PLV_ID, p_value) = 0
        AND
            a.AC_PLV_PositedAt = v_positing
        AND
            a.AC_PLV_Confidence = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
        WHERE
            a.AC_PLV_ID = v_posit
        AND
            a.AC_PLV_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(attributes.he_AC_PLV_Actor_ProfessionalLevel(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.AC_PLV_Actor_ProfessionalLevel_Meta (
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.AC_PLV_ID
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            attributes.eq_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_PLV_ID, p_value) = 0
        AND
            COALESCE(attributes.he_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.AC_PLV_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.AC_PLV_Actor_ProfessionalLevel_Fact (
            AC_PLV_AC_ID,
            AC_PLV_ChangedAt,
            AC_PLV_PLV_ID
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING AC_PLV_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.AC_PLV_Actor_ProfessionalLevel_Meta (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_PositedAt,
        AC_PLV_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_AC_PLV_Actor_ProfessionalLevel;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_PLV_Actor_ProfessionalLevel instead of INSERT trigger on AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER attributes.it_AC_PLV_Actor_ProfessionalLevel
INSTEAD OF INSERT ON attributes.AC_PLV_Actor_ProfessionalLevel
FOR EACH ROW
BEGIN
    attributes.ip_AC_PLV_Actor_ProfessionalLevel(
        p_owner => :NEW.AC_PLV_AC_ID,
        p_value => :NEW.AC_PLV_PLV_ID,
        p_changing => :NEW.AC_PLV_ChangedAt,
        p_positing => :NEW.AC_PLV_PositedAt,
        p_reliability => :NEW.AC_PLV_Confidence,
        p_metadata => :NEW.Metadata_AC_PLV
    );
END it_AC_PLV_Actor_ProfessionalLevel;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_NAM_Program_Name tells whether two values of PR_NAM_Program_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_PR_NAM_Program_Name (
    p_left IN attributes.PR_NAM_Program_Name_Fact.PR_NAM_Program_Name%TYPE,
    p_right IN attributes.PR_NAM_Program_Name_Fact.PR_NAM_Program_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_PR_NAM_Program_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_NAM_Program_Name is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_PR_NAM_Program_Name (
    p_id IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_ID%TYPE,
    p_positing IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_PositedAt%TYPE
) RETURN attributes.PR_NAM_Program_Name_Meta.PR_NAM_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_NAM_Confidence
        FROM
            attributes.PR_NAM_Program_Name_Meta a
        WHERE
            a.PR_NAM_ID = p_id
        AND
            a.PR_NAM_PositedAt <= p_positing
        ORDER BY
            a.PR_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_NAM_Confidence;
    END LOOP;
    RETURN NULL;
END he_PR_NAM_Program_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_NAM_Program_Name states a value of PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_PR_NAM_Program_Name (
    p_owner IN attributes.PR_NAM_Program_Name_Fact.PR_NAM_PR_ID%TYPE,
    p_value IN attributes.PR_NAM_Program_Name_Fact.PR_NAM_Program_Name%TYPE,
    p_positing IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.PR_NAM_Program_Name_Meta.Metadata_PR_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_posit attributes.PR_NAM_Program_Name_Fact.PR_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.PR_NAM_Program_Name_Fact.PR_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.PR_NAM_Program_Name_Meta (
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_PositedAt,
            PR_NAM_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.PR_NAM_Program_Name_Meta x
                WHERE
                    x.PR_NAM_ID = p_id
                AND
                    x.PR_NAM_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.PR_NAM_ID
        FROM
            attributes.PR_NAM_Program_Name_Fact p
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            attributes.eq_PR_NAM_Program_Name(p.PR_NAM_Program_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.PR_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_NAM_Program_Name_Meta a
        WHERE
            a.PR_NAM_ID = v_posit
        AND
            a.PR_NAM_PositedAt = v_positing
        AND
            a.PR_NAM_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Program_Name for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_NAM_Program_Name_Fact p
        JOIN
            attributes.PR_NAM_Program_Name_Meta a
        ON
            a.PR_NAM_ID = p.PR_NAM_ID
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            attributes.eq_PR_NAM_Program_Name(p.PR_NAM_Program_Name, p_value) = 0
        AND
            a.PR_NAM_PositedAt = v_positing
        AND
            a.PR_NAM_Confidence = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Program_Name for: ' || p_owner || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_NAM_Program_Name_Meta a
        WHERE
            a.PR_NAM_ID = v_posit
        AND
            a.PR_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(attributes.he_PR_NAM_Program_Name(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.PR_NAM_Program_Name_Meta (
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_PositedAt,
            PR_NAM_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.PR_NAM_ID
        FROM
            attributes.PR_NAM_Program_Name_Fact p
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            attributes.eq_PR_NAM_Program_Name(p.PR_NAM_Program_Name, p_value) = 0
        AND
            COALESCE(attributes.he_PR_NAM_Program_Name(p.PR_NAM_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.PR_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.PR_NAM_Program_Name_Fact (
            PR_NAM_PR_ID,
            PR_NAM_Program_Name
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING PR_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.PR_NAM_Program_Name_Meta (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_PositedAt,
        PR_NAM_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_PR_NAM_Program_Name;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_NAM_Program_Name instead of INSERT trigger on PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER attributes.it_PR_NAM_Program_Name
INSTEAD OF INSERT ON attributes.PR_NAM_Program_Name
FOR EACH ROW
BEGIN
    attributes.ip_PR_NAM_Program_Name(
        p_owner => :NEW.PR_NAM_PR_ID,
        p_value => :NEW.PR_NAM_Program_Name,
        p_positing => :NEW.PR_NAM_PositedAt,
        p_reliability => :NEW.PR_NAM_Confidence,
        p_metadata => :NEW.Metadata_PR_NAM
    );
END it_PR_NAM_Program_Name;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_LEN_Program_Length tells whether two values of PR_LEN_Program_Length are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_PR_LEN_Program_Length (
    p_left IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_Program_Length%TYPE,
    p_right IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_Program_Length%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_PR_LEN_Program_Length;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_LEN_Program_Length is the reliability that a posit has at a positing time (null if it has none): that of its latest
-- annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_PR_LEN_Program_Length (
    p_id IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_ID%TYPE,
    p_positing IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_PositedAt%TYPE
) RETURN attributes.PR_LEN_Program_Length_Meta.PR_LEN_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_LEN_Confidence
        FROM
            attributes.PR_LEN_Program_Length_Meta a
        WHERE
            a.PR_LEN_ID = p_id
        AND
            a.PR_LEN_PositedAt <= p_positing
        ORDER BY
            a.PR_LEN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_LEN_Confidence;
    END LOOP;
    RETURN NULL;
END he_PR_LEN_Program_Length;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_LEN_Program_Length states a value of PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_PR_LEN_Program_Length (
    p_owner IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_PR_ID%TYPE,
    p_value IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_Program_Length%TYPE,
    p_changing IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_ChangedAt%TYPE DEFAULT NULL,
    p_positing IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.PR_LEN_Program_Length_Meta.Metadata_PR_LEN%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_changing date;
    v_posit attributes.PR_LEN_Program_Length_Fact.PR_LEN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.PR_LEN_Program_Length_Meta (
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.PR_LEN_Program_Length_Meta x
                WHERE
                    x.PR_LEN_ID = p_id
                AND
                    x.PR_LEN_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.PR_LEN_ID
        FROM
            attributes.PR_LEN_Program_Length_Fact p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            attributes.eq_PR_LEN_Program_Length(p.PR_LEN_Program_Length, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.PR_LEN_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_LEN_Program_Length_Meta a
        WHERE
            a.PR_LEN_ID = v_posit
        AND
            a.PR_LEN_PositedAt = v_positing
        AND
            a.PR_LEN_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_LEN_Program_Length for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    IF v_reliability = 1 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_LEN_Program_Length_Fact p
        JOIN
            attributes.PR_LEN_Program_Length_Meta a
        ON
            a.PR_LEN_ID = p.PR_LEN_ID
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            attributes.eq_PR_LEN_Program_Length(p.PR_LEN_Program_Length, p_value) = 0
        AND
            a.PR_LEN_PositedAt = v_positing
        AND
            a.PR_LEN_Confidence = 1;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_LEN_Program_Length for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_LEN_Program_Length_Meta a
        WHERE
            a.PR_LEN_ID = v_posit
        AND
            a.PR_LEN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- whether the posit is asserted at the positing time
    IF v_reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF v_posit IS NULL THEN
            RETURN;
        END IF;
        IF COALESCE(attributes.he_PR_LEN_Program_Length(v_posit, v_positing), 0) <> 1 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.PR_LEN_Program_Length_Meta (
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Confidence
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR r IN (
        SELECT
            p.PR_LEN_ID
        FROM
            attributes.PR_LEN_Program_Length_Fact p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            attributes.eq_PR_LEN_Program_Length(p.PR_LEN_Program_Length, p_value) = 0
        AND
            COALESCE(attributes.he_PR_LEN_Program_Length(p.PR_LEN_ID, v_positing), 0) = 1
    ) LOOP
        retract(r.PR_LEN_ID);
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.PR_LEN_Program_Length
        FROM
            attributes.PR_LEN_Program_Length_Fact p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt < v_changing
        AND
            COALESCE(attributes.he_PR_LEN_Program_Length(p.PR_LEN_ID, v_positing), 0) = 1
        ORDER BY
            p.PR_LEN_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_PR_LEN_Program_Length(r.PR_LEN_Program_Length, p_value) = 1 THEN
            -- (an idempotent attribute does not store it)
            RETURN;
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.PR_LEN_ID,
            f.PR_LEN_Program_Length
        FROM
            attributes.PR_LEN_Program_Length_Fact f
        WHERE
            f.PR_LEN_PR_ID = p_owner
        AND
            f.PR_LEN_ChangedAt > v_changing
        AND
            COALESCE(attributes.he_PR_LEN_Program_Length(f.PR_LEN_ID, v_positing), 0) = 1
        ORDER BY
            f.PR_LEN_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_PR_LEN_Program_Length(r.PR_LEN_Program_Length, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.PR_LEN_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.PR_LEN_Program_Length_Fact (
            PR_LEN_PR_ID,
            PR_LEN_ChangedAt,
            PR_LEN_Program_Length
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING PR_LEN_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.PR_LEN_Program_Length_Meta (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_PositedAt,
        PR_LEN_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positing,
        v_reliability
    );
END ip_PR_LEN_Program_Length;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_LEN_Program_Length instead of INSERT trigger on PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER attributes.it_PR_LEN_Program_Length
INSTEAD OF INSERT ON attributes.PR_LEN_Program_Length
FOR EACH ROW
BEGIN
    attributes.ip_PR_LEN_Program_Length(
        p_owner => :NEW.PR_LEN_PR_ID,
        p_value => :NEW.PR_LEN_Program_Length,
        p_changing => :NEW.PR_LEN_ChangedAt,
        p_positing => :NEW.PR_LEN_PositedAt,
        p_reliability => :NEW.PR_LEN_Confidence,
        p_metadata => :NEW.Metadata_PR_LEN
    );
END it_PR_LEN_Program_Length;
/
