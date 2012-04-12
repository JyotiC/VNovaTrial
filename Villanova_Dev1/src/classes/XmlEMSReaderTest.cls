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
private class XmlEMSReaderTest {

	static testMethod void testCallEMSApi()
	{
		Test.startTest();
		Integer counter = XmlEMSReader.callEmsApi('emsapiuser', 'salesforce', Datetime.newInstance(2012, 1, 6), Datetime.newInstance(2012, 1, 9), 1, 50);
		Test.stopTest();
	}

	static testMethod void testGetEMSData()
	{
		String res =
			'<Bookings>'+
				'<Data>'+
					'<BookingDate>2012-01-06T00:00:00-05:00</BookingDate>'+
					'<StartBookingDate>2012-01-06T00:00:00-05:00</StartBookingDate>'+
					'<RoomDescription>St. Mary\'s Gym</RoomDescription>'+
					'<TimeEventStart>2012-01-06T16:00:00-05:00</TimeEventStart>'+
					'<TimeEventEnd>2012-01-06T19:00:00-05:00</TimeEventEnd>'+
					'<GroupName>Cheerleading</GroupName>'+
					'<EventName>Cheerleading Practice</EventName>'+
					'<SetupTypeDescription>(none)</SetupTypeDescription>'+
					'<SetupCount>0</SetupCount>'+
					'<ReservationID>5765</ReservationID>'+
					'<EventCoordinator />'+
					'<GroupID>26</GroupID>'+
					'<VIP xml:space="preserve"> </VIP>'+
					'<VIPEvent>false</VIPEvent>'+
					'<ClosedAllDay>false</ClosedAllDay>'+
					'<OpenTime>1900-01-01T00:00:00-05:00</OpenTime>'+
					'<CloseTime>1900-01-01T00:00:00-05:00</CloseTime>'+
					'<GroupTypeDescription>(none)</GroupTypeDescription>'+
					'<EventTypeDescription>Athletic Group</EventTypeDescription>'+
					'<Contact>Phil O\'Neil 8-2058</Contact>'+
					'<AltContact />'+
					'<BookingID>70255</BookingID>'+
					'<TimeBookingStart>2012-01-06T16:00:00-05:00</TimeBookingStart>'+
					'<TimeBookingEnd>2012-01-06T19:00:00-05:00</TimeBookingEnd>'+
					'<GMTStartTime>2012-01-06T16:00:00-05:00</GMTStartTime>'+
					'<GMTEndTime>2012-01-06T19:00:00-05:00</GMTEndTime>'+
					'<BuildingCode>SM</BuildingCode>'+
					'<Building>St. Marytest\'s</Building>'+
					'<RoomCode>St. Marytest\'s</RoomCode>'+
					'<Room>St. Mary\'s Gym</Room>'+
					'<RoomID>13</RoomID>'+
					'<BuildingID>10</BuildingID>'+
					'<StatusID>1</StatusID>'+
					'<StatusTypeID>-14</StatusTypeID>'+
					'<EventTypeID>42</EventTypeID>'+
					'<GroupTypeID>0</GroupTypeID>'+
					'<DateAdded>2011-08-26T13:26:36.127-04:00</DateAdded>'+
					'<AddedBy>Liz Masucci</AddedBy>'+
					'<DateChanged>2012-01-06T10:25:47.473-05:00</DateChanged>'+
					'<ChangedBy>Liz Masucci</ChangedBy>'+
				'</Data>'+
			'</Bookings>';

		Test.startTest();
		Integer counter = XmlEMSReader.getEMSData(res);
		Test.stopTest();
	}

	/*static testMethod void processEMSApitest()
	{
		VEMCallEMSWebService.ServiceSoap s = new VEMCallEMSWebService.ServiceSoap();
		String result = s.GetBookings('emsapiuser', 'salesforce', Datetime.newInstance(2012, 1, 6), Datetime.newInstance(2012, 1, 9), null, null, null, null, false);
		
		test.startTest();
		XmlEMSReader.getEMSData(res );
		test.stopTest();
	}*/

}