package caller

import (
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sts"
)

func GetCaller() (output *sts.GetCallerIdentityOutput, err error) {

	connection := sts.New(session.Must(session.NewSession()))
	callerInput := &sts.GetCallerIdentityInput{}
	output, err = connection.GetCallerIdentity(callerInput)

	return output, err
}
