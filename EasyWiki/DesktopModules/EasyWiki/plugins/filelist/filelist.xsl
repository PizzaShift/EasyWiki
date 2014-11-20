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
	<!-- filelist params -->
	<xsl:param name="folder"/>
	<xsl:param name="mode"/>
    <xsl:template match="/">
        <!--
            EasyWiki FileList Extension 01.00.00
            (c) Alberto Velo, 2011 - http://albe.ihnet.it/EasyWiki
            Builds a list of files in specified folder
        -->
        <mdo:header position="form">
            <!-- <script type="text/javascript" src="{concat($apppath, 'DesktopModules/EasyWiki/js/jquery.listmenu.min-1.1.js')}"></script> -->
        </mdo:header>
        <!-- <script type="text/javascript">$(function(){ $('#ewAllPages').show('fast').listmenu({ includeNums: true, includeOther: true, showCounts: false, noMatchText: 'No pages under this letter',  cols:{ count:5, gutter:15 } }); });</script> -->
        <xsl:choose>
            <xsl:when test="$mode='table'">
                <table>
                    <thead>
                        <tr><th>File</th>
                            <th>Size</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:for-each select="mdo:portal-files($folder)//file">
                            <xsl:variable name="style">
                                <xsl:choose>
                                    <xsl:when test="position() mod 2 = 1">#fff;</xsl:when>
                                    <xsl:otherwise>#eee;</xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="f" select="."></xsl:variable>
                            <tr style="background-color:{$style}">
                                <td><a href="/Portals/{mdo:dnn('P.PortalID')}/{$folder}/{$f}">{{$f}}</a></td>
                                <td>{{format-number(@size div 1024, '##.##')}} Kb</td>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table>
                
            </xsl:when>
            <xsl:otherwise>
                <ul id="ewFiles{mdo:rnd()}">
                    <xsl:for-each select="mdo:portal-files($folder)//file">
                        <xsl:variable name="f" select="."></xsl:variable>
                        <li>
                            <a href="/Portals/{mdo:dnn('P.PortalID')}/{$folder}/{$f}">{{$f}}</a>
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
</xsl:stylesheet>