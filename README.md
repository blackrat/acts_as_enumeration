# ActsAsEnumeration

If you've found this, you may be wondering why it exists since Rails has had enum since version 4.1.8. The biggest 
difference with this one is that it allows you to have a separate table to hold your enumerated values and have the 
primary key as the enumeration, which adds flexibility in how they are used.

The big plus that ActiveRecord::Enum has is that it adds scopes directly, 

acts_as_enumeration and its aliases acts_as_enumerable, acts_as_enum, enumerable_column and enum_column
allow for unique names in a database column to behave as if they were enumerated
types, including chaining etc.

## Installation

Add this line to your application's Gemfile:

    gem 'acts_as_enumeration'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acts_as_enumeration

## Usage

So if a database table had a column called "name", declaring

   acts_as_enumeration :name

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

CAVEAT: Due to the mechanism that the method_missing uses, if someone actually
had the name "not bruce", the combination query cannot use this as the first element.
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
