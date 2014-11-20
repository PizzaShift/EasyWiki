<xsl:stylesheet version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:msxsl="urn:schemas-microsoft-com:xslt"
   exclude-result-prefixes="msxsl mdo"
   xmlns:mdo="urn:mdo"
>
    <!--
    EasyWiki sql2htmltable Extension 01.00.00
    (c) Alberto Velo, 2011 - http://albe.ihnet.it/EasyWiki
-->
    <xsl:output method="html" omit-xml-declaration="yes"/>
    <!--
        EasyWiki params
        extension = 'sql2htmltable'
    -->
    <xsl:param name="wikipage"/>
    <xsl:param name="wikifolder"/>
    <xsl:param name="extension"/>
    <xsl:param name="apppath"/>
    <!--
	    sql2htmltable extension params
	    select: sql query
	-->
    <xsl:param name="select" xml:space="preserve" />
    <xsl:param name="showrn"/>
    <!--
        sql2htmltable Extension implementation
    -->
    <xsl:template match="/">
        <xsl:variable name="dataset" select="mdo:sql($select, 'tab')"/>
        <xsl:variable name="rs">
            <xsl:copy-of select="$dataset"/>
        </xsl:variable>
        <xsl:variable name="columns">
            <columns>
                <xsl:for-each select="$dataset//tab/*">
                    <xsl:if test="not(preceding::tab/*[name(.)=name(current())])">
                        <col>{{mdo:ToProperCase(name(.))}}</col>
                    </xsl:if>
                </xsl:for-each>
            </columns>
        </xsl:variable>
        <table>
            <!-- table header -->
            <thead>
                <tr>
                    <xsl:if test="$showrn='yes'">
                        <th>N.</th>
                    </xsl:if>
                    <xsl:for-each select="mdo:node-set($columns)//col">
                        <th>{{.}}</th>
                    </xsl:for-each>
                </tr>
            </thead>
            <xsl:variable name="numCols" select="count(mdo:node-set($columns)//col)"></xsl:variable>
            <!-- table data -->
            <tbody>
                <xsl:for-each select="mdo:node-set($rs)//tab">
                    <xsl:variable name="n" select="."></xsl:variable>
                    <xsl:variable name="style">
                        <xsl:choose>
                            <xsl:when test="position() mod 2 = 1">#fff;</xsl:when>
                            <xsl:otherwise>#eee;</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <tr style="background-color:{$style}">
                        <xsl:if test="$showrn='yes'">
                            <td>{{position()}}</td>
                        </xsl:if>
                        <xsl:for-each select="mdo:sequence(1,$numCols,1)">
                            <td>{{$n/*[current()=position()]}}</td>
                        </xsl:for-each>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>
</xsl:stylesheet>