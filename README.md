## KindTap Platform Library for Ruby

#### This library currently supports generating a signed authorization header which is required to make requests to KindTap Platform APIs.

### Installation

* Add the following to your Gemfile

`gem 'kindtap-platform-ruby', git: 'https://github.com/KindTap/kindtap-platform-ruby.git', tag: '0.1.0'`

### Example using Faraday

#### Important Notes

* the `host` and `x-kt-date` headers are required
* request body must be a string that matches exactly the body of the HTTP request

```rb
require 'date'
require 'faraday'
require 'json'
require 'kindtap_platform'

host = 'kindtap-platform-host'
date = Time.now.utc

path = '/path/to/api/endpoint/'
service = 'kindtap-platform-service-name'
key = 'kindtap-client-key'
secret = 'kindtap-client-secret'
method = '<http-method>'
headers = {
  'Content-Type' => 'application/json',
  'Host' => host,
  'X-KT-Date' => KindTapPlatform.stringify_date(date),
}
body = JSON.generate({})
query = {}
querystring = URI.encode_www_form(query)

headers['Authorization'] = KindTapPlatform.generate_signed_auth_header(
  service,
  key,
  secret,
  method,
  path,
  date,
  headers,
  body,
  query,
)

session = Faraday.new

response = session.post do |request|
    request.url "https://#{host}#{path}?#{querystring}"
    request.headers = headers
    request.body = body
end

puts response.body
```
