module "vpc" {
  #相对于当前项目的绝对路径
  source = "./modules/vpc"
  #VPC没有输入，不需要输入的变量
}

module "nsg" {
  source = "./modules/security_groups"
  #输入参数，参数名vpcid要和我们定义的安全组的输入vpcid一样
  #输入参数的值：调用vpc子模块下的输出（output）
  vpcid = module.vpc.vpc_id
}

module "ecs" {
  source = "./modules/ecs"
  #ECS 引用了两个模块的输出作为输入
  nsgid     = module.nsg.nsg_id
  vswitchid = module.vpc.vswitch_id
}