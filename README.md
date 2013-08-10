# Leif

A hypermedia browser for the CloudApp Collection+JSON API.

## Requirements

`leif` requires Ruby 1.9.3 or greater. Windows is not yet supported. If you're
willing to lend a hand, we'd love to officially support it.

## Installation

``` bash
$ gem install leif
$ leif
```

`leif` includes a man page. Read it [on the web][manpage] or install
`gem-man`:

``` bash
$ gem install gem-man
$ gem man leif
```

## Interactive Commands

  - `root`:
    Go back to the root.

  - `follow` <u>rel</u>:
    Follow link with the relation <u>rel</u> on the collection or selected item.

  - `create`:
    Begin editing the template to create a new item.

  - `update`:
    Begin editing the template to update the item selected with `items`.

  - `request`:
    Print the HTTP headers of the last request.

  - `response`:
    Print the HTTP headers of the last response.

  - `body`:
    Print the HTTP body of the last response.

  - `collection`:
    Print the collection from the last response.

  - `template`:
    Print the template from the last response.

  - `items`:
    Print each item from the last response one at a time in order to `update`
    or `follow` an item's link.

  - `item`:
    Print the selected item.

  - `basic` [<u>username</u> [<u>password</u>]]:
    Authenticate with HTTP Basic and reload the current resource. Will be
    prompted for username and password if omitted.

  - `token` <u>token</u>:
    Authenticate using the given token and reload the current resource.

  - `debug`:
    Print debug output from the previous HTTP request and response.

  - `help`:
    Print available commands.

  - `quit`:
    Exit `leif`.

## Example

The UI is weak at this point and not very intuitive. To get started, here's a
sample workflow. It should give you a general overview of what's possible.

    > follow authorization

    > basic arthur@dent.com
    Password: *****

    > token <token copied from response body>

    > follow drops
    > follow next
    > follow first

    > create

    Name (empty to submit): name
    Value: CloudApp

    Name (empty to submit): bookmark_url
    Value: http://getcloudapp.com

    Name (empty to submit):

    > root
    > follow drops
    > update

    Name (empty to submit): name
    Value: The Guide

    Name (empty to submit):


[manpage]: http://cloudapp.github.io/leif
