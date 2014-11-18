北航 ihome 社区第三方验证系统 IAuth Ruby SDK
============================================

# Install(Gem)

```bash
gem install iauth
```

# Install(Bundler)

```bash
echo "gem 'iauth'" >> Gemfile
```

# Usage

```ruby
require 'iauth'
require 'securerandom'
iauth = IAuth.new 'your app id here', 'your app secret here'
state = SecureRandom 8
login_url = iauth.login_url state

# redirect to login url, when logged in, it will redirect to callback url with param verifier and state

# if it redirected to login callback url, use `iauth.auth`, else `iauth.login`
iauth.auth verifier, state
```

# License

MIT License
