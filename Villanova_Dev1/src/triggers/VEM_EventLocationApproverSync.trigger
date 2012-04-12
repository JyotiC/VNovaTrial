trigger VEM_EventLocationApproverSync on VEM_Event__c (before insert, before update)
{
	if (Trigger.isInsert || Trigger.isUpdate)
	{
		VEM_Event.syncLocationApprover(Trigger.new);
	}
}