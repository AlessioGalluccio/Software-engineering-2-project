

abstract sig User {
	password: one String
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
	code: one Int
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
	vehicle: one Vehicle
}

sig Vehicle{
	licensePlate: one LicensePlate,
	owner: one Owner
}

sig Report{
	location: one Location,
	photo: one Photo,
	vehicles: some Vehicle,
	offenders: some Owner,
	ticket: lone Ticket
}

sig Ticket{
	givenBy: one AuthorityUser,
	givenTo: set Owner
}

pred show{} 
run show for 10
