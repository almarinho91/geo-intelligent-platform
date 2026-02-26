import boto3

s3 = boto3.client("s3")

BUCKET = "andre-geo-platform-dev"   # <-- change if your bucket name differs
INPUT_KEY = "raw/test_ais.csv"
OUTPUT_KEY = "curated/test_ais_processed.csv"


def lambda_handler(event, context):
    # 1) Read input file from S3
    obj = s3.get_object(Bucket=BUCKET, Key=INPUT_KEY)
    raw_text = obj["Body"].read().decode("utf-8")

    # 2) Very small "processing": add a new column speed_category
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

    # 3) Write output to S3 (curated zone)
    s3.put_object(
        Bucket=BUCKET,
        Key=OUTPUT_KEY,
        Body=out_text.encode("utf-8"),
        ContentType="text/csv",
    )

    return {
        "statusCode": 200,
        "body": f"Wrote s3://{BUCKET}/{OUTPUT_KEY} with {len(out_lines)-1} rows",
    }