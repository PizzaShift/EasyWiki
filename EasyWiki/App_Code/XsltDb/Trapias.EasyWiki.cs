///
///
/// EasyWiki
/// (c) Alberto Velo, 2011
///
///
/// 
using System;
using System.IO;
using DotNetNuke;
using System.Collections.Generic;
using System.Xml;
using System.Xml.XPath;
using System.Text.RegularExpressions;
using System.Security;
using System.Web;
using System.Diagnostics;
using System.Xml.Xsl;
using System.Runtime.Remoting.Messaging;
using System.Security.Permissions;
using System.Net;
using WkHtmlToXSharp;

namespace Findy.XsltDb
{
    /// <summary>
    /// AL's
    /// </summary>
    public partial class Helper
    {
        private static readonly global::Common.Logging.ILog _Log = global::Common.Logging.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        public static int count = 0;

        public class EasyWikiExtensionParameter
        {
            string _ExtensionParameterName;
            string _ExtensionParameterValue;

            public string name
            {
                get { return _ExtensionParameterName; }
                set { _ExtensionParameterName = value; }
            }
            public string value
            {
                get { return _ExtensionParameterValue; }
                set { _ExtensionParameterValue = value; }
            }

        }

        //public enum _WikiMarkup
        //{
        //    WikiCreole = 1, // http://www.wikicreole.org
        //    WikiPlex = 2, // http://wikiplex.codeplex.com
        //    WikidPad = 3 // wikidpad.sourceforge.net
        //    //MarkDown = 4
        //}


        public string ew_renderstring(string input)
        {
            return ew_renderstring(input, true);
        }

        /// <summary>
        /// Render WikiCreole markup string as HTML
        /// </summary>
        /// <param name="input"></param>
        /// <returns>HTML</returns>
        public string ew_renderstring(string input, bool processLayout)
        {
            //log("ew_renderstring " + processLayout.ToString() + " ::" + input);
            var engine = new Wiki.CreoleParser();

            //Interwiki links
            //today be added in module settings one per line as alias:baseurl, e.g.
            //wikipedia:http://wikipedia.org/wiki/ 
            // [[wikipedia:TOPIC]] -> http://wikipedia.org/wiki/TOPIC
            string Interwikimap = getmodulesetting("Interwikimap").ToString();
            string[] maps = Interwikimap.Split('\n');
            foreach (string map in maps)
            {
                int del = map.IndexOf(':');
                if (del > 0)
                    engine.InterWiki.Add(map.Substring(0, map.Length - (map.Length - del)), map.Substring(del + 1));
                //aka engine.InterWiki.Add("wikipedia", "http://wikipedia.org/wiki/");
            }

            // EasyWiki Link Handler
            engine.OnLink += new Wiki.LinkEventHandler(EasyWikiLinkHandler);

            // EasyWiki extensions handler
            EasyWikiExtensionHandler ew = new EasyWikiExtensionHandler();
            ew.h = new Helper(transformer);
            ew.currentPage = (string)iif(request("page") != "", request("page"), "index"); // todo: carica da request o da nuovo parametro?

            if (processLayout == true)
            {
                //save current page markup x layout extension, replacing <<<layout>>> tag to avoid recursive rendering
                Regex regex = new Regex(
                @"(?:^|[^\{{3}][^\<pre\>])<{3}layout[\s]?(.+?)?>{3}",
                RegexOptions.IgnoreCase
                | RegexOptions.Multiline
                | RegexOptions.Singleline
                | RegexOptions.Compiled
                );

                MatchCollection hasLayout = regex.Matches(input);
                if (hasLayout.Count > 0)
                {
                    /*
                    * EasyWiki Core Extension <<<layout page="PageName">>>
                     * 
                     * page content placeholder in layout page: {{{$page$}}}
                    * 
                   */
                    ew.currentPageMarkup = regex.Replace(input, "");

                    Match myLayout = hasLayout[0]; // only apply first <<<layout>>> tag
                    List<EasyWikiExtensionParameter> pp = ew.EasyWikiExtensionParametersParse(myLayout.Groups[1].Value);
                    string pageLayoutName = ew.EasyWikiExtensionParameterGetValue(pp, "page");
                    if (pageLayoutName.Trim() != string.Empty)
                    {
                        XPathNavigator navLayout = ew_readpagexml(pageLayoutName);
                        if (navLayout == null)
                            return "";
                        if (navLayout.SelectSingleNode("//error") == null)
                        {
                            string pageLayoutMarkup = navLayout.SelectSingleNode("//page/content").ToString();
                            ////pageLayoutMarkup = pageLayoutMarkup.Replace("{{{$page$}}}", ew_renderstringpartial(ew.currentPageMarkup));
                            //pageLayoutMarkup = pageLayoutMarkup.Replace("{{{$page$}}}", ew.currentPageMarkup);

                            ////pageLayoutMarkup = ew_renderstringpartial(pageLayoutMarkup);
                            ////pageLayoutMarkup = pageLayoutMarkup.Replace("{{{$page$}}}", " " + ew.currentPageMarkup);
                            //input =  ew_renderstring(pageLayoutMarkup);
                            pageLayoutMarkup = pageLayoutMarkup.Replace("{{{$page$}}}", ew_renderstring(ew.currentPageMarkup,false));
                            input = pageLayoutMarkup;// ew_renderstring(pageLayoutMarkup);


                        }
                        else
                        {
                            if (iseditable())
                                input = regex.Replace(input, "<span class='NormalRed'>" + navLayout.SelectSingleNode("//error").ToString() + "</span>");
                            else
                                input = regex.Replace(input, "");
                        }
                    }

                }
            }

            // parse extensions
            MatchEvaluator myEvaluator = new MatchEvaluator(ew.EasyWikiExtensionParser);
            // matcha estensioni con sintassi <<<Extension>>>
            // esclude se prefisso no-wiki {{{ o <pre>
            input = Regex.Replace(input, @"(?:^|[^\{{3}][^\<pre\>])<{3}(\w+)[\s]?(.+?)?>{3}", myEvaluator, RegexOptions.IgnoreCase
            | RegexOptions.Multiline
            | RegexOptions.Singleline
            | RegexOptions.Compiled);

            // DNN token-replace parser
            Regex dnnsafetokenreplace = new Regex(
                @"(\[([^: ]*):([^:/ ]*)\])",
                RegexOptions.IgnoreCase
                | RegexOptions.Multiline
                | RegexOptions.IgnorePatternWhitespace
                | RegexOptions.Compiled
                );
            MatchEvaluator str = new MatchEvaluator(DNNTokenReplace);
            input = dnnsafetokenreplace.Replace(input, str);

            if (processLayout)
                return engine.ToHTML(input);
            else
                return input;
        }

