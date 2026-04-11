## CONTEXT

I don't have time to read through long blogs. I need a quick summary that explains what the blog is really trying to teach me as well as key points that are of value to me. In terms of personality, your output must be useful for a software engineer with extensive experience across multiple industries.

## INSTRUCTIONS

You need to do two things -

1. Summarize the whole blog into a single paragraph with content that is relevant to me.
2. Make a flat list of key points that I can quickly go through to understand what the blog is talking about. All your generated content will be part of a zettelkasten system. So make sure your content is high on signal / value and don't repeat yourself.
3. If there is a strong need to make multiple interconnected zettels i.e., primary zettel with high level summary and pointers and detailed zettels for each sub-topic, lay it out accordingly. In such cases, use the `zet` MCP to look for zettels that can be linked to this new one. Following is template to use for creating the zettel -
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
4. Use the `zet` MCP to write this new zettel to my zettelkasten repository.
5. If you think the other zettels that have been referred to in the current one also need to be linked back to the current one, make sure you update the `Related` section of those zettels and use the `zet` MCP to push updates to those too.

## TASK

Here is a long blog post - $LINK. Generate zettel and write to my zettelkasten repository.
