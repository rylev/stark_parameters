# StarkParameters

## Usage

```ruby
raw_parameters = { :email => "john@example.com", :name => "John", :admin => true }
parameters = ActionController::Parameters.new(raw_parameters)

StarkParams::Validator.new(parameters).require(:name, admin: :sudoer).permit(:password).params
# => { name: "John", sudoer: true }
```