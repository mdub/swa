# swa - AWS CLI (backwards)

## Overview

**swa** is an alternative CLI for AWS that inverts the typical command structure by placing verbs at the end rather than the beginning. The name "swa" is "AWS" spelled backwards, reflecting this design philosophy.

**Version:** 0.8.6
**Repository:** https://github.com/mdub/swa
**License:** MIT
**Language:** Ruby

### Command structure comparison

```bash
# Standard AWS CLI
aws ec2 terminate-instances --instance-ids i-9336f049

# swa
swa ec2 instance i-9336f049 terminate
```

## What swa does

swa provides a more intuitive interface to AWS services by organizing commands hierarchically by service, resource type, and then action. It supports:

- **Resource inspection** - View details of AWS resources in YAML or JSON format
- **Resource filtering** - Filter by tags, states, dates, and custom predicates
- **Batch operations** - List and query collections of resources
- **JMESPath queries** - Extract specific fields from resource data
- **Smart resource resolution** - Automatically detect resource types from IDs (e.g., `swa i-123456` → EC2 instance)
- **Resource actions** - Perform operations like terminate, delete, put, get, etc.

### Supported AWS services

| Service | Resource types |
|---------|----------------|
| **EC2** | Instances, AMIs, Key-pairs, Security Groups, Snapshots, Volumes, Subnets, VPCs |
| **S3** | Buckets, Objects, Object versions |
| **IAM** | Users, Roles, Groups, Policies, Instance Profiles |
| **Glue** | Databases, Tables, Crawlers, Jobs, Job Runs, Partitions |
| **Athena** | Catalogs, Databases, Query Executions |
| **KMS** | Keys, Aliases |
| **CloudFormation** | Stacks, Templates, Parameters, Outputs, Resources |
| **ELB** | Load Balancers (Classic) |
| **LakeFormation** | Data Lake Settings, LF-Tags, Permissions, Resources |

## Codebase architecture

### Directory structure

```
/
├── exe/
│   └── swa                    # Main executable entry point
├── lib/
│   └── swa/
│       ├── cli/               # Command-line interface layer
│       │   ├── main_command.rb            # Top-level command dispatcher
│       │   ├── base_command.rb            # Base class for all commands
│       │   ├── *_command.rb               # Service-specific commands (9 services)
│       │   ├── collection_behaviour.rb    # Mixin for listing resources
│       │   ├── item_behaviour.rb          # Mixin for single resource ops
│       │   ├── data_output.rb             # Output formatting (YAML/JSON)
│       │   ├── filter_options.rb          # AWS filtering
│       │   ├── tag_filter_options.rb      # Tag-based filtering
│       │   └── selector.rb                # Custom filter predicates
│       ├── athena/            # Athena resource models
│       ├── cloud_formation/   # CloudFormation resource models
│       ├── ec2/               # EC2 resource models
│       ├── elb/               # ELB resource models
│       ├── glue/              # Glue resource models
│       ├── iam/               # IAM resource models
│       ├── kms/               # KMS resource models
│       ├── lake_formation/    # LakeFormation resource models
│       ├── s3/                # S3 resource models
│       ├── resource.rb        # Base class for AWS SDK resources
│       ├── record.rb          # Base class for API response records
│       ├── data_presentation.rb  # Display formatting utilities
│       └── version.rb         # Version constant
└── swa.gemspec                # Gem specification
```

### Key architectural patterns

#### 1. Command hierarchy (Clamp framework)

```
MainCommand (Swa::CLI::MainCommand)
├── BaseCommand (authentication, AWS client setup)
├── Service Commands (e.g., Ec2Command, S3Command)
│   ├── Collection Subcommands (e.g., "instances", "buckets")
│   │   └── Actions: summary, ids, data
│   └── Item Subcommands (e.g., "instance", "bucket")
│       └── Actions: summary, data, [resource-specific actions]
```

- **MainCommand** - Top-level dispatcher, includes smart resource ID prefix matching
- **BaseCommand** - Shared functionality: AWS authentication, region config, logging
- **Service Commands** - One per AWS service (9 total)
- **Mixins:**
  - `CollectionBehaviour` - Provides `summary`, `ids`, `data` subcommands for listings
  - `ItemBehaviour` - Provides `summary`, `data` subcommands for individual items

#### 2. Resource wrapping pattern

Two base classes wrap AWS SDK objects:

