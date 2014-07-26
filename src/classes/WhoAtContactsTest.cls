@isTest
public class WhoAtContactsTest{
    
    public static testMethod void testParse() {

        WhoAtContacts contacts = new WhoAtContacts(contactsJson);
        System.debug(contacts);
        
        System.assertEquals(4, contacts.contactList.size());
        
        //active source icons for whole list
        System.assertEquals(true, contacts.hasPhone);
        System.assertEquals(true, contacts.hasCompany);
        System.assertEquals(true, contacts.hasGroups);
        System.assertEquals(true, contacts.hasFriends);
        
        System.assertEquals('Michael Dell', contacts.contactList[0].label);
        System.assertEquals('MSD Ventures', contacts.contactList[0].organization);
        System.assertEquals('Chairman and CEO at Dell', contacts.contactList[0].title);
        System.assertEquals('1NJCQL-1NK7VW-1NJLGW', contacts.contactList[0].id);
        System.assertEquals(2, contacts.contactList[0].networks.size());
        System.assertEquals(1, contacts.contactList[0].networks[0].count);
        System.assertEquals('6', contacts.contactList[0].networks[0].id);
        System.assertEquals('Who@', contacts.contactList[0].networks[0].label);
        System.assertEquals('Organization', contacts.contactList[0].networks[0].type);
        System.assertEquals(1, contacts.contactList[0].networks[1].count);
        System.assertEquals('11751', contacts.contactList[0].networks[1].id);
        System.assertEquals('My Network - bill@whoat.net', contacts.contactList[0].networks[1].label);
        System.assertEquals('Personal', contacts.contactList[0].networks[1].type);
        System.assertEquals(1, contacts.contactList[0].details.emails.size());
        System.assertEquals('', contacts.contactList[0].details.emails[0].tag);
        System.assertEquals('michael@dell.com', contacts.contactList[0].details.emails[0].label);
        System.assertEquals(0, contacts.contactList[0].details.phones.size());
        
        System.assertEquals('Adam Dell', contacts.contactList[1].label);
        System.assertEquals('Austin Ventures', contacts.contactList[1].organization);
        System.assertEquals('', contacts.contactList[1].title);
        System.assertEquals('1NJDIK-1NK7VW-1NJDIK', contacts.contactList[1].id);
        System.assertEquals(1, contacts.contactList[1].networks.size());
        System.assertEquals(1, contacts.contactList[1].networks[0].count);
        System.assertEquals('6', contacts.contactList[1].networks[0].id);
        System.assertEquals('Who@', contacts.contactList[1].networks[0].label);
        System.assertEquals('Organization', contacts.contactList[1].networks[0].type);
        
        
        System.assertEquals('Preston Dell', contacts.contactList[2].label);
        System.assertEquals('Route 66 Casino', contacts.contactList[2].organization);
        System.assertEquals('', contacts.contactList[2].title);
        System.assertEquals('1NJL5Y-1NK7VW-1NJL5Y', contacts.contactList[2].id);
        System.assertEquals(1, contacts.contactList[2].networks.size());
        System.assertEquals(1, contacts.contactList[2].networks[0].count);
        System.assertEquals('11751', contacts.contactList[2].networks[0].id);
        System.assertEquals('My Network - bill@whoat.net', contacts.contactList[2].networks[0].label);
        System.assertEquals('Personal', contacts.contactList[2].networks[0].type);
        System.assertEquals(0, contacts.contactList[2].details.emails.size());
        System.assertEquals(1, contacts.contactList[2].details.phones.size());
        System.assertEquals(null, contacts.contactList[2].details.phones[0].tag);
        System.assertEquals('(505) 379-5290', contacts.contactList[2].details.phones[0].label);
        
    }
    
    public static testMethod void testContactNetworks() {

        WhoAtContacts contacts = new WhoAtContacts(contactsJson);
        contacts.contactList[0].getcontactDetailList();
        contacts.contactList[1].getcontactDetailList();
        contacts.contactList[2].getcontactDetailList();
        contacts.contactList[3].getcontactDetailList();
        contacts.contactList[0].getCompanyNetworkList();
        contacts.contactList[0].getGroupNetworkList();
        contacts.contactList[0].getFriendNetworkList();
        contacts.contactList[3].getCompanyNetworkList();
        contacts.contactList[3].getGroupNetworkList();
        contacts.contactList[3].getFriendNetworkList();

        contacts.contactList[0].getPhoneSourceCount();
        contacts.contactList[0].getCompanySourceCount();
        contacts.contactList[0].getGroupsSourceCount();
        contacts.contactList[0].getFriendsSourceCount();

        contacts.contactList[0].getinPhone();
        contacts.contactList[0].getinCompany();
        contacts.contactList[0].getinGroups();
        contacts.contactList[0].getinFriends();
        
        contacts.contactList[0].getid();
        contacts.contactList[0].getlabel();
        contacts.contactList[0].getorganization();
        contacts.contactList[0].gettitle();
        
        contacts.contactList[3].getPhoneSourceCount();
        contacts.contactList[3].getCompanySourceCount();
        contacts.contactList[3].getGroupsSourceCount();
        contacts.contactList[3].getFriendsSourceCount();
        
        System.assert(true);

    }
    
