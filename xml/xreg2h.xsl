<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:template match="/xregister">
        <xsl:text/>/*************************************<xsl:call-template name="new.line"/>
        <xsl:text/>    NOTE: Values are byte offset<xsl:call-template name="new.line"/>
        <xsl:text/>**************************************/<xsl:call-template name="new.line"/>
        <xsl:call-template name="new.line"/>
        
        <xsl:text/>#ifndef __<xsl:value-of select="name"/>_h__<xsl:call-template name="new.line"/>
        <xsl:text/>#define __<xsl:value-of select="name"/>_h__<xsl:call-template name="new.line"/>
        <xsl:call-template name="new.line"/>
        
        <xsl:for-each select="word">
            <xsl:text/>#define <xsl:value-of select="name"/><xsl:text> </xsl:text><xsl:value-of select="address * /xregister/dwidth div 8"/><xsl:call-template name="new.line"/>
        </xsl:for-each>        
        
        <xsl:call-template name="new.line"/>
        <xsl:text/>#endif<xsl:call-template name="new.line"/>        
    </xsl:template>

    <xsl:template name="new.line">
        <xsl:text>&#xD;</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>