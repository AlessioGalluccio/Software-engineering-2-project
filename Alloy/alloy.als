// Signature for a generic String code
sig StringCode{}

// Every User of the system
abstract sig User {
	password: one StringCode,
}

// End Users of the application
sig EndUser extends User{
	issuedReport: set Report,
	id: one FiscalCode
}

// Authority Users
sig AuthorityUser extends User{
	id: one AuthorizedCode
}

// System Managers
sig SystemManager extends User{}

// Signature for a generic Identifier
abstract sig ID{
	code: one StringCode
}

// Fiscal Code used by End Users
sig FiscalCode extends ID{}

// Authorized Code used by Authority Users and System Managers
sig AuthorizedCode extends ID{}

// Location registered by the GPS of the smartphone of a End User
sig Location{
	latitude: one Int,
	longitude: one Int
}

// Photo added to a Report
sig Photo{
	report: one Report,
	containsVehicles: set Vehicle
}

//Time registered when the End User makes the Photo for the Report. For simplicity, we use Int for the timestamp
sig Time{
	timestamp: one Int
}{
	timestamp >= 0
}

// License Plate of a vehicle
sig LicensePlate{
	vehicle: one Vehicle
}

// Owner of a Vehicle
sig Owner{
	vehicle: some Vehicle
}

sig Vehicle{
	licensePlate: one LicensePlate,
	owner: one Owner
}

//Report made by the End User and sent to the system
sig Report{
	location: one Location,
	photo: one Photo,
	vehicles: some Vehicle,
	offender: some Owner,
	ticket: lone TicketList,
	time: one Time
}

// Set of Tickets generated for a Report
sig TicketList{
	// generated by only one Authority user
	givenBy: one AuthorityUser,
	// but given to one or more Owners
	givenTo: some Owner
}


// No different users have the same ID
fact uniqueID{
	no disj user1, user2: EndUser | user1.id = user2.id
	no disj user1, user2: AuthorityUser + SystemManager | user1.id = user2.id
	no disj id1, id2: ID | id1.code = id2.code
}

// No different Vehicles have the same License Plate
// No different License Plates have the same Vehicle
// If a vehicle has a License Plate, the License Plate is registered with that Vehicle
fact uniqueLicensePlate{
	no disj v1, v2: Vehicle | v1.licensePlate = v2.licensePlate
	no disj l1, l2: LicensePlate | l1.vehicle = l2.vehicle
	all v1 : Vehicle, l1: LicensePlate |  ((l1 = v1.licensePlate) <=> (l1.vehicle = v1))
}

// If a Report has a Photo, that Photo has that report as Report
// All the vehicles of the Report are the same of the pPhoto
fact consistencyPhotoAndReport{
	all p1 : Photo, r1: Report |  ((p1 = r1.photo) <=> (r1 = p1.report))
	all p1: Photo, r1: Report | (p1 = r1.photo) implies (p1.containsVehicles = r1.vehicles)
}

// Different Owners can't have the same Vehicle
fact uniqueOwner{
	no disj o1, o2: Owner | o1.vehicle = o2.vehicle
}

// Different End Users can't generate the same Report
fact uniqueAuthorReport{
	no disj e1, e2: EndUser | e1.issuedReport = e2.issuedReport
}


// Ticket must be given to an Offender of a Report
fact consistencyTicketReport{
	all t1: TicketList | (some r1: Report | (r1.ticket in t1) implies (t1.givenTo in r1.offender)) 
}

// Two Reports can't have the same TicketList
fact twoReportsCantHaveSameTicket{
	no disj r1,r2 : Report | r1.ticket = r2.ticket
}

// There can't be Time, Location or Photo without a Report
fact allTimeLocationPhotoHaveReport{
	all t1: Time | (some r1: Report | r1.time = t1)
	all l1: Location | (some r1: Report | r1.location = l1)
	all p1: Photo | (some r1: Report | r1.photo = p1)
}


// No Ticket must be generated if they are not given to someone
pred noTicketHasNoOffender{
	no t1: TicketList | #(t1.givenTo) = 0
	#TicketList > 0
	#givenTo > 0
} 
run noTicketHasNoOffender for 2

// There can be a situation where there are Reports, but the Authority users haven't still generated the Tickets
pred ticketsNotAlreadyGenerated{
	#TicketList = 0
	#offender > 0
}
run ticketsNotAlreadyGenerated for 3


// If no Vehicles are specified by the End User in the Photo, a Report can't be made
pred noReportIfNoVehicleInPhoto{
	#(Photo.vehicle) = 0 implies #Report = 0
}
run noReportIfNoVehicleInPhoto for 4
