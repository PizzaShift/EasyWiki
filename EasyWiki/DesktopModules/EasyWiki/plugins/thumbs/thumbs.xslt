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
	<!-- Thumbs params -->
	<xsl:param name="folder"/>
    <xsl:param name="id"/>
    <xsl:param name="mode"/>
    <xsl:template match="/">
        <!--
            EasyWiki Thumbs Extension 01.00.00
            (c) Alberto Velo, 2011 - http://albe.ihnet.it/EasyWiki
            Builds a list of images from a dnn folder and show thumbnails with prettyPhoto
        -->
        <xsl:variable name="myID">
            <xsl:choose>
                <xsl:when test="$id!=''">prettyPhoto[{{$id}}]</xsl:when>
                <xsl:otherwise>prettyPhoto[gallery{{mdo:rnd()}}]</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="smode">
            <xsl:choose>
                <xsl:when test="$mode=''">thumbs</xsl:when>
                <xsl:otherwise>{{$mode}}</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <mdo:header position="page">
            <link rel="stylesheet" type="text/css" href="{concat($apppath,'DesktopModules/XSlideShow/js/prettyPhoto/prettyPhoto.css')}"></link>
            <style type="text/css">.easywikithumbs{text-align:left;width:100%;height:auto;padding:5px;margin:0;}</style>
        </mdo:header>
        <mdo:header position="form">
            <script type="text/javascript" src="{concat($apppath,'DesktopModules/XSlideShow/js/prettyPhoto/jquery.prettyPhoto.js')}"></script>
        </mdo:header>
        <script type="text/javascript">
            $(document).ready(function(){
            $("a[rel^='prettyPhoto']").prettyPhoto({animation_speed:'normal',theme:'pp_default',slideshow:5000, showTitle: false});
            });
        </script>
        <div class="easywikithumbs">
            <xsl:choose>
                <xsl:when test="$smode='thumbs'">
                    <xsl:for-each select="mdo:portal-files($folder)//file">
                        <xsl:variable name="f" select="."></xsl:variable>
                        <xsl:variable name="ext" select="substring($f, string-length($f)-2)"></xsl:variable>
                        <xsl:if test="$ext='png' or $ext='jpg' and $f!=''">
                            <xsl:variable name="href">/Portals/{{mdo:dnn('P.PortalID')}}/{{$folder}}/{{$f}}</xsl:variable>
                            <xsl:variable name="href2">{{$folder}}/{{$f}}</xsl:variable>
                            <xsl:variable name="thumb" select="mdo:portalthumbnail($href2,50,50)"></xsl:variable>
                            <a href="{$href}" rel="{$myID}"><img alt="{.}" src="{$thumb}" title="{.}" /></a>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <ul>
                        <xsl:for-each select="mdo:portal-files($folder)//file">
                            <xsl:variable name="f" select="."></xsl:variable>
                            <xsl:variable name="ext" select="substring($f, string-length($f)-2)"></xsl:variable>
                            <xsl:if test="$ext='png' or $ext='jpg' and $f!=''">
                                <xsl:variable name="href">/Portals/{{mdo:dnn('P.PortalID')}}/{{$folder}}/{{$f}}</xsl:variable>
                                <xsl:variable name="href2">{{$folder}}/{{$f}}</xsl:variable>
                                <xsl:variable name="thumb" select="mdo:portalthumbnail($href2,50,50)"></xsl:variable>
                                <li><a href="{$href}" rel="{$myID}">{{$f}}</a></li>
                            </xsl:if>
                        </xsl:for-each>
                    </ul>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
</xsl:stylesheet>