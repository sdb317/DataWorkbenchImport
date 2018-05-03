function Log(Message)
    {
    WScript.Echo(Message);
    }

function Popup(Message,Title,Type)
    {
    var Shell=new ActiveXObject('WScript.Shell');
    var State=Shell.Popup(Message,0,Title,Type);
    if (State!=2) // Not 'Cancel'
        return true;
    else
        return false;
    }

