<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:template match="/xregister">
        <xsl:text>block </xsl:text><xsl:value-of select="name"/> {<xsl:call-template name="new.line"/>
        <xsl:text>  bytes </xsl:text><xsl:value-of select="dwidth div 8 * count(word)"/><xsl:call-template name="punc.new.line"/>
        <xsl:call-template name="new.line"/>
        
        <xsl:for-each select="word">
            <xsl:text>  register </xsl:text><xsl:value-of select="name"/> {<xsl:call-template name="new.line"/>
            <xsl:text>    bytes </xsl:text><xsl:value-of select="/xregister/dwidth div 8"/><xsl:call-template name="punc.new.line"/>
            <xsl:for-each select="reg">
                <xsl:text>    field </xsl:text><xsl:value-of select="name"/> @<xsl:value-of select="offset"/> {<xsl:call-template name="new.line"/>
                <xsl:if test="comment">
                    <xsl:text>      doc {</xsl:text><xsl:value-of select="comment"/>}<xsl:call-template name="new.line"/>
                </xsl:if>
                <xsl:text>      bits </xsl:text><xsl:value-of select="width"/><xsl:call-template name="punc.new.line"/>
                <xsl:text>      reset </xsl:text><xsl:value-of select="reset.value"/><xsl:call-template name="punc.new.line"/>
                <xsl:text>      access </xsl:text>
                <xsl:choose>
                    <xsl:when test="sw.read.write"><xsl:text>rw</xsl:text></xsl:when>
                    <xsl:when test="sw.read.only.clear"><xsl:text>rc</xsl:text></xsl:when>
                    <xsl:when test="sw.read.only.write.1.clear"><xsl:text>w1c</xsl:text></xsl:when>
                    <xsl:otherwise><xsl:text>ro</xsl:text></xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="punc.new.line"/>
                <xsl:text>    }</xsl:text><xsl:call-template name="new.line"/>
                <xsl:call-template name="new.line"/>
            </xsl:for-each>            
            <xsl:text>  }</xsl:text><xsl:call-template name="new.line"/>
        </xsl:for-each>
        
        <xsl:text>}</xsl:text><xsl:call-template name="new.line"/>               
    </xsl:template>
    
    
    <xsl:template name="punc.new.line">
        <xsl:text>;&#xD;</xsl:text>
    </xsl:template>
    
    <xsl:template name="new.line">
        <xsl:text>&#xD;</xsl:text>
    </xsl:template>

</xsl:stylesheet>