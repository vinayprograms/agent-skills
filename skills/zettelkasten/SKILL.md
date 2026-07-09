---
name: zettelkasten
description: Convert blogs and documentation sites into zettels for a zettelkasten repository using the `zet` MCP. Use when user wants to generate a zettel from a blog post link or an entire documentation site.
---

# Zettelkasten

Convert internet content (blog posts, documentation sites) into focused, high-signal zettels written to a zettelkasten repository via the `zet` MCP.

## Zettel Template

Every zettel uses this structure:

```md
# <TITLE>

SOURCE: <original link/URL used for generating zettel>

<SUMMARY>

## Key Points

* **<key>**: <1-2 lines of text for key point>
* **<key>**: <1-2 lines of text for key point>
* ...

## Related

* [<title of zettel>](../<zettel ID>/README.md)
* [<title of zettel>](../<zettel ID>/README.md)
* ...
```

- Summary must be a single paragraph relevant to a software engineer with extensive cross-industry experience.
- Key Points must be a flat list — high signal, no repetition.
- If a zettel has no related zettels yet, omit the `## Related` section.
- When linking zettels bidirectionally, update the `## Related` section of referenced zettels and push updates via the `zet` MCP.

## Workflow 1 — Single Blog Post

Triggered when the user provides a single blog URL.

1. Use the `zet` MCP to search for existing zettels that can be linked to the new one.
2. Summarize the blog into a single paragraph relevant to the user.
3. Make a flat list of key points — high signal, no repetition.
4. If the content warrants multiple interconnected zettels (primary + sub-topic zettels), lay it out accordingly and use the zettel template for each.
5. Write the new zettel(s) to the zettelkasten repository using the `zet` MCP.
6. If other zettels referenced in the new one should link back, update their `## Related` sections and push via the `zet` MCP.

### Task

Here is a long blog post — `$LINK`. Generate a zettel and write it to my zettelkasten repository.

## Workflow 2 — Full Documentation Site

Triggered when the user provides a documentation site URL.

Insert 1–2 second delays between consecutive zettel creations via the `zet` MCP so that each gets a unique ID.

1. Navigate the site and collect all pages of interest.
2. **Create a landing zettel.**
   a. Summarize the entire site in a single paragraph.
   b. List key points — one per page of interest, each linking to the page's dedicated zettel.
   c. Landing zettel template:
      ```md
      # <TITLE>

      SOURCE: <original link/URL used for generating zettel>

      <SUMMARY>

      ## Key Points

      * **<key>**: <1-2 lines of text for key point>
      * **<key>**: <1-2 lines of text for key point>
      * ...
      ```
3. **For each page of interest:**
   a. Summarize the page into a single paragraph relevant to the user.
   b. Make a flat list of key points — high signal, no repetition.
   c. Search existing zettels via the `zet` MCP for linkable related zettels.
   d. Create the zettel using the full zettel template (with `## Related` section).
   e. Write it to the zettelkasten repository using the `zet` MCP.
4. **Update the landing zettel** — append a `## Further Reading` section linking to each page-of-interest zettel:
   ```md
   <existing content>

   ## Further Reading

   1. [<title of page-of-interest zettel>](../<page-of-interest zettel ID>/README.md)
   2. [<title of page-of-interest zettel>](../<page-of-interest zettel ID>/README.md)
   ```
5. Push the updated landing zettel via the `zet` MCP.

### Task

Here is the documentation site to convert into a set of zettels — `$LINK`. Generate a 2-level zettel hierarchy and write all zettels to my zettelkasten repository.