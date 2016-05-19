require 'rubygems'
if RUBY_VERSION >= '1.9'
  require 'minitest/autorun'
  require 'active_record'
else
  require 'test/unit'
  require 'activerecord'
  require 'sqlite3'
end
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'acts_as_enumeration'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  ActiveRecord::Base.logger
  ActiveRecord::Schema.define(:version => 1) do
    create_table :enumerates do |t|
      t.column :type, :string
      t.column :name, :string
      t.column :description, :string
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Enumerate < ActiveRecord::Base; end
class EnumerateAll < Enumerate; end
class EnumerateSome < Enumerate; end
class BrokenEnumeration < Enumerate; end

class EnumerateTest < (
begin
  MiniTest::Test rescue Test::Unit::TestCase
end)
  def setup
    setup_db
    [EnumerateAll].each do |klass|
      klass.create! :name => 'first', :description => 'First field'
      klass.create! :name => 'second', :description => 'Second field'
      klass.create! :name => 'third', :description => 'Third field'
    end
    [EnumerateSome].each do |klass|
      klass.create! :name => 'forth', :description => 'Forth field'
      klass.create! :name => 'fifth', :description => 'Fifth field'
      klass.create! :name => 'sixth', :description => 'Sixth field'
    end
    [BrokenEnumeration].each do |klass|
      klass.create! :name => '33108', :description => '33108 field'
    end
    EnumerateAll.acts_as_enumeration :description
    EnumerateSome.acts_as_enumeration :description
    BrokenEnumeration.acts_as_enumeration :name
  end

  def teardown
    teardown_db
  end

  def test_basics
    assert Enumerate.first.is?('first_field')
    assert Enumerate.first.is?(:first_field)
    assert Enumerate.first.is_not?(:second_field)
    assert Enumerate.first.is?(:first_field, :second_field)
    assert Enumerate.first.is_not?(:second_field, :third_field)
    assert Enumerate.first.is_first_field?
    assert Enumerate.first.is_not_second_field?
    assert Enumerate.first.is_first_field_or_second_field?
    assert EnumerateAll.second_field.is_first_field_or_second_field?
    assert EnumerateAll.second_field.is_not_first_field?
    assert EnumerateAll.first.first_field?
    assert_equal EnumerateAll.first, EnumerateAll.first_field
    assert_equal(:first_field, Enumerate.first.as_key)
    assert_equal(:first_field, EnumerateAll.as_key(Enumerate.first.id))
    assert EnumerateAll.valid_description?(:first_field)
    assert EnumerateAll.valid_description?('first_field')
    assert !EnumerateAll.valid_description?(:blah_blah_field)
    assert !EnumerateAll.valid_description?('blah_blah_field')
    assert Enumerate.first.id, EnumerateAll.id_for_description(:first_field)
    assert EnumerateAll::FIRSTFIELD,Enumerate.first.id
    assert EnumerateAll::FirstField,Enumerate.first.id
    assert EnumerateAll.FIRSTFIELD,Enumerate.first.id
    assert EnumerateAll.FirstField,Enumerate.first.id
    assert BrokenEnumeration._33108,BrokenEnumeration.first.id
  end

  def test_sti
    assert EnumerateSome.first.is?('forth_field')
    assert EnumerateSome.first.is?(:forth_field)
    assert EnumerateSome.first.is_not?(:second_field)
    assert EnumerateSome.first.is?(:forth_field, :second_field)
    assert EnumerateSome.first.is_not?(:second_field, :third_field)
    assert EnumerateSome.first.is_forth_field?
    assert EnumerateSome.first.is_not_second_field?
    assert EnumerateSome.first.is_forth_field_or_second_field?
    assert EnumerateSome.forth_field.is_forth_field_or_second_field?
    assert EnumerateSome.forth_field.is_not_fifth_field?
    assert EnumerateSome.first.forth_field?
    assert_equal EnumerateSome.first, EnumerateSome.forth_field
    assert_equal(:forth_field, EnumerateSome.first.as_key)
    assert_equal(:forth_field, EnumerateSome.as_key(EnumerateSome.first.id))
    assert EnumerateSome.valid_description?(:forth_field)
    assert EnumerateSome.valid_description?('forth_field')
    assert !EnumerateSome.valid_description?(:first_field)
    assert !EnumerateSome.valid_description?('first_field')
    assert EnumerateSome.first.id, EnumerateSome.id_for_description(:forth_field)
  end
end

