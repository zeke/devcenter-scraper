---
title: Heroku Postgres Production Tier Technical Characterization
slug: heroku-postgres-production-tier-technical-characterization
url: https://devcenter.heroku.com/articles/heroku-postgres-production-tier-technical-characterization
description: The performance characteristics of Heroku Postgres tiers, based on their multitenancy, CPU, RAM and I/O architectures.
---

>note
>All the information in this document is subject to change as Heroku  adapts the service to better handle customer database workloads.

The Heroku Postgres [Standard, Premium, and Enterprise tier] (https://devcenter.heroku.com/articles/heroku-postgres-plans#standard-tier) plans offer different performance characteristics based on their multitenancy, CPU, RAM and I/O architectures.  This article provides a technical description of the implementation of these production plans, and some of the performance characteristics of each.

## Performance characteristics

The following table outlines our production tier plans along with relevant
specifications about the underlying hardware.

| Heroku Postgres plan   | vCPU | RAM     | PIOPs  | Multitenant   | Connection Limit | Disk Size |
| ---------------------- | ---- | ------- | ------ | ------------- | ---------------- | --------- |
| Yanari                 | 2    | 400MB   | 200    | yes           | 60               | 64 GB     |
| Tengu                  | 2    | 1.7GB   | 200    | yes           | 200              | 256 GB    |
| Ika                    | 2    | 7.5GB   | 500    | no            | 400              | 512 GB    |
| Baku                   | 4    | 34.2GB  | 1000   | no            | 500              | 1 TB      |
| Mecha                  | 8    | 68.4GB  | 2000   | no            | 500              | 1 TB      |
| Ryu                    | 32   | 244GB   | 4000   | no            | 500              | 1 TB      |



## Legacy Performance characteristics

The following table outlines our production tier plans along with relevant
specifications about the underlying hardware.

| Heroku Postgres plan   | vCPU | RAM     | PIOPs  | Multitenant  |
| ---------------------- | ---- | ------- | ------ | ------------- |
| Crane                  | 2    | 400MB   | 200    | yes           |
| Kappa                  | 2    | 800MB   | 200    | yes           |
| Ronin                  | 1    | 1.7GB   | 200    | no            |
| Fugu                   | 1    | 3.75GB  | 200    | no            |
| Ika                    | 2    | 7.5GB   | 500    | no            |
| Zilla                  | 2    | 17.1GB  | 750    | no            |
| Baku                   | 4    | 34.2GB  | 1000   | no            |
| Mecha                  | 8    | 68.4GB  | 2000   | no            |

## Multitenancy 

Heroku Postgres databases currently run on virtualized infrastructure provided by AWS EC2. Higher level Heroku Postgres plans benefit from higher levels of resource isolation than lower level plans.

There are two main variants of database deployment architectures on Heroku Postgres: multi-tenant and single-tenant. 

For multi-tenant plans, several LXC containers are created within a single large instance. Each LXC container holds a single database service and provides security and resource isolation within the instance.   

Resource isolation and sharing on multi-tenant plans is imperfect and absolutely fair resource distribution between tenants cannot be guaranteed under this architecture.

For single-tenant plans, a customer's database and related management software are the sole residents of resources on the instance, offering more predictable and less variable performance. However, virtualized infrastructure is still subject to some resource contention and minor performance variations are expected.

## Architecture, vCPU, RAM and I/O

All Heroku Postgres plans run on 64-bit architectures, ensuring best performance
for internal Postgres operations, and interoperability with other features like [Forks](https://devcenter.heroku.com/articles/heroku-postgres-fork) and
[Followers](https://devcenter.heroku.com/articles/heroku-postgres-follower-databases)
across all production tier plans.

vCPU are the number of virtual processors on the underlying instance. Larger number of vCPUs
provide higher performance on the virtual server or instance.

RAM is the approximate amount of memory used for data caching. An in-depth
discussion on Postgres caching can be found in [Understanding Heroku Postgres Data Caching](https://devcenter.heroku.com/articles/understanding-postgres-data-caching).

All instances are backed by EBS optimized instances where EBS disks with provisioned IOPs
 are attached. PIOPs are a measure of how many IO operations the underlying disks can perform
per second. The amount of IOPs provisioned for each plan determines its I/O throughput. 
On write-heavy applications, I/O can be a significant bottleneck, but on read-heavy ones, your
hot dataset should fit in RAM and can therefore have very high performance with
lower IOPs values.