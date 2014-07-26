@isTest
public class MockWhoAtWebAPISearch implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assert(req.getEndpoint().startsWith('https://whoat.net/api/v1'));
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[]');
        res.setStatusCode(200);

		//return test value based on incoming url
        if (req.getEndpoint().contains('dell')) {
            res.setBody(dellSearchResponse);
        }
        else if (req.getEndpoint().contains('notLoggedIn')) {
            res.setBody(notLoggedIn);
        }
                
        return res;
    }
    
    public String dellSearchResponse = 
'[' + 
'  {' + 
'    "details": {' + 
'      "emails": [' + 
'        {' + 
'          "label": "michael@dell.com",' + 
'          "tag": "",' + 
'          "type": "",' + 
'          "value": "michael@dell.com"' + 
'        }' + 
'      ],' + 
'      "phones": []' + 
'    },' + 
'    "emails": [' + 
'      {' + 
'        "label": "michael@dell.com",' + 
'        "tag": "",' + 
'        "type": "",' + 
'        "value": "michael@dell.com"' + 
'      }' + 
'    ],' + 
'    "guid": "M4DE_MDVA_2_V5QH",' + 
'    "id": "M4DE_MDVA_2_V5QH",' + 
'    "label": "Michael Dell",' + 
'    "name": {' + 
'      "first": "Michael",' + 
'      "last": "Dell"' + 
'    },' + 
'    "networks": [' + 
'      {' + 
'        "count": 4,' + 
'        "id": 13307,' + 
'        "label": "who@22",' + 
'        "type": "Group"' + 
'      },' + 
'      {' + 
'        "count": 5,' + 
'        "id": 6,' + 
'        "label": "Who@",' + 
'        "type": "Organization"' + 
'      },' + 
'      {' + 
'        "count": 1,' + 
'        "id": 11751,' + 
'        "label": "Personal",' + 
'        "type": "Personal"' + 
'      }' + 
'    ],' + 
'    "organization": "MSD Ventures",' + 
'    "phones": [],' + 
'    "size": 12,' + 
'    "title": "Chairman and CEO at Dell"' + 
'  },' + 
'  {' + 
'    "guid": "311J_311J_2_V5QH",' + 
'    "id": "311J_311J_2_V5QH",' + 
'    "label": "Adam Dell",' + 
'    "name": {' + 
'      "first": "Adam",' + 
'      "last": "Dell",' + 
'      "middle": "R."' + 
'    },' + 
'    "networks": [' + 
'      {' + 
'        "count": 1,' + 
'        "id": 13307,' + 
'        "label": "who@22",' + 
'        "type": "Group"' + 
'      }' + 
'    ],' + 
'    "size": 1,' + 
'    "title": "Managing Partner"' + 
'  }' + 
']';

    public String notLoggedIn = 
'{' +
'  "error": {' +
'    "code": 9955,' +
'    "message": "You are not logged in.",' +
'    "uuid": "534fb0f36e745f1247911b0377a8d01a"' +
'  }' +
'}';

    public String badContact = 
'XXXXXXXXXX';

    
}