resource "aws_vpc" "vpcs" {
  count = length(var.resource_plan.vpcs)

  cidr_block = var.resource_plan.vpcs[count.index].cidr_block

  tags = {
    Name = var.resource_plan.vpcs[count.index].name
  }
}

resource "aws_subnet" "subnets" {
  count = length(var.resource_plan.subnets)

  vpc_id            = aws_vpc.vpcs[0].id
  cidr_block        = var.resource_plan.subnets[count.index].cidr_block
  availability_zone = var.resource_plan.subnets[count.index].availability_zone

  tags = {
    Name = var.resource_plan.subnets[count.index].name
  }
}

resource "aws_route_table" "route_tables" {
  count = length(var.resource_plan.route_tables)

  vpc_id = aws_vpc.vpcs[0].id

  tags = {
    Name = var.resource_plan.route_tables[count.index].name
  }
}

resource "aws_security_group" "security_groups" {
  count = length(var.resource_plan.security_groups)

  vpc_id      = aws_vpc.vpcs[0].id
  name        = var.resource_plan.security_groups[count.index].name
  description = var.resource_plan.security_groups[count.index].description

  tags = {
    Name = var.resource_plan.security_groups[count.index].name
  }
}

resource "aws_security_group_rule" "security_group_rules" {
  count = length(var.resource_plan.security_group_rules)

  security_group_id = aws_security_group.security_groups[0].id
  type              = var.resource_plan.security_group_rules[count.index].type
  cidr_blocks       = [var.resource_plan.security_group_rules[count.index].cidr_ip]
  protocol          = var.resource_plan.security_group_rules[count.index].ip_protocol
  from_port         = parseint(split("-", var.resource_plan.security_group_rules[count.index].port_range)[0], 10)
  to_port           = try(
                        parseint(split("-", var.resource_plan.security_group_rules[count.index].port_range)[1], 10),
                        parseint(split("-", var.resource_plan.security_group_rules[count.index].port_range)[0], 10)
                      )
}
