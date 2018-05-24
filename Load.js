function Load(Request,Schema,Class,FileName,Type,ComponentID) {
    try {
        var Payload = LoadJSON(FileName);
        //Payload=Payload.replace(/\n/g,' ');
        //Payload=Payload.replace(/\s{2,}/g,' ');
        var Template;
        switch (Payload.Specification.name) {
            case 'SpecimenGroup':
                switch (Payload.Specification.children[0].value) {
                    case 'Rodent':
                        Template = jsonPath(Schema, '$..[?(@.name=="Subject.Rodent")].children')[0];
                        break;
                    case 'Human':
                        Template = jsonPath(Schema, '$..[?(@.name=="Subject.Human")].children')[0];
                        break;
                    default:
                        return false; // Template not found
                }
                break;
            case 'Activity':
                Template = jsonPath(Schema, '$..[?(@.name=="Activity")].children')[0];
                break;
            case 'Dataset':
                Template = jsonPath(Schema, '$..[?(@.name=="Dataset")].children')[0];
                break;
            default:
                return false; // Template not found
        }
        var Items = jsonPath(Template, '$..[?(@.name)]');
        //Log('Validating...');
        for (var Item in Items) // For everything in the schema
        {
            if (!jsonPath(Payload, '$..[?(@.name=="' + Items[Item].name + '")]')) // If not found...
            {
                //Log('  False: '+Items[Item].name);
                switch (Payload.Specification.name) {
                    case 'SpecimenGroup':
                        //Payload.Specification.children[0].children[0].children.push(Items[Item]); // Add to the end
                        for (var i = 0; i < Payload.Specification.children[0].children.length; i++)
                            Payload.Specification.children[0].children[i].children.splice(Item, 0, Items[Item]); // Insert it in the correct position
                        break;
                    default:
                        Payload.Specification.children.splice(Item, 0, Items[Item]); // Insert it in the correct position
                }
            }
            else {
                //Log('  True: '+Items[Item].name);
            }
        }
        var State = 1; // Curated // 0; // Unknown // 
        var URL = '';
        //var Response=Popup('Update Production?','Load',1);
        var Response = true;
        if (Response) {
            //URL='https://localhost:8000/savespecification/'+ComponentID+'/'+State+'/json/';
            //URL = 'https://data-workbench-test.herokuapp.com/savespecification/' + ComponentID + '/' + State + '/json/';
            URL = 'https://data-workbench.herokuapp.com/savespecification/' + ComponentID + '/' + State + '/json/'; // !!!PRODUCTION!!!
            //Log(URL);
            Payload = this.JSON.stringify(Payload, undefined, 3);
            //Log(Payload);
            Request.open('POST', URL, false);
            Request.setRequestHeader('content-type', 'application/json');
            Request.setRequestHeader('content-length', Payload.length);
            Request.send(Payload);
            var Status = Request.responseText;
            Log(Status);
        }
    }
    catch (e) {
        Log(e.name);
        return false;
    }
    return true;
}
