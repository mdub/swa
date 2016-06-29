# SWA

SWA is AWS, backwards.

It's an alternative CLI for AWS.

"Backwards" because commands put verbs at the end:

    $ swa ec2 instance i-9336f049 terminate

rather than the front:

    $ aws ec2 terminate-instances --instance-ids i-9336f049

## Listing things

SWA provides sub-commands for listing many types of AWS resource, e.g.

    $ swa ec2 instances

Listing commands typically provide options for refining the search:

    $ swa ec2 instances --tagged purpose=QA --filter availability-zone=ap-southeast-2b

By default you'll get a "summary" view, one line per resource:

    $ swa ec2 instances | head
    i-bcf48c2b  ami-1e73737d  c3.large   running     10.47.5.16    
    i-1990d85c  ami-538e7330  t2.micro   running     10.47.7.25    "blarg/room-service"
    i-f9e6ea27  ami-8bfd7eb1  t2.small   running     10.47.11.54   "blarg/match-feed"
    i-19155e5c  ami-d5327ab6  c3.large   running     10.47.6.238   "fnord-snarfer"
    i-26357e63  ami-eded7ed7  t2.micro   running     10.47.6.96    "fnord-dashboard"
    i-b85f6c87  ami-695a7253  c3.xlarge  running     10.47.5.252   "bam-boozle"
    i-5627e187  ami-d9d779ba  c4.2xlarge running     10.47.11.201  "pub-batch-42"
    i-ced5ae59  ami-eded7ed7  t2.micro   running     10.47.6.22    "atlas-hugged"
    i-63e722b2  ami-8bfd7eb1  t2.small   running     10.47.8.95    "blarg/first-service"

But you can ask for **all** the data, if you wish:

    $ swa ec2 instances data
    ---
    - InstanceId: i-bcf48c2b
      ImageId: ami-1e73537d
      State:
        Code: 16
        Name: running
      PrivateDnsName: ip-10-48-9-16.ap-southeast-2.compute.internal
      PublicDnsName: ''
      ...

Specify `-J` if you like JSON better than YAML.

## Inspecting things

Each "collection" operation has a corresponding "item" operation, e.g.

    $ swa ec2 instance i-bcf48c2b ...

Different resource-types support different sub-commands, but they all implement `data`, which again dumps everything in YAML or JSON format.

    $ swa ec2 instance i-bcf48c2b data

The "item" sub-command can be ommitted, when it can be inferred from the resource-id:

    $ swa ec2 i-bcf48c2b data
    $ swa ec2 ami-1e73737d data

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/swa.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
