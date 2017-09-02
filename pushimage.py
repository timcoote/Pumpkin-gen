# push pumpkin image into same S3 bucket as pumpco binaries
# will need to fix credentials somewhere and document!

import boto3
from boto3.s3.transfer import TransferConfig
import sys

GB = 1024 ** 3

s3 = boto3.client ('s3')

# not normally run. Maybe should just handle failure of this
# s3.create_bucket (Bucket='pumpco', CreateBucketConfiguration={'LocationConstraint': 'eu-west-2'})

print (s3.list_buckets ())
config = TransferConfig (multipart_threshold=5 * GB) # avoid multipart uploads otherwise ansible cannot download them

print (sys.argv[1])
#s3.upload_file ("deploy/{}".format (sys.argv[1]), 'pumpco', "{}".format(phile), Config=config)
