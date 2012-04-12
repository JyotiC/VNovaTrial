trigger VEM_EventRecurrence on VEM_Event__c (before insert, before update, before delete, after insert, after update)
{
	if (Trigger.isBefore)
	{
		if (Trigger.isInsert || Trigger.isUpdate)
		{
			if (VEM_Event.validateEventRecurrence(Trigger.new))
			{
				VEM_Event.clearUnselectedRecurrenceOptions(Trigger.new);
			}
		}
		else if (Trigger.isDelete)
		{
			VEM_Event.removeRecurringEvents(Trigger.old);
		}
	}
	else if (Trigger.isAfter)
	{
		if (Trigger.isInsert)
		{
			VEM_Event.addRecurringEvents(Trigger.new);
		}
		else if (Trigger.isUpdate)
		{
			VEM_Event.removeRecurringEvents(Trigger.old);
			VEM_Event.addRecurringEvents(Trigger.new);
		}
	}
}