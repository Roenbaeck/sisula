<?xml version="1.0" ?>
<!--

	Lars Rönnbäck, 2015

	This transform can be used to migrate source system descriptions from the old
	Intellibis/Affecto ETL framework to the new sisula framework.

	USAGE
	Remove the namespace declaration from the old description before applying the
	transform.

-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
	<xsl:template match="/system">
		<xsl:for-each select="physicalFile">
			<source name="{name}" codepage="{characterMap}" datafiletype="{characterType}" fieldterminator="\r\n" rowlength="1000" split="regex">
				<description>
					<xsl:text>Source directory should be defined in the workflow: </xsl:text>
					<xsl:value-of select="parent::system/directory"/>\<xsl:value-of select="subdirectory"/>\<xsl:value-of select="pattern"/>
				</description>
				<xsl:for-each select="logicalFile">
					<part name="{name}">
						<xsl:if test="@nulls and not(@nulls = '')">
							<xsl:attribute name="nulls">
								<xsl:value-of select="parent::physicalFile/@nulls"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="number(parent::physicalFile/@skip) > 0">
							<xsl:text>&#10;SELECT * from %System%_</xsl:text>
							<xsl:value-of select="parent::physicalFile/name"/>
							<xsl:text>_Raw WHERE _id > </xsl:text>
							<xsl:value-of select="parent::physicalFile/@skip"/>
							<xsl:text>&#10;</xsl:text>
						</xsl:if>
						<xsl:for-each select="term">
							<term name="{name}" format="{format}">
								<xsl:choose>
									<xsl:when test="number(size) > 0">
										<xsl:attribute name="size">
											<xsl:value-of select="size"/>
										</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="delimiter">^;</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:if test="@nulls and not(@nulls = '')">
									<xsl:attribute name="nulls">
										<xsl:value-of select="@nulls"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:if test="string-length(normalize-space(expression)) > 0">
									<xsl:value-of select="normalize-space(expression)"/>
								</xsl:if>
							</term>
						</xsl:for-each>
						<xsl:for-each select="calculation">
							<calculation name="{name}" format="{format}" persisted="false">
								<xsl:value-of select="expression"/>
							</calculation>
						</xsl:for-each>
						<xsl:if test="count(term[type = 'identifier']) > 0">
							<key name="pk{name}" type="primary key">
								<xsl:for-each select="term[type = 'identifier']">
									<xsl:sort data-type="number" order="ascending" select="ordinal"/>
									<component of="{name}"/>
								</xsl:for-each>
							</key>
						</xsl:if>
					</part>
				</xsl:for-each>
			</source>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
