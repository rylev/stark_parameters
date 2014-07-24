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

  attr_reader :params

  def initialize(*params)
    @params = params.reduce(make_strong_parameter({})) do |hash, param|
      hash.merge(make_strong_parameter(param))
    end
  end

  def params
    all_params = permitted_params.merge(required_params)
    make_strong_parameter(all_params).permit!
  end

  private

  def permitted_params
    self.class.permitted_params.each_with_object({}) do |permitted_param, hash|
      permitted_key = permitted_param.is_a?(Hash) ? permitted_param.keys.first : permitted_param
      name = self.class.aliases[permitted_key] || permitted_key
      permitted_value = respond_to?(name) ? send(name) : @params.permit(permitted_param)[name]
      hash[name] = permitted_value if @params.has_key?(permitted_key)
    end
  end

  def required_params
    presence_required_params.merge(presence_optional_params)
  end

  def presence_optional_params
    collect_required_params(self.class.presence_optional_params, true)
  end

  def presence_required_params
    collect_required_params(self.class.presence_required_params, false)
  end

  def collect_required_params(keys, allow_nil)
    keys.each_with_object({}) do |required_params, hash|
      required_key = require_one(required_params, allow_nil)

      key = self.class.aliases[required_key] || required_key
      value = respond_to?(key) ? send(key) : @params[required_key]
      hash[key] = value
    end
  end

  def make_strong_parameter(hash)
    return hash if hash.is_a? ActionController::Parameters
    ActionController::Parameters.new(hash)
  end

  def require_one(to_require, allow_nil)
    present_param = to_require.detect{|k| respond_to?(k)} ||
              to_require.detect {|k| @params.include?(k) && (allow_nil || @params[k]) }

    unless present_param
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
      permitted_key = permitted_param.is_a?(Hash) ? permitted_param.keys.first : permitted_param
      if new_name = options[:as]
        @aliases[permitted_key] = new_name
      end
      @permitted_params.push permitted_param
    end
  end
end