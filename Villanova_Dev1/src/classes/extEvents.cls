public with sharing class extEvents {
    public List<Campaign> lstEvents {get;set;}
    public String strView {get;set;}
    
    public extEvents(ApexPages.StandardController controller) {
        strView = 'Future';
        ChangeView();
    }
    
    public PageReference NewEvent(){
        Id idRT = [Select Id from RecordType where SobjectType = 'Campaign' and DeveloperName = 'Event'][0].Id;
        PageReference pr = new PageReference('/701/e?RecordType=' +idRT +'&ent=Campaign');
        pr.setRedirect(true);
        
        return pr;
    }
    
    public PageReference ChangeView(){
        
        if (strView == 'Past'){
            lstEvents = [Select Id, Name, Date__c, Event_Venue__c, Event_Venue__r.Name, Type from Campaign 
                where Date__c <: System.today() and RecordType.DeveloperName = 'Event' order by Date__c DESC
            ];
        } 
		if (strView == 'Future'){
            lstEvents = [Select Id, Name, Date__c, Event_Venue__c, Event_Venue__r.Name, Type from Campaign 
                where (Date__c >=: System.today() or Date__c = null) and RecordType.DeveloperName = 'Event'
                order by Date__c
            ];
        }
        if (strView == 'All'){
            lstEvents = [Select Id, Name, Date__c, Event_Venue__c, Event_Venue__r.Name, Type from Campaign 
                where RecordType.DeveloperName = 'Event' order by Date__c DESC
            ];
        } 
        
        return null;
    }
    
    
    public List<SelectOption> getViews() {
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('Future','Future Events'));
        options.add(new SelectOption('Past','Past Events'));
        options.add(new SelectOption('All','All'));
        
        return options;
    }
      static testMethod void testPageMethods() {
        
        Campaign c = new Campaign(
            Name = 'Test Campaign',
            IsActive = true
        );
        insert c;
        c = [Select Id, Encrypted_Key__c from Campaign where Id =: c.Id];
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c);
        System.currentPagereference().getParameters().put('event',c.Encrypted_Key__c);
        extevents ext = new extevents(stdCon);
        ext.newevent();
        ext.getviews();
        ext.strview = 'Past';
        ext.changeview();
        ext.strview = 'All';
        ext.changeview();
        }
}