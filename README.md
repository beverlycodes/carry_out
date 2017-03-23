# CarryOut

CarryOut facilitates connecting single-purpose units of logic into larger workflows via a small DSL.  Each unit can further extend the DSL with parameter methods.  Artifacts and errors are collected as the workflow executes and are returned in a result bundle upon completion.

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
```
class SayHello < CarryOut::Unit
    def execute(result)
        puts "Hello, World!"
    end
end
```

CarryOut can then be used to create an execution plan using the unit.
```
plan = CarryOut.will(SayHello)
```

Run the plan using:
```
result = plan.execute
```

### Parameters
Execution units can be passed parameters statically during plan creation, or dynamically via a block.

Redefine the example above to greet someone by name:
```
class SayHello < CarryOut::Unit
    parameter :to, :name
    
    def execute(result)
        puts "Hello, #{@name}!"
    end
end
```

Define the plan as:
```
plan = CarryOut
    .will(SayHello)
    .to("Ryan")
    
# or

plan = CarryOut
    .will(SayHello)
    .to { "Ryan" }
```

And execute the same way as above.

### Artifacts and References
Execution units can publish artifacts to the plan's result.  Parameter blocks can be used to pass these artifacts on to subsequent execution units in the plan.

```
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
```
plan = CarryOut
    .will(AddToCart, as: :cart)
    .items([ item1, item2, item3])
    .then(CalculateSubtotal, as: :invoice)
    .items { |refs| refs[:cart][:contents] }
    
plan.execute do |result|
    puts "Subtotal: #{result.artifacts[:invoice][:subtotal]}"
end
```

## Motivation

I've been trying to keep my Rails controllers clean, but I prefer to avoid shoving inter-model business logic inside database models.  The recommendation I most frequently run into is to move that kind of logic into something akin to service objects.  I like that idea, but I want to keep my services small and composable, and I want to separate the "what" from the "how" of my logic.

CarryOut is designed to be a consistent layer of glue between single-purpose or "simple-purpose" units of business logic.  CarryOut describes what needs to be done and what inputs are to be used.  The units themselves worry about how to perform the actual work.  These units tend to have names that describe their intent.  They remain small and easier to test.  What ends up in my controllers is a process description that that can be comprehended at a glance and remains fairly agnostic to the underlying details of my chosen ORM, job queue, message queue, etc.

I'm building up CarryOut alongside a new Rails application, but my intent is for CarryOut to remain just as useful outside of Rails.  At present, it isn't bound in any way to things like ActiveRecord.  If those sorts of bindings emerge, I'll provide an add-on gem or an alternate require.

CarryOut's workflows don't support asynchronous execution units yet.  The workflows can't branch or loop.  These are features I hope to provide in the future.  Feature requests are welcome.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/carry_out. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

