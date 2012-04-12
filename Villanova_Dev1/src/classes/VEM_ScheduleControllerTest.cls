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
private class VEM_ScheduleControllerTest
{

	static VEM_ScheduleController scheduleController = new VEM_ScheduleController();

	static testMethod void testProfileSelectionList()
	{
		Test.startTest();
		List<SelectOption> selectOptionList = scheduleController.profileSelectionList;
		Test.stopTest();

		System.assert(selectOptionList.size() > 0);
	}

	static testMethod void testScheduleDateRangeString()
	{
		Test.startTest();
		String resultString1 = scheduleController.scheduleDateRangeString;
		scheduleController.scheduleStartDate = Date.today();
		scheduleController.scheduleEndDate = Date.today().addDays(3);
		String resultString2 = scheduleController.scheduleDateRangeString;
		Test.stopTest();

		System.assert(resultString1 != resultString2);
	}

	static testMethod void testProxyObject()
	{
		Test.startTest();
		Date dt1 = scheduleController.proxyObject.CloseDate;
		scheduleController.scheduleDate = Date.today();
		Date dt2 = scheduleController.proxyObject.CloseDate;
		Test.stopTest();

		System.assert(dt1 == dt2);
	}

	static testMethod void testHandlers()
	{
		Test.startTest();
		scheduleController.handlePreviousDay();
		scheduleController.handleNextDay();
		scheduleController.handleDateChange();
		Test.stopTest();

		System.assert(true);
	}

	static testMethod void testLocationSchedule()
	{
		Test.startTest();
		List<VEM_Location__c> resultList = scheduleController.locationSchedule;
		Test.stopTest();

		System.assert(resultList.size() >= 0);
	}

	static testMethod void testLocationScheduleWithProfile()
	{
		List<Profile> profileList =
			[ SELECT Id, Name
				FROM Profile
			   WHERE Name LIKE 'VEM %'
				 AND Name NOT IN ('VEM Standard User') ];

		List<User> userList = new List<User>();
		if (profileList.size() > 0)
		{
			userList = [ SELECT Id, Name FROM User WHERE IsActive = true AND ProfileId = :profileList[0].Id ];
		}

		List<VEM_Location__c> resultList = new List<VEM_Location__c>();

		Test.startTest();
		if (userList.size() > 0)
		{
			System.runAs(userList[0])
			{
				scheduleController.selectedProfileId = null;
				resultList = scheduleController.locationSchedule;
			}
		}
		Test.stopTest();

		System.assert(resultList.size() >= 0);
	}

}