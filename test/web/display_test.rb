require 'yeah/web'

class DisplayTest < Test
  include Yeah::Web

  def setup
    `document.body.appendChild(document.createElement('canvas'))`

    @object = Display.new(
      canvas_selector: 'canvas',
      size: V[400, 400]
    )
  end

  def test_implements_display_interface
    methods = %i[color_at transform translate scale rotate push pop line
      stroke_rectangle fill_rectangle begin_shape end_shape move_to line_to
      stroke_shape fill_shape clear image image_cropped fill_text stroke_text]
    methods.each { |m| assert_respond_to(@object, m) }

    %i[size width height fill_color stroke_color stroke_width].each do |prop|
      assert_respond_to(@object, prop)
      assert_respond_to(@object, "#{prop}=")
    end
  end

  def test_color_at_gets_color_at_position
    position = V[5, 5]

    @object.fill_color = C[0, 128, 255]
    @object.fill_rectangle(position, V[1, 1])

    assert_equal(@object.color_at(position), @object.fill_color)
  end

  def test_fill_rectangle_fills_area_with_color
    position = V[100, 200]
    size =     V[100, 100]

    @object.fill_color = C[255, 128, 0]
    @object.fill_rectangle(position, size)

    topleft = position
    middle = V[position.x + size.x / 2, position.y + size.y / 2]
    bottomright = V[position.x + size.x - 1, position.y + size.y - 1]

    [topleft, middle, bottomright].each do |position|
      assert_equal(@object.fill_color.value, @object.color_at(position).value)
    end
  end
end
