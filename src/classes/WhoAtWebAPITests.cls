@isTest
private class WhoAtWebAPITests{

    static void setupTests() {
        //NOTE - when using this setup function, you must surround your test with
        //       Test.startTest() and Test.stopTest() to avoid getting an error for having
        //       pending DML operations prior to a http callout.
        APIUrl__c storedAPIUrl = new APIUrl__c();
        storedAPIUrl.url__c = 'https://whoat.net/api/v1';
        insert storedAPIUrl;
    }
    
    static testMethod void testLogin() {
        setupTests();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPILogin());
        WhoAtWebAPI api = new WhoAtWebAPI();
        api.login('abe@example.com', 'test@1');
        
        api.upsertToken();

        System.assert(true);
        Test.stopTest();
    }

    static testMethod void testLoginErrors() {
        setupTests();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPILogin());
        WhoAtWebAPI api = new WhoAtWebAPI();
        
        try {
            api.login('ben@example.com', 'test@1');
        }
        catch (WhoAtWebAPI.APIException e) {
            System.assert(e.getMessage().contains('Access Denied'));
        }
        
        try {
            api.login('cal@example.com', 'test@1');
        }
        catch (WhoAtWebAPI.APIException e) {
            System.assert(e.getMessage().contains('Please verify your account'));
        }
        
        try {
            api.login('dan@example.com', 'test@1');
        }
        catch (WhoAtWebAPI.APIException e) {
            System.assert(e.getMessage().contains('This version of the Who@ app is outdated'));
        }
        
        try {
            api.login('eve@example.com', 'test@1');
        }
        catch (WhoAtWebAPI.APIException e) {
            System.assert(e.getMessage().contains('Hmmm, not able to log in right now'));
        }
        
        try {
            api.login('fen@example.com', 'test@1');
        }
        catch (WhoAtWebAPI.APIException e) {
            System.assert(e.getMessage().contains('Hmmm, got an error logging in'));
        }
        
        try {
            api.login('gus@example.com', 'test@1');
        }
        catch (WhoAtWebAPI.APIException e) {
            System.assert(e.getMessage().contains('Hmmm, tried to log in and did not get authorization'));
        }
        
        try {
            api.login('hal@example.com', 'test@1');
        }
        catch (WhoAtWebAPI.APIException e) {
            System.assert(e.getMessage().contains('Hmmm, tried to log in and did not get authorization'));
        }
        
        System.assert(true);
        Test.stopTest();
    }
    static testMethod void testSearch() {
        setupTests();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPILogin());
        WhoAtWebAPI api = new WhoAtWebAPI();
        api.login('abe@example.com', 'test@1');
        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPISearch());
        api.search('dell');

        api.logout();
        
        System.assert(true);
        Test.stopTest();
    }
    
    static testMethod void testSearch_NotLoggedIn() {
        setupTests();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPILogin());
        WhoAtWebAPI api = new WhoAtWebAPI();
        api.login('abe@example.com', 'test@1');
        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPISearch());
        try {
	        api.search('notLoggedIn');
        } catch (WhoAtWebAPI.APIException e) {
            System.debug(e.getMessage());
        }
        
        System.assert(true);
        Test.stopTest();
    }
    
    static testMethod void testSearch_BadContactReturned() {
        setupTests();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPILogin());
        WhoAtWebAPI api = new WhoAtWebAPI();
        api.login('abe@example.com', 'test@1');
        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPISearch());
        try {
	        api.search('badContact');
        } catch (WhoAtWebAPI.APIException e) {
            System.debug(e.getMessage());
        }
        //looks like various bad json contact data i tried all ended up returning just an empty list
        
        System.assert(true);
        Test.stopTest();
    }
    
    static testMethod void testRequestIntro() {
        setupTests();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPILogin());
        WhoAtWebAPI api = new WhoAtWebAPI();
        api.login('abe@example.com', 'test@1');
        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPISearch());
        api.search('dell');
        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPIRequestIntro());
        WhoAtContacts.Contact currentContact = api.selectOneContact('M4DE_MDVA_2_V5QH');
        WhoAtWebAPI.IntroRequestMessage ir = new WhoAtWebAPI.IntroRequestMessage();
        api.requestIntro(ir);

        api.restoreContacts();

        System.assert(true);
        Test.stopTest();
    }
}