        public string DNNTokenReplace(Match m)
        {
            DotNetNuke.Services.Tokens.TokenReplace tk = new DotNetNuke.Services.Tokens.TokenReplace();
            tk.ModuleId = transformer.ModuleID;
            return tk.ReplaceEnvironmentTokens(m.Value);
        }

        protected void EasyWikiLinkHandler(object sender, Wiki.LinkEventArgs e)
        {
            if (e.Href.StartsWith("mailto:"))
            {
                e.CssClass = "mailto";
                return;
            }

            //external urls (full urls)
            if (isURL(e.Href)) 
                return;

            // site urls (virtual urls)
            if(isRelativeURL(e.Href))
            {
                e.Target = Wiki.LinkEventArgs.TargetEnum.Internal;
                e.CssClass = "internallink";
                e.Href = resolveurl(e.Href);
                return;
            }

            //internal urls (wiki pages)
            e.Target = Wiki.LinkEventArgs.TargetEnum.Internal;
            e.CssClass = "internallink";
            e.Href = DotNetNuke.Common.Globals.NavigateURL(transformer.DnnSettings.T.TabID, "", "page=" + e.Link);
        }
        
        public class EasyWikiExtensionHandler
        {
            public string currentPage;
            public string currentPageMarkup;
            public Findy.XsltDb.Helper h;

            /// <summary>
            /// Parse <<<extension params>>>, call extension passing params to render HTML
            /// </summary>
            /// <param name="m"></param>
            /// <returns></returns>
            public string EasyWikiExtensionParser(Match m)
            {
                //log("EasyWikiExtensionParser: " + m.Value);
                Regex regex = new Regex(
                           @"<{3}(\w+)[\s]?(.+?)?>{3}",
                           RegexOptions.IgnoreCase
                           | RegexOptions.Multiline
                           | RegexOptions.Singleline
                           | RegexOptions.Compiled
                           );

                Match inc = regex.Match(m.Value);
                if (inc != null)
                {
                    string pluginName = inc.Groups[1].Value;
                    string pars = string.Empty;
                    //params are optional 
                    try { pars = inc.Groups[2].Value; }
                    catch (Exception) { }

                    List<EasyWikiExtensionParameter> pp = EasyWikiExtensionParametersParse(pars);
                    return EasyWikiExtensionExecutor(pluginName, pp);
                }
                else return "";
            }

