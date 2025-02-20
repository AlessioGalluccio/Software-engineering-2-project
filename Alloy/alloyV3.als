//signature for a generic String code
sig StringCode{}

abstract sig User {
	password: one StringCode,
}

sig EndUser extends User{
	issuedReport: set Report,
	id: one FiscalCode
}

sig AuthorityUser extends User{
	id: one AuthorizedCode
}

sig SystemManager extends User{}

abstract sig ID{
	code: one StringCode
}

sig FiscalCode extends ID{}

sig AuthorizedCode extends ID{}

sig Location{
	latitude: one Int,
	longitude: one Int
}

sig Photo{
	report: one Report,
	containsVehicles: set Vehicle
}

sig LicensePlate{
	vehicle: one Vehicle
}

sig Owner{
	vehicle: some Vehicle
}

sig Vehicle{
	licensePlate: one LicensePlate,
	owner: one Owner
}


sig Report{
	location: one Location,
	photo: one Photo,
	vehicles: some Vehicle,
	offender: some Owner,
	ticket: lone Ticket
}

sig Ticket{
	givenBy: one AuthorityUser,
	givenTo: set Owner
}{
	#givenTo >= 1
}


//No different users have the same ID
fact uniqueID{
	no disj user1, user2: EndUser | user1.id = user2.id
	no disj user1, user2: AuthorityUser | user1.id = user2.id
	no disj id1, id2: ID | id1.code = id2.code
}

//no different vehicles have the same License Plate
//no different License Plates have the same vehicle
//if a vehicle has a license plate, the license plate is registered with that vehicle
fact uniqueLicensePlate{
	no disj v1, v2: Vehicle | v1.licensePlate = v2.licensePlate
	no disj l1, l2: LicensePlate | l1.vehicle = l2.vehicle
	all v1 : Vehicle, l1: LicensePlate |  ((l1 = v1.licensePlate) <=> (l1.vehicle = v1))
}

//if a report has a photo, that photo has that report as report
//all the vehicles of the report are the same of the photo
fact consistencyPhotoAndReport{
	all p1 : Photo, r1: Report |  ((p1 = r1.photo) <=> (r1 = p1.report))
	all p1: Photo, r1: Report | (p1 = r1.photo) implies (p1.containsVehicles = r1.vehicles)

//	all p1: Photo, r1: Report | 
//		(r1.photo = p1) => some v1, v2: Vehicle |
//							((v1 = p1.vehicle && v2 = r1.vehicle) => (v1 = v2))
}

//different owners can't have the same vehicle
fact uniqueOwner{
	no disj o1, o2: Owner | o1.vehicle = o2.vehicle
}

//different End Users can't generate the same report
fact uniqueAuthorReport{
	no disj e1, e2: EndUser | e1.issuedReport = e2.issuedReport
}

//ticket must be given to an offender of the Report
fact consistencyTicketOffenderReport{
//	all o1 : Owner, t1:Ticket, r1: Report | ((o1 in t1.givenTo) and (t1=r1.ticket))
//												 => (some o2: Owner | (o2 in r1.offender) && (o2 = o1))
	all t1:Ticket| some r1: Report | (r1.ticket = t1) implies (t1.givenTo in r1.offender)
	
}


pred show{
no t1: Ticket | #(t1.givenTo) = 0
} 
run show for 5