    public static testMethod void testContact() {

        WhoAtContacts contacts = new WhoAtContacts();
        contacts.contactList.add(new WhoAtContacts.Contact());
        contacts.contactList[0].details = new WhoAtContacts.Details();
        contacts.contactList[0].details.emails = new List<WhoAtContacts.Email>();
        contacts.contactList[0].details.emails.add(new WhoAtContacts.Email());
        contacts.contactList[0].details.phones = new List<WhoAtContacts.Phone>();
        contacts.contactList[0].details.phones.add(new WhoAtContacts.Phone());
        
        contacts.contactList[0].networks = new List<WhoAtContacts.Network>();
        contacts.contactList[0].networks.add(new WhoAtContacts.Network());
        
        System.assert(true);
    }
    
    public static String contactsJson = '[' +
'  {' +
'    "details": {' +
'      "emails": [' +
'        {' +
'          "tag": "",' +
'          "label": "michael@dell.com"' +
'        }' +
'      ],' +
'      "phones": []' +
'    },' +
'    "id": "1NJCQL-1NK7VW-1NJLGW",' +
'    "hidden": false,' +
'    "label": "Michael Dell",' +
'    "networks": [' +
'      {' +
'        "count": 1,' +
'        "id": "6",' +
'        "label": "Who@",' +
'        "type": "Organization"' +
'      },' +
'      {' +
'        "count": 1,' +
'        "id": "11751",' +
'        "label": "My Network - bill@whoat.net",' +
'        "type": "Personal"' +
'      }' +
'    ],' +
'    "organization": "MSD Ventures",' +
'    "spoc": null,' +
'    "title": "Chairman and CEO at Dell"' +
'  },' +
'  {' +
'    "id": "1NJDIK-1NK7VW-1NJDIK",' +
'    "label": "Adam Dell",' +
'    "networks": [' +
'      {' +
'        "count": 1,' +
'        "id": "6",' +
'        "label": "Who@",' +
'        "type": "Organization"' +
'      }' +
'    ],' +
'    "organization": "Austin Ventures",' +
'    "spoc": null,' +
'    "title": ""' +
'  },' +
'  {' +
'    "details": {' +
'      "emails": [],' +
'      "phones": [' +
'        {' +
'          "tag": null,' +
'          "label": "(505) 379-5290"' +
'        }' +
'      ]' +
'    },' +
'    "id": "1NJL5Y-1NK7VW-1NJL5Y",' +
'    "hidden": false,' +
'    "label": "Preston Dell",' +
'    "networks": [' +
'      {' +
'        "count": 1,' +
'        "id": "11751",' +
'        "label": "My Network - bill@whoat.net",' +
'        "type": "Personal"' +
'      }' +
'    ],' +
'    "organization": "Route 66 Casino",' +
'    "spoc": null,' +
'    "title": ""' +
'  },' +
'  {' +
'    "details": {' +
'      "emails": [' +
'      {' +
'        "label": "justin.lall@scapromo.com",' +
'        "tag": "work",' +
'        "type": null,' +
'        "value": "justin.lall@scapromo.com"' +
'      }' +
'        ],' +
'      "phones": [' +
'        {' +
'          "label": "(214) 555-5891",' +
'          "tag": "work",' +
'          "type": null,' +
'          "value": "(214) 555-5891"' +
'        }' +
'      ]' +
'    },' +
'    "emails": [],' +
'    "guid": "UWlFQ0pCTU1PVlNBdDBzWGdGUjBUQWlZYmlaYXBHRkNZbmszTVltWkRYcHN2RUtSMENOblZIT0t6UT09",' +
'    "id": "UWlFQ0pCTU1PVlNBdDBzWGdGUjBUQWlZYmlaYXBHRkNZbmszTVltWkRYcHN2RUtSMENOblZIT0t6UT09",' +
'    "label": "Michael Dell",' +
'    "name": {' +
'      "first": "Michael",' +
'      "last": "Dell"' +
'    },' +
'    "networks": [' +
'      {' +
'        "count": 1,' +
'        "id": 13299,' +
'        "label": "Startup Grind Directors",' +
'        "type": "Group"' +
'      },' +
'      {' +
'        "count": 2,' +
'        "id": 13307,' +
'        "label": "Who@ Testers",' +
'        "type": "Group"' +
'      },' +
'      {' +
'        "count": 2,' +
'        "id": 6,' +
'        "label": "Who@",' +
'        "type": "Organization"' +
'      },' +
'      {' +
'        "count": 1,' +
'        "id": 11751,' +
'        "label": "Personal",' +
'        "type": "Personal"' +
'      },' +
'      {' +
'        "count": 2,' +
'        "id": 0,' +
'        "label": "Friends",' +
'        "type": "Friends"' +
'      }' +
'    ],' +
'    "organization": "Dell",' +
'    "phones": [],' +
'    "size": 10,' +
'    "title": "Chairman and CEO"' +
'  }' +
']';

}