using System;
using System.Xml;
using System.Web;
using System.IO;
using System.Security.Cryptography;
using System.Text.RegularExpressions;

///
///
/// Trapias XsltDb Utilities
/// (c) Alberto Velo, 2010-2011
///
/// last update: 12/01/2011
///
namespace Findy.XsltDb
{
public partial class Helper
{
    /// <summary>
    /// get current logged user profile property value, for property named pname
    /// </summary>
    /// <param name="pname"></param>
    /// <returns></returns>
    public string GetUserProfileProperty(string pname)
    {
        try
        {
            DotNetNuke.Entities.Users.UserInfo ui = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
            string pval = ui.Profile.GetPropertyValue(pname);

            if (pval != "" && pval!=null)
                return pval;
            else
                return "";
        }
        catch (Exception)
        {
            return "";
        }
    }

    //public bool iseditable()
    //{
    //    DotNetNuke.Entities.Modules.ModuleInfo mi = new DotNetNuke.Entities.Modules.ModuleController().GetModule(transformer.DnnSettings.M.ModuleID);
    //    bool editPerm = DotNetNuke.Security.Permissions.ModulePermissionController.HasModuleAccess(DotNetNuke.Security.SecurityAccessLevel.Edit, "CONTENT", mi);
    //    if (editPerm)
    //    {
    //        string setting = Convert.ToString(DotNetNuke.Services.Personalization.Personalization.GetProfile("Usability", "UserMode" + transformer.DnnSettings.P.PortalID.ToString()));
    //        if (setting.ToUpper() == "EDIT")
    //            return true;
    //        else
    //            return false;
    //    }
    //    else
    //        return false;

    //}
    
    public DateTime Tomorrow()
    {
        DateTime oggi = DateTime.Today;
        oggi = oggi.AddDays(1);
        return oggi;
    }

    /// <summary>
    /// Register javascript file avoiding duplicates (obsolete: use mdo:header)
    /// </summary>
    /// <param name="key"></param>
    /// <param name="path"></param>
    public void registerjs(string key, string path)
    {
        try
        {
            if (!transformer.Module.IsPostBack)
                if (!DotNetNuke.UI.Utilities.ClientAPI.IsClientScriptBlockRegistered(transformer.Module.Page, key))
                    DotNetNuke.UI.Utilities.ClientAPI.RegisterClientScriptBlock(transformer.Module.Page, key, String.Format("<script type=\"text/javascript\" src=\"{0}\"></script>", resolveurl(path)));
        }
        catch (Exception)
        { }
    }

    /// <summary>
    /// Register css stylesheet avoiding duplicates (obsolete: use mdo:header)
    /// </summary>
    /// <param name="key"></param>
    /// <param name="path"></param>
    public void registercss(string key, string path)
    {
        try
        {
            if (!transformer.Module.IsPostBack)
                if (!DotNetNuke.UI.Utilities.ClientAPI.IsClientScriptBlockRegistered(transformer.Module.Page, key))
                    DotNetNuke.UI.Utilities.ClientAPI.RegisterClientScriptBlock(transformer.Module.Page, key, String.Format("<link rel=\"stylesheet\" type=\"text/css\" href=\"{0}\"></script>", resolveurl(path)));
        }
        catch (Exception)
        { }
    }

    /// <summary>
    /// get DNN AppPath
    /// eg. / or /dotnetnuke/
    /// </summary>
    /// <returns></returns>
    public string getappath()
    {
        try
        {
            if (HttpContext.Current.Request.ApplicationPath.EndsWith("/"))
                return HttpContext.Current.Request.ApplicationPath;
            else
                return HttpContext.Current.Request.ApplicationPath + "/";
        }
        catch (Exception e)
        { return ""; }
    }

