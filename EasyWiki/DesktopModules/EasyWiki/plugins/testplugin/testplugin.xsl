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
   	<xsl:template match="/">
        <xsl:variable name="curpage">
            <xsl:choose>
                <xsl:when test="mdo:param('@page')!=''">{{mdo:param('@page')}}</xsl:when>
                <xsl:when test="mdo:request('page')!=''">{{mdo:request('page')}}</xsl:when>
                <xsl:otherwise>{{$wikipage}}</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <a href="{mdo:jajax('@page', $curpage, '@test1', 'ciao test1' )}">TEST</a>
        PAGE-VALUE: {{mdo:param('@page')}}<br></br>
        TEST-VALUE: {{mdo:param('@test1')}}<br></br>
        <br></br>$wikipage = {{$wikipage}} (request-page: {{mdo:request('page')}} ), (param@page: {{mdo:param('@page')}} )
    </xsl:template>
</xsl:stylesheet>