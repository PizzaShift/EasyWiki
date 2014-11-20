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
        <div style="text-align:center;">
            <a href="{mdo:service-url('page2pdf')}&amp;page={$wikipage}" alt="Print as PDF" title="Print as PDF">
                <img src="/DesktopModules/EasyWiki/images/pdficon.png" alt="Print as PDF"></img>
            </a>
        </div>
    </xsl:template>
</xsl:stylesheet>