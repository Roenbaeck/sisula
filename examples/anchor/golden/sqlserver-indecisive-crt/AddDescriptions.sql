-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'GRD_Grade';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
A grade, used by knotted attributes and by the value roles of ties.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'GRD_Grade';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_Subject';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_Subject';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NAM_Subject_Name_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NAM_Subject_Name_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_COD_Subject_Code_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static and idempotent.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_COD_Subject_Code_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_GRD_Subject_Grade_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static and knotted.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_GRD_Subject_Grade_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NOT_Subject_Note_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static, with a checksum.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NOT_Subject_Note_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TTL_Subject_Title_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, restatable.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TTL_Subject_Title_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_STA_Subject_State_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, not restatable: a restatement is an error.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_STA_Subject_State_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LBL_Subject_Label_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, not restatable and idempotent: a restatement is skipped.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LBL_Subject_Label_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TAG_Subject_Tag_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, restatable and idempotent: a restatement is skipped.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TAG_Subject_Tag_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LVL_Subject_Level_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized and knotted.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LVL_Subject_Level_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TXT_Subject_Text_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, with a checksum.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TXT_Subject_Text_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ASR_Subject_Assessment_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, not assertive: a re-assertion is skipped (bitemporal and concurrent-reliance-temporal).
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ASR_Subject_Assessment_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ERS_Subject_Erasable_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized and deletable (uni-temporal).
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ERS_Subject_Erasable_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_Object';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Something the subject has or keeps.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_Object';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_NAM_Object_Name_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_NAM_Object_Name_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
An event, with attributes of its own, a static one and a historized one.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_QTY_Event_Quantity_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_QTY_Event_Quantity_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_PLC_Event_Place_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized and not restatable, as an attribute of an anchor may be.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_PLC_Event_Place_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event',
@level2type = N'Column', @level2name = 'SU_ID_for';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject the event is for.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event',
@level2type = N'Column', @level2name = 'SU_ID_for';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, with identifiers and a knotted value role, restatable.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit',
@level2type = N'Column', @level2name = 'SU_ID_holder';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit',
@level2type = N'Column', @level2name = 'SU_ID_holder';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit',
@level2type = N'Column', @level2name = 'OB_ID_item';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Something the subject has or keeps.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit',
@level2type = N'Column', @level2name = 'OB_ID_item';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit',
@level2type = N'Column', @level2name = 'GRD_ID_grade';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
A grade, used by knotted attributes and by the value roles of ties.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade_Posit',
@level2type = N'Column', @level2name = 'GRD_ID_grade';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, with identifiers and a knotted value role, idempotent and not assertive.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit',
@level2type = N'Column', @level2name = 'SU_ID_keeper';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit',
@level2type = N'Column', @level2name = 'SU_ID_keeper';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit',
@level2type = N'Column', @level2name = 'OB_ID_thing';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Something the subject has or keeps.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit',
@level2type = N'Column', @level2name = 'OB_ID_thing';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit',
@level2type = N'Column', @level2name = 'GRD_ID_rank';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
A grade, used by knotted attributes and by the value roles of ties.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank_Posit',
@level2type = N'Column', @level2name = 'GRD_ID_rank';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static, with an identifier and a value role: each object has one owner.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner_Posit',
@level2type = N'Column', @level2name = 'OB_ID_part';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Something the subject has or keeps.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner_Posit',
@level2type = N'Column', @level2name = 'OB_ID_part';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner_Posit',
@level2type = N'Column', @level2name = 'SU_ID_owner';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner_Posit',
@level2type = N'Column', @level2name = 'SU_ID_owner';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with_Posit';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, without identifiers.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with_Posit';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with_Posit',
@level2type = N'Column', @level2name = 'SU_ID_partner';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with_Posit',
@level2type = N'Column', @level2name = 'SU_ID_partner';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with_Posit',
@level2type = N'Column', @level2name = 'SU_ID_with';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with_Posit',
@level2type = N'Column', @level2name = 'SU_ID_with';
GO