    /// <summary>
    /// Get current portal alias without ending slash
    /// SSL-aware
    /// </summary>
    /// <returns></returns>
    public string HTTPAlias()
    {
        string protocol = "http://";

        if(HttpContext.Current.Request.IsSecureConnection)
            protocol = "https://";

        string url = protocol + HttpContext.Current.Request.Url.Host; // + HttpContext.Current.Request.ApplicationPath;
        if (url.EndsWith("/"))
            return url.Substring(0, url.Length - 1);
        else
            return url;
    }


    /// <summary>
    /// transform string to lower case
    /// </summary>
    /// <param name="s"></param>
    /// <returns></returns>
    public string tolowercase(string s)
    {
        return s.ToLower();
    }

   
    /// <summary>
    /// Save text file in Portal
    /// </summary>
    /// <param name="filePath">path to file, relative to Portal root</param>
    /// <param name="content">file content</param>
    /// <returns></returns>
    public bool SaveFile(string filePath, string content)
    {
        try
        {
            string phisicalRoot = transformer.DnnSettings.P.HomeDirectoryMapPath; // phisical portal home directory
            if (!phisicalRoot.EndsWith("\\"))
            {
                phisicalRoot += "\\";
            }
             System.IO.StreamWriter w;

            w = System.IO.File.CreateText(System.IO.Path.Combine(phisicalRoot, filePath));

            w.Write(content);
            w.Flush();
            w.Close();
            
            return true;
        }
        catch (Exception)
        {
            return false;
        }
    }

    /// <summary>
    /// Read text file
    /// </summary>
    /// <param name="filePath">path to file, relative to Portal root</param>
    /// <returns>file content as string</returns>
    public string ReadFile(string filePath)
    {
        try
        {
            string phisicalRoot = transformer.DnnSettings.P.HomeDirectoryMapPath; // phisical portal home directory
            if (!phisicalRoot.EndsWith("\\"))
            {
                phisicalRoot += "\\";
            }
            
            string result = System.IO.File.ReadAllText(System.IO.Path.Combine(phisicalRoot, filePath));

            return result;
        }
        catch (Exception)
        {
            return String.Empty;
        }
    }

    /// <summary>
    /// Delete file
    /// </summary>
    /// <param name="filePath">path to file, relative to Portal root</param>
    /// <returns></returns>
    public bool DeleteFile(string filePath)
    {
        try
        {
            string phisicalRoot = transformer.DnnSettings.P.HomeDirectoryMapPath; // phisical portal home directory
            if (!phisicalRoot.EndsWith("\\"))
            {
                phisicalRoot += "\\";
            }

            System.IO.File.Delete(System.IO.Path.Combine(phisicalRoot, filePath));
            return true;
        }
        catch (Exception)
        {
            return false;
        }
    }


    /// <summary>
    /// Clean HTML string (remove tags)
    /// </summary>
    /// <param name="sHTML"></param>
    /// <returns></returns>
    public string CleanHTML(string sHTML)
    {
        return DotNetNuke.Common.Utilities.HtmlUtils.Clean(sHTML, false);
    }

    public string CamelCase(string sText)
    {
        return replace(Microsoft.VisualBasic.Strings.StrConv(sText,Microsoft.VisualBasic.VbStrConv.ProperCase,0),"","");
    }

    public string ToProperCase(string sString)
    {
        return replace(Microsoft.VisualBasic.Strings.StrConv(sString, Microsoft.VisualBasic.VbStrConv.ProperCase, 0), "", "");
    }

    public bool endswith(string mystring, string pattern)
    {
        return mystring.EndsWith(pattern);
    }

    public int datediff(DateTime date1, DateTime date2, string mode)
    {
        switch (mode.ToLower())
        {
            case "h":
                return date2.Subtract(date1).Hours;

            case "m":
                return date2.Subtract(date1).Minutes;

            case "s":
                return date2.Subtract(date1).Seconds;

            case "d":
                return date2.Subtract(date1).Days;

            default:
                return date2.Subtract(date1).Days;
        }
    }

    public int rnd()
    {
        Random r = new Random();
        return r.Next(1, 99999);
    }
}

}