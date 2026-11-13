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
CREATE OR REPLACE TRIGGER itST_Stage
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itST_Stage instead of INSERT trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lST_Stage
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN

    INSERT INTO ST_Stage (
        ST_ID,
        ST_Dummy 
    ) VALUES (
        :NEW.ST_ID,
        :NEW.ST_Dummy 
    );

    if (:NEW.ST_NAM_Stage_Name is not null) then -- insert
        INSERT INTO ST_NAM_Stage_Name (

            ST_NAM_ChangedAt, -- timestamp null,
            ST_NAM_Stage_Name, --  nvarchar2(42) null,   ELSE

        ) VALUES (

            nvl(:NEW.ST_NAM_ChangedAt, l_now), -- timestamp null,
            :NEW.ST_NAM_Stage_Name, --  nvarchar2(42) null,   ELSE

        );
    end if;
    if (:NEW.ST_LOC_Stage_Location is not null) then -- insert
        INSERT INTO ST_LOC_Stage_Location (


            ST_LOC_Stage_Location, --  geography null,   ELSE

        ) VALUES (


            :NEW.ST_LOC_Stage_Location, --  geography null,   ELSE

        );
    end if;
    if (:NEW.UTL_Utilization is not null) then -- insert
        INSERT INTO ST_AVG_Stage_Average (

            ST_AVG_ChangedAt, -- timestamp null,
            -- UTL_Utilization, -- number(3) null,   KNOT
            -- 
            UTL_ID, --  number(3) null,   KNOT

        ) VALUES (

            nvl(:NEW.ST_AVG_ChangedAt, l_now), -- timestamp null,
            -- :NEW.UTL_Utilization, -- number(3) null,   KNOT
            -- 
            (select knot.UTL_ID from UTL_Utilization knot where knot.UTL_Utilization = :NEW.UTL_Utilization), -- number(3) null,    -- KNOT insert om UTL_Utilization på väg in i vyn finns i UTL_Utilization

        );
    end if;
    if (:NEW.UTL_Utilization is not null) then -- insert
        INSERT INTO ST_MIN_Stage_Minimum (


            -- UTL_Utilization, -- number(3) null,   KNOT
            -- 
            UTL_ID, --  number(3) null

        ) VALUES (


            -- :NEW.UTL_Utilization, -- number(3) null,   KNOT
            -- 
            (select knot.UTL_ID from UTL_Utilization knot where knot.UTL_Utilization = :NEW.UTL_Utilization), -- number(3) null

        );
    end if;
END itST_Stage;
/
CREATE OR REPLACE TRIGGER utST_Stage
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utST_Stage instead of UPDATE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF UPDATE
ON lST_Stage
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
    if is_changed(:NEW.ST_NAM_Stage_Name, :OLD.ST_NAM_Stage_Name) then -- insert
        l_changedate := get_changedate(:NEW.ST_NAM_ChangedAt, :OLD.ST_NAM_ChangedAt);

        INSERT INTO ST_NAM_Stage_Name (

            ST_NAM_ChangedAt, -- timestamp null,
            ST_NAM_Stage_Name, --  nvarchar2(42) null,   ELSE

        ) VALUES (

            l_changedate,
            :NEW.ST_NAM_Stage_Name, --  nvarchar2(42) null,   ELSE

        );
    end if;
    if is_changed(:NEW.ST_LOC_Stage_Location, :OLD.ST_LOC_Stage_Location) then -- insert


        INSERT INTO ST_LOC_Stage_Location (


            ST_LOC_Stage_Location, --  geography null,   ELSE

        ) VALUES (


            :NEW.ST_LOC_Stage_Location, --  geography null,   ELSE

        );
    end if;
    if is_changed(:NEW.UTL_Utilization, :OLD.UTL_Utilization) then -- insert
        l_changedate := get_changedate(:NEW.ST_AVG_ChangedAt, :OLD.ST_AVG_ChangedAt);

        INSERT INTO ST_AVG_Stage_Average (

            ST_AVG_ChangedAt, -- timestamp null,
            -- UTL_Utilization, -- number(3) null,   KNOT
            -- 
            UTL_ID, --  number(3) null,   KNOT

        ) VALUES (

            l_changedate,
            -- :NEW.UTL_Utilization, -- number(3) null,   KNOT
            -- 
            (select knot.UTL_ID from UTL_Utilization knot where knot.UTL_Utilization = :NEW.UTL_Utilization), -- number(3) null,    -- KNOT insert om UTL_Utilization på väg in i vyn finns i UTL_Utilization

        );
    end if;
    if is_changed(:NEW.UTL_Utilization, :OLD.UTL_Utilization) then -- insert


        INSERT INTO ST_MIN_Stage_Minimum (


            -- UTL_Utilization, -- number(3) null,   KNOT
            -- 
            UTL_ID, --  number(3) null

        ) VALUES (


            -- :NEW.UTL_Utilization, -- number(3) null,   KNOT
            -- 
            (select knot.UTL_ID from UTL_Utilization knot where knot.UTL_Utilization = :NEW.UTL_Utilization), -- number(3) null

        );
    end if;
