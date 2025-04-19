<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
<!-- BOF BMW_XSLT_TighteningTorques2XHTML_1.0.xslt -->
<!--
 Author: Frank Mehlhose
 Date: 12|2005
 Id:  BMW_XSLT_TighteningTorques2XHTML_1.0.xslt,v 1.8 2010-05-04 13:55:35 mandeld Exp 
 Function: Creates XHTML 1.0 Documents from TT Documents
-->
<!-- Big tables -->
 <xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
<!-- BOF BMW_XSLT_ExecuteInGreen_1.0.xslt  BMW_XSLT_ExecuteInGreen_1.0.xslt,v 1.4.2.2 2010-05-20 13:52:25 woehrle Exp  -->

<xsl:template match="/view/slave[@id=/view/master/include-slave/@idref]">
 <xsl:apply-templates select="content/*" />
</xsl:template>

<!-- EOF BMW_XSLT_ExecuteInGreen_1.0.xslt -->

 <xsl:variable name="ConsiderColumnWidths" select="'false'" />

<!-- BOF BMW_XSLT_LibXHTML_1.0.xslt -->
<!--
 Author: Frank Mehlhose
 Date: 12|2005
 Id:
  BMW_XSLT_LibXHTML_1.0.xslt,v 1.20.2.5 2011-03-01 14:14:14 woehrle Exp 
 Function: - Creates XHTML 1.0 Tables from Tables defined in table.def
   - Creates XHTML 1.0 Lists
   - Provides Templates for HOTSPOT, REFERENCE and GRAPHIC which are special, because they depend
   on javascript functions in the browser
   - Provides Template for Generallist, a list in table layout that can have user defined list
-->
<!--
 Hint:
  In the other Stylesheets there are templates called "makeViewCompatibleOuput". They are similar to the template of the root
  element, but they only produce output for the body and not a whole XHTML Document. This will be useful for the implemenation of "VIEW".
  There may be problems with layout, because alle the layout is done by CSS and the rules are not included in the output by the "makeViewCompatibleOuput" template.

 Hint:
  The stylesheet for TDP should work for TD.
