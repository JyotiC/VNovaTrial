public class clsAttendance {
	
	@future
	public static void WaitListOpenings(Integer intSize, Set<Id> setAttGroupOpen){
		List<CampaignMember> lstWaiters = [Select Id, Attendee_Group__c, Email__c, First_Name__c, Campaign.Name from CampaignMember where Attendee_Group__c IN: setAttGroupOpen and Status = 'Wait List'
			Order by Attendee_Group__c, Entered_Wait_List__c DESC	
		];
		
		for (CampaignMember cm : lstWaiters){ 
			if (intSize > 0){
				//If there's room, increment the current registered tracker
				cm.Status = 'Registered';
				intSize = intSize - 1;
				if (cm.Email__c != null){
					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					String[] userEmails = new String[1];
					userEmails[0] = cm.Email__c;
					
					mail.setToAddresses(userEmails);
					
					mail.setReplyTo('donotreply@nyu.edu');
					// Specify the name used as the display name.
					mail.setSenderDisplayName('NYU Abu Dhabi Institute');
					// Specify the subject line for your email address.
					mail.setSubject(cm.Campaign.Name +' - Notification of Registration');
					
					
					String strEmail = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
					strEmail += '<html>';
					strEmail += '<head>';
					strEmail += '<title>' +cm.Campaign.Name +' - Notification of Registration</title>';
	
					strEmail += '</head>';
					strEmail += '<body><center>';
					strEmail += '<div style="background: #ffffff; text-align: center; font-size: 11px; line-height: 16px; font-family: verdana, arial, tahoma, sans-serif;">';
					strEmail += '<table width="600" cellspacing="0" cellpadding="0" border="0" style="text-align: left; margin: 0 auto; font-size: 11px">';
					strEmail += '<tbody>';
					strEmail += '<tr>';
					strEmail += '<td valign="top"><a href="http://nyuad.nyu.edu/news.events/events.ad.html" style="border: medium none ;"><img width="600" height="99" border="0" src="http://www.nyu.edu/info/abudhabi.emails/images/hdr.april.gif" alt="NYU Abu Dhabi Institute - Notice of Registration" /></a></td>';
					strEmail += '</tr>';
					strEmail += '<tr>';
					strEmail += '<td">&nbsp;</td>';
	                strEmail += '</tr>';
	                strEmail += '<tr>';
	
	                strEmail += '<td width="600" valign="top">';
	                strEmail += '<p style="margin: 0 0 10px 0; line-height: 16px">Dear ' +cm.First_Name__c +',</p>';
	                strEmail += '<p style="margin: 0 0 10px 0; line-height: 16px">This email is to inform you that a space has opened for the ' +cm.Campaign.Name +' event for which you were on the Wait List and you are now registered. Please let us know if you are not able to attend.</p>';
	                strEmail += '<p style="margin: 0 0 10px 0; line-height: 16px">Regards,<br/>NYU Abu Dhabi Institute</p>';
	                strEmail += '</td>';
					strEmail += '</tr>';
	            	strEmail += '</tbody>';
	        		strEmail += '</table>';
	        		strEmail += '</div>';
	        		strEmail += '</center>';
	    			strEmail += '</body>';
					strEmail += '</html>';
					
					mail.setHtmlBody(strEmail);
					// Send the email
					Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				}
			}
		}
		update lstWaiters;
	}
	
	static testMethod void testMethods() {
        Id idRT = [Select Id from RecordType where SObjectType = 'Campaign' and DeveloperName = 'Event'][0].Id;
        Campaign c = new Campaign(
            Name = 'Test Campaign',
            IsActive = true,
            RecordTypeId = idRT, 
            Date__c = System.today()
        );
        
        insert c;
        
        Campaign grp = [Select Id from Campaign where Event__c =: c.Id and Short_Name__c = 'All'];
        grp.Registration_Limit__c = 1;
        grp.Wait_List_Limit__c = 1;
        update grp;
        
        c = [Select Id, Encrypted_Key__c from Campaign where Id =: c.Id];
        Id idIndiv = [Select Id from Account limit 1][0].id;
    	
        Contact con1 = new Contact(
            FirstName = 'Test',
            LastName = 'Person',
            AccountId = idIndiv,
            Email = 'email@email.com'
        );
        insert con1;
        
        Contact con3 = new Contact(
            FirstName = 'Test',
            LastName = 'Person3',
            AccountId = idIndiv,
            Email = 'email@email.com'
        );
        insert con3;
        
        Contact con2 = new Contact(
            FirstName = 'Test',
            LastName = 'Person2',
            AccountId = idIndiv,
            Email = 'email@email.com'
        );
        insert con2;
        
        System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1About to insert CampMember with Camp: ' +c.Id);
        CampaignMember cm = new CampaignMember(
        	CampaignId = c.Id,
        	Status = 'Registered',
        	ContactId = con1.Id
    	);
        insert cm;
        cm = [Select Id, Status from CampaignMember where Id =: cm.Id];
        grp = [Select Id, Current_Wait_List__c, Current_Registration__c from Campaign where Id =: grp.Id];
        System.debug('cm status 1: ' +cm.Status +' wait list :' +grp.Current_Wait_List__c +' reg :' +grp.Current_Registration__c);
        CampaignMember cm_first = cm.clone();
        
        cm = new CampaignMember(
        	CampaignId = c.Id,
        	Status = 'Registered',
        	ContactId = con2.Id
    	);
        insert cm;
        grp = [Select Id, Current_Wait_List__c, Current_Registration__c from Campaign where Id =: grp.Id];
        System.debug('cm status 2: ' +cm.Status +' wait list :' +grp.Current_Wait_List__c +' reg :' +grp.Current_Registration__c);
        
        cm = new CampaignMember(
        	CampaignId = c.Id,
        	Status = 'Registered',
        	ContactId = con3.Id
    	);
    	Boolean isError = false;
    	try {
        	insert cm;
    	} catch (Exception e) {
    		isError = true;
    	}
    	System.assert(IsError);
    	
    	Test.startTest();
    	cm_first.Status = 'New (not invited yet)';
    	update cm_first;
    	Test.stopTest();
	}
}