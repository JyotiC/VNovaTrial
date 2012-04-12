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
private class VEM_EventControllerTest
{

	static VEM_EventController eventController = new VEM_EventController();

	static testMethod void todayPlus()
	{
        Test.startTest();
		String todayPlus0Str = eventController.todayPlus0String;
		String todayPlus1Str = eventController.todayPlus1String;
		String todayPlus2Str = eventController.todayPlus2String;
		String todayPlus3Str = eventController.todayPlus3String;
		String todayPlus4Str = eventController.todayPlus4String;
		String todayPlus5Str = eventController.todayPlus5String;
		String todayPlus6Str = eventController.todayPlus6String;
		Test.stopTest();
		system.assertNotEquals(todayPlus0Str, todayPlus1Str, todayPlus2Str);
		system.assertNotEquals(todayPlus2Str, todayPlus3Str, todayPlus4Str);
		system.assertNotEquals(todayPlus4Str, todayPlus5Str, todayPlus6Str);
	}

    static testMethod void todayInTheConnellyCenter()
    {
		VEM_Location__c connellyCenter = VEM_TestHelper.getLocation('Connelly Center');
		VEM_Location__c radnorRoom = VEM_TestHelper.getLocation('Radnor Room');
		if (radnorRoom.Parent_Location__c != connellyCenter.Id)
		{
			radnorRoom.Parent_Location__c = connellyCenter.Id;
			update radnorRoom;
		}

        List<VEM_Event__c> todaysEvents1 = eventController.eventsInConnellyToday;

		VEM_Event__c TestEvent1 = new VEM_Event__c();
		TestEvent1.Name = 'Test Insert';
		TestEvent1.Event_Type__c = 'Meeting';
		TestEvent1.Event_Location__c = radnorRoom.Id;
		TestEvent1.Start_Date__c = Date.today();
		TestEvent1.Start_Time__c = '11:30 PM';
		TestEvent1.End_Date__c = Date.today();
		TestEvent1.End_Time__c = '11:45 PM';
		TestEvent1.Event_Sponsor__c = 'Test';
		TestEvent1.Expected_Volume__c = 100;
		TestEvent1.Event_Status__c = 'Approved';
		insert TestEvent1;

        Test.startTest();
        List<VEM_Event__c> todaysEvents2 = eventController.getEventsInConnellyToday();
		Test.stopTest();

		system.assert(todaysEvents2.size() - todaysEvents1.size() == 1);
    }

    static testMethod void todayInAthletics()
    {
        List<VEM_Event__c> todaysEvents1 = eventController.eventsInAthleticsToday;
		eventController.ClearCacheOfEventsInAthleticsToday();

		VEM_Event__c TestEvent1 = new VEM_Event__c();
		TestEvent1.Name = 'Test Insert';
		TestEvent1.Event_Type__c = 'Meeting';
		TestEvent1.Event_Location__c = VEM_TestHelper.getLocation('Softball Field').Id;
		TestEvent1.Start_Date__c = Date.today();
		TestEvent1.Start_Time__c = '11:30 PM';
		TestEvent1.End_Date__c = Date.today();
		TestEvent1.End_Time__c = '11:45 PM';
		TestEvent1.Event_Sponsor__c = 'Test';
		TestEvent1.Expected_Volume__c = 100;
		TestEvent1.Event_Status__c = 'Approved';
		insert TestEvent1;

        Test.startTest();
        List<VEM_Event__c> todaysEvents2 = eventController.getEventsInAthleticsToday();
		Test.stopTest();

		system.assert(todaysEvents2.size() - todaysEvents1.size() == 1);
    }

	static testMethod void eventsInAthleticsTodayPlus()
	{
        Test.startTest();
		List<VEM_Event__c> todayPlus0List = eventController.eventsInAthleticsTodayPlus0;
		List<VEM_Event__c> todayPlus1List = eventController.eventsInAthleticsTodayPlus1;
		List<VEM_Event__c> todayPlus2List = eventController.eventsInAthleticsTodayPlus2;
		List<VEM_Event__c> todayPlus3List = eventController.eventsInAthleticsTodayPlus3;
		List<VEM_Event__c> todayPlus4List = eventController.eventsInAthleticsTodayPlus4;
		List<VEM_Event__c> todayPlus5List = eventController.eventsInAthleticsTodayPlus5;
		List<VEM_Event__c> todayPlus6List = eventController.eventsInAthleticsTodayPlus6;
		Test.stopTest();
		system.assert(true);
	}

    static testMethod void thisWeekInAthletics()
    {
        List<VEM_Event__c> thisWeekEvents1 = eventController.eventsInAthleticsThisWeek;
        eventController.ClearCacheOfEventsInAthleticsThisWeek();

		VEM_Event__c TestEvent1 = new VEM_Event__c();
		TestEvent1.Name = 'Test Insert';
		TestEvent1.Event_Type__c = 'Meeting';
		TestEvent1.Event_Location__c = VEM_TestHelper.getLocation('Softball Field').Id;
		TestEvent1.Start_Date__c = Date.today();
		TestEvent1.Start_Time__c = '11:30 PM';
		TestEvent1.End_Date__c = Date.today();
		TestEvent1.End_Time__c = '11:45 PM';
		TestEvent1.Event_Sponsor__c = 'Test';
		TestEvent1.Expected_Volume__c = 100;
		TestEvent1.Event_Status__c = 'Approved';
		insert TestEvent1;

        Test.startTest();
        List<VEM_Event__c> thisWeekEvents2 = eventController.getEventsInAthleticsThisWeek();
		Test.stopTest();

		system.assert(thisWeekEvents2.size() - thisWeekEvents1.size() == 1);
    }

	static testMethod void testConnellyCenterOperationsReportDates()
	{
		final Date c_operationsReportDate = Date.parse('11/30/2020');
		final Date c_projectionReportStartDate = Date.parse('12/1/2020');
		final Date c_projectionReportEndDate = Date.parse('12/31/2020');

		Test.startTest();
		eventController.connellyOperationsReportDate = c_operationsReportDate;
		Date operationsReportDate = eventController.connellyOperationsReportDate;

		eventController.connellyProjectionStartDate = c_projectionReportStartDate;
		Date projectionReportStartDate = eventController.connellyProjectionStartDate;
		eventController.connellyProjectionEndDate = c_projectionReportEndDate;
		Date projectionReportEndDate = eventController.connellyProjectionEndDate;
		Test.stopTest();

		system.assert(operationsReportDate == c_operationsReportDate);
		system.assert(projectionReportStartDate == c_projectionReportStartDate);
		system.assert(projectionReportEndDate == c_projectionReportEndDate);
	}

	static testMethod void projectionDateRangeString()
	{
        Test.startTest();
		String dateRangeString = eventController.projectionDateRangeString;
		Test.stopTest();

		system.assert(dateRangeString != null && dateRangeString != '');
	}

	static testMethod void connellyOperationsReportEvents()
	{
        Test.startTest();
		List<VEM_Event__c> eventList1 = eventController.connellyOperationsReportEvents;
		List<VEM_Event__c> eventList2 = eventController.connellyOperationsReportEvents;
		Test.stopTest();

		system.assert(eventList1.size() == eventList2.size());
	}

	static testMethod void connellyOperationsProjectionEvents()
	{
        Test.startTest();
		List<VEM_Event__c> eventList1 = eventController.connellyOperationsProjectionEvents;
		List<VEM_Event__c> eventList2 = eventController.connellyOperationsProjectionEvents;
		Test.stopTest();

		system.assert(eventList1.size() == eventList2.size());
	}

}