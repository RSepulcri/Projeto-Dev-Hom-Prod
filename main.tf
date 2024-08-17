provider "aws" {
  region = "us-west-2" # Change this to your desired region
}

# Define an API Gateway
resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "my-api-gateway"
  description = "API Gateway for Meu App"
}

# Define a Lambda function
resource "aws_lambda_function" "lambda_function" {
  function_name = "my-lambda-function"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "python3.8"
  
  # Example code and other configurations
  # You should replace this with actual code and settings
  s3_bucket = aws_s3_bucket.lambda_bucket.bucket
  s3_key    = "lambda_function.zip"
}

# Define a Load Balancer
resource "aws_elb" "elb" {
  name               = "my-load-balancer"
  availability_zones = ["us-west-2a", "us-west-2b"]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    protocol          = "HTTP"
  }
  
  # Attach instances or other necessary configurations
}

# Define an RDS instance
resource "aws_db_instance" "db_instance" {
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t2.micro"
  name              = "mydatabase"
  username          = "admin"
  password          = "password" # Use a more secure approach for production
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
}

# Define an S3 bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "my-s3-bucket"
}

# Define EventBridge
resource "aws_cloudwatch_event_rule" "eventbridge_rule" {
  name        = "my-eventbridge-rule"
  description = "EventBridge rule for Meu App"
  event_pattern = jsonencode({
    source = ["aws.events"]
  })
}

# Define IAM role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_execution_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to IAM role for Lambda
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Define a security group for RDS
resource "aws_security_group" "db_sg" {
  name        = "db_security_group"
  description = "Allow inbound access to RDS instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Use more restrictive rules in production
  }
}

# Define a VPC and subnet (as an example, adjust to your needs)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.main.id]
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda_security_group"
  description = "Allow inbound access to Lambda functions"
  vpc_id      = aws_vpc.main.id
}
