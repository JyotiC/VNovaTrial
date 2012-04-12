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
private class VEM_EventTest
{

	private static VEM_Event__c TestEvent1
	{
		get
		{
			if (TestEvent1 == null)
			{
				TestEvent1 = new VEM_Event__c();
				TestEvent1.Name = 'Test Insert';
				TestEvent1.Event_Type__c = 'Meeting';
				TestEvent1.Event_Location__c = VEM_TestHelper.getLocation('Bartley Hall').Id;
				TestEvent1.Time_Interval__c = '30 Minute';
				TestEvent1.Start_Date__c = Date.parse('1/10/2050');
				TestEvent1.Start_Time__c = '1:00 PM';
				TestEvent1.End_Date__c = Date.parse('1/10/2050');
				TestEvent1.End_Time__c = '3:00 PM';
				TestEvent1.Event_Sponsor__c = 'Test';
				TestEvent1.Expected_Volume__c = 100;
			}

			return TestEvent1;
		}
	}

	private static VEM_Event__c TestEvent2
	{
		get
		{
			if (TestEvent2 == null)
			{
				TestEvent2 = new VEM_Event__c();
				TestEvent2.Name = 'Test Insert';
				TestEvent2.Event_Type__c = 'Meeting';
				TestEvent2.Event_Location__c = VEM_TestHelper.getLocation('Bartley Hall').Id;
				TestEvent2.Time_Interval__c = '30 Minute';
				TestEvent2.Start_Date__c = Date.parse('2/1/2050');
				TestEvent2.Start_Time__c = '1:00 PM';
				TestEvent2.End_Date__c = Date.parse('2/1/2050');
				TestEvent2.End_Time__c = '3:00 PM';
				TestEvent2.Event_Sponsor__c = 'Test';
				TestEvent2.Expected_Volume__c = 100;
			}

			return TestEvent2;
		}
	}

	private static VEM_Event__c TestEvent3
	{
		get
		{
			if (TestEvent3 == null)
			{
				TestEvent3 = new VEM_Event__c();
				TestEvent3.Name = 'Test Insert';
				TestEvent3.Event_Type__c = 'Meeting';
				TestEvent3.Event_Location__c = VEM_TestHelper.getLocation('Bartley Hall').Id;
				TestEvent3.Time_Interval__c = '30 Minute';
				TestEvent3.Start_Date__c = Date.parse('2/28/2050');
				TestEvent3.Start_Time__c = '1:00 PM';
				TestEvent3.End_Date__c = Date.parse('3/1/2050');
				TestEvent3.End_Time__c = '3:00 PM';
				TestEvent3.Event_Sponsor__c = 'Test';
				TestEvent3.Expected_Volume__c = 100;
			}

			return TestEvent3;
		}
	}

	private static VEM_Event__c TestEvent4
	{
		get
		{
			if (TestEvent4 == null)
			{
				TestEvent4 = new VEM_Event__c();
				TestEvent4.Name = 'Test Insert 4';
				TestEvent4.Event_Type__c = 'Meeting';
				TestEvent4.Event_Location__c = VEM_TestHelper.getLocation('Bartley Hall').Id;
				TestEvent4.Time_Interval__c = '30 Minute';
				TestEvent4.Start_Date__c = Date.today().addDays(-1);
				TestEvent4.Start_Time__c = '1:00 PM';
				TestEvent4.End_Date__c = Date.today().addDays(-1);
				TestEvent4.End_Time__c = '3:00 PM';
				TestEvent4.Event_Sponsor__c = 'Test';
				TestEvent4.Expected_Volume__c = 100;
			}

			return TestEvent4;
		}
	}

	private static VEM_BlackoutDate__c TestBlackoutDate1
	{
		get
		{
			if (TestBlackoutDate1 == null)
			{
				TestBlackoutDate1 = new VEM_BlackoutDate__c();
				TestBlackoutDate1.Name = 'Test Blackout Date 1';
				TestBlackoutDate1.Start_Date__c = Date.parse('2/1/2050');
				TestBlackoutDate1.End_Date__c = TestBlackoutDate1.Start_Date__c;
				TestBlackoutDate1.Requestor__c = UserInfo.getUserId();
			}

			return TestBlackoutDate1;
		}
	}

	private static VEM_BlackoutDate__c TestBlackoutDate2
	{
		get
		{
			if (TestBlackoutDate2 == null)
			{
				TestBlackoutDate2 = new VEM_BlackoutDate__c();
				TestBlackoutDate2.Name = 'Test Blackout Date 2';
				TestBlackoutDate2.Start_Date__c = Date.parse('3/1/2050');
				TestBlackoutDate2.End_Date__c = TestBlackoutDate2.Start_Date__c.addDays(1);
				TestBlackoutDate2.Requestor__c = UserInfo.getUserId();
			}

			return TestBlackoutDate2;
		}
	}

	static testMethod void testAllowFutureEventsOnly()
	{
		VEM_Event__c event1 = TestEvent1.clone(false);
		event1.Start_Date__c = Date.today().addDays(-10);
		event1.Start_Time__c = '4:15 AM';
		event1.Start_Date_Time__c = VEM_Event.toDatetime(event1.Start_Date__c, event1.Start_Time__c, false);
		event1.End_Date__c = event1.Start_Date__c;
		event1.End_Time__c = '4:30 AM';
		event1.End_Date_Time__c = VEM_Event.toDatetime(event1.End_Date__c, event1.End_Time__c, false);

		List<VEM_Event__c> eventList1 = new List<VEM_Event__c>{event1};

		Test.startTest();
		VEM_Event.allowFutureEventsOnly = false;
		Boolean result1 = VEM_Event.validateEvents(eventList1);
		VEM_Event.allowFutureEventsOnly = true;
		Boolean result2 = VEM_Event.validateEvents(eventList1);
		Test.stopTest();

		system.assert(result1);
		system.assert(!result2);
	}

	static testMethod void testIsValidationRequired()
	{
		VEM_Event__c event1 = TestEvent1.clone(false);
		List<VEM_Event__c> eventList1 = new List<VEM_Event__c>{event1};
		insert eventList1;

		Test.startTest();
		VEM_Event.isValidationRequired = false;
		Boolean result1 = VEM_Event.validateEvents(eventList1);
		Test.stopTest();
		
		system.assert(result1);
	}

	static testMethod void testEventTriggers()
	{
		Integer beforeCount = [ SELECT count() FROM VEM_Event__c ];

		Test.startTest();
		insert TestEvent1;
		Test.stopTest();

		Integer afterCount = [ SELECT count() FROM VEM_Event__c ];

		system.assert(afterCount - beforeCount == 1);
	}