**Resource** class (`lib/swa/resource.rb`):
- Used for AWS SDK resource objects (EC2, S3, IAM, CloudFormation, ELB)
- Delegates method calls to underlying SDK resource
- Provides standard interface:
  - `summary()` - One-line display string
  - `id` - Resource identifier
  - `data()` - Full data as hash (for YAML/JSON output)

**Record** class (`lib/swa/record.rb`):
- Used for API response data structures (Glue, Athena, KMS, LakeFormation)
- Wraps plain Ruby hashes/structs from API responses
- Same standard interface as Resource

Each AWS service has specialized subclasses in its directory (e.g., `Swa::EC2::Instance`, `Swa::S3::Bucket`).

#### 3. Filtering and querying

Multiple filtering mechanisms work together:

- **FilterOptions** - AWS API-level filters (e.g., `--filter name=value`)
- **TagFilterOptions** - Tag-based filtering (e.g., `--tagged environment=prod`)
- **Selector** - Custom Ruby predicates for in-memory filtering
- **Date ranges** - Via Chronic gem for date/time parsing
- **JMESPath** - Query expressions for extracting specific fields from output

#### 4. Output formatting

**DataOutput** module provides:
- YAML output (default)
- JSON output (`--json` / `-J`)
- JMESPath query support (as command argument)
- Pretty-printing with indentation
- CSV support for certain data types

### Core components

#### CLI layer (`lib/swa/cli/`)

| File | Purpose |
|------|---------|
| `main_command.rb` | Top-level command, service dispatch, smart ID prefix matching |
| `base_command.rb` | AWS authentication, region config, client setup |
| `athena_command.rb` | Athena catalogs, databases, queries |
| `cloud_formation_command.rb` | CloudFormation stacks, templates |
| `ec2_command.rb` | EC2 instances, images, volumes, security groups, etc. |
| `elb_command.rb` | Elastic Load Balancers |
| `glue_command.rb` | Glue databases, tables, jobs, crawlers |
| `iam_command.rb` | IAM users, roles, groups, policies |
| `kms_command.rb` | KMS keys, aliases |
| `lake_formation_command.rb` | LakeFormation tags, permissions |
| `s3_command.rb` | S3 buckets, objects |
| `collection_behaviour.rb` | Mixin: list resources, filter, output |
| `item_behaviour.rb` | Mixin: single resource inspection |
| `data_output.rb` | YAML/JSON formatting, JMESPath |
| `filter_options.rb` | AWS API filter options |
| `tag_filter_options.rb` | Tag-based filter options |
| `selector.rb` | Custom predicate filtering |

#### Resource models

Each AWS service has a directory with resource model classes:

- **EC2** - 9 resource types (Instance, Image, KeyPair, SecurityGroup, Snapshot, Volume, Subnet, Vpc, TaggedResource)
- **S3** - 6 types (Bucket, Object, ObjectVersion, ObjectListEntry, ObjectSummary, ObjectPrefix)
- **IAM** - 7 types (User, Role, Group, Policy, RolePolicy, InstanceProfile, Credentials)
- **Glue** - 8 types (Database, Table, Job, JobRun, JobBookmarkEntry, Crawler, Crawl, Partition)
- **Athena** - 4 types (Catalog, Database, QueryExecution, WorkGroup)
- **KMS** - 2 types (Key, Alias)
- **CloudFormation** - 1 type (Stack)
- **ELB** - 1 type (LoadBalancer)
- **LakeFormation** - 4 types (DataLakeSettings, Permission, ResourceInfo, Tag)

Each model:
- Extends `Resource` or `Record`
- Implements `summary()` for display
- Exposes attributes via method delegation
- May implement custom actions (e.g., `terminate`, `delete`, `put`)

### Key dependencies

```ruby
# AWS SDK (modular approach)
aws-sdk-athena, aws-sdk-cloudformation, aws-sdk-ec2,
aws-sdk-elasticloadbalancing, aws-sdk-glue, aws-sdk-iam,
aws-sdk-kms, aws-sdk-lakeformation, aws-sdk-s3

# CLI framework
clamp (~> 1.1.0)              # Command-line parsing

# Data processing
multi_json                    # JSON serialization
jmespath                      # Query language for JSON
chronic                       # Natural language date/time parsing
ox                            # XML parsing

# Display formatting
console_logger                # Structured logging
bytesize                      # Human-readable byte sizes

# Utilities
stackup (~> 1.0.0)            # CloudFormation tooling
```

