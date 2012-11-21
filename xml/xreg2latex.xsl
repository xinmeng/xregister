<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:variable name="h_space">0.5</xsl:variable>
    <xsl:variable name="h_bidx">1</xsl:variable>
    <xsl:variable name="h_reg">2</xsl:variable>
    <xsl:variable name="W">
        <xsl:choose>
            <xsl:when test="/xregister/dwidth > 32">32</xsl:when>
            <xsl:otherwise><xsl:value-of select="/xregister/dwidth"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="seg">
        <xsl:value-of select="ceiling(/xregister/dwidth div $W)"/>
    </xsl:variable>
    
    <xsl:variable name="H">
        <xsl:value-of select="$seg * ($h_bidx + $h_reg) + ($seg - 1) * $h_space"/>
    </xsl:variable>
    
    <xsl:variable name="left.arrow.dx">-0.6</xsl:variable>
    <xsl:variable name="right.arrow.dx">-0.5</xsl:variable>
    <xsl:variable name="arrow.dy">0.2</xsl:variable>
    
    <xsl:variable name="digit.dx">0.1</xsl:variable>
    <xsl:variable name="digit.dy">0.25</xsl:variable>
    
    <xsl:template match="/xregister">
        <xsl:text>Module \texttt</xsl:text>{<xsl:call-template name="latex.name">
            <xsl:with-param name="s" select="name"/>
        </xsl:call-template>}'s data bus width is
        <xsl:value-of select="dwidth"/>, and address bus width is
        <xsl:value-of select="awidth"/>. Detailed register locations and descriptions are listed in following sections.
        
        <xsl:text>\setlength{\unitlength}{2ex}</xsl:text><xsl:call-template name="new.line"/>
        
        <xsl:for-each select="word">
            <xsl:variable name="label"><xsl:value-of select="concat('wd:', position())"/></xsl:variable>
            <xsl:text>\section{</xsl:text><xsl:call-template name="latex.name"><xsl:with-param name="s" select="name"/></xsl:call-template>}\label{<xsl:value-of select="$label"/>}<xsl:call-template name="new.line"/>
            <xsl:text>\begin{center}\begin{picture}</xsl:text><xsl:value-of select="concat('(', $W, ',', $H, ')')"/><xsl:call-template name="new.line"/>
            <xsl:call-template name="draw.box">
                <xsl:with-param name="ycordinate" select="$H"/>
                <xsl:with-param name="length" select="/xregister/dwidth"/>
                <xsl:with-param name="start" select="0"/>
            </xsl:call-template>
            
            <xsl:for-each select="reg">
                <xsl:call-template name="draw.reg"/>
            </xsl:for-each>
            <xsl:text>\end{picture}\end{center}</xsl:text><xsl:call-template name="new.line"/>
            
            
            <xsl:for-each select="reg">    
                <xsl:call-template name="reg.info"/>
                
                <xsl:call-template name="new.line"/>
                \hspace{\stretch{1}}\hyperref[<xsl:value-of select="$label"/>]{\tiny{\textsl{Back}}}<xsl:call-template name="new.line"/>
            </xsl:for-each>
            
            <xsl:call-template name="new.line"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="reg.info">
        <xsl:text/>\subsection{<xsl:call-template name="latex.name">
            <xsl:with-param name="s" select="name"/>
        </xsl:call-template>}\label{reg:<xsl:call-template name="label.name">
            <xsl:with-param name="s" select="name"/>
        </xsl:call-template>}\index{<xsl:call-template name="latex.name">
            <xsl:with-param name="s" select="name"/>
        </xsl:call-template>}<xsl:call-template name="new.line"/>
        
        <xsl:text/>\textbf{Location:} <xsl:call-template name="latex.name"><xsl:with-param name="s" select="../name"/></xsl:call-template><xsl:call-template name="reg.location"/>\hspace{\stretch{1}}\textbf{Width:}
        <xsl:value-of select="width"/>-bit\hspace{\stretch{1}}\textbf{Reset Value:}
        <xsl:value-of select="reset.value"/>\\<xsl:call-template name="new.line"/>
        
        <xsl:if test="software.domination">
            <xsl:text>$\oint$</xsl:text>
        </xsl:if>
        <xsl:text/>\textbf{SW:}<xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="sw.read.write">RW</xsl:when>
            <xsl:when test="sw.read.only.clear">RC</xsl:when>
            <xsl:when test="sw.read.only.write.1.clear">RW1C</xsl:when>
            <xsl:otherwise>RO</xsl:otherwise>
        </xsl:choose>
        <xsl:text/>\hspace{\stretch{1}}<xsl:text/>
        <xsl:if test="not(software.domination)">
            <xsl:text>$\oint$</xsl:text>
        </xsl:if>
        <xsl:text/>\textbf{HW:}<xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="hw.set.value">StVal</xsl:when>
            <xsl:when test="hw.set.bit.flag">StFlg</xsl:when>
            <xsl:when test="hw.clear.bit.flag">ClrFlg</xsl:when>
            <xsl:when test="hw.get.value">RO</xsl:when>
            <xsl:when test="hw.wired">Tie</xsl:when>
            <xsl:when test="hw.const">Const</xsl:when>
        </xsl:choose>
        \hspace{\stretch{1}}\textbf{Indications:}<xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="read.indication and write.indication">RD, WR</xsl:when>
            <xsl:when test="read.indication">RD</xsl:when>
            <xsl:when test="write.indication">WR</xsl:when>
            <xsl:otherwise>\textsl{(None)}</xsl:otherwise>
        </xsl:choose>
        \\<xsl:call-template name="new.line"/>
        
        <xsl:if test="comment">
            <xsl:text/>\textbf{Comment:}\begin{verbatim}<xsl:value-of select="comment"/>\end{verbatim}<xsl:call-template name="new.line"/>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="draw.reg">
        <xsl:variable name="seg"><xsl:value-of select="floor(offset div $W)"/></xsl:variable>
        <xsl:variable name="nxt.seg"><xsl:value-of select="floor((offset + width - 1) div $W)"/></xsl:variable>
        
        <xsl:text/>\put<xsl:value-of select="concat('(', $W - offset mod $W, ',', $H - $seg * ($h_bidx + $h_reg + $h_space ) - 1, '){\line(0,-1){2}}')"/><xsl:call-template name="new.line"/>
        
        <xsl:choose>
            <xsl:when test="$seg = $nxt.seg">
                <xsl:text/>\put<xsl:value-of select="concat('(', $W - offset mod $W - width, ',', $H - $seg * ($h_bidx + $h_reg + $h_space ) - 1, '){\line(0,-1){2}}')"/><xsl:call-template name="new.line"/>
                <xsl:text/>\put<xsl:value-of select="concat('(', $W - offset mod $W - width, ',', $H - $seg * ($h_bidx + $h_reg + $h_space ) - 3, ')')"
                />{\makebox<xsl:value-of select="concat('(', width, ',', 2,')[c]')"
                />{\hyperref[reg:<xsl:call-template name="label.name">
                    <xsl:with-param name="s" select="name"/>
                </xsl:call-template>]{<xsl:value-of select="position()"/>}}}<xsl:call-template name="new.line"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>\put<xsl:value-of select="concat('(', 2 * $W - offset mod $W - width, ',', $H - $nxt.seg * ($h_bidx + $h_reg + $h_space ) - 1, '){\line(0,-1){2}}')"/><xsl:call-template name="new.line"/>
                <xsl:text/>\put<xsl:value-of select="concat('(', 0, ',', $H - $seg * ($h_bidx + $h_reg + $h_space ) - 3, ')')"
                />{\makebox<xsl:value-of select="concat('(', $W - offset, ',', 2,')[c]')"
                />{\hyperref[reg:<xsl:call-template name="label.name">
                    <xsl:with-param name="s" select="name"/>
                </xsl:call-template>]{<xsl:value-of select="position()"/>}}}<xsl:call-template name="new.line"/>
                <xsl:text/>\put<xsl:value-of select="concat('(', $left.arrow.dx, ',', $H - $seg * ($h_bidx + $h_reg + $h_space ) - 3 + $arrow.dy, ')')"
                />{$\gets$}<xsl:call-template name="new.line"/>
                
                <xsl:text/>\put<xsl:value-of select="concat('(', 2 * $W - offset mod $W - width, ',', $H - $nxt.seg * ($h_bidx + $h_reg + $h_space ) - 3, ')')"
                />{\makebox<xsl:value-of select="concat('(', width - $W + offset, ',', 2,')[c]')"
                />{\hyperref[reg:<xsl:call-template name="label.name">
                    <xsl:with-param name="s" select="name"/>
                </xsl:call-template>]{<xsl:value-of select="position()"/>}}}<xsl:call-template name="new.line"/>
                <xsl:text/>\put<xsl:value-of select="concat('(', $W + $right.arrow.dx, ',', $H - $nxt.seg * ($h_bidx + $h_reg + $h_space ) - 3 + $arrow.dy, ')')"
                />{$\to$}<xsl:call-template name="new.line"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="latex.name">
        <xsl:param name="s"/>
        <xsl:choose>
            <xsl:when test="contains($s, '_')">
                <xsl:value-of select="concat(substring-before($s, '_'), '\_')"/>
                <xsl:call-template name="latex.name">
                    <xsl:with-param name="s" select="substring-after($s, '_')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$s"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="label.name">
        <xsl:param name="s"/>
        <xsl:text/><xsl:value-of select="translate($s, '_', ' ')"/><xsl:text/>
    </xsl:template>
    
    <xsl:template name="draw.box">
        <xsl:param name="ycordinate"/>
        <xsl:param name="start" select="0"/>
        <xsl:param name="length" select="32"/>
        
        <xsl:choose>
            <xsl:when test="$length > 32">
                <xsl:text/>\put<xsl:value-of select="concat('(', $W, ',', $ycordinate, ')')"/>{\line<xsl:value-of select="concat('(0, -1){', $h_bidx + $h_reg, '}')"/>}<xsl:call-template name="new.line"/>
                <xsl:text/>\put<xsl:value-of select="concat('(', 0,  ',', $ycordinate, ')')"/>{\line<xsl:value-of select="concat('(0, -1){', $h_bidx + $h_reg, '}')"/>}<xsl:call-template name="new.line"/>
                <xsl:text/>\put<xsl:value-of select="concat('(', 0,  ',', $ycordinate - $h_bidx, ')')"/>{\line<xsl:value-of select="concat('(1,0){', $W, '}')"/>}<xsl:call-template name="new.line"/>
                <xsl:text/>\put<xsl:value-of select="concat('(', 0,  ',', $ycordinate - $h_bidx - $h_reg, ')')"/>{\line<xsl:value-of select="concat('(1,0){', $W, '}')"/>}<xsl:call-template name="new.line"/>
                
                <xsl:call-template name="fill.bidx">
                    <xsl:with-param name="segment" select="floor($start div $W)"/>
                    <xsl:with-param name="start" select="$start"/>
                    <xsl:with-param name="count" select="$start + 32"/>
                </xsl:call-template>
                
                
                <xsl:call-template name="draw.box">
                    <xsl:with-param name="ycordinate" select="$ycordinate - $h_bidx - $h_reg - $h_space"/>
                    <xsl:with-param name="start" select="$start + 32"/>
                    <xsl:with-param name="length" select="$length - 32"/>
                </xsl:call-template>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:variable name="xordinate"><xsl:value-of select="32 - $length"/></xsl:variable>
                <xsl:text/>\put<xsl:value-of select="concat('(', $W, ',', $ycordinate, ')')"/>{\line<xsl:value-of select="concat('(0, -1){', $h_bidx + $h_reg, '}')"/>}<xsl:call-template name="new.line"/>
                <xsl:text/>\put<xsl:value-of select="concat('(', $xordinate,  ',', $ycordinate, ')')"/>{\line<xsl:value-of select="concat('(0, -1){', $h_bidx + $h_reg, '}')"/>}<xsl:call-template name="new.line"/>
                <xsl:text/>\put<xsl:value-of select="concat('(', $xordinate,  ',', $ycordinate - $h_bidx, ')')"/>{\line<xsl:value-of select="concat('(1,0){', $length, '}')"/>}<xsl:call-template name="new.line"/>
                <xsl:text/>\put<xsl:value-of select="concat('(', $xordinate,  ',', $ycordinate - $h_bidx - $h_reg, ')')"/>{\line<xsl:value-of select="concat('(1,0){', $length, '}')"/>}<xsl:call-template name="new.line"/>
                
                <xsl:call-template name="fill.bidx">
                    <xsl:with-param name="segment" select="floor($start div $W)"/>
                    <xsl:with-param name="start" select="$start"/>
                    <xsl:with-param name="count" select="$start + $length"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="fill.bidx">
        <xsl:param name="segment"/>
        <xsl:param name="start"/>
        <xsl:param name="count"/>
        
        <xsl:text/>\put<xsl:value-of select="concat('(', $W - $start mod $W - 1 + $digit.dx, ',', $H - $segment * ($h_bidx + $h_reg + $h_space) - 1 + $digit.dy, '){\tiny{', $start, '}}')"/><xsl:call-template name="new.line"/>
        
        <xsl:text/>\put<xsl:value-of select="concat('(', $W - $start mod $W - 1, ',', $H - $segment * ($h_bidx + $h_reg + $h_space), '){\line(0,-1){1}}')"/><xsl:call-template name="new.line"/>
        
        <xsl:if test="$start + 1 != $count">
            <xsl:call-template name="fill.bidx">
                <xsl:with-param name="segment" select="$segment"/>
                <xsl:with-param name="start" select="$start + 1"/>
                <xsl:with-param name="count" select="$count"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="reg.location">
        <xsl:choose>
            <xsl:when test="width = 1">
                <xsl:text/>[<xsl:value-of select="offset"/>]<xsl:text/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>[<xsl:value-of select="offset + width - 1"/>:<xsl:value-of select="offset"/>]<xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="new.line">
        <xsl:text>&#xD;</xsl:text>
    </xsl:template>

</xsl:stylesheet>