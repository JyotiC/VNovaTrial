public with sharing class Kevin
{
	private void Kevin()
	{
		myProperty = false;
	}

	public static Boolean myProperty
	{
		get;
	} 

	private static Boolean m_myProperty2 = false;
	public static Boolean myProperty2
	{
		get { return m_myProperty2; }
	}

	public static Boolean myProperty3
	{
		get
		{
			if (myProperty2 == null)
			{
				myProperty2 = false;
			}
			return myProperty2;
		}
	}

	private static Map<Id,VEM_Location__c> m_locationMap = new Map<Id,VEM_Location__c>([SELECT Id, Name, Parent_Location__c FROM VEM_Location__c]);
	public static Map<Id,VEM_Location__c> locationMap
	{
		get	{ return m_locationMap; }
	}

}