-->
 <!-- common variables -->
 <xsl:variable name="leerzeichen"><xsl:text> </xsl:text></xsl:variable>
 <xsl:variable name="linkIdSeparator" select="','"/>
 <xsl:key name="references" match="REFERENCE[@TYPE='SWZ']" use="normalize-space(translate(text(),'&#xA0;',' '))"/>

 <!-- Tables -->
 <!--
 table border depends on: - @FRAME Element in TGROUP and if this is not set
        the @FRAME Element in parent::TABLE
 rowsep depends on the following: - is there a following row?
      - is there a Rowsep attribute in the entry, the parent row element or the parent tgroup element?
 colspan: - the stylesheet gets the position of namest and nameend in the colgroup definition
        and calculates the difference
 align and valign: - the values consider the ENTRY, the parent ROW and the parent COLSPEC, THEAD, TBODY and TFOOT elements
 morerows: - the rowspan is 1 + @MOREROWS
 -->
 <!--
  There are the CSS Classes t, b, l and r where each is defining one border as thin solid black
 -->
 <xsl:template name="getClassFromFRAME">
  <xsl:param name="FRAMEval" select="@FRAME"/>
  <xsl:param name="upperFRAMEval" select="../@FRAME"/>
  <xsl:choose>
   <xsl:when test="$FRAMEval='SIDES'">l r</xsl:when>
   <xsl:when test="$FRAMEval='TOP'">t</xsl:when>
   <xsl:when test="$FRAMEval='BOTTOM'">b</xsl:when>
   <xsl:when test="$FRAMEval='TOPBOT'">t b</xsl:when>
   <xsl:when test="$FRAMEval='ALL'">t b l r</xsl:when>
   <xsl:when test="$FRAMEval='NONE'"></xsl:when>
   <xsl:otherwise>
    <xsl:choose>
     <xsl:when test="$upperFRAMEval='NONE'"></xsl:when>
     <!-- No value implies ALL -->
     <xsl:otherwise>t b l r</xsl:otherwise>
    </xsl:choose>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 <xsl:template match="TABLE" xmlns="http://www.w3.org/1999/xhtml">
  <div class="normtable">
   <xsl:apply-templates select="HEADING" />
   <xsl:apply-templates select="TGROUP" />
  </div>
 </xsl:template>
 <xsl:template match="TABLE/HEADING">
  <xsl:apply-templates select="text() | processing-instruction()" />
 </xsl:template>
 <xsl:template match="TGROUP">
  <xsl:variable name="Class">
   <xsl:call-template name="getClassFromFRAME"/>
  </xsl:variable>
  <table class="{$Class}">
   <xsl:if test="$ConsiderColumnWidths='true'">
    <colgroup>
     <xsl:apply-templates select="COLSPEC" />
    </colgroup>
   </xsl:if>
   <xsl:apply-templates select="THEAD" />
   <xsl:apply-templates select="TFOOT" />
   <xsl:apply-templates select="TBODY" />
   <!--
    FIX
    date: 01|12|2006
    author: Frank Mehlhose
    IE has Problems with tables that have only one row and a colspan defined,
    so if a table consits only of one row and has a colspan, we add one row of height 1
   -->
   <xsl:if test="(count(descendant::ROW) = 1) and descendant::ENTRY/@NAMEST">
    <tr>
     <xsl:for-each select="descendant::COLSPEC">
      <td><img height="1"></img></td>
     </xsl:for-each>
    </tr>
   </xsl:if>
   <!--
    End of FIX
   -->
  </table>
 </xsl:template>
 <!-- This thing is taken from the original DSSSL, it splits the string into value and unit; then it forces the output to have only 'px' as unit -->
 <xsl:template name="calculateWidth">
  <xsl:param name="WidthString" />
  <xsl:choose>
   <xsl:when test="$WidthString='*'">
    <xsl:text>*px</xsl:text>
   </xsl:when>
   <xsl:when test="number($WidthString)">
    <xsl:value-of select="$WidthString"></xsl:value-of>
    <xsl:text>px</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:variable name="unit">
     <xsl:choose>
      <xsl:when test="contains($WidthString,'pt')">
       <xsl:text>pt</xsl:text>
      </xsl:when>
      <xsl:when test="contains($WidthString,'mm')">
       <xsl:text>mm</xsl:text>
      </xsl:when>
      <xsl:when test="contains($WidthString,'cm')">
       <xsl:text>cm</xsl:text>
      </xsl:when>
      <xsl:when test="contains($WidthString,'pi')">
       <xsl:text>pi</xsl:text>
      </xsl:when>
      <xsl:when test="contains($WidthString,'in')">
       <xsl:text>in</xsl:text>
      </xsl:when>
     </xsl:choose>
    </xsl:variable>
    <xsl:variable name="num">
     <xsl:choose>
      <xsl:when test="$unit='pt'">
       <!-- convert to px (*96/72) -->
       <xsl:value-of select="round( substring-before($WidthString,'pt') * 1.33333333333333 )" />
      </xsl:when>
      <xsl:when test="$unit='mm'">
       <!-- convert to px (*96/25.4) -->
       <xsl:value-of select="round( substring-before($WidthString,'mm') * 3.77952756 )" />
      </xsl:when>
      <xsl:when test="$unit='cm'">
       <!-- convert to px (*96/2.54) -->
       <xsl:value-of select="round( substring-before($WidthString,'cm') * 37.7952756 )" />
      </xsl:when>
      <xsl:when test="$unit='pi'">
       <!-- convert to px (*96/6) -->
       <xsl:value-of select="round( substring-before($WidthString,'pi') * 16 )" />
      </xsl:when>
      <xsl:when test="$unit='in'">
       <!-- convert to px (*96) -->
       <xsl:value-of select="round( substring-before($WidthString,'in') * 96 )" />
      </xsl:when>
     </xsl:choose>
    </xsl:variable>
    <!-- Output is in px-->
    <xsl:value-of select="$num" />
    <xsl:text>px</xsl:text>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 <xsl:template match="COLSPEC">
  <col>
   <xsl:attribute name="style">
    <xsl:text>width: </xsl:text>
    <xsl:call-template name="calculateWidth">
     <xsl:with-param name="WidthString">
      <xsl:value-of select="@COLWIDTH" />
     </xsl:with-param>
    </xsl:call-template>
   </xsl:attribute>
  </col>
 </xsl:template>
 <xsl:template match="THEAD">
  <xsl:apply-templates select="ROW" />
 </xsl:template>
 <xsl:template match="TBODY">
  <xsl:apply-templates select="ROW" />
 </xsl:template>
 <xsl:template match="TFOOT">
  <xsl:apply-templates select="ROW" />
 </xsl:template>
 <xsl:template match="ROW">
  <tr>
   <xsl:variable name="ishead">
    <xsl:choose>
     <xsl:when test="parent::THEAD">
      <xsl:text>th</xsl:text>
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>td</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <xsl:apply-templates select="ENTRY"><!-- Here we get the information about the rowseparators-->
    <xsl:with-param name="td">
     <xsl:value-of select="$ishead" />
    </xsl:with-param>
   </xsl:apply-templates>
  </tr>
 </xsl:template>

 <xsl:template match="ENTRY">
  <xsl:param name="td" select="'td'" />
  <!-- If there is an Align Attribute, use it's value, otherwise look at the parent elements-->
  <xsl:variable name="align-capital">
   <xsl:choose>
    <xsl:when test="@ALIGN">
     <xsl:value-of select="@ALIGN" />
    </xsl:when>
    <xsl:when test="ancestor::TGROUP[1]/COLSPEC[position()]/@ALIGN">
     <xsl:value-of select="ancestor::TRGOUP[1]/COLSPEC[position()]/@ALIGN" />
    </xsl:when>
    <xsl:when test="ancestor::TGROUP[1]/@ALIGN">
     <xsl:value-of select="ancestor::TGROUP[1]/@ALIGN" />
    </xsl:when>
    <xsl:otherwise></xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <!-- The XML documents are in upper case, but the align and valign attributes for td element need lowercase values-->
  <xsl:variable name="align">
   <xsl:choose>
    <xsl:when test="$align-capital='LEFT'">left</xsl:when>
    <xsl:when test="$align-capital='RIGHT'">right</xsl:when>
    <xsl:when test="$align-capital='CENTER'">center</xsl:when>
    <xsl:when test="$align-capital='JUSTIFY'">justify</xsl:when>
    <xsl:when test="$align-capital='CHAR'">char</xsl:when>
   </xsl:choose>
  </xsl:variable>
  <!-- the same as with "align" -->
  <xsl:variable name="valign-capital">
   <xsl:choose>
    <xsl:when test="@VALIGN">
     <xsl:value-of select="@VALIGN" />
    </xsl:when>
    <xsl:when test="ROW/@VALIGN">
     <xsl:value-of select="ROW/@VALIGN" />
    </xsl:when>
    <xsl:when test="parent::TBODY/@VALIGN">
     <xsl:value-of select="parent::TBODY/@VALIGN" />
    </xsl:when>
    <xsl:when test="parent::THEAD/@VALIGN">
     <xsl:value-of select="parent::THEAD/@VALIGN" />
    </xsl:when>
    <xsl:otherwise></xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="valign">
   <xsl:choose>
    <xsl:when test="$valign-capital='TOP'">top</xsl:when>
    <xsl:when test="$valign-capital='MIDDLE'">middle</xsl:when>
    <xsl:when test="$valign-capital='BOTTOM'">bottom</xsl:when>
    <xsl:when test="$valign-capital='BASELINE'">baseline</xsl:when>
   </xsl:choose>
  </xsl:variable>
  <!-- Map background color to ISTA colors (see styleguide, CR 14873) -->
  <xsl:variable name="style">
   <xsl:choose>
    <xsl:when test="@BGCOLOR='BLACK'">background-color: #000000; color: #FFFFFF</xsl:when>
    <xsl:when test="@BGCOLOR='DARKGRAY'">background-color: #666666; color: #FFFFFF</xsl:when>
    <xsl:when test="@BGCOLOR='MEDIUMGRAY'">background-color: #A9A9A9; color: #FFFFFF</xsl:when>
    <xsl:when test="@BGCOLOR='LIGHTGRAY'">background-color: #CCCCCC</xsl:when>
    <xsl:when test="@BGCOLOR='WHITE'">background-color: #FFFFFF</xsl:when>
    <xsl:when test="@BGCOLOR='RED'">background-color: #FF0000</xsl:when>
    <xsl:when test="@BGCOLOR='GREEN'">background-color: #00AD2B</xsl:when>
    <xsl:when test="@BGCOLOR='YELLOW'">background-color: #FFCC00</xsl:when>
    <xsl:when test="@BGCOLOR='BLUE'">background-color: #003399; color: #FFFFFF</xsl:when>
    <xsl:when test="@BGCOLOR='LIGHTBLUE'">background-color: #99CCFF</xsl:when>
    <xsl:when test="@BGCOLOR='CREME'">background-color: #EDE3D3</xsl:when>
    <xsl:when test="@BGCOLOR='BROWN'">background-color: #996633; color: #FFFFFF</xsl:when>
    <xsl:when test="@BGCOLOR='BLACKBERRY'">background-color: #993366; color: #FFFFFF</xsl:when>
    <xsl:when test="@BGCOLOR='BMWGROUP'">background-color: #669999</xsl:when>
    <xsl:when test="@BGCOLOR='BMW'">background-color: #003399; color: #FFFFFF</xsl:when>
    <xsl:when test="@BGCOLOR='ROLLSROYCE'">background-color: #F5F2BD</xsl:when>
    <xsl:when test="@BGCOLOR='MINI'">background-color: #FF6600</xsl:when>
   </xsl:choose>
  </xsl:variable>
  <!-- $td = th or td-->
  <!-- colspan = position of NAMEEND - position of NAMEST -->
  <xsl:element name="{$td}">
   <xsl:if test="@NAMEST">
    <xsl:attribute name="colspan">
     <xsl:variable name="namest" select="@NAMEST" />
     <xsl:variable name="nameend" select="@NAMEEND" />
     <xsl:value-of select="count(ancestor::TGROUP/COLSPEC[@COLNAME=$nameend]/preceding-sibling::COLSPEC) - count(ancestor::TGROUP/COLSPEC[@COLNAME=$namest]/preceding-sibling::COLSPEC) + 1"/>
    </xsl:attribute>
   </xsl:if>
   <!-- rowspan = Morerows + 1 -->
   <xsl:if test="@MOREROWS">
    <xsl:attribute name="rowspan">
     <xsl:value-of select="number(@MOREROWS)+1" />
    </xsl:attribute>
   </xsl:if>
   <xsl:attribute name="class">
    <!-- Calculate row separator -->
    <xsl:choose>
     <!-- No check for last row (regarding THEADER, TBODY, TFOOTER), border given with @FRAME attribute -->
     <xsl:when test="count(ancestor::ROW/following-sibling::ROW)=0 and count(ancestor::ROW/parent::*/following-sibling::*//ROW)=0"></xsl:when>
     <xsl:when test="count(ancestor::ROW/following-sibling::ROW)=number(@MOREROWS) and count(ancestor::ROW/parent::*/following-sibling::*//ROW)=0"></xsl:when>

     <!-- check value given on the cell -->
     <xsl:when test="@ROWSEP='0'"></xsl:when>
     <xsl:when test="@ROWSEP='1'">b </xsl:when>

     <!-- check value given on the row -->
     <xsl:when test="ancestor::ROW/@ROWSEP='0'"></xsl:when>
     <xsl:when test="ancestor::ROW/@ROWSEP='1'">b </xsl:when>

     <!-- check value given on the column -->
     <!--xsl:when test="ancestor::TGROUP/COLSPEC[position()]/@ROWSEP='0'"></xsl:when>
     <xsl:when test="ancestor::TGROUP/COLSPEC[position()]/@ROWSEP='1'">b </xsl:when-->

     <!-- check value given on the table body -->
     <xsl:when test="ancestor::TGROUP/@ROWSEP='0'"></xsl:when>
     <xsl:when test="ancestor::TGROUP/@ROWSEP='1'">b </xsl:when>

     <!-- No value found implies 1 -->
     <xsl:otherwise>b </xsl:otherwise>
    </xsl:choose>

    <!-- Calculate column separator -->
    <xsl:variable name="position" select="position()" />

    <!-- Check the last ENTRY of each row above wheather it is a rowspan to the current row so the current last ENTRY must show a right border-->
     <xsl:variable name="lastElemHasRowspan">
       <xsl:choose>
      <xsl:when test="count(following-sibling::ENTRY)>0">
        <xsl:value-of select="0" />
      </xsl:when>
      <xsl:when test="count(ancestor::TABLE//ENTRY[@MOREROWS and @MOREROWS!='0']) > 0 or count(ancestor::TABLE//ENTRY[@NAMEST]) > 0">
        <xsl:variable name="rowsAbove" select="count(ancestor::ROW[1]/preceding-sibling::ROW)"/>
        <xsl:for-each select="ancestor::ROW[1]/preceding-sibling::ROW/child::ENTRY[last()]">
       <xsl:variable name="currentRow" select="count(ancestor::ROW[1]/preceding-sibling::ROW)+1"/>
       <xsl:if test="$rowsAbove - $currentRow + number(@MOREROWS) >= 1">1</xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0"/>
      </xsl:otherwise>
       </xsl:choose>
    </xsl:variable>

    <xsl:choose>
     <!-- check value given on the cell -->
     <xsl:when test="@COLSEP='0'"></xsl:when>

     <!-- check value for merged cells -->
     <xsl:when test="@NAMEST">
      <xsl:variable name="namest" select="@NAMEST" />
      <xsl:variable name="nameend" select="@NAMEEND" />

      <xsl:choose>
       <!-- No check for last column, border given with @FRAME attribute -->
       <xsl:when test="count(ancestor::TGROUP/COLSPEC[@COLNAME=$nameend]/following-sibling::COLSPEC)=0"></xsl:when>

       <!-- check value given on the cell -->
       <xsl:when test="@COLSEP='1'">r </xsl:when>

       <!-- check value given on the column -->
       <xsl:when test="ancestor::TGROUP/COLSPEC[@COLNAME=$namest]/@COLSEP='0'"></xsl:when>
       <xsl:when test="ancestor::TGROUP/COLSPEC[@COLNAME=$nameend]/@COLSEP='1'">r </xsl:when>

       <!-- check value given on the table body -->
       <xsl:when test="ancestor::TGROUP/@COLSEP='0'"></xsl:when>
       <xsl:when test="ancestor::TGROUP/@COLSEP='1'">r </xsl:when>

       <!-- No value given implies 1 -->
       <xsl:otherwise>r </xsl:otherwise>
      </xsl:choose>
     </xsl:when>

     <!-- check for one before last column, when last column is a rowspan from the above rows -->
     <xsl:when test="count(following-sibling::ENTRY)=0 and $lastElemHasRowspan>0">r </xsl:when>

     <!-- No check for last column, border given with @FRAME attribute -->
     <xsl:when test="count(following-sibling::ENTRY)=0"></xsl:when>

     <!-- check value given on the cell -->
     <xsl:when test="@COLSEP='1'">r </xsl:when>

     <!-- check value given on the column -->
     <xsl:when test="ancestor::TGROUP/COLSPEC[$position]/@COLSEP='0'"></xsl:when>
     <xsl:when test="ancestor::TGROUP/COLSPEC[$position]/@COLSEP='1'">r </xsl:when>

     <!-- check value given on the table body -->
     <xsl:when test="ancestor::TGROUP/@COLSEP='0'"></xsl:when>
     <xsl:when test="ancestor::TGROUP/@COLSEP='1'">r </xsl:when>

     <!-- No value given implies 1 -->
     <xsl:otherwise>r </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>
   <xsl:if test="$valign!=''">
    <xsl:attribute name="valign">
     <xsl:value-of select="$valign" />
    </xsl:attribute>
   </xsl:if>
   <xsl:if test="$align!=''">
    <xsl:attribute name="align">
     <xsl:value-of select="$align" />
    </xsl:attribute>
   </xsl:if>
   <xsl:if test="$style!=''">
    <xsl:attribute name="style">
     <xsl:value-of select="$style" />
    </xsl:attribute>
   </xsl:if>
   <!-- display also rows that have no entry with values -->
   <xsl:choose>
    <xsl:when test="descendant::text() or descendant::processing-instruction() or count(//GRAPHIC) > 0">
     <xsl:apply-templates select="*" />
    </xsl:when>
    <xsl:otherwise><!-- Empty Cells get one div with an whitepace -->
     <div style="display:block; height:1pt;">
     <![CDATA[ ]]>
     </div>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:element>
 </xsl:template>
 <!-- LIST -->
 <!--
  each type of list has its own style definition
 -->
 <xsl:template match="LIST" xmlns="http://www.w3.org/1999/xhtml">
  <xsl:if test="count(TITLE)>0">
   <p class="listtitle">
    <xsl:apply-templates select="TITLE"/>
   </p>
  </xsl:if>
  <div class="list">
  <xsl:choose>
   <xsl:when test="@TYPE='BULLET' or @LISTTYPE='BULLET'">
    <ul class="list-bullet">
     <xsl:for-each select="LISTENTRY | LISTELEMENT">
      <li class="listentry-bullet">
       <xsl:apply-templates select="*" />
      </li>
     </xsl:for-each>
    </ul>
   </xsl:when>
   <xsl:when test="@TYPE='DASH'">
    <table class="list-dash">
     <xsl:for-each select="LISTENTRY">
      <tr>
       <td class="listbullet-dash">-</td>
       <td class="listentry-dash">
        <xsl:apply-templates select="*" />
       </td>
      </tr>
     </xsl:for-each>
    </table>
   </xsl:when>
   <xsl:when test="@TYPE='ARABIC' or @LISTTYPE='NUMBER'">
    <ol class="list-decimal">
     <xsl:for-each select="LISTENTRY | LISTELEMENT">
      <li class="listentry-decimal">
       <xsl:apply-templates select="*" />
      </li>
     </xsl:for-each>
    </ol>
   </xsl:when>
   <xsl:when test="@TYPE='LOWERROMAN'">
    <ol class="list-lowerroman">
     <xsl:for-each select="LISTENTRY">
      <li class="listenentry-lowerroman">
       <xsl:apply-templates select="*" />
      </li>
     </xsl:for-each>
    </ol>
   </xsl:when>
   <xsl:when test="@TYPE='UPPERROMAN'">
    <ol class="list-upperroman">
     <xsl:for-each select="LISTENTRY">
      <li class="listentry-upperroman">
       <xsl:apply-templates select="*" />
      </li>
     </xsl:for-each>
    </ol>
   </xsl:when>
   <xsl:when test="@TYPE='LOWERALPHA'">
    <ol class="list-loweralpha">
     <xsl:for-each select="LISTENTRY">
      <li class="listentry-loweralpha">
       <xsl:apply-templates select="*" />
      </li>
     </xsl:for-each>
    </ol>
   </xsl:when>
   <xsl:when test="@TYPE='UPPERALPHA'">
    <ol class="list-upperalpha">
     <xsl:for-each select="LISTENTRY">
      <li class="listentry-upperalpha">
       <xsl:apply-templates select="*" />
      </li>
     </xsl:for-each>
    </ol>
   </xsl:when>
  </xsl:choose>
  </div>
 </xsl:template>
 <!-- GENERALLIST-->
 <!-- represents user lists with user defined labels -->
 <!-- Generallist is displayed as an table -->
 <xsl:template match="GENERALLIST" xmlns="http://www.w3.org/1999/xhtml">
  <xsl:if test="count(TITLE)>0">
   <p class="listtitle">
    <xsl:apply-templates select="TITLE"/>
   </p>
  </xsl:if>
  <table class="gen-table">
   <xsl:apply-templates select="LISTELEMENT" />
  </table>
 </xsl:template>
 <xsl:template match="GENERALLIST/LISTELEMENT" xmlns="http://www.w3.org/1999/xhtml">
  <tr class="gen-tr">
   <td class="gen-td-l">
    <xsl:apply-templates select="LABEL" />
   </td>
   <td class="gen-td-r">
    <xsl:apply-templates select="PARAGRAPH | LIST | GENERALLIST | FORMULA | ICON" />
   </td>
  </tr>
 </xsl:template>
 <!-- Graphics -->
 <xsl:template match="GRAPHIC">
  <xsl:variable name="linkid" select="@LINKID" />
  <span class="img-with-zoom" xmlns="http://www.w3.org/1999/xhtml">
   <xsl:attribute name="class">
    <!-- Force a size if a Graphicsize attribute exists, otherwise take original 
				size -->
    <xsl:choose>
     <xsl:when test="../@GRAPHICSIZE='SMALL'">
      <xsl:text>img-with-zoom-small</xsl:text>
     </xsl:when>
     <xsl:when test="../@GRAPHICSIZE='MEDIUM'">
      <xsl:text>img-with-zoom-medium</xsl:text>
     </xsl:when>
     <xsl:when test="../@GRAPHICSIZE='LARGE'">
      <xsl:text>img-with-zoom-large</xsl:text>
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>img-with-zoom</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>
   <xsl:variable name="mylink"
    select="ancestor::slave/links/link[contains(concat($linkIdSeparator,@linkid,$linkIdSeparator),concat($linkIdSeparator,$linkid,$linkIdSeparator))]" />
   <!-- Add anchor for deep links -->
   <xsl:element name="a">
    <xsl:attribute name="name">
     <xsl:value-of select="$linkid" />
    </xsl:attribute>
   </xsl:element>
   <a>
    <xsl:choose>
     <xsl:when test="count($mylink) &gt; 0">
      <xsl:variable name="zoomurl">
       <xsl:value-of select="$mylink/@zoomurl" />
      </xsl:variable>
      <xsl:if test="string-length($zoomurl) &gt; 0">
       <xsl:attribute name="href">
        <xsl:value-of select="$zoomurl" />
       </xsl:attribute>
      </xsl:if>
     </xsl:when>
    </xsl:choose>
    <img xmlns="">
	<!-- set Graphic border to 0 for ISAR -->
	 <xsl:variable name="ISTA_SCRIPT" select="ancestor::slave/script/@content" />
		<xsl:if test="count($ISTA_SCRIPT) = 0">
			<xsl:attribute name="class">
				<xsl:text>imgWithoutLink</xsl:text>
			</xsl:attribute>
		</xsl:if>
     <xsl:attribute name="alt">
      <xsl:value-of select="@GRAPHICID" />
     </xsl:attribute>
     <xsl:choose>
      <xsl:when test="count($mylink) &gt; 0">
       <xsl:attribute name="src">
        <xsl:value-of select="$mylink/@url" />
       </xsl:attribute>
      </xsl:when>
     </xsl:choose>
    </img>
   </a>
  </span>
 </xsl:template>
 
 <!-- HOTSPOT und REFERENCE -->
 <xsl:template match="REFERENCE" xmlns="http://www.w3.org/1999/xhtml">
 <xsl:variable name="linkid"><xsl:value-of select="@LINKID" /></xsl:variable>
 <xsl:variable name="mylink" select="ancestor::slave/links/link[contains(concat($linkIdSeparator,@linkid,$linkIdSeparator),concat($linkIdSeparator,$linkid,$linkIdSeparator))]"/>
 <xsl:choose>
  <!-- check if we have any target information for this link.
       if so, format it as hotspot. if not, format it as normal text.
  -->
  <xsl:when test="count($mylink) &gt; 0">
  <a class="reference" >
   <xsl:attribute name="href">
    <xsl:value-of select="$mylink/@url" />
   </xsl:attribute>
   <xsl:apply-templates select="text() | processing-instruction()" />
  </a>
  </xsl:when>
  <xsl:otherwise>
   <xsl:apply-templates select="text() | processing-instruction()" />
  </xsl:otherwise>
 </xsl:choose>
 </xsl:template>

 <xsl:template match="HOTSPOT" xmlns="http://www.w3.org/1999/xhtml">
 <xsl:variable name="linkid"><xsl:value-of select="@LINKID" /></xsl:variable>
 <xsl:variable name="mylink" select="ancestor::slave/links/link[contains(concat($linkIdSeparator,@linkid,$linkIdSeparator),concat($linkIdSeparator,$linkid,$linkIdSeparator))]"/>
 <xsl:choose>
  <!-- check if we have any target information for this link.
       if so, format it as hotspot. if not, format it as normal text.
  -->
  <xsl:when test="count($mylink) &gt; 0">
  <a class="hotspot" >
   <xsl:attribute name="href">
    <xsl:value-of select="$mylink/@url" />
   </xsl:attribute>
   <xsl:apply-templates select="text() | processing-instruction()" />
  </a>
  </xsl:when>
  <xsl:otherwise>
   <xsl:apply-templates select="text() | processing-instruction()" />
  </xsl:otherwise>
 </xsl:choose>
 </xsl:template>

 <!-- handling the processing instruction that represent linebreaks, normal linebreaks are exchanged for whitespaces in a transformation,
    so we represent linebreaks by <?linebreak?> and write an <br /> in the output
  -->
 <xsl:template match="processing-instruction()" xmlns="http://www.w3.org/1999/xhtml">
  <xsl:if test="name()='linebreak'">
   <br />
  </xsl:if>
 </xsl:template>

 <!--
   Add version of common XHTML library to HTML output (used for error handling)
 -->
 <xsl:template name="LibXHTML_PrintVersion">
  <xsl:comment> BMW_XSLT_LibXHTML_1.0.xslt,v 1.20.2.5 2011-03-01 14:14:14 woehrle Exp </xsl:comment>
 </xsl:template>
