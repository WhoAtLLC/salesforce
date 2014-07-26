public class WhoAtWebAPI{

    public String token;
    public APIToken__c storedToken;
//    public String apiURL = 'https://whoat.net/api/v1';          //production
//    public String apiURL = 'http://alpha.whoat.net/api/v1';     //alpha
    public String apiURL;
    public APIUrl__c storedAPIUrl;
    public String username = '';
	public WhoAtContacts contacts = new WhoAtContacts();
    public WhoAtContacts storedContacts = new WhoAtContacts();

    //internally declared classes
    public class IntroRequestMessage {
        public boolean bounty = true;
        public String guid = '';
        public String message = '';
        public boolean name_game = true;
        public List<String> networks = new List<String>();
    }
    public class APIException extends Exception {}    
    
    //constructor
    public WhoAtWebAPI()
    {
        storedAPIUrl = APIUrl__c.getInstance();
        apiURL = storedAPIUrl.url__c;
        storedToken = APIToken__c.getInstance();
        token = storedToken.token__c;
        username = storedToken.username__c;
    }
    
    public void login(String username, String password) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
      
        String encodedUsername = EncodingUtil.urlEncode(username,'UTF-8');
        String encodedPassword = EncodingUtil.urlEncode(password,'UTF-8');
        String[] credentials = new String[] {apiURL, encodedUsername , encodedPassword};
        String loginCommand = String.format('{0}/member/authenticate?username={1}&password={2}&src=salesforce', credentials);
        req.setEndpoint(loginCommand);
        System.debug('Server Request URL: ' + req.getEndpoint());
        req.setMethod('GET');
        
        HttpResponse res = h.send(req);
        System.debug('Server Response: ' + res.getBody());

        Map<String, Object> loginResponse;
        try {
	        loginResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    	    System.debug(loginResponse);
        } catch (JSONException e) {
            throw new APIException ('Hmmm, not able to log in right now.  Contact Support at support@whoat.net');
        }
        
        Map<String, Object> errorResponse = (Map<String, Object>)loginResponse.get('error');
        if (errorResponse != null) {
            if (errorResponse.get('code') != null) {
                Integer intCode = 0;
                if (errorResponse.get('code') instanceof Integer) {
                    intCode = (Integer)errorResponse.get('code');
                }
                else if (errorResponse.get('code') instanceof String) {
                    intCode = Integer.valueOf((String)errorResponse.get('code'));
                }
                else {
                    throw new APIException ('Hmmm, not able to log in right now.  Contact Support at support@whoat.net');
                }
                
                if (intCode == 1900) throw new APIException('The username ' + username + ' is not recognized.');
                if (intCode == 1100) throw new APIException('The password did not match what was expected.');
                if (intCode == 1350) throw new APIException('Please verify your account through email.');
                if (intCode == 9955) throw new APIException('Access Denied.  Please login or get support at support@whoat.net.');
                if (intCode == 9966) throw new APIException('Please verify your account through email.');
                if (intCode == 9999) throw new APIException('This version of the Who@ app is outdated and must be upgraded.');
                throw new APIException('Hmmm, not able to log in right now.  Contact Support at support@whoat.net');
            }
            else {
                throw new APIException ('Hmmm, got an error logging in.  Contact Support at support@whoat.net');
            }
        }
                
        token = (String)loginResponse.get('token');
        System.debug(token);
        if (String.isBlank(token)) {
            throw new APIException('Hmmm, tried to log in and did not get authorization.  Contact Support at support@whoat.net');
        }
        storedToken.token__c = token;
        this.username = username;
        storedToken.username__c = username;
        //upsert storedToken; - need to update this token, but have to do it later after any api calls - call separate upsert function

        return;
    }
    
    public void search(String query) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
      
        String encodedQuery = EncodingUtil.urlEncode(query,'UTF-8');
        String[] params = new String[] {apiURL, encodedQuery, token};
        String searchCommand = String.format('{0}/contacts/search/{1}?token={2}&src=salesforce', params);
        req.setEndpoint(searchCommand);
        System.debug('Server Request URL: ' + req.getEndpoint());
        req.setMethod('GET');
        
        HttpResponse res = h.send(req);
        System.debug('Server Response: ' + res.getBody());

        // To check if return value is a map or list (search results will be list if successful, map if error code returned)
        JSONParser parser;
        try {
            parser = JSON.createParser(res.getBody());
        } catch (JSONException e) {
            throw new APIException ('Hmmm, not able to log in right now.  Contact Support at support@whoat.net');
        }
        parser.nextToken();
        System.debug(parser.getCurrentToken());
        if (parser.getCurrentToken() == null) {
            throw new APIException ('Hmmm, not able to log in right now.  Contact Support at support@whoat.net');
        }
        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {    //it's a map
            Integer code = 0;
            try {
	        	Map<String, Object> unexpectedResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    	    	System.debug(unexpectedResponse);
                Map<String, Object> error = (Map<String, Object>)unexpectedResponse.get('error');
                code = (Integer)error.get('code');
            } catch (Exception e) {
                throw new APIException ('Hmmm, not able to access the Who@ services right now.  Please contact Support at support@whoat.net', e);
            }
                            
            if (code == 9955) {
	            throw new APIException ('Please log in.');
            }
            else if (code == 1350) {
	            throw new APIException ('Please verify your email.  Request another verification email at http://whoat.net');
            } else {
                throw new APIException ('Hmmm, got error code ' + code + '.  Please contact Support at support@whoat.net');
            }
        }
        
        if (parser.getCurrentToken() == JSONToken.START_ARRAY) {    //it's a list
            List<Object> searchResponse;
            try {
                //check that it's reasonable json by doing deserializeUntyped (I think this checks if it's well-formed - it may not)
                searchResponse = (List<Object>)JSON.deserializeUntyped(res.getBody());
    	        System.debug(searchResponse);
            } catch (JSONException e) {
                throw new APIException ('Hmmm, not able to log in right now.  Contact Support at support@whoat.net');
            }
            try {
                contacts = new WhoAtContacts(res.getBody());
                storedContacts = contacts;
            } catch (Exception e) {
                throw new APIException ('Hmmm, not able to log in right now.  Contact Support at support@whoat.net');
            }
        }
        else {  //should not reach here
            throw new APIException ('Hmmm, not able to log in right now.  Contact Support at support@whoat.net');
        }
       
        return;
    }
    
    public void requestIntro(IntroRequestMessage ir) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
      
        String[] params = new String[] {apiURL, token};
        String requestCommand = String.format('{0}/message/request_intro?token={1}&src=salesforce', params);
        req.setEndpoint(requestCommand);
        System.debug('Server Request URL: ' + req.getEndpoint());
        req.setHeader('content-type', 'application/json');
        req.setBody(JSON.serialize(ir));
        System.debug('Server Request Body: ' + req.getBody());
        req.setMethod('POST');
        
        HttpResponse res = h.send(req);
        System.debug('Server Response: ' + res.getBody());
        
        if (res.getBody().startsWith('{')) {
            String message = '';
            try {
	        	Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    	    	System.debug(response);
                message = (String)response.get('message');
            } catch (Exception e) {
                throw new APIException ('Hmmm, not able to access the Who@ services right now.  Please contact Support at support@whoat.net', e);
            }
                            
            if (message == 'success') {
                //good result - don't do anything
            } else {
                throw new APIException ('Unexpected message from Who@ services: ' + message + '|  Please contact Support at support@whoat.net');
            }
                
        }
        
        return;
    }
    
    public void logout() {
        contacts = new WhoAtContacts();

        Http h = new Http();
        HttpRequest req = new HttpRequest();
      
        String[] params = new String[] {apiURL, token};
        String searchCommand = String.format('{0}/logout?token={1}&src=salesforce', params);
        req.setEndpoint(searchCommand);
        System.debug('Server Request URL: ' + req.getEndpoint());
        req.setMethod('GET');
        
        HttpResponse res = h.send(req);
        System.debug('Server Response: ' + res.getBody());
        
        username = '';
        storedToken.username__c = '';
        
        return;
    }        
    
    public void upsertToken() {
        upsert storedToken;
        SObject tokenField = [select WhoAtToken__c from User where id = :UserInfo.getUserId()];
		tokenField.put('WhoAtToken__c', token);
		upsert tokenField;
    }
    
    public WhoAtContacts.Contact selectOneContact (String id) {
        for (WhoAtContacts.Contact c: contacts.contactList) {
            if (c.id == id) {
                contacts = new WhoAtContacts();
                contacts.contactList.add(c);
                return c;
            }
        }
        return null;
    }
    
    public void restoreContacts() {
        contacts = storedContacts;
    }

}