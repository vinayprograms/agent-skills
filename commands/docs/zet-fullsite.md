## CONTEXT

I don't have time to read through documentation sites. I need a quick summary that explains what each documentation page is really trying to teach me as well as key points that are of value to me. In terms of personality, your output must be useful for a software engineer with extensive experience across multiple industries.

Since you are going to use the `zet` MCP (and that MCP only) for creating multiple zettels, make sure to insert 1-2 second delay between creation of consecutive zettels so that we can get unique IDs for each zettel.

## INSTRUCTIONS

You need to do two things -

1. Navigate the site and pick up all pages-of-interest.
2. Create a landing zettel.
  a. This zettel should summarize the whole site followed by key points listing the points of interest for each of the pages that this page will link to.
  b. Each of the key point must be a link to another zettel that will summarize one of teh pages from the site.
  c. Following is template to use for creating the landing zettel -
      ```md
      # <TITLE>

      SOURCE: <original link/URL used for generating zettel>

      <SUMMARY>

      ## Key Points

      * **<key>**: <1-2 lines of text for key point>
      * **<key>**: <1-2 lines of text for key point>
      * ...
      ```
3. For each page-of-interest from the site -
  a. Summarize the whole page into a single paragraph with content that is relevant to me.
  b. Make a flat list of key points that I can quickly go through to understand what the blog is talking about. All your generated content will be part of a zettelkasten system. So make sure your content is high on signal / value and don't repeat yourself.
  c. Create a new zettel using the following template. Use the `zet` MCP to look for other zettels that can be linked to this new one.
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
  d. Use the `zet` MCP to write this new page-of-interest zettel to my zettelkasten repository.
4. Update the landing zettel and add a `Further reading` section at the end, with each entry linking to the page-of-interest zettels. Use the following template for this section -
    ```md
    <existing content>

    ## Further Reading

    1. [<title of page-of-interest zettel](../<page-of-interest zettel ID>/README.md)
    2. [<title of page-of-interest zettel](../<page-of-interest zettel ID>/README.md)
    ```
5. Finally, use the `zet` MCP to update the landing zettel.

## TASK

Here is the documentation site that need to be converted to a set of zettels - $LINK. Generate a 2-level zettel hierarchy as instructed in the `## INSTRUCTIONS` section and write all of them to my zettelkasten repository.
