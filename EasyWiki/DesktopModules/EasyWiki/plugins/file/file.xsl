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
        file params 
        id: id for div
        file: url to linked resource
        title: title of linked resource
    -->
    <xsl:param name="id"/>
    <xsl:param name="url"/>
    <xsl:param name="title"/>
    <xsl:template match="/">
        <!--
            EasyWiki File Extension 01.00.00
            (c) Alberto Velo, 2011 - http://albe.ihnet.it/EasyWiki
            Embed videos in wiki
            < < < file id="file1" url="http://content.longtailvideo.com/videos/flvplayer.flv" title="File Title" > > >
        -->
        <xsl:variable name="spanID">
            <xsl:choose>
                <xsl:when test="$id!=''">{{$id}}</xsl:when>
                <xsl:otherwise>ew_filelink{{mdo:rnd()}}</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--
            ew_getFileIcon: publish link to file with automatic icon 
            note: icons are seached in file manager gif icons folder (/images/FileManager/Icons/)
        -->
        <xsl:variable name="imgURL" select="mdo:ew_getFileIcon($url)"></xsl:variable>
        <span id="{$spanID}">
            <xsl:text> </xsl:text>
            <xsl:choose>
                <xsl:when test="$imgURL!=''">
                    <a href="{$url}" title="{$title}">
                        <span>{{$title}}</span>
                        <xsl:text> </xsl:text>
                        <img src="{$imgURL}" alt="{$imgURL}" title="{$title}"></img>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a href="{$url}" title="{$title}">
                        <span>{{$title}}</span>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>
</xsl:stylesheet>