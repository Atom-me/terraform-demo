#ECS需要两个输入 安全组ID和交换机ID
variable "nsgid" {
  type = list(string)
}

variable "vswitchid" {
  type = string
}