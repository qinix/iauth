require 'digest'
require 'time'
require 'httparty'
require 'securerandom'

class IAuth
  def initialize(appId, appSecret, accessToken='', accessSecret='', timeOffset=0)
    @APP_ID = appId
    @APP_SECRET = appSecret
    @ACCESS_URL = 'http://i.buaa.edu.cn/plugin/iauth/access.php'
    @GETUID_URL = 'http://i.buaa.edu.cn/plugin/iauth/getuid.php'
    @ACCESS_TOKEN = accessToken
    @ACCESS_SECRET = accessSecret
    @TIME_OFFSET = timeOffset
  end

  def login_url(state='')
    "http://i.buaa.edu.cn/plugin/iauth/login.php?appid=#{@APP_ID}&state=#{state}"
  end

  def auth(verifier, state='', ip='')
    options = {
      'verifier' => verifier
    }
    options['state'] = state unless state == ''
    options['ip'] = ip unless ip == ''

    # {
    #   'uid' => '...',
    #   'access_token' => '...',
    #   'access_secret' => '...'
    # }
    params = parse_param signed_get @ACCESS_URL, options
    @uid = params['uid']
    @ACCESS_TOKEN = params['access_token']
    @ACCESS_SECRET = params['access_secret']
    params
  end

  def login(verifier, state='', ip='')
    options = {
      'verifier' => verifier
    }
    options['state'] = state unless state == ''
    options['ip'] = ip unless ip == ''

    # {
    #   'uid' => '...',
    #   'access_token' => '...'
    # }
    params = parse_param signed_get @GETUID_URL, options
    @uid = params['uid']
    @ACCESS_TOKEN = params['access_token']
    params
  end

  def get(url, params)
    request('get', url, params)
  end

  def post(url, params)
    request('post', url, params)
  end

  def request(method, url, params)
    nonce = SecureRandom.hex[0..16]
    options = {
      'nonce' => nonce,
      'token' => @ACCESS_TOKEN,
      'hashmethod' => 'MD5',
      'hash' => Digest::MD5.hexdigest(params.sort.map{|p|p.join '='}.join('&'))
    }
    signed_request(method, url, header_options = options, params = params)
  end

private

  def parse_param(param)
    ret = {}
    param.split('&').map do |p|
      kv = p.split('=')
      ret[kv[0]] = kv[1]
    end
    ret
  end

  def signed_get(url, header_options, params={})
    signed_request('get', url, header_options = header_options, params = params)
  end

  def signed_post(url, header_options, params)
    signed_request('post', url, header_options = header_options, params = params)
  end

  def signed_request(method, url, header_options, params)
    now = Time.now.to_i + @TIME_OFFSET
    header = {
      'appid'=> @APP_ID,
      'time'=> now,
      'sigmethod'=> 'MD5',
      'version'=> '2.0'
    }
    header.merge! header_options
    headerStr = header.sort.map{|p|p.join '='}.join '&'
    baseStr = "#{method.upcase}&#{url}&#{headerStr}"
    sig = signature(baseStr, @APP_SECRET)
    header['sig'] = sig

    options = {
      headers: {
        'Authorization' => header.map{|k,v|"#{k}=\"#{v}\""}.join(',')
      },
      query: params
    }
    if method.upcase == 'GET'
      HTTParty.get(url, options).body
    elsif method.upcase == 'POST'
      HTTParty.post(url, options).body
    end
  end

  def signature(baseStr, secret)
    Digest::MD5.hexdigest "#{baseStr}&#{secret}"
  end

end
