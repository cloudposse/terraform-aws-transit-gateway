<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 3.0 |
| local | >= 1.2 |
| random | >= 2.2 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_tag\_map | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| allow\_external\_principals | Indicates whether principals outside your organization can be associated with a resource share | `bool` | `false` | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| auto\_accept\_shared\_attachments | Whether resource attachment requests are automatically accepted. Valid values: `disable`, `enable`. Default value: `disable` | `string` | `"enable"` | no |
| config | Configuration for VPC attachments, Transit Gateway routes, and subnet routes | <pre>map(object({<br>    vpc_id                            = string<br>    vpc_cidr                          = string<br>    subnet_ids                        = set(string)<br>    subnet_route_table_ids            = set(string)<br>    route_to                          = set(string)<br>    route_to_cidr_blocks              = set(string)<br>    transit_gateway_vpc_attachment_id = string<br>    static_routes = set(object({<br>      blackhole              = bool<br>      destination_cidr_block = string<br>    }))<br>  }))</pre> | `null` | no |
| context | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| create\_transit\_gateway | Whether to create a Transit Gateway. If set to `false`, an existing Transit Gateway ID must be provided in the variable `existing_transit_gateway_id` | `bool` | `true` | no |
| create\_transit\_gateway\_route\_table | Whether to create a Transit Gateway Route Table. If set to `false`, an existing Transit Gateway Route Table ID must be provided in the variable `existing_transit_gateway_route_table_id` | `bool` | `true` | no |
| create\_transit\_gateway\_route\_table\_association\_and\_propagation | Whether to create Transit Gateway Route Table associations and propagations | `bool` | `true` | no |
| create\_transit\_gateway\_vpc\_attachment | Whether to create Transit Gateway VPC Attachments | `bool` | `true` | no |
| default\_route\_table\_association | Whether resource attachments are automatically associated with the default association route table. Valid values: `disable`, `enable`. Default value: `enable` | `string` | `"disable"` | no |
| default\_route\_table\_propagation | Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable` | `string` | `"disable"` | no |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| dns\_support | Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable` | `string` | `"enable"` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| environment | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| existing\_transit\_gateway\_id | Existing Transit Gateway ID. If provided, the module will not create a Transit Gateway but instead will use the existing one | `string` | `null` | no |
| existing\_transit\_gateway\_route\_table\_id | Existing Transit Gateway Route Table ID. If provided, the module will not create a Transit Gateway Route Table but instead will use the existing one | `string` | `null` | no |
| id\_length\_limit | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| label\_key\_case | The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| label\_order | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| label\_value\_case | The letter case of output label values (also used in `tags` and `id`).<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Default value: `lower`. | `string` | `null` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| ram\_principal | The principal to associate with the resource share. Possible values are an AWS account ID, an Organization ARN, or an Organization Unit ARN. If this is not provided and `ram_resource_share_enabled` is set to `true`, the Organization ARN will be used | `string` | `null` | no |
| ram\_resource\_share\_enabled | Whether to enable sharing the Transit Gateway with the Organization using Resource Access Manager (RAM) | `bool` | `false` | no |
| regex\_replace\_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| route\_keys\_enabled | If true, Terraform will use keys to label routes, preventing unnecessary changes,<br>but this requires that the VPCs and subnets already exist before using this module.<br>If false, Terraform will use numbers to label routes, and a single change may<br>cascade to a long list of changes because the index or order has changed, but<br>this will work when the `true` setting generates the error `The "for_each" value depends on resource attributes...` | `bool` | `false` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| vpc\_attachment\_dns\_support | Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable` | `string` | `"enable"` | no |
| vpc\_attachment\_ipv6\_support | Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable` | `string` | `"disable"` | no |
| vpn\_ecmp\_support | Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable` | `string` | `"enable"` | no |

## Outputs

| Name | Description |
|------|-------------|
| subnet\_route\_ids | Subnet route identifiers combined with destinations |
| transit\_gateway\_arn | Transit Gateway ARN |
| transit\_gateway\_association\_default\_route\_table\_id | Transit Gateway association default route table ID |
| transit\_gateway\_id | Transit Gateway ID |
| transit\_gateway\_propagation\_default\_route\_table\_id | Transit Gateway propagation default route table ID |
| transit\_gateway\_route\_ids | Transit Gateway route identifiers combined with destinations |
| transit\_gateway\_route\_table\_id | Transit Gateway route table ID |
| transit\_gateway\_vpc\_attachment\_ids | Transit Gateway VPC attachment IDs |

<!-- markdownlint-restore -->
