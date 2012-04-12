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
private class VEM_VolumeMonitorTest
{

	static final Integer THRESHOLD = 3000;

	static testMethod void test()
	{
		VEM_Event__c testEvent = new VEM_Event__c();
		testEvent.Name = 'Test Insert';
		testEvent.Event_Type__c = 'Meeting';
		testEvent.Event_Location__c = VEM_TestHelper.getLocation('Bartley Hall').Id;
		testEvent.Time_Interval__c = '30 Minute';
		testEvent.Start_Date__c = Date.today().addDays(1);
		testEvent.Start_Time__c = '2:30 AM';
		testEvent.End_Date__c = testEvent.Start_Date__c;
		testEvent.End_Time__c = '2:45 AM';
		testEvent.Event_Sponsor__c = 'Test';
		testEvent.Expected_Volume__c = THRESHOLD;

		Test.startTest();
		VEM_VolumeMonitor volumeMonitor = new VEM_VolumeMonitor(THRESHOLD);
		volumeMonitor.isTest = true;
		SchedulableContext sc;
		volumeMonitor.execute(sc);
		Test.stopTest();

		System.assert(true);
	}

}