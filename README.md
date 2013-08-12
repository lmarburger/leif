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

[manpage]: http://cloudapp.github.io/leif

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

    $ leif
    ...

    -- Links --
      account, authorization

    > follow authorization
    ...

    > basic arthur@dent.com
    Password: *****
    ...
    {
      "name": "token",
      "value": "2c2p2B2Y0U3y3c2c"
    },
    ...

    > token 2c2p2B2Y0U3y3c2c
    ...

    -- Links --
      drops, drops-template, stream, store

    > follow drops
    ...

    > create
    ...
    Fill the template to create a new item.
    name [null]: New Drop
    private [null]: false
    trash [false]:
    bookmark_url [null]: http://getcloudapp.com
    file_size [null]:
    ...

    > items
    ...
    Select this item [y,n]? y

    -- Links --
      collection, canonical, icon

    > follow collection
    ...

    > items
    ...
    Select this item [y,n]? y
    ...

    > update
    ...
    Fill the template to update the item.
    name ["New Drop"]: Updated Drop
    private [false]:
    trash [false]:
    bookmark_url [null]:
    file_size [null]:
    ...

    > root
    ...
    -- Links --
      drops, drops-template, account, stream
