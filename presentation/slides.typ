#import "@preview/polylux:0.4.0": *
#import "@preview/friendly-polylux:0.1.0" as friendly
#import friendly: titled-block

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()

#codly(languages: codly-languages, zebra-fill: black.lighten(98%))

#show link: it => {
  if type(it.dest) == str {
    // Style links to strings red
    text(fill: blue.darken(50%), it)
  } else {
    // Return other links as usual
    it
  }
}

#show: friendly.setup.with(
  short-title: [Intro to the proto/RPC ecosystem],
  short-speaker: [Théophile Roos],
)

#set heading(numbering: "1.1.1")
#set text(size: 20pt, font: "Andika")
#show raw: set text(font: "Fantasque Sans Mono")
// #show math.equation: set text(font: "Lete Sans Math")

#friendly.title-slide(
  title: [
    #set text(size: 25pt, font: "Andika")
    Introduction to the protobuf ecosystem],
  speaker: [Théophile Roos],
  conference: [for: iBanfirst R&D Payment Team],
  speaker-website: "orness.com", // use `none` to disable
  slides-url: "https://github.com/slashformotion/proto-course", // use `none` to disable
  qr-caption: text(font: "Excalifont")[Get these slides],
  logo: stack(dir: rtl)[#image("assets/orness.png", width: 55%)][#h(1fr)][#image("assets/ibf.jpeg", width: 25%)],
)
#slide[

  #set text(size: 12pt, font: "Andika")
  #columns(2)[#outline()]
]

#slide[
  = What is protobuf ?

  Short for Protocol Buffers: an efficient, language-neutral data serialization format developed by Google

  - Much smaller and faster than formats like JSON or XML
  - Strong Typing and Schema: strict structure of the data defined in `.proto` files, enabling forward and backward compatibility
  - Used for many use-cases: synchronous communication between network services, async communication through brokers systems (Kafka, RabbitMQ...), WebAssembly interfaces...
]


#slide[
  == Syntax

  #toolbox.side-by-side[
    Protobuf syntax versions
    - `proto2`: legacy should not be used
    - `proto3`: most used version currently
    - `revision <year>`: new version with very limited support
  ][
    First line of the `.proto` file
    ```proto
    syntax = "proto3";
    // syntax = "proto2";
    // edition = "2023";
    ```
    #line(length: 100%)
    no syntax specified: proto2 assumed
  ]
]

#slide[
  === Message definition

  #toolbox.side-by-side[
    Message definition
    ```proto
    message User {
      string name = 1 [json_name = "name"];
      optional int32 age = 2 [default = 18];

      // a comment
      repeated string hobbies = 3;

      map<string, int32> ibanToBalance = 4;
    }
    ```

  ][
    Fields are defined with:
    - a FieldType: #link("https://protobuf.dev/programming-guides/proto3/#scalar")[int32, string, bool, bytes, etc].
    - a #link("https://protobuf.dev/programming-guides/proto3/#specifying-types")[FieldName]: name, age, etc.
    - a #link("https://protobuf.dev/programming-guides/proto3/#field-labels")[Field Cardinality]: optional, required, repeated, etc.

    notes:
    - _maps can't be repeated_

  ]
]

#slide[
  === Enum definition

  #toolbox.side-by-side[
    ```proto
    enum USER_TYPE {
      // a comment
      USER_TYPE_UNSPECIFIED = 0;
      USER_TYPE_REGULAR = 1;
      USER_TYPE_GUEST = 2;
      USER_TYPE_ADMIN = 3;
    }

    message User {
      // ...
      USER_TYPE user_type = 3;
    }
    ```

  ][
    The enum has a default value, which is the first value defined in the enum and with the FieldNumber `0`.

  ]
]

#slide[
  === Enum definition (Aliases)

  #toolbox.side-by-side[
    ```proto
    enum Corpus {
      option allow_alias = true;

      CORPUS_UNSPECIFIED = 0;
      CORPUS_UNIVERSAL = 1;
      CORPUS_WEB = 2;
      CORPUS_WWW = 2;
    }

    ```

  ][
    Message and enums can have options defined with the option keyword.
  ]
]

#slide[
  === Message Composition

  #toolbox.side-by-side[
    ```proto
    // user.proto
    import "user_type.proto";

    message User {
      // ...
      USER_TYPE user_type = 3;
    }

    message Organisation {
      string name = 1;
      repeated User users = 2;
    }
    ```

  ][
    ```proto
    // user_type.proto
    enum USER_TYPE {
      // a comment
      USER_TYPE_UNSPECIFIED = 0;
      USER_TYPE_REGULAR = 1;
      // ...
    }
    ```
  ]
  An _Organisation_ contains a list of _User_ wich contain a field of type _USER_TYPE_
]



#slide[
  === Nested Types

  #toolbox.side-by-side[
    ```proto
    message User {
      enum USER_TYPE {
        USER_TYPE_UNSPECIFIED = 0;
        USER_TYPE_REGULAR = 1;
        // ...
      }
      // ...
      USER_TYPE user_type = 3;
    }
    ```

  ][
    Using nested type outside of the parent message definition
    ```proto
    message UserProfile {
      User.USER_TYPE type = 1;
    }
    ```
  ]
]