## How the codebase hangs together

### 1. Command execution flow

```
User runs: swa ec2 instance i-123456 data --json
    ↓
MainCommand.run (lib/swa/cli/main_command.rb)
    ↓
Ec2Command (lib/swa/cli/ec2_command.rb)
    ↓
InstanceCommand (defined in Ec2Command via subcommand DSL)
    ↓
ItemBehaviour#execute (lib/swa/cli/item_behaviour.rb)
    ↓
find_item method (retrieves AWS::EC2::Instance)
    ↓
Wrapped as Swa::EC2::Instance (lib/swa/ec2/instance.rb)
    ↓
DataCommand.execute (outputs data as JSON)
    ↓
Output formatted and printed to stdout
```

### 2. Smart prefix matching

MainCommand includes logic to detect resource prefixes and route commands automatically:

```ruby
# In lib/swa/cli/main_command.rb
case parameter
when /^i-/         then ["ec2", "instance", parameter]
when /^ami-/       then ["ec2", "image", parameter]
when /^sg-/        then ["ec2", "security-group", parameter]
when /^vol-/       then ["ec2", "volume", parameter]
when /^snap-/      then ["ec2", "snapshot", parameter]
when /^s3:\/\//    then s3_url_command_line(parameter)
when /^arn:.*:iam:.*:policy\//  then ["iam", "policy", parameter]
# ... etc
```

This allows shortcut commands like:
```bash
swa i-123456 data              # → swa ec2 instance i-123456 data
swa sg-789abc data             # → swa ec2 security-group sg-789abc data
```

### 3. Collection vs. item commands

**Collection commands** (plural, e.g., "instances"):
- List multiple resources
- Apply filters (tags, state, date ranges, AWS API filters)
- Support three output modes:
  - `summary` - One-line per resource (default)
  - `ids` - Just resource identifiers
  - `data` - Full YAML/JSON with optional JMESPath

**Item commands** (singular, e.g., "instance"):
- Address a single resource by ID
- Support inspection (`summary`, `data`)
- Support resource-specific actions (`terminate`, `delete`, `get`, `put`, etc.)

### 4. AWS SDK integration

BaseCommand establishes AWS clients:
```ruby
def aws_config
  @aws_config ||= {}.tap do |config|
    config[:region] = region if region
    config[:credentials] = aws_credentials if aws_credentials
    # ... other config
  end
end
```

Service commands create AWS SDK clients:
```ruby
def ec2
  @ec2 ||= Aws::EC2::Resource.new(aws_config)
end
```

Resource wrappers delegate to SDK objects:
```ruby
class Instance < Swa::Resource
  def summary
    [id, image_id, instance_type, state.name, private_ip_address].join(" ")
  end
end
```

### 5. Data presentation

Resources implement `data()` method to return hash for serialization:
```ruby
def data
  {
    "InstanceId" => id,
    "ImageId" => image_id,
    "InstanceType" => instance_type,
    "State" => state.name,
    # ... etc
  }
end
```

DataOutput handles formatting:
- Applies JMESPath query if specified
- Serializes to YAML (default) or JSON
- Pretty-prints with proper indentation

### 6. Extension points

The architecture makes it easy to add new services or resources:

1. **Add a new service:**
   - Create `lib/swa/cli/new_service_command.rb`
   - Extend `BaseCommand`
   - Define collection and item subcommands
   - Register in `MainCommand`

2. **Add a new resource type:**
   - Create `lib/swa/new_service/new_resource.rb`
   - Extend `Resource` or `Record`
   - Implement `summary()` and optionally `data()`
   - Add command in service command class

3. **Add a new action:**
   - Define method in resource class
   - Add subcommand in item command
   - Handle action-specific options

## Usage patterns

### Basic inspection

```bash
# List resources
swa ec2 instances summary
swa s3 buckets
swa iam users

# Inspect single resource
swa ec2 instance i-123456 data
swa s3 bucket my-bucket data
swa iam user alice data --json
```

### Filtering

```bash
# By tag
swa ec2 instances --tagged environment=prod

# By state
swa ec2 instances --state running

# By AWS API filter
swa ec2 instances --filter availability-zone=us-east-1a

# By date range
swa ec2 snapshots --since "last week"
```

### Querying with JMESPath

