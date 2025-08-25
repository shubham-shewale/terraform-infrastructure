## AWS OIDC Setup Guide

### Step 1 — Create the OIDC Identity Provider in AWS (Console)

1. In AWS IAM, go to **Identity providers** and choose **Add provider** with type **OpenID Connect**.
2. Set **Provider URL host** to `token.actions.githubusercontent.com` and click **Get thumbprint** to fetch and validate the IdP certificate automatically.
3. Set **Audience** to `sts.amazonaws.com` to allow STS to issue web identity credentials for GitHub tokens.
4. Complete creation and note the resulting **OIDC provider ARN** for use in trust policies.

> 💡 **Tip**: Let the AWS console compute the current thumbprint to avoid hard‑coding certificate hashes that may rotate.

---

### Step 2 — Create an IAM Role Trusted by GitHub OIDC

1. Create an IAM role that uses **WebIdentity federation** and selects the GitHub OIDC provider created above.
2. Attach the **minimal permissions** required by the workflow (least privilege).
3. Use a **trust policy** that restricts:
   - `aud` (audience) to `sts.amazonaws.com`
   - `sub` (subject) to the intended repository (and optionally branch) so only that repo/branch can assume the role.

#### Example Trust Policy

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:shubham-shewale/terraform-infrastructure:*"
                }
            }
        }
    ]
}

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "elasticloadbalancing:*",
                "acm:*",
                "route53:*",
                "s3:*",
                "ksm:*",
                "logs:*",
                "iam:*"
            ],
            "Resource": "*"
        }
    ]
}

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::127311923021:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::alb-logs-905418359995-us-east-1/*"
        }
    ]
}
