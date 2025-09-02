#import "@preview/touying:0.6.1": *
#import themes.simple: *

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

// Code blocks
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()

#set quote(block: true, quotes: true)

#let talk_title = "Authorization in Federated GraphQL"
#let grafbase_green = rgb(7, 168, 101)

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: talk_title,
    subtitle: [],
    author: [Tom Houlé],
    date: "2025-  09-08",
    institution: [Grafbase],
  ),
  config-common(
    preamble: {
      codly(languages: codly-languages, zebra-fill: none)
    }
  )
)

#set text(size: 20pt, font: ("Inter"))

#title-slide[
  #figure(
    image("../grafbase-logo.svg", width: 20%)
  )

  #text(size: 68pt, weight: "bold")[
    Authorization in #text(stroke: grafbase_green, fill: grafbase_green)[Federated GraphQL]
  ]

  #text(size: 20pt)[Tom Houlé]
]

== Federated GraphQL

#v(2em)
#align(center)[
#diagram(
  {
    let client_a = (0, 0)
    let client_b = (0, 1)
    let gateway = (1, 0.5)
    let subgraph_a = (2, 0)
    let subgraph_b = (2, 1)
    let service_a = (2, 2)
    node(client_a, "Client A")
    node(client_b, "Client B")
    node(gateway, "Gateway")
    node(subgraph_a, "Subgraph A")
    node(subgraph_b, "Subgraph B")
    node(service_a, "Service A")
    edge(client_a, gateway, "->")
    edge(client_b, gateway, "->")
    edge(gateway, subgraph_a, "->")
    edge(gateway, subgraph_b, "->")
    edge(gateway, service_a, "->")
  }
)
]

== Why Authorize in the Gateway

- First point of contact to the outside world
#pause
- Whole schema view
#pause
- Whole request context
#pause
- Entity resolvers make subgraphs lose context

== Entity resolvers make subgraphs lose context

#text(size: 18pt)[
#box(width: 40%, baseline: -50pt)[
 ```graphql
 query {
     currentUser {
         directMessages {
             author { name }
             content
         }
     }
 }
 ```

]
#box(baseline: -150pt, width: 8%)[#align(center)[VS]]
#box(width: 50%)[
  ```graphql
  query {
    _entities(representations: [{ __typename: "User", id: "1" }]) {
      ... on User {
        directMessages {
          author { name }
          content
        }
      }
    }
  }
  ```

]
]

== Federation v2 Standard Directives

```graphql
directive @authenticated on
    FIELD_DEFINITION
  | OBJECT
  | INTERFACE
  | SCALAR
  | ENUM
```

== Federation v2 Standard Directives

```graphql
directive @requiresScopes(scopes: [[federation__Scope!]!]!) on
    FIELD_DEFINITION
  | OBJECT
  | INTERFACE
  | SCALAR
  | ENUM
```

== Federation v2 Standard Directives

```graphql
directive @policy(policies: [[federation__Policy!]!]!) on
    FIELD_DEFINITION
  | OBJECT
  | INTERFACE
  | SCALAR
  | ENUM
```

== Limitations

== Extensions as the next steps

== Why integration with the query planner matters

== ABAC and ReBAC

== Conclusion

Workshop tomorrow in ...

= Links
