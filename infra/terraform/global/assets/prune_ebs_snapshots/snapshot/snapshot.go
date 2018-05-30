package snapshot

import (
	"../caller"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/ec2"
	"log"
	"time"
)

func GetSnapShots(connection *ec2.EC2, key string, val string) (output *ec2.DescribeSnapshotsOutput, err error) {

	//var snapShotInput *ec2.DescribeSnapshotsInput

	// Get the owner ID a.k.a the aws account number
	callerResult, callerErr := caller.GetCaller()
	if callerErr != nil {
		log.Panicf("Error while getting owner ID: %s", err)
	}
	ownerID := *callerResult.Account

	filters := []*ec2.Filter{
		{
			Name: aws.String("owner-id"),
			Values: []*string{
				aws.String(ownerID),
			},
		},
	}

	if len(key) > 0 && len(val) > 0 {
		filters = append(filters, &ec2.Filter{
			Name: aws.String(fmt.Sprintf("tag:%s", key)),
			Values: []*string{
				aws.String(val),
			},
		})
	}

	snapShotInput := &ec2.DescribeSnapshotsInput{Filters: filters}

	return connection.DescribeSnapshots(snapShotInput)
}

func DeleteSnapShot(connection *ec2.EC2, snapshotID string) (output *ec2.DeleteSnapshotOutput, err error) {

	deleteSnapShotShotInput := &ec2.DeleteSnapshotInput{
		SnapshotId: aws.String(snapshotID),
	}

	return connection.DeleteSnapshot(deleteSnapShotShotInput)
}

func OlderThan(createdAt *time.Time, duration time.Duration) bool {

	return createdAt.Add(duration).Before(time.Now())
}
