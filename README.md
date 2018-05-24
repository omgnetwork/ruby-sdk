# OmiseGO

OmiseGO is a Ruby SDK meant to communicate with an OmiseGO eWallet setup.

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

```ruby
# config/initializers/omisego.rb
OmiseGO.configure do |config|
  config.access_key = ENV['OMISEGO_ACCESS_KEY']
  config.secret_key = ENV['OMISEGO_SECRET_KEY']
  config.base_url   = ENV['OMISEGO_BASE_URL']
end
```

If initialized this way, the `OmiseGO` classes can be used without specifying the client.

```ruby
user = OmiseGO::User.find(provider_user_id: 'some_uuid')
```

### Logging

The Ruby SDK comes with the possibility to log requests to the eWallet. For example, within a Rails application, the following can be defined:

```ruby
# config/initializers/omisego.rb
OmiseGO.configure do |config|
  config.access_key = ENV['OMISEGO_ACCESS_KEY']
  config.secret_key = ENV['OMISEGO_SECRET_KEY']
  config.base_url   = ENV['OMISEGO_BASE_URL']
  config.logger     = Rails.logger
end
```

This would provide the following in the logs:

```
[OmiseGO] Request: POST login
User-Agent: Faraday v0.13.1
Authorization: [FILTERED]
Accept: application/vnd.omisego.v1+json
Content-Type: application/vnd.omisego.v1+json

{"provider_user_id":"aeab0d51-b3d9-415d-98ef-f9162903f024"}

[OmiseGO] Response: HTTP/200
Connection: close
Server: Cowboy
Date: Wed, 14 Feb 2018 04:35:52 GMT
Content-Length: 140
Content-Type: application/vnd.omisego.v1+json; charset=utf-8
Cache-Control: max-age=0, private, must-revalidate

{"version":"1","success":true,"data":{"object":"authentication_token","authentication_token":[FILTERED]}}
```

### Client init

With this approach, the client needs to be passed in every call and will be used as the call initiator.

```ruby
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

Retrieve a user from the eWallet API.

```ruby
user = OmiseGO::User.find(
  provider_user_id: 'some_uuid'
)
```

Returns either:
- An `OmiseGO::User` instance
- An `OmiseGO::Error` instance

#### Create

Create a user in the eWallet API database. The `provider_user_id` is how a user is identified and cannot be changed later on.

```ruby
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

Update a user in the eWallet API database. All fields need to be provided and the values in the eWallet database will be replaced with the sent ones (behaves like a HTTP `PUT`). Sending `metadata: {}` in the request below would remove the `first_name` and `last_name` fields for example.

```ruby
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

Login a user and retrieve an `authentication_token` that can be passed to a mobile client to make calls to the eWallet API directly.

```ruby
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

```ruby
address = OmiseGO::Wallet.all(
  provider_user_id: 'some_uuid'
)
```

Returns either:
- An `OmiseGO::Wallet` instance
- An `OmiseGO::Error` instance

#### Credit

Transfer the specified amount (as an integer, down to the `subunit_to_unit`) from the master wallet to the specified user's wallet. In the following methods, an idempotency token is used to ensure that one specific credit/debit occurs only once. The implementer is responsible for ensuring that those idempotency tokens are unique - sending the same one two times will prevent the second transaction from happening.

```ruby
address = OmiseGO::Wallet.credit(
  provider_user_id: 'some_uuid',
  token_id: 'OMG:5e9c0be5-15d1-4463-9ec2-02bc8ded7120',
  amount: 10_000,
  idempotency_token: "123",
  metadata: {}
)
```

To use the primary balance of a specific account instead of the master account's as the sending balance, specify an `account_id`:

```ruby
address = OmiseGO::Wallet.credit(
  account_id: 'account_uuid',
  provider_user_id: 'some_uuid',
  token_id: 'OMG:5e9c0be5-15d1-4463-9ec2-02bc8ded7120',
  amount: 10_000,
  idempotency_token: "123",
  metadata: {}
)
```

#### Debit

Transfer the specified amount (as an integer, down to the `subunit_to_unit`) from the specified user's wallet back to the master wallet.

```ruby
address = OmiseGO::Wallet.debit(
  provider_user_id: 'some_uuid',
  token_id: 'OMG:5e9c0be5-15d1-4463-9ec2-02bc8ded7120',
  amount: 10_000,
  idempotency_token: "123",
  metadata: {}
)
```

To use the primary balance of a specific account instead of the master account as the receiving balance, specify an `account_id`:

```ruby
address = OmiseGO::Wallet.debit(
  account_id: 'account_uuid',
  provider_user_id: 'some_uuid',
  token_id: 'OMG:5e9c0be5-15d1-4463-9ec2-02bc8ded7120',
  amount: 10_000,
  idempotency_token: "123",
  metadata: {}
)
```

By default, points won't be burned and will be returned to the account's primary balance (either the master's balance or the account's specified with `account_id`). If you wish to burn points, send them to a burn address. By default, a burn address identified by `'burn'` is created for each account which can be set in the `burn_wallet_identifier` field:

```ruby
address = OmiseGO::Wallet.debit(
  account_id: 'account_uuid',
  burn_wallet_identifier: 'burn',
  provider_user_id: 'some_uuid',
  token_id: 'OMG:5e9c0be5-15d1-4463-9ec2-02bc8ded7120',
  amount: 10_000,
  idempotency_token: "123",
  metadata: {}
)
```

### Getting settings

#### All

Retrieve the settings from the eWallet API.

```ruby
settings = OmiseGO::Setting.all
```

Returns either:
- An `OmiseGO::Setting` instance
- An `OmiseGO::Error` instance


### Listing transactions

#### Params

Some parameters can be given to the two following methods to customize the returned results. With them, the list of results can be paginated, sorted and searched.

- `page`: The page you wish to receive.
- `per_page`: The number of results per page.
- `sort_by`: The sorting field. Available values: `id`, `status`, `from`, `to`, `created_at`, `updated_at`
- `sort_dir`: The sorting direction. Available values: `asc`, `desc`
- `search_term`: A term to search for in ALL of the searchable fields. Conflict with `search_terms`, only use one of them. See list of searchable fields below (same as `search_terms`).
- `search_terms`: A hash of fields to search in:

```ruby
{
  search_terms: {
    from: "address_1"
  }
}
```

Available values: `id`, `idempotency_token`, `status`, `from`, `to`

#### All

Get the list of transactions from the eWallet API.

```ruby
transaction = OmiseGO::Transaction.all
```

Returns either:
- An `OmiseGO::List` instance of `OmiseGO::Transaction` instances
- An `OmiseGO::Error` instance

Parameters can be specified in the following way:

```ruby
transaction = OmiseGO::Transaction.all(params: {
  page: 1,
  per_page: 10,
  sort_by: 'created_at',
  sort_dir: 'desc',
  search_terms: {
    from: "address_1",
    to: "address_2",
    status: "confirmed"
  }
})
```

#### All for user

Get the list of transactions for a specific provider user ID from the eWallet API.

```ruby
transaction = OmiseGO::Transaction.all(
  params: {
    provider_user_id: "some_uuid"
  }
)
```

Returns either:
- An `OmiseGO::List` instance of `OmiseGO::Transaction` instances
- An `OmiseGO::Error` instance

Parameters can be specified in the following way:

```ruby
transaction = OmiseGO::Transaction.all(params: {
  provider_user_id: "some_uuid",
  page: 1,
  per_page: 10,
  sort_by: 'created_at',
  sort_dir: 'desc',
  search_terms: {
    from: "address_1",
    status: "confirmed"
  }
})
```

Since those transactions are already scoped down to the given user, it is NOT POSSIBLE to specify both `from` AND `to` in the `search_terms`. Doing so will result in the API ignoring both of those fields for the search.

## Models

Here is the list of all the models available in the SDK with their attributes.

### `OmiseGO::Wallet`

Attributes:
- `address` (string)
- `balances` (array of OmiseGO::Wallet)

### `OmiseGO::Wallet`

Attributes:
- `amount` (integer)
- `token` (OmiseGO::Token)

### `OmiseGO::AuthenticationToken`

Attributes:
- `authentication_token` (string)

### `OmiseGO::Pagination`

Attributes
- `per_page` (integer)
- `current_page` (integer)
- `first_page?` (boolean)
- `last_page?` (boolean)

### `OmiseGO::List`

Attributes:
- `data` (array of models)
- `pagination` (OmiseGO::Pagination)

### `OmiseGO::Token`

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

### `OmiseGO::Exchange`

- `rate` (integer)

### `OmiseGO::TransactionSource`

- `address` (string)
- `amount` (integer)
- `token` (`OmiseGO::Token`)

### `OmiseGO::Transaction`

- `id` (string)
- `idempotency_token` (string)
- `amount` (integer)
- `token` (`OmiseGO::Token`)
- `from` (`OmiseGO::TransactionSource`)
- `to` (`OmiseGO::TransactionSource`)
- `exchange` (`OmiseGO::Exchange`)
- `status` (string)
- `created_at` (string)
- `updated_at` (string)

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

# License

The OmiseGO Ruby SDK is released under the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).