	static testMethod void testValidateEvents()
	{
		insert TestBlackoutDate1;
		insert TestBlackoutDate2;

		List<VEM_Event__c> eventList1 = new List<VEM_Event__c>{TestEvent1};
		List<VEM_Event__c> eventList2 = new List<VEM_Event__c>{TestEvent2};
		List<VEM_Event__c> eventList3 = new List<VEM_Event__c>{TestEvent3};
		List<VEM_Event__c> eventList4 = new List<VEM_Event__c>{TestEvent4};

		Test.startTest();
		Boolean result1 = VEM_Event.validateEvents(eventList1);
		Boolean result2 = VEM_Event.validateEvents(eventList2);
		Boolean result3 = VEM_Event.validateEvents(eventList3);
		Boolean result4 = VEM_Event.validateEvents(eventList4);
		Test.stopTest();

		system.assert(result1);
		system.assert(!result2);
		system.assert(!result3);
		system.assert(!result4);
	}

	static testMethod void testValidateEventDateTimes()
	{
		VEM_Event__c event1 = TestEvent1;
		event1.Start_Date__c = Date.today();
		event1.End_Date__c = event1.Start_Date__c.addDays(-1);

		VEM_Event__c event2 = TestEvent2;
		event2.Start_Date__c = Date.today();
		event2.Start_Time__c = '4:00 PM';
		event2.End_Date__c = event2.Start_Date__c;
		event2.End_Time__c = '2:00 PM';

		VEM_Event__c event3 = TestEvent3;
		event3.Time_Interval__c = '';
		event3.Start_Date__c = Date.today().addDays(1);
		event3.Start_Time__c = '1:00 AM';
		event3.End_Date__c = Date.today().addDays(2);
		event3.End_Time__c = '2:00 AM';

		Test.startTest();
		Boolean result1 = VEM_Event.validateEventDateTimes(event1);
		Boolean result2 = VEM_Event.validateEventDateTimes(event2);
		Boolean result3 = VEM_Event.validateEventDateTimes(event3);
		event3.Start_Time__c = '12:00 AM';
		Boolean result4 = VEM_Event.validateEventDateTimes(event3);
		event3.Time_Interval__c = '30 Minute';
		event3.Start_Time__c = '';
		Boolean result5 = VEM_Event.validateEventDateTimes(event3);
		event3.Start_Time__c = '12:00 AM';
		event3.End_Time__c = null;
		Boolean result6 = VEM_Event.validateEventDateTimes(event3);
		event3.Start_Date__c = Date.today().addDays(-1);
		event3.End_Time__c = '2:00 AM';
		Boolean result7 = VEM_Event.validateEventDateTimes(event3);
		event3.Time_Interval__c = '30 Minute';
		event3.Start_Date__c = Date.today();
		event3.Start_Time__c = '12:00 AM';
		event3.End_Date__c = Date.today();
		event3.End_Time__c = '11:00 PM';
		Boolean result8 = VEM_Event.validateEventDateTimes(event3);
		event3.Time_Interval__c = '30 Minute';
		event3.Start_Date__c = Date.today().addDays(5);
		event3.Start_Time__c = '3:00 PM';
		event3.Start_Date_Time__c = VEM_Event.toDatetime(event3.Start_Date__c, event3.Start_Time__c, false);
		event3.End_Date__c = Date.today().addDays(5);
		event3.End_Time__c = '3:00 PM';
		event3.End_Date_Time__c = VEM_Event.toDatetime(event3.End_Date__c, event3.End_Time__c, false);
		Boolean result9 = VEM_Event.validateEventDateTimes(event3);
		Test.stopTest();

		system.assert(!result1);
		system.assert(!result2);
		system.assert(!result3);
		system.assert(!result4);
		system.assert(!result5);
		system.assert(!result6);
		system.assert(!result7);
		system.assert(!result8);
		system.assert(!result9);
	}

	static testMethod void testValidateEventForBlackoutDates()
	{
		insert TestBlackoutDate1;
		insert TestBlackoutDate2;

		Test.startTest();
		Boolean result1 = VEM_Event.validateEventForBlackoutDates(TestEvent1);
		Boolean result2 = VEM_Event.validateEventForBlackoutDates(TestEvent2);
		Boolean result3 = VEM_Event.validateEventForBlackoutDates(TestEvent3);
		Test.stopTest();

		system.assert(result1);
		system.assert(!result2);
		system.assert(!result3);
	}

	static testMethod void testValidateEventLocationAvailability()
	{
		VEM_Event__c event1 = TestEvent1;
		event1.Start_Date__c = Date.today().addDays(1);
		event1.End_Date__c = event1.Start_Date__c;
		insert event1;

		VEM_Event__c event2 = TestEvent2;
		event2.Start_Date__c = event1.Start_Date__c;
		event2.End_Date__c = event1.End_Date__c;

		VEM_Event__c event3 = TestEvent3;
		event3.Start_Date__c = Date.today().addMonths(72);
		event3.End_Date__c = event3.Start_Date__c.addDays(1);
		insert event3;

		VEM_Event__c event4 = TestEvent4;
		event4.Event_Location__c = VEM_TestHelper.getLocation('Connelly Center').Id;
		event4.Start_Date__c = Date.today().addMonths(72);
		event4.End_Date__c = event4.Start_Date__c.addDays(1);

		Test.startTest();
		Boolean result1 = VEM_Event.validateEventLocationAvailability(event2);
		event2.Start_Date__c = event3.Start_Date__c;
		event2.End_Date__c = event3.End_Date__c;
		Boolean result2 = VEM_Event.validateEventLocationAvailability(event2);
		Boolean result4 = VEM_Event.validateEventLocationAvailability(event4);
		Test.stopTest();

		system.assert(!result1);
		system.assert(!result2);
		system.assert(result4);
	}

	/*static testMethod void testParentIdOf()
	{
		Map<Id,VEM_Location__c> parentIdMap = VEM_Event.parentIdMap;
		System.debug(LoggingLevel.INFO, parentIdMap.size());
		VEM_Location__c child = [SELECT Id,Name FROM VEM_Location__c WHERE Name = 'Villanova Room' limit 1];
		Id parentId = VEM_Event.parentIdOf(child.Id);
		VEM_Location__c parent = [SELECT Id,Name FROM VEM_Location__c WHERE id = :parentId limit 1];
		System.debug(LoggingLevel.INFO, parent.Name);
	}*/

