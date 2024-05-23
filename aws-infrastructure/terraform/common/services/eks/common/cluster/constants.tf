locals {
  azs                 = formatlist("${data.aws_region.current.name}%s", ["a", "b", "c"])
}
