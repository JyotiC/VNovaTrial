public with sharing class extSelectProcess {
    public Campaign camp {get;set;}
    public Map<Id, Process_Template__c> mapProcs {get;set;}
    public String strDescrip {get;set;}
    public String strProc {get;set;} 
    
    public extSelectProcess(ApexPages.StandardController ctrl) {
        this.camp = (Campaign)ctrl.getRecord();
        if (camp.Id != null){
            camp = [Select Id, Name, Date__c from Campaign where Id =: camp.Id];
        }
        
        if (camp.Date__c == null){
            ApexPages.Message mssErr = new ApexPages.Message(ApexPages.severity.ERROR,'Please enter a Date for this Event before implementing a Process.');
            ApexPages.addMessage(mssErr);
        }
    }
    
    public List<SelectOption> getProcesses() {
        List<SelectOption> options = new List<SelectOption>(); 
         
        mapProcs = new Map<Id, Process_Template__c>([Select Id, Name, Description__c from Process_Template__c Order by Name]);
        
        options.add(new SelectOption('','--- None ---'));
        
        for (Process_Template__c pt : mapProcs.values()){
            options.add(new SelectOption(pt.Id,pt.Name));
        }
        
        return options; 
    }
    
    public PageReference SelectProc(){
        
        if (mapProcs.get(strProc) != null){
            strDescrip = mapProcs.get(strProc).Description__c;
        }
        
        return null;
    }
    
    public PageReference Implement(){
        ApexPages.Message mssErr;
        
        if (strProc != null &&camp.Date__c != null){
            List<Process_Step__c> lstSteps = [Select Id, Name, Description__c, Tolerance__c
                from Process_Step__c where Process_Template__c =: strProc
            ];
            
            List<Task> lstEvents = new List<Task>();
            
            for (Process_Step__c ps : lstSteps){
                Date dte = camp.Date__c.addDays(ps.Tolerance__c.intValue() * -1);
                
                lstEvents.add(
                    new Task(
                        Subject = ps.Name, 
                        Description = ps.Description__c,
                        ActivityDate = dte,
                        //DurationinMinutes = 30,
                        WhatId = camp.Id //,
                        //ActivityDateTime = Datetime.newInstance(dte.year(), dte.month(), dte.day()).addHours(9)
                ));
            }   
            
            if (lstEvents.size() > 0){
                try {
                    insert lstEvents;
                } catch (Exception e) {
                    mssErr = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
                }
            }
            if (mssErr == null){
                mssErr = new ApexPages.Message(ApexPages.severity.INFO,'Process implemented, ' +lstEvents.size() +' steps created.');
            }
        } else {
            if (strProc == null){
                mssErr = new ApexPages.Message(ApexPages.severity.ERROR,'Please select a Process.');
            } else {
                mssErr = new ApexPages.Message(ApexPages.severity.ERROR,'Please enter a Date for this Event before implementing a Process.');
            }
        }
        
        if (mssErr != null){
            System.debug('Error implementing: ' +mssErr.getDetail());
            
        } 
        ApexPages.addMessage(mssErr);
        return null;
    }
   static testMethod void testPageMethods() {
        
        Campaign c = new Campaign(
            Name = 'Test Campaign',
            IsActive = true, Date__c=system.today()
        );
        insert c;
        c = [Select Id, Encrypted_Key__c from Campaign where Id =: c.Id];
        
        Process_Template__c pt = new Process_Template__c(
        	Name = 'Test Template',
        	Description__c = 'Test Description'
        );
        insert pt;
        Process_Step__c ps = new Process_Step__c(
        	Name = 'Test', 
        	Description__c = 'Descrip', 
        	Tolerance__c = 10,
        	Process_Template__c = pt.Id
    	);
        insert ps;
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c);
        System.currentPagereference().getParameters().put('event',c.Encrypted_Key__c);
        extselectprocess ext = new extselectprocess(stdCon);
        
        ext.getprocesses();       
       ext.strproc = pt.id;
       ext.implement();
       ext.selectproc(); 
    }       
}