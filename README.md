# CarryOut

CarryOut runs isolated units of logic in a series.  Each unit can extend the DSL with methods for passing input parameters.  Artifacts and errors are collected as the series executes and are returned in a result bundle upon completion.

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
  def call
    puts "Hello, World!"
  end
end
```

CarryOut can then be used to create an execution plan using the unit.
```ruby
plan = CarryOut.plan do
  call SayHello
end
```

Run the plan using:
```
result = plan.call
```

### Parameters
Execution units can be passed parameters statically during plan creation, or dynamically via a block.  There is also a special `context` method that will be explained futher down in this document.

#### parameter

Redefine the example above to greet someone by name:
```ruby
class SayHello < CarryOut::Unit
  parameter :to, :name
    
  def call
    puts "Hello, #{@name}!"
  end
end
```

Define the plan as:
```ruby
plan = CarryOut.plan do
  call SayHello do
    to "World"
  end
end

# or

plan = CarryOut do
  call SayHello do
    to { "World" }
  end
end
```

And execute the same way as above.

#### appending_parameter

Appending parameters will convert the value of an existing parameter to an array and push new values into that array.  These parameters can improve the readability of a plan, and are also helpful if creating a plan dynamically.

```ruby
class SayHello < CarryOut::Unit
  parameter :to, :names
  appending_parameter :and_to, :names

  def call
    puts "Hello, #{@names}.join(", ")}!"
  end
end

plan = CarryOut.plan do
  call SayHello do
    to "John"
    and_to "Jane"
  end
end
```

Unlike `parameter`, `appending_parameter` must provide both a method name and an instance variable name.

A non-appending parameter does not need to be called (or even exist) in order for appending parameters to operate.

Calling the non-appending version of a parameter *after* calling the appending version will result in the array being lost, replaced by the explicit non-appending value provided.

A unit may wish to provide the syntactic sugar while ensuring the underlying instance variable is always an array.  This can be accomplished by defining two (or more) appending parameters pointed at the same instance variable.

### Results and Artifact References

Plan executions return a `CarryOut::Result` object that contains any artifacts returned by units (in `Result#artifacts`), along with any errors raised (in `Result#errors`).  If `errors` is empty, `Result#success?` will return `true`.

The result context can be accessed via the `context` method when creating a plan.

```ruby
class AddToCart < CarryOut::Unit
  parameter :items
    
  def call; @items; end
end

class CalculateSubtotal < CarryOut::Unit
  parameters :items
    
  def call
    items.inject { |sum, item| sum + item.price }
  end
end
```
```ruby
plan = CarryOut.plan do
  call AddToCart do
    items [ item1, item2, item3 ]
    return_as :cart
  end
  
  then_call CalculateSubtotal do
    items context(:cart)
    # or: items { context(:cart) }
    return_as :subtotal
  end
end

result = plan.call
puts "Subtotal: #{result.artifacts[:subtotal]}"
```

### Initial Artifacts

`Plan#call` accepts a hash that will seed the initial result context.

```ruby
plan = CarryOut.plan do
  call AddToCart do
    items context(:items)
  end
end

plan.call(items: [ item1, item2, item3 ])
```

### Altering a returned value

It should be considered preferable to encapsulate all logic inside units and always append to the context.  However, it may be more pragmatic in some circumstances to make minor changes to a returned value as it is being returned.  This can be achieved by providing a block to `return_as`.

```ruby
plan = CarryOut.plan do
  call EchoName do
    name 'john'
    return_as (:name) { |result| result.capitalize }
  end
end
```

### Embedding Plans

A plan can be used in place of a `CarryOut::Unit`.  This allows plans to be reused as part of larger series.  Compositing plans can also help when dealing with optional series.

```ruby
say_hello = CarryOut.plan { call SayHello }

plan = CarryOut do
  call DisplayBanner
  then_call SayHello
end
```

Passing a plan to `call` works similar to passing a `CarryOut::Unit` class or instance.  A block can be included in order to specify a `return_as` directive.  The resulting artifact hash will be stored under the name given to `return_as`.

An embedded plan will receive the current result context as its initial context.

**Caveat**
Errors for embedded plans will be stored at the top level of `Result#errors`.  The `return_as` label for embedded plans is not factored into the label path for errors.  As a result, it can be tricky to determine whether an error was set by the outer plan or an embedded plan.  This is a known bug and will be fixed in a future release.

### Conditional Units

Use the `only_when` or `except_when` directives to conditionally execute a unit.  

```ruby
plan = CarryOut.plan do
  call SayHello
    only_when context(:audible)
  end
end
```

```ruby
plan = CarryOut.plan do
  call SayHello
  except_when context(:silenced)
end
```

These directives can be given blocks if more complex conditional logic is needed.  As with parameter blocks, the `context` method is available inside the block.

### Magic Unit Methods

CarryOut provides some magic to translate unit classes into method names that can replace the `call Class` syntax.  This feature relies on a search strategy to find classes by name.  A very limited strategy is provided out-of-the-box.  This strategy accepts an array of modules and will only find classes that are direct children of any of the provided modules.  The first match gets priority.

Assuming `MyModule1` contains definitions for units `DisplayBanner` and `SayHello`:

```ruby
CarryOut.configure do
  search [ MyModule1 ]
end

plan = CarryOut.plan do
  display_banner { with_text "This is my banner." }
  say_hello { to "World" }
end
```

If the default strategy is insufficient (and it most likely will be), a custom strategy can be provided as a lambda/Proc.  For example, a strategy that works in Rails is to put the following in an initializer:

```ruby
CarryOut.configure do
  search -> (name) { name.constantize }
end
```

## Configuration
The CarryOut global can be configured using `CarryOut#configure`.  It accepts a block containing configuration directives.  At the moment, the only directive is the `search` option described above.

If more than one configuration of CarryOut is needed, the `CarryOut#with_configuration` method can be used to obtain a configured instance of CarryOut.  At the moment, this method accepts a hash of configuration options.  *This will change in a future release, in which this method will be called just like the configure method.*  This method returns an instance that operates just like the CarryOut global, but uses the provided configuration options when creating and running plans.

## Motivation

I've been trying to keep my Rails controllers clean, but I prefer to avoid shoving inter-model business logic inside database models.  The recommendation I most frequently run into is to move that kind of logic into something akin to service objects.  I like that idea, but I want to keep my services small and composable, and I want to separate the "what" from the "how" of my logic.

CarryOut is designed to be a consistent layer of glue between single-purpose or "simple-purpose" units of business logic.  CarryOut describes what needs to be done and which inputs are to be used.  The units themselves worry about how to perform the actual work.  These units tend to have names that describe their intent.  They remain small and easier to test in isolation.  What ends up in my controllers is a process description that that can be comprehended at a glance and remains fairly agnostic to the underlying details of my chosen ORM, job queue, message queue, etc.

I'm building up CarryOut alongside a new Rails application, but my intent is for CarryOut to remain just as useful outside of Rails.  At present, it is not bound in any way to ActiveRecord.  If those sorts of bindings emerge, I intend to provide an add-on gem or an alternate require.

A CarryOut series is synchronous.  Support for asynchronous execution is desired, but not yet planned for a future release.  A series can not loop.  Branching is achievable in a round-about way through the `only_when` and `except_when` conditionals, but this becomes hard to follow in complex plans.  If you find frequent need of complex branching and looping, a full workflow engine might be a better choice than CarryOut.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryanfields/carry_out. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

