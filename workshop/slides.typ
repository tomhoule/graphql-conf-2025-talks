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
#let graphql_logo = "../GraphQL_Logo.svg"

#let talk_title = "Beyond GraphQL Federation: How We Use Composite Schemas and WebAssembly to Federate Non-GraphQL Data Sources "
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

#set text(size: 19pt, font: ("Inter"))

#title-slide[
  #figure(
    image("../grafbase-logo.svg", width: 16%)
  )

  #text(size: 55pt, weight: "bold")[
    Beyond #text(stroke: grafbase_green, fill: grafbase_green)[GraphQL Federation]\
  #text(size: 26pt)[How We Use Composite Schemas and WebAssembly to Federate Non-GraphQL Data Sources]
  ]

  #text(size: 16pt)[Benjamin Rabier and Tom Houlé]
]

== Traditional GraphQL Federation

#align(center + horizon)[
#diagram(
  {
    node((0, 0), "Client A", name: <client_a>)
    node((0, 1), "Client B", name: <client_b>)
    node((2, 0.5), "Federation\nGateway", name: <gateway>, stroke: 1pt, inset: 10pt, outset: 10pt)
    node((4, 0), [Subgraph A #box(image(graphql_logo, width: 20pt))], name: <subgraph_a>)
    node((4, 1), [Subgraph B #box(image(graphql_logo, width: 20pt))], name: <subgraph_b>)
    node((4, 2), [Subgraph C #box(image(graphql_logo, width: 20pt))], name: <service_a>, outset: 8pt)
    edge(<client_a>, <gateway>, "->")
    edge(<client_b>, <gateway>, "->")
    edge(<gateway>, <subgraph_a>, "->")
    edge(<gateway>, <subgraph_b>, "->")
    edge(<gateway>, <service_a>, "->")
  }
)
]

== Extensions-enabled GraphQL Federation

#absolute-place(dx: 50%, dy: 28%, image(graphql_logo, width: 7%))

#align(center + horizon)[
#diagram(
  {
    node(enclose: ((-1,0), (2.7,2)), stroke: rgb(210, 90, 110), inset: 10pt, snap: false)

    node((0, 0.5), "Client A", name: <client_a>)
    node((0, 1.5), "Client B", name: <client_b>)
    node((2, 1), "Federation\nGateway", name: <gateway>, stroke: 1pt, inset: 10pt, outset: 10pt)
    node((4, 0), [Subgraph A #box(image(graphql_logo, width: 20pt))], name: <subgraph_a>)
    node((4, 0.5), [Subgraph B #box(image(graphql_logo, width: 20pt))], name: <subgraph_b>)
    node((4, 1), [Postgres database], name: <service_a>, outset: 8pt)
    node((4, 1.5), [Kafka], name: <kafka>, outset: 8pt)
    node((4, 2), [REST API], name: <rest_a>, outset: 8pt)
    node((4, 2.5), [GRPC API], name: <grpc>, outset: 8pt)
    node((4, 3), [Another REST API], name: <rest_b>, outset: 8pt)
    edge(<client_a>, <gateway>, "->")
    edge(<client_b>, <gateway>, "->")
    edge(<gateway>, <subgraph_a>, "->")
    edge(<gateway>, <subgraph_b>, "->")
    edge(<gateway>, <service_a>, "->")
    edge(<gateway>, <kafka>, "->")
    edge(<gateway>, <rest_a>, "->")
    edge(<gateway>, <rest_b>, "->")
    edge(<gateway>, <grpc>, "->")
  }
)
]


== Composite Schemas

== Links

- Composite Schemas meeting videos on the GraphQL Foundation's YouTube channel
- Composite Schemas spec (draft)
- Grafbase Extensions docs
- Grafbase SDK
