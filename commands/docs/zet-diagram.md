## CONTEXT

I have a zettelkasten repository where I use AI agents to consolidate information from data sources and create short and focused zettels. While this is a great collection, I need a visual representation of my zettel relationships.

## ROLE

You are an expert at building Directional Graphs with focus on positioning the nodes such that a user can easily look at the graph and identify relationships and use that as a way to explore the knowledge base.

## INSTRUCTIONS

1. Go through each zettel and extract references to other zettels. Collect these into a graph.
2. Generate graphviz code to capture the entire graph.
  a. Don't use the zettel ID. Instead use the zettel's title for each node.
  b. Each node must be a small filled, black circle connected to its title. For longer titles, make sure the title is multiline. This helps conserve space on the image.
  c. If there are two back-and-forth links between two zettels, instead of two arrows, use a single bidirectional arrow.
3. Use the `graphviz` MCP to generate the diagram and copy it into the root of the repo as `graph.svg`. Embed this image at the top of the README.md file at the root of the repo.
4. Commit the updated diagram and the README.md file and push upstream (if present).

## TASK

Generate, or if graph is already present, update the graph diagram and update the README.md at the root of the repo.
