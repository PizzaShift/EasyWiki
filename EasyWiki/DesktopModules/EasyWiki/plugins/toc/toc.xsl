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
    <xsl:param name="level"/>
    <xsl:template match="/">
        <!--
            EasyWiki TOC Extension 01.00.00
            (c) Alberto Velo, 2011 - http://albe.ihnet.it/EasyWiki
        -->
        <mdo:header position="page">
            <script type="text/javascript" src="{concat($apppath, 'DesktopModules/EasyWiki/js/jquery.toc-0.1.js')}"></script>
        </mdo:header>
      <xsl:variable name="tocid" select="mdo:rnd()"></xsl:variable>
        <div id="tocdiv"></div>
        <xsl:variable name="nLevel">
            <xsl:choose>
                <xsl:when test="not($level) or $level=''">3</xsl:when>
                <xsl:otherwise>{{number($level)}}</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sLevel">
            <xsl:for-each select="mdo:sequence(1, number($nLevel), 1)">
                .easywiki h{{current()}}<xsl:if test="current()&lt;number($nLevel)">,</xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <script type="text/javascript">
          $(function(){ $.toc('{{$sLevel}}').appendTo('#tocdiv'); });</script>
    </xsl:template>
</xsl:stylesheet>