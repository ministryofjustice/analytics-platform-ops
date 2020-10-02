package snapshot

import (
	"fmt"

	"github.com/aws/aws-sdk-go/service/ec2"
)

// Create an EBS snapshot
func Create(connection *ec2.EC2, volumeID *string) (snapshot *ec2.Snapshot, err error) {

	snapshotInput := &ec2.CreateSnapshotInput{
		VolumeId: volumeID,
	}

	// Perform ebs snapshot operation
	snapshot, err = connection.CreateSnapshot(snapshotInput)

	fmt.Println(snapshot)

	return snapshot, err

}
