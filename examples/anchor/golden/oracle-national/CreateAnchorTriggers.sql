-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
CREATE OR REPLACE TRIGGER itST_Scen
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itST_Scen instead of INSERT trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lST_Scen
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN

    INSERT INTO ST_Scen (
        ST_ID,
        Metadata_ST 
    ) VALUES (
        :NEW.ST_ID,
        :NEW.Metadata_ST 
    );

    if (:NEW.ST_NAM_Scen_Namn is not null) then -- insert
        INSERT INTO ST_NAM_Scen_Namn (
            ST_NAM_ST_ID, -- number(10) null,
            ST_NAM_ChangedAt, -- timestamp null,
            ST_NAM_Scen_Namn, --  nvarchar2(42) null,   ELSE
            Metadata_ST_NAM -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,
            nvl(:NEW.ST_NAM_ChangedAt, l_now), -- timestamp null,
            :NEW.ST_NAM_Scen_Namn, --  nvarchar2(42) null,   ELSE
            nvl(:NEW.Metadata_ST_NAM, :NEW.Metadata_ST) -- null,
        );
    end if;
    if (:NEW.ST_LOC_Scen_Plats is not null) then -- insert
        INSERT INTO ST_LOC_Scen_Plats (
            ST_LOC_ST_ID, -- number(10) null,

            ST_LOC_Scen_Plats, --  geography null,   ELSE
            Metadata_ST_LOC -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,

            :NEW.ST_LOC_Scen_Plats, --  geography null,   ELSE
            nvl(:NEW.Metadata_ST_LOC, :NEW.Metadata_ST) -- null,
        );
    end if;
    if (:NEW.ST_AVG_UTL_Utnyttjande is not null) then -- insert
        INSERT INTO ST_AVG_Scen_Medel (
            ST_AVG_ST_ID, -- number(10) null,
            ST_AVG_ChangedAt, -- timestamp null,
            -- ST_AVG_UTL_Utnyttjande, -- number(3) null,   KNOT
            -- ST_AVG_Metadata_UTL, -- number(10) null,   KNOT
            ST_AVG_UTL_ID, --  number(3) null,   KNOT
            Metadata_ST_AVG -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,
            nvl(:NEW.ST_AVG_ChangedAt, l_now), -- timestamp null,
            -- :NEW.ST_AVG_UTL_Utnyttjande, -- number(3) null,   KNOT
            -- nvl(:NEW.ST_AVG_Metadata_UTL, :NEW.Metadata_ST), -- null,   KNOT
            (select knot.UTL_ID from UTL_Utnyttjande knot where knot.UTL_Utnyttjande = :NEW.ST_AVG_UTL_Utnyttjande), -- number(3) null,    -- KNOT insert om ST_AVG_UTL_Utnyttjande på väg in i vyn finns i UTL_Utnyttjande
            nvl(:NEW.Metadata_ST_AVG, :NEW.Metadata_ST) -- null,
        );
    end if;
    if (:NEW.ST_MIN_UTL_Utnyttjande is not null) then -- insert
        INSERT INTO ST_MIN_Scen_Minimum (
            ST_MIN_ST_ID, -- number(10) null,

            -- ST_MIN_UTL_Utnyttjande, -- number(3) null,   KNOT
            -- ST_MIN_Metadata_UTL, -- number(10) null,   KNOT
            ST_MIN_UTL_ID, --  number(3) null
            Metadata_ST_MIN -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,

            -- :NEW.ST_MIN_UTL_Utnyttjande, -- number(3) null,   KNOT
            -- nvl(:NEW.ST_MIN_Metadata_UTL, :NEW.Metadata_ST), -- null,   KNOT
            (select knot.UTL_ID from UTL_Utnyttjande knot where knot.UTL_Utnyttjande = :NEW.ST_MIN_UTL_Utnyttjande), -- number(3) null
            nvl(:NEW.Metadata_ST_MIN, :NEW.Metadata_ST) -- null,
        );
    end if;
END itST_Scen;
/
CREATE OR REPLACE TRIGGER utST_Scen
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utST_Scen instead of UPDATE trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF UPDATE
ON lST_Scen
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now date := sysdate;
    l_changedate date := sysdate;
    l_metadata  integer;
    -- är kolumnen förändrad, OBS tar hänsyn till NULL
    function is_changed ( in_new varchar2, in_old varchar2) return boolean is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return false;
        else
            -- TRUE
            return true;
        end if;
    end is_changed;
    -- ger changedate, OBS tar hänsyn till NULL
    function get_changedate ( in_new date, in_old date) return date is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) OR (in_new is null) then
            -- FALSE
            return l_now;
        else
            -- TRUE
            return in_new;
        end if;
    end get_changedate;
    -- ger metadata, OBS tar hänsyn till NULL
    function get_metadata ( in_new integer, in_old integer) return integer is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return 0;
        else
            -- TRUE
            return in_new;
        end if;
    end get_metadata;
