module Kharon
  module Processors

    # Processor to validate boxes. It has the :at_most and :at_least with the default ones.
    # @author Vincent Courtois <courtois.vincent@outlook.com>
    class BoxProcessor < Kharon::Processor

      Kharon.add_processor(:box, Kharon::Processors::BoxProcessor)

      # Checks if the given key is a box (geofences) or not. A box is composed of four numbers (positive or negative, decimal or not) separed by commas.
      # @param [Object] key the key about which verify the type.
      # @param [Hash]   options a hash of options passed to this method (see documentation to know which options pass).
      # @example Validates a key so it has to be a box.
      #   @validator.box(:a_box)
      def process(key, options = {})
        before_all(key, options)
        match?(key, /^(?:[+-]?\d{1,3}(?:\.\d{1,7})?,?){4}$/) ? store(key, nil, options) : raise_type_error(key, "Box")
      end

      # Tries to store the associated key in the filtered key, transforming it with the given process.
      # @param [Object] key the key associated with the value to store in the filtered datas.
      # @param [Proc]   process a process (lambda) to execute on the initial value. Must contain strictly one argument.
      # @param [Hash]   options the options applied to the initial value.
      def store(key, process, options)
        if(options.has_key?(:at_least))
          box_contains?(key, validator.datas[key], options[:at_least])
        end
        if(options.has_key?(:at_most))
          box_contains?(key, options[:at_most], validator.datas[key])
        end
        super(key, ->(item){parse_box(key, validator.datas[key])}, options)
      end

      private

      # Verify if a box contains another box.
      # @param [Object] container any object that can be treated as a box, container of the other box
      # @param [Object] contained any object that can be treated as a box, contained in the other box
      # @return [Boolean] TRUE if the box is contained in the other one, FALSE if not.
      def box_contains?(key, container, contained)
        container = parse_box(key, container)
        contained = parse_box(key, contained)
        result = ((container[0][0] <= contained[0][0]) and (container[0][1] <= container[0][1]) and (container[1][0] >= container[1][0]) and (container[1][1] >= container[1][1]))
        raise_error(type: "box.containment", contained: contained, container: container, key: key) unless result
      end

      # Parses a box given as a string of four numbers separated by commas.
      # @param [String] box the string representing the box.
      # @return [Array] an array of size 2, containing two arrays of size 2 (the first being the coordinates of the top-left corner, the second the ones of the bottom-right corner)
      def parse_box(key, box)
        if box.kind_of?(String)
          begin
            raw_box = box.split(",").map(&:to_f)
            box = [[raw_box[0], raw_box[1]], [raw_box[2], raw_box[3]]]
          rescue
            raise_error(type: "box.format", key: "key", value: box)
          end
        end
        return box
      end
    end
  end
end