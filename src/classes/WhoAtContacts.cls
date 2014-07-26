public with sharing class WhoAtContacts {

    public List<Contact> contactList = new List<Contact>();
    public boolean hasPhone;
    public boolean hasCompany;
    public boolean hasGroups;
    public boolean hasFriends;    
    
    public class Contact {
        public Details details;
        public String id;
        public String guid;
        public String label;
        public List<Network> networks;
        public String organization;
        public String title;
        
        //var holding network (relationship source) counts
        public NetworkCounts networkCounts;
        
        public String getid() { return id; }
        public String getlabel() { return label; }
        public String getorganization() { return organization; }
        public String gettitle() { return title; }
        
        public Integer phoneSourceCount;
        public Integer companySourceCount;
        public Integer groupsSourceCount;
        public Integer friendsSourceCount;

		//move this crap out of the model and into view (page extension class) at next opportunity
        public String getPhoneSourceCount() { 
            if (networkCounts.phone > 1)
	            return String.valueOf(networkCounts.phone); 
            else
                return '';
        }
        
        public String getCompanySourceCount() { 
            if (networkCounts.company > 1)
	            return String.valueOf(networkCounts.company); 
            else
                return '';
        }
        
        public String getGroupsSourceCount() { 
            if (networkCounts.groups > 1)
	            return String.valueOf(networkCounts.groups); 
            else
                return '';
        }
        
        public String getFriendsSourceCount() { 
            if (networkCounts.friends > 1)
	            return String.valueOf(networkCounts.friends); 
            else
                return '';
        }
        
        public Boolean getinPhone() {
            return (networkCounts.phone > 0);
        }
        
        public Boolean getinCompany() {
            return (networkCounts.company > 0);
        }
        
        public Boolean getinGroups() {
            return (networkCounts.groups > 0);
        }
        
        public Boolean getinFriends() {
            return (networkCounts.friends > 0);
        }
        
        public List<String> getCompanyNetworkList() {
            List<String> result = new List<String>();
            for (Network n: networks) {
                if (n.type == 'Organization') {
                    result.add(n.id);
                }
            }
            return result;
        }
        
        public List<String> getGroupNetworkList() {
            List<String> result = new List<String>();
            for (Network n: networks) {
                if (n.type == 'Group') {
                    result.add(n.id);
                }
            }
            return result;
        }
        
        public List<String> getFriendNetworkList() {
            List<String> result = new List<String>();
            for (Network n: networks) {
                if (n.type == 'Friends') {
                    result.add(n.id);
                }
            }
            return result;
        }
        
        public List<String> getcontactDetailList() {
            List<String> result = new List<String>();
            
            if (details != null) {
                for (Email e: details.emails) {
                    String line = '';
                    if (!String.isBlank(e.tag)) {
                        line = e.tag + ':  ';
                    } else {
                        line = 'email:  ';
                    }
                    line = line + e.label;
                    result.add(line);
                }
                
                for (Phone p: details.phones) {
                    String line = '';
                    if (!String.isBlank(p.tag)) {
                        line = p.tag + ':  ';
                    } else {
                        line = 'phone:  ';
                    }
                    line = line + p.label;
                    result.add(line);
                }
            }
            
            return result;
        }
        
    }
    
    public class Network {
        public Integer count;
        public String id;
        public String label;
        public String type;
    }
    
    //The following class is for calculating network counts and is not represented in json.
    public class NetworkCounts {
        public Integer phone = 0;
        public Integer company = 0;
        public Integer groups = 0;
        public Integer friends = 0;
    }
    
    public class Details {
        public List<Email> emails;
        public List<Phone> phones;
    }
    
    public class Email {
        public String tag;
        public String label;
    }
    
    public class Phone {
        public String tag;
        public String label;
    }

    public WhoAtContacts() {
        hasPhone = false; hasCompany = false; hasGroups = false; hasFriends = false;
    }
    
    public WhoAtContacts(String jsonInput) {
        contactList = (List<Contact>)JSON.deserialize(jsonInput, List<Contact>.class);
        
        hasPhone = false; hasCompany = false; hasGroups = false; hasFriends = false;
        for (Contact c: contactList) {
            NetworkCounts counts = new NetworkCounts();
            for (Network n: c.networks) {
                if (n.type == 'Personal') {
                    hasPhone = true;
                    counts.phone += n.count;
                }
                if (n.type == 'Organization') {
                    hasCompany = true;
                    counts.company += n.count;
                }
                if (n.type == 'Group') {
                    hasGroups = true;
                    counts.groups += n.count;
                }
                if (n.type == 'Friends') {
                    hasFriends = true;
                    counts.friends += n.count;
                }
            }
            c.networkCounts = counts;
        }
    }
}