BEGIN
    if is_changed(:NEW.ST_NAM_Scen_Namn, :OLD.ST_NAM_Scen_Namn) then -- insert
        l_changedate := get_changedate(:NEW.ST_NAM_ChangedAt, :OLD.ST_NAM_ChangedAt);
        l_metadata := get_metadata(:NEW.Metadata_ST_NAM, :OLD.Metadata_ST_NAM);
        INSERT INTO ST_NAM_Scen_Namn (
            ST_NAM_ST_ID, -- number(10) null,
            ST_NAM_ChangedAt, -- timestamp null,
            ST_NAM_Scen_Namn, --  nvarchar2(42) null,   ELSE
            Metadata_ST_NAM -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,
            l_changedate,
            :NEW.ST_NAM_Scen_Namn, --  nvarchar2(42) null,   ELSE
            l_metadata -- number(10) null,
        );
    end if;
    if is_changed(:NEW.ST_LOC_Scen_Plats, :OLD.ST_LOC_Scen_Plats) then -- insert

        l_metadata := get_metadata(:NEW.Metadata_ST_LOC, :OLD.Metadata_ST_LOC);
        INSERT INTO ST_LOC_Scen_Plats (
            ST_LOC_ST_ID, -- number(10) null,

            ST_LOC_Scen_Plats, --  geography null,   ELSE
            Metadata_ST_LOC -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,

            :NEW.ST_LOC_Scen_Plats, --  geography null,   ELSE
            l_metadata -- number(10) null,
        );
    end if;
    if is_changed(:NEW.ST_AVG_UTL_Utnyttjande, :OLD.ST_AVG_UTL_Utnyttjande) then -- insert
        l_changedate := get_changedate(:NEW.ST_AVG_ChangedAt, :OLD.ST_AVG_ChangedAt);
        l_metadata := get_metadata(:NEW.Metadata_ST_AVG, :OLD.Metadata_ST_AVG);
        INSERT INTO ST_AVG_Scen_Medel (
            ST_AVG_ST_ID, -- number(10) null,
            ST_AVG_ChangedAt, -- timestamp null,
            -- ST_AVG_UTL_Utnyttjande, -- number(3) null,   KNOT
            -- ST_AVG_Metadata_UTL, -- number(10) null,   KNOT
            ST_AVG_UTL_ID, --  number(3) null,   KNOT
            Metadata_ST_AVG -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,
            l_changedate,
            -- :NEW.ST_AVG_UTL_Utnyttjande, -- number(3) null,   KNOT
            -- nvl(:NEW.ST_AVG_Metadata_UTL, :NEW.Metadata_ST), -- null,   KNOT
            (select knot.UTL_ID from UTL_Utnyttjande knot where knot.UTL_Utnyttjande = :NEW.ST_AVG_UTL_Utnyttjande), -- number(3) null,    -- KNOT insert om ST_AVG_UTL_Utnyttjande på väg in i vyn finns i UTL_Utnyttjande
            l_metadata -- number(10) null,
        );
    end if;
    if is_changed(:NEW.ST_MIN_UTL_Utnyttjande, :OLD.ST_MIN_UTL_Utnyttjande) then -- insert

        l_metadata := get_metadata(:NEW.Metadata_ST_MIN, :OLD.Metadata_ST_MIN);
        INSERT INTO ST_MIN_Scen_Minimum (
            ST_MIN_ST_ID, -- number(10) null,

            -- ST_MIN_UTL_Utnyttjande, -- number(3) null,   KNOT
            -- ST_MIN_Metadata_UTL, -- number(10) null,   KNOT
            ST_MIN_UTL_ID, --  number(3) null
            Metadata_ST_MIN -- number(10) null,
        ) VALUES (
            :NEW.ST_ID, -- number(10) null,

            -- :NEW.ST_MIN_UTL_Utnyttjande, -- number(3) null,   KNOT
            -- nvl(:NEW.ST_MIN_Metadata_UTL, :NEW.Metadata_ST), -- null,   KNOT
            (select knot.UTL_ID from UTL_Utnyttjande knot where knot.UTL_Utnyttjande = :NEW.ST_MIN_UTL_Utnyttjande), -- number(3) null
            l_metadata -- number(10) null,
        );
    end if;
