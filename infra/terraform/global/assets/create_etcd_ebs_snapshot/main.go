package main

import (
	"./snapshot"
	"./tag"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"log"
	"os"
)

var (
	clientSession       = session.Must(session.NewSession())
	connection          = ec2.New(clientSession)
	optionalTagKey      = os.Getenv("TAG_KEY")
	optionalTagVal      = os.Getenv("TAG_VALUE")
	instanceKeyFilter   = os.Getenv("INSTANCE_TAG_KEY")
	instanceValueFilter = os.Getenv("INSTANCE_TAG_VALUE")
)

func main() {

	instanceInput := &ec2.DescribeInstancesInput{
		Filters: []*ec2.Filter{
			{
				Name:   aws.String(fmt.Sprintf("tag:%s", instanceKeyFilter)),
				Values: []*string{aws.String(instanceValueFilter)},
			},
		},
	}

	// A reservation corresponds to a command to start instances
	// A reservation is what you do to provision instances, while an instance is what you get
	results, err := connection.DescribeInstances(instanceInput)
	if err != nil {
		log.Fatal(err.Error())
	}

	for _, res := range results.Reservations {

		for _, instance := range res.Instances {

			for _, blk := range instance.BlockDeviceMappings {

				// Exclude root volumes.  Root volumes have "Delete on termination" set to true mostly
				isRootDevice := *blk.Ebs.DeleteOnTermination

				if isRootDevice != true {
					volumeID := blk.Ebs.VolumeId
					instanceID := instance.InstanceId

					// Perform and tag the snapshot
					snapShot, err := snapshot.CreateSnapshot(connection, volumeID)
					if err != nil {
						log.Printf("Error while taking snapshot of %s: %s", volumeID, err)
					}

					_, volumeName, err := tag.FetchResourceTags(connection, volumeID, "Name")
					if err != nil {
						log.Printf("Error while getting tags for volume %s: %s", volumeID, err)
					}

					_, instanceName, err := tag.FetchResourceTags(connection, instanceID, "Name")
					if err != nil {
						log.Printf("Error while getting tags for ec2 instance %s: %s", instanceID, err)
					}

					snapShotID := *snapShot.SnapshotId
					deviceName := *blk.DeviceName

					Tags := []*ec2.Tag{
						{
							Key:   aws.String(optionalTagKey),
							Value: aws.String(optionalTagVal),
						},
						{
							Key:   aws.String("Device_Name"),
							Value: aws.String(deviceName),
						},
						{
							Key:   aws.String("Name"),
							Value: aws.String(volumeName),
						},
						{
							Key:   aws.String("Instance_Name"),
							Value: aws.String(instanceName),
						},
					}

					tag.TagResource(connection, snapShotID, Tags)
					if err != nil {
						log.Printf("Error while tagging snapshot %s: %s", snapShotID, err)
					}
				}
			}
		}
	}
}
