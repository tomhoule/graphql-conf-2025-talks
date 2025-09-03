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
#box(width: 40%, baseline: -20pt)[
 ```graphql
 query {
     currentUser {
         friends {
             profilePictureUrl
             name
             photos {
                 url
             }
         }
     }
 }
 ```

]
#box(baseline: -150pt, width: 8%)[#align(center)[VS]]
#box(width: 50%, baseline: -20pt)[
  ```graphql
  query {
    _entities(representations: [{ __typename: "User", id: "1" }]) {
      ... on User {
          profilePictureUrl
          name
          photos {
              url
          }
    }
  }
  ```

]
]

== Federation v2 Standard Directives

#pause

- They work with _claims_
- Claims are derived from:
  - JWT claims
  - Coprocessors

== Federation v2 Standard Directives

```graphql
directive @authenticated on
    FIELD_DEFINITION
  | OBJECT
  | INTERFACE
  | SCALAR
  | ENUM
```

Allows accessing the field or type when the request carries _any_ accepted JWT.

== Federation v2 Standard Directives

```graphql
directive @requiresScopes(scopes: [[federation__Scope!]!]!) on
    FIELD_DEFINITION
  | OBJECT
  | INTERFACE
  | SCALAR
  | ENUM
```

Allows accessing the field or type when the request has the required scopes/claims.

The outer list wrapper is interpreted as OR. The inner list wrapper is interpreted as AND.

== Federation v2 Standard Directives

```graphql
directive @policy(policies: [[federation__Policy!]!]!) on
    FIELD_DEFINITION
  | OBJECT
  | INTERFACE
  | SCALAR
  | ENUM
```

Calls coprocessors or scripts for the given policies. A policy is just a name. The coprocessor has access to claims and context like request headers.

== Federation v2 Standard Directives

#align(horizon)[

```graphql
type Query {
    adminDashboard: AdminDashboard
        @policy(policies: [
            ["ip_not_marked_as_potentially_fraudulent"],
            ["is_support_agent", "in_business_hours"],
        ])
}
```
#v(2em)
]

== Limitations

- The directives above are sufficient to enable RBAC and limited ABAC. Scopes can match roles, or more targeted permissions.

#pause

- The authorization decisions can however not be tied to the GraphQL query contents
  - The GraphQL document itself: what fields are requested, and at what paths (example: `User.friends`)
  - The data passed in: arguments from literals and variables

#pause

- -> _Relationships_ cannot be enforced
  - Users can see the photos on the profile of their friends
  - I can see the balance on my own bank account
  - I can see the medical records of my own patients

== Comprehensive authorization in the Gateway

#pause

- We want to make authorization decisions based on:
  - Request data
  ```graphql
  query {
      user(id: "user_015f91b8-eb7a-418a-8193-f72ddea5760d") {
          socialSecurityNumber
      }
  }
  ```

#pause

  - And in some cases in response data too

== Comprehensive authorization in the Gateway

```graphql
type User @key(fields: "id") {
    id: ID!
    email: String!
    userType: UserType
    socialSecurityNumber: String @policy(policies: ["check_access_to_user_ssn"])
}
```

Assume we need the `id` and `userType` of the user in addition to the current request context to control access to the social security number.

== Comprehensive authorization in the Gateway

Looks good, but...

```graphql
query {
    userByEmail(email: "george@pizzahut.com") {
        socialSecurityNumber
    }
}
```

The `id` and `userType` fields are not going to be available, so our plugin / coprocessor does not have the data it needs to make authorization decisions.

== Query planner involvement

It sounds like we need `@requires`:

```graphql

```

Like require, but _without external_.

- Pass the relevant input data

Realization: we sometimes need more than the requested data to make authorization decisions

```graphql
query {
  apartments {
    tenant {
      socialSecurityNumber
    }
  }
}
```

I'm only allowed to see the social security number on tenants.

== Why integration with the query planner matters

- Batching

== ABAC and ReBAC

== Also

#v(3em)

#text(size: 25pt)[
#pause Workshop! #pause Tomorrow! #pause

Grote Zaal - 2nd Floor. #pause 10:45am.

#pause Thank you!
]

= Links
