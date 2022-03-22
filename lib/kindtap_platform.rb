DEBUG = true

module KindTapPlatform
  class << self
    ALGO_PRE = "KT1"
    ALGO = "#{ALGO_PRE}-HMAC-SHA256"
    AUTH_TYPE = "#{ALGO_PRE.downcase}_request"
    REGION = "us"

    EQUALS_ENC = URI.encode_www_form_component("=")

    EQUALS_EXPR = /=/
    MULTI_WS_EXPR = /[ ][ ]+/

    def HMACSHA256(key, data)
      OpenSSL::HMAC.digest("SHA256", key, data)
    end

    def SHA256(data)
      OpenSSL::Digest.hexdigest("SHA256", data)
    end

    def build_canon_headers(headers)
      parsed = headers.reduce({}) { |acc, (k, v)|
        acc.merge({ k.to_s.downcase => v.to_s.gsub(MULTI_WS_EXPR, " ") })
      }
      sorted = parsed.sort_by { |k, v| k.to_s.ord }
      sorted.reduce("") { |acc, cur| acc += "#{cur[0]}:#{cur[1]}\n" }
    end

    def build_canon_query(params)
      parsed = params.reduce({}) { |acc, (k, v)|
        acc.merge({ k.to_s => v.to_s.gsub(EQUALS_EXPR, EQUALS_ENC) })
      }
      sorted = parsed.sort_by { |k, v| k.to_s.ord }
      encoded = sorted.reduce([]) { |acc, cur|
        acc.push("#{URI.encode_www_form_component(cur[0])}=#{URI.encode_www_form_component(cur[1])}")
      }
      encoded.join("&")
    end

    def build_canon_uri(uri)
      parts = uri.split("/").filter { |p| p.length > 0 }
      if parts.length == 0
        return "/"
      end
      encoded = parts.reduce([]) { |acc, cur|
        acc.push(URI.encode_www_form_component(URI.encode_www_form_component(cur)))
      }
      "/#{encoded.join("/")}/"
    end

    def build_signed_headers(headers)
      parsed = headers.reduce([]) { |acc, cur| acc.push([cur[0].downcase]) }
      parsed.join(";")
    end

    def debug(*args)
      if DEBUG
        puts args
      end
    end

    def generate_signature_v1(service, secret, method, uri, date, headers, body, params)
      #debug({
      #  "service" => service,
      #  "secret" => secret,
      #  "method" => method,
      #  "uri" => uri,
      #  "date" => date,
      #  "headers" => headers,
      #  "body" => body,
      #  "params" => params,
      #})

      canon_headers = build_canon_headers(headers)
      debug({ "canon_headers" => canon_headers })
      canon_query = build_canon_query(params)
      debug({ "canon_query" => canon_query })
      canon_uri = build_canon_uri(uri)
      debug({ "canon_uri" => canon_uri })
      signed_headers = build_signed_headers(headers)
      debug({ "signed_headers" => signed_headers })

      canon_request = [
        method.upcase,
        canon_uri,
        canon_query,
        canon_headers,
        signed_headers,
        SHA256(body),
      ].join("\n")
      debug({ "canon_request" => canon_request })
      canon_request_hash = SHA256(canon_request)
      debug({ "canon_request_hash" => canon_request_hash })

      cred_date = stringify_date(date, false)
      cred_scope = "#{cred_date}/#{REGION}/#{service}/#{AUTH_TYPE}"

      msg_to_sign = [
        ALGO,
        stringify_date(date),
        cred_scope,
        canon_request_hash,
      ].join("\n")
      debug({ "msg_to_sign" => msg_to_sign })

      k0 = HMACSHA256("#{ALGO_PRE}#{secret}", cred_date)
      k1 = HMACSHA256(k0, REGION)
      k2 = HMACSHA256(k1, service)
      k3 = HMACSHA256(k2, AUTH_TYPE)

      HMACSHA256(k3, msg_to_sign).unpack("H*")[0]
    end

    def generate_signed_auth_header(service, key, secret, method, uri, date, headers, body, params)
      cred_date = stringify_date(date, false)
      cred_scope = "#{cred_date}/#{REGION}/#{service}/#{AUTH_TYPE}"
      signed_headers = build_signed_headers(headers)
      signature = generate_signature_v1(service, secret, method, uri, date, headers, body, params)
      debug({ "signature" => signature })
      "#{ALGO} Credential=#{key}/#{cred_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"
    end

    def stringify_date(date, full = true)
      date.strftime(full ? "%Y%m%dT%H%M%SZ" : "%Y%m%d")
    end
  end
end
