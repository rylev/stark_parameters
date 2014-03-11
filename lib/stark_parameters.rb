module StarkParameters
  class Validator

    def initialize(params)
      @params = make_strong_parameter(params)
      @permitted_params = make_strong_parameter({})
    end

    def params
      make_strong_parameter(@permitted_params.empty? ? @params : @permitted_params)
    end

    def require(*to_require)
      to_require.each { |required_param| @params.require(required_param) }
      self
    end

    def require_as(aliases)
      params = @params.dup
      aliases.each do |old_key, new_key|
        params.require(old_key)
        params[new_key] = params.delete(old_key)
      end
      @params = make_strong_parameter(params)
      self
    end

    def require_one(*to_require)
      unless to_require.any? {|p| @params.include?(p) }
        raise ActionController::ParameterMissing.new(to_require.join(" or "))
      end
      self
    end

    def permit(*to_permit)
      @permitted_params = @permitted_params.merge(@params.permit(*to_permit))
      self
    end

    def permit_as(aliases)
      @permitted_params = aliases.each_with_object({}) do |(old_key, new_key), hash|
        if value = @params[old_key]
          hash[new_key] = value
        end
      end.merge(@permitted_params)
      self
    end

    private

    def make_strong_parameter(hash)
      return hash if hash.is_a? ActionController::Parameters
      ActionController::Parameters.new(hash)
    end
  end
end