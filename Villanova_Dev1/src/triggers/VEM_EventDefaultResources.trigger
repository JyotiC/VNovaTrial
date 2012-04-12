trigger VEM_EventDefaultResources on VEM_Event__c (after insert, after update)
{
    if (Trigger.isInsert)
    {
    	VEM_Event.addDefaultResourcesByLocation(null, Trigger.new);
    }
    if (Trigger.isUpdate)
    {
    	// Commenting this out for now because it adds resources for new event to existing list of resources
    	//VEM_Event.addDefaultResourcesByLocation(Trigger.old, Trigger.new);
    }
}