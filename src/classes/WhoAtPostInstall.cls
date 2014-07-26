public class WhoAtPostInstall implements InstallHandler {
    
    public void onInstall(InstallContext context) {
        APIUrl__c storedAPIUrl = APIUrl__c.getInstance(UserInfo.getOrganizationId());
        storedAPIUrl.url__c = 'https://whoat.net/api/v1';
        insert storedAPIUrl;
    }

}