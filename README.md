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

`leif` includes a man page. To read it:

``` bash
$ gem install gem-man
$ gem man leif
```

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

  - `help`:
    Print interactive command help.

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