            private string EasyWikiExtensionExecutor(string extensionName, List<EasyWikiExtensionParameter> parameters)
            {
                //log("EasyWikiExtensionExecutor: extensionName=" + extensionName + ", par=" + iif(parameters == null, "NULL", parameters.Count.ToString()));
                string wikiFolder = h.getmodulesetting("wikiFolder").ToString();
                string appPath = h.getappath();
                string phisicalRoot = h.transformer.DnnSettings.P.HomeDirectoryMapPath; // phisical portal home directory
                if (!phisicalRoot.EndsWith("\\"))
                    phisicalRoot += "\\";
                
                switch (extensionName)
                {
                    /*
                     * EasyWiki Core Extension <<<include page="PageName">>>
                     * 
                    */
                    case "include":
                        string pageName = EasyWikiExtensionParameterGetValue(parameters, "page");
                        if (pageName == this.currentPage)
                            if (h.iseditable())
                                throw new Exception("EasyWiki error: page cannot include self");
                            else
                                return ""; // avoid recursion!

                        XPathNavigator nav = h.ew_readpagexml(pageName);
                        if (nav == null)
                            return "";
                        if (nav.SelectSingleNode("//error") == null)
                        {
                            string pageMarkup = nav.SelectSingleNode("//page/content").ToString();
                            //include page without processing eventual layout
                            return h.ew_renderstring(pageMarkup,false);
                        }
                        else
                        {
                            if (h.iseditable())
                                return "<span class='NormalRed'>" + nav.SelectSingleNode("//error").ToString() + "</span>";
                            else
                                return "";
                        }

                    /*
                    * EasyWiki Core Extension <<<layout page="PageName">>>
                     * 
                     * page content placeholder in layout page: {{{$page$}}}
                    * 
                   */
                    case "layout":
                        return ""; // layout must be handled before page rendering


                    /*
                    * EasyWiki XSL Extensions <<<ANY>>>
                    * 
                   */
                    default:
                        string xslExtension = string.Empty; string pathToPlugin = string.Empty;
                        try
                        {
                            //try to load local extensions first (from plugins folder under wiki root folder)
                            pathToPlugin = Path.Combine(phisicalRoot, wikiFolder) + @"\plugins\" + extensionName + @"\" + extensionName + ".xsl";
                            if (!System.IO.File.Exists(pathToPlugin))
                                pathToPlugin = Path.Combine(phisicalRoot, wikiFolder) + @"\plugins\" + extensionName + @"\" + extensionName + ".xslt";

                            //then try to load shared (module level) extensions
                            if (!System.IO.File.Exists(pathToPlugin))
                                pathToPlugin = h.mappath(":DesktopModules/EasyWiki/plugins/" + extensionName + "/" + extensionName + ".xsl");
                            if (!System.IO.File.Exists(pathToPlugin))
                                pathToPlugin = h.mappath(":DesktopModules/EasyWiki/plugins/" + extensionName + "/" + extensionName + ".xslt");
                            if (!System.IO.File.Exists(pathToPlugin))
                                if (h.iseditable())
                                    return "<span class='NormalRed'>Extension '" + extensionName + "' is not available</span>";
                                else
                                    return "";

                            xslExtension = System.IO.File.ReadAllText(pathToPlugin);
                        }
                        catch (Exception e)
                        {
                            if (h.iseditable())
                                return "<span class='NormalRed'>Could not load extension '" + extensionName + "' from file " + pathToPlugin + ": " + e.Message + ".<br/><b>Stack:</b>" + e.StackTrace + "</span>";
                            else
                                return "";
                        }

                        string resultExtension = string.Empty;
                        try
                        {
                            //todo: verificare issuper
                            resultExtension = h.ew_JustTransform(xslExtension, "<root/>", false, true, extensionName, parameters);
                            //h.log("resultExtension " + extensionName + " = " + resultExtension);
                            return resultExtension;
                        }
                        catch (Exception ex)
                        {
                            if (h.iseditable())
                                return "<span class='NormalRed'>Extension '" + extensionName + "' exception:" + ex.Message + ".<br/><b>Stack:</b>" + ex.StackTrace + "</span>";
                            else
                                return "";
                        }
                }

            }

            /// <summary>
            /// Parse Extension Parameters
            /// </summary>
            /// <param name="pars"></param>
            /// <returns></returns>
            public List<EasyWikiExtensionParameter> EasyWikiExtensionParametersParse(string pars)
            {
                //(?<name>\b\w+\b)\s*=\s*(?<value>"[^"]*"|'[^']*'|[^"'<>\s]+)
                List<EasyWikiExtensionParameter> myParams = new List<EasyWikiExtensionParameter>();
                //log("EasyWikiExtensionParametersParse: " + pars);
                MatchCollection matches = Regex.Matches(pars, @"(?<name>\b\w+\b)\s*=\s*(?<value>""[^""]*""|'[^']*'|[^""'<>\s" + @"]+)");
                foreach (Match m in matches)
                {
                    //Debug.WriteLine(m.Value + ":: " + m.Groups[1].Value + " ->" + m.Groups[2].Value);
                    EasyWikiExtensionParameter par = new EasyWikiExtensionParameter();
                    par.name = m.Groups[1].Value;
                    par.value = m.Groups[2].Value;
                    //elimina " o ' ad inizio e fine stringa (regex da sistemare!)
                    if (par.value.StartsWith("\"") && par.value.EndsWith("\""))
                        par.value = par.value.Substring(1, par.value.Length - 2);
                    else if (par.value.StartsWith("'") && par.value.EndsWith("'"))
                        par.value = par.value.Substring(1, par.value.Length - 2);

                    //log("add par " + par.name + " = " + par.value);
                    myParams.Add(par);
                }
                return myParams;
            }

