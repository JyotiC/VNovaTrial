/// This class contains properties and methods for Villanova University locations.
///
public with sharing class VEM_Location
{

	// Validate that the parent location will not create a circular reference
	public static Boolean validateParentLocation(List<VEM_Location__c> oldLocationList, List<VEM_Location__c> newLocationList)
	{
		Boolean isValid = true;

		VEM_Location__c oldLocation;
		VEM_Location__c newLocation;
		Integer locationCount = oldLocationList.size();

		for (Integer i = 0; i < locationCount; i++)
		{
			oldLocation = oldLocationList[i];
			newLocation = newLocationList[i];

			// Is the parent location changing?
			if (oldLocation.Parent_Location__c <> newLocation.Parent_Location__c)
			{
				// List of locations found in hierarchy
				Set<Id> locationIds = new Set<Id>();

				// Add id to list of locations found
				locationIds.add(newLocation.Id);

				Id locationId = newLocation.Parent_Location__c;
				VEM_Location__c parentLocation;

				while (locationId != null)
				{
					// Add id to list of locations found
					locationIds.add(locationId);

					// Get parent of current location
					parentLocation = [SELECT Id, Name, Parent_Location__c FROM VEM_Location__c WHERE Id = :locationId];
					locationId = parentLocation.Parent_Location__c;

					// Was this Id already found in the hierarchy?
					if (locationIds.contains(locationId))
					{
						// Circular reference found
						isValid = false;
						newLocation.Parent_Location__c.addError('The parent location is invalid for this location because it would cause a circular reference.');
					}
				}
			}
		}

		return isValid;
	}

}