trigger trgCampaignMember on CampaignMember (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
  //BEFORE 
  if (Trigger.isBefore){
    //INSERT UPDATE
    if (Trigger.isInsert || Trigger.isUpdate){
      Set<Id> setGroups = new Set<Id>();
      Set<Id> setCamps = new Set<Id>();
      Map<Id, Id> mapLeadNoGroup = new Map<Id, Id>();
      Map<Id, Id> mapContactNoGroup = new Map<Id, Id>();
      Map<Id, Id> mapLeadGroup = new Map<Id, Id>();
      Map<Id, Id> mapContactGroup = new Map<Id, Id>();
      Set<Id> setRemGroup = new Set<Id>();
      Set<Id> setStatUpdate = new Set<Id>();
      
      Set<Id> setLeads = new Set<Id>();
      Set<Id> setCons = new Set<Id>();
      
      //Get Campaign details to see if these are members of an Event
      for (CampaignMember cm : Trigger.new){
        if (Trigger.isInsert){
          if (cm.ContactId != null){
            setCons.add(cm.ContactId);
          }
          if (cm.LeadId != null){
            setLeads.add(cm.LeadId);
          }
        }
        
        System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Adding Camp: ' +cm.CampaignId);
        setCamps.add(cm.CampaignId);
        setCamps.add(cm.Attendee_Group__c);
        //See if Event Member Status has changed, track the corresponding Group Membership
        if (Trigger.isUpdate &&cm.Group_Membership__c != null &&cm.Status != Trigger.oldMap.get(cm.Id).Status
          &&cm.Attendee_Group__c == Trigger.oldMap.get(cm.Id).Attendee_Group__c
        ){
          setStatUpdate.add(cm.Group_Membership__c);
        }
        
      }//end CM loop
      
      
      
      //Get related campaigns
      map<Id, Campaign> mapCamps = new map<Id, Campaign>(
        [Select Id, Name, RecordType.DeveloperName, (Select Id, RecordType.DeveloperName, Name, Where_Clause__c from Campaigns__r Order By Order__c),
        Wait_List_Limit__c, Registration_Limit__c, Current_Registration__c, Current_Wait_List__c
        from Campaign where Id IN: setCamps]
      );
      
      //To add members to the group campaign
      List<CampaignMember> lstGroupMembers = [Select Id, ContactId, LeadId, Status, CampaignId from CampaignMember where Id IN: setStatUpdate];
      
      
      
      for (CampaignMember cm : Trigger.new){
        //Only need to do this for events
        if (mapCamps.get(cm.CampaignId).RecordType.DeveloperName == 'Event'){
          //Each member needs to belong to a group
          if (cm.Attendee_Group__c == null){
            if (cm.ContactId != null){
              mapContactNoGroup.put(cm.ContactId, cm.CampaignId);
            } else {
              mapLeadNoGroup.put(cm.LeadId, cm.CampaignId);
            }
          } else {
            //gather the group ids for later
            setGroups.add(cm.Attendee_Group__c);
            if (Trigger.isUpdate &&cm.Attendee_Group__c != Trigger.oldMap.get(cm.Id).Attendee_Group__c){
                setRemGroup.add(cm.Group_Membership__c);
                lstGroupMembers.add(new CampaignMember(
                  Status = cm.Status,
                  ContactId = cm.ContactId,
                  LeadId = cm.LeadId,
                  CampaignId = cm.Attendee_Group__c
                ));
            } //end if update and attendee group changed
            
          }
        }//end if event
        
      }//end CampaignMember loop2
      
      //If someone switched to another group, remove them from the original group
      if (setRemGroup.size() > 0){
        List<CampaignMember> lstDels = [Select Id from CampaignMember where Id IN: setRemGroup];
        delete lstDels;
      }
      
      //Check which group Contacts should go into
      if (mapContactNoGroup.size() > 0){
        for (Id idContact : mapContactNoGroup.keySet()){
          Boolean inGroup = false;
          for (Campaign grp : mapCamps.get(mapContactNoGroup.get(idContact)).Campaigns__r){
            if (!inGroup &&grp.RecordType.DeveloperName == 'Event_Attendee_Group'){
              String strSoQL = 'Select Id from Contact where Id = \'' +idContact +'\'';
              if (grp.Where_Clause__c != null){
                strSoQL += ' and (';
                strSoQL += grp.Where_Clause__c;
                strSoQL += ')';
              }
              System.debug('In CampaignMember trigger, Contact strSoQL = ' +strSoQL);
              if (Database.query(strSoQL).size() == 1){
                mapContactGroup.put(idContact, grp.Id);
                setCamps.add(grp.Id);
                System.debug('Adding to group: ' +grp.Name);
                inGroup = true;
              }  
            }
          }
        }
      }
      
      //Check which group Leads should go into
      if (mapLeadNoGroup.size() > 0){
        for (Id idLead : mapLeadNoGroup.keySet()){
          Boolean inGroup = false;
          for (Campaign grp : mapCamps.get(mapLeadNoGroup.get(idLead)).Campaigns__r){
            if (!inGroup &&grp.RecordType.DeveloperName == 'Event_Attendee_Group'){
              String strSoQL = 'Select Id from Lead where Id = \'' +idLead +'\'';
              
              if (grp.Where_Clause__c != null){
                strSoQL += ' and (';
                strSoQL += grp.Where_Clause__c;
                strSoQL += ')';
              }
              System.debug('In CampaignMember trigger, Lead strSoQL = ' +strSoQL);
              if (Database.query(strSoQL).size() == 1){
                mapLeadGroup.put(idLead, grp.Id);
                setCamps.add(grp.Id);
                System.debug('Adding to group: ' +grp.Name);
                inGroup = true;
              }  
            }
          }
        }
      }
      
      //Get related campaigns (again, because there are new campaigns now)
      mapCamps = new map<Id, Campaign>(
        [Select Id, RecordType.DeveloperName, (Select Id, Name, Where_Clause__c from Campaigns__r Order By Order__c),
        Wait_List_Limit__c, Registration_Limit__c, Current_Registration__c, Current_Wait_List__c
        from Campaign where Id IN: setCamps]
      );
      
      map<Id, Double> mapGroupCurrReg = new map<Id, Double>();
      map<Id, Double> mapGroupCurrWait = new map<Id, Double>();
      for (Campaign c : mapCamps.values()){
        if (c.RecordType.DeveloperName == 'Event_Attendee_Group'){
          mapGroupCurrReg.put(c.Id, c.Current_Registration__c);
          mapGroupCurrWait.put(c.Id, c.Current_Wait_List__c);
        }
      }
      
      Set<Id> setAttGroupOpen = new Set<Id>();
      //Now put the groups into the records, or throw an error
      for (CampaignMember cm : Trigger.new){
        //Only need to do this for events
        if (mapCamps.get(cm.CampaignId).RecordType.DeveloperName == 'Event'){
          if (cm.Attendee_Group__c == null){
            if (cm.ContactId != null){
              cm.Attendee_Group__c = mapContactGroup.get(cm.ContactId);
              if (cm.Attendee_Group__c != null){
                lstGroupMembers.add(new CampaignMember(Status = cm.Status, ContactId = cm.ContactId, CampaignId = mapContactGroup.get(cm.ContactId)));
              } else {
                cm.addError('This Contact does not fall into any of the Attendee Groups and cannot be added.');
              }
              
            } else {
              cm.Attendee_Group__c = mapLeadGroup.get(cm.LeadId);
              if (cm.Attendee_Group__c != null){
                lstGroupMembers.add(new CampaignMember(Status = cm.Status, LeadId = cm.LeadId, CampaignId = mapLeadGroup.get(cm.LeadId)));
              } else {
                cm.addError('This Lead does not fall into any of the Attendee Groups and cannot be added.');
              }
            }
          }
          //If there already was a group or the group was successfully assigned...
          if (cm.Attendee_Group__c != null){
            Boolean isError = false;
            //Make sure the limits aren't being hit
            if ((Trigger.isUpdate &&cm.Status == 'Registered' &&Trigger.oldMap.get(cm.Id).Status != 'Registered')
              || (Trigger.isInsert &&cm.Status == 'Registered')
            ){
              
              if (mapGroupCurrReg.get(cm.Attendee_Group__c).intValue() < mapCamps.get(cm.Attendee_Group__c).Registration_Limit__c){
                //If there's room, increment the current registered tracker
                mapGroupCurrReg.put(cm.Attendee_Group__c, mapGroupCurrReg.get(cm.Attendee_Group__c)+1);
              } else {
                cm.Status = 'Wait List';
              }
            }
            
            if ((Trigger.isUpdate &&cm.Status == 'Wait List' &&Trigger.oldMap.get(cm.Id).Status != 'Wait List')
              || (Trigger.isInsert &&cm.Status == 'Wait List') &&cm.Attendee_Group__c != null
            ){
              cm.Entered_Wait_List__c = System.now();
              System.debug('Current wait list: ' +mapGroupCurrWait.get(cm.Attendee_Group__c).intValue() +' wait list limit: ' +mapCamps.get(cm.Attendee_Group__c).Wait_List_Limit__c);
              if (mapGroupCurrWait.get(cm.Attendee_Group__c).intValue() < mapCamps.get(cm.Attendee_Group__c).Wait_List_Limit__c){
                //If there's room in the wait list, increment the current wait list tracker
                mapGroupCurrWait.put(cm.Attendee_Group__c, mapGroupCurrWait.get(cm.Attendee_Group__c)+1);
              } else {
                //Otherwise, they're out of luck
                cm.addError('Sorry, there\'s no more room on the wait list for ' +cm.First_Name__c +' ' +cm.Last_Name__c +' for this event.');
                isError = true;
              }
            }
            //See if someone stopped being Registered
            if (Trigger.isUpdate &&cm.Status != 'Registered' &&Trigger.oldMap.get(cm.Id).Status == 'Registered'){
              setAttGroupOpen.add(cm.Attendee_Group__c);
              //Decrement the Current Reg
              mapGroupCurrReg.put(cm.Attendee_Group__c, mapGroupCurrReg.get(cm.Attendee_Group__c)-1);
            }
            
            
            if (
              !isError
            ){
              for (CampaignMember gm : lstGroupMembers){
                if (gm.LeadId == cm.LeadId &&gm.ContactId == cm.ContactId
                ){
                  gm.Status = cm.Status;
                }
              }
            }
          }
          System.debug('End of loop 3 and the status is ' +cm.Status);
        }//end if this is an event registration
        
      }//end CampMember loop 3
      
      //If there were any openings in an Attendence Group, sort those out
      if (setAttGroupOpen.size() > 0){
        clsAttendance.WaitListOpenings(setAttGroupOpen.size(), setAttGroupOpen);
      }
      
      if (lstGroupMembers.size() > 0){
        upsert lstGroupMembers;
        //Need the Group Member Id stored in the Event Member record to sync statuses
        for (CampaignMember gm : lstGroupMembers){
          for (CampaignMember em : Trigger.new){
            if (gm.ContactId == em.ContactId &&gm.LeadId == em.LeadId){
              em.Group_Membership__c = gm.Id;
            }
          }
        }
      }
    }//END INSERT UPDATE
  }//END BEFORE
  
  //AFTER
  if (Trigger.isAfter){
    //INSERT UPDATE
    if (Trigger.isInsert || Trigger.isUpdate){
      
      
    }//END INSERT UPDATE
    
    //DELETE
    if (Trigger.isDelete){
      Set<Id> setMembers = new Set<Id>();
      Set<Id> setRegGroup = new Set<Id>();
      
      for (CampaignMember cm : Trigger.old){
        System.debug('Adding Group_Membership__c' +cm.Group_Membership__c);
        setMembers.add(cm.Group_Membership__c);
        if (cm.Status == 'Registered' &&cm.Attendee_Group__c != null){
          setRegGroup.add(cm.Attendee_Group__c);
        }
      }
      
      List<campaignMember> lstDel = [Select Id from CampaignMember where Id IN: setMembers];
      delete lstDel;
      
      //If there were any openings in an Attendence Group, sort those out
      if (setRegGroup.size() > 0){
        clsAttendance.WaitListOpenings(setRegGroup.size(), setRegGroup);
      }
      
    }
  }//END AFTER
}