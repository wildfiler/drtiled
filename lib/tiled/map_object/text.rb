module Tiled
  class MapObject
    class Text < MapObject
      HALIGN = {
        left: 0,
        center: 1,
        right: 2,
        justify: 0,
      }.freeze

      VALIGN = {
        bottom: 0,
        center: 1,
        top: 2,
      }.freeze

      attributes :id, :x, :y, :width, :height, :name, :type, :object_type, :visible,
                 :fontfamily, :pixelsize, :bold, :italic, :underline, :strikeout, :kerning, :wrap, :color, :halign, :valign

      def initialize(map, attrs, children)
        super(map, attrs, children)

        text_child = children.find { |child| child[:name] == 'text' }
        text_attrs = text_child[:attributes]

        attributes.add(
          text: text_child.dig(:children, 0, :data),
          fontfamily: text_attrs['fontfamily'],
          pixelsize: text_attrs['pixelsize'],
          wrap: text_attrs['wrap'] == '1',
          bold: text_attrs['bold'] == '1',
          italic: text_attrs['italic'] == '1',
          underline: text_attrs['underline'] == '1',
          strikeout: text_attrs['strikeout'] == '1',
          kerning: text_attrs['kerning'] == '1',
          color: Color.from_tiled_rgba(text_attrs['color']),
          halign: text_attrs['halign']&.to_sym || :left,
          valign: text_attrs['valign']&.to_sym || :top,
        )
      end

      def to_h
        {
          primitive_marker: :label,
          text: text,
          font: fontfamily,
          x: x + x_offset,
          y: y + y_offset,
          size_px: pixelsize,
          alignment_enum: HALIGN.fetch(halign, 0),
          vertical_alignment_enum: VALIGN.fetch(valign, 0),
        }
      end

      private

      def x_offset
        @x_offset ||= case halign
        when :center
          width.half
        when :right
          width
        else
          0
        end
      end

      def y_offset
        @y_offset ||= case valign
        when :center
          height.half
        when :bottom
          0
        else
          height
        end
      end
    end
  end
end
