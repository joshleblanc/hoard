module Hoard
  module Serializable
    def serialize
      instance_variables.reduce({}) do |memo, var|
        memo[var] = instance_variable_get(var)
        memo
      end
    end

    def to_s
      serialize.to_s
    end

    def inspect
      serialize.to_s
    end
  end
end
