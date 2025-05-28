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
    text(fill: blue.darken(60%), it)
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
  === TODO extension and annotations
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
  == Protobuf based RP


  some commonly used RPC framework
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
]



#slide[

  #set text(size: 10pt, font: "Andika")
  #bibliography("./works.bib")
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
