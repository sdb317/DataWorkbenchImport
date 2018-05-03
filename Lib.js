FileSystem=new ActiveXObject('Scripting.FileSystemObject'); // Add this to the global namesapce

function GetSchema()
    {
    try 
        {
        var SchemaFile=FileSystem.OpenTextFile(GetCurrentFolder()+'Schema.json');
        var Schema=SchemaFile.ReadAll().replace(/export default /,'');
        SchemaFile.Close();
        return this.JSON.parse(Schema);
        }
    catch (e)
        {
        Log('GetSchema failed: '+e.name);
        }
    return;
    }

function LoadJSON(FileName)
    {
    try 
        {
        var Stream=new ActiveXObject('ADODB.Stream');
        Stream.Open();
        Stream.Type=2;
        Stream.Charset='UTF-8';
        Stream.LoadFromFile(FileName);
        var Data=Stream.ReadText();
        Stream.Close();
        Data=this.JSON.parse(Data);
        return Data;
        }
    catch (e)
        {
        Log('LoadJSON failed: '+e.name);
        }
    return;
    }

function SaveJSON(FileName,Data)
    {
    try 
        {
        var Stream=new ActiveXObject('ADODB.Stream');
        Stream.Open();
        Stream.Type=2;
        Stream.Charset='UTF-8';
        Stream.WriteText(this.JSON.stringify(Data));
        Stream.SaveToFile(FileName,2);
        Stream.Close();
        return true;
        }
    catch (e)
        {
        Log('SaveJSON failed: '+e.name);
        }
    return false;
    }

