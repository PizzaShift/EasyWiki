<xsl:stylesheet version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:msxsl="urn:schemas-microsoft-com:xslt"
   exclude-result-prefixes="msxsl mdo"
   xmlns:mdo="urn:mdo"
>
    <!--
    EasyWiki Freemind Extension 01.00.00
    (c) Alberto Velo, 2011 - http://albe.ihnet.it/EasyWiki
-->
    <xsl:output method="html" indent="yes" omit-xml-declaration="yes"/>
    <!--
        EasyWiki params
        extension = 'freemind'
    -->
    <xsl:param name="wikipage"/>
    <xsl:param name="wikifolder"/>
    <xsl:param name="extension"/>
    <xsl:param name="apppath"/>
    <xsl:param name="httpalias"/>
    <!--
	    freemind extension params
	-->
    <xsl:param name="map"/>
    <!--
        freemind Extension implementation
    -->
	<xsl:variable name="smap">
        <xsl:choose>
            <xsl:when test="$map=''">http://rolandog.com/freemind/Polietileno.mm</xsl:when>
            <xsl:when test="substring($map, 1, 4)='http'">{{$map}}</xsl:when>
            <xsl:otherwise>{{$httpalias}}{{$map}}</xsl:otherwise>
        </xsl:choose>
	</xsl:variable>
    <xsl:template match="/">
        Map: [[{{$smap}}]]<br/>
        <!--[if !IE]>--> 
<object classid="java:freemind.main.FreeMindApplet.class" type="application/x-java-applet" archive="/DesktopModules/EasyWiki/plugins/freemind/freemindbrowser.jar" width="100%" height="100%"> 
      <param name="archive" value="/DesktopModules/EasyWiki/plugins/freemind/freemindbrowser.jar" /> 
      <param name="scriptable" value="false" /> 
      <param name="modes" value="freemind.modes.browsemode.BrowseMode" /> 
      <param name="browsemode_initial_map" value="{$smap}" /> 
      <param name="initial_mode" value="Browse" /> 
      <param name="selection_method" value="selection_method_direct" /> 
<!--<![endif]--> 
      <object classid="clsid:8AD9C840-044E-11D1-B3E9-00805F499D93" codebase="http://java.sun.com/update/1.5.0/jinstall-1_5_0-windows-i586.cab" width="100%" height="100%"> 
            <param name="code" value="freemind.main.FreeMindApplet" /> 
            <param name="archive" value="/DesktopModules/EasyWiki/plugins/freemind/freemindbrowser.jar" /> 
            <param name="scriptable" value="false" /> 
            <param name="modes" value="freemind.modes.browsemode.BrowseMode" /> 
            <param name="browsemode_initial_map" value="{$smap}" /> 
            <param name="initial_mode" value="Browse" /> 
            <param name="selection_method" value="selection_method_direct" /> 
            <strong> 
                  This browser does not have a Java Plug-in. 
            </strong> 
            <br /> 
            <a href="http://java.sun.com/products/plugin/downloads/index.html"> 
                  Get the latest Java Plug-in here. 
            </a> 
      </object> 
<!--[if !IE]>--> 
</object> 
<!--<![endif]-->
<br/><br/><br/>
    </xsl:template>
</xsl:stylesheet>

