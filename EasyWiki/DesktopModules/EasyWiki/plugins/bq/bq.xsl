<xsl:stylesheet version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:msxsl="urn:schemas-microsoft-com:xslt"
   exclude-result-prefixes="msxsl mdo"
   xmlns:mdo="urn:mdo"
>
    <!--
        BQ (BlockQuote) EasyWiki Extension 01.00.00
        (c) Alberto Velo, 2011 - http://albe.ihnet.it/EasyWiki   
    -->
    <xsl:output method="html" indent="yes" omit-xml-declaration="yes"/>
    <!--
        EasyWiki params
        extension = 'bq' (blockquote)
    -->
    <xsl:param name="wikipage"/>
	<xsl:param name="wikifolder"/>
	<xsl:param name="extension"/>
	<xsl:param name="apppath"/>
	<!-- 
        BlockQuote extension params 
        text: text content for blockquote element; use text or page
        page: page to include as blockquote element; use text or page
        class: optional css class for blockquote element
        link: optional url to link blockquote element
        cite: optional citation url
        citetitle: optional citation title
    -->
    <xsl:param name="text"/>
    <xsl:param name="page"/>
    <xsl:param name="class"/>
    <xsl:param name="link"/>
    <xsl:param name="cite"/>
    <xsl:param name="citetitle"/>
    <!--
        BQ (BlockQuote) Extension implementation
    -->
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$page!=''">
                <!-- 
                    1. blockquote content is included from page specified with 'page' param 
                    example: <<<bq page="PageName">>>
                -->
                <xsl:if test="$link!=''">
                    <!-- optionally specify an url to link content to (open a href) -->
                    <xsl:variable name="ahref">&lt;a href="{{$link}}" target="_blank" alt="{{$link}}"&gt;</xsl:variable>
                    {h{$ahref}}
                </xsl:if>
                <blockquote>
                    <xsl:if test="$class!=''">
                        <!-- optionally specify a class for blockquote element -->
                        <xsl:attribute name="class">{{$class}}</xsl:attribute>
                    </xsl:if>
                    <xsl:variable name="includePage"><![CDATA[<<<include page=']]>{{$page}}<![CDATA['>>>]]></xsl:variable>
                    <span>{h{mdo:ew_renderstring($includePage)}}</span>
                    <!-- optionally specify a cite url and/or title -->
                    <xsl:choose>
                        <xsl:when test="$cite!='' and $citetitle!=''">
                            <div class="cite"><a target="_blank" href="{$cite}"><xsl:choose><xsl:when test="$citetitle!=''">{{$citetitle}}</xsl:when><xsl:otherwise>{{$cite}}</xsl:otherwise></xsl:choose></a></div>
                        </xsl:when>
                        <xsl:when test="$cite!=''">
                            <div class="cite"><a target="_blank" href="{$cite}">{{$cite}}</a></div>
                        </xsl:when>
                        <xsl:when test="$citetitle!=''">
                            <div class="cite">{{$cite}}</div>
                        </xsl:when>
                    </xsl:choose>
                </blockquote>
                <xsl:if test="$link!=''">
                    <!-- optionally specify an url to link content to (close a href) -->
                    <xsl:variable name="ahref">&lt;/a&gt;</xsl:variable>
                    {h{$ahref}}
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <!--
                    2. blockquote with value of 'text' param 
                    example: <<<bq text="My Html or WikiCreole text">>>
                -->
                <xsl:if test="$link!=''">
                    <!-- optionally specify an url to link content to (open a href) -->
                    <xsl:variable name="ahref">&lt;a href="{{$link}}" target="_blank" alt="{{$link}}"&gt;</xsl:variable>
                    {h{$ahref}}
                </xsl:if>
                <blockquote>
                    <xsl:if test="$class!=''">
                        <!-- optionally specify a class for blockquote element -->
                        <xsl:attribute name="class">{{$class}}</xsl:attribute>
                    </xsl:if>
                    <span>{h{$text}}</span>
                    <!-- optionally specify a cite url and/or title -->
                    <xsl:choose>
                        <xsl:when test="$cite!='' and $citetitle!=''">
                            <div class="cite">
                                <a target="_blank" href="{$cite}">
                                    <xsl:choose>
                                        <xsl:when test="$citetitle!=''">{{$citetitle}}</xsl:when>
                                        <xsl:otherwise>{{$cite}}</xsl:otherwise>
                                    </xsl:choose>
                                </a>
                            </div>
                        </xsl:when>
                        <xsl:when test="$cite!=''">
                            <div class="cite">
                                <a target="_blank" href="{$cite}">{{$cite}}</a>
                            </div>
                        </xsl:when>
                        <xsl:when test="$citetitle!=''">
                            <div class="cite">{{$cite}}</div>
                        </xsl:when>
                    </xsl:choose>
                </blockquote>
                <xsl:if test="$link!=''">
                    <!-- optionally specify an url to link content to (close a href) -->
                    <xsl:variable name="ahref">&lt;/a&gt;</xsl:variable>
                    {h{$ahref}}
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>