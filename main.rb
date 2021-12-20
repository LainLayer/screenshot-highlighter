require 'gosu'
require 'rtesseract'

FILE = ARGV.join(' ').strip

IMAGE = Gosu::Image.new(FILE)

RED   = Gosu::Color.argb(0xff_ff0000)
GREEN = Gosu::Color.argb(0xff_00ff00)
BLUE  = Gosu::Color.argb(0xff_0000ff)

PADDING   = 4
THICKNESS = 3

Element = Struct.new(:x1, :y1, :x2, :y2) do
	def draw(c=RED)
		Gosu.draw_rect(
			x1-THICKNESS,
			y1-THICKNESS,
			x2-x1+(THICKNESS*2),
			THICKNESS, c)
		
		
		Gosu.draw_rect(
			x1-THICKNESS,
			y1-THICKNESS,
			THICKNESS,
			y2-y1+(THICKNESS*2), c)
		
		
		Gosu.draw_rect(
			x1-THICKNESS,
			y2,
			x2-x1+(THICKNESS*2),
			THICKNESS, c)
		
	
		Gosu.draw_rect(
			x2,
			y1-THICKNESS,
			THICKNESS,
			y2-y1+(THICKNESS*2), c)
	end

	def line_to(e)
		st = en = []
		dis = 0
		min = (IMAGE.width**2 + IMAGE.height**2)/2
		corners().each do |corner|
			e.corners().each do |target|
				dis = Math.sqrt(
					(corner[0] - target[0]).abs ** 2 +
					(corner[1] - target[1]).abs ** 2)

				if dis < min
					min = dis
					st = corner
					en = target
				end
			end
		end
		
		return [st[0], st[1], en[0], en[1]]
	end

	def corners
		[
			[x1,y1],
			[x2,y1],
			[x2,y2],
			[x1,y2]
		]
	end

	def under_mouse
		w.x1 < mouse_x and w.x2 > mouse_x and w.y1 < mouse_y and w.y2 > mouse_y
	end
end

data = RTesseract.new(FILE).to_box

words = []

data.each do |word|
	words << Element.new(
		word[:x_start]-4,
		word[:y_start]-4,
		word[:x_end]+4,
		word[:y_end]+4)
end

class Screenshot < Gosu::Window
	def initialize(words)
		super IMAGE.width, IMAGE.height
		@words = words
		self.caption = "Screenshot editor"

		@unselected = []
		@group = []
		@gelem = nil
		@pair = []
		@lines = []
	end

	def button_down(id)
		case id
			when Gosu::KbQ
				close
				
			when Gosu::MsLeft
				@words.each do |w|
					@group << w if under_mouse(w)
				end
				if not @group.empty?
					min_x1 = @group.map { |g| g = g.x1 }.min
					max_x2 = @group.map { |g| g = g.x2 }.max
					min_y1 = @group.map { |g| g = g.y1 }.min
					max_y2 = @group.map { |g| g = g.y2 }.max
									
					@gelem = Element.new(min_x1, min_y1, max_x2, max_y2)
				end
				
			when Gosu::KbReturn
				@unselected << @gelem unless @gelem.nil?
				@group = []
				@gelem = nil
				
			when Gosu::KbX
				@unselected.each do |c|
					@unselected.delete(c) if under_mouse(c)
				end
				
			when Gosu::KbS
				output = "#{FILE.split('.')[0..-2].join('.')}_highlighted.png"
				Gosu.render(IMAGE.width, IMAGE.height) do
					draw()
				end.save(output)
				puts output
				close
				
			when 46, 87
				@unselected.each do |c|
					if under_mouse(c)
						c.x1 -= 5
						c.x2 += 5
						c.y1 -= 5
						c.y2 += 5
					end
				end
				
			when 45, 86
				@unselected.each do |c|
					if under_mouse(c)
						c.x1 += 5
						c.x2 -= 5
						c.y1 += 5
						c.y2 -= 5
					end
				end
				
			when Gosu::KbO
				@unselected = []
				@group = []
				@gelem = nil
				@pair = []
				@lines = []
				
			when Gosu::KbC
				@unselected.each do |c|
					if under_mouse(c)
						@pair << c
						if @pair.length == 2
							@lines << @pair[0].line_to(@pair[1])
							@pair = []
						end
						break
					end
				end
			when Gosu::KbR
				e = Element.new(mouse_x, mouse_y, mouse_x+1, mouse_y+1)
				@group << e
				min_x1 = @group.map { |g| g = g.x1 }.min
				max_x2 = @group.map { |g| g = g.x2 }.max
				min_y1 = @group.map { |g| g = g.y1 }.min
				max_y2 = @group.map { |g| g = g.y2 }.max
									
				@gelem = Element.new(min_x1, min_y1, max_x2, max_y2)
				
		end
	end

	def under_mouse(w)
		w.x1 < mouse_x and w.x2 > mouse_x and w.y1 < mouse_y and w.y2 > mouse_y
	end

	def draw
		IMAGE.draw(0,0)
		@words.each do |w|
			if under_mouse(w)
				w.draw()
				break
			end
		end

		@gelem.draw(GREEN) if not @gelem.nil?

		@unselected.each { |c| c.draw() }

		@pair.each { |p| p.draw(BLUE) }
		
		@lines.each do |l|
			Gosu.draw_quad(
				l[0]-1, l[1]-1, RED,
				l[0]+1, l[1]+1, RED,
				l[2]+1, l[3]+1, RED,
				l[2]-1, l[3]-1, RED)
				
			Gosu.draw_quad(
				l[0]-1, l[1]+1, RED,
				l[0]+1, l[1]-1, RED,
				l[2]+1, l[3]-1, RED,
				l[2]-1, l[3]+1, RED)
		end
		
	end
end

Screenshot.new(words).show
