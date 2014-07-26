@isTest
public class MockWhoAtWebAPIAccountExtension implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('');
        res.setStatusCode(200);
        System.assertEquals(200, res.getStatusCode());

		//return test value based on incoming url
        if (req.getEndpoint().contains('abe%40example.com')) {
            res.setBody(loginSuccessAbe);
        }
        else if (req.getEndpoint().contains('bob%40example.com')) {
            res.setBody(loginSuccessBob);
        }
        else if (req.getEndpoint().contains('search')) {
            res.setBody(dellSearchResponse);
        }
                
        return res;
    }
    
    public String loginSuccessAbe = 
'{' + 
'  "member": {' + 
'    "avatar": "https://s3.amazonaws.com/whoat_assets/images/member_avatar.png",' + 
'    "badges": {' + 
'      "inbox": {' + 
'        "total": 0,' + 
'        "unread": 0' + 
'      },' + 
'      "outbox": {' + 
'        "total": 6,' + 
'        "unread": 1' + 
'      }' + 
'    },' + 
'    "contacts": 5884,' + 
'    "coworkers": 15,' + 
'    "id": 2,' + 
'    "label": "Abe Tester",' + 
'    "networks": 3,' + 
'    "username": "abe@example.com",' + 
'    "verified": true,' + 
'    "version": 1190604' + 
'  },' + 
'  "progress": {' + 
'    "browse": false,' + 
'    "groups": false,' + 
'    "invite": false,' + 
'    "profile": false,' + 
'    "request": true,' + 
'    "respond": true,' + 
'    "search": true,' + 
'    "snarf": true' + 
'  },' + 
'  "state": {' + 
'    "accessible_member_count": 15' + 
'  },' + 
'  "token": "f6fa35d16820ef165914",' + 
'  "type": "Agent",' + 
'  "verified": true' + 
'}';

    public String loginSuccessBob = 
'{' + 
'  "member": {' + 
'    "avatar": "https://s3.amazonaws.com/whoat_assets/images/member_avatar.png",' + 
'    "badges": {' + 
'      "inbox": {' + 
'        "total": 0,' + 
'        "unread": 0' + 
'      },' + 
'      "outbox": {' + 
'        "total": 6,' + 
'        "unread": 1' + 
'      }' + 
'    },' + 
'    "contacts": 5884,' + 
'    "coworkers": 15,' + 
'    "id": 2,' + 
'    "label": "Bob Tester",' + 
'    "networks": 3,' + 
'    "username": "bob@example.com",' + 
'    "verified": true,' + 
'    "version": 1190604' + 
'  },' + 
'  "progress": {' + 
'    "browse": false,' + 
'    "groups": false,' + 
'    "invite": false,' + 
'    "profile": false,' + 
'    "request": true,' + 
'    "respond": true,' + 
'    "search": true,' + 
'    "snarf": true' + 
'  },' + 
'  "state": {' + 
'    "accessible_member_count": 15' + 
'  },' + 
'  "token": "f6fa35d16820ef165914",' + 
'  "type": "Agent",' + 
'  "verified": true' + 
'}';

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

}