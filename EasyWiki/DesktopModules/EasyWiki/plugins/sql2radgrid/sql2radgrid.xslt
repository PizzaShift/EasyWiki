<xsl:stylesheet version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:msxsl="urn:schemas-microsoft-com:xslt"
   exclude-result-prefixes="msxsl mdo"
   xmlns:mdo="urn:mdo"
>
    <!--
    EasyWiki sql2radgrid Extension 01.00.00
    (c) Alberto Velo, 2011 - http://albe.ihnet.it/EasyWiki
-->
    <xsl:output method="html" indent="yes" omit-xml-declaration="yes"/>
    <!--
        EasyWiki params
        extension = 'sql2radgrid'
    -->
    <xsl:param name="wikipage"/>
    <xsl:param name="wikifolder"/>
    <xsl:param name="extension"/>
    <xsl:param name="apppath"/>
	<xsl:param name="filter"/>
	<xsl:param name="export"/>
    <!--
	    sql2radgrid extension params
	    select: sql query
	-->
    <xsl:param name="select" xml:space="preserve" />
    <xsl:param name="skin"/>
    <!--
        sql2radgrid Extension implementation
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
        <mdo:asp
          xmlns:asp="asp"
          xmlns:telerik="telerik"
>
            <asp:SqlDataSource
                id="dssql2radgrid"
                runat="server"
                DataSourceMode="DataReader"
                ConnectionString="&lt;%$ ConnectionStrings:SiteSqlServer %&gt;"
                SelectCommand="{$select}"
      />
            <!--
            skin: set EnableEmbeddedSkins="false" to use easywiki standard table css class instead of skin
            -->
            <xsl:variable name="activeSkin">
                <xsl:choose>
                    <xsl:when test="not($skin) or $skin=''">Default</xsl:when>
                    <!--
                        WARNING: skin name MUST match (case sensitive!) one of predefined values, as stated at http://www.telerik.com/help/aspnet-ajax/howskinswork.html
                        skins: Black Default Forest Hay Office2007 Outlook Simple Sitefinity Sunset Telerik Vista Web20 WebBlue Windows7
                    -->
                    <xsl:otherwise>{{$skin}}</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="sfilter">
				<xsl:choose>
					<xsl:when test="$filter='' or $filter='false' or $filter='False'">false</xsl:when>
					<xsl:otherwise>true</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="sexport">
				<xsl:choose>
					<xsl:when test="$export='' or $export='false' or $export='False'">false</xsl:when>
					<xsl:otherwise>true</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<telerik:RadGrid ID="RadGrid1" Skin="{$activeSkin}" EnableEmbeddedSkins="true" DataSourceID="dssql2radgrid"
				 AllowPaging="True" AllowSorting="True" PageSize="20" AllowFilteringByColumn="{$sfilter}"
				 runat="server">
				<ExportSettings ExportOnlyData="true" IgnorePaging="true">
					<csv EncloseDataWithQuotes="false" ColumnDelimiter="Semicolon"/>
				</ExportSettings>
				<MasterTableView Width="100%" CommandItemDisplay="Top">
					<CommandItemSettings ShowAddNewRecordButton="false"/>
					<PagerStyle Mode="NextPrevNumericAndAdvanced"/>
					<CommandItemSettings ShowExportToWordButton="{$sexport}" ShowExportToExcelButton="{$sexport}" ShowExportToCsvButton="{$sexport}"/>
				</MasterTableView>
			</telerik:RadGrid>
            <!-- RadWindow for master-detail views -->
            <telerik:RadWindow ID="wnd" runat="server">
            </telerik:RadWindow>
        </mdo:asp>
    </xsl:template>
</xsl:stylesheet>