END utST_Scen;
/
CREATE OR REPLACE TRIGGER dtST_Scen
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtST_Scen instead of DELETE trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lST_Scen
FOR EACH ROW
DECLARE    l_now date := sysdate;
BEGIN
    -- ta bort attribut för givet ankare och tid
    delete ST_NAM_Scen_Namn where 1=1
    and ST_NAM_ST_ID = :OLD.ST_ID
    and ST_NAM_ChangedAt = :OLD.ST_NAM_ChangedAt
    ;
    -- ta bort attribut för givet ankare
    delete ST_LOC_Scen_Plats where 1=1
    and ST_LOC_ST_ID = :OLD.ST_ID
    ;
    -- ta bort attribut för givet ankare och tid
    delete ST_AVG_Scen_Medel where 1=1
    and ST_AVG_ST_ID = :OLD.ST_ID
    and ST_AVG_ChangedAt = :OLD.ST_AVG_ChangedAt
    ;
    -- ta bort attribut för givet ankare
    delete ST_MIN_Scen_Minimum where 1=1
    and ST_MIN_ST_ID = :OLD.ST_ID
    ;
    -- ta bort ankare om det inte längre har några attribut
    delete ST_Scen where ST_ID = :OLD.ST_ID

    and 0 = (select count(*) from ST_NAM_Scen_Namn where ST_NAM_ST_ID = :OLD.ST_ID)

    and 0 = (select count(*) from ST_LOC_Scen_Plats where ST_LOC_ST_ID = :OLD.ST_ID)

    and 0 = (select count(*) from ST_AVG_Scen_Medel where ST_AVG_ST_ID = :OLD.ST_ID)

    and 0 = (select count(*) from ST_MIN_Scen_Minimum where ST_MIN_ST_ID = :OLD.ST_ID)
    ;
END dtST_Scen;
/
CREATE OR REPLACE TRIGGER itAC_Skådespelare
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_Skådespelare instead of INSERT trigger on lAC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lAC_Skådespelare
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN

    INSERT INTO AC_Skådespelare (
        AC_ID,
        Metadata_AC 
    ) VALUES (
        :NEW.AC_ID,
        :NEW.Metadata_AC 
    );

    if (:NEW.AC_NAM_Skådespelare_Namn is not null) then -- insert
        INSERT INTO AC_NAM_Skådespelare_Namn (
            AC_NAM_AC_ID, -- number(5) null,
            AC_NAM_ChangedAt, -- timestamp null,
            AC_NAM_Skådespelare_Namn, --  nvarchar2(42) null,   ELSE
            Metadata_AC_NAM -- number(10) null,
        ) VALUES (
            :NEW.AC_ID, -- number(5) null,
            nvl(:NEW.AC_NAM_ChangedAt, l_now), -- timestamp null,
            :NEW.AC_NAM_Skådespelare_Namn, --  nvarchar2(42) null,   ELSE
            nvl(:NEW.Metadata_AC_NAM, :NEW.Metadata_AC) -- null,
        );
    end if;
    if (:NEW.AC_GEN_GEN_Kön is not null) then -- insert
        INSERT INTO AC_GEN_Skådespelare_Kön (
            AC_GEN_AC_ID, -- number(5) null,

            -- AC_GEN_GEN_Kön, -- nvarchar2(42) null,   KNOT
            -- AC_GEN_Metadata_GEN, -- number(10) null,   KNOT
            AC_GEN_GEN_ID, --  number(3) null,   KNOT
            Metadata_AC_GEN -- number(10) null,
        ) VALUES (
            :NEW.AC_ID, -- number(5) null,

            -- :NEW.AC_GEN_GEN_Kön, -- nvarchar2(42) null,   KNOT
            -- nvl(:NEW.AC_GEN_Metadata_GEN, :NEW.Metadata_AC), -- null,   KNOT
            (select knot.GEN_ID from GEN_Kön knot where knot.GEN_Kön = :NEW.AC_GEN_GEN_Kön), -- number(3) null,    -- KNOT insert om AC_GEN_GEN_Kön på väg in i vyn finns i GEN_Kön
            nvl(:NEW.Metadata_AC_GEN, :NEW.Metadata_AC) -- null,
        );
    end if;
    if (:NEW.AC_PLV_PLV_Yrkesnivå is not null) then -- insert
        INSERT INTO AC_PLV_Skådespelare_Yrkesnivå (
            AC_PLV_AC_ID, -- number(5) null,
            AC_PLV_ChangedAt, -- timestamp null,
            -- AC_PLV_PLV_Yrkesnivå, -- nclob null,   KNOT
            -- AC_PLV_Metadata_PLV, -- number(10) null,   KNOT
            AC_PLV_PLV_ID, --  number(3) null
            Metadata_AC_PLV -- number(10) null,
        ) VALUES (
            :NEW.AC_ID, -- number(5) null,
            nvl(:NEW.AC_PLV_ChangedAt, l_now), -- timestamp null,
            -- :NEW.AC_PLV_PLV_Yrkesnivå, -- nclob null,   KNOT
            -- nvl(:NEW.AC_PLV_Metadata_PLV, :NEW.Metadata_AC), -- null,   KNOT
            (select knot.PLV_ID from PLV_Yrkesnivå knot where knot.PLV_Yrkesnivå = :NEW.AC_PLV_PLV_Yrkesnivå), -- number(3) null
            nvl(:NEW.Metadata_AC_PLV, :NEW.Metadata_AC) -- null,
        );
    end if;
