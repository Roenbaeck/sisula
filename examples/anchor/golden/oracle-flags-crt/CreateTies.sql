-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- CRT ties use posit and annex split with changing/positing time, positor, reliability, and assertion.
--
CREATE TABLE IF NOT EXISTS ties.AC_partner_AC_with_ONG_currently_Posit (
    AC_partner_AC_with_ONG_currently_ID number(10) IDENTITY(1,1) not null, 
    AC_ID_partner number(5) not null, 
    AC_ID_with number(5) not null, 
    ONG_ID_currently number(3) not null,
    AC_partner_AC_with_ONG_currently_ChangedAt timestamp not null,
    constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_partner foreign key (
        AC_ID_partner
    ) references anchors.AC_Actor(AC_ID),
    constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_with foreign key (
        AC_ID_with
    ) references anchors.AC_Actor(AC_ID),
    constraint AC_partner_AC_with_ONG_currently_Posit_fkONG_currently foreign key (
        ONG_ID_currently
    ) references knots.ONG_Ongoing(ONG_ID),
    constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_partner unique (
        AC_ID_partner,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_with unique (
        AC_ID_with,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    constraint pkAC_partner_AC_with_ONG_currently_Posit primary key (
        AC_partner_AC_with_ONG_currently_ID
    ),
    constraint uqAC_partner_AC_with_ONG_currently unique (
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    )
) CLUSTER BY (
    AC_partner_AC_with_ONG_currently_ChangedAt
);

CREATE TABLE IF NOT EXISTS ties.AC_partner_AC_with_ONG_currently_Annex (
    AC_partner_AC_with_ONG_currently_ID number(10) not null,
    AC_partner_AC_with_ONG_currently_PositedAt timestamp not null,
    AC_partner_AC_with_ONG_currently_Positor number(3) not null,
    AC_partner_AC_with_ONG_currently_Reliability number(5,2) not null,
    AC_partner_AC_with_ONG_currently_Assertion varchar2(4000) default (
        case
            when AC_partner_AC_with_ONG_currently_Reliability > 0 then '+'
            when AC_partner_AC_with_ONG_currently_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_partner_AC_with_ONG_currently_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_partner_AC_with_ONG_currently number(10) not null,
    constraint fkAC_partner_AC_with_ONG_currently_Annex foreign key (
        AC_partner_AC_with_ONG_currently_ID
    ) references ties.AC_partner_AC_with_ONG_currently_Posit(AC_partner_AC_with_ONG_currently_ID),
    constraint pkAC_partner_AC_with_ONG_currently_Annex primary key (
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_Positor,
        AC_partner_AC_with_ONG_currently_PositedAt
    )
) CLUSTER BY (AC_partner_AC_with_ONG_currently_ID, AC_partner_AC_with_ONG_currently_Positor, AC_partner_AC_with_ONG_currently_PositedAt);
CREATE TABLE IF NOT EXISTS ties.AC_subset_PN_of_Posit (
    AC_subset_PN_of_ID number(10) IDENTITY(1,1) not null, 
    AC_ID_subset number(5) not null, 
    PN_ID_of number(19) not null, 
    constraint AC_subset_PN_of_Posit_fkAC_subset foreign key (
        AC_ID_subset
    ) references anchors.AC_Actor(AC_ID),
    constraint AC_subset_PN_of_Posit_fkPN_of foreign key (
        PN_ID_of
    ) references anchors.PN_Person(PN_ID),
    constraint AC_subset_PN_of_Posit_uqAC_subset unique (
        AC_ID_subset
    ),
    constraint AC_subset_PN_of_Posit_uqPN_of unique (
        PN_ID_of
    ),
    constraint pkAC_subset_PN_of_Posit primary key (
        AC_subset_PN_of_ID
    ),
    constraint uqAC_subset_PN_of unique (
        AC_ID_subset,
        PN_ID_of
    )
) CLUSTER BY (
);

CREATE TABLE IF NOT EXISTS ties.AC_subset_PN_of_Annex (
    AC_subset_PN_of_ID number(10) not null,
    AC_subset_PN_of_PositedAt timestamp not null,
    AC_subset_PN_of_Positor number(3) not null,
    AC_subset_PN_of_Reliability number(5,2) not null,
    AC_subset_PN_of_Assertion varchar2(4000) default (
        case
            when AC_subset_PN_of_Reliability > 0 then '+'
            when AC_subset_PN_of_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_subset_PN_of_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_subset_PN_of number(10) not null,
    constraint fkAC_subset_PN_of_Annex foreign key (
        AC_subset_PN_of_ID
    ) references ties.AC_subset_PN_of_Posit(AC_subset_PN_of_ID),
    constraint pkAC_subset_PN_of_Annex primary key (
        AC_subset_PN_of_ID,
        AC_subset_PN_of_Positor,
        AC_subset_PN_of_PositedAt
    )
) CLUSTER BY (AC_subset_PN_of_ID, AC_subset_PN_of_Positor, AC_subset_PN_of_PositedAt);
CREATE TABLE IF NOT EXISTS ties.EV_in_AC_wasCast_Posit (
    EV_in_AC_wasCast_ID number(10) IDENTITY(1,1) not null, 
    EV_ID_in number(12,0) not null, 
    AC_ID_wasCast number(5) not null, 
    constraint EV_in_AC_wasCast_Posit_fkEV_in foreign key (
        EV_ID_in
    ) references nexuses.EV_Event(EV_ID),
    constraint EV_in_AC_wasCast_Posit_fkAC_wasCast foreign key (
        AC_ID_wasCast
    ) references anchors.AC_Actor(AC_ID),
    constraint pkEV_in_AC_wasCast_Posit primary key (
        EV_in_AC_wasCast_ID
    ),
    constraint uqEV_in_AC_wasCast unique (
        EV_ID_in,
        AC_ID_wasCast
    )
) CLUSTER BY (
    EV_ID_in,
    AC_ID_wasCast
);

CREATE TABLE IF NOT EXISTS ties.EV_in_AC_wasCast_Annex (
    EV_in_AC_wasCast_ID number(10) not null,
    EV_in_AC_wasCast_PositedAt timestamp not null,
    EV_in_AC_wasCast_Positor number(3) not null,
    EV_in_AC_wasCast_Reliability number(5,2) not null,
    EV_in_AC_wasCast_Assertion varchar2(4000) default (
        case
            when EV_in_AC_wasCast_Reliability > 0 then '+'
            when EV_in_AC_wasCast_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_in_AC_wasCast_Reliability <  then 0
            else 1
        end
    ),
    Metadata_EV_in_AC_wasCast number(10) not null,
    constraint fkEV_in_AC_wasCast_Annex foreign key (
        EV_in_AC_wasCast_ID
    ) references ties.EV_in_AC_wasCast_Posit(EV_in_AC_wasCast_ID),
    constraint pkEV_in_AC_wasCast_Annex primary key (
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_Positor,
        EV_in_AC_wasCast_PositedAt
    )
) CLUSTER BY (EV_in_AC_wasCast_ID, EV_in_AC_wasCast_Positor, EV_in_AC_wasCast_PositedAt);
CREATE TABLE IF NOT EXISTS ties.AC_part_PR_in_RAT_got_Posit (
    AC_part_PR_in_RAT_got_ID number(10) IDENTITY(1,1) not null, 
    AC_ID_part number(5) not null, 
    PR_ID_in number(19) not null, 
    RAT_ID_got number(3) not null,
    AC_part_PR_in_RAT_got_ChangedAt timestamp not null,
    constraint AC_part_PR_in_RAT_got_Posit_fkAC_part foreign key (
        AC_ID_part
    ) references anchors.AC_Actor(AC_ID),
    constraint AC_part_PR_in_RAT_got_Posit_fkPR_in foreign key (
        PR_ID_in
    ) references anchors.PR_Program(PR_ID),
    constraint AC_part_PR_in_RAT_got_Posit_fkRAT_got foreign key (
        RAT_ID_got
    ) references knots.RAT_Rating(RAT_ID),
    constraint pkAC_part_PR_in_RAT_got_Posit primary key (
        AC_part_PR_in_RAT_got_ID
    ),
    constraint uqAC_part_PR_in_RAT_got unique (
        AC_ID_part,
        PR_ID_in,
        AC_part_PR_in_RAT_got_ChangedAt,
        RAT_ID_got
    )
) CLUSTER BY (
    AC_ID_part,
    PR_ID_in,
    AC_part_PR_in_RAT_got_ChangedAt
);

CREATE TABLE IF NOT EXISTS ties.AC_part_PR_in_RAT_got_Annex (
    AC_part_PR_in_RAT_got_ID number(10) not null,
    AC_part_PR_in_RAT_got_PositedAt timestamp not null,
    AC_part_PR_in_RAT_got_Positor number(3) not null,
    AC_part_PR_in_RAT_got_Reliability number(5,2) not null,
    AC_part_PR_in_RAT_got_Assertion varchar2(4000) default (
        case
            when AC_part_PR_in_RAT_got_Reliability > 0 then '+'
            when AC_part_PR_in_RAT_got_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_part_PR_in_RAT_got_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_part_PR_in_RAT_got number(10) not null,
    constraint fkAC_part_PR_in_RAT_got_Annex foreign key (
        AC_part_PR_in_RAT_got_ID
    ) references ties.AC_part_PR_in_RAT_got_Posit(AC_part_PR_in_RAT_got_ID),
    constraint pkAC_part_PR_in_RAT_got_Annex primary key (
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_Positor,
        AC_part_PR_in_RAT_got_PositedAt
    )
) CLUSTER BY (AC_part_PR_in_RAT_got_ID, AC_part_PR_in_RAT_got_Positor, AC_part_PR_in_RAT_got_PositedAt);
CREATE TABLE IF NOT EXISTS ties.ST_at_PR_isPlaying_Posit (
    ST_at_PR_isPlaying_ID number(10) IDENTITY(1,1) not null, 
    ST_ID_at number(10) not null, 
    PR_ID_isPlaying number(19) not null, 
    ST_at_PR_isPlaying_ChangedAt timestamp not null,
    constraint ST_at_PR_isPlaying_Posit_fkST_at foreign key (
        ST_ID_at
    ) references anchors.ST_Stage(ST_ID),
    constraint ST_at_PR_isPlaying_Posit_fkPR_isPlaying foreign key (
        PR_ID_isPlaying
    ) references anchors.PR_Program(PR_ID),
    constraint pkST_at_PR_isPlaying_Posit primary key (
        ST_at_PR_isPlaying_ID
    ),
    constraint uqST_at_PR_isPlaying unique (
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_ChangedAt
    )
) CLUSTER BY (
    ST_ID_at,
    PR_ID_isPlaying,
    ST_at_PR_isPlaying_ChangedAt
);

CREATE TABLE IF NOT EXISTS ties.ST_at_PR_isPlaying_Annex (
    ST_at_PR_isPlaying_ID number(10) not null,
    ST_at_PR_isPlaying_PositedAt timestamp not null,
    ST_at_PR_isPlaying_Positor number(3) not null,
    ST_at_PR_isPlaying_Reliability number(5,2) not null,
    ST_at_PR_isPlaying_Assertion varchar2(4000) default (
        case
            when ST_at_PR_isPlaying_Reliability > 0 then '+'
            when ST_at_PR_isPlaying_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_at_PR_isPlaying_Reliability <  then 0
            else 1
        end
    ),
    Metadata_ST_at_PR_isPlaying number(10) not null,
    constraint fkST_at_PR_isPlaying_Annex foreign key (
        ST_at_PR_isPlaying_ID
    ) references ties.ST_at_PR_isPlaying_Posit(ST_at_PR_isPlaying_ID),
    constraint pkST_at_PR_isPlaying_Annex primary key (
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_Positor,
        ST_at_PR_isPlaying_PositedAt
    )
) CLUSTER BY (ST_at_PR_isPlaying_ID, ST_at_PR_isPlaying_Positor, ST_at_PR_isPlaying_PositedAt);
CREATE TABLE IF NOT EXISTS ties.AC_parent_AC_child_PAT_having_Posit (
    AC_parent_AC_child_PAT_having_ID number(10) IDENTITY(1,1) not null, 
    AC_ID_parent number(5) not null, 
    AC_ID_child number(5) not null, 
    PAT_ID_having number(3) not null,
    constraint AC_parent_AC_child_PAT_having_Posit_fkAC_parent foreign key (
        AC_ID_parent
    ) references anchors.AC_Actor(AC_ID),
    constraint AC_parent_AC_child_PAT_having_Posit_fkAC_child foreign key (
        AC_ID_child
    ) references anchors.AC_Actor(AC_ID),
    constraint AC_parent_AC_child_PAT_having_Posit_fkPAT_having foreign key (
        PAT_ID_having
    ) references knots.PAT_ParentalType(PAT_ID),
    constraint pkAC_parent_AC_child_PAT_having_Posit primary key (
        AC_parent_AC_child_PAT_having_ID
    ),
    constraint uqAC_parent_AC_child_PAT_having unique (
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    )
) CLUSTER BY (
    AC_ID_parent,
    AC_ID_child,
    PAT_ID_having
);

CREATE TABLE IF NOT EXISTS ties.AC_parent_AC_child_PAT_having_Annex (
    AC_parent_AC_child_PAT_having_ID number(10) not null,
    AC_parent_AC_child_PAT_having_PositedAt timestamp not null,
    AC_parent_AC_child_PAT_having_Positor number(3) not null,
    AC_parent_AC_child_PAT_having_Reliability number(5,2) not null,
    AC_parent_AC_child_PAT_having_Assertion varchar2(4000) default (
        case
            when AC_parent_AC_child_PAT_having_Reliability > 0 then '+'
            when AC_parent_AC_child_PAT_having_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_parent_AC_child_PAT_having_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_parent_AC_child_PAT_having number(10) not null,
    constraint fkAC_parent_AC_child_PAT_having_Annex foreign key (
        AC_parent_AC_child_PAT_having_ID
    ) references ties.AC_parent_AC_child_PAT_having_Posit(AC_parent_AC_child_PAT_having_ID),
    constraint pkAC_parent_AC_child_PAT_having_Annex primary key (
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_Positor,
        AC_parent_AC_child_PAT_having_PositedAt
    )
) CLUSTER BY (AC_parent_AC_child_PAT_having_ID, AC_parent_AC_child_PAT_having_Positor, AC_parent_AC_child_PAT_having_PositedAt);
CREATE TABLE IF NOT EXISTS ties.PR_content_ST_location_EV_of_Posit (
    PR_content_ST_location_EV_of_ID number(10) IDENTITY(1,1) not null, 
    PR_ID_content number(19) not null, 
    ST_ID_location number(10) not null, 
    EV_ID_of number(12,0) not null, 
    PR_content_ST_location_EV_of_ChangedAt timestamp not null,
    constraint PR_content_ST_location_EV_of_Posit_fkPR_content foreign key (
        PR_ID_content
    ) references anchors.PR_Program(PR_ID),
    constraint PR_content_ST_location_EV_of_Posit_fkST_location foreign key (
        ST_ID_location
    ) references anchors.ST_Stage(ST_ID),
    constraint PR_content_ST_location_EV_of_Posit_fkEV_of foreign key (
        EV_ID_of
    ) references nexuses.EV_Event(EV_ID),
    constraint PR_content_ST_location_EV_of_Posit_uqPR_content unique (
        PR_ID_content,
        PR_content_ST_location_EV_of_ChangedAt
    ),
    constraint PR_content_ST_location_EV_of_Posit_uqST_location unique (
        ST_ID_location,
        PR_content_ST_location_EV_of_ChangedAt
    ),
    constraint pkPR_content_ST_location_EV_of_Posit primary key (
        PR_content_ST_location_EV_of_ID
    ),
    constraint uqPR_content_ST_location_EV_of unique (
        PR_content_ST_location_EV_of_ChangedAt,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    )
) CLUSTER BY (
    PR_content_ST_location_EV_of_ChangedAt
);

CREATE TABLE IF NOT EXISTS ties.PR_content_ST_location_EV_of_Annex (
    PR_content_ST_location_EV_of_ID number(10) not null,
    PR_content_ST_location_EV_of_PositedAt timestamp not null,
    PR_content_ST_location_EV_of_Positor number(3) not null,
    PR_content_ST_location_EV_of_Reliability number(5,2) not null,
    PR_content_ST_location_EV_of_Assertion varchar2(4000) default (
        case
            when PR_content_ST_location_EV_of_Reliability > 0 then '+'
            when PR_content_ST_location_EV_of_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when PR_content_ST_location_EV_of_Reliability <  then 0
            else 1
        end
    ),
    Metadata_PR_content_ST_location_EV_of number(10) not null,
    constraint fkPR_content_ST_location_EV_of_Annex foreign key (
        PR_content_ST_location_EV_of_ID
    ) references ties.PR_content_ST_location_EV_of_Posit(PR_content_ST_location_EV_of_ID),
    constraint pkPR_content_ST_location_EV_of_Annex primary key (
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_Positor,
        PR_content_ST_location_EV_of_PositedAt
    )
) CLUSTER BY (PR_content_ST_location_EV_of_ID, PR_content_ST_location_EV_of_Positor, PR_content_ST_location_EV_of_PositedAt);
