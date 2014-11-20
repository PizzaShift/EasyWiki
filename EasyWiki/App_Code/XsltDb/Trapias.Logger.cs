using System;
using System.IO;
using DotNetNuke;
///
///
/// Trapias XsltDb Logging Utilities
/// (c) Alberto Velo, 2011
///
/// last update: 31/01/2011
///
namespace Findy.XsltDb
{
public partial class Helper
{

    public void log(string message)
    {
        log(1, "", "XsltDb", message);
    }

    public void log(int severity, string message)
    {
        log(severity, "", "XsltDb", message);
    }

    public void log(int severity, string log4netCfg, string libName, string message)
    {
        if(log4netCfg == "")
        {
            //load log4net configuration from DNN Host root (e.g. c:\inetpub\wwwroot\dotnetnuke\log4net.xml)
            //log4netCfg = DotNetNuke.Common.Globals.ApplicationMapPath + "\\log4net.xml";
            //load log4net configuration from portal root (e.g. c:\inetpub\wwwroot\dotnetnuke\Portals\0\log4net.xml)
            log4netCfg = transformer.DnnSettings.P.HomeDirectoryMapPath + "\\log4net.xml";
        }

        log4net.Core.Level logLevel = log4net.Core.Level.Debug;
        switch (severity)
        {
            case 0:
                logLevel = log4net.Core.Level.Debug;
                break;

            case 1:
                logLevel = log4net.Core.Level.Info;
                break;

            case 2:
                logLevel = log4net.Core.Level.Warn;
                break;

            case 3:
                logLevel = log4net.Core.Level.Error;
                break;

            case 4:
                logLevel = log4net.Core.Level.Fatal;
                break;

            default:
                logLevel = log4net.Core.Level.Debug;
                break;
        }

        FileInfo cfgFile = new FileInfo(log4netCfg);
        log4net.Config.XmlConfigurator.Configure(cfgFile);
        log4net.ILog log = log4net.LogManager.GetLogger(libName);
        log4net.Core.LoggingEvent evt = new log4net.Core.LoggingEvent(typeof(Helper), log.Logger.Repository, log.Logger.Name, logLevel, message, null);
        log.Logger.Log(evt);
    }
 
}

}