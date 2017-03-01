'use strict';

const aws = require('aws-sdk');

const s3 = new aws.S3({ apiVersion: '2006-03-01' });


exports.handler = (event, context, callback) => {
    console.log('Received event:', JSON.stringify(event, null, 2));

    // Get the object from the event and show its content type
    const bucket = event.Records[0].s3.bucket.name;
    const key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));

    console.log('key:', JSON.stringify(key, null, 2));
    const headParams = {
        Bucket: bucket,
        Key: key,
    };

    s3.headObject(headParams, function(err, data) {
        if (err) {
            const error_msg = `Error getting object ${key} from bucket ${bucket}`;
            console.log(error_msg);
            callback(error_msg);
        } else {
            // Only encrypt if not encrypted already
            if (data.ServerSideEncryption !== 'AES256') {
                console.log(`Unencrypted S3 object, key="${key}" bucket=${bucket}. Encrypting it...`);
                // Copying an object into itself with encryption enabled
                const copyParams = {
                    CopySource: `${bucket}/${key}`,
                    Bucket: bucket,
                    Key: key,
                    ServerSideEncryption: 'AES256',
                };
                s3.copyObject(copyParams, (err, data) => {
                    if (err) {
                        console.log(err);
                        const error_msg = `Error encrypting object ${key} in bucket ${bucket}.`;
                        console.log(error_msg);
                        callback(error_msg);
                    } else {
                        const success_msg = `S3 object with key "${key}" in ${bucket} successfully encrypted`;
                        console.log(success_msg);
                        callback(null, success_msg);
                    }
                });
            } else {
                const success_msg = `SKIPPING ENCRYPTION...already encrypted! key="${key}" bucket=${bucket}.`;
                console.log(success_msg);
                callback(null, success_msg);
            }
        }
    });
};