	/*static testMethod void testChildIdsOf()
	{
		VEM_Location__c parent = [SELECT Id,Name FROM VEM_Location__c WHERE name = 'Pavilion' limit 1];
		System.debug(LoggingLevel.INFO, parent.Name);
		Set<Id> parentSet = new Set<Id>{parent.Id};
		while (!parentSet.isEmpty())
		{
			Set<Id> childIdSet = new Set<Id>(VEM_Event.childIdsOf(parentSet));
			List<VEM_Location__c> childLocations = [SELECT Id,Name FROM VEM_Location__c WHERE Id IN :childIdSet];
			parentSet.clear();
			for (VEM_Location__c childLocation : childLocations)
			{
				parentSet.add(childLocation.Id);
				System.debug(LoggingLevel.INFO, childLocation.Name);
			}
		}
	}*/

	static testMethod void testSyncEventDateTime()
	{
		VEM_Event__c event1 = new VEM_Event__c();
		event1.Start_Date__c = Date.today().addDays(100);
		event1.Start_Time__c = '6:00 PM';
		event1.Start_Date_Time__c = VEM_Event.toDatetime(event1.Start_Date__c, event1.Start_Time__c, false);
		event1.End_Date__c = event1.Start_Date__c;
		event1.End_Time__c = '7:00 PM';
		event1.End_Date_Time__c = VEM_Event.toDatetime(event1.End_Date__c, event1.End_Time__c, false);
		List<VEM_Event__c> eventList1 = new List<VEM_Event__c>{event1};

		VEM_Event__c event2 = new VEM_Event__c();
		event2.Start_Date__c = Date.today().addDays(100);
		event2.Start_Time__c = '6:00 PM';
		event2.Start_Date_Time__c = VEM_Event.toDatetime(Date.today().addDays(95), event2.Start_Time__c, false);
		event2.End_Date__c = event1.Start_Date__c;
		event2.End_Time__c = '7:00 PM';
		event2.End_Date_Time__c = VEM_Event.toDatetime(Date.today().addDays(95), event2.End_Time__c, false);
		List<VEM_Event__c> eventList2 = new List<VEM_Event__c>{event2};

		Test.startTest();
		VEM_Event.syncEventDateTime_OnUpdate(eventList1, eventList2);
		Test.stopTest();

		system.assert(VEM_Event.toDatetime(event2.Start_Date__c, event2.Start_Time__c, false) == event2.Start_Date_Time__c);
		system.assert(VEM_Event.toDatetime(event2.End_Date__c, event2.End_Time__c, false) == event2.End_Date_Time__c);
	}

	static testMethod void testEventLocationGroup1()
	{
		VEM_Event__c event1 = TestEvent1;
		event1.Event_Location__c = VEM_TestHelper.getLocation('Villanova Room').Id;
		insert event1;

		VEM_Event__c event2 = event1.clone(false);
		event2.Event_Location__c = VEM_TestHelper.getLocation('Villanova & Radnor Rooms').Id;

		Test.startTest();
		Boolean result1 = VEM_Event.validateEventLocationAvailability(event2);
		Test.stopTest();
		
		if (VEM_TestHelper.isInitialDeployment)
		{
			system.assert(true);
		}
		else
		{
			system.assert(!result1);
		}
	}

	static testMethod void testEventLocationGroup2()
	{
		VEM_Event__c event1 = TestEvent1;
		event1.Event_Location__c = VEM_TestHelper.getLocation('Villanova & Radnor Rooms').Id;
		insert event1;

		VEM_Event__c event2 = event1.clone(false);
		event2.Event_Location__c = VEM_TestHelper.getLocation('Villanova Room').Id;

		Test.startTest();
		Boolean result1 = VEM_Event.validateEventLocationAvailability(event2);
		Test.stopTest();

		if (VEM_TestHelper.isInitialDeployment)
		{
			system.assert(true);
		}
		else
		{
			system.assert(!result1);
		}
	}

	static testMethod void testToDatetime()
	{
		Test.startTest();
		Datetime dt1 = VEM_Event.toDatetime(Date.parse('7/17/2090'), '', false);
		Datetime dt2 = VEM_Event.toDatetime(Date.parse('7/16/2090'), '', true);
		Test.stopTest();

		system.assert(dt1.format() == '7/17/2090 12:00 AM');
		system.assert(dt2.format() == '7/17/2090 12:00 AM');
	}

	static testMethod void testAutoSubmitForApproval()
	{
		VEM_Event__c event1 = TestEvent1;
		event1.Event_Location__c = VEM_TestHelper.getLocation('Villanova Stadium').Id;
		event1.Event_Status__c = 'Approved';
		insert event1;

		event1.Expected_Volume__c = event1.Expected_Volume__c + 1;
		Test.startTest();
		try
		{
			update event1;
		}
		catch (System.Dmlexception e)
		{
			// Ignore -- the update is going to raise an exception because
			// the auto-submit approval process is not in place yet
		}
		Test.stopTest();

		VEM_Event__c event2 = [ SELECT Id, Name, Event_Status__c FROM VEM_Event__c WHERE Id = :event1.Id ];
		if (VEM_TestHelper.isInitialDeployment)
		{
			system.assert(true);
		}
		else
		{
			system.assert(event2.Event_Status__c == 'Pending');
		}
	}

