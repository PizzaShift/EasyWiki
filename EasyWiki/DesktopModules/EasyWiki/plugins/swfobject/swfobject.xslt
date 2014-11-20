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
    <!-- 
        embed params 
        id: id for div
        file: url to video
    -->
    <xsl:param name="id"/>
    <xsl:param name="url"/>
    <xsl:param name="autostart"/>
    <xsl:param name="width"/>
    <xsl:param name="height"/>
    <xsl:template match="/">
        <!--
            EasyWiki Embed Extension 01.00.00
            (c) Alberto Velo, 2011 - http://albe.ihnet.it/EasyWiki
            Embed videos in wiki
            id: optional id for div (mandatory for multi-instance!)
            url="url-to-video"
            < < < embed id="videosample1" url="http://content.longtailvideo.com/videos/flvplayer.flv" > > >
        -->
        <mdo:header position="page">
            <script type="text/javascript" src="{concat($apppath, 'DesktopModules/EasyWiki/js/jwplayer/swfobject.js')}"></script>
        </mdo:header>
        <xsl:variable name="divID">
            <xsl:choose>
                <xsl:when test="$id!=''">{{$id}}</xsl:when>
                <xsl:otherwise>ew_embeddedvideo{{mdo:rnd()}}</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="bautostart">
            <xsl:choose>
                <xsl:when test="mdo:to-lower($autostart)='true'">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="frameWidth">
            <xsl:choose>
                <xsl:when test="$width!=''">{{$width}}</xsl:when>
                <xsl:otherwise>470</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="frameHeight">
            <xsl:choose>
                <xsl:when test="$height!=''">{{$height}}</xsl:when>
                <xsl:otherwise>320</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div id="{$divID}"></div>
        <script type="text/javascript">
            $(function(){
            var so = new SWFObject('{{concat($apppath, 'DesktopModules/EasyWiki/js/jwplayer/player.swf')}}','{{$divID}}','{{$frameWidth}}','{{$frameHeight}}','9');
            so.addParam('allowfullscreen','true');
            so.addParam('allowscriptaccess','always');
            so.addParam('bgcolor','#FFFFFF');
            so.addParam('flashvars','file={{$url}}&amp;autostart={{$bautostart}}');
            so.write('{{$divID}}');
            });
        </script>
    </xsl:template>
</xsl:stylesheet>