#import "@preview/touying:0.6.1": *
#import themes.simple: *

// Absolute placement
#import "@preview/pinit:0.2.2": *

// Diagrams
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

#align(center + horizon)[
#diagram(
  {
    node((0, 0), "Client A", name: <client_a>)
    node((0, 1), "Client B", name: <client_b>)
    node((2, 0.5), "Federation\nGateway", name: <gateway>, stroke: 1pt, inset: 10pt, outset: 10pt)
    node((4, 0), "Subgraph A", name: <subgraph_a>)
    node((4, 1), "Subgraph B", name: <subgraph_b>)
    node((4, 2), "Service A", name: <service_a>, outset: 8pt)
    edge(<client_a>, <gateway>, "->")
    edge(<client_b>, <gateway>, "->")
    edge(<gateway>, <subgraph_a>, "->")
    edge(<gateway>, <subgraph_b>, "->")
    edge(<gateway>, <service_a>, "->")
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
- Single point of enforcement
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
    _entities(representations: [
      { __typename: "User", id: "1" }
    ]) {
      ... on User {
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
]

== Federation v2 Standard Directives

#pause

- Based on _claims_ aka _scopes_
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

Allows accessing the field or type when the request carries _any_ verified JWT.

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
            ["ip_is_allowlisted"],
            ["is_support_agent", "in_business_hours"],
        ])
}
```
#v(2em)
]

== Limitations

- The directives above are sufficient to enable *RBAC* and *limited ABAC*
#pause

- But decisions cannot be tied to *data*
  - Inputs to the fields
  - Output data returned by the subgraphs
#pause

- -> *Relationships* cannot be enforced
  - “Users can see the photos on the profile of their friends”
  - “I can see the balance on my own bank account”
  - “I can see the medical records of my own patients”
  - “My direct manager can approve my expense requests if they are < 5000€”

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

  - And response data too

#pause

  - *-> Authorization must be taken into account by the query planner*


== Example

#box(width: 33%)[
#text(size: 12pt)[
```graphql
query PostsWithComments(
    $userID: ID!
) {
  posts(user: $userID) {
    title
    comments(includeHidden: true) {
      author { name }
      commentText
      createdAt
    }
  }
}
```
]
]
#box(width: 66%)[
#text(size: 13pt)[
#align(center)[
#diagram(
  {
    let label_size = 0.7em
    node((0, 1.7), "Client", name: <client_a>, inset: 10pt, outset: 10pt, stroke: 1pt)
    node((1.8, 1.7), "Gateway", name: <gateway>, inset: 10pt, outset: 5pt, stroke: 1pt)
    node((4.5, 1), "Posts\nsubgraph", name: <subgraph_a>, inset: 10pt, outset: 5pt, stroke: 1pt)
    node((4.5, 3), "Comments\nsubgraph", name: <subgraph_b>, inset: 10pt, outset: 10pt, stroke: 1pt)
    edge(<client_a>, <gateway>, "->", label-size: label_size, label: "1 (request)", bend: 10deg, label-pos: 55%)
    edge(<gateway>, <subgraph_a>, "->", label-size: label_size, label: "2 (get posts)", bend: 10deg, label-pos: 13%)
    edge(<subgraph_a>, <gateway>, label-size: label_size, label: "3", "->", bend: +20deg, label-pos: 30%)
    edge(<gateway>, <subgraph_b>, "->", label-size: label_size, label: "4 (get comments)", label-pos: 70%, bend: 10deg)
    edge(<subgraph_b>, <gateway>, "->", label-size: label_size, label: "5", bend: 10deg)
    edge(<gateway>, <client_a>, "->", label-size: label_size, label: "6 (response)", bend: +30deg)
    edge((0.7, 0), (0.7, 3), "--", label-size: label_size / 1.5, label: "Request level authzn", label-pos: 15%, label-angle: 90deg)
    edge((3, 0), (3, 3), "--", label-size: label_size / 1.5, label: "Fine grained authzn", label-pos: 15%, label-angle: 90deg)
  }
)
]
]
]

== Our solution

- Achieved with *extensions*.
  - They can define their own directives that will be used by the Gateway for query planning.
  - Compiled to Wasm (WASI preview 2).
    - Near-native performance, in-process secure sandbox.
    - They can perform arbitrary IO (with configurable capabilities).

== Pre-subgraph request authorization: define a directive

```graphql
extend schema
  @link(
      url: "https://specs.grafbase.com/grafbase",
      import: ["InputFieldSet"])