	static testMethod void testValidateEventRecurrence()
	{
		VEM_Event__c event0 = new VEM_Event__c();
		event0.Recurrence_Type__c = 'Daily';
		event0.Recurrence_Daily_Type__c = null;
		VEM_Event__c event1 = new VEM_Event__c();
		event1.Recurrence_Type__c = 'Daily';
		event1.Recurrence_Daily_Type__c = '';
		List<VEM_Event__c> eventList1 = new List<VEM_Event__c>();
		eventList1.add(event0);
		eventList1.add(event1);

		VEM_Event__c event2 = new VEM_Event__c();
		event2.Recurrence_Type__c = 'Daily';
		event2.Recurrence_Daily_Type__c = 'Every X day(s)';
		event2.Recurrence_Days__c = null;
		List<VEM_Event__c> eventList2 = new List<VEM_Event__c>();
		eventList2.add(event2);

		VEM_Event__c event3 = new VEM_Event__c();
		event3.Recurrence_Type__c = 'Daily';
		event3.Recurrence_Daily_Type__c = 'Every X day(s)';
		event3.Recurrence_Days__c = 366;
		List<VEM_Event__c> eventList3 = new List<VEM_Event__c>();
		eventList3.add(event3);

		VEM_Event__c event4 = new VEM_Event__c();
		event4.Recurrence_Type__c = 'Daily';
		event4.Recurrence_Daily_Type__c = 'Every X day(s)';
		event4.Recurrence_Days__c = 3;
		List<VEM_Event__c> eventList4 = new List<VEM_Event__c>();
		eventList4.add(event4);

		VEM_Event__c event5 = new VEM_Event__c();
		event5.Recurrence_Type__c = 'Weekly';
		event5.Recurrence_Weeks__c = null;
		List<VEM_Event__c> eventList5 = new List<VEM_Event__c>();
		eventList5.add(event5);

		VEM_Event__c event6 = new VEM_Event__c();
		event6.Recurrence_Type__c = 'Weekly';
		event6.Recurrence_Weeks__c = -1;
		List<VEM_Event__c> eventList6 = new List<VEM_Event__c>();
		eventList6.add(event6);

		VEM_Event__c event7 = new VEM_Event__c();
		event7.Recurrence_Type__c = 'Weekly';
		event7.Recurrence_Weeks__c = 3;
		event7.Recurrence_Sunday__c = false;
		event7.Recurrence_Monday__c = false;
		event7.Recurrence_Tuesday__c = false;
		event7.Recurrence_Wednesday__c = false;
		event7.Recurrence_Thursday__c = false;
		event7.Recurrence_Friday__c = false;
		event7.Recurrence_Saturday__c = false;
		List<VEM_Event__c> eventList7 = new List<VEM_Event__c>();
		eventList7.add(event7);

		VEM_Event__c event8 = new VEM_Event__c();
		event8.Recurrence_Type__c = 'Weekly';
		event8.Recurrence_Weeks__c = 3;
		event8.Recurrence_Friday__c = true;
		List<VEM_Event__c> eventList8 = new List<VEM_Event__c>();
		eventList8.add(event8);

		VEM_Event__c event9 = new VEM_Event__c();
		event9.Recurrence_Type__c = 'Monthly';
		event9.Recurrence_Monthly_Type__c = null;
		List<VEM_Event__c> eventList9 = new List<VEM_Event__c>();
		eventList9.add(event9);

		VEM_Event__c event10 = new VEM_Event__c();
		event10.Recurrence_Type__c = 'Monthly';
		event10.Recurrence_Monthly_Type__c = '';
		List<VEM_Event__c> eventList10 = new List<VEM_Event__c>();
		eventList10.add(event10);

		VEM_Event__c event11 = new VEM_Event__c();
		event11.Recurrence_Type__c = 'Monthly';
		event11.Recurrence_Monthly_Type__c = 'Day X of every Y month(s)';
		event11.Recurrence_Day_Of_Month__c = null;
		List<VEM_Event__c> eventList11 = new List<VEM_Event__c>();
		eventList11.add(event11);

		VEM_Event__c event12 = new VEM_Event__c();
		event12.Recurrence_Type__c = 'Monthly';
		event12.Recurrence_Monthly_Type__c = 'Day X of every Y month(s)';
		event12.Recurrence_Day_Of_Month__c = 32;
		List<VEM_Event__c> eventList12 = new List<VEM_Event__c>();
		eventList12.add(event12);

		VEM_Event__c event13 = new VEM_Event__c();
		event13.Recurrence_Type__c = 'Monthly';
		event13.Recurrence_Monthly_Type__c = 'Day X of every Y month(s)';
		event13.Recurrence_Day_Of_Month__c = 21;
		event13.Recurrence_Months1__c = null;
		List<VEM_Event__c> eventList13 = new List<VEM_Event__c>();
		eventList13.add(event13);

		VEM_Event__c event14 = new VEM_Event__c();
		event14.Recurrence_Type__c = 'Monthly';
		event14.Recurrence_Monthly_Type__c = 'Day X of every Y month(s)';
		event14.Recurrence_Day_Of_Month__c = 21;
		event14.Recurrence_Months1__c = -1;
		List<VEM_Event__c> eventList14 = new List<VEM_Event__c>();
		eventList14.add(event14);

		VEM_Event__c event15 = new VEM_Event__c();
		event15.Recurrence_Type__c = 'Monthly';
		event15.Recurrence_Monthly_Type__c = 'Day X of every Y month(s)';
		event15.Recurrence_Day_Of_Month__c = 21;
		event15.Recurrence_Months1__c = 3;
		List<VEM_Event__c> eventList15 = new List<VEM_Event__c>();
		eventList15.add(event15);

		VEM_Event__c event16 = new VEM_Event__c();
		event16.Recurrence_Type__c = 'Monthly';
		event16.Recurrence_Monthly_Type__c = 'The X Y of every Z month(s)';
		event16.Recurrence_Monthly_Day_List1__c = null;
		List<VEM_Event__c> eventList16 = new List<VEM_Event__c>();
		eventList16.add(event16);

		VEM_Event__c event17 = new VEM_Event__c();
		event17.Recurrence_Type__c = 'Monthly';
		event17.Recurrence_Monthly_Type__c = 'The X Y of every Z month(s)';
		event17.Recurrence_Monthly_Day_List1__c = '';
		List<VEM_Event__c> eventList17 = new List<VEM_Event__c>();
		eventList17.add(event17);

		VEM_Event__c event18 = new VEM_Event__c();
		event18.Recurrence_Type__c = 'Monthly';
		event18.Recurrence_Monthly_Type__c = 'The X Y of every Z month(s)';
		event18.Recurrence_Monthly_Day_List1__c = 'First';
		event18.Recurrence_Monthly_Day_List2__c = null;
		List<VEM_Event__c> eventList18 = new List<VEM_Event__c>();
		eventList18.add(event18);

		VEM_Event__c event19 = new VEM_Event__c();
		event19.Recurrence_Type__c = 'Monthly';
		event19.Recurrence_Monthly_Type__c = 'The X Y of every Z month(s)';
		event19.Recurrence_Monthly_Day_List1__c = 'First';
		event19.Recurrence_Monthly_Day_List2__c = '';
		List<VEM_Event__c> eventList19 = new List<VEM_Event__c>();
		eventList19.add(event19);

		VEM_Event__c event20 = new VEM_Event__c();
		event20.Recurrence_Type__c = 'Monthly';
		event20.Recurrence_Monthly_Type__c = 'The X Y of every Z month(s)';
		event20.Recurrence_Monthly_Day_List1__c = 'First';
		event20.Recurrence_Monthly_Day_List2__c = 'Monday';
		event20.Recurrence_Months2__c = null;
		List<VEM_Event__c> eventList20 = new List<VEM_Event__c>();
		eventList20.add(event20);

		VEM_Event__c event21 = new VEM_Event__c();
		event21.Recurrence_Type__c = 'Monthly';
		event21.Recurrence_Monthly_Type__c = 'The X Y of every Z month(s)';
		event21.Recurrence_Monthly_Day_List1__c = 'First';
		event21.Recurrence_Monthly_Day_List2__c = 'Monday';
		event21.Recurrence_Months2__c = -1;
		List<VEM_Event__c> eventList21 = new List<VEM_Event__c>();
		eventList21.add(event21);

		VEM_Event__c event22 = new VEM_Event__c();
		event22.Recurrence_Type__c = 'Monthly';
		event22.Recurrence_Monthly_Type__c = 'The X Y of every Z month(s)';
		event22.Recurrence_Monthly_Day_List1__c = 'First';
		event22.Recurrence_Monthly_Day_List2__c = 'Monday';
		event22.Recurrence_Months2__c = 3;
		List<VEM_Event__c> eventList22 = new List<VEM_Event__c>();
		eventList22.add(event22);

		VEM_Event__c event23 = new VEM_Event__c();
		event23.Recurrence_Type__c = 'Yearly';
		event23.Recurrence_Yearly_Type__c = null;
		List<VEM_Event__c> eventList23 = new List<VEM_Event__c>();
		eventList23.add(event23);

		VEM_Event__c event24 = new VEM_Event__c();
		event24.Recurrence_Type__c = 'Yearly';
		event24.Recurrence_Yearly_Type__c = null;
		List<VEM_Event__c> eventList24 = new List<VEM_Event__c>();
		eventList24.add(event24);

		VEM_Event__c event25 = new VEM_Event__c();
		event25.Recurrence_Type__c = 'Yearly';
		event25.Recurrence_Yearly_Type__c = 'Every X Y';
		event25.Recurrence_Yearly_Month_List1__c = null;
		List<VEM_Event__c> eventList25 = new List<VEM_Event__c>();
		eventList25.add(event25);

		VEM_Event__c event26 = new VEM_Event__c();
		event26.Recurrence_Type__c = 'Yearly';
		event26.Recurrence_Yearly_Type__c = 'Every X Y';
		event26.Recurrence_Yearly_Month_List1__c = '';
		List<VEM_Event__c> eventList26 = new List<VEM_Event__c>();
		eventList26.add(event26);

		VEM_Event__c event27 = new VEM_Event__c();
		event27.Recurrence_Type__c = 'Yearly';
		event27.Recurrence_Yearly_Type__c = 'Every X Y';
		event27.Recurrence_Yearly_Month_List1__c = 'July';
		event27.Recurrence_Yearly_Day__c = null;
		List<VEM_Event__c> eventList27 = new List<VEM_Event__c>();
		eventList27.add(event27);

		VEM_Event__c event28 = new VEM_Event__c();
		event28.Recurrence_Type__c = 'Yearly';
		event28.Recurrence_Yearly_Type__c = 'Every X Y';
		event28.Recurrence_Yearly_Month_List1__c = 'July';
		event28.Recurrence_Yearly_Day__c = 32;
		List<VEM_Event__c> eventList28 = new List<VEM_Event__c>();
		eventList28.add(event28);

		VEM_Event__c event29 = new VEM_Event__c();
		event29.Recurrence_Type__c = 'Yearly';
		event29.Recurrence_Yearly_Type__c = 'Every X Y';
		event29.Recurrence_Yearly_Month_List1__c = 'July';
		event29.Recurrence_Yearly_Day__c = 17;
		List<VEM_Event__c> eventList29 = new List<VEM_Event__c>();
		eventList29.add(event29);

		VEM_Event__c event30 = new VEM_Event__c();
		event30.Recurrence_Type__c = 'Yearly';
		event30.Recurrence_Yearly_Type__c = 'The X Y of Z';
		event30.Recurrence_Yearly_Day_List1__c = null;
		List<VEM_Event__c> eventList30 = new List<VEM_Event__c>();
		eventList30.add(event30);

		VEM_Event__c event31 = new VEM_Event__c();
		event31.Recurrence_Type__c = 'Yearly';
		event31.Recurrence_Yearly_Type__c = 'The X Y of Z';
		event31.Recurrence_Yearly_Day_List1__c = '';
		List<VEM_Event__c> eventList31 = new List<VEM_Event__c>();
		eventList31.add(event31);

		VEM_Event__c event32 = new VEM_Event__c();
		event32.Recurrence_Type__c = 'Yearly';
		event32.Recurrence_Yearly_Type__c = 'The X Y of Z';
		event32.Recurrence_Yearly_Day_List1__c = 'Third';
		event32.Recurrence_Yearly_Day_List2__c = null;
		List<VEM_Event__c> eventList32 = new List<VEM_Event__c>();
		eventList32.add(event32);

		VEM_Event__c event33 = new VEM_Event__c();
		event33.Recurrence_Type__c = 'Yearly';
		event33.Recurrence_Yearly_Type__c = 'The X Y of Z';
		event33.Recurrence_Yearly_Day_List1__c = 'Third';
		event33.Recurrence_Yearly_Day_List2__c = '';
		List<VEM_Event__c> eventList33 = new List<VEM_Event__c>();
		eventList33.add(event33);

		VEM_Event__c event34 = new VEM_Event__c();
		event34.Recurrence_Type__c = 'Yearly';
		event34.Recurrence_Yearly_Type__c = 'The X Y of Z';
		event34.Recurrence_Yearly_Day_List1__c = 'Third';
		event34.Recurrence_Yearly_Day_List2__c = 'Saturday';
		List<VEM_Event__c> eventList34 = new List<VEM_Event__c>();
		eventList34.add(event34);

		VEM_Event__c event35 = new VEM_Event__c();
		event35.Recurrence_Type__c = 'Yearly';
		event35.Recurrence_Yearly_Type__c = 'The X Y of Z';
		event35.Recurrence_Yearly_Day_List1__c = 'Third';
		event35.Recurrence_Yearly_Day_List2__c = 'Saturday';
		event35.Recurrence_Yearly_Month_List2__c = null;
		List<VEM_Event__c> eventList35 = new List<VEM_Event__c>();
		eventList35.add(event35);

		VEM_Event__c event36 = new VEM_Event__c();
		event36.Recurrence_Type__c = 'Yearly';
		event36.Recurrence_Yearly_Type__c = 'The X Y of Z';
		event36.Recurrence_Yearly_Day_List1__c = 'Third';
		event36.Recurrence_Yearly_Day_List2__c = 'Saturday';
		event36.Recurrence_Yearly_Month_List2__c = '';
		List<VEM_Event__c> eventList36 = new List<VEM_Event__c>();
		eventList36.add(event36);

		VEM_Event__c event37 = new VEM_Event__c();
		event37.Recurrence_Type__c = 'Yearly';
		event37.Recurrence_Yearly_Type__c = 'The X Y of Z';
		event37.Recurrence_Yearly_Day_List1__c = 'Third';
		event37.Recurrence_Yearly_Day_List2__c = 'Saturday';
		event37.Recurrence_Yearly_Month_List2__c = 'November';
		List<VEM_Event__c> eventList37 = new List<VEM_Event__c>();
		eventList37.add(event37);

		VEM_Event__c event38 = new VEM_Event__c();
		event38.Start_Date__c = Date.today().addDays(100);
		event38.Recurrence_Type__c = 'Daily';
		event38.Recurrence_Daily_Type__c = 'Every X day(s)';
		event38.Recurrence_Days__c = 1;
		event38.Recurrence_Start_Date__c = event38.Start_Date__c.addDays(-1);
		List<VEM_Event__c> eventList38 = new List<VEM_Event__c>();
		eventList38.add(event38);

		VEM_Event__c event39 = new VEM_Event__c();
		event39.Start_Date__c = Date.today().addDays(100);
		event39.Recurrence_Type__c = 'Daily';
		event39.Recurrence_Daily_Type__c = 'Every X day(s)';
		event39.Recurrence_Days__c = 1;
		event39.Recurrence_Start_Date__c = event39.Start_Date__c;
		event39.Recurrence_End_Date__c = event39.Recurrence_Start_Date__c.addDays(-1);
		List<VEM_Event__c> eventList39 = new List<VEM_Event__c>();
		eventList39.add(event39);

		Test.startTest();
		Boolean result1 = VEM_Event.validateEventRecurrence(eventList1);
		Boolean result2 = VEM_Event.validateEventRecurrence(eventList2);
		Boolean result3 = VEM_Event.validateEventRecurrence(eventList3);
		Boolean result4 = VEM_Event.validateEventRecurrence(eventList4);
		Boolean result5 = VEM_Event.validateEventRecurrence(eventList5);
		Boolean result6 = VEM_Event.validateEventRecurrence(eventList6);
		Boolean result7 = VEM_Event.validateEventRecurrence(eventList7);
		Boolean result8 = VEM_Event.validateEventRecurrence(eventList8);
		Boolean result9 = VEM_Event.validateEventRecurrence(eventList9);
		Boolean result10 = VEM_Event.validateEventRecurrence(eventList10);
		Boolean result11 = VEM_Event.validateEventRecurrence(eventList11);
		Boolean result12 = VEM_Event.validateEventRecurrence(eventList12);
		Boolean result13 = VEM_Event.validateEventRecurrence(eventList13);
		Boolean result14 = VEM_Event.validateEventRecurrence(eventList14);
		Boolean result15 = VEM_Event.validateEventRecurrence(eventList15);
		Boolean result16 = VEM_Event.validateEventRecurrence(eventList16);
		Boolean result17 = VEM_Event.validateEventRecurrence(eventList17);
		Boolean result18 = VEM_Event.validateEventRecurrence(eventList18);
		Boolean result19 = VEM_Event.validateEventRecurrence(eventList19);
		Boolean result20 = VEM_Event.validateEventRecurrence(eventList20);
		Boolean result21 = VEM_Event.validateEventRecurrence(eventList21);
		Boolean result22 = VEM_Event.validateEventRecurrence(eventList22);
		Boolean result23 = VEM_Event.validateEventRecurrence(eventList23);
		Boolean result24 = VEM_Event.validateEventRecurrence(eventList24);
		Boolean result25 = VEM_Event.validateEventRecurrence(eventList25);
		Boolean result26 = VEM_Event.validateEventRecurrence(eventList26);
		Boolean result27 = VEM_Event.validateEventRecurrence(eventList27);
		Boolean result28 = VEM_Event.validateEventRecurrence(eventList28);
		Boolean result29 = VEM_Event.validateEventRecurrence(eventList29);
		Boolean result30 = VEM_Event.validateEventRecurrence(eventList30);
		Boolean result31 = VEM_Event.validateEventRecurrence(eventList31);
		Boolean result32 = VEM_Event.validateEventRecurrence(eventList32);
		Boolean result33 = VEM_Event.validateEventRecurrence(eventList33);
		Boolean result34 = VEM_Event.validateEventRecurrence(eventList34);
		Boolean result35 = VEM_Event.validateEventRecurrence(eventList35);
		Boolean result36 = VEM_Event.validateEventRecurrence(eventList36);
		Boolean result37 = VEM_Event.validateEventRecurrence(eventList37);
		Boolean result38 = VEM_Event.validateEventRecurrence(eventList38);
		Boolean result39 = VEM_Event.validateEventRecurrence(eventList39);
		Test.stopTest();

		system.assert(!result1);
		system.assert(!result2);
		system.assert(!result3);
		system.assert(result4);
		system.assert(!result5);
		system.assert(!result6);
		system.assert(!result7);
		system.assert(result8);
		system.assert(!result9);
		system.assert(!result10);
		system.assert(!result11);
		system.assert(!result12);
		system.assert(!result13);
		system.assert(!result14);
		system.assert(result15);
		system.assert(!result16);
		system.assert(!result17);
		system.assert(!result18);
		system.assert(!result19);
		system.assert(!result20);
		system.assert(!result21);
		system.assert(result22);
		system.assert(!result23);
		system.assert(!result24);
		system.assert(!result25);
		system.assert(!result26);
		system.assert(!result27);
		system.assert(!result28);
		system.assert(result29);
		system.assert(!result30);
		system.assert(!result31);
		system.assert(!result32);
		system.assert(!result33);
		system.assert(!result34);
		system.assert(!result35);
		system.assert(!result36);
		system.assert(result37);
		system.assert(!result38);
		system.assert(!result39);
	}