```bash
# Extract specific fields
swa ec2 instances data '[].{Id:InstanceId,Type:InstanceType,State:State.Name}'

# Get just IPs
swa ec2 instances data '[].PrivateIpAddress'

# Complex query
swa s3 buckets data '[?CreationDate > `2024-01-01`].Name'
```

### Resource actions

```bash
# EC2
swa ec2 instance i-123456 terminate

# S3
swa s3 bucket my-bucket object mykey get > file.txt
echo "content" | swa s3 bucket my-bucket object mykey put

# IAM
swa iam role my-role assume --session-name mysession

# Glue
swa glue job my-job start
swa glue crawler my-crawler start
```

### Complex operations

```bash
# Athena query execution
swa athena query "SELECT * FROM mytable" -D mydb -O s3://bucket/path/

# Glue database and table addressing
swa glue database mydb table mytable data

# LakeFormation permissions
swa glue database mydb table mytable lf-permissions

# CloudFormation stack inspection
swa cf stack my-stack template
swa cf stack my-stack outputs
```

### Smart shortcuts

```bash
# Automatic resource type detection
swa i-123456 data                    # EC2 instance
swa ami-789abc data                  # EC2 AMI
swa sg-456def data                   # EC2 security group
swa s3://my-bucket/path/file get     # S3 object
swa arn:aws:iam::123:policy/MyPolicy # IAM policy
```

## Development focus areas

Based on recent commit history:
- Glue and LakeFormation integration (active development)
- ARN-based resource addressing
- Enhanced filtering and pattern matching
- Catalog specification for Glue resources

The tool appears to be particularly focused on AWS data services (Glue, Athena, LakeFormation) while maintaining broad coverage of core AWS services.

## Issue Tracking with bd (beads)

**IMPORTANT**: This project uses **bd (beads)** for ALL issue tracking. Do NOT use markdown TODOs, task lists, or other tracking methods.

### Why bd?

- Dependency-aware: Track blockers and relationships between issues
- Git-friendly: Auto-syncs to JSONL for version control
- Agent-optimized: JSON output, ready work detection, discovered-from links
- Prevents duplicate tracking systems and confusion

### Quick Start

**Check for ready work:**
```bash
bd ready --json
```

**Create new issues:**
```bash
bd create "Issue title" -t bug|feature|task -p 0-4 --json
bd create "Issue title" -p 1 --deps discovered-from:bd-123 --json
```

**Claim and update:**
```bash
bd update bd-42 --status in_progress --json
bd update bd-42 --priority 1 --json
```

**Complete work:**
```bash
bd close bd-42 --reason "Completed" --json
```

### Issue Types

- `bug` - Something broken
- `feature` - New functionality
- `task` - Work item (tests, docs, refactoring)
- `epic` - Large feature with subtasks
- `chore` - Maintenance (dependencies, tooling)

### Priorities

- `0` - Critical (security, data loss, broken builds)
- `1` - High (major features, important bugs)
- `2` - Medium (default, nice-to-have)
- `3` - Low (polish, optimization)
- `4` - Backlog (future ideas)

### Workflow for AI Agents

1. **Check ready work**: `bd ready` shows unblocked issues
2. **Claim your task**: `bd update <id> --status in_progress`
3. **Work on it**: Implement, test, document
4. **Discover new work?** Create linked issue:
   - `bd create "Found bug" -p 1 --deps discovered-from:<parent-id>`
5. **Complete**: `bd close <id> --reason "Done"`

### Auto-Sync

bd automatically syncs with git:
- Exports to `.beads/issues.jsonl` after changes (5s debounce)
- Imports from JSONL when newer (e.g., after `git pull`)
- No manual export/import needed!

### MCP Server (Recommended)

If using Claude or MCP-compatible clients, install the beads MCP server:

```bash
pip install beads-mcp
```

Add to MCP config (e.g., `~/.config/claude/config.json`):
```json
{
  "beads": {
    "command": "beads-mcp",
    "args": []
  }
}
```

Then use `mcp__beads__*` functions instead of CLI commands.

### Important Rules

- ✅ Use bd for ALL task tracking
- ✅ Always use `--json` flag for programmatic use
- ✅ Link discovered work with `discovered-from` dependencies
- ✅ Check `bd ready` before asking "what should I work on?"
- ❌ Do NOT create markdown TODO lists
- ❌ Do NOT use external issue trackers
- ❌ Do NOT duplicate tracking systems

For more details, see README.md and QUICKSTART.md.
