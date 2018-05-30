package main

import (
	"./snapshot"
	"fmt"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"log"
	"os"
	"strconv"
	"time"
)

var (
	clientSession       = session.Must(session.NewSession())
	connection          = ec2.New(clientSession)
	snapShotKeyFilter   = os.Getenv("SNAPSHOT_TAG_KEY")
	snapShotValueFilter = os.Getenv("SNAPSHOT_TAG_VALUE")
	getDays             = os.Getenv("DAYS_OLD")
)

func main() {

	// Convert `DAYS_OLD` value to an integer
	daysOldValue, err := strconv.Atoi(getDays)
	if err != nil {
		fmt.Println(err)
		log.Panicf("Failed to parse DAYS_OLD, must be an integer: %s", err)
	}

	snapShots, err := snapshot.GetSnapShots(connection, snapShotKeyFilter, snapShotValueFilter)
	if err != nil {
		log.Fatal(err.Error())
	}

	for _, snapShot := range snapShots.Snapshots {

		// Cast integer to type Duration
		numberOfDays := time.Duration(daysOldValue)
		days := time.Hour * 24 * numberOfDays

		if snapshot.OlderThan(snapShot.StartTime, days) {
			_, err := snapshot.DeleteSnapShot(connection, *snapShot.SnapshotId)
			if err != nil {
				log.Printf("Error while pruning snapshot %s: %s", *snapShot.SnapshotId, err)
			}
		}
	}
}
