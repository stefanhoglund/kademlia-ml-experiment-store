package kademlia

import (
	"fmt"
	"testing"
)

// TestContact splittra upp till mindre tester?
func TestContact(t *testing.T) {
	fmt.Println("Running TestContact")
	testContactCandidates := kademlia.ContactCandidates{}
	testContact1 := kademlia.NewContact(kademlia.NewKademliaID("2111111000000000000000000000000000000001"), "localhost:8001")
	testContact2 := kademlia.NewContact(kademlia.NewKademliaID("2111111000000000000000000000000000000002"), "localhost:8002")
	testContact3 := kademlia.NewContact(kademlia.NewKademliaID("2111111000000000000000000000000000000003"), "localhost:8003")

	// Get distances to first contact
	testContact1.CalcDistance(kademlia.NewKademliaID("2111111100000000000000000000000000000000"))
	testContact2.CalcDistance(kademlia.NewKademliaID("2111111100000000000000000000000000000000"))
	testContact3.CalcDistance(kademlia.NewKademliaID("2111111100000000000000000000000000000000"))

	// Test append in wrong order, to then sort and check if correct
	testContactList := []kademlia.Contact{testContact1, testContact2, testContact3}
	testContactCandidates.Append([]kademlia.Contact{testContact3, testContact2, testContact1})
	testContactCandidates.Sort()

	// Test if last object is same
	if testContactList[0] != testContactCandidates.GetContacts(3)[0] {
		t.Errorf("Last object in list and candidates was not the same. Expected: %s Got: %s", testContactList[2], testContactCandidates.GetContacts(3)[2])
	}

	//Test if .string gives the same from the same contact {
	if testContactList[0].String() != testContactCandidates.GetContacts(3)[0].String() {
		t.Errorf("Last object string in list and candidates was not the same. Expected: %s Got: %s", testContactList[2].String(), testContactCandidates.GetContacts(3)[2].String())
	}

	// Test if same length
	if len(testContactList) != testContactCandidates.Len() {
		t.Errorf("List and candidate are not same length. Expected: %d Got: %d ", len(testContactList), testContactCandidates.Len())
	}
}
