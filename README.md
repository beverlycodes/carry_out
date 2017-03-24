# CarryOut

CarryOut connects units of logic into workflows.  Each unit can extend the DSL with parameter methods.  Artifacts and errors are collected as the workflow executes and are returned in a result bundle upon completion.

[![Gem Version](https://badge.fury.io/rb/carry_out.svg)](https://badge.fury.io/rb/carry_out) [![Build Status](https://travis-ci.org/ryanfields/carry_out.svg?branch=master)](https://travis-ci.org/ryanfields/carry_out) [![Coverage Status](https://coveralls.io/repos/github/ryanfields/carry_out/badge.svg?branch=master)](https://coveralls.io/github/ryanfields/carry_out?branch=master) [![Code Climate](https://codeclimate.com/github/ryanfields/carry_out/badges/gpa.svg)](https://codeclimate.com/github/ryanfields/carry_out)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'carry_out'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install carry_out

## Usage

Execution units extend CarryOut::Unit and should implement ```CarryOut::Unit#execute(result)```.
```ruby
class SayHello < CarryOut::Unit
  def execute(result)
    puts "Hello, World!"
  end
end
```

CarryOut can then be used to create an execution plan using the unit.
```ruby
plan = CarryOut.will(SayHello)
```

Run the plan using:
```
result = plan.execute
```

### Parameters
Execution units can be passed parameters statically during plan creation, or dynamically via a block.

#### parameter

Redefine the example above to greet someone by name:
```ruby
class SayHello < CarryOut::Unit
  parameter :to, :name
    
  def execute(result)
    puts "Hello, #{@name}!"
  end
end
```

Define the plan as:
```ruby
plan = CarryOut
  .will(SayHello)
  .to("Ryan")
    
# or

plan = CarryOut
  .will(SayHello)
  .to { "Ryan" }
```

And execute the same way as above.

#### appending_parameter

Appending parameters will convert the value of an existing parameter to an array and push new values into that array.  These parameters can improve the readability of a plan, and are also helpful if creating a plan dynamically.

```ruby
class SayHello < CarryOut::Unit
  parameter :to, :names
  appending_parameter :and, :names

  def execute
    puts "Hello, #{@names}.join(", ")}!"
  end
end

plan = CarryOut
  .will(SayHello)
  .to("John")
  .and("Jane")
  .and("Ryan")
```

Unlike `parameter`, `appending_parameter` must provide both a method name and an instance variable name.

A non-appending parameter does not need to be called (or even exist) in order for appending parameters to operate.

Calling the non-appending version of a parameter *after* calling the appending version will result in the array being lost, replaced by the explicit non-appending value provided.

A unit may wish to provide the syntactic sugar while ensuring the underlying instance variable is always an array.  This can be accomplished by defining two (or more) appending parameters pointed at the same instance variable.

### Results and Artifact References

Plan executions return a `CarryOut::Result` object that contains any artifacts returned by units (in `Result#artifacts`), along with any errors raised (in `Result#errors`).  If `errors` is empty, `Result#success?` will return `true`.

Parameter blocks can be used to pass result artifacts on to subsequent execution units in the plan.

```ruby
class AddToCart < CarryOut::Unit
  parameter :items
    
  def execute(result)
    result.add :contents, @items
  end
end

class CalculateSubtotal < CarryOut::Unit
  parameters :items
    
  def execut(result)
    subtotal = items.inject { |sum, item| sum + item.price }
    result.add :subtotal, subtotal
  end
end
```
```ruby
plan = CarryOut
    .will(AddToCart, as: :cart)
    .items([ item1, item2, item3])
    .then(CalculateSubtotal, as: :invoice)
    .items { |refs| refs[:cart][:contents] }
    
plan.execute do |result|
  puts "Subtotal: #{result.artifacts[:invoice][:subtotal]}"
end
```

### Initial Artifacts

`Plan#execute` accepts a hash that will seed the initial result artifacts.

```ruby
plan = CarryOut
  .will(SayHello)
  .to { |refs| refs[:name] }

plan.execute(name: 'John')
```

### Wrapping Execution

Plan execution can be wrapped for purposes such as ensuring files get closed or to run the plan inside a database transaction.  Wrapping also provides an alternative mechanism for injecting initial artifacts into the plan result.

If `Plan#execute` is passed an initial artifact hash, and a wrapper injects an artifact hash, the two will be merged.  The wrapper hash will get priority.

```ruby
class FileContext
  def initialize(file_path)
    @file_path = file_path
  end
  
  def execute
    File.open(@file_path, "r") do |f|
      yield file: f
    end
  end
end

plan = CarryOut
  .within(FileContext.new("path/to/file"))  # Expects instance, not class
  .will(DoAThing)
    .with_file { |refs| refs[:file] }
```

The wrapping context can also be a block.

```ruby
plan = CarryOut
  .within { |proc| ActiveRecordBase.transaction { proc.call } }
  .will(CreateModel)
```

When using a block, `proc.call` can be used to seed the references hash in the same manner as `yield` in the first example.

Wrapper contexts will always be applied to an entire plan.  If a plan has multiple phases that need to be wrapped in different contexts, it is better to create multiple plans and embed them together in a larger plan as shown below.

### Embedding Plans

A plan can be used in place of a `CarryOut::Unit`.  This allows plans to be reused as part of larger strategies.

```ruby
say_hello = CarryOut.will(SayHello)

plan = CarryOut
  .will(DisplayBanner)
  .then(say_hello)
```

Passing a plan to `#then` works similar to passing a `CarryOut::Unit` class or instance.  If the `as` option is added, the inner plan's result artifacts will be added to the outer plan's result at the specified key.

**One caveat to be aware of**:  There is no way to specify initial artifacts for an embedded plan.  If an embedded plan depends on an external context, `CarryOut#within` is sufficient to work around this limitation.  However, there is currently no way for an inner plan to access an outer plan's artifacts.  This is considered a bug and will be fixed in a future release.

## Motivation

I've been trying to keep my Rails controllers clean, but I prefer to avoid shoving inter-model business logic inside database models.  The recommendation I most frequently run into is to move that kind of logic into something akin to service objects.  I like that idea, but I want to keep my services small and composable, and I want to separate the "what" from the "how" of my logic.

CarryOut is designed to be a consistent layer of glue between single-purpose or "simple-purpose" units of business logic.  CarryOut describes what needs to be done and what inputs are to be used.  The units themselves worry about how to perform the actual work.  These units tend to have names that describe their intent.  They remain small and easier to test.  What ends up in my controllers is a process description that that can be comprehended at a glance and remains fairly agnostic to the underlying details of my chosen ORM, job queue, message queue, etc.

I'm building up CarryOut alongside a new Rails application, but my intent is for CarryOut to remain just as useful outside of Rails.  At present, it isn't bound in any way to things like ActiveRecord.  If those sorts of bindings emerge, I'll provide an add-on gem or an alternate require.

CarryOut's workflows don't support asynchronous execution units yet.  The workflows can't branch or loop.  These are features I hope to provide in the future.  Feature requests are welcome.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryanfields/carry_out. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

