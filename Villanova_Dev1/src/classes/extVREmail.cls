public with sharing class extVREmail {
	public String strHead {get;set;}
    public String strFoot {get;set;}
    public Campaign camp {get;set;}
    public List<Campaign> lstCamps {get;set;}
    public List<EventThing> lstEvents {get;set;}
    public Boolean isMultiple {get;set;}
    public String strContent {get;set;}
    public String strText {get;set;}
    public String strTextHead {get;set;}
    public String strTextFoot {get;set;}
    public Integer intCount;
      
    public extVREmail(ApexPages.StandardController ctrl) {
        this.camp = (Campaign)ctrl.getRecord();
        if (camp.Id != null){
            isMultiple = false;
        } else {
            isMultiple = true;
            
        }
         
        
        strHead = '<style>p{margin-top:0px; margin-bottom:0px;}</style><body  onload="init()"  style=" background-color:#CCCCCC; bLabel:body; bEditID:b1st1;"><center ><table id="topTable" height="450" width="500" cellpadding="0" cellspacing="0" ><tr valign="top" ><td  style=" vertical-align:top; height:100; text-align:left; background-color:#FFFFFF; bLabel:header; bEditID:r1st1;"><img id="r1sp1" bLabel="headerImage" border="0" bEditID="r1sp1" src="https://na6.salesforce.com/servlet/servlet.ImageServer?id=01580000000zLMQ&oid=00D80000000bB04" ></img></td></tr><tr valign="top" ><td  style=" height:5; background-color:#412833; bLabel:accent1; bEditID:r2st1;"></td></tr><tr valign="top" ><td styleInsert="1" height="300"  style=" color:#000000; font-size:12pt; background-color:#CFC592; font-family:arial; bLabel:main; bEditID:r3st1;"><table height="400" width="550" cellpadding="5" border="0" cellspacing="5" ><tr height="400" valign="top" ><td style=" color:#000000; font-size:12pt; background-color:#CFC592; font-family:arial; bLabel:main; bEditID:r3st1;" tEditID="c1r1" aEditID="c1r1" locked="0" ><P><FONT style="COLOR: rgb(51,51,51)" size=3>';
        
        
        strFoot = '</td></tr></table></td></tr><tr valign="top" ><td  style=" height:5; background-color:#CFC592; bLabel:accent2; bEditID:r4st1;"></td></tr><tr valign="top" ><td  style=" vertical-align:middle; height:100; text-align:center; background-color:#CFC592; bLabel:footer; bEditID:r5st1;"></td></tr><tr valign="top" ><td  style=" height:5; background-color:#412833; bLabel:accent3; bEditID:r6st1;"></td></tr></table></center>';
        
        
        //strTextHead = '{FIRST_NAME}  {LAST_NAME},\n\n';
        strTextHead = '';
        
        //strTextFoot += 'For more details and to register visit www.villanova.edu/business.';
        
        InitList(); 
        
    }
    

    
    public PageReference InitList(){
        lstEvents = new List<EventThing>(); 
        if (camp.Id != null){
            lstCamps = [Select Id, Name, Date__c, Location__c,
                Encrypted_Key__c, Web_Description__c, Description, Speaker__c
                from Campaign 
                where (Date__c >=: System.today() 
                or Date__c = null or Id =: camp.Id) 
                and RecordType.DeveloperName = 'Event'
                order by Date__c
            ];
            
        } else {
            lstCamps = [Select Id, Name, Date__c, Location__c,
                Encrypted_Key__c, Web_Description__c, Description, Speaker__c
                from Campaign 
                where (Date__c >=: System.today()  or Date__c = null) 
                and RecordType.DeveloperName = 'Event'
                order by Date__c
            ];
        }
        
        
        for (Campaign e : lstCamps){
            if (e.Id == camp.Id &&camp.Id != null){
                lstEvents.add(new EventThing(true, e));
            } else {
                lstEvents.add(new EventThing(false, e));
            }
        }
        MakeHTML();
        
        return null;
    }
    
    public PageReference MakeHTML(){
        strContent = strHead;
        strText = strTextHead;
        Boolean isMiddle = false;
        String strMid = '';
        String strRight = '';
        System.debug('strContent = ' +strContent);
        intCount = 0;
        
        for (EventThing e : lstEvents){
            if (e.isChecked){
                intCount++;
            }
        }
        for (EventThing e : lstEvents){
            if (e.isChecked){
                //isMiddle = (isMiddle ? false : true);
                strText += SingleEventText(e.Event);
                //if (isMiddle){
                    strMid += SingleEvent(isMiddle, e.Event);
                /*   System.debug('strMid = ' +strMid);
                } else {
                    strRight += SingleEvent(isMiddle, e.Event);
                    System.debug('strRight = ' +strRight);
                }*/
            }   
        }
        System.debug('strContent = ' +strContent);
        if (intCount > 0){
            /*Middle column
            if (intCount == 1){
                strContent += '<td width="430" colspan="2" valign="top" style="padding-left: 10px;">';
            } else {
                strContent += '<td width="215" valign="top" style="padding-left: 10px;">';
            }*/
            strContent += strMid +'\n\n';
            //strContent += '</td>\n\n';
            /*
            if (intCount > 1){
                //Right column
                strContent += '<td width="215" valign="top" style="padding-left: 10px;">';
                strContent += strRight;
                strContent += '</td>\n\n';
            }*/
            strContent += strFoot;
            
        } else {
            strContent = null;
            strText = null;
        }
        System.debug('strContent = ' +strContent);
        return null;
    }//end MakeHTML
    
    public String SingleEvent(Boolean isMiddle, Campaign c){
        String strHTML = '';
        String strDate = '';
        //if (isMiddle){
        //    strHTML = '<h2>' +c.Name +'</h2>\n\n';
        //} else {
            strHTML = '<h3>' +c.Name +'</h3><br/><br/>\n\n';
        //}
        
		if (c.Date__c != null){
        	
            strHTML += '<h3>Date: </h3>' +c.Date__c.format();
            strHTML += '<br/><br/>\n';
        }
        
        if (c.Location__c != null){
        	
        	strHTML += '<h3>Location: </h3>' +c.Location__c +'<br/><br/>\n\n';
        	
        }
        if (c.Speaker__c != null){
            strHTML += '<h3>Speaker: </h3>' +c.Speaker__c +'<br/><br/>'; 
        }
        
        if (c.Web_Description__c != null &&intCount == 1){
        	strHTML += '<p style="margin: 10px 0; line-height: 16px">'; 
            strHTML += c.Web_Description__c; 
            strHTML += '</p>'; 
        }
        strHTML += '<p style="margin: 10px 0; line-height: 16px">'; 
         
        strHTML += '<a href="'; 
        strHTML += 'http://villanova.force.com/Events/EventRegistration?event=' +c.Encrypted_Key__c +'&person={Key}';
        strHTML += '" target="_blank">RSVP</a>'; 
        strHTML += '</p>\n\n'; 
        return strHTML;
    }//end SingleEvent
    
   
    
    public String SingleEventText(Campaign c){
        String str = '\n\n';
        str += c.Name;
        String strDate = '';
        
        if (c.Date__c != null){
        	
            str += c.Date__c.format();
            str += '\n';
        }
        /*
        if (c.Start_Date_Time__c != null){
        	str += '\n';
            if (c.End_Date_Time__c != null){
            	strDate = c.Start_Date_Time__c.format() +' -' +c.End_Date_Time__c.format().substring(c.End_Date_Time__c.format().indexOf(' '), c.End_Date_Time__c.format().length()); 
            } else {
            	strDate = Date.newInstance(c.Start_Date_Time__c.year(),c.Start_Date_Time__c.month(), c.Start_Date_Time__c.day()).format();
            }
            str += strDate;
        } */
       
        if (c.Location__c != null){
        	str += '\n';
        	
        	str += c.Location__c;
        	
        }
        
        if (c.Speaker__c != null){
            str += '\n\n' +c.Speaker__c; 
        }
        
        if (c.Web_Description__c != null &&intCount == 1){
            String strDesc = c.Web_Description__c.replaceAll('<p>', '\n').replaceAll('</p>', '\n\n').replaceAll('<br/>', '\n').replaceAll('<span style="color: #57068c;font-weight:bold;margin: 10px 0; line-height: 16px">','').replaceAll('</span>','');
            str += '\n\n' +strDesc;
        }
        str += '\n\nTo register, go to: ';
        str += 'http://villanova.force.com/Events/EventRegistration?event=' +c.Encrypted_Key__c +'&person={Key}';
         
        return str;
    }//end SingleEvent
    
    public class EventThing{
        public Boolean isChecked {get;set;}
        public Campaign Event {get;set;}
        
        public EventThing(Boolean boo, Campaign camp){
            Event = camp;
            isChecked = boo;
        }
    }
static testMethod void testPageMethods() {
        
        Campaign c = new Campaign(
            Name = 'Test Campaign',
            IsActive = true, Date__c=system.today()
        );
        insert c;
        c = [Select Id, Encrypted_Key__c from Campaign where Id =: c.Id];
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c);
        System.currentPagereference().getParameters().put('event',c.Encrypted_Key__c);
        extvrEmail ext = new extvrEmail(stdCon);
        ext.makehtml();
        ext.initlist();
        
        ext.isMultiple = true;
        ext.InitList();
        
        Integer i = 0;
        for (EventThing e : ext.lstEvents){
        	if (i < 3){
        		e.isChecked = true;
        		i++;
        	}
        }
        ext.MakeHTML();
    }
}