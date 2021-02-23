module Tiled
  module AttributeAssignment
    def assign_attributes(new_attributes)
      return if new_attributes.nil? || new_attributes.empty?

      new_attributes.each do |name, value|
        setter = "#{name}="
        if respond_to?(setter)
          send(setter, value)
        else
          raise Tiled::UnknownAttribute.new(self, name)
        end
      end

      self
    end

    alias attributes= assign_attributes
    alias update assign_attributes
  end
end