directive @authorized(arguments: InputFieldSet = "*")
```

== Pre-subgraph request authorization: apply the directive

```graphql
extend schema
  @link(
      url: "https://extensions.grafbase.com/authorized/0.1.0",
      import: ["@authorized"])

type Query {
    bankAccountByUserEmail(email: String!): BankAccount @authorized
}
```

== Pre-subgraph request authorization: implement authzn logic

#text(size: 14pt)[

```rust
#[derive(serde::Deserialize)]
struct Authorized<T> {
    arguments: T,
}

#[derive(serde::Deserialize)]
struct BankAccountByUserEmailArguments {
    email: String,
}

fn authorize_query(
    &mut self,
    headers: &mut SubgraphHeaders,
    token: Token,
    elements: QueryElements<'_>,
) -> Result<impl IntoQueryAuthorization, ErrorResponse> {

    let mut builder = AuthorizationDecisions::deny_some_builder();
    for element in elements {
        let DirectiveSite::FieldDefinition(field) = element.directive_site() else {
            unreachable!()
        };
        match (field.parent_type_name(), field.name()) {
            ("Query", "bankAccountByUserEmail") => {
                let authorized: Authorized<BankAccountByUserEmailArguments> = element.directive_arguments()?;
                if authorized.arguments.email != "george@pizzahut.com" {
                    builder.deny(element, "Access denied");
                }
            }
            _ => unreachable!(),
        }
    }

    Ok(builder.build())
}
```
]


== Pre-subgraph request authorization

- Takes place when a subgraph request is planned
- Will cause the field to become null, with your authorization error in `errors`
- The field and its subfields will not even be requested from the subgraph

== Response authorization

```graphql
type User @key(fields: "id") {
  id: ID!
  email: String!
  userType: UserType
  socialSecurityNumber: String @policy(
    policies: ["check_access_to_user_ssn"]
  )
}
```

Assume we need the `id` and `userType` of the user in addition to the current request context to control access to the social security number.

== Response authorization: Problem

Looks good, but...

```graphql
query {
  userByEmail(email: "george@pizzahut.com") {
    socialSecurityNumber
  }
}
```

The `id` and `userType` fields are not going to be available, so our plugin / coprocessor does not have the data it needs to make authorization decisions.

== Response authorization: Solution

We define a directive that declaratively pulls in the fields we need in order to make a decision:

```graphql
extend schema
  @link(
      url: "https://specs.grafbase.com/grafbase",
      import: ["FieldSet"])

directive @guard(requires: FieldSet!)
```

== Response authorization: Solution

Then we apply it:

#text(size: 16pt)[

```graphql
extend schema
  @link(
      url: "https://extensions.grafbase.com/authorized/0.1.0",
      import: ["@guard"])

type User @key(fields: "id") {
  id: ID!
  email: String!
  userType: UserType
  socialSecurityNumber: String @guard(
    requires: "id userType { canReadSensitiveInfo }"
  )
}
```
]

== Takeaways

- Authorization decision for each annotated field or type can depend on *inputs (arguments)* or *arbitrary associated data*.
#pause
- Integrated in the *query planner*
  - Avoids requesting what the current client request is not authorized to see
  - Potentially requests extra fields that are not needed to resolve the GraphQL query, but are required to make authorization decisions.
#pause
- All these decisions *batched* by the query planner.
#pause
- Enables *fine grained Attribute-based Access Control (ABAC)* and *Relation-based Access Control (ReBAC)*.

== Also

#v(3em)

#text(size: 25pt)[
#pause Workshop! #pause Tomorrow! #pause

Grote Zaal - 2nd Floor. #pause 10:45am.

#pause Thank you!

#absolute-place(dx: 30%, dy: 70%, figure(image("../grafbase-logo.svg", width: 50%)))
]

== Links

- #link("https://www.permit.io/blog/what-is-fine-grained-authorization-fga")[Blog post on fine-grained authorization by Permit.io]
- #link("https://www.apollographql.com/docs/graphos/routing/security/authorization")[Docs on built-in]
- Grafbase Authorization extensions:
  - #link("https://grafbase.com/blog/custom-authentication-and-authorization-in-graphql-federation")[Grafbase blog post: Custom Authentication and Authorization in GraphQL Federation]
  - #link("https://github.com/grafbase/grafbase/tree/main/examples/authorization")[Example project for authorization extensions]
