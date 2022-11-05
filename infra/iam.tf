resource "aws_iam_role" "iam_role_lambda" {
  name = "iam_role_lambda"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}


resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": [
            "s3:PutObject",
          ],
          "Resource": "arn:aws:s3:::dogbucket-jk/*"
      },
    ],
    "Condition": {
      "StringEquals": {
        "whereami": "whoknows"
      }
    }
  })
}

resource "aws_iam_role_policy_attachment" "lambda-iam-attach" {
  role       = aws_iam_role.iam_role_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}