	static testMethod void testClearUnselectedRecurrenceOptions()
	{
		VEM_Event__c event1 = new VEM_Event__c();
		event1.Recurrence_Type__c = 'Daily';
		event1.Recurrence_Daily_Type__c = 'Every X day(s)';

		VEM_Event__c event2 = new VEM_Event__c();
		event2.Recurrence_Type__c = 'Daily';
		event2.Recurrence_Daily_Type__c = 'Every weekday';

		VEM_Event__c event3 = new VEM_Event__c();
		event3.Recurrence_Type__c = 'Weekly';

		VEM_Event__c event4 = new VEM_Event__c();
		event4.Recurrence_Type__c = 'Monthly';
		event4.Recurrence_Monthly_Type__c = 'Day X of every Y month(s)';

		VEM_Event__c event5 = new VEM_Event__c();
		event5.Recurrence_Type__c = 'Monthly';
		event5.Recurrence_Monthly_Type__c = 'The X Y of every Z month(s)';

		VEM_Event__c event6 = new VEM_Event__c();
		event6.Recurrence_Type__c = 'Yearly';
		event6.Recurrence_Yearly_Type__c = 'Every X Y';

		VEM_Event__c event7 = new VEM_Event__c();
		event7.Recurrence_Type__c = 'Yearly';
		event7.Recurrence_Yearly_Type__c = 'The X Y of Z';

		List<VEM_Event__c> eventList = new List<VEM_Event__c>();
		eventList.add(event1);
		eventList.add(event2);
		eventList.add(event3);
		eventList.add(event4);
		eventList.add(event5);
		eventList.add(event6);
		eventList.add(event7);

		Test.startTest();
		VEM_Event.clearUnselectedRecurrenceOptions(eventList);
		Test.stopTest();
		
		system.assert(true);
	}

