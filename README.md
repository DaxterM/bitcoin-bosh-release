# bitcoin-bosh-release
# BOSH release for bitcoin

This is a a bosh release for a full bitcoin node.

### Upload the BOSH releases

To use this BOSH release first upload it to your BOSH:

```
bosh target BOSH_HOST
bosh upload release https://github.com/DaxterM/bitcoin-bosh-release/releases/download/1.0.0/bitcoin-bosh-release-1.tgz
```



### Example AWS BOSH deployment manifest
```
---
name: Bitcoin

director_uuid: Replace_With_Director_ID

releases:
- name: bitcoin-bosh-release
  version: latest


stemcells:
- alias: trusty
  os: ubuntu-trusty
  version: latest

instance_groups:
- name: Bitcoin
  instances: 1
  vm_type: large


  stemcell: trusty
  azs: [us-east-1a]

  persistent_disk_type: large
  networks:
      - name: default
        default: [dns, gateway]
      #- name: vip #Optional if you want to use Elastic IP
      #  static_ips: [Your.ELB.IP.HERE] #Optional if you want to use Elastic IP
  jobs:
  - name: bitcoin
    release: bitcoin-bosh-release


update:
  canaries: 1
  max_in_flight: 1
  serial: false
  canary_watch_time: 1000-60000
  update_watch_time: 1000-60000

```
### Example AWS cloud config
```
azs:
- name: us-east-1a
  cloud_properties: {availability_zone: us-east-1a}

vm_types:
- name: small
  cloud_properties:
    instance_type: t2.micro
    ephemeral_disk: {size: 3000, type: gp2}
    auto_assign_public_ip: True
- name: large
  cloud_properties:
    instance_type: m3.large
    ephemeral_disk: {size: 30000, type: gp2}
    auto_assign_public_ip: True




disk_types:
- name: small
  disk_size: 3000
  cloud_properties: {type: gp2}
- name: large
  disk_size: 50_000
  cloud_properties: {type: gp2}

networks:
- name: default
  type: manual
  subnets:
  - range: 10.0.10.0/24
    gateway: 10.0.10.1
    az: us-east-1a
    static: [10.0.10.62]
    dns: [10.0.10.2]
    reserved: [10.0.10.2-10.0.10.10]
    cloud_properties:
      subnet: Replace_With_AWS_Subnet-ID


- name: vip
  type: vip

compilation:
  workers: 5
  reuse_compilation_vms: true
  az: us-east-1a
  vm_type: large
  network: default

```
