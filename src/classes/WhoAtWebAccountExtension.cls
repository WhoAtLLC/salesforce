/*
    Who@ Controller extension
    -------------------------

    Revision : 2
    Modified By : MBAZ > Add a sub-filter system (an input and an action for limit the research for this account)
                            > Add private method "normalizeToken"
                            > Add public VF Action "doSearch"
                            > Add Visualforce attribute "search_token"
*/

public with sharing class WhoAtWebAccountExtension{
    ///////////////
    // Atributes //
    ///////////////

    //VF Accessible
    public String myPhoneImageName {get; set;}
    public String companyImageName {get; set;}
    public String groupImageName {get; set;}
    public String friendsImageName {get; set;}
    public String labelUsername {get; set;}

    public String username {get; set;}
    public String password {get; set;}

    public boolean displayUsername {get; set;}
    public boolean displayLogin {get; set;}
    public boolean displayNoResultsMsg {get; set;}
    public boolean displayIntro {get; set;}
    public boolean displayMyContact {get; set;}
    public boolean requestIntroDisabled {get; set;}

    public WhoAtContacts.Contact currentContact {get; set;}
    public String currentContactID {get; set;}
    public String currentContactName {get; set;}
    public String currentIntroMessage {get; set;}
    public TargetNetworks currentTargetNetworks = new TargetNetworks();

    public String introCompanyImageName {get; set;}
    public String introGroupImageName {get; set;}
    public String introFriendsImageName {get; set;}

    public String search_token {get; set;}
    private static final String NO_ACCESS_ERROR_MESSAGE = 'Hmm, it seems Who@ Intro is not configured for your profile. Please ask your administrator or contact Support at support@whoat.net';

    // Internal
    private final Account acct;
    private WhoAtWebAPI api;
    private Map<String, Map<String, boolean>> rulesDisplay = new Map<String, Map<String, boolean>> {
        'NotLoggedIn' => new Map<String, boolean> {
            'displayUsername' => false,
            'displayLogin' => false,
            'displayNoResultsMsg' => false,
            'displayIntro' => false,
            'displayMyContact' => false,
            'requestIntroDisabled' => false},
        'LoginScreen' => new Map<String, boolean> {
            'displayUsername' => false,
            'displayLogin' => true,
            'displayNoResultsMsg' => false,
            'displayIntro' => false,
            'displayMyContact' => false,
            'requestIntroDisabled' => false},
        'GoodSearchResults' => new Map<String, boolean> {
            'displayUsername' => true,
            'displayLogin' => false,
            'displayNoResultsMsg' => false,
            'displayIntro' => false,
            'displayMyContact' => false,
            'requestIntroDisabled' => false},
        'NoSearchResults' => new Map<String, boolean> {
            'displayUsername' => true,
            'displayLogin' => false,
            'displayNoResultsMsg' => true,
            'displayIntro' => false,
            'displayMyContact' => false,
            'requestIntroDisabled' => false},
        'ShowIntro' => new Map<String, boolean> {
            'displayUsername' => true,
            'displayLogin' => false,
            'displayNoResultsMsg' => false,
            'displayIntro' => true,
            'displayMyContact' => false,
            'requestIntroDisabled' => false
            }
    };

    /////////////////
    // Constructor //
    /////////////////
    public WhoAtWebAccountExtension(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
        this.api = new WhoAtWebAPI();
        Username = api.username;
        labelUsername = '';  //blank until we're definitely logged in
        setDisplayFlags('NotLoggedIn');
    }

    // Action method, called at initialization of page.
    // Post init.
    public void initSession() {
        try {
            search_token = '';
            api.search(this.acct.name);
            turnOnOffRelationshipSourceIcons();
            labelUsername = api.username;
            setDisplayFlags('GoodSearchResults');
            if (api.contacts.contactList.size() == 0) {
                setDisplayFlags('NoSearchResults');
            }
        } catch (WhoAtWebAPI.APIException le) {
            setDisplayFlags('LoginScreen');
        } catch (NoAccessException naE) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, NO_ACCESS_ERROR_MESSAGE));
        }
    }

    //////////////////////////////////////////
    // Action Methods (called from VF page) //
    //////////////////////////////////////////
    // Initialise flags & token, to modify the screen according the status and the data of controller
    public void setDisplayFlags(String state) {
        displayUsername = rulesDisplay.get(state).get('displayUsername');
        displayLogin = rulesDisplay.get(state).get('displayLogin');
        displayNoResultsMsg = rulesDisplay.get(state).get('displayNoResultsMsg');
        displayIntro = rulesDisplay.get(state).get('displayIntro');
        displayMyContact = rulesDisplay.get(state).get('displayMyContact');

        if (state == 'GoodSearchResults'
                && api.contacts.contactList.size() == 0
            ) {
            displayNoResultsMsg = true;
        }

        if (state == 'ShowIntro'
                && !currentTargetNetworks.company
                && !currentTargetNetworks.groups
                && !currentTargetNetworks.friends
            ) {
            displayMyContact = true;
        }
    }

    public void closeLogin() {
        setDisplayFlags('NotLoggedIn');
    }

    public void doLogout() {
        api.logout();
        labelUsername = '';
        setDisplayFlags('LoginScreen');
    }

    public void doLogin() {
        try {
            api.login(Username, Password);
            api.search(this.acct.name);

            turnOnOffRelationshipSourceIcons();

            labelUsername = api.username;
            setDisplayFlags('GoodSearchResults');

            if (api.contacts.contactList.size() == 0) {
                setDisplayFlags('NoSearchResults');
            }

            api.upsertToken();
        } catch (WhoAtWebAPI.APIException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        } catch (NoAccessException naE) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, NO_ACCESS_ERROR_MESSAGE));
        }
    }

    public void doSearch(){
        String search_expr = this.acct.name + '%20' + normalizeToken(search_token);

        try {
            //Search with filter
            api.search(search_expr);

            System.debug(System.LoggingLevel.WARN,'WHO@ :: Search Expression' + search_expr);
            //Active / unactive collumns to match data shape.
            turnOnOffRelationshipSourceIcons();

            // Header label handling
            setDisplayFlags('GoodSearchResults');
            if (getContactListSize() == 0) {
               setDisplayFlags('NoSearchResults');
            }
        } catch (WhoAtWebAPI.APIException le){
             // User Not logged
             setDisplayFlags('LoginScreen');
        } catch (NoAccessException naE) {
            // Conf error (Auth Profile / User.WhoAt__WhoAtToken__c is not visible)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, NO_ACCESS_ERROR_MESSAGE));
        }
    }

    public void requestIntro() {
        WhoAtWebAPI.IntroRequestMessage ir = new WhoAtWebAPI.IntroRequestMessage();
        ir.guid = currentContactID;
        ir.message = currentIntroMessage;
        ir.networks = getIntroTargetNetworks(currentContact, currentTargetNetworks);
        if (ir.networks.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select a network to send to (Company, Groups, or Friends).'));
            return;
        }
        api.requestIntro(ir);
        api.restoreContacts();
        setDisplayFlags('GoodSearchResults');
    }

    ////////////////////
    // Intro Handling //
    ////////////////////
    public void showIntro() {
        currentContact = api.selectOneContact(currentContactID);
        currentTargetNetworks = setIntroTargetNetworks(currentContact);
        turnOnOffTargetNetworks(currentTargetNetworks);
        currentIntroMessage = 'Hi, I\'m looking for an introduction to ' +
            currentContact.label + '.  Can you help me?';
        setDisplayFlags('ShowIntro');
    }

    public void closeIntro() {
        api.restoreContacts();
        setDisplayFlags('GoodSearchResults');
    }


    /////////////
    // Helpers //
    /////////////
    @TestVisible
    private String normalizeToken(String rawToken) {
        //shield Filter token var.
        if (String.isEmpty(rawToken)){
            return '';
        }
        String normalizedToken;
        // If token doesn't start with a "+" or a "-", it's invalid.
        // Normalize it with a "+", and trim it.
        if (!rawToken.trim().startswith('-') && !rawToken.trim().startswith('+')) {
            normalizedToken = '+' + rawToken.trim();
        } else {
            normalizedToken = rawToken.trim();
        }

        //UrlEncode it
        return normalizedToken.replace(' ', '%20');
    }

    public List<WhoAtContacts.Contact> getContactList() {
        return api.contacts.contactList;
    }

    public Integer getContactListSize() {
        return api.contacts.contactList.size();
    }

    //////////////////////
    // Screen modifiers //
    //////////////////////
    public void toggleIntroCompanyIcon() {
        if (currentContact.getInCompany()) {
            currentTargetNetworks.company = !currentTargetNetworks.company;
            turnOnOffTargetNetworks(currentTargetNetworks);
        }
    }

    public void toggleIntroGroupIcon() {
        if (currentContact.getInGroups()) {
            currentTargetNetworks.groups = !currentTargetNetworks.groups;
            turnOnOffTargetNetworks(currentTargetNetworks);
        }
    }

    public void toggleIntroFriendsIcon() {
        if (currentContact.getInFriends()) {
            currentTargetNetworks.friends = !currentTargetNetworks.friends;
            turnOnOffTargetNetworks(currentTargetNetworks);
        }
    }

    public void turnOnOffRelationshipSourceIcons() {
        if (api.contacts.hasPhone) myPhoneImageName = 'MyPhoneActive'; else myPhoneImageName = 'MyPhoneSource';
        if (api.contacts.hasCompany) companyImageName = 'CompanyActive'; else companyImageName = 'CompanySource';
        if (api.contacts.hasGroups) groupImageName = 'GroupActive'; else groupImageName = 'GroupSource';
        if (api.contacts.hasFriends) friendsImageName = 'FriendsActive'; else friendsImageName = 'FriendsSource';
    }

    ///////////////
    // Sub Class //
    ///////////////
    public class TargetNetworks {
        public boolean company;
        public boolean groups;
        public boolean friends;
    }

    /////////////////////////
    // Sub Class accessors //
    /////////////////////////
    public TargetNetworks setIntroTargetNetworks(WhoAtContacts.Contact c) {
        TargetNetworks targetNetworks = new TargetNetworks();
        targetNetworks.company = c.getInCompany();
        targetNetworks.groups = c.getInGroups();
        targetNetworks.friends = c.getInFriends();
        return targetNetworks;
    }

    public List<String> getIntroTargetNetworks(WhoAtContacts.Contact c, TargetNetworks tn) {
        List<String> result = new List<String>();
        if (tn.company) result.addAll(c.getCompanyNetworkList());
        if (tn.groups) result.addAll(c.getGroupNetworkList());
        if (tn.friends) result.addAll(c.getFriendNetworkList());
        return result;
    }

    public void turnOnOffTargetNetworks(TargetNetworks n) {
        if (n.company) introCompanyImageName = 'CompanyActive'; else introCompanyImageName = 'CompanySource';
        if (n.groups) introGroupImageName = 'GroupActive'; else introGroupImageName = 'GroupSource';
        if (n.friends) introFriendsImageName = 'FriendsActive'; else introFriendsImageName = 'FriendsSource';

        //disable send intro request button if no sources selected
        requestIntroDisabled = !n.company && !n.groups && !n.friends;
    }
}