	static testMethod void testAddRecurringEvents1()
	{
		List<VEM_Event__c> eventList = new List<VEM_Event__c>();

		VEM_Event__c event1 = TestEvent1.clone(false);
		event1.Start_Date__c = Date.today().addDays(500);
		event1.Start_Time__c = '1:00 AM';
		event1.Start_Date_Time__c = VEM_Event.toDatetime(event1.Start_Date__c, event1.Start_Time__c, false);
		event1.End_Date__c = event1.Start_Date__c;
		event1.End_Time__c = '2:00 AM';
		event1.End_Date_Time__c = VEM_Event.toDatetime(event1.End_Date__c, event1.End_Time__c, false);
		event1.Recurrence_Type__c = 'Daily';
		event1.Recurrence_Daily_Type__c = 'Every X day(s)';
		event1.Recurrence_Days__c = 1;
		event1.Recurrence_Start_Date__c = event1.Start_Date__c;
		event1.Recurrence_End_Date__c = event1.Start_Date__c.addDays(2);
		eventList.add(event1);

		VEM_Event__c event2 = TestEvent1.clone(false);
		event2.Start_Date__c = Date.today().addDays(510);
		event2.Start_Time__c = '1:00 AM';
		event2.Start_Date_Time__c = VEM_Event.toDatetime(event2.Start_Date__c, event2.Start_Time__c, false);
		event2.End_Date__c = event2.Start_Date__c;
		event2.End_Time__c = '2:00 AM';
		event2.End_Date_Time__c = VEM_Event.toDatetime(event2.End_Date__c, event2.End_Time__c, false);
		event2.Recurrence_Type__c = 'Daily';
		event2.Recurrence_Daily_Type__c = 'Every weekday';
		event2.Recurrence_Start_Date__c = event2.Start_Date__c;
		event2.Recurrence_End_Date__c = event2.Start_Date__c.addDays(3);
		eventList.add(event2);

		Test.startTest();
		VEM_Event.addRecurringEvents(eventList);
		Test.stopTest();

		System.assert(true);
	}