<!-- BOF BMW_XSLT_LibXHTML_1.0.xslt -->

 <xsl:template match="TIGHTENINGTORQUES" xmlns="http://www.w3.org/1999/xhtml">
  <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="{@LANGUAGE}" lang="{@LANGUAGE}">
   <xsl:comment> BMW_XSLT_TighteningTorques2XHTML_1.0.xslt,v 1.8 2010-05-04 13:55:35 mandeld Exp </xsl:comment>
   <xsl:call-template name="LibXHTML_PrintVersion" />
   <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, user-scalable=no, viewport-fit=cover"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta http-equiv="cache-control" content="no-cache, no-store, must-revalidate"/>
    <meta http-equiv="expires" content="0"/>
    <meta http-equiv="pragma" content="no-cache"/>
    <link rel="shortcut icon" href="./favicon.ico" type="image/x-icon"/>
    <link href="../../../assets/scss/AZD-AZD-XML-1.css" rel="stylesheet" type="text/css"/>
    <script src="../../../assets/script/jquery-2.1.0.min.js" language="javascript"/>
    <title>
		AZD-
      <xsl:comment></xsl:comment>
     <xsl:value-of select="SUBGROUPTITLE/SUBGROUPNAME" />
     <xsl:value-of select="$leerzeichen" />
     <xsl:value-of select="SUBGROUPTITLE/SUBGROUPADDITION" />
    </title>
     <xsl:call-template name="ISTA_SCRIPTS" />
   </head>
   <body>
    <!-- set scroll attribute in ISAR to yes and in ISTA to no-->
	  <xsl:attribute name="scroll">
		  <xsl:variable name="ISTA_SCRIPT" select="ancestor::slave/script/@content" />
		  <xsl:choose>
		<xsl:when test="count($ISTA_SCRIPT) > 0">
		  <xsl:text>no</xsl:text>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:text>yes</xsl:text>
		</xsl:otherwise>
		</xsl:choose>
	  </xsl:attribute>

    <div class="title">
     <xsl:value-of select="TITLE/MAINGROUPNUMBER" />
     <xsl:value-of select="$leerzeichen" />
     <xsl:value-of select="SUBGROUPTITLE/SUBGROUPNUMBER" />
     <xsl:value-of select="$leerzeichen" />
     <xsl:value-of select="SUBGROUPTITLE/SUBGROUPNAME" />
     <xsl:value-of select="$leerzeichen" />
     <xsl:value-of select="SUBGROUPTITLE/SUBGROUPADDITION" />
    </div>
    <xsl:apply-templates select="TABLE" />
    <script src="../../../assets/script/import-entry11.js" defer="true" language="javascript"/>
   </body>
  </html>
 </xsl:template>

 <xsl:template match="TITLE">
  <!-- EMPTY -->
 </xsl:template>

 <xsl:template match="VALIDITY">
  <xsl:apply-templates select="SERIES" />
  <xsl:apply-templates select="ENGINE" />
  <xsl:apply-templates select="TRANSMISSION" />
  <xsl:apply-templates select="MODEL" />
  <xsl:apply-templates select="BODY" />
  <xsl:apply-templates select="ADDITION" />
  <xsl:choose>
   <xsl:when test="count(following-sibling::VALIDITY)>0">
    <xsl:text>, </xsl:text>
   </xsl:when>
  </xsl:choose>
 </xsl:template>

 <!-- The templates have to check if there a preceding elements, and from which type the preceding elements are. Then we can decide
  if, and which character is used between the elements
  -->
 <xsl:template match="SERIES">
  <xsl:choose>
   <xsl:when test="count(preceding-sibling::*)>0">
    <xsl:text> / </xsl:text>
    <xsl:apply-templates select="text() | processing-instruction()" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$leerzeichen" />
    <xsl:apply-templates select="text() | processing-instruction()" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 <xsl:template match="ENGINE">
  <xsl:choose>
   <xsl:when test="count(preceding-sibling::*)>0">
    <xsl:text> / </xsl:text>
    <xsl:apply-templates select="text() | processing-instruction()" />
   </xsl:when>
   <xsl:otherwise>
   <xsl:value-of select="$leerzeichen" />
    <xsl:apply-templates select="text() | processing-instruction()" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 <xsl:template match="TRANSMISSION">
  <xsl:choose>
   <xsl:when test="count(preceding-sibling::*)>0">
    <xsl:text> / </xsl:text>
    <xsl:apply-templates select="text() | processing-instruction()" />
   </xsl:when>
   <xsl:otherwise>
   <xsl:value-of select="$leerzeichen" />
    <xsl:apply-templates select="text() | processing-instruction()" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 <xsl:template match="MODEL">
  <xsl:choose>
   <xsl:when test="count(preceding-sibling::*)>0">
    <xsl:text> / </xsl:text>
    <xsl:apply-templates select="text() | processing-instruction()" />
   </xsl:when>
   <xsl:otherwise>
   <xsl:value-of select="$leerzeichen" />
    <xsl:apply-templates select="text() | processing-instruction()" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 <xsl:template match="BODY">
  <xsl:choose>
   <xsl:when test="count(preceding-sibling::*)>0">
    <xsl:text> / </xsl:text>
    <xsl:apply-templates select="text() | processing-instruction()" />
   </xsl:when>
   <xsl:otherwise>
   <xsl:value-of select="$leerzeichen" />
    <xsl:apply-templates select="text() | processing-instruction()" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 <xsl:template match="ADDITION">
  <xsl:choose>
   <xsl:when test="count(preceding-sibling::*)>0">
    <xsl:text> / </xsl:text>
    <xsl:apply-templates select="text() | processing-instruction()" />
   </xsl:when>
   <xsl:otherwise>
   <xsl:value-of select="$leerzeichen" />
    <xsl:apply-templates select="text() | processing-instruction()" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 <xsl:template match="TYPEHEADER">
  <div class="header">
   <xsl:apply-templates select="text() | processing-instruction()" />
  </div>
 </xsl:template>
 <xsl:template match="SCREWHEADER">
  <div class="header">
   <xsl:apply-templates select="text() | processing-instruction()" />
  </div>
 </xsl:template>
 <xsl:template match="OPERATINGHEADER">
  <div class="header">
   <xsl:apply-templates select="text() | processing-instruction()" />
  </div>
 </xsl:template>
 <xsl:template match="TORQUEHEADER">
  <div class="header">
   <xsl:apply-templates select="text() | processing-instruction()" />
  </div>
 </xsl:template>
 <xsl:template match="RELATION">
  <table>
   <tr>
    <td class="address"><xsl:apply-templates select="ADDRESS" /></td>
    <td class="paragraph"><xsl:apply-templates select="PARAGRAPH" /></td>
   </tr>
  </table>
 </xsl:template>
 <xsl:template match="ADDRESS">
  <xsl:apply-templates select="text() | processing-instruction()" />
 </xsl:template>
 <xsl:template match="SCREW">
  <span>
   <xsl:apply-templates select="text() | processing-instruction()" />
  </span>
 </xsl:template>
 <xsl:template match="TORQUE">
  <span class="paragraph_measure">
   <xsl:apply-templates select="MEASURE" />
   <xsl:value-of select="$leerzeichen" />
   <xsl:apply-templates select="UNIT" />
  </span>
 </xsl:template>
 <xsl:template match="MEASURE">
  <xsl:apply-templates select="PARAGRAPH" mode="measure"/>
 </xsl:template>
 <xsl:template match="PARAGRAPH" mode="measure">
  <xsl:apply-templates select="text() | HOTSPOT | REFERENCE 
     | FOOTNOTE | SUPERSCRIPT | SUBSCRIPT | processing-instruction()" />
 </xsl:template>
 <xsl:template match="OPERATINGSTEP">
  <xsl:apply-templates select="PARAGRAPH" />
 </xsl:template>
 <xsl:template match="VALIDITIES">
  <xsl:apply-templates select="VALIDITY" />
 </xsl:template>
 <xsl:template match="UNIT">
  <xsl:apply-templates select="text() | processing-instruction()" />
 </xsl:template>
 <xsl:template match="PARAGRAPH">
  <p class="paragraph">
  <xsl:apply-templates select="text() | HOTSPOT | REFERENCE 
     | FOOTNOTE | SUPERSCRIPT | SUBSCRIPT | processing-instruction()" />
  </p>
 </xsl:template>
 <xsl:template match="SUBSCRIPT">
  <span class="subscript">
   <xsl:apply-templates select="text() | processing-instruction()" />
  </span>
 </xsl:template>
 <xsl:template match="SUPERSCRIPT">
  <span class="superscript">
   <xsl:apply-templates select="text() | processing-instruction()" />
  </span>
 </xsl:template>
 <xsl:template match="FOOTNOTE">
  <span class="footnote">
   <xsl:apply-templates select="text() | processing-instruction()" />
  </span>
 </xsl:template>
 <xsl:template match="MAINGROUPNUMBER">
  <!-- EMPTY --></xsl:template>
 <xsl:template match="MAINGROUPNAME">
  <!-- EMPTY --></xsl:template>
 <xsl:template match="SUBGROUPTITLE">
  <!-- EMPTY --></xsl:template>
 <xsl:template match="SUBGROUPNUMBER">
  <!-- EMPTY --></xsl:template>
 <xsl:template match="SUBGROUPNAME">
  <!-- EMPTY --></xsl:template>
 <xsl:template match="SUBGROUPADDITION">
  <!-- EMPTY --></xsl:template>

  <xsl:template name="ISTA_SCRIPTS">
    <xsl:variable name="ISTA_SCRIPT" select="ancestor::slave/script/@content" />
    <xsl:if test="count($ISTA_SCRIPT) > 0">
      <xsl:text disable-output-escaping="yes"> 
         <![CDATA[ 
            <script type="text/javascript"> 
         ]]> 
      </xsl:text>

      <xsl:value-of select="$ISTA_SCRIPT"/>

      <xsl:text disable-output-escaping="yes"> 
        <![CDATA[ 
              </script> 
         ]]>   
      </xsl:text>
    </xsl:if>
  </xsl:template>
<!-- EOF BMW_XSLT_TighteningTorques2XHTML_1.0.xslt -->
</xsl:stylesheet>
