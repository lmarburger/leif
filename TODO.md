# TODO

 - Automation: Pass a series of newline-separated commands to perform.
 - `error` command that works just like `items` but for an error
   representation
 - Copy to clipboard command: `copy {item,collection,response,...}`
 - Query templates
 - `items` > `delete`: Delete the current item
 - Add relevance checking to commands (e.g., `update` when there is no template)
 - Handle errors in commands (e.g., basic auth without user)
 - Warn when choosing a non-existent field
 - netrc support
 - Request body isn't shown
 - Fill template field with file
 - Persist basic auth
 - `back`/`forward` commands
 - Lint flag: show warnings if responses don't conform with media type
 - Fail through to `follow` if given command doesn't match

# Go Nuts

 - `help <command>`: print expanded help
 - `items` > `j`/`k`: Step through items
 - Open last printed message in `$EDITOR`
 - `create`/`update`: edit request body in `$EDITOR`
 - `item name="some value"`: find and print the first item that matches
 - Bookmarks
