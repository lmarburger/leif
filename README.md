# Leif

A hypermedia browser for the CloudApp Collection+JSON API.

## Interactive Commands

  - `root`:
    Go back to the root

  - `follow` <u>rel</u>:
    Follow link with the given relation.

  - `basic` <u>username</u> [<u>password</u>]:
    Authenticate with HTTP Basic and reload the current resource. Will be
    prompted for password if it is omitted.

  - `token` <u>token</u>:
    Authenticate using the given token and reload the current resource.
