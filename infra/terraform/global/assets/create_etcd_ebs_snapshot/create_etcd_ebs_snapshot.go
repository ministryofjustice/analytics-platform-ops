package main

import (
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/aws"
	"fmt"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"os"
	"log"
)

var (
	connection = ec2.New(session.New())
)


func main() {

	instanceKeyFilter   := os.Getenv("INSTANCE_KEY")
	instanceValueFilter := os.Getenv("INSTANCE_VALUE")

	// Filter instances with role set to master
	instanceInput := &ec2.DescribeInstancesInput{
		Filters: []*ec2.Filter{
			{
				Name: 	aws.String(fmt.Sprintf("tag:%s", instanceKeyFilter )),
				Values: []*string{ aws.String(instanceValueFilter)},
			},
		},
	}

	// A reservation corresponds to a command to start instances
	// A reservation is what you do to provision instances, while an instance is what you get
	reservation, err := connection.DescribeInstances(instanceInput)
	if err != nil {
		log.Fatal(err.Error())
	}

	// Iterate over reservations
	for index := range reservation.Reservations {

		// Iterate reservations to access ec2 instances
		for _, inst := range reservation.Reservations[index].Instances {

			// Iterate over each instance's block device metadata
			for _, blk := range inst.BlockDeviceMappings {

				// Exclude root volumes.  Root volumes have "Delete on termination" set to true mostly
				rootDevice := *blk.Ebs.DeleteOnTermination

				if rootDevice != true {
					vol_id := blk.Ebs.VolumeId

					snapshotInput := &ec2.CreateSnapshotInput{
						VolumeId: vol_id,
					}

					// Perform ebs snapshot operation
					snapIt, err := connection.CreateSnapshot(snapshotInput)
					if err != nil {
						if aerr, ok := err.(awserr.Error); ok {
							switch aerr.Code() {
							default:
								fmt.Println(aerr.Error())
							}
						} else {
							// Print the error, cast err to awserr.Error to get the Code and
							// Message from an error.
							fmt.Println(err.Error())
						}
						return
					}
					// Print result
					fmt.Println(snapIt)

					volTagsInput := &ec2.DescribeTagsInput{
						Filters:	[]*ec2.Filter{
							{
								Name:	aws.String("resource-id"),
								Values: []*string{
									aws.String(*vol_id),
								},
							},
						},
					}

					// Get the volume's tags
					getVolumesTags, err := connection.DescribeTags(volTagsInput)
					if err != nil {
						if aerr, ok := err.(awserr.Error); ok {
							switch aerr.Code() {
							default:
								fmt.Println(aerr.Error())
							}
						} else {
							// Print the error, cast err to awserr.Error to get the Code and
							// Message from an error.
							fmt.Println(err.Error())
						}
						return
					}

					snapShotID   := *snapIt.SnapshotId
					instanceName := *inst.Tags[1].Value
					deviceName   := *blk.DeviceName
					volumeName   := *getVolumesTags.Tags[1].Value

					tagsInput := &ec2.CreateTagsInput{
						Resources: []*string{
							aws.String(snapShotID),
						},
						Tags: []*ec2.Tag{
							{
								Key:   aws.String("Instance_Name"),
								Value: aws.String(instanceName),

							},
							{
								Key:   aws.String("Device_Name"),
								Value: aws.String(deviceName),
							},
							{
								Key:   aws.String("Name"),
								Value: aws.String(volumeName),
							},
						},
					}

					// Finally tag snapshot with instance ID, Device designation and Volume name
					tagIt, err := connection.CreateTags(tagsInput)
					if err != nil {
						if aerr, ok := err.(awserr.Error); ok {
							switch aerr.Code() {
							default:
								fmt.Println(aerr.Error())
							}
						} else {
							// Print the error, cast err to awserr.Error to get the Code and
							// Message from an error.
							fmt.Println(err.Error())
						}
						return
					}
					fmt.Println(tagIt)
				}
			}
		}
	}
}
