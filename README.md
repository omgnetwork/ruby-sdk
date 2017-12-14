# OmiseGO

OmiseGO is a Ruby SDK meant to communicate with an OmiseGO Wallet setup.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omisego'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omisego

## Initialization

The OmiseGO SDK can either be initialized on a global level, or a on client basis. However, initializing on a global level is not necessarily what you want and won't be thread-safe. If using Rails, Sticking a `client` method in your `ApplicationController` will probably be a better solution than using an initializer as shown below.

In the end, the choice is yours and the optimal solution depends on your needs.

### Global init

```
# config/initializers/omisego.rb
OmiseGO.configure do |config|
  config.access_key = ENV['OMISEGO_ACCESS_KEY']
  config.secret_key = ENV['OMISEGO_SECRET_KEY']
  config.base_url   = ENV['OMISEGO_BASE_URL']
end
```

If initialized this way, the `OmiseGO` classes can be used without specifying the client.

```
user = OmiseGO::User.find(provider_user_id: 'some_uuid')
```

### Client init

With this approach, the client needs to be passed in every call and will be used as the call initiator.

```
client = OmiseGO::Client.new(
  access_key: ENV['OMISEGO_ACCESS_KEY'],
  secret_key: ENV['OMISEGO_SECRET_KEY'],
  base_url:   ENV['OMISEGO_BASE_URL']
)

user = OmiseGO::User.find(provider_user_id: 'some_uuid', client: client)
```

## Usage

All the calls below will communicate with the OmiseGO wallet specified in the `base_url` configuration. They will either return an instance of `OmiseGO:Error` or of the appropriate model (`User`, `Balance`, etc.), see [the list of models](#models) for more information.

__The method `#error?` can be used on any model to check if it's an error or a valid result.__

### Managing Users

#### Find

Retrieve a user from the Wallet API.

```
user = OmiseGO::User.find(
  provider_user_id: 'some_uuid'
)
```

Returns either:
- An `OmiseGO::User` instance
- An `OmiseGO::Error` instance

#### Create

Create a user in the Wallet API database. The `provider_user_id` is how a user is identified and cannot be changed later on.

```
user = OmiseGO::User.create(
  provider_user_id: 'some_uuid',
  username: 'john@doe.com',
  metadata: {
    first_name: 'John',
    last_name: 'Doe'
  }
)
```

Returns either:
- An `OmiseGO::User` instance
- An `OmiseGO::Error` instance

#### Update

Update a user in the Wallet API database. All fields need to be provided and the values in the Wallet database will be replaced with the sent ones (behaves like a HTTP `PUT`). Sending `metadata: {}` in the request below would remove the `first_name` and `last_name` fields for example.

```
user = OmiseGO::User.update(
  provider_user_id: 'some_uuid',
  username: 'jane@doe.com',
  metadata: {
    first_name: 'Jane',
    last_name: 'Doe'
  }
)
```

Returns either:
- An `OmiseGO::User` instance
- An `OmiseGO::Error` instance

### Managing Sessions

#### Login

Login a user and retrieve an `authentication_token` that can be passed to a mobile client to make calls to the Wallet API directly.

```
auth_token = OmiseGO::User.login(
  provider_user_id: 'some_uuid'
)
```

Returns either:
- An `OmiseGO::AuthenticationToken` instance
- An `OmiseGO::Error` instance

### Managing Balances

- [All](#All)
- [Credit](#Credit)
- [Debit](#Debit)

#### All

Retrieve a list of addresses (with only one address for now) containing a list of balances.

```
address = OmiseGO::Balance.all(
  provider_user_id: 'some_uuid'
)
```

Returns either:
- An `OmiseGO::Address` instance
- An `OmiseGO::Error` instance

#### Credit

Transfer the specified amount (as an integer, down to the `subunit_to_unit`) from the master wallet to the specified user's wallet.

```
address = OmiseGO::Balance.credit(
  provider_user_id: 'some_uuid',
  token_id: 'OMG:5e9c0be5-15d1-4463-9ec2-02bc8ded7120',
  amount: 10_000,
  metadata: {}
)
```

To use the primary balance of a specific account instead of the master account's as the sending balance, specify an `account_id`:

```
address = OmiseGO::Balance.credit(
  account_id: 'account_uuid',
  provider_user_id: 'some_uuid',
  token_id: 'OMG:5e9c0be5-15d1-4463-9ec2-02bc8ded7120',
  amount: 10_000,
  metadata: {}
)
```

#### Debit

Transfer the specified amount (as an integer, down to the `subunit_to_unit`) from the specified user's wallet back to the master wallet.

```
address = OmiseGO::Balance.debit(
  provider_user_id: 'some_uuid',
  token_id: 'OMG:5e9c0be5-15d1-4463-9ec2-02bc8ded7120',
  amount: 10_000,
  metadata: {}
)
```

To use the primary balance of a specific account instead of the master account as the receiving balance, specify an `account_id`:

```
address = OmiseGO::Balance.debit(
  account_id: 'account_uuid',
  provider_user_id: 'some_uuid',
  token_id: 'OMG:5e9c0be5-15d1-4463-9ec2-02bc8ded7120',
  amount: 10_000,
  metadata: {}
)
```

By default, points won't be burned and will be returned to the account's primary balance (either the master's balance or the account's specified with `account_id`). If you wish to burn points, send them to a burn address. By default, a burn address identified by `'burn'` is created for each account which can be set in the `burn_balance_identifier` field:

```
address = OmiseGO::Balance.debit(
  account_id: 'account_uuid',
  burn_balance_identifier: 'burn',
  provider_user_id: 'some_uuid',
  token_id: 'OMG:5e9c0be5-15d1-4463-9ec2-02bc8ded7120',
  amount: 10_000,
  metadata: {}
)
```

### Getting settings

#### All

Retrieve the settings from the Wallet API.

```
settings = OmiseGO::Setting.all
```

Returns either:
- An `OmiseGO::Setting` instance
- An `OmiseGO::Error` instance

## Models

Here is the list of all the models available in the SDK with their attributes.

### `OmiseGO::Address`

Attributes:
- `address` (string)
- `balances` (array of OmiseGO::Balance)

### `OmiseGO::Balance`

Attributes:
- `amount` (integer)
- `minted_token` (OmiseGO::MintedToken)

### `OmiseGO::AuthenticationToken`

Attributes:
- `authentication_token` (string)

### `OmiseGO::List`

Attributes:
- `data` (array of models)

### `OmiseGO::MintedToken`

Attributes:
- `symbol` (string)
- `name` (string)
- `subunit_to_unit` (integer)

### `OmiseGO::User`

Attributes:
- `id` (string)
- `username` (string)
- `provider_user_id` (string)
- `metadata` (hash)

### `OmiseGO::Error`

Attributes:
- `code` (string)
- `description` (string)
- `messages` (hash)

## Live Tests

Live tests are recorded using VCR. However, they have been updated to hide any access/secret key which means deleting them and re-running the live tests will fail. It is first required to update the `spec/env.rb` file with real keys. Once the VCR records have been re-generated, do not forget to replace the `Authorization` header in all of them using the base64 encoding of fake access and secret keys.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
