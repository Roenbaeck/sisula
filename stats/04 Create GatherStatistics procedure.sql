
IF OBJECT_ID('stats._GatherStatistics') IS NOT NULL
DROP PROC stats._GatherStatistics;
GO

/*
	This procedure calculates measures used as indicators of how a database
	is growing over time. It lends heavily from thinking found in RFM-models
	(Recency, Frequency, Monetary).

	RUNNING: 
	EXEC stats._GatherStatistics DEFAULT;

	RESULTS:
	SELECT * FROM stats.lGC_GatheredConstruct;

*/
CREATE PROC stats._GatherStatistics (
	@Metadata_Id int = 0
)
AS
BEGIN
	-- is used to determine when things are within normal deviations
	declare @normalDeviationPercentage float = 0.01; -- = 1%
	-- is used to determine when growth passes from delayed to overdue
	declare @overdueThresholdPercentage float = 1.00; -- = 100%
	-- number of allowed standard deviatons before something is trending heavily
	declare @numberOfStandardDeviations float = 2.00; -- = 2σ
	-- when the gathering of statistics is done
	declare @gatheringTime datetime = getdate();

	if OBJECT_ID('tempdb..#schemas') is not null
	drop table #schemas;

	select s.[name]
	into #schemas
	from sys.tables t 
	join sys.schemas s
		on s.[schema_id] = t.[schema_id]
	where t.[name] = '_Schema'
		and s.[name] <> 'stats'; -- do not gather statistics from stats

	if OBJECT_ID('tempdb..#constructs') is not null
	drop table #constructs;

	create table #constructs (
		[GC_ID] int null,
		[capsule] nvarchar(128) not null,
		[name] nvarchar(128) not null,
		[type] char(1) not null,
		primary key (
			[capsule],
			[name]
		)
	)
	
	declare @schema nvarchar(128);
	declare schemaNames cursor for (
		select [name] from #schemas
	);
	open schemaNames;
	fetch next from schemaNames into @schema;

	declare @sql varchar(max);
	while(@@FETCH_STATUS = 0)
	begin
		set @sql = '
		insert into #constructs (
			[name],
			[capsule],
			[type]
		)
		select distinct [name], [capsule], ''A'' as [type] from ' + @schema + '._Anchor 
		union all
		select distinct [name], [capsule], ''B'' as [type] from ' + @schema + '._Attribute 
		union all
		select distinct [name], [capsule], ''K'' as [type] from ' + @schema + '._Knot 
		union all
		select distinct [name], [capsule], ''T'' as [type] from ' + @schema + '._Tie;
		';

		EXEC(@sql);

		fetch next from schemaNames into @schema;
	end

	close schemaNames;
	deallocate schemaNames;

	update c 
	set
		c.GC_ID = nk.GC_ID
	from #constructs c
	join stats.key_GC_ConstructName nk
	  on nk.GC_CAP_GatheredConstruct_Capsule = c.[capsule]
	 and nk.GC_NAM_GatheredConstruct_Name = c.[name];		

	insert into stats.lGC_GatheredConstruct (
		 [GC_LGT_ChangedAt], 
		 [GC_LGT_GatheredConstruct_LatestGatheringTime],
		 [GC_ID], 
		 [Metadata_GC], 
		 [GC_NAM_GatheredConstruct_Name], 
		 [GC_CAP_GatheredConstruct_Capsule], 
		 [GC_TYP_TYP_ID], 
		 [GC_ROC_ChangedAt], 
		 [GC_ROC_GatheredConstruct_RowCount], 
		 [GC_UMB_ChangedAt], 
		 [GC_UMB_GatheredConstruct_UsedMegabytes], 
		 [GC_AMB_ChangedAt], 
		 [GC_AMB_GatheredConstruct_AllocatedMegabytes]
	)
	select
		 @gatheringTime,
		 @gatheringTime,
		 c.GC_ID,
		 @Metadata_Id,
		 c.[name],
		 c.[capsule],
		 c.[type],
		 @gatheringTime,	
		 MAX(p.[rows]),
		 @gatheringTime,	
		 CAST(ROUND((SUM(a.used_pages) / 128.00), 2) AS decimal(19,2)),
		 @gatheringTime,	
		 CAST(ROUND((SUM(a.total_pages) / 128.00), 2) AS decimal(19,2))
	from #constructs c
	join sys.tables t
	  on t.[name] = c.[name]
	JOIN sys.schemas s 
	  ON s.[schema_id] = t.[schema_id]
	 AND s.[name] = c.[capsule]
	JOIN sys.indexes i 
	  ON i.[object_id] = t.[object_id] 
	JOIN sys.partitions p 
	  ON p.[object_id] = t.[object_id] 
	 AND p.[index_id] = i.[index_id] 
	JOIN sys.allocation_units a 
	  ON a.[container_id] = p.[partition_id]
	GROUP BY
		 c.GC_ID,
		 c.[capsule],
		 c.[name],
		 c.[type];

	declare @n int = 4; -- current and 3 previous

	insert into stats.lGC_GatheredConstruct (
		GC_ID,
		[Metadata_GC], 
		GC_RGR_ChangedAt,
		GC_RGR_GatheredConstruct_RowGrowth,
		GC_RGN_ChangedAt,
		GC_RGN_GatheredConstruct_RowGrowthNormal, 
		GC_RGI_ChangedAt,
		GC_RGI_GatheredConstruct_RowGrowthInterval,
		GC_RGD_ChangedAt, 
		GC_RGD_GatheredConstruct_RowGrowthDeviation
	)
	SELECT
		GC_ID,
		@Metadata_Id,
		@gatheringTime,
		MAX(CASE WHEN Latest = 1 THEN Growth END),
		@gatheringTime,
		MAX(MedianGrowth), 
		@gatheringTime, 
		AVG(Interval),
		@gatheringTime, 
		STDEVP(Growth)
	FROM (
		SELECT
			ROC.GC_ROC_GC_ID as GC_ID,
			CASE WHEN ROC.GC_ROC_ChangedAt = window.GC_ROC_ChangedAt THEN 1 END as Latest,
			window.GC_ROC_GatheredConstruct_RowCount - window.PreviousValue as Growth,
			PERCENTILE_CONT(0.5) WITHIN GROUP (
				ORDER BY CASE 
					WHEN window.GC_ROC_ChangedAt < ROC.GC_ROC_ChangedAt 
					THEN window.GC_ROC_GatheredConstruct_RowCount - window.PreviousValue
				END) OVER (
					PARTITION BY window.GC_ROC_GC_ID
			) AS MedianGrowth, 
			DATEDIFF(s, window.PreviousChangedAt, window.GC_ROC_ChangedAt) as Interval
		FROM stats.GC_ROC_GatheredConstruct_RowCount ROC
		OUTER APPLY (
			SELECT 
				*, 
				LAG(ROC_n.GC_ROC_GatheredConstruct_RowCount) OVER (
					PARTITION BY ROC_n.GC_ROC_GC_ID 
					ORDER BY ROC_n.GC_ROC_ChangedAt
				) as PreviousValue,
				LAG(ROC_n.GC_ROC_ChangedAt) OVER (
					PARTITION BY ROC_n.GC_ROC_GC_ID 
					ORDER BY ROC_n.GC_ROC_ChangedAt
				) as PreviousChangedAt
			FROM stats.GC_ROC_GatheredConstruct_RowCount ROC_n
			WHERE ROC_n.GC_ROC_GC_ID = ROC.GC_ROC_GC_ID
			  AND ROC_n.GC_ROC_ChangedAt <= ROC.GC_ROC_ChangedAt
			ORDER BY ROC_n.GC_ROC_ChangedAt DESC
			OFFSET 0 ROWS
			FETCH FIRST (@n) ROWS ONLY 
		) window
		WHERE ROC.GC_ROC_ChangedAt = @gatheringTime
	) calc
	GROUP BY
		GC_ID;

	insert into stats.lGC_GatheredConstruct (
		GC_ID,
		[Metadata_GC], 
		GC_UGR_ChangedAt,
		GC_UGR_GatheredConstruct_UsedGrowth,
		GC_UGN_ChangedAt,
		GC_UGN_GatheredConstruct_UsedGrowthNormal,
		GC_UGI_ChangedAt,
		GC_UGI_GatheredConstruct_UsedGrowthInterval,
		GC_UGD_ChangedAt, 
		GC_UGD_GatheredConstruct_UsedGrowthDeviation
	)
	SELECT
		GC_ID,
		@Metadata_Id,
		@gatheringTime,
		MAX(CASE WHEN Latest = 1 THEN Growth END),
		@gatheringTime,
		MAX(MedianGrowth), 
		@gatheringTime, 
		AVG(Interval),
		@gatheringTime, 
		STDEVP(Growth)
	FROM (
		SELECT
			UMB.GC_UMB_GC_ID as GC_ID,
			CASE WHEN UMB.GC_UMB_ChangedAt = window.GC_UMB_ChangedAt THEN 1 END as Latest,
			window.GC_UMB_GatheredConstruct_UsedMegabytes - window.PreviousValue as Growth,
			PERCENTILE_CONT(0.5) WITHIN GROUP (
				ORDER BY CASE 
					WHEN window.GC_UMB_ChangedAt < UMB.GC_UMB_ChangedAt 
					THEN window.GC_UMB_GatheredConstruct_UsedMegabytes - window.PreviousValue
				END) OVER (
					PARTITION BY window.GC_UMB_GC_ID
			) AS MedianGrowth, 
			DATEDIFF(s, window.PreviousChangedAt, window.GC_UMB_ChangedAt) as Interval
		FROM stats.GC_UMB_GatheredConstruct_UsedMegabytes UMB
		OUTER APPLY (
			SELECT 
				*, 
				LAG(UMB_n.GC_UMB_GatheredConstruct_UsedMegabytes) OVER (
					PARTITION BY UMB_n.GC_UMB_GC_ID 
					ORDER BY UMB_n.GC_UMB_ChangedAt
				) as PreviousValue,
				LAG(UMB_n.GC_UMB_ChangedAt) OVER (
					PARTITION BY UMB_n.GC_UMB_GC_ID 
					ORDER BY UMB_n.GC_UMB_ChangedAt
				) as PreviousChangedAt
			FROM stats.GC_UMB_GatheredConstruct_UsedMegabytes UMB_n
			WHERE UMB_n.GC_UMB_GC_ID = UMB.GC_UMB_GC_ID
			  AND UMB_n.GC_UMB_ChangedAt <= UMB.GC_UMB_ChangedAt
			ORDER BY UMB_n.GC_UMB_ChangedAt DESC
			OFFSET 0 ROWS
			FETCH FIRST (@n) ROWS ONLY 
		) window
		WHERE UMB.GC_UMB_ChangedAt = @gatheringTime
	) calc
	GROUP BY
		GC_ID;

	insert into stats.lGC_GatheredConstruct (
		GC_ID,
		[Metadata_GC], 
		GC_AGR_ChangedAt,
		GC_AGR_GatheredConstruct_AllocatedGrowth,
		GC_AGN_ChangedAt,
		GC_AGN_GatheredConstruct_AllocatedGrowthNormal,
		GC_AGI_ChangedAt,
		GC_AGI_GatheredConstruct_AllocatedGrowthInterval,
		GC_AGD_ChangedAt,
		GC_AGD_GatheredConstruct_AllocatedGrowthDeviation
	)
	SELECT
		GC_ID,
		@Metadata_Id,
		@gatheringTime,
		MAX(CASE WHEN Latest = 1 THEN Growth END),
		@gatheringTime,
		MAX(MedianGrowth), 
		@gatheringTime, 
		AVG(Interval),
		@gatheringTime, 
		STDEVP(Growth)
	FROM (
		SELECT
			AMB.GC_AMB_GC_ID as GC_ID,
			CASE WHEN AMB.GC_AMB_ChangedAt = window.GC_AMB_ChangedAt THEN 1 END as Latest,
			window.GC_AMB_GatheredConstruct_AllocatedMegabytes - window.PreviousValue as Growth,
			PERCENTILE_CONT(0.5) WITHIN GROUP (
				ORDER BY CASE 
					WHEN window.GC_AMB_ChangedAt < AMB.GC_AMB_ChangedAt 
					THEN window.GC_AMB_GatheredConstruct_AllocatedMegabytes - window.PreviousValue
				END) OVER (
					PARTITION BY window.GC_AMB_GC_ID
			) AS MedianGrowth, 
			DATEDIFF(s, window.PreviousChangedAt, window.GC_AMB_ChangedAt) as Interval
		FROM stats.GC_AMB_GatheredConstruct_AllocatedMegabytes AMB
		OUTER APPLY (
			SELECT 
				*, 
				LAG(AMB_n.GC_AMB_GatheredConstruct_AllocatedMegabytes) OVER (
					PARTITION BY AMB_n.GC_AMB_GC_ID 
					ORDER BY AMB_n.GC_AMB_ChangedAt
				) as PreviousValue,
				LAG(AMB_n.GC_AMB_ChangedAt) OVER (
					PARTITION BY AMB_n.GC_AMB_GC_ID 
					ORDER BY AMB_n.GC_AMB_ChangedAt
				) as PreviousChangedAt
			FROM stats.GC_AMB_GatheredConstruct_AllocatedMegabytes AMB_n
			WHERE AMB_n.GC_AMB_GC_ID = AMB.GC_AMB_GC_ID
			  AND AMB_n.GC_AMB_ChangedAt <= AMB.GC_AMB_ChangedAt
			ORDER BY AMB_n.GC_AMB_ChangedAt DESC
			OFFSET 0 ROWS
			FETCH FIRST (@n) ROWS ONLY 
		) window
		WHERE AMB.GC_AMB_ChangedAt = @gatheringTime
	) calc
	GROUP BY
		GC_ID;

	insert into stats.lGC_GatheredConstruct (
		GC_ID,
		[Metadata_GC], 
		GC_RGT_ChangedAt,
		GC_RGT_TRE_Trend, 
		GC_UGT_ChangedAt, 
		GC_UGT_TRE_Trend,
		GC_AGT_ChangedAt, 
		GC_AGT_TRE_Trend,
		GC_RGS_ChangedAt, 
		GC_RGS_SYN_Sync,
		GC_UGS_ChangedAt,
		GC_UGS_SYN_Sync,
		GC_AGS_ChangedAt,
		GC_AGS_SYN_Sync
	)
	select
		GC_ID,
		@Metadata_Id,
		@gatheringTime,
		case
			when GC_RGR_GatheredConstruct_RowGrowth between GC_RGN_GatheredConstruct_RowGrowthNormal - RowGrowthPercentage and GC_RGN_GatheredConstruct_RowGrowthNormal + RowGrowthPercentage then '0'
			when GC_RGR_GatheredConstruct_RowGrowth > GC_RGN_GatheredConstruct_RowGrowthNormal + RowGrowthPercentage + @numberOfStandardDeviations * GC_RGD_GatheredConstruct_RowGrowthDeviation then '++'
			when GC_RGR_GatheredConstruct_RowGrowth > GC_RGN_GatheredConstruct_RowGrowthNormal + RowGrowthPercentage then '+'
			when GC_RGR_GatheredConstruct_RowGrowth < GC_RGN_GatheredConstruct_RowGrowthNormal - RowGrowthPercentage - @numberOfStandardDeviations * GC_RGD_GatheredConstruct_RowGrowthDeviation then '--'
			when GC_RGR_GatheredConstruct_RowGrowth < GC_RGN_GatheredConstruct_RowGrowthNormal - RowGrowthPercentage then '-'
		end as GC_RGD_GatheredConstruct_RowGrowthTrend,
		@gatheringTime,
		case
			when GC_UGR_GatheredConstruct_UsedGrowth between GC_UGN_GatheredConstruct_UsedGrowthNormal - UsedGrowthPercentage and GC_UGN_GatheredConstruct_UsedGrowthNormal + UsedGrowthPercentage then '0'
			when GC_UGR_GatheredConstruct_UsedGrowth > GC_UGN_GatheredConstruct_UsedGrowthNormal + UsedGrowthPercentage + @numberOfStandardDeviations * GC_UGD_GatheredConstruct_UsedGrowthDeviation then '++'
			when GC_UGR_GatheredConstruct_UsedGrowth > GC_UGN_GatheredConstruct_UsedGrowthNormal + UsedGrowthPercentage then '+'
			when GC_UGR_GatheredConstruct_UsedGrowth < GC_UGN_GatheredConstruct_UsedGrowthNormal - UsedGrowthPercentage - @numberOfStandardDeviations * GC_UGD_GatheredConstruct_UsedGrowthDeviation then '--'
			when GC_UGR_GatheredConstruct_UsedGrowth < GC_UGN_GatheredConstruct_UsedGrowthNormal - UsedGrowthPercentage then '-'
		end as GC_UGR_GatheredConstruct_UsedGrowthTrend,
		@gatheringTime,
		case
			when GC_AGR_GatheredConstruct_AllocatedGrowth between GC_AGN_GatheredConstruct_AllocatedGrowthNormal - AllocatedGrowthPercentage and GC_AGN_GatheredConstruct_AllocatedGrowthNormal + AllocatedGrowthPercentage then '0'
			when GC_AGR_GatheredConstruct_AllocatedGrowth > GC_AGN_GatheredConstruct_AllocatedGrowthNormal + AllocatedGrowthPercentage + @numberOfStandardDeviations * GC_AGD_GatheredConstruct_AllocatedGrowthDeviation then '++'
			when GC_AGR_GatheredConstruct_AllocatedGrowth > GC_AGN_GatheredConstruct_AllocatedGrowthNormal + AllocatedGrowthPercentage then '+'
			when GC_AGR_GatheredConstruct_AllocatedGrowth < GC_AGN_GatheredConstruct_AllocatedGrowthNormal - AllocatedGrowthPercentage - @numberOfStandardDeviations * GC_AGD_GatheredConstruct_AllocatedGrowthDeviation then '--'
			when GC_AGR_GatheredConstruct_AllocatedGrowth < GC_AGN_GatheredConstruct_AllocatedGrowthNormal - AllocatedGrowthPercentage then '-'
		end as GC_AGR_GatheredConstruct_AllocatedGrowthTrend,
		@gatheringTime,
		case 
			when datediff(s, GC_RGR_ChangedAt, @gatheringTime) < RowGrowthTimeToDelay then 'Arrived'
			when datediff(s, GC_RGR_ChangedAt, @gatheringTime) between RowGrowthTimeToDelay and RowGrowthTimeToOverdue then 'Delayed'
			when datediff(s, GC_RGR_ChangedAt, @gatheringTime) > RowGrowthTimeToOverdue then 'Overdue'
		end,
		@gatheringTime,
		case 
			when datediff(s, GC_UGR_ChangedAt, @gatheringTime) < UsedGrowthTimeToDelay then 'Arrived'
			when datediff(s, GC_UGR_ChangedAt, @gatheringTime) between UsedGrowthTimeToDelay and UsedGrowthTimeToOverdue then 'Delayed'
			when datediff(s, GC_UGR_ChangedAt, @gatheringTime) > UsedGrowthTimeToOverdue then 'Overdue'
		end,
		@gatheringTime,
		case 
			when datediff(s, GC_AGR_ChangedAt, @gatheringTime) < AllocatedGrowthTimeToDelay then 'Arrived'
			when datediff(s, GC_AGR_ChangedAt, @gatheringTime) between AllocatedGrowthTimeToDelay and AllocatedGrowthTimeToOverdue then 'Delayed'
			when datediff(s, GC_AGR_ChangedAt, @gatheringTime) > AllocatedGrowthTimeToOverdue then 'Overdue'
		end
	from	
		stats.lGC_GatheredConstruct
	outer apply (
		values (
			@normalDeviationPercentage * GC_RGN_GatheredConstruct_RowGrowthNormal,
			@normalDeviationPercentage * GC_UGN_GatheredConstruct_UsedGrowthNormal,
			@normalDeviationPercentage * GC_AGN_GatheredConstruct_AllocatedGrowthNormal, 
			GC_RGI_GatheredConstruct_RowGrowthInterval + @normalDeviationPercentage * GC_RGI_GatheredConstruct_RowGrowthInterval,
			GC_UGI_GatheredConstruct_UsedGrowthInterval + @normalDeviationPercentage * GC_UGI_GatheredConstruct_UsedGrowthInterval,
			GC_AGI_GatheredConstruct_AllocatedGrowthInterval + @normalDeviationPercentage * GC_AGI_GatheredConstruct_AllocatedGrowthInterval,
			GC_RGI_GatheredConstruct_RowGrowthInterval + @overdueThresholdPercentage * GC_RGI_GatheredConstruct_RowGrowthInterval,
			GC_UGI_GatheredConstruct_UsedGrowthInterval + @overdueThresholdPercentage * GC_UGI_GatheredConstruct_UsedGrowthInterval,
			GC_AGI_GatheredConstruct_AllocatedGrowthInterval + @overdueThresholdPercentage * GC_AGI_GatheredConstruct_AllocatedGrowthInterval
		)
	) v (
		RowGrowthPercentage,
		UsedGrowthPercentage,
		AllocatedGrowthPercentage, 
		RowGrowthTimeToDelay,
		UsedGrowthTimeToDelay,
		AllocatedGrowthTimeToDelay,
		RowGrowthTimeToOverdue,
		UsedGrowthTimeToOverdue,
		AllocatedGrowthTimeToOverdue
	);

END
