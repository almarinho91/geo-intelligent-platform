import boto3
import os

s3 = boto3.client("s3")
BUCKET = os.environ["BUCKET_NAME"]


def lambda_handler(event, context):
    # If this wasn't triggered by S3, return a helpful message
    if "Records" not in event:
        return {
            "statusCode": 200,
            "body": "No S3 event records found. Upload a .csv to s3://<bucket>/raw/ to trigger this function."
        }

    record = event["Records"][0]
    key = record["s3"]["object"]["key"]  # e.g. raw/test_ais.csv

    # Only process files in raw/
    if not key.startswith("raw/"):
        return {"statusCode": 200, "body": f"Skipped non-raw key: {key}"}

    # Read input file from S3
    obj = s3.get_object(Bucket=BUCKET, Key=key)
    raw_text = obj["Body"].read().decode("utf-8")

    # Process: add a speed_category column
    lines = raw_text.strip().splitlines()
    header = lines[0] + ",speed_category"
    out_lines = [header]

    for line in lines[1:]:
        parts = line.split(",")
        sog = float(parts[4])

        if sog < 0.5:
            cat = "stopped"
        elif sog < 5:
            cat = "slow"
        else:
            cat = "moving"

        out_lines.append(line + f",{cat}")

    out_text = "\n".join(out_lines) + "\n"

    # Build output key: curated/<filename>_processed.csv
    filename = key.split("/")[-1]  # test_ais.csv
    base = filename.rsplit(".", 1)[0]
    output_key = f"curated/{base}_processed.csv"

    # Write output
    s3.put_object(
        Bucket=BUCKET,
        Key=output_key,
        Body=out_text.encode("utf-8"),
        ContentType="text/csv",
    )

    return {
        "statusCode": 200,
        "body": f"Read s3://{BUCKET}/{key} and wrote s3://{BUCKET}/{output_key}",
    }