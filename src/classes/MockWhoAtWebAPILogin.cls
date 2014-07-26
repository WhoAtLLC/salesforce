@isTest
public class MockWhoAtWebAPILogin implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assert(req.getEndpoint().startsWith('https://whoat.net/api/v1'));
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('');
        res.setStatusCode(200);

		//return test value based on incoming url
        if (req.getEndpoint().contains('abe%40example.com')) {
            res.setBody(loginSuccess);
        }
        else if (req.getEndpoint().contains('ben%40example.com')) {
            res.setBody(loginError9955);
        }
        else if (req.getEndpoint().contains('cal%40example.com')) {
            res.setBody(loginError1350);
        }
        else if (req.getEndpoint().contains('dan%40example.com')) {
            res.setBody(loginError9999);
        }
        else if (req.getEndpoint().contains('eve%40example.com')) {
            res.setBody(loginError1234);
        }
        else if (req.getEndpoint().contains('fen%40example.com')) {
            res.setBody(loginErrorNoCode);
        }
        else if (req.getEndpoint().contains('gus%40example.com')) {
            res.setBody(loginNoToken);
        }
        else if (req.getEndpoint().contains('hal%40example.com')) {
            res.setBody(loginNoData);
        }
                
        return res;
    }
    
    public String loginSuccess = 
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
    
    public String loginError9955 = 
'{' +
  '"error": {' +
    '"code": 9955,' +
    '"message": "You are not logged in.",' +
    '"uuid": "0562f451cb109b34f44b5a404df22d4a"' +
  '}' +
'}';

    public String loginError1350 = 
'{' +
  '"error": {' +
    '"code": "1350",' +
    '"message": "You have not verified your account.",' +
    '"uuid": "d4d808f5427504f0e41ff4bf8d1a8807"' +
  '}' +
'}';

    public String loginError9999 = 
'{' +
  '"error": {' +
    '"code": 9999,' +
    '"message": "You are using an outdated version of the Who@ mobile client, please download and install the latest version from the app store.",' +
    '"uuid": "d4d808f5427504f0e41ff4bf8d1a8807"' +
  '}' +
'}';

    public String loginError1234 = 
'{' +
  '"error": {' +
    '"code": 1234,' +
    '"message": "Unexpected error code.",' +
    '"uuid": "d4d808f5427504f0e41ff4bf8d1a8807"' +
  '}' +
'}';
    
    public String loginErrorNoCode = 
'{' +
  '"error": {' +
    '"message": "Missing error code.",' +
    '"uuid": "d4d808f5427504f0e41ff4bf8d1a8807"' +
  '}' +
'}';
    
    public String loginNoToken = 
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
'  "type": "Agent",' + 
'  "verified": true' + 
'}';
    
    public String loginNoData = 
'{' + 
'}';
    

}