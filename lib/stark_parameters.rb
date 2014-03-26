require "active_support/all"
require "rack"
require "rack/test"
require "action_controller/metal/strong_parameters"

module StarkParameters
  def self.included(klass)
    klass.send :extend, ClassMethods
    klass.permitted_params = []
    klass.presence_required_params = []
    klass.presence_optional_params = []
    klass.aliases = {}
  end

  def initialize(*params)
    @params = params.each_with_object(make_strong_parameter({})) do |p, hash|
      hash.merge!(make_strong_parameter(p))
    end
  end

  def params
    make_strong_parameter(permitted_params.merge(required_params)).permit!
  end

  private

  def permitted_params
    self.class.permitted_params.each_with_object({}) do |permitted_param, hash|
      param_key = permitted_param.is_a?(Hash) ? permitted_param.keys.first : permitted_param
      permitted_value = @params.permit(permitted_param).values.first
      hash[(self.class.aliases[param_key] || param_key).to_s] = permitted_value unless permitted_value.nil?
    end
  end

  def required_params
    presence_required_params = self.class.presence_required_params.each_with_object({}) do |required_params, hash|
      param_key = require_one(required_params)
      hash[(self.class.aliases[param_key] || param_key).to_s] = @params[param_key]
    end
    presence_optional_params =  self.class.presence_optional_params.each_with_object({}) do |required_params, hash|
      param_key = require_one(required_params, true)
      hash[(self.class.aliases[param_key] || param_key).to_s] = @params[param_key]
    end
    presence_required_params.merge(presence_optional_params)
  end


  def make_strong_parameter(hash)
    return hash if hash.is_a? ActionController::Parameters
    ActionController::Parameters.new(hash)
  end

  def require_one(to_require, allow_nil = false)
    present_param = to_require.detect {|p| @params.include?(p) }
    value_presence_valid = allow_nil ? true : !@params.stringify_keys[present_param.to_s].nil?
    unless present_param && value_presence_valid
      raise ActionController::ParameterMissing.new(to_require.join(" or "))
    end
    present_param
  end

  module ClassMethods
    attr_accessor :permitted_params, :presence_required_params, :presence_optional_params, :aliases

    def require(required_params, options = {})
      required_params = Array(required_params)
      if new_name = options[:as]
        required_params.each { |rp| @aliases[rp] = new_name }
      end
      if options[:allow_nil]
        @presence_optional_params.push required_params
      else
        @presence_required_params.push required_params
      end
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