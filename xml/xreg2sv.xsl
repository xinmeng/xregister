<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="/xregister">
        
        <xsl:text>module </xsl:text><xsl:value-of select="name"/> (<xsl:call-template name="new.line"/>
        <xsl:call-template name="port.list"/>
        <xsl:text>  )</xsl:text><xsl:call-template name="punc.new.line"/>
        <xsl:call-template name="new.line"/>
        
        <xsl:call-template name="port.declaration"/>
        <xsl:call-template name="net.declaration"/>

        <xsl:for-each select="word">
            <xsl:call-template name="grouping"/>            

            <xsl:for-each select="reg">
                <xsl:sort select="offset" order="ascending"/>
                <xsl:call-template name="reg"/>
            </xsl:for-each>
            
        </xsl:for-each>
        
        <xsl:call-template name="decoder"/>        
        <xsl:call-template name="indications"/> 
        <xsl:call-template name="read.mux"/>
        
        <xsl:call-template name="new.line"/>
        <xsl:text>endmodule</xsl:text>
        <xsl:call-template name="new.line"/>

    </xsl:template>
    
    <xsl:template name="read.mux">
        <xsl:text>// ----------------------------</xsl:text><xsl:call-template name="new.line"/>
        <xsl:text>//       Read MUX and FF</xsl:text><xsl:call-template name="new.line"/>
        <xsl:text>// ----------------------------</xsl:text><xsl:call-template name="new.line"/>        
        <xsl:text>always_comb</xsl:text><xsl:call-template name="new.line"/>
        <xsl:text>  unique case (1'b1)</xsl:text><xsl:call-template name="new.line"/>
        <xsl:for-each select="word">
            <xsl:text>    </xsl:text><xsl:call-template name="word.rd"/>: read_data[<xsl:value-of select="/xregister/dwidth - 1"/>:0] = <xsl:call-template name="word.data"/><xsl:call-template name="punc.new.line"/>
        </xsl:for-each>
        <xsl:text>    default: read_data[</xsl:text><xsl:value-of select="/xregister/dwidth - 1"/>:0] = <xsl:value-of select="/xregister/dwidth"/>'d0<xsl:call-template name="punc.new.line"/>
        <xsl:text>  endcase</xsl:text><xsl:call-template name="new.line"/>
        <xsl:call-template name="new.line"/>
        
        <xsl:text>always_ff @(posedge clock or negedge reset_n)</xsl:text><xsl:call-template name="new.line"/>
        <xsl:text>  if (~reset_n) begin</xsl:text><xsl:call-template name="new.line"/>
        <xsl:text>    reg_ack &lt;= 1'b0</xsl:text><xsl:call-template name="punc.new.line"/>
        <xsl:text>    ack_tmp &lt;= 1'b0</xsl:text><xsl:call-template name="punc.new.line"/>
        <xsl:text>    wr_data_ff[</xsl:text><xsl:value-of select="/xregister/dwidth - 1"/>:0] &lt;= <xsl:value-of select="/xregister/dwidth"/>'d0<xsl:call-template name="punc.new.line"/>
        <xsl:text>    reg_rdata[</xsl:text><xsl:value-of select="/xregister/dwidth - 1"/>:0] &lt;= <xsl:value-of select="/xregister/dwidth"/>'d0<xsl:call-template name="punc.new.line"/>    
        <xsl:text>  end</xsl:text><xsl:call-template name="new.line"/>
        <xsl:text>  else begin</xsl:text><xsl:call-template name="new.line"/>
        <xsl:text>    reg_ack &lt;= ack_tmp</xsl:text><xsl:call-template name="punc.new.line"/>
        <xsl:text>    ack_tmp &lt;= reg_rd</xsl:text><xsl:call-template name="punc.new.line"/>
        <xsl:text>    wr_data_ff[</xsl:text><xsl:value-of select="/xregister/dwidth - 1"/>:0] &lt;= reg_wdata[<xsl:value-of select="/xregister/dwidth - 1"/>:0]<xsl:call-template name="punc.new.line"/>
        <xsl:text>    reg_rdata[</xsl:text><xsl:value-of select="/xregister/dwidth - 1"/>:0] &lt;= read_data[<xsl:value-of select="/xregister/dwidth - 1"/>:0]<xsl:call-template name="punc.new.line"/>
        <xsl:text>  end</xsl:text>
        <xsl:call-template name="new.line"/>        
    </xsl:template>
    
    <xsl:template name="grouping">
        <xsl:text>//==== </xsl:text><xsl:value-of select="address"/>: <xsl:value-of select="name"/> ====\\<xsl:call-template name="new.line"/>
        <xsl:text/>always_comb begin<xsl:call-template name="new.line"/>
        <xsl:text>  </xsl:text><xsl:call-template name="word.data"/>[<xsl:value-of select="/xregister/dwidth -1"/>:0] = <xsl:value-of select="/xregister/dwidth"/>'d0<xsl:call-template name="punc.new.line"/>
        <xsl:for-each select="reg">
            <xsl:text>  </xsl:text><xsl:call-template name="reg.dst.location"/> = <xsl:call-template name="reg.name.range"/><xsl:call-template name="punc.new.line"/>
        </xsl:for-each>
        <xsl:text>end</xsl:text><xsl:call-template name="new.line"/><xsl:call-template name="new.line"/>        
    </xsl:template>
    
    <xsl:template name="port.list">
        <xsl:text/>  clock, reset_n, reg_addr, reg_wr, reg_rd, reg_ack, reg_wdata, reg_rdata, <xsl:call-template name="new.line"/>
        <xsl:for-each select="//reg">
            <xsl:text>  </xsl:text><xsl:call-template name="reg.name"/><xsl:text/>
            <xsl:choose>
                <xsl:when test="hw.set.bit.flag or hw.clear.bit.flag">, <xsl:call-template name="reg.hw.ctrl"/></xsl:when>
                <xsl:when test="hw.set.value">, <xsl:call-template name="reg.hw.ctrl"/>, <xsl:call-template name="reg.hw.value.name"/></xsl:when>
                <xsl:when test="hw.wired">, <xsl:call-template name="reg.hw.value.name"/></xsl:when>
            </xsl:choose>
            <xsl:if test="read.indication">, <xsl:call-template name="reg.ridct"/></xsl:if>
            <xsl:if test="write.indication">, <xsl:call-template name="reg.widct"/></xsl:if>
            <xsl:if test="position() != last()">,</xsl:if>
            <xsl:call-template name="new.line"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="port.declaration">
        <xsl:text>input  logic clock, reset_n, reg_rd, reg_wr</xsl:text><xsl:call-template name="punc.new.line"/>
        <xsl:text>output logic reg_ack</xsl:text><xsl:call-template name="punc.new.line"/>
        <xsl:text>input  logic [</xsl:text><xsl:value-of select="/xregister/dwidth - 1"/>:0] reg_wdata<xsl:call-template name="punc.new.line"/>
        <xsl:text>output logic [</xsl:text><xsl:value-of select="/xregister/dwidth - 1"/>:0] reg_rdata<xsl:call-template name="punc.new.line"/>
        <xsl:text>input  logic [</xsl:text><xsl:value-of select="/xregister/awidth - 1"/>:0] reg_addr<xsl:call-template name="punc.new.line"/>
        <xsl:call-template name="new.line"/>

        
        <xsl:for-each select="//reg">
            <xsl:text>output logic </xsl:text><xsl:call-template name="reg.range"/><xsl:text> </xsl:text><xsl:call-template name="reg.name"/><xsl:call-template name="punc.new.line"/>
            <xsl:choose>
                <xsl:when test="hw.set.bit.flag or hw.clear.bit.flag">
                    <xsl:text>input  logic </xsl:text><xsl:call-template name="reg.hw.ctrl"/><xsl:call-template name="punc.new.line"/>
                </xsl:when>
                <xsl:when test="hw.set.value">
                    <xsl:text>input  logic </xsl:text><xsl:call-template name="reg.hw.ctrl"/><xsl:call-template name="punc.new.line"/>
                    <xsl:text>input  logic </xsl:text><xsl:call-template name="reg.range"/><xsl:text> </xsl:text><xsl:call-template name="reg.hw.value.name"/><xsl:call-template name="punc.new.line"/>
                </xsl:when>
                <xsl:when test="hw.wired">
                    <xsl:text>input  logic </xsl:text><xsl:call-template name="reg.range"/><xsl:text> </xsl:text><xsl:call-template name="reg.hw.value.name"/><xsl:call-template name="punc.new.line"/> 
                </xsl:when>
            </xsl:choose>
            <xsl:if test="read.indication">
                <xsl:text>output logic </xsl:text><xsl:call-template name="reg.ridct"/><xsl:call-template name="punc.new.line"/>
            </xsl:if>
            <xsl:if test="write.indication">
                <xsl:text>output logic </xsl:text><xsl:call-template name="reg.widct"/><xsl:call-template name="punc.new.line"/>
            </xsl:if>
            <xsl:call-template name="new.line"/>            
        </xsl:for-each>        
        
        <xsl:call-template name="new.line"/>
    </xsl:template>
    
    <xsl:template name="net.declaration">
        <xsl:text>logic ack_tmp</xsl:text><xsl:call-template name="punc.new.line"/>
        <xsl:text>logic [</xsl:text><xsl:value-of select="/xregister/dwidth - 1"/>:0]<xsl:text> read_data, wr_data_ff</xsl:text><xsl:call-template name="punc.new.line"/>
        <xsl:call-template name="new.line"/>
        
        <xsl:text>logic [</xsl:text><xsl:value-of select="/xregister/dwidth - 1"/>:0]<xsl:text> </xsl:text>
        <xsl:for-each select="word">
            <xsl:call-template name="word.data"/>
            <xsl:choose>
                <xsl:when test="position() != last()">
                    <xsl:text>, </xsl:text>
                    <xsl:if test="position() mod 5 = 0">
                        <xsl:call-template name="new.line"/>
                        <xsl:text>             </xsl:text>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="punc.new.line"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:call-template name="new.line"/>
        
        
        <xsl:for-each select="word">
            <xsl:text>logic </xsl:text>
            <xsl:call-template name="word.sel"/>, <xsl:call-template name="word.rd"/>
            <xsl:if test="count(reg[sw.read.write | sw.read.only.clear | sw.read.only.write.1.clear]) >= 1">
                <xsl:text>, </xsl:text><xsl:call-template name="word.wr"/>
            </xsl:if>
            <xsl:if test="count(reg[read.indication]) >= 1">
                <xsl:text>, </xsl:text><xsl:call-template name="word.ridct"/>
            </xsl:if>
            <xsl:if test="count(reg[write.indication]) >= 1">
                <xsl:text>, </xsl:text><xsl:call-template name="word.widct"/>
            </xsl:if>            
            <xsl:call-template name="punc.new.line"/>
        </xsl:for-each>
        <xsl:call-template name="new.line"/>
        
    </xsl:template>


    
    
    <xsl:template name="reg">
        <xsl:call-template name="check"/>
        
        <xsl:text/>/* <xsl:value-of select="../name"/><xsl:call-template name="reg.location"/><xsl:value-of select="concat(', No.', position(), ': ')"/><xsl:call-template name="reg.name.range"/><xsl:text> </xsl:text>       
        <xsl:if test="comment">
            <xsl:call-template name="new.line"/>
            <xsl:value-of select="comment"/><xsl:text/>
            <xsl:call-template name="new.line"/>
        </xsl:if>
        <xsl:text>*/</xsl:text><xsl:call-template name="new.line"/>
        
        <xsl:choose>
            <xsl:when test="hw.const">
                <xsl:text/>assign <xsl:call-template name="reg.name.range"/> = <xsl:value-of select="reset.value"/><xsl:call-template name="punc.new.line"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>always_ff @(posedge clock or negedge reset_n)<xsl:call-template name="new.line"/>
                <xsl:text/>  if ( ~reset_n )<xsl:call-template name="new.line"/>
                <xsl:text>    </xsl:text><xsl:call-template name="reg.name.range"/> &lt;= <xsl:value-of select="reset.value"/><xsl:call-template name="punc.new.line"/>
                <xsl:text/>  else<xsl:call-template name="new.line"/>
                
                <xsl:choose>
                    <xsl:when
                        test="(hw.set.bit.flag or hw.clear.bit.flag or hw.set.value) and (sw.read.write or sw.read.only.clear or sw.read.only.write.1.clear)">
                        <xsl:call-template name="both.write"/>
                    </xsl:when>
                    <xsl:when test="(hw.set.bit.flag or hw.clear.bit.flag or hw.set.value) and sw.read.only">
                        <xsl:call-template name="hw.write.sw.read"/>
                    </xsl:when>
                    <xsl:when test="hw.get.value">
                        <xsl:call-template name="hw.read.sw.write"/>
                    </xsl:when>
                    <xsl:when test="hw.wired">
                        <xsl:text>    </xsl:text><xsl:call-template name="reg.name.range"/> &lt;= <xsl:call-template name="reg.hw.value"/><xsl:call-template name="punc.new.line"/>
                    </xsl:when>
                </xsl:choose>                
            </xsl:otherwise>
        </xsl:choose>
        
        
        
        <xsl:if test="read.indication">
            <xsl:text>assign </xsl:text><xsl:call-template name="reg.ridct"/> = <xsl:call-template name="reg.word.ridct"/><xsl:call-template name="punc.new.line"/>
        </xsl:if>
        <xsl:if test="write.indication">
            <xsl:text>assign </xsl:text><xsl:call-template name="reg.widct"/> = <xsl:call-template name="reg.word.widct"/><xsl:call-template name="punc.new.line"/>
        </xsl:if>
        
        <xsl:call-template name="new.line"/>
    </xsl:template>

    <xsl:template name="both.write"> 
        <xsl:choose>
            <xsl:when test="software.domination">
                <xsl:call-template name="gen.sw.code"/>
                <xsl:text>    else </xsl:text><xsl:call-template name="gen.hw.code"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="gen.hw.code"/>
                <xsl:text>    else </xsl:text><xsl:call-template name="gen.sw.code"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="gen.default.code"/>
    </xsl:template>

    <xsl:template name="hw.write.sw.read">
        <xsl:call-template name="gen.hw.code"/>
        <xsl:call-template name="gen.default.code"/>
    </xsl:template>

    <xsl:template name="hw.read.sw.write">
        <xsl:call-template name="gen.sw.code"/>
        <xsl:call-template name="gen.default.code"/>
    </xsl:template>

    <xsl:template name="gen.default.code">
        <xsl:text>    else</xsl:text><xsl:call-template name="new.line"/>
        <xsl:text>      </xsl:text><xsl:call-template name="reg.name.range"/> &lt;= <xsl:call-template name="reg.name.range"/><xsl:call-template name="punc.new.line"/>
    </xsl:template>
    
    <xsl:template name="gen.hw.code">
        <xsl:choose>
            <xsl:when test="hw.set.bit.flag">
                <xsl:text>    if (</xsl:text><xsl:call-template name="reg.hw.ctrl"/>)<xsl:call-template name="new.line"/>
                <xsl:text>      </xsl:text><xsl:call-template name="reg.name.range"/> &lt;= 1'b1<xsl:call-template name="punc.new.line"/>
            </xsl:when>
            <xsl:when test="hw.clear.bit.flag">
                <xsl:text>    if (</xsl:text><xsl:call-template name="reg.hw.ctrl"/>)<xsl:call-template name="new.line"/>
                <xsl:text>      </xsl:text><xsl:call-template name="reg.name.range"/> &lt;= 1'b0<xsl:call-template name="punc.new.line"/>
            </xsl:when>
            <xsl:when test="hw.set.value">
                <xsl:text>    if (</xsl:text><xsl:call-template name="reg.hw.ctrl"/>)<xsl:call-template name="new.line"/>
                <xsl:text>      </xsl:text><xsl:call-template name="reg.name.range"/> &lt;= <xsl:call-template name="reg.hw.value"/><xsl:call-template name="punc.new.line"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="gen.sw.code">
        <xsl:choose>
            <xsl:when test="sw.read.write">
                <xsl:text>    if (</xsl:text><xsl:call-template name="reg.word.wr"/>)<xsl:call-template name="new.line"/>
                <xsl:text>      </xsl:text><xsl:call-template name="reg.name.range"/> &lt;= <xsl:call-template name="reg.src.location"/><xsl:call-template name="punc.new.line"/>
            </xsl:when>
            <xsl:when test="sw.read.only.clear">
                <xsl:text>    if (</xsl:text><xsl:call-template name="reg.word.rd"/>)<xsl:call-template name="new.line"/>
                <xsl:text>      </xsl:text><xsl:call-template name="reg.name.range"/> &lt;= <xsl:value-of select="width"/>'d0<xsl:call-template name="punc.new.line"/>
            </xsl:when>
            <xsl:when test="sw.read.only.write.1.clear">
                <xsl:text>    if (</xsl:text><xsl:call-template name="reg.word.wr"/>)<xsl:call-template name="new.line"/>
                <xsl:text>      </xsl:text><xsl:call-template name="reg.name.range"/> &lt;= ~<xsl:call-template name="reg.src.location"/> &amp; <xsl:call-template name="reg.name.range"/><xsl:call-template name="punc.new.line"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
    

    <xsl:template name="check">
        <xsl:if test="offset + width > /xregister/dwidth">
            <xsl:message terminate="yes">
                <xsl:text/>**Error:<xsl:value-of select="../name"/>/<xsl:value-of select="name"/>[<xsl:value-of select="offset"/>:<xsl:value-of select="offset + width -1 "/>], exceeds word width <xsl:value-of select="/xregister/dwidth"/>.<xsl:text/>
            </xsl:message>
        </xsl:if>

        <xsl:if test="position() != 1 ">
            <xsl:variable name="previous">
                <xsl:value-of select="position()-1"/>
            </xsl:variable>
            <xsl:if
                test="../reg[position()=$previous]/offset + ../reg[position()=$previous]/width - 1 >= offset">
                <xsl:message terminate="yes">
                    <xsl:text/>**Error:<xsl:value-of select="../name"/>/<xsl:value-of select="name"/>[<xsl:value-of select="offset"/>:<xsl:value-of select="offset + width - 1"/>] overlaps with <xsl:value-of select="../name"/>/<xsl:value-of
                        select="../reg[position()=$previous]/name"/>[<xsl:value-of
                        select="../reg[position()=$previous]/offset"/>:<xsl:value-of
                        select="../reg[position()=$previous]/offset + ../reg[position()=$previous]/width - 1"
                    />].<xsl:text/>
                </xsl:message>
            </xsl:if>
        </xsl:if>

        <xsl:if test="(hw.set.bit.flag or hw.clear.bit.flag) and (width > 1)">
            <xsl:message terminate="yes">
                <xsl:text/>**Error:<xsl:value-of select="../name"/>/<xsl:value-of select="name"/> is flag, but width (<xsl:value-of select="width"/>) is larger than 1.<xsl:text/>
            </xsl:message>
        </xsl:if>
    </xsl:template>

    <xsl:template name="decoder">
        <xsl:text>// ----------------------------</xsl:text><xsl:call-template name="new.line"/>
        <xsl:text>//           Decoder</xsl:text><xsl:call-template name="new.line"/>
        <xsl:text>// ----------------------------</xsl:text><xsl:call-template name="new.line"/>
        <xsl:text>always_comb begin</xsl:text><xsl:call-template name="new.line"/>
        <xsl:for-each select="word">
            <xsl:text>  </xsl:text><xsl:call-template name="word.sel"/> = 1'b0<xsl:call-template name="punc.new.line"/>
        </xsl:for-each>
        <xsl:text>  unique case ( reg_addr[</xsl:text><xsl:value-of select="awidth - 1"/>:0] )<xsl:call-template name="new.line"/>
        <xsl:for-each select="word">            
            <xsl:text>    </xsl:text><xsl:value-of select="/xregister/awidth"/>'d<xsl:value-of select="address"/>: <xsl:call-template name="word.sel"/> = 1'b1<xsl:call-template name="punc.new.line"/>
        </xsl:for-each>
        <xsl:text>  endcase</xsl:text><xsl:call-template name="new.line"/>
        <xsl:text>end</xsl:text><xsl:call-template name="new.line"/>
        <xsl:call-template name="new.line"/>
        
        
        
        <xsl:text>always_ff @(posedge clock or negedge reset_n)</xsl:text><xsl:call-template name="new.line"/>
        <xsl:text>  if ( ~reset_n ) begin</xsl:text><xsl:call-template name="new.line"/>
        <xsl:for-each select="word">
            <xsl:text>    </xsl:text><xsl:call-template name="word.rd"/> &lt;= 1'b0<xsl:call-template name="punc.new.line"/>
            <xsl:if test="count(reg/sw.read.write | reg/sw.read.only.clear | reg/sw.read.only.write.1.clear)">
                <xsl:text>    </xsl:text><xsl:call-template name="word.wr"/> &lt;= 1'b0<xsl:call-template name="punc.new.line"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>  end</xsl:text><xsl:call-template name="new.line"/>
        <xsl:text>  else begin</xsl:text><xsl:call-template name="new.line"/>
        <xsl:for-each select="word">
            <xsl:text>    </xsl:text><xsl:call-template name="word.rd"/> &lt;= reg_rd &amp; <xsl:call-template name="word.sel"/><xsl:call-template name="punc.new.line"/>
            <xsl:if test="count(reg/sw.read.write | reg/sw.read.only.clear | reg/sw.read.only.write.1.clear)">
                <xsl:text>    </xsl:text><xsl:call-template name="word.wr"/> &lt;= reg_wr &amp; <xsl:call-template name="word.sel"/><xsl:call-template name="punc.new.line"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>  end</xsl:text><xsl:call-template name="new.line"/>
        <xsl:call-template name="new.line"/>        
    </xsl:template>
    
    <xsl:template name="indications">
        <xsl:if test="count(word[count(reg/read.indication)]) or count(word[count(reg/write.indication)])">
            <xsl:text>// ----------------------------</xsl:text><xsl:call-template name="new.line"/>
            <xsl:text>//         Indications</xsl:text><xsl:call-template name="new.line"/>
            <xsl:text>// ----------------------------</xsl:text><xsl:call-template name="new.line"/>    
        </xsl:if>
        
        <xsl:for-each select="word[count(reg/read.indication) >= 1]">
            <xsl:text/>assign <xsl:value-of select="concat('word_', address, '_ridct')"/> = <xsl:call-template name="word.rd"/><xsl:call-template name="punc.new.line"/>
        </xsl:for-each>
        <xsl:call-template name="new.line"/>
        
        <xsl:if test="count(word[count(reg/write.indication) >= 1])">
            <xsl:text>always_ff @(posedge clock or negedge reset_n)</xsl:text><xsl:call-template name="new.line"/>
            <xsl:text>  if (~reset_n) begin</xsl:text><xsl:call-template name="new.line"/>
            <xsl:for-each select="word[count(reg/write.indication) >= 1]">
                <xsl:text>    </xsl:text><xsl:call-template name="word.widct"/> &lt;= 1'b0<xsl:call-template name="punc.new.line"/>
            </xsl:for-each>
            <xsl:text>  end</xsl:text><xsl:call-template name="new.line"/>
            <xsl:text>  else begin</xsl:text><xsl:call-template name="new.line"/>
            <xsl:for-each select="word[count(reg/write.indication) >= 1]">
                <xsl:text>    </xsl:text><xsl:call-template name="word.widct"/> &lt;= <xsl:call-template name="word.wr"/><xsl:call-template name="punc.new.line"/>                        
            </xsl:for-each>
            <xsl:text>  end</xsl:text><xsl:call-template name="new.line"/>
            <xsl:call-template name="new.line"/>
        </xsl:if>        
    </xsl:template>
    
    <xsl:template name="reg.name">
        <xsl:text/><xsl:value-of select="concat('reg_', name)"/><xsl:text/>
    </xsl:template>
    
    <xsl:template name="reg.name.range">
        <xsl:call-template name="reg.name"/>
        <xsl:call-template name="reg.range"></xsl:call-template>
    </xsl:template>
    
    <xsl:template name="reg.range">
        <xsl:choose>
            <xsl:when test="width = 1">
                <xsl:text/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>[<xsl:value-of select="width - 1"/>:0]<xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
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
    
    <xsl:template name="reg.hw.ctrl">
        <xsl:text/><xsl:value-of select="concat('reg_', name, '_hw_ctrl')"/><xsl:text/>
    </xsl:template>
    
    <xsl:template name="reg.hw.value">
        <xsl:text/><xsl:value-of select="concat('reg_', name, '_hw_value')"/><xsl:text/>
        <xsl:call-template name="reg.range"/>
    </xsl:template>
    
    <xsl:template name="reg.hw.value.name">
        <xsl:text/><xsl:value-of select="concat('reg_', name, '_hw_value')"/><xsl:text/>
    </xsl:template>
    
    <xsl:template name="reg.src.location">
        <xsl:text/>wr_data_ff<xsl:text/>
        <xsl:call-template name="reg.location"/>
    </xsl:template>
    
    <xsl:template name="reg.dst.location">
        <xsl:text/><xsl:value-of select="concat('word_', ../address, '_data')"/><xsl:text/>
        <xsl:call-template name="reg.location"/>
    </xsl:template>
    
    <xsl:template name="reg.ridct">
        <xsl:text/><xsl:value-of select="concat('reg_', name, '_ridct')"/><xsl:text/>
    </xsl:template>
    
    <xsl:template name="reg.widct">
        <xsl:text/><xsl:value-of select="concat('reg_', name, '_widct')"/><xsl:text/>
    </xsl:template>
    
    <xsl:template name="reg.word.wr">
        <xsl:text/><xsl:value-of select="concat('word_', ../address, '_wr')"/><xsl:text/>
    </xsl:template>
    
    <xsl:template name="reg.word.rd">
        <xsl:text/><xsl:value-of select="concat('word_', ../address, '_rd')"/><xsl:text/>
    </xsl:template>
    
    <xsl:template name="reg.word.ridct">
        <xsl:text/><xsl:value-of select="concat('word_', ../address, '_ridct')"/><xsl:text/>
    </xsl:template>
    
    <xsl:template name="reg.word.widct">
        <xsl:text/><xsl:value-of select="concat('word_', ../address, '_widct')"/><xsl:text/>
    </xsl:template>
    
    <xsl:template name="punc.new.line">
        <xsl:text>;&#xD;</xsl:text>
    </xsl:template>
    
    <xsl:template name="new.line">
        <xsl:text>&#xD;</xsl:text>
    </xsl:template>
    
    <xsl:template name="word.rd">
        <xsl:text/><xsl:value-of select="concat('word_', address, '_rd')"/><xsl:text/>
    </xsl:template>
    
    <xsl:template name="word.wr">
        <xsl:text/><xsl:value-of select="concat('word_', address, '_wr')"/><xsl:text/>
    </xsl:template>
    
    <xsl:template name="word.sel">
        <xsl:text/><xsl:value-of select="concat('word_', address, '_sel')"/><xsl:text/>
    </xsl:template>
    
    <xsl:template name="word.ridct">
        <xsl:text/><xsl:value-of select="concat('word_', address, '_ridct')"/><xsl:text/>
    </xsl:template>

    <xsl:template name="word.widct">
        <xsl:text/><xsl:value-of select="concat('word_', address, '_widct')"/><xsl:text/>
    </xsl:template>
    
    <xsl:template name="word.data">
        <xsl:text/><xsl:value-of select="concat('word_', address, '_data')"/><xsl:text/>
    </xsl:template>
    
</xsl:stylesheet>
