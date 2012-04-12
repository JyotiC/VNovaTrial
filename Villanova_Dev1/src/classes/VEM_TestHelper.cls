public with sharing class VEM_TestHelper
{

	public static final Boolean isInitialDeployment = ([ SELECT count() FROM VEM_Location__c ] == 0);
	
	public static final User currentUser = [ SELECT Id, Name, Email FROM User WHERE Id = :Userinfo.getUserId() ];

	public static VEM_Location__c getLocation(String name)
	{
		VEM_Location__c location = null;

		List<VEM_Location__c> locationList = [ SELECT Id, Name, Parent_Location__c FROM VEM_Location__c WHERE Name = :name ];
		if (locationList.size() > 0)
		{
			location = locationList[0];
		}
		else
		{
			location = new VEM_Location__c();
			location.Name = name;
			location.Location_Type__c = 'Building';
			location.Zone__c = 'Main Campus - East';
			location.Approver__c = UserInfo.getUserId();
			insert location;
		}
		return location;
	}

	public static User getUser(String firstName, String lastName)
	{
		User usr = null;

		List<User> userList = [ SELECT Id FROM User WHERE FirstName = :firstName AND LastName = :lastName AND isActive = true LIMIT 1 ];
		if (userList.size() > 0)
		{
			usr = userList[0];
		}
		else
		{
			usr = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1 ];
		}

		return usr;
	}

}