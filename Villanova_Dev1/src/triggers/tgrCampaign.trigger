trigger tgrCampaign on Campaign (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

	if (Trigger.isBefore){
        //INSERT UPDATE UNDELETE
        if (Trigger.isUpdate || Trigger.isInsert || Trigger.isUnDelete){
            for (Campaign c : Trigger.new) {
                if (c.Short_Name__c != null &&c.Event__c != null){
                    String strEvent = [Select Name from Campaign where Id =: c.Event__c][0].Name;
                    String str = strEvent +' - ' +c.Short_Name__c;
                    if (str.length() > 80){
                    	//c.addError('My err- ' +(strEvent.substring(0, (strEvent.length() - (str.length()-79)))));
                    	str = strEvent.substring(0, (strEvent.length() - (str.length()-79))) +' - ' +c.Short_Name__c;
                    }
                    c.Name = str;
                } 
                if (c.Encrypted_Key__c == null){
                    DateTime now = System.now();
                    String formattednow = now.formatGmt('yyyy-MM-dd')+'T'+ now.formatGmt('HH:mm:ss')+'.'+now.formatGMT('SSS')+'Z';
                    String canonical = c.id + c.Name + c.OwnerId + formattednow;
                    Blob bsig = Crypto.generateDigest('MD5', Blob.valueOf(canonical));
                    String token = EncodingUtil.base64Encode(bsig);
                
                    if(token.length() > 255) {
                        token = token.substring(0,254);
                    }
                    try {
                        c.Encrypted_Key__c = Encodingutil.urlEncode(token, 'UTF-8').replaceAll('%','_');
                    }catch (Exception e){
                        system.debug('EncrytpedKey__c assignment failed:' +e);
                    }
                }//end if encrypted key is null
                
                if (c.Description != null &&(c.Web_Description__c == null ||
                	(Trigger.isUpdate &&c.Web_Description__c == Trigger.oldMap.get(c.Id).Description))
                ){
                	c.Web_Description__c = c.Description;
                }
                
                if (Trigger.isUpdate &&!extAttendeeGroups.InitialGroupSave){
                	Boolean isError = false;
                	List<Group_Criterion__c> lstCrit = [Select Id, Name, Operator__c, Order__c, Value__c, Field_Type__c
                            from Group_Criterion__c where Attendee_Group__c =: c.id
                        ];
                        
                    //Make sure the operators make sense
                    for (Group_Criterion__c gc : lstCrit){
                    	if (gc.Field_Type__c == 'BOOLEAN' &&
                    		!(gc.Operator__c == 'Equals' || gc.Operator__c == 'Does Not Equals')
                    	){
                    		c.addError('Checkbox fields must use the \'Equals\' or \'Does Not Equal\' Operators');
                    		isError = true;
                    	}
                    	if ((gc.Field_Type__c == 'DECIMAL' || gc.Field_Type__c == 'CURRENCY' || 
                    		gc.Field_Type__c == 'DOUBLE' || 
                    		gc.Field_Type__c == 'DATE' || gc.Field_Type__c == 'DATETIME') &&
                    		!(gc.Operator__c == 'Equals' || gc.Operator__c == 'Does Not Equals' || gc.Operator__c == 'Greater Than or Equal To'
                    		|| gc.Operator__c == 'Greater Than' || gc.Operator__c == 'Less Than or Equal To' || gc.Operator__c == 'Less Than' 
                    		)
                    	){
                    		c.addError('Number and Checkbox fields must use the \'Equals\', \'Does Not Equal\', \'Greater Than or Equal To\',  \'Greater Than\', \'Less Than or Equal To\' or \'Less Than\' Operators.');
                    		isError = true;
                    	}
                    	if (gc.Field_Type__c != 'MULTIPICKLIST' &&
                    		(gc.Operator__c == 'Includes' || gc.Operator__c == 'Excludes')
                    	){
                    		c.addError('The \'Includes\' or \'Excludes\' Operators are only valid for Multi-select Picklist fields.');
                    		isError = true;
                    	}
                    	if (gc.Field_Type__c == 'MULTIPICKLIST' &&
                    		!(gc.Operator__c == 'Includes' || gc.Operator__c == 'Excludes'
                    		||gc.Operator__c == 'Equals' || gc.Operator__c == 'Does Not Equals')
                    	){
                    		c.addError('Multi-select Picklist fields must use the \'Equals\', \'Does Not Equal\', \'Includes\' or \'Excludes\' Operators.');
                    		isError = true;
                    	}
                    }
                    //Logic for Attendee Group campaigns 
                    if (!isError &&(c.Boolean__c != null || lstCrit.size() > 0)){
                        
                        
                        if (lstCrit.size() > 0 &&c.Boolean__c == null){
                        	c.addError('Please specify Logic for the Criteria you\'ve entered.');
                        	isError = true;
                        }
                        if (c.Boolean__c != null &&lstCrit.size() == 0){
                            c.addError('There must be Criteria associated with the Logic you\'ve entered.');
                            isError = true;
                        }
                        if (!isError){
                        	clsFunctions.CreateWhere(c, lstCrit);
                        }//end if there are no criteria records
                    }//end if boolean not null
                }//end if is update
            }//end campaign loop
        }//END INSERT / UPDATE
        
        //IF UPDATE, UNDELETE
        if (Trigger.isUnDelete || Trigger.isUpdate){
            for (Campaign c : Trigger.new){
                
            }//end new loop
        }//END UPDATE, UNDELETE
        
        //DELETE
        if (Trigger.isDelete){
            Id idEvent;
            Id idGroup;
            
            
            
            List<RecordType> lstRT = [Select Id, DeveloperName from RecordType 
                where SObjectType = 'Campaign' and (DeveloperName = 'Event' or 
                DeveloperName = 'Event_Attendee_Group')
            ];
            
            for (RecordType rt : lstRT){
                if (rt.DeveloperName == 'Event'){
                    idEvent = rt.Id;
                }
                if (rt.DeveloperName == 'Event_Attendee_Group'){
                    idGroup = rt.Id;
                }
            }
            
            for (Campaign c : Trigger.old){ 
                if (c.RecordTypeId == idGroup &&!clsConstants.isEventDelete){
                    List<Campaign> lstGroups = [Select Id, Event__r.Name from Campaign 
                        where Event__c =: c.Event__c and RecordTypeId =: idGroup]; 
                        
                    if (lstGroups.size() == 1 &&lstGroups[0].Event__r.Name != null){
                        c.addError('This Attendee Group is the last group in the ' +lstGroups[0].Event__r.Name 
                            +' event and cannot be deleted'
                        );
                    }
                    
                    //Don't allow groups with people in them to be deleted
                    if (c.NumberOfContacts > 0 || c.NumberofLeads >0){
                    	c.AddError('This group has members in it and cannot be deleted.  Re-assign these people to other groups on the Event page and then try deleting again.');
                    }
                }
                if (c.RecordTypeId == idEvent){
                	clsConstants.isEventDelete = true;
                }
            }
        }//END DELETE
    }//END BEFORE 
	
	 //AFTER
    if (Trigger.isAfter){
    	//INSERT UPDATE
        if (Trigger.isInsert || Trigger.isUpdate){
            Id idEvent;
            Id idGroup;
            Id idEvEvent;
            Id idStandard;
            List<Campaign> lstGroups = new List<Campaign>();
            List<Campaign> lstCamps = new List<Campaign>();
            List<CampaignMemberStatus> lstStats = new List<CampaignMemberStatus>();
            Set<Id> setCampIds = new Set<Id>();
            
            List<RecordType> lstRT = [Select Id, DeveloperName, SobjectType from RecordType 
                where (SObjectType = 'Campaign' and (DeveloperName = 'Event' or 
                DeveloperName = 'Standard_campaign' or DeveloperName = 'Event_Attendee_Group'))
                or (SObjectType = 'Event' and DeveloperName = 'Event')
            ];
            
            for (RecordType rt : lstRT){
                if (rt.DeveloperName == 'Event' &&rt.SObjectType == 'Campaign'){
                    idEvent = rt.Id;
                }
                if (rt.DeveloperName == 'Standard_campaign' &&rt.SObjectType == 'Campaign'){
                    idStandard = rt.Id;
                }
                if (rt.DeveloperName == 'Event_Attendee_Group'){
                    idGroup = rt.Id;
                }
                if (rt.DeveloperName == 'Event' &&rt.SObjectType == 'Event'){
                    idEvEvent = rt.Id;
                }
            }
            
            for (Campaign c : Trigger.new) {
                //for new Event campaigns, add in the All Attendee Group
                if (Trigger.isInsert &&c.RecordTypeId == idEvent){
                    lstGroups.add(new Campaign(
                        Short_Name__c = 'All',
                        Event__c = c.Id,
                        Registration_Limit__c = 200,
                        Wait_List_Limit__c = 20,
                        Order__c = 1,
                        RecordTypeId = idGroup,
                        isActive = true
                    )); 
                    
                    
                    setCampIds.add(c.Id);
                    
                    
                }
                
                
                if (Trigger.isInsert &&(c.RecordTypeId == idEvent || c.RecordTypeId == idGroup || (c.RecordTypeId == idStandard &&c.Short_Name__c != null))){     
                    lstStats.add(new CampaignMemberStatus(
                    	CampaignId = c.Id,
                    	Label = 'New (not invited yet)',
                    	IsDefault = true,
                    	SortOrder = 4
                    ));
                    
                    
                    
                    lstStats.add(new CampaignMemberStatus(
                    	CampaignId = c.Id,
                    	Label = 'Registered',
                    	HasResponded = true,
                    	SortOrder = 5
                    ));
                    
                    lstStats.add(new CampaignMemberStatus(
                    	CampaignId = c.Id,
                    	Label = 'Wait List',
                    	HasResponded = true,
                    	SortOrder = 6
                    ));
                    
                    lstStats.add(new CampaignMemberStatus(
                    	CampaignId = c.Id,
                    	Label = 'Attended',
                    	HasResponded = true,
                    	SortOrder = 7
                    ));
                    
                    
                
	                if (lstGroups.size() > 0){
	                    insert lstGroups;
	                }
	                
	                if (lstCamps.size() > 0){
	                    insert lstCamps;
	                }
	                
	                if (lstStats.size() > 0){
	                    insert lstStats;
	                }
	                lstStats = [Select Id from CampaignMemberStatus where CampaignId IN: setCampIds 
	                	and (Label = 'Sent' or Label = 'Responded')];
	                for (CampaignMemberStatus cms : lstStats){
	                	cms.IsDefault = false;
	                }
	                update lstStats;
	                delete lstStats;
                }//end if Insert and campaign is event or group
            }//end Campaign loop
        }//END INSERT
        
        if (Trigger.isDelete){
            Id idEvent;
            Id idGroup;
            List<Campaign> lstGroups = new List<Campaign>();
            List<RecordType> lstRT = [Select Id, DeveloperName from RecordType 
                where SObjectType = 'Campaign' and (DeveloperName = 'Event' or 
                DeveloperName = 'Event_Attendee_Group')
            ];
            
            for (RecordType rt : lstRT){
                if (rt.DeveloperName == 'Event'){
                    idEvent = rt.Id;
                }
                if (rt.DeveloperName == 'Event_Attendee_Group'){
                    idGroup = rt.Id;
                }
            }
            
            Set<Id> setCamps = new Set<Id>();
            
            for (Campaign c : Trigger.old) {
            	if (c.RecordTypeId == idGroup){
            		setCamps.add(c.Event__c);
            	}
            }
            
            //Fix the Order of other Attendee Groups
            if (setCamps.size() > 0){
            	List<Campaign> lstGrps = [Select Id, Order__c from Campaign where Event__c IN: lstGroups Order by Event__c, Order__c];
            	Integer i;
            	String strLast;
            	for (Campaign c : lstGroups){
            		if (strLast != c.Event__c){
            			i = 1;
            			strLast = c.Event__c;
            		}
            		c.Order__c = i;
            	}
            	
            	update lstGroups;
            }
        }//END DELETE
    }//END AFTER
}