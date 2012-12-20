// Maakt een nieuw contact aan.
function Contact(firstName, lastName, image) {
	this.firstName = firstName;
	this.lastName = lastName;
	this.image = image;
}

// Geeft de naam van het contact weer zoals de gebruiker dit wenst.
function getName(contact) {
	if(firstNameFirst) {
			return contact.firstName + " " + contact.lastName;
		} else {
			return contact.lastName + " " + contact.firstName;
		}
}

// Vergelijkt welk contact eerder komt in de alfabetische lijst die de gebruiker wenst te zien.
function compare(a,b) {
  	if(firstNameFirst) {
  		return firstNameFirstCompare(a,b);
  	} else {
  		return notFirstNameFirstCompare(a,b);
  	}
}

// Hulpfunctie om te vergelijken welk contact eerder komt in de alfabetische lijst.
function firstNameFirstCompare(a,b) {
	if (a.firstName < b.firstName)
		return -1;
	else if (a.firstName > b.firstName)
		return 1;
	else if (a.lastName < b.lastName)
		return -1;
	else if (a.lastName > b.lastName)
		return 1;
	else
		return 0;
}

//Hulpfunctie om te vergelijken welk contact eerder komt in de alfabetische lijst.
function notFirstNameFirstCompare(a,b) {
	if (a.lastName < b.lastName)
		return -1;
	else if (a.lastName > b.lastName)
		return 1;
	else if (a.firstName < b.firstName)
		return -1;
	else if (a.firstName > b.firstName)
		return 1;
	else
		return 0;
}
