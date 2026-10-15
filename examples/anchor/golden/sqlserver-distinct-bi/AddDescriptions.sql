-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'knots',
@level1type = N'Table', @level1name = 'PAT_ParentalType';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Kind of parent-child relationship between two actors, such as biological or adoptive parent.
',
@level0type = N'Schema', @level0name = 'knots',
@level1type = N'Table', @level1name = 'PAT_ParentalType';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'knots',
@level1type = N'Table', @level1name = 'GEN_Gender';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Gender of an actor.
',
@level0type = N'Schema', @level0name = 'knots',
@level1type = N'Table', @level1name = 'GEN_Gender';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'knots',
@level1type = N'Table', @level1name = 'PLV_ProfessionalLevel';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.
',
@level0type = N'Schema', @level0name = 'knots',
@level1type = N'Table', @level1name = 'PLV_ProfessionalLevel';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'knots',
@level1type = N'Table', @level1name = 'UTL_Utilization';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.
',
@level0type = N'Schema', @level0name = 'knots',
@level1type = N'Table', @level1name = 'UTL_Utilization';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'knots',
@level1type = N'Table', @level1name = 'ONG_Ongoing';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Yes or No flag indicating whether a relationship is still ongoing or has ended.
',
@level0type = N'Schema', @level0name = 'knots',
@level1type = N'Table', @level1name = 'ONG_Ongoing';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'knots',
@level1type = N'Table', @level1name = 'RAT_Rating';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Rating of how well an actor performs a part in a program, such as good, mediocre or bad.
',
@level0type = N'Schema', @level0name = 'knots',
@level1type = N'Table', @level1name = 'RAT_Rating';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'anchors',
@level1type = N'Table', @level1name = 'PN_Person';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
A person. Persons who perform are also registered as actors.
',
@level0type = N'Schema', @level0name = 'anchors',
@level1type = N'Table', @level1name = 'PN_Person';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'anchors',
@level1type = N'Table', @level1name = 'ST_Stage';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
A stage or venue where programs are played and events are held.
',
@level0type = N'Schema', @level0name = 'anchors',
@level1type = N'Table', @level1name = 'ST_Stage';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'ST_NAM_Stage_Name_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Name of the stage. Historized, since a stage may be renamed over time.
',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'ST_NAM_Stage_Name_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'ST_LOC_Stage_Location_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Geographic location of the stage as a geography point.
',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'ST_LOC_Stage_Location_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'ST_AVG_Stage_Average_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Average utilization of the stage capacity, recalculated over time.
',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'ST_AVG_Stage_Average_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'ST_MIN_Stage_Minimum_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Minimum utilization of the stage capacity required for a performance to take place.
',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'ST_MIN_Stage_Minimum_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'anchors',
@level1type = N'Table', @level1name = 'AC_Actor';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
An actor, a person who performs parts in programs and is cast in events.
',
@level0type = N'Schema', @level0name = 'anchors',
@level1type = N'Table', @level1name = 'AC_Actor';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'AC_NAM_Actor_Name_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Name of the actor, such as a stage name. Historized, since it may change over time.
',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'AC_NAM_Actor_Name_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'AC_GEN_Actor_Gender_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Gender of the actor.
',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'AC_GEN_Actor_Gender_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'AC_PLV_Actor_ProfessionalLevel_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Professional level of the actor, which may change as the actor gains experience.
',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'AC_PLV_Actor_ProfessionalLevel_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'PR_NAM_Program_Name_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Name or title of the program.
',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'PR_NAM_Program_Name_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'PR_LEN_Program_Length_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Running time of the program. Historized, since the program may be shortened or extended over time.
',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'PR_LEN_Program_Length_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'nexuses',
@level1type = N'Table', @level1name = 'EV_Event';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
An event, a single performance of a program held at a stage at a specific date and time.
',
@level0type = N'Schema', @level0name = 'nexuses',
@level1type = N'Table', @level1name = 'EV_Event';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'EV_DAT_Event_Date_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Date and time when the event took place.
',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'EV_DAT_Event_Date_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'EV_AUD_Event_Audience_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Number of people in the audience at the event.
',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'EV_AUD_Event_Audience_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'EV_REV_Event_Revenue_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Revenue from ticket sales for the event.
',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'EV_REV_Event_Revenue_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'EV_STA_Event_Status_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Status of the event, which may change until it has taken place.
',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'EV_STA_Event_Status_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'EV_LVL_Event_Level_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Professional level required for the event, over time.
',
@level0type = N'Schema', @level0name = 'attributes',
@level1type = N'Table', @level1name = 'EV_LVL_Event_Level_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'nexuses',
@level1type = N'Table', @level1name = 'EV_Event',
@level2type = N'Column', @level2name = 'ST_ID_wasHeldAt';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The stage at which the event was held.
',
@level0type = N'Schema', @level0name = 'nexuses',
@level1type = N'Table', @level1name = 'EV_Event',
@level2type = N'Column', @level2name = 'ST_ID_wasHeldAt';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'nexuses',
@level1type = N'Table', @level1name = 'EV_Event',
@level2type = N'Column', @level2name = 'PR_ID_wasPlayed';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The program that was played at the event.
',
@level0type = N'Schema', @level0name = 'nexuses',
@level1type = N'Table', @level1name = 'EV_Event',
@level2type = N'Column', @level2name = 'PR_ID_wasPlayed';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit',
@level2type = N'Column', @level2name = 'AC_ID_partner';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
One of the actors in the partnership.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit',
@level2type = N'Column', @level2name = 'AC_ID_partner';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit',
@level2type = N'Column', @level2name = 'AC_ID_with';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The other actor in the partnership.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit',
@level2type = N'Column', @level2name = 'AC_ID_with';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit',
@level2type = N'Column', @level2name = 'ONG_ID_currently';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Whether the partnership is still ongoing (Yes) or has ended (No).
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_partner_AC_with_ONG_currently_Posit',
@level2type = N'Column', @level2name = 'ONG_ID_currently';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_subset_PN_of_Posit',
@level2type = N'Column', @level2name = 'AC_ID_subset';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
An actor, a person who performs parts in programs and is cast in events.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_subset_PN_of_Posit',
@level2type = N'Column', @level2name = 'AC_ID_subset';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_subset_PN_of_Posit',
@level2type = N'Column', @level2name = 'PN_ID_of';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The person who is the actor.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_subset_PN_of_Posit',
@level2type = N'Column', @level2name = 'PN_ID_of';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'EV_in_AC_wasCast_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The actors that were cast in an event, meaning those who performed at that performance.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'EV_in_AC_wasCast_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'EV_in_AC_wasCast_Posit',
@level2type = N'Column', @level2name = 'EV_ID_in';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The event the actor was cast in.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'EV_in_AC_wasCast_Posit',
@level2type = N'Column', @level2name = 'EV_ID_in';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'EV_in_AC_wasCast_Posit',
@level2type = N'Column', @level2name = 'AC_ID_wasCast';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
An actor cast in the event.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'EV_in_AC_wasCast_Posit',
@level2type = N'Column', @level2name = 'AC_ID_wasCast';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit',
@level2type = N'Column', @level2name = 'AC_ID_part';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The actor having a part in the program.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit',
@level2type = N'Column', @level2name = 'AC_ID_part';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit',
@level2type = N'Column', @level2name = 'PR_ID_in';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The program the actor has a part in.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit',
@level2type = N'Column', @level2name = 'PR_ID_in';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit',
@level2type = N'Column', @level2name = 'RAT_ID_got';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The rating the actor got for the part.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_part_PR_in_RAT_got_Posit',
@level2type = N'Column', @level2name = 'RAT_ID_got';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'ST_at_PR_isPlaying_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'ST_at_PR_isPlaying_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'ST_at_PR_isPlaying_Posit',
@level2type = N'Column', @level2name = 'ST_ID_at';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The stage where the program is playing.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'ST_at_PR_isPlaying_Posit',
@level2type = N'Column', @level2name = 'ST_ID_at';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'ST_at_PR_isPlaying_Posit',
@level2type = N'Column', @level2name = 'PR_ID_isPlaying';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The program playing at the stage.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'ST_at_PR_isPlaying_Posit',
@level2type = N'Column', @level2name = 'PR_ID_isPlaying';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Parent-child relationships between actors, along with the type of parental relationship.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit',
@level2type = N'Column', @level2name = 'AC_ID_parent';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The actor who is the parent.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit',
@level2type = N'Column', @level2name = 'AC_ID_parent';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit',
@level2type = N'Column', @level2name = 'AC_ID_child';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The actor who is the child.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit',
@level2type = N'Column', @level2name = 'AC_ID_child';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit',
@level2type = N'Column', @level2name = 'PAT_ID_having';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The type of parental relationship.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'AC_parent_AC_child_PAT_having_Posit',
@level2type = N'Column', @level2name = 'PAT_ID_having';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit',
@level2type = N'Column', @level2name = 'PR_ID_content';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The program that made up the content of the event.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit',
@level2type = N'Column', @level2name = 'PR_ID_content';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit',
@level2type = N'Column', @level2name = 'ST_ID_location';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The stage where the event was located.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit',
@level2type = N'Column', @level2name = 'ST_ID_location';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit',
@level2type = N'Column', @level2name = 'EV_ID_of';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The event.
',
@level0type = N'Schema', @level0name = 'ties',
@level1type = N'Table', @level1name = 'PR_content_ST_location_EV_of_Posit',
@level2type = N'Column', @level2name = 'EV_ID_of';
GO