#slide[
  === oneof

  #toolbox.side-by-side[
    ```proto
    enum USER_TYPE {
      // ...
    }
    enum ADMIN_TYPE {
      // ...
    }

    message User {
      // ...
      oneof type {
        USER_TYPE user_type = 3;
        ADMIN_TYPE admin_type = 4;
      }
    }
    ```

  ][
    Using oneof to define a field that can be either a user or an admin.

    Only one field of the oneof can be set at a time.

    => avoid using oneof if possible because of restrictions on the backward compatibility.
  ]
]


#slide[
  === Packages
  file structure:
  ```
  ./foo/bar/baz.proto
  ./fizz/buzz.proto
  ```
  #toolbox.side-by-side[
    ```proto
    // foo/bar/baz.proto
    package foo.bar;

    message Baz {
      // ...
    }
    ```
  ][
    ```proto
    // fizz/buzz.proto
    package fizz;

    import "foo/bar/baz.proto";

    message Buzz {
      foo.bar.Baz baz = 1;
    }
    ```
  ]
]


#slide[
  === Service definition
  #toolbox.side-by-side[
    ```proto
    message GetUserRequest {
      string username = 1;
    }
    message GetUserResponse {
      User user = 1;
    }

    service UserService {
      rpc GetUser(GetUserRequest) returns (GetUserResponse);
      // rpc DeleteUser(DeleteUserRequest) returns (DeleteUserResponse);
    }
    ```
  ][
    A service _UserService_ is defined with an RPC method _GetUser_ that takes a _GetUserRequest_ and returns a _GetUserResponse_.


  ]
]

#slide[
  === Option and Annotation
  Protobuf has a way to add metadata to the messages and fields.

  #toolbox.side-by-side[
    ```proto
    message User {
      string name = 1 [json_name = "name"];
    }
    ```
    The `json_name` field option is used to define the name of the field when it is serialized to JSON.
  ][
    ```proto
    import "google/protobuf/descriptor.proto";

    extend google.protobuf.FieldOptions {
      string field_suffix = 12345; // this must be unique
    }
    message User {
      string name = 1 [(field_suffix)= "This is the user's name"];
    }
    ```
  ]
]

#slide[
  == Usefull links

  #set text(size: 15pt, font: "Andika")
  - Official documentation: https://protobuf.dev/overview/
  - Un-official (but very good) documentation by the #link("https://buf.build/")[Buf team]: https://protobuf.com/docs/introduction

  - Third party protoc code generation plugins: https://github.com/protocolbuffers/protobuf/blob/main/docs/third_party.md
  - Registed protobuf extension: https://github.com/protocolbuffers/protobuf/blob/main/docs/options.md#existing-registered-extensions

  - somewhat standard google protobuf definitions: https://github.com/googleapis/googleapis
]

#slide[
  = RPCs

  #link("https://en.wikipedia.org/wiki/Remote_procedure_call")[_Remote Procedure Calls_]: a way to call a function on a remote server

  RPC based communication is pattern with many different implementations @rpcWiki:

  - NFS: Network File System
  - JSON-RPC: an RPC protocol that uses JSON-encoded messages.
  - gRPC is a modern open source RPC framework that uses HTTP/2 and Protocol Buffers.
  - IBM AIX: use of RPC in the AIX operating system. @aixRpc
]

#slide[
  == Protobuf based RPC

  Some commonly used RPC framework

  #table(
    stroke: .5pt + black,
    columns: (auto, auto, auto, auto),
    table.header(
      [Framework],
      [Transport Layer],
      [Code Generation],
      [Notable Features],
    ),

    [gRPC], [HTTP/2], [Yes], [Streaming, TLS, strong ecosystem],
    [ConnectRPC], [HTTP], [Yes], [Streaming, TLS, wide platform support],
    [Ranger RPC], [HTTP (any version)], [Yes], [Simple, fast, Go-centric],
    [Apache Thrift], [Any], [Yes], [Simple, fast, C++-centric],
    [trpc], [Any], [No], [Pure TypeScript],
  )
  #v(1fr)

  Side notes: gRPC can also use alternative serialization formats but it's uncommon.
]

#slide[
  == gRPC

  - gRPC: "gRPC Remote Procedure Calls"
  - Started by Google in 2015, now a project of the #link("https://www.cncf.io")[Cloud Native Computing Foundation]
  - Transport layer: HTTP/2
  - Interface Definition Language: Protocol Buffers
  - Open-Source: Apache License 2.0
  - Most used RPC framework

  - Development by RFCs: https://github.com/grpc/proposal

  Docs: https://grpc.io
]

#slide[
  == gRPC Features/Concepts

  - Unary and Streaming RPC (client, server and bidirectional)
  - Metadata (headers)
  - Interceptors (middleware)
  - Trailing metadata (HTTP/2 Trailers): used to send status codes, errors, etc.
  - Deadlines/Timeouts: client communication timeouts to the server, which can know much time is left to respond.
  - Cancellation: can be done by the client or the server, works on the server stops when the RPC is cancelled.
  - Proxyless Load balancing: gRPC supports load balancing directly on the client side with the xDS protocol (xDS-based service discovery using a control plane)
]

