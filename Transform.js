function Transform()
    {
    try
        {
        var Shell=new ActiveXObject('WScript.Shell');
        Shell.Run(GetSessionFolderName()+'ProcessAll.bat',1,true);
        }
    catch (e)
        {
        Log(e.name);
        return false;
        }
    return true;
    }
