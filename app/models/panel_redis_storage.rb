class PanelRedisStorage
  def initialize(user_id:, key:)
    @user_id = user_id
    @key = key
  end

  def add(value)
    establish_connection
    @redis.sadd redis_key(@key), value
    close_connection
  end

  def get
    establish_connection
    result = @redis.smembers(redis_key(@key))
    close_connection
    result
  end

  def remove(value)
    establish_connection
    @redis.srem redis_key(@key), value
    close_connection
  end

  def delete_all
    establish_connection
    @redis.del redis_key(@key)
    close_connection
  end

  private

  def establish_connection
    configs = {
      url: Rails.configuration.redis_storage
    }

    if Rails.configuration.redis_is_on_heroku == true
      configs[:ssl_params] = { verify_mode: OpenSSL::SSL::VERIFY_NONE }
    end

    @redis = Redis.new(
      **configs
    )
  end

  def close_connection
    @redis.quit
  end

  def redis_key(key)
    "#{@user_id}-#{key}"
  end
end
