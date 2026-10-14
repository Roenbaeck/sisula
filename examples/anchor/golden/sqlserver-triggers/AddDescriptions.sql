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
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, with identifiers and a knotted value role, restatable.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade',
@level2type = N'Column', @level2name = 'SU_ID_holder';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade',
@level2type = N'Column', @level2name = 'SU_ID_holder';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade',
@level2type = N'Column', @level2name = 'OB_ID_item';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Something the subject has or keeps.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade',
@level2type = N'Column', @level2name = 'OB_ID_item';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade',
@level2type = N'Column', @level2name = 'GRD_ID_grade';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
A grade, used by knotted attributes and by the value roles of ties.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_holder_OB_item_GRD_grade',
@level2type = N'Column', @level2name = 'GRD_ID_grade';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, with identifiers and a knotted value role, idempotent and not assertive.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank',
@level2type = N'Column', @level2name = 'SU_ID_keeper';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank',
@level2type = N'Column', @level2name = 'SU_ID_keeper';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank',
@level2type = N'Column', @level2name = 'OB_ID_thing';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Something the subject has or keeps.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank',
@level2type = N'Column', @level2name = 'OB_ID_thing';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank',
@level2type = N'Column', @level2name = 'GRD_ID_rank';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
A grade, used by knotted attributes and by the value roles of ties.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_keeper_OB_thing_GRD_rank',
@level2type = N'Column', @level2name = 'GRD_ID_rank';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static, with an identifier and a value role: each object has one owner.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner',
@level2type = N'Column', @level2name = 'OB_ID_part';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Something the subject has or keeps.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner',
@level2type = N'Column', @level2name = 'OB_ID_part';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner',
@level2type = N'Column', @level2name = 'SU_ID_owner';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_part_SU_owner',
@level2type = N'Column', @level2name = 'SU_ID_owner';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, without identifiers.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with',
@level2type = N'Column', @level2name = 'SU_ID_partner';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with',
@level2type = N'Column', @level2name = 'SU_ID_partner';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with',
@level2type = N'Column', @level2name = 'SU_ID_with';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
The subject of the tests.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_partner_SU_with',
@level2type = N'Column', @level2name = 'SU_ID_with';
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
An event, with an attribute of its own.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_Event';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_QTY_Event_Quantity';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static, as the attributes of a nexus are.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'EV_QTY_Event_Quantity';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NAM_Subject_Name';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NAM_Subject_Name';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_COD_Subject_Code';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static and idempotent.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_COD_Subject_Code';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_GRD_Subject_Grade';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static and knotted.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_GRD_Subject_Grade';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NOT_Subject_Note';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static, with a checksum.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_NOT_Subject_Note';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TTL_Subject_Title';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, restatable.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TTL_Subject_Title';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_STA_Subject_State';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, not restatable: a restatement is an error.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_STA_Subject_State';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LBL_Subject_Label';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, not restatable and idempotent: a restatement is skipped.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LBL_Subject_Label';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TAG_Subject_Tag';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, restatable and idempotent: a restatement is skipped.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TAG_Subject_Tag';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LVL_Subject_Level';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized and knotted.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_LVL_Subject_Level';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TXT_Subject_Text';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, with a checksum.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_TXT_Subject_Text';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ASR_Subject_Assessment';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized, not assertive: a re-assertion is skipped (bitemporal and concurrent-reliance-temporal).
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ASR_Subject_Assessment';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ERS_Subject_Erasable';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Historized and deletable (uni-temporal).
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'SU_ERS_Subject_Erasable';
GO
BEGIN TRY
EXEC sp_dropextendedproperty
@name = N'MS_Description',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_NAM_Object_Name';
END TRY BEGIN CATCH BEGIN TRY ROLLBACK END TRY BEGIN CATCH END CATCH END CATCH -- workaround for MS bug 658556
EXEC sp_addextendedproperty
@name = N'MS_Description',
@value = '
Static.
',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table', @level1name = 'OB_NAM_Object_Name';
GO
