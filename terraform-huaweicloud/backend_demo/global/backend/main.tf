#ak/sk使用的是临时变量方式，所以这里只声明了region
provider "huaweicloud" {
  region = var.region
}


resource "huaweicloud_obs_bucket" "bucket" {
  bucket = "liuyamingtfbuckeet"
  acl    = "private"

  tags = {
    type = "bucket"
  }
}