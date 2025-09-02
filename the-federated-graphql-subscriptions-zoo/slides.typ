#import "@preview/touying:0.6.1": *
#import themes.simple: *

// Absolute placement
#import "@preview/pinit:0.2.2": *

// Code blocks
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()

#set quote(block: true, quotes: true)

#let talk_title = "The Federated GraphQL Subscriptions Zoo"
#let grafbase_green = rgb(7, 168, 101)

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: talk_title,
    subtitle: [],
    author: [Tom Houlé],
    date: "2025-09-08",
    institution: [Grafbase],
  ),
  config-common(
    preamble: {
      codly(languages: codly-languages, zebra-fill: none, display-name: false)
    }
  )
)

#set text(size: 20pt, font: ("Inter"))

#title-slide[
  #figure(
    image("../grafbase-logo.svg", width: 16%)
  )

  #text(size: 55pt, weight: "bold")[
    The #text(stroke: grafbase_green, fill: grafbase_green)[Federated GraphQL Subscriptions] Zoo\
    🐢🦏🦧🦬🦉
  ]

  #text(size: 20pt)[Tom Houlé]
]

== Subscriptions are special... in GraphQL

#quote(attribution: link("https://spec.graphql.org/draft/#sel-GAFTJFABOBjDywM")[GraphQL spec (draft)])[
   a long-lived request that fetches data in response to a sequence of events over time
]

#pause

#quote(attribution: link("https://spec.graphql.org/draft/#sec-Type-Name-Introspection")[GraphQL spec (draft)])[
  GraphQL supports type name introspection within any selection set in an operation, with the single exception of selections at the root of a subscription operation.
]

== Subscriptions are special... in GraphQL

#pause

#quote(attribution: link("https://spec.graphql.org/draft/#sel-HALPJDDHBCBJ4uR")[GraphQL spec (draft)])[
  Subscription operations must have exactly one root field.

  To enable us to determine this without access to runtime variables, we must forbid the \@skip and \@include directives in the root selection set.
]

#pause

#quote(attribution: link("https://spec.graphql.org/draft/#note-80ec0")[GraphQL spec (draft)])[
   While each subscription must have exactly one root field, a document may contain any number of operations, each of which may contain different root fields. When executed, a document containing multiple subscription operations must provide the operation name as described in GetOperation().
]

== Subscriptions are special... in GraphQL-over-HTTP

#pause

#quote(attribution: link("https://graphql.github.io/graphql-over-http/draft/#sel-EAFPCBJBSqsJ")[GraphQL over HTTP spec (draft)])[
   GraphQL Subscriptions are beyond the scope of this specification at this time.
]

== Subscriptions are actually not that special in Federated GraphQL

#pause

#block[
  #set text(size: 17pt)

  #columns(2)[
  Schema of the sales subgraph:

  ```graphql
  type Product @key(fields: "id") {
    id: ID!
  }

  type Subscription {
    productSales: Product
  }
  ```
  #colbreak()

  Schema of the products subgraph:

  ```graphql
  type Product @key(fields: "id") {
    id: ID!
    name: String!
  }

  type Query {
    productById(
      id: ID!
    ): Product @lookup
  }
  ```
  ]
]


== Subscriptions are actually not that special in Federated GraphQL

#block[
  #set text(size: 17pt)

  #columns(2)[

    #v(4em)

    Client -> Gateway

  ```graphql
  subscription ProductSalesWithName {
    productSales {
      name
    }
  }
  ```

  #colbreak()

  Gateway -> sales subgraph

  ```graphql
  subscription {
    productSales {
      id
    }
  }
  ```

  Gateway -> products subgraph

  ```graphql
  query {
    productById(id: $id) {
      name
    }
  }
  ```

  ]
]

== Subscriptions are actually not that special in Federated GraphQL

Data returned to the client:

```json
{"name":"Labubu"}
{"name":"Labubu"}
{"name":"Crocs"}
{"name":"Zune"}
{"name":"Furbies (12 pack)"}
{"name":"Labubu"}
{"name": "Google Glass"}
```

== The problems with Federated Subscriptions

- Lack of transport standardisation has led to fragmentation:
  - WebSockets (HTTP/1.1)
  - SSE (HTTP/2 and 3)
- Stateful connections impose extra burden on the subgraphs and the gateway
- Connection loss is both more likely and harder to handle
- One connection between the Gateway and the relevant subgraph per subscribed client, even when they all subscribe to the same events
- Multi-protocol subscriptions

== Multi-protocol subscriptions

- 🖊️ Client --- 🍍-> Gateway --- 🍎-> 🖊️ Subgraph

#pause

- At each step, one of
  - SSE,
  - WebSockets
    - `subscriptions-transport-ws`
    - `graphql-ws` / `graphql-transport-ws`
- And different handshake shapes between each!
  - Headers vs init payload formats
  // you have to think about just like header forwarding, but separate, and more complicated with the mappings

#pause

#absolute-place(dx: 30%, dy:50%, figure(image("./penpineappleapplepen.png", width: 60%)))

== Event queue to gateway

- Two implementations
  - #link("https://cosmo-docs.wundergraph.com/router/event-driven-federated-subscriptions-edfs#the-%E2%80%9Csubjects%E2%80%9D-argument")[EDFS]
  - #link("https://grafbase.com/docs/extensions")[Grafbase extensions]

== Takeaways

- Pros of traditional federated subscriptions
  - Federate existing GraphQL subgraphs, no need to modify them
  - Subscription fields are managed directly in your subgraphs, next to your other logic

#pause

- Pros of subscriptions offloaded to a message queue
  - Stream deduplication
  - Non-GraphQL services can publish to subjects directly

#pause

#align(center)[
  #text(weight: "bold")[You can mix and match both approaches]
]

== Conclusion

Take care.

== Also

#v(3em)

#text(size: 25pt)[
#pause Workshop! #pause Tomorrow! #pause

Grote Zaal - 2nd Floor. #pause 10:45am #pause.
]

= Appendices

== Links

- WebSockets
  - #link("https://github.com/enisdenjo/graphql-ws/issues/3")[Issues and security implications with subscriptions-transport-ws]
- SSE
  - #link("https://github.com/enisdenjo/graphql-sse/blob/master/PROTOCOL.md")[GraphQL-SSE spec]
- #link("https://www.youtube.com/watch?v=NfuiB52K7X8")[Pen Pineapple Apple Pen]