#slide[
  == gRPC-ecosystem

  #grid(
    columns: (1fr, 2fr),
    gutter: 1em,
    [Suite of tools and libraries for gRPC

      - _gRPC-gateway_ : tool that converts gRPC APIs into RESTful APIs. Used to support legacy clients that are not capable of using gRPC.],
    [#image("assets/gtw.svg")],
  )

  - _openapiv2_ : OpenAPI v2 specification generator for gRPC services.
  - _grpc-opentracing_ : OpenTracing instrumentation for gRPC.
  - _grpc-health-probe_ : gRPC health checking service.

  Docs: https://github.com/grpc-ecosystem/
]

#slide[
  = Tools

  - *protoc*: official compiler, usually used with makefiles.\
    - pros: official implementation, very flexible (almost to much).
    - cons: somewhat slow, makefiles are not fun, no linting, mandatory vendoring.

  - *prototool* @prototool: deprecated but still used protobuf toolchain created by Uber.
    - pros: fast, good integration with IDEs, linting.
    - cons: no package management, deprecated and unmaintained.

  - *buf*: new protobuf toolchain, created by buf.build @bufCompany.
    - pros: fast, good integration with IDEs, linting, package management.
    - cons: remote plugins send your code to their cloud

]

#slide[
  == Official protobuf compiler: protoc
  Open-Source Code: https://github.com/protocolbuffers/protobuf .
  Use plugins to generate code and artifacts from `.proto` files.

  #toolbox.side-by-side[
    ```bash
    $ ls
    ./proto/foo/bar/baz.proto # our proto
    ./third_party/googleapi/annotation.proto
    # vendored protos
    ```
  ][
    ```bash
    protoc --proto_path=./protos \
      --proto_path=./third_party \
      --go_out=paths=source_relative:. \
      --go-grpc_out=paths=source_relative:. \
    ```
    calls (args passed via stdin):
    - protoc-gen-go
    - protoc-gen-go-grpc
  ]
  Proto files are managed manually (vendored proto code see @descriptorVendored)
]
#slide[
  === Issues with protoc
  Version/pinning issues:
  - plugins versions are not pinned (you manage yourself your installation)
  - dependencies are not pinned (you manage yourself the vendoring)
  - homemade makefiles and/or shell scripts are required to automate the compilation
  - (protoc version depends on your package manager or installation method)

  Quality of code issues:
  - No linting
  - Modern IDE support is almost inexistent


]

#slide[
  == buf.build cli: buf

  All in one tool to manage your protobuf code using configuration first approach.

  Version/pinning issues:
  - #strike[plugins versions are not pinned (you manage yourself your installation)]\
    #text(fill: red.darken(10%))[caveat: this require remote plugins]
  - #strike[dependencies are not pinned (you manage yourself the vendoring)]
  - #strike[homemade makefiles and/or shell scripts are required to automate the compilation]
  - #strike[(protoc version depends on your package manager or installation method)]\
    #text(fill: red.darken(10%))[caveat: this require pinning the buf cli]

  Quality of code issues:
  - #strike[No linting]
  - #strike[Modern IDE support is almost inexistent] https://buf.build/docs/cli/editor-integration/
  - #"+" Breaking change detection, gRPC curl ...
]

#slide[
  === Migrating from protoc to buf
  #set text(size: 14pt, font: "Andika")
  #toolbox.side-by-side[
    #heading(level: 4, numbering: none)[with protoc]
    ```bash
    protoc --proto_path=./protos \
      --proto_path=./third_party \
      --go_out=paths=source_relative:. \
      --go-grpc_out=paths=source_relative:. \
    ```
    calls (args passed via stdin):
    - protoc-gen-go
    - protoc-gen-go-grpc
  ][
    #heading(level: 4, numbering: none)[with buf]
    ```yaml
    #buf.yaml
    version: v2
    modules:
      - path: proto
    deps:
      - buf.build/googleapis/googleapis
      - buf.build/bufbuild/protovalidate
    lint:
      use: [ "STANDARD"]

    # buf.gen.yaml
    version: v2
    plugins:
      - name: go # managed plugin
        out: .
        opt: paths=source_relative
      - name: go-grpc # managed plugin
        out: .
        opt: paths=source_relative
    ```
    generate Go code with `buf generate`
  ]
]

#slide[
  #set text(size: 10pt, font: "Andika")
  #bibliography("./works.bib", full: true, style: "ieee", title: "References")
]

#friendly.last-slide(
  title: [That's it!],
  project-url: "https://github.com/slashformotion/proto-course",
  qr-caption: text(font: "Excalifont")[Get these slides],
  contact-appeal: [Get in touch #emoji.hand.wave],
  // leave out any of the following if they don't apply to you:
  // email: "theophile.roos@protonmail.com",
  // mastodon: "@foo@baz.org",
  website: "https://orness.com",
)
