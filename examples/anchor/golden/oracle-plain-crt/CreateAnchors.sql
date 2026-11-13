-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PN_Person (
    PN_ID number(10) IDENTITY(1,1) not null, 
    PN_Dummy boolean null,
    constraint pkPN_Person primary key (
        PN_ID
    )
) CLUSTER BY (PN_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ST_Stage (
    ST_ID number(10) IDENTITY(1,1) not null, 
    ST_Dummy boolean null,
    constraint pkST_Stage primary key (
        ST_ID
    )
) CLUSTER BY (ST_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.AC_Actor (
    AC_ID number(10) IDENTITY(1,1) not null, 
    AC_Dummy boolean null,
    constraint pkAC_Actor primary key (
        AC_ID
    )
) CLUSTER BY (AC_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.PR_Program (
    PR_ID number(10) IDENTITY(1,1) not null, 
    PR_Dummy boolean null,
    constraint pkPR_Program primary key (
        PR_ID
    )
) CLUSTER BY (PR_ID);
