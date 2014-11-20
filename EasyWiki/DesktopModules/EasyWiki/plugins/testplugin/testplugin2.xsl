<xsl:stylesheet version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:msxsl="urn:schemas-microsoft-com:xslt"
   exclude-result-prefixes="msxsl mdo"
   xmlns:mdo="urn:mdo"
>
    <mdo:callable js="Sgrunt(p)" type="text/html">
        <xsl:template match="/">
            <xsl:variable name="rc" select="mdo:ew_pageurl(mdo:request('pagename'))"></xsl:variable>
            ew_pageurl:{{$rc}}
        </xsl:template>
    </mdo:callable>
    <xsl:output method="html" indent="yes" omit-xml-declaration="yes"/>
    <xsl:param name="wikipage"/>
	<xsl:param name="wikifolder"/>
	<xsl:param name="extension"/>
	<xsl:param name="apppath"/>
   	<xsl:template match="/" name="testplugin2">
        <script type="text/javascript">
            function test1()
            {
            var s = Sgrunt('Host');
            alert(s);
            }
        </script>
        Hello Sgrunt Test: <a onclick="javascript:test1();">CLick Sgrunt test1</a>
    </xsl:template>
</xsl:stylesheet>