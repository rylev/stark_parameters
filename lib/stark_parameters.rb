module StarkParameters

  def self.included(klass)
    klass.send :extend, ClassMethods
    klass.required_params = []
    klass.permitted_params = []
    klass.aliases = {}
  end

  def initialize(params)
    @params = make_strong_parameter(params)
  end

  def params
    make_strong_parameter(permitted_params.merge(required_params))
  end

  private

  def permitted_params
    self.class.permitted_params.each_with_object({}) do |permitted_param, hash|
      param_key = permitted_param.is_a?(Hash) ? permitted_param.keys.first : permitted_param
      permitted_value = @params.permit(permitted_param).values.first
      hash[(self.class.aliases[param_key] || param_key).to_s] = permitted_value if permitted_value
    end
  end

  def required_params
    self.class.required_params.each_with_object({}) do |required_params, hash|
      param_key = require_one(required_params)
      hash[(self.class.aliases[param_key] || param_key).to_s] = @params[param_key]
    end
  end


  def make_strong_parameter(hash)
    return hash if hash.is_a? ActionController::Parameters
    ActionController::Parameters.new(hash)
  end

  def require_one(to_require)
    present_param = to_require.detect {|p| @params.include?(p) }
    unless present_param
      raise ActionController::ParameterMissing.new(to_require.join(" or "))
    end
    present_param
  end

  module ClassMethods
    attr_accessor :required_params, :permitted_params, :aliases

    def require(required_params, options = {})
      required_params = Array(required_params)
      if new_name = options[:as]
        required_params.each { |rp| @aliases[rp] = new_name }
      end
      @required_params.push required_params
    end

    def permit(permitted_param, options = {})
      if new_name = options[:as]
        param_key = if permitted_param.is_a? Hash
          permitted_param.keys.first
        else
          permitted_param
        end

        @aliases[param_key] = new_name
      end
      @permitted_params.push permitted_param
    end
  end
end