@isTest
public class WhoAtWebAccountExtensionTests{
    
    static void setupTests() {
        //NOTE - when using this setup function, you must surround your test with
        //       Test.startTest() and Test.stopTest() to avoid getting an error for having
        //       pending DML operations prior to a http callout.
        APIUrl__c storedAPIUrl = new APIUrl__c();
        storedAPIUrl.url__c = 'https://whoat.net/api/v1';
        insert storedAPIUrl;
    }
        
    public static testMethod void testPage() {
        setupTests();
        
        Account a = new Account(name='Tester');
        insert a;
        
        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPIAccountExtension());
        
        ApexPages.StandardController sc = new ApexPages.standardController(a);
        WhoAtWebAccountExtension e = new WhoAtWebAccountExtension(sc);

        Test.startTest();
        e.initSession();
        e.closeLogin();
        e.setDisplayFlags('LoginScreen');
        Test.stopTest();
                
        System.assert(true);
    }

    public static testMethod void testPageLogin() {
        setupTests();
        
        Account a = new Account(name='Tester');
        insert a;
        
        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPIAccountExtension());
        ApexPages.StandardController sc = new ApexPages.standardController(a);
        WhoAtWebAccountExtension e = new WhoAtWebAccountExtension(sc);

        Test.startTest();
        e.initSession();
        e.Username = 'bob@example.com';
        e.Password = 'test@1';
        e.doLogin();
        e.closeLogin();
        Test.stopTest();
                
        System.assert(true);
    }
    
    public static testMethod void testPageLogout() {
        setupTests();
        
        Account a = new Account(name='Tester');
        insert a;
        
        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPIAccountExtension());
        ApexPages.StandardController sc = new ApexPages.standardController(a);
        WhoAtWebAccountExtension e = new WhoAtWebAccountExtension(sc);

        Test.startTest();
        e.initSession();
        e.doLogout();
        Test.stopTest();
                
        System.assert(true);
    }

    public static testMethod void testRequestIntro() {
        setupTests();
        
        Account a = new Account(name='Tester');
        insert a;
        
        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPIAccountExtension());
        ApexPages.StandardController sc = new ApexPages.standardController(a);
        WhoAtWebAccountExtension e = new WhoAtWebAccountExtension(sc);

        Test.startTest();
        e.initSession();
        e.currentContactID = 'M4DE_MDVA_2_V5QH';
        e.showIntro();
        e.toggleIntroCompanyIcon();
        e.toggleIntroGroupIcon();
        e.toggleIntroFriendsIcon();
        e.requestIntro();
        e.closeIntro();
        Test.stopTest();
                
        System.assert(true);
    }

    private static testMethod void test_privateNormalizationSearchToken(){
        setupTests();

        Account a = new Account(Name='Tester');
        insert a;

        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPIAccountExtension());
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(a);
        WhoAtWebAccountExtension ctrl = new WhoAtWebAccountExtension(stdCtrl);

        Test.startTest();
        ctrl.initSession();

        System.assertEquals('', ctrl.normalizeToken(null));
        System.assertEquals('-Test', ctrl.normalizeToken('-Test'));
        System.assertEquals('+test', ctrl.normalizeToken('+test'));
        System.assertEquals('+/test', ctrl.normalizeToken('/test'));
        System.assertEquals('+test', ctrl.normalizeToken('   test\n'));

        Test.stopTest();
    }

    private static testMethod void test_doSearch(){
        setupTests();

        Account a = new Account(Name='Tester');
        insert a;

        Test.setMock(HttpCalloutMock.class, new MockWhoAtWebAPIAccountExtension());
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(a);
        WhoAtWebAccountExtension ctrl = new WhoAtWebAccountExtension(stdCtrl);

        Test.startTest();
        ctrl.initSession();
        ctrl.currentContactID = 'M4DE_MDVA_2_V5QH';
        ctrl.showIntro();
       
        ctrl.search_token = '+test';
        ctrl.doSearch();
        Test.stopTest();

        System.assert(true);
    }
}