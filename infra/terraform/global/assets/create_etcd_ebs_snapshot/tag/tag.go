package tag

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/ec2"
)

func FetchResourceTags(connection *ec2.EC2, resourceID *string, filter string) (getTagsOutput *ec2.DescribeTagsOutput, filteredVal string, err error) {

	volTagsInput := &ec2.DescribeTagsInput{
		Filters: []*ec2.Filter{
			{
				Name: aws.String("resource-id"),
				Values: []*string{
					aws.String(*resourceID),
				},
			},
		},
	}
	// Get the volume's tags
	getTagsOutput, err = connection.DescribeTags(volTagsInput)
	// Optional filter to retrieve tag values from returned Tag slice
	for i := range getTagsOutput.Tags {
		if *getTagsOutput.Tags[i].Key == filter {
			filteredVal = *getTagsOutput.Tags[i].Value
		}
	}

	return getTagsOutput, filteredVal, err

}

func TagResource(connection *ec2.EC2, resourceID string, tags []*ec2.Tag) (err error) {

	tagsInput := &ec2.CreateTagsInput{
		Resources: []*string{
			aws.String(resourceID),
		},
		Tags: tags,
	}

	_, err = connection.CreateTags(tagsInput)

	return err

}
