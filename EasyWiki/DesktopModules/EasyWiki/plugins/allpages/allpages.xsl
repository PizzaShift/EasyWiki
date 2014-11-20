<xsl:stylesheet version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:msxsl="urn:schemas-microsoft-com:xslt"
   exclude-result-prefixes="msxsl mdo"
   xmlns:mdo="urn:mdo"
>
    <xsl:output method="html" indent="yes" omit-xml-declaration="yes"/>
    <xsl:param name="wikipage"/>
    <xsl:param name="wikifolder"/>
    <xsl:param name="extension"/>
    <xsl:param name="apppath"/>
    <xsl:param name="mode"/>
	<xsl:param name="id"/>
    <xsl:template match="/">
        <!--
            EasyWiki AllPages Extension 01.00.01
            (c) Alberto Velo, 2011 - http://albe.ihnet.it/EasyWiki
            Build index of all pages
            mode = 'listmenu' or empty -> listmenu, other name -> plain UL
        -->
		<xsl:variable name="myID">
            <xsl:choose>
                <xsl:when test="$id!=''">{{$id}}</xsl:when>
                <xsl:otherwise>ewAllPages{{mdo:rnd()}}</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
		<xsl:if test="$mode='' or $mode='listmenu'">
        <mdo:header position="page">
            <script type="text/javascript" src="{concat($apppath, 'DesktopModules/EasyWiki/js/jquery.listmenu.min-1.1.js')}"></script>
        </mdo:header>
        <script type="text/javascript">$(function(){ $('#{{$myID}}').show('fast').listmenu({includeNums: true, includeOther: true, showCounts: false, noMatchText: 'No pages under this letter',  cols:{ count:5, gutter:10 } }); });</script>
		</xsl:if>
        <ul id="{$myID}">
		<xsl:if test="$mode='' or $mode='listmenu'">
			<xsl:attribute name="style">display:none;</xsl:attribute>
		</xsl:if>
            <xsl:for-each select="mdo:ew_getallpages()//page">
                <li>
                    <xsl:choose>
                        <xsl:when test="@name=$wikipage">
                        <!-- this page -->
                            <b>{{@name}}</b>
                        </xsl:when>
                        <xsl:otherwise>
                            <a href="{mdo:ew_pageurl(@name)}">{{@name}}</a>
                        </xsl:otherwise>
                    </xsl:choose>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
</xsl:stylesheet>