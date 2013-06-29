# ActsAsEnum

acts_as_enumerable and its aliases acts_as_enum, enumerable_column and enum_column
allow for unique names in a database column to behave as if they were enumerated
types, including chaining etc.

## Installation

Add this line to your application's Gemfile:

    gem 'acts_as_enum'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acts_as_enum

## Usage

So if a database table had a column called "name", declaring

   acts_as_enumerable :name

would select all of the items in that column and map them in a hash to their
primary key values.

In addition, it creates the instance methods is_#{key} where key is all of the
values in that column, is?(array) and is_not?(array) that check for type within
that array.

Keeping name as our column example, the class methods id_for_name will return
the primary key value for that mapping and valid_name?(value) will say if the
table contains and entry in the name column with that value.

Finally, the method missing allows for is_ and is_not chaining of methods, such
as is_paul_or_michael_or_luke? which has the same effect as
(is_paul? || is_michael? || is_luke?) or is?(:paul, :michael, :luke) and
is_not_paul_or_michael_or_like which has the same effect as
!(is_paul || is_michael? || is_luke?) or !is?(:paul, :michael, :luke)

CAVEAT: due to the mechanism that the method_missing uses in is someone actually
had the name "not bruce", the combinations cannot use this as the first element.
i.e. "not <anything>" not just "not bruce".

So a combination of is_not_bruce_or_paul? would have to be written
is_paul_or_not_bruce? to have the desired effect. is_not_not_bruce_or_paul
is fine, but the chances of this happening are about as likely as someone actually
called "not bruce" outside of a Monty Python sketch.

(Which means it probably will, so before you change code to support a new entry,
try just changing the order)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
