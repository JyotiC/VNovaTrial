/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class VEM_TestHelperTest
{

	static testMethod void testGetLocation()
	{
		final String c_VillanovaRoom = 'Villanova Room';
		final String c_NewLocation = 'ABC-XYZ';

		Test.startTest();
		VEM_Location__c location1 = VEM_TestHelper.getLocation(c_VillanovaRoom);
		VEM_Location__c location2 = VEM_TestHelper.getLocation(c_NewLocation);
		Test.stopTest();

		system.assert(location1.Name == c_VillanovaRoom);
		system.assert(location2.Name == c_NewLocation);
	}

	static testMethod void testGetUser()
	{
		Test.startTest();
		User user1 = VEM_TestHelper.getUser('Timothy', 'Ay');
		User user2 = VEM_TestHelper.getUser('ABC', 'XYZ');
		Test.stopTest();

		system.assert(user1.Id != null);
		system.assert(user2.Id != null);
	}

}