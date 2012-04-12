trigger VEM_EventDateValidation on VEM_Event__c (before insert, before update)
{
	if (Trigger.isInsert || Trigger.isUpdate)
	{
 		if (Trigger.isInsert)
		{
			VEM_Event.syncEventDateTime_OnInsert(Trigger.new);
		}
		else if (Trigger.isUpdate)
		{
			VEM_Event.syncEventDateTime_OnUpdate(Trigger.old, Trigger.new);
		}

		VEM_Event.validateEvents(Trigger.new);
	}
}