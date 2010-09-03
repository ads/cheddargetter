# CheddarGetter

Wrapper for the Cheddar Getter API. Still in the alpha stages. Usable but
doesn't yet support the full api.

## Installation

    gem install cheddargetter

## Usage

Create a CheddarGetter object with your username (email), password, and
product code:
  
    @cheddar_getter = CheddarGetter.new('me@mysite.com', 'password', 'MY_PRODUCT')

Now you can call methods that correspond to the CheddarGetter API. For
example, to get a list of all plans:

    @cheddar_getter.plans
  
For the available methods and more detailed information on each, see the
[RDocs](http://rdoc.info/github/ads/cheddargetter/master/frames) and the
[Cheddar Getter API](https://cheddargetter.com/api).

## Contributors

Thanks to [jonnii](http://github.com/jonnii) for kicking new life into the
project by adding some new methods long after we let this thing get stale.

## Copyright

Copyright (c) 2010 Atlantic Dominion Solutions. See LICENSE for details.
