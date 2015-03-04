<?xml version="1.0" ?>
<!--

	Lars Rönnbäck, 2015

	This transform can be used to migrate job descriptions from the old
	Intellibis/Affecto ETL framework to the new sisula framework.
	
	USAGE
	Remove the namespace declaration from the old description before applying the
	transform.
	
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
	<xsl:key name="dependencies" match="//dependency" use="@reference"/>
	<xsl:template match="/job">
		<xsl:variable name="jobName" select="@name"/>
		<workflow name="Converted Workflow">
			<!-- enumeration of on_success_action codes -->
			<variable name="quitWithSuccess" value="1"/>
			<variable name="quitWithFailure" value="2"/>
			<variable name="goToTheNextStep" value="3"/>
			<variable name="goToStepWithId" value="4"/>
			<xsl:for-each select=".//job[not(dependency) and @type]">
				<job name="{$jobName}">
					<xsl:comment>
						<xsl:value-of select="@name"/>
						<xsl:text> is an independent jobstep</xsl:text>
					</xsl:comment>
					<xsl:apply-templates select="."/>
					<xsl:if test="key('dependencies', @name)">
						<xsl:apply-templates select="key('dependencies', @name)/.."/>
					</xsl:if>
				</job>
			</xsl:for-each>
		</workflow>
	</xsl:template>
	<xsl:template match="job">
		<xsl:if test="dependency">
			<xsl:comment>
				<xsl:value-of select="@name"/>
				<xsl:text> depends on: </xsl:text>
				<xsl:value-of select="dependency/@reference"/>
			</xsl:comment>
		</xsl:if>
		<jobstep name="{@name}" database_name="%stage%" on_success_action="%goToTheNextStep%">
			<xsl:choose>
				<xsl:when test="@type = 'SP'">
					<xsl:attribute name="subsystem">TSQL</xsl:attribute>
					<xsl:text>EXEC </xsl:text>
					<xsl:value-of select="@script"/>
				</xsl:when>
			</xsl:choose>
		</jobstep>
		<xsl:if test="key('dependencies', @name)">
			<xsl:apply-templates select="key('dependencies', @name)/.."/>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
