trigger VEM_EventAutoSubmit on VEM_Event__c (after update)
{
	if (Trigger.isUpdate)
	{
		for (Integer i = 0; i < Trigger.new.size(); i++)
		{
			if (
				 (Trigger.old[i].Event_Status__c == 'Approved' && Trigger.new[i].Event_Status__c == 'Approved') &&
			     (
			       (Trigger.new[i].Start_Date_Time__c < Trigger.old[i].Start_Date_Time__c) ||
			       (Trigger.new[i].End_Date_Time__c > Trigger.old[i].End_Date_Time__c) ||
			       (Trigger.new[i].Event_Location__c != Trigger.old[i].Event_Location__c) ||
			       (Trigger.new[i].Expected_Volume__c > Trigger.old[i].Expected_Volume__c)
			     ) &&
			     (
			       (Trigger.new[i].Location_Approver__c != null) &&  // Need to know who to assign it to
			       (Trigger.new[i].EMS_Booking_ID__c == null)        // Events from EMS do not require approval 
			     )
			   )
			{
		    	// Create an approval request
				Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
				req.setObjectId(Trigger.new[i].Id);
				req.setComments('Event updated. Please re-approve.');

				// Submit the approval request for processing
				Approval.ProcessResult result = Approval.process(req);
			}
		}
	}
}