END utST_Stage;
/
CREATE OR REPLACE TRIGGER dtST_Stage
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtST_Stage instead of DELETE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lST_Stage
FOR EACH ROW
DECLARE    l_now date := sysdate;
BEGIN
    -- ta bort attribut för givet ankare och tid
    delete ST_NAM_Stage_Name where 1=1
    and ST_NAM_ChangedAt = :OLD.ST_NAM_ChangedAt
    ;
    -- ta bort attribut för givet ankare
    delete ST_LOC_Stage_Location where 1=1
    ;
    -- ta bort attribut för givet ankare och tid
    delete ST_AVG_Stage_Average where 1=1
    and ST_AVG_ChangedAt = :OLD.ST_AVG_ChangedAt
    ;
    -- ta bort attribut för givet ankare
    delete ST_MIN_Stage_Minimum where 1=1
    ;
    -- ta bort ankare om det inte längre har några attribut
    delete ST_Stage where ST_ID = 

    and 0 = (select count(*) from ST_NAM_Stage_Name where 

    and 0 = (select count(*) from ST_LOC_Stage_Location where 

    and 0 = (select count(*) from ST_AVG_Stage_Average where 

    and 0 = (select count(*) from ST_MIN_Stage_Minimum where 
    ;
END dtST_Stage;
/
CREATE OR REPLACE TRIGGER itAC_Actor
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_Actor instead of INSERT trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lAC_Actor
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN

    INSERT INTO AC_Actor (
        AC_ID,
        AC_Dummy 
    ) VALUES (
        :NEW.AC_ID,
        :NEW.AC_Dummy 
    );

    if (:NEW.AC_NAM_Actor_Name is not null) then -- insert
        INSERT INTO AC_NAM_Actor_Name (

            AC_NAM_ChangedAt, -- timestamp null,
            AC_NAM_Actor_Name, --  nvarchar2(42) null,   ELSE

        ) VALUES (

            nvl(:NEW.AC_NAM_ChangedAt, l_now), -- timestamp null,
            :NEW.AC_NAM_Actor_Name, --  nvarchar2(42) null,   ELSE

        );
    end if;
    if (:NEW.GEN_Gender is not null) then -- insert
        INSERT INTO AC_GEN_Actor_Gender (


            -- GEN_Gender, -- nvarchar2(42) null,   KNOT
            -- 
            GEN_ID, --  number(3) null,   KNOT

        ) VALUES (


            -- :NEW.GEN_Gender, -- nvarchar2(42) null,   KNOT
            -- 
            (select knot.GEN_ID from GEN_Gender knot where knot.GEN_Gender = :NEW.GEN_Gender), -- number(3) null,    -- KNOT insert om GEN_Gender på väg in i vyn finns i GEN_Gender

        );
    end if;
    if (:NEW.PLV_ProfessionalLevel is not null) then -- insert
        INSERT INTO AC_PLV_Actor_ProfessionalLevel (

            AC_PLV_ChangedAt, -- timestamp null,
            -- PLV_ProfessionalLevel, -- nclob null,   KNOT
            -- 
            PLV_ID, --  number(3) null

        ) VALUES (

            nvl(:NEW.AC_PLV_ChangedAt, l_now), -- timestamp null,
            -- :NEW.PLV_ProfessionalLevel, -- nclob null,   KNOT
            -- 
            (select knot.PLV_ID from PLV_ProfessionalLevel knot where knot.PLV_ProfessionalLevel = :NEW.PLV_ProfessionalLevel), -- number(3) null

        );
    end if;
END itAC_Actor;
/
CREATE OR REPLACE TRIGGER utAC_Actor
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utAC_Actor instead of UPDATE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF UPDATE
ON lAC_Actor
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
    if is_changed(:NEW.AC_NAM_Actor_Name, :OLD.AC_NAM_Actor_Name) then -- insert
        l_changedate := get_changedate(:NEW.AC_NAM_ChangedAt, :OLD.AC_NAM_ChangedAt);

        INSERT INTO AC_NAM_Actor_Name (

            AC_NAM_ChangedAt, -- timestamp null,
            AC_NAM_Actor_Name, --  nvarchar2(42) null,   ELSE

        ) VALUES (

            l_changedate,
            :NEW.AC_NAM_Actor_Name, --  nvarchar2(42) null,   ELSE

        );
    end if;
    if is_changed(:NEW.GEN_Gender, :OLD.GEN_Gender) then -- insert


        INSERT INTO AC_GEN_Actor_Gender (


            -- GEN_Gender, -- nvarchar2(42) null,   KNOT
            -- 
            GEN_ID, --  number(3) null,   KNOT

        ) VALUES (


            -- :NEW.GEN_Gender, -- nvarchar2(42) null,   KNOT
            -- 
            (select knot.GEN_ID from GEN_Gender knot where knot.GEN_Gender = :NEW.GEN_Gender), -- number(3) null,    -- KNOT insert om GEN_Gender på väg in i vyn finns i GEN_Gender

        );
    end if;
    if is_changed(:NEW.PLV_ProfessionalLevel, :OLD.PLV_ProfessionalLevel) then -- insert
        l_changedate := get_changedate(:NEW.AC_PLV_ChangedAt, :OLD.AC_PLV_ChangedAt);

        INSERT INTO AC_PLV_Actor_ProfessionalLevel (

            AC_PLV_ChangedAt, -- timestamp null,
            -- PLV_ProfessionalLevel, -- nclob null,   KNOT
            -- 
            PLV_ID, --  number(3) null

        ) VALUES (

            l_changedate,
            -- :NEW.PLV_ProfessionalLevel, -- nclob null,   KNOT
            -- 
            (select knot.PLV_ID from PLV_ProfessionalLevel knot where knot.PLV_ProfessionalLevel = :NEW.PLV_ProfessionalLevel), -- number(3) null

        );
    end if;
END utAC_Actor;
/
CREATE OR REPLACE TRIGGER dtAC_Actor
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtAC_Actor instead of DELETE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lAC_Actor
FOR EACH ROW
DECLARE    l_now date := sysdate;
BEGIN
    -- ta bort attribut för givet ankare och tid
    delete AC_NAM_Actor_Name where 1=1
    and AC_NAM_ChangedAt = :OLD.AC_NAM_ChangedAt
    ;
    -- ta bort attribut för givet ankare
    delete AC_GEN_Actor_Gender where 1=1
    ;
    -- ta bort attribut för givet ankare och tid
    delete AC_PLV_Actor_ProfessionalLevel where 1=1
    and AC_PLV_ChangedAt = :OLD.AC_PLV_ChangedAt
    ;
    -- ta bort ankare om det inte längre har några attribut
    delete AC_Actor where AC_ID = 

    and 0 = (select count(*) from AC_NAM_Actor_Name where 

    and 0 = (select count(*) from AC_GEN_Actor_Gender where 

    and 0 = (select count(*) from AC_PLV_Actor_ProfessionalLevel where 
    ;
END dtAC_Actor;
/
CREATE OR REPLACE TRIGGER itPR_Program
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itPR_Program instead of INSERT trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lPR_Program
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN

    INSERT INTO PR_Program (
        PR_ID,
        PR_Dummy 
    ) VALUES (
        :NEW.PR_ID,
        :NEW.PR_Dummy 
    );

    if (:NEW.PR_NAM_Program_Name is not null) then -- insert
        INSERT INTO PR_NAM_Program_Name (


            PR_NAM_Program_Name, --  nvarchar2(42) null,   ELSE

        ) VALUES (


            :NEW.PR_NAM_Program_Name, --  nvarchar2(42) null,   ELSE

        );
    end if;
    if (:NEW.PR_LEN_Program_Length is not null) then -- insert
        INSERT INTO PR_LEN_Program_Length (

            PR_LEN_ChangedAt, -- date null,
            PR_LEN_Program_Length, --  timestamp null

        ) VALUES (

            nvl(:NEW.PR_LEN_ChangedAt, l_now), -- date null,
            :NEW.PR_LEN_Program_Length, --  timestamp null

        );
    end if;
END itPR_Program;
/
CREATE OR REPLACE TRIGGER utPR_Program
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utPR_Program instead of UPDATE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF UPDATE
ON lPR_Program
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
    if is_changed(:NEW.PR_NAM_Program_Name, :OLD.PR_NAM_Program_Name) then -- insert


        INSERT INTO PR_NAM_Program_Name (


            PR_NAM_Program_Name, --  nvarchar2(42) null,   ELSE

        ) VALUES (


            :NEW.PR_NAM_Program_Name, --  nvarchar2(42) null,   ELSE

        );
    end if;
    if is_changed(:NEW.PR_LEN_Program_Length, :OLD.PR_LEN_Program_Length) then -- insert
        l_changedate := get_changedate(:NEW.PR_LEN_ChangedAt, :OLD.PR_LEN_ChangedAt);

        INSERT INTO PR_LEN_Program_Length (

            PR_LEN_ChangedAt, -- date null,
            PR_LEN_Program_Length, --  timestamp null

        ) VALUES (

            l_changedate,
            :NEW.PR_LEN_Program_Length, --  timestamp null

        );
    end if;
END utPR_Program;
/
CREATE OR REPLACE TRIGGER dtPR_Program
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtPR_Program instead of DELETE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lPR_Program
FOR EACH ROW
DECLARE    l_now date := sysdate;
BEGIN
    -- ta bort attribut för givet ankare
    delete PR_NAM_Program_Name where 1=1
    ;
    -- ta bort attribut för givet ankare och tid
    delete PR_LEN_Program_Length where 1=1
    and PR_LEN_ChangedAt = :OLD.PR_LEN_ChangedAt
    ;
    -- ta bort ankare om det inte längre har några attribut
    delete PR_Program where PR_ID = 

    and 0 = (select count(*) from PR_NAM_Program_Name where 

    and 0 = (select count(*) from PR_LEN_Program_Length where 
    ;
END dtPR_Program;
/
