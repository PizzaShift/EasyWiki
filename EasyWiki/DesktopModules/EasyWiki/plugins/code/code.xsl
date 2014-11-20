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
    <xsl:param name="lang"/>
    <xsl:template match="/">
        <!--
            EasyWiki Code (Syntax Highlighter) Extension 01.00.00
            (c) Alberto Velo, 2011 - http://albe.ihnet.it/EasyWiki
        -->
        <mdo:header position="page">
            <link rel="stylesheet" type="text/css" href="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/styles/shCoreDefault.css')}"></link>
            <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shCore.js')}"></script>
            <xsl:choose>
                <xsl:when test="$lang='html'">
                    <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shBrushXml.js')}"></script>
                    <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shBrushJScript.js')}"></script>
                    <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shBrushCss.js')}"></script>
                </xsl:when>
                <xsl:when test="$lang='js'">
                    <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shBrushJScript.js')}"></script>
                </xsl:when>
                <xsl:when test="$lang='css'">
                    <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shBrushCss.js')}"></script>
                </xsl:when>
                <xsl:when test="$lang='xml'">
                    <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shBrushXml.js')}"></script>
                </xsl:when>
                <xsl:when test="$lang='csharp' or $lang='c#'">
                    <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shBrushCSharp.js')}"></script>
                </xsl:when>
                <xsl:when test="$lang='vb' or $lang='vbnet'">
                    <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shBrushVb.js')}"></script>
                </xsl:when>
                <xsl:when test="$lang='sql'">
                    <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shBrushSql.js')}"></script>
                </xsl:when>
                <xsl:otherwise>
                <!-- all -->
                    <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shBrushXml.js')}"></script>
                    <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shBrushJScript.js')}"></script>
                    <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shBrushCss.js')}"></script>
                    <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shBrushCSharp.js')}"></script>
                    <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shBrushVb.js')}"></script>
                    <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/syntaxhighlighter_3_0_83/scripts/shBrushSql.js')}"></script>
                </xsl:otherwise>
            </xsl:choose>
        </mdo:header>
        <script type="text/javascript">$(function(){ SyntaxHighlighter.all();});</script>
    </xsl:template>
</xsl:stylesheet>