END itAC_Skådespelare;
/
CREATE OR REPLACE TRIGGER utAC_Skådespelare
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utAC_Skådespelare instead of UPDATE trigger on lAC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF UPDATE
ON lAC_Skådespelare
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now date := sysdate;
    l_changedate date := sysdate;
    l_metadata  integer;
    -- är kolumnen förändrad, OBS tar hänsyn till NULL
    function is_changed ( in_new varchar2, in_old varchar2) return boolean is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return false;
        else
            -- TRUE
            return true;
        end if;
    end is_changed;
    -- ger changedate, OBS tar hänsyn till NULL
    function get_changedate ( in_new date, in_old date) return date is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) OR (in_new is null) then
            -- FALSE
            return l_now;
        else
            -- TRUE
            return in_new;
        end if;
    end get_changedate;
    -- ger metadata, OBS tar hänsyn till NULL
    function get_metadata ( in_new integer, in_old integer) return integer is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return 0;
        else
            -- TRUE
            return in_new;
        end if;
    end get_metadata;
BEGIN
    if is_changed(:NEW.AC_NAM_Skådespelare_Namn, :OLD.AC_NAM_Skådespelare_Namn) then -- insert
        l_changedate := get_changedate(:NEW.AC_NAM_ChangedAt, :OLD.AC_NAM_ChangedAt);
        l_metadata := get_metadata(:NEW.Metadata_AC_NAM, :OLD.Metadata_AC_NAM);
        INSERT INTO AC_NAM_Skådespelare_Namn (
            AC_NAM_AC_ID, -- number(5) null,
            AC_NAM_ChangedAt, -- timestamp null,
            AC_NAM_Skådespelare_Namn, --  nvarchar2(42) null,   ELSE
            Metadata_AC_NAM -- number(10) null,
        ) VALUES (
            :NEW.AC_ID, -- number(5) null,
            l_changedate,
            :NEW.AC_NAM_Skådespelare_Namn, --  nvarchar2(42) null,   ELSE
            l_metadata -- number(10) null,
        );
    end if;
    if is_changed(:NEW.AC_GEN_GEN_Kön, :OLD.AC_GEN_GEN_Kön) then -- insert

        l_metadata := get_metadata(:NEW.Metadata_AC_GEN, :OLD.Metadata_AC_GEN);
        INSERT INTO AC_GEN_Skådespelare_Kön (
            AC_GEN_AC_ID, -- number(5) null,

            -- AC_GEN_GEN_Kön, -- nvarchar2(42) null,   KNOT
            -- AC_GEN_Metadata_GEN, -- number(10) null,   KNOT
            AC_GEN_GEN_ID, --  number(3) null,   KNOT
            Metadata_AC_GEN -- number(10) null,
        ) VALUES (
            :NEW.AC_ID, -- number(5) null,

            -- :NEW.AC_GEN_GEN_Kön, -- nvarchar2(42) null,   KNOT
            -- nvl(:NEW.AC_GEN_Metadata_GEN, :NEW.Metadata_AC), -- null,   KNOT
            (select knot.GEN_ID from GEN_Kön knot where knot.GEN_Kön = :NEW.AC_GEN_GEN_Kön), -- number(3) null,    -- KNOT insert om AC_GEN_GEN_Kön på väg in i vyn finns i GEN_Kön
            l_metadata -- number(10) null,
        );
    end if;
    if is_changed(:NEW.AC_PLV_PLV_Yrkesnivå, :OLD.AC_PLV_PLV_Yrkesnivå) then -- insert
        l_changedate := get_changedate(:NEW.AC_PLV_ChangedAt, :OLD.AC_PLV_ChangedAt);
        l_metadata := get_metadata(:NEW.Metadata_AC_PLV, :OLD.Metadata_AC_PLV);
        INSERT INTO AC_PLV_Skådespelare_Yrkesnivå (
            AC_PLV_AC_ID, -- number(5) null,
            AC_PLV_ChangedAt, -- timestamp null,
            -- AC_PLV_PLV_Yrkesnivå, -- nclob null,   KNOT
            -- AC_PLV_Metadata_PLV, -- number(10) null,   KNOT
            AC_PLV_PLV_ID, --  number(3) null
            Metadata_AC_PLV -- number(10) null,
        ) VALUES (
            :NEW.AC_ID, -- number(5) null,
            l_changedate,
            -- :NEW.AC_PLV_PLV_Yrkesnivå, -- nclob null,   KNOT
            -- nvl(:NEW.AC_PLV_Metadata_PLV, :NEW.Metadata_AC), -- null,   KNOT
            (select knot.PLV_ID from PLV_Yrkesnivå knot where knot.PLV_Yrkesnivå = :NEW.AC_PLV_PLV_Yrkesnivå), -- number(3) null
            l_metadata -- number(10) null,
        );
    end if;