	static testMethod void testAddRecurringEvents2()
	{
		List<VEM_Event__c> eventList = new List<VEM_Event__c>();

		VEM_Event__c event3 = TestEvent1.clone(false);
		event3.Start_Date__c = Date.today().addDays(520);
		event3.Start_Time__c = '1:00 AM';
		event3.Start_Date_Time__c = VEM_Event.toDatetime(event3.Start_Date__c, event3.Start_Time__c, false);
		event3.End_Date__c = event3.Start_Date__c;
		event3.End_Time__c = '2:00 AM';
		event3.End_Date_Time__c = VEM_Event.toDatetime(event3.End_Date__c, event3.End_Time__c, false);
		event3.Recurrence_Type__c = 'Weekly';
		event3.Recurrence_Weeks__c = 1;
		event3.Recurrence_Friday__c = true;
		event3.Recurrence_Start_Date__c = event3.Start_Date__c;
		event3.Recurrence_End_Date__c = event3.Start_Date__c.addDays(15);
		eventList.add(event3);

		VEM_Event__c event4 = TestEvent1.clone(false);
		event4.Start_Date__c = Date.today().addDays(530);
		event4.Start_Time__c = '1:00 AM';
		event4.Start_Date_Time__c = VEM_Event.toDatetime(event4.Start_Date__c, event4.Start_Time__c, false);
		event4.End_Date__c = event4.Start_Date__c;
		event4.End_Time__c = '2:00 AM';
		event4.End_Date_Time__c = VEM_Event.toDatetime(event4.End_Date__c, event4.End_Time__c, false);
		event4.Recurrence_Type__c = 'Monthly';
		event4.Recurrence_Monthly_Type__c = 'Day X of every Y month(s)';
		event4.Recurrence_Day_Of_Month__c = 27;
		event4.Recurrence_Months1__c = 1;
		event4.Recurrence_Start_Date__c = event4.Start_Date__c;
		event4.Recurrence_End_Date__c = event4.Start_Date__c.addDays(60);
		eventList.add(event4);

		VEM_Event__c event5 = TestEvent1.clone(false);
		event5.Start_Date__c = Date.today().addDays(600);
		event5.Start_Time__c = '1:00 AM';
		event5.Start_Date_Time__c = VEM_Event.toDatetime(event5.Start_Date__c, event5.Start_Time__c, false);
		event5.End_Date__c = event5.Start_Date__c;
		event5.End_Time__c = '2:00 AM';
		event5.End_Date_Time__c = VEM_Event.toDatetime(event5.End_Date__c, event5.End_Time__c, false);
		event5.Recurrence_Type__c = 'Monthly';
		event5.Recurrence_Monthly_Type__c = 'The X Y of every Z month(s)';
		event5.Recurrence_Monthly_Day_List1__c = 'Last';
		event5.Recurrence_Monthly_Day_List2__c = 'Day';
		event5.Recurrence_Months2__c = 1;
		event5.Recurrence_Start_Date__c = event5.Start_Date__c;
		event5.Recurrence_End_Date__c = event5.Start_Date__c.addDays(60);
		eventList.add(event5);

		VEM_Event__c event6 = TestEvent1.clone(false);
		event6.Start_Date__c = Date.today().addDays(700);
		event6.Start_Time__c = '1:00 AM';
		event6.Start_Date_Time__c = VEM_Event.toDatetime(event6.Start_Date__c, event6.Start_Time__c, false);
		event6.End_Date__c = event6.Start_Date__c;
		event6.End_Time__c = '2:00 AM';
		event6.End_Date_Time__c = VEM_Event.toDatetime(event6.End_Date__c, event6.End_Time__c, false);
		event6.Recurrence_Type__c = 'Yearly';
		event6.Recurrence_Yearly_Type__c = 'Every X Y';
		event6.Recurrence_Yearly_Month_List1__c = 'January';
		event6.Recurrence_Yearly_Day__c = 1;
		event6.Recurrence_Start_Date__c = event6.Start_Date__c;
		event6.Recurrence_End_Date__c = event6.Start_Date__c.addDays(370);
		eventList.add(event6);

		VEM_Event__c event7 = TestEvent1.clone(false);
		event7.Start_Date__c = Date.today().addDays(1100);
		event7.Start_Time__c = '1:00 AM';
		event7.Start_Date_Time__c = VEM_Event.toDatetime(event7.Start_Date__c, event7.Start_Time__c, false);
		event7.End_Date__c = event7.Start_Date__c;
		event7.End_Time__c = '2:00 AM';
		event7.End_Date_Time__c = VEM_Event.toDatetime(event7.End_Date__c, event7.End_Time__c, false);
		event7.Recurrence_Type__c = 'Yearly';
		event7.Recurrence_Yearly_Type__c = 'The X Y of Z';
		event7.Recurrence_Yearly_Day_List1__c = 'First';
		event7.Recurrence_Yearly_Day_List2__c = 'Day';
		event7.Recurrence_Yearly_Month_List2__c = 'January';
		event7.Recurrence_Start_Date__c = event7.Start_Date__c;
		event7.Recurrence_End_Date__c = event7.Start_Date__c.addDays(370);
		eventList.add(event7);

		Test.startTest();
		VEM_Event.addRecurringEvents(eventList);
		Test.stopTest();

		System.assert(true);
	}

