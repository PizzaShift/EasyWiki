<xsl:stylesheet version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:msxsl="urn:schemas-microsoft-com:xslt"
   exclude-result-prefixes="msxsl mdo"
   xmlns:mdo="urn:mdo"
>
    <!--
    EasyWiki XMenu (DDRMenu) Extension 01.00.00
    (c) Alberto Velo, 2011 - http://albe.ihnet.it/EasyWiki
-->
    <xsl:output method="html" indent="yes" omit-xml-declaration="yes"/>
    <!--
        EasyWiki params
        extension = 'XMenu'
    -->
    <xsl:param name="wikipage"/>
    <xsl:param name="wikifolder"/>
    <xsl:param name="extension"/>
    <xsl:param name="apppath"/>
    <!--
	    XMenu extension params
	    ProviderName
	-->
    <xsl:param name="ProviderName" xml:space="preserve" />
    <xsl:param name="MenuStyle"/>
	<xsl:param name="NodeSelector"/>
	<xsl:param name="IncludeNodes"/>
	<xsl:param name="ExcludeNodes"/>
    <!--
        XMenu Extension implementation
    -->
    <xsl:template match="/">
        <!-- mdo:ajax-enabled current page handler -->
        <xsl:variable name="curpage">
            <xsl:choose>
                <xsl:when test="mdo:param('@page')!=''">{{mdo:param('@page')}}</xsl:when>
                <xsl:when test="mdo:request('page')!=''">{{mdo:request('page')}}</xsl:when>
                <xsl:otherwise>{{$wikipage}}</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text disable-output-escaping="yes">
		<!-- 
		cfr http://www.dotnetnuke.com/Resources/Wiki/Page/DDRMenu-reference-guide.aspx 
		-->
		<![CDATA[
		<%@ Register TagPrefix="ddr" TagName="MENU" src="~/DesktopModules/DDRMenu/Menu.ascx" %>
		]]>
		</xsl:text>
		<mdo:asp xmlns:asp="asp" xmlns:telerik="telerik" xmlns:ddr="ddr">
            <xsl:choose>
                <xsl:when test="$ProviderName!=''">
                    <ddr:MENU MenuStyle="{$MenuStyle}" runat="server" ProviderName="{$ProviderName}" NodeSelector="{$NodeSelector}" IncludeNodes="{$IncludeNodes}" ExcludeNodes="{$ExcludeNodes}" />
                </xsl:when>
                <xsl:otherwise>
                    <ddr:MENU MenuStyle="{$MenuStyle}" runat="server" NodeSelector="-1" IncludeNodes="{$IncludeNodes}" ExcludeNodes="{$ExcludeNodes}" />
                </xsl:otherwise>
            </xsl:choose>
        </mdo:asp>
    </xsl:template>
</xsl:stylesheet>