# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

NUMBERS = [1, 2, 3]
COLORS = ['red', 'green', 'purple']
SHADINGS = ['outlined', 'shaded', 'filled']
SHAPES = ['oval', 'diamond', 'squiggle']

# seeding Cardface with initial values for each card type:
# (Number, Color, Shading, and Shape) is added to table Cardface.
NUMBERS.each do |num|
  COLORS.each do |col|
    SHADINGS.each do |shd|
      SHAPES.each do |shp|
        c = Cardface.new
        c.number = num
        c.color = col
        c.shading = shd
        c.shape = shp
        c.save
      end
    end
  end
end # finished inserting cardface data rows