	static testMethod void testRemoveRecurringEvents()
	{
		List<VEM_Event__c> eventList = new List<VEM_Event__c>();

		VEM_Event__c event1 = TestEvent1.clone(false);
		event1.Start_Date__c = Date.today().addDays(500);
		event1.Start_Time__c = '4:00 AM';
		event1.Start_Date_Time__c = VEM_Event.toDatetime(event1.Start_Date__c, event1.Start_Time__c, false);
		event1.End_Date__c = event1.Start_Date__c;
		event1.End_Time__c = '5:00 AM';
		event1.End_Date_Time__c = VEM_Event.toDatetime(event1.End_Date__c, event1.End_Time__c, false);
		event1.Recurrence_Type__c = 'Daily';
		event1.Recurrence_Daily_Type__c = 'Every X day(s)';
		event1.Recurrence_Days__c = 1;
		event1.Recurrence_Start_Date__c = event1.Start_Date__c;
		event1.Recurrence_End_Date__c = event1.Start_Date__c.addDays(2);
		insert event1;

		eventList.add(event1);

		Test.startTest();
		VEM_Event.removeRecurringEvents(eventList);
		Test.stopTest();

		System.assert(true);
	}

	static testMethod void testIsWeekday()
	{
		Test.startTest();
		Boolean result1 = VEM_Event.isWeekday(Date.parse('12/25/2020'));
		Boolean result2 = VEM_Event.isWeekday(Date.parse('12/26/2020'));
		Boolean result3 = VEM_Event.isWeekday(Datetime.parse('12/27/2020 3:00 PM'));
		Boolean result4 = VEM_Event.isWeekday(Datetime.parse('12/28/2020 3:00 PM'));
		Test.stopTest();

		System.assert(result1);
		System.assert(!result2);
		System.assert(!result3);
		System.assert(result4);
	}

	static testMethod void testSelectedDate()
	{
		Test.startTest();
		Date date1 = VEM_Event.selectedDate('First', 'Day', Date.parse('1/20/2020'));
		Date date2 = VEM_Event.selectedDate('Second', 'Day', Date.parse('1/20/2020'));
		Date date3 = VEM_Event.selectedDate('Third', 'Day', Date.parse('1/20/2020'));
		Date date4 = VEM_Event.selectedDate('Fourth', 'Day', Date.parse('1/20/2020'));
		Date date5 = VEM_Event.selectedDate('Last', 'Day', Date.parse('1/20/2020'));
		Date date6 = VEM_Event.selectedDate('First', 'Sunday', Date.parse('1/20/2020'));
		Date date7 = VEM_Event.selectedDate('Second', 'Monday', Date.parse('1/20/2020'));
		Date date8 = VEM_Event.selectedDate('Third', 'Tuesday', Date.parse('1/20/2020'));
		Date date9 = VEM_Event.selectedDate('Fourth', 'Wednesday', Date.parse('1/20/2020'));
		Date date10 = VEM_Event.selectedDate('Last', 'Thursday', Date.parse('1/20/2020'));
		Test.stopTest();

		System.assert(date1 == Date.parse('1/1/2020'));
		System.assert(date2 == Date.parse('1/2/2020'));
		System.assert(date3 == Date.parse('1/3/2020'));
		System.assert(date4 == Date.parse('1/4/2020'));
		System.assert(date5 == Date.parse('1/31/2020'));
		System.assert(date6 == Date.parse('1/5/2020'));
		System.assert(date7 == Date.parse('1/13/2020'));
		System.assert(date8 == Date.parse('1/21/2020'));
		System.assert(date9 == Date.parse('1/22/2020'));
		System.assert(date10 == Date.parse('1/30/2020'));
	}

	static testMethod void testMonthValueOf()
	{
		Test.startTest();
		Integer int1 = VEM_Event.monthValueOf('January');
		Integer int2 = VEM_Event.monthValueOf('February');
		Integer int3 = VEM_Event.monthValueOf('March');
		Integer int4 = VEM_Event.monthValueOf('April');
		Integer int5 = VEM_Event.monthValueOf('May');
		Integer int6 = VEM_Event.monthValueOf('June');
		Integer int7 = VEM_Event.monthValueOf('July');
		Integer int8 = VEM_Event.monthValueOf('August');
		Integer int9 = VEM_Event.monthValueOf('September');
		Integer int10 = VEM_Event.monthValueOf('October');
		Integer int11 = VEM_Event.monthValueOf('November');
		Integer int12 = VEM_Event.monthValueOf('December');
		Test.stopTest();

		System.assert(int1 == 1);
		System.assert(int2 == 2);
		System.assert(int3 == 3);
		System.assert(int4 == 4);
		System.assert(int5 == 5);
		System.assert(int6 == 6);
		System.assert(int7 == 7);
		System.assert(int8 == 8);
		System.assert(int9 == 9);
		System.assert(int10 == 10);
		System.assert(int11 == 11);
		System.assert(int12 == 12);
	}

}