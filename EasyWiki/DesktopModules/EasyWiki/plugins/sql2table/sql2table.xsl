<xsl:stylesheet version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:msxsl="urn:schemas-microsoft-com:xslt"
   exclude-result-prefixes="msxsl mdo"
   xmlns:mdo="urn:mdo"
>
    <!--
    EasyWiki SQL2Table Extension 01.00.00
    (c) Alberto Velo, 2011 - http://albe.ihnet.it/EasyWiki
-->
    <xsl:output method="text" omit-xml-declaration="yes"/>
    <!--
        EasyWiki params
        extension = 'sql2table'
    -->
    <xsl:param name="wikipage"/>
    <xsl:param name="wikifolder"/>
    <xsl:param name="extension"/>
    <xsl:param name="apppath"/>
    <!--
	    SQL2Table extension params
	    select: sql query
	-->
    <xsl:param name="select" xml:space="preserve" />
    <xsl:param name="showrn"/>
    <!--
        SQL2Table Extension implementation
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
        \\
        <!-- table header -->
        <xsl:if test="$showrn='yes'">|= N.</xsl:if> <xsl:for-each select="mdo:node-set($columns)//col">|={{.}}</xsl:for-each> \\
        <xsl:variable name="numCols" select="count(mdo:node-set($columns)//col)"></xsl:variable>
        <!-- data -->
        <xsl:for-each select="mdo:node-set($rs)//tab">
            <xsl:variable name="n" select="."></xsl:variable>
            <xsl:if test="$showrn='yes'">| {{position()}}</xsl:if> <xsl:for-each select="mdo:sequence(1,$numCols,1)">| {{$n/*[current()=position()]}}</xsl:for-each> |
        </xsl:for-each>
        \\
    </xsl:template>
</xsl:stylesheet>