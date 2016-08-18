# PATCH - the block beginning on line 70 was commented out because the maintainer doesn't know why it's there.
# I want it so I've uncommented it.
module Gruff
  class Base
   # Draws horizontal background lines and labels
    def draw_line_markers
      return if @hide_line_markers

      @d = @d.stroke_antialias false

      if @y_axis_increment.nil?
        # Try to use a number of horizontal lines that will come out even.
        #
        # TODO Do the same for larger numbers...100, 75, 50, 25
        if @marker_count.nil?
          (3..7).each do |lines|
            if @spread % lines == 0.0
              @marker_count = lines
              break
            end
          end
          @marker_count ||= 4
        end
        @increment = (@spread > 0 && @marker_count > 0) ? significant(@spread / @marker_count) : 1
      else
        # TODO Make this work for negative values
        @marker_count = (@spread / @y_axis_increment).to_i
        @increment = @y_axis_increment
      end
      @increment_scaled = @graph_height.to_f / (@spread / @increment)

      # Draw horizontal line markers and annotate with numbers
      (0..@marker_count).each do |index|
        y = @graph_top + @graph_height - index.to_f * @increment_scaled

        @d = @d.fill(@marker_color)

        # FIXME(uwe): Workaround for Issue #66
        #             https://github.com/topfunky/gruff/issues/66
        #             https://github.com/rmagick/rmagick/issues/82
        #             Remove if the issue gets fixed.
        y += 0.001 unless defined?(JRUBY_VERSION)
        # EMXIF

        @d = @d.line(@graph_left, y, @graph_right, y)
        #If the user specified a marker shadow color, draw a shadow just below it
        unless @marker_shadow_color.nil?
          @d = @d.fill(@marker_shadow_color)
          @d = @d.line(@graph_left, y + 1, @graph_right, y + 1)
        end

        marker_label = BigDecimal(index.to_s) * BigDecimal(@increment.to_s) +
            BigDecimal(@minimum_value.to_s)

        unless @hide_line_numbers
          @d.fill = @font_color
          @d.font = @font if @font
          @d.stroke('transparent')
          @d.pointsize = scale_fontsize(@marker_font_size)
          @d.gravity = EastGravity

          # Vertically center with 1.0 for the height
          @d = @d.annotate_scaled(@base_image,
                                  @graph_left - LABEL_MARGIN, 1.0,
                                  0.0, y,
                                  label(marker_label, @increment), @scale)
        end
      end

      @additional_line_values.each_with_index do |value, i|
        @increment_scaled = @graph_height.to_f / (@maximum_value.to_f / value)

        y = @graph_top + @graph_height - @increment_scaled
      
        @d = @d.stroke(@additional_line_colors[i] || @colors[i])
        @d = @d.line(@graph_left, y, @graph_right, y)
      
        @d.fill = @additional_line_colors[i] || @colors[i]
        @d.font = @font if @font
        @d.stroke('transparent')
        @d.pointsize = scale_fontsize(@marker_font_size)
        @d.gravity = EastGravity
        @d = @d.annotate_scaled( @base_image,
                          100, 20,
                          -10, y - (@marker_font_size/2.0),
                          "", @scale)
      end

      @d = @d.stroke_antialias true
    end
  end
end
