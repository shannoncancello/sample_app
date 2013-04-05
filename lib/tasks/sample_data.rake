namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    User.destroy_all
    Micropost.destroy_all
    make_users
    make_microposts
    make_relationships
  end
end

def make_users
  admin = User.create!(name:     "Example User",
                        username: "Admin",
                       email:    "example@railstutorial.org",
                       password: "foobar",
                       password_confirmation: "foobar")
  admin.toggle!(:admin)
  99.times do |n|
    name  = Faker::Name.name
    username = Faker::Name.name.gsub(" ","_")
    email = "example-#{n+1}@railstutorial.org"
    password  = "password"
    User.create!(name:     name,
                  username: username,
                 email:    email,
                 password: password,
                 password_confirmation: password)
  end
end

def make_microposts
  admin = User.find_by_username "Admin"
  users = User.all(limit: 6)
  50.times do |n|
    attribs = {}
    attribs[:content] = Faker::Lorem.sentence(5)
    if (n+1)%10 == 0
      attribs[:content] = "@Admin #{attribs[:content]}"
      attribs[:in_reply_to] = admin.id
    elsif (n+1)%4 == 0
      attribs[:content] = "d #{attribs[:content]}"
      attribs[:private] = 1
    end
    users.each { |user| user.microposts.create!(attribs) }
  end
end

def make_relationships
  users = User.all
  user  = users.first
  followed_users = users[2..50]
  followers      = users[3..40]
  followed_users.each { |followed| user.follow!(followed) }
  followers.each      { |follower| follower.follow!(user) }
end
