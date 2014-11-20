<xsl:stylesheet version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:msxsl="urn:schemas-microsoft-com:xslt"
   exclude-result-prefixes="msxsl mdo"
   xmlns:mdo="urn:mdo"
>
    <!--
    EasyWiki jQueryLayout Extension 01.00.00
    (c) Alberto Velo, 2011 - http://albe.ihnet.it/EasyWiki
    cfr http://layout.jquery-dev.net
-->
    <xsl:output method="html" indent="yes" omit-xml-declaration="yes"/>
    <!--
        EasyWiki params
        extension = 'jquerylayout'
    -->
    <xsl:param name="wikipage"/>
    <xsl:param name="wikifolder"/>
    <xsl:param name="extension"/>
    <xsl:param name="apppath"/>
    <xsl:param name="httpalias"/>
    <!--
	    jQueryLayout extension params
	-->
    <xsl:param name="layout"/>
    <!--
        jQueryLayout Extension implementation
    -->
    <xsl:template match="/">
        <mdo:header position="page">
            <script type="text/javascript" src="{concat($apppath, 'DesktopModules/EasyWiki/js/jquery.layout-latest.js')}"></script>
            <script type="text/javascript" src="{concat($apppath,'Portals/_default/js/ui/jquery-ui-1.8.5.custom.min.js')}"></script>
            <style type="text/css">
                .easywikijlayout{height:100%; min-height:200px; overflow: visible !important;}
            </style>
        </mdo:header>
        <script type="text/javascript">
            var jql;
            var jQueryLayout={
            applyDefaultStyles: true,
            name:"jQueryLayout",
            scrollToBookmarkOnLoad: false,
            defaults:{
            applyDemoStyles: true,
            resizable: true
            },
            center:{size:"600"}};
            $(function(){
            jql = $('.easywikijlayout').layout(jQueryLayout);
            });</script>
    </xsl:template>
</xsl:stylesheet>

