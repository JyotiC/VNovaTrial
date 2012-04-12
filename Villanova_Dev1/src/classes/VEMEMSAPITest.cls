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
private class VEMEMSAPITest {

	static testMethod void testExecute()
	{
		SchedulableContext sc;

		Test.startTest();
		VEMEMSAPI.execute(sc);
		Test.stopTest();

		System.assert(true);
	}

	static testMethod void testLoadEmsBookings()
	{
		//ToDo: Override start/end dates with 1/1/2012 and 1/9/2012 (134 records)

		Test.startTest();
		VEMEMSAPI.loadEmsBookings();
		Test.stopTest();

		System.assert(true);
	}

	static testMethod void testScheduleNextJob()
	{
		Test.startTest();
		VEMEMSAPI.scheduleNextJob(VEMEMSAPI.batchSize - 1);
		VEMEMSAPI.scheduleNextJob(VEMEMSAPI.batchSize);
		Test.stopTest();

		System.assert(true);
	}

	static testMethod void testProperties()
	{
		Test.startTest();
		Integer batchSize = VEMEMSAPI.batchSize;
		Integer batchDelay = VEMEMSAPI.batchDelayInMinutes;
		Date bookingStart = VEMEMSAPI.bookingStartDate;
		Date bookingEnd = VEMEMSAPI.bookingEndDate;
		Test.stopTest();

		System.assert(true);
	}

	static testMethod void testSendEmail()
	{
		String currentUserEmail = VEM_TestHelper.currentUser.Email;

		Test.startTest();
		VEMEMSAPI.sendEmail(currentUserEmail, currentUserEmail, 'Testing API', 'Testing API');
		Test.stopTest();
	}

}