END utAC_Skådespelare;
/
CREATE OR REPLACE TRIGGER dtAC_Skådespelare
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtAC_Skådespelare instead of DELETE trigger on lAC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lAC_Skådespelare
FOR EACH ROW
DECLARE    l_now date := sysdate;
BEGIN
    -- ta bort attribut för givet ankare och tid
    delete AC_NAM_Skådespelare_Namn where 1=1
    and AC_NAM_AC_ID = :OLD.AC_ID
    and AC_NAM_ChangedAt = :OLD.AC_NAM_ChangedAt
    ;
    -- ta bort attribut för givet ankare
    delete AC_GEN_Skådespelare_Kön where 1=1
    and AC_GEN_AC_ID = :OLD.AC_ID
    ;
    -- ta bort attribut för givet ankare och tid
    delete AC_PLV_Skådespelare_Yrkesnivå where 1=1
    and AC_PLV_AC_ID = :OLD.AC_ID
    and AC_PLV_ChangedAt = :OLD.AC_PLV_ChangedAt
    ;
    -- ta bort ankare om det inte längre har några attribut
    delete AC_Skådespelare where AC_ID = :OLD.AC_ID

    and 0 = (select count(*) from AC_NAM_Skådespelare_Namn where AC_NAM_AC_ID = :OLD.AC_ID)

    and 0 = (select count(*) from AC_GEN_Skådespelare_Kön where AC_GEN_AC_ID = :OLD.AC_ID)

    and 0 = (select count(*) from AC_PLV_Skådespelare_Yrkesnivå where AC_PLV_AC_ID = :OLD.AC_ID)
    ;
END dtAC_Skådespelare;
/
CREATE OR REPLACE TRIGGER itPR_Föreställning
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itPR_Föreställning instead of INSERT trigger on lPR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lPR_Föreställning
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN

    INSERT INTO PR_Föreställning (
        PR_ID,
        Metadata_PR 
    ) VALUES (
        :NEW.PR_ID,
        :NEW.Metadata_PR 
    );

    if (:NEW.PR_NAM_Föreställning_Namn is not null) then -- insert
        INSERT INTO PR_NAM_Föreställning_Namn (
            PR_NAM_PR_ID, -- number(19) null,

            PR_NAM_Föreställning_Namn, --  nvarchar2(42) null,   ELSE
            Metadata_PR_NAM -- number(10) null,
        ) VALUES (
            :NEW.PR_ID, -- number(19) null,

            :NEW.PR_NAM_Föreställning_Namn, --  nvarchar2(42) null,   ELSE
            nvl(:NEW.Metadata_PR_NAM, :NEW.Metadata_PR) -- null,
        );
    end if;
    if (:NEW.PR_LEN_Föreställning_Längd is not null) then -- insert
        INSERT INTO PR_LEN_Föreställning_Längd (
            PR_LEN_PR_ID, -- number(19) null,
            PR_LEN_ChangedAt, -- date null,
            PR_LEN_Föreställning_Längd, --  timestamp null
            Metadata_PR_LEN -- number(10) null,
        ) VALUES (
            :NEW.PR_ID, -- number(19) null,
            nvl(:NEW.PR_LEN_ChangedAt, l_now), -- date null,
            :NEW.PR_LEN_Föreställning_Längd, --  timestamp null
            nvl(:NEW.Metadata_PR_LEN, :NEW.Metadata_PR) -- null,
        );
    end if;
