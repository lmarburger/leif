# Leif

A hypermedia browser for the CloudApp Collection+JSON API.

## Commands

```
  r
  root
    Go back to the root

  f <rel>
  follow <rel>
    Follow link with the given relation.

  b <username> [<password>]
  basic <username> [<password>]
    Authenticate with HTTP Basic and reload the current resource. Will be
    prompted for password if it is omitted.

  t <token>
  token <token>
    Authenticate using the given token and reload the current resource.
```
