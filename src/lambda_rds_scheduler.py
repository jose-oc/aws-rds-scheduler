import logging
import os

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger(__name__)
logger.setLevel(os.environ.get('LOGLEVEL', 'WARNING').strip().upper())

aws_region = os.environ['AWS_REGION']
rds = boto3.client('rds', region_name=aws_region)


def lambda_handler(event, context):
    rds_instances = rds.describe_db_instances()
    # logger.debug('Describe RDS: %s', str(rds_instances))

    instances = list()
    if 'stop' == event['action']:
        instances = stop_rds_instances(rds_instances)
        logger.info('Instances stopped: %s', instances)
    elif 'start' == event['action']:
        instances = start_rds_instances(rds_instances)
        logger.info('Instances started: %s', instances)

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": f"RDS instances to {event['action']}: {instances}"
    }


def stop_rds_instances(rds_instances):
    instances_stopped = list()
    try:
        for db in rds_instances['DBInstances']:
            if db['DBInstanceStatus'] == 'available':
                db_tags = rds.list_tags_for_resource(ResourceName=db['DBInstanceArn'])['TagList']
                for tags in db_tags:
                    if tags['Key'] == 'autostop' and tags['Value'] == 'yes':
                        _ = rds.stop_db_instance(DBInstanceIdentifier=db['DBInstanceIdentifier'])
                        instances_stopped.append(db['DBInstanceIdentifier'])
                        logger.debug("Stopping instance: %s", db['DBInstanceIdentifier'])
    except ClientError as e:
        logger.error(e)
    return instances_stopped


def start_rds_instances(rds_instances):
    instances_started = list()
    try:
        for db in rds_instances['DBInstances']:
            if db['DBInstanceStatus'] == 'stopped':
                db_tags = rds.list_tags_for_resource(ResourceName=db['DBInstanceArn'])['TagList']
                for tags in db_tags:
                    if tags['Key'] == 'autostart' and tags['Value'] == 'yes':
                        _ = rds.start_db_instance(DBInstanceIdentifier=db['DBInstanceIdentifier'])
                        instances_started.append(db['DBInstanceIdentifier'])
                        logger.debug("Starting instance: %s", db['DBInstanceIdentifier'])
    except ClientError as e:
        logger.error(e)
    return instances_started
