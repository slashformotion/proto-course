# Core Banking Transformation

## "Ideal" protobuf project

### Protobuf structure
```
- proto/
  - <company>/
    - <product>/
      - <version>/
        - <service1>/
          - <service1>.proto
        - <service2>/
          - <service2>.proto
  - <other-company>/
    - ## here vendored stuff
```

```proto
// proto/company/product/version/service1/service1.proto

syntax = "proto3";
package <company>.<product>.<version>.<service1>;

import "google/protobuf/timestamp.proto";
import "google/protobuf/empty.proto";

service <service1>Service {
    rpc CreatePayment(CreatePaymentRequest) returns (CreatePaymentResponse);
}    
```

example: google cloud proto apis https://github.com/googleapis/googleapis/tree/master/google


### Distribution of the proto files

The proto files are distributed in a central repository. On a new release, clients and server code is generated from the proto files and distributed to the respective toolchains repositories (pypi for python, a git repository for go, Nexus for Java, etc.).

## Our issues with protobuf

Main Issues:
- No Linting
- No separation between semi-public (intra ibf) and private APIs (intra payment team)
- Not ready to support vendored proto from other companies
- Not ready to support multiple versions of the same service
- No breaking changes detection

Less problematic issues:
- our proto packages are not well organized
- makefiles are not fun

## Proposed solution

### Protobuf structure
```
- api/
  - app/ (keep old way to do things here)
    - payment-manager/
    - ...
  - ibanfirst/
    - payment/
      - payment_manager/
        - payment_manager_internal/v0/
          - ... (internal protos)
        - reconciliation/v2/
            - reconciliationv2.proto
        - reconciliation/v3
            - reconciliationv3.proto
      - instant-sepa/
      - fund-api/
```

This is also the moment to fix our protobuf package naming.
- old: `api.file_generator.v1`;
- new: `ibanfirst.payment.file_generator.payment_initiation.v1`;

Alternatively we could remove the "app" layer altogether like google is doing but I would likely mean having to maintain grpc reverse proxy (I personally really like the idea but ibanfirst proxy infrastructure is probably not mature enough to fully support this in a declarative way).

#### HTTP routes versioning and breaking changes

Currently we have no way upgrade our semi-public APIs without porting all the RPCs of the previous version. I suggest we separate the semi-public and private APIs to make small semi-public proto packages that will be easier to upgrade.

For example current folder app/api/payment-manager contains the protos for:
- the reconciliation api for FX (semi-public)
- the client payment api for assistant (semi-public)
- the safeguarding cashflow initiation api for website (semi-public)
- the PSR api for the new BO (semi-public)
- the external cashflow api for HUF and BGN (semi-public)
- the FX cashflow api  (semi-public)
- the payment channel api for the BO (semi-public) 
- the scheduled payment api for the BO (semi-public)
- the "validate payment" api for the BO (semi-public)
- the remaining RPCs are internal

if we were to release a new version of one of the RPCs in this package, we would have to port all the RPCs of the next version to maintain a feature parity with the previous version.

By splitting the proto in different packages, we can have a more granular approach to versioning and breaking changes.

The URL scheme right now looks like this:

```
https://hostname:port/api/v1/payment/create
```
we can change our url scheme to reflect the new package structure:
```
https://hostname:port/<api_name>/<api_version>/.....

ex:
https://payment-manager.ibf.com/reconciliation/v2/create
https://payment-manager.ibf.com/reconciliation/v2/delete

new version:
https://payment-manager.ibf.com/reconciliation/v3/delete
https://payment-manager.ibf.com/reconciliation/v3/create

internal api if we decide to keep http for internal data transfer:
https://payment-manager.ibf.com/internal/v0/breakingchangesallowed

```
### Change our proto build tool to buf

buf if a protobuf build tool that is very similar to protoc. It is a lot more powerful and has a lot of features that protoc does not have.

buf will manage every proto in the api folder except the api/app folder.
The protos in the api/app folder are managed by protoc, and will be moved to the buf managed portion once we figure out the api segmentation.

buf is already in the builder image in the version `v.0.1.0`

buf has a simple configuration:
see https://git.ibanfirst.tech/ibanfirst-product/payment/DHL/core-banking/-/merge_requests/1683 for an example.

