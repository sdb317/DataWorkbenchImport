function Log(Message)
    {
    window.alert(Message);
    }

function Popup(Message,Title,Type)
    {
    return window.confirm(Message);
    }

function GetCurrentFolder()
    {
    return document.location.pathname.replace(/^\//i,'').replace(/ImportRodent\.hta/i,'');
    }

