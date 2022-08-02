# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

20.times do |i| 
  u = User.new(email:"tester#{i+1}@gmail.com", password:"123123", username:"tester#{i+1}")
  u.confirm 
  u.save 
end

50.times do |i|
  p = Post.create(
    user_id: (i+1)%20, 
    title: Faker::Lorem.sentence, 
    body:"<div>#{ Faker::Lorem.paragraphs.join('<br>') }</div>")
  p.enqueue
  p.publish if i % 2 == 0
end

5.times do |i|
  User.find(i+1).add_role :admin
end