            /// <summary>
            /// Get value of param searching it by name
            /// search is case insensitive (.ToLower())
            /// returns value stripping quotes
            /// </summary>
            /// <param name="parameters"></param>
            /// <param name="name"></param>
            /// <returns></returns>
            public string EasyWikiExtensionParameterGetValue(List<EasyWikiExtensionParameter> parameters, string name)
            {
                try
                {
                    foreach (EasyWikiExtensionParameter p in parameters)
                    {
                        if (p.name.ToLower() == name.ToLower())
                            return Regex.Replace(p.value, @"[""|'](.+)[""|']", "$1", RegexOptions.Multiline | RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
                    }
                }
                catch (Exception ex)
                {
                    if (h.iseditable())
                        return "EasyWikiExtensionParameterGetValue error: " + ex.Message;
                    else
                        return "";
                }

                return "";
            }
        }

        private bool isURL(string href)
        {
            //|mailto:
            return Regex.Match(href, "(?i)(http://|https://|ftp://|file://)").Success;
        }
        
        private bool isRelativeURL(string href)
        {
            return Regex.Match(href, "(?i)(/)").Success;
        }

        public string ew_savepagexml(string pageName, string subFolder,XPathNavigator content)
        {
            try
            {
                string wikiFolder = getmodulesetting("wikiFolder").ToString();
                string pagePath = string.Empty; string sPath = string.Empty;
                string phisicalRoot = transformer.DnnSettings.P.HomeDirectoryMapPath; // phisical portal home directory
                if (!phisicalRoot.EndsWith("\\"))
                {
                    phisicalRoot += "\\";
                }
              
                //optional subFolder (currently used only for archived versions in "archive" folder)
                if(subFolder!=string.Empty)
                    sPath = wikiFolder + @"\" + subFolder;
                else
                    sPath = wikiFolder;

                //log("Check path " + System.IO.Path.Combine(phisicalRoot, sPath));

                if (!Directory.Exists(System.IO.Path.Combine(phisicalRoot, sPath)))
                    Directory.CreateDirectory(System.IO.Path.Combine(phisicalRoot, sPath));
                
                pagePath = sPath + @"\" + pageName;

                if (!pagePath.ToLower().EndsWith(".wiki.xml"))
                {
                    pagePath += ".wiki.xml";
                }
              
                System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                XmlDeclaration xmldecl;
                xmldecl = doc.CreateXmlDeclaration("1.0", null, null);
                doc.LoadXml(content.OuterXml);
                XmlElement root = doc.DocumentElement;
                doc.InsertBefore(xmldecl, root);

                //log("Save page to " + System.IO.Path.Combine(phisicalRoot, pagePath));

                doc.Save(System.IO.Path.Combine(phisicalRoot, pagePath));

                return "ok";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        public XPathNavigator ew_readpagexml(string pageName)
        {
            try
            {
                string wikiFolder = getmodulesetting("wikiFolder").ToString();
                string pagePath = wikiFolder + @"\" + pageName;
                if (!pagePath.ToLower().EndsWith(".wiki.xml"))
                {
                    pagePath += ".wiki.xml";
                }
                string phisicalRoot = transformer.DnnSettings.P.HomeDirectoryMapPath; // phisical portal home directory
                if (!phisicalRoot.EndsWith("\\"))
                {
                    phisicalRoot += "\\";
                }
                
                XmlDocument doc = new XmlDocument();
                doc.Load(System.IO.Path.Combine(phisicalRoot, pagePath));
                //string sPage = doc.SelectSingleNode("//page/content").InnerText;
                return doc.CreateNavigator();
            }
            catch (Exception ex)
            {
                XmlDocument doc = new XmlDocument();
                XmlDeclaration xmldecl;
                xmldecl = doc.CreateXmlDeclaration("1.0", null, null);
                doc.LoadXml("<easywiki><error>" + ex.Message + "</error></easywiki>");
                XmlElement root = doc.DocumentElement;
                doc.InsertBefore(xmldecl, root);
                return doc.CreateNavigator();
            }
        }

        public bool ew_deletepagexml(string pageName)
        {
            try
            {
                string wikiFolder = getmodulesetting("wikiFolder").ToString();
                string pagePath = wikiFolder + @"\" + pageName;
                if (!pagePath.ToLower().EndsWith(".wiki.xml"))
                {
                    pagePath += ".wiki.xml";
                }

                string phisicalRoot = transformer.DnnSettings.P.HomeDirectoryMapPath; // phisical portal home directory
                if (!phisicalRoot.EndsWith("\\"))
                {
                    phisicalRoot += "\\";
                }

                System.IO.File.Delete(System.IO.Path.Combine(phisicalRoot, pagePath));
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public bool ew_pageexistsxml(string pageName)
        {
            string wikiFolder = getmodulesetting("wikiFolder").ToString();
            string pagePath = wikiFolder + @"\" + pageName;
            if (!pagePath.ToLower().EndsWith(".wiki.xml"))
            {
                pagePath += ".wiki.xml";
            }

            string phisicalRoot = transformer.DnnSettings.P.HomeDirectoryMapPath;

            if (!System.IO.File.Exists(System.IO.Path.Combine(phisicalRoot, pagePath)))
                return false;
            else
                return true;
        }

        /// <summary>
        /// get list of pages
        /// excluding backup versions (in archive folder) and special pages (named $PageName ?)
        /// </summary>
        /// <returns></returns>
        public XPathNavigator ew_getallpages()
        {
            try
            {
                string wikiFolder = getmodulesetting("wikiFolder").ToString();
                string phisicalRoot = transformer.DnnSettings.P.HomeDirectoryMapPath;
                if (!phisicalRoot.EndsWith("\\"))
                    phisicalRoot += "\\";

                XmlDocument doc = new XmlDocument();
                XmlNode docNode = doc.CreateXmlDeclaration("1.0", "UTF-8", null);
                doc.AppendChild(docNode);
                XmlNode pages = doc.CreateElement("pages");
             
                string[] filePaths = Directory.GetFiles(System.IO.Path.Combine(phisicalRoot, wikiFolder), "*.wiki.xml");
                foreach (string f in filePaths)
                {
                    System.IO.FileInfo ff = Microsoft.VisualBasic.FileIO.FileSystem.GetFileInfo(f);
                    XmlNode page = doc.CreateElement("page");
                    XmlAttribute name = doc.CreateAttribute("name");
                    name.Value = ff.Name.Substring(0, ff.Name.Length - 9); //filename only, aka PageName without ending .wiki.xml
                    page.Attributes.Append(name);
                    XmlAttribute path = doc.CreateAttribute("path");
                    path.Value = ff.FullName;
                    page.Attributes.Append(path);
                    pages.AppendChild(page);   

                    //Regex regex = new Regex(
                    //        "([a-z|A-Z|\\d|\\s?|\\-]+).wiki.xml",
                    //        RegexOptions.IgnoreCase
                    //        | RegexOptions.Multiline
                    //        | RegexOptions.Singleline
                    //        | RegexOptions.Compiled
                    //        );

                    //    Match ms = regex.Match(f);
                    //    if (ms.Success)
                    //    {
                    //        XmlNode page = doc.CreateElement("page");
                    //        XmlAttribute name = doc.CreateAttribute("name");
                    //        name.Value = ms.Groups[1].Value;
                    //        page.Attributes.Append(name);
                    //        pages.AppendChild(page);
                    //    }
                    
                }
                
                doc.AppendChild(pages);
                                
                return doc.CreateNavigator();
            }
            catch (Exception ex)
            {
                XmlDocument doc = new XmlDocument();
                XmlDeclaration xmldecl;
                xmldecl = doc.CreateXmlDeclaration("1.0", null, null);
                doc.LoadXml("<easywiki><error>" + ex.Message + "</error></easywiki>");
                XmlElement root = doc.DocumentElement;
                doc.InsertBefore(xmldecl, root);
                return doc.CreateNavigator();
            }
        }

        public string ew_JustTransform(string xsl, string xml, bool debug, bool IsSuper, string extensionName, List<EasyWikiExtensionParameter> parameters)
        {
            Stopwatch sw = Stopwatch.StartNew();

            xsl = Transformer.PrepareXslt(xsl);

            Helper h = new Helper(this.transformer);
            string html = string.Empty;

            //if (debug)
            //    html = TransformDebug(xml, xsl, h, html, IsSuper);
            //else

            string inlineJS = string.Empty;
            xsl = Transformer.CallableRegex.Replace(xsl, delegate(Match match)
            {
                inlineJS += CreateHandlerJS(match.Groups[2].Value, match.Groups[3].Value, true);
                return string.Empty;
            });

            if (inlineJS != string.Empty)
                inlineJS = "<script type=\"text/javascript\">" + inlineJS + "</script>";

            //log("JS:" + inlineJS);

            //log("T:" + h.transformer.Transform(xml,xsl,IsSuper));

            html = TransformRelease(xml, xsl, h, html, IsSuper, extensionName, parameters);

            //log(extensionName + " html=" + html);

            if (!isajax())
            {
                try
                {
                    //HeaderRegex
                    html = Transformer.HeaderRegex.Replace(html, delegate(Match match)
                    {
                        System.Web.UI.Page p = (System.Web.UI.Page)(HttpContext.Current != null ? HttpContext.Current.Handler : null);
                        var attrs = Transformer.GetXmlTagFromMatch(match);

                        string position = attrs.ContainsKey("position") ? attrs["position"] : "module";
                        string text = match.Groups["b"].Value;

                        if (string.IsNullOrEmpty(text))
                            return string.Empty;

                        if (attrs.ContainsKey("key"))
                        {
                            string key = attrs["key"];
                            string contextKey = "XsltDb.mdo:header." + key;
                            if (HttpContext.Current.Items.Contains(contextKey))
                                return string.Empty;
                            HttpContext.Current.Items[contextKey] = true;
                        }

                        //if (position == "module")
                        //    noajax += text;

                        if (position == "page" && p != null)
                            p.Header.Controls.Add(new System.Web.UI.LiteralControl(text));

                        if (position == "form" && p != null)
                            p.Form.Controls.AddAt(0, new System.Web.UI.LiteralControl(text));

                        return string.Empty;
                    });
                }
                catch(Exception)
                {
                    return string.Empty;
                }
            }
            else
            {
                 html = Transformer.HeaderRegex.Replace(html, delegate(Match match)
                 {
                     return "";
                 });

            }

            //html = html.Trim();


            //log("H:" + html);

            //html = h.transformer.Transform(xml,xsl,IsSuper);
            
            string res = h.getWatchers() + html + inlineJS;
            //string res = h.getWatchers() + html;

            sw.Stop();

            //Uncomment this to start collecting performance information
            //SaveElapsed(sw.ElapsedMilliseconds);

            return res;
        }

        private string TransformRelease(string xml, string xsl, Helper h, string html, bool IsSuper, string extensionName, List<EasyWikiExtensionParameter> parameters)
        {
            string xslKey = Transformer.xslCachePrefix + xsl.MD5();
            XslCompiledTransform t = (XslCompiledTransform)StaticCache2.Get(xslKey, delegate()
            {
                XslCompiledTransform transf = new XslCompiledTransform();
                XsltSettings s = new XsltSettings(true, IsSuper);
                using (StringReader sr = new StringReader(xsl))
                using (XmlReader xr = XmlReader.Create(sr))
                    transf.Load(xr, s, new MdoResolver(this.transformer));
                return transf;
            });


            using (StringReader sr = new StringReader(xml))
            {
                using (XmlReader xr = XmlReader.Create(sr))
                {
                    using (StringWriter sw = new StringWriter())
                    {
                        XsltArgumentList xslArg = new XsltArgumentList();
                        xslArg.AddExtensionObject("urn:mdo", h);

                        //EasyWiki parameters
                        if(isajax())
                            xslArg.AddParam("wikipage", "", iif(param("@page") != "", param("@page"), "index"));
                        else
                            xslArg.AddParam("wikipage", "", iif(request("page") != "", request("page"), "index"));

                        xslArg.AddParam("extension", "", extensionName);
                        xslArg.AddParam("apppath", "", getappath());
                        xslArg.AddParam("wikifolder", "", getmodulesetting("wikiFolder"));
						xslArg.AddParam("httpalias", "", HTTPAlias());
						
                        // wikibaseurl, template, .... ?

                        //EasyWiki extension parameters
                        foreach (EasyWikiExtensionParameter ewparam in parameters)
                            xslArg.AddParam(ewparam.name, "", ewparam.value);
                        
                        DoTransform(t, xr, xslArg, sw);
                        sw.Flush();
                        html = sw.ToString();
                        if (t.OutputSettings.OutputMethod == XmlOutputMethod.Xml)
                        {
                            if (html.Trim().Length == 0)
                                html = "<root/>";
                            string enc = "utf-8";
                            if (HttpContext.Current != null && HttpContext.Current.Response != null)
                                enc = HttpContext.Current.Response.ContentEncoding.HeaderName;
                            html = string.Format("<?xml version=\"1.0\" encoding=\"{0}\"?>", enc) + html;
                        }
                    }
                }
            }
            return html;
        }

        [FileIOPermission(SecurityAction.Deny)]
        [RegistryPermission(SecurityAction.Deny)]
        [UIPermission(SecurityAction.Deny)]
        [ReflectionPermission(SecurityAction.Deny)]
        [WebPermission(SecurityAction.Deny)]
        private void DoTransform(XslCompiledTransform t, XmlReader xr, XsltArgumentList xslArg, StringWriter sw)
        {
            XmlWriterSettings xws = new XmlWriterSettings();
            using (XmlWriter xw = XmlWriter.Create(sw, t.OutputSettings))
                t.Transform(xr, xslArg, xw, new MdoResolver(this.transformer));
        }

        /// <summary>
        /// get url to main wiki page (aka to dnn tabid)
        /// </summary>
        /// <returns></returns>
        public string ew_wikiurl()
        {
            return DotNetNuke.Common.Globals.NavigateURL();
        }

        /// <summary>
        /// get url to wiki page
        /// </summary>
        /// <param name="pageName"></param>
        /// <returns></returns>
        public string ew_pageurl(string pageName)
        {
            if (pageName.ToLower() == "index")
                return ew_wikiurl();

            return DotNetNuke.Common.Globals.NavigateURL(transformer.DnnSettings.T.TabID, "", "page=" + pageName);
        }

        ///// <summary>
        ///// get url to wiki page with additional custom querystring params
        ///// </summary>
        ///// <param name="parameters"></param>
        ///// <returns></returns>
        //public string ew_pageurl(string pageName, string[] parameters)
        //{
        //    string[] tmp = new string[parameters.GetUpperBound(0) + 1];
        //    if (parameters != null)
        //    {
        //        System.Array.Copy(parameters, tmp, System.Math.Min(parameters.Length, tmp.Length));
        //        tmp[tmp.GetUpperBound(0)] = "page=" + pageName;
        //        parameters = tmp;
        //    }
        //    return DotNetNuke.Common.Globals.NavigateURL(transformer.DnnSettings.T.TabID, "", parameters);
        //}

        public string ew_renamepagexml(string pageName, string pageNewName)
        {
            string rc = string.Empty;
            try
            {
                if (ew_pageexistsxml(pageNewName))
                    return "Error: a page named '" + pageNewName + "' already exists";
                
                string wikiFolder = getmodulesetting("wikiFolder").ToString();
                string pagePath = wikiFolder + @"\" + pageName;
                string pagePath2 = wikiFolder + @"\" + pageNewName;

                if (!pagePath.ToLower().EndsWith(".wiki.xml"))
                    pagePath += ".wiki.xml";

                if (!pagePath2.ToLower().EndsWith(".wiki.xml"))
                    pagePath2 += ".wiki.xml";
                
                string phisicalRoot = transformer.DnnSettings.P.HomeDirectoryMapPath; // phisical portal home directory
                if (!phisicalRoot.EndsWith("\\"))
                    phisicalRoot += "\\";

                try
                {
                    File.Move(Path.Combine(phisicalRoot, pagePath), Path.Combine(phisicalRoot, pagePath2));
                }
                catch(Exception e){
                    rc = "ew_renamepagexml Exception: " + e.Message;
                    return rc;
                }

                rc = "ok";
                return rc;
            }
            catch (Exception ex)
            {
                rc = "ew_renamepagexml Exception: " + ex.Message;
                return rc;
            }
        }

        /// <summary>
        /// get link to icon for a file, based on file ext
        /// available icons are searched in file manager gif icons folder (/images/FileManager/Icons/)
        /// </summary>
        /// <param name="urlToFile"></param>
        /// <returns></returns>
        public string ew_getFileIcon(string urlToFile)
        {
            string[] icons = Directory.GetFiles(mappath(":images/FileManager/Icons"), "*.gif");
            string ext = urlToFile.Substring(urlToFile.LastIndexOf(".")+1);
            foreach (string i in icons)
            {
                int l = i.LastIndexOf('\\');
                int l2 = i.LastIndexOf('/');
                string name = i.Substring((int)iif(l > 0, l, l2)+1, i.Length - i.Substring(i.LastIndexOf('.')).Length - (int)iif(l > 0, l, l2) - 1);
                if (name == ext)
                    return getappath() + "images/FileManager/Icons/" + i.Substring((int)iif(l > 0, l, l2)+1);
            }
            return "";
        }

        private string CreateHandlerJS(string fn, string argList, bool callable)
        {
            string js = @"
function {fn}({argList})
{
    var p = {};
    {argAssign}
    return mdo_handler_comm({ids}, p, {callable}, callback);
}
";
            string argAssign = string.Empty;
            argList = argList.Trim();
            if (argList.Length > 0)
            {
                string[] args = argList.Split(',');
                string[] assigns = new string[args.Length];

                for (int i = 0; i < args.Length; i++)
                {
                    args[i] = args[i].Trim();
                    assigns[i] = string.Format("p[\"{0}\"] = {0};", args[i]);
                }
                argAssign = string.Join(Environment.NewLine, assigns);
                argList = string.Join(", ", args).Trim();
            }
            if (argList.Length > 0) argList += ", ";
            argList += "callback";


            js = js
                .Replace("{fn}", fn.Trim())
                .Replace("{argList}", argList)
                .Replace("{argAssign}", argAssign.Trim())
                .Replace("{ids}", XsltDb.Transformer.EncodeJsString(transformer.ClientID))
                .Replace("{callable}", callable ? "\"" + fn + "\"" : "null");


            return Regex.Replace(js, "\\s+", " ", RegexOptions.Singleline);
        }

        public string ew_page2pdf(string pageName)
        {
            try
            {
                string wikiFolder = getmodulesetting("wikiFolder").ToString();
                string pagePath = wikiFolder + @"\" + pageName;
                if (!pagePath.ToLower().EndsWith(".wiki.xml"))
                {
                    pagePath += ".wiki.xml";
                }
                string phisicalRoot = transformer.DnnSettings.P.HomeDirectoryMapPath; // phisical portal home directory

                if (!phisicalRoot.EndsWith("\\")) phisicalRoot += "\\";

                //log("pagePath=" + pagePath + ", " + Path.Combine(phisicalRoot, pagePath));

                XmlDocument doc = new XmlDocument();
                doc.Load(Path.Combine(phisicalRoot, pagePath));
                string sPage = doc.SelectSingleNode("//page/content").InnerText;
                string html = ew_renderstring(sPage, true);
                string td = phisicalRoot + @"\" + wikiFolder + @"\tmp\";

                if (!Directory.Exists(td))
                    Directory.CreateDirectory(td);
                
                //string tmpFile = System.IO.Path.GetTempFileName() + ".html";
                string tmpFile = td + Path.GetRandomFileName() + ".html";

                File.WriteAllText(tmpFile, html, System.Text.Encoding.Unicode);

                //string pdfFile = System.IO.Path.GetTempFileName() + ".pdf";
                string pdfFile = td + Path.GetRandomFileName() + ".pdf";

                /*
                 * versione 1: conversione con exe e tutti i parametri
                 * 
                */
                //ProcessStartInfo ProcessProperties = new ProcessStartInfo();
                //ProcessProperties.FileName = @"""c:\Program Files\wkhtmltopdf\wkhtmltopdf.exe""";
                //ProcessProperties.Arguments = "--disable-smart-shrinking --print-media-type --footer-font-size 10 --footer-center [page]/[topage] --footer-left EasyWiki --header-left [date] --header-right [page]/[topage] " + tmpFile + " " + pdfFile;
                //ProcessProperties.WindowStyle = System.Diagnostics.ProcessWindowStyle.Minimized;
                //Process myProcess = Process.Start(ProcessProperties);
                //// 2 minutes timeout
                //myProcess.WaitForExit(2 * 60 * 1000);

                /*
                 * versione 2: conversione con dll
                 * 
                */
                using (var wk = _GetConverter())
                {
                    // _Log.DebugFormat("Performing conversion..");

                    wk.GlobalSettings.Margin.Top = "0cm";
                    wk.GlobalSettings.Margin.Bottom = "0cm";
                    wk.GlobalSettings.Margin.Left = "0cm";
                    wk.GlobalSettings.Margin.Right = "0cm";

                    //wk.GlobalSettings.Out = @"c:\temp\tmp.pdf";

                    wk.ObjectSettings.Web.UserStyleSheet = phisicalRoot + @"DesktopModules\EasyWiki\EasyWiki.css";
                    //wk.ObjectSettings.Web.LoadImages = true;

                    wk.ObjectSettings.Web.EnablePlugins = false;
                    wk.ObjectSettings.Web.EnableJavascript = false;
                    wk.ObjectSettings.Page = tmpFile;
                    //wk.ObjectSettings.Page = "http://doc.trolltech.com/4.6/qstring.html";
                    wk.ObjectSettings.Load.Proxy = "none";

                    var tmp = wk.Convert();

                    //Assert.IsNotEmpty(tmp);
                    var number = 0;
                    lock (this) number = count++;
                    File.WriteAllBytes(pdfFile, tmp);
                }

                ew_deltempfile(tmpFile);

                return pdfFile;

            }
            catch (Exception ex)
            {
                log("Error: " + ex.Message);
                return ex.Message;
            }
        }


        public void ew_deltempfile(string path)
        {
           try{
            File.Delete(path);
           }
           catch (Exception ex)
           {
               log("DelTempFile Error: " + ex.Message);
           }
        }

        private MultiplexingConverter _GetConverter()
        {
            var obj = new MultiplexingConverter();
            obj.Begin += (s, e) => _Log.DebugFormat("Conversion begin, phase count: {0}", e.Value);
            obj.Error += (s, e) => _Log.Error(e.Value);
            obj.Warning += (s, e) => _Log.Warn(e.Value);
            obj.PhaseChanged += (s, e) => _Log.InfoFormat("PhaseChanged: {0} - {1}", e.Value, e.Value2);
            obj.ProgressChanged += (s, e) => _Log.InfoFormat("ProgressChanged: {0} - {1}", e.Value, e.Value2);
            obj.Finished += (s, e) => _Log.InfoFormat("Finished: {0}", e.Value ? "success" : "failed!");
            return obj;
        }


    }

    
}