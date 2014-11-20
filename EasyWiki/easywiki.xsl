<xsl:stylesheet version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:msxsl="urn:schemas-microsoft-com:xslt"
   exclude-result-prefixes="msxsl mdo"
   xmlns:mdo="urn:mdo"
>
    <!-- 	
	=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    						 A L ' s   E a s y W I K I
    :                                                                         :
    			   An extensible Wiki Module for DotNetNuke 
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                            Last update: 09/11/2011
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    -->
    <mdo:searchable>
        <xsl:stylesheet version="2.0"
             xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
             xmlns:msxsl="urn:schemas-microsoft-com:xslt"
             exclude-result-prefixes="msxsl mdo user"
             xmlns:mdo="urn:mdo"
             xmlns:user="urn:user"
>
            <msxsl:script language="C#" implements-prefix="user">
                <msxsl:assembly name="DotNetNuke"></msxsl:assembly>
                public string clean(string html)
                {
                return DotNetNuke.Common.Utilities.HtmlUtils.Clean(html, false);
                }
                public string shortandclean(string html)
                {
                return DotNetNuke.Common.Utilities.HtmlUtils.Shorten(DotNetNuke.Common.Utilities.HtmlUtils.Clean(html, false), 500, "...");
                }
            </msxsl:script>
            <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
            <xsl:template match="/">
                <root>
                    <xsl:for-each select="mdo:ew_getallpages()//page">
                        <xsl:variable name="pagename" select="@name"></xsl:variable>
                        <xsl:variable name="pageXML" select="mdo:ew_readpagexml($pagename)"></xsl:variable>
                        <xsl:variable name="lastupdate">
                            <xsl:choose>
                                <xsl:when test="not($pageXML//page/revision/@lastupdate)">{{$pageXML//page/@lastupdate}}</xsl:when>
                                <xsl:otherwise>{{$pageXML//page/revision/@lastupdate}}</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="description" select="substring(user:shortandclean( mdo:ew_renderstring($pageXML//page/content,false)),0,500)"></xsl:variable>
                        <xsl:variable name="content" select="user:clean( mdo:ew_renderstring($pageXML//page/content,false))"></xsl:variable>
                        <search-item>
                            <title>{{$pageXML//page/@title}}</title>
                            <description>{{$description}}</description>
                            <content>{{concat($pageXML//page/@title, ' - ', $content)}}</content>
                            <user>{{$pageXML//page/@author}}</user>
                            <date>{{mdo:fmt-date($lastupdate, 'yyyy-MM-dd HH:mm:ss')}}</date>
                            <key>{{$pageXML//page/@name}}</key>
                            <guid>page={{$pageXML//page/@name}}</guid>
                        </search-item>
                    </xsl:for-each>
                </root>
            </xsl:template>
        </xsl:stylesheet>
    </mdo:searchable>
    <mdo:setup>
        <xsl:template match="/">
            <!--
                    M O D U L E  C O N F I G U R A T I O N
            -->
            <xsl:variable name="Version"><![CDATA[01.00.00]]></xsl:variable>
            <section label-width="200px" > EasyWiki {{$Version}} Configuration</section>
            <setting name="wikiFolder" type="select">
                <caption>Wiki Storage Folder</caption>
                <source>
                    <xsl:for-each select="mdo:portal-files('')//dir">
                        <xsl:variable name="c" select="."></xsl:variable>
                        <option value="{.}">{{.}}</option>
                        <xsl:for-each select="mdo:portal-files(.)//dir">
                            <option value="{$c}/{.}">{{$c}}/{{.}}</option>
                        </xsl:for-each>
                    </xsl:for-each>
                </source>
            </setting>
            <setting name="ImageLibraryFolder" type="select">
                <caption>Image Library Folder</caption>
                <source>
                    <xsl:for-each select="mdo:portal-files('')//dir">
                        <xsl:variable name="c" select="."></xsl:variable>
                        <option value="{.}">{{.}}</option>
                        <xsl:for-each select="mdo:portal-files(.)//dir">
                            <option value="{$c}/{.}">{{$c}}/{{.}}</option>
                        </xsl:for-each>
                    </xsl:for-each>
                </source>
            </setting>
            <!--<setting name="wikiHome" type="text">
                <caption>Base Wiki Url</caption>
                <tooltip>Base URL to DNN Tabid hosting EasyWiki; leave blank if using FriendlyURL provider, 
                otherwise copy page url without params (temporary, to be fixed)</tooltip>
            </setting>-->
            <setting name="Interwikimap" type="longtext">
                <caption>InterWiki Map</caption>
                <tooltip>
                    Map of InterWiki links, one line per map.
                    Map formatted as: alias:baseurl
                    e.g.: wikipedia:http://wikipedia.org/wiki/
                </tooltip>
            </setting>
            <setting name="header" type="select">
                <caption>Header</caption>
                <source>
                    <option value="default">Full (default)</option>
                    <option value="none">None</option>
                </source>
            </setting>
            <setting name="headerbgcolor" type="text">
                <caption>Header background color</caption>
            </setting>
            <setting name="footer" type="select">
                <caption>Footer</caption>
                <source>
                    <option value="default">Full (default)</option>
                    <option value="compact">Compact</option>
                    <option value="none">None</option>
                </source>
            </setting>
            <setting name="footerbgcolor" type="text">
                <caption>Footer background color</caption>
            </setting>
        </xsl:template>
    </mdo:setup>
    <mdo:service name="Library" type="text/html">
        <!--
        Library: images and files from DNN Portal root
    -->
        <xsl:template match="/">
            <html>
                <head>
                    <title>EasyWiki Library</title>
                </head>
                <body>
                    <style type="text/css">
                        body{color:#fff; background-color:#000;}
                        .ewlibImages{list-style-type:none;}
                        .ewlibImages li{float:right;padding:5px;margin:0;font-size:0.8em;text-align:center;}
                    </style>
                    <div>
                        <ul class="ewlibImages">
                            <xsl:variable name="ImageLibraryFolder" select="mdo:get-module-setting('ImageLibraryFolder')"></xsl:variable>
                            <!-- image library of jpg, png, gif files -->
                            <xsl:for-each select="mdo:portal-files($ImageLibraryFolder)//file">
                                <xsl:if test="count(mdo:match(.,'(?i).png|(?i).jpg|(?i).gif')//match)&gt;0">
                                    <xsl:variable name="img">{{mdo:HTTPAlias()}}/Portals/{{mdo:dnn('P.PortalID')}}/{{$ImageLibraryFolder}}/{{.}}</xsl:variable>
                                    <xsl:variable name="vimg">/{{$ImageLibraryFolder}}/{{.}}</xsl:variable>
                                    <xsl:variable name="thumb" select="mdo:portalthumbnail($vimg,100,100)"></xsl:variable>
                                    <li>
                                        <a title="{.}" onclick="javascript:parent.insertPicture('{.}', '{$img}');">
                                            <img alt="{.}" src="{$thumb}" title="{.}" />
                                            <br/>{{.}}
                                        </a>
                                    </li>
                                </xsl:if>
                            </xsl:for-each>
                        </ul>
                    </div>
                </body>
            </html>
        </xsl:template>
    </mdo:service>
    <mdo:callable js="RenamePage(pagename,newname)" type="text/html">
        <xsl:template match="/">
            <xsl:variable name="rc" select="mdo:ew_renamepagexml(mdo:request('pagename'),mdo:request('newname'))"></xsl:variable>
            {{$rc}}
        </xsl:template>
    </mdo:callable>
    <mdo:callable js="GetPageURL(pagename)" type="text/html">
        <xsl:template match="/">
            <xsl:variable name="rc" select="mdo:ew_pageurl(mdo:request('pagename'))"></xsl:variable>
            {{$rc}}
        </xsl:template>
    </mdo:callable>
    <mdo:service name="page2pdf">
        <msxsl:script language="C#" implements-prefix="script">
            <msxsl:assembly name="System.Web" />
            <msxsl:using namespace="System.IO"/>
            <msxsl:using namespace="System.Web"/>
            public int sendData(string fpath)
            {
            byte[] b = System.IO.File.ReadAllBytes(fpath);
            HttpContext.Current.Response.ContentType = "application/pdf";
            HttpContext.Current.Response.OutputStream.Write(b, 0, b.Length);
            return 0;
            }
        </msxsl:script>
        <xsl:template match="/">
            <xsl:variable name="page" select="mdo:request('page')"></xsl:variable>
            <xsl:variable name="fpath" select="mdo:ew_page2pdf($page)"></xsl:variable>
            <xsl:execute select="script:sendData($fpath)" />
            <xsl:execute select="mdo:ew_deltempfile($fpath)" />
        </xsl:template>
    </mdo:service>
    <xsl:output method="html" indent="no" omit-xml-declaration="yes"/>
    <xsl:template match="/">
        <xsl:variable name="apppath" select="mdo:getappath()"></xsl:variable>
        <xsl:variable name="iseditable" select="mdo:iseditable()"></xsl:variable>
        <xsl:variable name="dateFormat">
            <xsl:choose>
                <xsl:when test="mdo:culture()='it-IT'">dd/MM/yyyy HH:mm</xsl:when>
                <xsl:otherwise>MM/dd/yyyy HH:mm</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="wikiFolder">{{mdo:get-module-setting('wikiFolder')}}</xsl:variable>
        <xsl:variable name="wikiHome">
            <xsl:value-of select="mdo:ew_wikiurl()"/>
            <!--<xsl:choose>
                <xsl:when test="mdo:get-module-setting('wikiHome')!=''">{{mdo:get-module-setting('wikiHome')}}</xsl:when>
                <xsl:otherwise>{{concat(mdo:HTTPAlias(), mdo:replace(mdo:dnn('T.TabPath'),'//','/'))}}</xsl:otherwise>
            </xsl:choose>-->
        </xsl:variable>
        <xsl:variable name="mode">
            <xsl:choose>
                <xsl:when test="$iseditable='true' and mdo:request('mode')='edit'">edit</xsl:when>
                <xsl:when test="$iseditable='true' and mdo:param('@mode')='edit'">edit</xsl:when>
                <xsl:otherwise>view</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="page">
            <!-- todo: PageNotFound -->
            <xsl:choose>
                <xsl:when test="mdo:param('@page')!=''">{{mdo:param('@page')}}</xsl:when>
                <xsl:when test="mdo:request('page')!=''">{{mdo:request('page')}}</xsl:when>
                <xsl:otherwise>Index</xsl:otherwise>
                <!--<xsl:otherwise>
                    -->
                <!-- try to parse from url -->
                <!--
                        <xsl:variable name="parseNavPathFromURL" select="mdo:aspnet('Context.Request.RawUrl')"></xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$parseNavPathFromURL='test'">TestPage</xsl:when>
                            <xsl:otherwise>Index</xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>-->
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="lastVisitedSess" select="concat('EasyWikiLastVisited', mdo:dnn('M.ModuleID'))"></xsl:variable>
        <xsl:variable name="lastVisited" select="mdo:aspnet('Context.Session[$lastVisitedSess]')"></xsl:variable>
        <!-- load page from xml file -->
        <xsl:variable name="pageXML" select="mdo:ew_readpagexml($page)"></xsl:variable>
        <xsl:variable name="sPageTitle">
            <xsl:choose>
                <xsl:when test="mdo:param('@action')='save'">{{mdo:request('pagetitle')}}</xsl:when>
                <xsl:when test="not($pageXML//page/@title)">{{$page}}</xsl:when>
                <xsl:otherwise>{{$pageXML//page/@title}}</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="CurrentPageVersion">
            <xsl:choose>
                <xsl:when test="not($pageXML//page/revision/@version)">
                    <xsl:choose>
                        <xsl:when test="not($pageXML//page/@version)">0</xsl:when>
                        <xsl:otherwise>{{number($pageXML//page/@version)}}</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>{{number($pageXML//page/revision/@version)}}</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <mdo:header position="page">
            <link rel="stylesheet" type="text/css" href="{concat($apppath,'DesktopModules/EasyWiki/EasyWiki.css')}"></link>
            <xsl:if test="$iseditable='true'">
                <link rel="stylesheet" type="text/css" href="{concat($apppath,'DesktopModules/EasyWiki/js/markitup/skins/markitup/style.css')}"></link>
                <link rel="stylesheet" type="text/css" href="{concat($apppath,'DesktopModules/EasyWiki/js/markitup/sets/wiki/style.css')}"></link>
            </xsl:if>
            </mdo:header>
        <mdo:header position="module">
            <xsl:if test="$iseditable='true'">
                <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/malsup/jquery.blockUI.js')}"></script>
                <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/markitup/jquery.markitup.js')}"></script>
                <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/markitup/sets/wiki/set.js')}"></script>
                <!--<script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/jquery.hotkeys-0.7.9.js')}"></script>-->
                <script type="text/javascript" src="{concat($apppath,'DesktopModules/EasyWiki/js/simplemodal/jquery.simplemodal.1.4.1.min.js')}"></script>
            </xsl:if>
            <xsl:execute select="mdo:assign('Page.Title', concat( mdo:aspnet('Module.ModuleConfiguration.ModuleTitle'), ' - ', $sPageTitle))" />
            <xsl:if test="mdo:tolower($sPageTitle)!='index'">
                <xsl:execute select="mdo:assign('Module.ModuleConfiguration.ModuleTitle', concat( mdo:aspnet('Module.ModuleConfiguration.ModuleTitle'), ' - ', $sPageTitle))" />
            </xsl:if>
            <!-- if $page is not last visited save to session -->
            <xsl:if test="$page!=$lastVisited">
                <xsl:execute select="mdo:assign('Context.Session[$lastVisitedSess]', $page)" />
            </xsl:if>
        </mdo:header>
        <script language="javascript">
            function wait()
            {
            $("#easywiki{{mdo:dnn('M.ModuleID')}}").block({
            message: '<h2 style="border:0;text-align:center">EasyWiki Loading...</h2>',
            css: { border: '0', padding: '5px', textAlign: 'center' }
            });
            }
            function CreateNewPage()
            {
            var p=prompt("Page title?", "NewPage");
            //window.location.href='{{$wikiHome}}?mode=edit&amp;page=' + p;
            if(p!=null)
            window.location.href='{{$wikiHome}}?mode=edit&amp;page=' + p;
            else
            $("#easywiki{{mdo:dnn('M.ModuleID')}}").unblock();
            }
            function insertPicture(name, path)	{
            try {
            parent.$.markItUp( { replaceWith:'<img src="'+path+'" alt="[![Alt Text:!:'+name+']!]" title="[![Title Text:!:'+name+']!]" />' } );
            parent.$.modal.close();
            } catch(e) {
            alert("Error: editor not found!");
            }
            }
            function AskRenamePage()
            {
            wait();
            var p=prompt("Change page name?", "{{$page}}");
            if(p==null)
            $("#easywiki{{mdo:dnn('M.ModuleID')}}").unblock();
            else
            {
            var rc = RenamePage('{{$page}}', p);
            if(rc!='ok')
            {
            jQuery.blockUI.defaults.growlCSS = {
            width:  	'350px',
            top:		'10px',
            left:   	'',
            right:  	'10px',
            border: 	'none',
            padding:	'5px',
            opacity:	'0.9',
            cursor: 	'default',
            color:		'#fff',
            backgroundColor: '#000',
            '-webkit-border-radius': '10px',
            '-moz-border-radius':	 '10px',
            'border-radius': 		 '10px',
            'background-image': 'url({{concat($apppath,'DesktopModules/EasyWiki/js/malsup/cancel.png')}})',
            'background-repeat': 'no-repeat',
            'background-position': '10px 10px'
            };
            jQuery.growlUI('Cannot rename page', rc, 4000, null);
            $("#easywiki{{mdo:dnn('M.ModuleID')}}").unblock();
            }
            else
            {
            jQuery.blockUI.defaults.growlCSS = {
            width:  	'350px',
            top:		'10px',
            left:   	'',
            right:  	'10px',
            border: 	'none',
            padding:	'5px',
            opacity:	'0.9',
            cursor: 	'default',
            color:		'#fff',
            backgroundColor: '#000',
            '-webkit-border-radius': '10px',
            '-moz-border-radius':	 '10px',
            'border-radius': 		 '10px',
            'background-image': 'url({{concat($apppath,'DesktopModules/EasyWiki/js/malsup/ok.png')}})',
            'background-repeat': 'no-repeat',
            'background-position': '10px 10px'
            };
            jQuery.growlUI('Page renamed', 'Please wait, loading renamed page', 4000, null);
            window.location.href=GetPageURL(p);
            }
            }
            }
        </script>
        <div id="easywiki{mdo:dnn('M.ModuleID')}" class="easywiki">
            <!--
            Build Output (View or Edit)
        -->
            <!-- TEST TEST TEST -->
            <!-- try to parse from url -->
            <!--
            <xsl:variable name="rawURL" select="mdo:aspnet('Context.Request.RawUrl')"></xsl:variable>
            rawURL:{{$rawURL}}<br/>
            pattern:'\/[^Wiki](.*)\s'<br/>-->
            <!-- \/(.*) -->
            <!--
            <hr></hr>
            <xsl:variable name="match" select="mdo:match($rawURL, '\/[^Wiki](.*)\s')"></xsl:variable>
            <xsl:for-each select="$match//match">
                -groupname:{{group/@name}}, gn:{{group/@n}}, val: {{group}}<br/>
            </xsl:for-each>
                <xsl:variable name="lastToken" select="$match[position()=last()]/@name"></xsl:variable>
            <br/>Last:{{$lastToken}}
            wikihome:{{$wikiHome}}<br></br>
            wikihome-nav:{{mdo:navigate('$page','AL')}}<br></br>-->
            <!-- TEST TEST TEST -->
            <xsl:choose>
                <xsl:when test="$mode='edit'">
                    <!--
                Edit Mode
            -->
                    <xsl:variable name="libraryPath" select="mdo:service-url('Library')"/>
                    <script language="javascript">
                        <!-- Ctrl-S to save -->
                        easywiki = {
                        save: function(markItUp) {
                        wait();
                        {{mdo:jajax('@mode', 'edit', '@action', 'save', '@page',  $page)}}
                        },
                        <!-- Ctrl-E to view -->
                        view: function(markItUp) {
                        wait();
                        {{mdo:jajax('@mode', 'view', '@page',  $page)}}
                        }
                        }
                        $(document).ready(function(){
                        mySettings.libraryPath='{{$libraryPath}}';
                        //todo: .previewParserPath='';
                        $('#easywikieditor{{mdo:dnn('M.ModuleID')}}').markItUp(mySettings);
                        });
                    </script>
                    <xsl:variable name="editorContent" select="mdo:request(concat('easywikieditor',mdo:dnn('M.ModuleID')))"></xsl:variable>
                    <xsl:variable name="pageTitle">
                        <xsl:choose>
                            <xsl:when test="mdo:request('pagetitle')!=''">{{mdo:request('pagetitle')}}</xsl:when>
                            <xsl:otherwise>{{mdo:param('@page')}}</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="newversion">
                        <xsl:choose>
                            <xsl:when test="mdo:request('newversion')='on'">{{number($CurrentPageVersion)+1}}</xsl:when>
                            <xsl:otherwise>{{number($CurrentPageVersion)}}</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="mdo:param('@action')='save'">
                            <!--
                            @action save ::: save page
                        -->
                            <!-- content -->
                            <!-- build xml -->
                            <xsl:variable name="xmlFragment">
                                <!--
                                version 0: save page author and revision author
                                version 1+: load page author from existing page xml and save revision author only
                            -->
                                <easywiki>
                                    <xsl:choose>
                                        <xsl:when test="not($pageXML//page/@created)">
                                            <!-- new page -->
                                            <page name="{mdo:param('@page')}" title="{$pageTitle}" markup="WikiCreole" version="{$newversion}" author="{mdo:dnn('U.UserID')}" authorname="{mdo:dnn('U.DisplayName')}" authorusername="{mdo:dnn('U.Username')}" authoremail="{mdo:dnn('U.Email')}" created="{mdo:date()}" lastupdate="{mdo:date()}">
                                                <content>{{$editorContent}}</content>
                                            </page>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <!-- existing page -->
                                            <page name="{mdo:param('@page')}" title="{$pageTitle}" markup="WikiCreole" version="{$pageXML//page/@version}" author="{$pageXML//page/@author}" authorname="{$pageXML//page/@authorname}" authorusername="{$pageXML//page/@authorusername}" authoremail="{$pageXML//page/@authoremail}" created="{$pageXML//page/@created}" lastupdate="{$pageXML//page/@lastupdate}">
                                                <content>{{$editorContent}}</content>
                                                <revision version="{$newversion}" author="{mdo:dnn('U.UserID')}" authorname="{mdo:dnn('U.DisplayName')}" authorusername="{mdo:dnn('U.Username')}" authoremail="{mdo:dnn('U.Email')}" lastupdate="{mdo:date()}" />
                                            </page>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </easywiki>
                            </xsl:variable>
                            <!-- tenere inline rc e rc2 altrimenti errore js! -->
                            <!-- backup previous version -->
                            <xsl:variable name="rc"><xsl:if test="$newversion&gt;$CurrentPageVersion">Backup version {{$CurrentPageVersion}}: <xsl:value-of select="mdo:ew_savepagexml(concat(mdo:param('@page'), '.', $CurrentPageVersion),'archive', $pageXML)"/></xsl:if></xsl:variable>
                            <!-- save page -->
                            <xsl:variable name="rc2">Save version {{$newversion}}: <xsl:value-of select="mdo:ew_savepagexml(mdo:param('@page'),'', $xmlFragment)"/></xsl:variable>
                            <script type="text/javascript">
                                jQuery.blockUI.defaults.growlCSS = {
                                width:  	'350px',
                                top:		'10px',
                                left:   	'',
                                right:  	'10px',
                                border: 	'none',
                                padding:	'5px',
                                opacity:	'0.9',
                                cursor: 	'default',
                                color:		'#fff',
                                backgroundColor: '#000',
                                '-webkit-border-radius': '10px',
                                '-moz-border-radius':	 '10px',
                                'border-radius': 		 '10px',
                                'background-image': 'url({{concat($apppath,'DesktopModules/EasyWiki/js/malsup/ok.png')}})',
                                'background-repeat': 'no-repeat',
                                'background-position': '10px 10px'
                                };
                                jQuery.growlUI('Save page', "{h{$rc}}<br/>{h{$rc2}}", 1500, null);
                            </script>
                        </xsl:when>
                        <xsl:when test="mdo:param('@action')='delete'">
                            <!--
                            @action delete ::: delete page
                            todo: delete all versions
                        -->
                            <xsl:variable name="rc">
                                <xsl:value-of select="mdo:ew_deletepagexml(mdo:param('@page'))"/>
                            </xsl:variable>
                            <script type="text/javascript">
                                window.location.href='{{$wikiHome}}';
                            </script>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:variable name="pageExists" select="mdo:ew_pageexistsxml($page)"></xsl:variable>
                    <div class="easywikitoolbarTop">
                        <a onclick="wait();" href="{mdo:jajax('@mode', 'view', '@page',  $page, '@iseditable', 'true')}">View</a>
                        |
                        <a onclick="wait();" href="{mdo:jajax('@mode', 'edit', '@action', 'save', '@page',  $page)}">Save</a>
                        New version:<input type="checkbox" name="newversion"></input>
                        |
                        <a onclick="wait();" href="{mdo:jajax('@mode', 'edit', '@action', 'delete', '@page', $page)}">Delete</a>
                        |
                        <a href="javascript:AskRenamePage();">Rename</a>
                        <xsl:if test="not($pageExists)">
                            <span>
                                |
                                <b>New Page</b>
                            </span>
                        </xsl:if>
                        |
                        <span>
                            <b>Page Title:</b>
                            <input type="text" name="pagetitle" value="{$sPageTitle}" size="30"></input>
                        </span>
                    </div>
                    <textarea id="easywikieditor{mdo:dnn('M.ModuleID')}" name="easywikieditor{mdo:dnn('M.ModuleID')}">
                        <xsl:choose>
                            <xsl:when test="mdo:param('@action')='save'">{{$editorContent}}</xsl:when>
                            <xsl:otherwise>{{$pageXML//content}}</xsl:otherwise>
                        </xsl:choose>
                    </textarea>
                    <div class="easywikitoolbar">
                        <table width="100%" border="0">
                            <tr>
                                <td>
                                    <span>
                                        Page: <b>{{$page}}</b>
                                    </span>
                                </td>
                                <td>
                                    <span title="Version">
                                        Version: <b>
                                            <xsl:choose>
                                                <xsl:when test="not($pageXML//page)">{{$newversion}} (New Page)</xsl:when>
                                                <xsl:otherwise>{{$pageXML//page/revision/@version}}</xsl:otherwise>
                                            </xsl:choose>
                                        </b>
                                    </span>
                                </td>
                                <td rowspan="3" align="right" width="50px">
                                    <span>
                                        <xsl:variable name="authorPageExists" select="mdo:ew_pageexistsxml($pageXML//page/@authorusername)"></xsl:variable>
                                        <xsl:choose>
                                            <xsl:when test="string($authorPageExists)='true'">
                                                <xsl:text><![CDATA[ ]]></xsl:text>
                                                <a href="{mdo:ew_pageurl($pageXML//page/@authorusername)}">
                                                    <img style="vertical-align:text-top;" src="http://www.gravatar.com/avatar/{mdo:md5($pageXML//page/@authoremail)}?s=40" />
                                                </a>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text><![CDATA[ ]]></xsl:text>
                                                <img style="vertical-align:text-top;" src="http://www.gravatar.com/avatar/{mdo:md5($pageXML//page/@authoremail)}?s=40" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </span>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <span>
                                        Created: <b>{{mdo:fmt-date($pageXML//page/@created, $dateFormat)}}</b>
                                    </span>
                                </td>
                                <td>
                                    <span>
                                        Updated: <b>{{mdo:fmt-date($pageXML//page/revision/@lastupdate, $dateFormat)}}</b>
                                    </span>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <span>
                                        By: <b>{{$pageXML//page/@authorname}}</b>
                                    </span>
                                </td>
                                <td>
                                    <span>
                                        By: <b>{{$pageXML//page/revision/@authorname}}</b>
                                    </span>
                                </td>
                            </tr>
                        </table>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <!--
                View Mode
                todo: layout templates
                {h{mdo:apply-template('DefaultPageLayout', 'pageXML', $pageXML)}}
                -->
                    <xsl:call-template name="DefaultPageLayout">
                        <xsl:with-param name="pageXML" select="$pageXML"></xsl:with-param>
                        <xsl:with-param name="CurrentPageVersion" select="$CurrentPageVersion"></xsl:with-param>
                        <xsl:with-param name="page" select="$page"></xsl:with-param>
                        <xsl:with-param name="wikiFolder" select="$wikiFolder"></xsl:with-param>
                        <xsl:with-param name="wikiHome" select="$wikiHome"></xsl:with-param>
                        <xsl:with-param name="dateFormat" select="$dateFormat"></xsl:with-param>
                        <xsl:with-param name="iseditable" select="$iseditable"></xsl:with-param>
                        <xsl:with-param name="plastVisited">
                            <xsl:choose>
                                <xsl:when test="$page!=$lastVisited">
                                    <xsl:value-of select="$lastVisited"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$page"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <!--
        DefaultPageLayout
    -->
    <xsl:template name="DefaultPageLayout">
        <xsl:param name="pageXML"/>
        <xsl:param name="CurrentPageVersion"/>
        <xsl:param name="page"/>
        <xsl:param name="wikiFolder"/>
        <xsl:param name="wikiHome"/>
        <xsl:param name="dateFormat"/>
        <xsl:param name="iseditable"/>
        <xsl:param name="plastVisited"/>
        <xsl:variable name="header" select="mdo:get-module-setting('header')"></xsl:variable>
        <xsl:variable name="headerbgcolor" select="mdo:get-module-setting('headerbgcolor')"></xsl:variable>
        <xsl:if test="$headerbgcolor!=''">
            <style type="text/css">.easywikitoolbarTop{background-color:{{$headerbgcolor}} !important;}</style>
        </xsl:if>
        <!-- toolbar -->
        <xsl:choose>
            <xsl:when test="$header='none' and $iseditable!='true'"></xsl:when>
            <xsl:otherwise>
                <div class="easywikitoolbarTop">
                    <div style="width:70%;left:0;position:absolute;">
                        <a href="{$wikiHome}">Home</a>
                        <xsl:if test="$iseditable='true'">
                            <a onclick="wait();" href="{mdo:jajax('@mode', 'edit', '@page', $page)}">Edit</a>
                            <a onclick="wait();" href="javascript:CreateNewPage();">New Page</a>
                        </xsl:if>
                    </div>
                    <xsl:if test="$plastVisited!=''">
                        <div style="width:30%;right:0; position:absolute; text-align:right;">
                            <a href="{mdo:ew_pageurl($plastVisited)}" title="Go back to last visited page">Back to {{$plastVisited}}</a>
                        </div>
                    </xsl:if>
                </div>
            </xsl:otherwise>
        </xsl:choose>
        <!-- page content -->
        <xsl:variable name="html" select="mdo:ew_renderstring($pageXML//content)"></xsl:variable>
        <div id="pagediv">{h{$html}}</div>
        <!-- footer toolbar -->
        <xsl:variable name="footer" select="mdo:get-module-setting('footer')"></xsl:variable>
        <xsl:variable name="footerbgcolor" select="mdo:get-module-setting('footerbgcolor')"></xsl:variable>
        <xsl:if test="$footerbgcolor!=''">
            <style type="text/css">.easywikitoolbar{background-color:{{$footerbgcolor}} !important;}</style>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$footer='compact'">
                <div class="easywikitoolbar">
                    <table width="100%" border="0">
                        <tr>
                            <td>
                                <span>
                                    Page Version: <b>
                                        <xsl:choose>
                                            <xsl:when test="not($pageXML//page)">{{$CurrentPageVersion}} (New Page)</xsl:when>
                                            <xsl:otherwise>{{$pageXML//page/revision/@version}}</xsl:otherwise>
                                        </xsl:choose>
                                    </b>
                                </span>
                            </td>
                            <td>
                                <span>
                                    Updated: <b>{{mdo:fmt-date($pageXML//page/revision/@lastupdate, $dateFormat)}}</b>
                                </span>
                            </td>
                            <td>
                                <span>
                                    By: <b>{{$pageXML//page/revision/@authorname}}</b>
                                </span>
                            </td>
                        </tr>
                    </table>
                </div>
            </xsl:when>
            <xsl:when test="$footer='none'"></xsl:when>
            <xsl:otherwise>
                <div class="easywikitoolbar">
                    <table width="100%" border="0">
                        <tr>
                            <td>
                                <span>
                                    Page: <b>{{$page}}</b>
                                </span>
                            </td>
                            <td>
                                <span title="Version">
                                    Version: <b>
                                        <xsl:choose>
                                            <xsl:when test="not($pageXML//page)">{{$CurrentPageVersion}} (New Page)</xsl:when>
                                            <xsl:otherwise>{{$pageXML//page/revision/@version}}</xsl:otherwise>
                                        </xsl:choose>
                                    </b>
                                </span>
                            </td>
                            <td rowspan="3" align="right" width="50px">
                                <span>
                                    <xsl:variable name="authorPageExists" select="mdo:ew_pageexistsxml($pageXML//page/@authorusername)"></xsl:variable>
                                    <xsl:choose>
                                        <xsl:when test="string($authorPageExists)='true'">
                                            <xsl:text><![CDATA[ ]]></xsl:text>
                                            <a href="{mdo:ew_pageurl($pageXML//page/@authorusername)}">
                                                <img style="vertical-align:text-top;" src="http://www.gravatar.com/avatar/{mdo:md5($pageXML//page/@authoremail)}?s=40" />
                                            </a>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text><![CDATA[ ]]></xsl:text>
                                            <img style="vertical-align:text-top;" src="http://www.gravatar.com/avatar/{mdo:md5($pageXML//page/@authoremail)}?s=40" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <span>
                                    Created: <b>{{mdo:fmt-date($pageXML//page/@created, $dateFormat)}}</b>
                                </span>
                            </td>
                            <td>
                                <span>
                                    Updated: <b>{{mdo:fmt-date($pageXML//page/revision/@lastupdate, $dateFormat)}}</b>
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <span>
                                    By: <b>{{$pageXML//page/@authorname}}</b>
                                </span>
                            </td>
                            <td>
                                <span>
                                    By: <b>{{$pageXML//page/revision/@authorname}}</b>
                                </span>
                            </td>
                        </tr>
                    </table>
                </div>
            </xsl:otherwise>
        </xsl:choose>
        </xsl:template>
</xsl:stylesheet>