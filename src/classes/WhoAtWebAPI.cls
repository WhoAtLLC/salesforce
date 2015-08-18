/*
*  API Handler Class
*  =================
*
* Endpoints
* ---------
*
*  'https://whoat.net/api/v1';          //production
*  'http://alpha.whoat.net/api/v1';     //alpha
*
*/
public with sharing class WhoAtWebAPI{
    ////////////////
    // Attributes //
    ////////////////
    public String token;
    public APIToken__c storedToken;
    public String apiURL;
    public APIUrl__c storedAPIUrl;
    public String username = '';
    public WhoAtContacts contacts = new WhoAtContacts();
    public WhoAtContacts storedContacts = new WhoAtContacts();

    private static final String TAG = '>> WhoAtWebAPI :: ';

    /////////////////
    // Sub classes //
    /////////////////
    public class IntroRequestMessage {
        public boolean bounty = true;
        public String guid = '';
        public String message = '';
        public boolean name_game = true;
        public List<String> networks = new List<String>();
    }

    public class APIException extends Exception {}


    /////////////////
    // constructor //
    /////////////////
    public WhoAtWebAPI()
    {
        storedAPIUrl = APIUrl__c.getInstance();
        apiURL = storedAPIUrl.url__c;
        storedToken = APIToken__c.getInstance();
        token = storedToken.token__c;
        username = storedToken.username__c;
    }


    ///////////
    // Login //
    ///////////
    public void login(String username, String password) {
        //Preprare Request
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        String encodedUsername = EncodingUtil.urlEncode(username,'UTF-8');
        String encodedPassword = EncodingUtil.urlEncode(password,'UTF-8');

        String[] credentials = new String[] {
            apiURL,
            encodedUsername ,
            encodedPassword
        };

        String loginCommand = String.format('{0}/member/authenticate?username={1}&password={2}&src=salesforce', credentials);

        req.setEndpoint(loginCommand);

        System.debug(System.LoggingLevel.INFO,TAG + 'LOGIN :: Server Request URL: ' + req.getEndpoint());

        req.setMethod('GET');

        // Req...
        HttpResponse res = h.send(req);
        System.debug(System.LoggingLevel.DEBUG, TAG + 'LOGIN :: Server Response: ' + res.getBody());

        // Response Handling
        Map<String, Object> loginResponse;
        try {
            loginResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        } catch (JSONException e) {
            throw new APIException ('Hmmm, not able to log in right now.  Contact Support at support@whoat.net');
        }

        // Errors Handling
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

        // Result Handling
        // The token must be upsert, on WebToken__c (Hierarchical CS), and in current User.WhoAtToken field.
        // This is handling by the "upsertToken" method
        token = (String)loginResponse.get('token');

        if (String.isBlank(token)) {
            throw new APIException('Hmmm, tried to log in and did not get authorization.  Contact Support at support@whoat.net');
        }

        storedToken.token__c = token;
        this.username = username;
        storedToken.username__c = username;
        //upsert storedToken; - need to update this token, but have to do it later after any api calls - call separate upsert function

        return;
    }


    ////////////
    // Search //
    ////////////
    public void search(String query) {
        // Prepare Request
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        // String encodedQuery = EncodingUtil.urlEncode(query,'UTF-8');
        String encodedQuery = query;
        String[] params = new String[] {
            apiURL,
            encodedQuery,
            token
        };

        String searchCommand = String.format('{0}/contacts/search/{1}?token={2}&src=salesforce', params);

        req.setEndpoint(searchCommand);
        System.debug(System.LoggingLevel.INFO, 'SEARCH :: Server Request URL: ' + req.getEndpoint());

        req.setMethod('GET');

        // Req
        HttpResponse res = h.send(req);
        System.debug(System.LoggingLevel.DEBUG, 'SEARCH :: Server Response: ' + res.getBody());

        // Respons handling
        // To check if return value is a map or list (search results will be list if successful, map if error code returned)
        // * Init JSON Parser
        JSONParser parser;
        try {
            parser = JSON.createParser(res.getBody());
        } catch (JSONException e) {
            throw new APIException ('Hmmm, not able to log in right now.  Contact Support at support@whoat.net');
        }

        parser.nextToken();
        if (parser.getCurrentToken() == null) {
            throw new APIException ('Hmmm, not able to log in right now.  Contact Support at support@whoat.net');
        }

        // * Handling Error Body, if necessary
        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {    //it's a map
            Integer code = 0;
            //  - Unknown Error
            try {
                Map<String, Object> unexpectedResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                System.debug(unexpectedResponse);
                Map<String, Object> error = (Map<String, Object>)unexpectedResponse.get('error');
                code = (Integer)error.get('code');
            } catch (Exception e) {
                throw new APIException ('Hmmm, not able to access the Who@ services right now.  Please contact Support at support@whoat.net', e);
            }
            //  - Not Logged
            if (code == 9955) {
                throw new APIException ('Please log in.');
            }
            //  - User not Verified at Who@ system.
            else if (code == 1350) {
                throw new APIException ('Please verify your email.  Request another verification email at http://whoat.net');
            //  - Other
            } else {
                throw new APIException ('Hmmm, got error code ' + code + '.  Please contact Support at support@whoat.net');
            }
        }

        // * Handling Response
        if (parser.getCurrentToken() == JSONToken.START_ARRAY) {    //it's a list
            List<Object> searchResponse;
            // Not Necessary.
            // try {
            //     //check that it's reasonable json by doing deserializeUntyped (I think this checks if it's well-formed - it may not)
            //     searchResponse = (List<Object>)JSON.deserializeUntyped(res.getBody());
            //     System.debug(searchResponse);
            // } catch (JSONException e) {
            //     throw new APIException ('Hmmm, not able to log in right now.  Contact Support at support@whoat.net');
            // }

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


    ////////////////////
    // Intro Request //
    ////////////////////
    public void requestIntro(IntroRequestMessage ir) {
        // Prepare Request
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        String[] params = new String[] {
            apiURL,
            token
        };

        String requestCommand = String.format('{0}/message/request_intro?token={1}&src=salesforce', params);
        req.setEndpoint(requestCommand);
        System.debug(System.LoggingLevel.INFO, TAG + 'REQUEST INTRO :: Request endpoint > ' + req.getEndpoint());

        req.setHeader('content-type', 'application/json');
        req.setBody(JSON.serialize(ir));

        System.debug(System.LoggingLevel.DEBUG, TAG + 'REQUEST INTRO :: Server Request Body: ' + req.getBody());
        req.setMethod('POST');

        // Req...
        HttpResponse res = h.send(req);
        System.debug(System.LoggingLevel.DEBUG, TAG + 'REQUEST INTRO :: Server Response: ' + res.getBody());

        // Handling Response
        if (res.getBody().startsWith('{')) {
            String message = '';
            try {
                Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

                System.debug(System.LoggingLevel.DEBUG, TAG + 'REQUEST INTRO :: parsed body > ' + response);

                message = (String)response.get('message');
            } catch (Exception e) {
                throw new APIException ('Hmmm, not able to access the Who@ services right now.  Please contact Support at support@whoat.net', e);
            }

            if (message == 'success') {
                //good result - don't do anything
                System.debug(System.LoggingLevel.INFO, TAG + 'REQUEST INTRO :: Request successful');
            } else {
                System.debug(System.LoggingLevel.ERROR, TAG + 'REQUEST INTRO :: Request error > '+message);
                throw new APIException ('Unexpected message from Who@ services: ' + message + '|  Please contact Support at support@whoat.net');
            }
        }

        return;
    }


    /////////////
    // Logout //
    /////////////
    public void logout() {
        contacts = new WhoAtContacts();

        // Prepare Request
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        String[] params = new String[] {apiURL, token};

        String searchCommand = String.format('{0}/logout?token={1}&src=salesforce', params);
        req.setEndpoint(searchCommand);

        System.debug(System.LoggingLevel.INFO, TAG + 'LOGOUT :: Server Request URL: ' + req.getEndpoint());
        req.setMethod('GET');

        // Req..
        HttpResponse res = h.send(req);
        System.debug(System.LoggingLevel.DEBUG, TAG + 'LOGOUT :: Server Response: ' + res.getBody());

        username = '';
        storedToken.username__c = '';

        return;
    }


    ////////////////
    // DML TOKEN //
    ////////////////
    public void upsertToken() {
        upsert storedToken;
        SObject tokenField = [select Id, WhoAtToken__c from User where id = :UserInfo.getUserId()];
        tokenField.put('WhoAtToken__c', token);
        upsert tokenField;
    }


    //////////////
    // Helpers //
    //////////////
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
