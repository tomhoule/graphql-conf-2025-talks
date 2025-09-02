#import "@preview/touying:0.6.1": *
#import themes.simple: *

// Code blocks
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()
#codly(languages: codly-languages, zebra-fill: none)

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

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= Federation and Authorization

== Federated GraphQL

Hello, Touying!

#pause

Hello, Typst!

== Why Authorize in the Gateway

- First point of contact to the outside world
#pause
- Whole schema view
#pause
- Whole request context
#pause
- Entity resolvers make things tricky

==

```graphql
directive @authenticated on
    FIELD_DEFINITION
  | OBJECT
  | INTERFACE
  | SCALAR
  | ENUM
```

==

```graphql
directive @requiresScopes(scopes: [[federation__Scope!]!]!) on
    FIELD_DEFINITION
  | OBJECT
  | INTERFACE
  | SCALAR
  | ENUM
```

==

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
