function Load(Schema,FileName,ComponentID)
    {
    try
        {
        var Request=new ActiveXObject('Msxml2.XMLHTTP');
        //var URL='http://localhost:8000/getspecification/'+ComponentID+'/json';
        //Request.open('GET',URL,false);
        //Request.send();
        var Payload=LoadJSON(FileName);
        //Payload=Payload.replace(/\n/g,' ');
        //Payload=Payload.replace(/\s{2,}/g,' ');
        var Template;
        switch (Payload.Specification.name) 
            {
            case 'SpecimenGroup':
                switch (Payload.Specification.children[0].value) 
                    {
                    case 'Rodent':
                        Template=jsonPath(Schema,'$..[?(@.name=="Subject.Rodent")].children')[0];
                        break;
                    case 'Human':
                        Template=jsonPath(Schema,'$..[?(@.name=="Subject.Human")].children')[0];
                        break;
                    default:
                        return false; // Template not found
                    }
                break;
            case 'Activity':
                Template=jsonPath(Schema,'$..[?(@.name=="Activity")].children')[0];
                break;
            case 'Dataset':
                Template=jsonPath(Schema,'$..[?(@.name=="Dataset")].children')[0];
                break;
            default:
                return false; // Template not found
            }
        var Items=jsonPath(Template,'$..[?(@.name)]');
        //Log('Validating...');
        for (var Item in Items) // For everything in the schema
            {
            if (!jsonPath(Payload,'$..[?(@.name=="'+Items[Item].name+'")]')) // If not found...
                {
                //Log('  False: '+Items[Item].name);
                switch (Payload.Specification.name) 
                    {
                    case 'SpecimenGroup':
                        //Payload.Specification.children[0].children[0].children.push(Items[Item]); // Add to the end
                        for (var i=0;i<Payload.Specification.children[0].children.length;i++)
                            Payload.Specification.children[0].children[i].children.splice(Item,0,Items[Item]); // Insert it in the correct position
                        break;
                    default:
                        Payload.Specification.children.splice(Item,0,Items[Item]); // Insert it in the correct position
                    }
                }
            else
                {
                //Log('  True: '+Items[Item].name);
                }
            }
        var State=1; // Curated // 0; // Unknown // 
        //var URL='http://localhost:8000/savespecification/'+ComponentID+'/'+State+'/json/';
        var URL='';
        //var Response=Popup('Update Production?','Load',1);
        var Response=true;
        if (Response)
            {
            //URL='https://localhost:8000/savespecification/'+ComponentID+'/'+State+'/json/';
            //URL='https://data-workbench-test.herokuapp.com/savespecification/'+ComponentID+'/'+State+'/json/';
            URL='https://data-workbench.herokuapp.com/savespecification/'+ComponentID+'/'+State+'/json/'; // !!!PRODUCTION!!!
            //Log(URL);
            Payload=this.JSON.stringify(Payload,undefined,3);
            //Log(Payload);
            Request.open('POST',URL,false);
            //var Payload='{"Specification": {"Categories": [{"Category": "General","Items": [{"Item": "Title","Properties": {"Validate": "PLA","Required": "Y","Type": "Select","Occurrence": "{1}"}},{"Item": "MethodStatement","Properties": {"Validate": "","Required": "","Type": "SelectionTextarea","Occurrence": "{1}"}}]},{"Category": "Activity","Items": [{"Item": "EthicsAuthority","Properties": {"Validate": "","Required": "Y","Type": "Text","Occurrence": "{1}"}},{"Item": "EthicsApprovalID","Properties": {"Validate": "","Required": "Y","Type": "Text","Occurrence": "{1}"}},{"Item": "Protocol","Properties": {"Validate": "","Required": "","Type": "DynamicList","Occurrence": "*"}}]},{"Category": "Dataset","Items": [{"Item": "ReleaseDate","Properties": {"Validate": "Y","Required": "","Type": "DatePicker","Occurrence": "{1}"}},{"Item": "Owner","Properties": {"Validate": "Y","Required": "Y","Type": "DynamicList","Occurrence": "{1}"}},{"Item": "License","Properties": {"Validate": [{"name": "Public","value": "P"}],"Required": "Y","Type": "Select","Occurrence": "{1}"}},{"Item": "Category","Properties": {"Validate": "yes+","Required": "Y","Type": "DynamicList","Occurrence": "+"}},{"Item": "DataBundle","Properties": {"Validate": "Y","Required": "","Type": "DynamicList","Occurrence": "{1}"}},{"Item": "Atlas","Properties": {"Validate": [{"name": "Allen","value": "A"},{"name": "Waxholm","value": "W"}],"Required": "","Type": "Select","Occurrence": "{1}"}},{"Item": "Region","Properties": {"Validate": "yes+","Required": "Y","Type": "Select","Occurrence": "{1}"}}]},{"Category": "Reference","Items": [{"Item": "DatasetID","Properties": {"Validate": "","Required": "","Type": "Static","Occurrence": "{1}"}},{"Item": "ComponentID","Properties": {"Validate": "Y","Required": "","Type": "Static","Occurrence": "{0,1}"}},{"Item": "ReleaseID","Properties": {"Validate": "","Required": "","Type": "Static","Occurrence": ""}},{"Item": "CreatedDate","Properties": {"Validate": "","Required": "","Type": "Static","Occurrence": "{1}"}},{"Item": "ModifiedDate","Properties": {"Validate": "","Required": "","Type": "Static","Occurrence": "{1}"}},{"Item": "Contributor","Properties": {"Validate": "Y","Required": "Y","Type": "DynamicList","Occurrence": "+"}}]},{"Category": "Specimen","Items": [{"Item": "SpecimenID","Properties": {"Validate": "","Required": "Y","Type": "Text","Occurrence": "{1}"}},{"Item": "Species","Properties": {"Validate": [{"name": "Mouse","value": "M"},{"name": "Rat","value": "R"},{"name": "Human","value": "H"}],"Required": "Y","Type": "Select+DynamicList","Occurrence": "{1}"}},{"Item": "Strain","Properties": {"Validate": "Y","Required": "Y","Type": "DynamicList","Occurrence": "{0,1}"}},{"Item": "Sex","Properties": {"Validate": [{"name": "Male","value": "M"},{"name": "Female","value": "F"}],"Required": "Y","Type": "Select","Occurrence": "{1}"}},{"Item": "AgeValue","Properties": {"Validate": "Y","Required": "Y","Type": "Text","Occurrence": "{1}"}},{"Item": "AgeCategory","Properties": {"Validate": [{"name": "Adult","value": "A"},{"name": "Juvenile","value": "J"}],"Required": "Y","Type": "Select","Occurrence": "{1}"}},{"Item": "Weight","Properties": {"Validate": "","Required": "Y","Type": "Text","Occurrence": "{1}"}}]}]}}';
            Request.setRequestHeader('connection','close');
            Request.setRequestHeader('content-type','application/json');
            Request.setRequestHeader('content-length',Payload.length);
            Request.send(Payload);
            var Status=Request.responseText;
            Log(Status);
            }
        }
    catch (e)
        {
        Log(e.name);
        return false;
        }
    return true;
    }