END itPR_Föreställning;
/
CREATE OR REPLACE TRIGGER utPR_Föreställning
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utPR_Föreställning instead of UPDATE trigger on lPR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF UPDATE
ON lPR_Föreställning
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now date := sysdate;
    l_changedate date := sysdate;
    l_metadata  integer;
    -- är kolumnen förändrad, OBS tar hänsyn till NULL
    function is_changed ( in_new varchar2, in_old varchar2) return boolean is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return false;
        else
            -- TRUE
            return true;
        end if;
    end is_changed;
    -- ger changedate, OBS tar hänsyn till NULL
    function get_changedate ( in_new date, in_old date) return date is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) OR (in_new is null) then
            -- FALSE
            return l_now;
        else
            -- TRUE
            return in_new;
        end if;
    end get_changedate;
    -- ger metadata, OBS tar hänsyn till NULL
    function get_metadata ( in_new integer, in_old integer) return integer is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return 0;
        else
            -- TRUE
            return in_new;
        end if;
    end get_metadata;
BEGIN
    if is_changed(:NEW.PR_NAM_Föreställning_Namn, :OLD.PR_NAM_Föreställning_Namn) then -- insert

        l_metadata := get_metadata(:NEW.Metadata_PR_NAM, :OLD.Metadata_PR_NAM);
        INSERT INTO PR_NAM_Föreställning_Namn (
            PR_NAM_PR_ID, -- number(19) null,

            PR_NAM_Föreställning_Namn, --  nvarchar2(42) null,   ELSE
            Metadata_PR_NAM -- number(10) null,
        ) VALUES (
            :NEW.PR_ID, -- number(19) null,

            :NEW.PR_NAM_Föreställning_Namn, --  nvarchar2(42) null,   ELSE
            l_metadata -- number(10) null,
        );
    end if;
    if is_changed(:NEW.PR_LEN_Föreställning_Längd, :OLD.PR_LEN_Föreställning_Längd) then -- insert
        l_changedate := get_changedate(:NEW.PR_LEN_ChangedAt, :OLD.PR_LEN_ChangedAt);
        l_metadata := get_metadata(:NEW.Metadata_PR_LEN, :OLD.Metadata_PR_LEN);
        INSERT INTO PR_LEN_Föreställning_Längd (
            PR_LEN_PR_ID, -- number(19) null,
            PR_LEN_ChangedAt, -- date null,
            PR_LEN_Föreställning_Längd, --  timestamp null
            Metadata_PR_LEN -- number(10) null,
        ) VALUES (
            :NEW.PR_ID, -- number(19) null,
            l_changedate,
            :NEW.PR_LEN_Föreställning_Längd, --  timestamp null
            l_metadata -- number(10) null,
        );
    end if;
END utPR_Föreställning;
/
CREATE OR REPLACE TRIGGER dtPR_Föreställning
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtPR_Föreställning instead of DELETE trigger on lPR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lPR_Föreställning
FOR EACH ROW
DECLARE    l_now date := sysdate;
BEGIN
    -- ta bort attribut för givet ankare
    delete PR_NAM_Föreställning_Namn where 1=1
    and PR_NAM_PR_ID = :OLD.PR_ID
    ;
    -- ta bort attribut för givet ankare och tid
    delete PR_LEN_Föreställning_Längd where 1=1
    and PR_LEN_PR_ID = :OLD.PR_ID
    and PR_LEN_ChangedAt = :OLD.PR_LEN_ChangedAt
    ;
    -- ta bort ankare om det inte längre har några attribut
    delete PR_Föreställning where PR_ID = :OLD.PR_ID

    and 0 = (select count(*) from PR_NAM_Föreställning_Namn where PR_NAM_PR_ID = :OLD.PR_ID)

    and 0 = (select count(*) from PR_LEN_Föreställning_Längd where PR_LEN_PR_ID = :OLD.PR_ID)
    ;
END dtPR_Föreställning;
/
