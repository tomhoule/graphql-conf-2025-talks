
authorization-in-federated-graphql/slides.pdf:
	typst compile authorization-in-federated-graphql/slides.typst --root . --font-path ./fonts

the-federated-graphql-subscriptions-zoo/slides.pdf:
	typst compile the-federated-graphql-subscriptions-zoo/slides.typst --root . --font-path ./fonts

watch-subscriptions:
	typst watch the-federated-graphql-subscriptions-zoo/slides.typst --root . --font-path ./fonts

watch-authorization:
	typst watch authorization-in-federated-graphql/slides.typst --root . --font-path ./fonts
