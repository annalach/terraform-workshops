# 1. Setup

## AWS Account

1. Create an AWS account, click [here](https://aws.amazon.com/free/?trk=ps_a134p000003yjtxAAA&trkCampaign=acq_paid_search_brand&sc_channel=PS&sc_campaign=acquisition_EEM&sc_publisher=Google&sc_category=Core&sc_country=EEM&sc_geo=EMEA&sc_outcome=acq&sc_detail=aws%20sign%20up&sc_content=Signup_e&sc_segment=453071975197&sc_medium=ACQ-P%7CPS-GO%7CBrand%7CDesktop%7CSU%7CAWS%7CCore%7CEEM%7CEN%7CText%7Cxx%7CEU&s_kwcid=AL!4422!3!453071975197!e!!g!!aws%20sign%20up&ef_id=CjwKCAjw7fuJBhBdEiwA2lLMYcj7TaIGIfVQtxyV3t9ZhTra5MeOwD-eESl2JxqnOefNKjohRc83OhoC13gQAvD_BwE:G:s&s_kwcid=AL!4422!3!453071975197!e!!g!!aws%20sign%20up&all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all).
2. Create an Administrator IAM user and user group, follow [the AWS guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html).
3. Create a billing alarm, follow [this guide](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/monitor_estimated_charges_with_cloudwatch.html).
4. Install AWS CLI using [Homebrew](https://formulae.brew.sh/formula/awscli) \(Mac OS users\).
5. Configure AWS CLI, use the `aws configure` command, follow [the AWS guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).

## **Terraform**

Follow **Homebrew on OS X** installation guide on [Terraform webpage](https://learn.hashicorp.com/tutorials/terraform/install-cli). 

## Packer

Follow **Homebrew on OS X** installation guide on [Packer webpage](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli).

## VS Code Extensions

* [HashiCorp Terraform](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)
* [Packer](https://marketplace.visualstudio.com/items?itemName=4ops.packer)

