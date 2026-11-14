# Changelog

## 0.1.0 (2026-11-14)


### 💡 New features

* Add a CI/CD IAM policy module ([#6](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/6)) ([ee5e14d](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/ee5e14d9e6d510fe8909f8ed4e4a384a1047787e))
* Add the EKS Auto Mode cluster and log groups ([#3](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/3)) ([fb57d96](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/fb57d96b3f71fcaf12775b426dd5a087c7c35919))
* Output what a Kubernetes client needs to connect ([#38](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/38)) ([8c479ba](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/8c479bacc2623d2f1d8d6ca4b13899cb853d0613))
* Validate inputs and add node pool and endpoint settings ([#39](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/39)) ([66cba6d](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/66cba6dafd1bc7b50e88e7e204d5ffa4f1711608))


### 🐛 Bug fixes

* Create the cluster after its role policies and log group ([#36](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/36)) ([e64c01b](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/e64c01ba7b8b85ce16d2d47e4ada0e95a8f325c9))
* Encrypt secrets with the cluster KMS key ([#37](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/37)) ([adb503d](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/adb503d391300b018682cb081cd139fe91929561))
* Grant the CI policy what the root module needs ([#43](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/43)) ([71568c0](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/71568c06f4dd99a1c42af5591dc2154ecdc72167))
* Tag the basic example's subnets for load balancers ([#42](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/42)) ([7961472](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/79614720e1953237d03b7bcfcd12c44b388c8e6b))


### 🧹 Miscellaneous

* Accept any AWS provider from v6.0 ([#40](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/40)) ([429ffd2](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/429ffd2f3ab606ec222e68aad7d58226afbce236))
* Add a submodule for custom node classes ([d6de2b8](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/d6de2b851fe7eedfaf50396664b793d532d19843))
* Add SPDX licence headers to .tf files ([#10](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/10)) ([dc05d19](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/dc05d19f8a181cc500c9f227a5305b64e672b890))
* Adopt Meta v0.4.1 workflows ([#32](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/32)) ([1551b07](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/1551b0752a13a0715408d21cf95e6bdcca8c52a9))
* Adopt shared Terraform verification workflow ([#23](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/23)) ([8085142](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/8085142cf7400456a636e22e2040c15d2a66cb85))
* Automatically update README version numbers ([#8](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/8)) ([4ce9f54](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/4ce9f543b08cc394596f9a8276aca8fa2d8fdc25))
* Bump actions/checkout from 5 to 6 ([#5](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/5)) ([9a8b3f5](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/9a8b3f5f15709d16a6bb2cc0865545d022fbdf71))
* Bump actions/checkout from 6.0.2 to 7.0.1 ([#22](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/22)) ([9a7746e](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/9a7746e6ff1aaaaba5c49293576531f57ef08d99))
* Bump googleapis/release-please-action from 4.4.0 to 5.0.0 ([#18](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/18)) ([80a0122](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/80a0122a1ba93e12db37f796a5652425bbfa5c86))
* Bump hashicorp/setup-terraform from 3 to 4 ([#12](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/12)) ([e4babb0](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/e4babb09945b668ff7a483e46bbac4315e11bc61))
* Configure chore conventional commit type ([#11](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/11)) ([6291158](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/6291158d29e6252e1febcf22b02a8f6cac840e87))
* Configure the initial Terraform module ([#1](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/1)) ([c3c2bc6](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/c3c2bc68ea3caca068c771704c8494c024421a01))
* Configure workflow runner images ([#2](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/2)) ([45ac000](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/45ac000736fc6fc3edfd8190fc08a95d559eed6d))
* Lock GitHub Actions workflow dependencies ([#29](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/29)) ([1068f93](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/1068f936fb98aae6d7f9e2891a77e346b991711e))
* Pin GitHub Actions ([#15](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/15)) ([95aeaeb](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/95aeaeb3b8a5a2752837e482c4ac4c05e5767ecd))
* Pin GitHub Actions to SHAs ([#14](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/14)) ([0bfaeeb](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/0bfaeeb283adaf7f92a2a009aedcdfe53fa1fa41))
* Remove the custom node class submodule ([#33](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/33)) ([851aeb1](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/851aeb1ddba900634cb5a5a5925b650ec1037806))
* Remove x-release-please comment pointers ([#9](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/9)) ([95feb20](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/95feb207bc01d72c569a82024e5a1d0cd16731d5))
* Update AWS provider to v6.67.0 ([#28](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/28)) ([cbc02bd](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/cbc02bd9a7f99124135798fe6e1fbc0f1a0fb4bd))
* Update meta workflows to v0.2.0 ([#24](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/24)) ([ea72736](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/ea72736dace8ba654f85c1338e318f868fc6f071))
* Update meta workflows to v0.3.0 ([#25](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/25)) ([b65bd75](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/b65bd75d1676cd40c79c84d5c4a0b624f0da9a2d))
* Update Terraform to v1.16.4 ([#27](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/27)) ([29d50a7](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/29d50a71a2cf724c1c10b4a858bdd10d670bc278))
* Update Terraform version requirements ([#13](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/13)) ([f4d35fe](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/f4d35fe6f0d8c37daab27c1bd0f763317b17cdf3))
* Upgrade Terraform to v1.17.1 ([#31](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/31)) ([5e9d5b8](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/5e9d5b877681de591914480d44e97b53dfbd06fb))
* Upgrade Terraform to v1.17.2 and the example VPC module ([#41](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/41)) ([ef745be](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/ef745be7a55a57e5e405b30f6d4de4933345b6d5))
* Use hash comments in Terraform files ([#44](https://github.com/unfunco/terraform-aws-eks-auto-mode/issues/44)) ([cb0c0de](https://github.com/unfunco/terraform-aws-eks-auto-mode/commit/cb0c0de308ed1a3e879395c589f0cd8a0650992f))
