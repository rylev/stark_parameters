# StarkParameters

## Usage

Include `StarkParameters` in any class with which you want to be able to validate params.

You can require, permit and alias params.

StarkParameters uses [Strong Parameters](https://github.com/rails/strong_parameters)
under the hood so missing require params also raise an `ActionController::ParameterMissing` error.
Also nested permits work just as they do in Strong Parameters

## Example

```ruby
# Rails Controller

class UsersContoller < ApplicationController
  def index
    @users = User.find_by(UserIndexParams.new(params).params)
  end

  def create
    @user = User.create!(UserCreateParams.new(params).params)
  end
end

class UserIndexParams
  include StarkParameters

  require :email, as: :email_id
end

class UserCreateParams
  include StarkParameters

  require :email, as: :email_id
  permit  :name, as: name_id
  require  [:facebook_id, :google_id]
end
```

In the index action an email would be required but would be passed to `find_by`
as `email_id`.

In the create action an `email` would be required but passed in as `email_id`,
name would be permitted and passed as `name_id` if present, and either a
`facebook_id` or a `google_id` would be required.