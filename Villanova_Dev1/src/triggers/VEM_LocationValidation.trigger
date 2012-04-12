trigger VEM_LocationValidation on VEM_Location__c (before update)
{

	if (Trigger.isUpdate)
	{
		VEM_Location.validateParentLocation(Trigger.old, Trigger.new);
	}

}